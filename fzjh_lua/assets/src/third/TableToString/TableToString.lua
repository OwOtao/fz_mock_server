-- 拼凑变量名的字符列表
local charArray = {
    "_",
    "a",
    "b",
    "c",
    "d",
    "e",
    "f",
    "g",
    "h",
    "i",
    "j",
    "k",
    "l",
    "m",
    "n",
    "o",
    "p",
    "q",
    "r",
    "s",
    "t",
    "u",
    "v",
    "w",
    "x",
    "y",
    "z",
    "A",
    "B",
    "C",
    "D",
    "E",
    "F",
    "G",
    "H",
    "I",
    "J",
    "K",
    "L",
    "M",
    "N",
    "O",
    "P",
    "Q",
    "R",
    "S",
    "T",
    "U",
    "V",
    "W",
    "X",
    "Y",
    "Z"
}

-- 字符列表长度
local charArrayLen = #charArray

-- lua保留字, 不能作为变量名
local reservedWordMap = 
{
    ["and"] = true,
    ["break"] = true,
    ["do"] = true,
    ["else"] = true,
    ["elseif"] = true,
    ["end"] = true,
    ["false"] = true,
    ["for"] = true,
    ["function"] = true,
    ["if"] = true,
    ["in"] = true,
    ["local"] = true,
    ["nil"] = true,
    ["not"] = true,
    ["or"] = true,
    ["repeat"] = true,
    ["return"] = true,
    ["then"] = true,
    ["true"] = true,
    ["until"] = true,
    ["while"] = true,
    ["goto"] = true
}

-- 将整数转为字符串
local function intToChar(int)
    local rets = {}

    repeat
        table.insert(rets, charArray[int % charArrayLen + 1])
        int = math.floor(int / charArrayLen)
    until int <= 0

    return table.concat(rets)
end

--[[
    @desc:table转字符串方法
    author:TangJian
    time:2021-08-11 18:53:30
    --@tb:表
	--@compress:是否压缩
	--@isCoroutine: 是否为协程
    @return:字符串
]]
local function tableToString(tb, compress, isCoroutine)
    if type(tb) ~= "table" then
        print("tableToString 参数1必须为table类型")
        return tostring(tb)
    end

    -- 要返回的字符串列表
    local rets = {}
    -- 防止递归的table查询表
    local lookUp = {}
    -- 需要处理的key和value
    local keyValueIndexArray = {}
    -- 每个值出现的次数记录
    local valueTimesMap = {}
    -- 加密表
    local keyEncryptMap = {}
    -- 解密表
    local keyDecryptMap = {}
    -- 变量名缓存
    local varNameMap = {}

    -- 判断能否序列化, 用来排除一些不需要序列化的对象
    local function canSerialized(value, valueType)
        valueType = valueType or type(value)
        if lookUp[value] or valueType == "function" or valueType == "userdata" then
            return false
        elseif valueType == "table" and value.__isNotSerializable then
            return false
        end
        return true
    end

    -- 不能序列化, 直接返回
    if canSerialized(tb) == false then
        return tostring(tb)
    end

    -- 重写table插入, 用于记录需要替换的字符串
    local tableInsert = function(array, value, needRecord)
        table.insert(array, value)
        if compress and needRecord then
            if valueTimesMap[value] == nil then
                valueTimesMap[value] = 0
            end
            valueTimesMap[value] = valueTimesMap[value] + 1
            table.insert(keyValueIndexArray, #rets)
        end
    end
    
    -- 回车字符 '\n'
    local stringCharReturn = string.char(10)

    -- 拼接字符串, 拼接前处理\n开头的字符串, 在前天添加一个\n. 因为直接concat会导致第一个\n丢失
    local tableConcat = function(stringArray)
        for i, v in ipairs(stringArray) do
            if string.byte(v, 1) == 10 then
                v = stringCharReturn .. v
            end
            stringArray[i] = v
        end

        return table.concat(stringArray)
    end 

    -- 判断字符串是否可以作为变量名
    local function isVarName(name)
        local ok = varNameMap[name]
        if ok ~= nil then
            return ok
        else
            ok = string.match(name, "^[_%a][_%w]*$") ~= nil
            varNameMap[name] = ok
            return ok
        end
    end
    
    -- table的key转成字符串
    local function keyToString(key)
        if type(key) == "string" then
            if isVarName(key) then
                tableInsert(rets, key, true)
                tableInsert(rets, "=")
            else
                tableInsert(rets, [=[["]=])
                tableInsert(rets, key, true)
                tableInsert(rets, [==["]=]==])
            end
        else
            tableInsert(rets, "[" .. tostring(key) .. "]=")
        end
    end

    -- table的value转成字符串
    local function valueToString(tb, tbType)
        local tableType = tbType or type(tb)
        if tableType == "string" then
            -- 如果有换行或者是左右中括号, 则用 [=[]=]包裹字符串, 否则直接用 ""
            if string.find(tb, "[\n\"'%[%]]") then
                tableInsert(rets, "[=[")
                tableInsert(rets, tb, true)
                tableInsert(rets, "]=]")
            else
                tableInsert(rets, '"')
                tableInsert(rets, tb, true)
                tableInsert(rets, '"')
            end
        elseif tableType == "table" then
            -- 如果则处理table内容, 没元素直接插入{}
            if next(tb) ~= nil then
                -- 查询表, 用于去重防止递归
                lookUp[tb] = tb
                
                tableInsert(rets, "{")

                -- 判断是否为数组
                local isArray = true
                for k, v in pairs(tb) do
                    if type(k) ~= "number" then
                        isArray = false
                        break
                    end
                end

                -- 数组不需要key=value, 映射(map)需要key=value
                if isArray then
                    for i, v in ipairs(tb) do
                        local vType = type(v)
                        if canSerialized(v, vType) then
                            valueToString(v, vType)
                            tableInsert(rets, ",")
                        end
                    end
                else
                    for k, v in pairs(tb) do
                        local vType = type(v)
                        if canSerialized(v, vType) then
                            keyToString(k)
                            valueToString(v, vType)
                            tableInsert(rets, ",")
                        end
                    end
                end
                -- 最后的,用}替换, 比如直接插入}效率更高
                rets[#rets] = "}"
            else
                tableInsert(rets, "{}")
            end
        else
            -- 非字符串和table类型, 直接tostring
            tableInsert(rets, tostring(tb))
        end

        -- 协程节点位置
        if isCoroutine then
            coroutine.yield()
        end
    end

    -- 转table为string, 根入口
    valueToString(tb)
    
    -- 如果需要压缩, 则走压缩流程
    if compress then

        -- 整理需要加密的关键词
        local sortedValueTimesArray = {}
        for k, v in pairs(valueTimesMap) do
            local keyLen = #k
            tableInsert(sortedValueTimesArray, {key = k, sortValue = keyLen * v - (keyLen + 4)})
        end

        -- 按照长度乘出现次数排序, 优先处理长的且出现次数多的字符串
        table.sort(
            sortedValueTimesArray,
            function(a, b)
                return a.sortValue > b.sortValue
            end
        )

        -- 生成加密表
        local keyIndex = -1
        for i, v in ipairs(sortedValueTimesArray) do
            -- 不断尝试, 获取到一个不与需要加密的字符串中的元素相等的字符串
            local char = nil
            repeat
                keyIndex = keyIndex + 1
                char = intToChar(keyIndex)
            until valueTimesMap[char] == nil and reservedWordMap[char] == nil
            
            local charLen = #char
            -- 无需重复添加 并且只有当能够减少序列化后的字符串长度才会加密
            if v.sortValue > 0 then
                keyEncryptMap[v.key] = char
            else
                -- 上边排了序, 如果不满足条件, 则后续的都不会满足
                break
            end
        end

        -- 加密键值对
        for _, v in ipairs(keyValueIndexArray) do
            local i = v
            v = rets[v]
            local encrypt = keyEncryptMap[v]
            if encrypt ~= nil then
                keyDecryptMap[encrypt] = v
                rets[i] = encrypt
            end
        end
        
        tableInsert(rets, ",")

        -- 插入解密表
        tableInsert(rets, tableToString(keyDecryptMap))
        return tableConcat(rets)
    else
        return tableConcat(rets)
    end
end

-- 创建tableToString的协程
local function tableToStringCoroutine()
    return coroutine.create(
        function(tb, compress)
            local retString = table.tostring(tb, compress, true)
            coroutine.yield(true, retString)
        end
    )
end

-- 解密字符串为table
local function loadString(str)
    local func = loadstring("return " .. str)
    if not func then
        return nil
    end
    local tb, keyMap = func()
    if keyMap and next(keyMap) ~= nil then
        local function trans(tb)
            if type(tb) ~= "table" then
                local ret = keyMap[tb]
                if ret == nil then
                    return tb
                end
                return ret
            end

            local newTb = {}
            for k, v in pairs(tb) do
                local key = keyMap[k]
                if key == nil then
                    newTb[k] = trans(v)
                else
                    newTb[key] = trans(v)
                end
            end
            return newTb
        end

        return trans(tb)
    end

    return tb
end

return {tableToString, loadString, tableToStringCoroutine}0000000