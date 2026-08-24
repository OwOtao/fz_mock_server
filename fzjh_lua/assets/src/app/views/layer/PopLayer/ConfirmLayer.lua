local ConfirmLayer = class("ConfirmLayer", LayerEx)

function ConfirmLayer:create()
	local p = ConfirmLayer.new()
	return p
end

-- 创建confirmLayer到runningScene
function ConfirmLayer:createCustomInRunningScene(text, buttonName1, buttonFunc1, buttonName2, buttonFunc2)
	local confirmLayer = nil
	local runningScene = cc.Director:getInstance():getRunningScene()
    if runningScene then
        confirmLayer = ConfirmLayer:createCustom(text, buttonName1, buttonFunc1, buttonName2, buttonFunc2)
        -- 添加到当前scene
        runningScene:addChild(confirmLayer)
        -- 设置为置顶
        confirmLayer:setGlobalZOrder(1)
        confirmLayer:maxZ()
        -- 显示
        confirmLayer:show()
    end
    return confirmLayer
end

-- 创建自定义
function ConfirmLayer:createCustom(text, buttonName1, buttonFunc1, buttonName2, buttonFunc2)
	local p = ConfirmLayer:create()

	-- 设置文字显示
	p:setText(text)

	-- 设置按钮
	p:setButton1(buttonName1, buttonFunc1)
	p:setButton2(buttonName2, buttonFunc2)

    -- 初始化编辑框
    p:initEditBox()
	return p
end

function ConfirmLayer:ctor()
	self:init()
end

function ConfirmLayer:init()
	self._UI = require("Layer/PopUI/ConfirmUI").create()['root']
	self._UI:addTo(self)

	Helper:convertUI(self) -- 获得所有子节点
end

function ConfirmLayer:setText(text)
	self.Text_center:setText(text)
end

function ConfirmLayer:setButton1(name, func)
	if func == nil then
		self.Text_1:setVisible(false)
		self.Button_1:setVisible(false)
		return
	else
	end
	if name == nil then
		name = "重试"
	end
	self.Text_1:setString(name)
	self.Button_1:releaseFunc(
		function()
			func(self)
			self:hideAndRemoveSelf()
		end)
end

function ConfirmLayer:setButton2(name, func)
	if func == nil then
		self.Text_2:setVisible(false)
		self.Button_2:setVisible(false)
		return
	else
	end
	if name == nil then
		name = "重试"
	end
	self.Text_2:setString(name)
	self.Button_2:releaseFunc(
		function()
			func(self)
			self:hideAndRemoveSelf()
		end)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 设置编辑框
function ConfirmLayer:initEditBox()
    --邮箱输入框
	if self.editBox == nil then
		local size = self.Input:getContentSize()
		self.editBox = ccui.EditBox:create(size, "请输入")

		self.editBox:setInputMode(1)
		self.editBox:setInputFlag(3)
		self.editBox:setReturnType(1)
		self.editBox:setFontSize(62)
		self.editBox:setPlaceholderFontSize(62)
        self.editBox:setPlaceholderFontName("Font/default.ttf")

		self.Input:getParent():addChild(self.editBox)
		self.editBox:setPosition(self.Input:getPositionX(), self.Input:getPositionY())

		self.editBox:onEditHandler(function(event)
			local eventName = event.name
			local eventTarget = event.target

			if eventName == "began" then
                self:showTouchSwallowLayer()
			elseif eventName == "changed" then
				self.editBoxMailStr = self.editBox:getText()
			elseif eventName == "return" then
				self:hideTouchSwallowLayer()
			end
		end)
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 获得编辑框文本
function ConfirmLayer:getEditBoxString()
    local retString = ""
    if self.editBox then
        retString = self.editBox:getText()
    end
    return retString
end

function ConfirmLayer:show()
	self:setVisible(true)
end

function ConfirmLayer:hide()
	self:setVisible(false)
end

function ConfirmLayer:hideAndRemoveSelf()
	self:removeFromParent()
end

return ConfirmLayer
0000000000