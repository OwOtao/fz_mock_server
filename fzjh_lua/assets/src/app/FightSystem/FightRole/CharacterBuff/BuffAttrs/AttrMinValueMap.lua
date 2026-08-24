--[[
    author:Seven
    time:2023-03-22 21:09:55
    desc:属性最小值映射管理器
]]
local newClass = require("third.class.NewClass")

local AttrMinValueMap = {}

function AttrMinValueMap:create(sys)
    return AttrMinValueMap.new():__init(sys)
end

function AttrMinValueMap:__init(sys)
    --@RefType [src.app.FightSystem.FightRole.CharacterBuff.BasicBuffSystem#BasicBuffSystem]
    self.__sys = sys

    self.__createIndexId = 200

    self.__valueMap = {}

    -- 缓存每个属性的最小值，避免重复排序
    self.__minValueCache = {}

    return self
end

function AttrMinValueMap:__createNewId()
    self.__createIndexId = self.__createIndexId + 1
    return self.__createIndexId
end

function AttrMinValueMap:addMinAttr(attrName, value, effectId)
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

    -- 更新缓存的最小值
    self:__updateMinValueCache(attrName)

    return id
end

function AttrMinValueMap:removeMinAttr(attrName, id)
    if self.__valueMap[attrName] == nil then
        error("AttrMinValueMap:removeMinAttr 属性：" .. tostring(attrName) .. "对应列表为nil，无法执行移除操作")
    end

    local count = table.getn(self.__valueMap[attrName])

    if count <= 0 then
        error("AttrMinValueMap:removeMinAttr 属性：" .. tostring(attrName) .. "对应列表为空，无法执行移除操作")
    end

    local list = self.__valueMap[attrName]
    local isRemove = false
    for i = count, 1, -1 do
        local minValueInfo = list[i]

        if tonumber(minValueInfo.id) == tonumber(id) then
            isRemove = true
            table.remove(list, i)
            break
        end
    end

    if isRemove then
        if table.getn(self.__valueMap[attrName]) <= 0 then
            self.__valueMap[attrName] = nil
            self.__minValueCache[attrName] = nil
        else
            -- 更新缓存的最小值
            self:__updateMinValueCache(attrName)
        end
    else
        error("AttrMinValueMap:removeMinAttr 没有找到attrName:" .. tostring(attrName) .. "列表中对应的id：" .. tostring(id))
    end
end

function AttrMinValueMap:getMinValue(attrName, defaultValue)
    defaultValue = defaultValue or 0

    if self.__valueMap[attrName] == nil or table.getn(self.__valueMap[attrName]) <= 0 then
        return defaultValue
    end

    -- 直接返回缓存的最小值，避免重复排序
    return self.__minValueCache[attrName] or defaultValue
end

-- 更新某个属性的最小值缓存
function AttrMinValueMap:__updateMinValueCache(attrName)
    local list = self.__valueMap[attrName]
    if list == nil or table.getn(list) <= 0 then
        self.__minValueCache[attrName] = nil
        return
    end

    -- 遍历找出最小值
    local minValue = list[1].value
    for i = 2, table.getn(list) do
        if list[i].value < minValue then
            minValue = list[i].value
        end
    end

    self.__minValueCache[attrName] = minValue
end

return newClass("AttrMinValueMap", {}, AttrMinValueMap)
0000000