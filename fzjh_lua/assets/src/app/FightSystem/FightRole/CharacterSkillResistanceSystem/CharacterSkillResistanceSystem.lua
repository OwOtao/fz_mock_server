--[[
    author:Seven
    time:2025-02-27 14:31:28
    desc: 武学攻击抗性系统
]]
local newClass = require("third.class.NewClass")
local ABasicCharacterFuncSystem = require("app.FightSystem.FightRole.BasicFuncSystem.ABasicCharacterFuncSystem")

local SkillDamageAttrConf = require("app.FightSystem.Configuration.SkillDamageAttrConf")

local __verifyId = function(id)
    return SkillDamageAttrConf:getSkillDamageAttrRes(id) ~= nil
end

--@SuperType [src.app.FightSystem.FightRole.BasicFuncSystem.ABasicCharacterFuncSystem#ABasicCharacterFuncSystem]
local CharacterSkillResistanceSystem = {}

function CharacterSkillResistanceSystem:create()
    return CharacterSkillResistanceSystem.new()
end

function CharacterSkillResistanceSystem:ctor()
    --@desc 存放角色攻击属性抗性
    self.__atkResistanceMap = {}

    --@desc 存放角色防御属性抗性
    self.__defResistanceMap = {}
end

function CharacterSkillResistanceSystem:getName()
    if self.__name == nil then
        assert(false, "角色系统未命名！！")
    end
    return self.__name
end

function CharacterSkillResistanceSystem:onInit()
end

function CharacterSkillResistanceSystem:onDestory()
end

function CharacterSkillResistanceSystem:onUpdate(ft)
end

--@desc: 增加/减少角色武学攻击抗性
--@author:Seven
--@time:2025-02-27 14:36:41
--@id: 抗性id
--@value: 抗性值
function CharacterSkillResistanceSystem:addSkillAtkResistance(id, value)
    __verifyId(id)
    if self.__atkResistanceMap[id] == nil then
        self.__atkResistanceMap[id] = 0
    end

    self.__atkResistanceMap[id] = self.__atkResistanceMap[id] + value

    if self.__atkResistanceMap[id] == 0 then
        self.__atkResistanceMap[id] = nil
    end
end

--@desc: 增加/减少角色武学防御抗性
--@author:Seven
--@time:2025-02-27 14:37:41
--@id: 抗性id
--@value: 抗性值
function CharacterSkillResistanceSystem:addSkillDefResistance(id, value)
    __verifyId(id)
    if self.__defResistanceMap[id] == nil then
        self.__defResistanceMap[id] = 0
    end

    self.__defResistanceMap[id] = self.__defResistanceMap[id] + value

    if self.__defResistanceMap[id] == 0 then
        self.__defResistanceMap[id] = nil
    end
end

function CharacterSkillResistanceSystem:getSkillAtkResistance(id)
    __verifyId(id)
    return self.__atkResistanceMap[id] or 0
end

function CharacterSkillResistanceSystem:getSkillDefResistance(id)
    __verifyId(id)
    return self.__defResistanceMap[id] or 0
end

return newClass("CharacterSkillResistanceSystem", {ABasicCharacterFuncSystem}, CharacterSkillResistanceSystem)
0000000000000000