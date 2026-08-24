local BindingMailLayer = class("BindingMailLayer", LayerEx)

local ControllLayer = require("app.views.layer.ControllLayer")

function BindingMailLayer:create()
	local p = BindingMailLayer:new()
	p:init()
	return p
end

function BindingMailLayer:ctor()
	self._fm = FunctionManager:create()
end

function BindingMailLayer:init()
	local UI = require("Layer/BindingMailUI.lua").create()["root"]
	UI:addTo(self)

	Helper:convertUIByParent(self)
	self.editBoxMail = nil
	self.editBoxCodes = nil

	self.editBoxMailStr = ""
	self.editBoxCodesStr = ""

	self.isSend = false				--邮件已发送 下次发送60秒间隔
	self.sendTime = 0
	self.sendInterval = 0

	self._isMailEditing = false			--是否正在编辑邮箱
	self._isCodeEditing = false			--是否正在编辑验证码

	self:schedule(
	function(ft)
		self:update(ft)
	end, 1)
end

function BindingMailLayer:show()
	self._isMailEditing = false
	self._isCodeEditing = false
	self:setBack()
	self:setVisible(true)
	self:setEditBox()
	self:setButtonCodes()
	self:setButtonBind()
end

function BindingMailLayer:hide()
	PopupLayerController:hideLayer("BindingMailLayer", function(layer)
		self:setVisible(false)
	end)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 增加回调
function BindingMailLayer:addCallback(func)
	self._fm:addFunction(func)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 调用回调
function BindingMailLayer:callCallbacks(eventName)
	self._fm:callFunctions(eventName)
end

function BindingMailLayer:setBack()
	self.Image_back:releaseFunc(function()
		if self._isMailEditing == true or self._isCodeEditing == true then
			return
		end
		--self:hide()
	end)

	self.Panel_back:releaseFunc(function()
		if self._isMailEditing == true or self._isCodeEditing == true then
			return
		end
		self:hide()
	end)
end

function BindingMailLayer:setEditBox()
	self.editBoxMailStr = ""
	self.editBoxCodesStr = ""

	--邮箱输入框
	if self.editBoxMail == nil then
		local size = self.EditBoxMail:getContentSize()
		self.editBoxMail = ccui.EditBox:create(size, "请输入")

		self.editBoxMail:setInputMode(1)
		self.editBoxMail:setInputFlag(3)
		self.editBoxMail:setReturnType(1)
		self.editBoxMail:setFontSize(62)

		self.editBoxMail:setPlaceholderFontSize(62)
		self.editBoxMail:setPlaceholderFontName("Font/default.ttf")

		self.EditBoxMail:getParent():addChild(self.editBoxMail)
		self.editBoxMail:setPosition(self.EditBoxMail:getPositionX(), self.EditBoxMail:getPositionY())

		self.editBoxMail:onEditHandler(function(event)
			local eventName = event.name
			local eventTarget = event.target

			if eventName == "began" then
				self._isMailEditing = true
			elseif eventName == "changed" then
				if not device.platform == "android" then 
					self._isMailEditing = true
				end
				self.editBoxMailStr = self.editBoxMail:getText()
			elseif eventName == "return" then
				self._isMailEditing = false
			end
		end)
	end
	self.editBoxMail:setText("")

	--验证码输入框
	if self.editBoxCodes == nil then
		local size = self.EditBoxCodes:getContentSize()
		self.editBoxCodes = ccui.EditBox:create(size, "请输入")

		self.editBoxCodes:setInputMode(1)
		self.editBoxCodes:setInputFlag(3)
		self.editBoxCodes:setReturnType(1)
		self.editBoxCodes:setFontSize(62)
		self.editBoxMail:setPlaceholderFontSize(62)
		self.editBoxMail:setPlaceholderFontName("Font/default.ttf")

		self.EditBoxCodes:getParent():addChild(self.editBoxCodes)
		self.editBoxCodes:setPosition(self.EditBoxCodes:getPositionX(), self.EditBoxCodes:getPositionY())
		self.editBoxCodes:setMaxLength(6)

		self.editBoxCodes:onEditHandler(function(event)
			local eventName = event.name
			local eventTarget = event.target

			if eventName == "began" then
				self._isCodeEditing = true
			elseif eventName == "changed" then
				if not device.platform == "android" then 
					self._isCodeEditing = true
				end
				self.editBoxCodesStr = self.editBoxCodes:getText()
			elseif eventName == "return" then
				self._isCodeEditing = false
			end
		end)
	end
	self.editBoxCodes:setText("")
end

function BindingMailLayer:setButtonCodes()
	--获取验证码
	self.Button_Send:releaseFunc(function()
		if self._isMailEditing == true or self._isCodeEditing == true then
			return
		end

		if self.editBoxMailStr== "" then
			PopText("请填写正确邮箱地址")
			return
		end

		--正在发送中
		if self.isSend == true then
			PopText("你发送太频繁了")
			return
		end

		Account:sendEmail("绑定", self.editBoxMailStr,
		function(eventName, expired_time, errmsg)
			if eventName == "发送成功" then
				PopText("发送成功")
				self.sendTime = GetTime()
				self.isSend = true
			elseif eventName == "发送失败" then
				PopText(errmsg)
			else
				error()
			end
		end)

	end)
end

function BindingMailLayer:setButtonBind()
	--确认绑定
	self.Button_Bind:releaseFunc(function()
		if self._isMailEditing == true or self._isCodeEditing == true then
			return
		end

		if self.editBoxMailStr== "" or self.editBoxCodesStr == "" then
			PopText("请填写正确邮箱地址和验证码")
			return
		end

		HttpManagerEx:bindDevice(self.editBoxMailStr, tonumber(self.editBoxCodesStr), function(status, errcode, errmsg, data)
			if status == 200 then
				if 0 == errcode then
					self.sendTime = 0
					local SetupLayer = ControllLayer:getInstance():getLayer("SetupLayer")
					SetupLayer:setTextBindMail()
					self:callCallbacks("绑定成功")
					PopText("绑定成功")
				else
					PopText(tostring(errmsg))
				end
				
			else
	    		PopText("网络请求出错,请换个网络环境再试!")
			end
		end, IS_SHOW_WAITING)
	end)
end

function BindingMailLayer:update( ft )
	if self.isSend == true then
		self.sendInterval = math.floor(60 - ( GetTime() - self.sendTime ) )

		--60秒后才可再次发送验证码
		if self.sendInterval <= 0 then
			self.isSend = false
			self.Button_Send.Text_SendName:setString("获取验证码")
			self.Button_Send:setTouchEnabled(true)
		else
			self.Button_Send.Text_SendName:setString(tostring(self.sendInterval) .. "秒后重新获取")
			self.Button_Send:setTouchEnabled(false)
		end
	end
end

Helper:classDefNodeGetInstance(BindingMailLayer)

return BindingMailLayer
000