local ShenBingDesc = {}
local textMap = {}
local knowledgeList ={}
--一些属性的文本
local godweapon = require("script.others.godweapon")
function ShenBingDesc:init()
	if MapIsEmpty(textMap) == false then
		return
	end
	local TextList = godweapon["weaponDesc"]
	for k,texts in pairs(TextList) do 
		if textMap[texts.weapontype2] == nil then
			textMap[texts.weapontype2] = {}
		end
		--硬度
		if textMap[texts.weapontype2].yindu == nil then
			textMap[texts.weapontype2].yindu = {}
		end

		--韧性
		if textMap[texts.weapontype2].rendu == nil then
			textMap[texts.weapontype2].rendu = {}
		end

		--重量
		if textMap[texts.weapontype2].weight == nil then
			textMap[texts.weapontype2].weight = {}
		end

		-- --特性
		-- if textMap[texts.weapontype2].effect == nil then
		-- 	textMap[texts.weapontype2].effect = {}
		-- end
		local keyList = {weight = "weight1",yindu = "hard1",rendu = "Tenacity1"}
		for key,textKey in pairs(keyList) do 
			local list = string.split(texts[textKey],";")
			local descList = {
				down = Helper:getDef(tonumber(list[1]),0),
				up = Helper:getDef(tonumber(list[2]),100000),
				[textKey.."dsc"] = texts[textKey.."dsc"],
				[textKey.."level"] = texts[textKey.."level"],
				[textKey.."text"] = texts[textKey.."text"],
			}
			table.insert(textMap[texts.weapontype2][key],descList)
		end
	end
    --特性
	if textMap["effect"] == nil then
		textMap["effect"] = {}
	end
	local effectList = godweapon["weaponSpecials"]
	for k,effect in pairs(effectList) do 
		local tab = {
			name = effect.name,
			specialdsc = effect.specialdsc,
			weapontype = effect.weapontype,
			specialtext = effect.specialtext, 
			specialnumber = effect.specialnumber,  
			value = effect.value, 
			formula = effect.formula, 
			specialget = effect.specialget,
			specialid = effect.specialid,
		}
		textMap["effect"][effect.specialid] = tab
	end

	--拔剑脱下描述
	local descList = godweapon["weaponTakeOffDesc"]
	local tab,count = {},0
	for k, desc in pairs(descList) do 
		if textMap[desc.equipmenttype] == nil then
			textMap[desc.equipmenttype] = {}
		end
		if textMap[desc.equipmenttype].Weardes == nil then
			textMap[desc.equipmenttype].Weardes = {}
			textMap[desc.equipmenttype].Weardes.descMap = {}
			textMap[desc.equipmenttype].Weardes.count = 0
		end
		textMap[desc.equipmenttype].Weardes.descMap[desc.desid] = desc
		textMap[desc.equipmenttype].Weardes.count = textMap[desc.equipmenttype].Weardes.count + 1
	end

	-- 物品锻造  知识点对应武器 
	local duanzaoList =  assert(godweapon["itemOfFurnaceWeaponType"])
	-- local knowledgeAll = {}  --读配置 锻造对应的 全部知识点   和配置中  武器一一对应 
    -- local weaponAll = {}     --读配置 锻造对应的 全部武器 （中文名） 如 长剑,短剑,软剑,重剑,长刀  
	if textMap.knowledgeList == nil then
		textMap.knowledgeList ={}
	end
	for id,duanzao in pairs(duanzaoList) do
		-- print("duanzaoList      id"..id)
		textMap.knowledgeList[tonumber(id)] ={}
		textMap.knowledgeList[tonumber(id)].itemname1 = duanzao.itemname1
		textMap.knowledgeList[tonumber(id)].knowledgeAll =  string.split(Helper:getDef(duanzao.forgingknow," ") ,",")
		textMap.knowledgeList[tonumber(id)].weaponAll =  string.split(Helper:getDef(duanzao.weapontype1," ") ,",")
		-- print("duanzaoList      itemname1",textMap.knowledgeList[tonumber(id)].itemname1,duanzao.itemname1)
	end
    -- Helper:print_lua_table(textMap.knowledgeList)
	--初始外观描述
	local lookList = godweapon["weaponAppearanceDesc"]
	-- textMap["剑"].look ={}
	-- textMap["刀"].look ={}
	-- textMap["棍"].look ={}
	-- textMap["鞭"].look ={}
	-- local mytype ={
	-- 	"剑",
	-- 	"刀",
	-- 	"棍",
	-- 	"鞭",
	-- }
	local facade = {}
	for k,list in pairs(lookList) do 
		local tab = {
			["剑"] = list.weapontype1,
			["刀"] = list.weapontype2,
			["棍"] = list.weapontype3,
			["鞭"] = list.weapontype4,
			["双持"] = list.weapontype5,
			["乐器"] = list.weapontype6,
			["暗器"] = list.weapontype7,
		}
		facade[list.weaponid] = tab
	end
	textMap.facade = facade

	-- for k, desc in pairs(lookList) do 
	
	-- 	for i, typ in pairs(mytype) do 
	-- 		if textMap[desc.equipmenttype].descMap == nil then
	-- 			textMap[typ].look.descMap = {}
	-- 			textMap[typ].look.count = 0
	-- 		end	
	-- 		textMap[typ].look.descMap["weaponLookId"] = desc.weaponid
	-- 		textMap[typ].look.descMap["baseLook"] = desc["weapontype"..i]
	-- 		textMap[typ].look.count = textMap[typ].look.count+1
	-- 	end
	-- end
	DataBase:setLuaTable("ShenBingMap", textMap)
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/01/15 12:18:59
-- @desc 获取武器外观描述
function ShenBingDesc:getWeaponFacade(weapon)
	assert(type(weapon) == "table" and type(weapon.type) == "string")
	if type(weapon.weaponLookId) == nil or weapon.weaponLookId == "" then
		return "暂无描述"
	end
	local facadeList = assert(textMap.facade)
	return assert(facadeList[weapon.weaponLookId][weapon.type])
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/01/23 14:26:25
-- @desc 随机获取新的武器外观描述
function ShenBingDesc:getRandomWeaponFacade(weapon)
	assert(type(weapon) == "table" and type(weapon.type) == "string")
	local randomList = {}
	local facadeList = assert(textMap.facade)
	for facadeId, list in pairs(facadeList) do 
		if weapon.weaponLookId ~= facadeId then
			table.insert(randomList,facadeId)
		end
	end
	local random = math.random(1,#randomList)
	-- print("---------------------------------------:",randomList[random])
	return randomList[random]
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/25 15:58:26
-- @desc 获取描述
function ShenBingDesc:getDesc(key,keyVlaue,weaponType)
	assert(textMap[weaponType],"没有此类型的兵器，检查神兵的type类型:"..weaponType)
	assert(textMap[weaponType][key],"没有这个属性"..key)
	assert(keyVlaue >= 0,"keyVlaue不能存在负值")
	for k,descList in pairs(textMap[weaponType][key]) do 
		if descList.up >= keyVlaue and descList.down < keyVlaue then
			return descList
		end
	end
end

--@desc: 获取重量相关描述
--@author:Liang SongQiang
--@time:2017-12-22 11:59:05
function ShenBingDesc:getWeightDesc(weapon,role)
	assert(weapon and weapon.type and weapon.weight)
	local tmp = Item:getOneItemByKey(weapon.id)
	role = Helper:getDef(role,User:getRole())
	local weight = weapon.weight
	if MapIsEmpty(tmp) == false and tmp.id == weapon.id then
		weight = tmp:getWeaponWeight(role)
	end
	if DEBUG_MODE == 1 then
		print("------------重量：",weight)
	end
	
	-- print("---------------getWeightDesc------------------",weight,weapon.type,self:getDesc("weight",weight,weapon.type))
	return self:getDesc("weight",weight,weapon.type)
end

--@desc: 获取硬度相关描述
--@author:Liang SongQiang
--@time:2017-12-22 11:59:58
function ShenBingDesc:getYingDuDesc(weapon,role)
	assert(weapon and weapon.type and weapon.yindu)
	local tmp = Item:getOneItemByKey(weapon.id)
	role = Helper:getDef(role,User:getRole())
	local yindu = weapon.yindu
	if MapIsEmpty(tmp) == false and tmp.id == weapon.id then
		yindu = tmp:getWeaponYingDu(role)
	end
	if DEBUG_MODE == 1 then
		print("------------硬度：",yindu)
	end
	-- print("---------------getYingDuDesc------------------",yindu,weapon.type,self:getDesc("yindu",yindu,weapon.type))
	return self:getDesc("yindu",yindu,weapon.type)
end

--@desc: 获取坚韧度描述
--@author:Liang SongQiang
--@time:2017-12-22 14:14:49
function ShenBingDesc:getRenDuDesc(weapon,role)
	assert(weapon and weapon.type and weapon.rendu)
	local tmp = Item:getOneItemByKey(weapon.id)
	role = Helper:getDef(role,User:getRole())
	local rendu = weapon.rendu
	if MapIsEmpty(tmp) == false and tmp.id == weapon.id then
		rendu = tmp:getWeaponRenDu(role)
	end
	if DEBUG_MODE == 1 then
		print("------------坚韧度：",rendu)
	end
	-- print("---------------getRenDuDesc------------------",rendu,weapon.type,self:getDesc("rendu",rendu,weapon.type))
	return self:getDesc("rendu",rendu,weapon.type)
end


--@desc: 特性描述
--@author:Liang SongQiang
--@time:2017-12-22 15:23:57
function ShenBingDesc:getEffctText(weapon)
	local r = require("script.others.godweapon") ["weaponSpecials"]
	assert(type(weapon) == "table")
	local strArr = {}
	for i = 1, 10 do
		if weapon["effct" .. tostring(i)] ~= nil and weapon["effct" .. tostring(i)] ~= "" then
			for k,pecialList in pairs(r) do 
				if pecialList.specialid == weapon["effct" .. tostring(i)] then
					-- print("-------------------------------------",pecialList.specialtext)
					table.insert(strArr, pecialList.specialtext)
					break
				end
			end
		else 
			break
		end
	end
	
	local str = ""
	for i, v in ipairs(strArr) do
		if i == #strArr then
			str = str .. v
		else
			str = str .. v .. ","
		end
	end
	return str
end


-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/25 16:32:05
-- @desc 获取特性一的配置
function ShenBingDesc:getEffctOne(weapon)
	assert(weapon)
	if weapon.effct1 == nil or weapon.effct1 == "" then
		return nil
	end
	return assert(textMap.effect[weapon.effct1])
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/25 16:32:05
-- @desc 获取特性二的配置
function ShenBingDesc:getEffctTwo(weapon)
	assert(weapon)
	if weapon.effct2 == nil or weapon.effct2 == "" then
		return nil
	end
	return assert(textMap.effect[weapon.effct2])
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/25 16:32:05
-- @desc 获取特性三的配置
function ShenBingDesc:getEffctThree(weapon)
	assert(weapon)
	if weapon.effct3 == nil or weapon.effct3 == "" then
		return nil
	end
	return assert(textMap.effect[weapon.effct3])
end



local unitMap = {
	["剑"] = "把",
	["刀"] = "把",
	["棍"] = "根",
	["鞭"] = "根",
}

--@desc: 获取兵器描述
--@author:Liang SongQiang
--@time:2017-12-22 15:09:52
function ShenBingDesc:getShenBingDesc(weapon,isShow)
	local desc = ""
	assert(weapon)
	local list = {
		typeDesc = function()
			return weapon.typeDesc--武器类型描述
		end,
		lookDesc = function()
				local desc = self:getWeaponFacade(weapon)
				if desc == "暂无描述" then
					return ""
				else
					return desc
				end
		end,
		weight = function()
			return self:getWeightDesc(weapon).weight1dsc--重量
		end,
		yindu = function()
			return self:getYingDuDesc(weapon).hard1dsc--硬度
		end,
		rendu = function()
			return self:getRenDuDesc(weapon).Tenacity1dsc--坚韧度
		end,
		effct1 = function()
			local effect = self:getEffctOne(weapon)
			if effect == nil then
				return nil
			else
				return effect.specialtext
			end
		end,
		effct2 = function()
			local effect = self:getEffctTwo(weapon)
			if effect == nil then
				return nil
			else
				return effect.specialtext
			end
		end,
		effct3 = function()
			local effect = self:getEffctThree(weapon)
			if effect == nil then
				return nil
			else
				return effect.specialtext
			end
		end,
	}
	if weapon.wanhaodu == 0 then
		return weapon.typeDesc.."，如今它已经损坏。"
	end
	local getList = {"typeDesc","lookDesc","weight","yindu","rendu","effct1","effct2","effct3"}
	if isShow == true then
		local getList = {"typeDesc","weight","yindu","rendu"}
	end
	local strList = {}
	for k,key in pairs(getList) do 
		local func = list[key]
		local str = func()
		if str ~= nil and str ~= "" then
			table.insert(strList,str)

		end
	end
	for k,str in pairs(strList) do 
		desc = desc .. str
		if k ~= #strList then
			desc = desc .."，"
		else
			desc = desc .."。"
		end
	end
	weapon.desc = desc
	return desc
end

--@desc: 获取神兵状态
--@author:Liang SongQiang
--@time:2017-12-25 15:13:12
function ShenBingDesc:getShenBingStatusDesc(weapon)
	local str = "支离破碎"
	local text = ""
	if weapon.wanhaodu >= 0 and weapon.wanhaodu < 40 then
		str = "支离破碎"
		text = "RED支离破碎：这把兵器已经支离破碎，根本发挥不了多少威力。"
	elseif weapon.wanhaodu >= 40 and weapon.wanhaodu < 80 then
		str = "残缺不全"
		text = "GRN残缺不全：这把兵器残缺不全，发挥不了它之前的力量。"
	elseif weapon.wanhaodu >= 80 and weapon.wanhaodu < 100 then
		str = "略有瑕疵"
		text = "HIB略有瑕疵：这把兵器被修理得有些瑕疵，可能发挥不了它全部的力量。"
	elseif weapon.wanhaodu == 100 then
		str = "完美无缺"
		text = "HIC完美无缺：这把兵器完美无缺，可发挥其全部的威力。"
	elseif weapon.wanhaodu > 100 then
		str = "巧夺天工"
		text = "HIW巧夺天工：这件兵器的制作工艺可算得上是巧夺天工，现可发挥出比原兵器更强的威力。"
	end
	
	return str, text
end


-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/26 11:04:44
-- @desc 获取神兵拔剑文本
function ShenBingDesc:getWeaponEquipText(weapon)
	assert(type(weapon) == "table")
	local Weardes = self:getWeaponWeardes(weapon)
	if Weardes == nil then
		return ""
	end
	local str = Weardes.Weardes
	str = string.gsub(str,"$N",User:getRole():getName())				
	str = string.gsub(str,"$w",weapon.name)	
	return str
end


-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/26 11:08:15
-- @desc 获取收鞘文本
function ShenBingDesc:getWeaponTakeOffText(weapon)
	assert(type(weapon) == "table")
	local Weardes = self:getWeaponWeardes(weapon)
	if Weardes == nil then
		return ""
	end
	local str = Weardes.Takedes
	str = string.gsub(str,"$N",User:getRole():getName())				
	str = string.gsub(str,"$w",weapon.name)	
	return str
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/26 14:04:26
-- @desc 获取当前神兵的拔剑收鞘文本
function ShenBingDesc:getWeaponWeardes(weapon)
	assert(type(weapon) == "table" and weapon.equipDescId ~= nil and weapon.type ~= nil)

	if textMap[weapon.type] ~= nil and textMap[weapon.type].Weardes ~= nil then
		return clone(textMap[weapon.type].Weardes.descMap[weapon.equipDescId])
	else
		return nil
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/26 14:13:01
-- @desc 获取新的拔剑收鞘文本
function ShenBingDesc:getRandomWeaponWeardes(weapon)
	assert(type(weapon) == "table" and weapon.type ~= nil)
	if weapon.equipDescId == nil or weapon.equipDescId == "" then
		-- assert(nil,"初始拔剑文本")
		local BWM = {
	 		["剑"] =  "jianmiaoshu23",
	 		["刀"] =  "daomiaoshu23",
	 		["棍"] =  "gunmiaoshu23",
	 		["鞭"] =  "bianmiaoshu23",
			["双持"] = "shuangchimiaoshu23",
			["乐器"] = "qinmiaoshu23",
            ["暗器"] = "anqimiaoshu23"
		}
		return assert(textMap[weapon.type].Weardes.descMap[BWM[weapon.type]])
	else
		local WeardesList = clone(textMap[weapon.type].Weardes)
		if WeardesList.descMap[weapon.equipDescId] ~= nil then
			WeardesList.descMap[weapon.equipDescId] = nil
			WeardesList.count = WeardesList.count - 1
		end
		local random = math.random(1,WeardesList.count)
		local num = 0
		for k,v in pairs(WeardesList.descMap) do 
			num = num +1 
			if num == random then
				return v
			end
		end
	end
	assert(nil,"未找到")
end

-- 获得新的随机基础外观
function ShenBingDesc:getRandomWeaponLook(weapon)
	assert(type(weapon) == "table" and weapon.type ~= nil)
	local lookList = clone(textMap[weapon.type].look)
	if lookList.descMap[weapon.weaponLookId] ~= nil then
	
		table.remove( lookList.descMap,weapon.weaponLookId )
		lookList.count = lookList.count - 1
	end
	local random = math.random(1,lookList.count)
	local num = 0
	for k,v in pairs(lookList.descMap) do 
		num = num +1 
		if num == random then
			return v.baseLook
		end
	end
	assert(nil,"未找到")
end
function ShenBingDesc:getTextMapAttr(name)
	return textMap[name]
end


function ShenBingDesc:getCollectScore(score)
    local collectScore = ((score + 100) / 12) ^ 1.3

	print("收藏评价 :"..collectScore)
	
    local desc = ""
    if collectScore >= 1 and collectScore <= 1000 then
        desc = "小有斩获"
    elseif collectScore > 1000 and collectScore <= 3000 then
        desc = "什袭而藏"
    elseif collectScore > 3000 and collectScore <= 6000 then
        desc = "琳琅满目"
    elseif collectScore > 6000 and collectScore <= 9000 then
        desc = "洋洋大观"
    elseif collectScore > 9000 and collectScore <= 15000 then
        desc = "武库充实"
    elseif collectScore > 15000 and collectScore <= 30000 then
        desc = "紫电清霜"
    elseif collectScore > 30000 and collectScore <= 50000 then
        desc = "剑胆琴心"
    elseif collectScore > 50000 and collectScore <= 80000 then
        desc = "地负海涵"
    elseif collectScore > 80000 and collectScore <= 100000 then
        desc = "物华天宝"
    elseif collectScore > 100000 then
        desc = "气冲牛斗"
    end

    return desc
end

--获取任务的收藏评价
function ShenBingDesc:getRoleCollectDesc(role)
    role = Helper:getDef(role, User:getRole())
    local collectScore = Helper:getDef(role:getAttr("collectScore"), 0)
    return self:getCollectScore(collectScore)
end

local talkList = {
	"YEL铁匠：珍稀的锻造材料可在江湖中获得，这个还是得看机缘呐。",
	"YEL铁匠：若是寻常材料，在城中铁匠处便能购到了。",
	"YEL铁匠：少侠，欧冶子大师吩咐我，以后跟着你，你有什么需要的直接使唤我便是了。"	
}

--1 自己成功 2 自己失败 3 npc成功 4 npc失败
function ShenBingDesc:getShenBingCuiLianText(resultType) 
	local successByNPCList = {
		{
			"HIC你将兵器与淬炼材料交付给#name#，#name#转过身拿起了材料和铁锤，尝试对兵器进行淬炼。",
			"HIC听着铁锤敲打兵器的声音，你心中略有几分不安，不自主地在屋里踱步。不多时，#name#缓缓转过身来。",
			"YEL#name#：#nickName#且放宽心，淬炼成功了。"
		},
		{
			"HIC你将兵器与淬炼材料交付给#name#，#name#转过身拿起了材料和铁锤，尝试对兵器进行淬炼。",
			"HIC你听着铁锤敲打兵器的声音，心中忐忑不安。突然间，你听到了一阵爽朗的笑声，#name#转过身来。",
			"YEL#name#：哈哈，#nickName#，这淬炼已经成功了，你来看看。"
		}
	}

	local failTextByNPCList = {
		{
			"HIC你将兵器与淬炼材料交付给#name#，#name#转过身拿起了材料和铁锤，尝试对兵器进行淬炼。",
			"听着铁锤敲打兵器的声音，你不由得担心起兵器的情况。不多时，#name#缓缓转过身来。",
			"YEL#name#：唉，这次老夫失手，淬炼已是失败，当真是对不住#nickName#了。"
		},
		{
			"HIC你将兵器与淬炼材料交付给#name#，#name#转过身拿起了材料和铁锤，尝试对兵器进行淬炼。",
			"HIR突然一声爆响从锻造炉中传来！",
			"HIR只见#name#灰头土脸地拿着你的兵器走了出来，本次淬炼失败了。"
		}
	}

	local successTextByMyselfList = {
		{
			"HIC你将武器放置于锻造台上，取出早已准备好的淬炼材料投入火炉之中，又把武器一同加热。",
			"HIC淬炼材料渐渐软化，你抄起铁钳将兵器与材料固定在一起锻打，材料在不断的敲打和高温熔炼之下逐渐与武器融为一体。",
			"HIW不多时，淬炼材料已与武器已经完美地融合在了一起。"
		},	
		{
			"HIC你将武器放置于锻造台上，取出早已准备好的淬炼材料投入火炉之中，又把武器一同加热。",
			"HIC淬炼材料渐渐软化，你抄起铁钳将兵器与材料固定在一起锻打，但这材料始终难以与兵器相融。",
			"HIW你一气之下，将淬炼材料与武器一同丢入炉中煅烧，却没想到，这材料竟自然融入了兵器中。"
		},
		{
			"HIC你将武器放置于锻造台上，取出早已准备好的淬炼材料投入火炉之中，又把武器一同加热。",
			"HIC淬炼材料渐渐软化，你抄起铁钳将兵器与材料固定在一起锻打，这一过程十分顺畅，材料与武器完美地融合在了一起。",
			"HIW你甩了甩头上的汗水，看着崭新的兵器，心中满是快意。"
		},
	}

	local failTextByMyselfList = {
		{
			"HIC你将武器放置于锻造台上，取出早已准备好的淬炼材料投入火炉之中，又把武器一同加热。",
			"HIC淬炼材料渐渐软化，你抄起铁钳将兵器与材料固定在一起锻打，但这材料始终难以与兵器相融。",
			"HIR你锻打了许久，都未能见效，本次淬炼看来是失败了。",
		},
		{

			"HIC你将武器放置于锻造台上，取出早已准备好的淬炼材料投入火炉之中，又把武器一同加热。",
			"HIC淬炼材料渐渐软化，你抄起铁钳将兵器与材料固定在一起锻打，材料在敲打与高温之下逐渐与武器融为一体。",
			"HIR“啊”，你只觉一阵剧痛袭来，原来是最后时刻，你因为紧张，一锤子砸到了手！"
		},
		{
			"HIC你将武器放置于锻造台上，取出早已准备好的淬炼材料投入火炉之中，又把武器一同加热。",
			"HIC淬炼材料渐渐软化，你抄起铁钳将兵器与材料固定在一起锻打，在你的敲打下两者渐渐融为一体，突然一声轻响......",
			"HIR你心中一惊，顺眼看去，武器与材料相融之处竟出现了道道裂痕，本次淬炼失败了！"
		}
	}
	if resultType == 1 then 
		return successTextByMyselfList
	elseif resultType == 2 then
		return failTextByMyselfList
	elseif resultType == 3 then
		return successByNPCList
	elseif resultType == 4 then
		return failTextByNPCList
	end
end
--roleType 1 自己  2 Npc  
function ShenBingDesc:getShenBingFixText(roleType,wanhaodu) 
	if not wanhaodu or not roleType then 
		print("参数有误")
		return 
	end
	local function createTextMySelf(wanhaodu)
        local textArr = {
            [40] = {
                "#name#将毁坏的兵器放入炉中煅烧，待至烧红，将其取出。",
                "#name#取下一小块修补材料，填补在武器之上，用铁钳夹住兵器让断裂处重合。 ",
                "#name#拿起铁锤敲打着兵器断裂处，试图让其拼接在一起。 ",
                "#name#却无法掌握好力道，铁锤甚至还在兵器上砸出了几个坑。",
                "HIR过了许久，兵器终于修理完成，但效果比断裂也好不了多少。"
            },

            [60] = {
                "#name#将毁坏的兵器放入炉中煅烧，待至烧红，将其取出。",
                "#name#取下一小块修补材料，填补在武器之上，用铁钳夹住兵器让断裂处重合。 ",
                "#name#拿起铁锤敲打着兵器断裂处，试图让其拼接在一起。 ",
                "#name#却无法掌握好敲打的力道，修补进行地十分缓慢。",
                "HIB过了许久，兵器终于修理完成，但修理效果十分差。"
            },
            [80] = {
                "#name#将毁坏的兵器放入炉中煅烧，待至烧红，将其取出。",
                "#name#取下一小块修补材料，填补在武器之上，用铁钳夹住兵器让断裂处重合。 ",
                "#name#拿起铁锤敲打着兵器断裂处，试图让其拼接在一起。 ",
                "#name#掌握好节奏，小心敲打着兵器断裂处，终于是将其补合在了一起。",
                "BLU过了许久，兵器终于修理完成，效果一般。"
            },
            [100] = {
                "#name#将毁坏的兵器放入炉中煅烧，待至烧红，将其取出。",
                "#name#取下一小块修补材料，填补在武器之上，用铁钳夹住兵器让断裂处重合。 ",
                "#name#拿起铁锤敲打着兵器断裂处，试图让其拼接在一起。 ",
                "#name#掌握好节奏，每一次锻打都拿捏地十分到位，断裂的兵器在你的锻打下逐渐合为一体。",
                "HIC兵器终于修理完成，你看着焕然一新的兵器，看不出任何修补的痕迹，当真算是完美无瑕。"
            }
        }

        local text = {}
        if 0 <= wanhaodu and wanhaodu <= 40 then
            text = textArr[40]
        elseif 40 < wanhaodu and wanhaodu <= 60 then
            text = textArr[60]
        elseif 60 < wanhaodu and wanhaodu <= 80 then
            text = textArr[80]
        elseif 80 < wanhaodu and wanhaodu <= 100 then
            text = textArr[100]
        end

        return text
    end

    local function createTextByNpc(wanhaodu)
        local textArry = {
            "#name#将兵器放入炉中煅烧，待至烧红，将其取出。",
            "#name#取下一小块修补材料，填补在武器之上，用铁钳夹住兵器让断裂处重合。 ",
            "#name#拿起铁锤敲打着兵器断裂处，试图让其拼接在一起。 ",
            "#name#心神合一，一丝不苟地锻打着破损的兵器，过了许久方才缓缓转过身来。"
        }

        local tempText = ""
        if wanhaodu < 100 then
            tempText = "YEL#name#：#nickName#,您的兵器虽然已经过修理，但仍存在一些问题，还需进一步修复才行呐。"
        elseif wanhaodu == 100 then
            tempText = "YEL#name#：#nickName#,您的兵器我已经帮您修复完毕了，您拿好！ "
        elseif wanhaodu > 100 then
            tempText = "YEL#name#：#nickName#，您的兵器我已经帮你修复完毕了，不仅如此，我还帮你加固了一番，这兵器比之前的可厉害不少。 "
        end

        table.insert(textArry, tempText)

        return textArry
    end

    local text={}
    if roleType == 1 then 
    	text = createTextMySelf(wanhaodu)
	elseif roleType == 2 then 
		text = createTextByNpc(wanhaodu)
	end
	return text
end

function ShenBingDesc:getShenBingDuanQiText()
	local text={
        "你亲眼看着#name#将锻器所需的材料放入了火炉之中，一股刺鼻之味飘来，金刚石被熊熊烈火烧得通红。",
        "很快，#name#将你的神兵也送入了炉中，待烧得通红时，他立马将金刚石锻了上去，随后反复锤打，直至与神兵相互融合，毫无瑕疵。",
        "只听“嘶”的一声，神兵已经被#name#放入水中，大功告成——整个锻器过程行云流水，你尚未反应，#name#已经将神兵朝你递来。"
    }
    return text
end 
return ShenBingDesc000000000