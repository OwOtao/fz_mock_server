local class = require("third.class.NewClass")
local BuffConst = require("app.models.ChallengeMap.BuffSystem.BuffConst")
local ZhaoHurtDegreeFactory = require("app.FightSystem.Factory.FightSkillFactory.ZhaoHurtDegreeFactory")
local normalBuffs = {}

local NormalBuff = {}

local function getEffectParams(parmas)
    if type(parmas) == "string" then
        local values = string.split(parmas,"#")
        return values
    end
    return 
end

function NormalBuff:create(data)
    local p = NormalBuff.new(data)
    p:init()
    return p
end

function NormalBuff:init()
end

function NormalBuff:getBuffId()
    return self.id
end

function NormalBuff:getAddBuffDesc()
    return self.addBuffDesc
end

function NormalBuff:getDeleteBuffDesc()
    return self.deleteBuffDesc
end

function NormalBuff:getBuffEffectValues(fightRole)
    local effectType = self:getBuffEffectType()
    local params = getEffectParams(self.effectParam)

    if MapIsEmpty(params) == false then
        return switch(effectType,{
            [BuffConst.BuffEffectType.NONE_VALUE] = function()
                -- 一般不会调用到这里，但为了保险起见，还是加上这个分支避免报错
                return BuffConst.BuffEffectType.NONE_VALUE, 0, nil
            end,
            [BuffConst.BuffEffectType.ROLE_FIGHT_ATTR_VALUE] = function()
                local attr = params[1]
                local calcalutionType = params[2]
                local value = params[3]

                if tonumber(calcalutionType) == 1 then
                    local hurtDegreeID = params[3]
                    local hurtDegrees = ZhaoHurtDegreeFactory:createHurtDegreeGroup(hurtDegreeID, fightRole)
                    value = hurtDegrees:getHurtValue()
                else
                    value = tonumber(value)
                end

                return BuffConst.BuffEffectType.ROLE_FIGHT_ATTR_VALUE,attr,value
            end,

            [BuffConst.BuffEffectType.ROLE_FIGHT_ATTR_PERCENT_VALUE] = function()
                local attr = params[1]
                local calcalutionType = params[2]
                local value = params[3]

                if tonumber(calcalutionType) == 1 then
                    local hurtDegreeID = params[3]
                    local hurtDegrees = ZhaoHurtDegreeFactory:createHurtDegreeGroup(hurtDegreeID, fightRole)
                    value = hurtDegrees:getHurtValue()
                else
                    value = tonumber(value)
                end

                return BuffConst.BuffEffectType.ROLE_FIGHT_ATTR_PERCENT_VALUE,attr,value
            end,

            [BuffConst.BuffEffectType.ROLE_ATTR_VALUE] = function()
                local attr = params[1]
                local calcalutionType = params[2]
                local value = params[3]

                if tonumber(calcalutionType) == 1 then
                    local hurtDegreeID = params[3]
                    local hurtDegrees = ZhaoHurtDegreeFactory:createHurtDegreeGroup(hurtDegreeID, fightRole)
                    value = hurtDegrees:getHurtValue()
                else
                    value = tonumber(value)
                end
                
                return BuffConst.BuffEffectType.ROLE_ATTR_VALUE,attr,value
            end,

            [BuffConst.BuffEffectType.ROLE_ATTR_PERCENT_VALUE] = function()
                local attr = params[1]
                local attrParam = params[2]
                local value = attrParam.."#"..params[3]
                
                return BuffConst.BuffEffectType.ROLE_ATTR_PERCENT_VALUE,attr,value
            end
        })
    end
    return 
end

function NormalBuff:getBuffEffectType()
    return self.effectType
end

function NormalBuff:getBuffRemoveInfo()
    local buffRemoveType = self.delete

    local removeTypeInfo = {}

    buffRemoveType = string.split(buffRemoveType,"|")

    for k,info in pairs(buffRemoveType) do
        local value = string.split(info,"#")
        local removeType = tonumber(value[1])
        local buffValue = tonumber(value[2])

        if removeType == BuffConst.NormalBuffRemoveType.DURATION then
            removeTypeInfo[BuffConst.NormalBuffRemoveType.DURATION] = buffValue
        elseif removeType == BuffConst.NormalBuffRemoveType.FIGHT_TIMES then
            removeTypeInfo[BuffConst.NormalBuffRemoveType.FIGHT_TIMES] = buffValue
        elseif removeType == BuffConst.NormalBuffRemoveType.SYSTEM then
            removeTypeInfo[BuffConst.NormalBuffRemoveType.SYSTEM] = buffValue
        end
    end

    return removeTypeInfo
end

function NormalBuff:getFightBuffParamsArray()
    assert(self.addBuffID,"NormalBuff:getFightBuffParamsArray: id"..tostring(self.id))
    assert(self.addBuffdynamicArg1,"NormalBuff:getFightBuffParamsArray: id"..tostring(self.id))
    assert(self.addBuffdynamicArg2,"NormalBuff:getFightBuffParamsArray: id"..tostring(self.id))
    assert(self.addBuffdynamicArg3,"NormalBuff:getFightBuffParamsArray: id"..tostring(self.id))
    return {self.addBuffID,self.addBuffdynamicArg1,self.addBuffdynamicArg2,self.addBuffdynamicArg3}
end

return class("Buff", {}, NormalBuff)00000