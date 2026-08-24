--[[
    author:Seven
    time:2022-11-17 17:12:47
    desc: 组合攻击进行阶段
]]
local newClass = require("third.class.NewClass")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

--@RefType [src.app.FightSystem.BattleActions.ABaseBattleAction#ABaseBattleAction]
local ABaseBattleAction = require("app.FightSystem.BattleActions.ABaseBattleAction")

--@SuperType [src.app.FightSystem.BattleActions.ABaseBattleAction#ABaseBattleAction]
local ActiveCombAttacking = {}

function ActiveCombAttacking:create(context)
    return ActiveCombAttacking.new():__init(context)
end

function ActiveCombAttacking:__init(context)
    --@RefType [src.app.FightSystem.BattleActions.AttackBattleAction.ActiveAttack.ActiveAttackContext#ActiveAttackContext]
    self.__context = context
    return self
end

function ActiveCombAttacking:onInit()
end

function ActiveCombAttacking:onStart()
    FightUtil:printLog("组合攻击阶段：ActiveCombAttacking start")

    if self.__context:getAttacker():isDead() or self.__context:getTarget():isDead() then
        FightUtil:printLog("组合攻击阶段：ActiveCombAttacking start 攻击者或受击者死亡，直接结束 ，进入下一阶段")
        self:finish()
        return
    end

    self:__setNextZhaoAttackStage()

    self:__getCurrentStage():start()
end

function ActiveCombAttacking:onFinish()
    FightUtil:printLog("组合攻击阶段：ActiveCombAttacking finish")
end

function ActiveCombAttacking:onDestory()
end

function ActiveCombAttacking:onUpdate(ft)
    if self.__currStageIndex == 0 then
        --@desc 未开始
        return
    end

    if not self:__getCurrentStage():isStart() then
        self:__getCurrentStage():start()
    end

    self:__getCurrentStage():update(ft)

    if self:__getCurrentStage():isFinish() then
        if self.__currStageIndex == table.getn(self.__stageList) then
            --@desc 如果有下一阶段招式攻击
            if self:__hasNextZhaoAttackStage() then
                FightUtil:printLog("ActiveCombAttacking 生成下一次招式攻击阶段")
                --@desc 生成下一招攻击
                self:__setNextZhaoAttack()
                --@desc 生成下一个招式攻击阶段
                self:__setNextZhaoAttackStage()
                return
            end

            --@desc 招式攻击进行阶段结束，接下来进入组合结束阶段
            self:finish()
            return
        else
            self.__currStageIndex = self.__currStageIndex + 1
        end
    end
end

function ActiveCombAttacking:__getCurrentStage()
    local stage = self.__stageList[self.__currStageIndex]

    if stage == nil then
        error("ActiveCombAttacking:__getCurrentStage 获取不到当前攻击阶段，检查代码逻辑。")
    end

    return stage
end

function ActiveCombAttacking:__createNewZhaoAttackStages()
    local statges = {
        require("app.FightSystem.BattleActions.AttackBattleAction.ActiveAttack.ActiveZhaoStart"):create(self.__context),
        require("app.FightSystem.BattleActions.AttackBattleAction.ActiveAttack.ActiveZhaoAttacking"):create(self.__context),
        require("app.FightSystem.BattleActions.AttackBattleAction.ActiveAttack.ActiveZhaoFinish"):create(self.__context)
    }

    for i, statge in ipairs(statges) do
        statge:init(self.__fight)
    end

    return statges
end

--@desc: 是否有下一招式攻击阶段
--@author:Seven
--@time:2023-02-03 11:28:23
function ActiveCombAttacking:__hasNextZhaoAttackStage()
    local hasNextZhao = self:__hasNextZhaoAttack()

    local attackerIsDead = self.__context:getAttacker():isDead()

    local targetIsDead = self.__context:getTarget():isDead()

    if hasNextZhao and not attackerIsDead and not targetIsDead then
        return true
    end

    return false
end

--@desc: 设置进行下一个招式攻击阶段
--@author:Seven
--@time:2023-02-02 21:32:11
function ActiveCombAttacking:__setNextZhaoAttackStage()
    self.__stageList = self:__createNewZhaoAttackStages()

    self.__currStageIndex = 1
end

--@desc: 设置下一个招式攻击
--@author:Seven
--@time:2023-02-02 21:34:33
function ActiveCombAttacking:__setNextZhaoAttack()
    self.__context:setNextZhaoAttack(self.__context:getNextNewZhaoAttack())
end

function ActiveCombAttacking:__hasNextZhaoAttack()
    if self.__context:hasNextZhaoAttack() then
        return true
    end

    return false
end

return newClass("ActiveCombAttacking", {ABaseBattleAction}, ActiveCombAttacking)
000000000000000