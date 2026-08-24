--@desc 管家相关功能

--@SuperType [src.app.models.map.MapHandle.Modules.BaseModule#BaseModule]
local GuanJiaModule = class("GuanJiaModule", require("app.models.map.MapHandle.Modules.BaseModule"))
local MapInfo = require("app.models.map.MapInfo")
local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
local HomelandRoleUtil = require("app.models.HomelandModel.HomelandRoleUtil")

--@RefType [src.app.models.HomelandModel.HomelandRoomUtil#HomelandRoomUtil]
local HomelandRoomUtil = require("app.models.HomelandModel.HomelandRoomUtil")
--@RefType [src.app.models.HomelandModel.FurnitureModel.FurnitureModel#FurnitureModel]
local FurnitureModel = require("app.models.HomelandModel.FurnitureModel.FurnitureModel")
--@RefType [src.app.models.HomelandModel.HomelandDesc#HomelandDesc]
local HomelandDesc = require("app.models.HomelandModel.HomelandDesc")

--@desc 条件结果的方法
GuanJiaModule.doResult = {
    ["初始管家交谈"] = function(map, result, environment)
        local text = HomelandDesc:getGuanJiaOrginTalkDesc(environment.currRole)
        RichPrint("main", text)
    end,
    ["初始管家雇佣"] = function(map, result, environment)
        local currRole = environment.currRole
        local gjData = {
            name = currRole.name,
            sex = currRole.sex,
            age = currRole.age,
            looks = currRole.looks,
            defaultZhongCheng = currRole.defaultZhongCheng,
            jobType = currRole.jobType,
            speedZhongCheng = currRole.speedZhongCheng,
            price = currRole.price,
            price_unit = currRole.price_unit,
            modal = currRole.modal,
            character = currRole.character,
            trait1 = currRole.trait1,
            trait2 = currRole.trait2,
            trait3 = currRole.trait3,
            leave_day = currRole.leave_day,
            shenShi = currRole.shenShi,
            mobanSkill = currRole.mobanSkill
        }

        local employData = {
            hid = 0,
            objId = "guanjia1001",
            mid = map.mid,
            push_data = gjData,
            npcId = 0
        }
        
        HttpManagerEx:viewCurrencyByType("yinpiao", User:getRole():getCurrencyVersion(),function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    local dialog = DialogALayer:getInstance()
                    local commands = Resource:getColorTb()
                    dialog:show("雇佣该管家要花" .. currRole.price .. "银票，是否雇佣？RED（管家雇佣后无法辞退，请慎重选择）","当前拥有银票:"..data.number)
                    dialog:setDescColor(commands["YEL"].color)
                    dialog:setRichText("雇佣该管家要花" .. currRole.price .. "银票，是否雇佣？RED（管家雇佣后无法辞退，请慎重选择）")
                    dialog:setButton1(
                        "确定",
                        function()
                            HomelandRoleUtil:employeNpc(
                                employData,
                                function(data)
                                    local FangQiModel = require("app.models.HomelandModel.FangQiModel")
                                    FangQiModel:updateInfo({isDispose = true})
                                    map:removeRoomRole(environment.currRoomId, currRole.id)

                                    dialog:hide()
                                    -- Helper:print_lua_table(role)
                                    if map:getMapType() == MAP_TYPE.MYHOME then
                                        local role = clone(gjData)
                                        role = HomelandRoleUtil:initHomelandMapRole(role, map)
                                        --把雇佣的人物加到副本,房间 fjId
                                        local fjId = data.fjId
                                        print("fjId = ", fjId)
                                        role.id = employData.objId
                                        if map.roles[employData.objId] then
                                            map.roles[employData.objId] = nil
                                        end
                                        map:createRole(role)

                                        map:addRoomRole(fjId, employData.objId)

                                        map:addPersonJobCount(gjData.jobType,1)
                                        local HomelandUtil = require("app.models.HomelandModel.HomelandUtil")
                                        HomelandUtil:updateRoleFlag(map)

                                        map.__MapLayer:delayRefreshMap()

                                        local chenHaoText = HomelandDesc:subChengHuText("#ch#")
                                        RichPrint(
                                            "main",
                                            "YEL" ..
                                                role.name ..
                                                    "：" .. chenHaoText .. "，我既然成了您的管家，便多说几句吧，在这房屋之中，您可以随时呼唤小的，一些闲杂琐事，直接找我即可，勿需劳您大驾。"
                                        )
                                        User:getRole():setInheritFlag("chushiGjName", nil)
                                    else
                                        User:getRole():setInheritFlag("haveGj",1)
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
                    dialog:setWeChatVisible(false)
                else
                PopText(errmsg)
                end
            else
                PopText(errmsg)
            end
        end, IS_SHOW_WAITING)
    end,
    ["拒绝初始管家"] = function(map, result, environment)
        local currRole = environment.currRole
        local currRoleId = currRole.id
        local roomId = environment.currRoomId
        local dialog = DialogALayer:getInstance()
        local text = "RED你确定要拒绝该名管家吗？NOR\nYEL如果拒绝，可以前往长安城的关中书院重新招募新的管家。NOR"
        dialog:show(text)
        dialog:setRichText(text)
        dialog:setButton1(
            "确定",
            function()
                local FangQiModel = require("app.models.HomelandModel.FangQiModel")
                FangQiModel:updateInfo({isDispose = true})
                map:removeRoomRole(roomId, currRoleId)
                MainControllLayer:getLayer("MapLayer"):delayRefreshMap()
                User:getRole():setInheritFlag("chushiGjName", nil)
                RichPrint(
                    "main",
                    "YEL" ..
                    currRole.name ..
                    "：看来是你我二人没有主仆之缘了。如果日后你要招募管家，可前往长安城的关中书院招募，老朽告辞了。")
            end
        )
        dialog:setButton2(
            "取消",
            function()
                dialog:hide()
            end
        )
    end,
    ["雇佣管家"] = function(map, result, environment)
        local EmployDataModel = require("app.models.HomelandModel.HomelandRoleModel.EmployDataModel")
        local GuanJiaModel = require("app.models.HomelandModel.HomelandRoleModel.GuanJiaModel")
        local role = User:getRole()
        local HomelandUtil = require("app.models.HomelandModel.HomelandUtil")
        if HomelandUtil:sysIsOpen() == false then
            return
        end

        local mid = role:getHouseId()

        if mid == nil then
            PopText("少侠，你还没房子呢。")
            return
        end

        local traitValue = result.arg2 --特点值
        local sex = "男"
        if tonumber(result.arg3) == 2 then
            sex = "女"
        end
        
        local npcId = environment.currRole.id

        GuanJiaModel:clear()
        GuanJiaModel:setMid(mid)
        GuanJiaModel:setNpcId(npcId)
        GuanJiaModel:setTraitValue(traitValue)
        GuanJiaModel:setSex(sex)

        GuanJiaModel:initEmployList(function ()
            EmployDataModel:setEmployModel(GuanJiaModel)
            PopupLayerController:showLayer("HomelandRoleEmployLayer",function ( layer )
                layer:showLayer()
                layer:setTextTitle("雇佣管家")
                layer:setBackButtonVisible(true)
                layer:setReplaceButtonVisible(true)
                layer:setTextMoneyVisible(true)
                layer:setTextBackVisible(false)
                layer:setPanelBack(false)
            end)
        end)
    end,
    ["管家交谈"] = function(map, result, environment)
        local HomelandDesc = require("app.models.HomelandModel.HomelandDesc")
        local currRole = environment.currRole
        local characterId = currRole.character --先获取人物性格

        local jobType = currRole.jobType

        local objId = currRole.id
        local mid = map.mid

        local jobTypeAttr = HomelandRoleUtil:getRoleTypeData(jobType)

        --@RefType [src.app.models.role.Role#Role]
        local role = User:getRole()

        local fq = role:getHomelandAttr("fq")

        local isHome = false
        if fq and fq.mid == map.mid then
            isHome = true
        end
        local currRoleStatus = HomelandRoleUtil:getRoleCurrStatus(currRole)
        if isHome then
            if role:getDayFlag("第一次管家交谈") == 0 then
                local Gossipzhongcheng1 = HomelandRoleUtil:getCharacterFactor(jobType).Gossipzhongcheng1
                local Gossipzhongcheng = HomelandRoleUtil:getCharacterAttr(characterId).Gossipzhongcheng
        
                local value = Gossipzhongcheng * Gossipzhongcheng1
        
                local text = HomelandDesc:getGrowthText(value, currRole.name) --忠诚度成长文本
                HttpManagerEx:updateEmployRoleData(
                    objId,
                    mid,
                    "chat",
                    value,
                    0,
                    function(status, errcode, errmsg, data)
                        if status == 200 then
                            if errcode == 0 then
                                print(data.defaultZhongCheng)
                                HomelandRoleUtil:setHomeLandRoleData(jobType, data.defaultZhongCheng)
                                HomelandRoleUtil:updateFidelity(data.defaultZhongCheng, currRole)
                                HomelandRoleUtil:DeblockRoleTrait(data, data.trait)
                                local firstText = HomelandDesc:getGuanJiaDayFirstTalk(currRole)
                                RichPrint("main", firstText)
                            elseif errcode == 1 then
                                PopText(errmsg)
                            elseif errcode == 2 then
                                RichPrint("main", "今日" .. currRole.name .. "已经与你聊的够多了，还是明日再来吧。")
                            elseif errcode == 3 then
                                local text = currRole.name .. "如今已同你生死与共，忠诚度无法再提升了。"
                                RichPrint("main", text)
                            end
                            role:setDayFlag("第一次管家交谈", 1)
                        else
                            PopText(errmsg)
                        end
                    end,
                    IS_SHOW_WAITING
                )
            else
                local text = "YEL" .. currRole.name .. "：" .. jobTypeAttr.talk1
                text = HomelandDesc:subChengHuText(text)
                RichPrint("main", text)
            end
        else
            local flag = map:getFlag("roleHouseStatus")
            local talkText = ""
            if flag == 0 then
                --@desc 未入侵也未被邀请。
                talkText = HomelandDesc:getNorTalkDesc(currRoleStatus, jobTypeAttr, currRole, map)
            elseif flag == 1 then
                --@desc 入侵。
                talkText = "YEL" .. currRole.name .. "：" .. jobTypeAttr.talk4
            elseif flag == 2 then
                --@desc 被邀请。
                talkText = HomelandDesc:getKrTalkDesc(currRoleStatus, jobTypeAttr, currRole, map)
            end
            RichPrint("main", talkText)
        end
    end,
    ["房屋事务"] = function(map, result, environment)
        local type = 1
        local mid = map.mid
        local limit = 10

        local npc = environment.currRole

        HttpManagerEx:getAffairList(
            type,
            mid,
            limit,
            function(status, errcode, errmsg, data)
                if status == 200 then
                    if errcode == 0 then
                        do
                            --@desc 房屋升级事务，本地创建
                            local AffairFactory = require("app.models.HomelandModel.AffairModel.AffairFactory")
                            local houseUpgradeAffair = AffairFactory:createHouseUpgradeAffair(npc)
                            if houseUpgradeAffair then
                                table.insert(data, 1, houseUpgradeAffair)
                            end
                        end
                        
                        if MapIsEmpty(data) then
                            PopText("当前没有房屋事务需要处理！")
                            return
                        end
                        PopupLayerController:showLayer(
                            "RoomAffairLayer",
                            function(layer)
                                layer:showLayer(data)
                            end
                        )
                    else
                        print("errcode = ", errcode)
                        PopText(errmsg)
                    end
                else
                    PopText(errmsg)
                end
            end,
            IS_SHOW_WAITING
        )
    end,
    ["房屋改造"] = function(map, result, environment)
        local room = map:getRoomById(map:getCurrRoomId())
        local roomType = room.roomType
        if roomType == nil then
            return
        end
        if HomelandRoomUtil:roomIsRemould(roomType) == false then
            PopText("该房间不可被改造")
            return
        end
        PopupLayerController:showLayer(
            "RoomRenovationLayer",
            function(layer)
                layer:showLayer(map, environment)
            end
        )
    end,
    ["招募仆人"] = function(map, result, environment)
        --@RefType [src.app.models.HomelandModel.HomelandRoleModel.EmployDataModel#EmployDataModel]
        local EmployDataModel = require("app.models.HomelandModel.HomelandRoleModel.EmployDataModel")

        --@desc [src.app.models.HomelandModel.HomelandRoleModel.PuRenModel#PuRenModel]
        local PuRenModel = require("app.models.HomelandModel.HomelandRoleModel.PuRenModel")
        --@desc [src.app.models.role.Role#Role]
        local role = User:getRole()
        local HomelandUtil = require("app.models.HomelandModel.HomelandUtil")
        if HomelandUtil:sysIsOpen() == false then
            return
        end

        local defaultZhongCheng = environment.currRole.defaultZhongCheng
        local npcId = environment.currRole.id
        local mid = role:getHouseId()
        if mid == nil then
            PopText("少侠，你还没房子呢。")
            return
        end
        PuRenModel:clear()
        PuRenModel:setMid(mid)
        PuRenModel:setNpcId(npcId)
        PuRenModel:setZhongCheng(defaultZhongCheng)

        PuRenModel:initEmployList(function ()
            EmployDataModel:setEmployModel(PuRenModel)
            PopupLayerController:showLayer("HomelandRoleEmployLayer",function ( layer )
                layer:showLayer()
                layer:setTextTitle("仆人招募")
                layer:setBackButtonVisible(true)
                layer:setReplaceButtonVisible(true)
                layer:setTextMoneyVisible(true)
                layer:setTextBackVisible(false)
                layer:setPanelBack(false)
            end)
        end)
    end,
    ["阻拦"] = function(map, result, environment)
        --@RefType [src.app.models.role.Role#Role]
        local player = User:getRole()
        if player:getInheritFlag("家园引导") < 2 then
            PopText("你无法进入。")
            return 
        end

        local currRole = environment.currRole
        local dialog = DialogALayer:getInstance()
        dialog:hide()
        dialog:show(environment.currRole.name .. "拦住了你")
        dialog:setBack(false)
        dialog:setButton1(
            "闯门切磋",
            function()
                Audio:playEffect("jiaoHu")
                local role = currRole
                local currMap = map
                role:initNpcAttr() -- NPC状态初始化
                map.mapLayer = map.__MapLayer
                map:afterFightWithQieCuo(
                    player,
                    role,
                    function(winTeamId)
                        if winTeamId == 1 then
                            RichPrint("main", "你三拳两脚便将管家打翻在地，" .. role.name .. "见势不好，立马溜走了。")
                            role.fightMark = 1
                            --@desc 设置人物状态，1为入侵状态 2、邀请状态
                            map:setFlag("roleHouseStatus", 1)

                            local roles = map:getRoles()
                            for k, npc in pairs(roles) do
                                if npc.type == "item" then
                                    -- FurnitureModel:aftIntrude(map,npc)
                                elseif npc.type == "role" then
                                    HomelandRoleUtil:aftIntrude(map, npc)
                                end
                            end

                            map.mapLayer:delayRefreshMap()
                            map:removeRoomRole(environment.currRoomId, role.id)
                            map:doRoomConditionAndResult(environment.currRoomId)

                            local AffairFactory = require("app.models.HomelandModel.AffairModel.AffairFactory")
                            local pushData = AffairFactory:createIntrudedPushData(map.uid, player)
                            HttpManagerEx:pushAffair(
                                pushData,
                                function(status, errcode, errmsg, data)
                                    if status == 200 then
                                        if errcode == 0 then
                                            print("已经向房主发出闯门事务")
                                        else
                                            print("errcode : ", errcode)
                                            print(errmsg)
                                        end
                                    else
                                        PopText(errmsg)
                                    end
                                end
                            )
                        elseif winTeamId == 2 then
                            RichPrint("main", "YEL" .. role.name .. "：就你这点功夫也敢闯门？还是回家练练再来吧。")
                            map.__MapLayer:quit(false)
                        elseif winTeamId == 3 then
                            RichPrint("main", "你灰溜溜的逃跑了。")
                            map.__MapLayer:quit(false)
                        end

                        do
                            local LimitedTimeExperience = require("app.models.Action.LimitedTimeExperience")
                    
                            if LimitedTimeExperience:checkTaskIsOpen("chuangmen") then
                                LimitedTimeExperience:setRole(User:getRole())
                                LimitedTimeExperience:finishTaskByTaskType("chuangmen")
                            end
                        end
                    end
                )
            end
        )
        dialog:setButton2("取消", EMPTY_FUNC)
        dialog:setWeChatVisible(false)
    end,
    ["送邀请函"] = function(map, result, environment)
        local role = User:getRole()
        local items = role:getItems()

        PopupLayerController:showLayer(
            "ShenBingBagLayer",
            function(layer)
                layer:showLayer()

                for i, item in ipairs(items) do
                    local itemAttr = Item:getOneItemByKey(item.itemId)

                    local temp = {
                        itemId = itemAttr.id,
                        type = itemAttr.type,
                        count = item.count,
                        mid = itemAttr.mid
                    }
                    layer:pushItemToLeftList(temp)
                end

                layer:setCondiPushRightList(
                    function(leftList, rightList, item)
                        if #rightList >= 1 then
                            PopText("一次只能送一张邀请函。")
                            return false
                        end

                        if item.type ~= "邀请函" then
                            PopText("只收邀请函。")
                            return false
                        end

                        return true
                    end
                )

                layer:setLeftName("背包")
                layer:setRightName(environment.currRole.name)
                layer:btnRightClickFunc(
                    function(leftList, rightList)
                        Helper:print_lua_table(rightList)

                        local item = rightList[1]

                        if item == nil then
                            PopText("未选择邀请函")
                            return
                        end
                        if map.mid ~= item.mid then
                            PopText("这张邀请函非我主人发出！")
                            return
                        end

                        local YaoQingHanModel = require("app.models.HomelandModel.YaoQingHanModel")
                        YaoQingHanModel:deleteInfoAndItem(item.itemId)
                        RichPrint("main", "YEL管家：原来是贵客上门，请进请进！")
                        map:setFlag("roleHouseStatus", 2)
                        map.__MapLayer:delayRefreshMap()
                        map:doRoomConditionAndResult(environment.currRoomId)
                        local role = User:getRole()
                        local pushData = {
                            userid = map.uid,
                            affair_id = "6",
                            affair_val = {
                                from_name = role.name
                            },
                            biz_type = 2,
                            objId = User:getUserId(),
                            from_id = User:getUserId(),
                            expired_time = GetTime() + 3600 * 24,
                            count = "",
                        }
                        HttpManagerEx:pushAffair(
                            pushData,
                            function(status, errcode, errmsg, data)
                                if status == 200 then
                                    if errcode == 0 then
                                        print("已经向房主发出拜访事务")
                                    else
                                        print("errcode : ", errcode)
                                        print(errmsg)
                                    end
                                else
                                    PopText(errmsg)
                                end
                            end
                        )
                        layer:destory()
                    end,
                    "确定"
                )
                layer:btnLeftClickFunc(
                    function()
                        layer:destory()
                    end,
                    "取消"
                )
            end
        )
    end,
    ["求购土地"] = function(map, result, environment)
        local DiQiModel = require("app.models.HomelandModel.DiQiModel")
        local dpId = map.dpId
        if dpId == nil or dpId == "" then
            PopText("房主没有土地")
            return
        end
        local role = User:getRole()
        local mid = role:getHouseId()
        if mid == nil or mid == "" then
            PopText("您还没买房，请先购买房产")
            return
        end

        PopupLayerController:showLayer(
            "AskToBuyLayer",
            function(layer)
                layer:showLayer(map)
            end
        )
    end,
    ["搬家"] = function(map, result, environment)
        local FangQiModel = require("app.models.HomelandModel.FangQiModel")
        FangQiModel:moveHouse(environment.currRole, map)
    end,
    ["户型图"] = function(map, result, environment)

        local hxId = map.hxId

        local attr = HomelandRoomUtil:getHuxinAttr(hxId)
        
        if attr == nil then
            PopText("户型图获取失败。")
            return
        end

		PopupLayerController:showLayer("FloorPlanLayer",function ( layer )
			layer:showLayer(attr.name,attr.mapAppearance)
		end)
    end,
    ["仆人管理"] = function(map, result, environment)
        local prInfo = map.puRenInfo
        if MapIsEmpty(prInfo) then 
            local desc = "#ch#，目前府上没有仆人。"
            desc = HomelandDesc:subChengHuText(desc)
            PopText(desc)
            return 
        end
        PopupLayerController:showLayer("PuRenManagementLayer", function(layer)
            layer:showLayer(map)
        end)
    end,
}

--@desc:
--@author:Liang SongQiang
--@time:2018-04-27 14:28:12
function GuanJiaModule:entryMap(map, currTime)
    -- if PRINT_MODE == 1 then
    -- 	print("EntryMap(): id: " .. map.id, "name: " .. map.name)
    -- end
    local role = User:getRole()
    local fq = role:getHomelandAttr("fq")

    if fq and map:isUserMap() and fq.isDispose ~= true then
        self:createInitialGuanJia(map, currTime)
    end
end

--@desc:生成测试管家
function GuanJiaModule:createInitialGuanJia(map, currTime)
    local hxId = map.hxId
    print("hxId = ", hxId)
    if hxId == nil then
        return
    end
    local huxinAttr = HomelandRoomUtil:getHuxinAttr(hxId)
    local roomId = huxinAttr.entryRoom1
    local entryRoom1Attr = map:getRoomById(roomId)

    --@RefType [src.app.models.map.UserMap#UserMap]
    local UserMap = require("app.models.map.UserMap")
    local GuanJiaModel = require("app.models.HomelandModel.HomelandRoleModel.GuanJiaModel")
    local linkDir = UserMap:getHouseDirByIndex(map.dirMark)
    roomId = entryRoom1Attr.link[linkDir]

    local chushiGjName
    local chushiGjModal = "moban010"
    if User:getRole():getInheritFlag("chushiGjName") == 0 then
        chushiGjName = GuanJiaModel:getGjRandomName("男")
        --@desc 记录管家初始名字
        User:getRole():setInheritFlag("chushiGjName", chushiGjName)
    else
        chushiGjName = User:getRole():getInheritFlag("chushiGjName")
    end

    -- if User:getRole():getInheritFlag("chushiGjModal") == 0 then
    --     chushiGjModal = "moban0"..math.random(10,16)
    --     User:getRole():setInheritFlag("chushiGjModal", chushiGjModal)
    -- else
    --     chushiGjModal = User:getRole():getInheritFlag("chushiGjModal")
    -- end


    print("roomId = ", roomId)
    local roleId = "guanjia001"
    local roleAttr = 
        {
            id = roleId,
            type = "role",
            sex = "男",
            name = chushiGjName,
            age = 50,
            looks = 20,
            defaultZhongCheng = math.random(1,100),
            jobType = "guanjia001",
            speedZhongCheng = 10, --忠诚成长度
            price = 600, --雇佣价格
            price_unit = "yinpiao",
            modal = chushiGjModal,
            character = "xingge004", --性格id
            trait1 = "texing001",
            trait2 = "",
            trait3 = "",
            leave_day = "",
            shenShi = "",
            mobanSkill = HomelandRoleUtil:getUploadWebRoleSkillArray(chushiGjModal),
            canSee = true,
            canTalk = true,
            canKill = false,
            caozuo1 = true,
            caozuoName1 = "雇佣",
            caozuo2 = true,
            caozuoName2 = "拒绝",
            conditionAndResults = {
                {
                    conditionRelation = "and",
                    conditions = {
                        {
                            type = "玩家操作",
                            arg1 = "玩家操作",
                            arg2 = "交谈"
                        }
                    },
                    results = {
                        {
                            type = "玩家操作",
                            arg1 = "初始管家交谈",
                            arg2 = ""
                        }
                    }
                },
                {
                    conditionRelation = "and",
                    conditions = {
                        {
                            type = "玩家操作",
                            arg1 = "玩家操作",
                            arg2 = "操作1"
                        }
                    },
                    results = {
                        {
                            -- type = "副本离开",
                            arg1 = "初始管家雇佣",
                            arg2 = ""
                        }
                    }
                },
                {
                    conditionRelation = "and",
                    conditions = {
                        {
                            type = "玩家操作",
                            arg1 = "玩家操作",
                            arg2 = "操作2"
                        }
                    },
                    results = {
                        {
                            -- type = "文本输出",
                            arg1 = "拒绝初始管家",
                            arg2 = ""
                        }
                    }
                },
                {
                    conditionRelation = "and",
                    conditions = {
                        {
                            arg1 = "玩家进入房间",
                            arg2 = roomId
                        },
                        {
                            arg1 = "地图标记等于",
                            arg2 = "roleComeInHouse",
                            arg3 = 0
                        }
                    },
                    results = {
                        {
                            arg1 = "文本输出",
                            arg2 = "YEL" .. chushiGjName .. "：少侠请留步，还请过来一叙。"
                        },
                        {
                            arg1 = "地图标记设置",
                            arg2 = "roleComeInHouse",
                            arg3 = 1
                        }
                    }
                }
            }
        }

    roleAttr = table.mergeMap(roleAttr, HomelandRoleUtil:getMobanRoleAttr(roleAttr.modal))
    local role =
        Helper:tableCover(
        require("app.models.npc.BaseNpc"):create(),roleAttr
    )

    role.dsc = HomelandRoleUtil:createRoleDsc(role)

    MapInfo:addMapRole(map, role)
    MapInfo:addRoleToRoom(map, roomId, roleId)
end

return GuanJiaModule
000000000