local newClass = require("third.class.NewClass")

local BaseHurt = require("app.models.fight.Hurt.BaseHurt")

local ShenBingHurt = {}

function ShenBingHurt:create(type,value)
    local p = ShenBingHurt.new()
    p:init(type,value)
    return p
end

function ShenBingHurt:ctor()
end

function ShenBingHurt:isActiveHurt()
    return false
end

function ShenBingHurt:isAutoHurt()
    return true
end

return newClass("ShenBingHurt", {BaseHurt}, ShenBingHurt)
000000000000000