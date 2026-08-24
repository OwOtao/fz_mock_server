local newClass = require("third.class.NewClass")

local TaskConst = require("app.models.Task2.TaskConst")

local TaskFactory = require("app.models.Task2.TaskFactory")

local RoleTaskControllor = require("app.views.layer.RoleLayer.RoleTaskControllor")

local HangUpTaskSystem = require("app.models.Task2.HangUpTaskSystem")

local PreReviewHangUpTaskSystem = {}

function PreReviewHangUpTaskSystem:create(player)
    local p = PreReviewHangUpTaskSystem.new()
    p:__init(player)
    return p
end

-- function PreReviewHangUpTaskSystem:__init(player)
--     self.__isNotSerializable = true

--     self.__player = player

--     self.__taskList = TaskFactory:createPlayerHangUpTasks(self.__player)

--     self.__currHangUpTaskId = self.__player:loadCurrHangUpTaskId()

--     self.__hangUpVersion = self.__player:loadHangUpVersion()

--     self.__isStoppingHangUp = false

--     table.sort(
--         self.__taskList,
--         function(a, b)
--             return tonumber(a:getId()) < tonumber(b:getId())
--         end
--     )

--     self:updateTaskTypeAndStatus()
-- end

function PreReviewHangUpTaskSystem:getVersion()
    return self.__hangUpVersion
end

function PreReviewHangUpTaskSystem:updateTaskTypeAndStatus()
end

function PreReviewHangUpTaskSystem:setOutput(output)
    --@RefType [MainTaskPresenter]
    self.__output = output
end

function PreReviewHangUpTaskSystem:getPlayer()
    return self.__player
end

function PreReviewHangUpTaskSystem:isHangUping()
    return self.__currHangUpTaskId ~= nil
end

function PreReviewHangUpTaskSystem:getCurrHangUpTaskId()
    return self.__currHangUpTaskId
end

function PreReviewHangUpTaskSystem:getHangUpTasks()
    return self.__taskList
end

--@desc 当前是否拥有雅士加成
function PreReviewHangUpTaskSystem:currIsYaShiAddition()
    return self.__player:isYaShi()
end

--@desc: 获取挂机任务对象
--@author:Seven
--@time:2021-09-07 15:25:33
--@taskId: 任务id
--@return [src.app.models.Task2.PlayerHangUpTask#PlayerHangUpTask]
function PreReviewHangUpTaskSystem:getHangUpTask(taskId)
    for _, task in ipairs(self.__taskList) do
        if task:getId() == taskId then
            return task
        end
    end

    error("PreReviewHangUpTaskSystem:getHangUpTask 没有找到挂机任务：" .. taskId)
end

function PreReviewHangUpTaskSystem:workForTask(taskId)
end

function PreReviewHangUpTaskSystem:startHangUpTask(taskId)
end

function PreReviewHangUpTaskSystem:getCurrExceptRewards(taskId)
    local task = self:getHangUpTask(taskId)
    return task:getCurrExceptRewards()
end

function PreReviewHangUpTaskSystem:getExceptRewards(taskId)
    local task = self:getHangUpTask(taskId)

    return task:getExceptRewards()
end

function PreReviewHangUpTaskSystem:autoStopHangUp()
end

function PreReviewHangUpTaskSystem:manualStopHangUpTask(taskId)
    return true, {}
end

function PreReviewHangUpTaskSystem:checkHangUpTaskFinish()
    return false
end

function PreReviewHangUpTaskSystem:update(ft)
end

return newClass("PreReviewHangUpTaskSystem", {HangUpTaskSystem}, PreReviewHangUpTaskSystem)
00000000000000