--[[
    author:Seven
    time:2023-01-06 20:21:30
    desc: 主动招式结果生成工厂
]]
local newClass = require("third.class.NewClass")

local IZhaoAttackFactory = require("app.FightSystem.ZhaoAttacks.ZhaoAttackFactory.IZhaoAttackFactory")

local ActiveZhaoAttackFactory = {}

function ActiveZhaoAttackFactory:create(context)
    return ActiveZhaoAttackFactory.new():__init(context)
end

function ActiveZhaoAttackFactory:__init(context)
    --@RefType [src.app.FightSystem.BattleActions.AttackBattleAction.ActiveAttack.ActiveAttackContext#ActiveAttackContext]
    self.__context = context
    return self
end

function ActiveZhaoAttackFactory:getZhaoAttack()
    local zhaoComb = self.__context:getAttackComb()

    local path 
    if zhaoComb:isAttackActiveComb() then
        path = "app.FightSystem.ZhaoAttacks.Hit.AcitveAtkHit"
    else
        path = "app.FightSystem.ZhaoAttacks.None.ActiveAtkRelease"
    end
    return require(path):create(self.__context, self.__context:getNextZhao())
end


return newClass("ActiveZhaoAttackFactory",{IZhaoAttackFactory},ActiveZhaoAttackFactory)0000000