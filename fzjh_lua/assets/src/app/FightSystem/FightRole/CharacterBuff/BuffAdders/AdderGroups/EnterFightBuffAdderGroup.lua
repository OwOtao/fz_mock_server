--[[
    author:Seven
    time:2023-03-07 20:28:10
    desc: 主动技能添加器组实现类
]]
local newClass = require("third.class.NewClass")

local BuffConf = require("app.FightSystem.Configuration.BuffConf")

local AFightCharacterBuffAdderGroup = require("app.FightSystem.FightRole.CharacterBuff.BuffAdders.AFightCharacterBuffAdderGroup")

--@RefType [Constants]
local BUFF_CONSTANTS = require("app.FightSystem.FightBuff.Constants")
local ADDER_TRIGGER_TYPE = BUFF_CONSTANTS.ADDER_TRIGGER_TYPE

--@SuperType [src.app.FightSystem.FightRole.CharacterBuff.BuffAdders.AFightCharacterBuffAdderGroup#AFightCharacterBuffAdderGroup]
local EnterFightBuffAdderGroup = {}

function EnterFightBuffAdderGroup:create()
    return EnterFightBuffAdderGroup.new()
end

function EnterFightBuffAdderGroup:__initBuffAdder(buffLauncherId)
    local adderClasses = BuffConf:getEnterBuffAdderGroupResClass(buffLauncherId)

    for _, adderResClass in ipairs(adderClasses) do
        --@RefType [src.app.FightSystem.FightRole.CharacterBuff.BuffAdders.BasicFightCharacterBuffAdder#BasicFightCharacterBuffAdder]
        local adder = require("app.FightSystem.FightRole.CharacterBuff.BuffAdders.BasicFightCharacterBuffAdder"):create(adderResClass)

        adder:setFight(self.__fight)

        adder:setCharacter(self.__character)

        table.insert(self.__adders, adder)
    end
end

return newClass("EnterFightBuffAdderGroup", {AFightCharacterBuffAdderGroup}, EnterFightBuffAdderGroup)
0000000000