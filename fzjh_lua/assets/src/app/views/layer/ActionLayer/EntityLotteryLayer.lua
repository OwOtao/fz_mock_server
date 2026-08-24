
local EntityLotteryLayer = class("EntityLotteryLayer", LayerEx)

function EntityLotteryLayer:create()
	local p = EntityLotteryLayer:new()
	p:init()
	return p
end
function EntityLotteryLayer:showLayer()
	local layer = self:getInstance()
	layer:show()
    self:initPanelOne()
end
function EntityLotteryLayer:init()
	local UI = require("Layer/ActionUI/EntityLotteryUI.lua").create()['root']
	UI:addTo(self)
	Helper:convertUIByParent(self)
	self:getLayerBack()
end

function EntityLotteryLayer:initPanelOne()
	-- self.Text_title:setString("")
	self:createEditBox()
	self:setPanelOneButtons()
	
end
function EntityLotteryLayer:setPanelOneButtons(func)
	self.Button_determine:releaseFunc(function()
		self.determine_time = Helper:getDef(self.determine_time,0)
		if GetTime() - self.determine_time < 5 then
			PopText("您点击的太快了")
			return
		end
		self.determine_time = GetTime()
		local name,iphone,addr,qq = self:getEditBoxText()

        name = self:checkText(name)
		addr = self:checkText(addr)
		qq = self:checkText(qq,true)
		if name == "" and iphone == "" and addr == "" and qq == "" then
			PopText("您还没有填写联系信息")
			return
		end

		if name =="" then
			PopText("请填写收件人！")
			return
		end

		if iphone == "" then
			PopText("请填写手机号码！")
			return
		else
			iphone = self:checkPhone(iphone)
			if iphone == false then
				PopText("请输入正确的手机号码！")
				return
			elseif iphone == "请输入11位数的手机号码！" then
				PopText("请输入11位数的手机号码！")
				return
			end
		end

		if addr == "" then
			PopText("请填写收件地址！")
			return
		end

		if qq == "" then
			PopText("请填写QQ号码！")
			return
		end
		

		if qq == false then
			PopText("请输入正确的QQ号吗")
			return
		end

		self:saveUserInfo(iphone,addr,name,qq,func)
        self:hide()
		-- print("name,iphone,addr,",name,iphone,addr)
	end)
	self.Button_cancel:releaseFunc(function()
		self:hide()
	end)
end

function EntityLotteryLayer:checkPhone(str)
	--去掉字符串中空格
	local phonestr = string.getChars(str)
	phonestr = self:deleteNilFromTable(phonestr)
	if phonestr == false then
		return false
	end

	if #phonestr ~= 11 then
		phonestr =  "请输入11位数的手机号码！"
		return phonestr
	end

	if string.match(phonestr,"^1[3-9]%d+$") == nil then
		return false
	else
		return phonestr
	end
end


function EntityLotteryLayer:checkText(str,isCheckNum)
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
function EntityLotteryLayer:deleteNilFromTable(tab)
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
function EntityLotteryLayer:checkCharIsNumber(tab)
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
function EntityLotteryLayer:connectCharToString(tab)
	if tab ~= nil and type(tab) == "table" then
		local str = ""
		for k,v in pairs(tab) do 
			str = str .. v
		end
		return str
	end	
end
function EntityLotteryLayer:getEditBoxText()
	local name,iphone,addr,qq
	iphone = self.editBoxPhone:getText()
	name = self.editBoxName:getText()
	addr = self.editBoxAddr:getText()
	qq = self.editBoxQQ:getText()
	return name,iphone,addr,qq
end
-- function EntityLotteryLayer:initPanelTwo()
-- 	self.Panel_2.Button_back:releaseFunc(function()
-- 		self.Panel_2:setVisible(false)
-- 	end)
-- end
function EntityLotteryLayer:createEditBox()
	local phone,name,addr,qq = "","","",""
	-- if data.info ~= false then
	-- 	phone,qq,mail = data.info.phone,data.info.qq,data.info.email
	-- end
	if self.editBoxPhone == nil then
		self:setEditBox("EditBoxPhone","editBoxPhone",phone)
	else
		self["editBoxPhone"]:setText(phone)
	end
	
	if self.editBoxName == nil then
		self:setEditBox("EditBoxName","editBoxName",name)
	else
		self["editBoxName"]:setText(name)
	end

	if self.editBoxAddr == nil then
		self:setEditBox("EditBoxAddr","editBoxAddr",addr)
	else
		self["editBoxAddr"]:setText(addr)
	end
	
	if self.editBoxQQ == nil then
		self:setEditBox("EditBoxQQ","editBoxQQ",qq)
	else
		self["editBoxQQ"]:setText(qq)
	end
end
function EntityLotteryLayer:setEditBox(node,name,str)
	if self[node] then
		local size = self[node]:getContentSize()
		self[name] = ccui.EditBox:create(size, "请输入")
		self[name]:setInputMode(1)
		self[name]:setInputFlag(3)
		self[name]:setReturnType(1)
		self[name]:setFontSize(54)
        self[name]:setPlaceholderFontSize(54)
        self[name]:setPlaceholderFontName("Font/default.ttf")
		self[node]:getParent():addChild(self[name])
		self[name]:setPosition(self[node]:getPositionX(), self[node]:getPositionY())
		str = Helper:getDef(str,"")
		self[name]:setText(str)
	else
		assert(nil)
	end
end

function EntityLotteryLayer:getLayerBack()
	self.Panel_back:releaseFunc(function()
		self:hide()
		self:destroyInstance() -- add by XiaoZhiWei 2017/09/11 15:05:38 弹出类窗口,隐藏时删除自身
	end)

end

function EntityLotteryLayer:saveUserInfo(phoneStr,addrStr,nameStr,qqStr,func)
	print("phoneStr,addrStr,nameStr,qqStr",phoneStr,addrStr,nameStr,qqStr)
	HttpManagerEx:saveUserInfo(phoneStr,addrStr,nameStr,qqStr,function(status, errcode, errmsg, data)
		if status == 200 and errcode == 0 then
			PopText("提交成功！")
			if func then
            	func()
        	end
			RichPrint("main","YEL您的个人信息已经提交成功，我们将尽快安排客服与您联系、给您邮寄相关物品，届时请留意。")
		else
			PopText(errmsg)
		end
	end)
end
Helper:classDefNodeGetInstance(EntityLotteryLayer)

return EntityLotteryLayer00000000000000