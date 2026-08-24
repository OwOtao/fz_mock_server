local newClass = require("third.class.NewClass")

local TimeLimitStatusTagHelper = require("app.models.RoleStatusTags.TimeLimitStatusTagHelper")

local RoleStatusTagsSystem = {}

function RoleStatusTagsSystem:create(...)
    local p = RoleStatusTagsSystem.new()
    return p:__init(...)
end

function RoleStatusTagsSystem:__init(role, roleType)
    self.__role = role

    self.__roleType = roleType

    if roleType == "__player__" then
        self.__archiveService = require("app.models.RoleStatusTags.RoleStatusTagsArchiveService"):create(role)
    elseif roleType == "__npc__" then
        self.__archiveService = require("app.models.RoleStatusTags.NpcRoleStatusTagsArchiveService"):create(role)
    else
        error("RoleStatusTagsSystem:__init unkonw roleType:" .. tostring(roleType))
    end

    return self
end

--@desc: 设置状态标识 , value 必须>=0
--@author:Seven
--@time:2025-02-21 18:27:12
--@tagId: 标识id
--@value: 标识值
function RoleStatusTagsSystem:setStatusTags(tagId, value)
    if value == nil or value < 0 then
        error("RoleStatusTagsSystem:setStatusTags 设置普通状态标识值不能为空小于0 tagId:" .. tostring(tagId) .. " value:" .. tostring(value))
    end

    self.__archiveService:setStatusTags(tagId, value)
end

--@desc: 设置继承状态标识值（继承）, value 必须>=0
--@author:Seven
--@time:2025-02-21 18:27:38
--@tagId: 标识id
--@value: 标识值
function RoleStatusTagsSystem:setInheritStatusTags(tagId, value)
    if value == nil or value < 0 then
        error("RoleStatusTagsSystem:setInheritStatusTags 设置继承状态标识值不能为空小于0 tagId:" .. tostring(tagId) .. " value:" .. tostring(value))
    end

    self.__archiveService:setInheritStatusTags(tagId, value)
end

--@desc: 获取状态标识值（普通/继承）,如果没有则返回-1，表示未设置, tagId 不存在时返回-1
function RoleStatusTagsSystem:getStatusTagValue(tagId)
    return self.__archiveService:getStatusTags(tagId)
end

--@desc: 获取继承状态标识值（继承）,如果没有则返回-1，表示未设置, tagId 不存在时返回-1
function RoleStatusTagsSystem:getInheritStatusTagValue(tagId)
    return self.__archiveService:getInheritStatusTags(tagId)
end

function RoleStatusTagsSystem:setTimeStatusTagValue(tagId, value)
    if value == nil or value < 0 then
        error("RoleStatusTagsSystem:setTimeStatusTagValue 设置时间状态标识值不能为空或小于0 tagId:" .. tostring(tagId) .. " value:" .. tostring(value))
    end

    local t_tagObject = self.__archiveService:getTimeLimitTag(tagId)
    if t_tagObject == nil then
        t_tagObject = TimeLimitStatusTagHelper:newTimeLimitObject(tagId)
    else
        local isExpired = TimeLimitStatusTagHelper:isExpired(tagId, t_tagObject)

        if isExpired then
            self.__archiveService:deleteTimeLimitTag(tagId)
            t_tagObject = TimeLimitStatusTagHelper:newTimeLimitObject(tagId)
        end
    end

    t_tagObject.value = value

    self.__archiveService:addTimeLimit(tagId, t_tagObject)
end

function RoleStatusTagsSystem:getTimeStatusTagValue(tagId)
    local t_tagObject = self.__archiveService:getTimeLimitTag(tagId)
    if t_tagObject == nil then
        return -1
    end

    local isExpired = TimeLimitStatusTagHelper:isExpired(tagId, t_tagObject)

    if isExpired then
        self.__archiveService:deleteTimeLimitTag(tagId)
        return -1
    end

    local tagValue = t_tagObject.value

    if tagValue == nil then
        return -1
    end

    return tagValue
end

function RoleStatusTagsSystem:setInheritTimeStatusTagValue(tagId, value)
    if value == nil or value < 0 then
        error("RoleStatusTagsSystem:setInheritTimeStatusTagValue 设置时间传承状态标识值不能为空或小于0 tagId:" .. tostring(tagId) .. " value:" .. tostring(value))
    end

    local t_tagObject = self.__archiveService:getInheritTimeLimitTag(tagId)
    if t_tagObject == nil then
        t_tagObject = TimeLimitStatusTagHelper:newTimeLimitObject(tagId)
    else
        local isExpired = TimeLimitStatusTagHelper:isExpired(tagId, t_tagObject)

        if isExpired then
            self.__archiveService:deleteInheritTimeLimitTag(tagId)
            t_tagObject = TimeLimitStatusTagHelper:newTimeLimitObject(tagId)
        end
    end

    t_tagObject.value = value

    self.__archiveService:addInheritTimeLimit(tagId, t_tagObject)
end

function RoleStatusTagsSystem:getInheritTimeStatusTagValue(tagId)
    local t_tagObject = self.__archiveService:getInheritTimeLimitTag(tagId)
    if t_tagObject == nil then
        return -1
    end

    local isExpired = TimeLimitStatusTagHelper:isExpired(tagId, t_tagObject)

    if isExpired then
        self.__archiveService:deleteInheritTimeLimitTag(tagId)
        return -1
    end

    local tagValue = t_tagObject.value

    if tagValue == nil then
        return -1
    end

    return tagValue
end

function RoleStatusTagsSystem:deleteStatusTags(tagId)
    self.__archiveService:deleteStatusTags(tagId)
end

function RoleStatusTagsSystem:getAllInheritStatusTags()
    return self.__archiveService:getAllInheritStatusTags()
end

return newClass("RoleStatusTagsSystem", {}, RoleStatusTagsSystem)
000