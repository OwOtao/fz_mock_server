local SkillConst = require("app.models.skill.SkillConst")
local XiSuiJingExpAndLvConfig = requireWithEncrypt("script.zhishiSkills.xisuiSkillExpAndLvConf")["等级经验"]
local XiSuiJingAttrConfig = requireWithEncrypt("script.zhishiSkills.xisuiAttrAdd")["洗髓武学属性"]
local ZhiShiSkillsGrowthConf = requireWithEncrypt("script.zhishiSkills.zhishiSkillsGrowthConf")["练功"]
local BaseSkill = require("app.models.skill.BaseSkill")

local XiSuiJingSkill = inherit({}, BaseSkill)

function XiSuiJingSkill:getId()
    return self.id
end

function XiSuiJingSkill:getLv(exp)
    local currLv = 0

    for k,v in pairs(XiSuiJingExpAndLvConfig) do
        if exp >= v.totalEXP and currLv < v.id then
            currLv = v.id
        end
    end

    return currLv
end

function XiSuiJingSkill:getExp(lv)
    if lv > self:getMaxLv() then
        return self:getMaxExp()
    end
    
    for k,v in pairs(XiSuiJingExpAndLvConfig) do
        if lv == v.id then
            return v.totalEXP
        end
    end
end

function XiSuiJingSkill:getDsc()
    return self.dsc
end

function XiSuiJingSkill:getXiSuiNeedJing()
    for k, v in pairs(ZhiShiSkillsGrowthConf) do
        if v.id == self.id then
            return v.upgrade_cost_jing
        end
    end
end

-- 消耗潜能 = 向上取整( (基础消耗潜能+currInt)*消耗潜能比例修正 )
-- 基础消耗潜能，配置在 表[知识武学练功表]
-- 消耗潜能比例修正，配置在 表[知识武学练功表]
-- currInt：角色当前有效悟性
function XiSuiJingSkill:getXiSuiNeedPot(currInt)
    local upgrade_cost_pot_base = 0
    local upgrade_cost_pot_param = 0
    for k, v in pairs(ZhiShiSkillsGrowthConf) do
        if v.id == self.id then
            upgrade_cost_pot_base = v.upgrade_cost_pot_base
            upgrade_cost_pot_param = v.upgrade_cost_pot_param
        end
    end
    return math.ceil((upgrade_cost_pot_base + currInt) * upgrade_cost_pot_param)
end


--武学潜能转化率，读取 表[武功1.xls]，对应ID的 潜能转化效率;potEfficiency
function XiSuiJingSkill:getSkillPotEfficiency()
    local potEfficiency = self.learn.potEfficiency

    if not potEfficiency then
        potEfficiency = 80
    end

    return potEfficiency
end

--基础潜能转化率，配置在 表[知识武学通用参数表].upgrade_role_pot_base
function XiSuiJingSkill:__getBasePotEfficiency()
    return SkillConst:getZhiShiSkillParamContent(SkillConst.ZhiShiSkillParams.UPGRADE_ROLE_POT_BASE)
end

--潜能转化率比例修正，配置在 表[知识武学通用参数表].upgrade_role_pot_param
function XiSuiJingSkill:__getParamsPotEfficiency()
    return SkillConst:getZhiShiSkillParamContent(SkillConst.ZhiShiSkillParams.UPGRADE_ROLE_POT_PARAM)
end

-- 获得武学经验 = 消耗潜能*(角色当前武学潜能转化率/100)
-- 角色当前武学潜能转化率 = 武学潜能转化率*(基础潜能转化率+currInt)/潜能转化率比例修正
-- 武学潜能转化率，读取 表[武功1.xls]，对应ID的 潜能转化效率;potEfficiency
-- 基础潜能转化率，配置在 表[知识武学通用参数表].upgrade_role_pot_base
-- 潜能转化率比例修正，配置在 表[知识武学通用参数表].upgrade_role_pot_param
function XiSuiJingSkill:xiSui(currInt)
    local addExp = 0

    local skillPotEfficiency = self:getSkillPotEfficiency()

    local basePotEfficiency = self:__getBasePotEfficiency()

    local paramsPotEfficiency = self:__getParamsPotEfficiency()
    
    addExp = self:getXiSuiNeedPot(currInt) * ((skillPotEfficiency * (basePotEfficiency + currInt) / paramsPotEfficiency) / 100)

    return addExp
end

function XiSuiJingSkill:getSkillStageInfoByExp(exp)
    local lv = self:getLv(exp)
    local currStage = 0

    for k,v in pairs(XiSuiJingAttrConfig) do
        if lv >= v.level and currStage < v.id then
            currStage = v.id
        end
    end

    return self:getSkillStageInfoById(currStage)
end

function XiSuiJingSkill:getSkillStageInfoById(id)
    for k,v in pairs(XiSuiJingAttrConfig) do
        if id == v.id then
            return v
        end
    end
end

function XiSuiJingSkill:getSkillStageMax()
    local stage = 0
    for k,v in pairs(XiSuiJingAttrConfig) do
        if stage < v.id then
            stage = v.id
        end
    end
    return stage
end

function XiSuiJingSkill:getAttrPointValue(attr,exp)
    local stageInfo = self:getSkillStageInfoByExp(exp)

    if MapIsEmpty(stageInfo) then
        return 0
    end
    
    local attrPoint = switch(attr,
        {
            ["con"] = stageInfo.transform_conAdd,
            ["str"] = stageInfo.transform_strAdd,
            ["dex"] = stageInfo.transform_dexAdd,
            ["int"] = stageInfo.transform_intAdd,
            default = 0
        }
    )

    return attrPoint
end

function XiSuiJingSkill:getMaxExp()
    local exp = 0
    
    for k,v in pairs(XiSuiJingExpAndLvConfig) do
        if exp < v.totalEXP then
            exp = v.totalEXP
        end
    end

    return exp
end

function XiSuiJingSkill:getMaxLv()
    local lv = 0
    
    for k,v in pairs(XiSuiJingExpAndLvConfig) do
        if lv < v.id then
            lv = v.id
        end
    end

    return lv
end

return XiSuiJingSkill000000