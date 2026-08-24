local Constants = require("third.dotween.Constants")
local NewClass = require("third.class.NewClass")

local Tween = {}

function Tween:create()
    local p = self.new()
    return p
end

function Tween:ctor()
    self.__node = nil
    self.__getter = nil
    self.__setter = nil
    self.__interpolator = nil
    self.__endValue = 0
    self.__time = 0
    self.__duration = 0
    self.isCompleted = false
    self.__onComplete = nil
    self.__isPause = false
    self.__needKill = false
    self.__autoKill = true
    self.__onKill = nil
    self.__easeFunc = nil
end

function Tween:init(getter, setter, interpolator, endValue, duration)
    self.getter = getter
    self.__setter = setter
    self.__interpolator = interpolator
    self.__endValue = endValue
    self.__duration = duration
    self.__time = 0
    self.isCompleted = false
end

--[[
    @desc: 暂停刷新
    author:TangJian
    time:2021-03-16 15:48:02
    @return:
]]
function Tween:pause()
    self.__isPause = true
end

--[[
    @desc: 恢复刷新
    author:TangJian
    time:2021-03-16 15:48:11
    @return:
]]
function Tween:resume()
    self.__isPause = false
end

function Tween:isPause()
    return self.__isPause
end

function Tween:kill()
    self.__needKill = true

    if self.__onKill then
        self.__onKill(self)
    end
end

function Tween:needKill()
    return self.__needKill
end

function Tween:onKill(onKill)
    self.__onKill = onKill
end

function Tween:withEase(easeType)
    if easeType == Constants.EaseType.SlowFast then
        self.__easeFunc = function(x)
            return x ^ 3
        end
    else
        self.__easeFunc = function(x)
            return (x - 1) * (x - 1) * (x - 1) * (x - 1) * (x - 1) + 1
        end
    end
    return self
end

function Tween:__ease(percentage)
    return percentage
end

function Tween:update(ft)
    if self.isCompleted == false then
        self.__time = self.__time + ft
        local percentage = self.__time / self.__duration
        if percentage < 0 then
            percentage = 0
        elseif percentage > 1 then
            percentage = 1
        end

        self:setValue(self:interpolate(self:__ease(percentage)))

        if percentage >= 1 then
            self:__complete(self)
            if self.__autoKill then
                self:kill()
            end
        end
    end
end

--[[
    @desc: 完成回调设置
    author:TangJian
    time:2021-03-16 15:48:22
    --@onComplete: 
    @return:
]]
function Tween:onComplete(onComplete)
    self.__onComplete = onComplete
    return self
end

function Tween:getValue()
    return self.getter()
end

function Tween:setValue(value)
    self.__setter(value)
end

function Tween:interpolate(percentage)
    return self.__interpolator(percentage)
end

function Tween:__complete()
    self.isCompleted = true

    if self.__onComplete then
        self.__onComplete(self)
    end
end

return NewClass("Tween", {}, Tween)
000