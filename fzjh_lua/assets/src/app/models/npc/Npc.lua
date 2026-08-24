local Skill = require("app.models.skill.Skill")

local Npc = {}
local npcLooksMap -- Npc 长相属性集合


-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/03/20 14:33:06
-- @desc 检查资源错误
function Npc:checkResError(role)
	if true then
		return false
	end
	if MapIsEmpty(role) == true then
		return true, "角色为空,不需要检查"
	end
	local result, errTab = false, {"开始检查角色 ============================================================="..tostring(role.name)}
	local prepare, skills = role.skillPrepare, role.skills

	if MapIsEmpty(prepare) == false then
		for ptype,skillId in pairs(prepare) do
			if skills[skillId] == nil then
				result = true
				table.insert(errTab, "准备的"..ptype.."不在武功("..skillId..")的列表中,请检查")
			end
		end
	end

	if MapIsEmpty(skills) == false then
		for skillId,roleSkill in pairs(skills) do
			if roleSkill.exp == nil then
				result = true
				table.insert(errTab, "武功列表中"..skillId.."没有填写武功等级,请检查")
			end
		end
	end

	local checkNumberList = 
	{
		"age",
		"looks",
		"luck",
		"tili",
		"tiliMax",
		"str",
		"int",
		"con",
		"dex",
		"jing",
		"jingMax",
		"qi",
		"qiMax",
		"neili",
		"neiliMax",
		"exp",
		"pot",
		"money",
		"gold",
		"lv",
		"jiaLi"
	} ---- add by XiaoZhiWei 2017/03/20 14:53:04 需要检查的属性列表(全是数字类型)
	for i,v in ipairs(checkNumberList) do
		if role[v] == nil or type(role[v]) ~= "number" then
			result = true
			table.insert(errTab, "属性类型有错误 -> "..v.." 是一个 "..type(role[v]))
		end
	end
	return result, table.concat(errTab, "\n")
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2016/11/10 10:41:04
-- @desc  从本地读取NPC长相信息
local function getNpcLooksData()
	return nil
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2016/11/10 10:41:30
-- @desc 将初始化好的NPC长相信息保存到本地 (在初始化完成之后保存)
local function setNpcLooksData()
	-- 不再保存到 DataBase
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2016/11/10 10:39:48
-- @desc 初始化NPC长相,本地有记录文件,则以本地记录为准,没有则初始化一个,并记录到本地
local function initNpcLooks(npc) 
	if not npc or not npc.looks then
		return
	end
	if MapIsEmpty(npcLooksMap) == true then
		npcLooksMap = {}
	end
	if npcLooksMap[npc.id] == nil then 		-- 如果不存在则初始化
		if type(npc.looks) == "string" then
			npc.looks = tonumber(Helper:GetValueFromScript(npc.looks))
		end
		npcLooksMap[npc.id] = 
		{
			id = npc.id,
			name = npc.name,
			looks = npc.looks
		}
	else
		npc.looks = tonumber(npcLooksMap[npc.id].looks)
	end
end

local npcMap = {}
local function initNpc(npc)	
	-- npc.looks = math.random(0, 30)

	npc.type = "role"
	local family = 
	{
		level = npc.level,
		name = npc.family
	}	
	npc.family = family

	local skills = {}

	-- if DEBUG_MODE == 1 then
	-- 	local prepareList = {"quanjiao", "neigong", "qinggong", "zhaojia", "jianfa", "daofa", "gunfa", "anqi", "shuangchi", "qinfa"}
	-- 	-- 初始化基本类武功等级
	-- 	for k,v in pairs(prepareList) do
	-- 		local id = "jiben"..v
	-- 		local skill =
	-- 		{
	-- 			id = id,
	-- 			exp = Skill:getExp(tonumber(npc.lv))
	-- 		}
	-- 		skills[id] = skill
	-- 	end
	-- end
	
	-- local i = 0
	-- while (npc["skill"..i] ~= nil and string.len(npc["skill"..i]) > 0) do
	-- 	skills[npc["skill"..i]] = 
	-- 	{
	-- 		id = npc["skill"..i],
	-- 		exp = Skill:getExp(tonumber(npc["skillLv"..i]))
	-- 	}
	-- 	i = i + 1
	-- end


	--@desc 师傅能教的技能
	local t_skills = {}
    local i = 0
    while (npc["tSkill" .. i] ~= nil and string.len(npc["tSkill" .. i]) > 0) do
        t_skills[npc["tSkill" .. i]] = {
            id = npc["tSkill" .. i],
            exp = Skill:getExp(tonumber(npc["tSkillLv" .. i]))
        }
        i = i + 1
	end
    npc.tSkills = createEncryptTable(t_skills)

	--@desc 兼容旧地图
	local functions = {}
	
	--@desc 新副本结构
	local operations = {}
	
    if npc.talk == 1 then
        table.insert(
            functions,
            {
                name = "交谈",
                func = function(teacher)
                    return teacher:obTalk(User:getRole())
                end
            }
        )

        --@desc 副本操作结果
        local results = {
            OperationFactory:createResult("师门交谈")
        }
        local operation = OperationFactory:createNoConditionBtnOperation("交谈", results)
        table.insert(operations, operation)
        npc.talkOpId = operation.id
    end
    if npc.baishi == 1 then
        table.insert(
            functions,
            {
                name = "拜师",
                func = function(teacher)
					return User:getRole():obApprentice(teacher)
                end
            }
        )

        --@desc 副本操作结果
        local results = {
            OperationFactory:createResult("拜师")
        }
        local operation = OperationFactory:createNoConditionBtnOperation("拜师", results)
        table.insert(operations, operation)
        npc.baishiOpId = operation.id
    end
    -- if npc.learn == 1 then
    --     table.insert(
    --         functions,
    --         {
    --             name = "请教",
    --             func = function(teacher)
    --                 return teacher:obConsult(User:getRole())
    --             end
    --         }
    --     )

    --     --@desc 副本操作结果
    --     local results = {
    --         OperationFactory:createResult("师门请教")
    --     }
    --     local operation = OperationFactory:createNoConditionBtnOperation("请教", results)
    --     table.insert(operations, operation)
    --     npc.learnOpId = operation.id
    -- end

    if npc.compare == 1 then
        table.insert(
            functions,
            {
                name = "比试",
                func = function(teacher)
                    return teacher:obCompete(User:getRole())
                end
            }
        )

        --@desc 副本操作结果
        local results = {
            OperationFactory:createResult("师门比武")
        }
        local operation = OperationFactory:createNoConditionBtnOperation("比试", results)
        table.insert(operations, operation)
        npc.teacherFightOpId = operation.id
    end
	
	--@desc npc表的animation为1时，增加门派往事按钮
    if npc.animation and npc.animation == 1 then
        table.insert(
            functions,
            {
                name = "门派往事",
                func = function(teacher)
					local menPaiStr = User:getRole():getFamilyName()
					teacher:showTeacherAnimation( menPaiStr )
                end
            }
		)
		
		--@desc 副本操作结果
		local results = {
			OperationFactory:createResult("门派故事")
		}
		local operation = OperationFactory:createNoConditionBtnOperation("门派往事", results)
		table.insert(operations, operation)
		npc.teacherFightOpId = operation.id
	end
	
	npc.functions = functions
	npc.operations = operations

	local prepareMap = {
		"quanjiao1",
		"quanjiao2",
		"neigong",
		"qinggong",
		"zhaojia",
		"jianfa",
		"daofa",
		"gunfa",
		"anqi",
		"shuangchi",
		"qinfa",
	}

	npc.skillPrepare = {}
	for i,prepareType in ipairs(prepareMap) do
		local skillType = prepareType
		if prepareType == "quanjiao1" or prepareType == "quanjiao2" then
			skillType = "quanjiao"
		end
		
		local skillId = npc[prepareType]
		if skillId ~= "jiben"..skillType then
			skills["jiben"..skillType] = {
				id = "jiben"..skillType,
				exp  = Skill:getExp(tonumber(npc.lv))
			}
		end
		
		if skillId ~= nil then
			local skillLv = npc[prepareType.."_lv"]

			if skillLv == nil then
				skillLv = npc.lv
			end

			skills[skillId] = {
				id = skillId,
				exp = Skill:getExp(tonumber(skillLv))
			}
		end
		
		npc.skillPrepare[prepareType] = skillId
	end


	--@desc 初始化基本技能
	local prepareList = {"quanjiao", "neigong", "qinggong", "zhaojia", "jianfa", "daofa", "gunfa", "anqi","bianfa", "shuangchi", "qinfa"}
	for i,v in ipairs(prepareList) do
		local id = "jiben"..v
		if skills[id] == nil then
			local skill = {
				id = id,
				exp = Skill:getExp(tonumber(npc.lv))
			}
			skills[id] = skill
		end
	end

	-- add by XiaoZhiWei 2017/05/11 10:44:09 加密 (主防 技能等级)
	npc.skills = createEncryptTable(skills)

	local prepare = 
	{
		quanjiao1 = npc.quanjiao1 == nil and "jibenquanjiao" or npc.quanjiao1,
		quanjiao2 = npc.quanjiao2,
		neigong = npc.neigong == nil and "jibenneigong" or npc.neigong,
		qinggong = npc.qinggong == nil and "jibenqinggong" or npc.qinggong,
		zhaojia = npc.zhaojia == nil and "jibenzhaojia" or npc.zhaojia,
		jianfa = npc.jianfa == nil and "jibenjianfa" or npc.jianfa,
		daofa = npc.daofa == nil and "jibendaofa" or npc.daofa,
		gunfa = npc.gunfa == nil and "jibengunfa" or npc.gunfa,
		anqi = npc.anqi == nil and "jibenanqi" or npc.anqi,
		bianfa = npc.bianfa == nil and "jibenbianfa" or npc.bianfa,
		shuangchi = npc.shuangchi == nil and "jibenshuangchi" or npc.shuangchi,
		qinfa = npc.qinfa == nil and "jibenqinfa" or npc.qinfa,
	}
	npc.skillPrepare = prepare

	local apprenticeCondition = {}
	i = 1
	while (npc["masterconType_"..i] ~= nil and npc["mastercon_"..i] ~= nil) do
		local tab = 
		{
			type = npc["masterconType_"..i],
			name = npc["mastercon_"..i],
			cond = npc["masterconRelation_"..i],
			value = npc["masterconDate_"..i],
			failed = npc["Remasterfalse_"..i]
		}
		table.insert(apprenticeCondition, tab)
		i = i + 1
	end
	npc.apprenticeCondition = apprenticeCondition

	-----------------------------------------------------------------------------------------------------------
	-- @author XiaoZhiWei
	-- @time 2016/12/03 13:01:30
	-- @desc 拜师条件添加与或判断
	npc.apprenticeRelation = Helper:getDef(npc.masterRelation, "and") -- 拜师条件与或关系,默认与

	-- 只有或条件时才存在这个,与条件可以写在前面一起
	if npc.apprenticeRelation == "or" then
		apprenticeCondition, i = {}, 1 -- 初始化前面的记录
		while (npc["masterOrConType_"..i] ~= nil and npc["masterOrCon_"..i] ~= nil) do
			local tab = 
			{
				type = npc["masterOrConType_"..i],
				name = npc["masterOrCon_"..i],
				cond = npc["masterOrConRelation_"..i],
				value = npc["masterOrConValue_"..i],
				failed = npc["RemasterOrFalse_"..i]
			}
			table.insert(apprenticeCondition, tab)
			i = i + 1
		end

		npc.apprenticeOrCondition = apprenticeCondition
	else
	end
	-----------------------------------------------------------------------------------------------------------


	local equips = {}
	-- 武器
	if npc.weapon and #tostring(npc.weapon) > 0 then
		equips.weapon = {id = Helper:getOnlyId(), itemId = npc.weapon}
	end
	-- 头帽
	if npc.head and #tostring(npc.head) > 0 then
		equips.head = {id = Helper:getOnlyId(), itemId = npc.head}
	end
	-- 上装
	if npc.cloth and #tostring(npc.cloth) > 0 then
		equips.cloth = {id = Helper:getOnlyId(), itemId = npc.cloth}
	end
	-- 腰带
	if npc.belt and #tostring(npc.belt) > 0 then
		equips.belt = {id = Helper:getOnlyId(), itemId = npc.belt}
	end
	-- 手部
	if npc.hand and #tostring(npc.hand) > 0 then
		equips.hand = {id = Helper:getOnlyId(), itemId = npc.hand}
	end
	-- 下装
	if npc.pants and #tostring(npc.pants) > 0 then
		equips.pants = {id = Helper:getOnlyId(), itemId = npc.pants}
	end
	-- 鞋子
	if npc.shoes and #tostring(npc.shoes) > 0 then
		equips.shoes = {id = Helper:getOnlyId(), itemId = npc.shoes}
	end
	-- 戒指
	if npc.ring and #tostring(npc.ring) > 0 then
		equips.ring = {id = Helper:getOnlyId(), itemId = npc.ring}
	end
	-- 腰坠
	if npc.yaozhui and #tostring(npc.yaozhui) > 0 then
		equips.yaozhui = {id = Helper:getOnlyId(), itemId = npc.yaozhui}
	end
	-- 项链
	if npc.necklace and #tostring(npc.necklace) > 0 then
		equips.necklace = {id = Helper:getOnlyId(), itemId = npc.necklace}
	end
	npc.equips = equips

	
	npc.items = {}
	for part,v in pairs(equips) do
		if not v or not v.itemId then
		else
			local item = {id = v.id, count = 1 , itemId = v.itemId}
			table.insert(npc.items, item)
		end
	end

	npc.chenghao = npc.title
	npc.jiaLi = npc.powerNeili
	npc.qiMax = npc.qi
	npc.neiliMax = npc.neili
	initNpcLooks(npc)
end

function Npc:initNpcMap()
	local listData = require("script.npc.npc")

	for sheetName,list in pairs(listData) do
		for k,v in pairs(list) do
			-- add by XiaoZhiWei 2017/05/11 10:44:09 加密 (主防 技能等级,师傅等级)
			list[k] = createEncryptTable(v)
		end
	end

	local result ,errTab = false, {}
	for key,npc in pairs(listData.npcs) do
		initNpc(npc)
		npcMap[key] = npc--Helper:tableCover(require("app.models.npc.BaseNpc"):create(), npc)
		npcMap[key].id = key
		npcMap[npc.name] = npcMap[key]
	end
end

Npc:initNpcMap() -- 初始化ｎｐｃ列表

function Npc:getNpc(name)
	local npc = npcMap[name]
	if npc == nil then
		if PRINT_MODE == 1 then
			print("没有这个npc name = "..tostring(name))
		end
		return nil
	end	
	return Helper:tableCover(require("app.models.npc.BaseNpc"):create(), npc)--npc
end


---------------------------------------------------------------------------------------------------------------------------------------------------
-- 任务NPC部分

local onlyId = 0
local function getOnlyId()
	onlyId = onlyId + 1
	return onlyId
end

-- 对以封号隔开的字符串，随机获得其中一个
local function getRandomString(str)
	if not str then
		return 
	end
	local list = string.split(str, ";")
	return list[math.random(1, #list)]
end 

function Npc:createTaskNpc(id)
	local listData = require("script.npc.taskNpc")
	for k,npc in pairs(listData["npc"]) do
		if k == id then
			if PRINT_MODE == 1 then
				print("初始化一个任务角色"..tostring(id))
			end
			local role = clone(npc)
			role.id = id..tostring(getOnlyId())
			role.type = "role"
			role._canDetect = false -- add by XiaoZhiWei 2017/05/04 10:54:55 神书是否能够检测 false 代表不能检测 其他的则可以检测
			return self:initTaskNpc(role)
		end
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2016/12/18 01:41:35
-- @desc 创建随机NPC
function Npc:createRandomNpc(id)
	if npcMap[id] == nil then
		return self:createTaskNpc(id)
	else
		return clone(npcMap[id])
	end
end


function Npc:initTaskNpc(npc)
	self:initRoleAttr(npc)

	npc.chenghao = npc.title
	npc.jiaLi = npc.powerNeili
	npc = Helper:tableCover(require("app.models.npc.BaseNpc"):create(), npc)
	npc.exp = npc:getExp()
	-- npc.zhaojia = Helper:GetValueFromScript(npc.zhaojia, params)
	-- local family = 
	-- {
	-- 	level = npc.level,
	-- 	name = npc.family
	-- }	
	-- npc.family = family
	npc.canKill = 1

	-- 身上穿戴的也要存入背包
	local equips = {}
	-- 武器
	if npc.weapon and #tostring(npc.weapon) > 0 then
		equips.weapon = {id = Helper:getOnlyId(), itemId = npc.weapon}
	end
	-- 头帽
	if npc.head and #tostring(npc.head) > 0 then
		equips.head = {id = Helper:getOnlyId(), itemId = npc.head}
	end
	-- 上装
	if npc.cloth and #tostring(npc.cloth) > 0 then
		equips.cloth = {id = Helper:getOnlyId(), itemId = npc.cloth}
	end
	-- 腰带
	if npc.belt and #tostring(npc.belt) > 0 then
		equips.belt = {id = Helper:getOnlyId(), itemId = npc.belt}
	end
	-- 手部
	if npc.hand and #tostring(npc.hand) > 0 then
		equips.hand = {id = Helper:getOnlyId(), itemId = npc.hand}
	end
	-- 下装
	if npc.pants and #tostring(npc.pants) > 0 then
		equips.pants = {id = Helper:getOnlyId(), itemId = npc.pants}
	end
	-- 鞋子
	if npc.shoes and #tostring(npc.shoes) > 0 then
		equips.shoes = {id = Helper:getOnlyId(), itemId = npc.shoes}
	end
	-- 戒指
	if npc.ring and #tostring(npc.ring) > 0 then
		equips.ring = {id = Helper:getOnlyId(), itemId = npc.ring}
	end
	-- 腰坠
	if npc.yaozhui and #tostring(npc.yaozhui) > 0 then
		equips.yaozhui = {id = Helper:getOnlyId(), itemId = npc.yaozhui}
	end
	-- 项链
	if npc.necklace and #tostring(npc.necklace) > 0 then
		equips.necklace = {id = Helper:getOnlyId(), itemId = npc.necklace}
	end

	npc.equips = equips

	local prepare = 
	{
		quanjiao1 = npc.quanjiao1 == nil and "jibenquanjiao" or npc.quanjiao1,
		quanjiao2 = npc.quanjiao2,
		neigong = npc.neigong == nil and "jibenneigong" or npc.neigong,
		qinggong = npc.qinggong == nil and "jibenqinggong" or npc.qinggong,
		zhaojia = npc.zhaojia == nil and "jibenzhaojia" or npc.zhaojia,
		jianfa = npc.jianfa == nil and "jibenjianfa" or npc.jianfa,
		daofa = npc.daofa == nil and "jibendaofa" or npc.daofa,
		gunfa = npc.gunfa == nil and "jibengunfa" or npc.gunfa,
		anqi = npc.anqi == nil and "jibenanqi" or npc.anqi,
		shuangchi = npc.shuangchi == nil and "jibenshuangchi" or npc.shuangchi,
		qinfa = npc.qinfa == nil and "jibenqinfa" or npc.qinfa,
	}

	local skills = {}
	--  初始化武功等级
	for k,skillId in pairs(prepare) do
		local skill = 
		{
			id = skillId, 
			exp = Skill:getExp(tonumber(npc.lv / 2))  -- 修改 2016-10-31 XiaoZhiWei 飞贼武功等级减半
		}
		skills[skillId] = skill
		-- table.insert(skills, skill)
	end

	-- 初始化基本类武功等级
	for k,v in pairs(prepare) do
		if k == "quanjiao1" then
			k = "quanjiao"
		end

		if k ~= "quanjiao2" then
			local id = "jiben"..k
			local skill = 
			{
				id = id,
				exp = Skill:getExp(tonumber(npc.lv))
			}
			skills[id] = skill
		end
	end

	npc.skillPrepare = prepare
	npc.skills = skills
	return npc
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/03/08 16:11:57
-- @desc 初始化NPC准备招式和技能
function Npc:initSkillAndPrepareSkill(role)
	if MapIsEmpty(role) == true then
		return
	end
	local params = {lv = User:getRoleAttr("lv")}
	local prepare = 
	{
		quanjiao1 = role.quanjiao1 == nil and "jibenquanjiao" or role.quanjiao1,
		quanjiao2 = role.quanjiao2,
		neigong = role.neigong == nil and "jibenneigong" or role.neigong,
		qinggong = role.qinggong == nil and "jibenqinggong" or role.qinggong,
		zhaojia = role.zhaojia == nil and "jibenzhaojia" or role.zhaojia,
		jianfa = role.jianfa == nil and "jibenjianfa" or role.jianfa,
		daofa = role.daofa == nil and "jibendaofa" or role.daofa,
		gunfa = role.gunfa == nil and "jibengunfa" or role.gunfa,
		anqi = role.anqi == nil and "jibenanqi" or role.anqi,
		bianfa = role.bianfa == nil and "jibenbianfa" or role.bianfa,
		shuangchi = role.shuangchi == nil and "jibenshuangchi" or role.shuangchi,
		qinfa = role.qinfa == nil and "jibenqinfa" or role.qinfa,
	}
	
	local skills = {}
	local prepareList = {"quanjiao", "neigong", "qinggong", "zhaojia", "jianfa", "daofa", "gunfa", "anqi", "bianfa", "shuangchi", "qinfa"}
	-- 初始化基本类武功等级
	for k,v in pairs(prepareList) do
		local id = "jiben"..v
		local skill =
		{
			id = id,
			exp = Skill:getExp(tonumber(role.lv))
		}
		skills[id] = skill
	end
	
	for i=1,100 do
		if role["skill"..tostring(i)] ~= nil and role["skillLv"..tostring(i)] ~= nil then
			skills[ role["skill"..tostring(i)] ] = 
			{
				id = role["skill"..tostring(i)],
				exp = Skill:getExp( Helper:GetValueFromScript(role["skillLv"..tostring(i)], params) )  -- add by XiaoZhiWei 2017/03/08 12:07:13 武功等级公式自定义填写
			}
		else
			-- if role["skill"..tostring(i)] ~= nil and DEBUG_MODE == 1 then
			-- 	assert(nil, "副本["..tostring(self.name).."] NPC ["..tostring(role.name).."] 技能未填写等级 -- > "..tostring(role["skill"..tostring(i)]))
			-- end
		end
	end

	role.skillPrepare = prepare
	role.skills = skills

	-- add by XiaoZhiWei 2017/03/08 12:07:45 检查程序,检查准备的武功是否存在在武功列表中
	if DEBUG_MODE == 1 then
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/03/08 16:16:15
-- @desc 初始化NPC属性
function Npc:initRoleAttr(role)
	if MapIsEmpty(role) == true then
		return
	end

	local params = {lv = User:getRoleAttr("lv")}
	role.age = Helper:GetValueFromScript(role.age)				-- 年龄
	role.looks = Helper:GetValueFromScript(role.looks)			-- 容貌
	role.jiaLi = Helper:GetValueFromScript(role.jiaLi, params)	-- 加力
	role.weapon = Helper:getRandomString(role.weapon)					-- 武器
	role.qi = Helper:GetValueFromScript(role.qi, params)		-- 气血
	role.neili = Helper:GetValueFromScript(role.neili, params)	-- 内力
	role.str = Helper:GetValueFromScript(role.str, params)		-- 臂力
	role.con = Helper:GetValueFromScript(role.con, params)		-- 根骨
	role.dex = Helper:GetValueFromScript(role.dex, params)		-- 身法
	role.int = Helper:GetValueFromScript(role.int, params)		-- 悟性
	role.lv = Helper:GetValueFromScript(role.lv, params)		-- 等级
	role.exp = Helper:GetValueFromScript(role.exp, params)		-- 经验

	role.quanjiao1 = Helper:getRandomString(role.quanjiao1)			-- 拳脚
	role.zhaojia = Helper:getRandomString(role.zhaojia)				-- 招架
	role.qinggong = Helper:getRandomString(role.qinggong)			-- 轻功
	role.neigong = Helper:getRandomString(role.neigong)				-- 内功
	role.jianfa = Helper:getRandomString(role.jianfa)					-- 剑法
	role.daofa = Helper:getRandomString(role.daofa)					-- 刀法
	role.anqi = Helper:getRandomString(role.anqi)						-- 暗器
	role.gunfa = Helper:getRandomString(role.gunfa)						-- 棍法
	role.bianfa = Helper:getRandomString(role.bianfa)					-- 鞭法
	role.shuangchi = Helper:getRandomString(role.shuangchi)					-- 双持
	role.qinfa = Helper:getRandomString(role.qinfa)					-- 琴法

	role.qiMax = role.qi
	role.neiliMax = role.neili
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/03/08 11:35:17
-- @desc 初始化副本角色 (属性可填写公式)
function Npc:initRoleWithRandomAttr(role)
	if MapIsEmpty(role) == true then
		return
	end
	self:initRoleAttr(role)
	self:initSkillAndPrepareSkill(role)
end


--@desc: 初始化 NPC 属性数据，但不创建Role类 ，role：create()将用在副本中进入房间时调用。
--@author:Liang SongQiang
--@time:2018-12-06 15:07:32
function Npc:initNpc(npc)
	if MapIsEmpty(npc) then
		return
	end

	self:fixAttr(npc)

	self:initNpcAttr(npc)

	self:initItemsAndEquips(npc)

	self:initSkillsAndPrepare(npc)

	self:initNpcActiveZhao(npc)

	npc.isNpc = true

	return npc
end


--@desc: npc 属性的修复 
--@author:Liang SongQiang
--@time:2018-12-06 15:16:21
function Npc:fixAttr(npc)
	if MapIsEmpty(npc) then
		return
	end

	if npc.type == nil then
		npc.type = npc.unitType
	end

	npc.unitType = nil

	npc.canSee = npc.isVisible or 1
	
	npc.isVisible = nil

	npc.baseId = npc.id

	if npc.jiali then
		npc.jiaLi = npc.jiali
	end

	--@desc 编辑器导出字段
	if npc.sav ~= nil then
		npc.int = npc.sav
		npc.sav = nil
	end
	
	if npc.words and type(npc.words) == "string" then
		npc.words = string.split(npc.words,";") 
	end

	--add by LvBin 2019/12/06 17:29:13 修复部分资源表轻功字段少了个g
	if npc.qinggong == nil and npc.qingong then
		npc.qinggong = npc.qingong
	end
end

--@desc: 初始化NPC基本属性 
--@author:Liang SongQiang
--@time:2018-12-06 15:21:58
function Npc:initNpcAttr(npc)
	if MapIsEmpty(npc) then
		return
	end

	if npc.lv == nil then
		npc.lv = 1
	end

	if npc.exp == nil and tonumber(npc.lv) ~= nil then
		npc.exp = math.ceil(0.1 * (tonumber(npc.lv)+4) ^ 3+1)
	end
	
	local params = {lv = User:getRoleAttr("lv")}
    npc.age = tonumber(Helper:GetValueFromScript(npc.age))				-- 年龄
	npc.looks = tonumber(Helper:GetValueFromScript(npc.looks))			-- 容貌
	npc.jiali = tonumber(Helper:GetValueFromScript(npc.jiali,params))	-- 加力
	npc.weapon = Helper:getRandomString(npc.weapon)					-- 武器
	npc.qi = tonumber(Helper:GetValueFromScript(npc.qi, params))		-- 气血
	npc.neili = tonumber( Helper:GetValueFromScript(npc.neili, params))	-- 内力
	npc.str = tonumber(Helper:GetValueFromScript(npc.str, params))		-- 臂力
	npc.con = tonumber(Helper:GetValueFromScript(npc.con, params))		-- 根骨
	npc.dex = tonumber(Helper:GetValueFromScript(npc.dex, params))		-- 身法
	npc.int = tonumber(Helper:GetValueFromScript(npc.int, params))		-- 悟性
	npc.lv = tonumber(Helper:GetValueFromScript(npc.lv, params))		-- 等级
	npc.exp = tonumber(Helper:GetValueFromScript(npc.exp, params))		-- 经验

	npc.quanjiao1 = Helper:getRandomString(npc.quanjiao1)			-- 拳脚
	npc.zhaojia = Helper:getRandomString(npc.zhaojia)				-- 招架
	npc.qinggong = Helper:getRandomString(npc.qinggong)				-- 轻功
	npc.neigong = Helper:getRandomString(npc.neigong)				-- 内功
	npc.jianfa = Helper:getRandomString(npc.jianfa)					-- 剑法
	npc.daofa = Helper:getRandomString(npc.daofa)					-- 刀法
	npc.anqi = Helper:getRandomString(npc.anqi)						-- 暗器
	npc.bianfa = Helper:getRandomString(npc.bianfa)					-- 鞭法
	npc.shuangchi = Helper:getRandomString(npc.shuangchi)					-- 双持
	npc.qinfa = Helper:getRandomString(npc.qinfa)					-- 琴法
    
    
	npc.jiaLi = tonumber(npc.jiali) == nil and 0 or tonumber(npc.jiali)
	npc.qiMax = tonumber(npc.qi) == nil and 100 or tonumber(npc.qi)
	npc.neiliMax = tonumber(npc.neili) == nil and 50 or tonumber(npc.neili)
end

local cloneNpc
function Npc:initItemsAndEquips(npc)
    if MapIsEmpty(npc) then
        return
	end

	if cloneNpc == nil then
		cloneNpc = Role:create()
	end
	
	cloneNpc.items = {}
	
	if npc._version == EDITOR_MAP_VERSION then
		if MapIsEmpty(npc.items) ~= true then
			--@desc 编辑器副本结构
			for i, item in ipairs(npc.items) do
				if item.itemId and item.count > 0 then
					local createSafeItem = {
						id = cloneNpc:getItemOnlyId(),
						itemId = item.itemId,
						count = item.count
					}
					table.insert(cloneNpc.items, cloneNpc:createSafeItem(createSafeItem))
				end
			end
		end
	else
		npc.items = {}
		for i=1,10 do
			local items = npc["item"..i]
			local itemId, count
			if items and type(items) == "string" then
				local start = string.find(items, ",")
				if start then
					itemId = string.sub(items, 0 , start -1)
					count = tonumber(string.sub(items, start + 1, #items))
				else
					itemId = items
					count = 1
				end
			end
			if itemId then
				-- add by XiaoZhiWei 2017/08/09 17:39:31 书页类型会直接添加到书箱,所以需要用插入
				local item = {id = cloneNpc:getItemOnlyId(), count = count , itemId = itemId}
				table.insert(cloneNpc.items, cloneNpc:createSafeItem(item))
			else
				break
			end
		end
	end
	
    -- 身上穿戴的也要存入背包
	local equips = {}
	
	if npc.weapon and #tostring(npc.weapon) > 0 then
		equips.weapon = {id = cloneNpc:getItemOnlyId(), itemId = npc.weapon}
		-- npc.weapon = nil
    end
    -- 头帽
    if npc.head and #tostring(npc.head) > 0 then
		equips.head = {id = cloneNpc:getItemOnlyId(), itemId = npc.head}
		-- npc.head = nil
    end
    -- 上装
    if npc.cloth and #tostring(npc.cloth) > 0 then
		equips.cloth = {id = cloneNpc:getItemOnlyId(), itemId = npc.cloth}
		-- npc.cloth = nil
    end
    -- 腰带
    if npc.belt and #tostring(npc.belt) > 0 then
		equips.belt = {id = cloneNpc:getItemOnlyId(), itemId = npc.belt}
		-- npc.belt = nil
    end
    -- 手部
    if npc.hand and #tostring(npc.hand) > 0 then
		equips.hand = {id = cloneNpc:getItemOnlyId(), itemId = npc.hand}
		-- npc.hand = nil
    end
    -- 下装
    if npc.pants and #tostring(npc.pants) > 0 then
		equips.pants = {id = cloneNpc:getItemOnlyId(), itemId = npc.pants}
		-- npc.pants = nil
    end
    -- 鞋子
    if npc.shoes and #tostring(npc.shoes) > 0 then
		equips.shoes = {id = cloneNpc:getItemOnlyId(), itemId = npc.shoes}
		-- npc.shoes = nil
    end
    -- 戒指
    if npc.ring and #tostring(npc.ring) > 0 then
		equips.ring = {id = cloneNpc:getItemOnlyId(), itemId = npc.ring}
		-- npc.ring = nil
    end
    -- 腰坠
    if npc.yaozhui and #tostring(npc.yaozhui) > 0 then
		equips.yaozhui = {id = cloneNpc:getItemOnlyId(), itemId = npc.yaozhui}
		-- npc.yaozhui = nil
    end
    -- 项链
    if npc.necklace and #tostring(npc.necklace) > 0 then
		equips.necklace = {id = cloneNpc:getItemOnlyId(), itemId = npc.necklace}
		-- npc.necklace = nil
	end
	
	npc.equips = equips

	for part,v in pairs(equips) do
		if not v or not v.itemId then
		else
			local item = {id = v.id, count = 1 , itemId = v.itemId}
			table.insert(cloneNpc.items, cloneNpc:createSafeItem(item))
			-- cloneNpc:addItemCount(v.itemId, 1)
		end
	end

	npc.items = cloneNpc.items
end

--@desc: 旧副本初始化 
--@author:Liang SongQiang
--@time:2018-12-06 16:27:46
function Npc:initSkillsAndPrepare(npc)
	local params = {lv = User:getRoleAttr("lv")}

	local prepareList = {"quanjiao", "neigong", "qinggong", "zhaojia", "jianfa", "daofa", "gunfa", "anqi", "shuangchi", "qinfa"}
	
	--[[
		准备拳脚1,
        准备拳脚2,
        准备内功,
        准备轻功,
        准备招架,
        准备刀法,
        准备剑法,
        准备棍法,
        准备鞭法,
        准备暗器,
        准备双持,
        准备琴法,
	]]
	local enum = {
		[0] = "quanjiao1",
		[1] = "quanjiao2",
		[2] = "neigong",
		[3] = "qinggong",
		[4] = "zhaojia",
		[5] = "daofa",
		[6] = "jianfa",
		[7] = "gunfa",
		[8] = "bianfa",
		[9] = "anqi",
		[10] = "shuangchi",
		[11] = "qinfa",
	}
	if npc._version == EDITOR_MAP_VERSION then
		
		local prepareMap = {}
		
		local skills = {}
		
		for i,skillData in ipairs(npc.skillPrepare) do
			local skillType = enum[skillData.preSkillType]

			if skillType == "quanjiao1" or skillType == "quanjiao2" then
				skillType = "quanjiao"
			end

			if skillData.skillId ~= "jiben"..skillType then
				skills["jiben"..skillType] = {
					id = "jiben"..skillType,
					exp = Skill:getExp(tonumber(Helper:GetValueFromScript(skillData.lv, params))) 
				}
			end

			skills[skillData.skillId] = {
				id = skillData.skillId,
				exp = Skill:getExp(tonumber(Helper:GetValueFromScript(skillData.lv, params))) 
			}
			
			prepareMap[enum[skillData.preSkillType]] = skillData.skillId
		end

		npc.skillPrepare = prepareMap

		for i,v in ipairs(prepareList) do
			local id = "jiben"..v
			if skills[id] == nil then
				local skill = {
					id = id,
					exp = Skill:getExp(tonumber(npc.lv))
				}
				skills[id] = skill
			end
		end

		npc.skills = skills

		return
	end
	
	local prepareList = {"quanjiao", "neigong", "qinggong", "zhaojia", "jianfa", "daofa", "gunfa", "anqi", "shuangchi","bianfa","qinfa"}
    -- 武功初始化
    local prepare = {
        quanjiao1 = npc.quanjiao1 == nil and "jibenquanjiao" or npc.quanjiao1,
        quanjiao2 = npc.quanjiao2,
        neigong = npc.neigong == nil and "jibenneigong" or npc.neigong,
        qinggong = npc.qinggong == nil and "jibenqinggong" or npc.qinggong,
        zhaojia = npc.zhaojia == nil and "jibenzhaojia" or npc.zhaojia,
        jianfa = npc.jianfa == nil and "jibenjianfa" or npc.jianfa,
        daofa = npc.daofa == nil and "jibendaofa" or npc.daofa,
        gunfa = npc.gunfa == nil and "jibengunfa" or npc.gunfa,
		anqi = npc.anqi == nil and "jibenanqi" or npc.anqi,
		bianfa = npc.bianfa == nil and "jibenbianfa" or npc.bianfa,
        shuangchi = npc.shuangchi == nil and "jibenshuangchi" or npc.shuangchi,
        qinfa = npc.qinfa == nil and "jibenqinfa" or npc.qinfa
    }
    npc.skillPrepare = prepare

    local skills = {}


    -- 初始化基本类武功等级
    for k, v in pairs(prepareList) do
        local id = "jiben" .. v
        local skill = {
            id = id,
            exp = Skill:getExp(tonumber(npc.lv))
        }
        skills[id] = skill
    end

    for i = 1, 20 do
        if npc["skill" .. tostring(i)] ~= nil and npc["skillLv" .. tostring(i)] ~= nil then
            skills[npc["skill" .. tostring(i)]] = {
                id = npc["skill" .. tostring(i)],
                exp = Skill:getExp(Helper:GetValueFromScript(npc["skillLv" .. tostring(i)], params)) -- add by XiaoZhiWei 2017/03/08 12:07:13 武功等级公式自定义填写
            }
        else
            -- if role["skill"..tostring(i)] ~= nil and DEBUG_MODE == 1 then
            -- 	assert(nil, "副本["..tostring(self.name).."] NPC ["..tostring(role.name).."] 技能未填写等级 -- > "..tostring(role["skill"..tostring(i)]))
            -- end
        end
    end

    npc.skills = skills
end

function Npc:initNpcActiveZhao(npc)
	npc.preparedActiveZhao = {
		bingqi = {},
		quanjiao = {}
	}

	local bingqi = {}
	local quanjiao = {}

	for i=1,10 do
		local activeZhaoId = npc["activeZhao"..tostring(i)]
		if activeZhaoId ~= nil and activeZhaoId ~= "" and type(activeZhaoId) == "string" then
			local activeZhao = Skill:getActiveZhao(activeZhaoId)

			local skillId = Skill:getSkillIdByZhaoId(activeZhaoId)
			local skill = Skill:getSkill(skillId)
			
			local skillMethods = skill.methods

			local npcWeaponType
			
			if MapIsEmpty(npc.equips) == false and npc.equips.weapon ~= nil then
				npcWeaponType = Item:getOneItemByKey(npc.equips.weapon.itemId).type
			end

			local function getCurrTypeByWeapon(wtype)
				if wtype == "刀" then
					return SKILL_METHOD_TYPE_DAO
				elseif wtype == "剑" then
					return SKILL_METHOD_TYPE_JIAN
				elseif wtype == "暗器" then
					return SKILL_METHOD_TYPE_ANQI
				elseif wtype == "棍" then
					return SKILL_METHOD_TYPE_GUN
				elseif wtype == "鞭" then
					return SKILL_METHOD_TYPE_BIANFA
				elseif wtype == "双持" then
					return SKILL_METHOD_TYPE_SHUANGCHI
				elseif wtype == "乐器" then
					return SKILL_METHOD_TYPE_QIN
				else
					return SKILL_METHOD_TYPE_QUANJIAO
				end
			end
			

			--@desc 目前所有主动技能methods属性只有一个method，所以直接取1
			local aMethods = activeZhao.methods[1]
			if aMethods == 1  then
				table.insert( quanjiao,activeZhaoId )
				table.insert( bingqi,activeZhaoId )
			elseif aMethods == 5 then
				local currEqWeaponType
				if npcWeaponType  then
					currEqWeaponType = getCurrTypeByWeapon(npcWeaponType)
				end
				
				local isPrepare = false
				
				for i,method in ipairs(skillMethods) do
					if method == currEqWeaponType then
						isPrepare = true
					end
				end
				
				if isPrepare then
					table.insert( bingqi,activeZhaoId )
				end
			elseif aMethods == 2 or aMethods == 3 or aMethods == 4 then
				table.insert( bingqi,activeZhaoId )
				table.insert( quanjiao,activeZhaoId )
			end
		end

		
		for i,id in ipairs(bingqi) do
			npc.preparedActiveZhao.bingqi["zhaoshi"..tostring(i)] = id
		end
		
		for i,id in ipairs(quanjiao) do
			npc.preparedActiveZhao.quanjiao["zhaoshi"..tostring(i)] = id
		end
	end
end

--@desc:初始化人物状态，是否可见 等等
--@author:Liang SongQiang
--@time:2019-01-24 17:16:09
function Npc:initRoleIsForbidden(npc)

	if npc.startValidTime == nil then
		npc.startValidTime = "20160701;12"
	end
	if npc.endValidTime == nil then
		npc.endValidTime = "20360701;24"
	end

	local stratTimeArray = string.split(tostring(npc.startValidTime), ";")
	local stratDate = stratTimeArray[1]
	local stratHour = Helper:getDef(stratTimeArray[2],"12")
	local stratMinute = Helper:getDef(stratTimeArray[3],"00")

	local endTimeArray = string.split(tostring(npc.endValidTime), ";")
	local endDate = endTimeArray[1]
	local endHour = Helper:getDef(endTimeArray[2],"24")
	local endMinute = Helper:getDef(endTimeArray[3],"00") 

	local nowTime = GetTime()
	local stratTime,endTime

	if type(tonumber(stratDate)) == "number" then
		stratTime = Helper:getTimeStampWithStringDate(tostring(stratDate), tonumber(stratHour)) + tonumber(stratMinute)*60
	elseif stratDate == "nowDate" then
		stratTime = tonumber(Helper:getDayTime(nowTime)) + tonumber(stratHour)*3600 + tonumber(stratMinute)*60
	else
		print("日期格式填错")
		return
	end

	if type(tonumber(endDate)) == "number" then
		endTime = Helper:getTimeStampWithStringDate(tostring(endDate), tonumber(endHour)) + tonumber(endMinute)*60
	elseif stratDate == "nowDate" then
		endTime = tonumber(Helper:getDayTime(nowTime)) + tonumber(endHour)*3600 + tonumber(endMinute)*60
	else
		print("日期格式填错")
		return
	end
	
	-- 当前时间在 显示时间范围内

	if nowTime >= stratTime and nowTime <= endTime then
		npc.isForbidden = false
	else
		npc.isForbidden = true
	end
end


function Npc:initSalesItem(npc)

	-- if npc and (npc.canSale == 1 or npc.canSale == true) and npc.saleList and type(npc.saleList) == "string" then
	if npc then
		--@desc 出售列表
		if npc.saleList and type(npc.saleList) == "string" and npc.saleList ~= "" then
			local items = string.split(npc.saleList, ";")
			if npc.type == "item" then
				npc.items = items
			else
				--@desc 是否商人的标识
				npc.canSale = true
				for k,v in pairs(items) do
					--增加对能否获取物品的判断
					if not npc:addItemCount(v, 1) then
						return
					end
				end
			end
			npc.saleList = nil
		end
	end
end

return Npc0000000000000