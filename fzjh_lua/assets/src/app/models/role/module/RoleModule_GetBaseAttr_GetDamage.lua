local Module = require("third.module.Module")
local RoleModule_GetBaseAttr_GetDamage = class("RoleModule_GetBaseAttr_GetDamage", Module)

function RoleModule_GetBaseAttr_GetDamage:ctor()
    self._name = "RoleModule_GetBaseAttr_GetDamage"
end

function RoleModule_GetBaseAttr_GetDamage.getBaseAttr(module, self, attrName)
    if attrName == "damage" then
        -- 只获取基础的数值，不添加其他加成
        local jiaLi = self:getFinalAttr("jiaLi")
        if self.neili < jiaLi then
            jiaLi = 0
        end

        local cType = self:getCurrTypeByWeapon()
        local factor = self:getSkillFactor(cType, "powerDamRate")

        local weapon = self:getEquipByName("weapon")
        local item
        if weapon and weapon.itemId then
            item = self:getOneItemByKey(weapon.itemId)
        end
        local wpAtk = 0
        if item and item.damage then
            wpAtk = item:getWeaponDamage(self)
        end

        local wsdamage = self:getWsdamage()

        -- 基础伤害力
        local baseValue = (jiaLi * factor / 80) + wpAtk + wsdamage

        return true, baseValue
    end
    return false
end


function RoleModule_GetBaseAttr_GetDamage:getBuffAttr(target, attrName)
    if attrName ~= "damage" then
        return 0
    end

    local value = 0

    return value
end

return RoleModule_GetBaseAttr_GetDamage
0000000