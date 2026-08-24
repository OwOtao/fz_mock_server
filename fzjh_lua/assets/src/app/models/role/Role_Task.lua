local Role_Task = {}

-- 任务
function Role_Task:getTasks()
    return self:getAttr("tasks")
end

function Role_Task:setTask(taskId, task)
    local tasks = self.tasks
    if not tasks then
        tasks = {}
    end
    tasks[taskId] = task
end

function Role_Task:getTask(taskId)
    local tasks = self.tasks
    if not tasks[taskId] then
    else
        return tasks[taskId]
    end
end

--判断当前是否有师门任务
function Role_Task:getCurrTeacherTaskState()
    if self.teacherTask and self.teacherTask ~= nil then
        return true
    else
        return false
    end
end
--设置师门任务
function Role_Task:setCurrTeacherTask(tab)
    self.teacherTask = tab
end
function Role_Task:getTeacherTask()
    if self.teacherTask == nil or self.teacherTask == {} then
        self.teacherTask.count = 0
        self.teacherTask.refreshCount = 0
        self.teacherTask.appointRefreshCount = 0
        self.teacherTask.date = tonumber(Helper:date("%Y%m%d", tonumber(GetTime())))
        self.teacherTask.taskTab = 0
        self.teacherTask.receiveTask = 0
        self.teacherTask.ContributionPoint = 0
    end
    return self.teacherTask
end
--设置当前任务列表
function Role_Task:setTeacherTaskTab(tab)
    if self.teacherTask == nil or self.teacherTask == {} then
        self.teacherTask.count = 0
        self.teacherTask.refreshCount = 0
        self.teacherTask.appointRefreshCount = 0
        self.teacherTask.date = tonumber(Helper:date("%Y%m%d", tonumber(GetTime())))
        self.teacherTask.taskTab = 0
        self.teacherTask.receiveTask = 0
        self.teacherTask.ContributionPoint = 0
    end
    if tab then
        self.teacherTask.taskTab = tab
    end
end
--接取任务后在任务列表中删除该任务
function Role_Task:removeTaskFromTeacherTaskTab(taskId)
    print("444444444444444444444444444444444444444444444444444444444444444444")
    if taskId then
        for k, v in pairs(self.teacherTask.taskTab) do
            print("55555555555555555555555555555555555555", taskId, v.taskId)
            if v.taskId == taskId then
                self.teacherTask.taskTab[k] = nil
            end
        end
    end
end
--接取师门任务
function Role_Task:setReceiveTask(task)
    if task then
        if self.teacherTask.receiveTask == 0 then
            self.teacherTask.receiveTask = task
        else
            PopText("当前任务尚未完成")
        end
    end
end
function Role_Task:getReceiveTask()
    if self.teacherTask == nil or self.teacherTask == {} then
        self.teacherTask.count = 0
        self.teacherTask.refreshCount = 0
        self.teacherTask.appointRefreshCount = 0
        self.teacherTask.date = tonumber(Helper:date("%Y%m%d", tonumber(GetTime())))
        self.teacherTask.taskTab = 0
        self.teacherTask.receiveTask = 0
        self.teacherTask.ContributionPoint = 0
    end
    return self.teacherTask.receiveTask
end
function Role_Task:getTeacherTaskTab()
    if self.teacherTask == nil or self.teacherTask == {} then
        self.teacherTask.count = 0
        self.teacherTask.appointCount = 0
        self.teacherTask.refreshCount = 0
        self.teacherTask.appointRefreshCount = 0
        self.teacherTask.date = tonumber(Helper:date("%Y%m%d", tonumber(GetTime())))
        self.teacherTask.taskTab = 0
        self.teacherTask.receiveTask = 0
        self.teacherTask.ContributionPoint = 0
    end
    return self.teacherTask.taskTab
end
--是否指派师门任务
function Role_Task:getCurrTeacherTaskIsAppoint()
    if self.teacherTask and self.teacherTask ~= nil then
        if self.appointTeacherTask and self.appointTeacherTask ~= nil then
            return true
        end
        return false
    end
    return false
end
function Role_Task:getTeacherTaskAttr(name)
    return self.teacherTask[name]
end
function Role_Task:setTeacherTaskAttr(name, value)
    if self.teacherTask == nil or self.teacherTask == {} then
        self.teacherTask.count = 0
        self.teacherTask.appointCount = 0
        self.teacherTask.refreshCount = 0
        self.teacherTask.appointRefreshCount = 0
        self.teacherTask.date = tonumber(Helper:date("%Y%m%d", tonumber(GetTime())))
        self.teacherTask.taskTab = 0
        self.teacherTask.receiveTask = 0
        self.teacherTask.ContributionPoint = 0
    end
    self.teacherTask[name] = value
end
--设置指派师门任务信息
function Role_Task:setAppointTeacherTask(tab)
    if tab and type(tab) == "table" then
        self.appointTeacherTask = tab
    else
        -- assert(tab,"设置指派师门任务tab是个空值")
        -- assert(type(tab) == "table","设置指派师门任务tab是个空值")
    end
end
function Role_Task:obTask()
    local ControllLayer = require("app.views.layer.ControllLayer"):getInstance()
    ControllLayer:pushLayer("ReceiveTeacherTaskLayer")
    local ReceiveTeacherTaskLayer = ControllLayer:getLayer("ReceiveTeacherTaskLayer")
    ReceiveTeacherTaskLayer:initLayer()
end
function Role_Task:obAppoint()
    local ControllLayer = require("app.views.layer.ControllLayer"):getInstance()
    ControllLayer:pushLayer("AppointRecordTeacherTaskLayer")
    local ReceiveTeacherTaskLayer = ControllLayer:getLayer("AppointRecordTeacherTaskLayer")
    ReceiveTeacherTaskLayer:initLayer()
end
function Role_Task:obRule()
    local ControllLayer = require("app.views.layer.ControllLayer"):getInstance()
    ControllLayer:pushLayer("ShiMenQingGuiLayer")
    local ShiMenQingGuiLayer = ControllLayer:getLayer("ShiMenQingGuiLayer")
    ShiMenQingGuiLayer:initLayer()
end
--放弃师门任务
function Role_Task:giveUpTeacherTask()
    local TeacherTask = require("app.models.task.teacherTask.teacherTask")
    -- local role = self
    if self.money < 100 then
        PopText("碎银不足")
        PopText("碎银不足")
        return
    end
    local receiveTask = TeacherTask:getTeacherTaskAttr("receiveTask")
    if receiveTask and receiveTask.itemId and receiveTask.taskType == 2 then
        local item = self:getItem(receiveTask.itemId)
        print("扣除任务物品")
        if item then
            self:addItemCount(receiveTask.itemId, 0 - item.count)
        end
    elseif receiveTask and receiveTask.itemId and receiveTask.taskType == 4 then
        if receiveTask.itemId ~= nil and receiveTask.itemId ~= 0 then
            local item = self:getItem(receiveTask.itemId)
            print("扣除任务物品")
            if item then
                self:addItemCount(receiveTask.itemId, 0 - item.count)
            end
        end
        if receiveTask.itemgift ~= nil and receiveTask.itemgift ~= 0 then
            local item = self:getItem(receiveTask.itemgift)
            print("扣除任务物品")
            if item then
                self:addItemCount(receiveTask.itemgift, 0 - item.count)
            end
        end
        if receiveTask.daoju ~= nil and receiveTask.daoju ~= 0 then
            if type(receiveTask.daoju) == "table" then
                for k, v in pairs(receiveTask.daoju) do
                    if self:getItem(v) ~= nil then
                        self:addItemCount(v, 0 - self:getItem(v).count)
                    end
                end
            else
                self:addItemCount(receiveTask.daoju, 0 - self:getItem(receiveTask.daoju).count)
            end
        end
        if self:getItem("shimenwupin30") ~= nil then
            self:addItemCount("shimenwupin30", -1)
        end
        if self:getItem("shimenwupin35") ~= nil then
            self:addItemCount("shimenwupin35", 0 - self:getItem("shimenwupin35").count)
        end
        if self:getItem("shimenwupin34") ~= nil then
            self:addItemCount("shimenwupin34", 0 - self:getItem("shimenwupin34").count)
        end
        if self:getItem("shimenwupin36") ~= nil then
            self:addItemCount("shimenwupin36", 0 - self:getItem("shimenwupin36").count)
        end
    -- role:addItemCount("shimenwupin35",0 - role:getItem("shimenwupin35").count)
    end
    TeacherTask:setTeacherTaskAttr("receiveTask", 0)
    TeacherTask:setTeacherTaskAttr("isAppoint", 0)
    TeacherTask:setTeacherTaskAttr("count", tonumber(TeacherTask:getTeacherTaskAttr("count")) - 1)
    TeacherTask:setTeacherTaskAttr("giveUpTime", GetTime() + 5 * 60)
    self:removeRoleCurrState(ROLE_CURR_STATE_SHIMEN)
    self:addAttr("money", -100)
    PopText("碎银-100")
    PopText("任务已放弃")
end

-----------------------------------------------------------------------------------------------------------
--停止师门挂机
function Role_Task:stopTeacherGuaJiTask()
    local TeacherGuaJiTaskUtil = require("app.models.task.teacherGuaJiTask.TeacherGuaJiTaskUtil")
    local role = User:getRole()
    local teacherGuaJiTask = role:getAttr("teacherGuaJiTask")
    if not MapIsEmpty(teacherGuaJiTask) then
        for taskId, task in pairs(teacherGuaJiTask) do
            local state = task.state
            if state == TASK_STATE_GUAJI then
                TeacherGuaJiTaskUtil:cancelTask(task)
                break
            end
        end
    end
end

--刷新师门挂机任务
function Role_Task:updateTeacherGuaJiTask()
    local TeacherGuaJiTaskUtil = require("app.models.task.teacherGuaJiTask.TeacherGuaJiTaskUtil")
    local role = User:getRole()
    local teacherGuaJiTask = role:getAttr("teacherGuaJiTask")
    if not MapIsEmpty(teacherGuaJiTask) then
        for taskId, task in pairs(teacherGuaJiTask) do
            TeacherGuaJiTaskUtil:refreshRoleTask(task)
        end
    end
end

function Role_Task:setHangUpSystem(system)
    self.__hangUpSystem = system
end

function Role_Task:getHangUpSystem()
    return self.__hangUpSystem
end

function Role_Task:saveHangUpVersion(version)
    self.hangUpTasks.__ver = version
end

function Role_Task:loadHangUpVersion()
    return self.hangUpTasks.__ver
end

function Role_Task:saveCurrHangUpTaskId(taskId)
    self.hangUpTasks.__currHangUpTaskId = taskId
end

function Role_Task:loadCurrHangUpTaskId()
    return self.hangUpTasks.__currHangUpTaskId
end

function Role_Task:getHangUpTaskData(taskId)
    return self.hangUpTasks.__tasks[taskId]
end

function Role_Task:saveHangUpTaskData(taskId, data)
    self.hangUpTasks.__tasks[taskId] = data
end

function Role_Task:setLiLianTaskSystem(system)
    self.__liLianSystem = system
end

function Role_Task:getLiLianTaskSystem()
    return self.__liLianSystem
end

return Role_Task
00000000