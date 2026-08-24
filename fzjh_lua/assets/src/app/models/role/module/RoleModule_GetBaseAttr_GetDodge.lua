local Module = require("third.module.Module")
local RoleModule_GetBaseAttr_GetDodge = class("RoleModule_GetBaseAttr_GetDodge", Module)

function RoleModule_GetBaseAttr_GetDodge:ctor()
    self._name = "RoleModule_GetBaseAttr_GetDodge"
end

function RoleModule_GetBaseAttr_GetDodge.getBaseAttr(module, self, attrName)
    if attrName == "dodge" then
        -- 只获取基础的数值，不添加其他加成
        local skillLv, factor = self:getSkillLvAndFactor("qinggong", "dodge")

        -- 基础躲闪力  闪躲力 = (轻功等效技能等级 * 0.012 * 轻功闪躲系数 + 10 + 0.2 * 玩家经验^0.5) * (1.6 + 0.01 * 等效身法)
        local baseValue = (skillLv * 0.012 * factor + 10 + 0.2 * self:getExp() ^ 0.5) * (1.6 + 0.01 * self:getEffectDex())

        return true, baseValue
    end
    return false
end


function RoleModule_GetBaseAttr_GetDodge:getBuffAttr(target, attrName)
    if attrName ~= "dodge" then
        return 0
    end

	--神兵特性
	local addDodge = 0
	local equipWeapon = target:getEquipByName("weapon")
	if equipWeapon ~= nil and equipWeapon ~="拳脚" then
		local weapen = target:getOneItemByKey(equipWeapon.itemId)
		if weapen ~= nil then
			addDodge = Helper:getDef(ShenBingEffct:getWeaponExtraDodge(weapen,target),0)
		end
	end

    local fistFootAddValue = 0
	if equipWeapon == nil or equipWeapon == "拳脚" then
		local FightRoleFistFootEffect = require("src.app.models.fight.FightRoleFistFootEffect")
		fistFootAddValue = FightRoleFistFootEffect:getDodgeBuffsValue(target)
	end

    return addDodge + fistFootAddValue
end

return RoleModule_GetBaseAttr_GetDodge
00