-- 使用参考BuffSystem

local LazyUpdateMap = {}

function LazyUpdateMap:create(updateFunc)
    local p = setmetatable({}, {__index = LazyUpdateMap})
    p:ctor()
    p:__init(updateFunc)
    return p
end

function LazyUpdateMap:ctor()
    self.__map = {}
    self.__needUpdateMap = {}
    self.__updateFunc = function(self)
    end
end

function LazyUpdateMap:__init(updateFunc)
    self.__updateFunc = updateFunc
end

function LazyUpdateMap:set(key, value)
    self.__map[key] = value
end

function LazyUpdateMap:get(key)
    if self.__needUpdateMap[key] == true or self.__needUpdateMap[key] == nil then
        self.__needUpdateMap[key] = false
        self:__doUpdate(key)
    end

    return self.__map[key]
end

function LazyUpdateMap:update(key)
    self.__needUpdateMap[key] = true
end

function LazyUpdateMap:__doUpdate(key)
    self.__updateFunc(self, key)
end

return LazyUpdateMap
0000