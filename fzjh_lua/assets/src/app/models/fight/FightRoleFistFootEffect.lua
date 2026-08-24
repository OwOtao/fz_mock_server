local newClass = require("third.class.NewClass")
local FistFootResManager = require("app.models.FistFootSystem.FistFootResManager")
local LogSystem = require("app.models.LogSystem.LogSystem")
local BasicSkill = require("app.models.skill.BasicSkill.BasicSkill")
local RoleFistFootEffect = require("src.app.models.FistFootSystem.FistFootEffect.RoleFistFootEffect")

local FightRoleFistFootEffect = {}

function FightRoleFistFootEffect:create()
    local p = FightRoleFistFootEffect.new()
    return p
end

function FightRoleFistFootEffect:ctor()
end

function FightRoleFistFootEffect:getRoleFistFootEffects(role)
    local effects = role:getFistFootEffects()

    table.sort(effects, function(a, b)
        return a:getId() < b:getId()
    end)

    return effects
end

function FightRoleFistFootEffect:getFightRandomTriggerEffects(role, effectType)
    local effects = self:getRoleFistFootEffects(role:getRole())

    if MapIsEmpty(effects) then
        return
    end

    local triggerEffects = {}

    local args = {
        currStr = role:getFinalAttr("currStr"),
        currDex = role:getFinalAttr("currDex"),
        currCon = role:getFinalAttr("currCon"),
        currInt = role:getFinalAttr("currInt"),
        zhengqi = role:getFinalAttr("zhengqi"),
        currjqdamage = 0
    }

    local isAddEffects = {}

    for k, effect in ipairs(effects) do
        if not isAddEffects[tostring(effect:getId())] and effect:getConditiontype() == effectType then
            local currjqdamage = 0
            if effect:checkIsFromPrepSkill() then
                currjqdamage = role:getPrepJqdamage()
            elseif effect:checkIsFromStandBySkill() then
                currjqdamage = role:getStandByJqdamage()
            end

            args.currjqdamage = currjqdamage
            local isTrue = false
            local randomNum1 = role._fight:randomAndSetSeed(1, 100) - 1
            local randomNum2 = role._fight:randomAndSetSeed(1, 100)
            
            local effectRandomNum = self:__getEffectValue(effect:getFormula(), args) * 10000
            local effectRandomNum1 = Helper:mathFloor(effectRandomNum / 100)
            local effectRandomNum2 = Helper:mathFloor(effectRandomNum % 100)


            if effectRandomNum1 > randomNum1 then
                isTrue = true
            elseif effectRandomNum1 == randomNum1 then
                isTrue = effectRandomNum2 > randomNum2
            end

            LogSystem:log("旧版战斗：拳脚特性概率"," |特性id：",effect:getId()," |概率值：",effectRandomNum," |随机值1：",randomNum1," |随机值2：",randomNum2)
            
            if isTrue then
                isAddEffects[tostring(effect:getId())] = true
                
				local effectId = effect:getSpecialEffectId()

				local args = effect:getSpecialEffectArgs()
				
				local triggerEffect = Skill:getSkillEffect(effectId):clone()
				
				triggerEffect:setZArgs(args)
                
				triggerEffect:setEffectExtraValue(currjqdamage)
                
                table.insert(triggerEffects, triggerEffect)
            end
        end
    end

    return triggerEffects
end

function FightRoleFistFootEffect:getHitBuffsValue(role)
    local value = 0

    local effects = self:getRoleFistFootEffects(role)

    if MapIsEmpty(effects) == false then
        local args = {
            currStr = role:getFinalAttr("currStr"),
            currDex = role:getFinalAttr("currDex"),
            currCon = role:getFinalAttr("currCon"),
            currInt = role:getFinalAttr("currInt"),
            zhengqi = role:getFinalAttr("zhengqi"),
            currjqdamage = 0
        }

        for k, effect in ipairs(effects) do
            if effect:getSpecialEffectId() == "HIT" then
                if effect:checkIsFromPrepSkill() then
                    args.currjqdamage = role:getPrepJqdamage()
                elseif effect:checkIsFromStandBySkill() then
                    args.currjqdamage = role:getStandByJqdamage()
                end
                LogSystem:log("旧版战斗：拳脚特性id：",effect:getId())
                value = value + self:__getEffectValue(effect:getFormula(), args)
            end
        end

        if value > 0 then
            LogSystem:log("旧版战斗：拳脚特性命中加成值：",value)
        end
    end
    

    return value
end

function FightRoleFistFootEffect:getAtkBuffsValue(role, skillId)
    local value = 0
    local sourceType = 0
    local prepSkillId = role:getPrepareSkill("quanjiao1")
    local standbyPrepSkillId = role:getPrepareSkill("quanjiao2")
    local isTrue = false

    if skillId == prepSkillId then
        isTrue = true
        sourceType = 1
    end

    if skillId == standbyPrepSkillId then
        isTrue = true
        sourceType = 2
    end

    if not isTrue then
        return value
    end

    local fistFootEffects = {}

    local effects = self:getRoleFistFootEffects(role)
    for k, effect in ipairs(effects) do
        if effect:getSourceType() == sourceType or effect:checkIsFromPrepSkillAndStandBySkill() then
            table.insert(fistFootEffects, effect)
        end
    end
   
    if MapIsEmpty(fistFootEffects) == false then
        local args = {
            currStr = role:getFinalAttr("currStr"),
            currDex = role:getFinalAttr("currDex"),
            currCon = role:getFinalAttr("currCon"),
            currInt = role:getFinalAttr("currInt"),
            zhengqi = role:getFinalAttr("zhengqi"),
            currjqdamage = 0
        }
        for k, effect in ipairs(fistFootEffects) do
            if effect:getSpecialEffectId() == "ATK" then
                if effect:checkIsFromPrepSkill() then
                    args.currjqdamage = role:getPrepJqdamage()
                elseif effect:checkIsFromStandBySkill() then
                    args.currjqdamage = role:getStandByJqdamage()
                end
                LogSystem:log("旧版战斗：拳脚特性id：",effect:getId())
                value = value + self:__getEffectValue(effect:getFormula(), args)
            end
        end

        if value > 0 then
            LogSystem:log("旧版战斗：拳脚特性攻击加成值：",value)
        end
    end
    
    return value
end

function FightRoleFistFootEffect:getDodgeBuffsValue(role)
    local value = 0

    local effects = self:getRoleFistFootEffects(role)

    if MapIsEmpty(effects) == false then
        local args = {
            currStr = role:getFinalAttr("currStr"),
            currDex = role:getFinalAttr("currDex"),
            currCon = role:getFinalAttr("currCon"),
            currInt = role:getFinalAttr("currInt"),
            zhengqi = role:getFinalAttr("zhengqi"),
            currjqdamage = 0
        }

        for k, effect in ipairs(effects) do
            if effect:getSpecialEffectId() == "DODGE" then
                if effect:checkIsFromPrepSkill() then
                    args.currjqdamage = role:getPrepJqdamage()
                elseif effect:checkIsFromStandBySkill() then
                    args.currjqdamage = role:getStandByJqdamage()
                end
                LogSystem:log("旧版战斗：拳脚特性id：",effect:getId())
                value = value + self:__getEffectValue(effect:getFormula(), args)
            end
        end

        if value > 0 then
            LogSystem:log("旧版战斗：拳脚特性闪避加成值：",value)
        end
    end
    
    return value
end

function FightRoleFistFootEffect:getParryBuffsValue(role)
    local value = 0

    local effects = self:getRoleFistFootEffects(role)

    if MapIsEmpty(effects) == false then
        local args = {
            currStr = role:getFinalAttr("currStr"),
            currDex = role:getFinalAttr("currDex"),
            currCon = role:getFinalAttr("currCon"),
            currInt = role:getFinalAttr("currInt"),
            zhengqi = role:getFinalAttr("zhengqi"),
            currjqdamage = 0
        }

        for k, effect in ipairs(effects) do
            if effect:getSpecialEffectId() == "PARRY" then
                if effect:checkIsFromPrepSkill() then
                    args.currjqdamage = role:getPrepJqdamage()
                elseif effect:checkIsFromStandBySkill() then
                    args.currjqdamage = role:getStandByJqdamage()
                end
                LogSystem:log("旧版战斗：拳脚特性id：",effect:getId())
                value = value + self:__getEffectValue(effect:getFormula(), args)
            end
        end

        if value > 0 then
            LogSystem:log("旧版战斗：拳脚特性招架加成值：",value)
        end
    end
    
    return value
end

function FightRoleFistFootEffect:getDefBuffsValue(role)
    local value = 0

    local effects = self:getRoleFistFootEffects(role)

    if MapIsEmpty(effects) == false then
        local args = {
            currStr = role:getFinalAttr("currStr"),
            currDex = role:getFinalAttr("currDex"),
            currCon = role:getFinalAttr("currCon"),
            currInt = role:getFinalAttr("currInt"),
            zhengqi = role:getFinalAttr("zhengqi"),
            currjqdamage = 0
        }

        for k, effect in ipairs(effects) do
            if effect:getSpecialEffectId() == "DEF" then
                if effect:checkIsFromPrepSkill() then
                    args.currjqdamage = role:getPrepJqdamage()
                elseif effect:checkIsFromStandBySkill() then
                    args.currjqdamage = role:getStandByJqdamage()
                end
                LogSystem:log("旧版战斗：拳脚特性id：",effect:getId())
                value = value + self:__getEffectValue(effect:getFormula(), args)
            end
        end

        if value > 0 then
            LogSystem:log("旧版战斗：拳脚特性防御加成值：",value)
        end
    end
    
    return value
end

function FightRoleFistFootEffect:__getEffectValue(formula, args)
    if type(formula) == "number" then
        return formula
    end

    LogSystem:log("旧版战斗：拳脚特性技谙值参数：",args.currjqdamage)
    
    local addValue = Helper:GetValueFromScript(formula, args)
    return addValue
end

return newClass("FightRoleFistFootEffect", {}, FightRoleFistFootEffect)
0000000