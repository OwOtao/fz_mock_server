local newClass = require("third.class.NewClass")

local HangUpTaskText = {}

function HangUpTaskText:create(data)
    return HangUpTaskText.new(data)
end

-- 编号;
function HangUpTaskText:getId()
    return self.id
end

-- 任务ID;
function HangUpTaskText:getTaskId()
    return self.taskId
end

-- 挂机文本类型;
function HangUpTaskText:getTaskType()
    return self.taskType
end

-- 挂机文本内容;
function HangUpTaskText:getShowDesc()
    return self.showDesc
end

function HangUpTaskText:getTime()
    return self.time
end

return newClass("HangUpTaskText", {}, HangUpTaskText)
000000000000