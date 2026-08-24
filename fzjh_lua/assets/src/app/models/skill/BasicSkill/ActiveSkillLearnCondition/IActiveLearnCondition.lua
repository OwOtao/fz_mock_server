local interface = require("third.class.interface")

local IActiveLearnCondition = {}

function IActiveLearnCondition:matchCondititon(f_character)
end

function IActiveLearnCondition:getConditionText()
end

return interface("IActiveLearnCondition",IActiveLearnCondition)000000000