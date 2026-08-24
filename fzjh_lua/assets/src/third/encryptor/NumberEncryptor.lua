local NumberEncryptor = {}

local head = math.random(4061, 40615)

local mixNumber = math.random(1000, 9999)
local mulNumber = math.random(100, 999)

local nameByte1Cache = {}
local nameByte2Cache = {}

-- 混淆变量
local function mixUpValue(name, value)
    local nv = nameByte1Cache[name]
    if nv == nil then
        nameByte1Cache[name] = string.byte(name) * mulNumber + string.len(name)
        nv = nameByte1Cache[name]
    end
    return -(value + mixNumber - nv)
end

-- 反混淆变量
local function unMixUpValue(name, value)
    local nv = nameByte1Cache[name]
    if nv == nil then
        nameByte1Cache[name] = string.byte(name) * mulNumber + string.len(name)
        nv = nameByte1Cache[name]
    end
    return -(value + mixNumber - nv)
end

function NumberEncryptor:isEncrypted(t)
    return true
end

function NumberEncryptor:encrypt(t, name)
    if name == nil then
        name = "0"
    end
    return mixUpValue(name, t)
end

function NumberEncryptor:decrypt(t, name)
    if name == nil then
        name = "0"
    end

    local retValue = unMixUpValue(name, t)

    if retValue == -0 then
        retValue = 0
    end

    return retValue
end

return NumberEncryptor
0000000000000