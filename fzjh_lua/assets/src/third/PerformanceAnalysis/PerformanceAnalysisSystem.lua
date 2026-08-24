-- local function print()
-- end

local PerformanceAnalysisSystem = {}

local l_ipairs = ipairs
local l_pairs = pairs

function PerformanceAnalysisSystem:create()
    local p = setmetatable({}, {__index = PerformanceAnalysisSystem})
    p:init()
    return p
end

function PerformanceAnalysisSystem:init()
    self.__items = {}
    self.__stack = {}
    self.__lookup = {}
end

local ignores = {
    printInfo = true,
    hook = true
}

local function getKey(info)
    return info.source .. "." .. info.linedefined .. "." .. info.name
end

function PerformanceAnalysisSystem:hook()
    self.__hookParams = {debug.gethook()}
    debug.sethook(
        function(debugType, ...)
            if debugType == "call" then
                local info = debug.getinfo(2)

                if ignores[info.name] then
                    return
                end

                if info.name == nil then
                    info.name = "nil"
                end

                local infoKey = getKey(info)

                if self.__lookup[infoKey] == nil then
                    self.__lookup[infoKey] = info
                    table.insert(self.__stack, info)
                    info.time = os.clock()
                end
            elseif debugType == "return" then
                local time = os.clock()
                local info = debug.getinfo(2)

                if ignores[info.name] then
                    return
                end

                if info.name == nil then
                    info.name = "nil"
                end

                local infoKey = getKey(info)


                for i = #self.__stack, 1, -1 do
                    local last = self.__stack[i]
                    local lastInfoKey = getKey(last)

                    if lastInfoKey == infoKey then
                        -- print("return", info.name, infoKey)
                        for j = #self.__stack, i, -1 do
                            table.remove(self.__stack, j)
                        end
                        self.__lookup[lastInfoKey] = nil

                        -- 记录时间
                        local currOnceDuration = (time - last.time)
                        local item = self:__getItem(infoKey)
                        item.name = infoKey
                        item.info = info
                        item.times = item.times + 1
                        item.totalTime = item.totalTime + (currOnceDuration)
                        item.minOnceDuration = math.min(item.minOnceDuration, currOnceDuration)
                        item.maxOnceDuration = math.max(item.maxOnceDuration, currOnceDuration)

                        -- print(item.name, item.totalTime)
                        break
                    end
                end
            end
        end,
        "cr"
    )
end

function PerformanceAnalysisSystem:unhook()
    if self.__hookParams then
        debug.sethook(unpack(self.__hookParams))
        self.__hookParams = nil
    end
end

function PerformanceAnalysisSystem:printInfo(sortId)
    if sortId == nil then
        sortId = "onceDuration"
    end

    local items = {}
    for _, item in l_pairs(self.__items) do
        -- 平均每次时间
        if item.times > 2 then
            item.onceDuration = (item.totalTime - item.maxOnceDuration - item.minOnceDuration) / (item.times - 2)
        else
            item.onceDuration = item.totalTime / item.times
        end

        table.insert(items, item)
    end

    table.sort(
        items,
        function(a, b)
            return a[sortId] > b[sortId]
        end
    )

    print("总时间 ," .. "调用次数 ," .. "平均每次时间 ," .. "最小每次时间 ," .. "最大每次时间 ," .. "函数名")
    for _, item in l_ipairs(items) do
        local name = item.name
        if string.find(name, "\n") and string.find(name, "GetValueFromScript") then
            name = "GetValueFromScript"
        end
        print(string.format("%f\t%d\t%f\t%f\t%f\t%s", item.totalTime, item.times, item.onceDuration, item.minOnceDuration, item.maxOnceDuration, name))
    end
end

function PerformanceAnalysisSystem:__getItem(name)
    if self.__items[name] == nil then
        self.__items[name] = {name = name, totalTime = 0, times = 0, minOnceDuration = 99999, maxOnceDuration = 0}
        return self.__items[name]
    end
    return self.__items[name]
end

return PerformanceAnalysisSystem
0