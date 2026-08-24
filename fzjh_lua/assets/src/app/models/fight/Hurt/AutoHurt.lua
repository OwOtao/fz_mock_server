local newClass = require("third.class.NewClass")

local BaseHurt = require("app.models.fight.Hurt.BaseHurt")

local AutoHurt = {}

function AutoHurt:create(type,value)
    local p = AutoHurt.new()
    p:init(type,value)
    return p
end

function AutoHurt:ctor()
end

function AutoHurt:isActiveHurt()
    return false
end

function AutoHurt:isAutoHurt()
    return true
end

return newClass("AutoHurt", {BaseHurt}, AutoHurt)
000000000000000