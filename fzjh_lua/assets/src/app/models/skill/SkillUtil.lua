local WeaponTypesResManager = require("app.FightSystem.FightRole.CharacterEquipment.WeaponTypesResManager")

local SkillUtil = {}

--[[
    @desc: 将武器中文名转为准备名称
    author:TangJian
    time:2022-10-20 11:52:39
    --@weaponType: 
    @return:
]]
function SkillUtil:weaponTypeToPrepareType(weaponType)
    return switch(
        weaponType,
        {
            ["拳脚"] = "quanjiao",
            ["剑"] = "jianfa",
            ["刀"] = "daofa",
            ["棍"] = "gunfa",
            ["鞭"] = "bianfa",
            ["暗器"] = "anqi",
            ["双持"] = "shuangchi",
            ["乐器"] = "qinfa",
            default = function()
                error()
            end
        }
    )
end

--[[
    @desc: 将武器类型转为攻击类技能类型
    author:TangJian
    time:2022-10-20 11:52:53
    --@type1:
	--@type2: 
    @return:
]]
function SkillUtil:weaponTypeToAttackingSkillType(weaponType)
    if weaponType == "拳脚" then
        weaponType = "空手"
    end
    local weaponInfo = WeaponTypesResManager:getWeaponInfoByTypeAndType2(weaponType, "1")
    return tostring(weaponInfo.autoChooseSkill)
end

function SkillUtil:expMapToLvOnConfig(exp, conf)
    local maxLv = #conf

    if exp >= conf[maxLv].totalEXP then
        return maxLv
    end

    for i, v in ipairs(conf) do
        if v.totalEXP > exp then
            return i - 1
        end
    end
end

function SkillUtil:lvMapToNeedExpOnConfig(lv, conf)
    if lv > #conf then
        error("SkillUtil:lvMapToNeedExpOnConfig 已超最大等级 ： " .. tostring(#conf) .. " 参数等级 ： " .. tostring(lv))
    end
    return conf[lv].totalEXP
end

function SkillUtil:skillLvMapToSkillStageIdOnConfig(lv, conf)
    local maxStageId = #conf

    if lv >= conf[maxStageId].level then
        return maxStageId
    end

    for id, info in ipairs(conf) do
        if info.level > lv then
            return id - 1
        end
    end
end

--@desc: 获取知识类武学参悟消耗潜能
--@author:Seven
--@time:2024-01-11 22:19:24
--@skillId: 技能id
--@currInt: 当前悟性
--@return: number
function SkillUtil:getBaseKnowledgeSkillLianGongCostPot(skillId, currInt)
    local conf = self:getKonwledgeSkillsGrowthConf(skillId)

    local upgrade_cost_pot_base = conf.upgrade_cost_pot_base

    local upgrade_cost_pot_param = conf.upgrade_cost_pot_param

    local costPot = math.ceil((upgrade_cost_pot_base + currInt) * upgrade_cost_pot_param)

    return costPot
end

function SkillUtil:getBaseKnowledgeSkillLianGongCostJing(skillId)
    local conf = self:getKonwledgeSkillsGrowthConf(skillId)

    local upgrade_cost_jing = conf.upgrade_cost_jing

    return upgrade_cost_jing
end

--@desc: 获取知识类武学参悟增加经验值
--@author:Seven
--@time:2024-01-11 22:14:04
--@skillId: 技能id
--@currInt: 当前悟性
--@costPot: 消耗潜能
--@return: number
function SkillUtil:getBaseKnowledgeSkillLianGongAddExp(skillId, currInt, costPot)
    local SkillConst = require("app.models.skill.SkillConst")

    local baseSkill = Skill:getSkill(skillId)

    local conf = self:getKonwledgeSkillsGrowthConf(skillId)

    local skillPotEfficiency = baseSkill:getSkillPotEfficiency()

    --@desc 基础潜能转化率
    local basePotEfficiency = SkillConst:getZhiShiSkillParamContent(SkillConst.ZhiShiSkillParams.UPGRADE_ROLE_POT_BASE)

    --@desc 潜能转化率比例修正
    local upgradePotParam = SkillConst:getZhiShiSkillParamContent(SkillConst.ZhiShiSkillParams.UPGRADE_ROLE_POT_PARAM)

    local addExp = costPot * ((skillPotEfficiency * (basePotEfficiency + currInt) / upgradePotParam) / 100)

    return addExp
end

--@desc: 知识类武学参悟参数配置表（暂时放置位置）
--@author:Seven
--@time:2024-01-11 22:04:47
--@skillId: 技能id
function SkillUtil:getKonwledgeSkillsGrowthConf(skillId)
    local conf = requireWithEncrypt("script.zhishiSkills.zhishiSkillsGrowthConf")["练功"]

    return conf[skillId]
end

return SkillUtil
000000000