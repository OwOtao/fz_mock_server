local TestHangUpTaskUtil = {}

local Role = require("app.models.role.Role")

local TaskConst = require("app.models.Task2.TaskConst")

function TestHangUpTaskUtil:addHangUpTaskTime(sec)
    if sec <= 0 then
        PopText("输入秒数不可小于0")
        return
    end

    local role = User:getRole()

    --@RefType [src.app.models.Task2.HangUpTaskSystem#HangUpTaskSystem]
    local hangUpSystem = role:getHangUpSystem()

    if not hangUpSystem:isHangUping() then
        PopText("当前没有正在挂机的任务")
        return
    end

    local currTask = hangUpSystem:getHangUpTask(hangUpSystem:getCurrHangUpTaskId())

    local version = hangUpSystem:getVersion()

    local startTime = currTask:getStartTime()

    local finishTime = currTask:getFinishTime()

    local n_startTime = startTime - sec

    local n_finishTime = finishTime - sec

    local data = {
        task_id = currTask:getId(),
        start_time = n_startTime,
        end_time1 = n_finishTime
    }

    HttpManagerEx:testSetUpdateHangTask(
        version,
        data,
        function(status, errcode, errmsg, data)
            if status == 200 and errcode == 0 then
                PopText("修改成功")
                currTask:setStartTime(n_startTime)
                currTask:setFinishTime(n_finishTime)
                currTask:saveData()
                return true
            else
                PopText(errmsg)
                return false
            end
        end,
        IS_SHOW_WAITING
    )
end

function TestHangUpTaskUtil:finishCurrTaskByMaxTime()
    local role = User:getRole()

    --@RefType [src.app.models.Task2.HangUpTaskSystem#HangUpTaskSystem]
    local hangUpSystem = role:getHangUpSystem()

    if not hangUpSystem:isHangUping() then
        PopText("当前没有正在挂机的任务")
        return
    end

    local currTime = GetTime()

    local currTask = hangUpSystem:getHangUpTask(hangUpSystem:getCurrHangUpTaskId())

    local version = hangUpSystem:getVersion()

    local startTime = currTask:getStartTime()

    local finishTime = currTask:getFinishTime()

    if currTime - startTime > TaskConst.MaxHangUpTime then
        PopText("当前时长已是最大值")
    end

    local n_startTime = currTime - TaskConst.MaxHangUpTime

    local n_finishTime = currTime

    local data = {
        task_id = currTask:getId(),
        start_time = n_startTime,
        end_time1 = n_finishTime
    }

    HttpManagerEx:testSetUpdateHangTask(
        version,
        data,
        function(status, errcode, errmsg, data)
            if status == 200 and errcode == 0 then
                PopText("修改成功")
                currTask:setStartTime(n_startTime)
                currTask:setFinishTime(n_finishTime)
                currTask:saveData()
                return true
            else
                PopText(errmsg)
                return false
            end
        end,
        IS_SHOW_WAITING
    )
end

function TestHangUpTaskUtil:resetWorkTasksDailyCount()
    local role = User:getRole()

    --@RefType [src.app.models.Task2.HangUpTaskSystem#HangUpTaskSystem]
    local hangUpSystem = role:getHangUpSystem()

    local tasks = hangUpSystem:getHangUpTasks()

    for _, v in ipairs(tasks) do
        --@RefType[src.app.models.Task2.PlayerHangUpTask#PlayerHangUpTask]
        local task = v

        if task:getCurrType() == TaskConst.HangUpTaskType.Work then
            task:setStatus(TaskConst.HangUpTaskStatus.WorkStatus.Idle)
            task:setDailyWork(0)
            task:saveData()
        end
    end

    PopText("重置成功")
end

function TestHangUpTaskUtil:resetAllTasks()
    local role = User:getRole()

    --@RefType [src.app.models.Task2.HangUpTaskSystem#HangUpTaskSystem]
    local hangUpSystem = role:getHangUpSystem()

    local tasks = hangUpSystem:getHangUpTasks()

    hangUpSystem.__hangUpVersion = 0

    hangUpSystem.__currHangUpTaskId = nil

    for _, v in ipairs(tasks) do
        --@RefType[src.app.models.Task2.PlayerHangUpTask#PlayerHangUpTask]
        local task = v
        task:setCurrType(TaskConst.HangUpTaskType.CLOSE)
        task:setStatus(0)
        task:setDailyWork(0)
        task:setStartTime(0)
        task:setFinishTime(0)
        task:setLuck(-1)
        task:setKongfu(-1)
        task:setUseYaShi(0)
        task:setShiSiZhenValue(0)
        task:saveData()
    end

    PopText("重置成功")
end

function TestHangUpTaskUtil:testRewards()
    local currTime = 1632919205

    local exceptFinishTime = 1632916683 + 72 *3600

    local startTime = 1632916683

    --@desc 计算收益的时间
    local calFinishTime = currTime
    if currTime > exceptFinishTime then
        calFinishTime = exceptFinishTime
    end

    local yaShiActiveTime = 2522

    local rewardInfos
    local rewardRecords = {}
    --@RefType [src.app.models.Task2.HangUpReward.CalHangUpTaskRewards#CalHangUpTaskRewards]
    local calHangUpTaskRewards = require("app.models.Task2.HangUpReward.CalHangUpTaskRewards"):create()

    calHangUpTaskRewards:setRewardClassId(101101)

    calHangUpTaskRewards:setStartTime(startTime)

    calHangUpTaskRewards:setFinishTime(calFinishTime)

    calHangUpTaskRewards:setYaShiActiveTime(yaShiActiveTime)

    calHangUpTaskRewards:setKongfu(1652.3333333333)

    calHangUpTaskRewards:setLuck(184)

    calHangUpTaskRewards:setInheritAdditionValue(0.2)

    calHangUpTaskRewards:setShiSiZhenValue(0.025)

    rewardInfos = calHangUpTaskRewards:getRewards()

    for i, reward in ipairs(rewardInfos) do
        print(reward:getAttrName(), reward:getValue())
    end
end

function TestHangUpTaskUtil:testCalAfterStartInfo()
    local role = Role:create()

    local TaskFactory = require("app.models.Task2.TaskFactory")
    local task = TaskFactory:getHangUpTask("10110")
    local PlayerHangUpTask = require("app.models.Task2.PlayerHangUpTask")
    --@RefType [src.app.models.Task2.PlayerHangUpTask#PlayerHangUpTask]
    local hangUpTask = PlayerHangUpTask:create(role, task)

    role:setAttr("inheritCount", 5)

    hangUpTask:setStartTime(1632537208)

    hangUpTask:setLuck(304)

    hangUpTask:setKongfu(1640)

    hangUpTask:setShiSiZhenValue(0)

    hangUpTask:setUseYaShi(true)

    local CalAfterStartExceptReward = require("app.models.Task2.HangUpReward.CalAfterStartExceptReward")

    --@RefType [src.app.models.Task2.HangUpReward.CalAfterStartExceptReward#CalAfterStartExceptReward]
    local rewardClass = CalAfterStartExceptReward:create()

    rewardClass:setPlayerHangUpTask(hangUpTask)

    local rewards = rewardClass:getRewards()

    for i, reward in ipairs(rewards) do
        print(reward:getAttrName(), reward:getValue() * 3635)
    end
end

function TestHangUpTaskUtil:testPlayerHangUpReward()
    local TaskRewardFactory = require("app.models.Task2.TaskRewardFactory")

    local rewards = TaskRewardFactory:getHangUpRewards(101101)

    local PlayerHangUpTaskReward = require("app.models.Task2.PlayerHangUpTaskReward")

    for _, v in ipairs(rewards) do
        --@RefType [src.app.models.Task2.PlayerHangUpTaskReward#PlayerHangUpTaskReward]
        local pHanguUpTaskReward = PlayerHangUpTaskReward:create()

        pHanguUpTaskReward:setTaskReward(v)

        pHanguUpTaskReward:setKongfu(1652.3333333333)

        pHanguUpTaskReward:setLuck(184)

        pHanguUpTaskReward:setShiZhenAddition(0.025)

        pHanguUpTaskReward:setYaShiAdditionValue(0.15)

        pHanguUpTaskReward:setInheritAddition(0.2)

        print(pHanguUpTaskReward:getRewardAttrName(), pHanguUpTaskReward:getValue() * 3635)
    end
end

function TestHangUpTaskUtil:viewHangUpDetail()
    local role = User:getRole()

    --@RefType [src.app.models.Task2.HangUpTaskSystem#HangUpTaskSystem]
    local hangUpSystem = role:getHangUpSystem()

    local version = hangUpSystem:getVersion()

    HttpManagerEx:testGetHangTask(
        version,
        function(status, errcode, errmsg, data)
            if status == 200 and errcode == 0 then
                print("版本号：" .. data.version)

                print("任务ID：" .. data.task_id)

                print("开始挂机时间：" .. data.start_time)

                print("预计结束挂机时间：" .. data.end_time1)

                print("结束挂机时间：" .. Helper:getDef(data.end_time2, 0))

                print("记录信息：")

                Helper:print_lua_table({json.decode(data.extra)})
                
                print("任务奖励：") 
                if data.reward ~= "" then
                    local rewards = json.decode( data.reward)
                    Helper:print_lua_table(rewards)

                else
                    print("无")
                end


                return true
            else
                PopText(errmsg)
                return false
            end
        end,
        IS_SHOW_WAITING
    )
end

function TestHangUpTaskUtil:setHangUpVersion(version)
    local role = User:getRole()
    local hangUpSystem = role:getHangUpSystem()
    hangUpSystem.__hangUpVersion = version
end

return TestHangUpTaskUtil
0000