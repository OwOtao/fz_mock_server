local QuestionnaireLayer = class("QuestionnaireLayer", LayerEx)

function QuestionnaireLayer:create()
	local p = QuestionnaireLayer:new()
	p:init()
	return p
end
function QuestionnaireLayer:showLayer()
	local layer = self:getInstance()
	layer:show()
    self:initPanelOne()
end
function QuestionnaireLayer:init()
	local UI = require("Layer/ActionUI/QuestionnaireUI.lua").create()['root']
	UI:addTo(self)
	
	Helper:convertUI(self)
	self:setPanelBack()
	self:getLayerBack()
end

--点击空白处，取消
function QuestionnaireLayer:setPanelBack()
	self.Panel_back:releaseFunc(function()
		    PopText("本次问卷尚未提交。")
			self:hide()
		end)
end

function QuestionnaireLayer:initPanelOne()
	-- self.Text_title:setString("")
	self:createEditBox()
	self:setPanelOneButtons()
	
end
function QuestionnaireLayer:setPanelOneButtons(func)
	self.Button_determine:releaseFunc(function()
		self.determine_time = Helper:getDef(self.determine_time,0)
		if GetTime() - self.determine_time < 5 then
			PopText("您点击的太快了")
			return
		end
		self.determine_time = GetTime()
		local iphone = self:getEditBoxText()
		if iphone == "" then
			PopText("您还没有填写联系信息")
			return
		end
		iphone = self:checkText(iphone,true)
		if iphone == false then
			PopText("联系电话中含有非法字符")
			return
		end
		if iphone == "" then
			PopText("请填写手机号码！")
			return
		end
		self:saveUserInfo(iphone)
        self:hide()
        if func then
            func()
        end
		print("qq,iphone,mail,",iphone)
	end)
end
function QuestionnaireLayer:checkText(str,isCheckNum)
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
function QuestionnaireLayer:deleteNilFromTable(tab)
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
function QuestionnaireLayer:checkCharIsNumber(tab)
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
function QuestionnaireLayer:connectCharToString(tab)
	if tab ~= nil and type(tab) == "table" then
		local str = ""
		for k,v in pairs(tab) do 
			str = str .. v
		end
		return str
	end	
end
function QuestionnaireLayer:getEditBoxText()
	local iphone
	iphone = self.editBoxPhone:getText()
	return iphone
end
function QuestionnaireLayer:createEditBox()
	local phone = ""
	-- if data.info ~= false then
	-- 	phone,qq,mail = data.info.phone,data.info.qq,data.info.email
	-- end
	if self.editBoxPhone == nil then
		self:setEditBox("EditBoxIphone","editBoxPhone",phone)
	else
		self["editBoxPhone"]:setText(phone)
	end
end
function QuestionnaireLayer:setEditBox(node,name,str)
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

function QuestionnaireLayer:getLayerBack()
	-- self.Panel_back:releaseFunc(function()
	-- 	self:hide()
	-- 	self:destroyInstance() -- add by XiaoZhiWei 2017/09/11 15:05:38 弹出类窗口,隐藏时删除自身
	-- end)
end

function QuestionnaireLayer:saveUserInfo(phoneStr)
	local role = User:getRole()
	local rwdTab = {["wjgift1"] = 1}
	-- local rwdTab = {["dao120"] = 1}
	if role:checkCanBuyTwoOrMoreThings(rwdTab) == true then
		HttpManagerEx:saveUserInfo(phoneStr,emailStr,qqStr,function(status, errcode, errmsg, data)
		    if status == 200 and errcode == 0 then
		    	role:setInheritFlag("tiankongti",1)
		    	PopText("提交成功！")
			    -- role:setFlag("问卷调查次数",1)
			    role:addItemCount("wjgift1",1)
			    -- role:addItemCount("dao120",1)
			    local item = Item:getOneItemByKey("wjgift1")
			    -- local item = Item:getOneItemByKey("dao120")
			    PopText("您获得 " .. item.name .. " x1")
		    end
		end)
    else
    	PopText("本次问卷尚未提交")
    	PopText(errmsg)
	end
end

Helper:classDefNodeGetInstance(QuestionnaireLayer)

return QuestionnaireLayer0