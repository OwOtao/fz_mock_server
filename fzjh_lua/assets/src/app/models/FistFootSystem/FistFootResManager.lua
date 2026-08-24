local FistFootResManager = {
    __branchGroup = {},
    __reflectLevelMap = {},
    __techniqueLevelData = {},
    __techniqueLevelMap = {},
    __talentLevelMap = {},
    __eventTextGroup = {},
    __characterPoolMap = {},
    __characterMap = {},
    __taskMap = {},
    __techniqueResetMap = {}
}

local function loadRes()
    local branchLevelMap = requireWithEncrypt("script.fistFoot.branchLevel")["1"]

    local branchGroup = {}

    for k, v in pairs(branchLevelMap) do
        if branchGroup[tostring(v.type)] == nil then
            branchGroup[tostring(v.type)] = {}
        end
        branchGroup[tostring(v.type)][v.level] = v
    end
    FistFootResManager.__branchGroup = branchGroup

    local baseLevelMap = requireWithEncrypt("script.fistFoot.baseLevel")["1"]

    local reflectLevelMap = {}

    for k, v in pairs(baseLevelMap) do
        reflectLevelMap[v.basislv] = v
    end
    FistFootResManager.__reflectLevelMap = reflectLevelMap

    local techniqueLevelData = requireWithEncrypt("script.fistFoot.techniqueLevel")["1"]

    local techniqueLevelMap = {}

    for k, v in pairs(techniqueLevelData) do
        if techniqueLevelMap[tostring(v.skillid)] == nil then
            techniqueLevelMap[tostring(v.skillid)] = {}
        end
        techniqueLevelMap[tostring(v.skillid)][v.skilllv] = v
    end

    FistFootResManager.__techniqueLevelMap = techniqueLevelMap

    FistFootResManager.__techniqueLevelData = techniqueLevelData

    local talentLevelMap = requireWithEncrypt("script.fistFoot.talentLevel")["1"]

    FistFootResManager.__talentLevelMap = talentLevelMap

    local eventTextMap = requireWithEncrypt("script.fistFoot.eventText")["1"]

    local eventTextGroup = {}

    for k, v in pairs(eventTextMap) do
        if eventTextGroup[tostring(v.incidentsid)] == nil then
            eventTextGroup[tostring(v.incidentsid)] = {}
        end
        table.insert(eventTextGroup[tostring(v.incidentsid)], v.text)
    end
    FistFootResManager.__eventTextGroup = eventTextGroup

    local characterPoolMap = requireWithEncrypt("script.fistFoot.characterPool")["1"]

    FistFootResManager.__characterPoolMap = characterPoolMap

    local characterData = requireWithEncrypt("script.fistFoot.character")["1"]

    local characterMap = {}

    for k, v in pairs(characterData) do
        if characterMap[tostring(v.peculiarityid)] == nil then
            characterMap[tostring(v.peculiarityid)] = {}
        end
        characterMap[tostring(v.peculiarityid)][v.level] = v
    end

    FistFootResManager.__characterMap = characterMap

    local taskMap = requireWithEncrypt("script.fistFoot.tasks")["1"]

    FistFootResManager.__taskMap = taskMap

    local techniqueReset = requireWithEncrypt("script.fistFoot.techniqueReset")["1"]

    FistFootResManager.__techniqueResetMap = techniqueReset
end

loadRes()

local BasicFistFootTechnique = require("app.models.FistFootSystem.FistFootTechniques.BasicFistFootTechnique")
local techniqueCacheMap = {}

--@RefType [src.app.models.FistFootSystem.FistFootEffect.FistFootEffect#FistFootEffect]
local FistFootEffect = require("app.models.FistFootSystem.FistFootEffect.FistFootEffect")
local effectCacheMap = {}

local BasicFistFootBranch = require("app.models.FistFootSystem.FistFootBranch.BasicFistFootBranch")
local branchCacheMap = {}

function FistFootResManager:getBranchMap(type)
    return assert(self.__branchGroup[tostring(type)], "FistFootResManager:getBranchMap 武学类型id：" .. type .. "填写错误！")
end

function FistFootResManager:getReflectLevelMap()
    return self.__reflectLevelMap
end

function FistFootResManager:getTechniqueLevelData()
    return self.__techniqueLevelData
end

function FistFootResManager:getTechniqueLevelGroup(id)
    if self.__techniqueLevelMap[tostring(id)] == nil then
        assert(nil, "FistFootResManager:getTechniqueLevelGroup 技巧id：" .. id .. "有误！")
    end

    return self.__techniqueLevelMap[tostring(id)]
end

function FistFootResManager:getTechniqueData(id, lv)
    if self.__techniqueLevelMap[tostring(id)] == nil then
        assert(nil, "FistFootResManager:getTechniqueData 技巧id：" .. id .. "有误！")
    end
    if self.__techniqueLevelMap[tostring(id)][lv] == nil then
        assert(nil, "FistFootResManager:getTechniqueData 技巧等级lv：" .. lv .. "有误！")
    end

    return self.__techniqueLevelMap[tostring(id)][lv]
end

function FistFootResManager:getTalentLevelMap()
    return self.__talentLevelMap
end

function FistFootResManager:getEventTextGroup()
    return self.__eventTextGroup
end

function FistFootResManager:getCharacterPoolMap()
    return self.__characterPoolMap
end

function FistFootResManager:getCharacterMap()
    return self.__characterMap
end

function FistFootResManager:getCharacterData(id, lv)
    if self.__characterMap[tostring(id)] == nil then
        assert(nil, "FistFootResManager:getCharacterData 特性id：" .. id .. "有误！")
    end
    if self.__characterMap[tostring(id)][lv] == nil then
        assert(nil, "FistFootResManager:getCharacterData 特性等级lv：" .. lv .. "有误！")
    end

    return self.__characterMap[tostring(id)][lv]
end

function FistFootResManager:getTaskMap()
    return self.__taskMap
end

function FistFootResManager:getResetData(resetCount)
    if self.__techniqueResetMap[resetCount] == nil then
        assert(nil, "FistFootResManager:getResetData 技巧回溯次数 resetCount：" .. resetCount .. "有误！")
    end
    return self.__techniqueResetMap[resetCount]
end

function FistFootResManager:getMaxResetCount()
    return #self.__techniqueResetMap
end

--@desc: 获取技巧基础资源类
--@author:Seven
--@time:2022-10-18 16:57:25
--@t_id: 技巧ID
--@t_lv: 技巧等级
--@return: [src.app.models.FistFootSystem.FistFootTechniques.BasicFistFootTechnique#BasicFistFootTechnique]
function FistFootResManager:getBasicFistFootTechnique(t_id, t_lv)
    local p = techniqueCacheMap[tostring(t_id) .. "|" .. tostring(t_lv)]

    if p == nil then
        local res = self:getTechniqueData(t_id, t_lv)
        p = BasicFistFootTechnique:create(res)
        techniqueCacheMap[tostring(t_id) .. "|" .. tostring(t_lv)] = p
    end

    return p
end

--@desc: 获取特性资源类
--@author:LvBin
--@time:2022-10-20 15:51:29
--@e_id: 特性id
--@e_lv: 特性等级
--@return
function FistFootResManager:getFistFootEffect(e_id, e_lv)
    local p = effectCacheMap[tostring(e_id) .. "|" .. tostring(e_lv)]

    if p == nil then
        local res = self:getCharacterData(e_id, e_lv)
        p = FistFootEffect:create(res)
        techniqueCacheMap[tostring(e_id) .. "|" .. tostring(e_lv)] = p
    end

    return p
end

function FistFootResManager:__getBranchResByTypeAndLv(b_type, b_lv)
    local groupByType = self.__branchGroup[tostring(b_type)]
    if groupByType == nil then
        assert(false, "FistFootResManager:__getBranchResByTypeAndLv 未知拳脚分支类型：" .. tostring(b_type))
    end

    local res = groupByType[b_lv]

    if res == nil then
        assert(false, "FistFootResManager:__getBranchResByTypeAndLv 拳脚分支类型：" .. tostring(b_type) .. "对应等级" .. tostring(b_lv) .. " 相关数据未找到")
    end

    return res
end

--@desc: 获取拳脚分支资源基础类
--@author:Seven
--@time:2022-11-25 16:00:59
--@b_type: 分支类型
--@b_lv: 分支等级
--@return: [src.app.models.FistFootSystem.FistFootBranch.BasicFistFootBranch#BasicFistFootBranch]
function FistFootResManager:getFistFootBranch(b_type, b_lv)
    local p = branchCacheMap[tostring(b_type) .. "|" .. tostring(b_lv)]

    if p == nil then
        local res = self:__getBranchResByTypeAndLv(b_type, b_lv)
        p = BasicFistFootBranch:create(res)
        branchCacheMap[tostring(b_type) .. "|" .. tostring(b_lv)] = p
    end

    return p
end

return FistFootResManager
00000000