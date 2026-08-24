local Class = require("third.class.NewClass")
local IAnimatorState = require("third.animator.IAnimatorState")

local SpineAnimationState = {}

function SpineAnimationState:create(skeletonAnimation, animName, loop, beginTime, endTime)
    local p = SpineAnimationState.new()
    p:init(skeletonAnimation, animName, loop, beginTime, endTime)
    return p
end

function SpineAnimationState:ctor()
    self.__normalizedTime = 0 -- 标准化时间

    self.__skeletonAnimation = nil -- 骨骼动画
    self.__animName = nil -- 动画名

    self.__isComplete = false -- 动画是否完成

    self.__animDuration = 0 -- 动画时长

    self.__loop = false -- 是否循环
    self.__beginTime = 0 -- 开始时间
    self.__endTime = 0 -- 结束时间

    self.__speed = 1 -- 速度缩放数值

    self.__eventIndex = 1
    self.__events = nil -- 帧事件

    self.__eventCallback = function()
    end

    -- 行为脚本
    self.__behaviours = {}
end

function SpineAnimationState:init(skeletonAnimation, animName, loop, beginTime, endTime)
    assert(skeletonAnimation ~= nil, "skeletonAnimation cannot be equal to nil")
    assert(type(animName) == "string" and #animName > 0, "The animName length must be greater than 0")

    -- loop类型不正确, 设置为不循环
    if type(loop) ~= "boolean" then
        loop = false
    end

    self.__skeletonAnimation = skeletonAnimation
    self.__animName = animName

    self.__animDuration = skeletonAnimation:getAnimDuration(animName)

    self.__loop = loop
    self.__beginTime = beginTime
    self.__endTime = self.__animDuration

    -- 如果类型不对, 则设置开始时间为0
    if type(beginTime) ~= "number" then
        self.__beginTime = 0
    end

    -- 如果结束时间类型正确, 则使用传入结束时间
    if type(endTime) == "number" then
        self.__endTime = endTime
    end

    -- print("animName = ", animName)
    -- 事件
    self.__events = skeletonAnimation:getAnimEvents(animName)
    for i, event in ipairs(self.__events) do
        event.time = event.time / self.__animDuration
    end
end

function SpineAnimationState:getId()
    return self.__animName
end

function SpineAnimationState:getNormalizedTime()
    return self.__normalizedTime
end

function SpineAnimationState:setNormalizedTime(normalizedTime)
    self.__normalizedTime = normalizedTime
end

function SpineAnimationState:getDuration()
    return self.__endTime - self.__beginTime
end

function SpineAnimationState:getSpeed()
    return self.__speed
end

function SpineAnimationState:setSpeed(speed)
    self.__speed = speed
end

function SpineAnimationState:setEventCallback(eventCallback)
    self.__eventCallback = eventCallback
end

function SpineAnimationState:setCompleteCallback(completeCallback)
    self.__completeCallback = completeCallback
end

function SpineAnimationState:setEndCallback(endCallback)
    self.__endCallback = endCallback
end

function SpineAnimationState:start(animator)
    self.__eventIndex = 0
    self.__isComplete = false
    self:setNormalizedTime(0)
    self.__skeletonAnimation:setAnimation(0, self.__animName, false)

    -- timescale不能未0， 会导致内存无法释放的bug，设定一个较小的数值确保能正常释放内存
    self.__skeletonAnimation:setTimeScale(0.0001)

    self:updateRenderer()
end

function SpineAnimationState:update(animator, ft)
    self:setNormalizedTime(self:getNormalizedTime() + ft * self.__speed / self:getDuration())

    self:updateRenderer()
    self:updateEvent()
end

function SpineAnimationState:exit(animator)
    self:updateRenderer()
end

function SpineAnimationState:updateRenderer()
    local time = 0

    if self.__loop then
        if self.__normalizedTime >= 0 then
            time = (self.__beginTime + self.__normalizedTime * (self.__endTime - self.__beginTime)) % (self.__endTime - self.__beginTime)
        else
            time = self.__endTime - (self.__beginTime + -self.__normalizedTime * (self.__endTime - self.__beginTime)) % (self.__endTime - self.__beginTime)
        end
    else
        if self.__normalizedTime >= 0 then
            time = (self.__beginTime + self.__normalizedTime * (self.__endTime - self.__beginTime))
        else
            time = self.__endTime - (self.__beginTime + -self.__normalizedTime * (self.__endTime - self.__beginTime))
        end

        if time > self.__endTime then
            time = self.__endTime
            if self.__isComplete == false then
                -- 不循环的动画播放完成
                self.__isComplete = true
                if self.__completeCallback then
                    self.__completeCallback(self.__animName)
                end
            end
        elseif time < self.__beginTime then
            time = self.__beginTime
        end
    end

    self.__skeletonAnimation:setTrackTime(0, time)
end

--@desc: 动画事件触发，根据实际播放时间触发，暂不支持倒放及时间段自定义
--@author:Seven
--@time:2023-09-19 15:06:55
function SpineAnimationState:updateEvent()
    if #self.__events <= 0 then
        return
    end

    if self.__loop then
        local intPart, fracPart = math.modf(self:getNormalizedTime())

        local maxIndex = 0

        if fracPart > 0 then
            maxIndex = (intPart + 2) * #self.__events
        else
            maxIndex = (intPart + 1) * #self.__events
        end

        local diffCount = maxIndex - self.__eventIndex

        local count = 1

        while count <= diffCount do
            local eventIndex = (self.__eventIndex % #self.__events) + 1

            local event = self.__events[eventIndex]

            local factor = math.floor(self.__eventIndex / #self.__events)

            if event and self:getNormalizedTime() >= event.time + factor then
                self.__eventIndex = self.__eventIndex + 1
                self.__eventCallback(event)
            else
                break
            end

            count = count + 1
        end
    else
        if self.__eventIndex == 0 then
            self.__eventIndex = 1
        end
        while self.__eventIndex <= #self.__events do
            local event = self.__events[self.__eventIndex]

            if event and self:getNormalizedTime() >= event.time then
                self.__eventIndex = self.__eventIndex + 1
                self.__eventCallback(event)
            else
                break
            end
        end
    end
end

return Class("SpineAnimationState", {IAnimatorState}, SpineAnimationState)
0000000000000000