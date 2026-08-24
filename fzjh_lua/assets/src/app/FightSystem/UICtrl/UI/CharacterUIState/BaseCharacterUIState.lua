local abstract = require("third.class.abstract")

local ICharacterUIState = require("app.FightSystem.UICtrl.UI.CharacterUIState.ICharacterUIState")

--@SuperType [src.app.FightSystem.UICtrl.UI.CharacterUIState.BaseCharacterUIState#ICharacterUIState]
local BaseCharacterUIState = {
    __stateType = 0,
    __animName = ""
}

function BaseCharacterUIState:create()
    return self.new()
end

function BaseCharacterUIState:setCharacterUICtrl(ctrl)
    --@RefType [src.app.FightSystem.UICtrl.CharacterUICtrl#CharacterUICtrl]
    self.__ctrl = ctrl
end

--@author:Seven
--@time:2021-06-01 16:42:44
--@return [src.app.FightSystem.UICtrl.CharacterUICtrl#CharacterUICtrl]
function BaseCharacterUIState:getCharacterUICtrl()
    return self.__ctrl
end

function BaseCharacterUIState:setAnimName(animName)
    self.__animName = animName
end


return abstract("BaseCharacterUIState", ICharacterUIState, BaseCharacterUIState)
00000000000000