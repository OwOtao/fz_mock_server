local class = require("third.class.NewClass")

local BaseSound = {}

function BaseSound:create()
    return BaseSound:new()
end

function BaseSound:playSound(soundFileName)
    local fileName = "Music/Fight/" .. soundFileName
    Audio:playEffectWithFileName(fileName, false)
end

return class("BaseSound", {}, BaseSound)
0000000000000000