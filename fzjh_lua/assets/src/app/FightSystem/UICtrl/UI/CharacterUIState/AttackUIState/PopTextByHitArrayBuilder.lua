--[[
    一击所要在攻守双方头顶冒字生成建造者
]]
local newClass = require("third.class.NewClass")

local PopTextVm = require("app.FightSystem.UICtrl.UIModel.PopTextVm")

local BuffConf = require("app.FightSystem.Configuration.BuffConf")

local PopTextByHitArrayBuilder = {
    __popTextArray = {}
}

function PopTextByHitArrayBuilder:create()
    return PopTextByHitArrayBuilder.new()
end

--@desc: 招式本身造成的气血伤害数组(目标：受击者)
--@author:Seven
--@time:2021-12-06 20:29:18
--@qiDamageHurts: [array]
function PopTextByHitArrayBuilder:setQiDamageHurtCauseByZhaoHit(qiDamageHurts)
    self.__qiDamageHurts = qiDamageHurts
end

--@desc: 招式本身造成的其它属性伤害(目标：受击者)
--@author:Seven
--@time:2021-12-06 20:58:24
--@hurts: [array]
function PopTextByHitArrayBuilder:setOtherAttrHurtCauseByZhaoHit(hurts)
    self.__hurts = hurts
end

--@desc: 设置因效果effect造成的攻击者属性变动
--@author:Seven
--@time:2021-12-06 21:11:02
--@attrChangeByEffectInfos:
function PopTextByHitArrayBuilder:setEffectAttrsByQiDamageArray(attrChangeByEffectInfos)
    self.__effectAttrsByQiDamageArray = attrChangeByEffectInfos
end

function PopTextByHitArrayBuilder:__initQiDamagePopText()
    if #self.__qiDamageHurts <= 0 then
        return
    end

    for i = 1, #self.__qiDamageHurts do
        --@RefType [src.app.FightSystem.AttackModel.QiDamageHurt#QiDamageHurt]
        local damage = self.__qiDamageHurts[i]

        local damageValue = damage:getActualValue()

        if damageValue > 0 then
            --@RefType[src.app.FightSystem.UICtrl.UIModel.PopTextVm#PopTextVm]
            local qiPopVm = PopTextVm:create()

            qiPopVm:setPrefix(self.__qiDamagePopTextPrefix)

            qiPopVm:setValueString(tostring(-damageValue))

            qiPopVm:setColor("HIW")

            table.insert(self.__popTextArray, qiPopVm)
        end

        local qiReductionPercentsValue = damage:getReductionConstOfActualValueArray()
        if #qiReductionPercentsValue > 0 then
            for _, v in ipairs(qiReductionPercentsValue) do
                local effectFuncId = v.effectFuncId
                local reductionValue = v.value
                local effect = BuffConf:getEffect(tostring(effectFuncId))
                local popPrefix = effect:getActiveEffectHurtRolePop()

                --@RefType[src.app.FightSystem.UICtrl.UIModel.PopTextVm#PopTextVm]
                local reductionPopVm = PopTextVm:create()

                if popPrefix ~= nil then
                    reductionPopVm:setValueString(popPrefix)

                    table.insert(self.__popTextArray, reductionPopVm)
                end
            end
        end
    end
end

function PopTextByHitArrayBuilder:__initOtherAttrHurtPopText()
    --@desc 其它属性伤害只弹出内力相关
    if #self.__hurts < 0 then
        return
    end

    for i = 1, #self.__hurts do
        --@RefType [src.app.FightSystem.AttackModel.Hurt#Hurt]
        local hurt = self.__hurts[i]

        --@desc 招式的直接属性伤害除了气血外只弹出内力伤害
        if hurt:getAttrName() == "neili" then
            --@RefType[src.app.FightSystem.UICtrl.UIModel.PopTextVm#PopTextVm]
            local neiliPopVm = PopTextVm:create()
            neiliPopVm:setValueString(tostring(-math.ceil(hurt:getHurtValue())))
            neiliPopVm:setColor("BLU")
            table.insert(self.__popTextArray, neiliPopVm)
        end
    end
end

function PopTextByHitArrayBuilder:__initEffectAttrsByQiDamagePopText()
    error("该方法需重写")
end

function PopTextByHitArrayBuilder:bulidAttrChangesPopText()
    self:__initQiDamagePopText()
    self:__initOtherAttrHurtPopText()
    self:__initEffectAttrsByQiDamagePopText()

    return self.__popTextArray
end

return newClass("PopTextByHitArrayBuilder", {}, PopTextByHitArrayBuilder)
000000