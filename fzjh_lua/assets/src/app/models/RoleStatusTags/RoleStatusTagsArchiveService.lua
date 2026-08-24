local newClass = require("third.class.NewClass")

local StatusTagsResourceHelper = require("app.models.RoleStatusTags.StatusTagsResourceHelper")

local RoleStatusTagsArchiveService = {}

function RoleStatusTagsArchiveService:create(...)
    local p = RoleStatusTagsArchiveService.new()
    return p:__init(...)
end

function RoleStatusTagsArchiveService:__init(role)
    self.__roleSaveData = role:getAttr("status_tags")

    if self.__roleSaveData == nil then
        self.__roleSaveData = {
            nsTags = {},
            inhsTags = {},
            tlTags = {},
            tlInhsTags = {}
        }
    end

    if self.__roleSaveData.nsTags == nil then
        self.__roleSaveData.nsTags = {}
    end

    if self.__roleSaveData.inhsTags == nil then
        self.__roleSaveData.inhsTags = {}
    end

    if self.__roleSaveData.tlTags == nil then
        self.__roleSaveData.tlTags = {}
    end

    if self.__roleSaveData.tlInhsTags == nil then
        self.__roleSaveData.tlInhsTags = {}
    end

    self.__normalTags = self.__roleSaveData.nsTags

    self.__inheritTags = self.__roleSaveData.inhsTags

    self.__timeLimitTags = self.__roleSaveData.tlTags

    self.__inheritTimeLimitTags = self.__roleSaveData.tlInhsTags

    role:setAttr("status_tags", self.__roleSaveData)

    return self
end

--@desc: 设置状态标识
--@author:Seven
--@time:2025-02-21 18:05:30
--@tagId: 标识id
--@value: 标识值
function RoleStatusTagsArchiveService:setStatusTags(tagId, value)
    if StatusTagsResourceHelper:isNormalStatusTag(tagId) then
        self.__normalTags[tostring(tagId)] = value
    else
        error("RoleStatusTagsArchiveService:setStatusTags tagId:" .. tostring(tagId) .. " 不存在或非玩家状态标识.")
    end
end

--@desc: 设置继承状态标识值（继承）
--@author:Seven
--@time:2025-02-21 18:05:30
--@tagId: 标识id
--@value: 标识值
function RoleStatusTagsArchiveService:setInheritStatusTags(tagId, value)
    if StatusTagsResourceHelper:isInheritStatusTag(tagId) then
        self.__inheritTags[tostring(tagId)] = value
    else
        error("RoleStatusTagsArchiveService:setInheritStatusTags tagId:" .. tagId .. " 不存在或非玩家传承状态标识.")
    end
end

--@desc: 获取状态标识值（普通/继承）,如果没有则返回-1，表示未设置
--@author:Seven
--@time:2025-02-21 18:07:30
--@tagId: 标识id
--@return: 标识值
function RoleStatusTagsArchiveService:getStatusTags(tagId)
    if StatusTagsResourceHelper:isNormalStatusTag(tagId) then
        return self.__normalTags[tostring(tagId)] or -1
    else
        error("RoleStatusTagsArchiveService:getStatusTags tagId:" .. tagId .. " 不存在或非玩家状态标识.")
    end
end

--@desc: 获取继承状态标识值（继承）,如果没有则返回-1，表示未设置
--@author:Seven
--@time:2025-02-21 18:07:30
--@tagId: 标识id
--@return: 标识值
function RoleStatusTagsArchiveService:getInheritStatusTags(tagId)
    if StatusTagsResourceHelper:isInheritStatusTag(tagId) then
        return self.__inheritTags[tostring(tagId)] or -1
    else
        error("RoleStatusTagsArchiveService:getInheritStatusTags tagId:" .. tagId .. " 不存在或非玩家传承状态标识.")
    end
end

function RoleStatusTagsArchiveService:addTimeLimit(tagId, tagObject)
    if not StatusTagsResourceHelper:isTimeLimitStatusTag(tagId) then
        error("RoleStatusTagsArchiveService:addTimeLimit tagId:" .. tostring(tagId) .. " 不存在或非玩家状态标识.")
    end

    if tagObject.value == nil then
        error("RoleStatusTagsArchiveService:addTimeLimit tagId:" .. tostring(tagId) .. " tagObject.value is nil.")
    end

    self.__timeLimitTags[tostring(tagId)] = tagObject
end

function RoleStatusTagsArchiveService:deleteTimeLimitTag(tagId)
    if not StatusTagsResourceHelper:isTimeLimitStatusTag(tagId) then
        error("RoleStatusTagsArchiveService:deleteTimeLimitTag tagId:" .. tostring(tagId) .. " 不存在或非玩家状态标识.")
    end

    self.__timeLimitTags[tostring(tagId)] = nil
end

function RoleStatusTagsArchiveService:getTimeLimitTag(tagId)
    if not StatusTagsResourceHelper:isTimeLimitStatusTag(tagId) then
        error("RoleStatusTagsArchiveService:getTimeLimitTag tagId:" .. tostring(tagId) .. " 不存在或非玩家状态标识.")
    end

    return self.__timeLimitTags[tostring(tagId)]
end

function RoleStatusTagsArchiveService:addInheritTimeLimit(tagId, tagObject)
    if not StatusTagsResourceHelper:isInheritTimeLimitStatusTag(tagId) then
        error("RoleStatusTagsArchiveService:addInheritTimeLimit tagId:" .. tostring(tagId) .. " 不存在或非玩家状态标识.")
    end

    if tagObject.value == nil then
        error("RoleStatusTagsArchiveService:addInheritTimeLimit tagId:" .. tostring(tagId) .. " tagObject.value is nil.")
    end

    self.__inheritTimeLimitTags[tostring(tagId)] = tagObject
end

function RoleStatusTagsArchiveService:deleteInheritTimeLimitTag(tagId)
    if not StatusTagsResourceHelper:isInheritTimeLimitStatusTag(tagId) then
        error("RoleStatusTagsArchiveService:deleteInheritTimeLimitTag tagId:" .. tostring(tagId) .. " 不存在或非玩家状态标识.")
    end

    self.__inheritTimeLimitTags[tostring(tagId)] = nil
end

function RoleStatusTagsArchiveService:getInheritTimeLimitTag(tagId)
    if not StatusTagsResourceHelper:isInheritTimeLimitStatusTag(tagId) then
        error("RoleStatusTagsArchiveService:getInheritTimeLimitTag tagId:" .. tostring(tagId) .. " 不存在或非玩家状态标识.")
    end

    return self.__inheritTimeLimitTags[tostring(tagId)]
end

function RoleStatusTagsArchiveService:deleteStatusTags(tagId)
    if StatusTagsResourceHelper:isNormalStatusTag(tagId) then
        self.__normalTags[tostring(tagId)] = nil
    elseif StatusTagsResourceHelper:isInheritStatusTag(tagId) then
        self.__inheritTags[tostring(tagId)] = nil
    elseif StatusTagsResourceHelper:isTimeLimitStatusTag(tagId) then
        self.__timeLimitTags[tostring(tagId)] = nil
    elseif StatusTagsResourceHelper:isInheritTimeLimitStatusTag(tagId) then
        self.__inheritTimeLimitTags[tostring(tagId)] = nil
    else
        error("RoleStatusTagsArchiveService:deleteStatusTags tagId:" .. tostring(tagId) .. " 不存在或非玩家状态标识.")
    end
end

function RoleStatusTagsArchiveService:getAllInheritStatusTags()
    local tags = {
        inhsTags = {},
        tlInhsTags = {}
    }

    for k, v in pairs(self.__inheritTags) do
        if v ~= nil and v >= 0 then
            tags.inhsTags[k] = v
        end
    end

    for k, timeobj in pairs(self.__inheritTimeLimitTags) do
        local t_obj = {}

        if timeobj.value ~= nil and timeobj.value >= 0 then
            tags.tlInhsTags[k] = t_obj
    
            for kk, v in pairs(timeobj) do
                t_obj[kk] = v
            end
        end
    end

    return tags
end

return newClass("RoleStatusTagsArchiveService", {}, RoleStatusTagsArchiveService)
0000000000