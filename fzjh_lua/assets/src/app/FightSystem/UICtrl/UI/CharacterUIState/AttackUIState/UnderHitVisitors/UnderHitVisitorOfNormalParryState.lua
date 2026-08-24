local newClass = require("third.class.NewClass")

local UnderHitVisitorOfHitState = require("app.FightSystem.UICtrl.UI.CharacterUIState.AttackUIState.UnderHitVisitors.UnderHitVisitorOfHitState")

local BuffConf = require("app.FightSystem.Configuration.BuffConf")

local PopTextVm = require("app.FightSystem.UICtrl.UIModel.PopTextVm")

local UnderHitVisitorOfNormalParryState = {
    __qiDamagePopTextPrefix = "招架",
    __targetPopTextList = {},
    __attackerPopTextList = {}
}

function UnderHitVisitorOfNormalParryState:create()
    return UnderHitVisitorOfNormalParryState.new()
end


function UnderHitVisitorOfNormalParryState:getTargetPopTextList()
    return self.__targetPopTextList
end

function UnderHitVisitorOfNormalParryState:getAttackerPopTextList()
    return self.__attackerPopTextList
end

return newClass("UnderHitVisitorOfNormalParryState", {UnderHitVisitorOfHitState}, UnderHitVisitorOfNormalParryState)
00000