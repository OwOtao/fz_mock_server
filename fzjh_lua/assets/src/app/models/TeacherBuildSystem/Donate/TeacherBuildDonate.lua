local NewClass = require("third.class.NewClass")

local TeacherBuildResManager = require("app.models.TeacherBuildSystem.TeacherBuildResManager")

local TeacherBuildDonate = {}

function TeacherBuildDonate:create(donateId)
    local p = TeacherBuildDonate.new()
    p:init(donateId)
    return p
end

function TeacherBuildDonate:init(donateId)
    self.__data = assert(TeacherBuildResManager:getBuildDonateMap()[tostring(donateId)],"师门建筑捐献内容不存在 donateId = "..donateId)
end

function TeacherBuildDonate:getId()
    return self.__data.donateid
end

function TeacherBuildDonate:getTitleText()
    return self.__data.titletext
end

function TeacherBuildDonate:getCondition()
    return self.__data.donatecondition
end

function TeacherBuildDonate:getUpresources()
    return self.__data.upresources
end

function TeacherBuildDonate:getDonateText()
    return self.__data.donatetext
end

function TeacherBuildDonate:getOpenText()
    return self.__data.text
end

function TeacherBuildDonate:getUnlockcondition()
    return self.__data.unlockcondition
end

return NewClass("TeacherBuildDonate", {}, TeacherBuildDonate)0000000