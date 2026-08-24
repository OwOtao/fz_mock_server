local Decorator = {}

-- 方法替换记录 add by TangJian 2016/11/08 20:09:20
function Decorator:record(class, dealMethod, funcName)
    if type(class) == "table" then
        if type(class.__decorator) ~= "table" then
            class.__decorator = {
                dealMethods = {}
            }
        end
        if type(class.__decorator.dealMethods[dealMethod]) ~= "table" then
            class.__decorator.dealMethods[dealMethod] = {}
        end
        class.__decorator.dealMethods[dealMethod][funcName] = true
    else
        if PRINT_MODE == 1 then
            print("Decorator:record(class, dealMethod, funcName)")
        end
    end
end

-- 移除记录
function Decorator:unRecord(class, dealMethod, funcName)
    if type(class) == "table" then
        if type(class.__decorator) ~= "table" then
            class.__decorator = {
                dealMethods = {}
            }
        end
        if type(class.__decorator.dealMethods[dealMethod]) ~= "table" then
            class.__decorator.dealMethods[dealMethod] = {}
        end
        class.__decorator.dealMethods[dealMethod][funcName] = nil
    else
        if PRINT_MODE == 1 then
            print("Decorator:record(class, dealMethod, funcName)")
        end
    end
end

-- 判断是否已经有过类似处理
function Decorator:isRecorded(class, dealMethod, funcName)
    if type(class) == "table" then
        if type(class.__decorator) ~= "table" then
            class.__decorator = {
                dealMethods = {}
            }
        end
        if type(class.__decorator.dealMethods[dealMethod]) ~= "table" then
            class.__decorator.dealMethods[dealMethod] = {}
        end
        return class.__decorator.dealMethods[dealMethod][funcName] == true
    else
        if PRINT_MODE == 1 then
            print("error: Decorator:isRecorded(class, dealMethod, funcName)")
        end
    end
    return false
end

-- 在class类的所有函前面执行beforeFunc(funcName, ...)方法
function Decorator:beforeAll(class, beforeFunc)
    for funcName, v in pairs(class) do
        if type(v) == "function" then
            self:before(class, funcName, beforeFunc)
        end
    end
end

-- 在class类的所有函后面执行beforeFunc(funcName, ...)方法
function Decorator:afterAll(class, beforeFunc)
    for funcName, v in pairs(class) do
        if type(v) == "function" then
            self:after(class, funcName, beforeFunc)
        end
    end
end

function Decorator:before(class, funcName, beforeFunc)
    assert(type(class) == "table", "type(class) = " .. type(class))
    assert(type(funcName) == "string", "type(funcName) = " .. type(funcName))
    assert(type(beforeFunc) == "function", "type(beforeFunc) = " .. type(beforeFunc))

    if self:isRecorded(class, "before", funcName) then
        -- print("方法", funcName, "已经", "添加了before处理")
    else
        -- print("给方法", funcName, "添加before处理")
        self:record(class, "before", funcName)

        local func = class[funcName]
        assert(type(func) == "function", "type(func) = " .. type(func))

        class[funcName] = function(...)
            beforeFunc(funcName, ...)
            return func(...)
        end
    end
end

function Decorator:after(class, funcName, afterFunc)
    assert(type(class) == "table", "type(class) = " .. type(class))
    assert(type(funcName) == "string", "type(funcName) = " .. type(funcName))
    assert(type(afterFunc) == "function", "type(afterFunc) = " .. type(afterFunc))

    if self:isRecorded(class, "after", funcName) then
        -- print("方法", funcName, "已经", "添加了after处理")
    else
        -- print("给方法", funcName, "添加after处理")
        self:record(class, "after", funcName)

        local func = class[funcName]
        assert(type(func) == "function", "type(func) = " .. type(func))

        class[funcName] = function(...)
            local arg1, arg2, arg3, arg4, arg5 = func(...)
            afterFunc(funcName, ...)
            return arg1, arg2, arg3, arg4, arg5
        end
    end
end

-- 替换掉class类的funcName方法为replaceFunc
function Decorator:replace(class, funcName, replaceFunc)
    assert(type(class) == "table", "type(class) = " .. type(class))
    assert(type(funcName) == "string", "type(funcName) = " .. type(funcName))
    assert(type(replaceFunc) == "function", "type(replaceFunc) = " .. type(replaceFunc))

    if self:isRecorded(class, "replace", funcName) then
        -- print("方法", funcName, "已经", "replace过了")
    else
        -- print("给方法", funcName, "添加replace处理")
        self:record(class, "replace", funcName)

        local func = class[funcName]
        assert(type(func) == "function", "type(func) = " .. type(func))

        class[funcName] = function(...)
            return replaceFunc(funcName, func, ...)
        end

        -- 返回个方法, 可以还原之前的替换
        return function()
            class[funcName] = func
            self:unRecord(class, "replace", funcName)
        end
    end
end

function Decorator:replaceAll(class, replaceFunc)
    for funcName, v in pairs(class) do
        if type(v) == "function" then
            self:replace(class, funcName, replaceFunc)
        end
    end
end

return Decorator
0000000000000