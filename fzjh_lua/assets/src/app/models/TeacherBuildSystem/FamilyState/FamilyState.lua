local NewClass = require("third.class.NewClass")

local TeacherBuildResManager = require("app.models.TeacherBuildSystem.TeacherBuildResManager")
local IconResManager = require("app.models.Const.IconResManager.IconResManager")

local FamilyState = {}

function FamilyState:create(id)
    local p = FamilyState.new()
    p:init(id)
    return p
end

function FamilyState:init(id)
    self.__data = assert(TeacherBuildResManager:getFamilyStateMap()[tostring(id)],"师门状态标识不存在 id = "..id)
end

function FamilyState:getName()
    return self.__data.name
end

function FamilyState:getText()
    return self.__data.text
end

function FamilyState:getIcon()
    local id = self.__data.iconId
    return IconResManager:getIconById(id)
end

return NewClass("FamilyState", {}, FamilyState)000000000