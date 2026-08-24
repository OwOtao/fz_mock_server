local Decorator = require("app.Decorator")

--@desc tb -> interface. 返回后的代理只能直接调用interface中存在的方法
local function tableImplement(tb, interface)
    local proxy = {}
    local methods = {}

    for k, v in pairs(interface) do
        if type(v) == "function" then
            methods[k] = v
        end
    end

    Decorator:replaceAll(
        methods,
        function(funcName, func, ...)
            -- 获取实例对象
            local obj = select(1, ...)

            -- 判断是否为代理, 代理只能调用b中的方法
            if obj == proxy then
                -- 将实例对象替换为a
                local params = {...}
                params[1] = tb
                return tb[funcName](unpack(params))
            elseif obj == tb then
                -- 如果对象已经为a说明是内部调用, 直接调用a中方法
                return tb[funcName](...)
            else
                -- 其他调用情况
                return func(...)
            end
        end
    )

    return setmetatable(
        proxy,
        {
            __index = function(_, key)
                return methods[key]
            end
        }
    )
end

return tableImplement
0000000000000