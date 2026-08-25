local LiLianTaskHelper = {}
local TaskRes = require("script.others.Activetask")
local ExperienceTaskRes = require("script.others.Experiencetask")

local ACTIVE_TASK_KEY = "主动任务"
local EXPERIENCE_TASK_KEY = "历练任务"
local OLD_SUFFIX = "old"
local NEW_SUFFIX = "new"
local OLD_CONFIG_VERSION = 0
local NEW_CONFIG_VERSION = 1
local DEFAULT_SWITCH_TIME_DATE = "20260720"

local function getSwitchTimeDate()
    if Game:isTesting() then
        local timeDate = WConfig and WConfig["主动历练任务版本切换时间"]
        if timeDate then
            return tostring(timeDate)
        end
    end

    return DEFAULT_SWITCH_TIME_DATE
end

local function getSwitchTime()
    return Helper:getTimeStampWithStringDate(getSwitchTimeDate(), 0)
end

local function normalizeConfigVersion(confVer)
    if confVer == nil then
        return nil
    end

    local versionNumber = tonumber(confVer)

    if confVer == OLD_SUFFIX or versionNumber == OLD_CONFIG_VERSION then
        return OLD_CONFIG_VERSION
    end

    if confVer == NEW_SUFFIX or versionNumber == NEW_CONFIG_VERSION then
        return NEW_CONFIG_VERSION
    end

    error("LiLianTaskHelper 配置版本不存在，confVer:"..tostring(confVer))
end

local function getConfigSuffix(confVer)
    local version = normalizeConfigVersion(confVer)

    if version == OLD_CONFIG_VERSION then
        return OLD_SUFFIX
    end

    if version == NEW_CONFIG_VERSION then
        return NEW_SUFFIX
    end

    local time = GetTime()
    return time < getSwitchTime() and OLD_SUFFIX or NEW_SUFFIX
end

local function getDynamicConfigTable(res, configKey, desc, confVer)
    local suffix = getConfigSuffix(confVer)
    local key = configKey .. suffix

    return assert(res[key], desc .. " " .. suffix .. "配置不存在")
end

local function findTaskConfigByTaskId(taskList, taskId)
    for k, task in pairs(taskList) do
        if task.taskId == taskId then
            return task
        end
    end

    error("LiLianTaskHelper:getTaskConfigInfo 任务id未找到，taskId:"..tostring(taskId))
end

local function mergeConfig(formalConfig, dynamicConfig)
    local config = {}

    for k, v in pairs(formalConfig) do
        config[k] = v
    end

    for k, v in pairs(dynamicConfig) do
        config[k] = v
    end

    return config
end

local function findDynamicTaskConfig(taskList, formalTask, taskId)
    local jobId = formalTask.jobid

    if jobId ~= nil then
        local task = taskList[tostring(jobId)] or taskList[jobId]
        if task then
            return task
        end

        for k, task in pairs(taskList) do
            if tostring(task.jobid) == tostring(jobId) then
                return task
            end
        end
    end

    for k, task in pairs(taskList) do
        if task.taskId == taskId then
            return task
        end
    end

    error("LiLianTaskHelper:getTaskConfigInfo 动态配置未找到，taskId:"..tostring(taskId)..", jobid:"..tostring(jobId))
end

local function findExperienceTaskConfigByIndex(taskList, taskIndex)
    local key = tostring(taskIndex)
    local task = taskList[key]

    if task then
        return task
    end

    error("LiLianTaskHelper:getExperienceTaskConfigInfo 配置索引未找到，taskIndex:"..tostring(taskIndex))
end

local function findDynamicExperienceTaskConfig(taskList, formalTask)
    for k, task in pairs(taskList) do
        if tostring(task.tasklevel) == tostring(formalTask.tasklevel) and tostring(task.jianghujindu) == tostring(formalTask.jianghujindu) then
            return task
        end
    end

    error("LiLianTaskHelper:getExperienceTaskConfigInfo 动态配置未找到，tasklevel:"..tostring(formalTask.tasklevel)..", jianghujindu:"..tostring(formalTask.jianghujindu))
end

local function getActiveTaskConfigTable(confVer)
    return getDynamicConfigTable(TaskRes, ACTIVE_TASK_KEY, "主动任务", confVer)
end

local function getFormalActiveTaskConfigTable()
    return assert(TaskRes[ACTIVE_TASK_KEY], "主动任务 正式配置不存在")
end

local function getExperienceTaskConfig(confVer)
    return getDynamicConfigTable(ExperienceTaskRes, EXPERIENCE_TASK_KEY, "历练任务", confVer)
end

local function getFormalExperienceTaskConfig()
    return assert(ExperienceTaskRes[EXPERIENCE_TASK_KEY], "历练任务 正式配置不存在")
end

function LiLianTaskHelper:getSwitchTime()
    return getSwitchTime()
end

function LiLianTaskHelper:getConfigVersionByTime(time)
    if time == nil then
        time = GetTime()
    end

    time = tonumber(time) or GetTime()

    if time < getSwitchTime() then
        return OLD_CONFIG_VERSION
    end

    return NEW_CONFIG_VERSION
end

function LiLianTaskHelper:getRoleTaskConfigVersion(roleTask)
    if roleTask == nil then
        return self:getConfigVersionByTime(GetTime())
    end

    local state = roleTask.state
    local isActiveState = state == TASK_STATE_ACCEPT or state == TASK_STATE_TO_SUBMIT or state == TASK_STATE_DISPATCH

    if isActiveState then
        if roleTask.aConfVer ~= nil then
            return normalizeConfigVersion(roleTask.aConfVer)
        end

        local startTime = tonumber(roleTask.startTime)

        if startTime == nil or startTime == 0 then
            return OLD_CONFIG_VERSION
        end

        return self:getConfigVersionByTime(startTime)
    end

    return self:getConfigVersionByTime(GetTime())
end

function LiLianTaskHelper:getExperienceTaskConfigInfo(taskIndex, confVer)
    local formalTask = findExperienceTaskConfigByIndex(getFormalExperienceTaskConfig(), taskIndex)
    local dynamicTask = findDynamicExperienceTaskConfig(getExperienceTaskConfig(confVer), formalTask)

    return mergeConfig(formalTask, dynamicTask)
end
--[[
    @desc: 获取任务完成时银票奖励
    author:tanqinjian
    time:2026-06-25 14:14:49
    --@countTimes:第几次
	--@taskConfig: 任务配置
    @return:
]]
function LiLianTaskHelper:getYinPiaoCount(countTimes, taskConfig)
-- jobreward7TaskTimes格式：任务第N次#任务第N次；jobreward7格式：银票奖励值#银票奖励值
-- 银票奖励值支持配置公式(古寺失窃奖励的银票就是公式算出来的)
-- 公式支持 fy 福缘，最大值、最小值
    local taskTimes = string.split(taskConfig.jobreward7TaskTimes, "#")
    local countInfo = string.split(taskConfig.jobreward7, "#")

    for i = 1, #taskTimes, 1 do
        if countTimes == tonumber(taskTimes[i]) then
            if tonumber(countInfo[i]) then
                return tonumber(countInfo[i])
            else
                local role = User:getRole()
	            local luck = role:getFinalAttr("luck")
                local value = Helper:GetValueFromScript(countInfo[i], {fy = luck, min = math.min, max = math.max})
                return math.floor(value)
            end
        end
    end

    return 0
end

function LiLianTaskHelper:getTaskConfigInfo(taskId, confVer)
    local formalTask = findTaskConfigByTaskId(getFormalActiveTaskConfigTable(), taskId)
    local dynamicTask = findDynamicTaskConfig(getActiveTaskConfigTable(confVer), formalTask, taskId)

    return mergeConfig(formalTask, dynamicTask)
end

return LiLianTaskHelper 
0000000000000000