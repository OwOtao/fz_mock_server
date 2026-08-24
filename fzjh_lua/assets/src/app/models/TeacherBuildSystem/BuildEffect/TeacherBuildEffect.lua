local NewClass = require("third.class.NewClass")

local TeacherBuildResManager = require("app.models.TeacherBuildSystem.TeacherBuildResManager")

local TeacherBuildEffect = {}

function TeacherBuildEffect:create(effectId)
    local p = TeacherBuildEffect.new()
    p:init(effectId)
    return p
end

function TeacherBuildEffect:init(effectId)
    self.__data = assert(TeacherBuildResManager:getBuildEffectMap()[tostring(effectId)],"师门建筑效果不存在 effectId = "..effectId)
end

function TeacherBuildEffect:getId()
    return self.__data.effectid
end

function TeacherBuildEffect:getEffect()
    return self.__data.effect
end

function TeacherBuildEffect:getEffectType()
    return self.__data.effect[1]
end

function TeacherBuildEffect:getSbutton()
    return self.__data.sbutton
end

function TeacherBuildEffect:getButtontext()
    return self.__data.buttontext
end

return NewClass("TeacherBuildEffect", {}, TeacherBuildEffect)0000000000000000