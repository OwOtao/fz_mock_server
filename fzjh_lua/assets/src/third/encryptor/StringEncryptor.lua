local StringEncryptor = {}

local head = tostring("&" .. math.random(4061, 40615) % 100)
local factorA = math.random(4061, 40615)
local factorB = math.random(4061, 40615)

-- 字符串转table后的缓存, 用于节约内存
local encrypt_cache = {}
local decrypt_cache = {}

function StringEncryptor:isEncrypted(t)
    if decrypt_cache[t] then
        return true
    elseif encrypt_cache[t] then
        return false
    end
    return string.find(t, head) == 1
end

local enable = true

function StringEncryptor:encrypt(str)
    if enable == false then
        return str
    end
    
    local ret = encrypt_cache[str]
    if ret then
        return ret
    else
        if not self:isEncrypted(str) then
            local strLen = #str

            for i = 1, strLen do
                if string.byte(str, i) > 128 then
                    encrypt_cache[str] = str
                    decrypt_cache[str] = str
                    return str
                end
            end

            local tb = {head}
            for i = 1, strLen do
                table.insert(tb, string.char((string.byte(str, i) + factorA - factorB) % 256))
            end

            ret = table.concat(tb)
            encrypt_cache[str] = ret
            return ret
        else
            print(string.format("StringEncryptor:encrypt(%s):不能加密已经加密的字符串!!", str))
        end
    end
    return str
end

function StringEncryptor:decrypt(str)
    local ret = decrypt_cache[str]
    if ret then
        return ret
    else
        if self:isEncrypted(str) then
            local strLen = #str

            local array = {}
            for i = #head + 1, strLen do
                table.insert(array, string.char((string.byte(str, i) - factorA + factorB) % 256))
            end

            ret = table.concat(array)
            decrypt_cache[str] = ret
            return ret
        else
            IS_ABLE_TO_SAVE_DATA = false
            cc.Director:getInstance():endToLua()
            error(string.format("StringEncryptor:decrypt(%s):不能解密已经解密的字符串!!", str))
            return
        end
    end
    return str
end

return StringEncryptor
00000000000