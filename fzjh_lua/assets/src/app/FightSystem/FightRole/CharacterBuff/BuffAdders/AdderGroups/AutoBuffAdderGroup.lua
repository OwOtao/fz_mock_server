--[[
    author:Seven
    time:2023-03-07 20:28:10
    desc: 主动技能添加器组实现类
]]
local newClass = require("third.class.NewClass")

local BuffConf = require("app.FightSystem.Configuration.BuffConf")

local AFightCharacterBuffAdderGroup = require("app.FightSystem.FightRole.CharacterBuff.BuffAdders.AFightCharacterBuffAdderGroup")

local FightCommons = require("app.FightSystem.FightCommons")

--@RefType [Constants]
local BUFF_CONSTANTS = require("app.FightSystem.FightBuff.Constants")
local ADDER_TRIGGER_TYPE = BUFF_CONSTANTS.ADDER_TRIGGER_TYPE

--@SuperType [src.app.FightSystem.FightRole.CharacterBuff.BuffAdders.AFightCharacterBuffAdderGroup#AFightCharacterBuffAdderGroup]
local AutoBuffAdderGroup = {}

function AutoBuffAdderGroup:create()
    return AutoBuffAdderGroup.new()
end

function AutoBuffAdderGroup:__initBuffAdder(buffLauncherId)
    local adderClasses = BuffConf:getAutoBuffAdderGroupResClass(buffLauncherId)

    for _, adderResClass in ipairs(adderClasses) do
        --@RefType [src.app.FightSystem.FightRole.CharacterBuff.BuffAdders.BasicFightCharacterBuffAdder#BasicFightCharacterBuffAdder]
        local adder = require("app.FightSystem.FightRole.CharacterBuff.BuffAdders.BasicFightCharacterBuffAdder"):create(adderResClass)

        adder:setFight(self.__fight)

        adder:setCharacter(self.__character)

        table.insert(self.__adders, adder)
    end
end

return newClass("AutoBuffAdderGroup", {AFightCharacterBuffAdderGroup}, AutoBuffAdderGroup)
000000000000000