local BindingTestMailLayer = class("BindingTestMailLayer", LayerEx)

local ControllLayer = require("app.views.layer.ControllLayer")

function BindingTestMailLayer:create()
	local p = BindingTestMailLayer:new()
	p:init()
	return p
end

function BindingTestMailLayer:init()
	local UI = require("Layer/BindingTestMailUI.lua").create()["root"]
	UI:addTo(self)

	self.__isMailEditing = false			--是否正在编辑邮箱
	self.__editBoxMailStr = ""

	Helper:convertUIByParent(self)
	self:initUI()
end

function BindingTestMailLayer:initUI()
	self:__initEditBox()
	self.Button_2:releaseFunc(function()
		PopText("需要验证邮箱后才能进行游戏")
	end)

	self.Button_1:releaseFunc(function()
		if self.__isMailEditing or self.__editBoxMailStr == "" then
			PopText("输入的邮箱错误，无法进入游戏")
			return
		end

		self:__bindingMail()
	end)
end

function BindingTestMailLayer:__initEditBox()
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
				self.__isMailEditing = true
			elseif eventName == "changed" then
				if not device.platform == "android" then 
					self.__isMailEditing = true
				end
				self.__editBoxMailStr = self.editBoxMail:getText()
			elseif eventName == "return" then
				self.__isMailEditing = false
			end
		end)
	end
	self.editBoxMail:setText("")
end

function BindingTestMailLayer:__bindingMail()
	HttpManagerEx:checkEmailWhite(self.__editBoxMailStr,function(status, errcode, errmsg, data)
        if status == 200 and errcode == 0 then
			local DebugConfig = require("app.views.layer.DebugLayer.DebugConfig")
			DebugConfig:setRoleType(data.auth)
			self:hide()
        else
            PopText(errmsg)
        end
    end,IS_SHOW_WAITING)
end

function BindingTestMailLayer:hide()
	PopupLayerController:hideLayer("BindingTestMailLayer", function(layer)
		self:setVisible(false)
	end)
end


Helper:classDefNodeGetInstance(BindingTestMailLayer)

return BindingTestMailLayer
00000