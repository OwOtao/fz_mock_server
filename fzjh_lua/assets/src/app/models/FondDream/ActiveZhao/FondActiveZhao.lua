local FondActiveZhao = {}

local ATTR_CHANGE_MAP = {
    ["strCondSkill"] = "currStr",
    ["conCondSkill"] = "currCon",
    ["dexCondSkill"] = "currDex",
    ["intCondSkill"] = "currInt"
}

local SKILL_TYPE_CHANGE_MAP = {
    ["1"] = "攻击武学",
    ["2"] = "攻击武学",
    ["1@2"] = "攻击武学",
    ["3"] = "内功武学",
    ["4"] = "轻功武学",
    ["5"] = "招架武学"
}

function FondActiveZhao:create(zhaoId, level)
    local BasicActiveSkillManager = require("app.models.skill.BasicSkill.BasicActiveSkillManager")
    local ActiveZhao = require("app.models.skill.ActiveZhao")
    self._activeZhao = BasicActiveSkillManager:getBasicActiveZhaoCombination(zhaoId, Helper:getDef(level, 1))
    local zhaoData = self:getZhaoData()

    return ActiveZhao:create(zhaoData)
end

function FondActiveZhao:getZhaoData()
    local retData = {
        id = self._activeZhao:getId(),
        name = self._activeZhao:getCombName(),
        type = self:_getType(),
        methods = self._activeZhao:getMethods(),
        desc = self._activeZhao:getDesc(),
        useDesc = self._activeZhao:getActionText(),
        cost = self._activeZhao:getNeiliCost(),
        cd = self._activeZhao:getCd(),
        learnMethod = self._activeZhao:getLearnMethod()
    }
    self:_initLearnConditions(retData)
    self:_initUseConditions(retData)
    return retData
end

function FondActiveZhao:_getType()
    local type = self._activeZhao:getActiveType()
    local FightCommons = require("app.FightSystem.FightCommons")

    if type == FightCommons.ACTIVE_TYPE.ATTACK then
        return "攻击"
    else
        return "释放"
    end
end

function FondActiveZhao:_initLearnConditions(retData)
    local learnConditions = self._activeZhao:getLearnConditions()
    if MapIsEmpty(learnConditions) == false then
        for index, condition_info in ipairs(learnConditions) do
            local condition = string.split(condition_info, "#")
            local type = condition[1]
            local id = condition[2]
            local logic = condition[3]
            local value = condition[4]
            if tonumber(type) == 1 then
                retData["learn_type_" .. index] = "属性"
                if ATTR_CHANGE_MAP[id] then
                    id = ATTR_CHANGE_MAP[id]
                end
                retData["learn_id_" .. index] = id
                retData["learn_logic_" .. index] = logic
                retData["learn_value_" .. index] = tonumber(value)
            elseif tonumber(type) == 2 then
                retData["learn_type_" .. index] = "武功"
                retData["learn_id_" .. index] = id
                retData["learn_logic_" .. index] = logic
                retData["learn_value_" .. index] = tonumber(value)
            elseif tonumber(type) == 3 then
                retData["learn_type_" .. index] = "门派"
                local idStr = string.gsub(id, "@", " or ")
                retData["learn_id_" .. index] = idStr
                retData["learn_logic_" .. index] = logic
                retData["learn_value_" .. index] = value
            end
        end
    end
end

function FondActiveZhao:_initUseConditions(retData)
    local useConditions = self._activeZhao:getUseConditions()
    if MapIsEmpty(useConditions) == false then
        for index, condition_info in ipairs(useConditions) do
            local condition = string.split(condition_info, "#")
            local type = condition[1]
            local id = condition[2]
            local logic = condition[3]
            local value = condition[4]
            if tonumber(type) == 1 then
                retData["use_type_" .. index] = "属性"
                if ATTR_CHANGE_MAP[id] then
                    id = ATTR_CHANGE_MAP[id]
                end
                retData["use_id_" .. index] = id
                retData["use_logic_" .. index] = logic
                retData["use_value_" .. index] = tonumber(value)
            elseif tonumber(type) == 2 then
                retData["use_type_" .. index] = "武功"
                retData["use_id_" .. index] = id
                retData["use_logic_" .. index] = logic
                retData["use_value_" .. index] = tonumber(value)
            elseif tonumber(type) == 3 then
                retData["use_type_" .. index] = "装备技能"
                local idStr = string.gsub(id, "@", " or ")
                retData["use_id_" .. index] = idStr
                retData["use_logic_" .. index] = logic
                if tonumber(value) == 0 then
                    value = "是"
                else
                    local SkillClassifyManager = require("app.FightSystem.FightSkill.SkillClassifyManager")
                    local activeMethods = SkillClassifyManager:getActiveMethodsByNewSkillFirstType(value)
                    value = tonumber(activeMethods)
                end
                retData["use_value_" .. index] = value
            elseif tonumber(type) == 4 then
                retData["use_type_" .. index] = "装备武器"
                retData["use_id_" .. index] = id
                retData["use_logic_" .. index] = "等于"
                retData["use_value_" .. index] = value
            elseif tonumber(type) == 5 then
                retData["use_type_" .. index] = "门派"
                local idStr = string.gsub(id, "@", " or ")
                retData["use_id_" .. index] = idStr
                retData["use_logic_" .. index] = "等于"
                retData["use_value_" .. index] = value
            elseif tonumber(type) == 6 then
                retData["use_type_" .. index] = "使用武学"
                local idStr = string.gsub(id, "@", " or ")
                retData["use_id_" .. index] = idStr
                retData["use_logic_" .. index] = "等于"
                retData["use_value_" .. index] = SKILL_TYPE_CHANGE_MAP[tostring(value)]
            elseif tonumber(type) == 7 then
                retData["use_type_" .. index] = "使用武学属于门派"
                local idStr = SKILL_TYPE_CHANGE_MAP[tostring(id)]
                local value = string.gsub(value, "@", " or ")
                retData["use_id_" .. index] = idStr
                retData["use_logic_" .. index] = "等于"
                retData["use_value_" .. index] = value
            end
        end
    end
end

return FondActiveZhao
000000