--[[
    玩家装备类型判断
]]
local newClass = require("third.class.NewClass")

local IActiveUseCondition = require("app.FightSystem.FightSkill.ActiveSkillUseCondition.IActiveUseCondition")

local WeaponTypesResManager = require("app.FightSystem.FightRole.CharacterEquipment.WeaponTypesResManager")

local UseWeaponCondition = {}

function UseWeaponCondition:create(name, placeholder, logicalSymbol)
    local p = self.new()
    p:init(name, placeholder, logicalSymbol)
    return p
end

function UseWeaponCondition:init(firstWeaponType, placeholder, logicalSymbol)
    self.__firstWeaponType = firstWeaponType

    self.__logicalSymbol = logicalSymbol

    if self.__firstWeaponType == nil then
        error("主动技能使用条件判断 - 武器装备判断：条件判断值不可为空")
    end
end

function UseWeaponCondition:getConditionType()
    return "4"
end

--@desc: 获取角色技能信息
--@author:Seven
--@time:2021-07-16 12:16:55
--@f_character: [src.app.FightSystem.FightRole.FightCharacter#FightCharacter]
function UseWeaponCondition:matchCondititon(f_character)
    local weapon = f_character:getWeapon()

    local isMatch =
        switch(
        self.__logicalSymbol,
        {
            ["是"] = function()
                return weapon:getFirstType() == self.__firstWeaponType
            end,
            ["否"] = function()
                return weapon:getFirstType() ~= self.__firstWeaponType
            end,
            ["default"] = function()
                error("主动技能使用条件判断 - 武器装备判断：判断类型填写错误，是可填写“是”或“否”")
            end
        }
    )

    local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

    FightUtil:printLog("角色武器装备条件判断：【结果】", tostring(isMatch))

    return isMatch
end

function UseWeaponCondition:getConditionText()
    --@desc 武器文本暂时不显示
    return ""
end

return newClass("UseWeaponCondition", {IActiveUseCondition}, UseWeaponCondition)
00000