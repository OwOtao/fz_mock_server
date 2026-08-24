local SkillResManager = {
    __specialSkillStageDescMap = {},
    __normalSkillStageDescMap = {},
    __kongFuDescMap = {},
}

local function loadSpecialSkillStageDesc()
    local SpecialSkillStageDesc = require("script.skill.specialSkillStageDesc")["data"]
    for k,v in pairs(SpecialSkillStageDesc) do
        table.insert(SkillResManager.__specialSkillStageDescMap, {lv = v.lv,dsc = v.dscColor..v.dscText})
    end

    table.sort(SkillResManager.__specialSkillStageDescMap,function(a,b)
        return a.lv < b.lv
    end)
end

local function loadNormalSkillStageDesc()
    local NormalSkillStageDesc = require("script.skill.normalSkillStageDesc")["data"]
    for k,v in pairs(NormalSkillStageDesc) do
        table.insert(SkillResManager.__normalSkillStageDescMap, {lv = v.lv,dsc = v.dscColor..v.dscText})
    end

    table.sort(SkillResManager.__normalSkillStageDescMap,function(a,b)
        return a.lv < b.lv
    end)
end

local function loadKongFuDesc()
    local KongFuDesc = require("script.skill.kongfuDesc")["data"]
    for k,v in pairs(KongFuDesc) do
        table.insert(SkillResManager.__kongFuDescMap, {value = v.kongfu,dsc = v.dscColor..v.dscText})
    end

    table.sort(SkillResManager.__kongFuDescMap,function(a,b)
        return a.value < b.value
    end)
end

loadSpecialSkillStageDesc()
loadNormalSkillStageDesc()
loadKongFuDesc()


function SkillResManager:getSpecialSkillStageDescMap()
    return self.__specialSkillStageDescMap
end

function SkillResManager:getNormalSkillStageDescMap()
    return self.__normalSkillStageDescMap
end

function SkillResManager:getKongFuDescMap()
    return self.__kongFuDescMap
end

return SkillResManager0000