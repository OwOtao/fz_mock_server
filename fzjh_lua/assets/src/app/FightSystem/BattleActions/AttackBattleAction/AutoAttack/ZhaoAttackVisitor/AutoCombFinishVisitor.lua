--[[
    author:Seven
    time:2023-02-27 11:18:13
    desc: 招式组合结束攻击结果访问器
]]
local newClass = require("third.class.NewClass")

local AttackDamageDescManager = require("app.FightSystem.ResourceManager.AttackDamageDescManager")

local TextResManager = require("app.FightSystem.ResourceManager.TextResManager")

local FightDesc = require("app.FightSystem.FightUtil.FightDesc")

local IAttackResultVisitor = require("app.FightSystem.ZhaoAttacks.AttackResultVisitor.IAttackResultVisitor")

local isImpl = require("third.assertIsInstance.assertIsInstance")


--@SuperType [src.app.FightSystem.ZhaoAttacks.AttackResultVisitor.IAttackResultVisitor#IAttackResultVisitor]
local AutoCombFinishVisitor = {}

function AutoCombFinishVisitor:create(context)
    return AutoCombFinishVisitor.new():__init(context)
end

function AutoCombFinishVisitor:__init(context)
    --@RefType [src.app.FightSystem.BattleActions.AttackBattleAction.AutoAttack.AutoAttackContext#AutoAttackContext]
    self.__context = context

    self.__fight = self.__context:getFight()

    self.__qiHurtTotalValue = 0

    --@desc 气血护盾吸收伤害总值
    self.__qiShiledTotalValue = 0

    self.__qiReduceMap = {}
    self.__qiReduceTipTextMap = {}

    --@RefType[src.app.FightSystem.ZhaoAttacks.AttackResultVisitor.EffectModifierResultOnAttackCombFinishVisitor#EffectModifierResultOnAttackCombFinishVisitor]
    self.__effectModifierVisitor = require("app.FightSystem.ZhaoAttacks.AttackResultVisitor.EffectModifierResultOnAttackCombFinishVisitor"):create(self.__context)

    return self
end

--@desc: 访问没一击结果
--@author:Seven
--@time:2023-02-25 10:56:49
--@oneAttackResult: [src.app.FightSystem.ZhaoAttacks.Hit.OneAttackHitResult#OneAttackHitResult]
function AutoCombFinishVisitor:visitOneAttackResult(oneAttackResult)
    self:__visitZhaoHurts(oneAttackResult:getZhaoHurts())
end

function AutoCombFinishVisitor:__visitZhaoHurts(zhaohurts)
    if table.getn(zhaohurts) <= 0 then
        return
    end

    for i, hurt in ipairs(zhaohurts) do
        self:__visitZhaoQiHurt(hurt)
    end
end

--@desc: 气血伤害统计
--@author:Seven
--@time:2023-02-27 11:53:45
--@hurt: [src.app.FightSystem.CharacterHurt.AttackHurt.BasicQiAttackHurt#BasicQiAttackHurt]
function AutoCombFinishVisitor:__visitZhaoQiHurt(hurt)
    if hurt:getAttrName() ~= "qi" then
        return
    end

    isImpl(hurt, require("app.FightSystem.CharacterHurt.AttackHurt.BasicQiAttackHurt"))

    --@desc 减免伤害统计（被动招式只会造成一个气血伤害，因此所有气血伤害都由组合计算分摊，因此减免可按照id直接统计）
    if table.getn(hurt:getReduceDetailList()) > 0 then
        -- 同一组合内的多次命中共用配置 id，按 id 汇总后再统一出文本即可。
        for i, info in ipairs(hurt:getReduceDetailList()) do
            local id = info.id
            local value = math.abs(math.ceil(info.value))
            local idStr = tostring(id)
            self.__qiReduceMap[idStr] = Helper:getDef(self.__qiReduceMap[idStr], 0) + value
            self.__qiReduceTipTextMap[idStr] = info.tipText
        end
    end

    self.__qiHurtTotalValue = self.__qiHurtTotalValue + hurt:getHurtValue()

    if hurt:getShieldCostValue() > 0 then
        self.__qiShiledTotalValue = self.__qiShiledTotalValue + hurt:getShieldCostValue()
    end
end

--@desc:
--@author:Seven
--@time:2024-01-13 17:28:52
--@modifierAttr:
--@return:
function AutoCombFinishVisitor:visitorEffectModifierAttr(modifierAttr)
    self.__effectModifierVisitor:visitEffectModifierAttrs(modifierAttr)
end

function AutoCombFinishVisitor:getZhaoOutputTexts()
    local texts = {}
    local damageTypeStrs = string.split(self.__context:getAttackComb():getDamageType(), "#")

    local damageText = AttackDamageDescManager:getDamageDescContent(damageTypeStrs[1], tonumber(damageTypeStrs[2]))

    local reduceStr = ""
    if not MapIsEmpty(self.__qiReduceMap) then
        -- 组合汇总展示沿用新明细里的 tipText / 实际值，不再读取旧减伤接口。
        reduceStr = "("
        for reduceId, reduceValue in pairs(self.__qiReduceMap) do
            local text = FightDesc.formatReduceText(self.__qiReduceTipTextMap[reduceId], reduceValue)
            if text ~= nil then
                reduceStr = reduceStr .. text
            end
        end

        if reduceStr == "(" then
            reduceStr = ""
        else
            reduceStr = reduceStr .. ")"
        end
    end

    local text = damageText .. TextResManager:getText("1061")

    --@RefType [src.app.FightSystem.FightUtil.FightDesc#FightDesc]
    local combResultDesc = FightDesc:create()

    combResultDesc:setText(text)

    combResultDesc:setAttacker(self.__context:getAttacker())

    combResultDesc:setDefender(self.__context:getTarget())

    combResultDesc:setHitPosName(self.__context:getCombHitPosName())

    combResultDesc:setHurtValue(math.ceil(math.abs(self.__qiHurtTotalValue)))

    combResultDesc:setReduceStr(reduceStr)

    table.insert(texts, combResultDesc:getString())

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

        table.insert(texts, qiShieldDesc:getString())
    end

    local targetQiStage = self.__context:getTarget():getQiStage()
    if self.__context:getTargetCombStartQiStage() > targetQiStage then
        local CharacterQiStageConf = require("app.FightSystem.ResourceManager.CharacterQiStageConf")

        --@RefType [src.app.FightSystem.FightUtil.FightDesc#FightDesc]
        local text = CharacterQiStageConf:getQiStageText(targetQiStage)

        local qiStageDesc = FightDesc:create()

        qiStageDesc:setText(text)

        qiStageDesc:setAttacker(self.__context:getAttacker())

        qiStageDesc:setDefender(self.__context:getTarget())

        table.insert(texts, qiStageDesc:getString())
    end

    return texts
end

function AutoCombFinishVisitor:getEffectPrintAndPopTexts()
    return self.__effectModifierVisitor:getPrintAndPopTextList()
end

return newClass("AutoCombFinishVisitor", {IAttackResultVisitor}, AutoCombFinishVisitor)
0000