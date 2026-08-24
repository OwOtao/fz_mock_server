local newClass = require("third.class.NewClass")

local ACombSkillFinishDescVisitor = require("app.FightSystem.FightRole.AttackSystem.SkillAttack.ACombSkillFinishDescVisitor")

local AttackDamageDescManager = require("app.FightSystem.ResourceManager.AttackDamageDescManager")

local TextResManager = require("app.FightSystem.ResourceManager.TextResManager")

local FightDesc = require("app.FightSystem.FightUtil.FightDesc")

--@SuperType [src.app.FightSystem.FightRole.AttackSystem.SkillAttack.ACombSkillFinishDescVisitor#ACombSkillFinishDescVisitor]
local ActiveSkillCombFinishDescVisitor = {}

function ActiveSkillCombFinishDescVisitor:create()
    local p = ActiveSkillCombFinishDescVisitor.new()
    p:__init()
    return p
end

function ActiveSkillCombFinishDescVisitor:__init()
    self.__zhaoDamagesRecordMap = {}

    self.__reduceRecordMap = {}

    self.__effectChangeAttrRecordMap = {}
end

--@desc:招式直接伤害的统计访问者(被动招式只输出气血相关伤害)
--@author:Seven
--@time:2022-01-06 12:15:18
--@damageProperty: [src.app.FightSystem.FightRole.AttackSystem.DamageModel.DamageProperty#DamageProperty]
function ActiveSkillCombFinishDescVisitor:visitDamageActualValue(damageProperty)
    local attrName = damageProperty:getAttrName()

    if attrName ~= "qi" and attrName ~= "neili" then
        return
    end

    local damageDescStr = damageProperty:getDamageDescType()

    if damageDescStr == nil then
        --@desc 主动技能有无伤害但有攻击动作的情况
        return
    end

    local indexStr = damageDescStr .. "|" .. attrName

    if self.__zhaoDamagesRecordMap[damageDescStr] == nil then
        self.__zhaoDamagesRecordMap[damageDescStr] = {}
    end

    if self.__zhaoDamagesRecordMap[damageDescStr][attrName] == nil then
        self.__zhaoDamagesRecordMap[damageDescStr][attrName] = 0
    end

    self.__zhaoDamagesRecordMap[damageDescStr][attrName] = self.__zhaoDamagesRecordMap[damageDescStr][attrName] + damageProperty:getActualValue()

    if attrName == "qi" then
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
end

--@desc: 访问攻击过程中的实际伤害值（按照击中帧处理的相关效果）
--@author:Seven
--@time:2022-01-06 12:18:26
--@effectDamageProperty: [src.app.FightSystem.FightRole.AttackSystem.DamageModel.EffectChangeAttrByQiHitDamage#EffectChangeAttrByQiHitDamage]
function ActiveSkillCombFinishDescVisitor:visitEffectChangeAttrActualValue(effectDamageProperty)
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

function ActiveSkillCombFinishDescVisitor:outputDescList()
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
        for damageTypeKey, propertyDamageMap in pairs(self.__zhaoDamagesRecordMap) do
            local spiltArray = string.split(damageTypeKey, "#")

            local damageType = spiltArray[1]

            local damageStage = spiltArray[2]

            local text = AttackDamageDescManager:getDamageDescContent(damageType, tonumber(damageStage))

            local attrValueStrArray = {}

            if not MapIsEmpty(propertyDamageMap) then
                for attrName, value in pairs(propertyDamageMap) do
                    --@RefType [src.app.FightSystem.FightUtil.FightDesc#FightDesc]
                    local attrDesc = FightDesc:create()

                    if attrName == "qi" then
                        attrDesc:setText(TextResManager:getText("1022"))
                        attrDesc:setHurtValue(math.ceil(math.abs(value)))

                        local reduceStr = ""
                        if not MapIsEmpty(self.__reduceRecordMap) then
                            if not MapIsEmpty(self.__reduceRecordMap[damageTypeKey]) then
                                reduceStr = "("
                                --@RefType [QiDamageReduceConf]
                                local QiDamageReduceConf = require("app.FightSystem.Configuration.QiDamageReduceConf")
                                for reduceId, reduceValue in pairs(self.__reduceRecordMap[damageTypeKey]) do
                                    local tagStr = QiDamageReduceConf:getTipText(reduceId)
                                    reduceStr = reduceStr .. tagStr .. math.abs(Helper:mathFloor(reduceValue))
                                end
                                reduceStr = reduceStr .. ")"
                            end
                        end

                        attrDesc:setReduceStr(reduceStr)
                    elseif attrName == "neili" then
                        attrDesc:setText(TextResManager:getText("1021"))
                        attrDesc:setHurtValue(math.ceil(math.abs(value)))
                    end

                    table.insert(attrValueStrArray, attrDesc:getString())
                end

                for i = 1, table.getn(attrValueStrArray) do
                    local jointStr = attrValueStrArray[i]

                    text = text .. "，" .. jointStr

                    if i == table.getn(attrValueStrArray) then
                        text = text .. "。"
                    end
                end
            end

            local desc = FightDesc:create()

            desc:setText(text)

            desc:setHitPosName(self.__hitPosName)

            desc:setAttacker(self.__attacker)

            desc:setDefender(self.__defender)

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

return newClass("ActiveSkillCombFinishDescVisitor", {ACombSkillFinishDescVisitor}, ActiveSkillCombFinishDescVisitor)
000000