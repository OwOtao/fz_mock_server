local class = require("third.class.NewClass")
local bilu = require("script.fenjiyindao.fenjiyindao")["Sheet1"]
local BiLu = {}

function BiLu:create()
    return BiLu:new()
end

function BiLu:ctor()
    self._name = ""

    self._point = 0

    self._id = nil

    self._task = {}
end

function BiLu:init(callback)
    self:__initTaskById(self._id)
    if callback then
        callback()
    end
end

function BiLu:setRole(role)
    self._role = role
end

function BiLu:setTaskId(id)
    self._id = id
end

function BiLu:getName()
    return self._name
end

function BiLu:getPoint()
    return self._point
end

function BiLu:getStoryText()
    return self._task.storyText
end

function BiLu:getTargetText()
    return self._task.targetText
end

function BiLu:getDescText()
    return self._task.taskText
end

function BiLu:getSelect1Text()
    return self._task.btnName1
end

function BiLu:getSelect2Text()
    return self._task.btnName2
end

function BiLu:getSelect1TaskId()
    return self._task.nextTaskId1
end

function BiLu:getSelect2TaskId()
    return self._task.nextTaskId2
end

function BiLu:__initTaskById(id)
    if MapIsEmpty(bilu) == false then
        for k,v in pairs(bilu) do
            if id == v.id then
                self._task = v
                return
            end
        end
    end
    assert(false,tostring(id).." is not found")
end

function BiLu:checkIsEndTask()
    return self._isEnd == 1
end
 
function BiLu:checkIsFinish()
    local conditionUnlockId = self._task.finishCondition
    if AchievementSystem:checkUnlockPointIsUnlock(conditionUnlockId) then
        return true
    end
    return false
end

return class("BiLu", {}, BiLu)
00000000