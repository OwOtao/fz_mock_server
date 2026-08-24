local Module = require("third.module.Module")
local RoleModule_GetBaseAttr_GetDef = class("RoleModule_GetBaseAttr_GetDef", Module)

function RoleModule_GetBaseAttr_GetDef:ctor()
    self._name = "RoleModule_GetBaseAttr_GetDef"
end

function RoleModule_GetBaseAttr_GetDef.getBaseAttr(module, self, attrName)
    if attrName == "def" then
        local skillLv, factor = self:getSkillLvAndFactor("zhaojia", "def")

        local baseValue = (5 * skillLv * factor / 120 + self:getExp() ^ 0.4 + 10) * (1.35 + self:getEffectDex() * 0.005)

        return true, baseValue
    end
    return false
end

function RoleModule_GetBaseAttr_GetDef:getBuffAttr(target, attrName)
    if attrName ~= "def" then
        return 0
    end

    local baseValue = select(2, self:getBaseAttr(target, attrName))

    local value = 0

    -- 经脉印记效果 攻击力提升
    if target:getTimeLimitFlag("经脉印记防御力提升") == 1 then
        local Meridian = require("app.models.Meridian.Meridian")
        local meridianBuffValue = Meridian:getMeridianBuffValue("taotieyin")
        value = math.ceil(baseValue * meridianBuffValue)
    end

    local fistFootAddValue = 0
    local equipWeapon = target:getEquipByName("weapon")
	if equipWeapon == nil or equipWeapon == "拳脚" then
		local FightRoleFistFootEffect = require("src.app.models.fight.FightRoleFistFootEffect")
		fistFootAddValue = FightRoleFistFootEffect:getDefBuffsValue(target)
	end

    return value + fistFootAddValue
end

return RoleModule_GetBaseAttr_GetDef
0000