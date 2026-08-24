local Trie = {}

local string_getByte = string.byte
local string_len = string.len
local string_sub = string.sub
local table_insert = table.insert
local math_max = math.max
local math_min = math.min

function Trie:create()
    local p = setmetatable({}, {__index = Trie})
    p:ctor()
    return p
end

function Trie:ctor()
    self.root = {}
    self.wordMaxLen = 0
    self.wordMinLen = 99999

    self.wordMap = {}
end

function Trie:getWordMaxLen()
    return self.wordMaxLen
end

function Trie:add(word)
    if self.wordMap[word] then
        return
    end
    self.wordMap[word] = true

    local wordLen = string_len(word)
    local curr = self.root
    local i = 1
    while i <= wordLen do
        local byte = string_getByte(word, i)
        if curr[byte] == nil then
            local node = {}
            curr[byte] = node
        end
        curr = curr[byte]
        if i == wordLen then
            curr["#"] = true
        end
        i = i + 1
    end
    self.wordMaxLen = math_max(self.wordMaxLen, wordLen)
    self.wordMinLen = math_min(self.wordMinLen, wordLen)
end

function Trie:get(word, left, right)
    if left == nil then
        left = 1
    end
    if right == nil then
        right = string_len(word)
    end
    local curr = self.root
    for i = left, right do
        local byte = string_getByte(word, i)
        if curr[byte] then
            curr = curr[byte]
        else
            return false
        end
    end
    if curr["#"] then
        return true
    end
    return false
end

--[[
    @desc: 使用trie分割字符串为字符串数组
    author:TangJian
    time:2021-04-14 19:45:24
    --@str: 被分割的字符串
    @return: 拆分后的字符串
]]
function Trie:partitionToArray(str)
    local strings = {}
    self:partitionWithCallback(
        str,
        function(i, str)
            table_insert(strings, str)
        end
    )
    return strings
end

--[[
    @desc: 使用trie遍历回调callback
    author:TangJian
    time:2021-04-14 19:49:46
    --@str: 要拆分的字符串
	--@callback: 回调
    @return: 拆分后的字符串
]]
function Trie:partitionWithCallback(str, callback)
    local strings = {}
    local lastPos = 1
    local strLen = string_len(str)
    local i = 1
    while i <= strLen - self.wordMinLen + 1 do
        local isMatched = false
        local currNode = self.root
        local matchedIndex = i
        for j = i, i + self.wordMaxLen + 1 do
            local byte = string_getByte(str, j)
            if currNode[byte] then
                currNode = currNode[byte]
                if currNode["#"] then
                    isMatched = true
                    matchedIndex = j
                end
            else
                if isMatched then
                    if i > lastPos then
                        callback(lastPos, string_sub(str, lastPos, i - 1))
                    end
                    callback(i, string_sub(str, i, matchedIndex))
                    i = matchedIndex + 1
                    lastPos = i
                end
                break
            end
        end

        if isMatched == false then
            i = i + 1
        end
    end

    if strLen >= lastPos then
        callback(lastPos, string_sub(str, lastPos, strLen))
    end

    return strings
end

--[[
    @desc: 急速查找方法
    author:TangJian
    time:2021-04-23 16:42:59
    --@str: 需要查找的字符串
    @return: 是否找到字典树中的单词
]]
function Trie:findInStr(str)
    local strLen = #str
    for i = 1, strLen - self.wordMinLen + 1 do
        local currNode = self.root
        for j = i, i + self.wordMaxLen do
            local byte = string_getByte(str, j)
            if currNode[byte] then
                currNode = currNode[byte]
                if currNode["#"] then
                    return i, string_sub(str, i, j)
                end
            else
                break
            end
        end
    end
    return -1
end

function Trie:relpaceString(str, callback)
    local strings = {}
    self:partitionWithCallback(str, function(i, s)
        if self.wordMap[s] then
            table.insert(strings, callback(s))
        else
            table.insert(strings, s)
        end
    end)

    return table.concat(strings)
end

return Trie
0000000000000000