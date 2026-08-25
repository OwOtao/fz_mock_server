local class = require("third.class.NewClass")
local JumpMapStyle = {}
local JumpMapConstants = require("app.models.JumpMapStyle.JumpMapConstants")
local UseFailureState = JumpMapConstants.UseFailureState

--@desc 跳转特殊房间，如随机到33章剑湖宫，跳转到石板路
local specialRoom = {
	["fb33_19"] = "fb33_16",
}

function JumpMapStyle:create()
    return JumpMapStyle:new()
end

function JumpMapStyle:ctor()
    --传送副本id
    self._mapId = nil
    --传送副本房间
    self._roomId = nil

    self._role = nil
end

function JumpMapStyle:setRole(role)
    self._role = role
end

function JumpMapStyle:getRole()
    return self._role
end

function JumpMapStyle:setMapId(mapId)
    self._mapId = mapId
end

function JumpMapStyle:setRoomId(roomId)
    self._roomId = roomId

    if specialRoom[roomId] then
		self._roomId = specialRoom[roomId]
	end
end


--禁止使用遁地符与五行遁法副本
local function checkMapCanUseDunDiFuAndWuXingDunFa(mapId)
    --不能使用遁地符的副本
	local TreasureList = require("script.others.Treasure")

    local forbidMapIdInfo = TreasureList["挖宝禁止"]["1"]["stopcopy"]

	local mapIdList = string.split(forbidMapIdInfo, ",")

	for k, __mapId in ipairs(mapIdList) do 
		if __mapId == mapId then
			return false
		end
	end

	return true
end

function JumpMapStyle:checkCanUseDunDiFu()
    local map = self._role:getCurrMap()

    if map ~= nil and not MapIsEmpty(map) and map:getRoleIsInMap() == true then
        if checkMapCanUseDunDiFuAndWuXingDunFa(self._role:getCurrMapId()) == false then
            return false, UseFailureState.MAP_FORBID
        end

        if map:canLeaveRoom() == false then
            return false, UseFailureState.MAP_STATE_FORBID_ITEM
        end
    end

    return true
end

--[[
    @desc: 使用遁地符跳转
    author:tanqinjian
    time:2026-05-06 15:22:50
	--@func: 跳转回调
    @return:
]]
function JumpMapStyle:useDunDiFu(func)
    if not self._role or not self._mapId or not self._roomId then
        assert(false, "JumpMapStyle:useDunDiFu 参数异常 mapId:"..tostring(self._mapId).."roomId:"..tostring(self._roomId))
    end

    func = Helper:getDef(func, EMPTY_FUNC)

    local item = Item:getOneItemByKey("dundifu")

    item:storeItemUse(function()
        self:goMap(func)
    end, false)
end

function JumpMapStyle:checkCanUseWuXingDunFa()
    local skill = self._role:getSkill("wuxingdunfa")

    if MapIsEmpty(skill) then
        return false
    end

    local skillLv = self._role:getSkillLv("wuxingdunfa")

    local costJing = 5

    if skillLv < 100 then
        costJing = 5
    elseif skillLv < 200 then
        costJing = 4
    elseif skillLv < 300 then
        costJing = 3
    elseif skillLv < 400 then
        costJing = 2
    elseif skillLv < 500 then
        costJing = 1
    else
        costJing = 0
    end

    if self._role:getAttr("jing") < costJing then
        return false, UseFailureState.JING_NOT_ENOUGH
    end

    local limitCount = 49
    if self._role:getDayFlag("wuxingdunfa") >= limitCount then
        return false, UseFailureState.COUNT_LIMIT
    end

    local map = self._role:getCurrMap()

    if map ~= nil and not MapIsEmpty(map) and map:getRoleIsInMap() == true then
        if checkMapCanUseDunDiFuAndWuXingDunFa(self._role:getCurrMapId()) == false then
            return false, UseFailureState.MAP_FORBID
        end

        if map:canLeaveRoom() == false then
            return false, UseFailureState.MAP_STATE_FORBID_SKILL
        end
    end

    return true
end

--[[
    @desc: 使用五行遁法
    author:tanqinjian
    time:2026-05-06 15:23:33
	--@func: 跳转回调
    @return:
]]
function JumpMapStyle:useWuXingDunFa(func)
    if not self._role or not self._mapId or not self._roomId then
        assert(false, "JumpMapStyle:useWuXingDunFa 参数异常 mapId:"..tostring(self._mapId).."roomId:"..tostring(self._roomId))
    end

    func = Helper:getDef(func, EMPTY_FUNC)

    local skill = self._role:getSkill("wuxingdunfa")

    if MapIsEmpty(skill) == false then
        local skillLv = self._role:getSkillLv("wuxingdunfa")

		local percent, addExp, addJing = 70, 0, - 5
		if skillLv < 100 then
			percent = 70
			addExp = 153
			addJing = - 5
		elseif skillLv < 200 then
			percent = 80
			addExp = 536
			addJing = - 4
		elseif skillLv < 300 then
			percent = 90
			addExp = 969
			addJing = - 3
		elseif skillLv < 400 then
			percent = 95
			addExp = 1416
			addJing = - 2
		elseif skillLv < 500 then
			percent = 98
			addExp = 1867
			addJing = - 1
		else
			percent = 100
			addExp = 0
			addJing = 0
		end

        if math.random(1, 100) > percent then
            self._role:addAttr("jing", addJing)
            func(false, UseFailureState.RATE_FAILURE)
        else
            self._role:setDayFlag("wuxingdunfa", self._role:getDayFlag("wuxingdunfa") + 1)
            self._role:addAttr("jing", addJing)
            self._role:addSkillExp("wuxingdunfa", addExp)
            self:goMap(func)
        end
    end
end

function JumpMapStyle:checkCanToSelectMap()
    --角色相关状态下不能进入副本
    local RoleTaskControllor = require("app.views.layer.RoleLayer.RoleTaskControllor")

	if RoleTaskControllor:clickMapLayer(self._role) == false then
		return false
	end

    return true
end

--[[
    @desc: 跳转到副本选择界面
    author:tanqinjian
    time:2026-05-06 15:23:57
	--@func: 跳转回调s
    @return:
]]
function JumpMapStyle:toSelectMapLayer(func)
    if not self._role or not self._mapId or not self._roomId then
        assert(false, "JumpMapStyle:toSelectMapLayer 参数异常 mapId:"..tostring(self._mapId).."roomId:"..tostring(self._roomId))
    end

    func = Helper:getDef(func, EMPTY_FUNC)

    if MainControllLayer:getCurrLayer() == "MapLayer" then
        local mapLayer = MainControllLayer:getLayer("MapLayer")
        mapLayer:quit()
        mapLayer:setVisible(false)
    end

    MainControllLayer:pushLayer("SelectMapLayer")
    local selectMapLayer = MainControllLayer:getLayer("SelectMapLayer")
    selectMapLayer:setMap(self._mapId)

    func(true)
end

function JumpMapStyle:checkCanJumpMap()
    --副本需要通关
    local isTrue = self._role:isMapCompleted(self._mapId)

    if isTrue == false then
        return false, UseFailureState.MAP_NOT_COMPLETED
    end

    local isUserMap = false

	if string.find(self._mapId, "user_fb_" ) ~= nil then
		isUserMap = true
	end

	-- 地图刷新
	if isUserMap == false then
		local map = self._role:getMapById(self._mapId)

		local lastTime = self._role:getFlag(self._mapId)

		if(lastTime ~= 0 and GetTime() - lastTime > MAP_REFRESH_INTERVAL) or lastTime == 0 then
		else
			--副本在冷却中，提示玩家刷新副本或等待副本自动刷新
			return false, UseFailureState.MAP_NOT_REFRESH
		end
	end

    --角色相关状态下不能进入副本
    local RoleTaskControllor = require("app.views.layer.RoleLayer.RoleTaskControllor")
	if RoleTaskControllor:clickMapLayer(self._role) == false then
		return false
	end

    return true
end

function JumpMapStyle:goMap(func)
    local isUserMap = false

	if string.find(self._mapId, "user_fb_" ) ~= nil then
		isUserMap = true
	end

    if isUserMap then
        --@RefType [src.app.models.map.UserMap#UserMap]
        local UserMap = require("app.models.map.UserMap")
        UserMap:getUserMap(string.split(self._mapId, "user_fb_")[2], User:getUserId(), function(map, isSuccess)
            if isSuccess == false then
                return
            end

            map._isComingIn = true
            local titleLayer = MainControllLayer:getLayer("TitleLayer")
            local mapRoleLayer = MainControllLayer:getLayer("MapRoleLayer")
            mapRoleLayer:show()
            mapRoleLayer:onResume()
            mapRoleLayer:maxZ()
            titleLayer:hide(true)

            map:setCallBackAndConnect(function()
                MainControllLayer:getLayer("PrintLayer"):setTexTure("Map")
                local mapLayer = MainControllLayer:getLayer("MapLayer")
                mapLayer:setMap(map)

                MainControllLayer:pushLayer("MapLayer")
                MessageCenter:notify("EnterMap",{map=map})

                if func then
                    func(true)
                end
            end)
        end)
    else
        --  副本冷却时间到达，做刷新处理
        local map = self._role:initMapById(self._mapId)

        map:setCallBackAndConnect(function()
            map._isComingIn = true

            local layer = MainControllLayer:getLayer("MapLayer")
            layer:setMap(map)
            map:setCurrRoomId(self._roomId) -- 遁地符传送到指定的房间			
            layer:replaceRoom(self._roomId)
            MainControllLayer:pushLayer("MapLayer")
            MessageCenter:notify("EnterMap",{map=map})

            User:setRoleAttr("currMapId", map.id)

            local titleLayer = MainControllLayer:getLayer("TitleLayer")
            titleLayer:hide(true)

            local MapRoleLayer = MainControllLayer:getLayer("MapRoleLayer")
            MapRoleLayer:show()
            MapRoleLayer:onResume()
            MapRoleLayer:maxZ()

            local layer = MainControllLayer:getLayer("PrintLayer")
            layer:show(true)
            layer:setLocalZOrder(10)
            Audio:stopMusic()

            if func then
                func(true)
            end
        end)
    end
end

return class("JumpMapStyle", {}, JumpMapStyle)00000000