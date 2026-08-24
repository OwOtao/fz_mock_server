local StringUtil = {}
local charMapsRes = require("script.others.charReplace")["通配符号"]
local Trie = require("third.tree.Trie")

local trie = Trie:create()
local charMaps = {}

function StringUtil:subString(strurl, strchar, bafter)
    local ts = string.reverse(strurl)
    local param1, param2 = string.find(ts, strchar)  -- 这里以"/"为例
    local m = string.len(strurl) - param2 + 1
    local result
    if (bafter == true) then
        result = string.sub(strurl, m + 1, string.len(strurl))
    else
        result = string.sub(strurl, 1, m - 1)
    end

    return result
end

--@desc 把字符串中的特殊符号串替换成副本中npc名字，或指定名字
--@map npc所在副本
--@name 指定名字
function StringUtil:replaceNpcName(str, map, name)
    local newStr = str
    local needSub = true

    if str == nil then
        return newStr
    end

    while needSub do
        local sPos, ePos, roleId = string.find(newStr, "%p(%w+)%p")

        if roleId then
            local npcName = ""

            if name then
                npcName = name
            elseif map then
                local npc = map:getRole(roleId)
                if npc == nil then
                    print("没有配置的npc  npcId = ", roleId)
                    return newStr
                end
                npcName = npc.name
            else
                return newStr
            end

            newStr = string.gsub(newStr, "(%p%w+%p)", npcName)
        else
            needSub = false
        end
    end

    return newStr
end

function StringUtil:subNum(str)
    local sPos, ePos, num = string.find(str, "(%d+)")

    return num
end

function StringUtil:replaceDynamicRoleText(str, role)
    return trie:relpaceString(str, function(s)
        return self:__getCharsToValue(s, role)
    end)
end

function StringUtil:initCharMap()
    if MapIsEmpty(charMapsRes) == false then
        for k, v in pairs(charMapsRes) do
            trie:add(v.Symbol)
        end
    end
end

StringUtil:initCharMap()

function StringUtil:__getCharsToValue(symbol, role)
    return switch(symbol, {
        ["$rolefamily"] = function()
            return role:getFamilyName()
        end
    })
end

return StringUtil00