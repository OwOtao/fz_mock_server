local hangUpTaskTextConfig = require("script.HangUpTask.hangUpTaskTextConfig")["挂机事件表"]

local hangUpTaskTextResByType = {}

local function initClassifyHangUpTaskTextByType()
    for id, res in pairs(hangUpTaskTextConfig) do
        local taskId = tostring(res.taskId)

        local taskType = res.taskType

        local key = string.format("%s|%s", taskId, tostring(taskType))

        if hangUpTaskTextResByType[key] == nil then
            hangUpTaskTextResByType[key] = {}
        end

        table.insert(hangUpTaskTextResByType[key], res)
    end
end

initClassifyHangUpTaskTextByType()

local TaskTextFactory = {}

local hangUpTaskClassCache = {}

function TaskTextFactory:getHangUpTaskTexts(taskId, taskType)
    local key = string.format("%s|%s", tostring(taskId), tostring(taskType))
    if hangUpTaskClassCache[key] == nil then
        local textResList = hangUpTaskTextResByType[key]

        if MapIsEmpty(textResList) then
            error("无法找到挂机任务文本 - id：" .. taskId .. "，文本类型：" .. taskType .. "")
        end

        hangUpTaskClassCache[key] = {}

        local HangUpTaskText = require("app.models.Task2.HangUpTaskText")
        for _, res in pairs(textResList) do
            local textClass = HangUpTaskText:create(res)

            table.insert(hangUpTaskClassCache[key], textClass)
        end

        table.sort(
            hangUpTaskClassCache[key],
            function(a, b)
                return tonumber(a:getId()) < tonumber(b:getId())
            end
        )
    end

    return hangUpTaskClassCache[key]
end

--@desc: 随机获取一条文本
--@author:Seven
--@time:2021-09-14 11:23:18
--@taskId: 任务id
--@taskType: 文本类型
--@return [src.app.models.Task2.HangUpTaskText#HangUpTaskText]
function TaskTextFactory:getRandomHangUpTaskText(taskId, taskType)
    local textClasses = self:getHangUpTaskTexts(taskId, taskType)

    if #textClasses > 1 then
        local rand = math.random(1, #textClasses)
        return textClasses[rand]
    else
        return textClasses[1]
    end
end

return TaskTextFactory
0000000000000000