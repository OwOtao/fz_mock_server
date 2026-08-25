local newClass = require("third.class.NewClass")

local Task = require("app.models.task.Task")

local RoleTaskControllor = require("app.views.layer.RoleLayer.RoleTaskControllor")

local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")

local PreReviewLiLianTaskSystem = {}

function PreReviewLiLianTaskSystem:create(player)
    local p = PreReviewLiLianTaskSystem.new()
    p:__init(player)
    return p
end

function PreReviewLiLianTaskSystem:__init(player)
    self.__isNotSerializable = true
    self.__player = player
    self.__taskList = {}
    Task:init()
end

function PreReviewLiLianTaskSystem:setOutput(output)
    self.__output = output
end

function PreReviewLiLianTaskSystem:getZhuDongTasks()
    local list = {}
    return list
end

function PreReviewLiLianTaskSystem:getZhuDongTask(taskId)
    return Task:getTask(taskId)
end

function PreReviewLiLianTaskSystem:isOpenLiLianTask()
    return false
end

function PreReviewLiLianTaskSystem:getLiLianTask()
    return Task:getTask("task15")
end

function PreReviewLiLianTaskSystem:acceptLiLianTask(taskId)
end

function PreReviewLiLianTaskSystem:submitLiLianTask(taskId)
end

function PreReviewLiLianTaskSystem:cancelLiLianTask(taskId)
end

function PreReviewLiLianTaskSystem:acceptZhuDongTask(taskId)
end

function PreReviewLiLianTaskSystem:showZhuDongTask(taskId)
end

function PreReviewLiLianTaskSystem:submitZhuDongTask(taskId)
end

function PreReviewLiLianTaskSystem:cancelZhuDongTask(taskId)
end
function PreReviewLiLianTaskSystem:updateAllTasks()
end

return newClass("PreReviewLiLianTaskSystem", {}, PreReviewLiLianTaskSystem)
0000000000000