local newClass = require("third.class.NewClass")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local QiReduce = {
    __effcetValueMap = {},
    __actualValueFuncTemp = {}
}

function QiReduce:create()
    return QiReduce.new()
end

function QiReduce:setConfClass(conf)
    --@RefType [QiDamageReduceConf]
    self.__conf = conf
end

function QiReduce:setReduceRateIdLv1(id)
    self.__reduceRateIdLv1 = id
    self.__actualValueFuncTemp[id] = "__getReduceRateActualValueLv1"
end

function QiReduce:setReduceRateIdLv2(id)
    self.__reduceRateIdLv2 = id
    self.__actualValueFuncTemp[id] = "__getReduceRateActualValueLv2"
end

function QiReduce:setReduceRateIdLv3(id)
    self.__reduceRateIdLv3 = id
    self.__actualValueFuncTemp[id] = "__getReduceRateActualValueLv3"
end

function QiReduce:setReduceValueIdLv1(id)
    self.__reduceValueIdLv1 = id
    self.__actualValueFuncTemp[id] = "__getReduceValueActualValueLv1"
end

function QiReduce:setReduceValueIdLv2(id)
    self.__reduceValueIdLv2 = id
    self.__actualValueFuncTemp[id] = "__getReduceValueActualValueLv2"
end

function QiReduce:setReduceValueIdLv3(id)
    self.__reduceValueIdLv3 = id
    self.__actualValueFuncTemp[id] = "__getReduceValueActualValueLv3"
end

function QiReduce:setReduceBreakId(id)
    self.__reduceBreakId = id
end

function QiReduce:setEffectMap(effectMap)
    self.__effcetValueMap = effectMap
end

function QiReduce:setQiDamageValue(value)
    self.__qiDamageValue = value
end

function QiReduce:__getEffectValue(id)
    local value = self.__effcetValueMap[tostring(id)]

    if value == nil then
        value = 0
    end

    return value
end

function QiReduce:setAllocPercent(percent)
    self.__allocPercent = percent
end

function QiReduce:getAllocPercent()
    return self.__allocPercent
end

--单次气血伤害(比例)
function QiReduce:getQiDamageRate()
    if self.__actualQiDamageRate == nil then
        self.__actualQiDamageRate = math.max(self.__qiDamageValue - self:__getReduceRateProjectedValueLv1() - self:__getReduceRateProjectedValueLv2() - self:__getReduceRateProjectedValueLv3(), 0)
    end

    return self.__actualQiDamageRate
end

--单次气血伤害(固值)
function QiReduce:getQiDamageConst()
    if self.__actualQiDamageConst == nil then
        self.__actualQiDamageConst =
            math.max(self:getQiDamageRate() - self:__getReduceValueProjectedValueLv1() - self:__getReduceValueProjectedValueLv2() - self:__getReduceValueProjectedValueLv3(), 0)
    end

    return self.__actualQiDamageConst
end

--@desc: 1类免伤率.预计效果值
--@author:Seven
--@time:2022-01-11 12:08:20
function QiReduce:__getReduceRateProjectedValueLv1()
    if self.__reduceRateProjectedValueLv1 == nil then
        self.__reduceRateProjectedValueLv1 =
            self.__qiDamageValue * (self.__conf:getDefaultValue(self.__reduceRateIdLv1) + self:__getEffectValue(self.__reduceRateIdLv1)) * self:__getQiReduceBreakValue()
    end

    return self.__reduceRateProjectedValueLv1
end

--@desc: 2类免伤率.预计效果值
--@author:Seven
--@time:2022-01-11 14:07:44
function QiReduce:__getReduceRateProjectedValueLv2()
    if self.__reduceRateProjectedValueLv2 == nil then
        self.__reduceRateProjectedValueLv2 =
            self.__qiDamageValue * (self.__conf:getDefaultValue(self.__reduceRateIdLv2) + self:__getEffectValue(self.__reduceRateIdLv2)) * self:__getQiReduceBreakValue()
    end

    return self.__reduceRateProjectedValueLv2
end

--@desc: 3类免伤率.预计效果值
--@author:Seven
--@time:2022-01-11 14:08:40
function QiReduce:__getReduceRateProjectedValueLv3()
    if self.__reduceRateProjectedValueLv3 == nil then
        self.__reduceRateProjectedValueLv3 =
            self.__qiDamageValue * (self.__conf:getDefaultValue(self.__reduceRateIdLv3) + self:__getEffectValue(self.__reduceRateIdLv3)) * self:__getQiReduceBreakValue()
    end
    return self.__reduceRateProjectedValueLv3
end

--@desc: 免伤值穿透率
--@author:Seven
--@time:2022-01-11 12:15:25
function QiReduce:__getQiReduceBreakValue()
    if self.__qiReduceBreakValue == nil then
        self.__qiReduceBreakValue = self.__conf:getDefaultValue(self.__reduceBreakId) + self:__getEffectValue(self.__reduceBreakId)
    end

    return self.__qiReduceBreakValue
end

--@desc: 1类免伤值.预计效果值
--@author:Seven
--@time:2022-01-11 14:56:18
function QiReduce:__getReduceValueProjectedValueLv1()
    if self.__reduceValueProjectedValueLv1 == nil then
        self.__reduceValueProjectedValueLv1 =
            (self.__conf:getDefaultValue(self.__reduceValueIdLv1) + self:__getEffectValue(self.__reduceValueIdLv1)) * self:__getQiReduceBreakValue() * self:getAllocPercent()
    end

    return self.__reduceValueProjectedValueLv1
end

--@desc: 2类免伤值.预计效果值
--@author:Seven
--@time:2022-01-11 14:56:18
function QiReduce:__getReduceValueProjectedValueLv2()
    if self.__reduceValueProjectedValueLv2 == nil then
        self.__reduceValueProjectedValueLv2 =
            (self.__conf:getDefaultValue(self.__reduceValueIdLv2) + self:__getEffectValue(self.__reduceValueIdLv2)) * self:__getQiReduceBreakValue() * self:getAllocPercent()
    end
    return self.__reduceValueProjectedValueLv2
end

--@desc: 3类免伤值.预计效果值
--@author:Seven
--@time:2022-01-11 14:56:18
function QiReduce:__getReduceValueProjectedValueLv3()
    if self.__reduceValueProjectedValueLv3 == nil then
        self.__reduceValueProjectedValueLv3 =
            (self.__conf:getDefaultValue(self.__reduceValueIdLv3) + self:__getEffectValue(self.__reduceValueIdLv3)) * self:__getQiReduceBreakValue() * self:getAllocPercent()
    end
    return self.__reduceValueProjectedValueLv3
end

--@desc: 1类免伤率.实际免伤值
--@author:Seven
--@time:2022-01-11 15:50:15
function QiReduce:__getReduceRateActualValueLv1()
    if self.__reduceRateActualValueLv1 == nil then
        self.__reduceRateActualValueLv1 = math.min(self.__qiDamageValue, self:__getReduceRateProjectedValueLv1())
    end

    return self.__reduceRateActualValueLv1
end

--@desc: 2类免伤率.实际免伤值
--@author:Seven
--@time:2022-01-11 15:50:21
function QiReduce:__getReduceRateActualValueLv2()
    if self.__reduceRateActualValueLv2 == nil then
        local tempValue = self.__qiDamageValue - self:__getReduceRateProjectedValueLv1()
        if tempValue > 0 then
            self.__reduceRateActualValueLv2 = math.min(tempValue, self:__getReduceRateProjectedValueLv2())
        else
            self.__reduceRateActualValueLv2 = 0
        end
    end

    return self.__reduceRateActualValueLv2
end

--@desc: 3类免伤率.实际免伤值
--@author:Seven
--@time:2022-01-11 15:50:30
function QiReduce:__getReduceRateActualValueLv3()
    if self.__reduceRateActualValueLv3 == nil then
        local tempValue = self.__qiDamageValue - self:__getReduceRateProjectedValueLv1() - self:__getReduceRateProjectedValueLv2()
        if tempValue > 0 then
            self.__reduceRateActualValueLv3 = math.min(tempValue, self:__getReduceRateProjectedValueLv3())
        else
            self.__reduceRateActualValueLv3 = 0
        end
    end

    return self.__reduceRateActualValueLv3
end

--@desc: 1类免伤值.实际效果值
--@author:Seven
--@time:2022-01-11 14:41:17
function QiReduce:__getReduceValueActualValueLv1()
    if self.__reduceValueActualValueLv1 == nil then
        self.__reduceValueActualValueLv1 = math.min(self:getQiDamageRate(), self:__getReduceValueProjectedValueLv1())
    end
    return self.__reduceValueActualValueLv1
end

--@desc: 2类免伤值.实际效果值
--@author:Seven
--@time:2022-01-11 14:41:17
function QiReduce:__getReduceValueActualValueLv2()
    if self.__reduceValueActualValueLv2 == nil then
        local tempValue = self:getQiDamageRate() - self:__getReduceValueProjectedValueLv1()

        if tempValue > 0 then
            self.__reduceValueActualValueLv2 = math.min(tempValue, self:__getReduceValueProjectedValueLv2())
        else
            self.__reduceValueActualValueLv2 = 0
        end
    end

    return self.__reduceValueActualValueLv2
end

--@desc: 3类免伤值.实际效果值
--@author:Seven
--@time:2022-01-11 14:41:17
function QiReduce:__getReduceValueActualValueLv3()
    if self.__reduceValueActualValueLv3 == nil then
        local tempValue = self:getQiDamageRate() - self:__getReduceValueProjectedValueLv1() - self:__getReduceValueProjectedValueLv2()
        if tempValue > 0 then
            self.__reduceValueActualValueLv3 = math.min(tempValue, self:__getReduceValueProjectedValueLv3())
        else
            self.__reduceValueActualValueLv3 = 0
        end
    end

    return self.__reduceValueActualValueLv3
end

function QiReduce:getReduceActualValueList()
    local list = {}
    for id, funcName in pairs(self.__actualValueFuncTemp) do
        local value = self[funcName](self)
        if value > 0 then
            table.insert(list, {id = id, value = value})
        end
    end
    return list
end

function QiReduce:printString()
    FightUtil:printLog("  1类免伤值ID :" .. self.__reduceValueIdLv1)
    FightUtil:printLog("  2类免伤值ID :" .. self.__reduceValueIdLv2)
    FightUtil:printLog("  3类免伤值ID :" .. self.__reduceValueIdLv3)
    FightUtil:printLog("  1类免伤率ID :" .. self.__reduceRateIdLv1)
    FightUtil:printLog("  2类免伤率ID :" .. self.__reduceRateIdLv2)
    FightUtil:printLog("  3类免伤率ID :" .. self.__reduceRateIdLv3)
    FightUtil:printLog("  气血伤害免伤值穿透ID :" .. self.__reduceBreakId)
    FightUtil:printLog("  初始伤害值 ：" .. self.__qiDamageValue)
    FightUtil:printLog("  分摊比例 ：" .. self:getAllocPercent())
    FightUtil:printLog("  免伤值穿透率 :" .. self:__getQiReduceBreakValue())
    FightUtil:printLog("  效果带来的影响值 ：" .. table.tostring(self.__effcetValueMap))
    FightUtil:printLog("  实际减免值列表 ：" .. table.tostring(self:getReduceActualValueList()))
    FightUtil:printLog("  1类免伤率.实际免伤值 : " .. self:__getReduceRateActualValueLv1())
    FightUtil:printLog("  2类免伤率.实际免伤值 : " .. self:__getReduceRateActualValueLv2())
    FightUtil:printLog("  3类免伤率.实际免伤值 : " .. self:__getReduceRateActualValueLv3())
    FightUtil:printLog("  1类免伤率.预计效果值 : " .. self:__getReduceRateProjectedValueLv1())
    FightUtil:printLog("  2类免伤率.预计效果值 : " .. self:__getReduceRateProjectedValueLv2())
    FightUtil:printLog("  3类免伤率.预计效果值 : " .. self:__getReduceRateProjectedValueLv3())
    FightUtil:printLog("  1类免伤值.预计效果值 : " .. self:__getReduceValueProjectedValueLv1())
    FightUtil:printLog("  2类免伤值.预计效果值 : " .. self:__getReduceValueProjectedValueLv2())
    FightUtil:printLog("  3类免伤值.预计效果值 : " .. self:__getReduceValueProjectedValueLv3())
    FightUtil:printLog("  1类免伤值.实际效果值 : " .. self:__getReduceValueActualValueLv1())
    FightUtil:printLog("  2类免伤值.实际效果值 : " .. self:__getReduceValueActualValueLv2())
    FightUtil:printLog("  3类免伤值.实际效果值 : " .. self:__getReduceValueActualValueLv3())
    FightUtil:printLog("  单次气血伤害(比例) :" .. self:getQiDamageRate())
    FightUtil:printLog("  单次气血伤害(固值) :" .. self:getQiDamageConst())
end

return newClass("QiReduce", {}, QiReduce)
00000000