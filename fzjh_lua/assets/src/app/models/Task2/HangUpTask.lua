local newClass = require("third.class.NewClass")

local HangUpTask = {}

function HangUpTask:create(res)
    return HangUpTask.new(res)
end

function HangUpTask:getId()
    return tostring(self.id)
end

function HangUpTask:getTaskName()
    return self.taskName
end

function HangUpTask:getTaskType()
    return self.taskType
end

function HangUpTask:getUnlockNeedMap()
    return self.unlockNeedMap
end

function HangUpTask:getUnlockNeedRoleExp()
    return self.unlockNeedRoleExp
end

function HangUpTask:getTransformLowAwardExp()
    return self.transformLowAwardExp
end

function HangUpTask:getClickLimit()
    return self.clickLimit
end

function HangUpTask:getAutoAwardClass()
    return self.autoAwardClass
end

function HangUpTask:getClickAwardClass()
    return self.clickAwardClass
end

function HangUpTask:getClickCD()
    return self.clickCD
end

return newClass("HangUpTask", {}, HangUpTask)
000000