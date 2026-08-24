--[[
    author:Seven
    time:2023-03-22 21:09:55
    desc:
]]
local newClass = require("third.class.NewClass")

local AttrMaxValueMap = {}

function AttrMaxValueMap:create(sys)
    return AttrMaxValueMap.new():__init(sys)
end

function AttrMaxValueMap:__init(sys)
    --@RefType [src.app.FightSystem.FightRole.CharacterBuff.BasicBuffSystem#BasicBuffSystem]
    self.__sys = sys

    self.__createIndexId = 100

    self.__valueMap = {}

    -- 缓存每个属性的最大值，避免重复排序
    self.__maxValueCache = {}

    return self
end

function AttrMaxValueMap:__createNewId()
    self.__createIndexId = self.__createIndexId + 1
    return self.__createIndexId
end

function AttrMaxValueMap:addMaxAttr(attrName, value, effectId)
    if self.__valueMap[attrName] == nil then
        self.__valueMap[attrName] = {}
    end

    local id = self:__createNewId()

    table.insert(
        self.__valueMap[attrName],
        {
            id = id,
            value = value,
            effectId = effectId
        }
    )

    -- 更新缓存的最大值
    self:__updateMaxValueCache(attrName)

    return id
end

function AttrMaxValueMap:removeMaxAttr(attrName, id)
    if self.__valueMap[attrName] == nil then
        error("AttrMaxValueMap:removeMaxAttr 属性：" .. tostring(attrName) .. "对应列表为nil，无法执行移除操作")
    end

    local count = table.getn(self.__valueMap[attrName])

    if count <= 0 then
        error("AttrMaxValueMap:removeMaxAttr 属性：" .. tostring(attrName) .. "对应列表为空，无法执行移除操作")
    end

    local list = self.__valueMap[attrName]
    local isRemove = false
    for i = count, 1, -1 do
        local maxValueInfo = list[i]

        if tonumber(maxValueInfo.id) == tonumber(id) then
            isRemove = true
            table.remove(list, i)
            break
        end
    end

    if isRemove then
        if table.getn(self.__valueMap[attrName]) <= 0 then
            self.__valueMap[attrName] = nil
            self.__maxValueCache[attrName] = nil
        else
            -- 更新缓存的最大值
            self:__updateMaxValueCache(attrName)
        end
    else
        error("AttrMaxValueMap:removeMaxAttr 没有找到attrName:" .. tostring(attrName) .. "列表中对应的id：" .. tostring(id))
    end
end

function AttrMaxValueMap:getMaxValue(attrName, defaultValue)
    defaultValue = defaultValue or 0

    if self.__valueMap[attrName] == nil or table.getn(self.__valueMap[attrName]) <= 0 then
        return defaultValue
    end

    -- 直接返回缓存的最大值，避免重复排序
    return self.__maxValueCache[attrName] or defaultValue
end

-- 更新某个属性的最大值缓存
function AttrMaxValueMap:__updateMaxValueCache(attrName)
    local list = self.__valueMap[attrName]
    if list == nil or table.getn(list) <= 0 then
        self.__maxValueCache[attrName] = nil
        return
    end

    -- 遍历找出最大值
    local maxValue = list[1].value
    for i = 2, table.getn(list) do
        if list[i].value > maxValue then
            maxValue = list[i].value
        end
    end

    self.__maxValueCache[attrName] = maxValue
end

return newClass("AttrMaxValueMap", {}, AttrMaxValueMap)
00000