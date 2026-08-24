--[[
    author:Seven
    time:2023-11-03 20:25:11
    desc: 主动招式攻击视图事件
]]
local newClass = require("third.class.NewClass")

local IViewEvent = require("app.FightSystem.Veiws.ViewEvents.Events.IViewEvent")

local FightCommons = require("app.FightSystem.FightCommons")

--@SuperType [src.app.FightSystem.Veiws.ViewEvents.Events.IViewEvent#IViewEvent]
local ActiveZhaoAttackViewEvent = {}

function ActiveZhaoAttackViewEvent:create(...)
    return ActiveZhaoAttackViewEvent.new():__init(...)
end

--@author:Seven
--@time:2023-11-03 20:27:00
--@context: [src.app.FightSystem.BattleActions.AttackBattleAction.AutoAttack.AutoAttackContext#AutoAttackContext]
--@zhaoAttack: [src.app.FightSystem.ZhaoAttacks.ABasicZhaoAttack#ABasicZhaoAttack]
function ActiveZhaoAttackViewEvent:__init(context, zhaoAttack)
    self.__context = context

    self.__zhaoAttack = zhaoAttack

    self.__buffContext = self.__context:getFight()

    return self
end

--@author:Seven
--@time:2023-10-24 16:33:02
--@mainView: [FightMainView]
function ActiveZhaoAttackViewEvent:doViewEvent(mainView)
    local attackType = self.__zhaoAttack:getHitType()

    if attackType == FightCommons.ATTACK_HIT_TYPE.HIT then
        local viewEventAction = require("app.FightSystem.Veiws.ViewEvents.EventActions.HitAttackViewEventAction"):create(mainView, self.__context, self.__zhaoAttack, self.__buffContext)
        mainView:addViewEventAction(viewEventAction)
    elseif attackType == FightCommons.ATTACK_HIT_TYPE.ACTIVE_RELEASE then
        local viewEventAction = require("app.FightSystem.Veiws.ViewEvents.EventActions.ActiveReleaseEventAction"):create(mainView, self.__context, self.__zhaoAttack, self.__buffContext)
        mainView:addViewEventAction(viewEventAction)
    elseif attackType == FightCommons.ATTACK_HIT_TYPE.NONE then
        local viewEventAction = require("app.FightSystem.Veiws.ViewEvents.EventActions.OnlyPlayAnimEventAction"):create(mainView, self.__context, self.__zhaoAttack, self.__buffContext)
        mainView:addViewEventAction(viewEventAction)
    end
end

return newClass("ActiveZhaoAttackViewEvent", {IViewEvent}, ActiveZhaoAttackViewEvent)
00