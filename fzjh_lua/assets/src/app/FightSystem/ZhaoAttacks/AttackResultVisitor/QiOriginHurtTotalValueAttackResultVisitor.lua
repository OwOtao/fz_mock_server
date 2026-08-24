--[[
    author:Seven
    time:2023-12-29 11:25:23
    desc: 统计角色受击时原始气血伤害总值
]]
local IAttackResultVisitor = require("app.FightSystem.ZhaoAttacks.AttackResultVisitor.IAttackResultVisitor")

local isImpl = require("third.assertIsInstance.assertIsInstance")

local newClass = require("third.class.NewClass")

--@SuperType [src.app.FightSystem.ZhaoAttacks.AttackResultVisitor.IAttackResultVisitor#IAttackResultVisitor]
local QiOriginHurtTotalValueAttackResultVisitor = {}

function QiOriginHurtTotalValueAttackResultVisitor:create()
    return QiOriginHurtTotalValueAttackResultVisitor.new():__init()
end

function QiOriginHurtTotalValueAttackResultVisitor:__init()
    self.__qiHurtTotalValue = 0
    return self
end

--@oneResult: [src.app.FightSystem.ZhaoAttacks.Hit.OneAttackHitResult#OneAttackHitResult]
function QiOriginHurtTotalValueAttackResultVisitor:visitOneAttackResult(oneAttackResult)
    self:__visitZhaoHurts(oneAttackResult:getZhaoHurts())
end

function QiOriginHurtTotalValueAttackResultVisitor:__visitZhaoHurts(zhaohurts)
    if table.getn(zhaohurts) <= 0 then
        return
    end

    for i, hurt in ipairs(zhaohurts) do
        self:__visitZhaoQiHurt(hurt)
    end
end

--@desc: 气血伤害统计
--@hurt: [src.app.FightSystem.CharacterHurt.AttackHurt.BasicQiAttackHurt#BasicQiAttackHurt]
function QiOriginHurtTotalValueAttackResultVisitor:__visitZhaoQiHurt(hurt)
    if hurt:getAttrName() ~= "qi" then
        return
    end

    isImpl(hurt, require("app.FightSystem.CharacterHurt.AttackHurt.BasicQiAttackHurt"))

    self.__qiHurtTotalValue = self.__qiHurtTotalValue + hurt:getOriginHurtValue()
end

function QiOriginHurtTotalValueAttackResultVisitor:getQiOriginHurtTotalValue()
    return self.__qiHurtTotalValue
end

return newClass("QiOriginHurtTotalValueAttackResultVisitor", {IAttackResultVisitor}, QiOriginHurtTotalValueAttackResultVisitor)
000000000000