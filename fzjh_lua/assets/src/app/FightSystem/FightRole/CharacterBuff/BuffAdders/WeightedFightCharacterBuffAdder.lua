--[[
    author:Seven
    time:2026-01-12
    desc: 加权随机Buff添加器类
]]
local newClass = require("third.class.NewClass")
local AFightCharacterBuffAdder = require("app.FightSystem.FightRole.CharacterBuff.BuffAdders.AFightCharacterBuffAdder")

--@SuperType [src.app.FightSystem.FightRole.CharacterBuff.BuffAdders.AFightCharacterBuffAdder#AFightCharacterBuffAdder]
local WeightedFightCharacterBuffAdder = {}

function WeightedFightCharacterBuffAdder:create(weightedBuffAdderRes)
    return WeightedFightCharacterBuffAdder.new():__init(weightedBuffAdderRes)
end

function WeightedFightCharacterBuffAdder:__init(weightedBuffAdderRes)
    --@RefType [src.app.FightSystem.FightBuff.BasicBuffAdder.WeightedBuffAdderRes#WeightedBuffAdderRes]
    self.__weightedBuffAdderRes = weightedBuffAdderRes
    return self
end

function WeightedFightCharacterBuffAdder:getAddBuffNodes()
    return tonumber(self.__weightedBuffAdderRes:getAddBuffNodes())
end

function WeightedFightCharacterBuffAdder:getAddBuffId()
    return self.__weightedBuffAdderRes:getAddBuffID()
end

--@desc: 获取buff添加目标类型
--@author:Seven
--@time:2026-01-12
function WeightedFightCharacterBuffAdder:getAddBuffTargetType()
    return self.__weightedBuffAdderRes:getAddBuffTarget()
end

function WeightedFightCharacterBuffAdder:getAddBuffdynamicArg1()
    return self.__weightedBuffAdderRes:getAddBuffdynamicArg1()
end

function WeightedFightCharacterBuffAdder:getAddBuffdynamicArg2()
    return self.__weightedBuffAdderRes:getAddBuffdynamicArg2()
end

function WeightedFightCharacterBuffAdder:getAddBuffdynamicArg3()
    return self.__weightedBuffAdderRes:getAddBuffdynamicArg3()
end

function WeightedFightCharacterBuffAdder:getAddBuffdynamicArg4()
    return self.__weightedBuffAdderRes:getAddBuffdynamicArg4()
end

--@desc: 获取权重值
--@author:Seven
--@time:2026-01-12
function WeightedFightCharacterBuffAdder:getWeight()
    return tonumber(self.__weightedBuffAdderRes:getWeight()) or 0
end

return newClass("WeightedFightCharacterBuffAdder", {AFightCharacterBuffAdder}, WeightedFightCharacterBuffAdder)
00000