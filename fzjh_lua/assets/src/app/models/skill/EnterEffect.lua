local newClass = require("third.class.NewClass")

local enterEffectMap = require("script.skill.activeZhao").enterEffect

local Skill = require("app.models.skill.Skill")

local EnterEffect = {
    __id = nil,
    __skillId = nil,
    __type = nil,
    __effects = {}
}

function EnterEffect:create(id,role)
    local p = EnterEffect.new()
    p:__init(id,role)
    return p
end

function EnterEffect:ctor()
    self.__id = nil

    self.__skillId = nil

    self.__type = nil

    self.__effects = {}
end

function EnterEffect:__init(id,role)
    self:__initRole(role)

    self:__initEffect(id)
end

function EnterEffect:__initRole(role)
    self.__role = role
end

function EnterEffect:__initEffect(id)
    for k, v in pairs(enterEffectMap) do
        if id == k then
            self.__id = v.id

            self.__skillId = v.skillId

            self.__type = tonumber(v.type)

            local effects = {}
        
            local strList = string.split(v.effectId, "|")
        
            for i,v in ipairs(strList) do
                local effectList = string.split(v, "#")
        
                local effectId = effectList[1]
        
                local effect = Skill:getSkillEffect(effectId):clone()
        
                local zArgs = {
                    tonumber(effectList[2]),
                    tonumber(effectList[3]),
                    tonumber(effectList[4]),
                }
        
                effect:setZArgs(zArgs)
        
                table.insert(effects, effect)
            end

            self.__effects = effects
        end
    end
end

function EnterEffect:getEffects()
    return self.__effects
end

function EnterEffect:condition()
    if self.__id == nil or self.__type == nil then
        return false
    end

    if self.__type == 1 then
        local skill,doubleSkill = self.__role:getPrepareAttackSkill()
        if skill and skill.id == self.__skillId then
            return true
        end

        if doubleSkill and doubleSkill.id == self.__skillId then
            return true
        end
    else
        local prepareSkillType = switch(tostring(self.__type),{
            ["2"] = "neigong",
            ["3"] = "qinggong",
            ["4"] = "zhaojia",
        })

        local prepareSkillId = self.__role:getPrepareSkillIdByType(prepareSkillType)

        if prepareSkillId == self.__skillId then
            return true
        end
    end

    return false
end

return newClass("EnterEffect", {}, EnterEffect)
0000000000000000