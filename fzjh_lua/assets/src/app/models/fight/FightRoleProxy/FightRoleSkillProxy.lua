--[[
    author:Seven
    time:2025-09-15 15:17:00
    desc: 战斗中角色技能相关逻辑的代理
]]
local FightRoleSkillProxy = {}

function FightRoleSkillProxy:create(role)
    local o = {}
    FightRoleSkillProxy.__index = FightRoleSkillProxy
    setmetatable(o, FightRoleSkillProxy)
    o.__role = role

    o:__init()

    return o
end

function FightRoleSkillProxy:__init()
    self:__initBuildSkillIndex()
end

function FightRoleSkillProxy:__addToSortedList(sortedList, prepareType, item)
    assert(item.id and item.level, "add_sorted_list item must have id and level")
    if not sortedList[0] then
        sortedList[0] = {}
    end

    if not sortedList[prepareType] then
        sortedList[prepareType] = {}
    end
    table.insert(sortedList[prepareType], item)
end

function FightRoleSkillProxy:__binarySearchSkillCount(skillList, threshold)
    if skillList.__cache == nil then
        skillList.__cache = {}
    end

    if skillList.__cache[threshold] then
        return skillList.__cache[threshold]
    end

    if not skillList or #skillList == 0 then
        return 0
    end

    if skillList[#skillList].level < threshold then
        return 0
    end

    if skillList[1].level >= threshold then
        return #skillList
    end

    local left, right = 1, #skillList
    while left < right do
        local mid = math.floor((left + right) / 2)
        if skillList[mid].level < threshold then
            left = mid + 1
        else
            right = mid
        end
    end

    local num = skillList[left] and skillList[left].level >= threshold and (#skillList - left + 1) or 0
    skillList.__cache[threshold] = num
    return num
end

function FightRoleSkillProxy:__initBuildSkillIndex()
    local sortedSkillsByType = {}
    local sortedSkillsLimitLvByType = {}

    local role = self.__role
    local skills = role:getSkills()

    for k, roleSkill in pairs(skills) do
        local skillId = roleSkill.id
        local skill = Skill:getSkill(skillId)
        if skill == nil then
            goto __continue__
        end
        local skillexp = roleSkill.exp


        if skill.type ~= SKILL_TYPE_BASE then
            local skillLevel = skill:getLv(skillexp)
            local skillLvLimit = role:getSkillLvLimit(skillId)
            local skill_lv_item = {id = skillId, level = skillLevel}
            local skill_lv_limit_item = {id = skillId, level = skillLvLimit}
            self:__addToSortedList(sortedSkillsByType, 0, skill_lv_item)
            self:__addToSortedList(sortedSkillsLimitLvByType, 0, skill_lv_limit_item)

            -- 配有skill.methods有数据时表示该技能可被准备
            if skill.methods then
                for _, method in ipairs(skill.methods) do
                    self:__addToSortedList(sortedSkillsByType, method, skill_lv_item)
                    self:__addToSortedList(sortedSkillsLimitLvByType, method, skill_lv_limit_item)
                end
            end
        end

        ::__continue__::
    end

    -- 按等级排序
    for pType, skillList in pairs(sortedSkillsByType) do
        table.sort(
            skillList,
            function(a, b)
                return a.level < b.level
            end
        )
    end

    for pType, skillList in pairs(sortedSkillsLimitLvByType) do
        table.sort(
            skillList,
            function(a, b)
                return a.level < b.level
            end
        )
    end

    self.__sortedSkillsByType = sortedSkillsByType
    self.__sortedSkillsLimitLvByType = sortedSkillsLimitLvByType

    self.__role["getNumOfSkillsByTypeAndLevelLimit"] = function(_, prepareType, needSkillLvLimit)
        return self:__binarySearchSkillCount(self.__sortedSkillsLimitLvByType[prepareType], needSkillLvLimit)
    end

    self.__role["getNumOfSkillsByTypeAndLevel"] = function(_, prepareType, needSkillLv)
        return self:__binarySearchSkillCount(self.__sortedSkillsByType[prepareType], needSkillLv)
    end
end

return FightRoleSkillProxy
00