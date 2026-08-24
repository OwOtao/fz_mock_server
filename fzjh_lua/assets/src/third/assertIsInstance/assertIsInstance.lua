--
local function getFuncParamsN(innerFunc)
    local n = -1

    -- 保存之前的hook
    local oldHookParams = {debug.gethook()}
    -- print("oldHookParams", unpack(oldHookParams))

    -- 设置钩子用于获取函数参数个数
    debug.sethook(
        function(...)
            local info = debug.getinfo(2)
            if info.name == "innerFunc" then
                n = info.nparams
                error()
            end
        end,
        "c"
    )

    -- 调用以获取参数列表
    pcall(
        function()
            innerFunc()
        end
    )

    -- 还原以前的hook
    debug.sethook(unpack(oldHookParams))

    return n
end

local function isInstance(a, b)
    local ok = true
    local errmsg = ""
    for k, v in pairs(b) do
        if type(v) == "function" then
            if type(a[k]) == "function" then
                local lc = getFuncParamsN(v)
                local rc = getFuncParamsN(a[k])
                if lc == rc then
                elseif lc == -1 or rc == -1 then
                    print("isInstance() error, lc == -1 or rc == -1")
                else
                    errmsg = errmsg .. "\n方法参数不一致:" .. k .. "现有" .. tostring(rc) .. "个参数" .. ", 应该有" .. tostring(lc) .. "个参数" .. "\n"
                    ok = false
                end
            else
                errmsg = errmsg .. "\n找不到方法:" .. k .. "\n"
                ok = false
            end
        end
    end

    return ok, errmsg
end

local function assertIsInstance(a, ...)
    -- windows下面才做接口检测
    if device == nil or device.platform == "windows" then
        for i = 1, select("#", ...) do
            local ok, errmsg = isInstance(a, select(i, ...))
            assert(ok, errmsg)
        end
    end
    return a
end

-- local b = {
--     getMethod = function(a, b, c)
--     end,
--     setMethod = function()
--     end
-- }

-- local a = {
--     getMethod = function(a, b)
--     end,
--     setMethod = function()
--     end
-- }

-- assertIsInstance(a, b)

return assertIsInstance
0000000000000000