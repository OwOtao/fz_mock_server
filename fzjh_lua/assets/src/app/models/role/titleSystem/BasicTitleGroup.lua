--[[
    author:Seven
    time:2024-04-16 16:32:17
    desc: 称号组基础类
]]
local newClass = require("third.class.NewClass")

local BasicTitleGroup = {}

function BasicTitleGroup:create(...)
    return BasicTitleGroup.new():__init(...)
end

function BasicTitleGroup:__init(id, name)
    self.__name = name

    self.__id = tostring(id)

    self.__titleIdList = {}

    return self
end

function BasicTitleGroup:getId()
    return self.__id
end

function BasicTitleGroup:getName()
    return self.__name
end

function BasicTitleGroup:addTitleId(titleId)
    table.insert(self.__titleIdList, titleId)
end

function BasicTitleGroup:getTitleIdList()
    return self.__titleIdList
end

return newClass("BasicTitleGroup", {}, BasicTitleGroup)
000000000000000