local BookSkills = {}

local oldPrint = print

local function print(...)
    if DEBUG_MODE == 1 then
        oldPrint(...)
    else
    end
end

-- [[0 无条件要求 江湖武学填0 value都填0
-- 1 需求武学和等级  value填武功id和等级,用;号隔开。格式示例：lunhuijianfa;300

-- 2 角色等级要求 value填需求的等级数字
-- 3 角色性别要求 value填0代表男1代表女
-- 4 最小根骨需求 value填具体值
-- 5 最小悟性需求 value填具体值
-- 6 最小臂力需求 value填具体值
-- 7 最小身法需求 value填具体值
-- 8 门派需求     value填具体的门派id]]

local bookSkillLearnConditionType={
    NO_CONDITION = 0,
    NEED_SKILL_LV = 1,
    ROLE_LV = 2,
    ROLE_SEX = 3,
    ROLE_MIN_CON = 4,
    ROLE_MIN_INT = 5,
    ROLE_MIN_STR = 6,
    ROLE_MIN_DEX = 7,
    ROLE_FAMILY = 8,
}
local bookSkillBelongType={
    NO_FAMILY = 0,
    FAMILY =1
}

-- 编号;id	名称;name	类型;type2	类型;type1	总数;totalNum	残页;page1

function BookSkills:initBookSkills()
	local dataList = assert(require("script.book.bookSkills"))
	if type(dataList) ~= "table" then
		if DEBUG_MODE == 1 then
			error("解析书页数据出错")
		end
		return
	end

	if self.__bookSkillsData then
		return self.__bookSkillsData
	end

    -- add by XiaoZhiWei 2017/05/11 10:44:09 加密 (主防 学习所需数量,以及经验值)
    for sheetName,list in pairs(dataList) do
        for k,v in pairs(list) do
            list[k] = createEncryptTable(v)
        end
    end

	if PRINT_MODE == 1 then
		-- print("``````````````````````````")
		-- Helper:print_lua_table(dataList)
	end

	local bookSkillsData = {}

	for id,skill in pairs(dataList.skills) do
        bookSkillsData[id] = {}
        bookSkillsData[id].totalNum = skill["totalNum"]
        bookSkillsData[id].name = skill["name"]
        bookSkillsData[id].skillId = skill["id"]
        bookSkillsData[id].exp = skill["exp"]
        bookSkillsData[id].belong = skill["belong"]
        bookSkillsData[id].learnCondition = skill["learnCondition"]
        bookSkillsData[id].learnValue = skill["learnValue"]
		bookSkillsData[id].sortIndex = Skill:getSkill(skill.id).sort

        if skill.type ~= nil then
            bookSkillsData[id].type = skill.type
        else
            local tb = {}
            for i = 1, 10 do
                if skill["type"..i] ~= nil then
                    tb[i] = skill["type"..i]
                else
                    bookSkillsData[id].type = tb
                    break
                end
            end
        end
        local tb = {}
        for i = 1 ,999 do
            if skill["pageName"..i] ~= nil  and skill["pageCount"..i] ~= nil then
                if not tb[i] then tb[i] = {} end
                tb[i].name = skill["pageName"..i]
                tb[i].count = 0--skill["pageCount"..i]
            else
                bookSkillsData[id].page = tb
            end
        end
    end

	self.__bookSkillsData = bookSkillsData
	
    return bookSkillsData
end

function BookSkills:getbookSkill()
	return self:initBookSkills()
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/03/29 17:51:33
-- @desc 初始化 招式残页
function BookSkills:initActiveZhaos()
    local dataList = assert(require("script.book.bookSkills"))
    if type(dataList) ~= "table" then
        if DEBUG_MODE == 1 then
            error("解析书页数据出错")
        end
        return
    end

	if self.__zhaoSkillData then
		return self.__zhaoSkillData
	end

    local ZhaoSkillData = {}
    if MapIsEmpty(dataList.activeZhao) == true then
        return ZhaoSkillData
    end

    for id,activeZhao in pairs(dataList.activeZhao) do
        ZhaoSkillData[id] = {}
        ZhaoSkillData[id].name = activeZhao["name"]
        ZhaoSkillData[id].skillId = activeZhao["id"]
        ZhaoSkillData[id].exp = activeZhao["exp"]
		ZhaoSkillData[id].sortIndex = Skill:getSkill(activeZhao.id).sort

        if activeZhao.type ~= nil then
            ZhaoSkillData[id].type = activeZhao.type
        else
            local tb = {}
            for i = 1, 10 do
                if activeZhao["type"..i] ~= nil then
                    tb[i] = activeZhao["type"..i]
                else
                    ZhaoSkillData[id].type = tb
                    break
                end
            end
        end
        local tb = {}
        for i = 1 ,10 do
            if activeZhao["pageName"..i] ~= nil  and activeZhao["pageCount"..i] ~= nil then
                if not tb[i] then tb[i] = {} end
                tb[i].name = activeZhao["pageName"..i]
                tb[i].count = 0
                tb[i].needCount = activeZhao["pageCount"..i]
            else
                ZhaoSkillData[id].page = tb
            end
        end
    end

	self.__zhaoSkillData = ZhaoSkillData

    return ZhaoSkillData
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/03/29 17:54:19
-- @desc 获取招式残页列表
function BookSkills:getBookActiveZhao()
    return self:initActiveZhaos()
end


--书页技能学习条件 activeZhaoId 招式id role 当前角色
function BookSkills:checkSkillCanLearn(skillId,skillData,role)
    if not skillId then 
        if DEBUG_MODE == 1 then
            print("BookSkills:checkSkillCanLearn error : skillid is null")
        end
        return false
    end

    local currBookSkill = skillData
   
    if not currBookSkill then 
        if DEBUG_MODE == 1 then
            print("BookSkills:checkSkillCanLearn error : the  skill is not exist")
        end
        return false
    end
    
    local currBelongType,currLearnConditionType,currLearnValue,currRole
    currBelongType = currBookSkill.belong 
    currLearnConditionType = currBookSkill.learnCondition
    currLearnValue = currBookSkill.learnValue

    currRole = role
    if not currRole then 
        currRole = User:getRole()
    end
    local canLearn =false
    canLearn=switch(currLearnConditionType,
    {
        [bookSkillLearnConditionType.NO_CONDITION] = function ()
            return true
        end,
        [bookSkillLearnConditionType.NEED_SKILL_LV] = function ()
            if type(currLearnValue) ~= "string" then 
                print("NEED_SKILL_LV 当前书页技能 currLearnValue 配置出错 书页技能id：",skillId)
                return false
            end
            currLearnValue = string.split(currLearnValue,";")
            if #currLearnValue<2 then 
                print("NEED_SKILL_LV 当前书页技能 currLearnValue 配置出错 书页技能id：",skillId)
                return false
            end
            
            local Skill = require("app.models.skill.Skill")
            local skillInfo = Skill:getSkill(currLearnValue[1])
            if not skillInfo then 
                print("NEED_SKILL_LV 当前书页技能 currLearnValue 配置出错 书页技能id：",skillId)
                return false
            end

            local currSkill = currRole:getSkill(currLearnValue[1])

            if not currSkill then 
                print("当前人物没有学习该技能武学")
                PopText("需要"..skillInfo.name.."等级不低于"..currLearnValue[2].."级！")
                return false
            end
            if currRole:getSkillLv(currSkill.id) < tonumber(currLearnValue[2]) then 
                print("当前人物该技能武学等级不够")
                PopText("需要"..skillInfo.name.."等级不低于"..currLearnValue[2].."级！")
                return false
            end
            return true
        end,
        [bookSkillLearnConditionType.ROLE_LV] = function ()
            if type(currLearnValue) ~= "number" then 
                print("ROLE_LV 当前书页技能 currLearnValue 配置出错 书页技能id：",skillId)
                return false
            end
            if currRole:getLv() < currLearnValue then 
                print("当前人物等级不够",currRole:getLv(),currLearnValue)
                PopText("人物等级不够")
                return false
            end
            return true
        end,
        [bookSkillLearnConditionType.ROLE_SEX] = function () --男为0 女为1
            if type(currLearnValue) ~= "number" then 
                print("ROLE_SEX 当前书页技能 currLearnValue 配置出错 书页技能id：",skillId)
                return false
            end
            if currRole:getAttr("sex") == "女" and currLearnValue ~= 1  then 
                print("当前人物性别不符",currRole:getAttr("sex"),currLearnValue)
                PopText("人物性别不符")
                return false
            end
            if currRole:getAttr("sex") == "男" and currLearnValue ~= 0  then 
                print("当前人物性别不符",currRole:getAttr("sex"),currLearnValue)
                PopText("人物性别不符")
                return false
            end
            return true
        end,
        [bookSkillLearnConditionType.ROLE_MIN_CON] = function ()
            if type(currLearnValue) ~= "number" then 
                print("ROLE_MIN_CON 当前书页技能 currLearnValue 配置出错 书页技能id：",skillId)
                return false
            end
            if currRole:getFinalAttr("currCon") < currLearnValue  then 
                print("当前人物根骨不符",currRole:getFinalAttr("currCon"),currLearnValue)
                PopText("人物根骨不符")
                return false
            end
            return true
        end,
        [bookSkillLearnConditionType.ROLE_MIN_INT] = function ()
            if type(currLearnValue) ~= "number" then 
                print("ROLE_MIN_INT 当前书页技能 currLearnValue 配置出错 书页技能id：",skillId)
                return false
            end
            if currRole:getFinalAttr("currInt") < currLearnValue  then 
                print("当前人物悟性不符",currRole:getFinalAttr("currInt"),currLearnValue)
                PopText("人物悟性不符")
                return false
            end
            return true
        end,
        [bookSkillLearnConditionType.ROLE_MIN_STR] = function ()
            if type(currLearnValue) ~= "number" then 
                print("ROLE_MIN_STR 当前书页技能 currLearnValue 配置出错 书页技能id：",skillId)
                return false
            end
            if currRole:getFinalAttr("currStr") < currLearnValue  then 
                print("当前人物臂力不符",currRole:getFinalAttr("currStr"),currLearnValue)
                PopText("人物臂力不符")
                return false
            end
            return true
        end,
        [bookSkillLearnConditionType.ROLE_MIN_DEX] = function ()
            if type(currLearnValue) ~= "number" then 
                print("ROLE_MIN_DEX 当前书页技能 currLearnValue 配置出错 书页技能id：",skillId)
                return false
            end
            if currRole:getFinalAttr("currDex") < currLearnValue  then 
                print("当前人物身法不符",currRole:getFinalAttr("currDex"),currLearnValue)
                PopText("人物身法不符")
                return false
            end
            return true
        end,
        [bookSkillLearnConditionType.ROLE_FAMILY] = function ()
            if currBelongType ~= bookSkillBelongType.FAMILY then --非门派书页技能
                print("当前书页技能 非门派书页技能")
                return false
            end
            if type(currLearnValue) ~= "string" then 
                print("ROLE_FAMILY 当前书页技能 currLearnValue 配置出错 书页技能id：",skillId)
                return false
            end
            if currRole:getFamilyId() ~= currLearnValue then 
                print("当前人物门派不符",currRole:getFamilyId(),currLearnValue)
                PopText("人物门派不符")
                return false
            end
            return true
        end,
        default = function()
            if DEBUG_MODE == 1 then
                print("BookSkills:checkSkillCanLearn error : the learnCondition of skill is not exist")
            end
            return false 
        end,
    })
    return canLearn
end

-- 加密标记
-- BookSkills.isEncrypted = true
return BookSkills
000