local recordData = require("script.others.Records")["record"]
local AchievementRecord = {}

local RECORD_TYPE = {
    ITEM_TYPE = 3,
    SKILL_TYPE = 4,
    ATTR_TYPE = 5,
    TUJIAN_TYPE = 6,
}
local record_info = {}

function AchievementRecord:initRecords()
    for k,v in pairs(recordData) do
        record_info[v.id] = v
    end
end

AchievementRecord:initRecords()

--value 字段 0 表示只需记录一次 1表示有多少次记录多少次
function AchievementRecord:checkIsNeedRecord(recordId)
    return record_info[recordId].value
end

function AchievementRecord:getRecordById(recordId)
    return record_info[recordId]
end

function AchievementRecord:getAttrTypeRecords()
    local attrRecords = {}

    for k,v in pairs(record_info) do
        if v.type == RECORD_TYPE.ATTR_TYPE then
            attrRecords[v.id] = v
        end
    end
    
    return attrRecords
end

function AchievementRecord:getItemTypeRecords()
    local itemRecords = {}

    for k,v in pairs(record_info) do
        if v.type == RECORD_TYPE.ITEM_TYPE then
            itemRecords[v.id] = v
        end
    end
    
    return itemRecords
end

function AchievementRecord:getSkillTypeRecords()
    local skillRecords = {}

    for k,v in pairs(record_info) do
        if v.type == RECORD_TYPE.SKILL_TYPE then
            skillRecords[v.id] = v
        end
    end
    
    return skillRecords
end

function AchievementRecord:getTujianTypeRecords()
    local tujianRecords = {}

    for k,v in pairs(record_info) do
        if v.type == RECORD_TYPE.TUJIAN_TYPE then
            tujianRecords[v.id] = v
        end
    end
    
    return tujianRecords
end

return AchievementRecord0000000000000000