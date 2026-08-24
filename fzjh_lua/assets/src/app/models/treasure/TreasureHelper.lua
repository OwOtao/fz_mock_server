local TreasureHelper = {}
local TreasureList = require("script.others.Treasure")
--分割字符串
local function stringSplit(str,split)
	assert(type(str) == "string",str)
	assert(type(split) == "string",split)
	return string.split(str,split)
end

--获取玩家技能等级
local function getRoleSkillLv(role,list)
	assert(role)
	assert(type(list) == "table")
	for k,v in pairs(list) do 
		local skill = role:getSkill(v)
		if skill ~= nil then
			return k,role:getSkillLv(v),v
		end
	end
	return nil,nil,nil
end
--获取技能的区间
local function getSkillSection(num,list,lv)
	assert(type(list) == "table")
	assert(type(num) == "number")
	local str = Helper:getDef(list.section,"")
	local skill_S = stringSplit(str,";")[num]
	local section = stringSplit(skill_S,",")
	-- local skill_W = stringSplit(str,";")[num]
	local rlist = {}
	local function getWeightNumber(number1,number2,str)
		assert(type(number1) == "number")
		assert(type(number2) == "number")
		assert(type(str) == "string")
		local number_S = stringSplit(str,";")[number1]
		return stringSplit(number_S,",")[number2]
	end
	for k,v in pairs(section) do
		local sectionList = stringSplit(v,"-")
		if #sectionList ~= 2 then
			assert(nil)
		end
		if  lv >= tonumber(sectionList[1]) and  lv <= tonumber(sectionList[2]) then
			for i=1,7 do 
				-- table.insert(list,getWeightNumber(num,k,v["SkilltypeWeight"..tostring(i)]))
				print(list["SkilltypeWeight"..tostring(i)])
				if list["SkilltypeWeight"..tostring(i)] ~= nil then
					rlist[i] = getWeightNumber(num,k,list["SkilltypeWeight"..tostring(i)])
				else
					-- list[i] = -1 
				end
			end
			return tonumber(sectionList[1]),tonumber(sectionList[2]),rlist
		end

	end
	print("-----------------------------没有找到合适的技能-----------------------------")
	return 0,0,nil
end
--生成技能的权重
local function getSkillWeight(num,lv,list)
	assert(type(num) == "number")
	assert(type(list) == "table")
	local down,up,tab = getSkillSection(num,list,lv)
	return {down = down,up = up ,weight = tab}
end





--初始化
function TreasureHelper:init(mapId,baoZangInfo)
	if PRINT_MODE == 1 then
		print("=====================function TreasureHelper:init=========================:",mapId)
	end
	assert(type(mapId) == "string","生成权重列表时mapId错误")
	-- local xinxiList = TreasureList["宝藏信息"]
	local weightList = {}
	if self.weigthList == nil then
		self.weigthList = {}
	end
	self.weigthList[mapId] = nil
	-- for k,v in pairs(xinxiList) do 
	-- 	if v.copyId == mapId then
	-- 		assert(type(v.skill) == "string","TreasureList 表中未配置skill"..tostring(mapId))

	-- 	end
	-- end
	print("---------`````````````````````````````````",baoZangInfo.skill)
	if baoZangInfo.skill == nil then
		return
	end
	local num,lv ,skillId= getRoleSkillLv(User:getRole(),stringSplit(baoZangInfo.skill,";"))
	if num == nil or lv == nil then

	else
		weightList[skillId] = getSkillWeight(num,lv,baoZangInfo)
	end
	self.weigthList[mapId] = weightList
	-- return self.weigthList
end
--是否需要重新生成
function TreasureHelper:checkNeedInit(mapId, baoZangInfo)
	if self.weigthList == nil or self.weigthList[mapId] == nil then
		return true
	else
	end

	local num,lv ,skillId= getRoleSkillLv(User:getRole(),stringSplit(baoZangInfo.skill,";"))
	if skillId == nil then
		return false
	elseif self.weigthList[mapId][skillId] == nil then
		return true
	else
		if lv >= self.weigthList[mapId][skillId].down and lv <= self.weigthList[mapId][skillId].up then
			return false
		end
	end
	return false
end

--获取权重列表
function TreasureHelper:getWeightList(mapId, baoZangInfo,weightList)
	-- if self.weigthList == nil or self.weigthList[mapId] == nil then
	-- 	return self:init(mapId)[mapId]
	-- else
		-- local lv = User
		if self:checkNeedInit(mapId, baoZangInfo) == false then
		else
			self:init(mapId,baoZangInfo)
		end
		if MapIsEmpty(self.weigthList[mapId]) == false then  
			-- return Helper:tableCover(weightList,self.weigthList[mapId])
			for k,v in pairs(self.weigthList[mapId]) do 
				if MapIsEmpty(v.weight) == false then
					return Helper:tableCover(weightList,v.weight)
				else
					return weightList
				end
			end
		else
			return weightList
		end
		-- return self.weigthList[mapId]
	-- end
end


function TreasureHelper:getWaBaoReward(func)
	local longevity = {
		[1] = {
			itemId = "changshengjueshengji2",
			flag = "长生诀2"
		},
		[2] = {
			itemId = "changshengjueshengji3",
			flag = "长生诀3"
		},
		[3] = {
			itemId = "changshengjueshengji4",
			flag = "长生诀4"
		},
		[4] = {
			itemId = "changshengjueshengji5",
			flag = "长生诀5"
		}
	}
	local role = User:getRole()
	for i = #longevity,1,-1 do 
		if role:getInheritFlag(longevity[i].flag) ~= 0 then
			table.remove(longevity,i)
		end
	end
	print("-----------------------------第一步处理---------------------------------------")
	Helper:print_lua_table(longevity)
	local skillLv = nil 
	local reward = nil
	local skillList = {"changshengjue","changshengjueyang","changshengjueyin"}
	for k,skillId in pairs(skillList) do 
		local lv = role:getSkillLv(skillId)
		if lv ~= 0 then
			skillLv = lv
		end
	end
	if skillLv == nil then
		--没有长生诀
		print("----------------------------没有长生诀-----------------------------------")
		reward = longevity[math.random(1,#longevity)]
		Helper:print_lua_table(reward)
	else
		if MapIsEmpty(longevity) == true then
			-- reward = {itemId = arg1}
			print("--------------------------------------奖励列表中的长生居都已经获得------------------------------")
			if func then
				func()
				return
			end
		else
			print("----------------------------获得奖励列表中的第一个奖励-------------------------------")
			reward = longevity[1]
		end
	end
	--书页不需要判断背包空间
	print("------------------------发放奖励--------------------------------------",MapIsEmpty(reward))
	Helper:print_lua_table(reward)
	if MapIsEmpty(reward) == false then
		role:addItemCount(reward.itemId,1)
		role:setInheritFlag(reward.flag,1)
		RichPrint("main","你搜索这尸体，竟从其怀中搜出一块图谱，上绘奇怪纹路，经久不腐，十分不凡。")
	end
end

return TreasureHelper00000000000000