-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/14 11:17:44
-- @desc 插入一个数组
function table.insertArray(t1, t2)
    for i, v in ipairs(t2) do
        table.insert(t1, v)
    end
    return t1
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/14 11:17:38
-- @desc 移除范围内的数据
function table.removeRange(array, from, to)
    local arrayCount = table.getn(array)
    for i = arrayCount, 1, -1 do
        if (from == nil or i >= from) and (to == nil or i <= to) then
            table.remove(array, i)
        end
    end
    return array
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 清空table
function table.clean(tb)
    for k, v in pairs(tb) do
        tb[k] = nil
    end
    return tb
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/14 11:17:54
-- @desc 合并两个数组
function table.mergeArray(array1, array2)
    local array3 = {}
    for i, v in ipairs(array1) do
        table.insert(array3, v)
    end
    for i, v in ipairs(array2) do
        table.insert(array3, v)
    end
    return array3
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/29 18:20:27
-- @desc 追加数组
function table.appendArray(array1, array2)
    if type(array1) == "table" and type(array2) == "table" then
        for i, v in ipairs(array2) do
            table.insert(array1, v)
        end
    end
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/01/12 10:14:03
-- @desc 合并两个map
function table.mergeMap(map1, map2)
    map1 = Helper:getDef(map1, {})
    map2 = Helper:getDef(map2, {})
    local retMap = {}
    for k, v in pairs(map1) do
        retMap[k] = v
    end

    for k, v in pairs(map2) do
        retMap[k] = v
    end
    return retMap
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/03/09 16:39:20
-- @desc 合并到左边table
function table.mergeToLeft(tb1, tb2)
    for k, v in pairs(tb2) do
        tb1[k] = v
    end
    return tb1
end

function table.addToLeft(tb1, tb2)
    for k, v in pairs(tb2) do
        if tb1[k] == nil then
            tb1[k] = v
        else
            tb1[k] = tb1[k] + v
        end
    end
    return tb1
end

-- 对每个元素处理方法
-- 用例:
-- map({1, 2, 3}, function(i) return i + 1 end)
-- return {2, 3, 4}
function table.map(tb, func)
    if tb == nil then
        return tb
    end

    local ret_tb = {}
    for k, v in pairs(tb) do
        ret_tb[k] = func(v)
    end
    return ret_tb
end

-- 过滤方法
-- 用例:
-- filter({1, 2, 3}, function(i, v) return v >= 2 end)
-- return {2, 3}
function table.filter(tb, func)
    if tb == nil then
        return tb
    end

    local ret_tb = {}
    for k, v in pairs(tb) do
        if func(k, v) then
            ret_tb[k] = v
        end
    end
    return ret_tb
end

-- @可以还原顺序的排序
function table.sortWithRollback(list, compare)
    local summaryMap = {}
    local listLen = table.getn(list)
    for i, v in ipairs(list) do
        assert(type(v) == "table", "expect a table")
        summaryMap[v] = i
    end

    table.sort(list, compare)

    local rollbackFunc = function()
        table.sort(
            list,
            function(a, b)
                if summaryMap[a] == nil then
                    summaryMap[a] = listLen + 1
                end
                if summaryMap[b] == nil then
                    summaryMap[b] = listLen + 1
                end
                return summaryMap[a] < summaryMap[b]
            end
        )
    end

    if listLen == 0 then
        rollbackFunc = function()
        end
    end

    return rollbackFunc
end

-- 二分搜索默认比较器
local defaultComparator = function(a, b)
    if a > b then
        return 1
    elseif a < b then
        return -1
    end
    return 0
end

-- 二分搜索
-- @param list    搜索的列表元素
-- @param val     搜索的元素
-- @param compare 元素比较的方法
-- @ret   返回查找元素的下表, 如果不存在则返回-1
-- 时间复杂度 O(logn)
function table.binarySearch(list, val, comparator)
    -- 默认比较元素大小方法
    if comparator == nil then
        comparator = defaultComparator
    end

    local l = 1
    local r = table.getn(list)
    while l <= r do
        local m = math.floor((r - l) / 2 + l)
        if comparator(list[m], val) == 0 then
            return m
        elseif comparator(list[m], val) > 0 then
            r = m - 1
        else
            l = m + 1
        end
    end
    return -1
end

function table.tostring(tb)
    local lookup = {}
    local function tableToString(tb)
        if lookup[tb] then
            return lookup[tb]
        elseif type(tb) ~= "table" then
            return tostring(tb)
        end

        local rets = {}

        lookup[tb] = tostring(tb)

        table.insert(rets, "{")
        for k, v in pairs(tb) do
            table.insert(rets, k)
            table.insert(rets, "=")
            table.insert(rets, tableToString(v))
            table.insert(rets, ",")
        end
        -- 去除，结尾
        local currLen = table.getn(rets)
        if rets[currLen] == "," then
            table.remove(rets, currLen)
        end
        table.insert(rets, "}")

        return table.concat(rets)
    end
    return tableToString(tb)
end

function table.heapSort(narray, sortFunc)
    local length = table.getn(narray)

    local function swap(i1, i2, arr)
        local tmp = arr[i2]
        arr[i2] = arr[i1]
        arr[i1] = tmp
    end

    --array是待调整的堆数组，i是待调整的数组元素的位置，nlength是数组的长度
    --本函数功能是：根据数组array构建大根堆
    local function HeapAdjust(array, i, nLength)
        local nChild
        --树深度
        while (2 * i <= nLength) do
            --子结点的位置=2*(父结点位置)
            nChild = 2 * i
            --得到子结点中较大的结点
            if (nChild < nLength and sortFunc(array[nChild + 1], array[nChild])) then
                nChild = nChild + 1
            end
            --如果较大的子结点大于父结点那么把较大的子结点往上移动，替换它的父结点
            if sortFunc(array[nChild], array[i]) then
                swap(i, nChild, array)
            else
                break
            end
            i = nChild
        end
    end

    --堆排序算法
    --调整序列的前半部分元素，调整完之后第一个元素是序列的最大的元素
    --length/2是最后一个非叶节点,构建大根堆
    for i = math.floor(length / 2), 1, -1 do
        HeapAdjust(narray, i, length)
    end

    --从最后一个元素开始对序列进行调整，不断的缩小调整的范围直到第一个元素
    for i = length, 1, -1 do
        --把第一个元素和当前的最后一个元素交换
        swap(i, 1, narray)
        HeapAdjust(narray, 1, i - 1)
    end
end

local function mergeSort(arr, low, high, sortFunc)
    local low = low
    local high = high
    if high - low < 1 then
        return
    end

    local mid = math.floor((low + high) / 2)
    -- 递归的拆分子序列
    mergeSort(arr, low, mid, sortFunc)
    mergeSort(arr, mid + 1, high, sortFunc)

    -- i, m 代表一个序列中的低高位
    -- m+1，high 代表相邻的另外一个序列（right序列）的低高位
    local i, m = low, mid
    local temp
    while i <= m and m + 1 <= high do
        local result
        if sortFunc ~= nil and type(sortFunc) == "function" then
            result = sortFunc(arr[m + 1], arr[i])
        else
            result = arr[i] < arr[m + 1]
        end
        if result then
            temp = arr[m + 1]
            -- 迭代left序列
            -- 之所以这么迭代是因为我们本质上还是在arr中
            for j = m, i, -1 do
                arr[j + 1] = arr[j]
            end
            arr[i] = temp
            m = m + 1
        else
            i = i + 1
        end
    end
end

--[[
    @desc: 将map转成array
    author:TangJian
    time:2021-11-15 14:24:16
    --@map: table
    @return: array
]]
function table.mapToArray(map)
    assert(type(map) == "table")
    local array = {}
    for _, v in pairs(map) do
        table.insert(array, v)
    end
    return array
end

function table.arrayToMap(array)
    assert(type(array) == "table")
    local map = {}
    for _, v in ipairs(array) do
        map[v] = true
    end
    return map
end

function table.mergeSort(arr, low, high, sortFunc)
    mergeSort(arr, low, high, sortFunc)
end

function table.cloneAndRemoveFunctions(data)
    local lookUp = {}
    local function _cloneAndRemoveFunctions(data)
        local dataType = type(data)
        if dataType == "number" or dataType == "string" or dataType == "boolean" then
            return data
        elseif lookUp[data] then
            return lookUp[data]
        elseif dataType == "table" then
            if data.__ignore_table_cover == true then
            else
                local newData = {}

                lookUp[data] = newData

                for k, v in pairs(data) do
                    newData[k] = _cloneAndRemoveFunctions(v)
                end
                return newData
            end
        end
        return nil
    end
    local newData = _cloneAndRemoveFunctions(data)
    if type(newData) ~= "table" then
        newData = {}
    end

    return newData
end

function table.getMap(t, filter)
    local map = {}
    for k, v in pairs(t) do
        local newKey, newValue = filter(k, v)
        map[newKey] = newValue
    end
    return map
end

--[[
    @desc: 数组包含判断
    author:TangJian
    time:2022-01-11 17:34:56
    --@a: array
	--@b: array
    @return: true|false
]]
function table.contains(a, b)
    if type(a) ~= "table" then
        a = {a}
    end
    if type(b) ~= "table" then
        b = {b}
    end

    local map =
        table.getMap(
        a,
        function(k, v)
            return v, true
        end
    )

    for i, v in ipairs(b) do
        if map[v] == nil then
            return false
        end
    end
    return true
end

function table.removeFromArray(array, filter)
    for i = table.getn(array), 1, -1 do
        if filter(i, array[i]) then
            table.remove(array, i)
        end
    end
end

function table.removeArrayFromArray(array, removeArray)
    local needRemoveMap =
        table.getMap(
        removeArray,
        function(k, v)
            return v, true
        end
    )

    for i = table.getn(array), 1, -1 do
        if needRemoveMap[array[i]] then
            table.remove(array, i)
        end
    end
end

--[[
    @desc: 从table中获取{key1,key2,key3,...}的值
    author:TangJian
    time:2021-12-15 18:11:38
    --@tb:
	--@key: 
    @return:
]]
function table.getValueListByKey(tb, key)
    assert(type(tb) == "table", "table.getValueListByKey tb is not a table")
    assert(type(key) == "string", "table.getValueListByKey key is not a string")

    local list = {}

    for i = 1, 99999 do
        local value = tb[key .. tostring(i)]
        if value == nil then
            return list
        end
        table.insert(list, value)
    end

    return list
end

--[[
    @desc: 从table中获取{{key1 = key11,key2=key21,...},{key1=key12,key2=key22},...}的值
    author:TangJian
    time:2021-12-15 18:12:50
    --@tb:
	--@keys: 
    @return:
]]
function table.getTableListByKeyList(tb, keys)
    assert(type(tb) == "table", "table.getTableListByKeyList tb is not a table")
    assert(table.getn(keys) > 0, "keys is empty")

    local list = {}

    for i = 1, 99999 do
        local obj = {}
        for _, key in ipairs(keys) do
            local value = tb[key .. tostring(i)]
            if value == nil then
                return list
            end
            obj[key] = value
        end
        table.insert(list, obj)
    end

    return list
end

--[[
    @desc: 将一个table内所有值全部转为number
    author:TangJian
    time:2022-01-21 16:52:07
    --@tb: 
    @return:
]]
function table.tonumber(tb)
    return table.getMap(
        tb,
        function(k, v)
            return k, tonumber(v)
        end
    )
end

--[[
    @desc: 对数组进行切片操作
    author:TangJian
    time:2022-09-16 15:25:40
    --@arr: 原数组
	--@l: 起始位置
	--@r: 结束位置
	--@step: 步长
    @return:
]]
function table.slice(arr, l, r, step)
    if l == nil then
        l = 1
    end
    if r == nil or r == -1 then
        r = table.getn(arr)
    end
    if step == nil then
        step = 1
    end

    local ans = {}
    for i = l, r, step do
        table.insert(ans, arr[i])
    end
    return ans
end

--[[
    @desc: 顺序使用默认的hashMap遍历顺序
    author:TangJian
    time:2022-09-17 17:15:15
    --@arr:
	--@key: 
    @return:
]]
function table.hashSort(arr, key)
    local map =
        table.getMap(
        arr,
        function(k, v)
            return v[key], v
        end
    )
    return table.mapToArray(map)
end

--[[
    @desc: 数组去重
    author:TangJian
    time:2022-10-18 18:12:37
    --@array:
	--@key: 
    @return:
]]
function table.removeDuplicates(array, key)
    local map = {}
    for i, t in ipairs(array) do
        if map[t[key]] == nil then
            map[t[key]] = 0
        end
        map[t[key]] = map[t[key]] + 1
    end
    for i = table.getn(array), 1, -1 do
        if map[array[i][key]] > 1 then
            map[array[i][key]] = map[array[i][key]] - 1
            table.remove(array, i)
        end
    end
end

--[[
    @desc: 所有为true则为true否则为false
    author:TangJian
    time:2022-11-17 16:05:07
    --@array: 
    @return:
]]
function table.all(array)
    local isTrue = false
    for _, b in ipairs(array) do
        if not b then
            return false
        end
    end
    return true
end

--[[
    @desc: 所有为false则为false否则为true
    author:TangJian
    time:2022-11-17 16:05:22
    --@array: 
    @return:
]]
function table.any(array)
    local isTrue = false
    for _, b in ipairs(array) do
        if b then
            return true
        end
    end
    return false
end

function table.pack(...)
    return {n = select("#", ...), ...}
end

function table.unpack(t, i, j)
    return unpack(t, i or 1, j or t.n or #t)
end
0000000000000000