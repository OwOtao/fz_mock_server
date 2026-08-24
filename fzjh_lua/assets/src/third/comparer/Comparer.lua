local Comparer = {}

function Comparer:equals(a, b)
    local lookup = {}
    local function equals(a, b)
        local aType = type(a)
        local bType = type(b)

        if aType ~= bType then
            return false
        end

        if lookup[a] then
            return true
        elseif aType == "table" then
            lookup[a] = true

            local aLen = 0
            local bLen = 0
            for k, v in pairs(a) do
                aLen = aLen + 1
            end
            for k, v in pairs(b) do
                bLen = bLen + 1
            end
            if aLen ~= bLen then
                return false
            end
            for k, v in pairs(a) do
                if equals(a[k], b[k]) == false then
                    print(k, "不相等", a[k], b[k])
                    return false
                end
            end
        elseif aType == "number" then
            return math.abs(a - b) < 0.0001
        else
            return a == b
        end

        return true
    end
    return equals(a, b)
end

return Comparer
000