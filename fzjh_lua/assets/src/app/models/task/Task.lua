local Task = {}

local taskType ={
	[1] = { title ="历练",},       --任务
	[2] = { title ="任务", }       --历练
}
----NEEDTODO 可以导出json 然后解析
local taskMap = -- 任务列表
{
	task1 = requireWithEncrypt("app.models.task.tasks.task1"),
	task2 = requireWithEncrypt("app.models.task.tasks.task2"),
	task3 = requireWithEncrypt("app.models.task.tasks.task3"),
	task4 = requireWithEncrypt("app.models.task.tasks.task4"),
	task5 = requireWithEncrypt("app.models.task.tasks.task5"),
	task6 = requireWithEncrypt("app.models.task.tasks.task6"),
	task7 = requireWithEncrypt("app.models.task.tasks.task7"),
	task8 = requireWithEncrypt("app.models.task.tasks.task8"),
	task9 = requireWithEncrypt("app.models.task.tasks.task9"),
	task10 = requireWithEncrypt("app.models.task.tasks.task10"),
	task11 = requireWithEncrypt("app.models.task.tasks.task11"),
	task12 = requireWithEncrypt("app.models.task.tasks.task12"),
	-- task13 = requireWithEncrypt("app.models.task.tasks.task13"),
	-- task14 = requireWithEncrypt("app.models.task.tasks.task14"),
	-- task15 = requireWithEncrypt("app.models.task.tasks.task15"),
	task15 = requireWithEncrypt("app.models.task.tasks.task15"),
	task16 = requireWithEncrypt("app.models.task.tasks.task16"),
	task17 = requireWithEncrypt("app.models.task.tasks.task17"),
	task18 = requireWithEncrypt("app.models.task.tasks.task18"),
	task19 = requireWithEncrypt("app.models.task.tasks.task19"),
	task20 = requireWithEncrypt("app.models.task.tasks.task20"),
	task21 = requireWithEncrypt("app.models.task.tasks.task21"),
}


for k, task in pairs(taskMap) do
	taskMap[k] = Helper:tableCover(clone(require("app.models.task.BaseTask")), task)
	taskMap[k].id = k

	taskMap[k] = createEncryptTableWithRecursive(taskMap[k])
end
local taskList = {}
for i=1,200 do
	if taskMap["task"..i] ~= nil then
		table.insert(taskList, taskMap["task"..i])
	end
end



local roleTaskTemplate =
{
	state = TASK_STATE_DISABLE,
	startTime = nil
}

function Task:init()
	local currTaskId = User:getRoleAttr("currTaskId")
	local currTask
	local tasks = User:getRoleAttr("tasks")

	if tasks == nil then
		tasks = {}
		currTaskId = nil
	end

	for k, task in pairs(taskMap) do
		if not tasks[k] then
			tasks[k] = clone(roleTaskTemplate) -- 初始化任务
		end
	end

	User:setRoleAttr("tasks", tasks)
	return tasks
end

function Task:getTaskMap()
	return taskMap
end

function Task:getTaskList()
	return taskList
end

function Task:getTask(taskId)
	return assert(taskMap[taskId])
end

function Task:getTaskAttr(taskId, attrName)
	return self:getTask(taskId)[attrName]
end

function Task:getRoleTasks()
	local tasks = User:getRoleAttr("tasks")
	if MapIsEmpty(tasks) then
		tasks = self:init()
	end
	return assert(tasks, "function Task:getRoleTasks()")
end

function Task:getRoleTask(taskId)
	local tasks = User:getRoleAttr("tasks")
	if MapIsEmpty(tasks) then
		self:init()
		tasks = User:getRoleAttr("tasks")
	end

	if tasks[taskId] == nil then
		Task:init()
		return Task:getRoleTask(taskId)
	end
	-- print("taskType == "..type(tasks[taskId]))
	return assert(tasks[taskId], "function Task:getRoleTask(taskId)")
end

function Task:getRoleCurrTaskId()
	return User:getRoleAttr("currTaskId")
end

function Task:getTaskStyle(taskId)
	local task = Task:getTask(taskId)
	return task:getUIState()
end

function Task:guaji(taskId)
	local task = Task:getTask(taskId)
	return task:guaji()
end

function Task:stopGuaji(taskId)
	local task = Task:getTask(taskId)
	return task:stopGuaji()
end

function Task:getGuajiRewardDsc(taskId)
	local task = Task:getTask(taskId)
	return task:getGuajiRewardDsc()
end

function Task:work(taskId)
	local task = Task:getTask(taskId)
	return task:work()
end

function Task:getWorkRewardDsc(taskId)
	local task = Task:getTask(taskId)
	return task:getWorkRewardDsc()
end

function Task:getTaskPercent(taskId)
	local task = Task:getTask(taskId)
	return task:getPercent()
end

function Task:getTaskConditionDsc(taskId)
	local task = Task:getTask(taskId)
	return task:getConditionDsc()
end

-- 对外
function Task:update(ft) -- 刷新任务
	for taskId, task in pairs(taskMap) do
		if self:getRoleTask(task.id) then
			task:update(ft)
		end
	end
end

function Task:getTaskType()
	return taskType
end


function Task:refreshTasks(npc, event_tyep)
    local player = User:getRole()
    local tasks = User:getRoleAttr("tasks")
    local currMap = player:getCurrMap()

    local function getNpc(list, roleId)
        if MapIsEmpty(list) then
            return nil
        end
        for k, v in pairs(list) do
            if string.find(roleId, k) ~= nil then
                list[k].id = k
                return list[k]
            end
        end
    end

    for i, v in pairs(tasks) do
        if v.state == TASK_STATE_ACCEPT and i ~= "task15" and i ~= "task22" then
            local task = Task:getTask(i)
            if task and task.zhuXianCondition and currMap ~= nil and currMap.id == task.mapId then
                local npcList = task.zhuXianCondition.npcList
                local npc = getNpc(npcList, npc.id)
                if npc ~= nil and npc.action == event_tyep then
                    if not v[currMap.name] then
                        v[currMap.name] = {}
                    end
                    if not v[currMap.name][npc.id] then
                        v[currMap.name][npc.id] = 1
                    else
                        v[currMap.name][npc.id] = v[currMap.name][npc.id] + 1
                    end
                    local state = true
                    for k, j in pairs(npcList) do
                        if v[currMap.name][k] < j.count then
                            state = false
                            RichPrint("main", "你已将这名飞贼就地正法，剩余" .. (j.count - v[currMap.name][k]) .. "名飞贼仍逍遥法外。")
                            break
                        end
                    end
                    if state then
                        PopText("飞贼讨伐完成")
                        v.state = TASK_STATE_TO_SUBMIT
                        -- 飞贼任务完成时增加人数
                        if task.id == "task16" then
                            local npcList = task.zhuXianCondition.npcList
                            for k, j in pairs(npcList) do
                                if j.count < 8 then
                                    j.count = j.count + 1
                                    if j.count >= player:getDayFlag("飞贼人数") then
                                        player:setDayFlag("飞贼人数", j.count)
                                    end
                                end
                            end
                        end
                    end
                end
            end

            if player:getDayFlag("送信任务") == 1 then
                if task.id == "task19" then
                    v.state = TASK_STATE_TO_SUBMIT
                    player:setDayFlag("送信任务", 0)
                end
            end
            if player:getFlag("追捕主动任务") == 2 then
                if task.id == "task21" then
                    v.state = TASK_STATE_TO_SUBMIT
                    player:setFlag("追捕主动任务", 0)
                end
            end
        -- if role:getInheritFlag("腊八施粥") == 2 then

        --     if task.id == "task18" then
        --         v.state = TASK_STATE_TO_SUBMIT
        --     end
        -- end
        end
    end
end



-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/14 17:20:04
-- @desc 获取挂机任务列表
local GuaJiTasks = {}
function Task:getGuaJiTasks()
	if MapIsEmpty(GuaJiTasks) == true then
		for k,task in pairs(taskMap) do 
			if task.type == "挂机任务" then
				GuaJiTasks[k] = task
			end
		end
	end
	return GuaJiTasks
end
-- 加密版本
Task.isEncrypted = true
return Task
0000