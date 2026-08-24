-- add by XiaoZhiWei 2017/07/12 16:32:53 战斗音效
local RandomHitSound = require("app.models.fight.FightSounds.RandomHitSound")
local RandomParrySound = require("app.models.fight.FightSounds.RandomParrySound")
local RandomDodgeSound = require("app.models.fight.FightSounds.RandomDodgeSound")
local RandomHurtSound = require("app.models.fight.FightSounds.RandomHurtSound")
local RandomDieSound = require("app.models.fight.FightSounds.RandomDieSound")
local ActiveZhaoSound = require("app.models.fight.FightSounds.ActiveZhaoSound")
local LogSystem = require("app.models.LogSystem.LogSystem")
local FightSounds = {}

-- 播放主动技能集中音效
function FightSounds:playActiveZhaoHitSound(sound, soundType)
    LogSystem:log("旧版战斗：主动技能击中音效","|参数1", sound, "|参数2", soundType)
    if sound == nil or soundType == nil then
        return
    end

    local soundFile = ActiveZhaoSound:getHitSoundFileName(sound, soundType)
    LogSystem:log("旧版战斗：主动技能击中音效","|音效文件", soundFile)
    if soundFile then
        ActiveZhaoSound:playSound(soundFile)
    end
end

-- 播放主动技能格挡音效
function FightSounds:playActiveZhaoParrySound(sound, soundType)
    LogSystem:log("旧版战斗：主动技能招架音效","|参数1", sound, "|参数2", soundType)
    if sound == nil or soundType == nil then
        return
    end
    
    local soundFile = ActiveZhaoSound:getParrySoundFileName(sound, soundType)
    LogSystem:log("旧版战斗：主动技能招架音效","|音效文件", soundFile)
    if soundFile then
        ActiveZhaoSound:playSound(soundFile)
    end
end

-- 播放主动技能闪避音效
function FightSounds:playActiveZhaoDodgeSound(sound, soundType)
    LogSystem:log("旧版战斗：主动技能闪避音效","|参数1", sound, "|参数2", soundType)
    if sound == nil or soundType == nil then
        return
    end
    
    local soundFile = ActiveZhaoSound:getDodgeSoundFileName(sound, soundType)
    LogSystem:log("旧版战斗：主动技能闪避音效","|音效文件", soundFile)
    if soundFile then
        ActiveZhaoSound:playSound(soundFile)
    end
end


-- 播放主动技能死亡音效
function FightSounds:playActiveZhaoDieSound(sound)
    LogSystem:log("旧版战斗：主动技能死亡音效","|参数1", sound)
    if sound == nil then
        return
    end

    local soundFile = ActiveZhaoSound:getDieSoundFileName(sound)
    LogSystem:log("旧版战斗：主动技能死亡音效","|音效文件", soundFile)
    if soundFile then
        ActiveZhaoSound:playSound(soundFile)
    end
end

-- 播放主动技能受伤音效
function FightSounds:playActiveZhaoHurtSound(sound)
    LogSystem:log("旧版战斗：主动技能受伤音效","|参数1", sound)
    if sound == nil then
        return
    end

    local soundFile = ActiveZhaoSound:getHurtSoundFileName(sound)
    LogSystem:log("旧版战斗：主动技能受伤音效","|音效文件", soundFile)
    if soundFile then
        ActiveZhaoSound:playSound(soundFile)
    end
end

--击中音效
function FightSounds:playRandomHitSound(type1, type2)
    LogSystem:log("旧版战斗：随机击中音效","|参数1", type1,"|参数2", type2)
    local soundFile = RandomHitSound:getSoundFileName(type1, type2)
    LogSystem:log("旧版战斗：随机击中音效","|音效文件", soundFile)
    if soundFile then
        RandomHitSound:playSound(soundFile)
    end
end

--招架音效
function FightSounds:playRandomParrySound(type1, type2)
    LogSystem:log("旧版战斗：随机招架音效","|参数1", type1,"|参数2", type2)
    local soundFile = RandomParrySound:getSoundFileName(type1, type2)
    LogSystem:log("旧版战斗：随机招架音效","|音效文件", soundFile)
    if soundFile then
        RandomParrySound:playSound(soundFile)
    end
end

--闪躲音效
function FightSounds:playRandomDodgeSound(type1, type2)
    LogSystem:log("旧版战斗：随机躲闪音效","|参数1", type1,"|参数2", type2)
    local soundFile = RandomDodgeSound:getSoundFileName(type1, type2)
    LogSystem:log("旧版战斗：随机躲闪音效","|音效文件", soundFile)
    if soundFile then
        RandomDodgeSound:playSound(soundFile)
    end
end

--受伤音效
function FightSounds:playRandomHurtSound(sex)
    LogSystem:log("旧版战斗：随机受伤音效","|参数1", sex)
    local soundFile = RandomHurtSound:getSoundFileName(sex)
    LogSystem:log("旧版战斗：随机受伤音效","|音效文件", soundFile)
    if soundFile then
        RandomHurtSound:playSound(soundFile)
    end
end

--死亡音效
function FightSounds:playRandomDieSound(sex)
    LogSystem:log("旧版战斗：随机死亡音效","|参数1", sex)
    local soundFile = RandomDieSound:getSoundFileName(sex)
    LogSystem:log("旧版战斗：随机死亡音效","|音效文件", soundFile)
    if soundFile then
        RandomDieSound:playSound(soundFile)
    end
end

return FightSounds000000000