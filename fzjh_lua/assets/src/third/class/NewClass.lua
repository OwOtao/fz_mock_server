local inherit = require("third.inherit.inherit")
local isImplement = require("third.assertIsInstance.assertIsInstance")

-- @desc 分离类和接口的方法
local function splitClassAndInterface(parents)
    local interfaces = {}

    -- 分离接口和类
    for i = #parents, 1, -1 do
        local parent = parents[i]
        if parent.__isInterface == true then
            table.insert(interfaces, parent)
            table.remove(parents, i)
        elseif parent.__isAbstract == true then
            table.remove(parents, i)
            for j = #parent.__interfaces, 1, -1 do
                table.insert(interfaces, parent.__interfaces[j])
            end
            table.insert(parents, parent.__body)
        end
    end

    if PRINT_MODE == 1 then
        print("#parents", #parents)
        print("#interfaces", #interfaces)
    end

    return parents, interfaces
end

-- @desc 定义和实现类
-- @desc 提供 .new方法, 可以创建出一个新的实例
local function newClass(className, parents, classBody, isSerializable)
    if isSerializable == nil then
        isSerializable = false
    end

    classBody.__isNotSerializable = not isSerializable

    if parents == nil or #parents == 0 then
        local c = classBody

        -- new方法
        c.new = function(data)
            if type(data) ~= "table" then
                data = {}
            else
                data = clone(data)
            end

            local p = inherit(data, c)
            if p.ctor then
                p:ctor()
            end

            return p
        end

        return c
    end

    -- 分离接口和类
    local classes, interfaces = splitClassAndInterface(parents)

    -- 继承类
    local c = inherit({}, classBody, unpack(classes))

    -- 实现接口
    isImplement(c, unpack(interfaces))

    -- 记录下老的new方法
    local oldNew = c.new
    if oldNew == nil then
        oldNew = function()
            return nil
        end
    end

    -- new方法
    c.new = function(data)
        if type(data) ~= "table" then
            data = {}
        else
            data = clone(data)
        end

        local p = inherit(data, c, oldNew())
        if p.ctor then
            p:ctor()
        end

        return p
    end

    -- 暴露new方法
    classBody.new = c.new

    return c
end

return newClass
000