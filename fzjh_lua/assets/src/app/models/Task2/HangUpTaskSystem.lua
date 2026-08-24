local newClass = require("third.class.NewClass")

local TaskConst = require("app.models.Task2.TaskConst")

local TaskFactory = require("app.models.Task2.TaskFactory")

local RoleTaskControllor = require("app.views.layer.RoleLayer.RoleTaskControllor")

local AsyncFunction = require("third.async.AsyncFunction")

local HangUpTaskSystem = {}

function HangUpTaskSystem:create(player)
    local p = HangUpTaskSystem.new()
    p:__init(player)
    return p
end

function HangUpTaskSystem:__init(player)
    self.__isNotSerializable = true

    self.__player = player

    self.__taskList = TaskFactory:createPlayerHangUpTasks(self.__player)

    self.__currHangUpTaskId = self.__player:loadCurrHangUpTaskId()

    self.__hangUpVersion = self.__player:loadHangUpVersion()

    self.__isStoppingHangUp = false

    table.sort(
        self.__taskList,
        function(a, b)
            return tonumber(a:getId()) < tonumber(b:getId())
        end
    )

    self:updateTaskTypeAndStatus()
end

function HangUpTaskSystem:getVersion()
    return self.__hangUpVersion
end

function HangUpTaskSystem:updateTaskTypeAndStatus()
    --@RefType [src.app.models.Task2.PlayerHangUpTask#PlayerHangUpTask]
    local preTask = nil
    for _, task in ipairs(self.__taskList) do
        if task:checkTheConditionsAreMet() and task:getCurrType() == TaskConst.HangUpTaskType.CLOSE then
            if task:getTaskType() == 0 then
                task:setCurrType(TaskConst.HangUpTaskType.Work)
                task:setStatus(TaskConst.HangUpTaskStatus.WorkStatus.Idle)
            elseif task:getTaskType() == 1 then
                if not self:isHangUping() then
                    task:setCurrType(TaskConst.HangUpTaskType.HangUp)
                    if preTask ~= nil then
                        if preTask:getCurrType() == TaskConst.HangUpTaskType.HangUp and preTask:getStatus() == TaskConst.HangUpTaskStatus.HangUpStatus.Idle then
                            preTask:setCurrType(TaskConst.HangUpTaskType.Work)
                            preTask:setStatus(TaskConst.HangUpTaskStatus.WorkStatus.Idle)
                            preTask:setStartTime(0)
                        end
                    end
                else
                    task:setCurrType(TaskConst.HangUpTaskType.OPEN_DISABLE)
                end
            end
        elseif task:getCurrType() == TaskConst.HangUpTaskType.OPEN_DISABLE then
            if not self:isHangUping() then
                task:setCurrType(TaskConst.HangUpTaskType.HangUp)
                task:setStatus(TaskConst.HangUpTaskStatus.HangUpStatus.Idle)
            end

            if preTask ~= nil then
                if preTask:getCurrType() == TaskConst.HangUpTaskType.HangUp then
                    if preTask:getStatus() == TaskConst.HangUpTaskStatus.HangUpStatus.Idle then
                        preTask:setCurrType(TaskConst.HangUpTaskType.Work)
                        preTask:setStatus(TaskConst.HangUpTaskStatus.WorkStatus.Idle)
                        preTask:setStartTime(0)
                    end
                elseif preTask:getCurrType() == TaskConst.HangUpTaskType.OPEN_DISABLE then
                    preTask:setCurrType(TaskConst.HangUpTaskType.Work)
                    preTask:setStatus(TaskConst.HangUpTaskStatus.WorkStatus.Idle)
                    preTask:setStartTime(0)
                end
            end
        elseif task:getCurrType() == TaskConst.HangUpTaskType.HangUp then
            if preTask ~= nil then
                if preTask:getCurrType() == TaskConst.HangUpTaskType.HangUp then
                    if preTask:getStatus() == TaskConst.HangUpTaskStatus.HangUpStatus.Idle then
                        preTask:setCurrType(TaskConst.HangUpTaskType.Work)
                        preTask:setStatus(TaskConst.HangUpTaskStatus.WorkStatus.Idle)
                        preTask:setStartTime(0)
                    end
                elseif preTask:getCurrType() == TaskConst.HangUpTaskType.OPEN_DISABLE then
                    preTask:setCurrType(TaskConst.HangUpTaskType.Work)
                    preTask:setStatus(TaskConst.HangUpTaskStatus.WorkStatus.Idle)
                    preTask:setStartTime(0)
                end
            end
        elseif task:getCurrType() == TaskConst.HangUpTaskType.Work then
            if preTask ~= nil then
                if preTask:getCurrType() == TaskConst.HangUpTaskType.HangUp and preTask:getStatus() == TaskConst.HangUpTaskStatus.HangUpStatus.Idle then
                    preTask:setCurrType(TaskConst.HangUpTaskType.Work)
                    preTask:setStatus(TaskConst.HangUpTaskStatus.WorkStatus.Idle)
                    preTask:setStartTime(0)
                end
            end
        end

        if not task:checkTheConditionsAreMet() then
            task:setCurrType(TaskConst.HangUpTaskType.CLOSE)
            task:setStatus(TaskConst.HangUpTaskStatus.HangUpStatus.Idle)
        end

        preTask = task
    end
end

function HangUpTaskSystem:__saveData()
    self.__player:saveCurrHangUpTaskId(self.__currHangUpTaskId)
    self.__player:saveHangUpVersion(self.__hangUpVersion)
    for _, task in ipairs(self.__taskList) do
        task:saveData()
    end
end

function HangUpTaskSystem:setOutput(output)
    --@RefType [MainTaskPresenter]
    self.__output = output
end

function HangUpTaskSystem:getPlayer()
    return self.__player
end

function HangUpTaskSystem:isHangUping()
    return self.__currHangUpTaskId ~= nil
end

function HangUpTaskSystem:getCurrHangUpTaskId()
    return self.__currHangUpTaskId
end

function HangUpTaskSystem:getHangUpTasks()
    return self.__taskList
end

--@desc 当前是否拥有雅士加成
function HangUpTaskSystem:currIsYaShiAddition()
    return self.__player:isYaShi()
end

--@desc: 获取挂机任务对象
--@author:Seven
--@time:2021-09-07 15:25:33
--@taskId: 任务id
--@return [src.app.models.Task2.PlayerHangUpTask#PlayerHangUpTask]
function HangUpTaskSystem:getHangUpTask(taskId)
    for _, task in ipairs(self.__taskList) do
        if task:getId() == taskId then
            return task
        end
    end

    error("HangUpTaskSystem:getHangUpTask 没有找到挂机任务：" .. taskId)
end

--@desc:
--@author:Seven
--@time:2021-09-09 12:03:00
--@task: [src.app.models.Task2.PlayerHangUpTask#PlayerHangUpTask]
--@taskType: 挂机任务类型
--@status: 挂机任务状态
function HangUpTaskSystem:__changeTaskTypeAndStatus(task, taskType, status)
    task:setCurrType(taskType)
    task:setStatus(status)
end

function HangUpTaskSystem:workForTask(taskId)
    local task = self:getHangUpTask(taskId)

    if task:getCurrType() ~= TaskConst.HangUpTaskType.Work then
        error("当前挂机任务：" .. taskId .. " 类型不为可点击类型，无法点击，检查代码！")
    end

    local currTime = GetTime()

    local preWorkTime = task:getStartTime()

    local daiyWork = task:getDailyWork()
    if Helper:diffWithDate(currTime, preWorkTime) >= 1 then
        daiyWork = 0
    end

    local attrRewardInfo = {}
    local rewards = task:getWorkRewards()
    for i = 1, #rewards do
        --@RefType [src.app.models.Task2.PlayerHangUpTaskReward#PlayerHangUpTaskReward]
        local reward = rewards[i]

        table.insert(
            attrRewardInfo,
            {
                attrName = reward:getRewardAttrName(),
                value = reward:getValue()
            }
        )
    end
    --@desc 记录相关
    local beforeExp = self.__player:getExp()

    local recordReward = {}

    for i = 1, #attrRewardInfo do
        local reward = attrRewardInfo[i]

        recordReward[reward.attrName] = reward.value
    end

    local recordExtra = {
        startExp = beforeExp,
        rewardTime = GetTime()
    }

    if recordReward.exp ~= nil and recordReward.exp > 0 then
        recordExtra.aftExp = beforeExp + recordReward.exp
    end

    HttpManagerEx:recordClickTask(
        taskId,
        recordReward,
        recordExtra,
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    local workText = task:getWorkText()

                    task:setStartTime(currTime)

                    task:setDailyWork(daiyWork + 1)

                    task:setStatus(TaskConst.HangUpTaskStatus.WorkStatus.Cooldown)

                    for i = 1, #attrRewardInfo do
                        local reward = attrRewardInfo[i]

                        self.__player:addAttr(reward.attrName, reward.value)
                    end

                    self:__saveData()

                    self:updateTaskTypeAndStatus()

                    if self.__output then
                        self.__output:hangUpTaskWorded(taskId, workText)
                        for i = 1, #attrRewardInfo do
                            local reward = attrRewardInfo[i]
                            self.__output:popMessage(string.format("获得%s%s", reward.value, Role:getCHAttrName(reward.attrName)))
                        end
                    end

                    return true
                else
                    PopText(errmsg)
                    return false
                end
            else
                PopText(errmsg)
                return false
            end
        end,
        IS_SHOW_WAITING,
        HTTP_MANAGER_RETRY_TYPE_RETRY
    )
end

function HangUpTaskSystem:startHangUpTask(taskId)
    if self.__player:getBuffAttr("xingzhenGuaJi") >= 1 then
        if self.__output then
            self.__output:popMessage("受行针走穴影响，你浑身乏力，想必一段时间内无法再行动了。")
        end
        return
    end

    RoleTaskControllor:clickGuaJiLayer(
        function()
            local task = self:getHangUpTask(taskId)

            if task:getCurrType() ~= TaskConst.HangUpTaskType.HangUp then
                error("开始挂机：" .. taskId .. " 类型不为挂机类型，无法开始挂机，检查代码！")
            end

            local isUseYaShi = self:currIsYaShiAddition()
            local kongfu = self.__player:getKongfu()
            local luck = self.__player:getFinalAttr("luck")
            local extraLuck = luck - self.__player:getAttr("luck")
            local shiSiZhenValue = self.__player:getBuffAttr("xingzhenGuaJiSY")
            local inheritValue = task:getInheritAddition()
            local extra = {
                startExp = self.__player:getExp(),
                luck = luck,
                kongfu = kongfu,
                isUseYaShi = isUseYaShi,
                shiSiZhenValue = shiSiZhenValue,
                inheritAddition = inheritValue,
                extraLuck = extraLuck
            }
            HttpManagerEx:startHangUpTask(
                self.__hangUpVersion,
                taskId,
                extra,
                function(status, errcode, errmsg, data)
                    if status == 200 then
                        if errcode == 0 then
                            SetTime(data.start_time)

                            local currTime = data.start_time

                            task:setStartTime(currTime)

                            task:setKongfu(kongfu)

                            task:setLuck(luck)

                            task:setExtraLuck(extraLuck)

                            task:setUseYaShi(isUseYaShi)

                            task:setShiSiZhenValue(shiSiZhenValue)

                            --@desc 最长挂机时间
                            task:setFinishTime(currTime + TaskConst.MaxHangUpTime)

                            task:setStatus(TaskConst.HangUpTaskStatus.HangUpStatus.HangUp)

                            self.__currHangUpTaskId = taskId

                            self.__hangUpVersion = data.version

                            --@TODO 其余系统判断关联，暂时无法取消
                            self.__player:setRoleCurrState(ROLE_CURR_STATE_GUAJI)

                            self:__saveData()

                            if self.__output then
                                self.__output:startHangUpTask(taskId)
                            end
                        else
                            PopText(errmsg)
                        end
                    else
                        PopText(errmsg)
                    end
                end,
                IS_SHOW_WAITING
            )
        end
    )
end

function HangUpTaskSystem:getCurrExceptRewards(taskId)
    local task = self:getHangUpTask(taskId)
    return task:getCurrExceptRewards()
end

function HangUpTaskSystem:getExceptRewards(taskId)
    local task = self:getHangUpTask(taskId)

    return task:getExceptRewards()
end

function HangUpTaskSystem:__updateTaskCD(task)
    local finishTime = task:getStartTime() + task:getWorkCD()

    local currTime = GetTime()

    local preWorkTime = task:getStartTime()

    local daiyWork = task:getDailyWork()
    if Helper:diffWithDate(currTime, preWorkTime) >= 1 then
        task:setDailyWork(0)
    end

    if finishTime <= currTime then
        if task:isDailyWorkMax() then
            task:setStatus(TaskConst.HangUpTaskStatus.WorkStatus.DailyMax)
            if self.__output then
                self.__output:hangUpTaskDailyMax(task:getId())
            end
        else
            task:setStatus(TaskConst.HangUpTaskStatus.WorkStatus.Idle)
            if self.__output then
                self.__output:updateHangUpTaskUI(task:getId())
            end
        end
    else
        local elapsed = finishTime - currTime

        local percent = math.min((task:getWorkCD() - elapsed) / task:getWorkCD() * 100, 100)

        if self.__output then
            self.__output:updateHangUpTaskCD(task:getId(), elapsed)
            self.__output:updateHangUpTaskBtnProgress(task:getId(), percent)
        end
    end
end

function HangUpTaskSystem:__stopHangUpTaskNew(taskId, callback)
    if self.__currHangUpTaskId ~= taskId then
        error("当前挂机任务并非指定停止的挂机任务，请检查代码")
    end

    local task = self:getHangUpTask(taskId)

    if task:getCurrType() ~= TaskConst.HangUpTaskType.HangUp then
        error("停止挂机：" .. taskId .. " 类型不为挂机类型，无法停止挂机，检查代码！")
    end

    if task:getStatus() ~= TaskConst.HangUpTaskStatus.HangUpStatus.HangUp then
        error("停止挂机：" .. taskId .. " 状态非挂机中，无法停止挂机，检查代码！")
    end

    if self.__isStoppingHangUp then
        return
    end

    self.__isStoppingHangUp = true

    self:__checkTaskIsCheat()

    Game:getWebTime(
        function(__currTime)
            local currTime = __currTime

            self:__getYaShiInHangUpTimeArray(
                function(__yaShiTimeList)
                    local yaShiTimeList = __yaShiTimeList

                    local exceptFinishTime = task:getFinishTime()

                    local startTime = task:getStartTime()

                    --@desc 计算收益的时间
                    local calFinishTime = currTime
                    if currTime > exceptFinishTime then
                        calFinishTime = exceptFinishTime
                    end

                    local yaShiActiveTime = 0
                    if not MapIsEmpty(yaShiTimeList) then
                        --@desc 雅士生效时间
                        yaShiActiveTime =
                            Helper:getActiveTime(
                            yaShiTimeList,
                            {
                                startTime = startTime,
                                finishTime = calFinishTime
                            }
                        )
                    end

                    local rewardInfos
                    local rewardRecords = {}
                    if calFinishTime - startTime >= 60 then
                        --@RefType [src.app.models.Task2.HangUpReward.CalHangUpTaskRewards#CalHangUpTaskRewards]
                        local calHangUpTaskRewards = require("app.models.Task2.HangUpReward.CalHangUpTaskRewards"):create()

                        calHangUpTaskRewards:setRewardClassId(task:getHangUpRewardClassId())

                        calHangUpTaskRewards:setStartTime(startTime)

                        calHangUpTaskRewards:setFinishTime(calFinishTime)

                        calHangUpTaskRewards:setYaShiActiveTime(yaShiActiveTime)

                        calHangUpTaskRewards:setKongfu(task:getKongfu())

                        calHangUpTaskRewards:setLuck(task:getLuck())

                        calHangUpTaskRewards:setInheritAdditionValue(task:getInheritAddition())

                        calHangUpTaskRewards:setShiSiZhenValue(task:getShiSiZhenValue())

                        rewardInfos = calHangUpTaskRewards:getRewards()

                        for i, reward in ipairs(rewardInfos) do
                            rewardRecords[reward:getAttrName()] = reward:getValue()
                        end
                    end

                    local extraRecord = {
                        calStartTime = startTime,
                        calFinishTime = calFinishTime,
                        aftExp = self.__player:getExp() + Helper:getDef(rewardRecords["exp"], 0),
                        yaShiActiveTime = yaShiActiveTime,
                        yaShiTimeList = Helper:getDef(yaShiTimeList, {})
                    }

                    HttpManagerEx:stopHangUpTask(
                        self.__hangUpVersion,
                        taskId,
                        extraRecord,
                        rewardRecords,
                        function(status, errcode, errmsg, data)
                            if status == 200 then
                                if errcode == 0 then
                                    task:setStatus(TaskConst.HangUpTaskStatus.HangUpStatus.Idle)

                                    self.__currHangUpTaskId = nil

                                    self:updateTaskTypeAndStatus()

                                    self:__saveData()

                                    if not MapIsEmpty(rewardInfos) then
                                        for _, reward in ipairs(rewardInfos) do
                                            self.__player:addAttr(reward:getAttrName(), reward:getValue())
                                        end
                                    end

                                    self.__player:removeRoleCurrState(ROLE_CURR_STATE_GUAJI)

                                    self:updateTaskTypeAndStatus()

                                    if callback then
                                        callback(rewardInfos)
                                    end

                                    if calFinishTime - startTime < 60 then
                                        --@TODO 2021-09-15 21:01:45 临时输出
                                        RichPrint("main", "由于你的半途而废，本次任务无任何收益。")
                                    else
                                        if MapIsEmpty(rewardInfos) then
                                            RichPrint("main", "本次任务无任何收益。")
                                        else
                                            local rewardStr = "您本次完成任务后一共获得%s。"
                                            local text = ""
                                            for i, reward in ipairs(rewardInfos) do
                                                if i == 1 then
                                                    text = text .. tostring(Helper:mathFloor(reward:getValue())) .. reward:getNameText()
                                                else
                                                    text = text .. "，" .. tostring(Helper:mathFloor(reward:getValue())) .. reward:getNameText()
                                                end
                                            end

                                            do  --限时历练
                                                local LimitedTimeExperience = require("app.models.Action.LimitedTimeExperience")

                                                if LimitedTimeExperience:checkTaskIsOpen("guaji") then
                                                    LimitedTimeExperience:setRole(User:getRole())
                                                    LimitedTimeExperience:finishTaskByTaskType("guaji")
                                                end
                                            end

                                            do --每日任务
                                                local DailyTasksActivity = require("app.models.Action.DailyTasksActivity")
                                                DailyTasksActivity:addDailyTaskPoint("guaji")
                                            end

                                            RichPrint("main", string.format(rewardStr, text))
                                        end
                                    end
                                    self.__isStoppingHangUp = false

                                    callback(true, rewardInfos)

                                    return true
                                else
                                    callback(false, errmsg)
                                    return true
                                end
                            else
                                callback(false, errmsg)
                                PopText(errmsg)
                                return false
                            end
                        end,
                        IS_SHOW_WAITING,
                        HTTP_MANAGER_RETRY_TYPE_RETRY
                    )
                end
            )
        end
    )
end

function HangUpTaskSystem:__stopHangUpTask(taskId, callback)
    if self.__currHangUpTaskId ~= taskId then
        error("当前挂机任务并非指定停止的挂机任务，请检查代码")
    end

    local task = self:getHangUpTask(taskId)

    if task:getCurrType() ~= TaskConst.HangUpTaskType.HangUp then
        error("停止挂机：" .. taskId .. " 类型不为挂机类型，无法停止挂机，检查代码！")
    end

    if task:getStatus() ~= TaskConst.HangUpTaskStatus.HangUpStatus.HangUp then
        error("停止挂机：" .. taskId .. " 状态非挂机中，无法停止挂机，检查代码！")
    end

    if self.__isStoppingHangUp then
        return
    end

    self.__isStoppingHangUp = true

    self:__checkTaskIsCheat()

    local currTime = nil

    Game:getWebTime(
        function(__currTime)
            currTime = __currTime
        end
    )

    while currTime == nil do
        coroutine.yield()
    end

    local yaShiTimeList = nil

    self:__getYaShiInHangUpTimeArray(
        function(__yaShiTimeList)
            yaShiTimeList = __yaShiTimeList
        end
    )

    while yaShiTimeList == nil do
        coroutine.yield()
    end

    local exceptFinishTime = task:getFinishTime()

    local startTime = task:getStartTime()

    --@desc 计算收益的时间
    local calFinishTime = currTime
    if currTime > exceptFinishTime then
        calFinishTime = exceptFinishTime
    end

    local yaShiActiveTime = 0
    if not MapIsEmpty(yaShiTimeList) then
        --@desc 雅士生效时间
        yaShiActiveTime =
            Helper:getActiveTime(
            yaShiTimeList,
            {
                startTime = startTime,
                finishTime = calFinishTime
            }
        )
    end

    local rewardInfos
    local rewardRecords = {}
    if calFinishTime - startTime >= 60 then
        --@RefType [src.app.models.Task2.HangUpReward.CalHangUpTaskRewards#CalHangUpTaskRewards]
        local calHangUpTaskRewards = require("app.models.Task2.HangUpReward.CalHangUpTaskRewards"):create()

        calHangUpTaskRewards:setRewardClassId(task:getHangUpRewardClassId())

        calHangUpTaskRewards:setStartTime(startTime)

        calHangUpTaskRewards:setFinishTime(calFinishTime)

        calHangUpTaskRewards:setYaShiActiveTime(yaShiActiveTime)

        calHangUpTaskRewards:setKongfu(task:getKongfu())

        calHangUpTaskRewards:setLuck(task:getLuck())

        calHangUpTaskRewards:setInheritAdditionValue(task:getInheritAddition())

        calHangUpTaskRewards:setShiSiZhenValue(task:getShiSiZhenValue())

        rewardInfos = calHangUpTaskRewards:getRewards()

        for i, reward in ipairs(rewardInfos) do
            rewardRecords[reward:getAttrName()] = reward:getValue()
        end
    end

    local extraRecord = {
        calStartTime = startTime,
        calFinishTime = calFinishTime,
        aftExp = self.__player:getExp() + Helper:getDef(rewardRecords["exp"], 0),
        yaShiActiveTime = yaShiActiveTime,
        yaShiTimeList = Helper:getDef(yaShiTimeList, {})
    }

    HttpManagerEx:stopHangUpTask(
        self.__hangUpVersion,
        taskId,
        extraRecord,
        rewardRecords,
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    task:setStatus(TaskConst.HangUpTaskStatus.HangUpStatus.Idle)

                    self.__currHangUpTaskId = nil

                    self:updateTaskTypeAndStatus()

                    self:__saveData()

                    if not MapIsEmpty(rewardInfos) then
                        for _, reward in ipairs(rewardInfos) do
                            self.__player:addAttr(reward:getAttrName(), reward:getValue())
                        end
                    end

                    self.__player:removeRoleCurrState(ROLE_CURR_STATE_GUAJI)

                    self:updateTaskTypeAndStatus()

                    if callback then
                        callback(rewardInfos)
                    end

                    if calFinishTime - startTime < 60 then
                        --@TODO 2021-09-15 21:01:45 临时输出
                        RichPrint("main", "由于你的半途而废，本次任务无任何收益。")
                    else
                        if MapIsEmpty(rewardInfos) then
                            RichPrint("main", "本次任务无任何收益。")
                        else
                            local rewardStr = "您本次完成任务后一共获得%s。"
                            local text = ""
                            for i, reward in ipairs(rewardInfos) do
                                if i == 1 then
                                    text = text .. tostring(Helper:mathFloor(reward:getValue())) .. reward:getNameText()
                                else
                                    text = text .. "，" .. tostring(Helper:mathFloor(reward:getValue())) .. reward:getNameText()
                                end
                            end

                            do
                                local LimitedTimeExperience = require("app.models.Action.LimitedTimeExperience")

                                if LimitedTimeExperience:checkTaskIsOpen("guaji") then
                                    LimitedTimeExperience:setRole(User:getRole())
                                    LimitedTimeExperience:finishTaskByTaskType("guaji")
                                end
                            end

                            do --每日任务
                                local DailyTasksActivity = require("app.models.Action.DailyTasksActivity")
                                DailyTasksActivity:addDailyTaskPoint("guaji")
                            end

                            RichPrint("main", string.format(rewardStr, text))
                        end
                    end
                    self.__isStoppingHangUp = false

                    callback(true, rewardInfos)

                    return true
                else
                    callback(false, errmsg)
                    return true
                end
            else
                callback(false, errmsg)
                PopText(errmsg)
                return false
            end
        end,
        IS_SHOW_WAITING,
        HTTP_MANAGER_RETRY_TYPE_RETRY
    )
end

function HangUpTaskSystem:__getYaShiInHangUpTimeArray(callback)
    HttpManagerEx:getHangUpYashiTime(
        self.__hangUpVersion,
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    --@desc 到目前时间雅士生效的时间段
                    local yaShiTimeList = {}
                    if MapIsEmpty(data) == false then
                        for i, time_info in ipairs(data) do
                            table.insert(
                                yaShiTimeList,
                                {
                                    startTime = time_info.start_time,
                                    finishTime = time_info.end_time
                                }
                            )
                        end
                    end
                    callback(yaShiTimeList)
                    return true
                elseif errcode == 2 then    --版本号异常修复
                    self:__repairVersion(function()
                        self:__getYaShiInHangUpTimeArray(callback)
                    end)
                    return true
                else
                    PopText("ys : " .. tostring(errmsg) .. " : " .. tostring(errcode) .. " : " .. tostring(status))
                    return false
                end
            else
                PopText("ys : " .. tostring(errmsg) .. " : " .. tostring(errcode) .. " : " .. tostring(status))
                return false
            end
        end,
        IS_SHOW_WAITING
    )
end

function HangUpTaskSystem:autoStopHangUp()
    if not self:isHangUping() then
        error("当前没有挂机任务，检查代码")
    end

    local taskId = self:getCurrHangUpTaskId()

    self:__stopHangUpTaskNew(
        self:getCurrHangUpTaskId(),
        function(ok, msg)
            if ok then
                if self.__output then
                    self.__output:autoStopHangUpTask(taskId)
                end
            end
        end
    )
end

function HangUpTaskSystem:manualStopHangUpTask(taskId)
    local ok, msg = AsyncFunction:asyncAwaitWithCallback(self.__stopHangUpTask, self, self:getCurrHangUpTaskId(), "callback")

    if ok then
        local rewardInfos = msg
        if self.__output then
            self.__output:manualStopHangUpTask(taskId)
            if not MapIsEmpty(rewardInfos) then
                for _, reward in ipairs(rewardInfos) do
                    --@RefType [src.app.models.Task2.TaskAttrReward#TaskAttrReward]
                    reward = reward
                    self.__output:popMessage(string.format("获得%s%s", Helper:mathFloor(reward:getValue()), reward:getNameText()))
                end
            end
        end
    end

    return ok, msg
end

function HangUpTaskSystem:checkHangUpTaskFinish()
    if self:getCurrHangUpTaskId() == nil then
        return false
    end

    local task = self:getHangUpTask(self:getCurrHangUpTaskId())

    if task:getCurrType() ~= TaskConst.HangUpTaskType.HangUp then
        error("当前记录的挂机任务非挂机状态，请检查代码。")
    end

    if task:getStatus() ~= TaskConst.HangUpTaskStatus.HangUpStatus.HangUp then
        error("当前记录的挂机任务处于空闲状态，请检查代码。")
    end

    local startTime = task:getStartTime()

    local exceptTime = task:getFinishTime()

    local currTime = GetTime()

    if currTime >= exceptTime then
        return true
    end

    return false
end

function HangUpTaskSystem:__updateHangUpingTime(task)
    if self.__output then
        local startTime = task:getStartTime()

        local currTime = GetTime()

        local elapsed = currTime - startTime

        self.__output:showHangUpingTime(task:getId(), elapsed)
    end
end

function HangUpTaskSystem:update(ft)
    for _, task in ipairs(self.__taskList) do
        --@RefType [src.app.models.Task2.PlayerHangUpTask#PlayerHangUpTask]
        local task = task

        if task:getCurrType() == TaskConst.HangUpTaskType.Work and task:getStatus() == TaskConst.HangUpTaskStatus.WorkStatus.Cooldown then
            -- elseif task:getCurrType() == TaskConst.HangUpTaskType.HangUp and task:getStatus() == TaskConst.HangUpTaskStatus.HangUpStatus.HangUp then
            self:__updateTaskCD(task)
        elseif task:getId() == self:getCurrHangUpTaskId() then
            self:__updateHangUpingTime(task)
        elseif task:getCurrType() == TaskConst.HangUpTaskType.Work and task:getStatus() == TaskConst.HangUpTaskStatus.WorkStatus.DailyMax then
            local currTime = GetTime()
            local preWorkTime = task:getStartTime()
            if Helper:diffWithDate(currTime, preWorkTime) >= 1 then
                task:setDailyWork(0)
                task:setStatus(TaskConst.HangUpTaskStatus.WorkStatus.Idle)
                if self.__output then
                    self.__output:updateHangUpTaskUI(task:getId())
                end
            end
        end
    end

    if self:checkHangUpTaskFinish() then
        self:autoStopHangUp()
    end
end

--版本号异常修复，模拟开始任务重新插入一条数据，额外添加任务开始时间
function HangUpTaskSystem:__repairVersion(callback)
    local taskId = self:getCurrHangUpTaskId()
    local task = self:getHangUpTask(taskId)
    local isUseYaShi = self:currIsYaShiAddition()
    local kongfu = self.__player:getKongfu()
    local luck = self.__player:getFinalAttr("luck")
    local shiSiZhenValue = self.__player:getBuffAttr("xingzhenGuaJiSY")
    local inheritValue = task:getInheritAddition()
    local taskStartTime = task:getStartTime()
    local extra = {
        startExp = self.__player:getExp(),
        luck = luck,
        kongfu = kongfu,
        isUseYaShi = isUseYaShi,
        shiSiZhenValue = shiSiZhenValue,
        inheritAddition = inheritValue,
    }

    HttpManagerEx:uploadAbnormalHangUpTask(self.__hangUpVersion, taskId, taskStartTime, extra, 
        function(status, errcode, errmsg, data)
            if status == 200 and errcode == 0 then
                if callback then
                    callback()
                end
            else
                PopText(errmsg)
            end
        end,
    IS_SHOW_WAITING)
end

function HangUpTaskSystem:__checkTaskIsCheat()
    if self:isHangUping() then
        local task = self:getHangUpTask(self:getCurrHangUpTaskId())
        local startExtraLuck = task:getExtraLuck()
        if startExtraLuck then
            local startBaseLuck = task:getLuck() - startExtraLuck
            local currBaseLuck = self.__player:getAttr("luck")

            if currBaseLuck < startBaseLuck then
                Collection:memoryCheat(User:getUserId(), "hangUpTask.baseLuck." .. tostring(self:getVersion()), startBaseLuck, currBaseLuck)

                print("HangUpTaskSystem:__checkTaskIsCheat: 作弊！！！，开始任务时基础福缘值：", startBaseLuck, "当前基础福缘值：", currBaseLuck)
            end
        end
    end
end

return newClass("HangUpTaskSystem", {}, HangUpTaskSystem)
00000000000000