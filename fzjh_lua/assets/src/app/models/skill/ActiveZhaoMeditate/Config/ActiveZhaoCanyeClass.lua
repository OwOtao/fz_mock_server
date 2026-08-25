local class = require("third.class.NewClass")

local ActiveZhaoCanyeClass = {}

function ActiveZhaoCanyeClass:create(res)
    return ActiveZhaoCanyeClass.new(res)
end

function ActiveZhaoCanyeClass:getId()
	return self.id
end
function ActiveZhaoCanyeClass:getToEnergyBase()
    return self.toEnergyBase
end

function ActiveZhaoCanyeClass:getToProficiencyBase()
    return self.toProficiencyBase
end

function ActiveZhaoCanyeClass:getCostTimeBase()
    return self.costTimeBase
end

return class("ActiveZhaoCanyeClass", {}, ActiveZhaoCanyeClass)
0000000