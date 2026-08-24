--[[
    author:Seven
    time:2022-11-15 16:55:02
    desc: 被动攻击流程
]]
local newClass = require("third.class.NewClass")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local ABaseBattleAction = require("app.FightSystem.BattleActions.ABaseBattleAction")

local AutoAttackContext = require("app.FightSystem.BattleActions.AttackBattleAction.AutoAttack.AutoAttackContext")

--@SuperType [src.app.FightSystem.BattleActions.ABaseBattleAction#ABaseBattleAction]
local AutoAttackBattleAction = {}

function AutoAttackBattleAction:create(context)
    return AutoAttackBattleAction.new():__init(context)
end

function AutoAttackBattleAction:__init(context)
    --@RefType [src.app.FightSystem.BattleActions.AttackBattleAction.AutoAttack.AutoAttackContext#AutoAttackContext]
    self.__context = context

    return self
end

function AutoAttackBattleAction:onInit()
    FightUtil:printLog("武学被动攻击：攻击初始化")

    self.__combAttackCount = 0

    self.__currStageIndex = 0
end

function AutoAttackBattleAction:onStart()
    FightUtil:printLog("武学被动攻击：攻击开始 ")

    self.__context:getAttacker():setCanRecover(false)

    self:__initNewAutoAttackStage(self.__context)

    self.__currStageIndex = 1

    self:__getCurrentStage():start()
end

function AutoAttackBattleAction:onFinish()
    self.__context:getAttacker():setCanRecover(true)
    FightUtil:printLog("武学被动攻击：攻击结束 ")
end

function AutoAttackBattleAction:onDestory()
end

function AutoAttackBattleAction:onUpdate(ft)
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
            self:finish()

            return
        else
            self.__currStageIndex = self.__currStageIndex + 1
        end
    end
end

--@desc: 获取当前阶段
--@author:Seven
--@time:2022-12-07 16:21:27
--@return: [src.app.FightSystem.BattleActions.ABaseBattleAction#ABaseBattleAction]
function AutoAttackBattleAction:__getCurrentStage()
    return self.__stageList[self.__currStageIndex]
end

--@desc: 初始化一次招式攻击组合
--@author:Seven
--@time:2022-12-08 15:52:57
function AutoAttackBattleAction:__initNewAutoAttackStage(context)
    --@desc 初始化被动招式攻击流程
    self.__stageList = {
        require("app.FightSystem.BattleActions.AttackBattleAction.AutoAttack.AutoCombStart"):create(context),
        require("app.FightSystem.BattleActions.AttackBattleAction.AutoAttack.AutoCombAttacking"):create(context),
        require("app.FightSystem.BattleActions.AttackBattleAction.AutoAttack.AutoCombFinish"):create(context)
    }

    for i, v in ipairs(self.__stageList) do
        v:init(self.__fight)
    end

    self.__currStageIndex = 0
end

function AutoAttackBattleAction:getNextBattleAction()
    return self.__context:getNextAttackBattleAction()
end

return newClass("AutoAttackBattleAction", {ABaseBattleAction}, AutoAttackBattleAction)
000000