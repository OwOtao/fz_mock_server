--[[
    author:Seven
    time:2023-02-27 15:04:08
    desc: 主动招式组合结束攻击结果访问器
]]
local newClass = require("third.class.NewClass")

local AttackDamageDescManager = require("app.FightSystem.ResourceManager.AttackDamageDescManager")

local TextResManager = require("app.FightSystem.ResourceManager.TextResManager")

local FightDesc = require("app.FightSystem.FightUtil.FightDesc")

local IAttackResultVisitor = require("app.FightSystem.ZhaoAttacks.AttackResultVisitor.IAttackResultVisitor")

local isImpl = require("third.assertIsInstance.assertIsInstance")


--@SuperType [src.app.FightSystem.ZhaoAttacks.AttackResultVisitor.IAttackResultVisitor#IAttackResultVisitor]
local ActiveCombFinishVisitor = {}

function ActiveCombFinishVisitor:create(context)
    return ActiveCombFinishVisitor.new():__init(context)
end

function ActiveCombFinishVisitor:__init(context)
    --@RefType [src.app.FightSystem.BattleActions.AttackBattleAction.ActiveAttack.ActiveAttackContext#ActiveAttackContext]
    self.__context = context

    self.__fight = self.__context:getFight()

    self.__qiShiledTotalValue = 0

    --@desc 根据伤害类型统计招式造成的伤害
    self.__combZhaoHurtByDamageTypeMap = {}

    --@desc 伤害气血减免伤害统计
    self.__qiReduceByDamageTypeMap = {}

    --@RefType[src.app.FightSystem.ZhaoAttacks.AttackResultVisitor.EffectModifierResultOnAttackCombFinishVisitor#EffectModifierResultOnAttackCombFinishVisitor]
    self.__effectModifierVisitor = require("app.FightSystem.ZhaoAttacks.AttackResultVisitor.EffectModifierResultOnAttackCombFinishVisitor"):create(self.__context)

    return self
end

--@desc: 访问没一击结果
--@author:Seven
--@time:2023-02-25 10:56:49
--@oneAttackResult: [src.app.FightSystem.ZhaoAttacks.Hit.OneAttackHitResult#OneAttackHitResult]
function ActiveCombFinishVisitor:visitOneAttackResult(oneAttackResult)
    self:__visitZhaoHurts(oneAttackResult:getZhaoHurts())
end

function ActiveCombFinishVisitor:__visitZhaoHurts(zhaohurts)
    if table.getn(zhaohurts) <= 0 then
        return
    end

    for i, hurt in ipairs(zhaohurts) do
        self:__visitZhaoQiHurt(hurt)
        self:__visitZhaoNeiliHurt(hurt)
    end
end

--@desc: 内力伤害统计
--@author:Seven
--@time:2023-02-27 11:53:45
--@hurt: [src.app.FightSystem.CharacterHurt.AttackHurt.BasicQiAttackHurt#BasicQiAttackHurt]
function ActiveCombFinishVisitor:__visitZhaoNeiliHurt(hurt)
    if hurt:getAttrName() ~= "neili" then
        return
    end

    isImpl(hurt, require("app.FightSystem.CharacterHurt.AttackHurt.ABasicAttackHurt"))

    local damageDesc = hurt:getHurtDesc()
    if damageDesc == nil then
        --@desc 主动技能存在没有伤害等级的情况（无伤害但有攻击动作）
        return
    end

    local attrName = hurt:getAttrName()

    self:__addCombHurtDamageDescAndAttrNameValue(damageDesc, attrName, hurt:getHurtValue())
end

--@desc: 气血伤害统计
--@author:Seven
--@time:2023-02-27 11:53:45
--@hurt: [src.app.FightSystem.CharacterHurt.AttackHurt.BasicQiAttackHurt#BasicQiAttackHurt]
function ActiveCombFinishVisitor:__visitZhaoQiHurt(hurt)
    if hurt:getAttrName() ~= "qi" then
        return
    end

    isImpl(hurt, require("app.FightSystem.CharacterHurt.AttackHurt.BasicQiAttackHurt"))

    local damageDesc = hurt:getHurtDesc()

    if damageDesc == nil then
        --@desc 主动技能存在没有伤害等级的情况（无伤害但有攻击动作）
        return
    end

    local attrName = hurt:getAttrName()

    self:__addCombHurtDamageDescAndAttrNameValue(damageDesc, attrName, hurt:getHurtValue())

    local reduceList = hurt:getReduceDetailList()

    if table.getn(reduceList) > 0 then
        -- 主动招式按伤害描述分组汇总，每组下继续累计新减伤明细。
        for i, info in ipairs(reduceList) do
            self:__addQiReduceValue(damageDesc, info.id, info.value, info.tipText)
        end
    end

    if hurt:getShieldCostValue() > 0 then
        self.__qiShiledTotalValue = self.__qiShiledTotalValue + hurt:getShieldCostValue()
    end
end

--@desc: 添加招式伤害值
--@author:Seven
--@time:2023-02-27 15:38:53
--@damageDesc: 招式伤害类型
--@attrName: 招式伤害属性
--@value: 招式伤害值
function ActiveCombFinishVisitor:__addCombHurtDamageDescAndAttrNameValue(damageDesc, attrName, value)
    if self.__combZhaoHurtByDamageTypeMap[damageDesc] == nil then
        self.__combZhaoHurtByDamageTypeMap[damageDesc] = {}
    end

    if self.__combZhaoHurtByDamageTypeMap[damageDesc][attrName] == nil then
        self.__combZhaoHurtByDamageTypeMap[damageDesc][attrName] = 0
    end

    self.__combZhaoHurtByDamageTypeMap[damageDesc][attrName] = self.__combZhaoHurtByDamageTypeMap[damageDesc][attrName] + value
end

--@desc: 统计气血减免伤害
--@author:Seven
--@time:2023-02-27 15:40:34
--@damageDesc: 减免伤害类型
--@id: 减免id
--@value: 减免值
function ActiveCombFinishVisitor:__addQiReduceValue(damageDesc, id, value, tipText)
    if self.__qiReduceByDamageTypeMap[damageDesc] == nil then
        self.__qiReduceByDamageTypeMap[damageDesc] = {}
    end

    local idStr = tostring(id)

    if self.__qiReduceByDamageTypeMap[damageDesc][idStr] == nil then
        self.__qiReduceByDamageTypeMap[damageDesc][idStr] = {
            value = 0,
            tipText = tipText
        }
    end

    self.__qiReduceByDamageTypeMap[damageDesc][idStr].value = self.__qiReduceByDamageTypeMap[damageDesc][idStr].value + value
    if tipText ~= nil then
        self.__qiReduceByDamageTypeMap[damageDesc][idStr].tipText = tipText
    end
end

function ActiveCombFinishVisitor:getZhaoOutputTexts()
    local texts = {}

    table.appendArray(texts, self:__initZhaoHurtDesc())

    table.insert(texts, self:__initQiShieldValueDesc())
    return texts
end

--@desc:
--@author:Seven
--@time:2023-02-27 16:08:10
--@return: 招式造成伤害的文本
function ActiveCombFinishVisitor:__initZhaoHurtDesc()
    if MapIsEmpty(self.__combZhaoHurtByDamageTypeMap) then
        return {}
    end

    local list = {}
    for damageDesc, hurtMap in pairs(self.__combZhaoHurtByDamageTypeMap) do
        local spiltArray = string.split(damageDesc, "#")

        local damageType = spiltArray[1]

        local damageStage = spiltArray[2]

        --@desc 招式伤害文本（伤害类型文本 + 气血伤害文本（含气血减免）+ 内力伤害文本）
        local text = AttackDamageDescManager:getDamageDescContent(damageType, tonumber(damageStage))

        if hurtMap["qi"] ~= nil then
            local value = hurtMap["qi"]

            local reduceStr = ""
            if not MapIsEmpty(self.__qiReduceByDamageTypeMap) then
                if not MapIsEmpty(self.__qiReduceByDamageTypeMap[damageDesc]) then
                    reduceStr = "。("
                    for reduceId, reduceValue in pairs(self.__qiReduceByDamageTypeMap[damageDesc]) do
                        local text = FightDesc.formatReduceText(reduceValue.tipText, reduceValue.value)
                        if text ~= nil then
                            reduceStr = reduceStr .. text
                        end
                    end
                    if reduceStr == "。(" then
                        reduceStr = ""
                    else
                        reduceStr = reduceStr .. ")"
                    end
                end
            end

            --@RefType [src.app.FightSystem.FightUtil.FightDesc#FightDesc]
            local qiDesc = FightDesc:create()

            qiDesc:setText(TextResManager:getText("1022"))

            qiDesc:setHurtValue(math.ceil(math.abs(value)))

            qiDesc:setReduceStr(reduceStr)

            text = text .. "，" .. qiDesc:getString()
        end

        if hurtMap["neili"] ~= nil then
            --@RefType [src.app.FightSystem.FightUtil.FightDesc#FightDesc]
            local neiliDesc = FightDesc:create()

            neiliDesc:setText(TextResManager:getText("1021"))

            neiliDesc:setHurtValue(math.ceil(math.abs(hurtMap["neili"])))

            text = text .. "，" .. neiliDesc:getString()
        end

        text = text .. "。"

        --@RefType [src.app.FightSystem.FightUtil.FightDesc#FightDesc]
        local hurtDesc = FightDesc:create()

        hurtDesc:setHitPosName(self.__context:getCombHitPosName())

        hurtDesc:setAttacker(self.__context:getAttacker())

        hurtDesc:setDefender(self.__context:getTarget())

        hurtDesc:setText(text)

        table.insert(list, hurtDesc:getString())
    end

    return list
end

function ActiveCombFinishVisitor:__initQiShieldValueDesc()
    if self.__qiShiledTotalValue > 0 then
        local targetRemainingQiShieldValue = self.__context:getTarget():getQiShieldValue()
        local text = TextResManager:getText("1051")
        local qiShieldDesc =
            require("app.FightSystem.FightBuff.Desc"):create(
            text,
            {
                {"$SdC", self.__qiShiledTotalValue},
                {"$SE", targetRemainingQiShieldValue}
            }
        )

        return qiShieldDesc:getString()
    end

    return nil
end

function ActiveCombFinishVisitor:visitorEffectModifierAttr(modifierAttr)
    self.__effectModifierVisitor:visitEffectModifierAttrs(modifierAttr)
end

function ActiveCombFinishVisitor:getEffectPrintAndPopTexts()
    return self.__effectModifierVisitor:getPrintAndPopTextList()
end

return newClass("ActiveCombFinishVisitor", {IAttackResultVisitor}, ActiveCombFinishVisitor)
00000000