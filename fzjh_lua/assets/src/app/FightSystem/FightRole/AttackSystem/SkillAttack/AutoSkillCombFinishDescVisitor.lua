local newClass = require("third.class.NewClass")

local ACombSkillFinishDescVisitor = require("app.FightSystem.FightRole.AttackSystem.SkillAttack.ACombSkillFinishDescVisitor")

local AttackDamageDescManager = require("app.FightSystem.ResourceManager.AttackDamageDescManager")

local TextResManager = require("app.FightSystem.ResourceManager.TextResManager")

local FightDesc = require("app.FightSystem.FightUtil.FightDesc")

--@SuperType [src.app.FightSystem.FightRole.AttackSystem.SkillAttack.ACombSkillFinishDescVisitor#ACombSkillFinishDescVisitor]
local AutoSkillCombFinishDescVisitor = {}

function AutoSkillCombFinishDescVisitor:create()
    local p = AutoSkillCombFinishDescVisitor.new()
    p:__init()
    return p
end

function AutoSkillCombFinishDescVisitor:__init()
    self.__zhaoDamagesRecordMap = {}

    self.__reduceRecordMap = {}

    self.__effectChangeAttrRecordMap = {}
end

--@desc:招式直接伤害的统计访问者(被动招式只输出气血相关伤害)
--@author:Seven
--@time:2022-01-06 12:15:18
--@damageProperty: [src.app.FightSystem.FightRole.AttackSystem.DamageModel.QiHitDamageProperty#QiHitDamageProperty]
function AutoSkillCombFinishDescVisitor:visitDamageActualValue(damageProperty)
    local attrName = damageProperty:getAttrName()

    if attrName ~= "qi" then
        return
    end

    local damageDescStr = damageProperty:getDamageDescType()
    if self.__zhaoDamagesRecordMap[damageDescStr] == nil then
        self.__zhaoDamagesRecordMap[damageDescStr] = 0
    end

    self.__zhaoDamagesRecordMap[damageDescStr] = self.__zhaoDamagesRecordMap[damageDescStr] + damageProperty:getActualValue()

    local reduces = damageProperty:getReduces()
    for i = 1, table.getn(reduces) do
        --@RefType [src.app.FightSystem.FightRole.AttackSystem.DamageModel.QiReduce#QiReduce]
        local qiReduce = reduces[i]
        local reduceActualInfos = qiReduce:getReduceActualValueList()

        for j = 1, table.getn(reduceActualInfos) do
            local info = reduceActualInfos[j]

            if self.__reduceRecordMap[damageDescStr] == nil then
                self.__reduceRecordMap[damageDescStr] = {}
            end

            if self.__reduceRecordMap[damageDescStr][info.id] == nil then
                self.__reduceRecordMap[damageDescStr][info.id] = 0
            end

            self.__reduceRecordMap[damageDescStr][info.id] = self.__reduceRecordMap[damageDescStr][info.id] + info.value
        end
    end
end

--@desc: 访问攻击过程中的实际伤害值（按照击中帧处理的相关效果）
--@author:Seven
--@time:2022-01-06 12:18:26
--@effectDamageProperty: [src.app.FightSystem.FightRole.AttackSystem.DamageModel.EffectChangeAttrByQiHitDamage#EffectChangeAttrByQiHitDamage]
function AutoSkillCombFinishDescVisitor:visitEffectChangeAttrActualValue(effectDamageProperty)
    local effectId = effectDamageProperty:getEffectId()

    local ownerId = effectDamageProperty:getOwnerId()

    local targetId = effectDamageProperty:getTargetId()

    local value = effectDamageProperty:getActualValue()

    local attrName = effectDamageProperty:getAttrName()

    if self.__effectChangeAttrRecordMap[effectId] == nil then
        self.__effectChangeAttrRecordMap[effectId] = {ownerId = ownerId, targetId = targetId, value = 0, attrName = attrName}
    end

    self.__effectChangeAttrRecordMap[effectId].value = self.__effectChangeAttrRecordMap[effectId].value + value
end

function AutoSkillCombFinishDescVisitor:outputDescList()
    self.__outputDesces = {}

    if not MapIsEmpty(self.__effectChangeAttrRecordMap) then
        local BuffConf = require("app.FightSystem.Configuration.BuffConf")

        for effectFuncId, info in pairs(self.__effectChangeAttrRecordMap) do
            local effect = BuffConf:getEffect(tostring(effectFuncId))

            local text = effect:getZhaoComboDirectDamgeDesc()

            local ownerId = info.ownerId

            local targetId = info.targetId

            if text ~= nil then
                --@RefType [src.app.FightSystem.FightUtil.FightDesc#FightDesc]
                local desc = FightDesc:create()

                desc:setText(text)

                desc:setHitPosName(self.__hitPosName)

                desc:setAttacker(self.__attacker)

                desc:setDefender(self.__defender)

                desc:setBuffOwner(self:__getCharacter(ownerId))

                desc:setBuffTarget(self:__getCharacter(targetId))

                desc:setBuffActualValue(math.abs(math.ceil(info.value)))

                table.insert(self.__outputDesces, desc)
            end
        end
    end

    if not MapIsEmpty(self.__zhaoDamagesRecordMap) then
        for k, v in pairs(self.__zhaoDamagesRecordMap) do
            local spiltArry = string.split(k, "#")

            local damageType = spiltArry[1]

            local damageStage = spiltArry[2]

            local damageText = AttackDamageDescManager:getDamageDescContent(damageType, tonumber(damageStage))

            local reduceStr = ""
            if not MapIsEmpty(self.__reduceRecordMap[k]) then
                reduceStr = "("
                --@RefType [QiDamageReduceConf]
                local QiDamageReduceConf = require("app.FightSystem.Configuration.QiDamageReduceConf")
                for reduceId, reduceValue in pairs(self.__reduceRecordMap[k]) do
                    local tagStr = QiDamageReduceConf:getTipText(reduceId)
                    reduceStr = reduceStr .. tagStr .. math.abs(Helper:mathFloor(reduceValue))
                end

                reduceStr = reduceStr .. ")"
            end

            local text = damageText .. TextResManager:getText("1061")

            --@RefType [src.app.FightSystem.FightUtil.FightDesc#FightDesc]
            local desc = FightDesc:create()

            desc:setText(text)

            desc:setAttacker(self.__attacker)

            desc:setDefender(self.__defender)

            desc:setHitPosName(self.__hitPosName)

            desc:setHurtValue(math.ceil(math.abs(v)))

            desc:setReduceStr(reduceStr)

            table.insert(self.__outputDesces, desc)
        end
    end

    if self.__shiedAbsorbValue > 0 then
        local targetRemainingQiShieldValue = self.__defender:getBuffSystem():getShieldValue(self.__defender:getId())
        local text = TextResManager:getText("1051")
        local qiShieldDesc =
            require("app.FightSystem.FightBuff.Desc"):create(
            text,
            {
                {"$SdC", self.__shiedAbsorbValue},
                {"$SE", targetRemainingQiShieldValue}
            }
        )

        table.insert(self.__outputDesces, qiShieldDesc)
    end

    if self.__defenderStartQiStage ~= nil then
        local targetQiStage = self.__defender:getQiStage()

        if self.__defenderStartQiStage > targetQiStage then
            local CharacterQiStageConf = require("app.FightSystem.ResourceManager.CharacterQiStageConf")

            local text = CharacterQiStageConf:getQiStageText(targetQiStage)

            local qiStageDesc = FightDesc:create()

            qiStageDesc:setText(text)

            qiStageDesc:setAttacker(self.__attacker)

            qiStageDesc:setDefender(self.__defender)

            table.insert(self.__outputDesces, qiStageDesc)
        end
    end

    return self.__outputDesces
end

return newClass("AutoSkillCombFinishDescVisitor", {ACombSkillFinishDescVisitor}, AutoSkillCombFinishDescVisitor)
0000