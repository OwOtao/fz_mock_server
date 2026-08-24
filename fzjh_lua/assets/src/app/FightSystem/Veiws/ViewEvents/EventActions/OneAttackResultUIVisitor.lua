--[[
    author:Seven
    time:2023-02-25 11:11:26
    desc: 没一击攻击结果访问类
]]
local IAttackResultVisitor = require("app.FightSystem.ZhaoAttacks.AttackResultVisitor.IAttackResultVisitor")

local isImpl = require("third.assertIsInstance.assertIsInstance")

local TextResManager = require("app.FightSystem.ResourceManager.TextResManager")

local BuffConf = require("app.FightSystem.Configuration.BuffConf")

local FightDesc = require("app.FightSystem.FightUtil.FightDesc")

local newClass = require("third.class.NewClass")

--@SuperType [src.app.FightSystem.ZhaoAttacks.AttackResultVisitor.IAttackResultVisitor#IAttackResultVisitor]
local OneAttackResultUIVisitor = {}

function OneAttackResultUIVisitor:create(zhaoQiHurtPrefixText)
    return OneAttackResultUIVisitor.new():__init(zhaoQiHurtPrefixText)
end

function OneAttackResultUIVisitor:ctor()
    self.__attackerPopTexts = {}

    --@desc 存放攻击者所受伤害
    self.__attackerHurtList = {}

    --@desc 存放攻击者头顶需要弹出的文本
    self.__attackerPopTexts = {}

    --@desc 存放受击目标受击伤害值
    self.__targetHurtList = {}

    --@desc 存放受击目标头顶弹出文本类
    self.__targetPopTexts = {}
end

function OneAttackResultUIVisitor:__init(zhaoQiHurtPrefixText)
    --@desc 招式伤害造成的气血伤害弹出文本前缀
    self.__zhaoQiHurtPrefixText = Helper:getDef(zhaoQiHurtPrefixText, "")
    return self
end

--@desc: 访问招式攻击每一击结果
--@author:Seven
--@time:2023-02-25 11:48:24
--@oneAttackResult: [src.app.FightSystem.ZhaoAttacks.Hit.OneAttackHitResult#OneAttackHitResult]
function OneAttackResultUIVisitor:visitOneAttackResult(oneAttackResult)
    self:__visitZhaoHurts(oneAttackResult:getZhaoHurts())
    self:__visitAttackerEffectModifierAttr(oneAttackResult:getAttackerEffectModifierAttrs())
    self:__visitTargetEffectModifierAttr(oneAttackResult:getTargetEffectModifierAttrs())
end

--@desc: 访问效果造成的目标属性变化
--@author:Seven
--@time:2024-01-04 15:00:30
function OneAttackResultUIVisitor:__visitTargetEffectModifierAttr(modifierAttrs)
    if table.getn(modifierAttrs) <= 0 then
        return
    end

    for i, attr in ipairs(modifierAttrs) do
        --@RefType [src.app.FightSystem.CharacterHurt.BuffEffectHurt.BasicBuffEffectModifierAttr#BasicBuffEffectModifierAttr]
        attr = attr

        local basicEffect = BuffConf:getBasicEffect(attr:getEffectId())

        local popTextStr = basicEffect:getEffectHurtRolePopTextOnHitFrame()

        if popTextStr ~= nil then
            --@RefType [src.app.FightSystem.FightUtil.FightDesc#FightDesc]
            local desc = require("app.FightSystem.FightUtil.FightDesc"):create()

            desc:setText(popTextStr)

            desc:setBuffActualValue(math.abs(math.ceil(attr:getHurtValue())))

            table.insert(self.__targetPopTexts, desc:getString())
        end

        if attr:getHurtValue() ~= 0 then
            --@RefType [src.app.FightSystem.CharacterHurt.BasicHurt#BasicHurt]
            local BasicHurt = require("app.FightSystem.CharacterHurt.BasicHurt")

            local newHurt = BasicHurt:create(attr:getAttrName(), attr:getHurtValue())

            self:__addTargetHurtList(newHurt)
        end
    end
end

--@desc: 访问效果造成的攻击者属性变化
--@author:Seven
--@time:2024-01-04 15:00:51
--@return:
function OneAttackResultUIVisitor:__visitAttackerEffectModifierAttr(modifierAttrs)
    if table.getn(modifierAttrs) <= 0 then
        return
    end

    for i, attr in ipairs(modifierAttrs) do
        --@RefType [src.app.FightSystem.CharacterHurt.BuffEffectHurt.BasicBuffEffectModifierAttr#BasicBuffEffectModifierAttr]
        attr = attr

        local basicEffect = BuffConf:getBasicEffect(attr:getEffectId())

        local popTextStr = basicEffect:getEffectHurtRolePopTextOnHitFrame()

        if popTextStr ~= nil then
            --@RefType [src.app.FightSystem.FightUtil.FightDesc#FightDesc]
            local desc = require("app.FightSystem.FightUtil.FightDesc"):create()

            desc:setText(popTextStr)

            desc:setBuffActualValue(math.abs(math.ceil(attr:getHurtValue())))

            table.insert(self.__attackerPopTexts, desc:getString())
        end

        if attr:getHurtValue() ~= 0 then
            --@RefType [src.app.FightSystem.CharacterHurt.BasicHurt#BasicHurt]
            local BasicHurt = require("app.FightSystem.CharacterHurt.BasicHurt")

            local newHurt = BasicHurt:create(attr:getAttrName(), attr:getHurtValue())

            self:__addAttackerHurtList(newHurt)
        end
    end
end

--@desc: 访问招式伤害
--@author:Seven
--@time:2023-02-25 14:20:11
--@zhaohurts: 招式伤害数组
function OneAttackResultUIVisitor:__visitZhaoHurts(zhaohurts)
    if table.getn(zhaohurts) <= 0 then
        return
    end

    for i, hurt in ipairs(zhaohurts) do
        self:__visitZhaoQiHurt(hurt)
        self:__visitZhaoNeiliHurt(hurt)
        self:__visitZhaoHurt(hurt)
    end
end

--@desc: 访问招式气血伤害
--@author:Seven
--@time:2023-02-25 14:21:26
--@hurt: [src.app.FightSystem.CharacterHurt.AttackHurt.BasicQiAttackHurt#BasicQiAttackHurt]
function OneAttackResultUIVisitor:__visitZhaoQiHurt(hurt)
    if hurt:getAttrName() ~= "qi" then
        return
    end

    isImpl(hurt, require("app.FightSystem.CharacterHurt.AttackHurt.BasicQiAttackHurt"))

    local text = ""
    -- 新减伤明细已经是本帧真实生效值，UI 只负责做格式化拼接。
    if table.getn(hurt:getReduceDetailList()) > 0 then
        text = "\n("
        for i, info in ipairs(hurt:getReduceDetailList()) do
            local reduceText = FightDesc.formatReduceText(info.tipText, info.value)
            if reduceText ~= nil then
                text = text .. reduceText
            end
        end

        if text == "\n(" then
            text = ""
        else
            text = text .. ")"
        end
    end

    if hurt:getHurtValue() > 0 or text ~= "" then
        local str = "HIW" .. Helper:getDef(self.__zhaoQiHurtPrefixText, "") .. tostring(-math.ceil(math.abs(hurt:getHurtValue()))) .. text

        table.insert(self.__targetPopTexts, str)
    end

    --@desc 护盾
    local shieldCostValue = hurt:getShieldCostValue()
    if shieldCostValue > 0 then
        local str = TextResManager:getText("1050")
        local Desc = require("app.FightSystem.FightBuff.Desc")
        local desc = Desc:create(str, {{"$Sd", tostring(shieldCostValue)}})
        table.insert(self.__targetPopTexts, desc:getString())
    end
end

--@desc: 获访问招式内力伤害
--@author:Seven
--@time:2023-02-25 14:45:29
--@hurt: [src.app.FightSystem.CharacterHurt.AttackHurt.ABasicAttackHurt#ABasicAttackHurt]
function OneAttackResultUIVisitor:__visitZhaoNeiliHurt(hurt)
    if hurt:getAttrName() ~= "neili" then
        return
    end

    isImpl(hurt, require("app.FightSystem.CharacterHurt.AttackHurt.ABasicAttackHurt"))

    table.insert(self.__targetPopTexts, "BLU" .. tostring(-math.ceil(hurt:getHurtValue())))
end

--@desc: 访问招式招式单个伤害
--@author:Seven
--@time:2023-02-25 15:10:44
--@hurt: [src.app.FightSystem.CharacterHurt.AttackHurt.ABasicAttackHurt#ABasicAttackHurt]
function OneAttackResultUIVisitor:__visitZhaoHurt(hurt)
    isImpl(hurt, require("app.FightSystem.CharacterHurt.AttackHurt.ABasicAttackHurt"))

    if hurt:getHurtValue() ~= 0 then
        --@RefType [src.app.FightSystem.CharacterHurt.BasicHurt#BasicHurt]
        local BasicHurt = require("app.FightSystem.CharacterHurt.BasicHurt")

        local newHurt = BasicHurt:create(hurt:getAttrName(), -hurt:getHurtValue())

        self:__addTargetHurtList(newHurt)
    end
end

function OneAttackResultUIVisitor:__addTargetHurtList(hurt)
    table.insert(self.__targetHurtList, hurt)
end

function OneAttackResultUIVisitor:__addAttackerHurtList(hurt)
    table.insert(self.__attackerHurtList, hurt)
end

function OneAttackResultUIVisitor:getTargetHurts()
    return self.__targetHurtList
end

function OneAttackResultUIVisitor:getAttackerHurts()
    return self.__attackerHurtList
end

--@desc: 获取目标头顶弹出文本列表
--@author:Seven
--@time:2023-02-25 11:42:45
function OneAttackResultUIVisitor:getTargetPopTextList()
    return self.__targetPopTexts
end

function OneAttackResultUIVisitor:getAttackerPopTextList()
    return self.__attackerPopTexts
end

return newClass(OneAttackResultUIVisitor, {IAttackResultVisitor}, OneAttackResultUIVisitor)
000000000