local interface = require("third.class.interface")

local IBuffNeeded = {}

function IBuffNeeded:getSelfWeaponType()
end

function IBuffNeeded:getTargetWeaponType()
end

function IBuffNeeded:getSelfWeaponAttr(attrName)
end

function IBuffNeeded:getTargetWeaponAttr(attrName)
end

function IBuffNeeded:getAttr(attrName)
end

function IBuffNeeded:getTargetAttr(attrName)
end

function IBuffNeeded:getAutoAvgAtk()
end

function IBuffNeeded:getDynamicArg1()
end

function IBuffNeeded:getDynamicArg2()
end

function IBuffNeeded:getDynamicArg3()
end

function IBuffNeeded:getDynamicArg(dynamicArgName)
end

function IBuffNeeded:getAttacker()
end

return interface("IBuffNeeded", IBuffNeeded)
000000000