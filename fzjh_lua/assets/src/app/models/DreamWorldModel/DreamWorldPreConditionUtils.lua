--
-- Author: TanQinJian
-- Date: 2019-12-18 10:32:34
--
local DreamWorldPreConditionUtils = {}
local level_limit = 200
local inherit_count = 1
local targetMapId = "fb219"
local targetRoomId = "fb219_01"

function DreamWorldPreConditionUtils:checkCanOpenPreTask()
	local role = User:getRole()

	if role:getLv() <= level_limit then 
		return false
	end

	if Map:getMapState("fb10") ~= MAP_STATE.COMPLETE then 
		return false
	end

	if role:getAttr("role_is_cheat") == true then 
		return false
	end

	return true
end

function DreamWorldPreConditionUtils:isFinishPreTask()
	local role = User:getRole()

	if role:getFlag("drqianzhi") ~= 1 then 
		return false
	end

	return true
end

function DreamWorldPreConditionUtils:startPreTask()
	local role = User:getRole()

	local RoleTaskControllor = require("app.views.layer.RoleLayer.RoleTaskControllor")
	if RoleTaskControllor:clickMapLayer(role, function()end) == false then
		return false
	end

    local map = role:getMapById(targetMapId)
    if MapIsEmpty(map) then
        print("没有找到该副本",targetMapId)
        return
    end

    do
        local lastTime = role:getFlag(map.id)
        if lastTime == 0 and map._isComingIn == nil then
            role:setFlag(map.id, GetTime())
        elseif lastTime ~= 0 and GetTime() - lastTime < MAP_REFRESH_INTERVAL and map._isComingIn == nil then
            local remainTime = MAP_REFRESH_INTERVAL - GetTime() + lastTime
            local second = math.floor(remainTime % 60)
            local min = math.floor(remainTime / 60)

            PopText("副本冷却中，剩余冷却时间 "..tostring(min).." 分".. tostring(second).." 秒")
            return
        elseif map._isComingIn == true and lastTime ~= 0 and GetTime() - lastTime > MAP_REFRESH_INTERVAL then
            --  副本冷却时间到达，做刷新处理
            map = role:initMapById(map.id)
        end
	end

    MainControllLayer:getLayer("PrintLayer"):initRichText()
    local entryMapLayer = MainControllLayer:getLayer("EntryMapLayer")
    entryMapLayer:maxZ()
    entryMapLayer:setCenterText("你只觉头脑昏昏沉沉，意识渐渐模糊……")
    entryMapLayer:show()

    local titleLayer = MainControllLayer:getLayer("TitleLayer")
    local mapRoleLayer = MainControllLayer:getLayer("MapRoleLayer")
    mapRoleLayer:onResume()
    titleLayer:hide(true)


    MainControllLayer:delayFunc(1,
    function(obj)
        map:setCallBackAndConnect(function()
            local mapLayer = MainControllLayer:getLayer("MapLayer")
			mapLayer:setMap(map)
			map._isComingIn = true
			
            MainControllLayer:removeLayer("EntryMapLayer")
			MainControllLayer:pushLayer("MapLayer")
			MessageCenter:notify("EnterMap",{map=map})
        end)
    end)
end

function DreamWorldPreConditionUtils:checkCanToHome()
	local state = 2 --0 没有完成前置 1 没有家园 2 可以
	if self:isFinishPreTask() ==false then 
		state = 0
		return state
	end
	local role = User:getRole()

	local fq=role:getHomelandAttr("fq")

	if MapIsEmpty(fq) then 
		state = 1
		return state
	end

	return state
end

function DreamWorldPreConditionUtils:goHome()
	local role = User:getRole()
	local RoleTaskControllor = require("app.views.layer.RoleLayer.RoleTaskControllor")
	if RoleTaskControllor:clickMapLayer(role, function()end) == false then
		return false
	end

	local fq = role:getHomelandAttr("fq")
	if MapIsEmpty(fq) then 
		return 
	end
	local UserMap = require("app.models.map.UserMap")
	local mid, userid = fq.mid, User:getUserId()

	local entryMapLayer = MainControllLayer:getLayer("EntryMapLayer")
	entryMapLayer:maxZ()
	entryMapLayer:show()
	entryMapLayer:setCenterText("你心有所感，在家里随意走了走。")
	Audio:playEffect("huijiaBGM")

	UserMap:getUserMap(mid, userid, function(map,isSuccess)
		if isSuccess == false or map == nil then
			MainControllLayer:removeLayer("EntryMapLayer")
			PopText("家园地图加载失败")
			return
		end

		map._isComingIn = true

		local titleLayer = MainControllLayer:getLayer("TitleLayer")
		local mapRoleLayer = MainControllLayer:getLayer("MapRoleLayer")
		mapRoleLayer:onResume()
		titleLayer:hide(true)

		map:setCallBackAndConnect(function()
			local mapLayer = MainControllLayer:getLayer("MapLayer")
			local roomId = map.entryDreamDefaultlRoom or map.entryRoom1

			if roomId == nil then
				roomId = map:getDefaultRoomId()
			end

			mapLayer:setMap(map)
			MainControllLayer:removeLayer("EntryMapLayer")
			MainControllLayer:pushLayer("MapLayer")
			MessageCenter:notify("EnterMap",{map=map})
			mapLayer:teleportRoom(roomId)
		end)
	end)
end

return DreamWorldPreConditionUtils0000