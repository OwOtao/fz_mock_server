local newClass = require("third.class.NewClass")

local BaseHurt = require("app.models.fight.Hurt.BaseHurt")

local ActiveHurt = {}

function ActiveHurt:create(type,value)
    local p = ActiveHurt.new()
    p:init(type,value)
    return p
end

function ActiveHurt:ctor()
end

function ActiveHurt:isActiveHurt()
    return true
end

function ActiveHurt:isAutoHurt()
    return false
end

return newClass("ActiveHurt", {BaseHurt}, ActiveHurt)
000000000000000