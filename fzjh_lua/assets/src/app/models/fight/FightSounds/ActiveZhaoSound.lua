local class = require("third.class.NewClass")
local BaseSound = require("app.models.fight.FightSounds.BaseSound")
local ActiveZhaoSound = {}

local Sounds = {
    ["dieSounds"] = {
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
        }
    },

    ["hurtSounds"] = {
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

}

local function initSounds()
    local weaponTypesRes = require("script.newbattle.demo.weaponTypesRes")["武器分类"]
    if MapIsEmpty(weaponTypesRes) == false then
        for k, res in pairs(weaponTypesRes) do
            local first, second = false, false

            if not Sounds[res.firstType] then
                Sounds[res.firstType] = {}
                Sounds[res.firstType]["hitSounds"] = {}
                Sounds[res.firstType]["dodgeSounds"] = {}
                Sounds[res.firstType]["parrySounds"] = {}
                first = true
            end

            if not Sounds[res.secondTypeName] then
                Sounds[res.secondTypeName] = {}
                Sounds[res.secondTypeName]["hitSounds"] = {}
                Sounds[res.secondTypeName]["dodgeSounds"] = {}
                Sounds[res.secondTypeName]["parrySounds"] = {}
                second = true
            end

            if res.hitSounds then
                local sounds = string.split(res.hitSounds, "#")

                for k, sound in pairs(sounds) do
                    if first then
                        table.insert(Sounds[res.firstType]["hitSounds"], sound)
                    end

                    if second then
                        table.insert(Sounds[res.secondTypeName]["hitSounds"], sound)
                    end
                end
            end

            if res.dodgeSounds then
                local sounds = string.split(res.dodgeSounds, "#")

                for k, sound in pairs(sounds) do
                    if first then
                        table.insert(Sounds[res.firstType]["dodgeSounds"], sound)
                    end

                    if second then
                        table.insert(Sounds[res.secondTypeName]["dodgeSounds"], sound)
                    end
                end
            end

            if res.parrySounds then
                local sounds = string.split(res.parrySounds, "#")

                for k, sound in pairs(sounds) do
                    if first then
                        table.insert(Sounds[res.firstType]["parrySounds"], sound)
                    end

                    if second then
                        table.insert(Sounds[res.secondTypeName]["parrySounds"], sound)
                    end
                end
            end
        end
    end
end

initSounds()

-- 音效类型=weaponClass，
--     音效参数=武器一级类型ID（例如：剑、刀、乐器……）
-- 音效类型=weaponType，
--     音效参数=武器二级类型ID（例如：短剑、弯刀、笛子……）
-- 音效类型=special，
--     音效参数=攻击命中音效文件名;攻击受击音效文件名;攻击死亡音效文件名;
--         攻击招架音效文件名;攻击闪躲音效文件名，
--         例如（buff.mp3;0;0;0;0）填0代表和第1个一样

function ActiveZhaoSound:getHitSoundFileName(sound, soundType)
    if soundType == "special" then
        return sound
    end

    local fileName = nil

    if sound == "拳脚" then
        sound = "空手"
    end

    local sounds = Sounds[sound]["hitSounds"]

    if sounds then
        fileName = sounds[math.random(1, #sounds)]
    end

    return fileName
end

function ActiveZhaoSound:getParrySoundFileName(sound, soundType)
    if soundType == "special" then
        return sound
    end

    if sound == "拳脚" then
        sound = "空手"
    end

    local fileName = nil

    local sounds = Sounds[sound]["parrySounds"]

    if sounds then
        fileName = sounds[math.random(1, #sounds)]
    end

    return fileName
end

function ActiveZhaoSound:getDodgeSoundFileName(sound, soundType)
    if soundType == "special" then
        return sound
    end

    if sound == "拳脚" then
        sound = "空手"
    end

    local fileName = nil

    local sounds = Sounds[sound]["dodgeSounds"]

    if sounds then
        fileName = sounds[math.random(1, #sounds)]
    end

    return fileName
end

function ActiveZhaoSound:getDieSoundFileName(sound)
    if Sounds["dieSounds"][sound] then
        local sounds = Sounds["dieSounds"][sound]
        return sounds[math.random(1, #sounds)]
    else
        return sound
    end
end

function ActiveZhaoSound:getHurtSoundFileName(sound)
    if Sounds["hurtSounds"][sound] then
        local sounds = Sounds["hurtSounds"][sound]
        return sounds[math.random(1, #sounds)]
    else
        return sound
    end
end

return class("ActiveZhaoSound", {BaseSound}, ActiveZhaoSound)
0000000000000