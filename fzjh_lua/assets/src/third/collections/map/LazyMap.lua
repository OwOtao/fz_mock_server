local PairsCoroutine = require("third.coroutine.PairsCoroutine")
local NewClass = require("third.collections.map.LazyMap")
local LazyMap = {}

function LazyMap:create(map)
    local proxy = {
        values = map or {}
    }
end

-- 遍历属性的协程
local function __pairs(self)
    for k, v in pairs(self.__LazyMap.values) do
        coroutine.yield(k, self[k])
    end
end

function LazyMap.__pairs(self)
    if type(self.__LazyMap) == "table" then
        return PairsCoroutine(__pairs, self)
    end
end

-- 遍历属性的协程
local function __ipairs(self)
    for k, v in ipairs(self.__LazyMap.values) do
        coroutine.yield(k, self[k])
    end
end

function LazyMap.__ipairs(self)
    if type(self.__LazyMap) == "table" then
        return PairsCoroutine(__ipairs, self)
    end
end

function LazyMap.__clone(self, lookup_table)
    local newObject = {}
    lookup_table[self] = newObject
    newObject.__LazyMap = clone(self.__LazyMap, lookup_table)
    return setmetatable(newObject, getmetatable(self))
end

function LazyMap.__getn(self)
    return table.getn(self.__LazyMap.values)
end

return NewClass("LazyMap", {}, LazyMap)
000