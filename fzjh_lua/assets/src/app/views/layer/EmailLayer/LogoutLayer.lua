local User = require("app.models.user.User")

local ControllLayer = require("app.views.layer.ControllLayer")

--转移设备
local LogoutLayer = class("LogoutLayer", LayerEx)

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 弹出退出登录
function LogoutLayer.pop()
	PopupLayerController:showLayer("LogoutLayer", function(layer)
		layer:show()
	end)
end

function LogoutLayer:create()
	local p = LogoutLayer:new()
	p:init()
	return p
end

function LogoutLayer:init()
	local UI = require("Layer/LogoutUI.lua").create()["root"]
	UI:addTo(self)

	Helper:convertUIByParent(self)
	self.editBoxMail = nil			--邮件输入框
	self.editBoxCodes = nil			--验证码输入框

	self.editBoxMailStr = ""
	self.editBoxCodesStr = ""

	self.isSend = false				--邮件已发送 下次发送60秒间隔
	self.sendTime = 0 				--发送时间
	self.sendInterval = 0 			--发送间隔

	self.openUIType = 1 			--从哪个界面打开的，1 设置界面 2开始界面

	self._isMailEditing = false			--是否正在编辑邮箱
	self._isCodeEditing = false			--是否正在编辑验证码

	self:schedule(
		function(ft)
			self:update(ft)
		end, 1)
end

function LogoutLayer:show(openUIType)
	self._isMailEditing = false
	self._isCodeEditing = false
	if openUIType ~= nil then
		self.openUIType = openUIType
	else
		self.openUIType = 1
	end
	self:setBack()
	self:setVisible(true)
	self:setEditBox()
	self:setButtonCodes()
	self:setButtonTransfer()
end

function LogoutLayer:hide()
	PopupLayerController:hideLayer("LogoutLayer", function(layer)
		self:setVisible(false)
	end)
end

function LogoutLayer:setBack()
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

function LogoutLayer:setEditBox()
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

function LogoutLayer:setButtonCodes()
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

		--判断邮件是否发送成功
		Account:sendEmail("登出", self.editBoxMailStr,
		function(eventName, expired_time, errmsg)
			if eventName == "发送成功" then
				PopText("发送成功")
				self.sendTime = GetLocalTime()
				self.isSend = true
			elseif eventName == "发送失败" then
				PopText(errmsg)
			else
				error()
			end
		end)

	end)
end

function LogoutLayer:setButtonTransfer()
	--确认绑定
	self.Button_Bind:releaseFunc(function()
		if self._isMailEditing == true or self._isCodeEditing == true then
			return
		end

		if self.editBoxMailStr== "" or self.editBoxCodesStr == "" then
			PopText("请填写正确邮箱地址和验证码")
			return
		end

		--判断验证码是否正确
		Account:logoutDevice(self.editBoxMailStr, tonumber(self.editBoxCodesStr),
		function(eventName, errmsg)
			if eventName == "登出成功" then
				-- 友盟统计 登出
				Mob.profileSignOff()
				
				self.sendTime = 0
				User:reset()
				Game:restart(
				function()
					cc.Director:getInstance():getRunningScene():delayFunc(0.5, function()
							PopText("登出成功")
						end)
				end)
			elseif eventName == "登出失败" then
				PopText(errmsg)
			end
		end)

	end)
end

function LogoutLayer:update( ft )
	if self.isSend == true then
		self.sendInterval = math.floor(60 - ( GetLocalTime() - self.sendTime ) )

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

function LogoutLayer:downloadUserData()
	HttpManagerEx:downloadUserData(
		function(status, errcode, errmsg, data)
	   		-- 网络请求成功
	   		if status == 200 then
	   			-- 判断服务器返回数据
   				-- 判断返回值状态
   				if errcode == 0 then
   					-- 判断返回数据是否正确
   					if type(data) == "table" and type(data[1]) == "table" then
   						DataBase:setRoleData(Role:trimRoleData(data[1]))
   						User:init()

   						-- 设置为无需重置
   						self:hide()
   						PopText("转移成功")
   						self:transferSuccess()
   					else
   						local CreateRoleLayer = require("app.views.layer.CreateRoleLayer")
   						local createRoleLayer = CreateRoleLayer:getInstance()
   						createRoleLayer:show()
   						-- PopText("重启游戏, 或者联系客服")
   					end
   					return true
   				else
   					-- print("下载存档失败")
   					-- PopText("下载存档失败, 请联系客服")
   				end
			else
	    		PopText("网络请求出错,请换个网络环境再试!")
	   		end
	end, IS_SHOW_WAITING, HTTP_MANAGER_RETRY_TYPE_RETRY)
end
--转移设备成功后的操作
function LogoutLayer:transferSuccess()
	if self.openUIType == 2 then
		local MenuLayer = ControllLayer:getInstance():getLayer("MenuLayer")
		MenuLayer:StartGame()
	elseif self.openUIType == 1 then
		local SetupLayer = ControllLayer:getInstance():getLayer("SetupLayer")
		SetupLayer:setTextBindMail()
	end
end

Helper:classDefNodeGetInstance(LogoutLayer)

return LogoutLayer
00000000000000