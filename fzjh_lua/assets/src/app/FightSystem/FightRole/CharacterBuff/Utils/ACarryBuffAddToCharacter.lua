--[[
    author:Seven
    time:2024-01-15 20:35:06
    desc:
]]
local abstract = require("third.class.abstract")

local isImplement = require("third.assertIsInstance.assertIsInstance")

local ICarryBuffProducer = require("app.FightSystem.FightRole.CharacterBuff.Utils.ICarryBuffProducer")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

--@SuperType [src.app.FightSystem.FightRole.CharacterBuff.Utils.ICarryBuffProducer#ICarryBuffProducer]
local ACarryBuffAddToCharacter = {
    __carryBuffIndexArray = {},
    __carryBuffAdderGroupIndexArray = {}
}

function ACarryBuffAddToCharacter:setCharacter(character)
    --@RefType [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
    self.__character = character
end

function ACarryBuffAddToCharacter:addCarryBuffToCharacter()
    local buffArray = self:getCarryBuffArray()
    if MapIsEmpty(buffArray) then
        return
    end

    if self.__carryBuffIndexArray == nil then
        self.__carryBuffIndexArray = {}
    end

    local AddBuffUtil = require("app.FightSystem.FightRole.CharacterBuff.Utils.AddBuffUtil")
    for _, buff in ipairs(buffArray) do
        -- --@RefType [src.app.FightSystem.FightRole.CharacterBuff.Buffs.BasicFightCharacterBuff#BasicFightCharacterBuff]
        -- buff = buff
        local result = AddBuffUtil:addBuff(self.__character, buff)

        if result.needAdd == true then
            FightUtil:printFormatLog("%s 添加自带buff【%s】, 系统自动生成索引【%s】", self.__character:getAttr("name"), tostring(buff:getBuffId()), tostring(result.index))
            table.insert(self.__carryBuffIndexArray, result.index)
        end
    end
end

function ACarryBuffAddToCharacter:removeCarryBuffFromCharacter()
    if MapIsEmpty(self.__carryBuffIndexArray) then
        return
    end

    for _, index in ipairs(self.__carryBuffIndexArray) do
        FightUtil:printFormatLog("%s 添加自带buff - 索引【%s】", self.__character:getAttr("name"), tostring(index))
        self.__character:removeCharacterBuff(index)
    end

    self.__carryBuffIndexArray = {}
end

function ACarryBuffAddToCharacter:addCarryBuffAdderToCharacter()
    local adderGroupArray = self:getCarryBuffAdderGroupArray()
    if MapIsEmpty(adderGroupArray) then
        return
    end

    if self.__carryBuffAdderGroupIndexArray == nil then
        self.__carryBuffAdderGroupIndexArray = {}
    end

    for _, adderGroup in ipairs(adderGroupArray) do
        --@RefType [src.app.FightSystem.FightRole.CharacterBuff.BuffAdders.AFightCharacterBuffAdderGroup#AFightCharacterBuffAdderGroup]
        adderGroup = adderGroup
        table.insert(self.__carryBuffAdderGroupIndexArray, self.__character:addBuffAdderGroup(adderGroup))
        FightUtil:printFormatLog("%s 添加自带buff添加器【%s】, 系统索引【%s】", self.__character:getAttr("name"), tostring(adderGroup:getBuffLauncherId()), tostring(adderGroup:getId()))
    end
end

function ACarryBuffAddToCharacter:removeCarryBuffAdderFromCharacter()
    if MapIsEmpty(self.__carryBuffAdderGroupIndexArray) then
        return
    end

    for _, index in ipairs(self.__carryBuffAdderGroupIndexArray) do
        self.__character:removeBuffAdderGroup(index)
        FightUtil:printFormatLog("%s 移除自带buff添加器 - 索引【%s】", self.__character:getAttr("name"), tostring(index))
    end

    self.__carryBuffAdderGroupIndexArray = {}
end

return abstract("ACarryBuffAddToCharacter", {ICarryBuffProducer}, ACarryBuffAddToCharacter)
0000