--
-- Author: TanQinJian
-- Date: 2020-05-21 18:16:12
--
local ActivityCalendarLayer = class("ActivityCalendarLayer", LayerEx)
local activityList = {}

function ActivityCalendarLayer:create()
	local p = ActivityCalendarLayer:new()
	p:init()
	return p
end

function ActivityCalendarLayer:init()
	local UI = require("Layer/ActionUI/ActivityCalendarUI.lua").create()['root']
	UI:addTo(self)

	Helper:convertUI(self)

	--self:setPanelBack()
	self.Panel_row:setVisible(false)
	self.Button_back:releaseFunc(function()
		self:hideLayer()
	end)
	self:setVisible(false)
end

function ActivityCalendarLayer:showLayer()
	HttpManagerEx:getActivityCalendar(function(status, errcode, errmsg, data)
		if status == 200 and errcode == 0 then
			activityList = data.list
			local jiaoziNum = Helper:getDef(data.point,0) 
			if jiaoziNum then 
				self.Text_money:setString("游字令："..tostring(data.point))
			end
			self:initUI()
			self:setVisible(true)
		else
			PopText(errmsg)
		end
	end, IS_SHOW_WAITING)
end

function ActivityCalendarLayer:hideLayer()
	self:hide()
	self:destroyInstance()
end

function ActivityCalendarLayer:initUI()
	self.Text_huodong:setString("八方游历")
	self.ListView_list:removeAllItems()
	for k,activity in pairs(activityList) do
		local row = self:createOneRow(activity)
		if not activity.status then 
			activity.status = 0
		end
		--0表示未开始，1表示正在进行中，2表示下一个活动 3已结束
		if tonumber(activity.status) == 0 or tonumber(activity.status) == 3 then   
			row.Text_title:setColor({r = 117, g = 117, b = 117})
			row.Text_time:setColor({r = 74, g = 74, b = 74})
			row.Text_descStr:setColor({r = 74, g = 74, b = 74})
			row.Text_desc:setColor({r = 74, g = 74, b = 74})
		elseif tonumber(activity.status) == 1 then
			row.Text_title:setColor({r = 200, g = 184, b = 65})
			row.Text_time:setColor({r = 140, g = 33, b = 33})
			row.Text_descStr:setColor({r = 54, g = 82, b = 166})
			row.Text_desc:setColor({r = 54, g = 82, b = 166})
		elseif tonumber(activity.status) == 2 then
			row.Text_title:setColor({r = 213, g = 213, b = 213})
			row.Text_time:setColor({r = 183, g = 183, b = 183})
			row.Text_descStr:setColor({r = 130, g = 130, b = 130})
			row.Text_desc:setColor({r = 130, g = 130, b = 130})
		end
		if tonumber(activity.status) == 3 then
			row.Image_end:setVisible(true)
		else
			row.Image_end:setVisible(false)
		end
		self.ListView_list:pushBackCustomItem(row)
	end
end
--[[
	title_1 color r g b 200 184 65
	----------#c8b841------200 184 65
	----------#8c2121------140 33  33
	----------#3652A6------54  82  166
	----------#d5d5d5------213  213  213
	----------#b7b7b7------183  183  183
	----------#828282------130  130  130
	----------#757575------117  117  117
	----------#4a4a4a------74  74  74
]]
function ActivityCalendarLayer:createOneRow(activity)
	if not activity then
		return
	end
	local row = self.Panel_row:clone()
	Helper:convertUI(row)
	row:setVisible(true)
	row.Text_title:setString(activity.name)
	--2020-05-20 00:00:00 格式固定 直接按照位置取
	local start_time = activity.start_time
	local end_time = activity.end_time
	local start_m,start_d,start_h,end_m,end_d,end_h
	start_m = string.sub(start_time,6,7)
	start_d = string.sub(start_time,9,10)
	start_h = string.sub(start_time,12,13)

	end_m = string.sub(end_time,6,7)
	end_d = string.sub(end_time,9,10)
	end_h = string.sub(end_time,12,13)

	local str_time = start_m.."月"..start_d.."日"..start_h.."时"..
	"—"..end_m.."月"..end_d.."日"..end_h.."时"

	row.Text_time:setString(str_time)
	row.Text_descStr:setString(activity.gift)
	return row
end

Helper:classDefNodeGetInstance(ActivityCalendarLayer)
return ActivityCalendarLayer
0000000000000