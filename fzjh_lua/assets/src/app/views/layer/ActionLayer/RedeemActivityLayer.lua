local RedeemActivityLayer = class("RedeemActivityLayer", LayerEx)
function RedeemActivityLayer:create()
	local p = RedeemActivityLayer:new()
	p:init()
	return p
end

function RedeemActivityLayer:showLayer(actionId)
	local layer = self:getInstance()
	layer:show()
	layer:initLayer(actionId)
end

function RedeemActivityLayer:init()
	local UI = require("Layer/ActionUI/RedeemActivityUI.lua").create()['root']
	UI:addTo(self)

	Helper:convertUIByParent(self)
end

function RedeemActivityLayer:initLayer(actionId)
	self:setActionTime(actionId)
end

function RedeemActivityLayer:setActionTime(actionId)--设置活动时间
	if actionId == nil then
		return
	end
	HttpManagerEx:getNewYearFestivalState(actionId,function(status, errcode, errmsg, data)
        if status == 200 and errcode == 0  then
        	if data ~= nil and data.is_open == 1 and data.status == 1 then
        		self:initEditBox(data.activity_id)
        	end
        else
            PopText(errmsg)
        end
	end, IS_SHOW_WAITING)
end

function RedeemActivityLayer:initEditBox(activityId)

	local editBox  = self:createEditBox()
	editBox:setText("此处输入礼品码,长按可粘贴")
	editBox:onEditHandler(function(event)
		if event.name == "began" then
			editBox:setText("")
			editBox:setFontColor(cc.c4b(208, 208, 208,255))
		elseif event.name == "changed" then

		elseif event.name == "return" then 
		end
	end)
	self:setButtonConvert(editBox,activityId)
	self:setButtonPaste(editBox)
end
function RedeemActivityLayer:createEditBox()
	self.Panel_text:setVisible(false)
	local size = self.Panel_text:getContentSize()
	size.width = size.width-16
	local name_EditBox = ccui.EditBox:create(size," ")
	name_EditBox:setInputMode(1)
	name_EditBox:setInputFlag(3)
	name_EditBox:setReturnType(1)
	name_EditBox:setFontSize(48)
	name_EditBox:setFontColor(cc.c4b(119, 119, 119,255))
	name_EditBox:setFontName("Font/default.ttf")
	name_EditBox:setPlaceholderFontSize(48)
	name_EditBox:setPlaceholderFontName("Font/default.ttf")
	name_EditBox:setAnchorPoint(0.5000, 0.5000)
	name_EditBox:addTo(self)
	name_EditBox:setPosition(self.Panel_text:getPositionX()+16,self.Panel_text:getPositionY())
	return name_EditBox
end
function RedeemActivityLayer:setButtonPaste(editBox)
	self.Panel_button.Button_paste:releaseFunc(function()
		editBox:removeFromParent()
		self:hide()
		self:destroyInstance()
	end)
end
function RedeemActivityLayer:setButtonConvert(editBox,activityId)
	self.Panel_button.Button_convert:releaseFunc(function()
		--PopText(self.editBox:getText())
		local convertStr = editBox:getText()
		self.Panel_button.Button_convert:setTouchEnabled(false)
		if convertStr == nil or convertStr == "" or string.len(convertStr) ~= 12 then
			PopText("兑换码错误")
			self.Panel_button.Button_convert:setTouchEnabled(true)
			return
		else
			--4399qiandao3
			local rwdTab = {}
			rwdTab["4399qiandao3"] = 1
			if User:getRole():checkCanBuyTwoOrMoreThings(rwdTab) == true then
				HttpManagerEx:getVoucherPrize(convertStr,activityId,function(status, errcode, errmsg, data, isEncrypted)
					if status == 200 and errcode == 0 then
						data = Helper:getDef(data,{})
						if data.yuanbao then--只能获取一种奖励，优先判断是否有元宝
							PopText("元宝X"..tostring(data.yuanbao))
						elseif data["itemId"] then
							PopText("领取成功,请到背包中查看")
							User:getRole():addItemCount(data["itemId"], 1)
						else
							PopText("领取异常，请联系客服!")
						end
						self.Panel_button.Button_convert:setTouchEnabled(true)
					elseif status == 200 and errcode == 8 then
						PopText("请重试")
						self.Panel_button.Button_convert:setTouchEnabled(true)
					else
						PopText(errmsg)
						self.Panel_button.Button_convert:setTouchEnabled(true)
					end
				end)
			else
				PopText("背包空间不足,无法领取")
				self.Panel_button.Button_convert:setTouchEnabled(true)
			end
		end

		--PopText(self.Panel_text.TextField_2:getStringValue())
	end)
end

Helper:classDefNodeGetInstance(RedeemActivityLayer)
return RedeemActivityLayer
0000