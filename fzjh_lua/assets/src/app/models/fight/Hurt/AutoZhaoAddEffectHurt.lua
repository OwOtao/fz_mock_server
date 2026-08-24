local newClass = require("third.class.NewClass")

local BaseHurt = require("app.models.fight.Hurt.BaseHurt")

local AutoZhaoAddEffectHurt = {}

function AutoZhaoAddEffectHurt:create(type,value)
    local p = AutoZhaoAddEffectHurt.new()
    p:init(type,value)
    return p
end

function AutoZhaoAddEffectHurt:ctor()
end

function AutoZhaoAddEffectHurt:isActiveHurt()
    return false
end

function AutoZhaoAddEffectHurt:isAutoHurt()
    return true
end

return newClass("AutoZhaoAddEffectHurt", {BaseHurt}, AutoZhaoAddEffectHurt)
0000000