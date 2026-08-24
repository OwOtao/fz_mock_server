local newClass = require("third.class.NewClass")

local IActiveSkillReleaseCondition = require("app.FightSystem.FightSkill.ActiveSkillRelaseCondition.IActiveSkillReleaseCondition")

local FightFormula = require("app.FightSystem.FightFormula")

local TextResManager = require("app.FightSystem.ResourceManager.TextResManager")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

--@SuperType [src.app.FightSystem.FightSkill.ActiveSkillRelaseCondition.IActiveSkillReleaseCondition#IActiveSkillReleaseCondition]
local SwitchWeaponFightStateCondition = {
    __type = 3
}

function SwitchWeaponFightStateCondition:create(placeholder, logicalSymbol, placeholder2, condValue, failureTextId)
    local p = SwitchWeaponFightStateCondition.new()
    p:__init(placeholder, logicalSymbol, placeholder2, condValue, failureTextId)
    return p
end

function SwitchWeaponFightStateCondition:__init(placeholder, logicalSymbol, placeholder2, condValue, failureTextId)
    self.__logicalSymbol = logicalSymbol

    self.__condValue = condValue

    self.__failureTextId = failureTextId
end

--@desc:
--@author:Seven
--@time:2022-05-11 15:04:54
--@f_character: [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
function SwitchWeaponFightStateCondition:canRelease(f_character)
    local targetWeapon = f_character:getSwitchTargetWeapon()

    local isMatch = false
    if self.__logicalSymbol == "等于" then
        if targetWeapon:getFightState() == self.__condValue then
            isMatch = true
        else
            isMatch = false
        end
    elseif self.__logicalSymbol == "不等于" then
        if targetWeapon:getFightState() ~= self.__condValue then
            isMatch = true
        else
            isMatch = false
        end
    end

    if not isMatch then
        --@RefType [src.app.FightSystem.FightUtil.FightDesc#FightDesc]
        local fightDesc = require("app.FightSystem.FightUtil.FightDesc"):create()
        fightDesc:setText(TextResManager:getText(self.__failureTextId))

        return false, fightDesc:getString()
    end

    return true
end

return newClass("SwitchWeaponFightStateCondition", {IActiveSkillReleaseCondition}, SwitchWeaponFightStateCondition)
00000000000000