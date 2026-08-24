local SkillHelper = {}
local SkillConst = require("app.models.skill.SkillConst")

function SkillHelper:getExp(skillId, lv)
    local skill = Skill:getSkill(skillId)
    assert(skill, "SkillHelper:getExp, skillId :" .. tostring(skillId) .. "  lv:" .. tostring(lv))

    return skill:getExp(lv)
end

function SkillHelper:getLv(skillId, exp)
    local skill = Skill:getSkill(skillId)
    assert(skill, "SkillHelper:getLv, skillId :" .. tostring(skillId) .. "  exp:" .. tostring(exp))

    return skill:getLv(exp)
end

function SkillHelper:getSkillLvLimit(role, skillId)
    local skill = Skill:getSkill(skillId)
    assert(skill, "SkillHelper:getSkillLvLimit, skillId :" .. tostring(skillId))

    if table.indexof(SkillConst.SpecialGrowUpZhiShiSkillList, skillId) then
        return skill:getMaxLv()
    else
        return role:getSkillBreakThroughSystem():getSkillBreakThroughMap(skillId).Blevel
    end
end

function SkillHelper:addSkillLv(role, skillId, lv)
    local roleSkill = role:getSkill(skillId)
    local afterLv = lv

    if roleSkill then
        afterLv = afterLv + self:getLv(skillId, roleSkill.exp)
    end

    afterLv = math.min(afterLv, self:getSkillLvLimit(role, skillId))
    afterLv = math.max(afterLv, 1)

    local exp = self:getExp(skillId, afterLv)
    self:setRoleSkill(role, skillId, {id = skillId, exp = exp})
end

function SkillHelper:addSkillExp(role, skillId, exp)
    local roleSkill = role:getSkill(skillId)
    local afterExp = exp
    if roleSkill then
        afterExp = afterExp + roleSkill.exp
    end

    afterExp = math.min(afterExp, self:getExp(skillId, self:getSkillLvLimit(role, skillId)))
    afterExp = math.max(afterExp, 1)

    self:setRoleSkill(role, skillId, {id = skillId, exp = afterExp})
end

function SkillHelper:setSkillLv(role, skillId, lv)
    lv = math.min(lv, self:getSkillLvLimit(role, skillId))

    lv = math.max(lv, 1)

    local exp = self:getExp(skillId, lv)

    self:setRoleSkill(role, skillId, {id = skillId, exp = exp})
end

function SkillHelper:setSkillExp(role, skillId, exp)
    local maxExp = self:getExp(skillId, self:getSkillLvLimit(role, skillId))

    exp = math.min(exp, maxExp)

    exp = math.max(exp, 1)

    self:setRoleSkill(role, skillId, {id = skillId, exp = exp})
end

--[[
    @desc: 
    author:tanqinjian
    time:2025-05-15 13:50:54
    --@role:
	--@skillId:
	--@skillData: {id = skillId, exp = exp}
    @return:
]]
function SkillHelper:setRoleSkill(role, skillId, skillData)
    if self:checkIsSelfCreatedSkillId(skillId) then
        local exp = skillData.exp
        local currExp = role:getSkillExp(skillId)
        role:addSelfCreatedSkillExp(skillId, exp - currExp)
    else
        role:setSkill(skillId, skillData)
    end
end

function SkillHelper:selfCreatedSkillDataIdToSkillId(roleOnlyId, skillDataId)
    return roleOnlyId .. "_selfCreatedSkill_" .. tostring(skillDataId)
end

function SkillHelper:skillIdToSelfCreatedSkillDataId(skillId)
    local startIndex, endIndex = string.find(skillId, "_selfCreatedSkill_")
    if endIndex then
        return string.sub(skillId, endIndex + 1)
    end

    return skillId
end

function SkillHelper:checkSkillIdIsSelfCreatedSkillDataId(role, skillId)
    local selfCreatedSkillData = role:getSelfCreatedSkillSystem():getCreatedSkillData()
    if MapIsEmpty(selfCreatedSkillData) == false then
        if selfCreatedSkillData[skillId] then
            return true
        end
    end

    return false
end

function SkillHelper:checkIsSelfCreatedSkillId(skillId)
    local startIndex, endIndex = string.find(skillId, "_selfCreatedSkill_")
    if endIndex then
        return true
    end

    return false
end

function SkillHelper:changeRoleSelfCreatedSkillId(role)
    local selfCreatedSkillData = role:getSelfCreatedSkillSystem():getCreatedSkillData()

    if MapIsEmpty(selfCreatedSkillData) == false then
        local prepareSkills = role:getAttr("skillPrepare")

        if MapIsEmpty(prepareSkills) == false then
            for prepareType, skillId in pairs(prepareSkills) do
                if selfCreatedSkillData[skillId] and self:checkIsSelfCreatedSkillId(skillId) == false then
                    local newSkillId = self:selfCreatedSkillDataIdToSkillId(role:getAttr("userid"), skillId)
                    if newSkillId ~= prepareSkills[prepareType] then
                        prepareSkills[prepareType] = newSkillId
                    end
                end
            end
        end

        local roleCurrState = role:getAttr("roleCurrState")
        local isOldXiuLian = false
        local isOldLianGong = false

        if MapIsEmpty(roleCurrState) == false then
            if role:getInheritFlag("roleStateChange") == 0 then
                -- TODO: 很久之前的版本旧存档角色状态存储使用的列表形式，后面的流程会有修复，整体兼容后续需改动
                for _, state in ipairs(roleCurrState) do
                    if tostring(state) == tostring(ROLE_CURR_STATE_XIULIAN) then
                        isOldXiuLian = true
                    elseif tostring(state) == tostring(ROLE_CURR_STATE_LIANGONG) then
                        isOldLianGong = true
                    end
                end
            elseif role:getInheritFlag("roleStateChange") == 1 then
                for state, bool in pairs(roleCurrState) do
                    if tostring(state) == tostring(ROLE_CURR_STATE_XIULIAN) then
                        isOldXiuLian = true
                    elseif tostring(state) == tostring(ROLE_CURR_STATE_LIANGONG) then
                        isOldLianGong = true
                    end
                end
            end
        end

        if isOldXiuLian then
            local xiuLianData = role:getAttr("xiuLianData")
            if MapIsEmpty(xiuLianData) == false then
                if selfCreatedSkillData[xiuLianData.skillId] then
                    xiuLianData.skillId = self:selfCreatedSkillDataIdToSkillId(role:getAttr("userid"), xiuLianData.skillId)
                end
            end
        end

        if isOldLianGong then
            local skillId = role:getFlag("当前武功")
            if skillId and selfCreatedSkillData[skillId] then
                role:setFlag("当前武功", self:selfCreatedSkillDataIdToSkillId(role:getAttr("userid"), skillId))
            end
        end

        local skillBreakData = role:getAttr("skillBreakData")
        local needRemoveList = {}
        for skillId, v in pairs(skillBreakData) do
            if selfCreatedSkillData[skillId] then
                table.insert(needRemoveList, skillId)
                local newSkillId = self:selfCreatedSkillDataIdToSkillId(role:getAttr("userid"), skillId)
                skillBreakData[newSkillId] = v
            end
        end

        for i = 1, #needRemoveList, 1 do
            skillBreakData[needRemoveList[i]] = nil
        end

        if Game:isTesting() then
            --由于自创武学id：userid__selfCreatedSkill__自创数据id，盖档需要调整成正确的userid
            if MapIsEmpty(prepareSkills) == false then
                for prepareType, skillId in pairs(prepareSkills) do
                    if self:checkIsSelfCreatedSkillId(skillId) then
                        local skillDataId = self:skillIdToSelfCreatedSkillDataId(skillId)
                        prepareSkills[prepareType] = self:selfCreatedSkillDataIdToSkillId(role:getAttr("userid"), skillDataId)
                    end
                end
            end

            local needRemoveList = {}
            for skillId, v in pairs(skillBreakData) do
                if self:checkIsSelfCreatedSkillId(skillId) then
                    local skillDataId = self:skillIdToSelfCreatedSkillDataId(skillId)
                    local newSkillId = self:selfCreatedSkillDataIdToSkillId(role:getAttr("userid"), skillDataId)

                    if newSkillId ~= skillId then
                        table.insert(needRemoveList, skillId)
                        skillBreakData[newSkillId] = v
                    end
                end
            end

            for i = 1, #needRemoveList, 1 do
                skillBreakData[needRemoveList[i]] = nil
            end
        end
    end
end

return SkillHelper
00000