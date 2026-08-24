local newClass = require("third.class.NewClass")

local BaseHurt = require("app.models.fight.Hurt.BaseHurt")

local FistFootHurt = {}

function FistFootHurt:create(type,value)
    local p = FistFootHurt.new()
    p:init(type,value)
    return p
end

function FistFootHurt:ctor()
end

function FistFootHurt:isActiveHurt()
    return false
end

function FistFootHurt:isAutoHurt()
    return true
end

return newClass("FistFootHurt", {BaseHurt}, FistFootHurt)
000000000000000