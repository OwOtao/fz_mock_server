local function tableTostring(tb)
    return table.tostring(tb)
end
local LogSystem = {
    enabled = false,
    pattern = {"http:", "%[other%]"}
}

function LogSystem:setEnabled(enabled)
    self.enabled = enabled or false
end

function LogSystem:getEnabled()
    return self.enabled
end

function LogSystem:addPattern(pattern)
    local isAdd = true
    if #self.pattern > 0 then
        for i = 1, #self.pattern do
            local s = self.pattern[i]
            if s == pattern then
                isAdd = false
                break
            end
        end
    end

    if isAdd then
        table.insert(self.pattern, pattern)
    end
end

function LogSystem:removePattern(pattern)
    if #self.pattern > 0 then
        for i, v in ipairs(self.pattern) do
            if v == pattern then
                table.remove(self.pattern, i)
                break
            end
        end
    end
end

function LogSystem:setFilterPattern(pattern)
    if type(pattern) == "string" then
        self.pattern = string.split(pattern, "|")
    else
        self.pattern = {}
    end
end

function LogSystem:getFilterPattern()
    return self.pattern
end

function LogSystem:log(...)
    if not self.enabled then
        return
    end

    local array = {...}
    for i = 1, table.maxn(array) do
        local v = array[i]
        local vType = type(v)
        if vType == "table" then
            v = tableTostring(v)
        end
        array[i] = tostring(v)
    end

    local printMsg = table.concat(array, " ")

    if self:__checkIsShow(printMsg) then
        print(printMsg)
    end
end

function LogSystem:logWithTab(...)
    if not self.enabled then
        return
    end
    local msgs = {...}
    for i = 1, #msgs - 1 do
        table.insert(msgs, i * 2, " ")
    end
    LogSystem:log(unpack(msgs))
end

function LogSystem:assert(cond, ...)
    if not self.enabled then
        return
    end

    if not cond then
        self:log(...)
        error()
    end
    return cond
end

function LogSystem:attach(prefix, object)
    local Decorator = require("app.Decorator")
    Decorator:replaceAll(
        object,
        function(funcName, func, ...)
            self:logWithTab(prefix, "开始调用方法：", funcName, func, ...)

            local params = {func(...)}

            self:logWithTab(prefix, "结束调用方法：", funcName, "return", params)

            return unpack(params)
        end
    )
end

function LogSystem:__checkIsShow(printMsg)
    if #self.pattern <= 0 then
        return true
    end

    if type(printMsg) == "string" then
        for _, v in ipairs(self.pattern) do
            if v ~= "" and string.find(printMsg, v) ~= nil then
                return true
            end
        end
    end
    return false
end

if WConfig then
    if WConfig["日志系统"] == true then
        LogSystem:setEnabled(true)
    else
        LogSystem:setEnabled(false)
    end

    local logModules = WConfig.logManager

    for k, v in pairs(logModules) do
        switch(
            k,
            {
                ["战斗日志"] = function()
                    if v == true then
                        LogSystem:addPattern("FightLog")
                    end
                end,
                ["战斗BUFF日志"] = function()
                    if v == true then
                        LogSystem:addPattern("增益日志")
                    end
                end,
                ["日志上传"] = function()
                    if v == true then
                        LogSystem:addPattern("Record Log")
                    end
                end,
                default = function() 
                    if v== true then
                        LogSystem:addPattern(k)
                    end
                end
            }
        )
    end
end

return LogSystem
00000000