--[[
    author:Seven
    time:2022-11-15 15:46:17
    desc: 攻击动作阶段
        （该阶段从开始到结束，攻击者唯一，如发生改变攻击者的情况，会结束当前阶段）
]]
local newClass = require("third.class.NewClass")

local ABaseBattleAction = require("app.FightSystem.BattleActions.ABaseBattleAction")

--@SuperType [src.app.FightSystem.BattleActions.ABaseBattleAction#ABaseBattleAction]
local AttackBattleAction = {
    __attackAction = nil
}

function AttackBattleAction:create(attackAction)
    return AttackBattleAction.new():__init(attackAction)
end

function AttackBattleAction:__init(attackAction)
    self.__attackAction = attackAction

    return self
end

function AttackBattleAction:onInit()
end

function AttackBattleAction:onStart()
    self.__attackAction:init(self.__fight)

    self.__attackAction:start()
end

function AttackBattleAction:onFinish()
end

function AttackBattleAction:onDestory()
end

function AttackBattleAction:onUpdate(ft)
    self.__attackAction:update(ft)

    if self.__attackAction:isFinish() then
        local nextAttackAction = self.__attackAction:getNextBattleAction()
        if nextAttackAction ~= nil then
            --@desc 如果有可以继续执行操作，那么当前阶段不会结束，继续进行
            self.__attackAction = nextAttackAction

            self.__attackAction:init(self.__fight)

            if self.__attackAction.start == nil then
                error("该阶段没有start方法")
            end

            self.__attackAction:start()
        else
            return self:finish()
        end
    end
end

return newClass("AttackBattleAction", {ABaseBattleAction}, AttackBattleAction)
00000000