local newClass = require("third.class.NewClass")

local HangUpTaskReward = {}

function HangUpTaskReward:create(res)
    return HangUpTaskReward.new(res)
end
--@desc 挂机任务奖励编号;
function HangUpTaskReward:getId()
    return self.id
end
--@desc 挂机任务奖励系列Class;
function HangUpTaskReward:getAwardClass()
    return self.awardClass
end
--@desc 奖励货币;
function HangUpTaskReward:getAwardType()
    return self.awardType
end
--@desc 奖励类型;
function HangUpTaskReward:getAwardNumType()
    return self.awardNumType
end
--@desc 任务基础收益;
function HangUpTaskReward:getBaseAward()
    return self.baseAward
end
--@desc sklv下限;
function HangUpTaskReward:getSklvLowLimit()
    return self.sklvLowLimit
end
--@desc sklv上限;
function HangUpTaskReward:getSklvUpperLimit()
    return self.sklvUpperLimit
end
--@desc sklv加成基准值;
function HangUpTaskReward:getSklvAddBase()
    return self.sklvAddBase
end
--@desc sklv加成修正值;
function HangUpTaskReward:getSklvAddCorrection()
    return self.sklvAddCorrection
end
--@desc sklv基础修正系数;
function HangUpTaskReward:getSklvBaseCorrection()
    return self.sklvBaseCorrection
end
--@desc 福缘系数A;
function HangUpTaskReward:getFyFactorA()
    return self.fyFactorA
end
--@desc 福缘系数B;
function HangUpTaskReward:getFyFactorB()
    return self.fyFactorB
end
--@desc 福缘参数A;
function HangUpTaskReward:getFyParamA()
    return self.fyParamA
end
--@desc 福缘参数B;
function HangUpTaskReward:getFyParamB()
    return self.fyParamB
end
--@desc 付费比例;
function HangUpTaskReward:getPayScale()
    return self.payScale
end
--@desc 福缘比例;
function HangUpTaskReward:getFyScale()
    return self.fyScale
end

--@desc 任务传承修正系数
function HangUpTaskReward:getInheritCountAddCorrection()
    return self.inheritCountAddCorrection
end

--@desc: 角色福缘限制
function HangUpTaskReward:getLuckLimit()
    return self.fyLimit
end

return newClass("HangUpTaskReward", {}, HangUpTaskReward)
00000000