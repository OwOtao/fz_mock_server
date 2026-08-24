local newClass = require("third.class.NewClass")

local BaseHurt = require("app.models.fight.Hurt.BaseHurt")

local PoisonHurt = {}

function PoisonHurt:create(type,value)
    local p = PoisonHurt.new()
    p:init(type,value)
    return p
end

function PoisonHurt:ctor()
end

function PoisonHurt:isActiveHurt()
    return false
end

function PoisonHurt:isAutoHurt()
    return true
end

return newClass("PoisonHurt", {BaseHurt}, PoisonHurt)
000000000000000