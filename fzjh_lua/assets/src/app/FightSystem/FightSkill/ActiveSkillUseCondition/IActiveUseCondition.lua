local interface = require("third.class.interface")

local IActiveUseCondition = {}

function IActiveUseCondition:getConditionType()
end

function IActiveUseCondition:matchCondititon(f_character)
end

function IActiveUseCondition:getConditionText()
end

return interface("IActiveUseCondition",IActiveUseCondition)00000000000