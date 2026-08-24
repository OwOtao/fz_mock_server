--
-- Author: TanQinJian
-- Date: 2020-05-29 14:32:15
--
local weekActivity = require("script.others.weekactivity")
local RoleTitleConst = require("app.models.role.titleSystem.RoleTitleConst")
local RoleTitleResManager = require("app.models.role.titleSystem.RoleTitleResManager")
local activityInfo = weekActivity["activity"]
local launchInfo = weekActivity["launch"]
local ActivityCalendarUtils = {}
--投放id表
local activityLaunchList={}
local activityNpcList = {}
local activityMapList = {}
local activityTimeList = {}

local function initActivityTime()
	for k, v in pairs(activityInfo) do
		local startTimeArray = string.split(v.startValidTime, ";")
		local startDate = startTimeArray[1]
		local startHour = Helper:getDef(startTimeArray[2],"00")
		local startMinute = Helper:getDef(startTimeArray[3],"00")

		local endTimeArray = string.split(v.endValidTime, ";")
		local endDate = endTimeArray[1]
		local endHour = Helper:getDef(endTimeArray[2],"00")
		local endMinute = Helper:getDef(endTimeArray[3],"00")

		local startTime = Helper:getTimeStampWithStringDate(startDate, tonumber(startHour)) + tonumber(startMinute) * 60
		local endTime = Helper:getTimeStampWithStringDate(endDate, tonumber(endHour)) + tonumber(endMinute) * 60

		if not activityTimeList[v.id] then
			activityTimeList[v.id] = {}
		end

		activityTimeList[v.id].startTime = startTime
		activityTimeList[v.id].endTime = endTime
	end
end

initActivityTime()

function ActivityCalendarUtils:initData()
	activityLaunchList={}
	activityNpcList = {}
	activityMapList = {}
	self:initCurrActivityInfo()
end

--根据当前时间获取当前活动
function ActivityCalendarUtils:initCurrActivityInfo()
	local currTime = GetTime()

	local function checkIsActivityTime(startValidTime,endValidTime)
		local stratTimeArray = string.split(tostring(startValidTime), ";")
		local stratDate = stratTimeArray[1]
		local stratHour = Helper:getDef(stratTimeArray[2],"12")
		local stratMinute = Helper:getDef(stratTimeArray[3],"00")

		local endTimeArray = string.split(tostring(endValidTime), ";")
		local endDate = endTimeArray[1]
		local endHour = Helper:getDef(endTimeArray[2],"24")
		local endMinute = Helper:getDef(endTimeArray[3],"00") 

		local stratTime,endTime

		if type(tonumber(stratDate)) == "number" then
			stratTime = Helper:getTimeStampWithStringDate(tostring(stratDate), tonumber(stratHour)) + tonumber(stratMinute)*60
		end

		if type(tonumber(endDate)) == "number" then
			endTime = Helper:getTimeStampWithStringDate(tostring(endDate), tonumber(endHour)) + tonumber(endMinute)*60
		end


		if currTime >= stratTime and currTime <= endTime then
			return true
		else
			return false
		end
		return false
	end
 	
 	if MapIsEmpty(activityInfo) then 
 		print("------------script.others.weekactivity.activity:资源有问题")
 		return 
 	end

	for index,activity in pairs(activityInfo) do 
		if checkIsActivityTime(activity.startValidTime,activity.endValidTime) then 
			self:addLaunch(activity.launchId,activity.startValidTime,activity.endValidTime)
		end
	end

	for k,v in ipairs(activityLaunchList) do 
		self:initActivityMapAndNpcId(v)
	end
end

function ActivityCalendarUtils:addLaunch(launchStr,startValidTime,endValidTime)
	local launchList = string.split(launchStr,",")

	if MapIsEmpty(launchList) then 
		return 
	end

	for k,v in pairs(launchList) do 
		if v then 
			local launch_table = {}
			launch_table.launchId = tonumber(v)
			launch_table.startValidTime = startValidTime
			launch_table.endValidTime = endValidTime
			table.insert(activityLaunchList,launch_table)
		end
	end
end

--根据投放id获取当前副本投放npc
function ActivityCalendarUtils:initActivityMapAndNpcId(launch_info)
	if MapIsEmpty(launchInfo) then 
		return 
	end

	for k,v in pairs(launchInfo) do 
		if launch_info.launchId == v.id then 
			if v.npcId == nil or v.mapId == nil then 
				return
			end
			
			local npc_table ={}
			npc_table.npcId = v.npcId
			npc_table.mapId = v.mapId
			npc_table.roomId = v.roomId
			npc_table.startValidTime = launch_info.startValidTime
			npc_table.endValidTime = launch_info.endValidTime
			table.insert(activityNpcList,npc_table)

			table.insert(activityMapList,v.mapId)
		end
	end
end

function ActivityCalendarUtils:checkIsActivityMap(mapId)
	if MapIsEmpty(activityMapList) then 
		return false
	end

	for k,v in ipairs(activityMapList) do 
		if mapId == v then 
			return true
		end
	end
	return false
end

function ActivityCalendarUtils:addNpcStartAndEndTime(map,npcInfo)
	if MapIsEmpty(map) == false then
		for k,v in pairs(map.roles) do 
			if npcInfo.npcId == v.id then 
				v.startValidTime = npcInfo.startValidTime
				v.endValidTime = npcInfo.endValidTime
			end
		end
	end
end

function ActivityCalendarUtils:launchNpc(map)
	if MapIsEmpty(map) == false then 
		for k,v in pairs(activityNpcList) do 
			if map.id == v.mapId then 
				self:addNpcStartAndEndTime(map,v)
				map:addRoomRole(v.roomId, v.npcId, false)
			end
		end
	end
end

--周活称号奖励
function ActivityCalendarUtils:getSpecialTitle(activityId)
	local titles ={
		["weekdmxb"] = {
            id = RoleTitleConst.SpecialBasicTitleId.YouLi_XiaoNaZhenBao
        },
        --weekxzzy 为集字活动
        ["weekxzzy"] = {
            id = RoleTitleConst.SpecialBasicTitleId.YouLi_XiuZiCangKe
        },
        ["weekwjss"] = {
            id = RoleTitleConst.SpecialBasicTitleId.YouLi_YiWuHuiXia
        },
        ["weekbgsq"] = {
            id = RoleTitleConst.SpecialBasicTitleId.YouLi_ShenFengTieMian
        },
        ["weekslcd"] = {
            id = RoleTitleConst.SpecialBasicTitleId.YouLi_LiHanQingGou
        },
        --weekhztc 放风筝
        ["weekhztc"] = {
            id = RoleTitleConst.SpecialBasicTitleId.YouLi_LvYeYuanFei
        },
        ["weekxqdm"] = {
            id = RoleTitleConst.SpecialBasicTitleId.YouLi_QiaoMinMiSi
        },
        ["weekwjhw"] = {
            id = RoleTitleConst.SpecialBasicTitleId.YouLi_JiHuiQunYing
        },
        ["zhouhuodongtx1"] = {
            id = RoleTitleConst.SpecialBasicTitleId.YouLi_DouJiuJiangHang
        },
        ["zhouhuodongtx2"] = {
            id = RoleTitleConst.SpecialBasicTitleId.YouLi_PoJunLunJian
        },
        ["zhouhuodongtx3"] = {
            id = RoleTitleConst.SpecialBasicTitleId.YouLi_MingCangWuYue
        },
        ["zhouhuodongtx4"] = {
            id = RoleTitleConst.SpecialBasicTitleId.YouLi_XiaXinWeiJi
        },
        ["zhouhuodongtx5"] = {
            id = RoleTitleConst.SpecialBasicTitleId.YouLi_TianYaBuLao
        },
	}
	local tab = titles[activityId]

	if MapIsEmpty(tab) then 
		return
	end
	
	local role = User:getRole()

	local basicTitleId = tab.id
	local title = RoleTitleResManager:getBasicTitleClassById(basicTitleId)
	if title and role:hasBasicTitle(basicTitleId) == false then
		role:addBasicTitle(basicTitleId)
		local name = title:getColorName()
		PopText("获得"..name.."称号")
	end
end

function ActivityCalendarUtils:setYuHuiLingLimit()
    if GetTime() > Helper:getTimeStampWithStringDate("20210201", 0)  and GetTime() < Helper:getTimeStampWithStringDate("20210301", 0) then
        YUHUILING_NUM_LIMIT = 20000
	end
	
	-- if GetTime() > Helper:getTimeStampWithStringDate("20201012", 0)  and GetTime() < Helper:getTimeStampWithStringDate("20201026", 0) then
    --     YUHUILING_NUM_LIMIT = 12500
    -- end
end

function ActivityCalendarUtils:checkActivityIsOpen(activityId)
	local startTime, endTime = self:getActivityTime(activityId)

	return self:__checkTimeIsOpen(startTime, endTime)
end

function ActivityCalendarUtils:getActivityTime(activityId)
	local info = activityTimeList[activityId]

	if MapIsEmpty(info) then
		assert(false, activityId.."活动时间配置异常")
	end

	return info.startTime, info.endTime
end

function ActivityCalendarUtils:__checkTimeIsOpen(startTime, endTime)
	if type(startTime) ~= "number" or type(endTime) ~= "number" then
		return false
	end

	local currTime = GetTime()
	if currTime >= startTime and currTime <= endTime then
		return true
	end

	return false
end

return ActivityCalendarUtils00000