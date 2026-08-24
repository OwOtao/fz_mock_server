local BindingIdcardLayer = class("BindingIdcardLayer", LayerEx)

local ControllLayer = require("app.views.layer.ControllLayer")


function BindingIdcardLayer:create()
	local p = BindingIdcardLayer:new()
	p:init()
	return p
end

function BindingIdcardLayer:ctor()
	self._fm = FunctionManager:create()
end

function BindingIdcardLayer:init()
	local UI = require("Layer/BindingShiMingInfoUI.lua").create()["root"]
	UI:addTo(self)

	Helper:convertUIByParent(self)
    self.editName = nil
    self.editIdCard = nil
    self.editPhone = nil

    self.editNameStr = ""
	self.editIdCardStr = ""
    self.editIdPhoneStr = ""
    self.editBoxCodesStr = ""

	self.isSend = false				--邮件已发送 下次发送60秒间隔
	self.sendTime = 0
	self.sendInterval = 0

    self._isNameEditing = false
	self._istIdCardEditing = false
    self._isPhoneEditing = false
    self._isCodeEditing = false

	self:schedule(
	function(ft)
		self:update(ft)
	end, 1)
end

function BindingIdcardLayer:show()
    self._isNameEditing = false
    self._istIdCardEditing = false
    self._isPhoneEditing = false
    self._isCodeEditing = false
    
	self:setVisible(true)
    self:setEditBox()
    self:setText()
    self:setButtonCodes()
    self:setButtonExit()
	self:setButtonBind()
end

function BindingIdcardLayer:hide()
	PopupLayerController:hideLayer("BindingIdcardLayer", function(layer)
		self:setVisible(false)
	end)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 增加回调
function BindingIdcardLayer:addCallback(func)
	self._fm:addFunction(func)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 调用回调
function BindingIdcardLayer:callCallbacks(eventName)
	self._fm:callFunctions(eventName)
end

function BindingIdcardLayer:setText()
    local text = "按照文化部《网络游戏管理暂行版本》的相关需求，网络游戏用户需要使用有效身份认证进行实名注册才能登陆游戏，未实名注册的玩家将无法登陆游戏，认证信息只能提交一次，请慎重填写，完成认证可前往商城免费领取一份礼盒。您的身份信息仅用于实名认证，我们不会将此信息泄露于任何第三方。"
    self.Text_desc2:setString(text)
end

function BindingIdcardLayer:setEditBox()
    self.editNameStr = ""
    self.editIdCardStr = ""
    self.editIdPhoneStr = ""
    self.editBoxCodesStr = ""

    --姓名输入框
	if self.editName == nil then
		local size = self.EditBoxName:getContentSize()
		self.editName = ccui.EditBox:create(size, "请输入")

		self.editName:setInputMode(1)
		self.editName:setInputFlag(3)
		self.editName:setReturnType(1)
		self.editName:setFontSize(62)
		self.editName:setPlaceholderFontSize(62)
		self.editName:setPlaceholderFontName("Font/default.ttf")

		self.EditBoxName:getParent():addChild(self.editName)
		self.editName:setPosition(self.EditBoxName:getPositionX(), self.EditBoxName:getPositionY())

		self.editName:onEditHandler(function(event)
			local eventName = event.name
			local eventTarget = event.target

			if eventName == "began" then
				self._isNameEditing = true
			elseif eventName == "changed" then
				if not device.platform == "android" then 
					self._isNameEditing = true
				end
				self.editNameStr = self.editName:getText()
			elseif eventName == "return" then
				self._isNameEditing = false
			end
		end)
    end
    self.editName:setText("")

	--身份证输入框
	if self.editIdCard == nil then
		local size = self.EditBoxIdCard:getContentSize()
		self.editIdCard = ccui.EditBox:create(size, "请输入")

		self.editIdCard:setInputMode(1)
		self.editIdCard:setInputFlag(3)
		self.editIdCard:setReturnType(1)
		self.editIdCard:setFontSize(62)
		self.editIdCard:setPlaceholderFontSize(62)
		self.editIdCard:setPlaceholderFontName("Font/default.ttf")

		self.EditBoxIdCard:getParent():addChild(self.editIdCard)
		self.editIdCard:setPosition(self.EditBoxIdCard:getPositionX(), self.EditBoxIdCard:getPositionY())

		self.editIdCard:onEditHandler(function(event)
			local eventName = event.name
			local eventTarget = event.target

			if eventName == "began" then
				self._istIdCardEditing = true
			elseif eventName == "changed" then
				if not device.platform == "android" then 
					self._istIdCardEditing = true
				end
				self.editIdCardStr = self.editIdCard:getText()
			elseif eventName == "return" then
				self._istIdCardEditing = false
			end
		end)
	end
	self.editIdCard:setText("")

	--手机号输入框
	if self.editPhone == nil then
		local size = self.EditBoxPhone:getContentSize()
		self.editPhone = ccui.EditBox:create(size, "请输入")

		self.editPhone:setInputMode(1)
		self.editPhone:setInputFlag(3)
		self.editPhone:setReturnType(1)
		self.editPhone:setFontSize(62)
		self.editPhone:setPlaceholderFontSize(62)
		self.editPhone:setPlaceholderFontName("Font/default.ttf")

		self.EditBoxPhone:getParent():addChild(self.editPhone)
		self.editPhone:setPosition(self.EditBoxPhone:getPositionX(), self.EditBoxPhone:getPositionY())
		-- self.editBoxCodes:setMaxLength(6)

		self.editPhone:onEditHandler(function(event)
			local eventName = event.name
			local eventTarget = event.target

			if eventName == "began" then
				self._isPhoneEditing = true
			elseif eventName == "changed" then
				if not device.platform == "android" then 
					self._isPhoneEditing = true
				end
				self.editIdPhoneStr = self.editPhone:getText()
			elseif eventName == "return" then
				self._isPhoneEditing = false
			end
		end)
	end
    self.editPhone:setText("")
    
    --验证码输入框
	if self.editBoxCodes == nil then
		local size = self.EditBoxCodes:getContentSize()
		self.editBoxCodes = ccui.EditBox:create(size, "请输入")

		self.editBoxCodes:setInputMode(1)
		self.editBoxCodes:setInputFlag(3)
		self.editBoxCodes:setReturnType(1)
		self.editBoxCodes:setFontSize(62)
		self.editBoxCodes:setPlaceholderFontSize(62)
		self.editBoxCodes:setPlaceholderFontName("Font/default.ttf")

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

function BindingIdcardLayer:setButtonExit()
    self.Button_exit:releaseFunc(function()
        cc.Director:getInstance():endToLua()
    end)
end

function BindingIdcardLayer:setButtonCodes()
	--获取验证码
	self.Button_Send:releaseFunc(function()
		if self._isNameEditing == true or self._istIdCardEditing == true or self._isPhoneEditing == true or self._isCodeEditing == true then
			return
        end
        
        if self.editNameStr == "" then
			PopText("请填写正确的姓名")
			return
        end

        if self.editIdCardStr == "" then
            PopText("请填写正确的身份证号码")
            return
        end

        if self.editIdPhoneStr == "" then
            PopText("请填写正确的手机号码")
            return
        end

		--正在发送中
		if self.isSend == true then
			PopText("你发送太频繁了")
			return
		end
        local function callback1(eventName, expired_time, errmsg)
            print("eventName = ",eventName,"errmsg = ",errmsg)
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

		HttpManagerEx:sendPhoneVerifyCode(tonumber(self.editIdPhoneStr),
        function(status, errcode, errmsg, data)
            print("status = ",status,"errcode = ",errcode)
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

function BindingIdcardLayer:setButtonBind()
	--确认绑定
	self.Button_Bind:releaseFunc(function()
		if self._isNameEditing == true or self._istIdCardEditing == true or self._isPhoneEditing == true or self._isCodeEditing == true then
			return
		end

		if self.editNameStr == "" then
			PopText("请填写正确的姓名")
			return
        end

        if self.editIdCardStr == "" then
            PopText("请填写正确的身份证号码")
            return
        end

        if self.editIdPhoneStr == "" then
            PopText("请填写正确的手机号码")
            return
        end

        if self.editBoxCodesStr == "" then
            PopText("请填写正确的验证码")
            return
        end
        
        HttpManagerEx:bindShiMingInfo(self.editNameStr,self.editIdCardStr,tonumber(self.editIdPhoneStr),tonumber(self.editBoxCodesStr),
        function(status, errcode, errmsg, data)
			if status == 200 then
				if 0 == errcode then
                    self.sendTime = 0
                    if not MapIsEmpty(data) then
                        local isadult = data.isadult
                        self:callCallbacks(isadult)
                    end
                    self:hide()
                    PopText("实名认证成功")
				else
					PopText(tostring(errmsg))
				end
			else
	    		PopText("网络请求出错,请换个网络环境再试!")
			end
		end, IS_SHOW_WAITING)
	end)
end

function BindingIdcardLayer:update( ft )
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

Helper:classDefNodeGetInstance(BindingIdcardLayer)

return BindingIdcardLayer
00000