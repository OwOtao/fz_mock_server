local abstract = require("third.class.abstract")

local IFightSystem = {}
function IFightSystem:init()
end

function IFightSystem:release()
end

function IFightSystem:update(ft)
end

--@SuperType [src.app.FightSystem.AFightSystem#IFightSystem]
local AFightSystem = {}

function AFightSystem:create(fight)
    local p = self.new()
    p:setFight(fight)
    return p
end

function AFightSystem:setFight(fight)
    --@RefType[src.app.FightSystem.Fight.Fight#Fight]
    self.__fight = fight
end

function AFightSystem:getFight()
    return self.__fight
end

return abstract("AFightSystem", {IFightSystem}, AFightSystem)
000000000