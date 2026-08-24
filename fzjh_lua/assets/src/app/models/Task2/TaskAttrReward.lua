local newClass = require("third.class.NewClass")

local Role = require("app.models.role.Role")

local TaskAttrReward = {}

function TaskAttrReward:create(attrName, value)
    local p = TaskAttrReward.new()

    p:__init(attrName, value)

    return p
end

function TaskAttrReward:__init(attrName, value)
    self.__attrName = attrName
    self.__value = value
end

function TaskAttrReward:getAttrName()
    return self.__attrName
end

function TaskAttrReward:setValue(value)
    self.__value = value
end

function TaskAttrReward:getValue()
    return self.__value
end

function TaskAttrReward:getNameText()
    return Role:getCHAttrName(self.__attrName)
end

return newClass("TaskAttrReward", {}, TaskAttrReward)
000