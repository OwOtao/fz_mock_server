local newClass = require("third.class.NewClass")

local StatusTagsResourceHelper = require("app.models.RoleStatusTags.StatusTagsResourceHelper")

local NpcRoleStatusTagsArchiveService = {}

function NpcRoleStatusTagsArchiveService:create(...)
    local p = NpcRoleStatusTagsArchiveService.new()
    return p:__init(...)
end

function NpcRoleStatusTagsArchiveService:__init(role)
    self.__roleSaveData = role:getAttr("status_tags")

    if self.__roleSaveData == nil then
        self.__roleSaveData = {
            nsTags = {}
        }
        role:setAttr("status_tags", self.__roleSaveData)
    end

    if self.__roleSaveData.nsTags == nil then
        self.__roleSaveData.nsTags = {}
    end

    self.__normalTags = self.__roleSaveData.nsTags

    return self
end

--@desc: 设置状态标识
--@author:Seven
--@time:2025-02-21 18:05:30
--@tagId: 标识id
--@value: 标识值
function NpcRoleStatusTagsArchiveService:setStatusTags(tagId, value)
    if StatusTagsResourceHelper:isNpcUseStatusTag(tagId) then
        self.__normalTags[tostring(tagId)] = value
    else
        error("NpcRoleStatusTagsArchiveService:setStatusTags tagId:" .. tostring(tagId) .. " not found in resources.")
    end
end

--@desc: 设置继承状态标识值（继承）
--@author:Seven
--@time:2025-02-21 18:05:30
--@tagId: 标识id
--@value: 标识值
function NpcRoleStatusTagsArchiveService:setInheritStatusTags(tagId, value)
    error("NpcRoleStatusTagsArchiveService:setInheritStatusTags 不支持继承状态标识")
end

--@desc: 获取状态标识值（普通/继承）,如果没有则返回-1，表示未设置
--@author:Seven
--@time:2025-02-21 18:07:30
--@tagId: 标识id
--@return: 标识值
function NpcRoleStatusTagsArchiveService:getStatusTags(tagId)
    if StatusTagsResourceHelper:isNpcUseStatusTag(tagId) then
        return self.__normalTags[tostring(tagId)] or -1
    else
        error("NpcRoleStatusTagsArchiveService:getStatusTags tagId:" .. tagId .. " not found in resources.")
    end
end

--@desc: NPC不支持调用
--@author:Seven
--@time:2025-02-21 18:07:30
--@tagId: 标识id
--@return: 标识值
function NpcRoleStatusTagsArchiveService:getInheritStatusTags(tagId)
    error("NpcRoleStatusTagsArchiveService:getInheritStatusTags 不支持继承状态标识")
end

function NpcRoleStatusTagsArchiveService:addTimeLimit(tagId, tagObject)
    error("NpcRoleStatusTagsArchiveService:addTimeLimit 不支持该操作")
end

function NpcRoleStatusTagsArchiveService:deleteTimeLimitTag(tagId)
    error("NpcRoleStatusTagsArchiveService:deleteTimeLimitTag 不支持该操作")
end

function NpcRoleStatusTagsArchiveService:getTimeLimitTag(tagId)
    error("NpcRoleStatusTagsArchiveService:getTimeLimitTag 不支持该操作")
end

function NpcRoleStatusTagsArchiveService:addInheritTimeLimit(tagId, tagObject)
    error("NpcRoleStatusTagsArchiveService:addInheritTimeLimit 不支持该操作")
end

function NpcRoleStatusTagsArchiveService:deleteInheritTimeLimitTag(tagId)
    error("NpcRoleStatusTagsArchiveService:deleteInheritTimeLimitTag 不支持该操作")
end

function NpcRoleStatusTagsArchiveService:getInheritTimeLimitTag(tagId)
    error("NpcRoleStatusTagsArchiveService:getInheritStatusTags 不支持继承的时间状态标识")
end

function NpcRoleStatusTagsArchiveService:deleteTimeLimitTag(tagId)
    if not StatusTagsResourceHelper:isNpcUseStatusTag(tagId) then
        error("NpcRoleStatusTagsArchiveService:deleteTimeLimitTag tagId:" .. tostring(tagId) .. "非NPC状态标识.")
    end

    self.__normalTags[tostring(tagId)] = nil
end

function NpcRoleStatusTagsArchiveService:getInheritStatusTags()
    error("NpcRoleStatusTagsArchiveService:getInheritStatusTags 不支持该操作")
end


return newClass("NpcRoleStatusTagsArchiveService", {}, NpcRoleStatusTagsArchiveService)
000000000000000