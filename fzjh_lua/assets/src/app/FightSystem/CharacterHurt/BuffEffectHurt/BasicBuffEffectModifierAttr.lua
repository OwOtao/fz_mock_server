--[[
    author:Seven
    time:2023-03-22 15:04:01
    desc: buff效果带来的属性变化
]]
local newClass = require("third.class.NewClass")

local ABuffEffectModifierAttr = require("app.FightSystem.CharacterHurt.BuffEffectHurt.ABuffEffectModifierAttr")

--@SuperType [src.app.FightSystem.CharacterHurt.BuffEffectHurt.ABuffEffectModifierAttr#ABuffEffectModifierAttr]
local BasicBuffEffectModifierAttr = {}

--@desc: 
--@author:Seven
--@time:2023-03-22 15:13:58
--@return [src.app.FightSystem.CharacterHurt.BuffEffectHurt.BasicBuffEffectModifierAttr#BasicBuffEffectModifierAttr]
function BasicBuffEffectModifierAttr:create()
    return BasicBuffEffectModifierAttr.new()
end

return newClass("BasicBuffEffectModifierAttr", {ABuffEffectModifierAttr}, BasicBuffEffectModifierAttr)
00000000000000