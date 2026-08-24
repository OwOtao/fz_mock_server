local function PairsCoroutine(func, self, arg1, arg2, arg3, arg4, arg5)
    local cor = coroutine.create(func)

    return function()
        local canMoveNext, k, v = coroutine.resume(cor, self, arg1, arg2, arg3, arg4, arg5)

        if canMoveNext == false then
            debug.traceback(cor)
            return nil
        end

        return k, v
    end
end

return PairsCoroutine
000000000000