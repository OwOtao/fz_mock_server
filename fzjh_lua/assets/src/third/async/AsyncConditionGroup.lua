local inherit = require("third.inherit.inherit")
local AsyncFunction = require("third.async.AsyncFunction")

local AsyncConditionGroup = {}

function AsyncConditionGroup:create(relation, conditions)
    assert(relation == "and" or relation == "or", "relation must be 'and' or 'or'")

    local obj = inherit({}, AsyncConditionGroup, AsyncFunction)
    AsyncFunction.init(
        obj,
        function(thread)
            for i, condition in ipairs(conditions) do
                local asyncFunction = AsyncFunction:create(condition)
                local isFinish, result = asyncFunction:tryGetResult()

                -- 等待异步方法结束
                while isFinish == false do
                    isFinish, result = asyncFunction:tryGetResult()
                    thread:yield()
                end

                -- 结果必须为boolean
                assert(type(result) == "boolean", "AsyncConditionGroup:create: condition must be boolean")

                -- 结束后判断
                if relation == "and" then
                    if result == false then
                        thread:finish(false)
                    end
                elseif relation == "or" then
                    if result == true then
                        thread:finish(true)
                    end
                end
            end

            if relation == "and" then
                thread:finish(true)
            elseif relation == "or" then
                thread:finish(false)
            end
        end
    )
    return obj
end

return AsyncConditionGroup
00