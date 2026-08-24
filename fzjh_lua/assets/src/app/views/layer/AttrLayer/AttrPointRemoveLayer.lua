--
-- Author: TanQinJian
-- Date: 2019-04-04 10:36:35
--
local AttrPointRemoveLayer= class("AttrPointRemoveLayer",cc.Layer)

function AttrPointRemoveLayer:create()
	local p = AttrPointRemoveLayer:new()
	p:init()
	return p
end

function AttrPointRemoveLayer:init()
	self._UI = require("Layer/AttrUI/AttrPointUI.lua").create()['root']
	self._UI:addTo(self)
	Helper:convertUIByParent(self)

	self:hideUI()
	self.Panel_removeAttrPoint.Button_back:releaseFunc(function()
		self:hideLayer()
	end)
end

function AttrPointRemoveLayer:showUI()
	self:setVisible(true)
	self.Panel_removeAttrPoint:setVisible(true)
end

function AttrPointRemoveLayer:hideUI()
	self:setVisible(false)
	self.Panel_removeAttrPoint:setVisible(false)
end

function AttrPointRemoveLayer:hideLayer()
	PopupLayerController:hideLayer("AttrPointRemoveLayer", function(layer)
		self:hideUI()
	end)
end

function AttrPointRemoveLayer:setUpdateFunc(scheduleFunc)
	self.__scheduleFunc = scheduleFunc
end

function AttrPointRemoveLayer:startTimeSchedule()
	if not self.__timeSchedule then
		self.__timeSchedule = self:schedule(
			function(ft)
				if self.__scheduleFunc then
					self.__scheduleFunc(ft)
				end
			end, 0.5)
	end 
end

function AttrPointRemoveLayer:endTimeSchedule()
	self:unscheduleAll()
	self.__timeSchedule = nil
end

local BtnUI_Attr = {
	["str"] = "Panel_bili_0",
	["dex"] = "Panel_shenfa_0",
	["con"] = "Panel_gengu_0",
	["int"] = "Panel_wuxing_0",
}

function AttrPointRemoveLayer:setAttrPointText(attr,text)
	if self.Panel_removeAttrPoint[BtnUI_Attr[attr]]["Text_num"] then
		self.Panel_removeAttrPoint[BtnUI_Attr[attr]]["Text_num"]:setString(text)
	end
end

function AttrPointRemoveLayer:setTotalAttrPointText(text)
	self.Panel_removeAttrPoint.Text_attrPoint:setString(text)
end

function AttrPointRemoveLayer:setXiSuiTimesText(text)
	self.Panel_removeAttrPoint.Text_removeTimes:setString(text)
end

function AttrPointRemoveLayer:setCoolTime(time)
	self.Panel_removeAttrPoint.Text_coolTimes:setString(time)
end

function AttrPointRemoveLayer:setCoolTimeVisible(visible)
	self.Panel_removeAttrPoint.Text_coolTimes:setVisible(visible)
end


function AttrPointRemoveLayer:initAttrBtnFunc(attr,func)
	if self.Panel_removeAttrPoint[BtnUI_Attr[attr]]["Button_remove"] then
		self.Panel_removeAttrPoint[BtnUI_Attr[attr]]["Button_remove"]:releaseFunc(function()
			if func then
				func()
			end
		end)
	end
end

function AttrPointRemoveLayer:setAttrBtnTouchEnable(attr,enable)
	if self.Panel_removeAttrPoint[BtnUI_Attr[attr]]["Button_remove"] then
		self.Panel_removeAttrPoint[BtnUI_Attr[attr]]["Button_remove"]:setTouchEnabled(enable)
	end
end

function AttrPointRemoveLayer:setAttrBtnTexture(attr,texture)
	if self.Panel_removeAttrPoint[BtnUI_Attr[attr]]["Button_remove"] then
		self.Panel_removeAttrPoint[BtnUI_Attr[attr]]["Button_remove"]:loadTextureNormal(texture)
	end
end

Helper:classDefNodeGetInstance(AttrPointRemoveLayer)
return AttrPointRemoveLayer00000000