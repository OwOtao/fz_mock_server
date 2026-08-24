local NewClass = require("third.class.NewClass")
local FadeTo = require("app.extends.NodeAction.FadeTo")
local FadeIn = {}

function FadeIn:create(duration)
    local p = FadeIn.new()
    p:__init(duration, 255)
    return p
end

return NewClass("FadeIn", {FadeTo}, FadeIn)
000