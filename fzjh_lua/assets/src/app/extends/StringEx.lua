function string.getBytes(s)
    local len = string.len(s)
    local bytes = {}
    for i = 1, len do
        local byte = string.byte(s, i)
        table.insert(bytes, byte)
    end
    return bytes
end

function string.getChars(s)
    local bytes = string.getBytes(s)
    local chars = {}
    for i, byte in ipairs(bytes) do
        table.insert(chars, string.char(byte))
    end
    return chars
end

function string.findAll(s, findStr, startPos)
    if startPos == nil then
        startPos = 0
    end
    local findStrLen = string.len(findStr)
    local strPosList = {}
    local pos = string.find(s, findStr, startPos)
    if pos == nil or pos < 0 then
        return nil
    end
    repeat
        -- print("startPos = "..startPos)
        pos = string.find(s, findStr, startPos)
        -- print("pos = "..tostring(pos))
        if pos == nil or pos < 0 then
            break
        end
        table.insert(strPosList, pos)
        startPos = pos + findStrLen
    until false
    return strPosList
end

function string.findAll_fix(s, findStr, startPos) -- 开头和末尾补全
    if startPos == nil then
        startPos = 0
    end
    local findStrLen = string.len(findStr)
    local strPosList = {}
    local pos = string.find(s, findStr, startPos)
    if pos == nil or pos < 0 then
        return nil
    end
    table.insert(strPosList, 0)
    repeat
        -- print("startPos = "..startPos)
        local pos = string.find(s, findStr, startPos)
        -- print("pos = "..tostring(pos))
        if pos == nil or pos < 0 then
            break
        end
        table.insert(strPosList, pos)
        startPos = pos + findStrLen
    until false
    table.insert(strPosList, string.len(s) + 1)
    return strPosList
end

function string.splitUTF8(str)
    local splitedTb = {}
    local strLen = string.len(str)
    local noAsciiBytes = {}
    for i = 1, strLen do
        local byte = string.byte(str, i)
        if byte < 128 then -- byte小于128为英文字符
            local tmpStr = string.char(byte)
            -- print("ascii字符:"..tmpStr)
            table.insert(splitedTb, tmpStr)
        else
            table.insert(noAsciiBytes, byte)
            if #noAsciiBytes >= 3 then
                local tmpStr = string.char(unpack(noAsciiBytes))
                -- print("非ascii字符:"..tmpStr)
                table.insert(splitedTb, tmpStr)
                noAsciiBytes = {}
            end
        end
    end
    return splitedTb
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 首字母大写
function string.upperFirst(str)
    return string.upper(string.sub(str, 1, 1)) .. string.sub(str, 2)
end

local splitCache = {}

function string.splitUnpack(str, sep)
    local key = str .. "@" .. sep
    local cache = splitCache[key]
    if cache == nil then
        cache = string.split(str, sep)
        splitCache[key] = cache
    end
    return cache[1], cache[2], cache[3], cache[4], cache[5], cache[6], cache[7], cache[8], cache[9], cache[10]
end
000000000