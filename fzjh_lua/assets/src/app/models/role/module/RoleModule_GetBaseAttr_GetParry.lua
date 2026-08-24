local Module = require("third.module.Module")
local RoleModule_GetBaseAttr_GetParry = class("RoleModule_GetBaseAttr_GetParry", Module)

function RoleModule_GetBaseAttr_GetParry:ctor()
    self._name = "RoleModule_GetBaseAttr_GetParry"
end

function RoleModule_GetBaseAttr_GetParry.getBaseAttr(module, self, attrName)
    if attrName == "parry" then
        local skillLv, factor = self:getSkillLvAndFactor("zhaojia", "parry")

        local baseValue = (skillLv * 15 * factor) / 200

        return true, baseValue
    end
    return false
end

function RoleModule_GetBaseAttr_GetParry:getBuffAttr(target, attrName)
    if attrName ~= "parry" then
        return 0
    end
    
	--神兵特性
	local addParry = 0
	local equipWeapon = target:getEquipByName("weapon")
	if equipWeapon ~= nil and equipWeapon ~="拳脚" then
		local weapen = target:getOneItemByKey(equipWeapon.itemId)
		if weapen ~= nil then
			addParry = Helper:getDef(ShenBingEffct:getWeaponExtraParry(weapen,target),0)
		end
		if DEBUG_MODE == 1 then
			print("------------------------兵器特性提升招架----------------------------------",addParry)
		end
	end

	local fistFootAddValue = 0
	if equipWeapon == nil or equipWeapon == "拳脚" then
		local FightRoleFistFootEffect = require("src.app.models.fight.FightRoleFistFootEffect")
		fistFootAddValue = FightRoleFistFootEffect:getParryBuffsValue(target)
	end

    return addParry + fistFootAddValue
end

return RoleModule_GetBaseAttr_GetParry
000000