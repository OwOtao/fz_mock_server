--[[
    author:Seven
    time:2022-09-02 11:21:59
    desc:
]]
local newClass = require("third.class.NewClass")

local FightCommons = require("app.FightSystem.FightCommons")

local AttackSound = {}

--@desc: 获取攻击音效
--@author:Seven
--@time:2022-09-02 11:23:12
--@zhaoInfo: [src.app.FightSystem.FightSkill.ZhaoInfo#ZhaoInfo]
--@attacker: [src.app.FightSystem.FightRole.FightCharacter#FightCharacter]
function AttackSound.getAttackSound(zhaoInfo, attacker)
    local zhaoSoundType = zhaoInfo:getSoundType()

    if zhaoSoundType == FightCommons.ZHAOINFO_SOUND_TYPE.ZHAO_ORIGIN then
        return zhaoInfo:getSoundId()
    elseif zhaoSoundType == FightCommons.ZHAOINFO_SOUND_TYPE.ATTACKER_WEAPON then
        local weapon = attacker:getWeapon()

        return weapon:getWeaponAttackSoundId()
    else
        assert(false, "武功招式：" .. zhaoInfo:getId() .. "音效类型未填或填写错误！")
    end
end

return AttackSound
00000000000000