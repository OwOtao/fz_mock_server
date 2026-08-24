local TuJianUtil = {}
local TuJianTextTab = require("script.others.wxspecimen")["wxtj"]
local StringUtil = require("app.extends.StringUtil")

local BaseTuJianTable = {
        jian ={},
        dao ={},
        gun ={},
        bian ={},
        shuangchi ={},
        anqi ={},
        fu = {},
        qiang = {},
        qin = {},
        zhang ={},
        zhi ={},
        tui ={},
        zhua ={},
        quan ={},
        qinggong = {},
        neigong = {},
        zhaojia = {},
        zhishi = {},
}

local TuJianTable = clone(BaseTuJianTable)

function TuJianUtil:getTujianIndexArray()
    local array = {"jian","dao","gun","bian","shuangchi","anqi","fu","qiang","qin","zhang","zhi","tui","zhua","quan","qinggong","neigong","zhaojia","zhishi"}
    return array
end

function TuJianUtil:getTujianDscList()
    return {
    {score = 0,dsc = "武林拾慧",dsc1 = "你初入武道，尚处于从师拾慧的阶段，在武学的路上你不怕武道遥远，只觉得进一分便有一分的欢喜。" },
    {score = 5001,dsc = "武海泛舟",dsc1 = "你功力渐长，作为武林中的后起之秀已经小有名气，练功学艺时，你越来越觉得武学深奥，自身渺小。" },
    {score = 15001,dsc = "独步武林",dsc1 = "你武功小成，平日里行走江湖少遇敌手，独步武林。练武之时，你渐渐能够化繁为简，融会贯通，渐入佳境，不日便可臻于大道。" },
    -- {score = 40001,dsc = "武学巨擘",dsc1 = "你武功已臻大成，对各路武学均已烂熟于心，信手拈来，如数家珍。对战之时，脑中总是不是闪出一两记妙招。" },
    -- {score = 68001,dsc = "武道宗师",dsc1 = "你武功已达绝顶之境，“术”已非你所求，参悟武道和开创武学才是你心之所向。" }
    }
end

function TuJianUtil:initTuJianTable(skill)
    local wxclassify = skill.wxclassify
    if wxclassify then
        for i,v in ipairs(wxclassify) do
            if type(TuJianTable[v]) == "table" then
                local strWulevel = string.split(skill.wxlevel,",")
                local levelScore = tonumber(strWulevel[i])
                if type(levelScore) ~= "number" then
                    assert(false,"检查技能 = "..skill.id)
                end
                skill.levelScore = levelScore
                table.insert(TuJianTable[v],skill)
            end
        end
    end
end

--获取武学图鉴资源配表
function TuJianUtil:getTextArry(index,score)
    if index == nil or score == nil then
        return {}
    end
    for k,v in pairs(TuJianTextTab) do
        if v.type == index and v.value then
            local valueStr = string.split(v.value,";")
            local minValue = tonumber(valueStr[1])
            local maxValue = tonumber(valueStr[2])
            -- print("valueStr",valueStr,"minValue = ",minValue,"maxValue = ",maxValue,"score = ",score)
            if minValue and maxValue then
                if score >= minValue and score <= maxValue  then
                    -- Helper:print_lua_table(v)
                    return v
                end
            else
                assert(false,"index = "..index.."v.value = "..v.value)
            end
        end
    end
    return {}
end

--获取图鉴列表
function TuJianUtil:getTuJianTable()
    return TuJianTable
end

--获取已掌握图鉴列表
function TuJianUtil:getRoleSkillsTable(role)
    local list = clone(BaseTuJianTable)
    if not role then
        role = User:getRole()
    end 
    local skills = role:getSkills()
    if not MapIsEmpty(skills) then
        for k, roleSkill in pairs(skills) do
            local skill = Skill:getSkill(roleSkill.id)
            if skill and skill.type ~= SKILL_TYPE_SELFCREATE then
                local wxclassify = skill.wxclassify
                if wxclassify then
                    for i,v in ipairs(wxclassify) do
                        if type(list[v]) == "table" then
                            local strWulevel = string.split(skill.wxlevel,",")
                            local levelScore = tonumber(strWulevel[i])
                            if type(levelScore) ~= "number" then
                                assert(false,"检查技能 = "..roleSkill.id)
                            end
                            skill.levelScore = levelScore
                            table.insert(list[v],skill)
                        end
                    end
                end
            end    
        end
    end
    return list
end

--获取类型中文名
function TuJianUtil:getTypeChineseName(index)
    if index == nil then
        return ""
    end
    local list = {
        jian = "剑",dao = "刀",gun = "棍",bian = "鞭",shuangchi = "双持",anqi = "暗器",fu = "斧",qiang = "枪",qin = "乐器",
        zhang = "掌",zhi = "指",tui = "腿",zhua = "爪", quan = "拳",
        qinggong = "轻功",
        neigong = "内功",
        zhaojia = "招架",
        zhishi = "绝世"
    }

    return list[index] or ""
end

function TuJianUtil:getWeaponStr(index)
    if index == nil then
        return
    end
    local list = {
        jian = "宝剑",dao = "宝刀",gun = "棍子",bian = "鞭子",shuangchi = "兵刃",anqi = "暗器",fu = "斧子",qiang = "兵刃",qin = "乐器",
    }

    return list[index]
end

--[[小于1  丁级
大于等于1、小于1.2  丙级
大于等于1.2、小于1.4 乙级
大于等于1.4 甲级
根据品阶获取对应的门槛分]]
function TuJianUtil:getScoreAndLevelStrByLevel(level)
    local minScore ,maxScore
  	switch(level,
    {
        first = function()
			minScore,maxScore = 1.4,10000000
		end ,
        second = function()
			minScore,maxScore = 1.2,1.4
		end ,
        third = function()
			minScore,maxScore = 1,1.2
		end ,
        fourth = function()
			minScore,maxScore = 0,1
		end ,
    })
    return minScore ,maxScore
end

--根据武学品质分获得对应阶段
function TuJianUtil:getlevelStr(levelScore)
    local levelStr = ""
    local list = {
        {score = 0,levelStr = "丁"}, 
        {score = 1,levelStr = "丙"},
        {score = 1.2,levelStr = "乙"},
        {score = 1.4,levelStr = "甲"},
    }
    for i,v in ipairs(list) do
        if levelScore >= v.score then
            levelStr = v.levelStr
        end
    end

    return levelStr
end

--[[品质字段 拳脚品质;Qjlevel ,兵器品质;Bqlevel ,轻功品质;Qglevel ,内功品质;Nglevel 
根据类型获取对应的品质字段]]
-- function TuJianUtil:getQualityStrByType(type)
--     local list = {
--         bingqiwuxue = "Bqlevel",
--         quanjiaowuxue = "Qjlevel",
--         qinggongwuxue = "Qglevel",
--         neigongwuxue = "Nglevel"
--     }
--     return list[type]
-- end

-- 以剑法精通为例：
-- 角色A目前总共学会了N种剑法：剑法1（n1级）、剑法2（n2级）、剑法3（n3级）、剑法4（n4级）……剑法N（nn级）。

-- 注1：n1、n2……nn都是自然数，最小为1，最大1000:
-- 注2：要把基本武功（基本剑法、基本刀法……）也算在内。基本武功默认武学品质为1；

-- 当N≥3时，该角色的剑法精通=
-- （n1*剑法1武学品质+n2*剑法2剑武学品质+n3*剑法3……nn*剑法N武学品质）/10+M*60

-- 当N＜3时，该角色的剑法精通=
-- （n1*剑法1武学品质+n2*剑法2剑武学品质）/8+M*80+20

-- 注3：M=当前学会的等级大于等于500的剑法类武学数量；
-- 注4：武学品质读取武功1表，算剑法精通时，就读取该武学作为剑法类武功的品质分，以此类推。
-- 注5：算出来的结果数值统一向上取整，算出来的数值直接显示在图鉴相应的界面上，是为剑法精通（值）。如下图所示：

--获取武学精通分数
function TuJianUtil:getWuXueScore(index,role)
    local indexList = {
       {index = "jian",factor = 1, jiben = "jibenjianfa"},
       {index = "dao",factor = 1, jiben = "jibendaofa"},
       {index = "qiang",factor = 1, jiben = "jibengunfa"},
       {index = "gun",factor = 1.2, jiben = "jibengunfa"},
       {index = "anqi",factor = 1.2, jiben = "jibenanqi"},
       {index = "bian",factor = 1.2, jiben = "jibenbianfa"},
       {index = "shuangchi",factor = 1.5, jiben = "jibenshuangchi"},
       {index = "fu",factor = 1.4, jiben = "jibendaofa"},
       {index = "qin",factor = 1, jiben = "jibenqinfa"},
       {index = "quan",factor = 1, jiben = "jibenquanjiao"},
       {index = "zhang",factor = 0.9, jiben = "jibenquanjiao"},
       {index = "tui",factor = 1.2, jiben = "jibenquanjiao"},
       {index = "zhi",factor = 1.3, jiben = "jibenquanjiao"},
       {index = "zhua",factor = 1.4, jiben = "jibenquanjiao"},
       {index = "neigong",factor = 1.2, jiben = "jibenneigong"},
       {index = "qinggong",factor = 1.3, jiben = "jibenqinggong"},
       {index = "zhaojia",factor = 1, jiben = "jibenzhaojia"},
       {index = "zhishi",factor = 1},
    }

    local finalWuXueNum = 0 --武学数量
    local score = 0 -- 所有 武学等级*武学品质得分
    local finalScore = 0 --精通得分
    local MoreThanFiveHundredNum = 0 --大于等于500级的武功数量
    local factor = 0 --精通系数
    local istrue = false

    if not role then
        role = User:getRole()
    end

    for i,v in ipairs(indexList) do
        if v.index == index then
            istrue = true
            local jibenSkillId = v.jiben
            if jibenSkillId then
                local jibenSkill = role:getSkill(jibenSkillId)
                if jibenSkill then --要把基本武功（基本剑法、基本刀法……）也算在内。基本武功默认武学品质为1
                    local jibenSkillLv = role:getSkillLv(jibenSkillId)
                    -- print("jibenSkillLv = ",jibenSkillLv)
                    if jibenSkillLv > 0 then
                        score = score + jibenSkillLv * 1 
                        finalWuXueNum = finalWuXueNum + 1
                        if jibenSkillLv >= 500 then
                            MoreThanFiveHundredNum = MoreThanFiveHundredNum + 1
                        end
                    end
                end
            end
            break
        end
    end
    
    if istrue == false then
        print("index = ",index)
        return 0
    end

	local learnedList = self:getRoleSkillsTable()[index]
    if not MapIsEmpty(learnedList) then
        for index,skill in ipairs(learnedList) do
            local levelScore = Helper:getDef(skill.levelScore,0)
            -- print("levelScore = ",levelScore) 
            local skillLv
            if skill:checkIsSpecialZhiShiSkill() then
                skillLv = role:getSpecialZhiShiSkillLv(skill.id)
            else
                skillLv = role:getSkillLv(skill.id)
            end
            score = score + skillLv * levelScore 
            finalWuXueNum = finalWuXueNum + 1

            if skillLv >= 500 then
                MoreThanFiveHundredNum = MoreThanFiveHundredNum + 1
            end
        end
    end

    if finalWuXueNum >= 3 then
        finalScore = math.ceil((score / 10) + (MoreThanFiveHundredNum * 60))
    else
        finalScore = math.ceil((score / 8) + (MoreThanFiveHundredNum * 80) + 20)
    end

	return finalScore
end

function TuJianUtil:getWuXueImage(index)
    local image = "Image/UI/SkillUI/bingqi.png"
	local indexList = {
       {index = "jian",image = "Image/UI/SkillUI/jianfa.png"},
       {index = "dao",image = "Image/UI/SkillUI/dao.png"},
       {index = "qiang",image = "Image/UI/SkillUI/qiangfa.png"},
       {index = "gun",image = "Image/UI/SkillUI/gunfa.png"},
       {index = "anqi",image = "Image/UI/SkillUI/anqi.png"},
       {index = "bian",image = "Image/UI/SkillUI/bianfa.png"},
       {index = "shuangchi",image = "Image/UI/SkillUI/shuangchi.png"},
       {index = "fu",image = "Image/UI/SkillUI/fufa.png"},
       {index = "quan",image = "Image/UI/SkillUI/quanjiao.png"},
       {index = "zhang",image = "Image/UI/SkillUI/zhangfa.png"},
       {index = "tui",image = "Image/UI/SkillUI/tuifa.png"},
       {index = "zhi",image = "Image/UI/SkillUI/zhifa.png"},
       {index = "zhua",image = "Image/UI/SkillUI/zhuafa.png"},
       {index = "neigong",image = "Image/UI/SkillUI/neigong.png"},
       {index = "qinggong",image = "Image/UI/SkillUI/qinggong.png"},
       {index = "zhaojia",image = "Image/UI/SkillUI/zhaojia.png"},
       {index = "zhishi",image = "Image/UI/SkillUI/zhishi.png"},
       {index = "qin",image = "Image/UI/SkillUI/qinfa.png"},
    }
    for i,v in ipairs(indexList) do
        if v.index == index  then
            image = v.image
            break
        end
    end
    return image
end

--获得图鉴武学数量
function TuJianUtil:getTuJianWuXueNum()
    local num = 0
    for index,v in pairs(self:getTuJianTable()) do
        num = num + #v
	end
    return num
end

--获得已见闻武学数量
function TuJianUtil:getSeeWuXueNum(role)
    local num = 0

    if not role then
        role = User:getRole()
    end
    
    for k,v in pairs(self:getTuJianTable()) do
        for i,skill in ipairs(v) do
            local skillState = role:getSkillStatus(skill.id)
            if skillState == SKILL_STATE_GRASP or skillState == SKILL_STATE_NOGRASP then
                num = num + 1
            end 
        end
    end

    return num
end

--获得已掌握的武学数量
function TuJianUtil:getZhangWoWuXueNum(role)
    local num = 0
    for index,v in pairs(self:getRoleSkillsTable(role)) do
        num = num + #v
	end
   
    return num
end

--获得已见闻的知识武学数量
function TuJianUtil:getSeeZhiShiNum(role)
    local num = 0

    if not role then
        role = User:getRole()
    end

    for i,skill in ipairs(self:getTuJianTable()["zhishi"]) do
        local skillState = role:getSkillStatus(skill.id)
		if skillState == SKILL_STATE_GRASP or skillState == SKILL_STATE_NOGRASP then
            num = num + 1
        end 
	end
    return num
end

--获取某类型武学见闻数量
function TuJianUtil:getRoleSeeSkillNumBySkillType(skillType,role)
    local num = 0

    if not role then
        role = User:getRole()
    end
    
    local typeSkills = self:getTuJianTable()[skillType]

    for i,skill in ipairs(typeSkills) do
        local skillState = role:getSkillStatus(skill.id)
        if skillState == SKILL_STATE_GRASP or skillState == SKILL_STATE_NOGRASP then
            num = num + 1
        end
    end

    return num
end

--获取普通技能的默认图鉴类别
function TuJianUtil:getSkillDefalutTuJianType(skillId,role)
    local skill = Skill:getSkill(skillId)

    if MapIsEmpty(skill) then
        print("---------TuJianUtil:getSkillDefalutTuJianType 技能有问题, skillId:",skillId)
        print(debug.traceback())
        return false
    end

    local wxclassify = skill.wxclassify
    if wxclassify then
        return wxclassify[1]
    end
end

--获取对应类型分数对应的图鉴等级
function TuJianUtil:getSkillTypeScoreLevel(skillType,role)
    local score = self:getWuXueScore(skillType,role)
    local level = 1

    for k,v in pairs(TuJianTextTab) do
        if v.type == skillType and v.value then
            local valueStr = string.split(v.value,";")
            local minValue = tonumber(valueStr[1])
            local maxValue = tonumber(valueStr[2])
            if minValue and maxValue then
                if score >= minValue and score <= maxValue  then
                    level = v.level
                    break
                end
            else
                assert(false,"skillType = "..skillType.."v.value = "..v.value)
            end
        end
    end

    return level
end

function TuJianUtil:getCurrWeaponimage(subType, weapontype)
    if subType == nil then
        return ""
    end
	local image = ""

	local list = {
		jian = {"images/weapon/sword1","kk/duanjian","kk/ruanjian","kk/zhongjian","kk/cijian"},
		dao = {"images/weapon/knife1","kk/duandao","kk/wandao","kk/dahuandao","kk/shuangrenfu"},
		gun = {"images/weapon/gun1","kk/changqiang","kk/sanjiegun/sanjiegun","kk/langyabang","kk/zhanji"},
		bian = {"images/weapon/bian1","kk/ruanbian","kk/jiujiebian","kk/ganzibian","kk/lianjia"},
		shuangchi = {"kk/shuanghuanwuqi_1","kk/duijian","kk/shuanggou"},
		anqi = {"kk/anqi/zhuixing","kk/anqi/yuanxing","kk/anqi/zhenxing",},
		fu = {"images/weapon/knife1","kk/duandao","kk/wandao","kk/dahuandao","kk/shuangrenfu"},
		qiang = {"images/weapon/gun1","kk/changqiang","kk/sanjiegun/sanjiegun","kk/langyabang","kk/zhanji"},
		qin = {"kk/jichuqinfa/jichuqinfa_qin2","kk/yueqi/Flute"},
	}

	if list[subType] then
		if weapontype then
			local weapontypeStr = tonumber(StringUtil:subNum(weapontype))
			if weapontypeStr then
				image = list[subType][weapontypeStr]
			else
				image = nil
			end
			if not image then
				image = list[subType][math.random(1,#list[subType])]
			end
		else
			image = list[subType][math.random(1,#list[subType])]
		end
	end

    return image
end

function TuJianUtil:getSkillAnimList(skills,weapontype)
	local animList = {}
	local anims = {}
	if not MapIsEmpty(skills) then
		for i, v in ipairs(skills) do
			local anims = v.anims
			if not MapIsEmpty(anims) then
				local animName = nil
				local offset = -120
				-- local hitPos = "chest"
				for index ,value in ipairs(anims) do
					local newAnims = {}
					if weapontype then
						if value[weapontype] then
							newAnims["anim"] = value[weapontype].anim
							newAnims["offset"] = Helper:getDef(value[weapontype].offset,offset)
							-- newAnims["hitPos"] = Helper:getDef(value[weapontype].hitPos,hitPos)
						end
					else
						newAnims["anim"] = value.anim
						newAnims["offset"] = Helper:getDef(value.offset,offset)
						-- newAnims["hitPos"] = Helper:getDef(value.hitPos,hitPos)
					end

					if newAnims ~= {} then
						table.insert(animList,newAnims)
					end
				end
			end
		end
	end

	return animList
end

function TuJianUtil:getJiBenSkills(titalIndex)
	local jibenSkills = {}
	local indexList = {
		{index = "jian",jiben = "jibenjianfa"},
		{index = "dao",jiben = "jibendaofa"},
		{index = "qiang",jiben = "jibengunfa"},
		{index = "gun",jiben = "jibengunfa"},
		{index = "anqi",jiben = "jibenanqi"},
		{index = "bian",jiben = "jibenbianfa"},
		{index = "shuangchi",jiben = "jibenshuangchi"},
		{index = "fu",jiben = "jibendaofa"},
		{index = "qin",jiben = "jibenqinfa"},
		{index = "quan",jiben = "jibenquanjiao"},
		{index = "zhang",jiben = "jibenquanjiao"},
		{index = "tui",jiben = "jibenquanjiao"},
		{index = "zhi",jiben = "jibenquanjiao"},
		{index = "zhua",jiben = "jibenquanjiao"},
		}
	local jibenSkillId = nil
	for i,v in ipairs(indexList)  do
		if v.index == titalIndex then
			jibenSkillId = v.jiben
			break
		end
	end
	if jibenSkillId then
		local jibenSkill = Skill:getSkill(jibenSkillId) 
		jibenSkills = jibenSkill:getAutoSkills()
	end
	return jibenSkills
end

function TuJianUtil:getNotOpenWuXueAnimList()
    local notOpenWuXueAnimList = {
        qinggong = true,
        neigong = true,
        zhishi = true,
        zhaojia = true,
        ["0"]= true,
    }

    return notOpenWuXueAnimList
end

return TuJianUtil0