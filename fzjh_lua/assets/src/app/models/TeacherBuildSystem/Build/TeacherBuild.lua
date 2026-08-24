local NewClass = require("third.class.NewClass")

local TeacherBuildResManager = require("app.models.TeacherBuildSystem.TeacherBuildResManager")

local TeacherBuild = {}

function TeacherBuild:create(buildId)
    local p = TeacherBuild.new()
    p:init(buildId)
    return p
end

function TeacherBuild:init(buildId)
    self.__data = assert(TeacherBuildResManager:getBuildMap()[tostring(buildId)],"师门建筑不存在 buildId = "..buildId)
end

function TeacherBuild:getId()
    return self.__data.buildid
end

function TeacherBuild:getTypeId()
    return self.__data.buildingid
end

function TeacherBuild:getName()
    return self.__data.buildname
end

function TeacherBuild:getLv()
    return self.__data.buildlv
end

function TeacherBuild:getSign()
    return self.__data.sign
end

function TeacherBuild:getDesc()
    return self.__data.builddescribe
end

function TeacherBuild:getEffectText()
    return self.__data.effecttext
end

function TeacherBuild:getEffectIdList()
    return self.__data.effectid
end

function TeacherBuild:getEffectList()
    local TeacherBuildEffect = require("app.models.TeacherBuildSystem.BuildEffect.TeacherBuildEffect")

    local effectIdList = self:getEffectIdList()

    local effectList = {}

    for i,effectId in ipairs(effectIdList) do
        table.insert(effectList,TeacherBuildEffect:create(effectId))
    end

    return effectList
end

function TeacherBuild:getMaxExp()
    return self.__data.maxupresources
end

function TeacherBuild:getCescalation()
    return self.__data.cescalation
end

function TeacherBuild:getDonateIdList()
    return self.__data.donateid
end

function TeacherBuild:getDonateList()
    local TeacherBuildDonate = require("app.models.TeacherBuildSystem.Donate.TeacherBuildDonate")

    local donateIdList = self:getDonateIdList()

    local donateList = {}

    for i,donateId in ipairs(donateIdList) do
        table.insert(donateList,TeacherBuildDonate:create(donateId))
    end

    return donateList
end

function TeacherBuild:getOpenLvDesc()
    return self.__data.conditiontxt
end

function TeacherBuild:getCondition()
    return self.__data.condition
end

function TeacherBuild:getConditiontext()
    return self.__data.conditiontext
end


return NewClass("TeacherBuild", {}, TeacherBuild)000000000000000