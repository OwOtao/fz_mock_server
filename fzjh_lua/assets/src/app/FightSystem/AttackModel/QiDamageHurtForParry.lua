local newClass = require("third.class.NewClass")

local BattleConstConf = require("app.FightSystem.Configuration.BattleConstConf")

local QiDamageHurtForParry = {
    __actualValue = 0
}

function QiDamageHurtForParry:create(qiDamageHurt)
    local p = self.new()
    p:init(qiDamageHurt)
    return p
end

function QiDamageHurtForParry:init(qiDamageHurt)
    --@RefType [src.app.FightSystem.AttackModel.QiDamageHurt#QiDamageHurt]
    self.__qiDamageHurt = qiDamageHurt
end

function QiDamageHurtForParry:setProjectionValue(value)
    self.__qiDamageHurt:setProjectionValue(value)
end

function QiDamageHurtForParry:getProjectionValue()
    return self.__qiDamageHurt:getProjectionValue()
end

function QiDamageHurtForParry:setHurtDesc(str)
    self.__qiDamageHurt:setHurtDesc(str)
end

function QiDamageHurtForParry:getHurtDesc()
    return self.__qiDamageHurt:getHurtDesc()
end

function QiDamageHurtForParry:getDescDamageType()
    return self.__qiDamageHurt:getDescDamageType()
end

function QiDamageHurtForParry:getDescDamageStage()
    return self.__qiDamageHurt:getDescDamageStage()
end

--@desc: 添加免伤比例相关信息
--@author:Seven
--@time:2021-07-17 14:46:44
--@redutionInfo: {effectFuncId = xx, value = 1}
function QiDamageHurtForParry:addReductionOfInjuryPercent(redutionInfo)
    self.__qiDamageHurt:addReductionOfInjuryPercent(redutionInfo)
end

function QiDamageHurtForParry:addReductionOfInjuryConstValue(redutionInfo)
    self.__qiDamageHurt:addReductionOfInjuryConstValue(redutionInfo)
end

function QiDamageHurtForParry:getReductionOfInjuryPercents()
    return self.__qiDamageHurt:getReductionOfInjuryPercents()
end

function QiDamageHurtForParry:getReductionOfInjuryConstValues()
    return self.__qiDamageHurt:getReductionOfInjuryConstValues()
end

function QiDamageHurtForParry:getTotalReductionPercent()
    return self.__qiDamageHurt:getTotalReductionPercent()
end

function QiDamageHurtForParry:getTotalReductionConstValue()
    return self.__qiDamageHurt:getTotalReductionConstValue()
end

function QiDamageHurtForParry:calActualValue()
    if self.__qiDamageHurt:getProjectionValue() == 0 then
        self.__actualValue = 0
    end

    local parrySuccessQiHurtScaleCorrectionFactor = BattleConstConf:get("parrySuccessQiHurtScaleCorrectionFactor")

    local actual = self.__qiDamageHurt:getProjectionValue() * (1 - parrySuccessQiHurtScaleCorrectionFactor) * (1 - self:getTotalReductionPercent()) - self:getTotalReductionConstValue()

    self.__actualValue = math.max(math.ceil(actual), 0)
end

function QiDamageHurtForParry:getActualValue()
    return self.__actualValue
end

--@desc: 获取比例减免具体数值信息
--@author:Seven
--@time:2021-07-17 14:56:58
--@return [{effectFuncId = 1,value = 100}] (返回每个效果减伤实际的减伤值)
function QiDamageHurtForParry:getReductionPercentOfActualValue()
    return self.__qiDamageHurt:getReductionPercentOfActualValue()
end

--@desc: 返回每个效果的实际固定减伤值
--@author:Seven
--@time:2021-07-17 15:05:54
function QiDamageHurtForParry:getReductionConstOfActualValueArray()
    return self.__qiDamageHurt:getReductionConstOfActualValueArray()
end

function QiDamageHurtForParry:allocByWeight(weight, totoalWeight)
    local newDamageHurt = self.__qiDamageHurt:allocByWeight(weight, totoalWeight)

    local newDamageHurtForParry = QiDamageHurtForParry:create(newDamageHurt)

    return newDamageHurtForParry
end

return newClass("QiDamageHurtForParry", {}, QiDamageHurtForParry)
00000