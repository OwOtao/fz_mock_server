local class = require("third.class.NewClass")
local BaseSound = require("app.models.fight.FightSounds.BaseSound")
local RandomDieSound = {}

local Sounds = {
    ["nan"] = {
        "nan_die_1.mp3",
        "nan_die_2.mp3",
    },

    ["男"] = {
        "nan_die_1.mp3",
        "nan_die_2.mp3",
    },

    ["nv"] = {
        "nv_die_1.mp3",
        "nv_die_2.mp3",
    },

    ["女"] = {
        "nv_die_1.mp3",
        "nv_die_2.mp3",
    },
}

function RandomDieSound:getSoundFileName(type)
    if Sounds[type] then
        local sounds = Sounds[type]
        
        local fileName = sounds[math.random(1, #sounds)]
        print("playRandomDieSound fileName = ", fileName)
        return fileName
    end
end

return class("RandomDieSound", {BaseSound}, RandomDieSound)
000000000000000