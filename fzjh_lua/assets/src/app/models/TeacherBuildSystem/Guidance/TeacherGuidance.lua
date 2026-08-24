local class = require("third.class.NewClass")

local ROLE_STATE = {
    --空闲
    IDLE = 0,
    --破境
    BREAK_THROUGH = 1,
    --冲脉
    ACUPOINT_ACTIVATE = 2
}

local TeacherGuidance = {
    --可指点次数
    __guidanceCount = 2,
    --指点可减少时间
    __reduceTime = 0,
    --状态（0 空闲，）
    __state = 1
}

function TeacherGuidance:create()
    return TeacherGuidance:new()
end

function TeacherGuidance:ctor()
end

function TeacherGuidance:init(func)
    HttpManagerEx:getSectGuidanceInfo(
        self.__role:getFamilyId(),
        function(status, errcode, errmsg, data)
            if status == 200 and errcode == 0 then
                self:setGuidanceCount(data.guidanceCount)
                self:setReduceTime(data.speedUpTime)
                self:refreshState()

                if func then
                    func()
                end
            else
                PopText(errmsg)
            end
        end,
        IS_SHOW_WAITING
    )
end

function TeacherGuidance:setRole(role)
    self.__role = role
end

function TeacherGuidance:setGuidanceCount(count)
    self.__guidanceCount = count
end

function TeacherGuidance:getGuidanceCount()
    return self.__guidanceCount
end

function TeacherGuidance:refreshState()
    self.__state = ROLE_STATE.IDLE

    if self.__role:getHiddenMeridianSystem():getBreakThroughState() and self.__role:getHiddenMeridianSystem():isFinishBreakThrough() == false then
        self.__state = ROLE_STATE.BREAK_THROUGH
    end

    if self.__role:getHiddenMeridianSystem():getAcupointActivateState() and self.__role:getHiddenMeridianSystem():isFinishAcupointActivate() == false then
        self.__state = ROLE_STATE.ACUPOINT_ACTIVATE
    end
end

function TeacherGuidance:getState()
    return self.__state
end

function TeacherGuidance:isIdleState()
    return self.__state == ROLE_STATE.IDLE
end

function TeacherGuidance:isBreakThroughState()
    return self.__state == ROLE_STATE.BREAK_THROUGH
end

function TeacherGuidance:isAcupointActivate()
    return self.__state == ROLE_STATE.ACUPOINT_ACTIVATE
end

function TeacherGuidance:getFeatClassName()
    return self.__role:getTeacherBuildSystem():getFeatClassName()
end

function TeacherGuidance:setReduceTime(reduceTime)
    self.__reduceTime = reduceTime
end

function TeacherGuidance:getReduceTime()
    return self.__reduceTime
end

function TeacherGuidance:getRemainingTime()
    if self.__state == ROLE_STATE.BREAK_THROUGH then
        return self.__role:getHiddenMeridianSystem():getBreakThroughTime() - GetTime()
    elseif self.__state == ROLE_STATE.ACUPOINT_ACTIVATE then
        return self.__role:getHiddenMeridianSystem():getAcupointActivateTime() - GetTime()
    end

    return 0
end

function TeacherGuidance:giveAdvice(succFunc, failFunc)
    self:refreshState()

    if self:isIdleState() then
        if failFunc then
            return failFunc("已修炼完成，无需进行指点")
        end

        return
    end

    if self.__state == ROLE_STATE.BREAK_THROUGH then
        self.__role:getHiddenMeridianSystem():speedUpBreakThroughByTeacherGuidance(
            function(result, data)
                if result == true then
                    self:refreshState()
                    self:setGuidanceCount(data.guidanceCount)
                    self:setReduceTime(data.speedUpTime)
                    if succFunc then
                        succFunc()
                    end
                else
                    if failFunc then
                        failFunc(data)
                    end
                end
            end
        )
    elseif self.__state == ROLE_STATE.ACUPOINT_ACTIVATE then
        self.__role:getHiddenMeridianSystem():speedUpAcupointActivateByTeacherGuidance(
            function(result, data)
                if result == true then
                    self:refreshState()
                    self:setGuidanceCount(data.guidanceCount)
                    self:setReduceTime(data.speedUpTime)
                    if succFunc then
                        succFunc()
                    end
                else
                    if failFunc then
                        failFunc(data)
                    end
                end
            end
        )
    end
end

return class("TeacherGuidance", {}, TeacherGuidance)
0000000000