local StringEncryptor = require("third.encryptor.StringEncryptor")
local NumberEncryptor = require("third.encryptor.NumberEncryptor")

local Encryptor = {}

local encryptorSwitchMap = {
    ["string"] = StringEncryptor,
    ["number"] = NumberEncryptor
}

function Encryptor:encrypt(t, ...)
    local tType = type(t)

    local encryptor = encryptorSwitchMap[tType]

    if encryptor then
        return encryptor:encrypt(t, ...)
    end

    return t
end

function Encryptor:decrypt(t, ...)
    local tType = type(t)

    local encryptor = encryptorSwitchMap[tType]

    if encryptor then
        return encryptor:decrypt(t, ...)
    end

    return t
end

return Encryptor
0000000000