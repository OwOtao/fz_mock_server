--[[
    战斗结果 
        arg1 : 0 胜利  ；1 失败； 2 逃跑
]]
local BaseBuffCondition = require("app.models.Buff.Conditions.BaseBuffCondition")
--@SuperType [BaseBuffCondition]
local FightFinishCondition = class("FightFinishCondition", BaseBuffCondition)

function FightFinishCondition:create()
    local p = FightFinishCondition:new()
    p:init()
    return p
end

function FightFinishCondition:init()
    self.type = 1
end

function FightFinishCondition:onCheck()
    local fightResult = self.context.fightResult

    if self.arg1 == 0 then
        if fightResult == 1 then
            return true
        end
    elseif self.arg1 == 1 then
        if fightResult == 2 then
            return true
        end
    elseif self.arg1 == 2 then
        if fightResult ~= 1 and fightResult ~= 2 then
            return true
        end
    end

    return false
end

return FightFinishCondition0