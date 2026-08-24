local ShenBingDuanZao = {}
local godweapon = require("script.others.godweapon")
local ShenBingDuanZaoSkills = require("app.models.ShenBing.ShenBingDuanZaoSkills")
local LimitConfig = require("script.others.godweaponhold")["Sheet1"]
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/16 11:58:37
-- @desc 锻造炉中投放的材料可锻造的所有武器以及所对应的锻造知识
function ShenBingDuanZao:getAllFurnaceByItem(itemProperty)
	assert(type(itemProperty) == "table","ShenBingDuanZao:getAllFurnaceByItem itemProperty = "..tostring(itemProperty)..","..type(itemProperty))
	-- assert(Item:getOneItemByKey(itemId),"ShenBingDuanZao:getAllFurnaceByItem，itemId = "..tostring(itemId))
	local items = {}
	assert(itemProperty.forgingknow and itemProperty.weapontype1)
	local forgingidList,forgingweaponList = string.split(itemProperty.forgingknow,","),string.split(itemProperty.weapontype1,",")
	assert(#forgingidList == #forgingweaponList,"知识个数与武器个数不相等")
	for k,forgingknow in pairs(forgingidList) do
		items[k] = {
			forgingknow = forgingknow,
			weapontype1 = forgingweaponList[k]
		}
	end
	return items
end
--
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/16 12:02:30
-- @desc 判断是否学习该武器的锻造之术
function ShenBingDuanZao:checkCanMakeShenBing(role,allFurnaceList)
	if PRINT_MODE == 1 then
		-- print("--------------------判断是否学习该武器的锻造之术-------------------：",type(role),allFurnaceList,type(allFurnaceList))
	end
	assert(role and type(allFurnaceList) == "table","ShenBingDuanZao:checkCanMakeShenBing")
	local knowledgeList = self:getAllForgeKnowledge()
	for i = #allFurnaceList,1,-1 do
		--删除没有学会对应锻造之术的武器
		if knowledgeList[allFurnaceList[i].forgingknow] ~= true then
			table.remove(allFurnaceList,i)
		end
	end
	return allFurnaceList
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/01/05 18:20:09
-- @desc 将任务学习过的锻造知识转换成map
function ShenBingDuanZao:getAllForgeKnowledge()
	local rtab = {}
	local knowledgeList = ForgeSkill:getUserFoegeKnowledge()
	for forgeId,knowledges in pairs(knowledgeList) do 
		for k,knowledge in pairs(knowledges) do 
			rtab[knowledge] = true
		end
	end
	return rtab
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/16 14:26:10
-- @desc 判断材料是否可以锻造
function ShenBingDuanZao:checkItemCanFurnace(itemId)
	assert(type(itemId) == "string","ShenBingDuanZao:checkItemCanFurnace itemId = "..tostring(itemId))
	local itemFurnaceList = assert(godweapon["itemOfFurnaceWeaponType"])
	for k,itemProperty in pairs(itemFurnaceList) do
		if itemProperty.itemid1 == itemId then
			return true ,itemProperty
		end
	end
	return false,{}
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/16 14:55:37
-- @desc 获取材料可锻造物品并且已经学习对应的锻造知识的所有武器
function ShenBingDuanZao:getAllLearnFurnaceByItem(itemId,role)
	assert(Item:getOneItemByKey(itemId),"不存在itemId为"..tostring(itemId).."的物品")
	role = Helper:getDef(role,User:getRole())
	local canMake,itemProperty = self:checkItemCanFurnace(itemId)
	-- Helper:print_lua_table(itemProperty)
	local furnaceList = {}--可锻造列表
	if canMake == false then
		return furnaceList
	end
	local allFurnaceList = self:getAllFurnaceByItem(itemProperty)
	-- Helper:print_lua_table(allFurnaceList)
	furnaceList = self:checkCanMakeShenBing(role,allFurnaceList)
	return furnaceList
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/16 16:55:01
-- @desc 获取锻造的武器的基本属性
function ShenBingDuanZao:getShenBingFurnaceProperty(itemId,weaponType)
	assert(type(itemId) == "string" and weaponType,"ShenBingDuanZao:getShenBingFurnaceProperty itemId = "..tostring(itemId)..",weaponType = "..tostring(weaponType))
	local itemFurnaceList = assert(godweapon["itemOfFurnaceInfo"])
	for k,itemProperty in pairs(itemFurnaceList) do
		if itemProperty.itemid == itemId and itemProperty.forgingweapon == weaponType  then
			-- Helper:print_lua_table(itemProperty)
			return itemProperty
		end
	end
	assert(nil)
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/18 09:43:51
-- @desc 获取材料的熔炼值，增温度已经适用范围
function ShenBingDuanZao:getItemmelting(itemId)
	assert(type(itemId) == "string","ShenBingDuanZao:getItemmelting itemId = "..tostring(itemId))
	local itemList = assert(godweapon["temperatureItems"],"ShenBingDuanZao:getItemmelting 策划资源缺少 增温材料")
	for k,itemmel in pairs(itemList) do 
		if itemmel.itemid == itemId then
			local itemmelting = assert(tonumber(itemmel.itemmelting),"增温材料表中 itemid = "..tostring(itemId).."未填写itemmelting字段")
			local temperature = assert(tonumber(itemmel.temperature),"增温材料表中 itemid = "..tostring(itemId).."未填写temperature字段")
			-- print("--------------------------------",itemmel.application)
			local application = string.split(assert(itemmel.application,"增温材料表中 itemid = "..tostring(itemId).."未填写application字段"),";")
			assert(#application == 2 ,"增温材料，itemId = " ..tostring(itemId).."application填写的数值有问题,策划检查")
			return {itemmelting = itemmelting,temperature = temperature,upTemp = tonumber(application[2]),downTemp = tonumber(application[1])}
		end
	end
	return nil
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/18 10:19:46
-- @desc 检测材料是否可以熔炼
function ShenBingDuanZao:checkItemCanSmelt(item,temperature)
	assert(type(item) == "table" and type(temperature) == "table" ,"ShenBingDuanZao:checkItemCanSmelt 参数类型有错，type(item)= "..tostring(type(item))..",type(temperature) = "..tostring(temperature))
	if item.downTemp ==nil or item.upTemp == nil then
		return false
	end
	if item.downTemp <= temperature and item.upTemp >= temperature then
		return true
	end
end


-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/19 16:50:14
-- @desc 过滤掉背包中穿在身上的装备
function ShenBingDuanZao:deleteEquipItem(items)
	assert(type(items) == "table","ShenBingDuanZao:deleteEquipItem items = "..type(items))
	local equips = clone(User:getRole():getAttr("equips"))
	local tmpItems = clone(items)
	-- Helper:print_lua_table(tmpItems)
	for i=#tmpItems,1,-1 do 
		for k = #equips,1,-1 do 
			if equips[k].itemId == tmpItems[i].itemId then
				table.remove(tmpItems,i)
				table.remove(equips,k)
				if MapIsEmpty(equips) == true then
					return tmpItems
				end
			end
		end
	end
	return tmpItems
end


-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/19 14:55:31
-- @desc 熔炼结果

function ShenBingDuanZao:getRongLianResult(smelt,extraSmelt)
-- K=math.min(math.floor(锻造技术等级/50+(熔炼值+额外熔炼值)/8)+10,100)

	assert(type(smelt) == "number" and type(extraSmelt) == "number","ShenBingDuanZao:getRongLianResult smelt,extraSmelt= "..type(smelt)..","..type(extraSmelt))
	local forgeSkillLv = User:getRole():getSkillLv("duanzaozhishu")
	if forgeSkillLv == 0 then 
		assert(nil,"异常，可能是作弊")
	end
	return math.min(math.floor(forgeSkillLv / 50 + (smelt + extraSmelt)/8) + 10,100)

end


-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/19 18:23:48
-- @desc 获取熔炼物品的熔炼属性
function ShenBingDuanZao:getItemRongLianInfo(itemId)
	assert(type(itemId) == "string","ShenBingDuanZao:getItemRongLianInfo itemId= "..type(itemId))
	local infoList = assert(godweapon["rongLianItems"])
	for k,itemDate in pairs(infoList) do 
		if itemDate.itemid == itemId then
			return itemDate
		end
	end
	return {meltingfail = "rongliianshibai1"}
	-- assert(nil,"熔炼物品表中没有"..itemId.."的信息")
end


-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/19 18:29:39
-- @desc 计算熔炼值
function ShenBingDuanZao:getItemSmelt(temperature,melPoint)
	assert(temperature and tonumber(melPoint))
	-- print("------------------------temperature---------melPoint----------",temperature,melPoint,temperature/melPoint*250)
	return temperature/melPoint*250
end
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/19 15:04:55
-- @desc 锻打随机变化属性
function ShenBingDuanZao:getRandomDuanDaResult(result)

	local text = {
		["yindu"] = "硬度值",
		["rendu"] = "韧度值",
		["effctNum"] = "特性值",
	}
	assert(type(result) == "number","锻打随机变化属性 result = "..type(result))
	local weight = nil
	if result < 50 then
		weight = {[1] = 60,[2] = 25,[3] = 10,[4] = 5,[5] = 0}
	elseif result >= 50 and result < 70 then
		weight = {[1] = 45,[2] = 25,[3] = 15,[4] = 10,[5] = 5}
	elseif result >= 70 and result < 80 then
		weight = {[1] = 40,[2] = 20,[3] = 18,[4] = 12,[5] = 10}
	elseif result >= 80 and result < 95 then
		weight = {[1] = 15,[2] = 15,[3] = 20,[4] = 15,[5] = 35}
		
	elseif  result >= 95 and result < 100 then
		weight = {[1] = 10,[2] = 10,[3] = 15,[4] = 25,[5] = 40}
	elseif result == 100 then	
		weight = {[1] = 0,[2] = 5,[3] = 20,[4] = 30,[5] = 45}
	else
		assert(nil)
	end
	local random = Helper:RandomByWeight(weight)
	if DEBUG_MODE == 1 then
		print("-------------------------------神兵锻造随机等级-------------------------------------",random)
	end
	local resultTab = {
		[1] = {
			yindu = math.random(1,3),
			rendu = math.random(1,3),
			effctNum = math.random(1,2)
		},
		[2] = {
			yindu = math.random(2,4),
			rendu = math.random(2,4),
			effctNum = math.random(2,4)
		},
		[3] = {
			yindu = math.random(4,8),
			rendu = math.random(4,8),
			effctNum = math.random(3,6)
		},
		[4] = {
			yindu = math.random(7,12),
			rendu = math.random(7,12),
			effctNum = math.random(5,9)
		},
		[5] = {
			yindu = math.random(10,15),
			rendu = math.random(10,15),
			effctNum = math.random(8,12) 
		}
	}
	return resultTab[random],random
end


-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/20 11:00:35
-- @desc  生成装备硬度,坚韧度,重量,特性值描述  desc
function ShenBingDuanZao:setWeapenDesc(weapen)
	assert(type(weapen) == "table")
	local descList = assert(godweapon["weaponDesc"])
	local ydDesc,jrDesc,zlDesc,txDesc = "","","",""
	for k,desc in pairs(descList) do 
		if desc.weapontype2 == weapen.bType then
			--硬度
			local hardList = string.split(assert(desc.hard),",")
			assert(#hardList == 2,"硬度:"..desc.hard) 
			if weapen.yindu >= tonumber(hardList[1]) and weapen.yindu <= tonumber(hardList[2]) then
				ydDesc = desc.harddsc
			end

			--坚韧度
			local hardList = string.split(assert(desc.Tenacity),",")
			assert(#hardList == 2,"坚韧度:"..desc.Tenacity) 
			if weapen.rendu >= tonumber(hardList[1]) and weapen.rendu <= tonumber(hardList[2]) then
				jrDesc = desc.Tenacitydsc
			end

			--重量
			local hardList = string.split(assert(desc.weight1),",")
			assert(#hardList == 2,"重量:"..desc.weight1) 
			if weapen.weight >= tonumber(hardList[1]) and weapen.weight <= tonumber(hardList[2]) then
				zlDesc = desc.weight1dsc
			end

			--特性值
			local hardList = string.split(assert(desc.Characteristic),",")
			assert(#hardList == 2,"特性值:"..desc.Characteristic) 
			if weapen.effctNum >= tonumber(hardList[1]) and weapen.effctNum <= tonumber(hardList[2]) then
				txDesc = desc.Characteristicdsc
			end
		end
	end
	-- local desc = ydDesc..","..jrDesc..","..zlDesc..""
	return ydDesc,jrDesc,zlDesc,txDesc
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/20 15:14:49
-- @desc 生成装备卸下的描述
	-- equipDesc = "", 		-- 装备描述
	-- getoffDesc
function ShenBingDuanZao:getequipDescAndGetOffDesc(weapen)
	assert(type(weapen) == "table" and weapen.type)
	local descList = assert(godweapon["weaponTakeOffDesc"])
	local typeList = {}
	for k,desc in pairs(descList) do 
		if desc.equipmenttype == weapen.type then
			table.insert(typeList,desc)
		end
	end
	local random = math.random(1,#typeList)
	-- descList.Weardes = string.gsub(descList.Weardes,"$N",User:getRole():getName())				
	-- descList.Weardes = string.gsub(descList.Weardes,"$N",weapen.name)	
	-- descList.Takedes = string.gsub(descList.Takedes,"$N",User:getRole():getName())				
	-- descList.Takedes = string.gsub(descList.Takedes,"$N",weapen.name)
	return typeList[random]
end


-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/20 17:56:37
-- @desc 武器锻造等级 skillLv,smelt,extraSmelt  锻造技术等级，熔炼值，额外熔炼值
function ShenBingDuanZao:getWeapenForgeLv(skillLv,smelt,extraSmelt)
	-- return math.min(math.floor(skillLv/50+(smelt+extraSmelt)/8)+10,100)
	return math.min(math.floor(skillLv/50+smelt*3/20+extraSmelt/20),100)
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/20 17:59:23
-- @desc 武器特性值

function ShenBingDuanZao:getWeapenEffctNum(weapen,skillLv,smelt,extraSmelt)
	print("武器特性值:","weapen.effctNum:",weapen.effctNum,"skillLv:",skillLv,"smelt:",smelt,"extraSmelt:",extraSmelt)
	local weapenForgeLv = math.floor(self:getWeapenForgeLv(skillLv,smelt,extraSmelt)/10)
	print("weapenForgeLv：",weapenForgeLv)
	return weapenForgeLv + weapen.effctNum
end


function ShenBingDuanZao:getWeaponDamage(weapon,skillLv)
	assert(weapon and type(skillLv) == "number")
	-- math.min(math.floor(*1.2),120)+材料带来的伤害力+模板基础伤害力（读表
	-- print("----------------------------------------------")
	return math.min(math.floor(skillLv * 1.2),120) + weapon.damage

end
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/20 18:11:29
-- @desc 获取特效
function ShenBingDuanZao:getWeapenSpecialId(weapon)
	assert(type(weapon) == "table")
	local effctNum,weapenType = weapon.effctNum,weapon.bType
	effctNum = Helper:getDef(effctNum,0)
	local key = nil
	if effctNum < 100 then
		effctNum = 0
		key = "effct1"
	elseif effctNum >= 100 and effctNum < 200 then
		effctNum = 100
		key = "effct2"
	elseif effctNum >= 200 then
		effctNum = 200
		key = "effct3"
	end
	local specialList = assert(godweapon["weaponSpecials"])
	for k,list in pairs(specialList) do 
		if list.weapontype == weapenType and effctNum == list.specialget then
			return list.specialid,key,list.name
		end
	end
end


-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/22 17:39:02
-- @desc 领取神兵
function ShenBingDuanZao:getNewShenBingWeapen(weapen)
	assert(weapen)
	local role = User:getRole()
	local shenBingItems = Helper:getDef(role:getAttr("shenBingItems"),{})
	table.insert(shenBingItems,weapen)
	role:setShenBingItems(shenBingItems)
end


-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/22 18:01:17
-- @desc 修改神兵状态
function ShenBingDuanZao:setShenBingStateInShenBingItems(id,state)
	assert(id and type(state) == "number")
	local role = User:getRole()
	local shenBingItems = Helper:getDef(role:getAttr("shenBingItems"),{})
	if MapIsEmpty(shenBingItems) == true then
		if DEBUG_MODE == 1 then
			print("******************shenBingItems中没有id为*********************************:",id)
		end
		return 
	end
	self:updateShenBingInfo({status = state,id = id},role)
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/22 18:13:04
-- @desc 获取未领取的神兵
function ShenBingDuanZao:getShenBingWeapenUnreceive()
	local role = User:getRole()
	local shenBingItems = Helper:getDef(role:getAttr("shenBingItems"),{})
	for k,weapen in pairs(shenBingItems) do 
		if weapen.status ~= 3 then
			return weapen
		end
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/26 14:40:33
-- @desc 判断背包是否可以添加神兵
function ShenBingDuanZao:checkBagCanAddShenBing()
	local role = User:getRole()
	local items = role:getItems()
	local count = 0
	for k, itemData in pairs(items) do 
		if itemData.type == "神兵" then
			count = count + 1
		end
	end

	if count < role:getAttr("bagShenBingNumLimit") then
		return true
	end

	return false
end


-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/26 18:07:12
-- @desc 增加锻造之术的经验
function ShenBingDuanZao:addFurnaceSkillExp(exp,type)
	ShenBingDuanZaoSkills:addDuanZaoExp(exp,type)
end


-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/26 18:10:08
-- @desc 锻造增加锻造之术经验   result 锻造成功还是失败
-- @desc 家园锻造：
--	锻造成功获得经验=math.floor(锻造技能等级^1.5+1500+(管家忠诚度等级+1)^2*30)
-- 	锻造失败获得经验=math.min(锻造技能等级*2.5,1200+管家忠诚度等级*50)
function ShenBingDuanZao:addFurnaceSkillExpByDuanZao(result,isHomeLandDZ,gjZcLv)
    result = Helper:getDef(result, true)
    --@RefType [app.models.role.Role#Role]
    local role = User:getRole()
	
    local exp = 0
	local upLv = 0
	
	local MAX_ROLE_SKILL_EXP = role:conversionSkillExpAndLv("exp", role:getSkillLvLimit("duanzaozhishu"))

    local todayExp = role:getDayFlag("duanzao")
    if todayExp < DUANZAO_EXP_MAX_DAY then
        local skillLv = role:getSkillLv("duanzaozhishu")
        if skillLv == nil then
            return
		end

		local nowExp = role:getSkillExp("duanzaozhishu")

        if result then
			if isHomeLandDZ == true and type(gjZcLv) == "number" then
				exp = math.floor(skillLv^1.5+1500+(gjZcLv+1)^2*30)
			else
				exp = math.floor((skillLv ^ 1.5)  + 1500)
			end
        else
			if isHomeLandDZ == true and type(gjZcLv) == "number" then
				exp = math.min(skillLv*2.5,1200+gjZcLv*50)
			else
				exp = math.min(skillLv * 2, 1200)
			end
		end
		
		if exp + nowExp > MAX_ROLE_SKILL_EXP then
			exp = MAX_ROLE_SKILL_EXP - nowExp
		end

        if todayExp + exp > DUANZAO_EXP_MAX_DAY then
            exp = DUANZAO_EXP_MAX_DAY - todayExp
		end
		
		local newLv = role:conversionSkillExpAndLv("lv",nowExp + exp)

		role:setDayFlag("duanzao", todayExp + exp)
		
		role.skills["duanzaozhishu"] = {id = "duanzaozhishu",exp = nowExp + exp}
        if  newLv - skillLv > 0  then
			upLv = newLv - skillLv 
		end
    end

    return exp , upLv
end


-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/26 18:17:54
-- @desc 熔炼增加锻造之术经验   result 锻造成功还是失败
function ShenBingDuanZao:addFurnaceSkillExpByRongLian(result)
	result = Helper:getDef(result,true)
	
	--@RefType [app.models.role.Role#Role]
	local role = User:getRole()
	local todayExp = role:getDayFlag("ronglian")

	local exp = 0
	local MAX_ROLE_SKILL_EXP = role:conversionSkillExpAndLv("exp", role:getSkillLvLimit("duanzaozhishu"))
	local upLv = 0

	if todayExp < RONGLIAN_EXP_MAX_DAY then
		local skillLv = role:getSkillLv("duanzaozhishu")

		if skillLv == nil then
			return
		end

		local nowExp = role:getSkillExp("duanzaozhishu")
		exp = math.min(skillLv*2+10,60)

		if exp + nowExp > MAX_ROLE_SKILL_EXP then
			exp = MAX_ROLE_SKILL_EXP - nowExp
		end

		if todayExp + exp > RONGLIAN_EXP_MAX_DAY then
			exp = RONGLIAN_EXP_MAX_DAY - todayExp
		end
		role:setDayFlag("ronglian",todayExp + exp)

		local newLv = role:conversionSkillExpAndLv("lv",nowExp + exp)

		role.skills["duanzaozhishu"] = {id = "duanzaozhishu",exp = nowExp + exp}

		if  newLv - skillLv > 0  then
			upLv = newLv - skillLv 
		end

	end

	return exp , upLv
end


-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/27 14:50:45
-- @desc  删除神兵 return true 删除成功,false 删除失败
function ShenBingDuanZao:deleteShenBingWeaponById(itemId)
	assert(type(itemId) == "string")
	--@RefType [app.models.role.Role#Role]
	local role = User:getRole()
	local shenBingItems = role:getAttr("shenBingItems")
	if MapIsEmpty(shenBingItems) == true then
		return false
	end
	for k, weapon in pairs(shenBingItems) do 
		if weapon.id == itemId then
			table.remove(shenBingItems,k)
			if role._shenbingCache and role._shenbingCache[itemId] then
				role._shenbingCache[itemId] = nil
			end
			return true
		end
	end
	return false
end

local commands = -- 字体颜色改变格式
    {
        RED =
        {
            id = "RED",
            type = "颜色",
            color = cc.c3b(219, 57, 57)
        },
        GRN =
        {
            id = "GRN",
            type = "颜色",
            color = cc.c3b(51, 153, 51)
        },
        YEL =
        {
            id = "YEL",
            type = "颜色",
            color = cc.c3b(175, 145, 25)
        },
        BLU =
        {
            id = "BLU",
            type = "颜色",
            color = cc.c3b(28, 76, 163)
        },
        MAG =
        {
            id = "MAG",
            type = "颜色",
            color = cc.c3b(153, 51, 153)
        },
        CYN =
        {
            id = "CYN",
            type = "颜色",
            color = cc.c3b(102, 153, 153)
        },
        WHT =
        {
            id = "WHT",
            type = "颜色",
            color = cc.c3b(159, 159, 159)
        },
        PNK = --粉色
        {
            id = "PNK",
            type = "颜色",
            color = cc.c3b(255, 128, 192)
        },
        HIR =
        {
            id = "HIR",
            type = "颜色",
            color = cc.c3b(241, 16, 16)
        },
        HIG =
        {
            id = "HIG",
            type = "颜色",
            color = cc.c3b(88, 244, 117)
        },
        HIY =
        {
            id = "HIY",
            type = "颜色",
            color = cc.c3b(246, 244, 80)
        },
        HIB =
        {
            id = "HIB",
            type = "颜色",
            color = cc.c3b(11, 128, 246)
        },
        HIM =
        {
            id = "HIM",
            type = "颜色",
            color = cc.c3b(204, 51, 204)
        },
        HIC =
        {
            id = "HIC",
            type = "颜色",
            color = cc.c3b(80, 246, 244)
        },
        HIW =
        {
            id = "HIW",
            type = "颜色",
            color = cc.c3b(255, 255, 255)
        },
        RAN =
        {
            id = "RAN",
            type = "颜色",
            color = cc.c3b(255, 255, 255)
        },
        NOR =
        {
            id = "NOR",
            type = "结束符",
        },
        LUC =
        {
            id = "LUC",
            type = "颜色",
            color = cc.c3b(159, 159, 159),
            opacity = 0
        },
        DWT =
        {
            id = "DWT",
            type = "颜色",
            color = cc.c3b(208, 208, 208),
        },
        GLD = -- 中立门派颜色
        {
            id = "GLD",
            type = "颜色",
            color = cc.c3b(255, 165, 0),
        },
        ORA =
        {
            id = "ORA",
            type = "颜色",
            color = cc.c3b(190, 170, 130),
        },
        DEO =
        {
            id = "DEO",
            type = "颜色",
            color = cc.c3b(28, 76, 163),
        },
        YELL =
        {
            id = "YELL",
            type = "颜色",
            color = cc.c3b(219, 187, 57),
        },
        ORN = {
            id = "ORN",
            type = "颜色",
            color = cc.c3b(236, 101, 26),
        },
        CRO =   
        {
            id = "CLO",
            type = "颜色",
            color = cc.c3b(190, 170, 130),
        },
    }

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/01/13 10:28:39
-- @desc 更新神兵信息
function ShenBingDuanZao:updateShenBingInfo(weapon,role)
	assert(type(weapon) == "table")
	role = Helper:getDef(role,User:getRole())
	if role == User:getRole() then
		print("-------------------------------------")
	end
	local shenBingItems = role:getAttr("shenBingItems")
	local storageWeaponData = role:getOneItemByKey(weapon.id)

	--TODO updateData理论上为纯更新数据，目前有值为item类对象，后续需要替换
	if storageWeaponData == weapon then
		weapon = clone(weapon)
	end

	for k,shenbing in pairs(shenBingItems) do 
		if shenbing.id == weapon.id then
			--shenBingItems中保存的数据才会更新
			for key ,value in pairs(shenbing) do
				if weapon[key] ~= nil then
					if weapon[key]=="nil" then 
						shenbing[key]=""
						storageWeaponData[key] =""
					else
						shenbing[key] = weapon[key]
						storageWeaponData[key] = weapon[key]
					end
					
					if key == "name" or key == "nameColor" then
						for command,list in pairs(commands) do 
							shenbing.name = string.gsub(shenbing.name,list.id,"")
						end
						storageWeaponData.name = shenbing.nameColor..shenbing.name.."NOR"
					end
				end
			end
			break
		end
	end
	role:setShenBingItems(shenBingItems)
end


--获取神兵基本信息
function ShenBingDuanZao:getWeaponBaseInfo(itemId)
	local shenBingItems = User:getRole():getAttr("shenBingItems")
	for k,shenbing in pairs(shenBingItems) do 
		if shenbing.id == itemId then
			return shenbing
		end
	end
	return nil
end


 --将老神兵转换成新神兵
 function ShenBingDuanZao:transOldShenBingToNewShenBing()
	local role = User:getRole()
	if role.shenBingweapon == nil or MapIsEmpty(role.shenBingweapon) then
		return
	end


	local weapon = {
		id = "weapon_defaultId", 	-- 必须唯一
		name = "",		-- 名字 
		type = "刀",	-- 武器类型
		bType = "长刀",
		wpType = "神兵", 	-- 类型 (用于区分神兵和普通兵器)
		damage = 0,		-- 伤害值
		yindu = 0, 		-- 硬度值
		rendu = 0, 		-- 韧度值
		weight = 0,		-- 重量值
		effctNum = 0,	-- 特性值 (计算得出,到达一定值可开启特效)
		wanhaodu = 100,	-- 完好度 (损坏完好度为0, 修理后耐久度修复,完好度根据计算得出)
		effct1 = "",		-- 特效1
		effct2 = "",		-- 特效2
		effct3 = "",		-- 特效3 (暂定三个特效,特效效果读取资源配置表)
		cuilianitems = {},  -- 加工使用的物品列表 {itemid = count}
		useNeiLi = 0,		-- 注入的内力值
		desc = "",			-- 武器的描述,在第一次载入的时候计算生成(生成规则查看策划案)
		equipDescId = "",	--装备描述与拖下描述 的Id
		getoffDesc = "", 		-- 拖下描述
		weaponLookId = "",
		status = 0, 		-- 铸造状态 0 铸造中,1 铸造完成未取名,2 铸造完成已取名
		canEquip = 1 ,		-- 可装备
		cuilianCount = 0  ,  -- 淬炼成功次数
		cuilianFailedCount = 0  , -- 淬炼失败次数
		--- 预备属性 (不知要以后会不会要用,建议保存记录到本地,并且定期上传至服务器)
		duanzaoitems = {},	-- 锻造使用的物品列表 {itemid = count}
		cuilian = {}	-- 淬炼统计,列表,每次淬炼记录一条 {xlType = "欧冶子", itemid = "", cost = 500, result = "success"}

	}
	local transBaseList = {
		["刀"] = {
			baseItem = "duanzaocailiao2",
			forgingweapon = "长刀",
		},
		["剑"] = {
			baseItem = "duanzaocailiao2",
			forgingweapon = "长剑",
		},
		["棍"] = {
			baseItem = "duanzaocailiao2",
			forgingweapon = "长棍",
		},

		["鞭"] = {
			baseItem = "duanzaocailiao2",
			forgingweapon = "长鞭",
		},
	}
	if role.shenBingweapon.id == nil then
		-- print("----------------------1----------------------")
	elseif role.shenBingweapon.id == "" then
		-- print("----------------------2----------------------")
	else
		-- print("----------------------3----------------------",role.shenBingweapon.id,type(role.shenBingweapon.id))
	end
	if role.shenBingweapon.id ~= nil and role.shenBingweapon.type ~= nil then
		local list = assert(transBaseList[role.shenBingweapon.type])
		weapon.type = role.shenBingweapon.type
		weapon.name = role.shenBingweapon.name
		weapon.bType = list.forgingweapon
		weapon.id = "weapon_"..tostring(Helper:getDef(User:getRole():getAttr("forgeCount"),0))
		User:getRole():addAttr("forgeCount",1)
		local base = self:getShenBingFurnaceProperty(list.baseItem,list.forgingweapon)
		weapon.damage = Helper:getDef(base.Forgingdamage,0) + math.max(Helper:getDef(role.shenBingweapon.damage,10),10)	-- 伤害值
		weapon.yindu = Helper:getDef(base.Forginghardness,0)		-- 硬度值
		weapon.rendu = Helper:getDef(base.Forgingtoughness,0) 		-- 韧度值
		weapon.weight = Helper:getDef(base.Forgingweight,0)	-- 重量值
		weapon.effctNum = Helper:getDef(tonumber(base.Forgingcharacteristics),0) + (role.shenBingweapon.damage/10) -- 特性值
		weapon.nameColor = Helper:getDef(base.Forgingcolor,"WHT")
		weapon.typeDesc = Helper:getDef(base.Forgingdsc,"")
		weapon.weaponLookId = ""
		weapon.cuilianCount = 0
		weapon.wanhaodu = 100
		weapon.cuilianFailedCount = 0   -- 淬炼失败次数
		--- 预备属性 (不知要以后会不会要用,建议保存记录到本地,并且定期上传至服务器)
		weapon.duanzaoitems = {}	-- 锻造使用的物品列表 {itemid = count}
		weapon.cuilian = {}	-- 淬炼统计,列表,每次淬炼记录一条 {xlType = "欧冶子", itemid = "", cost = 500, result = "success"}
		if weapon.name == nil or weapon.name == "" then
			weapon.name = weapon.bType
		end
		for k,v in pairs(commands) do 
			weapon.name = string.gsub(weapon.name,v.id,"")
		end

		--穿上脱下描述
		local descList = ShenBingDesc:getRandomWeaponWeardes(weapon)
		--特效1
		local specialId,key = self:getWeapenSpecialId(weapon)
		if key ~= nil then
			weapon[key] = specialId
		end
		assert(descList)
		weapon.equipDescId = descList.desid
		weapon.desc = ShenBingDesc:getShenBingDesc(weapon)
		weapon.status = 3
		--如果此时使用的武器是神兵则需要把神兵拿下来
		if User:getRole():checkItemIsEquipbyItemId("神兵") == true then
			User:getRole():setEquipByName("weapon",nil)
		end
		if role.shenBingweapon.status == "1" then
			HttpManagerEx:uploadClientData("xuanbingdong",{itemId = weapon.id}, function(status, errcode, errmsg, data)
				if status == 200 then
					if errcode == 0 then 
						--成功之后扣除神兵
						local items = role:getItems()
						for k,item in ipairs(items) do 
							if item.itemId == "神兵" then
								table.remove(items,k)
								break
							end
						end
						role:setAttr("items",items)
						role.shenBingweapon.id = nil
						self:getNewShenBingWeapen(weapon)
					else
						PopText(errmsg)
					end
					return true
				else
					PopText(errmsg)
				end
			end, IS_SHOW_WAITING,HTTP_MANAGER_RETRY_TYPE_RETRY)	
		elseif role.shenBingweapon.status == "2" then
			local items = role:getItems()
			for k,item in ipairs(items) do 
				if item.itemId == "神兵" then
					table.remove(items,k)
					break
				end
			end
			role:setAttr("items",items)	
			role.shenBingweapon.id = nil
			self:getNewShenBingWeapen(weapon)
			role:addItemCount(weapon.id,1)
		end
	else
		return
	end
 end

 -----------------------------------------------------------------------------------------------------------
 -- @author GaoHanZheng
 -- @time 2018/02/08 18:53:45
 -- @desc 上传数据至玄兵洞
function ShenBingDuanZao:updateDataToXuanBingDong(itemId,weapon,items)
	HttpManagerEx:uploadClientData("xuanbingdong",{itemId = itemId,info = weapon}, function(status, errcode, errmsg, data)
		if status == 200 then
			if errcode == 0 then 
				table.remove(items,1)
			 	if items[1] ~= nil then
			 		self:updateDataToXuanBingDong(items[1].id,items[1],items)
			 	end
			else
				PopText(errmsg)
			end
			return true
		else
			PopText(errmsg)
		end
	end, IS_SHOW_WAITING,HTTP_MANAGER_RETRY_TYPE_RETRY)
end

-----------------------------------------------------------------------------------------------------------
--------------------------------神兵持有上限----------------------------------------------------------------
local currencyType = {
	["0"] = "免费",
	["1"] = "碎银",
	["2"] = "元宝",
}

function ShenBingDuanZao:upgradeShenBingLimit(role, func)
	local currLimit = role:getAttr("shenBingNumLimit")
	if self:checkCanUpgradeShenBingLimit(currLimit) == false then
		PopText("当前可拥有神兵数量已达最大升级上限")
		return
	end

	local currLevel = self:getShenBingLevelByLimit(currLimit)
	local afterLevel = currLevel + 1

	HttpManagerEx:upgradeUserBag(5,afterLevel,function(status, errcode, errmsg, data)
        if status == 200 and errcode == 0 then
            if MapIsEmpty(data) == false then
                local afterSpace = self:getShenBingLimitByLevel(afterLevel)

                if data.count > 0 then
                    PopText("消耗"..tostring(data.count)..currencyType[tostring(data.currency)]..",神兵可拥有数量成功升级到"..afterSpace.."把")
                end

                --碎银
                if data.currency == 1 then
                    role:addAttr("money", -data.count)
                end

                role:setAttr("shenBingNumLimit", afterSpace)

                if func then
                    func()
                end
            end
        else
            PopText(errmsg)
        end
    end,IS_SHOW_WAITING)
end

function ShenBingDuanZao:getShenBingLevelByLimit(limit)
	assert(limit,"ShenBingDuanZao:getShenBingLevelByLimit limit is null")

	if MapIsEmpty(LimitConfig) == false then
        for i, v in pairs(LimitConfig) do
            if tonumber(v.bagcount) == limit then
                return tonumber(v.id)
            end
        end
    end
end

function ShenBingDuanZao:getShenBingLimitByLevel(level)
	assert(level,"ShenBingDuanZao:getShenBingLimitByLevel level is null")

	if MapIsEmpty(LimitConfig) == false then
        for i, v in pairs(LimitConfig) do
            if tonumber(v.id) == level then
                return tonumber(v.bagcount)
            end
        end
    end
end

function ShenBingDuanZao:getShenBingUpgradeCostByLevel(level)
	assert(level,"ShenBingDuanZao:getShenBingUpgradeCostByLevel level is null")

    if MapIsEmpty(LimitConfig) == false then
        for i, v in pairs(LimitConfig) do
            if tonumber(v.id) == level then
                return v.count, currencyType[tostring(v.currency)]
            end
        end
        error("当前神兵携带上限异常："..tostring(limit))
    end
end

function ShenBingDuanZao:checkCanUpgradeShenBingLimit(limit)
	assert(limit,"ShenBingDuanZao:checkCanUpgradeShenBingLimit limit is null")
	
	if MapIsEmpty(LimitConfig) == false then
        for i, v in pairs(LimitConfig) do
            if tonumber(v.bagcount) > limit then
                return true
            end
        end
    end

	return false
end


return ShenBingDuanZao00