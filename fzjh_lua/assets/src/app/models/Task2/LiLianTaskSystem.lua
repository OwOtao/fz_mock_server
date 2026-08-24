local newClass = require("third.class.NewClass")

local Task = require("app.models.task.Task")

local RoleTaskControllor = require("app.views.layer.RoleLayer.RoleTaskControllor")

local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")

local LiLianTaskSystem = {}

function LiLianTaskSystem:create(player)
    local p = LiLianTaskSystem.new()
    p:__init(player)
    return p
end

function LiLianTaskSystem:__init(player)
    self.__isNotSerializable = true
    self.__player = player
    self.__taskList = {}
    Task:init()
end

function LiLianTaskSystem:setOutput(output)
    self.__output = output
end

function LiLianTaskSystem:getZhuDongTasks()
    local list = {}
    local taskIds = {
        "task16",
        "task17",
        "task19",
        "task20",
        "task21"
    }

    for i, id in ipairs(taskIds) do
        local task = Task:getTask(id)
        if Map:getMapState(task.jindu) == MAP_STATE.COMPLETE then
            --限时主线任务位置提前
            --@desc 主线任务满足开启条件时应该设置成空闲状态
            local roleTask = self.__player:getTask(task.id)
            if roleTask.state == TASK_STATE_DISABLE then
                roleTask.state = TASK_STATE_IDLE
            end

            table.insert(list, task)
        end
    end

    return list
end

function LiLianTaskSystem:getZhuDongTask(taskId)
    return Task:getTask(taskId)
end

function LiLianTaskSystem:isOpenLiLianTask()
    local task = self:getLiLianTask()
    if Map:getMapState(task.jindu) == MAP_STATE.COMPLETE then
        --限时主线任务位置提前
        --@desc 主线任务满足开启条件时应该设置成空闲状态
        local roleTask = self.__player:getTask(task.id)
        if roleTask.state == TASK_STATE_DISABLE then
            roleTask.state = TASK_STATE_IDLE
        end

        return true
    end

    return false
end

function LiLianTaskSystem:getLiLianTask()
    return Task:getTask("task15")
end

function LiLianTaskSystem:acceptLiLianTask(taskId)
    RoleTaskControllor:clickZhuXianTask(
        function()
            if User:getRole():isInCurrState(ROLE_CURR_STATE_SHIMEN) == true then
                PopText("请先完成师门任务")
                return
            end

            local task = self:getLiLianTask()
            -- 玩家状态标记为已接受
            task:acceptTask()

            if self.__output then
                self.__output:updateSubmitLiLianTask(taskId)
            end

            -- 按钮改为进行中
            PopupLayerController:showLayer(
                "TaskZhuXianLayer",
                function(layer)
                    layer:show(task, self)
                end
            )
        end,
        taskId
    )
end

function LiLianTaskSystem:submitLiLianTask(taskId)
    if self.__player:isInCurrState(ROLE_CURR_STATE_ZHUDONG) == true then
        PopText("正在进行其他主动任务，不能领取奖励")
        return
    end

    local dialog = DialogALayer:getInstance()
    dialog:show("是否提交任务")
    dialog:setButton1(
        "是",
        function()
            if PRINT_MODE == 1 then
                print("是的，我提交任务")
            end
            local task = self:getLiLianTask()
            local isSubmit = task:submitTask()
            if isSubmit == false then
                return
            end

            if self.__output then
                self.__output:updateSubmitLiLianTask(taskId)
            end

            task:getTaskReward()

            task:getDayReward()
        
            task:extraFunc()
            
            task:recordActiveCount()
        end
    )
    dialog:setButton2(
        "否",
        function()
            if PRINT_MODE == 1 then
                print("暂时我还不提交任务")
            end
        end
    )
end

function LiLianTaskSystem:cancelLiLianTask(taskId)
end

function LiLianTaskSystem:acceptZhuDongTask(taskId)
    RoleTaskControllor:clickZhuXianTask(
        function()
            if User:getRole():isInCurrState(ROLE_CURR_STATE_SHIMEN) == true then
                PopText("请先完成师门任务")
                return
            end

            local task = self:getZhuDongTask(taskId)
            -- 玩家状态标记为已接受
            task:acceptTask()

            if self.__output then
                self.__output:updateSubmitZhuDongTask(taskId)
            end

            -- 按钮改为进行中
            PopupLayerController:showLayer(
                "TaskZhuXianLayer",
                function(layer)
                    layer:show(task, self)
                end
            )
        end,
        taskId
    )
end

function LiLianTaskSystem:submitZhuDongTask(taskId)
    local dialog = DialogALayer:getInstance()
    dialog:show("是否提交任务")
    dialog:setButton1(
        "是",
        function()
            if PRINT_MODE == 1 then
                print("是的，我提交任务")
            end
            local task = self:getZhuDongTask(taskId)
            local role = User:getRole()
            local roleTask = role:getTask(taskId)
            roleTask.dcount =0
            print("LiLianTaskSystem:submitZhuDongTask role addr:" , role, self.__player)
            print("LiLianTaskSystem:submitZhuDongTask role tasks addr:" , role.tasks, self.__player.tasks)
            print("LiLianTaskSystem:submitZhuDongTask before:" .. roleTask.state, roleTask)
            local isSubmit = task:submitTask()
            if isSubmit == false then
                return
            end
            
            task:update()

            local roleTask2 = role:getTask(taskId)
            print("LiLianTaskSystem:submitZhuDongTask after:" .. roleTask2.state, roleTask2)
            if self.__output then
                if self:isOpenLiLianTask() then
                    self.__output:updateSubmitLiLianTask(self:getLiLianTask().id)
                end
                
                self.__output:updateSubmitZhuDongTask(taskId)
            end
            
            task:getTaskReward()

            task:getDayReward()
        
            task:extraFunc()
            
            task:recordActiveCount()
        end
    )
    dialog:setButton2(
        "否",
        function()
            if PRINT_MODE == 1 then
                print("暂时我还不提交任务")
            end
        end
    )
end

function LiLianTaskSystem:cancelZhuDongTask(taskId)
    if self.__player:getTask(taskId).state == TASK_STATE_TO_SUBMIT then
        PopText("待提交的任务不能取消")
        return
    end

    local roleTask = self.__player:getTask(taskId)

    print("LiLianTaskSystem:cancelZhuDongTask before:" .. roleTask.state, roleTask)
    
    local task = self:getZhuDongTask(taskId)
    local cancelSuccess = task:cancelTask()
    if cancelSuccess == true then
        task:update()
    end
    roleTask = self.__player:getTask(taskId)
    print("LiLianTaskSystem:cancelZhuDongTask after:" .. roleTask.state, roleTask)
    if self.__output then
        self.__output:updateSubmitZhuDongTask(taskId)
    end

    return cancelSuccess
end
function LiLianTaskSystem:updateAllTasks()
    --@desc 派遣刷新
    local tasks = self.__player:getTasks()

    --@RefType [app.models.HomelandModel.DispatchTaskModel.DispatchTaskManager#DispatchTaskManager]
    local DispatchTaskManager = require("app.models.HomelandModel.DispatchTaskModel.DispatchTaskManager")
    for taskId, taskData in pairs(tasks) do
        if taskData.state == TASK_STATE_DISPATCH and taskData.endTime <= GetTime() then
            DispatchTaskManager:finishTask(taskId, taskData)
        end
    end

    for i, v in ipairs(self:getZhuDongTasks()) do
        v:updateCount()
    end

    if self:isOpenLiLianTask() then
        self:getLiLianTask():updateCount()
    end
end

return newClass("LiLianTaskSystem", {}, LiLianTaskSystem)
00000000000