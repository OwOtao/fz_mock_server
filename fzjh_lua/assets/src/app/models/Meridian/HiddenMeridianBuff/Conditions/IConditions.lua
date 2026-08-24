local interface = require("third.class.interface")

local IConditions = {}

function IConditions:check()
end

function IConditions:checkConditionList(conditionList)
end

function IConditions:getConditionRes(conditionId)
end

function IConditions:checkCondition(conditionId)
end

return interface("IConditions", IConditions)0000000000000