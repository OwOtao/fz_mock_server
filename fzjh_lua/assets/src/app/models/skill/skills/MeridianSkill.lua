local SkillConst = require("app.models.skill.SkillConst")

local JingMaiSkillExpAndLvConf = requireWithEncrypt("script.zhishiSkills.jingmaiSkillExpAndLvConf")["data"]

local JingmaiSkillAttrConf = requireWithEncrypt("script.zhishiSkills.jingmaiSkillAttr")["data"]

local ZhiShiSkillsGrowthConf = requireWithEncrypt("script.zhishiSkills.zhishiSkillsGrowthConf")["练功"]

local BaseSkill = require("app.models.skill.BaseSkill")

local MeridianSkill = inherit({}, BaseSkill)

function MeridianSkill:getId()
    return self.id
end

function MeridianSkill:getLv(exp)
    local currLv = 0

    for k,v in pairs(JingMaiSkillExpAndLvConf) do
        if exp >= v.totalEXP and currLv < v.id then
            currLv = v.id
        end
    end

    return currLv
end

function MeridianSkill:getExp(lv)
    if lv > self:getMaxLv() then
        return self:getMaxExp()
    end
    
    for k,v in pairs(JingMaiSkillExpAndLvConf) do
        if lv == v.id then
            return v.totalEXP
        end
    end
end

function MeridianSkill:getMaxExp()
    local exp = 0
    
    for k,v in pairs(JingMaiSkillExpAndLvConf) do
        if exp < v.totalEXP then
            exp = v.totalEXP
        end
    end

    return exp
end

function MeridianSkill:getMaxLv()
    local lv = 0
    
    for k,v in pairs(JingMaiSkillExpAndLvConf) do
        if lv < v.id then
            lv = v.id
        end
    end

    return lv
end

function MeridianSkill:getDsc()
    return self.dsc
end

--@desc: 获取武学削减真气阶段系数
--@author:LvBin
--@time:2023-07-04 11:19:51
--@exp: 武学经验
	--@index: 阶段索引
--@return
function MeridianSkill:getStageParam(exp,index)
    local lv = self:getLv(exp)

    local currStage = 0

    local param = 1

    for k,v in pairs(JingmaiSkillAttrConf) do
        if lv >= v.level and currStage < v.id then
            currStage = v.id

            if v[index] then
                param = v[index]
            end
        end
    end
    
    return param
end

function MeridianSkill:getSkillStageInfoByExp(exp)
    local lv = self:getLv(exp)
    local currStage = 0

    for k,v in pairs(JingmaiSkillAttrConf) do
        if lv >= v.level and currStage < v.id then
            currStage = v.id
        end
    end

    return self:getSkillStageInfoById(currStage)
end

function MeridianSkill:getSkillStageInfoById(id)
    for k,v in pairs(JingmaiSkillAttrConf) do
        if id == v.id then
            return v
        end
    end
end

function MeridianSkill:getSkillStageMax()
    local stage = 0
    for k,v in pairs(JingmaiSkillAttrConf) do
        if stage < v.id then
            stage = v.id
        end
    end
    return stage
end

--@desc: 一次练功所需精力
--@author:LvBin
--@time:2023-07-04 15:34:19
--@return
function MeridianSkill:getLianGongNeedJing()
    for k, v in pairs(ZhiShiSkillsGrowthConf) do
        if v.id == self.id then
            return v.upgrade_cost_jing
        end
    end
end

--@desc: 一次练功消耗潜能
--@author:LvBin
--@time:2023-07-04 15:37:53
--@currInt: 有效悟性
--@return
function MeridianSkill:getLianGongNeedPot(currInt)
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

function MeridianSkill:getSkillPotEfficiency()
    local potEfficiency = self.learn.potEfficiency

    if not potEfficiency then
        potEfficiency = 80
    end

    return potEfficiency
end

function MeridianSkill:__getBasePotEfficiency()
    return SkillConst:getZhiShiSkillParamContent(SkillConst.ZhiShiSkillParams.UPGRADE_ROLE_POT_BASE)
end


function MeridianSkill:__getParamsPotEfficiency()
    return SkillConst:getZhiShiSkillParamContent(SkillConst.ZhiShiSkillParams.UPGRADE_ROLE_POT_PARAM)
end

function MeridianSkill:getLianGongAddExp(currInt)
    local addExp = 0

    local skillPotEfficiency = self:getSkillPotEfficiency()

    local basePotEfficiency = self:__getBasePotEfficiency()

    local paramsPotEfficiency = self:__getParamsPotEfficiency()
    
    addExp = self:getLianGongNeedPot(currInt) * ((skillPotEfficiency * (basePotEfficiency + currInt) / paramsPotEfficiency) / 100)

    return addExp
end

return MeridianSkill0