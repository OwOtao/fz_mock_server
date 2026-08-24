local hangUpTaskConstConfig = requireWithEncrypt("script.HangUpTask.hangUpTaskConst")["挂机通用参数"]

local TaskConst = {}

TaskConst.HangUpTaskType = {
    CLOSE = 0,
    --@desc 已满足解锁条件，但不可用
    OPEN_DISABLE = 1,
    --@desc 挂机状态
    HangUp = 2,
    --@desc 打工状态
    Work = 3
}

TaskConst.HangUpTaskStatus = {}

--@desc 挂机类型任务状态
TaskConst.HangUpTaskStatus.HangUpStatus = {
    Idle = 0,
    --@desc 挂机中
    HangUp = 1
}

--@desc 打工（点击）类型任务状态
TaskConst.HangUpTaskStatus.WorkStatus = {
    Idle = 0,
    Cooldown = 1,
    DailyMax = 2
}

TaskConst.MaxHangUpTime = 72 * 3600

TaskConst.HangUpTaskTextType = {
    -- 1=开始挂机、点击开始挂机后，出现的文本
    StartHangUp = 1,
    -- 2=挂机中，玩家挂机中定期出现的文本内容，在停止挂机前，会每隔%d秒抽取此类型文本显示。
    HangUping = 2,
    -- 3=手动停止挂机，玩家手动点击停止挂机后，出现的文本。
    ManualStopHangUp = 3,
    -- 4=自动停止挂机，满足条件自动停止挂机后，出现的对应文本。
    AutoStopHangUp = 4,
    -- 5=点击任务文本，点击任务后出现的文本。
    WorkTask = 5,
    -- 6=低收益文本，若玩家任务变成低收益任务后，需要则外增加播放此文本。
    WorkTaskLess = 6,
    -- 7=任务未冷却，任务处于冷却时，点击播放的文本。
    CooldownWorkTask = 7
}

function TaskConst:getHangUpTaskConfigValue(key)
    if not hangUpTaskConstConfig[key] then
        error("挂机通用参数未找到配置 id：" .. key)
    end
    return hangUpTaskConstConfig[key].content
end

function TaskConst:getInheritAddition(count)
    local content = self:getHangUpTaskConfigValue("inheritCountAdd")

    local splitList = string.split(content, "|")

    local additionMaps = {}
    for i, v in ipairs(splitList) do
        local splitContent = string.split(v, "#")

        local inheritCount = tostring(splitContent[1])

        local additionValue = tonumber(splitContent[2])

        additionMaps[inheritCount] = additionValue
    end

    return additionMaps[tostring(count)]
end

return TaskConst
000