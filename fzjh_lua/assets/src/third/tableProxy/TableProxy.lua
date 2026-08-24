local EncryptedTable = require("third.encryptedTable.EncryptedTable")

local DataValidationTable = require("third.dataValidationTable.DataValidationTable")

-- table类型 -------------------------------------------------------------
local TABLE_TYPE_SAFE = 1

table.getn = function(t)
    if EncryptedTable:isEncryptedTable(t) then
        return EncryptedTable.__getn(t)
    end

    -- 支持table自己实现迭代器
    if rawget(t, "__getn") then
        return rawget(t, "__getn")(t)
    end

    if t and t.ignorePart then
        return table.getn(t.ignorePart.tb)
    else
        return #t
    end
end

table.insert = function(dest, src, begin)
    -- assert(type(dest) == "table", "table.insert: dest is not a table")
    if begin == nil then
        begin = table.getn(dest) + 1
    else
        local tmp = src
        src = begin
        begin = tmp
    end
    -- assert(type(begin) == "number", "table.insert: begin is not a number")

    for i = table.getn(dest), begin, -1 do
        dest[i + 1] = dest[i]
    end

    dest[begin] = src
end

table.remove = function(dest, index)
    -- assert(type(dest) == "table", "table.remove: dest is not a table")
    -- assert(type(index) == "number", "table.remove: index is not a number")

    -- 为了保持和默认的table。remove一致， index小于等于0直接返回空值
    if index <= 0 then
        return ""
    end

    local ret = dest[index]

    for i = index, table.getn(dest) do
        dest[i] = dest[i + 1]
    end

    return ret
end

local old_pairs = pairs -- 性能优化
-- 遍历方法重写
function pairs(t, filter)
    -- 支持table自己实现迭代器
    if rawget(t, "__pairs") then
        return rawget(t, "__pairs")(t, filter)
    end

    if EncryptedTable:isEncryptedTable(t) then
        return EncryptedTable.__pairs(t, filter)
    end

    local k, v
    if rawget(t, "ignorePart") then
        return pairs(
            rawget(t, "ignorePart").tb,
            function(k, v)
                t[k] = v
                return k, v
            end
        )
    else
        return old_pairs(t)
    end
end

local old_ipairs = ipairs -- 性能优化
-- 遍历方法重写
function ipairs(t)
    -- 支持table自己实现迭代器
    if rawget(t, "__ipairs") then
        return rawget(t, "__ipairs")(t)
    end

    if EncryptedTable:isEncryptedTable(t) then
        return EncryptedTable.__ipairs(t)
    end

    if rawget(t, "ignorePart") then
        return ipairs(rawget(t, "ignorePart").tb)
    else
        return old_ipairs(t)
    end
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 重写克隆方法
function clone(object, lookup_table)
    if type(lookup_table) ~= "table" then
        lookup_table = {}
    end
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end

        if rawget(object, "ignorePart") then
            -- 判断如果是safetable, 则直接克隆data部分
            local newObject = {}
            if rawget(object, "ignorePart").tt == TABLE_TYPE_SAFE then
                for key, value in pairs(object) do
                    if key ~= "ignoreCloneTb" then
                        newObject[_copy(key)] = _copy(value)
                    end
                end
                newObject =
                    createSafeTable(
                    rawget(object, "ignorePart").createSafeTableParams[1],
                    newObject,
                    rawget(object, "ignorePart").createSafeTableParams[3],
                    rawget(object, "ignorePart").createSafeTableParams[4]
                )
            end
            lookup_table[object] = newObject
            return newObject
        elseif rawget(object, "__clone") then -- 自带clone方法的table, 用自带的clone方法
            local newObject = rawget(object, "__clone")(object, lookup_table)
            return newObject
        elseif EncryptedTable:isEncryptedTable(object) then
            return EncryptedTable.__clone(object, lookup_table)
        else
            local newObject = {}
            lookup_table[object] = newObject
            for key, value in pairs(object) do
                if key ~= "ignoreCloneTb" then
                    newObject[_copy(key)] = _copy(value)
                end
            end
            return setmetatable(newObject, getmetatable(object))
        end
    end
    return _copy(object)
end

function cloneWithInherit(object)
    if object then
        return inherit({}, object)
    end
    return object
end

local confuse = require("third.confuse.confuse")

local function safeMixValue(name, value)
    return confuse(value, name)
end

-- 创建防修改table
function createSafeTable(tableName, t, cheatCallback, needRestoreChildMap)
    if t and t.ignorePart then
        return t
    else
        -- local PRINT_MODE = 1
        -- 如果t的类型部位table, 则初始话为table
        if type(t) ~= "table" then
            t = {}
        end

        -- 如果t本身就是 safeTabe, 则取出 t 所代理的tb, 替换代理.
        if t and t.ignorePart and t.ignorePart.tt == TABLE_TYPE_SAFE then
            t = t.ignorePart.tb
        end

        -- 作弊回调
        if type(cheatCallback) ~= "function" then
            cheatCallback = nil
        end

        -- 混淆变量存储的table
        local mixUpTb = {}

        -- 代理table
        local proxy = {}
        proxy.ignorePart = {
            tt = TABLE_TYPE_SAFE, -- table类型
            tb = t, -- 需要代理的table结构
            mixUpTb = mixUpTb, -- 混淆table引用
            needCloneSafeTable = true, -- 是否需要克隆
            createSafeTableParams = {tableName, t, cheatCallback, needRestoreChildMap} -- 创建safeTable时候的参数
        }

        -- 给代理table设置元表
        setmetatable(
            proxy,
            {
                -- 新增值的时候调用(这里是修改值的时候调用)
                __newindex = function(_, k, v)
                    -- 初始化
                    if mixUpTb[k] == nil then
                        mixUpTb[k] = safeMixValue(k, t[k])
                    end

                    -- 判断是否被修改
                    if safeMixValue(k, t[k]) == mixUpTb[k] then
                        -- 数据正常
                        t[k] = v
                        mixUpTb[k] = safeMixValue(k, v)
                    else
                        local from = "unKnow"
                        local to = tostring(t[k])

                        if PRINT_MODE == 1 then
                            PopText("设置数据异常: " .. tableName .. "." .. k .. ": " .. from .. " -> " .. to)
                            print("设置数据异常: " .. tableName .. "." .. k .. ": " .. from .. " -> " .. to)
                        end

                        -- 已经被修改
                        t[k] = v
                        mixUpTb[k] = safeMixValue(k, v)

                        -- 作弊记录 add by TangJian 2017/04/05 12:26:25
                        if cheatCallback then
                            cheatCallback(t, tostring(tableName) .. "." .. tostring(k), from, to)
                        end

                        IS_ABLE_TO_SAVE_DATA = false

                        -- 作弊的直接踢出游戏 add by TangJian 2017/04/05 12:26:10
                        cc.Director:getInstance():endToLua()
                        error("作弊!!!!!!!")
                    end
                end,
                -- 获得值的时候调用
                __index = function(_, k)
                    -- 初始化
                    if mixUpTb[k] == nil then
                        mixUpTb[k] = safeMixValue(k, t[k])
                    end

                    -- 判断是否被修改
                    if safeMixValue(k, t[k]) == mixUpTb[k] then
                        -- 数据正常
                        return t[k]
                    else
                        local from = "unKnow"
                        local to = tostring(t[k])

                        -- 已经被修改
                        if PRINT_MODE == 1 then
                            PopText("获取数据异常: " .. tableName .. "." .. k .. ": " .. from .. " -> " .. to)
                            print("获取数据异常: " .. tableName .. "." .. k .. ": " .. from .. " -> " .. to)
                        end

                        -- 作弊记录 add by TangJian 2017/04/05 12:26:25
                        if cheatCallback then
                            cheatCallback(t, tostring(tableName) .. "." .. tostring(k), from, to)
                        end

                        IS_ABLE_TO_SAVE_DATA = false

                        -- 作弊的直接踢出游戏 add by TangJian 2017/04/05 12:26:10
                        cc.Director:getInstance():endToLua()
                        error("作弊!!!!!!!")
                        return
                    end
                end
            }
        )

        -- 对初始值防修改
        for k, v in pairs(t) do
            proxy[k] = v
        end

        return proxy
    end
end

local TableProxy = {}

function TableProxy:createEncryptedTable(values)
    return EncryptedTable:create(values)
end

function TableProxy:createEncryptedTableRecursive(values)
    return EncryptedTable:createRecursive(values)
end

function TableProxy:createDataValidationTable(values)
    return DataValidationTable:create(values)
end

function TableProxy:createDataValidationTableRecursive(values)
    return DataValidationTable:createRecursive(values)
end

function TableProxy:createSafeTable(tableName, t, cheatCallback, needRestoreChildMap)
    return createSafeTable(tableName, t, cheatCallback, needRestoreChildMap)
end

function TableProxy:createSafeTableRecursive(tableName, t, cheatCallback, needRestoreChildMap)
    local lookup_table = {}
    local function innerCreateEncryptedTableRecursive(tableName, t, cheatCallback)
        for k, v in pairs(t) do
            if type(v) == "table" then
                t[k] = innerCreateEncryptedTableRecursive(tableName .. "." .. k, v, cheatCallback)
            end
        end
        return createSafeTable(tableName, t, cheatCallback)
    end
    return innerCreateEncryptedTableRecursive(tableName, t, cheatCallback)
end

return TableProxy
00