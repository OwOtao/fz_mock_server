--[[
    author:Seven
    time:2023-11-07 15:20:20
    desc: 视图技能model创建工厂
]]
local ViewActiveSkillFactory = {}

local ViewActiveSkill = require("app.FightSystem.Veiws.ViewCommonModel.ViewCharacterSkill.ViewActiveSkill")

--@desc:
--@author:Seven
--@time:2023-11-07 15:21:27
--@activeskill: [src.app.FightSystem.FightSkill.BasicFightActiveSkill#BasicFightActiveSkill]
--@return [src.app.FightSystem.Veiws.ViewCommonModel.ViewCharacterSkill.ViewActiveSkill#ViewActiveSkill]
function ViewActiveSkillFactory:create(activeskill, index)
    --@RefType [src.app.FightSystem.Veiws.ViewCommonModel.ViewCharacterSkill.ViewActiveSkill#ViewActiveSkill]
    local viewActiveSkill = ViewActiveSkill:create(activeskill:getId(), activeskill:getName(), index)

    viewActiveSkill:setCooldownTime(activeskill:getCoolDownTime())

    viewActiveSkill:setConditionText(activeskill:getUseConditionTexts())

    viewActiveSkill:setDesc(activeskill:getDesc())

    viewActiveSkill:setCostNeili(activeskill:getNeiliCost())

    viewActiveSkill:setLevel(activeskill:getLevel())

    viewActiveSkill:setViewActiveCD(activeskill:getCD())

    local isMeet, _ = activeskill:releaseAreMet()

    viewActiveSkill:setEnable(isMeet)

    return viewActiveSkill
end

return ViewActiveSkillFactory
000000000