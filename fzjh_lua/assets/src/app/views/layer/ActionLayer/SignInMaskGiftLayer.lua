local SignInMaskGiftLayer = class("SignInMaskGiftLayer", LayerEx)
function SignInMaskGiftLayer:create()
	local p = SignInMaskGiftLayer:new()
	p:init()
	return p
end
-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/01/09 16:03:50
-- @desc 首充页面测试方法
function SignInMaskGiftLayer:test(actionId)
	local layer = self:getInstance()
	layer:show()
	layer:initLayer(actionId)
end

function SignInMaskGiftLayer:init()
	local UI = require("Layer/ActionUI/SignInMaskGiftUI.lua").create()['root']
	UI:addTo(self)

	Helper:convertUIByParent(self)
end
function SignInMaskGiftLayer:initLayer(actionId)
	self:setButtonBack()
	self:setActionTime(actionId)
end
function SignInMaskGiftLayer:setActionTime(actionId)--设置活动时间
	if actionId == nil then
		return
	end
	HttpManagerEx:getNewYearFestivalState(actionId,function(status, errcode, errmsg, data)
        if status == 200 and errcode == 0  then
        	if data ~= nil and data.is_open == 1 and data.status == 1 then
        		local year,month,day,time,hour,min
        		year = tonumber(Helper:date("%Y", tonumber(data.start)))
        		month = tonumber(Helper:date("%m", tonumber(data.start)))
        		day = tonumber(Helper:date("%d", tonumber(data.start)))
        		time = "活动时间:活动上线——"
        		year =  tonumber(Helper:date("%Y", tonumber(data["end"])))
        		month = tonumber(Helper:date("%m", tonumber(data["end"])))
        		day = tonumber(Helper:date("%d", tonumber(data["end"])))
        		hour = tonumber(Helper:date("%H", tonumber(data["end"])))
        		min = tonumber(Helper:date("%M", tonumber(data["end"])))
        		time =time..year.."年"..month.."月"..day.."日"
        		self.Text_dsc4:setString(time)
        		self:setChannelTagVisible(actionId,data.activity_id,data.name)
        		self:initEditBox(data.activity_id)
        	end
        else
            PopText(errmsg)
        end
	end, IS_SHOW_WAITING)
end
function SignInMaskGiftLayer:initEditBox(activityId)

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
function SignInMaskGiftLayer:createEditBox()
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
	name_EditBox:setAnchorPoint(0.5000, 0.5000)
	name_EditBox:addTo(self)
	name_EditBox:setPosition(self.Panel_text:getPositionX()+16,self.Panel_text:getPositionY())
	return name_EditBox
end
function SignInMaskGiftLayer:setButtonPaste(editBox)
	self.Panel_button.Button_paste:releaseFunc(function()
		editBox:removeFromParent()
		-- self:hide()
		-- self:destroyInstance()
		PopupLayerController:hideLayer("SignInMaskGiftLayer",function(layer)
			layer:hide()
		end)
	end)
end
function SignInMaskGiftLayer:setButtonConvert(editBox,activityId)
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
function SignInMaskGiftLayer:setButtonBack()

end
function SignInMaskGiftLayer:setChannelTagVisible(actionId,activityId,title)
	self:initRichTextPreview()
	local str = "    踩着暑期的尾巴，一大批暑期开心大礼包上线啦！\n   大侠们，在此界面输入兑换码可获得RED丰厚的奖励NOR哦！"
	local str ="\n                         江湖”微“礼包来袭\n   小伙伴们，在此页面输入兑换码可获得精美面具一个。" 

	local str = "              亲爱的小伙伴，在此页面输入HIY礼包兑换码NOR，\n        即可HIY兑换礼包NOR呦！\n           \n                   HIC礼包码获取方式可咨询官方客服"
	self:printPreview(str)
	self.Text_title:setString(title)
end
function SignInMaskGiftLayer:printPreview(str, verticalSpace)
	local textColor = cc.c3b(255,255,255)
	local textHeight = self.RichText_Print:getRichText():getNewContentSizeHeight()
	if textHeight >= 4000 then
		self:initRichTextPreview()
	end
	self.Panel_10:setVisible(false)
	self.RichText_Print:pushBackText(str, textColor, 255, Resource:getFontPath("default"), 42)
	if verticalSpace ~= nil and type(verticalSpace) == "number" then
		self.RichText_print:pushBackNewLine(verticalSpace)
	else
		self.RichText_Print:pushBackNewLine()
		self.RichText_Print:pushBackNewLine(verticalSpace)
		-- self.RichText_Print:setCascadeOpacity(0)
		self.RichText_Print:jumpToTop()
		self.RichText_Print:setCascadeOpacity(255)
	end
end
function SignInMaskGiftLayer:initRichTextPreview()
	local x, y = self.Panel_10:getPosition()
	local size = self.Panel_10:getContentSize()
	if self.RichText_Print then
		self.RichText_Print:removeFromParent()
		self.RichText_Print = nil
	end
	local richTextScroll = ExtRichTextScroll:create()
	if device.platform == "android" then
		size.height = size.height * 2
		y = size.height / 1.5
		richTextScroll:setAnchorPoint( 0.5 , 0.75 )
	else
		if Game:isNewPackage() == false then
			size.height = size.height * 2
			y = size.height / 1.5
			richTextScroll:setAnchorPoint( 0.5 , 0.75 )
		else
			richTextScroll:setAnchorPoint( 0.5 , 0.5 )
		end
	end
	
   	self.Panel_10:getParent():addChild(richTextScroll)
   	local point = cc.p(self.Panel_10:getPosition())
   	richTextScroll:move(point)
   	richTextScroll:setSize(size)
   	richTextScroll:setDirection(kCCScrollViewDirectionVertical)
   	richTextScroll:getRichText():setVerticalSpace(5)
   	self.RichText_Print = richTextScroll
   	self.RichText_Print:setBounceEnabled(false)
   	self.RichText_Print:setTouchEnabled(false)
end
Helper:classDefNodeGetInstance(SignInMaskGiftLayer)
return SignInMaskGiftLayer
000