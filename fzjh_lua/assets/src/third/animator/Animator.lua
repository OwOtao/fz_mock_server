local Class = require("third.class.NewClass")
local IAnimator = require("third.animator.IAnimator")

local Animator = {}

function Animator:create()
    local p = Animator.new()
    return p
end

function Animator:ctor()
    self.__states = {}
    self.__entry = nil
    self.__currState = nil

    self.__speed = 1
end

function Animator:addState(id, state)
    state:setSpeed(self.__speed)
    self.__states[id] = state
end

function Animator:play(stateId)
    local lastState = self.__currState
    self.__currState = self.__states[stateId]

    if lastState ~= nil then
        lastState:exit(self, stateId)
    end
    self.__currState:start(self, stateId)
end

function Animator:getSpeed()
    return self.__speed
end

function Animator:setSpeed(speed)
    self.__speed = speed
    for stateId, state in pairs(self.__states) do
        state:setSpeed(speed)
    end
end

function Animator:update(ft)
    if self.__currState ~= nil then
        self.__currState:update(self, ft)
    end
end

return Class("Animator", {IAnimator}, Animator)
00000000