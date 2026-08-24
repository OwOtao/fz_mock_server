local TeacherBuildResManager = {
    __eventTextGroup = {},
    __taskMap = {},
    __sectLevelMap = {},
    __buildMap = {},
    __buildEffectMap = {},
    __buildDonateMap = {},
    __familyStateMap = {},
    __featInfoMap = {},
    __featClassLevelMap = {}
}

local function loadRes()
    local eventTextMap = requireWithEncrypt("script.family.eventTaskText")["1"]

    local eventTextGroup = {}

    for k, v in pairs(eventTextMap) do
        if eventTextGroup[tostring(v.incidentsid)] == nil then
            eventTextGroup[tostring(v.incidentsid)] = {}
        end
        table.insert(eventTextGroup[tostring(v.incidentsid)], v.text)
    end
    TeacherBuildResManager.__eventTextGroup = eventTextGroup

    local taskMap = requireWithEncrypt("script.family.tasks")["1"]

    TeacherBuildResManager.__taskMap = taskMap

    local sectLevelMap = requireWithEncrypt("script.family.sectLevel")["1"]

    TeacherBuildResManager.__sectLevelMap = sectLevelMap

    local buildMap = requireWithEncrypt("script.family.sectBuildInfo")["1"]

    TeacherBuildResManager.__buildMap = buildMap 

    local buildEffectMap = requireWithEncrypt("script.family.sectBuildEffect")["1"]

    TeacherBuildResManager.__buildEffectMap = buildEffectMap

    local buildDonateMap = requireWithEncrypt("script.family.sectBuildDonate")["1"]

    TeacherBuildResManager.__buildDonateMap = buildDonateMap

    local familyStateMap = requireWithEncrypt("script.family.familyStateConfig")["1"]

    TeacherBuildResManager.__familyStateMap = familyStateMap

    local featInfoMap = requireWithEncrypt("script.family.featInfo")["1"]

    TeacherBuildResManager.__featInfoMap = featInfoMap

    local featClassLevel = requireWithEncrypt("script.family.featClassLevel")["1"]

    local featClassLevelMap = {}

    for k, v in pairs(featClassLevel) do
        if featClassLevelMap[tostring(v.familyId)] == nil then
            featClassLevelMap[tostring(v.familyId)] = {}
        end
        table.insert(featClassLevelMap[tostring(v.familyId)], v)
    end
    
    TeacherBuildResManager.__featClassLevelMap= featClassLevelMap
end

loadRes()

function TeacherBuildResManager:getEventTextGroup()
    return self.__eventTextGroup
end

function TeacherBuildResManager:getTaskMap()
    return self.__taskMap
end

function TeacherBuildResManager:getSectLevelMap()
    return self.__sectLevelMap
end

function TeacherBuildResManager:getBuildMap()
    return self.__buildMap
end

function TeacherBuildResManager:getBuildEffectMap()
    return self.__buildEffectMap
end

function TeacherBuildResManager:getBuildDonateMap()
    return self.__buildDonateMap
end

function TeacherBuildResManager:getFamilyStateMap()
    return self.__familyStateMap
end

function TeacherBuildResManager:getFeatInfoMap()
    return self.__featInfoMap
end

function TeacherBuildResManager:getFeatClassLevelMap()
    return self.__featClassLevelMap
end

return TeacherBuildResManager
000000000