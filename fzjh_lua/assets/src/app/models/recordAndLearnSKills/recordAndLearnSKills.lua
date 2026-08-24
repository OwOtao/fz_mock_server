local class = require("third.class.NewClass")

local LIST_TYPE = {
    RECORD_QUANJIAO = 1,
    RECORD_BINGQI = 2,
    RECORD_QINGGONG = 3,
    RECORD_NEIGONG = 4,
    LEARN_QUANJIAO = 5,
    LEARN_BINGQI = 6,
    LEARN_QINGGONG = 7,
    LEARN_NEIGONG = 8,
}

local LIST_TITLE = {
    [LIST_TYPE.RECORD_QUANJIAO] = "拳脚",
    [LIST_TYPE.RECORD_BINGQI] = "兵器",
    [LIST_TYPE.RECORD_QINGGONG] = "轻功",
    [LIST_TYPE.RECORD_NEIGONG] = "内功",
    [LIST_TYPE.LEARN_QUANJIAO] = "拳脚",
    [LIST_TYPE.LEARN_BINGQI] = "兵器",
    [LIST_TYPE.LEARN_QINGGONG] = "轻功",
    [LIST_TYPE.LEARN_NEIGONG] = "内功",
}

local bingqiType = {[SKILL_METHOD_TYPE_JIAN] = true,[SKILL_METHOD_TYPE_DAO] = true,[SKILL_METHOD_TYPE_GUN] = true,
        [SKILL_METHOD_TYPE_ANQI] = true,[SKILL_METHOD_TYPE_BIANFA] = true,[SKILL_METHOD_TYPE_SHUANGCHI] = true,[SKILL_METHOD_TYPE_QIN] = true}


local recordAndLearnSkills = {}

function recordAndLearnSkills:create()
    return recordAndLearnSkills:new()
end

function recordAndLearnSkills:ctor()
    self._actionId = 0
    self._dreamSkills = {} --梦境武学列表
    self._jianghuSkills = {}    --江湖武学列表
    self._skillList = {}    --当前技能列表
    self._learnSkills = {}  --当前可学习技能列表
    self:__initJiangHuSkills()
end

function recordAndLearnSkills:setRole(role)
    self._role = role
end

function recordAndLearnSkills:initRecordSkills(callback)
    self:__filterRecordSkills(callback)
end

function recordAndLearnSkills:initLearnSkills(callback)
    self:__initLearnSkillList(callback)
end

function recordAndLearnSkills:initExchangeList()
end

function recordAndLearnSkills:getListType()
    return LIST_TYPE
end

function recordAndLearnSkills:getListTitle()
    return LIST_TITLE
end

function recordAndLearnSkills:getCurrencyCost()
    return self._currencyCost
end

function recordAndLearnSkills:getCurrencyName()
    return self._currencyName
end

function recordAndLearnSkills:getListByType(listType)
    return switch(listType,{
        [LIST_TYPE.RECORD_QUANJIAO] = function()
            local skills ={}

            if MapIsEmpty(self._skillList) == false then
                for __,skillId in ipairs(self._skillList) do
                    local skill = Skill:getSkill(skillId)
                    if skill and MapIsEmpty(skill.methods) == false then
                        for i,v in ipairs(skill.methods) do
                            if v == SKILL_METHOD_TYPE_QUANJIAO then
                                table.insert(skills, skill.id)
                            end
                        end
                    end
                end
            end

            return self:__dealWithRecordSkills(skills)
        end,

        [LIST_TYPE.RECORD_BINGQI] = function()
            local skills ={}
            if MapIsEmpty(self._skillList) == false then
                for __,skillId in ipairs(self._skillList) do
                    local skill = Skill:getSkill(skillId)
                    if skill and MapIsEmpty(skill.methods) == false then
                        for i,v in ipairs(skill.methods) do
                            if bingqiType[v] then
                                table.insert(skills, skill.id)
                            end
                        end
                    end
                end
            end

            return self:__dealWithRecordSkills(skills)
        end,

        [LIST_TYPE.RECORD_QINGGONG] = function()
            local skills ={}
            if MapIsEmpty(self._skillList) == false then
                for __,skillId in ipairs(self._skillList) do
                    local skill = Skill:getSkill(skillId)
                    for i,v in ipairs(skill.methods) do
                        if v == SKILL_METHOD_TYPE_QINGGONG then
                            table.insert(skills, skill.id)
                        end
                    end
                end
            end
        
            return self:__dealWithRecordSkills(skills)
        end,

        [LIST_TYPE.RECORD_NEIGONG] = function()
            local skills ={}
            if MapIsEmpty(self._skillList) == false then
                for __,skillId in ipairs(self._skillList) do
                    local skill = Skill:getSkill(skillId)
                    if skill and MapIsEmpty(skill.methods) == false then
                        for i,v in ipairs(skill.methods) do
                            if v == SKILL_METHOD_TYPE_NEIGONG then
                                table.insert(skills, skill.id)
                            end
                        end
                    end

                end
            end
        
            return self:__dealWithRecordSkills(skills)
        end,

        [LIST_TYPE.LEARN_QUANJIAO] = function()
            local skills ={}

            if MapIsEmpty(self._learnSkills) == false then
                for __,skillId in ipairs(self._learnSkills) do
                    local skill = Skill:getSkill(skillId)
                    if skill and MapIsEmpty(skill.methods) == false then
                        for i,v in ipairs(skill.methods) do
                            if v == SKILL_METHOD_TYPE_QUANJIAO then
                                table.insert(skills, skill.id)
                            end
                        end
                    end
                end
            end

            return self:__dealWithLearnSkills(skills)
        end,

        [LIST_TYPE.LEARN_BINGQI] = function()
            local skills ={}

            if MapIsEmpty(self._learnSkills) == false then
                for __,skillId in ipairs(self._learnSkills) do
                    local skill = Skill:getSkill(skillId)
                    if skill and MapIsEmpty(skill.methods) == false then
                        for i,v in ipairs(skill.methods) do
                            if bingqiType[v] then
                                table.insert(skills, skill.id)
                            end
                        end
                    end
                end
            end

            return self:__dealWithLearnSkills(skills)
        end,

        [LIST_TYPE.LEARN_QINGGONG] = function()
            local skills ={}
            
            if MapIsEmpty(self._learnSkills) == false then
                for __,skillId in ipairs(self._learnSkills) do
                    local skill = Skill:getSkill(skillId)
                    if skill and MapIsEmpty(skill.methods) == false then
                        for i,v in ipairs(skill.methods) do
                            if v == SKILL_METHOD_TYPE_QINGGONG then
                                table.insert(skills, skill.id)
                            end
                        end
                    end
                end
            end

            return self:__dealWithLearnSkills(skills)
        end,

        [LIST_TYPE.LEARN_NEIGONG] = function()
            local skills ={}

            if MapIsEmpty(self._learnSkills) == false then
                for __,skillId in ipairs(self._learnSkills) do
                    local skill = Skill:getSkill(skillId)
                    if skill and MapIsEmpty(skill.methods) == false then
                        for i,v in ipairs(skill.methods) do
                            if v == SKILL_METHOD_TYPE_NEIGONG then
                                table.insert(skills, skill.id)
                            end
                        end
                    end
                end
            end

            return self:__dealWithLearnSkills(skills)
        end,
        defalut = function()
            return {}
        end
    })
end

-- 1:江湖武学，2:门派武学，3:武学技能书
function recordAndLearnSkills:recordSkill(skillId,callback)
    local skillType = 1

    if self:__checkIsDreamSkill(skillId) then
        skillType = 2
    end

    HttpManagerEx:recordSkill(skillId,skillType,function(status, errcode, errmsg, data)
        if status == 200 and errcode == 0 then
            if callback then
                callback()
            end
        else
            PopText(errmsg)
        end
    end, IS_SHOW_WAITING)
end

function recordAndLearnSkills:learnSkill(skillId,callback)
    HttpManagerEx:learnSkill(skillId,function(status, errcode, errmsg, data)
        if status == 200 and errcode == 0 then
            self._role:addSkillExp(skillId,1)

            if callback then
                callback()
            end
        else
            PopText(errmsg)
        end
    end, IS_SHOW_WAITING)
end

function recordAndLearnSkills:getExchangeList()
end

function recordAndLearnSkills:__initRoleSkillList()
    self._skillList = {}
    local skills = self._role:getSkills()
    if MapIsEmpty(skills) == false then
        for __,skill in pairs(skills) do
            if self:__checkIsRecordedSkill(skill.id) ~= true and (self:__checkIsJiangHuSkill(skill.id) or self:__checkIsDreamSkill(skill.id)) then
                table.insert(self._skillList, skill.id)
            end
        end
    end
end

function recordAndLearnSkills:__checkIsDreamSkill(skillId)
    if not skillId then
        return false
    end

    return self._dreamSkills[skillId]
end

function recordAndLearnSkills:__checkIsJiangHuSkill(skillId)
    if not skillId then
        return false
    end
    return self._jianghuSkills[skillId]
end

function recordAndLearnSkills:__checkIsRecordedSkill(skillId)
    if not skillId then
        return false
    end

    if MapIsEmpty(self._learnSkills) == false then
        for __,_skillId in ipairs(self._learnSkills) do
            if _skillId == skillId then
                return true
            end
        end
    end

    return false
end

function recordAndLearnSkills:__initJiangHuSkills()
    self._jianghuSkills = {}
    local bookSkills = require("app.models.book.BookSkills")
	local jianghuSkills = clone(bookSkills:getbookSkill())
	for skillId,skill in pairs(jianghuSkills) do 
        if skill and skill.belong == 0 then --剔除门派技能 1为门派
            self._jianghuSkills[skillId] = true
        end
    end
end

function recordAndLearnSkills:__initLearnSkillList(callback)
    HttpManagerEx:getRecordSkills(function(status, errcode, errmsg, data)
        if status == 200 and errcode == 0 then
            self._learnSkills = data.record_skills

            if MapIsEmpty(data.learn) == false then
                self._currencyCost = data.learn.currency_cost
                self._currencyName = self._role:getCHAttrName(data.learn.currency_type)
            end
            
            if callback then
                callback()
            end
        else
            PopText(errmsg)
        end
    end, IS_SHOW_WAITING)
end

function recordAndLearnSkills:__filterRecordSkills(callback)
    HttpManagerEx:getRecordSkills(function(status, errcode, errmsg, data)
        if status == 200 and errcode == 0 then
            self._dreamSkills = {}  
            --data.dream_skills 梦境门派武学列表
            if MapIsEmpty(data.dream_skills == false) then 
                for __,skillId in ipairs(data.dream_skills) do
                    self._dreamSkills[skillId] = true
                end
            end

            self._learnSkills = data.record_skills --已记录可学习的武学

            self:__initRoleSkillList()
            
            if MapIsEmpty(data.record) == false then
                self._currencyCost = data.record.currency_cost
                self._currencyName = self._role:getCHAttrName(data.record.currency_type)
            end

            if callback then
                callback()
            end
        else
            PopText(errmsg)
        end
    end, IS_SHOW_WAITING)
end

function recordAndLearnSkills:__exchangeSkill()
end

function recordAndLearnSkills:__dealWithRecordSkills(skills)
    local _skills = {}
    if MapIsEmpty(skills) == false then
        for __,skillId in ipairs(skills) do
            local skill = {}
            skill.id = skillId
            skill.name = Skill:getSkill(skillId).name
            skill.btnName = "记录"

            table.insert(_skills, skill)
        end
    end

    local _isRepeat = {}
    for i = #_skills,1,-1 do 
        local skill = _skills[i]
        if not _isRepeat[skill.id] then
            _isRepeat[skill.id] = 0
        end

        if _isRepeat[skill.id] then
            _isRepeat[skill.id] = _isRepeat[skill.id] + 1
        end

        if _isRepeat[skill.id] > 1 then
            table.remove(_skills, i)
        end
    end

    table.sort(_skills, function(a,b)
        if a.id < b.id then
            return true
        else
            return false
        end
    end)

    return _skills
end

function recordAndLearnSkills:__dealWithLearnSkills(skills)
    local _skills = {}  
    if MapIsEmpty(skills) == false then
        for __,skillId in ipairs(skills) do
            local skill = {}
            skill.id = skillId
            skill.btnName = "学习"

            local skillInfo = Skill:getSkill(skillId)
            skill.name = skillInfo.name
            skill.type = skillInfo.type
            skill.state = 0--0 未学习 1 已学习

            if self._role:getSkill(skillId) then
                skill.state = 1
            end

            table.insert(_skills, skill)
        end
    end

    local _isRepeat = {}
    for i = #_skills,1,-1 do 
        local skill = _skills[i]
        if not _isRepeat[skill.id] then
            _isRepeat[skill.id] = 0
        end

        if _isRepeat[skill.id] then
            _isRepeat[skill.id] = _isRepeat[skill.id] + 1
        end

        if _isRepeat[skill.id] > 1 then
            table.remove(_skills, i)
        end
    end

    table.sort(_skills, function(a,b)
        if a.state > b.state then
            return false
        elseif a.state < b.state then
            return true
        end
        
        if a.id < b.id then
            return true
        else
            return false
        end
    end)
    
    return _skills
end


return class("recordAndLearnSkills", {}, recordAndLearnSkills)
000000