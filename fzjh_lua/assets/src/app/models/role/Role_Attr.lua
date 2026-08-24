local Role_Attr = {}
local RoleTitleConst = require("app.models.role.titleSystem.RoleTitleConst")
local SkillResManager = require("app.models.skill.SkillResManager")
local GameConst = require("app.models.game.GameConst")
--@RefType [src.app.models.skill.BasicSkill.BasicSkill#BasicSkill]
local BasicSkill = require("app.models.skill.BasicSkill.BasicSkill")
local Family = require("app.models.family.Family")
local NaturalAttrAdjustmentConst = require("app.models.role.attr.NaturalAttributePlan.NaturalAttrAdjustmentConst")

-- 年龄描述
local ageDsc =
{
	{age = 0, dsc = "十多岁"},
	{age = 20, dsc = "二十来岁"},
	{age = 25, dsc = "二十多岁"},
	{age = 30, dsc = "三十来岁"},
	{age = 35, dsc = "三十多岁"},
	{age = 40, dsc = "四十来岁"},
	{age = 45, dsc = "四十多岁"},
	{age = 50, dsc = "五十来岁"},
	{age = 55, dsc = "五十多岁"},
	{age = 60, dsc = "六十来岁"},
	{age = 65, dsc = "六十多岁"},
	{age = 70, dsc = "七十来岁"},
	{age = 75, dsc = "七十多岁"},
}

-- 气血状态描述
local qiDsc =
{
	{qi = 0, dsc = "HIR受伤过重，已经有如风中残烛，随时都可能断气"},
	{qi = 5, dsc = "HIR受伤过重，已经奄奄一息，命在旦夕了"},
	{qi = 10, dsc = "HIR伤重之下已经难以支撑，眼看就要倒在地上"},
	{qi = 20, dsc = "RED受了相当重的伤，只怕会有生命危险"},
	{qi = 30, dsc = "RED已经伤痕累累，正在勉力支撑著不倒下去"},
	{qi = 40, dsc = "RED气息粗重，动作开始散乱，看来所受的伤著实不轻"},
	{qi = 60, dsc = "HIY受伤不轻，看起来状况并不太好"},
	{qi = 80, dsc = "HIY受了几处伤，不过似乎并不碍事"},
	{qi = 90, dsc = "HIY看起来可能受了点轻伤"},
	{qi = 95, dsc = "HIG似乎受了点轻伤，不过光从外表看不大出来"},
	{qi = 100, dsc = "HIG气血充盈，并没有受伤"},
}

-- 战斗中, 状态描述
local fightQiDesc =
{
	{qi = 0, dsc = "HIR$n已经陷入半昏迷状态，随时都可能摔倒晕去。"},
	{qi = 10, dsc = "HIR$n摇头晃脑、歪歪斜斜地站都站不稳，眼看就要倒在地上。"},
	{qi = 20, dsc = "RED$n看起来已经力不从心了。"},
	{qi = 30, dsc = "RED$n已经一副头重脚轻的模样，正在勉力支撑著不倒下去。"},
	{qi = 40, dsc = "RED$n似乎十分疲惫，看来需要好好休息了。"},
	{qi = 60, dsc = "HIY$n气喘嘘嘘，看起来状况并不太好。"},
	{qi = 80, dsc = "HIY$n动作似乎开始有点不太灵光，但是仍然有条不紊。"},
	{qi = 90, dsc = "HIY$n看起来可能有些累了。"},
	{qi = 95, dsc = "HIG$n似乎有些疲惫，但是仍然十分有活力。"},
	{qi = 100, dsc = "HIG$n看起来充满活力，一点也不累。"},
}

local RoleAttrDesc = require("app.models.role.attrDescText.RoleAttrDesc")
-- 相貌描述
local looksDsc = RoleAttrDesc:getLooksDsc()

-- 角色属性初始化, 用来通过公式矫正角色属性, 以及恢复满血状态
function Role_Attr:initAttr()
	return self:callModuleFunc("initAttr")
end

-- 玩家属性变化时 判断是否有联动变化
function Role_Attr:checkAttr(name)
	return self:callModuleFunc("checkAttr", name)
end

-- 获得基础属性
function Role_Attr:getBaseAttr(name)
	return self:callModuleFunc("getBaseAttr", name)
end

-- 设置属性
function Role_Attr:setAttr(name, var)
	if self == User:getRole() and table.keyof(NaturalAttrAdjustmentConst.ATTR_TYPE, name) then
		return 
	end

	return self:callModuleFunc("setAttr", name, var)
end

-- 获取属性`
function Role_Attr:getAttr(name)
	return self:callModuleFunc("getAttr", name)
end

-- 获取属性值（取值为数字类型的属性值）
function Role_Attr:getNumAttr(name)
	return self:callModuleFunc("getNumAttr", name)
end

-- 添加属性（只用于数字类型）
function Role_Attr:addAttr(name, var)
	if table.keyof(NaturalAttrAdjustmentConst.ATTR_TYPE, name) and self.id == "wanjia" then
		return 
	end
	return self:callModuleFunc("addAttr", name, var)
end

-- @author TangJian
-- @time 2017/04/26 01:01:33
-- @desc 得到加成后的属性
function Role_Attr:getFinalAttr(name)
	return self:callModuleFunc("getFinalAttr", name)
end


function Role_Attr:addBuffV2(buffId)
	local id = tonumber(buffId)
	assert(id,"-----Role_Attr:addBuffV2----- buffId不是数字"..buffId)
	return self:callModuleFunc("addBuff",id)
end

function Role_Attr:removeBuffV2(buffId)
	local id = tonumber(buffId)
	assert(id,"-----Role_Attr:removeBuffV2----- buffId不是数字"..buffId)
	return self:callModuleFunc("removeBuff",id)
end

-- 获得加成的属性
function Role_Attr:getBuffAttr(name)
	local value = 0

	if self._roleBuff then
		value = self._roleBuff:getAttr(name)
	end

	return value
end

-- 基本属性
function Role_Attr:getName()
	return Helper:getDef(self.name, "o(=•ェ•=)m")
end

function Role_Attr:getExp()
	local lv = self.lv
	local exp = (0.1 * (lv+4) ^ 3+1)
	if exp < self:getAttr("exp") then
		return self:getAttr("exp")
	end
	return math.floor(exp)
end

function Role_Attr:getLv()
	local exp = self.exp
	if exp == 0 then
		return 1
	end
	local lv = math.floor(((exp-1) / 0.1) ^ (1 / 3)-4)
    return Helper:getRange(lv, 1)
end

-- 获取加力最大值
function Role_Attr:getJiaLiMax()
	local neigongLv, skillLv = self:getSkillLv("jibenneigong"), self:getSkillLv(self:getPrepareSkill("neigong"))
	if not neigongLv or not skillLv then
		return 0
	end
	return math.floor((neigongLv * 0.5 + skillLv) * 0.5)
end

-- 获得武功评价
function Role_Attr:getKongfuDsc()
	local kongfuValue = self:getKongfu()
	local kongfuDsc = SkillResManager:getKongFuDescMap()
	if not kongfuDsc then
		return "看不出武功强弱"
	end
	for i = #kongfuDsc, 1, -1 do
		local dsc = kongfuDsc[i]
		if kongfuValue >= dsc.value then
			return dsc.dsc
		end
	end
	return "看不出武功强弱"
end

function Role_Attr:getKongfuDesc(kongfu)
	local str = "看不出武功强弱"
	if not kongfu then
		return str
	end
	local kongfuDsc = SkillResManager:getKongFuDescMap()
	for i = #kongfuDsc, 1, -1 do
		local dsc = kongfuDsc[i]
		if kongfu >= dsc.value then
			return dsc.dsc
		end
	end
	return str
end

-- 获得武功
function Role_Attr:getKongfu()
	local realWugong = self:getRealWugong()
	local realNeigong = self:getRealNeigong()
	local realQinggong = self:getRealQinggong()
	local realZhaojia = self:getRealZhaojia()
	local currLv = self:getLv()
	local kongfu = (realNeigong + realQinggong + realWugong + realZhaojia + 3 * currLv) / 9
	if DEBUG_MODE == 1 then
		print("realWugong = ",realWugong)
		print("realNeigong = ",realNeigong)
		print("realQinggong = ",realQinggong)
		print("realZhaojia = ",realZhaojia)
		print("currLv = ",currLv)
		print("武功值 = ",kongfu)
	end
	self:setAttr("kongfu", kongfu)
	return kongfu
end

-- 气血状态描述
function Role_Attr:getQiDsc()
	local currQiPercent = (self.qi / self:getCurrQiMax()) * 100
	currQiPercent = math.floor(currQiPercent)
	if PRINT_MODE == 1 then
		print("currQiPercent = "..tostring(currQiPercent))
	end

	-- add by LvBin 2018/02/02 11:45:26 易容术改变气血状态描述
	if self:checkRoleIsPolymorph() then
		currQiPercent = self.polymorph.qi
	end

	for i = #qiDsc, 1, -1 do
		local dsc = qiDsc[i]		
		if currQiPercent >= dsc.qi then
			return dsc.dsc
		end
		
	end
	return qiDsc[1].dsc
end

-- 战斗时气血状况描述
function Role_Attr:getFightQiDesc()
	local currQiPercent = (self.qi / self.qiMax) * 100
	currQiPercent = math.floor(currQiPercent)

	if PRINT_MODE == 1 then
		print("currQiPercent = "..tostring(currQiPercent))
	end

	for i = #fightQiDesc, 1, -1 do
		local dsc = fightQiDesc[i]
		if currQiPercent >= dsc.qi then
			return dsc.dsc
		end
	end
	return "HIR$n体力耗尽，倒在了地上。"
end

-- 加力描述
function Role_Attr:getJialiDsc()
	local desc = "HIG很微妙"
	local percent = math.ceil(Helper:getDef(self.jiaLi, 0) / self:getJiaLiMax() * 100)
	if not percent then
		return "HIG极轻"
	end
	if percent == 0 then
		desc = "HIG极轻"
	elseif 0 < percent and percent <= 20 then
		desc = "HIG很轻"
	elseif 20 < percent and percent <= 40 then
		desc = "HIG不轻"
	elseif 40 < percent and percent <= 60 then
		desc = "HIG不重"
	elseif 60 < percent and percent <= 80 then
		desc = "HIG很重"
	elseif 80 < percent and percent <= 100 then
		desc = "HIG极重"
	else
		desc = "HIG很微妙"
	end
	return desc
end

-- 年龄描述
function Role_Attr:getAgeDsc()
	local currAge = tonumber(self.age)

	-- add by LvBin 2018/02/02 11:30:26 易容术改变年龄描述
	if self:checkRoleIsPolymorph() then
		currAge = self.polymorph.age
	end

	for i = #ageDsc, 1, -1 do
		local dsc = ageDsc[i]				
		if currAge >= dsc.age then
			return dsc.dsc
		end
				
	end
	return "看不出年龄"
end

-- 得到外貌描述
function Role_Attr:getFaceDsc()
	return self:getRoleFaceDsc(self.sex, self:getFinalAttr("looks"), self.equips, self.portrait)
end

-- 根据装备获取外貌描述
function Role_Attr:getRoleFaceDsc(sex, looks, equips, portrait)
	looks = Helper:getDef(looks, 0)
	sex = Helper:getDef(sex, "男")
	equips = Helper:getDef(equips, {})

	if self:checkRoleIsPolymorph() then  --易容改貌
		sex = self.polymorph.sex
		looks = self.polymorph.pLooks
	end
	local desc

	local headItemId = nil
	if type(equips) == "table" then
		if type(equips.head) == "table" then
			headItemId = equips.head.itemId
		end
	end

	-- 面具描述特殊处理
	if headItemId then
		local item = self:getOneItemByKey(headItemId)
		if item ~= nil and item.gradeId then
			local headAttr = self:getMaskSystem():getMaskAttrByMaskIdAndLv(item.gradeId,1)
			if headAttr and headAttr:getMaskDesc() then
				desc = headAttr:getMaskDesc()
			end
		end
		if desc ~= nil then
			return desc
		else
			-- 继续往下走
		end
	end

	-- 头像ID
	if portrait and portrait ~= "" then
		if type(portrait) == "string" then
			portrait = {id = portrait,lv = 1}
		end
		local item = self:getOneItemByKey(portrait.id)
		if item ~= nil and item.gradeId then
			local headAttr = self:getMaskSystem():getMaskAttrByMaskIdAndLv(item.gradeId,portrait.lv)
			if headAttr and headAttr:getMaskDesc() then
				desc = headAttr:getMaskDesc()
			end
		end
		if desc ~= nil then
			return desc
		else
			-- 继续往下走
		end
	end

	local dscs
	if sex == "男" or sex == "male" then
		dscs = looksDsc.male
	elseif sex == "女" or sex == "female" then
		dscs = looksDsc.female
	end

	for i = #dscs, 1, -1 do
		local dsc = dscs[i]
		if dsc and dsc.looks and looks >= dsc.looks then
			return dsc.dsc
		end
	end
	return "看不出长相"
end

--获取江湖容貌描述
function Role_Attr:getJiangHuFaceDsc(sex,looks)
	local dscs
	if sex == "男" or sex == "male" then
		dscs = looksDsc.male
	elseif sex == "女" or sex == "female" then
		dscs = looksDsc.female
	end

	for i = #dscs, 1, -1 do
		local dsc = dscs[i]
		if dsc and dsc.looks and looks >= dsc.looks then
			return dsc.dsc
		end
	end
	return "看不出长相"
end

-- 完整描述获得
-- add by XiaoZhiWei 2017/03/31 11:11:26 增加几个参数,应对策划描述需求调整
--[[
	isNeedAgeDesc  是否需要年龄描述 默认值 true
	isNeedLookDesc 是否需要长相描述 默认值 true
]]
function Role_Attr:getDsc(role, isNeedAgeDesc, isNeedLookDesc , isNeedQiDesc)
	return self:callModuleFunc("getDsc", role, isNeedAgeDesc, isNeedLookDesc , isNeedQiDesc)
end

-- 传承描述获得
function Role_Attr:getInheritDsc()
	local desc = ""
	local cl = "WHT"
	local sex = "他"
	if self.sex == "女" then
		sex = "她"
	elseif self.sex == "野兽" then
		return (self.dsc == nil and "" or tostring(self.dsc))
	end

	local dsc = ""
	if self.dsc then
		dsc = self.dsc
	end

	desc = desc .. cl .. sex .. "曾经看起来约" .. self:getAgeDsc()

	if self:getFaceDsc() ~= nil then
		desc = desc .. "，" .. sex .. cl .. "生得" .. self:getRoleFaceDsc(self.sex, self.looks, nil) .. cl .. "。$N"
	end

	desc = desc .. cl .. sex .. "的武功看来" .. self:getKongfuDsc() .. cl .. "，出手似乎" .. self:getJialiDsc() .. cl .. "。$N"

	desc = desc .. cl .. sex .. "看起来" .. self:getQiDsc() .. "。$N"

	return desc
end

-- 获得他或她
function Role_Attr:getHeOrHer(sex)
	if sex == nil then
		sex = self.sex
	end
	if sex == "男" then
		return "他"
	elseif sex == "女" then
		return "她"
	end
	return ""
end

-- 获得对方与你的关系
function Role_Attr:getRelation(role)
	if self:hasFamily() and role:hasFamily() and self:getFamilyId() == role:getFamilyId() then
		-- add by XiaoZhiWei 2017/03/06 15:02:57 官府称谓特殊处理
		local lvGap = -(role:getFamilyLevel() - self:getFamilyLevel())
		if self:getFamilyId() == "guanfu" then
			if lvGap == 0 then
				return "同僚"
			elseif lvGap <= -1 then
				return "下属"
			else
				return "上司"
			end
		end

		if lvGap == 0 then
			if role:getAttr("sex") == "男" then
				return "师兄"
			else
				return "师姐"
			end
		elseif lvGap == 1 then
			if self.teacherId == role:getAttr("id") then
				return "师父"
			end
			return "师叔"
		elseif lvGap == 2 then
			return "师叔公"
		elseif lvGap == 3 then
			return "师叔祖"
		elseif lvGap == 4 then
			return "太师叔祖"
		elseif lvGap == -1 then
			return "师侄"
		elseif lvGap <= -2 then
			return "徒孙"
		end
	else
		return nil
	end
end

--查看玩家资料
function Role_Attr:getRoleInfoDsc(role)
	local desc = ""
	local cl = "WHT"
	local sex = "他"
	if self.sex == "女" then
		sex = "她"
	elseif self.sex == "野兽" then
		return (self.dsc == nil and "" or tostring(self.dsc))
	end

	if self:checkRoleIsPolymorph() then  --易容改貌
		if self.polymorph.sex == "女" then
			sex = "她"
		else
			sex = "他"
		end
	end

	desc = desc .. cl .. sex .."是"

	--头衔
	local touxian = self:getTouXian()
	desc = desc .. touxian

	--名字
	desc = desc .. self:getName() .. "。\n"

	--传承
	-- if self.chuancheng ~= nil then
	-- 	desc = desc .. cl .. self.chuancheng .. "。\n"
	-- end

	--称号
	desc = desc .. "江湖人称 " .. self:getChengHaoColorName() .. cl .. "。\n"

	--时间
	if self.yueKaValid == "Y" then
		desc = desc .. "于公元" .. Helper:numberCast(Helper:date("%y", self.yuekaTime)) .. "年" .. Helper:numberCast(Helper:date("%m", self.yuekaTime)).. "月".. "加入江湖名士大会" .. cl .. "。\n"
	end

	desc = desc .. "\n"

	desc = desc..cl..sex.."看起来约"..self:getAgeDsc()

	if self:getFaceDsc() ~= nil then
		desc = desc.."，"..sex..cl.."生得"..self:getFaceDsc()..cl.."。\n"
	end

	desc = desc..cl..sex.."的武功看来"..self:getKongfuDsc()..cl.."，出手似乎"..self:getJialiDsc()..cl.."。\n"

	--desc = desc..cl..sex.."看起来"..self:getQiDsc().."。\n\n"

	-- add by XiaoZhiWei 2017/05/16 10:24:16 传承相关描述
	for i,v in ipairs(self.inheritHistory) do
		if i == #self.inheritHistory then
			-- 判断是否有改名
			if v.inheritName ~= self.name then
				v.inheritName = self.name
			end
		end
		desc = desc .. cl .. "公元" .. Helper:numberCast(Helper:date("%y", v.inheritTime)) .. "年" .. Helper:numberCast(Helper:date("%m", v.inheritTime)).. "月" .. Helper:numberCast(Helper:date("%d", v.inheritTime)).. "日" .. " " .. v.parentName .. "将衣钵传与" .. v.inheritName .. "，遂隐退于" .. Map:getDefaultMapById(Map:getMapIdByIndex(v.retireMap)).name .."。\n"
	end

	--武器
	desc = desc.."WHT"..sex.."身上装备着：\n"
	local weapoonName = self:getCurrWeaponName()
	local weapon = self:getEquipByName("weapon")
	if weapon ~= nil then
		if weapon.wpType == "神兵" then
			local itemAttr = self:getOneItemByKey(weapon.itemId)
			weapoonName = itemAttr.colorname .. weapoonName
			desc = desc .. "	□" .. weapoonName .. cl .. "\n"
		elseif weapon then
			desc = desc .. cl .. "	□" .. weapoonName .. cl .. "\n"
		end
	end
	
	local equipsTab =
	{
		[1] = "head",		-- 头帽
		[2] = "cloth",		-- 上装
		[3] = "pants",		-- 下装
		[4] = "belt",		-- 腰带
		[5] = "yaozhui",	-- 腰坠
		[6] = "shoes",		-- 鞋子
		[7] = "necklace",	-- 项链
		[8] = "hand",		-- 手部
		[9] = "ring",		-- 戒指
	}

	for i,v in ipairs(equipsTab) do
		local equip = self:getEquipByName(v)
		if equip and self:getOneItemByKey(equip.itemId) then
			desc = desc .. "	□" .. self:getOneItemByKey(equip.itemId).name .. cl .. "\n"
		end
	end

	--装备外观
	local appearance = self:getAttr("appearance")
	print("装备外观 id  = ",appearance)
	if appearance and appearance ~= "" and appearance ~= "waiguan0"  then
		desc = desc .. "	□" .. self:getOneItemByKey(appearance).name .. cl .. "\n"
	end
	
	return desc
end

-- 称呼
function Role_Attr:getHeCall()
	if self.sex == "男" then
		return "他"
	elseif self.sex == "女" then
		return "她"
	end
	return "它"
end

----- 玩家属性
-- 获取中文 年龄大小
function Role_Attr:getAgeWithChinese()
	local year = self:getAge()

	local str = ""

	str = year.."岁"

	if year == ROLE_AGE_LIMIT then
		return str
	end

	local gamingTime = self:getAttr("gamingTime")

	local month = math.floor(math.mod(gamingTime / 3600/ 24 * 2, 12))

	if month > 0 then
		str = str..month.."月"
	end

	return str
end

-- 获取岁数
function Role_Attr:getAge()
	return self:getNumAttr("age")
end

--年龄计算
function Role_Attr:calculateAge()
	local gamingTime = self:getAttr("gamingTime")
	-- 6天算1年
	local year = math.floor(gamingTime / 3600 / 24 / 12 * 2)
	--初始14岁
	year = 14 + year
	--@desc 限制年龄上限
	if year >= ROLE_AGE_LIMIT then
		year = ROLE_AGE_LIMIT
	end

	self:setAttr("age", year)
end

--获取等效根骨
function Role_Attr:getEffectCon()
	-- if not self.con or type(self.con) ~= "number" then
	-- 	self.con = 0
	-- end
	-- if not self.secCon or type(self.secCon) ~= "number" then
	-- 	self.secCon = 0
	-- end
	-- return tonumber(self.con + (self:getFinalAttr("secCon") * 0.5))
	return self:getFinalAttr("effectCon")
end

-- --获取总悟性
-- function Role_Attr:getTotalInt()
-- 	if not self.int or type(self.int) ~= "number" then
-- 		self.int = 0
-- 	end
-- 	if not self.secInt or type(self.secInt) ~= "number" then
-- 		self.secInt = 0
-- 	end
-- 	-- add by XiaoZhiWei 2017/06/23 10:54:07 修复,先天悟性没有参与计算的bug
-- 	return tonumber(self.int + self:getFinalAttr("secInt"))
-- end

-- 获取等效臂力
function Role_Attr:getEffectStr()
	-- if not self.str or type(self.str) ~= "number" then
	-- 	self.str = 0
	-- end
	-- if not self.secStr or type(self.secStr) ~= "number" then
	-- 	self.secStr = 0
	-- end
	-- return tonumber(self.str + (self:getFinalAttr("secStr") * 0.5))
	return self:getFinalAttr("effectStr")
end

-- 获取等效身法
function Role_Attr:getEffectDex()
	-- if not self.dex or type(self.dex) ~= "number" then
	-- 	self.dex = 0
	-- end
	-- if not self.secDex or type(self.secDex) ~= "number" then
	-- 	self.secDex = 0
	-- end
	-- return tonumber(self.dex + (self:getFinalAttr("secDex") * 0.5))
	return self:getFinalAttr("effectDex")
end

-- 设置精力最大值
function Role_Attr:setJingMax()
	local age = self:getAttr("age")
	local skills = self:getSkills()
	local xfLv = 0
	for k,v in pairs(skills) do
		local skill = Skill:getSkill(k)
		if skill ~= nil then
			if skill.type == SKILL_TYPE_SPECIAL and self:conversionSkillExpAndLv("lv", v.exp) > xfLv then
				xfLv = self:conversionSkillExpAndLv("lv", v.exp)
			end
		else
			print("缺少技能资源  skillId = ",k)
		end
	end
	-- 年龄分段加成精力
	--[[
		14-32 一岁加成24点
		32-50 一岁加成10点
		50-60 一岁加成5点
		60-10000 一岁加成1点
	]]
	local jingMax = 100 + xfLv/2 + Helper:getRange((age-14), 0, 18)*24 + Helper:getRange((age-32), 0, 18)*10 + Helper:getRange((age-50), 0, 10)*5 + Helper:getRange((age-60), 0, 10000)*1
	self:setAttr("jingMax", jingMax)
end

-- 获取精力最大值
function Role_Attr:getJingMax()
	local baseValue = self:getFinalAttr("jingMax") 
	local yueKaAddValue = 0
	local qiXiJingMaxAddValue = 0
	local qiyuCount = 0
	local qiYuCountAddValue = 0
	local xingZhenAddValue = 0

	local jingMax = baseValue
	if self:yueKaIsValid() == true then
		-- 月卡有效 且 当前称号时月卡称号时 精力最大值加100
		jingMax = jingMax + 100
		yueKaAddValue = 100
	end

	-- add by XiaoZhiWei 2017/08/26 13:11:00 七夕精力加成
	do
		qiXiJingMaxAddValue = Helper:getDef(self:getInheritFlag("QiXi_JingMax"), 0)
		jingMax = jingMax + qiXiJingMaxAddValue
	end
	
	--奇遇事件精力上限增加 一次增加100，最大次数13次
	if self.qiyujingCount ~= nil and self.qiyujingCount > 0 then
		jingMax = jingMax + self.qiyujingCount * 100

		qiyuCount = self.qiyujingCount
		qiYuCountAddValue = self.qiyujingCount * 100
	end

	jingMax = jingMax + self:getBuffAttr("xingZhenJingMax")
	
	xingZhenAddValue = self:getBuffAttr("xingZhenJingMax")

	return jingMax, {
		baseValue = baseValue,
		yueKaAddValue = yueKaAddValue,
		qiXiJingMaxAddValue = qiXiJingMaxAddValue,
		qiyuCount = qiyuCount,
		qiYuCountAddValue = qiYuCountAddValue,
		xingZhenAddValue = xingZhenAddValue
	}
end

-- 获取当前气血最大值
function Role_Attr:getCurrQiMax(onlyBaseValue)
	local qiPercent = self:getAttr("qiPercent")
	if not qiPercent or qiPercent > 1 then
		qiPercent = 1
		self:setAttr("qiPercent", 1)
	end

	local qiMax = self:getFinalAttr("qiMax")

	return qiMax * qiPercent
end


-------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------战斗相关公式计算
-- 玩家攻击力 onlyBaseValue 只获取基础的数值
function Role_Attr:getAtk(onlyBaseValue)
	if onlyBaseValue == true then
		return self:getBaseAttr("atk")
	end

	return self:getFinalAttr("atk")
end

-- 玩家加力攻击力
function Role_Attr:getJiaLiAtk()
	local cType = self:getCurrTypeByWeapon()
	if cType == "quanjiao" then
		-- 暂用拳脚1做计算
		cType = "quanjiao1"
	end
	local skillLv, factor = self:getSkillLvAndFactor(cType, "powerAtkRate")
	local jiaLi = self:getFinalAttr("jiaLi")
	if self.neili < jiaLi then
		return 0
	end
	return jiaLi*factor*(1+skillLv/500)*(0.49 + 0.001 *self:getEffectStr())
end

-- 玩家躲闪力 onlyBaseValue 只获取基础的数值
function Role_Attr:getDodge(onlyBaseValue)
	if self.dodgeScaleFactor ~= nil then
		if type( self.dodgeScaleFactor ) ~= "number" or self.dodgeScaleFactor < 0 or self.dodgeScaleFactor > 100 then
			self.dodgeScaleFactor = 1.0
		end

		return self.dodgeScaleFactor * self:getBaseAttr("dodge")
	end

	if onlyBaseValue == true then
		return self:getBaseAttr("dodge")
	end

	return self:getFinalAttr("dodge")
end

-- 玩家防御力 onlyBaseValue 只获取基础的数值
function Role_Attr:getDef(onlyBaseValue)
	if onlyBaseValue == true then
		return self:getBaseAttr("def")
	end

	return self:getFinalAttr("def")
end

-- 玩家伤害力 (加力伤害) onlyBaseValue 只获取基础的数值
-- fightRole 战斗人物
function Role_Attr:getPowerDamage(onlyBaseValue,fightRole)

	if onlyBaseValue == true then
		return self:getBaseAttr("damage")
	end

	local value = self:getFinalAttr("damage")

	-- -- fightRole 没有用到
	-- local weapon = self:getEquipByName("weapon")
	-- local item
	-- if weapon and weapon.itemId then
	-- 	item = self:getOneItemByKey(weapon.itemId)
	-- end
	-- local wpAtk = 0
	-- if item and item.damage then
	-- 	wpAtk = item:getWeaponDamage(self,nil,fightRole)
	-- end

	return value 
end

-- 玩家命中率
function Role_Attr:getHitRate(onlyBaseValue)
	local cType = self:getCurrTypeByWeapon()
	if cType == "quanjiao" then
		-- 暂用拳脚1做计算
		cType = "quanjiao1"
	end
	local skillLv, factor = self:getSkillLvAndFactor(cType, "hitRate")
	-- print(self:getName())
	-- print("Role_Attr:getHitRate() -> ")
	-- print(cType)
	-- print(skillLv)
	-- print(factor)
	-- print(self:getExp())
	-- print(self:getEffectStr())
	local baseValue = (skillLv*15*factor/100+1000+0.5*self:getExp()^0.5)*(1+self:getEffectStr()*0.02)
	if onlyBaseValue then
		return baseValue
	end

	--神兵特性
	local addHit = 0
	local equipWeapon = self:getEquipByName("weapon")
	if equipWeapon ~= nil and equipWeapon ~="拳脚" then
		local weapen = self:getOneItemByKey(equipWeapon.itemId)
		if weapen ~= nil then
			addHit = Helper:getDef(ShenBingEffct:getWeaponExtraHit(weapen,self),0)
		end
		if DEBUG_MODE == 1 then
			print("------------------------兵器特性提升命中----------------------------------",addHit)
		end
	end

	local fistFootAddHit = 0
	if equipWeapon == nil or equipWeapon == "拳脚" then
		local FightRoleFistFootEffect = require("src.app.models.fight.FightRoleFistFootEffect")
		fistFootAddHit = FightRoleFistFootEffect:getHitBuffsValue(self)
	end

	return baseValue + addHit + fistFootAddHit
end

-- 玩家招架
function Role_Attr:getParry(onlyBaseValue)
	if self.parryScaleFactor ~= nil then
		if type( self.parryScaleFactor ) ~= "number" or self.parryScaleFactor < 0 or self.parryScaleFactor > 100 then
			self.parryScaleFactor = 1.0
		end

		return self.parryScaleFactor * self:getBaseAttr("parry")
	end

	if onlyBaseValue == true then
		return self:getBaseAttr("parry")
	end

	return self:getFinalAttr("parry")
end

-- 玩家防护力 总值 onlyBaseValue 只获取基础的数值
function Role_Attr:getFangHu(onlyBaseValue)
	if onlyBaseValue == true then
		return self:getBaseAttr("protect")
	end

	local value = self:getFinalAttr("protect")

	return value
end

-- 获取命中部位保护力
function Role_Attr:getProtect(partName)
	local FightConfig = require("app.models.fight.FightConfig")

	local equipName = FightConfig:getPartEquipName(partName)

	LogSystem:log("旧版战斗：获取命中部位保护力 部位名称 = ",partName," 装备部位 = ",equipName)

	local equip = self:getEquipByName(equipName)
	if not equip then
		return self:getFangHu()
	end
	local item = self:getOneItemByKey(equip.itemId)
	if not item then
		return self:getFangHu()
	end

	return item:getItemAttr("protect")+ self:getFangHu()
end

-- 获取经脉属性加成
function Role_Attr:getMeridianAttrValue(attr)
	local meridian = self.meridian

	if meridian.attrTotal and meridian.attrTotal[attr] then
		return tonumber(meridian.attrTotal[attr])
	end

	return 0
end

-- 获得经脉等级
function Role_Attr:getMeridianLevel()
	local Meridian = require("app.models.Meridian.Meridian")
	local lv = Meridian:getMeridianLv(self.meridianExp)
	return lv
end

-- 判断是否拥有经脉印记
function Role_Attr:isHaveImprintingId(imprintingId)
	return self:getMeridianSystem():currPageHasMeridianImprinting(imprintingId)
end

--获取人物显示时传承者描述
function Role_Attr:getInheritRoleWebDsc()
	local desc = ""
	if MapIsEmpty(self.inheritHistory)==false then
		for i,v in ipairs(self.inheritHistory) do
			if i == #self.inheritHistory then
				-- 判断是否有改名
				if v.inheritName ~= self.name then
					v.inheritName = self.name
				end
			end
			desc = desc .. "WHT" .. "公元" .. Helper:numberCast(Helper:date("%y", v.inheritTime)) .. "年" .. Helper:numberCast(Helper:date("%m", v.inheritTime)).. "月" .. Helper:numberCast(Helper:date("%d", v.inheritTime)).. "日" .. " " .. v.parentName .. "将衣钵传与" .. v.inheritName .. "，遂隐退于" .. Map:getDefaultMapById(Map:getMapIdByIndex(v.retireMap)).name .."。\n"
		end
	end 
	return desc
end

--疲劳值自然恢复
function Role_Attr:spontaneousRecoveryPiJuan()
	local lastTime = self:getFlag("疲劳值刷新时间")
	if lastTime == 0 then 
		self:setFlag("疲劳值刷新时间", GetTime() )
		return
	end
	local diffTime = GetTime() - lastTime
	if diffTime >= 600 then --在线/离线，1小时可得6点疲倦值 10分钟一点
		local value = math.floor(diffTime/600)
		self:addAttr("pijuan",value)
		self:setFlag("疲劳值刷新时间", GetTime() )
	end
end

function Role_Attr:getSelfCreatedSkillData()
	return self:getAttr("selfCreatedSkillData")
end

--清除自创武学数据
function Role_Attr:deleteSelfCreatedSkillData()
    return self:getSelfCreatedSkillSystem():deleteSelfCreatedSkillData()
end

--@desc: 玩家当前fdamge (暂定名-武练)值
--@author:Seven
--@time:2022-09-20 18:00:21
function Role_Attr:getFDamage()
	local value = 0

	local prepSkillId = self:getPrepareSkillIdByType("quanjiao")
	
	if prepSkillId ~= nil then
		local prep_skill = Skill:getSkill(prepSkillId)
		if prep_skill then
			local skillTypes = prep_skill:getSkillTypes()
			for _,skill_type_id in ipairs(skillTypes) do
				if BasicSkill.IsAttackType(skill_type_id) then
					value = self:getFistFootSystem():getBranchDamage(skill_type_id) + value
				end
			end
		end
	end
	
	local standBySkillId = self:getPrepareSkillIdByType("quanjiao2")
	if standBySkillId ~= nil then
		local standBy_skill = Skill:getSkill(standBySkillId)
		if standBy_skill then
			local skillTypes = standBy_skill:getSkillTypes()
			for _,skill_type_id in ipairs(skillTypes) do
				if BasicSkill.IsAttackType(skill_type_id) then
					value = self:getFistFootSystem():getBranchDamage(skill_type_id) + value
				end
			end
		end
	end

	return value 
end

--@desc: 获取拳脚伤害力
--@author:Seven
--@time:2022-09-20 16:36:42
function Role_Attr:getWsdamage()
	-- 拳脚伤害力 = 角色fdamage总值 * fdamage伤害力修正系数
	local currWeaponType = self:getCurrWeaponType()

	if currWeaponType ~= "拳脚" then
		return 0
	end

	local BattleConstConf = require("app.FightSystem.Configuration.BattleConstConf")

	return self:getFDamage() * BattleConstConf:get("wushufdamageCorrectionFactor")
end

--@desc: 经脉化元技能相关存档数据
--@author:Seven
--@time:2023-07-05 14:19:22
--@return: {}
function Role_Attr:getMSkillUseRecord()
    if self.mSkillUseRecord == nil then
        self.mSkillUseRecord = {
            firstUseTime = 0,
            time = 0
        }
    end

    return self.mSkillUseRecord
end

--判断是不是归隐
function Role_Attr:checkRoleisSeclusion()
    return self.isSeclusion == true
end

--设置先天属性
function Role_Attr:setNaturalAttr(name, value)
    if self == User:getRole() and table.keyof(NaturalAttrAdjustmentConst.ATTR_TYPE, name) then
        return self:callModuleFunc("setAttr", name, value)
    end
end

--@desc: 限制角色属性正气值范围
--@author:LvBin
--@time:2024-10-31 12:04:31
--@return
function Role_Attr:limitAttrZhengQiRange()
	if self:getAttr("zhengqi") > 39999999 then
		self:setAttr("zhengqi", 39999999)
	elseif self:getAttr("zhengqi") < -39999999 then
		self:setAttr("zhengqi", -39999999)
	end
end

--@desc: 获取左右互博等级
--@author:LvBin
--@time:2025-01-17 11:43:36
--@return
function Role_Attr:getZuoYouHuBoYinLv()
	local leftRightFightExp = Helper:getDef(self:getAttr("leftRightFightExp"), 0)

	local lv = math.ceil(leftRightFightExp / 100)

	if leftRightFightExp > 99 and leftRightFightExp % 100 == 0 then
		lv = lv + 1
    end

	return math.min(lv,10)
end

--@desc: 获取装饰箱图鉴成就积分
--@author:LvBin
--@time:2025-03-18 16:23:38
--@return
function Role_Attr:getPokedexPoint()
	local point = 0

	local Pokedex = require("script.others.tujian")

	for k,v in pairs(Pokedex["江湖容貌"]) do
		if self:getFlag("江湖容貌图鉴成就" .. v.achievementId) == 1 then
			point = point + v.point
		end
	end

	for k,v in pairs(Pokedex["面具"]) do
		if self:getFlag("面具图鉴成就" .. v.achievementId) == 1 then
			point = point + v.point
		end
	end

	for k,v in pairs(Pokedex["信物"]) do
		if self:getFlag("信物图鉴成就" .. v.achievementId) == 1 then
			point = point + v.point
		end
	end

	return point
end


return Role_Attr00000000000