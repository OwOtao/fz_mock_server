local CacheMap = {}

function CacheMap:create()
    local p = clone(CacheMap)
    p:init()
    return p
end

function CacheMap:init()
    self._cacheMap = {}

end

function CacheMap:getCache(name)
    if self._cacheMap[name] == nil then
        self._cacheMap[name] = setmetatable({}, {__mode = "kv"}) 
    end
    return self._cacheMap[name]
end

return CacheMap0