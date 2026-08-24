local class = require("third.class.NewClass")
local BaseSound = require("app.models.fight.FightSounds.BaseSound")
local RandomHitSound = {}

local Sounds = {}

local function initSounds()
    local weaponTypesRes = require("script.newbattle.demo.weaponTypesRes")["武器分类"]
    if MapIsEmpty(weaponTypesRes) == false then
        for k, res in pairs(weaponTypesRes) do
            if not Sounds[res.firstType] then
                Sounds[res.firstType] = {}
            end

            if not Sounds[res.firstType][res.secondTypeId] then
                Sounds[res.firstType][res.secondTypeId] = {}
            end

            if res.hitSounds then
                local sounds = string.split(res.hitSounds, "#")

                for k, sound in pairs(sounds) do
                    table.insert(Sounds[res.firstType][res.secondTypeId], sound)
                end
            end
        end
    end
end

initSounds()

function RandomHitSound:getSoundFileName(type1, type2)
    assert(type1,"RandomHitSound:getSoundRes type1 is nil")

    local sounds = {}

    if type1 == "拳脚" then
        type1 = "空手"
        type2 = 1
    end

    if Sounds[type1] and Sounds[type1][type2] then
        sounds = Sounds[type1][type2]
    else
        assert(false, "RandomHitSound:getSoundFileName the type of Sounds is nil, type is"..type1)
    end

    local fileName = sounds[math.random(1, #sounds)]
    print("playRandomHitSound fileName = ", fileName)
    return fileName
end

return class("RandomHitSound", {BaseSound}, RandomHitSound)
00