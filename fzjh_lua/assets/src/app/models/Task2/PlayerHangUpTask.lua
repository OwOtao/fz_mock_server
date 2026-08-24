local newClass = require("third.class.NewClass")

local TaskConst = require("app.models.Task2.TaskConst")

local TaskRewardFactory = require("app.models.Task2.TaskRewardFactory")

local PlayerHangUpTask = {
    __taskRes = nil,
    __player = nil,
    __hangUpRewards = {},
    __currType = TaskConst.HangUpTaskType.CLOSE,
    __status = TaskConst.HangUpTaskStatus.HangUpStatus.Idle,
    __dailyWork = 0,
    --@desc 实际开始时间
    __startTime = 0,
    --@desc 预计最大结束时间
    __finishTime = 0,
    --@desc 开始挂机时的福缘（总福缘）
    __luck = -1,
    --@desc 开始挂机时的功夫值
    __kongfu = -1,
    --@desc 是否使用雅士
    __isUseYaShi = 0,
    --@desc 挂机后用的传承次数
    __inheritAddition = 0,
    __shiSiZhenValue = 0,
    --@desc 额外福缘值（辅助作弊检测，为了区分更新前后差异，默认为空）
    __extraLuck = nil
}

function PlayerHangUpTask:create(player, task)
    local p = PlayerHangUpTask.new()
    p:__init(player, task)
    return p
end

function PlayerHangUpTask:__init(player, task)
    --@RefType [src.app.models.Task2.HangUpTask#HangUpTask]
    self.__taskRes = task

    if self.__taskRes:getTaskType() == 0 then
        self.__currType = TaskConst.HangUpTaskType.Work
        self.__status = TaskConst.HangUpTaskStatus.WorkStatus.Idle
    end

    self.__player = player

    self:__loadData()

    assert(tonumber(self.__taskRes:getId()) < 100000, "任务ID不可大于100000，会导致UI层按钮排序算法出问题，如需使用该id，请改动UI层排序算法。")
end

function PlayerHangUpTask:__loadData()
    local playerTaskData = self.__player:getHangUpTaskData(self.__taskRes:getId())

    if MapIsEmpty(playerTaskData) then
        return
    end

    self:setCurrType(playerTaskData.currType)
    self:setStatus(playerTaskData.status)

    if playerTaskData.startTime ~= nil then
        self:setStartTime(playerTaskData.startTime)
    end

    if playerTaskData.finishTime ~= nil then
        self:setFinishTime(playerTaskData.finishTime)
    end

    if playerTaskData.dCount ~= nil then
        self:setDailyWork(playerTaskData.dCount)
    end

    if playerTaskData.luck ~= nil then
        self:setLuck(playerTaskData.luck)
    end

    if playerTaskData.kongfu ~= nil then
        self:setKongfu(playerTaskData.kongfu)
    end

    if playerTaskData.shiSiZhenValue ~= nil then
        self:setShiSiZhenValue(playerTaskData.shiSiZhenValue)
    end

    if playerTaskData.isUseYaShi ~= nil and type(playerTaskData.isUseYaShi) == "number" then
        self.__isUseYaShi = playerTaskData.isUseYaShi
    end

    if playerTaskData.extraLuck ~= nil then
        self:setExtraLuck(playerTaskData.extraLuck)
    end
end

function PlayerHangUpTask:saveData()
    self.__player:saveHangUpTaskData(
        self:getId(),
        {
            currType = self.__currType,
            status = self.__status,
            startTime = self.__startTime,
            finishTime = self.__finishTime,
            dCount = self.__dailyWork,
            isUseYaShi = self.__isUseYaShi,
            luck = self.__luck,
            kongfu = self.__kongfu,
            shiSiZhenValue = self.__shiSiZhenValue,
            extraLuck = self.__extraLuck
        }
    )
end

function PlayerHangUpTask:getId()
    return self.__taskRes:getId()
end

function PlayerHangUpTask:getName()
    return self.__taskRes:getTaskName()
end

function PlayerHangUpTask:setUseYaShi(bool)
    if bool then
        self.__isUseYaShi = 1
    else
        self.__isUseYaShi = 0
    end
end

function PlayerHangUpTask:isUseYaShi()
    if self.__isUseYaShi == 1 then
        return true
    elseif self.__isUseYaShi == 0 then
        return false
    end

    error("PlayerHangUpTask:isUseYaShi 数据异常，检查代码 ： " .. self.__isUseYaShi)
end

function PlayerHangUpTask:setLuck(value)
    self.__luck = value
end

function PlayerHangUpTask:getLuck()
    return self.__luck
end

function PlayerHangUpTask:setExtraLuck(value)
    self.__extraLuck = value
end

function PlayerHangUpTask:getExtraLuck()
    return self.__extraLuck
end

function PlayerHangUpTask:setKongfu(value)
    self.__kongfu = value
end

function PlayerHangUpTask:getKongfu()
    return self.__kongfu
end

function PlayerHangUpTask:setStartTime(time)
    self.__startTime = time
end

function PlayerHangUpTask:getStartTime()
    return self.__startTime
end

function PlayerHangUpTask:setFinishTime(time)
    self.__finishTime = time
end

function PlayerHangUpTask:getFinishTime()
    return self.__finishTime
end

function PlayerHangUpTask:setShiSiZhenValue(value)
    self.__shiSiZhenValue = value
end

function PlayerHangUpTask:getShiSiZhenValue()
    return self.__shiSiZhenValue
end

function PlayerHangUpTask:getInheritAddition()
    local playerInheritCount = self.__player:getAttr("inheritCount")

    local inheritAddition = TaskConst:getInheritAddition(playerInheritCount)

    return inheritAddition
end

function PlayerHangUpTask:getHangUpRewardClassId()
    return self.__taskRes:getAutoAwardClass()
end

function PlayerHangUpTask:getTaskType()
    return self.__taskRes:getTaskType()
end

function PlayerHangUpTask:setCurrType(type)
    if self.__taskRes:getTaskType() == 0 and type == TaskConst.HangUpTaskType.HangUp then
        error("PlayerHangUpTask:setCurrType 挂机任务类型为0，当前类型不可设置为挂机，检查代码！")
    end

    self.__currType = type
end

function PlayerHangUpTask:getCurrType()
    return self.__currType
end

function PlayerHangUpTask:getStatus()
    return self.__status
end

function PlayerHangUpTask:setStatus(status)
    self.__status = status
end

function PlayerHangUpTask:getDailyWorkLimit()
    return self.__taskRes:getClickLimit()
end

function PlayerHangUpTask:setDailyWork(num)
    self.__dailyWork = num
end

function PlayerHangUpTask:getWorkCD()
    return self.__taskRes:getClickCD()
end

function PlayerHangUpTask:getDailyWork()
    return self.__dailyWork
end

function PlayerHangUpTask:isDailyWorkMax()
    return self.__dailyWork >= self.__taskRes:getClickLimit()
end

--@desc: 检测是否满足解锁条件
--@author:Seven
--@time:2021-09-17 17:13:37
function PlayerHangUpTask:checkTheConditionsAreMet()
    if self:__isUnlockExp() and self:__isUnlockNeedMap() then
        return true
    end
end

function PlayerHangUpTask:isUnlock()
    if self:getCurrType() == TaskConst.HangUpTaskType.CLOSE or self:getCurrType() == TaskConst.HangUpTaskType.OPEN_DISABLE then
        return false
    end

    return true
end

function PlayerHangUpTask:__isUnlockExp()
    if self.__player:getExp() <= self.__taskRes:getUnlockNeedRoleExp() then
        return false
    end
    return true
end

function PlayerHangUpTask:__isUnlockNeedMap()
    if self.__taskRes:getUnlockNeedMap() ~= nil and not self.__player:isMapCompleted(self.__taskRes:getUnlockNeedMap()) then
        return false
    end

    return true
end

function PlayerHangUpTask:getUnlockStrs()
    local strList = {}

    if not self:__isUnlockNeedMap() then
        local mapName
        mapName = Map:getDefaultMapById(self.__taskRes:getUnlockNeedMap()).name
        table.insert(strList, string.format("需通关章节%s", mapName))
    end

    if not self:__isUnlockExp() then
        table.insert(strList, string.format("经验值 > %d", self.__taskRes:getUnlockNeedRoleExp()))
    end

    return strList
end

function PlayerHangUpTask:getWorkText()
    local currPlayerExp = self.__player:getExp()

    local taskType
    if currPlayerExp > self.__taskRes:getTransformLowAwardExp() then
        taskType = TaskConst.HangUpTaskTextType.WorkTaskLess
    else
        taskType = TaskConst.HangUpTaskTextType.WorkTask
    end

    local TaskTextFactory = require("app.models.Task2.TaskTextFactory")
    local textClass = TaskTextFactory:getRandomHangUpTaskText(self:getId(), taskType)

    return textClass:getShowDesc()
end

function PlayerHangUpTask:getCDText()
    local TaskTextFactory = require("app.models.Task2.TaskTextFactory")
    local textClass = TaskTextFactory:getRandomHangUpTaskText(self:getId(), TaskConst.HangUpTaskTextType.CooldownWorkTask)

    return textClass:getShowDesc()
end

function PlayerHangUpTask:getWorkRewards()
    local list = TaskRewardFactory:createPlayerHangUpRewards(self.__taskRes:getClickAwardClass())

    for i = 1, #list do
        --@RefType [src.app.models.Task2.PlayerHangUpTaskReward#PlayerHangUpTaskReward]
        local reward = list[i]

        reward:setKongfu(self.__player:getKongfu())

        reward:setLuck(self.__player:getFinalAttr("luck"))

        if self.__player:isYaShi() then
            reward:setYaShiAdditionValue(TaskConst:getHangUpTaskConfigValue("yaShiAwardExpAdd"))
        end
    end

    table.sort(
        list,
        function(a, b)
            return tonumber(a:getId()) < tonumber(b:getId())
        end
    )

    return list
end

return newClass("PlayerHangUpTask", {}, PlayerHangUpTask)
000000000