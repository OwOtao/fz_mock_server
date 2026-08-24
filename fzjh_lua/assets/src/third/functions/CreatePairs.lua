local function CreatePairs(t, ignoreMap)
    local k, v
    local function pairs()
        k, v = next(t, k)
        if ignoreMap[k] then
            return pairs()
        end
        return k, v
    end
    return pairs
end

return CreatePairs
0000000000000