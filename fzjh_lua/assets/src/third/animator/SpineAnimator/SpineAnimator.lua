local Class = require("third.class.NewClass")
local Animator = require("third.animator.Animator")
local SpineAnimationState = require("third.animator.SpineAnimator.SpineAnimationState")

--@SuperType [src.third.animator.Animator#Animator]
local SpineAnimator = {}

function SpineAnimator:create(skeletonAnimation)
    local p = SpineAnimator.new()
    p:__init(skeletonAnimation)
    return p
end

function SpineAnimator:ctor()
    self.__skeletonAnimation = nil
    self.__eventCallback = function()
    end
end

function SpineAnimator:__init(skeletonAnimation)
    assert(skeletonAnimation ~= nil, "skeletonAnimation cannot be equal to null")
    self.__skeletonAnimation = skeletonAnimation
end

function SpineAnimator:getSkeletonAnimation()
    return self.__skeletonAnimation
end

function SpineAnimator:setEventCallback(eventCallback)
    self.__eventCallback = eventCallback
    for _, state in pairs(self.__states) do
        state:setEventCallback(self.__eventCallback)
    end
end

function SpineAnimator:setCompleteCallback(animCompleteCallback)
    self.__animCompleteCallback = animCompleteCallback
    for _, state in pairs(self.__states) do
        state:setCompleteCallback(self.__animCompleteCallback)
    end
end

function SpineAnimator:play(animName, isLoop)
    if self.__states[animName] == nil then
        local state = SpineAnimationState:create(self.__skeletonAnimation, animName, isLoop)
        state:setEventCallback(self.__eventCallback)
        state:setCompleteCallback(self.__animCompleteCallback)
        self:addState(animName, state)
    end

    Animator.play(self, animName)
end

return Class("SpineAnimator", {Animator}, SpineAnimator)
0000000000000000