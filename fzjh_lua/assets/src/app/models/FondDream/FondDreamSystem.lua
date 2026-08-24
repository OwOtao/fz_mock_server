local class = require("third.class.NewClass")
local DreamSystem = require("app.models.DreamWorldModel.DreamSystem")
local DreamUtil = require("app.models.DreamWorldModel.DreamUtil")
local FondDreamSystem = {}

function FondDreamSystem:create(role)
    local p = FondDreamSystem.new()
    p.__isNotSerializable = true
    p:init(role)
    return p
end

function FondDreamSystem:init(role)
    self:setRole(role)
    self:setResManager()
    role:setDreamSystem(self)
end

function FondDreamSystem:setResManager()
    self._resManager = require("app.models.FondDream.FondDreamResManager")
end

function FondDreamSystem:_getMapType()
    return MAP_TYPE.FONDDREAMMAP
end

function FondDreamSystem:_getFloorEvents(floorEventId)
    local drEvents = self._resManager:getDrEvents()
    return drEvents["楼层事件"][tostring(floorEventId)]
end

function FondDreamSystem:_initDreamRole(role)
    local RoleBuff = require("app.models.role.RoleBuff")
	role._roleBuff = RoleBuff:create()

    -- 自创武学系统
    local SelfCreatedSkillSystem = require("app.models.SelfCreatedSkillSystem.SelfCreatedSkillSystem")
    role._selfCreatedSkillSystem = SelfCreatedSkillSystem:create()
    
    -- 面具系统
	local MaskSystem = require("app.models.mask.MaskSystem")
	role._maskSystem = MaskSystem:create(role)

	local RoleItemSystem = require("app.models.role.item.RoleItemSystem")
	role._roleItemSystem = RoleItemSystem:create(role)

	--@desc 情绪系统接入
	local EmotionMgr = require("app.models.FondDream.FondDreamEmotionMgr")
	role.emotionMgr = EmotionMgr:create(role)

	local BuffManager = require("app.models.Buff.BuffManager")
	role._buffManager = BuffManager:create()
	-- 监控buff状态变化
    role._buffManager:registerUpdateFunc(function()
        role:dispatchEvent("roleBuffUpdate")
    end)

    local SelfCreatedSkillPropSystem = require("app.models.SelfCreatedSkillSystem.SelfCreatedSkillPropSystem")
	role._selfCreatedSkillSystem:setPropSystem(SelfCreatedSkillPropSystem:create())
    role._selfCreatedSkillSystem:init(role)
    
    role._buffManager:init(role)
    
    role._selfCreatedSkillSystem:updataSelfCreatedSkillMap()
    
    role._isFondDrRole = true
end

function FondDreamSystem:_createDreamRole()
    local RoleFactory = require("app.models.role.factory.RoleFactory")
    return RoleFactory:createFondDreamRole()
end

function FondDreamSystem:_initDreamTalentBuff(role)
end

function FondDreamSystem:enterNewMap(dream_role)
    self:enterMap(1,dream_role,function()
    end)
end

function FondDreamSystem:_getfloorEventId(floor_num,dreamRole)
    local chessEventId = assert(dreamRole.chessEventId,"没有棋局id")
    local chessEventInfo = self._resManager:getChessEventInfo(chessEventId)
    local floorEvents = chessEventInfo.floorEvents
    local floorEventIds = string.split(floorEvents,";")
    local floorEventId = floorEventIds[floor_num]
    return floorEventId
end

function FondDreamSystem:_addSpecialNpc(map, floor)
end

function FondDreamSystem:enterMap(floor_num, dreamRole,enter_layer_callback)
    enter_layer_callback = Helper:getDef(enter_layer_callback,EMPTY_FUNC)
    local floorEventId = self:_getfloorEventId(floor_num,dreamRole)
    local map = self:createMap(floorEventId)
    Map:setMapWithId(map.id, map)
    map:setPlayer(dreamRole) --设置梦境主角
    dreamRole.dreamWorld.cFloor = floor_num --记录梦境楼层

    local currLayerName = MainControllLayer:getCurrLayer()
    local layer = MainControllLayer:getLayer(currLayerName)

    -- MainControllLayer:getLayer("PrintLayer"):initRichText()
    RichPrint("main", Helper:getDef(map.inText, ""))

    --@desc 进入梦境,需要把装备的兵器和准备的兵器武学同步
    local DreamEquip = require("app.models.DreamWorldModel.DreamEquip")
    DreamEquip:equipWeapon(dreamRole,dreamRole:getEquipByName("weapon"))

    layer:delayFunc(
        2,
        function()
            map:setCallBackAndConnect(
                function()
                    local mapLayer = MainControllLayer:getLayer("MapLayer")

                    mapLayer:enterMap(map)

                    MainControllLayer:pushLayer("MapLayer")

                    MessageCenter:notify("EnterMap", {map = map})

                    map:getPlayer():dispatchEvent("EnterMap", {map = map})

                    enter_layer_callback()
                end
            )
        end
    )
end

function FondDreamSystem:enterNextMap(map, showStr)
    local player = map:getPlayer()

    --@desc 当前楼层完成事件
    map:getPlayer():dispatchEvent("FloorCompleteEvent", {map = map})

    local next_floor = player.dreamWorld.cFloor + 1
    player.dreamWorld.cFloor = next_floor

    local currLayerName = MainControllLayer:getCurrLayer()
    local layer = MainControllLayer:getLayer(currLayerName)

    local entryMapLayer = MainControllLayer:getLayer("EntryMapLayer")
    entryMapLayer:maxZ()
    entryMapLayer:setCenterText(showStr)
    entryMapLayer:show()

    local enterNextMap = function(curr_map, next_map, role)
        -- @TODO 2020-11-20 12:01:32 临时处理进入下一层时 还能点击上一层人物按钮
        local roleList = curr_map:getRoomRoleList(curr_map:getCurrRoomId())

        for i = #roleList, 1, -1 do
            local tRoleId = roleList[i]
            curr_map:removeRoomRole(curr_map:getCurrRoomId(),tRoleId)
        end

        curr_map.__MapLayer:delayRefreshMap()
        
        role.dreamWorld.eFloor = next_floor
        
        next_map:setPlayer(role)
        
        layer:delayFunc(
            2,
            function()
                -- MainControllLayer:getLayer("PrintLayer"):initRichText()

                curr_map:leaveMap()

                RichPrint("main", Helper:getDef(next_map.inText, ""))

                next_map:setCallBackAndConnect(
                    function()
                        local mapLayer = MainControllLayer:getLayer("MapLayer")

                        mapLayer:switchMap(next_map)

                        
                        MessageCenter:notify("EnterMap", {map = next_map})
                        
                        map:getPlayer():dispatchEvent("EnterMap", {map = map})

                        MainControllLayer:removeLayer("EntryMapLayer")
                    end
                )
            end
        )
    end

    HttpManagerEx:fondDreamFloorComplete(
        player:getTrimData(),
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    local floorEventId = self:_getfloorEventId(next_floor,player)
                    local next_map = self:createMap(floorEventId)
                    Map:setMapWithId(next_map.id, next_map)
                    enterNextMap(map, next_map, player)
                    return true
                elseif errcode == 2 then
                    player:destory()
                    local role = self:createDreamRoleWithData(data.roleAttr)
                    local floorEventId = self:_getfloorEventId(next_floor,player)
                    local next_map = self:createMap(floorEventId)
                    Map:setMapWithId(next_map.id, next_map)
                    enterNextMap(map, next_map, role)
                    return true
                else
                    PopText(errmsg)
                    return false
                end
            else
                PopText(errmsg)
                return false
            end
        end,
        IS_SHOW_WAITING,
        HTTP_MANAGER_RETRY_TYPE_RETRY
    )
end

function FondDreamSystem:mapComplete(map, callback)
    local roleAttr = map:getPlayer():getTrimData()

    --@desc 奖励的角色
    local rewardRole = User:getRole()

    local uploadParams = {
        roleAttr = roleAttr,
        rewardParams = {lv = rewardRole:getLv(), menpaiId = map:getPlayer():getFamilyId(), qiMax = rewardRole:getFinalAttr("qiMax"), neiliMax = rewardRole:getFinalAttr("neiliMax")}
    }

    HttpManagerEx:fondDreamWorldComplete(
        uploadParams,
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    self:_handleCompleteReward(data.reward, map, map:getPlayer().dreamWorld.eFloor, callback)
                    return true
                elseif errcode == 1 then
                    print("--------------- 梦境角色信息重复上传！！！ -------------------")
                    return true
                elseif errcode == -2 then --@desc 作弊强制退出梦境副本
                    PopText(errmsg)
                    if callback then
                        callback()
                    end
                    return true
                else
                    PopText(errmsg)
                    return false
                end
            else
                PopText(errmsg)
                return false
            end
        end,
        IS_SHOW_WAITING,
        HTTP_MANAGER_RETRY_TYPE_RETRY
    )
end

function FondDreamSystem:finishTask(map, currRoomId)
    local room = map:getRoomMap()[currRoomId]
    local taskId = room.drEventId
    local eventType = room.roomType
    local events = self._resManager:getEventListByType()[tostring(eventType)]
    if MapIsEmpty(events) == false then
        local npcIds = nil
        for k, v in pairs(events) do
            if v.id == taskId then
                npcIds = v.rewardid
                break
            end
        end
        if npcIds then
            local npcIdList = string.split(npcIds,";") 
            for i,npcId in ipairs(npcIdList) do
                map:addRoomRole(currRoomId, npcId)
            end
        end
    else
        error(nil, "没有该类型事件 :" .. eventType)
    end
end

function FondDreamSystem:getWebReward(context)
    RewardManager2:getFondWebReward(context)
end

--@desc 获取南柯梦境经验奖励
function FondDreamSystem:addFondExpReward(player)
    local floor = player.dreamWorld.cFloor
    local chessType = player.chessType
    local exp = 0
    local dreamfloorexp = self._resManager:getDrFloorExp()

    for k,v in pairs(dreamfloorexp) do
        if v.drfloor == floor and v.type == chessType then
            exp = v.floorexp
            break
        end
    end
    
    player:addAttr("exp",exp)
end

--增加主动招式重数
function FondDreamSystem:addDreamZhaoLv(zhaoId,role,addLv)
    local currLv = role:getSkillZhaoLv(zhaoId)
    local BasicActiveSkillManager = require("app.models.skill.BasicSkill.BasicActiveSkillManager")
    local activeZhao = BasicActiveSkillManager:getBasicActiveSkill(zhaoId)
    local zhaoName = activeZhao:getActiveName()

    local maxLv = role:getZhaoLvLimit(zhaoId)
    if currLv >= maxLv then
        RichPrint("main", zhaoName .. "已练至最高重数")
        return
    end

    if addLv ~= nil then
        addLv = math.min(maxLv - currLv, addLv)
        currLv = currLv + addLv
        local exp = role:conversionZhaoExpAndLv("exp", currLv, role:getSkillZhaoPotEfficiency(zhaoId))

        local roleSkillZhao = {id = zhaoId, exp = exp}
        role:setSkillZhao(zhaoId, roleSkillZhao)
        PopText(zhaoName .. "提升了" .. addLv .. "重")
        RichPrint("main", zhaoName .. "提升了" .. addLv .. "重")
    end
end

function FondDreamSystem:_handleCompleteReward(rewards, map, floor, callback)
    PopupLayerController:showLayer(
        "ChessCompleteLayer",
        function(layer)
            layer:showLayer(
                rewards,
                floor,
                function()
                    if callback then
                        callback()
                    end
                    --@desc 梦境结束销毁梦境主角
                    map:getPlayer():destory()
                end
            )
        end
    )
    RewardManager2:getReward(rewards, User:getRole(), map)
end

function FondDreamSystem:_getMaxPj()
    return 12
end

return class("FondDreamSystem", { DreamSystem }, FondDreamSystem)0000000000000