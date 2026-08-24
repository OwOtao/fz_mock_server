--[[
    副本工厂类, 隔离副本细节, 对外提供统一的副本接口
]]
local assertIsInstance = require("third.assertIsInstance.assertIsInstance")
local SkillConst = require("app.models.skill.SkillConst")
local ISkill = require("app.models.skill.interface.ISkill")
local BaseSkill = require("app.models.skill.BaseSkill")
local ZhouGongZhiShuSkill = require("app.models.skill.skills.ZhouGongZhiShuSkill")
local XiSuiJingSkill = require("app.models.skill.skills.XiSuiJingSkill")
local MeridianSkill = require("app.models.skill.skills.MeridianSkill")

local function log(...)
    print("SkillFactory:", ...)
end

local SkillFactory = {}

-- @desc 创建技能
function SkillFactory:createSkill(skillType)
    -- log("createSkill", skillType)

    local skill = nil

    if skillType == SkillConst.SkillType.NORMAL_SKILL then
        skill = BaseSkill
    elseif skillType == SkillConst.SkillType.ZHOU_GONG_ZHI_SHU then
        skill = ZhouGongZhiShuSkill
    elseif skillType == SkillConst.SkillType.XI_SUI_JING then
        skill = XiSuiJingSkill
    elseif skillType == SkillConst.SkillType.DONG_YUAN_LU then
        skill = MeridianSkill
    else
        skill = BaseSkill
    end

    return assertIsInstance(skill, ISkill)
end

function SkillFactory:createSkillById(skillId)
    if skillId == SkillConst:getZhiShiSkillParamContent("skillID_pointSwitch") then
        return require("app.models.skill.skills.NaturalAttrAdjustmentSkill")
    else
        return BaseSkill
    end
end

return SkillFactory
0000