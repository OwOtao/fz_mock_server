local NewSignInGiftBagLayer = class("NewSignInGiftBagLayer", LayerEx)
function NewSignInGiftBagLayer:create()
	local p = NewSignInGiftBagLayer:new()
	p:init()
	return p
end
-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/01/09 16:03:50
-- @desc 首充页面测试方法
function NewSignInGiftBagLayer:showLayer(actionId)
	local layer = self:getInstance()
	layer:show()
	layer:initLayer(actionId)
end

function NewSignInGiftBagLayer:init()
	local UI = require("Layer/ActionUI/NewSignGiftBagUI.lua").create()['root']
	UI:addTo(self)

	Helper:convertUIByParent(self)
end
function NewSignInGiftBagLayer:initLayer(actionId)
	self:setButtonBack()
	self:setActionTime(actionId)
end
function NewSignInGiftBagLayer:setActionTime(actionId)--设置活动时间
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
        		time = "活动时间:"..year.."年"..month.."月"..day.."日-"
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
function NewSignInGiftBagLayer:initEditBox(activityId)

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
function NewSignInGiftBagLayer:createEditBox()
	self.Panel_text:setVisible(false)
	local size = self.Panel_text:getContentSize()
	size.width = size.width-16
	local name_EditBox = ccui.EditBox:create(size,"")
	name_EditBox:setInputMode(1)
	name_EditBox:setInputFlag(3)
	name_EditBox:setReturnType(1)
	name_EditBox:setFontSize(48)
	name_EditBox:setFontColor(cc.c4b(119, 119, 119,255))
	name_EditBox:setFontName("Font/default.ttf")
	name_EditBox:setAnchorPoint(0.5000, 0.5000)
	name_EditBox:setPlaceholderFontSize(48)
	name_EditBox:setPlaceholderFontName("Font/default.ttf")
	name_EditBox:addTo(self)
	name_EditBox:setPosition(self.Panel_text:getPositionX()+16,self.Panel_text:getPositionY())
	return name_EditBox
end
function NewSignInGiftBagLayer:setButtonPaste(editBox)
	self.Panel_button.Button_paste:releaseFunc(function()
		editBox:removeFromParent()
		self:hide()
		self:destroyInstance()
	end)
end
function NewSignInGiftBagLayer:setButtonConvert(editBox,activityId)
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
function NewSignInGiftBagLayer:setButtonBack()
	-- self.Panel_back_0:releaseFunc(function()
		
	-- end)
end
function NewSignInGiftBagLayer:setChannelTagVisible(actionId,activityId,title)
	self:initRichTextPreview()
	-- local str_4399 = "   小伙伴们,去RED4399游戏盒-进入广场-点击手游活动专区NOR\n                进行签到就可获得独家丰厚奖励哦！"
	-- local str_yyh = "     各位大侠们，在此页面输入礼包兑换码，即可获得\n     RED独家丰厚奖励NOR哦！"
	-- local str_4399_dujia = "   《放置江湖》一周年啦！\n   小伙伴们，在此页面输入兑换码可获得RED独家丰厚奖励NOR哦！"
	-- local str_4399_shujia = "   暑假来临，一大批礼包清凉上线啦！\n   小伙伴们，在此页面输入兑换码可获得RED丰厚的奖励NOR哦！"
	local str = "    踩着暑期的尾巴，一大批暑期开心大礼包上线啦！\n   大侠们，在此界面输入兑换码可获得RED丰厚的奖励NOR哦！"
	self:printPreview(str)
	self.Text_title:setString(title)
	-- if device.platform == "android" then
	-- 	if CURR_DEVICE_CHANNEL == "4399" then
	-- 		for i=1,6 do
	-- 			self.Panel_image["Panel_"..tostring(i)]:setVisible(true)
	-- 		end
	-- 		self.Text_title:setString(title)
	-- 		if title == "4399活动礼包" then
	-- 			self.Text_2:setString("签到兑换码")
	-- 			self.Panel_image["Panel_7"]:setVisible(false)
	-- 			self:printPreview(str_4399)
	-- 		elseif title == "4399暑期清凉礼包" then
	-- 			self.Text_2:setString("兑换码")
	-- 			for i=1,7 do
	-- 				self.Panel_image["Panel_"..tostring(i)]:setVisible(false)
	-- 			end
	-- 			self.Text_title:setString(title)
	-- 			self:printPreview(str_4399_shujia)
	-- 			self.Panel_image["Panel_3"]:setVisible(true)
	-- 			self.Panel_image["Panel_3"].Image_2:loadTexture("Image/UI/SignInUI/baoxiang-7.png")
	-- 			self.Panel_image["Panel_3"].Text_1:setString("暑期VIP礼包")
	-- 			self.Panel_image["Panel_3"]:setPositionX(self.Panel_image["Panel_3"]:getPositionX()-100)
	-- 			self.Panel_image["Panel_4"]:setVisible(true)
	-- 			self.Panel_image["Panel_4"].Image_2:loadTexture("Image/UI/SignInUI/baoxiang-2.png")
	-- 			self.Panel_image["Panel_4"].Text_1:setString("暑期新手礼包")
	-- 			self.Panel_image["Panel_4"]:setPositionX(self.Panel_image["Panel_4"]:getPositionX()+100)	
	-- 		else
	-- 			self.Text_2:setString("兑换码")
	-- 			for i=1,7 do
	-- 				self.Panel_image["Panel_"..tostring(i)]:setVisible(false)
	-- 			end
	-- 			self:printPreview(str_4399_dujia)
	-- 			self.Panel_image["Panel_3"]:setVisible(true)
	-- 			self.Panel_image["Panel_3"].Image_2:loadTexture("Image/UI/SignInUI/baoxiang-7.png")
	-- 			self.Panel_image["Panel_3"].Text_1:setString("独家礼包")
	-- 			self.Panel_image["Panel_4"]:setVisible(true)
	-- 			self.Panel_image["Panel_4"].Image_2:loadTexture("Image/UI/SignInUI/baoxiang-2.png")
	-- 			self.Panel_image["Panel_4"].Text_1:setString("新手礼包")
	-- 		end
	-- 	elseif CURR_DEVICE_CHANNEL == "yyh" then
	-- 		self.Text_title:setString(title)
	-- 		self.Text_2:setString("签到兑换码")
	-- 		self.Image_tag:setVisible(false)
	-- 		for i=1,6 do
	-- 			self.Panel_image["Panel_"..tostring(i)]:setVisible(false)
	-- 		end
	-- 		self.Text_title:setString(title)
	-- 		self.Panel_image["Panel_7"]:setVisible(true)
	-- 		self.Panel_image["Panel_7"].Text_1:setVisible(false)
	-- 		self:printPreview(str_yyh)
	-- 	end
	-- elseif device.platform == "ios" then
	-- 	self.Image_tag:setVisible(false)
	-- else
	-- 	if title == "4399活动礼包" then
	-- 		self.Text_title:setString(title)
	-- 		self.Text_2:setString("签到兑换码")
	-- 		self.Panel_image["Panel_7"]:setVisible(false)
	-- 		self:printPreview(str_4399)
	-- 	elseif title == "应用汇活动礼包" then
	-- 		self.Text_title:setString(title)
	-- 		self.Text_2:setString("签到兑换码")
	-- 		self.Image_tag:setVisible(false)
	-- 		for i=1,6 do
	-- 			self.Panel_image["Panel_"..tostring(i)]:setVisible(false)
	-- 		end
	-- 		self.Text_title:setString(title)
	-- 		self.Panel_image["Panel_7"]:setVisible(true)
	-- 		self.Panel_image["Panel_7"].Text_1:setVisible(false)
	-- 		self:printPreview(str_yyh)
	-- 	elseif title == "4399暑期清凉礼包" then
	-- 		self.Text_2:setString("兑换码")
	-- 		for i=1,7 do
	-- 			self.Panel_image["Panel_"..tostring(i)]:setVisible(false)
	-- 		end
	-- 		self.Text_title:setString(title)
	-- 		self:printPreview(str_4399_shujia)
	-- 		self.Panel_image["Panel_3"]:setVisible(true)
	-- 		self.Panel_image["Panel_3"].Image_2:loadTexture("Image/UI/SignInUI/baoxiang-7.png")
	-- 		self.Panel_image["Panel_3"].Text_1:setString("暑期VIP礼包")
	-- 		self.Panel_image["Panel_3"]:setPositionX(self.Panel_image["Panel_3"]:getPositionX()-100)
	-- 		self.Panel_image["Panel_4"]:setVisible(true)
	-- 		self.Panel_image["Panel_4"].Image_2:loadTexture("Image/UI/SignInUI/baoxiang-2.png")
	-- 		self.Panel_image["Panel_4"].Text_1:setString("暑期新手礼包")
	-- 		self.Panel_image["Panel_4"]:setPositionX(self.Panel_image["Panel_4"]:getPositionX()+100)
	-- 	else
	-- 		self.Text_2:setString("兑换码")
	-- 		self.Text_title:setString(title)
	-- 		for i=1,7 do
	-- 			self.Panel_image["Panel_"..tostring(i)]:setVisible(false)
	-- 		end
	-- 		self:printPreview(str_4399_shujia)
	-- 		self.Panel_image["Panel_3"]:setVisible(true)
	-- 		self.Panel_image["Panel_3"].Image_2:loadTexture("Image/UI/SignInUI/baoxiang-7.png")
	-- 		self.Panel_image["Panel_3"].Text_1:setString("独家礼包")
	-- 		self.Panel_image["Panel_4"]:setVisible(true)
	-- 		self.Panel_image["Panel_4"].Image_2:loadTexture("Image/UI/SignInUI/baoxiang-2.png")
	-- 		self.Panel_image["Panel_4"].Text_1:setString("新手礼包")
	-- 	end
	-- end
end
function NewSignInGiftBagLayer:printPreview(str, verticalSpace)
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
		self.RichText_Print:setCascadeOpacity(0)
		self:delayFunc(0.4,function ()
			self.RichText_Print:jumpToTop()
			self.RichText_Print:setCascadeOpacity(255)
		end)
	end
end
function NewSignInGiftBagLayer:initRichTextPreview()
	local x, y = self.Panel_10:getPosition()
	local size = self.Panel_10:getContentSize()
	if self.RichText_Print then
		self.RichText_Print:removeFromParent()
		self.RichText_Print = nil
	end
	local richTextScroll = ExtRichTextScroll:create()
	richTextScroll:setAnchorPoint( 0.5 , 0.5 )
   	self.Panel_10:getParent():addChild(richTextScroll)
   	local point = cc.p(self.Panel_10:getPosition())
   	richTextScroll:move(point)
   	richTextScroll:setSize(size)
   	richTextScroll:setDirection(kCCScrollViewDirectionVertical)
   	richTextScroll:getRichText():setVerticalSpace(5)
   	self.RichText_Print = richTextScroll
   	self.RichText_Print:setBounceEnabled(false)
end
Helper:classDefNodeGetInstance(NewSignInGiftBagLayer)
return NewSignInGiftBagLayer
000