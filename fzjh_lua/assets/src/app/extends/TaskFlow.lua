local NewClass = require("third.class.NewClass")

local TaskFlow = {}

function TaskFlow:create()
    local p = TaskFlow.new()
    p:init()
    return p
end

function TaskFlow:init()
    self._lock = false
    self._taskArray = {}
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/02/28 16:08:54
-- @desc 添加任务
function TaskFlow:startTask(func)
    table.insert(self._taskArray, func)
    if self._lock == false then
        self:doTask()
        self._lock = true
    end
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/02/28 16:09:43
-- @desc 执行任务
function TaskFlow:doTask()
    local task = self._taskArray[1]
    if task then
        -- Helper:getDef(task, function() end)()
        task()
    end
    table.remove(self._taskArray, 1)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/02/28 16:14:46
-- @desc 完成任务
function TaskFlow:finishTask()
    self._lock = false
    self:doTask()
end

local function test()
    local tf = TaskFlow:create()
    tf:startTask(
        function()
            print("1")
        end
    )

    tf:finishTask()

    tf:startTask(
        function()
            print("2")
        end
    )

    tf:finishTask()

    tf:startTask(
        function()
            print("3")
        end
    )
end
-- test()

return NewClass("TaskFlow", {}, TaskFlow)
000