--[[
    author:Seven
    time:2024-01-11 15:43:17
    desc:
]]
local SkillStageFactory = {}

local SkillUtil = require("app.models.skill.SkillUtil")

local map = {}

function SkillStageFactory:getBasicSkillStageBySkillLevel(lv, conf)
    local stageId = SkillUtil:skillLvMapToSkillStageIdOnConfig(lv, conf)
    return self:getBasicSkillStageByStageId(stageId, conf)
end

function SkillStageFactory:getBasicSkillStageByStageId(stageId, conf)
    local classObject = self:__getCache(conf, stageId)

    if classObject ~= nil then
        return classObject
    end

    local res = conf[stageId]

    if res == nil then
        error("SkillStageFactory:getBasicSkillStageByStageId 找不到资源：" .. tostring(stageId))
    end

    local BasicSkillStage = require("app.models.skill.SkillStage.BasicSkillStage")

    local classObject = BasicSkillStage:create(res)

    self:__saveCache(conf, stageId, classObject)

    return classObject
end

function SkillStageFactory:__saveCache(conf, stageId, classObject)
    if map[conf] == nil then
        map[conf] = {}
    end

    map[conf][stageId] = classObject
end

function SkillStageFactory:__getCache(conf, stageId)
    if map[conf] == nil then
        return nil
    end

    return map[conf][stageId]
end

return SkillStageFactory
000