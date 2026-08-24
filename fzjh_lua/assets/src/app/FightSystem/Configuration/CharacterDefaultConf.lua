local AnimResManager = require("app.FightSystem.ResourceManager.AnimResManager")
local AudioResManager = require("app.FightSystem.ResourceManager.AudioResManager")

local characterConfRes = require("script.newbattle.demo.characterConf")["角色外观设定"]

local FightCommons = require("app.FightSystem.FightCommons")

local CharacterDefaultConf = {}

function CharacterDefaultConf:getCharacterDefaultConf(id)
    local info = characterConfRes[id]
    if info == nil then
        assert(false, "获取角色默认配置信息错误，未知物种：" .. id)
    end

    return info
end

--@desc: 头部受击死亡动画
--@author:Seven
--@time:2021-06-24 16:40:39
--@id: 物种类型
function CharacterDefaultConf:getDeadHeadAnim(id)
    local info = self:getCharacterDefaultConf(id)
    local animName = AnimResManager:getOtherAnimName(info.deadHeadAnim)
    return animName
end

function CharacterDefaultConf:getDeadAnim(id, hitPos)
    if hitPos == FightCommons.HIT_POS.HEAD then
        return self:getDeadHeadAnim(id)
    elseif hitPos == FightCommons.HIT_POS.CHEST then
        return self:getDeadChestAnim(id)
    elseif hitPos == FightCommons.HIT_POS.FOOT then
        return self:getDeadFootAnim(id)
    else
        error(string.format("CharacterDefaultConf:getDeadAnim 获取死亡动画出错，受击【%s】未定义！", hitPos))
    end
end

function CharacterDefaultConf:getHurtAnim(id, hitPos)
    if hitPos == FightCommons.HIT_POS.HEAD then
        return self:getHurtHeadAnim(id)
    elseif hitPos == FightCommons.HIT_POS.CHEST then
        return self:getHurtChestAnim(id)
    elseif hitPos == FightCommons.HIT_POS.FOOT then
        return self:getHurtFootAnim(id)
    else
        error(string.format("CharacterDefaultConf:getHurtAnim 获取受击动画出错，受击【%s】未定义！", hitPos))
    end
end

function CharacterDefaultConf:getDeadChestAnim(id)
    local info = self:getCharacterDefaultConf(id)
    local animName = AnimResManager:getOtherAnimName(info.deadChestAnim)
    return animName
end

function CharacterDefaultConf:getDeadFootAnim(id)
    local info = self:getCharacterDefaultConf(id)
    local animName = AnimResManager:getOtherAnimName(info.deadFootAnim)
    return animName
end

function CharacterDefaultConf:getHurtHeadAnim(id)
    local info = self:getCharacterDefaultConf(id)
    local animName = AnimResManager:getOtherAnimName(info.hurtHeadAnim)
    return animName
end

function CharacterDefaultConf:getHurtChestAnim(id)
    local info = self:getCharacterDefaultConf(id)
    local animName = AnimResManager:getOtherAnimName(info.hurtChestAnim)
    return animName
end

function CharacterDefaultConf:getHurtFootAnim(id)
    local info = self:getCharacterDefaultConf(id)
    local animName = AnimResManager:getOtherAnimName(info.hurtFootAnim)
    return animName
end

function CharacterDefaultConf:getControlledStunAnim(id)
    local info = self:getCharacterDefaultConf(id)
    return info.controlledStunAnim
end

function CharacterDefaultConf:getControlledConfuseAnim(id)
    local info = self:getCharacterDefaultConf(id)
    return info.controlledConfuseAnim
end

function CharacterDefaultConf:getHurtSoundId(id)
    local info = self:getCharacterDefaultConf(id)
    return info.hurtSound
end

function CharacterDefaultConf:getHurtSound(id)
    local info = self:getCharacterDefaultConf(id)
    local soundName = AudioResManager:getSoundNameByRandom(info.hurtSound)
    return soundName
end

function CharacterDefaultConf:getDieSoundId(id)
    local info = self:getCharacterDefaultConf(id)
    return info.dieSound
end

return CharacterDefaultConf
00000000