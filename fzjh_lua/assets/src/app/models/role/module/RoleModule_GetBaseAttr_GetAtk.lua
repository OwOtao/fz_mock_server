local Module = require("third.module.Module")
local RoleModule_GetBaseAttr_GetAtk = class("RoleModule_GetBaseAttr_GetAtk", Module)

function RoleModule_GetBaseAttr_GetAtk:ctor()
    self._name = "RoleModule_GetBaseAttr_GetAtk"
end

function RoleModule_GetBaseAttr_GetAtk.getBaseAttr(module, self, attrName)
    if attrName == "atk" then
        local cType = self:getCurrTypeByWeapon()
        if cType == "quanjiao" then
            -- 暂用拳脚1做计算
            cType = "quanjiao1"
        end

        local skillLv, factor = self:getSkillLvAndFactor(cType, "atk")

        -- 基础攻击力
        local baseValue = (skillLv * 0.03 * factor + self:getFinalAttr("neiliMax") / 20 + 10 + self:getExp() ^ 0.4) * (1 + 0.02 * self:getEffectStr()) + self:getJiaLiAtk()

        return true, baseValue
    end
    return false
end

function RoleModule_GetBaseAttr_GetAtk:getBuffAttr(target, attrName)
    if attrName ~= "atk" then
        return 0
    end

    local value = 0

    local baseValue = select(2, self:getBaseAttr(target, attrName))

    -- 提升攻击力标记
    if target:getTimeLimitFlag("经脉印记攻击力提升") == 1 then
        local Meridian = require("app.models.Meridian.Meridian")
        local meridianBuffValue = Meridian:getMeridianBuffValue("dukangyin")

        value = math.ceil(baseValue * meridianBuffValue)
    end

    --神兵特性
    local addAtk = 0
    local equipWeapon = target:getEquipByName("weapon")
    if equipWeapon ~= nil and equipWeapon ~= "拳脚" then
        local weapen = target:getOneItemByKey(equipWeapon.itemId)
        if weapen ~= nil then
            addAtk = Helper:getDef(ShenBingEffct:getWeaponExtraAtk(weapen, target), 0)
        end
    end

    return value + addAtk
end

return RoleModule_GetBaseAttr_GetAtk
0000000000