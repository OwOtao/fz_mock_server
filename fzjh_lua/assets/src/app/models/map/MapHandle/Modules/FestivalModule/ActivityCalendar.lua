--周活动
-- Author: TanQinJian
-- Date: 2020-05-29 16:07:57
--
--@SuperType [src.app.models.map.MapHandle.Modules.BaseModule#BaseModule]
local ActivityCalendar = class("ActivityCalendar", require("app.models.map.MapHandle.Modules.BaseModule"))
local ActivityCalendarUtils = require("app.models.Action.ActivityCalendarUtils")


--@desc 涉及副本ID ：格式{["id"] = true} 默认为nil，无限制
ActivityCalendar.mapId = {}

--@desc 涉及房间 : 格式{["id"] = true} 默认为nil，无限制
ActivityCalendar.roomId = nil

--@desc 开启状态，默认开启
ActivityCalendar.status = 1

--@desc 活动时间 : 格式：20171001，默认值0 表示无时间限制
ActivityCalendar.activityTime = 0


ActivityCalendar.doResult = {
}

function ActivityCalendar:entryMap(map, currTime)
	local lastTime =  User:getRole():getFlag(map.id)
	if map._isComingIn == true and lastTime ~= 0 and GetTime() - lastTime < MAP_REFRESH_INTERVAL then 
		return
	end
	ActivityCalendarUtils:initData()
	if ActivityCalendarUtils:checkIsActivityMap(map.id) then 
		ActivityCalendarUtils:launchNpc(map)
	end
end



return ActivityCalendar
0000