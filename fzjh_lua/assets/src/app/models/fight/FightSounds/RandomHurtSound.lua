local class = require("third.class.NewClass")
local BaseSound = require("app.models.fight.FightSounds.BaseSound")
local RandomHurtSound = {}

local Sounds = {
    ["nan"] = {
        "nan_hurt_1.mp3",
        "nan_hurt_2.mp3",
    },

    ["男"] = {
        "nan_hurt_1.mp3",
        "nan_hurt_2.mp3",
    },

    ["nv"] = {
        "nv_hurt_1.mp3",
        "nv_hurt_2.mp3",
    },

    ["女"] = {
        "nv_hurt_1.mp3",
        "nv_hurt_2.mp3",
    },
}

function RandomHurtSound:getSoundFileName(type)
    if Sounds[type] then
        local sounds = Sounds[type]
        
        local fileName = sounds[math.random(1, #sounds)]
        print("playRandomHurtSound fileName = ", fileName)
        return fileName
    end
end

return class("RandomHurtSound", {BaseSound}, RandomHurtSound)
00