--[[
    author:Seven
    time:2023-03-11 16:15:40
    desc: 主动技能准备阶段
]]
local newClass = require("third.class.NewClass")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local FightCommons = require("app.FightSystem.FightCommons")

--@RefType [src.app.FightSystem.BattleActions.ABaseBattleAction#ABaseBattleAction]
local ABaseBattleAction = require("app.FightSystem.BattleActions.ABaseBattleAction")

--@SuperType [src.app.FightSystem.BattleActions.ABaseBattleAction#ABaseBattleAction]
local ActiveAttackReady = {}

function ActiveAttackReady:create(context)
    return ActiveAttackReady.new():__init(context)
end

function ActiveAttackReady:__init(context)
    --@RefType [src.app.FightSystem.BattleActions.AttackBattleAction.ActiveAttack.ActiveAttackContext#ActiveAttackContext]
    self.__context = context
    return self
end

function ActiveAttackReady:onInit()
end

function ActiveAttackReady:onStart()
    FightUtil:printLog("组合准备阶段：ActiveAttackReady start")

    FightUtil:printLog("ActiveComb 角色主动组合攻击开始-进入准备阶段：", tostring(self.__context:getAttackSkill():getName()))

    self.__context:getAttackSkill():setCD(self.__context:getAttackSkill():getCoolDownTime())

    --@region 体力消耗
    local costTili = self.__context:getAttackCostTili()

    self.__context:getAttacker():consumeTili(costTili)
    --@endregion

    --@region 内力消耗
    local costNeili = self.__context:getAttackCostNeili()

    self.__context:getAttacker():consumeNeili(costNeili)
    --@endregion

    --@desc 记录主动技能释放次数
    self.__context:getAttacker():getRecordClass():addActiveReleaseTime(self.__context:getAttackSkill():getId())

    --@region 文本输出
    self:__combStartTextOutput()
    --@endregion

    --@desc 准备招式
    self.__readyZhaoAttack = self.__context:getReadyZhaoAttack()
    if self.__readyZhaoAttack then
        self.__readyZhaoAttack:attack()
        self.__fight:notifyVeiwEvent(require("app.FightSystem.Veiws.ViewEvents.Events.ActiveZhaoAttackViewEvent"):create(self.__context, self.__readyZhaoAttack))
    end
    self.__readyZhaoAttackTime = 0
end

function ActiveAttackReady:onFinish()
    FightUtil:printLog("组合准备阶段：ActiveAttackReady finish")
end

function ActiveAttackReady:onDestory()
end

function ActiveAttackReady:onUpdate(ft)
    if self.__readyZhaoAttack ~= nil then
        if self.__readyZhaoAttack:getDuration() <= self.__readyZhaoAttackTime then
            self.__readyZhaoAttack = nil
            self:finish()
            return
        end

        self.__readyZhaoAttackTime = self.__readyZhaoAttackTime + ft
    else
        self:finish()
    end
end

function ActiveAttackReady:__combStartTextOutput()
    local startCombText = self.__context:getAttackComb():getActionText()
    --@RefType [src.app.FightSystem.FightUtil.FightDesc#FightDesc]
    local desc = require("app.FightSystem.FightUtil.FightDesc"):create()

    desc:setText(startCombText)

    desc:setAttacker(self.__context:getAttacker())

    desc:setDefender(self.__context:getTarget())

    desc:setHitPosName(self.__context:getCombHitPosName())

    desc:setZhaoCombName(self.__context:getAttackComb():getCombName())

    self.__fight:showPrintText(desc:getString())
end

return newClass("ActiveAttackReady", {ABaseBattleAction}, ActiveAttackReady)
000