local BaseUI = require("app.FightSystem.UICtrl.UI.BaseUI")
local NewClass = require("third.class.NewClass")
--@SuperType [src.app.FightSystem.UICtrl.UI.BaseUI#BaseUI]
local CharacterControllerBtnUI = {
    __isEnable = true
}

function CharacterControllerBtnUI:onInit()
    self:setClickEnable(self.__isEnable)
    -- 默认开启进度条动画效果
    self.CDBar:setAnimEnable(true)
end

function CharacterControllerBtnUI:onDestroy()
end

function CharacterControllerBtnUI:onUpdate(ft)
end

function CharacterControllerBtnUI:setPosition(x, y)
    self.__node:setPosition(cc.p(x, y))
end

function CharacterControllerBtnUI:setName(name)
    self.Text_name:setString(name)
end

function CharacterControllerBtnUI:setBtnProgress(value)
    self.CDBar:setPercent(value)
end

function CharacterControllerBtnUI:btnLoadTextureNormal(path)
    if path == nil then
        path = "Image/UI/MapUI/anniu04.png"
    end
    self.Button_back:loadTextureNormal(path, 0)
end

function CharacterControllerBtnUI:setClickEnable(bool)
    if type(bool) ~= "boolean" then
        assert(false, "CharacterControllerBtnUI:setClickEnble : The parameter type must be bool")
    end

    if bool then
        self.CDBar:getVirtualRenderer():getSprite():setGLProgram(Resource:getSpriteNormalShder())
    else
        self.CDBar:getVirtualRenderer():getSprite():setGLProgram(Resource:getSpriteGrayShder())
    end

    self.__isEnable = bool
end

function CharacterControllerBtnUI:isEnable()
    return self.__isEnable
end

function CharacterControllerBtnUI:setClickFunc(click_func)
    self.__node:releaseFunc(
        function()
            click_func()
        end
    )
end

function CharacterControllerBtnUI:setVisible(bool)
    self.__node:setVisible(bool)
end

function CharacterControllerBtnUI:registerClickFunc(beganFunc, releaseFunc, canceledFunc)
    local beganFunc = Helper:getDef(beganFunc, EMPTY_FUNC)
    local releaseFunc = Helper:getDef(releaseFunc, EMPTY_FUNC)
    local canceledFunc = Helper:getDef(canceledFunc, EMPTY_FUNC)

    self.__node:releaseFuncTotally(
        function()
            beganFunc()
        end,
        function()
            releaseFunc()
        end,
        function()
            canceledFunc()
        end
    )
end

return NewClass("CharacterControllerBtnUI", {BaseUI}, CharacterControllerBtnUI)
00000000