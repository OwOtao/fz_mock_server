local NewClass = require("third.class.NewClass")
local FadeTo = require("app.extends.NodeAction.FadeTo")
local FadeOut = {}

function FadeOut:create(duration)
    local p = FadeOut.new()
    p:__init(duration, 0)
    return p
end

return NewClass("FadeOut", {FadeTo}, FadeOut)
0000000000000000