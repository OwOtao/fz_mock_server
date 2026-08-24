--[[
    author:Seven
    time:2026-01-07 17:36:30
    desc: 存放角色初始化时，自身携带的buff
]]
local newClass = require("third.class.NewClass")
local ACarryBuffAddToCharacter = require("app.FightSystem.FightRole.CharacterBuff.Utils.ACarryBuffAddToCharacter")

--@SuperType [src.app.FightSystem.FightRole.CharacterBuff.Utils.ACarryBuffAddToCharacter#ACarryBuffAddToCharacter]
local CharacterCarryBuffWhenInit = {}

function CharacterCarryBuffWhenInit:create(...)
    return CharacterCarryBuffWhenInit.new():__init(...)
end

function CharacterCarryBuffWhenInit:__init(character, buffArray)
    self:setCharacter(character)
    self.__buffArray = buffArray or {}
    return self
end

function CharacterCarryBuffWhenInit:getCarryBuffArray()
    if MapIsEmpty(self.__buffArray) then
        return {}
    end

    local list = {}
    for _, normalRes in ipairs(self.__buffArray) do
        --@RefType [src.app.FightSystem.FightRole.CharacterBuff.Buffs.Builder.BasicCharacterBuffBuilder#BasicCharacterBuffBuilder]
        local buffBuilder = require("app.FightSystem.FightRole.CharacterBuff.Buffs.Builder.BasicCharacterBuffBuilder"):create()

        local origin_value_4 = normalRes.addBuffdynamicArg4

        local arg4
        if origin_value_4 == nil then
            arg4 = 0
        else
            if tonumber(origin_value_4) == nil then
                arg4 = origin_value_4
            else
                arg4 = tonumber(origin_value_4)
            end
        end
        local buff =
            buffBuilder:setBuffId(normalRes.addBuffID):setCharacter(self.__character):setBuffCreator(self.__character):setFight(self.__character:getFight()):setBuffDynamicArgValue(
            "dynamicArg1",
            normalRes.addBuffdynamicArg1
        ):setBuffDynamicArgValue("dynamicArg2", normalRes.addBuffdynamicArg2):setBuffDynamicArgValue("dynamicArg3", normalRes.addBuffdynamicArg3):setBuffDynamicArgValue("dynamicArg4", arg4):build()

        table.insert(list, buff)
    end

    return list
end

function CharacterCarryBuffWhenInit:getCarryBuffAdderGroupArray()
    return {}
end

return newClass("CharacterCarryBuffWhenInit", {ACarryBuffAddToCharacter}, CharacterCarryBuffWhenInit)
00000