setfenv(1, cc.exports)


local function getTime()
    return socket.gettime()
end

-- 性能分析
local performanceAnalysisTable = {}
local performanceAnalysis_totalDuration = 0
local performanceAnalysis_totalTimes = 0
local performanceAnalysis_depth = 0
local function performanceAnalysis_sortFunc(a, b)
    return a.sortValue > b.sortValue
end

function PerformanceAnalysis(name, func)
    
    
    performanceAnalysis_depth = performanceAnalysis_depth + 1
    
    local startTime = getTime()
    
    local retParams = {func()}
    
    local endTime = getTime()
    local duration = endTime - startTime
    if performanceAnalysisTable[name] == nil then
        performanceAnalysisTable[name] = {elapse = 0, times = 0}
    end
    if performanceAnalysis_depth == 1 then
        performanceAnalysis_totalDuration = performanceAnalysis_totalDuration + duration
        performanceAnalysis_totalTimes = performanceAnalysis_totalTimes + 1
    end
    performanceAnalysisTable[name].elapse = performanceAnalysisTable[name].elapse + duration
    performanceAnalysisTable[name].times = performanceAnalysisTable[name].times + 1
    performanceAnalysis_depth = performanceAnalysis_depth - 1
    
    
    return unpack(retParams)
end
-- function PerformanceAnalysis_printLog()
--     table.sort(performanceAnalysisTable, performanceAnalysis_sortFunc)
--     print("性能分析:")
--     print("总共耗时: "..performanceAnalysis_totalDuration)
--     for k,v in pairs(performanceAnalysisTable) do
--         print(k..": 耗时 "..tostring(v)..", 站总时间的: "..tostring(v/performanceAnalysis_totalDuration * 100).."%")
--     end
-- end
function PerformanceAnalysis_inner(name, func, ...)
    performanceAnalysis_depth = performanceAnalysis_depth + 1
    
    local startTime = getTime()
    func(...)
    local endTime = getTime()
    local duration = endTime - startTime
    if performanceAnalysisTable[name] == nil then
        performanceAnalysisTable[name] = 0
    end
    if performanceAnalysis_depth == 1 then
        performanceAnalysis_totalDuration = performanceAnalysis_totalDuration + duration
    end
    performanceAnalysisTable[name] = performanceAnalysisTable[name] + duration
    performanceAnalysis_depth = performanceAnalysis_depth - 1
end
function PerformanceAnalysis_printLog()
    local sortList = {}
    for k, v in pairs(performanceAnalysisTable) do
        local times = v.times
        local elapse = v.elapse
        local avgElapse = elapse / times
        local avgPercent = (elapse / times) / (performanceAnalysis_totalDuration / performanceAnalysis_totalTimes) * 100
        table.insert(sortList, {sortValue = avgElapse, name = k, elapse = v.elapse, times = v.times, avgElapse = avgElapse, avgPercent = avgPercent})
    end
    table.sort(sortList, performanceAnalysis_sortFunc)
    print("性能分析:")
    print("总共耗时: " .. performanceAnalysis_totalDuration)
    for i = 1, #sortList do
        local k = sortList[i].name
        local elapse = sortList[i].elapse
        local times = sortList[i].times
        local avgElapse = string.format("%.2e", sortList[i].avgElapse)
        local avgPercent = string.format("%3d", sortList[i].avgPercent)
        
        print(k .. ":")
        print("执行次数: " .. string.format("%5d", times) .. ", 每次平均耗时: " .. avgElapse .. ", 总耗时: " .. string.format("%.2e", elapse) .. ", 平均每次占总时间的：" .. avgPercent .. "%, 占总时间的: " .. string.format("%3d", elapse / performanceAnalysis_totalDuration * 100) .. "%")
    end
-- for k,v in pairs(performanceAnalysisTable) do
--     print(k..": 耗时 "..tostring(v)..", 站总时间的: "..tostring(v/performanceAnalysis_totalDuration * 100).."%")
-- end
end
00000000000000