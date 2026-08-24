local createPairs = require("third.functions.CreatePairs")

local function abstract(className, interfaces, body)
    assert(type(interfaces) == "table")
    assert(type(body) == "table")

    local class = {}

    -- 自定义遍历方法
    class.__pairs = function(tb)
        return createPairs(tb, {__isAbstract = true, __interface = true, __body = true, __pairs = true})
    end

    class.__isAbstract = true

    class.__interfaces = interfaces
    class.__body = body

    return class
end

return abstract
000000