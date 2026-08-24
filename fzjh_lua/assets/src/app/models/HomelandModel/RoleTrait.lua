-- add by XiaoZhiWei 2018/06/11 22:31:13 角色特性处理模版
local RoleTrait = {
	cacheData = {},		-- add by XiaoZhiWei 2018/06/11 22:38:05 用于做数据缓存
}

--[[
	对外接口
		calceRole

	需考虑的情况
		特性加成会不会有相互叠加的情况加 例: 特性1加臂力  特性2加百分比攻击力
]]

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2018/06/11 22:31:58
-- @params role 需要计算的角色  addList = {addKey = addValue ,... } 用于方法体外做加成计算
-- @desc 计算角色的特性加成 true 代表有加成, false 代表没有加成
function RoleTrait:calceRole(role, target)
	local retMap = {}
	if MapIsEmpty(role) == true then
		print("111111111111111111")
		return retMap
	end

	local traitList = self:getTraitList(role)
	if MapIsEmpty(traitList) == true then
		return retMap
	else
		-- print("333333333333333 name = ",role.name)


		-- Helper:print_lua_table(traitList)
	end

	-- add by XiaoZhiWei 2018/06/19 22:27:59 遍历所有特性
	for i,traitId in ipairs(traitList) do
		local info = self:getTraitInfo(traitId)
		if self:checkTraitCanUsed(info, role, target) ~= true then
			-- print("333333333333333333333333333333333333")
		else
			local retEffect = self:getRoleTraitResult(traitId, role.id)
			-- add by XiaoZhiWei 2018/06/19 22:28:10 判断是否存在缓存的特性效果,百分比的特性每次进来都重新计算
			--@desc 相同类型特性可用有多个，效果叠加，百分比同样叠加。
			if info.CharacteristicType == "百分比" or MapIsEmpty(retEffect) == true then
				local list = self:calcTraitEffect(role,info)
				for k,v in pairs(list) do
					if retMap[k] ~= nil then
						retMap[k] = retMap[k] + v
					else
						retMap[k] = v
					end
				end

				-- retMap = table.mergeMap(retMap, self:calcTraitEffect(role, info))
			else
				for k,v in pairs(retEffect) do
					if retMap[k] ~= nil then
						retMap[k] = retMap[k] + v
					else
						retMap[k] = v
					end
				end
				-- retMap = table.mergeMap(retMap, retEffect)
			end
		end
	end
	return retMap
end


-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2018/06/11 22:43:20
-- @params 
-- @desc 获取人物的特性列表
function RoleTrait:getTraitList(role)
	local retList = {}
	for i=1, 3 do
		if role["trait"..tostring(i)] ~= nil then
			table.insert(retList, role["trait"..tostring(i)])
		else
			break
		end
	end
	return retList
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2018/06/11 22:46:23
-- @params 
-- @desc 获取单个特性的属性
function RoleTrait:getTraitInfo(traitId)
	local ret = {}
	if traitId == nil then
		return ret
	end
	local resource = requireWithEncrypt("script.others.familyspecial").trait
	-- local resource = {texing001 = {id = "texing001", texingCode = "qiMax", Characteristic = "气血上限变化", attributeValue = 1000}}
	return resource[traitId]
end	

local changeMap = {
	[1] = "qiMax",						--气血上限增加
	[2] = "neiliMax",						--内力上限增加
	[3] = "atk",							--攻击力增加
	[4] = "def",							--防御力增加
	[5] = "dodge",						--闪躲力增加
	[6] = "parry",						--招架力增加
	[7] = "secCon",						--根骨增加
	[8] = "secStr",						--臂力增加
	[9] = "secDex",						--身法增加
	[10] = "jiaLi",						--加力增加
	[11] = "atk",							--对阵侠义值小于0的对手时，攻击提高
	[12] = "atk",							--对阵侠义值大于0的对手时，攻击提高
	[13] = "damage",						--伤害力提高
	[14] = "atk;def",						--对阵拿武器的对手时，攻击和防御提高
	[15] = "atk;def",						--对阵空手的对手时，攻击和防御提高
	-- [16] = "atk;def",						--气血低于30%时，攻击和防御提高
	[17] = "atk",							--对阵容貌低于自己的对手时，攻击提高
	-- [18] = "atk",							--忠诚度每提高20点，攻击力也提高一定数值
	[19] = "looks",						--容貌提高
	[21] = "fidelityAddByChat",				--每次闲聊获得忠诚度增加
	[22] = "fidelityRateByChat",				--每次闲聊仆人获得的忠诚度概率增加
	[25] = "fidelityAddByReward",				--每次赏赐仆人获得的忠诚度增加
	[28] = "firstComeInItemsAdd",			--每日进入房屋有一定概率获得物品（填概率）
	[29] = "firstRandomComeInmoneyAdd",			--每日进入房屋有一定概率获得金钱
	[30] = "firstComeInmoneyAdd",			--每日进入房屋必获得碎银（填金额）
	[31] = "qiecuoMoneyReduce",			--切磋结束后，敌人会丢失一定碎银
	[33] = "shangciItemProbobility",		--赏赐时概率获得道具
	[34] = "firstCoomInRoomFindChapman",		--每日第一次进入房屋可在对应房屋寻找到黑市商人
	[35] = "passiveFight",              --不会与入侵者主动战斗
	[36] = "firstXianliaoDushuExp",		--每次闲聊小几率获得一定的读书识字经验
	[37] = "yanduTimeLimitAdd",			--提高书童研读时间上限
	[38] = "dushuExpAdd",					--每秒获得的读书识字经验增加
	[39] = "yanduExpAdd",					--每秒研读的书籍经验增加
	[40] = "zhicuoCostReduce",			--制作消耗降低
	[41] = "spchanliangAdd",			--提高重复饰品处理产量
	[42] = "zhaoliaoCDReduce",			--降低照料功能CD
	[43] = "tianpuchanliangAdd",			--提高田圃产量
	[44] = "zhongzichushouPriceReduce",	--出售种子价钱降低
	[45] = "firstXianliaoDuanzaoExp",		--每次闲聊小几率获得一定锻造经验。
	[46] = "duanzaoLv",					--提高铁匠锻造等级
	[47] = "jiagongPriceReduce",			--神兵加工费用降低
	[48] = "cuilianPriceReduce",			--神兵淬炼费用降低
	[49] = "chushouPriceReduce",			--出售材料价格降低
	[50] = "dabaoNumAdd",					--打包数量提高
	[51] = "zuofanCDReduce",				--做饭冷却时间缩短
	[52] = "shiheTimeSub",				--食盒持续时间增加
	[53] = "daniaoCDReduce",				--完成树林打鸟时间缩短
	[54] = "xipanziCDReduce",				--完成酒馆洗盘子时间缩短
	[55] = "feizeiCDReduce",				--完成飞贼横行时间缩短
	[56] = "nanyangCDReduce",				--完成南阳匪乱时间缩短
	[57] = "songxinCDReduce",				--完成江湖送信时间缩短
	[58] = "etuCDReduce",					--完成缉拿恶徒时间缩短
	[59] = "gusiCDReduce",				--完成古寺失窃时间缩短
	[60] = "firstChatliaoExp",			--每次闲聊小几率获得一定的人物经验值
	[61] = "mkGrowthSpeed",				--门客成长度增加
	[62] = "jibenquanjiaoLv",				--基本拳脚等级提高
	[63] = "jibenjianfaLv",				--基本剑法等级提高
	[64] = "jibendaofaLv",				--基本刀法等级提高
	[65] = "jibenanqiLv",					--基本暗器等级提高
	[66] = "jibengunfaLv",				--基本棍法等级提高
	[67] = "jibenbianfaLv",				--基本鞭法等级提高
	[68] = "damage",						--对金钱超过1000万的玩家造成额外伤害
	[69] = "firstComeInItemsReduce",	--每日进入房屋有一定概率丢失物品
}

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2018/06/20 00:37:27
-- @params 
-- @desc 检查特性是否能够触发
function RoleTrait:checkTraitCanUsed(traitInfo, role, target)
	local result = false
	if MapIsEmpty(traitInfo) == true or MapIsEmpty(role) == true then
		return result
	end

	result = switch(traitInfo.type, {
		[1] = true,							--气血上限增加
		[2] = true,							--内力上限增加
		[3] = true,							--攻击力增加
		[4] = true,							--防御力增加
		[5] = true,							--闪躲力增加
		[6] = true,							--招架力增加
		[7] = true,							--根骨增加
		[8] = true,							--臂力增加
		[9] = true,							--身法增加
		[10] = true,							--加力增加
		[11] = function()						--对阵侠义值小于0的对手时，攻击提高
			if MapIsEmpty(target) == true or target:getFinalAttr("zhengqi") >= 0 then
				return false
			end
			return true
		end,							
		[12] = function()						--对阵侠义值大于0的对手时，攻击提高
			if MapIsEmpty(target) == true or target:getFinalAttr("zhengqi") <= 0 then
				return false
			end
			return true
		end,							
		[13] = true,							--伤害力提高
		[14] = function()						--对阵拿武器的对手时，攻击和防御提高
			if MapIsEmpty(target) == true or target:getCurrWeaponType() == "拳脚" then
				return false
			end
			return true
		end,						
		[15] = function()						--对阵空手的对手时，攻击和防御提高
			if MapIsEmpty(target) == true or target:getCurrWeaponType() ~= "拳脚" then
				return false
			end
			return true
		end,						
		-- [16] = function()						--气血低于30%时，攻击和防御提高
		-- 	if MapIsEmpty(role) == true or role:getFinalAttr("qiPercent") >= 0.3 then
		-- 		return false
		-- 	end
		-- 	return true
		-- end,						
		[17] = function()						--对阵容貌低于自己的对手时，攻击提高
			if MapIsEmpty(target) == true or target:getFinalAttr("looks") >= role:getFinalAttr("looks") then
				return false
			end
			return true
		end,							
		-- [18] = "atk",							--忠诚度每提高20点，攻击力也提高一定数值
		[19] = true,							--容貌提高
		[20] = false,							--
		[21] = true,							--每次闲聊仆人获得的忠诚度增加
		[22] = true,							--每次闲聊仆人获得的忠诚度概率增加
		[25] = true,							--每次赏赐仆人获得的忠诚度增加
		[28] = true,							--每日进入房屋有一定概率获得物品（填概率）
		[29] = true,							--每日进入房屋有一定概率获得金钱
		[30] = true,							--每日进入房屋必获得碎银（填金额）
		[31] = true,							--切磋结束后，敌人会丢失一定碎银
		[33] = true,							--赏赐时概率获得道具
		[34] = true,		                    --每日第一次进入房屋可在对应房屋寻找到黑市商人
		[35] = true,              				--不会与入侵者主动战斗
		[36] = true,							--每次闲聊小几率获得一定的读书识字经验
		[37] = true,							--提高书童研读时间上限
		[38] = true,							--每秒获得的读书识字经验增加
		[39] = true,							--每秒研读的书籍经验增加
		[40] = true,							--制作消耗降低
		[41] = true,							--提高重复饰品处理产量
		[42] = true,							--降低照料功能CD
		[43] = true,							--提高田圃产量
		[44] = true,							--出售种子价钱降低
		[45] = true,							--每次闲聊小几率获得一定锻造经验。
		[46] = true,							--提高铁匠锻造等级
		[47] = true,							--神兵加工费用降低
		[48] = true,							--神兵淬炼费用降低
		[49] = true,							--出售材料价格降低
		[50] = true,							--打包数量提高
		[51] = true,							--做饭冷却时间缩短
		[52] = true,							--食盒持续时间增加
		[53] = true,							--完成树林打鸟时间缩短
		[54] = true,							--完成酒馆洗盘子时间缩短
		[55] = true,							--完成飞贼横行时间缩短
		[56] = true,							--完成南阳匪乱时间缩短
		[57] = true,							--完成江湖送信时间缩短
		[58] = true,							--完成缉拿恶徒时间缩短
		[59] = true,							--完成古寺失窃时间缩短
		[60] = true,							--每次闲聊小几率获得一定的人物经验值
		[61] = true,							--门客成长度增加
		[62] = true,							--基本拳脚等级提高
		[63] = true,							--基本剑法等级提高
		[64] = true,							--基本刀法等级提高
		[65] = true,							--基本暗器等级提高
		[66] = true,							--基本棍法等级提高
		[67] = true,							--基本鞭法等级提高
		[68] = function()						--对金钱超过1000万的玩家造成额外伤害
			if MapIsEmpty(target) == true or target:getFinalAttr("money") <= 10000000 then
				return false
			end
			return true
		end,
		[69] = true,							--每日进入房屋有一定概率丢失物品						
	})

	print(traitInfo.type, result)
	if target then
		print(target:getCurrWeaponType())
	end

	return result
end


-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2018/06/11 22:50:49
-- @params 
-- @desc 计算属性结果
function RoleTrait:calcTraitEffect(role, traitInfo)
	local result = nil
	if MapIsEmpty(role) == true or MapIsEmpty(traitInfo) == true or traitInfo.type == nil then
		return result
	end

	local traitValue = Helper:getDef(traitInfo.CharacteristicValue, 0)
	local ret = {}
	do
		if changeMap[traitInfo.type] ~= nil then
			local list = string.split(changeMap[traitInfo.type], ";")
			for k,texingCode in pairs(list) do
				ret[texingCode] = traitValue
				if traitInfo.CharacteristicType == "百分比" then
					local value = switch(texingCode, {
						atk = function()
							return role:getAtk(true)
						end,
						def = function()
							return role:getDef(true)
						end,
						dodge = function()
							return role:getDodge(true)
						end,
						parry = function()
							return role:getParry(true)
						end,
						damage = function()
							return role:getPowerDamage(true)
						end,
						default = function()
							return Helper:getDef(role:getAttr(texingCode), 1)
						end
					})
					value = value * (traitValue / 100) -- add by XiaoZhiWei 2018/06/19 22:50:01 百分比计算
					ret[texingCode] = value
				end
			end
		else
			error("无用的效果,需要和程序定义. traitId = "..tostring(traitInfo.id))
		end
	end
	self:setRoleTraitResult(role.id, traitInfo.id, ret)
	return ret
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2018/06/11 23:22:33
-- @params 
-- @desc 缓存已计算的特性
function RoleTrait:setRoleTraitResult(roleId, traitId, retMap)
	if roleId == nil or traitId == nil or MapIsEmpty(retMap) == true then
		return
	end
	self.cacheData = Helper:getDef(self.cacheData, {})
	self.cacheData[roleId] = Helper:getDef(self.cacheData[roleId], {})
	self.cacheData[roleId][traitId] = retMap
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2018/06/11 23:26:17
-- @params 
-- @desc 获取缓存的特性
function RoleTrait:getRoleTraitResult(traitId, roleId)
	if roleId == nil or traitId == nil then
		return
	end
	self.cacheData = Helper:getDef(self.cacheData, {})
	self.cacheData[roleId] = Helper:getDef(self.cacheData[roleId], {})
	return self.cacheData[roleId][traitId]
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2018/06/19 22:40:07
-- @params 
-- @desc 清空所有缓存的特性
function RoleTrait:clearTraitResult()
	self.cacheData = {}
end

--检查是否有指定类型的特性
--有，返回特性信息
function RoleTrait:checkRoleHaveTraitType(role,traitType)
	if not role or not traitType then
		return false
	end

	local traitList = self:getTraitList(role)
	if MapIsEmpty(traitList) == true then
		return false
	else
		for i,traitId in ipairs(traitList) do
			local info = self:getTraitInfo(traitId)
			if info and info.type == traitType then
				return true,info
			end
		end
	end
end

return RoleTrait000000000