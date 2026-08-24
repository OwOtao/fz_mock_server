local SwitchServerEmailLayer = class("SwitchServerEmailLayer", LayerEx)

function SwitchServerEmailLayer:create()
    local p = SwitchServerEmailLayer.new()
    p:init()
    return p
end

function SwitchServerEmailLayer:init()
    self._hasBeenSent = false
    self.sendTime = 0
    
    self._getCodeFunc = function() end
    self._confirmFunc = function() end
    
    self.UI = require("Layer/SwitchServerUI/SwitchServerEmailUI.lua").create()['root']
    self:addChild(self.UI)
    Helper:convertUIByParent(self)
    
    self:initButton()
    self:initEditBox()
    
    
    self:schedule(
        function(ft)
            self:update(ft)
        end, 0.5)
end

function SwitchServerEmailLayer:initButton()
    self.Panel_back:releaseFunc(function()
        self:hide()
    end)
    
    self.Button_Send:releaseFunc(
        function()
            if self._hasBeenSent then
                PopText("已经发送, 请稍后再试...")
            else
                self._getCodeFunc()
                self._hasBeenSent = true
                self.sendTime = GetTime()
            end
        end)
    
    self.Button_Bind:releaseFunc(
        function()
            self._confirmFunc()
        end)


-- --　继承老号
-- self.Image_item1:releaseFunc(function()
-- end)
-- -- 玩新号
-- self.Image_item2:releaseFunc(function()
-- end)
end

function SwitchServerEmailLayer:initEditBox()
    if self.editBoxMail == nil then
        self._isMailEditing = false
        self.editBoxMailStr = ""
        
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
        self.editBoxMail:setText("")
    end
    
    --验证码输入框
    if self.editBoxCodes == nil then
        self._isCodeEditing = false
        self.editBoxCodesStr = ""
        
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
        
        self.editBoxCodes:setText("")
    end
end

function SwitchServerEmailLayer:setGetCodeFunc(func)
    self._getCodeFunc = Helper:getDef(func, function() end)
end

function SwitchServerEmailLayer:setConfirmFunc(func)
    self._confirmFunc = Helper:getDef(func, function() end)
end

function SwitchServerEmailLayer:setEditEmail(email)
    -- PopText("email: " .. email)
    if self.editBoxMail then
        self.editBoxMailStr = Helper:getDef(email, "")
        self.editBoxMail:setText(self.editBoxMailStr)
    end
end

function SwitchServerEmailLayer:getEditEmail()
    return self.editBoxMailStr
end

function SwitchServerEmailLayer:getEditCode()
    return self.editBoxCodesStr
end

function SwitchServerEmailLayer:update(ft)
    if self._hasBeenSent == true then
        self.sendInterval = math.floor(60 - (GetTime() - self.sendTime))
        
        --60秒后才可再次发送验证码
        if self.sendInterval <= 0 then
            self._hasBeenSent = false
            self.Button_Send.Text_SendName:setString("获取验证码")
            self.Button_Send:setTouchEnabled(true)
        else
            self.Button_Send.Text_SendName:setString(tostring(self.sendInterval) .. "秒后重新获取")
            self.Button_Send:setTouchEnabled(false)
        end
    end
end

Helper:classDefNodeGetInstance(SwitchServerEmailLayer)
return SwitchServerEmailLayer
0000000