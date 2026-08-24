local SkillConst = require("app.models.skill.SkillConst")

local EXP_CONF = requireWithEncrypt("script.zhishiSkills.naturalAttrKnowledgeSkillLevelConf")["等级经验"]

local STAGE_CONF = requireWithEncrypt("script.zhishiSkills.naturalAttrKnowledgeSkillStageConf")["data"]

local SkillUtil = require("app.models.skill.SkillUtil")

local SkillStageFactory = require("app.models.skill.factory.SkillStageFactory")

local BaseSkill = require("app.models.skill.BaseSkill")

local NaturalAttrAdjustmentSkill = inherit({}, BaseSkill)

function NaturalAttrAdjustmentSkill:getId()
    return self.id
end

function NaturalAttrAdjustmentSkill:getLv(exp)
    return SkillUtil:expMapToLvOnConfig(exp, EXP_CONF)
end

function NaturalAttrAdjustmentSkill:getExp(lv)
    return SkillUtil:lvMapToNeedExpOnConfig(lv, EXP_CONF)
end

function NaturalAttrAdjustmentSkill:getDsc()
    return self.dsc
end

function NaturalAttrAdjustmentSkill:getMaxLv()
    return #EXP_CONF
end

function NaturalAttrAdjustmentSkill:getSkillStageBySkillLv(lv)
    return SkillStageFactory:getBasicSkillStageBySkillLevel(lv, STAGE_CONF)
end

function NaturalAttrAdjustmentSkill:getSkillStageById(id)
    return SkillStageFactory:getBasicSkillStageByStageId(id, STAGE_CONF)
end

function NaturalAttrAdjustmentSkill:getMaxStageLv()
    return #STAGE_CONF
end

--@desc: 武学潜能转化率
--@author:Seven
--@time:2024-01-11 22:11:43
function NaturalAttrAdjustmentSkill:getSkillPotEfficiency()
    local potEfficiency = self.learn.potEfficiency

    if not potEfficiency then
        potEfficiency = 80
    end

    return potEfficiency
end

return NaturalAttrAdjustmentSkill
00