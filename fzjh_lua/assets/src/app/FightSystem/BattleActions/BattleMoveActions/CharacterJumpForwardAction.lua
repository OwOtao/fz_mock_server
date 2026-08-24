--[[
    author:Seven
    time:2023-02-01 16:57:48
    desc: 前跳动作
]]
local newClass = require("third.class.NewClass")

local ABaseBattleAction = require("app.FightSystem.BattleActions.ABaseBattleAction")

--@SuperType [src.app.FightSystem.BattleActions.ABaseBattleAction#ABaseBattleAction]
local CharacterJumpForwardAction = {}

function CharacterJumpForwardAction:create(fight, context)
    return CharacterJumpForwardAction.new():__init(fight, context)
end

function CharacterJumpForwardAction:__init(fight, context)
    self:init(fight)

    --@RefType [src.app.FightSystem.BattleActions.AttackBattleAction.AutoAttack.AutoAttackContext#AutoAttackContext]
    self.__context = context

    return self
end

function CharacterJumpForwardAction:onInit()
end

function CharacterJumpForwardAction:onStart()
    self.__duration = 0

    local currentAttack = self.__context:getCurrZhaoAttack()

    local jumpOffset = self.__context:getJumpForwardOffset()

    --@desc 前跳离开位置
    self.__context:getAttacker():setIsInOriginPos(false)

    self.__fight:notifyVeiwEvent(
        require "app.FightSystem.Veiws.ViewEvents.Events.CharacterJumpForwardViewEvent":create(self.__context:getAttacker():getId(), self.__context:getTarget():getId(), jumpOffset, 0.3)
    )
end

function CharacterJumpForwardAction:onFinish()
end

function CharacterJumpForwardAction:onDestory()
end

function CharacterJumpForwardAction:onUpdate(ft)
    if self.__duration >= 0.3 then
        self:finish()
        return
    end

    self.__duration = self.__duration + ft
end

return newClass("CharacterJumpForwardAction", {ABaseBattleAction}, CharacterJumpForwardAction)
000000000