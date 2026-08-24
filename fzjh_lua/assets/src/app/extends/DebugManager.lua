local Decorator = require("app.Decorator")

local DebugManager = {}

local indent = -1
local cache = {}
local function getTargetMemberValue(memberName, ...)
    local func = cache[memberName]
    if func == nil then
        func = loadstring("local arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8,arg9,arg10 = ... return " .. memberName)
        cache[memberName] = func
    end

    local ok, value = pcall(func, ...)
    if ok then
        return value
    end
    return nil
end

local getConfig = function(config, ...)
    if config == nil then
        return ""
    end

    local str = {}
    if config ~= nil then
        for i, member in ipairs(config) do
            local showName = member.name
            local memberValue = member.value
            local value = getTargetMemberValue(memberValue, ...)

            table.insert(str, showName)
            table.insert(str, "=")
            table.insert(str, tostring(value))
            table.insert(str, " ")
        end
    end
    return table.concat(str)
end

-- configs =
-- {
--     functionName =
--     {
--         members = {}
--     }
-- }
-- ignoreList = {functionName1, functionName2}
function DebugManager:addLog(name, class, configs, ignoreList)
    local ignoreMap = {}
    if ignoreList ~= nil then
        for i, ignore in ipairs(ignoreList) do
            ignoreMap[ignore] = true
        end
    end

    if type(configs) ~= "table" then
        configs = {}
    end

    Decorator:replaceAll(
        class,
        function(funcName, func, ...)
            if ignoreMap[funcName] == nil then
                indent = indent + 1

                local config = configs[funcName]

                print("call " .. string.rep("  ", indent) .. name .. ":" .. funcName .. " begin", ..., getConfig(config, ...))

                local beginTime = socket.gettime()
                local retParams = {func(...)}

                print("call " .. string.rep("  ", indent) .. name .. ":" .. funcName .. " end", unpack(retParams), getConfig(config, ...), "time-consuming:", socket.gettime() - beginTime)

                indent = indent - 1
                return unpack(retParams)
            else
                return func(...)
            end
        end
    )
end

function DebugManager:addLogMin(name, class, configs)
    Decorator:replaceAll(
        class,
        function(funcName, func, ...)
            local config = configs[funcName]
            if config ~= nil then
                indent = indent + 1

                print("call " .. string.rep("  ", indent) .. name .. ":" .. funcName .. " begin", ..., getConfig(config, ...))

                local beginTime = socket.gettime()
                local retParams = {func(...)}

                print("call " .. string.rep("  ", indent) .. name .. ":" .. funcName .. " end", unpack(retParams), getConfig(config, ...), "time-consuming:", socket.gettime() - beginTime)

                indent = indent - 1
                return unpack(retParams)
            else
                return func(...)
            end
        end
    )
end

return DebugManager
000