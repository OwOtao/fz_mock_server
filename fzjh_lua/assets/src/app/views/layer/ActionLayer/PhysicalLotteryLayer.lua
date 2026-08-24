
local PhysicalLotteryLayer = class("PhysicalLotteryLayer", LayerEx)

function PhysicalLotteryLayer:create()
	local p = PhysicalLotteryLayer:new()
	p:init()
	return p
end
function PhysicalLotteryLayer:showLayer(activityId)
	local layer = self:getInstance()
	layer:show()
	layer:initLayer(activityId)
end
function PhysicalLotteryLayer:init()
	local UI = require("Layer/ActionUI/PhysicalLotteryUI.lua").create()['root']
	UI:addTo(self)
	Helper:convertUIByParent(self)
	self:getLayerBack()
end
function PhysicalLotteryLayer:initLayer(activityId)
	self.Panel_1:setVisible(false)
	self.Panel_2:setVisible(false)
	local str = "在活动时间内HIY累计充值100元NOR以上的玩家都可以RED参与\n周边抽奖活动NOR，我们将会在活动结束后，公布中奖名\n单，中奖的玩家可以获得我们放置江湖实物奖励。"
	self:printPreview(str)
	self:setAcivityTime(activityId)
	self:getUserUploadInfo()
end
function PhysicalLotteryLayer:setAcivityTime(activityId)
	if activityId == nil then
		return
	end
	HttpManagerEx:getNewYearFestivalState(activityId,function(status, errcode, errmsg, data)
        if status == 200 and errcode == 0  then
        	if data ~= nil and data.is_open == 1 and data.status == 1 then
    			local str = "活动时间："
    			str = str..tostring(Helper:date("%Y",tonumber(data.start))).."年"
    			str = str..tostring(Helper:date("%m",tonumber(data.start))).."月"
    			str = str..tostring(Helper:date("%d",tonumber(data.start))).."日"

    			str = str.."-"..tostring(Helper:date("%Y",tonumber(data["end"]))).."年"
      			str = str..tostring(Helper:date("%m",tonumber(data["end"]))).."月"
    			str = str..tostring(Helper:date("%d",tonumber(data["end"]))).."日"
        		self.Text_time:setString(str)
        	end
        else
            PopText(errmsg)
        end
	end, IS_SHOW_WAITING)
end
function PhysicalLotteryLayer:setButtonLottery(title,data)
	self.Button_lottery:releaseFunc(function()
		if data.count < 100 then
			PopText("您还未满足抽奖需求")
		else
			self.Panel_1:setVisible(true)
			self.Panel_1:maxZ()
			self:initPanelOne(title,data)
		end
	end)
end
function PhysicalLotteryLayer:initPanelOne(panelTitle,data)
	self.Panel_1.Text_title:setString(panelTitle)
	self:createEditBox(data)
	self:setPanelOneButtons(data)
	self.str_qq = nil
	self.str_iphone = nil
	self.str_mail = nil
end
function PhysicalLotteryLayer:setPanelOneButtons(data)
	self.Panel_1.Button_determine:releaseFunc(function()
		self.determine_time = Helper:getDef(self.determine_time,0)
		if GetTime() - self.determine_time < 5 then
			PopText("您点击的太快了")
			return
		end
		self.determine_time = GetTime()
		local qq,iphone,mail = self:getEditBoxText()
		if qq == "" and iphone == "" and mail == "" then
			PopText("您还没有填写联系信息")
			return
		end
		iphone = self:checkText(iphone,true)
		if iphone == false then
			PopText("联系电话中含有非法字符")
			return
		end
		qq = self:checkText(qq,true)
		if qq == false then
			PopText("QQ号码中含有非法字符")
			return
		end
		mail = self:checkText(mail)
		if qq == "" and iphone == "" and mail == "" then
			PopText("您填写联系信息中有非法字符")
			return
		end
		self:saveUserInfo(iphone,mail,qq,data)
		print("qq,iphone,mail,",qq,iphone,mail)
	end)
	self.Panel_1.Button_cancel:releaseFunc(function()
		self.Panel_1:setVisible(false)
	end)
end
function PhysicalLotteryLayer:checkText(str,isCheckNum)
	--去掉字符串中空格
	local char_tab = string.getChars(str)
	char_tab = self:deleteNilFromTable(char_tab)
	if char_tab == false then
		return false
	end
	if isCheckNum == true or isCheckNum == 1 then
		if self:checkCharIsNumber(string.getBytes(char_tab)) then
			return char_tab
		else
			return false
		end
	else
		return char_tab
	end
end
function PhysicalLotteryLayer:deleteNilFromTable(tab)
	if tab ~= nil and type(tab) == "table" then
		for i = #tab,1,-1 do 
			if tab[i] == " " or string.byte(tab[i]) == 32 then
				table.remove(tab,i)
			end
		end
		if #tab == 0 then
			return ""
		end
		return self:connectCharToString(tab)
	end
end
function PhysicalLotteryLayer:checkCharIsNumber(tab)
	if tab ~= nil and type(tab) == "table" then
		for k ,v in pairs(tab) do 
			if v > 57 or v < 48 then
				return false
			end
		end
		return true
	end	
	return false
end
function PhysicalLotteryLayer:connectCharToString(tab)
	if tab ~= nil and type(tab) == "table" then
		local str = ""
		for k,v in pairs(tab) do 
			str = str .. v
		end
		return str
	end	
end
function PhysicalLotteryLayer:getEditBoxText()
	local qq,iphone,mail
	iphone = self.editBoxPhone:getText()
	qq = self.editBoxQQ:getText()
	mail = self.editBoxMail:getText()
	return qq,iphone,mail
end
function PhysicalLotteryLayer:initPanelTwo()
	self.Panel_2.Button_back:releaseFunc(function()
		self.Panel_2:setVisible(false)
	end)
end
function PhysicalLotteryLayer:createEditBox(data)
	local phone,qq,mail = "","",""
	if data.info ~= false then
		phone,qq,mail = data.info.phone,data.info.qq,data.info.email
	end
	if self.editBoxPhone == nil then
		self:setEditBox("EditBoxIphone","editBoxPhone",phone)
	else
		self["editBoxPhone"]:setText(phone)
	end
	if self.editBoxQQ == nil then
		self:setEditBox("EditBoxQQ","editBoxQQ",qq)
	else
		self["editBoxQQ"]:setText(qq)
	end
	if self.editBoxMail == nil then
		self:setEditBox("EditBoxMail","editBoxMail",mail)
	else
		self["editBoxMail"]:setText(mail)
	end
end
function PhysicalLotteryLayer:setEditBox(node,name,str)
	if self.Panel_1[node] then
		local size = self.Panel_1[node]:getContentSize()
		self[name] = ccui.EditBox:create(size, "请输入")
		self[name]:setInputMode(1)
		self[name]:setInputFlag(3)
		self[name]:setReturnType(1)
		self[name]:setFontSize(54)
		self[name]:setPlaceholderFontSize(54)
		self[name]:setPlaceholderFontName("Font/default.ttf")
		self.Panel_1[node]:getParent():addChild(self[name])
		self[name]:setPosition(self.Panel_1[node]:getPositionX(), self.Panel_1[node]:getPositionY())
		str = Helper:getDef(str,"")
		self[name]:setText(str)
	else
		assert(nil)
	end
end

function PhysicalLotteryLayer:getLayerBack()
	self.Panel_back:releaseFunc(function()
		self:hide()
		self:destroyInstance() -- add by XiaoZhiWei 2017/09/11 15:05:38 弹出类窗口,隐藏时删除自身
	end)

end
function PhysicalLotteryLayer:printPreview(str, verticalSpace)
	self:initRichTextPreview()
	local textColor = cc.c3b(255,255,255)
	local textHeight = self.RichText_Print:getRichText():getNewContentSizeHeight()
	if textHeight >= 4000 then
		self:initRichTextPreview()
	end
	self.Panel_dsc:setVisible(false)
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
function PhysicalLotteryLayer:initRichTextPreview()
	local x, y = self.Panel_dsc:getPosition()
	local size = self.Panel_dsc:getContentSize()
	if self.RichText_Print then
		self.RichText_Print:removeFromParent()
		self.RichText_Print = nil
	end
	local richTextScroll = ExtRichTextScroll:create()
	richTextScroll:setAnchorPoint( 0.5 , 0.5 )
   	self.Panel_dsc:getParent():addChild(richTextScroll)
   	local point = cc.p(self.Panel_dsc:getPosition())
   	richTextScroll:move(point)
   	richTextScroll:setSize(size)
   	richTextScroll:setDirection(kCCScrollViewDirectionVertical)
   	richTextScroll:getRichText():setVerticalSpace(5)
   	self.RichText_Print = richTextScroll
   	self.RichText_Print:setBounceEnabled(false)
   	self.RichText_Print:setTouchEnabled(false)
end

function PhysicalLotteryLayer:getUserUploadInfo()
	HttpManagerEx:getUserUploadInfo(function(status, errcode, errmsg, data)
		if status == 200 and errcode == 0 then
			data = Helper:getDef(data,{count = 0,info = false})
			self.Text_money:setString("您的累计充值金额："..tostring(data.count).."元")
			if data.info == false then
				self:setButtonLottery("填写信息",data)
				self.Button_lottery.Text_button_name:setString("参与抽奖")
			else
				self:setButtonLottery("修改信息",data)
				self.Button_lottery.Text_button_name:setString("修改信息")
			end
		else
			PopText(errmsg)
		end
	end)
end

function PhysicalLotteryLayer:saveUserInfo(phoneStr,emailStr,qqStr,list)
	print("phoneStr,emailStr,qqStr,",phoneStr,emailStr,qqStr)
	HttpManagerEx:saveUserInfo(phoneStr,emailStr,qqStr,function(status, errcode, errmsg, data)
		if status == 200 and errcode == 0 then
			Helper:print_lua_table(data)
			if list.info == false then
				self.Panel_2:setVisible(true)
				self.Panel_2:maxZ()
				self.Panel_1:setVisible(false)
				self:initPanelTwo()
				self.Button_lottery.Text_button_name:setString("修改信息")
				list.info = {}
			else
				self.Panel_1:setVisible(false)
				self.Button_lottery.Text_button_name:setString("修改信息")
				PopText("修改信息成功")
			end
			for k, v in pairs(data) do 
				list.info[k] = v
			end
		else
			if list.info == false then
				PopText(errmsg)
			else
				PopText("修改信息失败")
			end
		end
	end)
end
Helper:classDefNodeGetInstance(PhysicalLotteryLayer)

return PhysicalLotteryLayer0000000