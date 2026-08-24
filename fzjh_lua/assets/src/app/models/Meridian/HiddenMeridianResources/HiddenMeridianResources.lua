local HiddenMeridianResources = {
    __mapMaxLv = nil
}

local MeridianMapConfig = require("script.meridian.HiddenMeridian.MeridianMapConfig")["玄脉图"]

local AcupointConfig = require("script.meridian.HiddenMeridian.AcupointConfig")["玄脉图"]

local MeridianBuffConfig = require("script.meridian.HiddenMeridian.MeridianLinkConfig")["玄络"]

local UnlockConditionConfig = require("script.meridian.HiddenMeridian.unlockConditionConfig")["data"]

local DeleteConditionConfig = require("script.meridian.HiddenMeridian.deleteConditionConfig")["data"]

local ShowConditionConfig = require("script.meridian.HiddenMeridian.showConditionConfig")["data"]

local SkillDamageAttrConf = require("app.FightSystem.Configuration.SkillDamageAttrConf")

function HiddenMeridianResources:getHiddenMeridianChartRes(meridianMapId)
    if not meridianMapId then
        error("获取隐脉图资源，ID不可为空")
    end

    local res = MeridianMapConfig[tostring(meridianMapId)]

    if not res then
        error("没有找到隐脉图资源，id：" .. tostring(meridianMapId))
    end

    return res
end

function HiddenMeridianResources:getHiddenMeridianChartIdByLv(lv)
    for _, v in pairs(MeridianMapConfig) do
        if v.class == lv then
            return v.id
        end
    end

    error("没有找到对应等级的隐脉图资源，lv：" .. tostring(lv))
end

function HiddenMeridianResources:getAcupointRes(acupointId)
    if not acupointId then
        error("获取窍关资源，ID不可为空")
    end

    local res = AcupointConfig[tostring(acupointId)]

    if not res then
        error("没有找到窍关资源，id：" .. tostring(acupointId))
    end

    return res
end

function HiddenMeridianResources:getMeridianBuffRes(meridianBuffId)
    if not meridianBuffId then
        error("获取玄络资源，ID不可为空")
    end

    local res = MeridianBuffConfig[tostring(meridianBuffId)]

    if not res then
        error("没有找到玄络资源，id：" .. tostring(meridianBuffId))
    end

    return res
end

function HiddenMeridianResources:getConditionRes(conditionId)
    if not conditionId then
        error("获取条件资源，ID不可为空")
    end

    local res = UnlockConditionConfig[conditionId]

    if not res then
        error("没有找到条件资源，id：" .. tostring(conditionId))
    end

    return res
end

function HiddenMeridianResources:getDelConditionRes(delConditionId)
    if not delConditionId then
        error("获取删除条件资源，ID不可为空")
    end

    local res = DeleteConditionConfig[delConditionId]

    if not res then
        error("没有找到删除条件资源，id：" .. tostring(delConditionId))
    end

    return res
end

function HiddenMeridianResources:getShowConditionRes(showConditionId)
    if not showConditionId then
        error("获取显示条件资源，ID不可为空")
    end

    local res = ShowConditionConfig[showConditionId]

    if not res then
        error("没有找到显示条件资源，id：" .. tostring(showConditionId))
    end

    return res
end

function HiddenMeridianResources:getHiddenMeridianChartMaxLv()
    if self.__mapMaxLv == nil then
        self.__mapMaxLv = 0
    
        for _, v in pairs(MeridianMapConfig) do
            if v.class > self.__mapMaxLv then
                self.__mapMaxLv = v.class
            end
        end
    end

    return self.__mapMaxLv
end

function HiddenMeridianResources:getDamageAttrName(damageType,damageId)
    local name

    if damageType == "atkDamageClass" then
        name = SkillDamageAttrConf:getAtkDamageClassName(damageId)
    elseif damageType == "defDamageClass" then
        name = SkillDamageAttrConf:getDefDamageClassName(damageId)
    end

    return name
end

function HiddenMeridianResources:getMeridianBuffConfig()
    return MeridianBuffConfig
end

return HiddenMeridianResources
0000000000000