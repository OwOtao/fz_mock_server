local BindingShiMingLayer = class("BindingShiMingLayer", LayerEx)

local ControllLayer = require("app.views.layer.ControllLayer")


function BindingShiMingLayer:create()
	local p = BindingShiMingLayer:new()
	p:init()
	return p
end

function BindingShiMingLayer:ctor()
	self._fm = FunctionManager:create()
end

function BindingShiMingLayer:init()
	local UI = require("Layer/BindingShiming.lua").create()["root"]
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

function BindingShiMingLayer:show()
	self._isMailEditing = false
	self._isCodeEditing = false
	self:setBack()
	self:setVisible(true)
	self:setEditBox()
	self:setButtonCodes()
	self:setButtonBind()
end

function BindingShiMingLayer:hide()
	PopupLayerController:hideLayer("BindingShiMingLayer", function(layer)
		self:setVisible(false)
	end)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 增加回调
function BindingShiMingLayer:addCallback(func)
	self._fm:addFunction(func)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 调用回调
function BindingShiMingLayer:callCallbacks(eventName)
	self._fm:callFunctions(eventName)
end

function BindingShiMingLayer:setBack()
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

function BindingShiMingLayer:setEditBox()
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

function BindingShiMingLayer:setButtonCodes()
	--获取验证码
	self.Button_Send:releaseFunc(function()
		if self._isMailEditing == true or self._isCodeEditing == true then
			return
		end

		if self.editBoxMailStr== "" then
			PopText("请填写正确手机号码")
			return
		end

		--正在发送中
		if self.isSend == true then
			PopText("你发送太频繁了")
			return
		end
		local function callback1(eventName, expired_time, errmsg)
			if eventName == "发送成功" then
				PopText("发送成功")
				self.sendTime = GetTime()
				self.isSend = true
			elseif eventName == "发送失败" then
				PopText(errmsg)
			else
				error()
			end
		end

		HttpManagerEx:sendVerifyCode("phone", self.editBoxMailStr, 1,
		 function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    local expired_time = data.expired_time
                    callback1("发送成功", expired_time, errmsg)
                    -- print("发送成功 expired_time = " .. tostring(expired_time))
                else
                    callback1("发送失败", expired_time, errmsg)
                    -- print("发送失败")
                end
                return true
            end
		end,IS_SHOW_WAITING, HTTP_MANAGER_RETRY_TYPE_RETRY)
	end)
end

function BindingShiMingLayer:setButtonBind()
	--确认绑定
	self.Button_Bind:releaseFunc(function()
		if self._isMailEditing == true or self._isCodeEditing == true then
			return
		end

		if self.editBoxMailStr== "" or self.editBoxCodesStr == "" then
			PopText("请填写正确手机号码和验证码")
			return
		end

		HttpManagerEx:bindDevice2("phone",self.editBoxMailStr, tonumber(self.editBoxCodesStr), function(status, errcode, errmsg, data)
			if status == 200 then
				if 0 == errcode then
					self.sendTime = 0
					PopText("实名认证成功")
					self:callCallbacks("绑定成功")
					self:hide()
				else
					PopText(tostring(errmsg))
				end
			else
	    		PopText("网络请求出错,请换个网络环境再试!")
			end
		end, IS_SHOW_WAITING)
	end)
end

function BindingShiMingLayer:update( ft )
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

Helper:classDefNodeGetInstance(BindingShiMingLayer)

return BindingShiMingLayer
00000