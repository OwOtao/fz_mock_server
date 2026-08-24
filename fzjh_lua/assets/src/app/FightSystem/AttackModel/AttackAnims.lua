--[[
    desc 攻击相关UI信息
    author:Seven
    time:2021-07-17 24:40:59
]]
local newClass = require("third.class.NewClass")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local AudioResManager = require("app.FightSystem.ResourceManager.AudioResManager")

local AttackAnims = {
    --@desc 根据击中部位提供
    __targetHurtAnims = {},
    --@desc 根据部位存放受击动画及音效
    __targetAnimAndSound = {},
    --@desc 存放一次性特效相关信息
    __oneOffEffectMap = {}
}

function AttackAnims:create()
    return self.new()
end

function AttackAnims:setAttackerAnim(animName)
    self.__attackerAnim = animName
end

function AttackAnims:getAttackerAnim()
    return self.__attackerAnim
end

function AttackAnims:setTargetHurtAnims(anims)
    self.__targetHurtAnims = anims
end

--@desc: 目标动画受击数组
--@author:Seven
--@time:2021-07-17 01:29:02
function AttackAnims:addTargetHurtAnims(hitPos, animName)
    if self.__targetHurtAnims[hitPos] == nil then
        self.__targetHurtAnims[hitPos] = {}
    end

    table.insert(self.__targetHurtAnims[hitPos], animName)
end

function AttackAnims:getTargetHurtAnim(hitPos)
    local targetAnims = self.__targetHurtAnims[hitPos]

    if targetAnims == nil then
        assert(false, string.format("角色动画内没有部位【%s】对应的动画", hitPos))
    end

    local animName
    if #targetAnims > 1 then
        local index = FightUtil:random(1, #targetAnims)
        animName = targetAnims[index]
    else
        animName = targetAnims[1]
    end

    return animName
end

function AttackAnims:addTargetAnimAndSound(hitPos, animName, soundId)
    if self.__targetAnimAndSound[hitPos] == nil then
        self.__targetAnimAndSound[hitPos] = {}
    end

    table.insert(
        self.__targetAnimAndSound[hitPos],
        {
            animName = animName,
            soundId = soundId
        }
    )
end

function AttackAnims:getTargetAnimNameAndSoundName(hitPos)
    local animAndSoundList = self.__targetAnimAndSound[hitPos]

    if animAndSoundList == nil then
        assert(false, string.format("动画内没有部位【%s】对应的受击动画和音效", hitPos))
    end

    local animSoundInfo
    if #animAndSoundList > 1 then
        local index = FightUtil:random(1, #animAndSoundList)
        animSoundInfo = animAndSoundList[index]
    else
        animSoundInfo = animAndSoundList[1]
    end

    local animName = animSoundInfo.animName

    local soundFileName = AudioResManager:getSoundNameByRandom(animSoundInfo.soundId)

    return animName, soundFileName
end

function AttackAnims:setAttackerSoundStart(value)
    self.__attackerSoundStart = value
end

function AttackAnims:getAttackerSoundStart()
    return self.__attackerSoundStart
end

function AttackAnims:setAttackerSoundId(soundId)
    self.__attackerSoundId = soundId
end

function AttackAnims:getAttackerSoundId()
    return self.__attackerSoundId
end

function AttackAnims:setTargetSoundId(soundId)
    self.__targetSoundId = soundId
end

function AttackAnims:getTargetSoundId()
    return self.__targetSoundId
end

function AttackAnims:addOneOffEffectAnimName(eventName, c_id, animName)
    if self.__oneOffEffectMap[eventName] == nil then
        self.__oneOffEffectMap[eventName] = {}
    end

    if self.__oneOffEffectMap[eventName][c_id] == nil then
        self.__oneOffEffectMap[eventName][c_id] = {}
    end

    table.insert(self.__oneOffEffectMap[eventName][c_id], animName)
end

function AttackAnims:getOneOffEffectMap(eventName)
    return Helper:getDef(self.__oneOffEffectMap[eventName], {})
end

return newClass("AttackAnims", {}, AttackAnims)
000000000000