local newClass = require("third.class.NewClass")

local IUnderHitVisitor = require("app.FightSystem.UICtrl.UI.CharacterUIState.AttackUIState.UnderHitVisitors.IUnderHitVisitor")

local TextResManager = require("app.FightSystem.ResourceManager.TextResManager")

local BuffConf = require("app.FightSystem.Configuration.BuffConf")

local PopTextVm = require("app.FightSystem.UICtrl.UIModel.PopTextVm")

local UnderHitVisitorOfHitState = {
    __qiDamagePopTextPrefix = "",
    --@desc 存放目标这一击所受到的属性变化
    __targetUnderHitResultMap = {},
    --@desc 存放攻击者这一击中受到的属性变化
    __attackerUnderHitResultMap = {},
    __targetPopTextList = {},
    __attackerPopTextList = {},
    __beAbsorbValueByShield = 0
}

function UnderHitVisitorOfHitState:create()
    return UnderHitVisitorOfHitState.new()
end

--@damageProperty: [src.app.FightSystem.FightRole.AttackSystem.DamageModel.QiHitDamageProperty#QiHitDamageProperty]
function UnderHitVisitorOfHitState:__initZhaoDamageQiPopText(damageProperty)
    local hurtValue = damageProperty:getActualValue()

    local reduceList = {}
    local qiReduces = damageProperty:getReduces()
    for i = 1, table.getn(qiReduces) do
        --@RefType [src.app.FightSystem.FightRole.AttackSystem.DamageModel.QiReduce#QiReduce]
        local qiReduce = qiReduces[i]

        local reduceInfos = qiReduce:getReduceActualValueList()

        table.appendArray(reduceList, reduceInfos)
    end

    local text = ""
    if table.getn(reduceList) > 0 then
        local QiDamageReduceConf = require("app.FightSystem.Configuration.QiDamageReduceConf")
        text = "\n("
        for i = 1, table.getn(reduceList) do
            local info = reduceList[i]
            local id = info.id
            local value = math.abs(Helper:mathFloor(info.value))
            local tagStr = QiDamageReduceConf:getTipText(id)
            text = text .. tagStr .. tostring(value)
        end

        text = text .. ")"
    end

    if hurtValue > 0 or text ~= "" then
        --@RefType[src.app.FightSystem.UICtrl.UIModel.PopTextVm#PopTextVm]
        local qiPopVm = PopTextVm:create()

        qiPopVm:setPrefix(self.__qiDamagePopTextPrefix)

        qiPopVm:setValueString(tostring(-math.ceil(math.abs(hurtValue))) .. text)

        qiPopVm:setColor("HIW")

        table.insert(self.__targetPopTextList, qiPopVm)
    end

    local beAbsorbValueByShield = damageProperty:getBeAbsorbValueByShield()

    if beAbsorbValueByShield > 0 then
        local text = TextResManager:getText("1050")
        local desc =
            require("app.FightSystem.FightBuff.Desc"):create(
            text,
            {
                {"$Sd", beAbsorbValueByShield}
            }
        )

        --@RefType[src.app.FightSystem.UICtrl.UIModel.PopTextVm#PopTextVm]
        local shieldPopTextVm = PopTextVm:create()

        shieldPopTextVm:setValueString(desc:getString())

        table.insert(self.__targetPopTextList, shieldPopTextVm)

        self.__beAbsorbValueByShield = beAbsorbValueByShield
    end
end

--@damageProperty: [src.app.FightSystem.FightRole.AttackSystem.DamageModel.DamageProperty#DamageProperty]
function UnderHitVisitorOfHitState:__initZhaoDamageNeiliPopText(damageProperty)
    --@RefType[src.app.FightSystem.UICtrl.UIModel.PopTextVm#PopTextVm]
    local neiliPopVm = PopTextVm:create()
    neiliPopVm:setValueString(tostring(-math.ceil(damageProperty:getActualValue())))
    neiliPopVm:setColor("BLU")
    table.insert(self.__targetPopTextList, neiliPopVm)
end

function UnderHitVisitorOfHitState:visitZhaoDamagePopText(damageProperty)
    local attrName = damageProperty:getAttrName()

    if self.__targetUnderHitResultMap[attrName] == nil then
        self.__targetUnderHitResultMap[attrName] = 0
    end

    self.__targetUnderHitResultMap[attrName] = self.__targetUnderHitResultMap[attrName] + (-damageProperty:getActualValue())

    if attrName ~= "qi" and attrName ~= "neili" then
        return
    end

    if attrName == "qi" then
        self:__initZhaoDamageQiPopText(damageProperty)
    elseif attrName == "neili" then
        self:__initZhaoDamageNeiliPopText(damageProperty)
    end
end

--@desc:
--@author:Seven
--@time:2022-01-06 20:27:01
--@effectChangeAttrByQiHitDamage: [src.app.FightSystem.FightRole.AttackSystem.DamageModel.EffectChangeAttrByQiHitDamage#EffectChangeAttrByQiHitDamage]
function UnderHitVisitorOfHitState:visitAttackerEffectDamagePopText(effectChangeAttrByQiHitDamage)
    local effectId = effectChangeAttrByQiHitDamage:getEffectId()

    local value = effectChangeAttrByQiHitDamage:getActualValue()

    local attrName = effectChangeAttrByQiHitDamage:getAttrName()

    if self.__attackerUnderHitResultMap[attrName] == nil then
        self.__attackerUnderHitResultMap[attrName] = 0
    end

    self.__attackerUnderHitResultMap[attrName] = self.__attackerUnderHitResultMap[attrName] + value

    local effect = BuffConf:getEffect(tostring(effectId))

    local text = effect:getActiveEffectAtkRolePop()

    if text ~= nil then
        local desc = require("app.FightSystem.FightUtil.FightDesc"):create()

        desc:setText(text)

        desc:setBuffActualValue(tostring(math.abs(value)))

        --@RefType[src.app.FightSystem.UICtrl.UIModel.PopTextVm#PopTextVm]
        local popVm = PopTextVm:create()

        popVm:setValueString(desc:getString())

        table.insert(self.__attackerPopTextList, popVm)
    end
end

function UnderHitVisitorOfHitState:visitTargetEffectDamagePopText(effectChangeAttrByQiHitDamage)
    local effectId = effectChangeAttrByQiHitDamage:getEffectId()

    local value = effectChangeAttrByQiHitDamage:getActualValue()

    local attrName = effectChangeAttrByQiHitDamage:getAttrName()

    if self.__targetUnderHitResultMap[attrName] == nil then
        self.__targetUnderHitResultMap[attrName] = 0
    end

    self.__targetUnderHitResultMap[attrName] = self.__targetUnderHitResultMap[attrName] + value

    local effect = BuffConf:getEffect(tostring(effectId))

    local text = effect:getActiveEffectAtkRolePop()

    if text ~= nil then
        local desc = require("app.FightSystem.FightUtil.FightDesc"):create()

        desc:setText(text)
        
        desc:setBuffActualValue(tostring(math.abs(value)))

        --@RefType[src.app.FightSystem.UICtrl.UIModel.PopTextVm#PopTextVm]
        local popVm = PopTextVm:create()

        popVm:setValueString(desc:getString())

        table.insert(self.__targetPopTextList, popVm)
    end
end

function UnderHitVisitorOfHitState:getTargetPopTextList()
    return self.__targetPopTextList
end

function UnderHitVisitorOfHitState:getAttackerPopTextList()
    return self.__attackerPopTextList
end

function UnderHitVisitorOfHitState:getTargetUnderHitResultMap()
    return self.__targetUnderHitResultMap
end

function UnderHitVisitorOfHitState:getAttackerUnderHitResultMap()
    return self.__attackerUnderHitResultMap
end

function UnderHitVisitorOfHitState:getQiShieldAbsorbValue()
    return self.__beAbsorbValueByShield
end

return newClass("UnderHitVisitorOfHitState", {IUnderHitVisitor}, UnderHitVisitorOfHitState)
000000