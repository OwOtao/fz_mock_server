local Role_Inherit = {}

-----------------------------传承-----------------------------
-- 创建传承角色
function Role_Inherit:createInheritRole()
	-- 获得需要继承的属性
	local NeedInheritAttr =
	{
	}

	local NeedInheritAttrKey =
	{
		[1] = "looks", 				-- 长相
		[2] = "luck",  				-- 福缘
		[3] = "shenBingweapon",		-- 神兵
		[4] = "str",   				-- 臂力
		[5] = "int",   				-- 悟性
		[6] = "con",   				-- 根骨
		[7] = "dex",   				-- 身法
		[8] = "money",    			-- 碎银
		[9] = "gold",  				-- 黄金
		[10] = "weight",			-- 背包大小
		[11] = "ckLimit",   		-- 仓库大小
		[12] = "yueli",				-- 江湖阅历
		[13] = "qiyujingCount",		-- 奇遇事件获得精力上限次数，上限13次
		[14] = "items",				-- 物品
		[15] = "ckitems",			-- 仓库
		[16] = "jing",			    -- 当前精力
		[17] = "shuxiang",		    -- 武功书页
		[18] = "decorative",	    -- 装饰箱
		[19] = "portrait",		    -- 头像
		[20] = "zhaoShuXiang",	    -- 秘籍残页
		[21] = "_inherit_flags",    -- 可传承标记
		[22] = "decorativeLimit",	-- 装饰箱容量
		[23] = "literaryBox",		-- 百家典籍
		[24] = "leftRightFightExp",	-- 左右互搏熟练度
		[25] = "prayRoomId",        --七夕活动分组房间
		[26] = "openMark",          --七夕应援是否开启
		[27] = "equipsBox",			-- 装备箱
		[28] = "shenBingItems",      --神兵
		[29] = "medicinalBox",		--药囊
		[30] = "collectScore",      --收藏积分
		[31] = "titles",		--称号
		[32] = "candyData",		--唐人玩法记录
		[33] = "forgeCount",        --打造神兵次数
		[34] = "repairXuanBingDong",        --神兵修复，只修复一次。
		[35] = "repairShenBing",        --神兵修复，只修复一次。
		[36] = "qx2018",        --2018七夕活动。
		[37] = "Homeland",
		[38] = "DispatchTask",          --派遣任务
		[39] = "cwItems",               --仓库物品
		[40] = "wUpCount",               --仓库上限
		[41] = "ckUpCount",               --仓库上限
		[42] = "smeltBox",		--冶炼箱
		[43] = "nodeRewards",      -- 节点奖励
		[44] = "seeSkills",      -- 见闻武学
		[45] = "jiaRenData",		--假人数据
		[46] = "DreamTalent",		--天赋
		[47] = "borderVer",		-- 边框数据版本
		[48] = "skillSysVer",		-- 技能系统版本
		[49] = "basicTitleData",   --称号
		[50] = "hiddenMeridianData",   --隐脉数据
	}
	-----------------------------------------------------------------------------------------------------------

	--先天属性使用先天之资
	local NaturalAttrAdjustmentConst = require("app.models.role.attr.NaturalAttributePlan.NaturalAttrAdjustmentConst")
	local planData = User:getRole():getAndInitNaturalAttrAdjustmentPlanData()
	local basePlan = planData.planDict[NaturalAttrAdjustmentConst.PLAN_TYPE.BASE_PLAN]

	for k,v in ipairs(NeedInheritAttrKey) do
		if table.keyof(NaturalAttrAdjustmentConst.ATTR_TYPE, v) then
			NeedInheritAttr[v] = basePlan[v]
		else
			NeedInheritAttr[v] = User:getRoleAttr(v)
		end
	end

	local userid = User:getRoleAttr("inherit").userid

	local Role = require("app.models.role.Role")
	local role = Role:create()

	Helper:tableCover(role, NeedInheritAttr)

	---------------------------传承删除状态为未领取的神兵
	local shenBingItems = role:getAttr("shenBingItems")
	for i = #shenBingItems,1,-1 do 
		if shenBingItems[i].status ~= 3 then
			table.remove(shenBingItems,i)
		end
	end

	local bagItems = role:getItems()--删除背包中的神书
	local itemRecords = {}
	local bookList = {"shenshu100","shenshu101","shenshu102","shenshu103","shenshu104","shenshu105","shenshu106","shenshu107","shenshu108","shenshu109","shenshu110","shenshu111"}

	for i = #bagItems, 1, -1 do
		local itemAttr = role:getOneItemByKey(bagItems[i].itemId)
		if itemAttr.type == "神书" then
			itemRecords[bagItems[i].itemId] = bagItems[i].count
			table.remove(bagItems, i)
		elseif itemAttr.type == "师门任务" then--师门任务道具不传承
			itemRecords[bagItems[i].itemId] = bagItems[i].count
			table.remove(bagItems, i)
		elseif itemAttr.id=="item201_17new21" then --删除祭品
			itemRecords[bagItems[i].itemId] = bagItems[i].count
			table.remove(bagItems, i)
		elseif itemAttr.type == "历练任务" then  --任务物品道具不传承	
			itemRecords[bagItems[i].itemId] = bagItems[i].count
			table.remove(bagItems, i)  
		else
			for k,v in ipairs(bookList) do
				if bagItems[i].itemId == v then
					itemRecords[bagItems[i].itemId] = bagItems[i].count
					table.remove(bagItems, i)
					break
				end
			end
		end
	end

	local ckItems = role:getckItems() ----删除仓库中的神书

	for i=#ckItems,1,-1 do
		local itemAttr = role:getOneItemByKey(ckItems[i].itemId)
		if itemAttr.type == "神书" then
			itemRecords[ckItems[i].itemId] = ckItems[i].count
			table.remove(ckItems, i)
		elseif itemAttr.type == "师门任务" then--师门任务道具不传承
			itemRecords[ckItems[i].itemId] = ckItems[i].count
			table.remove(ckItems, i)
		else
			for k,v in ipairs(bookList) do
				if ckItems[i].itemId == v then
					itemRecords[ckItems[i].itemId] = ckItems[i].count
					table.remove(ckItems, i)
					break
				end
			end
		end
	end

	if MapIsEmpty(itemRecords) == false then
		Record:addLog(Record.LOG_TYPE.ITEM, itemRecords, "传承移除")
	end

	if self:checkRoleIsPolymorph() then
		role:setAttr("looks",self.polymorph.lastLooks)
	end

	-- 设置新角色属性
	role:setAttr("name", User:getRoleAttr("inherit").name)
	role:setAttr("sex", User:getRoleAttr("inherit").sex)
	role:setAttr("inheritCount", User:getRoleAttr("inheritCount") + 1)
	role:setAttr("userid", tonumber(userid))
	role:setAttr("zhengqi", User:getRoleAttr("inherit").zhengqi)
	role:setFlag("传送孤家集", 1)
	role:setAttr("weight", User:getRoleAttr("weight"))
	role:setAttr("ckLimit", User:getRoleAttr("ckLimit"))
	local flagList =
	{
		"惊鸿燕任务次数",
		"萧子远任务次数",
		"初心未泯",
		"鬼面人任务",
		"左右互搏可开启",
	}

	for i,v in ipairs(flagList) do
		if User:getRole():getFlag(v) ~= 0 then
			role:setFlag(v, User:getRole():getFlag(v))
		end
	end

	local dayFlagList =
	{
		"萧子远任务可接",
		"惊鸿燕任务可接",
	}

	for i,v in ipairs(dayFlagList) do
		if User:getRole():getDayFlag(v) ~= 0 then
			role:setDayFlag(v, User:getRole():getDayFlag(v))
		end
	end

	-- 当前精力值 最低为100
	if role:getAttr("jing") < 100 then
		role:setAttr("jing", 100)
		print("精力小于100时设置精力:", self:getNumAttr("jing"))
	end

	-- 当前经验超出传承所需经验部分 1/10转化为潜能
	--@desc 2019-01-09 10:27:12 公式修改 1/12转化
	local exp = User:getRole():GetInheritNeedExp()
	local pot = math.floor((User:getRoleAttr("exp") - exp) / 12)
	role:addAttr("pot", pot)

	-- 保留角色所学江湖技能
	local bookSkills = require("app.models.book.BookSkills")
	local jianghuSkills = clone(bookSkills:getbookSkill())
	for index,skill in pairs(jianghuSkills) do 
        if skill and skill.belong == 1 then --剔除门派技能 1为门派
            jianghuSkills[index] = nil
        end
    end
	local parentSkills = {}

	for k,v in pairs(jianghuSkills) do
		local skill = User:getRole():getSkill(v.skillId)
		if skill then
			table.insert(parentSkills, {id = skill.id, exp = math.ceil(skill.exp)})
		end
	end

	-- 百家典籍全部重置为一级
	local literaryBox = role:getAttr("literaryBox")
	for i,v in ipairs(literaryBox) do
		literaryBox[i].exp = 1
	end
	role:setAttr("literaryBox", literaryBox)

	-- 保存历代传承人名字和时间
	local inheritHistory = clone(User:getRoleAttr("inheritHistory"))
	table.insert(inheritHistory,
		{
			parentName = User:getRoleAttr("name"), 	-- 当前角色姓名
			inheritName = role:getAttr("name"),		-- 继承人姓名
			inheritTime = GetTime(),				-- 继承时间
			retireMap = 5,							-- 当前角色隐退副本
			parentDsc = "",							-- 当前角色描述
			parentSkills = parentSkills,			-- 当前角色所学的江湖技能
			zhengqiState = 1,						-- 论道状态
		})

	role:setAttr("inheritHistory", inheritHistory)
	

	--@desc 节点奖励(传承时需保留一次性奖励)
	local nodeRewards = role:getAttr("nodeRewards")
	if MapIsEmpty(nodeRewards) == false then
		for id, reward_type in pairs(nodeRewards) do
			if reward_type ~= NODE_REWARD_ONLY then
				nodeRewards[id] = nil
			end
		end
	end

	-- 基本技能50级
	local skills =
	{
		jibenquanjiao = {id = "jibenquanjiao", exp = 1876},
		jibenzhaojia = {id = "jibenzhaojia", exp = 1876},
		jibenqinggong = {id = "jibenqinggong", exp = 1876},
		jibenneigong = {id = "jibenneigong", exp = 1876},
	}

	role:setAttr("skills", skills)

	
	--走穴经
	local zouxueshisijing = User:getRole():getSkill("zouxueshisijing")
	if zouxueshisijing then
		local skillLv = self:getSkillLv("zouxueshisijing")
		if skillLv < 100 then
			role:setSkill("zouxueshisijing", {id = "zouxueshisijing", exp = math.ceil(zouxueshisijing.exp)})
		else
			role:setSkill("zouxueshisijing", {id = "zouxueshisijing", exp = math.max(math.ceil(zouxueshisijing.exp / 2),15001)})
		end
	end

	--@desc 添加传承保留的buff
	User:getRole():addRoleInheritBuffs(role)

	
	--[[   --传承保留所有经验

		changshengjue 长生诀
		changshengjueyin 长生诀阴
		changshengjueyang 长生诀阳
		yirongshu 易容术
		shenzhaojing003 神照经-神照
		shenzhaojing002	神照经-坐照
		shenzhaojing001 神照经-入神
		dankuixuangong 丹匮玄功
	]]

	--传承保留所有经验技能
	local inheritAllExpSkills={
		"changshengjue",
		"changshengjueyin",
		"changshengjueyang",
		"yirongshu",
		"shenzhaojing003",
		"shenzhaojing002",
		"shenzhaojing001",
		"dankuixuangong",
		"zhougongzhishu",
	}
	for index,skillId in ipairs(inheritAllExpSkills) do
		local currSkill = User:getRole():getSkill(skillId)
		if currSkill then
			role:setSkill(skillId, {id = skillId, exp = math.ceil(currSkill.exp)})
		end
	end


	--[[   --传承保留50%经验

		dushushizi 读书识字
		wuxingdunfa 五行遁法
		jianghudushu 江湖毒术
		zhongzhizhishu 种植之术
		duanzaozhishu 锻造之术

		xiangmashu 相马术
		zhanxingshu 占星术
		zhuizongshu 追踪术
		lubanshu 鲁班术
		xiangmianshu 相面术
		wuzuoshu 仵作术
		qihuangzhishu 岐黄之术
		mojiajiguanshu 墨家机关术
		miaosuanzhishu 庙算之术
	]]
	
	local SkillConst = require("app.models.skill.SkillConst")
	local xisuijingId = SkillConst:getZhiShiSkillParamContent(SkillConst.ZhiShiSkillParams.SKILLID_TRANSFORM)
	local meridianSkillId = SkillConst:getZhiShiSkillParamContent(SkillConst.ZhiShiSkillParams.SKILLID_MERIDIAN)
	local pointSwitchSkillId = SkillConst:getZhiShiSkillParamContent("skillID_pointSwitch")

	--传承保留50%经验技能
	local inheritHalfExpSkills={
		"dushushizi",
		"jianghudushu",
		"zhongzhizhishu",
		"duanzaozhishu",
		"wuxingdunfa",
		"xiangmashu",
		"zhanxingshu",
		"zhuizongshu",
		"lubanshu",
		"xiangmianshu",
		"wuzuoshu",
		"qihuangzhishu",
		"mojiajiguanshu",
		"miaosuanzhishu",
		"zhengaoxuanjing",
		"liandanshu",
		"wumuyishu",
		xisuijingId,
		meridianSkillId,
		pointSwitchSkillId
	}
	for index,skillId in ipairs(inheritHalfExpSkills) do
		local currSkill = User:getRole():getSkill(skillId)
		if currSkill then
			role:setSkill(skillId, {id = skillId, exp = math.ceil(currSkill.exp / 2)})
		end
	end

	do	--称号传承处理
		local TitleHelper = require("app.models.role.titleSystem.TitleHelper")
		TitleHelper:doInheritTitle(role)
	end

	--面具处理
	role:unwearMask()

	--@desc 传承隐脉数据处理,强制停止破境和冲脉
	local hiddenMeridianData = role:getAttr("hiddenMeridianData")
	if MapIsEmpty(hiddenMeridianData) == false then
		if hiddenMeridianData.breakThroughState == true then
			hiddenMeridianData.breakThroughState = false
			hiddenMeridianData.breakThroughFinishTime = 0
		end
		if hiddenMeridianData.acupointActivateState == true then
			hiddenMeridianData.acupointActivateState = false
			hiddenMeridianData.currAcupointId = nil
			hiddenMeridianData.acupointActivateFinishTime = 0
		end
	end

	local HiddenMeridianConstants = require("app.models.Meridian.HiddenMeridianConstants")
	--@RefType [src.app.models.Meridian.HiddenMeridianSystem.HiddenMeridianSystem#HiddenMeridianSystem]
	local HiddenMeridianSystem = require("app.models.Meridian.HiddenMeridianSystem.HiddenMeridianSystem")
	--@RefType [src.app.models.Meridian.HiddenMeridianSystem.HiddenMeridianSystem#HiddenMeridianSystem]
	local hm_sys = HiddenMeridianSystem:create(role)
	hm_sys:initSysData()
	hm_sys:deleteHMBuffByNodal(HiddenMeridianConstants.DeleteBuffNodal.ROLEINHERIT)
	
	role:setAttr("status_tags",  User:getRole():getAllInheritStatusTags())

	local shenShuTask = User:getRole():getAttr("shenShuTask")
	role:setAttr("shenShuTask", {
		count = shenShuTask.count, --当前周期进行神书次数
		allCount = shenShuTask.allCount, --总共进行神书次数
		startTime = shenShuTask.startTime, --任务开始时间
		task = {
			startTime = -1,
			bookDropInfoList = {}, --神书掉落信息
		}
	})
	
	return role
end

-- 获得传承加成
function Role_Inherit:getInheritBuff()
	-- 传承次数加成
	local inheritCount = self.inheritCount
	local buff = 1
	if inheritCount == 0 then
	elseif inheritCount == 1 then
		buff = 1.05
	elseif inheritCount == 2 then
		buff = 1.10
	elseif inheritCount == 3 then
		buff = 1.15
	elseif inheritCount >= 4 then
		buff = 1.20
	end

	return buff
end

-- 获得传承所需要等级
function Role_Inherit:GetInheritNeedExpLv()
	-- 传承次数加成
	local inheritCount = self.inheritCount
	local lv = 600
	if inheritCount == 0 then
		lv = 600
	elseif inheritCount == 1 then
		lv = 700
	elseif inheritCount == 2 then
		lv = 800
	elseif inheritCount == 3 then
		lv = 900
	elseif inheritCount >= 4 then
		lv = 1000
	end

	return lv
end

-- 获得传承所需等级的经验
function Role_Inherit:GetInheritNeedExp()
	local inheritCount = self.inheritCount
	local exp = 22034887
	if inheritCount == 0 then
		exp = 22034887
	elseif inheritCount == 1 then
		exp = 34891367
	elseif inheritCount == 2 then
		exp = 51971847
	elseif inheritCount == 3 then
		exp = 73876327
	elseif inheritCount >= 4 then
		exp = 101204807
	end
	return exp
end

function Role_Inherit:addRoleInheritBuffs(role)
	local buffs = self:getAttr("buffs")
	if MapIsEmpty(buffs) or MapIsEmpty(role) then
		return
	end

	-- 添加物品带来的buff
	local items = self:getItems()
	if MapIsEmpty(items) == false then
		for i,v in ipairs(items) do
			local itemId = v.itemId
			local count = v.count
			local itemAttr = self:getOneItemByKey(itemId)

			if itemAttr and itemAttr.buffid then
				--@desc 能装备的物品不用管
				if itemAttr.canEquip ~= 1 then
					local buffidList = string.split(tostring(itemAttr.buffid),";")
					for i,buffId in ipairs(buffidList) do
						role:addItemBuff(buffId,count)
					end
				end
			end
		end
	end

	--@desc 添加天赋带来的buff
	local DreamTalentTab = self:getAttr("DreamTalent")
	if MapIsEmpty(DreamTalentTab) == false then
		local DreamTalentModel = require("app.models.DreamWorldModel.DreamTalentModel")
		for talentId ,v in pairs(DreamTalentTab) do
			local talent = DreamTalentModel:getTalentAttrById(talentId)
			if talent.drbuffid and talent.drbuffid ~= 0 and talent.talentType == 1 then
				role:addBuffV2(talent.drbuffid)
			end
		end
	end
end

--@desc: 属性界面点击传承按钮时，检查能否进行传承
--@author:LvBin
--@time:2025-03-04 18:20:58
--@return
function Role_Inherit:canInherit()
	if self:getAttr("inheritCount") >= 5 then
		return false,"传承已达上限"
	end

	if self:getHiddenMeridianSystem():getBreakThroughState() then
		return false,"目前处于破境状态中，请取消破境状态后再进行传承"
	end

	if self:getHiddenMeridianSystem():getAcupointActivateState() then
		return false,"目前处于冲脉状态中，请取消冲脉状态后再进行传承"
	end

	return true
end

return Role_Inherit0000000