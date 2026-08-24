--@desc 门客相关功能

--@SuperType [src.app.models.map.MapHandle.Modules.BaseModule#BaseModule]
local RetainerModule = class("RetainerModule", require("app.models.map.MapHandle.Modules.BaseModule"))

--@RefType [src.app.models.HomelandModel.DispatchTaskModel.DispatchTaskManager#DispatchTaskManager]
local DispatchTaskManager = require("app.models.HomelandModel.DispatchTaskModel.DispatchTaskManager")
local HomelandRoleUtil = require("app.models.HomelandModel.HomelandRoleUtil")
--@desc 子模块
RetainerModule.childModule = {}

--@desc 条件结果的方法
RetainerModule.doResult = {
    ["派遣"] = function(map, result, environment)
        local currRole = environment.currRole

        local Role = require("app.models.role.Role")
        currRole = Helper:tableCover(Role:create(), environment.currRole)

        PopupLayerController:showLayer(
            "ChooseButtonLayer",
            function(layer)
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
                                layer:showLayer(currRole, task.taskid, map)
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
    end,
    ["派遣任务进度"] = function(map, result, environment)
        local zhiTiao = environment.currRole
        local textList = requireWithEncrypt("script.others.familylist")["派遣事件列表"]

        local npcId = zhiTiao.npcId
        if not npcId then
            if DEBUG_MODE == 1 then
                assert(false, "纸条生成ID出错")
            end

            PopText("ERROR!")
            
            return
        end

        local percent, taskId,speedRate,startTime,endTime = DispatchTaskManager:getDispatchTaskProgressByTaskId(npcId)

        local text_tb = textList[taskId]


        local list
        if speedRate == 0  then
            list = text_tb.dispatch1
        elseif speedRate == 1 then
            list = text_tb.dispatch3
        elseif speedRate == 2 then
            list = text_tb.dispatch2
        elseif speedRate == 3 then
            list = text_tb.dispatch4
        else
            assert(false,"派遣任务进度查看，代码有问题，派遣任务不知道是否成功"..taskId)
        end

        local text = string.split(list,";")
        
        -- 10%<事件进度《25%，时，点击纸条，显示对应文本2
        -- 25%<事件进度《60%，时，点击纸条，显示对应文本3
        -- 60%<事件进度《80%，时，点击纸条，显示对应文本4
        -- 80%《事件进度，点击纸条，显示对应文本5sw
        local str
        if percent < 10 then
            str = text[1]
        elseif percent >= 10 and percent < 25 then
            str = text[2]
        elseif percent >= 25 and percent < 60 then
            str = text[3]
        elseif percent >= 60 and percent < 80 then
            str = text[4]
        elseif percent >= 80 then
            str = text[5]
        end
        
        local startDate=Helper:date("%m",startTime).."月"..Helper:date("%d",startTime).."日"..Helper:date("%H",startTime).."时"
        local endDate=Helper:date("%m",endTime).."月"..Helper:date("%d",endTime).."日"..Helper:date("%H",endTime).."时"
        local str1="门客于"..startDate.."出发，预计"..endDate.."归来。"
        local HomelandDesc = require("app.models.HomelandModel.HomelandDesc")
        PopupLayerController:showLayer("LetterFormatLayer",function (layer)
            layer:setText1(HomelandDesc:subChengHuText("#ch#"))
            layer:setText2(zhiTiao.npcName)
            layer:setDesc("\t\t"..str)
            layer:setTimeDesc(str1)
            layer:show()
        end)

    end,
    ["派遣奖励"] = function(map, result, environment)
        local npcId = string.split(environment.currRole.id, "reward_package_")[2]

        if not npcId then
            assert(false, "包裹生成ID出错，解析出错")
        end

        DispatchTaskManager:getReward(map, npcId)
    end,
    ["副本门客"] = function(map, result, environment)
        --@desc [src.app.models.role.Role#Role]
        local role = User:getRole()
        local HomelandUtil = require("app.models.HomelandModel.HomelandUtil")
        if HomelandUtil:sysIsOpen() == false then
            return
        end
        
        if HomelandUtil:isJobTypeFromFlag("guanjia001") == false then
            PopText("请先雇佣一个管家，再招募门客！")
            return
        end
        
		local roleData = {}
		local name = environment.currRole.name
		local sex = environment.currRole.sex
        local age = environment.currRole.age
        local looks = environment.currRole.looks
		local jobType = "menke001"
		local MobanId = result.arg2
		local characterId = result.arg3
		local trait = Helper:getDef(result.arg4,"")
		
        --测试数据，让策划加
		local traitVal = Helper:getDef(result.arg5,0) 
		local price_unit = Helper:getDef(result.arg6,"yinpiao")
		local price = Helper:getDef(result.arg7,0)*14
		local defaultZhongCheng = Helper:getDef(result.arg8,0)
        local shenShi = result.arg9

        --@desc 成功的条件结果集
        local successStr = result.arg11

        --@desc 失败的条件结果集
        local failStr = result.arg12

        if shenShi == nil then
            assert(false,"npc 身世信息每填，检查资源。")
        end
        
        local mobanSkill = HomelandRoleUtil:getUploadWebRoleSkillArray(MobanId)
        
        trait = string.split(trait,";")
        local speedZhongCheng ,leave_day = HomelandRoleUtil:getSpeedZhongChengAndLeaveDay(jobType,characterId)

        roleData.name = name
        roleData.sex = sex
		roleData.age = age
        roleData.looks = looks
		roleData.modal = MobanId
		roleData.jobType = jobType
		roleData.character = characterId
        roleData.traitVal = traitVal
	    roleData.trait1 = Helper:getDef(trait[1],"") 
        roleData.trait2 = Helper:getDef(trait[2],"")
        roleData.trait3 = Helper:getDef(trait[3],"")
		roleData.leave_day = leave_day
		roleData.price_unit = price_unit
		roleData.price = price
		roleData.speedZhongCheng = speedZhongCheng
		roleData.defaultZhongCheng = defaultZhongCheng
        roleData.shenShi = shenShi
        roleData.mobanSkill = mobanSkill
        roleData.extra = {
            inheritFlag = environment.currRole.id
        }

        local mid = role:getHouseId()
        
        local PuRenModel = require("app.models.HomelandModel.HomelandRoleModel.PuRenModel")
        PuRenModel:clear()
        PuRenModel:setMid(mid)
        PuRenModel:setNpcId(0)
        PuRenModel:setZhongCheng(0)
        PuRenModel:push(roleData)

        PopupLayerController:showLayer(
            "EmployDscLayer",
            function(layer)
                layer:setButtonFunc(function ()
                    --@RefType [src.app.models.role.Role#Role]
                    local role = User:getRole()
                    local mid = role:getHouseId()
                    if mid == nil then
                        PopText("少侠，您还没自己的房子呢！")
                        return
                    end
                    
                    PuRenModel:employeeNpc(1,function ()
                        role:setInheritFlag(environment.currRole.id,1)
                        if successStr then
                            map:doNoRoleResults(successStr,environment)
                        end
                        layer:hideLayer()
                    end)
                end)

                layer:showLayer(roleData)
            end
        )
	end,
    ["招募门客"] = function(map, result, environment)
        --@RefType [src.app.models.HomelandModel.HomelandRoleModel.EmployDataModel#EmployDataModel]
        local EmployDataModel = require("app.models.HomelandModel.HomelandRoleModel.EmployDataModel")

        local MenKeModel = require("app.models.HomelandModel.HomelandRoleModel.MenKeModel")
        --@desc [src.app.models.role.Role#Role]
        local role = User:getRole()
        local HomelandUtil = require("app.models.HomelandModel.HomelandUtil")
        if HomelandUtil:sysIsOpen() == false then
            return
        end            
        if HomelandUtil:isJobTypeFromFlag("guanjia001") == false then
            PopText("请先雇佣一个管家，再招募门客！")
            return
        end
        local npcId = environment.currRole.id
        local mid = role:getHouseId()
        if mid == nil then
            PopText("少侠，你还没房子呢。")
            return
        end
        MenKeModel:clear()
        MenKeModel:setMid(mid)
        MenKeModel:setNpcId(npcId)

        MenKeModel:initEmployList(function (result,msg)
            if result == false then
                PopText(msg)
                return
            end
            EmployDataModel:setEmployModel(MenKeModel)
            PopupLayerController:showLayer("HomelandRoleEmployLayer",function ( layer )
                layer:showLayer()
                layer:setTextTitle("门客招募")
                layer:setBackButtonVisible(false)
                layer:setReplaceButtonVisible(false)
                if DEBUG_MODE == 1 then
                    layer:setReplaceButtonVisible(true)
                end
                layer:setTextMoneyVisible(false)
                layer:setTextBackVisible(true)
                layer:setPanelBack(true)
            end)
        end)
    end,

    ["飞鸽传书"] = function(map, result, environment)
        local player = User:getRole()

        local tasks = player:getAttr("tasks")

        local zhiTiao = environment.currRole

        local npcId = zhiTiao.npcId
        if not npcId then
            if DEBUG_MODE == 1 then
                assert(false, "纸条生成ID出错")
            end
            PopText("ERROR!")
            return
        end

        local taskEndTime
        for taskId, task in pairs(tasks) do
            if task.state == TASK_STATE_DISPATCH and task.npcId == npcId then
                taskEndTime=task.endTime or "0"
            end
        end
        local function useFeiGe(endTime)
            local endTime=endTime
            if player:getItemCount("mkpqwp1")>=1 then
                PopText("您消耗了一张信纸") 
                local outText={"YEL你望着窗外沉思片刻，从书案上拿起了笔，迅速写了一封书信塞入信鸽脚上的小竹筒中，片刻间，放飞的信鸽已不见踪影。"}
                local timeStr=Helper:date("%H",endTime).."时"..Helper:date("%M",endTime).."分"
                outText[2]="YEL没过多久，听得屋檐外扑棱了两声，一只信鸽迅速的落在了你的书案上，还带有一封书信。拆开信件，上书：在下将于"..timeStr.."回到府上，勿念。"
                PopupLayerController:showLayer(
                    "GlobalShadeLayer",
                    function(layer)
                        layer:showLayer()
                        layer:setPopText("")
                    end
                )
                local i = 1
                map:setSchedule(function (tag)
                    RichPrint("main", outText[i])
                    if i == #outText then
                        player:addItemCount("mkpqwp1", -1)
                        PopupLayerController:hideLayer(
                            "GlobalShadeLayer",
                            function(layer)
                                layer:hideLayer()
                            end
                        )
                    end
                    i = i + 1
                end,2,0,#outText)
            else
                PopText("缺少信纸，无法书写。")
            end
        end

        local str="#nn#此番出行已有些时候，不知是否顺利，是否给#nn#写一封书信，询问一下现况，什么时候能回到府上？"
        str=string.gsub(str,"#nn#",zhiTiao.npcName)
        local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
        local dialog = DialogALayer:getInstance()
        dialog:hide()
        dialog:show(str)
        dialog:setButton1("确定", function()
            useFeiGe(taskEndTime)
        end)
        
        dialog:setButton2("取消", function()
            dialog:hide()
        end)
    end, 
}

--@desc:
--@author:Liang SongQiang
--@time:2018-04-27 15:03:02
function RetainerModule:entryMap(map, currTime)
    if PRINT_MODE == 1 then
        print("EntryMap(): id: " .. map.id, "name: " .. map.name)
    end

    self:checkDispatchTask(map, currTime)
end

--@desc:检查派遣任务相关任务物品是否需要生成和删除
--@author:Liang SongQiang
--@time:2018-06-04 20:29:48
--@map:[src.app.models.map.BaseMap#BaseMap]
function RetainerModule:checkDispatchTask(map, currTime)
    --@RefType [src.app.models.role.Role#Role]
    local role = User:getRole()

    -- local fq = role:getHomelandAttr("fq")

    -- --@desc 如果不是自己的副本，不用考虑包裹的生成
    if map:getMapType() ~= MAP_TYPE.MYHOME then
        return
    end

    DispatchTaskManager:checkNeedLockRoom(map)

    local dispatchTask = role:getAttr("DispatchTask")

    local taskReward = dispatchTask.taskReward

    if not MapIsEmpty(taskReward) then
        for k, reward in pairs(taskReward) do
            --@desc 判断副本是否存在包裹
            local package = map.roles["reward_package_" .. reward.npcId]
            if not package then
                print("RetainerModule:checkDispatchTask(map, currTime),createRewardPackage", reward.npcId,reward.roomId)
                DispatchTaskManager:createRewardPackage(map, reward.npcId,reward.roomId)

                --设置地图状态锁
                map:addMapLock("dispatch"..reward.npcId,"您有派遣任务未完成或者有奖励未领取，无法进行")
            end
        end
    end

    local tasks = role:getAttr("tasks")

    for taskId, task in pairs(tasks) do
        if task.state == TASK_STATE_DISPATCH then
            assert(task.npcId, "派遣任务结构没有 npcId,请检查代码。" .. taskId)
            
            local npcs = map:getRoles()

            --@desc 修复存档回档的情况
            if npcs[task.npcId] == nil then
                DispatchTaskManager:repairTaskDataNpcIsNull(map,task)
            else
                local zt = map.roles["zt_" .. task.npcId]
                if not zt then
                    print("RetainerModule:checkDispatchTask(map, currTime),createZhiTiao", task.npcId)
                    DispatchTaskManager:createZhiTiao(map, task.npcId)
                end
            end

        end
    end

    map:setSchedule(
        function()
            --@desc 检查派遣任务
            DispatchTaskManager:checkTaskFinish(map)
        end,
        1
    )
end

return RetainerModule000000