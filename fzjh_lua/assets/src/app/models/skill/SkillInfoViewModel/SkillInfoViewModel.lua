local class = require("third.class.NewClass")

local SkillConst = require("app.models.skill.SkillConst")

local BaseSkillInfoViewModel = require("app.models.skill.SkillInfoViewModel.BaseSkillInfoViewModel")

local SkillClassifyManager = require("app.FightSystem.FightSkill.SkillClassifyManager")

local SkillInfoViewModel = {}

function SkillInfoViewModel:create(role)
    local p = SkillInfoViewModel:new()
    p:init(role)
    return p
end

function SkillInfoViewModel:init(role)
    self:setRole(role)

    self:__initRoleSkillList()
end

function SkillInfoViewModel:__initRoleSkillList()
    local skillList = self:getSkills()
    local qjList, bqList, qgList, ngList, zjList, zsList = {}, {}, {}, {}, {}, {}
    for k,v in pairs(skillList) do
        local skill = self:getSkill(k)
        -- 知识类和特殊类放入知识类
        if skill.type == SKILL_TYPE_DUSHU or skill.type == SKILL_TYPE_SPECIAL or skill.type == SKILL_TYPE_HUIFU or skill.type == SKILL_TYPE_DUNDI or skill.type == SKILL_TYPE_ZHISHI then
            table.insert(zsList, v)
        elseif skill and skill.methods then
            for i,vtype in ipairs(skill.methods) do
                if vtype == SKILL_METHOD_TYPE_QUANJIAO then
                    table.insert(qjList, v)
                elseif vtype == SKILL_METHOD_TYPE_NEIGONG then
                    table.insert(ngList, v)
                elseif vtype == SKILL_METHOD_TYPE_QINGGONG then
                    table.insert(qgList, v)
                elseif vtype == SKILL_METHOD_TYPE_ZHAOJIA then
                    table.insert(zjList, v)
                else
                    
                    local temp = false
                    for _,tempSkill in pairs(bqList) do
                        if tempSkill.id == v.id then
                            temp = true
                        end
                    end

                    if temp == false then
                        table.insert(bqList, v)
                    end
                end
            end
        end
    end

    self:__initSkillListTab(qjList, bqList, qgList, ngList, zjList, zsList)
end

function SkillInfoViewModel:__initSkillListTab(qjList, bqList, qgList, ngList, zjList, zsList)
    self.__skillListTab = {
        {name = "拳脚",skillType ="quanjiao1",list = qjList},
        {name = "兵器",skillType ="bingqi",list = bqList},
        {name = "轻功",skillType ="qinggong",list = qgList},
        {name = "内功",skillType ="neigong",list = ngList},
        {name = "招架",skillType ="zhaojia",list = zjList},
        {name = "知识",skillType ="zhishi",list = zsList}
    }
end

function SkillInfoViewModel:getCurrTabSkillType()
    return self:getCurrSkillListTab().skillType
end

function SkillInfoViewModel:getSkills()
    return self.__role:getSkills()
end

function SkillInfoViewModel:sortSkill(list,skillType)
    if MapIsEmpty(list) == true then
        return list
    end

    local baseList, normalList = {}, {}

    for i, v in pairs(list) do
        local skill = self:getSkill(v.id)
        if skill.type == SKILL_TYPE_BASE then
            table.insert(baseList, v)
        else
            table.insert(normalList, v)
        end
    end

    if skillType == "bingqi" then
        table.sort(baseList, function(a, b)
            if a.exp == b.exp then
                return a.id > b.id
            else
                return a.exp > b.exp
            end
        end)
    end

    local rList = baseList
    if MapIsEmpty(normalList) == true then
        return rList
    end

    local tab =
    {
        jibendaofa = "daofa",
        jibenjianfa = "jianfa",
        jibenbianfa = "bianfa",
        jibengunfa = "gunfa",
        jibenanqi = "anqi",
        jibenshuangchi = "shuangchi",
        jibenqinfa = "qinfa",
        -- jibenquanjiao = "quanjiao",
        -- jibenneigong = "neigong",
        -- jibenqinggong = "qinggong",
        -- jibenzhaojia = "zhaojia",
    }

    local prepareList, unpareList = {}, {}
    for k,v in pairs(normalList) do
        if skillType == "bingqi" then
            -- 修复 没学基本功法特殊功法将不显示的 bug
            if MapIsEmpty(baseList) == true then
                table.insert(unpareList, v)
            else
                for i,v1 in ipairs(baseList) do
                    if self.__role:getPrepareSkill(tab[v1.id]) == v.id then
                        table.insert(prepareList, v)
                        break
                    elseif i == #baseList then
                        table.insert(unpareList, v)
                    end
                end
            end
        elseif skillType == "quanjiao1" and (self.__role:getPrepareSkill("quanjiao1") == v.id or self.__role:getPrepareSkill("quanjiao2") == v.id) then
            table.insert(prepareList, v)
        elseif self.__role:getPrepareSkill(skillType) == v.id then
            table.insert(prepareList, v)
        else
            table.insert(unpareList, v)
        end
    end

    table.sort( unpareList, function(a, b)
        if a.exp == b.exp then
            return a.id > b.id
        else
            return a.exp > b.exp
        end
    end )

    table.sort(prepareList,function(a, b)
        if a.exp == b.exp then
            return a.id > b.id
        else
            return a.exp > b.exp
        end
    end)
    normalList = prepareList
    for k,v in pairs(unpareList) do
        table.insert(normalList, v)
    end

    for k,v in pairs(normalList) do
        table.insert(rList, v)
    end
    return rList
end

function SkillInfoViewModel:getTextSkillThridTypes()
    return self:getSkill():getTextSkillThridTypes()
end


--@desc: 获取武学当前兵器准备类型
--@author:LvBin
--@time:2024-08-13 16:55:22
--@return
function SkillInfoViewModel:getCurrBingQiPrepareType()
    local bqPrepareTypes = self:getSkill():getBingQiPrepareTypes()

    if #bqPrepareTypes <= 1 then
        return bqPrepareTypes[1]
    end

    local currBqPreType

    local tempExp = 0

    local prepareList = self.__role:getPrepareType(self.__skillId)

    if not MapIsEmpty(prepareList) then
        for index,preType in ipairs(prepareList) do
            for i,bqPreType in ipairs(bqPrepareTypes) do
                if bqPreType == preType then
                    local jibenSkillId = SkillConst.PrepareList[bqPreType]

                    local jibenSkillExp = self.__role:getSkillExp(jibenSkillId)

                    if jibenSkillExp > tempExp then
                        tempExp = jibenSkillExp

                        currBqPreType = bqPreType
                    elseif jibenSkillExp == 0 and tempExp ==0 then
                        currBqPreType = bqPreType
                    end

                    break
                end
            end
        end
    else
        for i,bqPreType in ipairs(bqPrepareTypes) do
            local jibenSkillId = SkillConst.PrepareList[bqPreType]

            local jibenSkillExp = self.__role:getSkillExp(jibenSkillId)

            if jibenSkillExp > tempExp then
                tempExp = jibenSkillExp

                currBqPreType = bqPreType
            elseif jibenSkillExp == 0 and tempExp ==0 then
                currBqPreType = bqPreType
            end
        end
    end

    return currBqPreType
end

function SkillInfoViewModel:skillIsPrepared()
	local prepareType = self:getCurrTabSkillType()

	if prepareType == "quanjiao1" then
		local prepareSkill1 = self.__role:getPrepareSkill("quanjiao1")

		local prepareSkill2 = self.__role:getPrepareSkill("quanjiao2")
		
        if prepareSkill1 == self.__skillId or prepareSkill2 == self.__skillId then
			return true
		end
	elseif prepareType == "bingqi" then
        local bqPrepareTypes = self:getSkill():getBingQiPrepareTypes()

        for i,bqPreType in ipairs(bqPrepareTypes) do
            if self.__skillId == self.__role:getPrepareSkill(bqPreType) then
                return true
            end
        end
    else
        if self.__skillId == self.__role:getPrepareSkill(prepareType) then
            return true
        end
	end

    return false
end

function SkillInfoViewModel:cancelPrepareSkill()
    local prepareType = self:getCurrTabSkillType()

    local cancelType = prepareType

    if prepareType == "quanjiao1" then
        if self.__role:getPrepareSkill("quanjiao2") == self.__skillId then
			cancelType =  "quanjiao2"
		end
    elseif prepareType == "bingqi" then
        cancelType = self:getCurrBingQiPrepareType()
    end

    self.__role:prepareSkill(cancelType, nil)
end

function SkillInfoViewModel:prepareSkill()
    local tabSkillType = self:getCurrTabSkillType()

    local prepareType = tabSkillType

    if tabSkillType == "quanjiao1" then
        local preIdQj1 = self.__role:getPrepareSkill("quanjiao1")
						
	    local preIdQj2 = self.__role:getPrepareSkill("quanjiao2")
        
        if preIdQj1 ~= nil and preIdQj2 == nil then
			local zuoyouHB = self:__isOpenZuoYouHuBo()
			if zuoyouHB == true then
				prepareType = "quanjiao2"
			else
				local skill_1st = self:getSkill(preIdQj1)
				
				if skill_1st.combob and string.len(skill_1st.combob) >= 1 then
					local combobSkill = self.__role:getSkill(skill_1st.combob)

					if combobSkill and skill_1st.combob == self.__skillId then
						prepareType = "quanjiao2"
					end
				end
			end
		end
    elseif tabSkillType == "bingqi" then
        prepareType = self:getCurrBingQiPrepareType()
    end

    self.__role:prepareSkill(prepareType, self.__skillId)
end

function SkillInfoViewModel:canLianGong()
	if self:getSkill():canLianGong() == false then
		return false,"该功法不能练功"
	end

	-- 内功类型不能练功
	if self:getSkill():isNeiGong() then
		return false,"内功类型的功法不能练功"
	end

	if self.__role:isInCurrState(ROLE_CURR_STATE_LIANGONG) then
		if self.__role:getLianGongSystem():getSkillId() == self.__skillId then
			return true
		else
			PopText("正在修炼其他功法")
			return false
		end
	end

	if self.__role:isInCurrState(ROLE_CURR_STATE_BIGUAN) then
		return false,"正在修炼其他功法"
	end

	if self.__role:isInCurrState(ROLE_CURR_STATE_XIULIAN) then
		return false,"正在修习其他功法"
	end

	if not self:skillIsPrepared() then
		return false,"你只能练习你准备上的武功。"
	end

    local skillLv = self.__role:getSkillLv(self.__skillId)

    local tabSkillType = self:getCurrTabSkillType()

    local prepareType = tabSkillType

    if tabSkillType == "bingqi" then
        prepareType = self:getCurrBingQiPrepareType()
    end

    local jibenSkillId = SkillConst.PrepareList[prepareType]

	local jiBenSkill = self.__role:getSkill(jibenSkillId)

    if not jiBenSkill or not jiBenSkill.exp or skillLv >= (Skill:getLv(jiBenSkill.exp) + 1) then
		return false,"你的基本功火候未到，必须先打好基础才能继续提高。"
	end

	if skillLv >= self.__role:getLv() then
		return false,"你的实战经验不足，你的练习总没法进步。"
	end

	if skillLv >= self.__role:getSkillLvLimit(self.__skillId) then
		return false,"已经达到该武学最高等级，无法练功"
	end

	return true
end

function SkillInfoViewModel:getSkillExpDsc(skillId)
    local skillLv = self.__role:getSkillLv(skillId)

    local exp = Helper:mathFloor(self.__role:getSkillExp(skillId))

    return exp.."/"..skillLv.."级"
end

function SkillInfoViewModel:getSkillStageDsc(skillId)
    return self:getSkill(skillId):getStageDsc(self.__role)
end

function SkillInfoViewModel:__isOpenZuoYouHuBo()
    return self.__role:isHaveImprintingId("zuoyouhuboyin")
end

return class("SkillInfoViewModel", {BaseSkillInfoViewModel}, SkillInfoViewModel)000000