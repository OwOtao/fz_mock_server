local recordConditions = require("script.others.Records")["condition"]

local AchievementUnlockConditions = {}

local log = function(...)
    if DEBUG_MODE == 1 then
        print(...)
    end
end

local CONDITION_TYPE = {
    ATTR_TYPE = 1,
    ITEM_TYPE = 2,
    SKILL_TYPE = 3,
    TUJIAN_GRASP_TYPE = 4,
    TUJIAN_SEE_TYPE = 5,
}

local attrTypeRecord = {}
local itemTypeRecord = {}
local skillTypeRecord = {}
local tujianGraspTypeRecord = {}
local tujianSeeTypeRecord = {}

function AchievementUnlockConditions:initRecordConditions()
    self:getAttrTypeRecord()
    self:getItemTypeRecord()
    self:getSkillTypeRecord()
    self:getTujianGraspTypeRecord()
    self:getTujianSeeTypeRecord()
end

function AchievementUnlockConditions:getConditionsByRecordId(recordId)
    if attrTypeRecord[recordId] then
        return attrTypeRecord[recordId]
    elseif itemTypeRecord[recordId] then
        return itemTypeRecord[recordId]
    elseif skillTypeRecord[recordId] then
        return skillTypeRecord[recordId]
    elseif tujianGraspTypeRecord[recordId] then
        return tujianGraspTypeRecord[recordId]
    elseif tujianSeeTypeRecord[recordId] then
        return tujianSeeTypeRecord[recordId]
    end
    log("AchievementUnlockConditions:getConditionsByRecordId unknown type ,recordId: "..recordId)
    return
end

function AchievementUnlockConditions:getAttrTypeConditionsByRecordId(recordId)
    if attrTypeRecord[recordId] then
        return attrTypeRecord[recordId]
    end
    log("AchievementUnlockConditions:getAttrTypeConditionsByRecordId unknown type ,recordId: "..recordId)
    return
end

function AchievementUnlockConditions:getItemTypeConditionsByRecordId(recordId)
    if itemTypeRecord[recordId] then
        return itemTypeRecord[recordId]
    end
    log("AchievementUnlockConditions:getItemTypeConditionsByRecordId unknown type ,recordId: "..recordId)
    return
end

function AchievementUnlockConditions:getSkillTypeConditionsByRecordId(recordId)
    if skillTypeRecord[recordId] then
        return skillTypeRecord[recordId]
    end
    log("AchievementUnlockConditions:getSkillTypeConditionsByRecordId unknown type ,recordId: "..recordId)
    return
end

function AchievementUnlockConditions:gettujianGraspTypeConditionsByRecordId(recordId)
    if tujianGraspTypeRecord[recordId] then
        return tujianGraspTypeRecord[recordId]
    end 
    log("AchievementUnlockConditions:gettujianGraspTypeConditionsByRecordId unknown type ,recordId: "..recordId)
    return
end

function AchievementUnlockConditions:gettujianSeeTypeConditionsByRecordId(recordId)
    if tujianSeeTypeRecord[recordId] then
        return tujianSeeTypeRecord[recordId]
    end
    log("AchievementUnlockConditions:gettujianSeeTypeConditionsByRecordId unknown type ,recordId: "..recordId)
    return
end

function AchievementUnlockConditions:getAttrTypeRecord()
    for k,v in pairs(recordConditions) do
        if CONDITION_TYPE.ATTR_TYPE == v.type then
            local attrName = AttrName[v.Params]
            attrTypeRecord[v.recordid] = v
            attrTypeRecord[v.recordid].Params = attrName
            local valueStr = v.value
            local symbol = string.find(valueStr,",")

            --assert(symbol,"script.others.Records condition: "..tostring(v.id).." value not symbol")

            if symbol == 1 then
                attrTypeRecord[v.recordid].symbol = "<"
            else
                attrTypeRecord[v.recordid].symbol = ">"
            end
            local value = string.gsub(valueStr,",","")
            attrTypeRecord[v.recordid].value = tonumber(value)
        end
    end
end

function AchievementUnlockConditions:getItemTypeRecord()
    for k,v in pairs(recordConditions) do
        if CONDITION_TYPE.ITEM_TYPE == v.type then
            itemTypeRecord[v.recordid] = v
            local valueStr = v.value
            local symbol = string.find(valueStr,",")

            --assert(symbol,"script.others.Records condition: "..tostring(v.id).." value not symbol")

            if symbol == 1 then
                itemTypeRecord[v.recordid].symbol = "<"
            else
                itemTypeRecord[v.recordid].symbol = ">"
            end
            local value = string.gsub(valueStr,",","")
            itemTypeRecord[v.recordid].value = tonumber(value)
        end
    end
end

function AchievementUnlockConditions:getSkillTypeRecord()
    for k,v in pairs(recordConditions) do
        if CONDITION_TYPE.SKILL_TYPE == v.type then
            skillTypeRecord[v.recordid] = v
            local valueStr = v.value
            local symbol = string.find(valueStr,",")

            --assert(symbol,"script.others.Records condition: "..tostring(v.id).." value not symbol")

            if symbol == 1 then
                skillTypeRecord[v.recordid].symbol = "<"
            else
                skillTypeRecord[v.recordid].symbol = ">"
            end
            local value = string.gsub(valueStr,",","")
            skillTypeRecord[v.recordid].value = tonumber(value)
        end
    end
end

function AchievementUnlockConditions:getTujianSeeTypeRecord()
    for k,v in pairs(recordConditions) do
        if CONDITION_TYPE.TUJIAN_SEE_TYPE == v.type then
            tujianSeeTypeRecord[v.recordid] = v
            local valueStr = v.value
            local symbol = string.find(valueStr,",")

            if symbol == 1 then
                tujianSeeTypeRecord[v.recordid].symbol = "<"
            else
                tujianSeeTypeRecord[v.recordid].symbol = ">"
            end
            local value = string.gsub(valueStr,",","")
            tujianSeeTypeRecord[v.recordid].value = tonumber(value)
        end
    end
end

function AchievementUnlockConditions:getTujianGraspTypeRecord()
    for k,v in pairs(recordConditions) do
        if CONDITION_TYPE.TUJIAN_GRASP_TYPE == v.type then
            tujianGraspTypeRecord[v.recordid] = v
            local valueStr = v.value
            local symbol = string.find(valueStr,",")

            if symbol == 1 then
                tujianGraspTypeRecord[v.recordid].symbol = "<"
            else
                tujianGraspTypeRecord[v.recordid].symbol = ">"
            end
            local value = string.gsub(valueStr,",","")
            tujianGraspTypeRecord[v.recordid].value = tonumber(value)
        end
    end
end


function AchievementUnlockConditions:checkAttrCondition(recordId,roleAttrValue)
    local value = attrTypeRecord[recordId].value
    local symbol = attrTypeRecord[recordId].symbol
    log("--------checkAttrCondition:",recordId,roleAttrValue,symbol,value)
    if symbol == ">" then
        return roleAttrValue > value
    else
        return roleAttrValue < value
    end
end

function AchievementUnlockConditions:checkSkillCondition(recordId,roleSkillLv)
    local value = skillTypeRecord[recordId].value
    local symbol = skillTypeRecord[recordId].symbol
    log("--------checkSkillCondition:",recordId,roleSkillLv,symbol,value)
    if symbol == ">" then
        return roleSkillLv > value
    else
        return roleSkillLv < value
    end
end

function AchievementUnlockConditions:checkItemCondition(recordId,roleItemNum)
    local value = itemTypeRecord[recordId].value
    local symbol = itemTypeRecord[recordId].symbol
    log("--------checkItemCondition:",recordId,roleItemNum,symbol,value)
    if symbol == ">" then
        return roleItemNum > value
    else
        return roleItemNum < value
    end
end

function AchievementUnlockConditions:checkTujianCondition(recordId,skillNums)

    local value
    local symbol

    if  tujianGraspTypeRecord[recordId] then
        value = tujianGraspTypeRecord[recordId].value
        symbol = tujianGraspTypeRecord[recordId].symbol
    elseif tujianSeeTypeRecord[recordId] then
        value = tujianSeeTypeRecord[recordId].value
        symbol = tujianSeeTypeRecord[recordId].symbol
    end
    log("--------checkTujianCondition:",recordId,skillNums,symbol,value)
    if symbol == ">" then
        return skillNums > value
    else
        return skillNums < value
    end
end

AchievementUnlockConditions:initRecordConditions()

return AchievementUnlockConditions0