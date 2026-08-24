--[[
    author:Seven
    time:2023-10-23 12:01:35
    desc: 玩家按钮控制视图UI
]]
local BaseViewUI = require("app.FightSystem.Veiws.ViewCommon.BaseViewUI")

local NewClass = require("third.class.NewClass")

local ViewUIClickRegister = require("app.FightSystem.Veiws.ViewCommon.ViewUIClickRegister")

--@SuperType [src.app.FightSystem.Veiws.ViewCommon.BaseViewUI#BaseViewUI]
local PlayerButtonViewUI = {}

function PlayerButtonViewUI:onInit()
    self.__isEnable = true
    self:setClickEnable(false)

    --@RefType [src.app.FightSystem.Veiws.ViewCommon.ViewUIClickRegister#ViewUIClickRegister]
    self.__viewUIClickRegister = ViewUIClickRegister:createWithReleaseFuncTotally(self.__node)
end

function PlayerButtonViewUI:onUpdate(ft)
    self.__viewUIClickRegister:update(ft)
end

function PlayerButtonViewUI:setBtnName(name)
    self.Text_name:setString(name)
end

function PlayerButtonViewUI:setPosition(x, y)
    self.__node:setPosition(x, y)
end

function PlayerButtonViewUI:getContentSize()
    return self.__node:getContentSize()
end

function PlayerButtonViewUI:setVisible(bool)
    self.__node:setVisible(bool)
end

function PlayerButtonViewUI:setBtnStatus(status)
    if type(status) ~= "number" then
        assert(false, "PlayerButtonViewUI:setBtnStatus : The parameter type must be number")
    end

    if status == 1 then
        self.CDBar:setVisible(false)
        self.Text_name:setVisible(false)
        self.Button_back:loadTextureNormal("Image/BaseUI/btn-fight-notPrepare.png", 0)
        self:setBtnProgress(0)
        self:setClickEnable(false)
        self.__node:setTouchEnabled(false)
        self:registerClickFunc(nil, nil, nil, nil)
    elseif status == 2 then
        self.CDBar:setVisible(true)
        self.Text_name:setVisible(true)
        self.Button_back:loadTextureNormal("Image/UI/MapUI/anniu04.png", 0)
        self:setClickEnable(true)
        self.__node:setTouchEnabled(true)
    end
end

function PlayerButtonViewUI:setClickEnable(bool)
    if type(bool) ~= "boolean" then
        assert(false, "PlayerButtonViewUI:setClickEnble : The parameter type must be bool")
    end

    if bool then
        self.CDBar:getVirtualRenderer():getSprite():setGLProgram(Resource:getSpriteNormalShder())
    else
        self.CDBar:getVirtualRenderer():getSprite():setGLProgram(Resource:getSpriteGrayShder())
    end
end

function PlayerButtonViewUI:setTouchEnable(bool)
    self.__node:setTouchEnabled(bool)
end

function PlayerButtonViewUI:setBtnProgressValue(valeu, maxValue)
    self:setBtnProgress(valeu / maxValue * 100)
end

function PlayerButtonViewUI:setBtnProgress(value)
    self.CDBar:setPercent(value)
end

function PlayerButtonViewUI:registerClickFunc(beganFunc, releaseFunc, canceledFunc, pressingUpdateFunc)
    self.__viewUIClickRegister:registerClickFunc(beganFunc, releaseFunc, canceledFunc, pressingUpdateFunc)
end

return NewClass("PlayerButtonViewUI", {BaseViewUI}, PlayerButtonViewUI)
0