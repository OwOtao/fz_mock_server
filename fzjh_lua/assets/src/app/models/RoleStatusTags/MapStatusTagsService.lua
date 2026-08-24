local newClass = require("third.class.NewClass")

local StatusTagsResourceHelper = require("app.models.RoleStatusTags.StatusTagsResourceHelper")

local MapStatusTagsService = {}

function MapStatusTagsService:create(...)
    local p = MapStatusTagsService.new()
    return p:__init(...)
end

function MapStatusTagsService:__init(map)
    self.__normalTags = {}

    return self
end

--@desc: 设置状态标识
--@author:Seven
--@time:2025-02-21 18:05:30
--@tagId: 标识id
--@value: 标识值
function MapStatusTagsService:setStatusTags(tagId, value)
    if StatusTagsResourceHelper:isMapUseStatusTag(tagId) then
        self.__normalTags[tostring(tagId)] = value
    else
        error("MapStatusTagsService:setStatusTags tagId:" .. tostring(tagId) .. " 不存在或非地图用类型状态标识")
    end
end

--@desc: 获取状态标识值（普通/继承）,如果没有则返回-1，表示未设置
--@author:Seven
--@time:2025-02-21 18:07:30
--@tagId: 标识id
--@return: 标识值
function MapStatusTagsService:getStatusTags(tagId)
    if StatusTagsResourceHelper:isMapUseStatusTag(tagId) then
        return self.__normalTags[tostring(tagId)] or -1
    else
        error("MapStatusTagsService:getStatusTags tagId:" .. tagId .. " 不存在或非地图用类型状态标识.")
    end
end

return newClass("MapStatusTagsService", {}, MapStatusTagsService)
000000000000000