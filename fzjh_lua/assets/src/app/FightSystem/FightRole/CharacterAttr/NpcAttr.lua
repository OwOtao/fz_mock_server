local class = require("third.class.NewClass")
local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

-- local ICharacterAttr = require("app.FightSystem.FightRole.CharacterAttr.ICharacterAttr")

local BaseCharacterAttr = require("app.FightSystem.FightRole.CharacterAttr.BaseCharacterAttr")

--@SuperType [src.app.FightSystem.FightRole.CharacterAttr.BaseCharacterAttr#BaseCharacterAttr]
local NpcAttr = {
    __fightAttr = {
        --@desc 攻击力
        atk = 1,
        --@desc 防御力;def
        def = 1,
        --@desc 伤害力;damage
        damage = 1,
        --@desc 防护力;protect
        protect = 1,
        --@desc 命中力;hit
        hitForce = 0,
        --@desc 闪躲力;dodge
        dodgeForce = 0,
        --@desc 招架力;parry
        parryForce = 0,
        --@desc 拳脚伤害力
        wsdamage = 0
    }
}

function NpcAttr:create(character)
    return NpcAttr.new()
end

function NpcAttr:setAttr(name, value)
    if self.__fightAttr[name] ~= nil then
        return self:__setFightAttr(name, value)
    else
        return BaseCharacterAttr.setAttr(self, name, value)
    end
end

--@desc: 设置战斗相关属性(角色初始时设置完成)
--@author:Seven
--@time:2021-06-30 10:38:40
--@name: 属性名
--@value: 属性值
function NpcAttr:__setFightAttr(name, value)
    if self.__fightAttr[name] == nil then
        assert(false, "NPC战斗属性未定义：" .. name)
    end

    if type(value) ~= "number" then
        error("NpcAttr:__setFightAttr : NPC战斗属性值必须为数字类型 : " .. tostring(name) .. " : " .. tostring(value))
    end

    self.__fightAttr[name] = value
end

--@desc: 攻击力
--@author:Seven
--@time:2021-06-29 16:30:40
function NpcAttr:__getAtk()
    local atk = self.__fightAttr.atk
    FightUtil:printTemplateLog("NPCATTR_GETATK", self:getAttr("name"), tostring(atk))
    return atk
end

function NpcAttr:__getAtkBattle()
    local roleAtk = self:getAttr("atk")

    -- * buff比例加成
    local buffAddition = self.__character:getBuffMulAttr("atk")

    -- * buff固值加成
    local buffConstAtkValue = self.__character:getBuffAddAttr("atk")

    local value = roleAtk * (1 + buffAddition) + buffConstAtkValue

    FightUtil:printTemplateLog("NPCATTR_GETATKBATTLE", self:getAttr("name"), tostring(roleAtk), tostring(buffAddition), tostring(buffConstAtkValue), tostring(value))

    return value
end

--@desc: 伤害力
--@author:Seven
--@time:2021-06-29 16:31:15
function NpcAttr:__getDamage()
    local damage = self.__fightAttr.damage
    FightUtil:printTemplateLog("NPCATTR_GETDAMAGE", self:getAttr("name"), damage)
    return damage
end

function NpcAttr:__getDamageBattle()
    local damage = self:getAttr("damage")

    -- * buff比例加成
    local buffAddition = self.__character:getBuffMulAttr("damage")

    -- * buff固值加成
    local buffConstDamageForceValue = self.__character:getBuffAddAttr("damage")

    local value = damage * (1 + buffAddition) + buffConstDamageForceValue

    FightUtil:printTemplateLog("NPCATTR_GETDAMAGEBATTLE", self:getAttr("name"), damage, buffAddition, buffConstDamageForceValue, value)

    return value
end

--@desc: 防御力
--@author:Seven
--@time:2021-06-29 16:31:31
function NpcAttr:__getDef()
    local def = self.__fightAttr.def
    FightUtil:printTemplateLog("NPCATTR_GETDEF", self:getAttr("name"), def)
    return def
end

function NpcAttr:__getDefBattle()
    local roleDef = self:getAttr("def")

    -- * buff比例加成
    local buffAddition = self.__character:getBuffMulAttr("def")

    -- * buff固值防御加成
    local buffConstDefValue = self.__character:getBuffAddAttr("def")

    local value = roleDef * (1 + buffAddition) + buffConstDefValue

    FightUtil:printTemplateLog("NPCATTR_GETDEFBATTLE", self:getAttr("name"), roleDef, buffAddition, buffConstDefValue, value)

    return value
end

--@desc: 防护力
--@author:Seven
--@time:2021-06-29 21:23:10
function NpcAttr:__getProtect()
    local protect = self.__fightAttr.protect
    FightUtil:printTemplateLog("NPCATTR_GETPROTECT", self:getAttr("name"), protect)
    return protect
end

function NpcAttr:__getProtectBattle()
    local protect = self:getAttr("protect")
    local buffAddition = self.__character:getBuffMulAttr("protect")
    local buffConstProtectValue = self.__character:getBuffAddAttr("protect")

    local value = protect * (1 + buffAddition) + buffConstProtectValue

    FightUtil:printTemplateLog("NPCATTR_GETPROTECTBATTLE", self:getAttr("name"), protect, buffAddition, buffConstProtectValue, value)

    return value
end

--@desc: 闪躲力
--@author:Seven
--@time:2021-06-29 22:29:48
function NpcAttr:__getDodgeForce()
    local dodgeForce = self.__fightAttr.dodgeForce
    FightUtil:printTemplateLog("NPCATTR_GETDODGEFORCE", self:getAttr("name"), dodgeForce)
    return dodgeForce
end

function NpcAttr:__getDodgeForceBattle()
    local dodgeForce = self:getAttr("dodgeForce")

    -- * buff比例加成
    local buffAddition = self.__character:getBuffMulAttr("dodgeForce")

    -- * buff固值闪躲力加成
    local buffConstDodgeForceValue = self.__character:getBuffAddAttr("dodgeForce")

    local value = dodgeForce * (1 + buffAddition) + buffConstDodgeForceValue

    FightUtil:printTemplateLog("NPCATTR_GETDODGEFORCEBATTLE", self:getAttr("name"), dodgeForce, buffAddition, buffConstDodgeForceValue, value)

    return value
end

--@desc: 命中力
--@author:Seven
--@time:2021-06-30 10:28:06
function NpcAttr:__getHitForce()
    local hitForce = self.__fightAttr.hitForce

    FightUtil:printTemplateLog("NPCATTR_GETHITFORCE", self:getAttr("name"), hitForce)

    return hitForce
end

function NpcAttr:__getHitForceBattle()
    local roleHitForce = self:getAttr("hitForce")

    -- * buff比例加成
    local buffAddition = self.__character:getBuffMulAttr("hitForce")

    -- * buff固值命中力加成
    local buffConstHitForceValue = self.__character:getBuffAddAttr("hitForce")

    local value = roleHitForce * (1 + buffAddition) + buffConstHitForceValue

    FightUtil:printTemplateLog("NPCATTR_GETHITFORCEBATTLE", self:getAttr("name"), roleHitForce, buffAddition, buffConstHitForceValue, value)

    return value
end

--@desc: 招架力
--@author:Seven
--@time:2021-06-30 14:42:37
function NpcAttr:__getParryForce()
    local parryForce = self.__fightAttr.parryForce
    FightUtil:printTemplateLog("NPCATTR_GETPARRYFORCE", self:getAttr("name"), parryForce)
    return parryForce
end

function NpcAttr:__getParryForceBattle()
    local parryForce = self:getAttr("parryForce")
    -- * buff比例加成
    local buffAddition = self.__character:getBuffMulAttr("parryForce")

    -- * buff固值加成
    local buffConstParryForceValue = self.__character:getBuffAddAttr("parryForce")

    local value = parryForce * (1 + buffAddition) + buffConstParryForceValue

    FightUtil:printTemplateLog("NPCATTR_GETPARRYFORCEBATTLE", self:getAttr("name"), parryForce, buffAddition, buffConstParryForceValue, value)

    return value
end

--@desc: 实际加力值
--@author:Seven
--@time:2021-07-12 16:43:04
function NpcAttr:__getPlusPoint()
    return self.__attrs.plusPoint
end

function NpcAttr:__setTiliSpeed(value)
    self.__attrs.tiliSpeed = value
end

function NpcAttr:__getTiliSpeed()
    return self.__attrs.tiliSpeed
end

--@region 算法与旧版数值一致，但新版战斗NPC属性读表与副本中的NPC配置不同源，所以NPC相关重新计算
local SkillConst = require("app.models.skill.SkillConst")
function NpcAttr:__getStrCondSkill()
    local str = self:getAttr("str")

    local baseLv = self.__character:getBaseSkill(SkillConst.SkillSecondType.QUAN_JIAO):getLevel()

    return str + Helper:mathFloor(baseLv / 10)
end

function NpcAttr:__getDexCondSkill()
    local dex = self:getAttr("dex")

    local baseLv = self.__character:getBaseSkill(SkillConst.SkillSecondType.QING_GONG):getLevel()

    return dex + Helper:mathFloor(baseLv / 10)
end

function NpcAttr:__getConCondSkill()
    local con = self:getAttr("con")

    local baseLv = self.__character:getBaseSkill(SkillConst.SkillSecondType.NEI_GONG):getLevel()

    return con + Helper:mathFloor(baseLv / 10)
end

function NpcAttr:__getIntCondSkill()
    return self.__attrs.intCondSkill
end

function NpcAttr:__getWsdamage()
    return self.__fightAttr.wsdamage
end

--@endregion

return class("NpcAttr", {BaseCharacterAttr}, NpcAttr)
00000