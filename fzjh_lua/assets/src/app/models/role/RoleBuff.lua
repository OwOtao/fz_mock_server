local RoleBuff = {}

function RoleBuff:create()
	local p = clone(RoleBuff)
	p:init()
	return p
end

function RoleBuff:init()
	-- 所有的增益菜村
	self._buffs =
	{
		
	}
	
	-- 属性加成 add by TangJian 2017/04/25 22:00:52
	self._attrBuff = {}
end


----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @author TangJian --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @time 2017/04/27 17:38:09 -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @desc 更新增益 -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/04/27 17:24:18
-- @desc 更新装备增益
function RoleBuff:updateEquipBuff(role)
	local roleEquipBuff = require("script.npc.npcEquipBuff")
	local equipBuffMap = roleEquipBuff[role.AttrModifyId]
	-- local equipBuffMap = roleEquipBuff["zhang"]
	if equipBuffMap then
		if role and role.equips then
			local equipBuffTotal = {}
			
			for k, equip in pairs(role.equips) do
				local equipBuff = equipBuffMap[equip.itemId]
				
				if equipBuff then
					for k, v in pairs(equipBuff) do
						if equipBuffTotal[k] == nil then
							equipBuffTotal[k] = v
						else
							if type(v) == "number" then
								equipBuffTotal[k] = equipBuffTotal[k] + v
							end
						end
					end
				end
			end
			self._buffs["equipBuff"] =
			{
				type = "attrBuff",
				body = equipBuffTotal
			}
		end
	end
end

function RoleBuff:updateZouxueshisijingBuff(role)
	local XingZhenEffects = require("app.models.XingZhenEffects.XingZhenEffects")
	local zouxueshisijingBuffTotal = XingZhenEffects:getXingZhenMap(role)

	self._buffs["zouxueshisijingBuff"] =
	{
		type = "attrBuff",
		body = zouxueshisijingBuffTotal
	}
end

-- 更新经脉增益
function RoleBuff:updateMeridianBuff(role)
	-- 攻击力加成 atk
	-- 躲闪力加成 dodge
	-- 防御力加成 def
	-- 伤害力加成 damage
	-- 防护力加成 protect
	-- 内力上限 neiLiLimit
	-- 气血最大值 qiMax
	-- 根骨 secCon
	-- 悟性 secInt
	-- 身法 secDex
	-- 福缘 luck
	local Meridian = require("app.models.Meridian.Meridian")
	local meridian = role:getAttr("meridian")

	local meridianBuffTotal = {}
	
	if MapIsEmpty(meridian.attrTotal) ~= true then
		Meridian:countGuBenAttrTotal(role)
		for k, v in pairs(meridian.attrTotal) do
			meridianBuffTotal[k] = v
		end
	end
	-- self._buffs["meridianBuff"] =
	-- {
	--     type = "attrBuff",
	--     body = meridianBuffTotal
	-- }
	-- 经脉印记加成
	local meridianImprintingAttrBuff = Meridian:countImprintingAttrTotal(role)
	self._buffs["meridianImprintingBuff"] =
	{
		type = "attrBuff",
		body = meridianImprintingAttrBuff
	}
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2018/06/12 00:54:51
-- @params 
-- @desc 特性增益
-- @desc target 战斗中对方角色
function RoleBuff:updateTraitBuff(role, target)
	local RoleTrait = require("app.models.HomelandModel.RoleTrait")
	local traitBuff = RoleTrait:calceRole(role, target)
	self._buffs["traitBuff"] =
	{
		type = "attrBuff",
		body = traitBuff
	}
end

-- @desc 入梦buff
function RoleBuff:updateAsleepBuff(role)
	local DreamAsleepBuff = require("app.models.DreamWorldModel.DreamAsleepBuff")
	local buffMap = DreamAsleepBuff:getAsleepBuffMap(role)

	self._buffs["AsleepBuff"] =
	{
		type = "attrBuff",
		body = buffMap
	}
end



----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @author TangJian --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @time 2017/04/27 17:37:03 -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @desc 确认增益 -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/04/27 17:25:08
-- @desc 提交属性增益
function RoleBuff:confirmAttrBuff()
	local totalAttrBuff = {}
	
	for k, buff in pairs(self._buffs) do
		if buff.type == "attrBuff" then
			for k, v in pairs(buff.body) do
				if totalAttrBuff[k] == nil then
					totalAttrBuff[k] = v
				else
					if type(v) == "number" then
						totalAttrBuff[k] = totalAttrBuff[k] + v
					end
				end
			end
		end
	end
	
	self._attrBuff = totalAttrBuff
end


----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @author TangJian --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @time 2017/04/27 17:34:58 -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @desc 更新增益模块 -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/04/27 17:22:38
-- @desc 刷新增益
function RoleBuff:updateAllBuff(role,target)
	self:updateEquipBuff(role)
	self:updateMeridianBuff(role)
	self:updateTraitBuff(role,target)
	self:updateZouxueshisijingBuff(role)
	self:updateAsleepBuff(role)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/04/27 17:26:36
-- @desc 确认所有增益
function RoleBuff:confirmAllBuff(role)
	self:confirmAttrBuff(role)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/04/27 17:27:37
-- @desc 刷新roleBuff
function RoleBuff:update(role,target)
	self:updateAllBuff(role,target)
	self:confirmAllBuff(role)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/04/27 17:23:02
-- @desc 得到属性增益
function RoleBuff:getAttr(attrName, attrValue)
	if self._attrBuff[attrName] then
		return self._attrBuff[attrName]
	end
	return 0
end

return RoleBuff
00