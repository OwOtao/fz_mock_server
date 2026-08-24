local createPairs = require("third.functions.CreatePairs")

local function interface(className, body)
    local class = body

    -- 自定义遍历方法
    class.__pairs = function(tb)
        return createPairs(tb, {__isInterface = true, __pairs = true})
    end

    class.__isInterface = true
    return class
end

return interface
000000000000000