local HangUpTask = require("app.models.Task2.HangUpTask")

local TaskFactory = {
    __taskRes = {}
}

local hangUpTaskRes = require("script.HangUpTask.hangUpTaskConfig")["挂机任务"]

function TaskFactory:getHangUpTask(id)
    local task = self.__taskRes[tostring(id)]
    if task == nil then
        local res = hangUpTaskRes[tostring(id)]
        if res == nil then
            assert(false, "没有找到id：【" .. id .. "】所对应的挂机任务资源")
        end
        task = HangUpTask:create(res)

        self.__taskRes[tostring(id)] = task
    end

    return task
end

function TaskFactory:createPlayerHangUpTasks(player)
    local PlayerHangUpTask = require("app.models.Task2.PlayerHangUpTask")
    local list = {}
    for taskId, res in pairs(hangUpTaskRes) do
        local taskRes = self:getHangUpTask(taskId)
        table.insert(list, PlayerHangUpTask:create(player, taskRes))
    end
    return list
end

return TaskFactory
0000