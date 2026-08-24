--[[
    author:Seven
    time:2026-01-12
    desc: 加权随机buff添加器资源类
]]
local newClass = require("third.class.NewClass")

local WeightedBuffAdderRes = {}

function WeightedBuffAdderRes:create(res)
    return WeightedBuffAdderRes.new():__init(res)
end

function WeightedBuffAdderRes:__init(res)
    self.__res = res
    return self
end

-- 编号;
function WeightedBuffAdderRes:getId()
    return self.__res.id
end

-- buff添加器;
function WeightedBuffAdderRes:getBuffLauncher()
    return self.__res.buffLauncher
end

-- Buff添加目标;
function WeightedBuffAdderRes:getAddBuffTarget()
    return self.__res.addBuffTarget
end

-- 添加Buff节点;
function WeightedBuffAdderRes:getAddBuffNodes()
    return self.__res.addBuffNodes
end

-- 战场BuffID;
function WeightedBuffAdderRes:getAddBuffID()
    return self.__res.addBuffID
end

-- Buff效果参数1;
function WeightedBuffAdderRes:getAddBuffdynamicArg1()
    return self.__res.addBuffdynamicArg1
end

-- Buff效果参数2;
function WeightedBuffAdderRes:getAddBuffdynamicArg2()
    return self.__res.addBuffdynamicArg2
end

-- Buff效果参数3;
function WeightedBuffAdderRes:getAddBuffdynamicArg3()
    return self.__res.addBuffdynamicArg3
end

-- Buff效果参数4;
function WeightedBuffAdderRes:getAddBuffdynamicArg4()
    return self.__res.addBuffdynamicArg4
end

-- 加权随机权值;
function WeightedBuffAdderRes:getWeight()
    return tonumber(self.__res.weight) or 0
end

return newClass("WeightedBuffAdderRes", {}, WeightedBuffAdderRes)
00000