--[[
    招式气血伤害计算相关
]]

local newClass = require("third.class.NewClass")

local QiDamageHurt = {
    __projectionValue = 0,
    __actualValue = 0,
    __reductionOfInjuryPercents = {},
    __reductionOfInjuryConstValues = {}
}

function QiDamageHurt:create()
    return self.new()
end

function QiDamageHurt:setProjectionValue(value)
    self.__projectionValue = value
end

function QiDamageHurt:getProjectionValue()
    return self.__projectionValue
end

function QiDamageHurt:setHurtDesc(str)
    local list = string.split(str, "#")

    local damageType = list[1]

    local damageStage = list[2]

    if damageType == nil or damageStage == nil then
        error("气血伤害文本信息设置：参数格式错误（damageType#damageStage）, 传入参数：" .. str)
    end
    self.__hurtDesc = str

    self.__descDamageType = damageType

    self.__descDamageStage = damageStage
end

function QiDamageHurt:getHurtDesc()
    return self.__hurtDesc
end

function QiDamageHurt:getDescDamageType()
    return self.__descDamageType
end

function QiDamageHurt:getDescDamageStage()
    return self.__descDamageStage
end

--@desc: 添加免伤比例相关信息
--@author:Seven
--@time:2021-07-17 14:46:44
--@redutionInfo: {effectFuncId = xx, value = 1}
function QiDamageHurt:addReductionOfInjuryPercent(redutionInfo)
    table.insert(self.__reductionOfInjuryPercents, redutionInfo)
end

function QiDamageHurt:addReductionOfInjuryConstValue(redutionInfo)
    table.insert(self.__reductionOfInjuryConstValues, redutionInfo)
end

function QiDamageHurt:getReductionOfInjuryPercents()
    return self.__reductionOfInjuryPercents
end

function QiDamageHurt:getReductionOfInjuryConstValues()
    return self.__reductionOfInjuryConstValues
end

function QiDamageHurt:getTotalReductionPercent()
    local percent = 0

    if MapIsEmpty(self.__reductionOfInjuryPercents) then
        return percent
    end

    for i, info in ipairs(self.__reductionOfInjuryPercents) do
        if info.value > percent then
            percent = info.value
        end
    end

    return percent
end

function QiDamageHurt:getTotalReductionConstValue()
    local totalValue = 0

    if MapIsEmpty(self.__reductionOfInjuryConstValues) then
        return totalValue
    end

    for _, info in ipairs(self.__reductionOfInjuryConstValues) do
        totalValue = totalValue + info.value
    end

    return totalValue
end

function QiDamageHurt:calActualValue()
    if self.__projectionValue == 0 then
        self.__actualValue = 0
    end

    local actual = self.__projectionValue * (1 - self:getTotalReductionPercent()) - self:getTotalReductionConstValue()

    self.__actualValue = math.max(math.ceil(actual), 0)
end

function QiDamageHurt:getActualValue()
    return self.__actualValue
end

--@desc: 获取比例减免具体数值信息
--@author:Seven
--@time:2021-07-17 14:56:58
--@return [{effectFuncId = 1,value = 100}] (返回每个效果减伤实际的减伤值)
function QiDamageHurt:getReductionPercentOfActualValue()
    local array = {}
    if MapIsEmpty(self.__reductionOfInjuryPercents) then
        return array
    end

    -- local percent = self:getTotalReductionPercent()

    local percent = 0

    local effectFuncId

    for i, info in ipairs(self.__reductionOfInjuryPercents) do
        if info.value > percent then
            percent = info.value
            effectFuncId = info.effectFuncId
        end
    end
    
    if effectFuncId ~= nil then
        local actualReduction = self.__projectionValue * percent
    
        table.insert(array, {effectFuncId = effectFuncId, value = actualReduction})
    end

    return array
end

--@desc: 返回每个效果的实际固定减伤值
--@author:Seven
--@time:2021-07-17 15:05:54
function QiDamageHurt:getReductionConstOfActualValueArray()
    return self.__reductionOfInjuryConstValues
end

function QiDamageHurt:allocByWeight(weight, totoalWeight)
    --@RefType [src.app.FightSystem.AttackModel.QiDamageHurt#QiDamageHurt]
    local newDamageHurt = QiDamageHurt:create()

    local percent = weight / totoalWeight

    local allocProjectionValue = self.__projectionValue * percent

    if MapIsEmpty(self:getReductionOfInjuryPercents()) == false then
        for _, v in ipairs(self:getReductionOfInjuryPercents()) do
            newDamageHurt:addReductionOfInjuryPercent({effectFuncId = v.effectFuncId, value = v.value})
        end
    end

    if MapIsEmpty(self:getReductionOfInjuryConstValues()) == false then
        for _, v in ipairs(self:getReductionOfInjuryConstValues()) do
            newDamageHurt:addReductionOfInjuryConstValue({effectFuncId = v.effectFuncId, value = v.value * percent})
        end
    end

    if self:getHurtDesc() ~= nil then
        newDamageHurt:setHurtDesc(self:getHurtDesc())
    end

    newDamageHurt:setProjectionValue(allocProjectionValue)

    return newDamageHurt
end

return newClass("QiDamageHurt", {}, QiDamageHurt)
0000000