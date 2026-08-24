--[[
    author:Seven
    time:2022-11-15 16:55:02
    desc: 被动攻击流程
]]
local newClass = require("third.class.NewClass")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local ABaseBattleAction = require("app.FightSystem.BattleActions.ABaseBattleAction")

local ActiveAttackContext = require("app.FightSystem.BattleActions.AttackBattleAction.ActiveAttack.ActiveAttackContext")

--@SuperType [src.app.FightSystem.BattleActions.ABaseBattleAction#ABaseBattleAction]
local ActiveAttackBattleAction = {}

function ActiveAttackBattleAction:create(context)
    return ActiveAttackBattleAction.new():__init(context)
end

function ActiveAttackBattleAction:__init(context)
    --@RefType [src.app.FightSystem.BattleActions.AttackBattleAction.ActiveAttack.ActiveAttackContext#ActiveAttackContext]
    self.__context = context

    return self
end

function ActiveAttackBattleAction:onInit()
    FightUtil:printLog("ActiveAttackBattleAction:onInit 武学主动攻击：攻击初始化 主动技能：" .. tostring(self.__context:getAttackSkill():getId()))

    self.__currStageIndex = 0

    --@desc 刷新AI时间
    local rule = self.__context:getAttacker():getActiveReleaseAIRule(self.__context:getAttackSkill():getId())
    if rule ~= nil then
        rule:releaseActiveSkill()
    end
end

function ActiveAttackBattleAction:onStart()
    FightUtil:printLog("ActiveAttackBattleAction:onStart 武学主动攻击：攻击开始 ")

    self.__context:getAttacker():setCanRecover(false)

    self:__initNewActiveAttackStage(self.__context)

    self.__currStageIndex = 1

    self:__getCurrentStage():start()
end

function ActiveAttackBattleAction:onFinish()
    FightUtil:printLog("ActiveAttackBattleAction:onFinish 武学主动攻击攻击：攻击结束 ")
    self.__context:getAttacker():setCanRecover(true)
end

function ActiveAttackBattleAction:onDestory()
end

function ActiveAttackBattleAction:onUpdate(ft)
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
function ActiveAttackBattleAction:__getCurrentStage()
    return self.__stageList[self.__currStageIndex]
end

--@desc: 初始化一次招式攻击组合
--@author:Seven
--@time:2022-12-08 15:52:57
function ActiveAttackBattleAction:__initNewActiveAttackStage(context)
    --@desc 初始化被动招式攻击流程
    self.__stageList = {
        require("app.FightSystem.BattleActions.AttackBattleAction.ActiveAttack.ActiveAttackReady"):create(context),
        require("app.FightSystem.BattleActions.AttackBattleAction.ActiveAttack.ActiveCombStart"):create(context),
        require("app.FightSystem.BattleActions.AttackBattleAction.ActiveAttack.ActiveCombAttacking"):create(context),
        require("app.FightSystem.BattleActions.AttackBattleAction.ActiveAttack.ActiveCombFinish"):create(context)
    }

    for i, v in ipairs(self.__stageList) do
        v:init(self.__fight)
    end

    self.__currStageIndex = 0
end

function ActiveAttackBattleAction:getNextBattleAction()
    return self.__context:getNextAttackBattleAction()
end

return newClass("ActiveAttackBattleAction", {ABaseBattleAction}, ActiveAttackBattleAction)
00000000000