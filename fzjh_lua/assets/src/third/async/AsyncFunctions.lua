local inherit = require("third.inherit.inherit")
local AsyncFunction = require("third.async.AsyncFunction")

local AsyncFunctions = {}

function AsyncFunctions:create(funcs)
    local obj = inherit({}, AsyncFunctions, AsyncFunction)
    AsyncFunction.init(
        obj,
        function(thread)
            local results = {}
            for i, func in ipairs(funcs) do
                local result = AsyncFunction:create(func):await()
                table.insert(results, result or "nil")
            end
            thread:finish(results)
        end
    )
    return obj
end

return AsyncFunctions
0000000000000000