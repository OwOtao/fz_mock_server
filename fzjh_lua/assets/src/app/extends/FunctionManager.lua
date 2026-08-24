local DEBUG = true

-- 打印log
local function printLog(...)
    if DEBUG ~= true then return end
    local args = {...}
    for i, v in ipairs(args) do
        args[i] = tostring(v)
    end
    local str = table.concat(args, "")
    if PRINT_MODE == 1 then
        print(str)
    end
end

-----------------------------------------------------------
local FunctionManager = {}

function FunctionManager:create()
    local p = clone(FunctionManager)
    p:init()
    return p
end

function FunctionManager:init()
    self._functions = {}
end

function FunctionManager:getFuncCount()
    return #self._functions
end

-- 添加方法
function FunctionManager:addFunction(func)
    assert(type(func) == "function", "type(func) = " .. type(func))
    table.insert(self._functions, func)-- 插入到队列尾部 add by TangJian 2017/06/20 01:38:59
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/06/20 01:39:30
-- @desc 执行头部方法并且移除
function FunctionManager:callAndRemoveFunction(index, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10)
    local funcCount = #self._functions
    if funcCount <= 0 or index > funcCount then return end    
    local func = self._functions[index]
    if func(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10) then
        table.remove(self._functions, index)
    end
end

-- 执行所有方法，移除返回值为true or nil的方法。
function FunctionManager:callFunctions(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10)
    local funcCount = #self._functions
    if funcCount <= 0 then return end
    local removeList = {}
    -- 执行所有方法
    for i, func in ipairs(self._functions) do
        local ret = func(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10)
        if ret == true then
            table.insert(removeList, i)
        end
    end
    
    -- 移除执行成功的方法
    for i = #removeList, 1, -1 do
        local removeId = removeList[i]
        table.remove(self._functions, removeId)
    end
end

function FunctionManager:test()
    local fm = FunctionManager:create()
    
    fm:addFunction(
        function(tag)
            if tag == "tag" then
                printLog("test")
                return true
            end
        end)
    
    for i = 1, 10 do
        fm:callFunctions("tag")
    end
end
-- FunctionManager.test()
return FunctionManager
0000000000000000