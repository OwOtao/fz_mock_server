local interface = require("third.class.interface")

local IReleaseActiveAIRule = {}

function IReleaseActiveAIRule:releaseActiveSkill()
end

function IReleaseActiveAIRule:checkRealease(attacker, target)
end

function IReleaseActiveAIRule:getActiveSkillId()
end

function IReleaseActiveAIRule:onUpdate(ft)
end

return interface("IReleaseActiveAIRule", IReleaseActiveAIRule)
0000000000