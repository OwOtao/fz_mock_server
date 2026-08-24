local IBtnCtrl = {}

function IBtnCtrl:beganFunc()
end

function IBtnCtrl:releaseFunc()
end

function IBtnCtrl:canceledFunc()
end

function IBtnCtrl:update(ft)
end

local abstract = require("third.class.abstract")

local ABtnCtrl = {}

function ABtnCtrl:setFightUICtrl(ctrl)
    --@RefType [Fight2Layer]
    self.__fightUICtrl = ctrl
end

function ABtnCtrl:setBtnUI(btnUI)
    --@RefType [src.app.FightSystem.UICtrl.UI.CharacterControllerBtnUI#CharacterControllerBtnUI]
    self.__ui = btnUI

    self.__ui:registerClickFunc(
        function()
            self:beganFunc()
        end,
        function()
            self:releaseFunc()
        end,
        function()
            self:canceledFunc()
        end
    )
end

function ABtnCtrl:getUI()
    return self.__ui
end

function ABtnCtrl:getType()
    return self.__type
end

function ABtnCtrl:setId(id)
    self.__id = id
end

function ABtnCtrl:getId()
    return self.__id
end

function ABtnCtrl:setVisible(bool)
    self.__ui:setVisible(bool)
end

function ABtnCtrl:setPosition(x, y)
    self.__ui:setPosition(x, y)
end

function ABtnCtrl:setBtnName(name)
    self.__ui:setName(name)
end

function ABtnCtrl:setEnable(bool)
    self.__ui:setClickEnable(bool)
end

function ABtnCtrl:setProgress(value, maxValue)
    self.__ui:setBtnProgress((value / maxValue) * 100)
end

function ABtnCtrl:btnLoadTextureNormal(path)
    self.__ui:btnLoadTextureNormal(path)
end

return abstract(ABtnCtrl, IBtnCtrl, ABtnCtrl)
00000