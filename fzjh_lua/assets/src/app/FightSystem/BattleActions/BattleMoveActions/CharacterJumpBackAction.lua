--[[
    author:Seven
    time:2023-02-01 16:57:48
    desc: 前跳动作
]]
local newClass = require("third.class.NewClass")

local ABaseBattleAction = require("app.FightSystem.BattleActions.ABaseBattleAction")

local CharacterJumpBackViewEvent = require("app.FightSystem.Veiws.ViewEvents.Events.CharacterJumpBackViewEvent")

--@SuperType [src.app.FightSystem.BattleActions.ABaseBattleAction#ABaseBattleAction]
local CharacterJumpBackAction = {}

function CharacterJumpBackAction:create(fight, context)
    return CharacterJumpBackAction.new():__init(fight, context)
end

function CharacterJumpBackAction:__init(fight, context)
    self:init(fight)

    --@RefType [src.app.FightSystem.BattleActions.AttackBattleAction.AutoAttack.AutoAttackContext#AutoAttackContext]
    self.__context = context

    return self
end

function CharacterJumpBackAction:onInit()
end

function CharacterJumpBackAction:onStart()
    self.__duration = 0

    self.__fight:notifyVeiwEvent(CharacterJumpBackViewEvent:create(self.__context:getAttacker():getId(), 0.2))
end

function CharacterJumpBackAction:onFinish()
    --@desc 跳回结束回到位置
    self.__context:getAttacker():setIsInOriginPos(true)
end

function CharacterJumpBackAction:onDestory()
end

function CharacterJumpBackAction:onUpdate(ft)
    if self.__duration >= 0.2 then
        self:finish()
        return
    end

    self.__duration = self.__duration + ft
end

return newClass("CharacterJumpBackAction", {ABaseBattleAction}, CharacterJumpBackAction)
00000000