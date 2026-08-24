--[[
    一次攻击帧的结果对象
    
    time:2021-12-07 17:53:28
]]
local newClass = require("third.class.NewClass")

local OneHitAttack = {
    __isCalResult = false,
    __target = nil,
    __qiDamages = {},
    __otherAttrDamages = {},
    __effectAttrsByQiDamages = {},
    __result = {}
}

function OneHitAttack:create()
    local p = OneHitAttack.new()

    -- p:__init()

    return p
end

function OneHitAttack:addQiDamage(qiDamage)
    table.insert(self.__qiDamages, qiDamage)
end

function OneHitAttack:getQiDamages()
    return self.__qiDamages
end

function OneHitAttack:addOtherAttrDamageHurt(hurt)
    table.insert(self.__otherAttrDamages, hurt)
end

function OneHitAttack:getOtherAttrDamageHurt()
    return self.__otherAttrDamages
end

function OneHitAttack:addEffectAttrsByQiDamage(effectInfo)
    table.insert(self.__effectAttrsByQiDamages, effectInfo)
end

function OneHitAttack:getEffectAttrsByQidamage()
    return self.__effectAttrsByQiDamages
end

function OneHitAttack:__addResult(info)
    if self.__result[info.attrName] == nil then
        self.__result[info.attrName] = 0
    end

    self.__result[info.attrName] = self.__result[info.attrName] + info.value
end

function OneHitAttack:getHitAttackResult()
    if self.__isCalResult then
        return self.__result
    end

    if #self.__qiDamages > 0 then
        for i = 1, #self.__qiDamages do
            --@RefType [src.app.FightSystem.AttackModel.QiDamageHurt#QiDamageHurt]
            local qiDamage = self.__qiDamages[i]
            local value = -qiDamage:getActualValue()

            self:__addResult(
                {
                    attrName = "qi",
                    value = value
                }
            )
        end
    end

    if #self.__otherAttrDamages > 0 then
        for i = 1, #self.__otherAttrDamages do
            --@RefType [src.app.FightSystem.AttackModel.Hurt#Hurt]
            local hurt = self.__otherAttrDamages[i]
            local value = -hurt:getHurtValue()

            self:__addResult(
                {
                    attrName = hurt:getAttrName(),
                    value = value
                }
            )
        end
    end

    if #self.__effectAttrsByQiDamages > 0 then
        for i = 1, #self.__effectAttrsByQiDamages do
            local effectAttrInfo = self.__effectAttrsByQiDamages[i]

            self:__addResult(
                {
                    attrName = effectAttrInfo.attraName,
                    value = effectAttrInfo.value
                }
            )
        end
    end

    self.__isCalResult = true

    return self.__result
end

return newClass("OneHitAttack", {}, OneHitAttack)
00