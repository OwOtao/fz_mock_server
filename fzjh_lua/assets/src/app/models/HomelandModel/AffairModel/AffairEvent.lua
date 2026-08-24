local AffairEvent = {}

function AffairEvent:UpgradeHouse(affair)
    local event = {}

    event.handleEvent =
        function()

        local role = User:getRole()
        local map = role:getCurrMap()
        local ret ,msg =  map:cheakUserMapIsRebuild()
        if ret == false then
            PopText(msg.."房屋升级")
            return
        end

        PopupLayerController:showLayer(
            "HouseEnlargeLayer",
            function(layer)
                layer:setSuccessCallback(function ()
                    local roomAffairLayer = PopupLayerController:getLayer("RoomAffairLayer")
                    roomAffairLayer:hideLayer()
                end)
                layer:showLayer(affair)
            end
        )
    end

    return event
end

--@desc:缴纳地税
--@author:Liang SongQiang
--@time:2018-08-10 21:16:03
--@affair:[src.app.models.HomelandModel.AffairModel.Affair#Affair]
function AffairEvent:payLandTax(affair)
    local event = {}

    event.handleEvent =
        function()
        local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")

        local dialog = DialogALayer:getInstance()
        dialog:show("你确定要缴纳吗？")
        dialog:setButton1(
            "确定",
            function()
                affair:processEvent(
                    function(data)
                        PopText("成功缴纳地税")
                    end
                )
            end
        )
        dialog:setButton2(
            "取消",
            function()
                dialog:hide()
            end
        )
        dialog:setWeChatVisible(false)
    end

    return event
end

function AffairEvent:paySalaryForPuRen(affair, transTime)
    local event = {}

    event.handleEvent =
        function()
        local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
        local dialog = DialogALayer:getInstance()
        local cost = affair.affair_val.pay_base
        local unit = affair.affair_val.pay_unit
        local npcId = affair.affair_val.rwId
        local payMethod = {yinpiao = "银票", yuanbao = "元宝"}
        dialog:show("你确定要花费" .. cost * transTime .. payMethod[unit] .. "给" .. affair.affair_val.name .. "发放薪水吗？")
        dialog:setButton1(
            "确定",
            function()
                affair:processEvent(
                    function(data)
                        --@RefType [src.app.models.role.Role#Role]
                        local role = User:getRole()

                        local map = role:getCurrMap()

                        local npc = map:getRole(npcId)
                        local roleExtra = npc.extra
                        if npc and roleExtra.naoshi ~= 0 then
                            roleExtra.naoshi = 0
                            npc.conditionAndResults = {}
                            local HomelandRoleTemplate =
                                require("app.models.HomelandModel.HomelandRoleModel.HomelandRoleTemplate")
                            HomelandRoleTemplate:initRoleConditions(npc, map)
                        else
                            print("副本没有这个人 id = " .. npcId)
                        end

                        PopText("发薪成功")
                    end
                )
            end
        )
        dialog:setButton2(
            "取消",
            function()
                dialog:hide()
            end
        )
        dialog:setWeChatVisible(false)
    end

    return event
end

function AffairEvent:askToBuy(affair)
    local event = {}
    --@RefType [src.app.models.role.Role#Role]
    if affair.from_id == tostring(User:getUserId()) then
        local DiQiModel = require("app.models.HomelandModel.DiQiModel")
        event.handleEvent =
            switch(
            affair.state,
            {
                [0] = function()
                    return function()
                        local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
                        local dialog = DialogALayer:getInstance()
                        dialog:show("你确定要取消求购吗？")
                        dialog:setButton1(
                            "确定",
                            function()
                                affair:setProcessType(0)
                                affair:processEvent(
                                    function(data)
                                        PopText("获得" .. affair.affair_val.number .. "银票")
                                    end
                                )
                            end
                        )
                        dialog:setButton2(
                            "取消",
                            function()
                                dialog:hide()
                            end
                        )
                        dialog:setWeChatVisible(false)
                    end
                end,
                [1] = function()
                    event.handleEventConditon = function()
                        local role = User:getRole()
                        if not role:checkCanBuyTwoOrMoreThings({["jian111"] = 1}) then
                            return false
                        end

                        return true
                    end

                    return function()
                        affair:setProcessType(1)
                        affair:processEvent(
                            function(data)
                                local upload = {}
                                upload.dpId = affair.affair_val.dpId
                                DiQiModel:getDiQi(upload)
                                PopText("获得地契")
                            end
                        )
                    end
                end,
                [2] = function()
                    return function()
                        affair:setProcessType(2)
                        affair:processEvent(
                            function(data)
                                PopText("获得" .. affair.affair_val.number .. "银票")
                            end
                        )
                    end
                end
            }
        )
    else
        event.handleEvent =
            function()
            local DiQiModel = require("app.models.HomelandModel.DiQiModel")
            local dpId = affair.affair_val.dpId
            DiQiModel:checkManagementCost(
                dpId,
                function(day, total_pay)
                    if DEBUG_MODE == 1 then
                        print(day,total_pay)
                    end
                    local title =
                    "你准备同意别人的购地请求，在此之前需要先缴清未支付的地税，否则交易无法继续。打算现在就缴清地税" .. total_pay .. "元宝吗？"
                    local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
                    local dialog = DialogALayer:getInstance()
                    dialog:hide()
                    dialog:show(title)
                    dialog:setButton1(
                        "确定",
                        function()
                            affair:setProcessType(1)
                            affair:processEvent(
                                function(data)
                                    PopText("获得" .. affair.affair_val.number .. "银票")
                                    if data then 
                                        local locationStr=data.data
                                        local refreshData={dpId="nil",location=locationStr}
                                        local FangQiModel = require("app.models.HomelandModel.FangQiModel")
                                        FangQiModel:updateInfo(refreshData)
                                    end
                                end
                            )
                        end
                    )

                    dialog:setButton2(
                        "取消",
                        function()
                            dialog:hide()
                        end
                    )
                end
            )
            
        end

        event.handleEvent1 =
            function()
            affair:setProcessType(2)
            affair:processEvent(
                function(data)
                    PopText("你拒绝了此次求购。")
                end
            )
        end
    end

    return event
end

function AffairEvent:showTypeEvent(affair,callback)
    local event = {}

    event.handleEvent = function()
        affair:processEvent(callback)
    end

    return event
end

function AffairEvent:invitation(affair)
    local event = {}

    event.handleEventConditon1 = function()
        local role = User:getRole()
        if not role:checkCanBuyTwoOrMoreThings({["jian111"] = 1}) then
            return false
        end

        return true
    end

    event.handleEvent1 =
        function()
        affair:processEvent(
            function(data)
                local array = {}
                array.userName = affair.affair_val.from_name
                array.mid = affair.affair_val.mid
                array.toMapId = affair.affair_val.toMapId
                array.from_id = affair.from_id
                local YaoQingHanModel = require("app.models.HomelandModel.YaoQingHanModel")
                YaoQingHanModel:getYaoQingHan(array)

                PopText("你获得了一封邀请函。")
            end
        )
    end

    event.handleEvent =
        function(data)
        affair:processEvent(
            function(data)
                PopText("您拒绝了此封邀请函")
            end
        )
    end

    return event
end

function AffairEvent:abnormalLeave(affair)
    local event = {}

    if affair.affair_val.number == 0 then
        event.handleEvent = function()
            affair:processEvent()
        end
    elseif affair.affair_val.number > 0 then
        event.handleEvent =
            function()
            affair:processEvent(
                function(data)
                    local payMethod = {yinpiao = "银票", yuanbao = "元宝"}
                    PopText("获得" .. affair.affair_val.number .. payMethod[affair.affair_val.unit])
                    local extra = affair.affair_val.extra
                    if extra then
                        local HomelandRoleUtil = require("app.models.HomelandModel.HomelandRoleUtil")

                        HomelandRoleUtil:deleteRole({id = affair.affair_val.rwId, extra = extra})
                    end
                end
            )
        end
    else
        print("检查为什么返回的薪水为负数")
    end

    return event
end

function AffairEvent:puRenLeave(affair)
    local event = {}
    event.handleEvent =
        function()
        affair:processEvent(
            function(data)
                local extra = affair.affair_val.extra
                if extra then
                    local HomelandRoleUtil = require("app.models.HomelandModel.HomelandRoleUtil")

                    HomelandRoleUtil:deleteRole({id = affair.affair_val.rwId, extra = extra})
                end
            end
        )
    end

    return event
end

function AffairEvent:newYearVisited(affair)
    local event = {}
    event.handleEvent =
        function()
        if affair.btnName=="领取礼品" then
            if User:getRole():getAttr("weight") - #User:getRole():getItems() < 2 then
                PopText("背包空间不足，无法领取奖励")
                return
            end
        end
        affair:processEvent(
            function(data)
                local giftType=tonumber(affair.affair_val.gift_type)
                if giftType == 1 or giftType==2 then
                    local rewardRsid={[1]="2020chuanmen1",[2]="2020chuanmen2"}
                    local SpringFestival = require("app.models.SpringFestival.SpringFestival")
                    SpringFestival:getNewYearRewardByRsid(rewardRsid[giftType])
                    SpringFestival:getHouserNewYearExtraReward(giftType)
                end
            end
        )
    end

    return event
end

function AffairEvent:menkeWarning(affair)
    local event = {}
    event.handleEvent =
        function()

            local role = User:getRole()
            local map = role:getCurrMap() 
            local currRole = map:getRole(affair.affair_val.rwId)

            if MapIsEmpty(currRole) then
                assert(false,"门客跑了不应该存在该事件")
            end

            local roleExtra = currRole.extra

            if roleExtra.naoshi ~= 0 then
                PopText("请先付清门客薪水")
                return 
            end

            local HomelandRoleUtil = require("app.models.HomelandModel.HomelandRoleUtil")
            if not HomelandRoleUtil:checkRoleIsInRightRoom(currRole,map) then
                PopText("连客房都不提供，还想让门客干活？")
                return
            end

            local roomAffairLayer = PopupLayerController:getLayer("RoomAffairLayer")
            roomAffairLayer:hideLayer()

            PopupLayerController:showLayer(
                "ChooseButtonLayer",
                function(layer)
                    local DispatchTaskManager = require("app.models.HomelandModel.DispatchTaskModel.DispatchTaskManager")
                    local taskList = DispatchTaskManager:getDoDispatchTaskList(currRole)
    
                    local params = {}
                    for i, task in ipairs(taskList) do
                        params["btnName" .. i] = task.taskname
                        params["btnFunc" .. i] =
                            function()
                            local ret, msg = DispatchTaskManager:checkCanDoTaskById(map, task.taskid, currRole)
                            if not ret then
                                PopText(msg)
                                return
                            end
    
                            PopupLayerController:showLayer(
                                "DispatchTaskLayer",
                                function(layer)
                                    layer:showLayer(currRole, task.taskid, map,function()
                                        affair:processEvent(
                                            function()
                                            end
                                        )
                                    end)
                                end
                            )
                        end
                    end
    
                    layer:initLayer(
                        "你要派遣" .. currRole.name .. "去做什么",
                        params.btnName1,
                        params.btnFunc1,
                        params.btnName2,
                        params.btnFunc2,
                        params.btnName3,
                        params.btnFunc3
                    )
                end
            )
    end

    return event
end

return AffairEvent
0000000000