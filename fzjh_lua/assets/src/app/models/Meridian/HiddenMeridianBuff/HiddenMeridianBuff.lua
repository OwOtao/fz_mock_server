local newClass = require("third.class.NewClass")

local HiddenMeridianResources = require("app.models.Meridian.HiddenMeridianResources.HiddenMeridianResources")

local HiddenMeridianEffect = require("app.models.Meridian.HiddenMeridianBuff.HiddenMeridianEffect")

local HiddenMeridianConditions = require("app.models.Meridian.HiddenMeridianBuff.Conditions.HiddenMeridianConditions")

local HiddenMeridianDelConditions = require("app.models.Meridian.HiddenMeridianBuff.Conditions.HiddenMeridianDelConditions")

local HiddenMeridianShowConditions = require("app.models.Meridian.HiddenMeridianBuff.Conditions.HiddenMeridianShowConditions")

local HiddenMeridianBuff = {}

function HiddenMeridianBuff:create(...)
    local p = HiddenMeridianBuff:new()
    p:init(...)
    return p
end

function HiddenMeridianBuff:ctor()
    self.__effectList = {}

    self.__spEffectList = {}

    self.__spActiveEffectDataList = {}
end

function HiddenMeridianBuff:init(role,meridianBuffId)
    self.__role = role

    self.__res = HiddenMeridianResources:getMeridianBuffRes(meridianBuffId)

    local effects = self:getProperty()
    
    if not MapIsEmpty(effects) then
        for i,effectData in ipairs(effects) do
            local effect = HiddenMeridianEffect:create(effectData)
            table.insert(self.__effectList, effect) 
        end
    end

    local speEffects = self:getSpecialProperty()
    
    if not MapIsEmpty(speEffects) then
        for i,effectData in ipairs(speEffects) do
            if effectData[1] == "damageAttr" then
                local effect = HiddenMeridianEffect:create(effectData)
                table.insert(self.__spEffectList, effect) 
            elseif effectData[1] == "activeEffect" then
                table.insert(self.__spActiveEffectDataList, effectData) 
            end
        end
    end
end

function HiddenMeridianBuff:getId()
    return self.__res.id
end

function HiddenMeridianBuff:getName()
    return self.__res.name
end

function HiddenMeridianBuff:getType()
    return self.__res.type
end

function HiddenMeridianBuff:getClass()
    return self.__res.class
end

function HiddenMeridianBuff:getUnlockCondition()
    return self.__res.Unlockcondition
end

function HiddenMeridianBuff:getUnlockText()
    return self.__res.Unlocktext or ""
end

function HiddenMeridianBuff:getResource()
    return self.__res.resource
end

function HiddenMeridianBuff:getProperty()
    return self.__res.property
end

function HiddenMeridianBuff:getSpecialProperty()
    return self.__res.specialproperty
end

function HiddenMeridianBuff:getSpecialEffectText()
    return self.__res.specialtext or ""
end

function HiddenMeridianBuff:getSpecialAttrText()
    return self.__res.specialnaturetext or ""
end

function HiddenMeridianBuff:getSpecialPropertyUnlockCondition()
    return self.__res.specialpropertyul
end

function HiddenMeridianBuff:getSpecialUnlockText()
    return self.__res.SUnlocktext or ""
end

function HiddenMeridianBuff:getDeleteCondition()
    return self.__res.deleteCondition
end

function HiddenMeridianBuff:getShowCondition()
    return self.__res.showCondition
end

function HiddenMeridianBuff:getTriggerEffectList()
    local speConditions = HiddenMeridianConditions:create(self.__role,self:getSpecialPropertyUnlockCondition())

    if speConditions:check() then
        return table.mergeArray(self.__effectList, self.__spEffectList)
    else
        return self.__effectList
    end
end

function HiddenMeridianBuff:getTriggerActiveEffectDataList()
    local speConditions = HiddenMeridianConditions:create(self.__role,self:getSpecialPropertyUnlockCondition())

    if speConditions:check() then
        return self.__spActiveEffectDataList
    else
        return {}
    end
end

function HiddenMeridianBuff:canUnlock()
    local conditions = HiddenMeridianConditions:create(self.__role,self:getUnlockCondition())

    return conditions:check()
end

function HiddenMeridianBuff:canShow()
    local showConditions = HiddenMeridianShowConditions:create(self.__role,self:getShowCondition())

    return showConditions:check()
end

function HiddenMeridianBuff:canDelete(delNodal)
    local delConditions = HiddenMeridianDelConditions:create(self.__role,self:getDeleteCondition(),delNodal)

    return delConditions:check()
end

return newClass("HiddenMeridianBuff", {}, HiddenMeridianBuff)
000000000000