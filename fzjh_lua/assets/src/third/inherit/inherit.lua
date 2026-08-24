local PairsCoroutine = require("third.coroutine.PairsCoroutine")

local function log(...)
    if PRINT_MODE == 1 then
        print("inherit:", ...)
    end
end

local function getValue(values, nils, parents, key)
    -- 记录空值表如果为true, 则返回空值
    if nils[key] then
        return nil
    else
        -- 获取自己表的数据
        local value = values[key]
        if value == nil then
            for i = 1, #parents do
                value = parents[i][key]
                if value ~= nil then
                    -- 获取table可能会进行修改, 所以得克隆一份新的, 避免影响到父节点数据
                    if type(value) == "table" then
                        value = clone(value)
                    end

                    -- 使用到的至, 存储到自己的表中, 用于下次获取加速
                    values[key] = value
                    break
                end
            end

            -- 如果获取不到值，则设置威nil，防止反复查找
            if value == nil then
                nils[key] = true
            end
        end

        return value
    end
end

local function setValue(values, nils, parents, key, value)
    -- 记录空值
    if value == nil then
        nils[key] = true
    else
        nils[key] = false
    end

    values[key] = value
end

-- 遍历属性的协程
local function walkValues(self, filter)
    local values = rawget(self, "__inherit").values
    local nils = rawget(self, "__inherit").nils
    local parents = rawget(self, "__inherit").getParents()

    local records = {}

    local l_pairs = pairs

    for k, v in l_pairs(values) do
        if nils[k] then
        else
            records[k] = true
            if filter then
                k, v = filter(k, v)
            end
            coroutine.yield(k, v)
        end
    end

    for i = 1, #parents do
        local parent = parents[i]
        for k, v in l_pairs(parent) do
            if nils[k] then
            elseif records[k] then
            else
                records[k] = true
                k, v = k, self[k]
                if filter then
                    k, v = filter(k, v)
                end
                coroutine.yield(k, v)
            end
        end
    end
end

-- 简化parents, 避免重复继承和继承自身
local function simplifyParents(parents)
    local lookup = {}

    for i = #parents, 1, -1 do
        local parent = parents[i]

        if lookup[parent] then
            table.remove(parents, i)
        else
            lookup[parent] = true
            if parent ~= nil and next(parent) == nil and getmetatable(parent) == nil then
                log("继承的类中有空表, 已移除")
                table.remove(parents, i)
            end
        end
    end

    return parents
end

local function __getn(self)
    return table.getn(rawget(self, "__inherit").values)
end

-- 迭代器
local function __pairs(self)
    return PairsCoroutine(walkValues, self)
end

-- clone
local function __clone(self, lookup_table)
    local newObject = {}
    lookup_table[self] = newObject

    rawset(newObject, "__inherit", clone(rawget(self, "__inherit"), lookup_table))
    rawset(newObject, "__pairs", __pairs)
    rawset(newObject, "__clone", __clone)
    rawset(newObject, "__getn", __getn)

    return setmetatable(newObject, getmetatable(self))
end

local inherit_metatable = {
    __index = function(tb, key)
        local __inherit = rawget(tb, "__inherit")
        local values = __inherit.values
        local nils = __inherit.nils
        local parents = __inherit.getParents()

        return getValue(values, nils, parents, key)
    end,
    __newindex = function(tb, key, value)
        local __inherit = rawget(tb, "__inherit")
        local nils = __inherit.nils
        local values = __inherit.values
        local parents = __inherit.getParents()

        setValue(values, nils, parents, key, value)
    end
}

local function inherit_base(dataTb, ...)
    -- 无需clone, 可以单独拿出来
    local parents = {...}
    parents = simplifyParents(parents)

    -- 需要clone
    local child = {
        __inherit = {
            -- 忽略tablecover
            __ignore_table_cover = true,
            -- 数值存储
            values = dataTb,
            -- 空值存储
            nils = {},
            -- 父类列表获取
            getParents = function()
                return parents
            end
        }
    }

    child.__getn = __getn
    child.__pairs = __pairs
    child.__clone = __clone

    return setmetatable(child, inherit_metatable)
end

-- 简单继承, 可以支持遍历
-- data: 数据存取table
-- ... : 父节对象
local function inherit(dataTable, ...)
    return inherit_base(dataTable, ...)
end

return inherit
0000000000