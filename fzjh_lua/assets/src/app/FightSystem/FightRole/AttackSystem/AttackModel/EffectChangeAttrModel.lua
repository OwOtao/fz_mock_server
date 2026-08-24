local newClass = require("third.class.NewClass")
local EffectChangeAttrModel = {}

local BuffConf = require("app.FightSystem.Configuration.BuffConf")

local FightDesc = require("app.FightSystem.FightUtil.FightDesc")

function EffectChangeAttrModel:create()
    return EffectChangeAttrModel.new()
end

function EffectChangeAttrModel:setCharacterSystem(sys)
    --@RefType [src.app.FightSystem.FightRole.CharacterSystem#CharacterSystem]
    self.__characterSystem = sys
end

function EffectChangeAttrModel:setAttackerId(id)
    self.__attackerId = id
end

function EffectChangeAttrModel:setDefenderId(id)
    self.__defenderId = id
end

function EffectChangeAttrModel:setEffectOwnerId(id)
    self.__effectOwnerId = id
end

function EffectChangeAttrModel:setTargetId(id)
    self.__targetId = id
end

function EffectChangeAttrModel:setEffectId(effectId)
    self.__effectId = tostring(effectId)

    self.__effectInfo = BuffConf:getEffect(self.__effectId)
end

function EffectChangeAttrModel:setChangeAttrName(attrName)
    self.__attrName = attrName
end

function EffectChangeAttrModel:getChangeAttrName()
    return self.__attrName
end

function EffectChangeAttrModel:getChangeValue()
    return self.__changeValue
end

function EffectChangeAttrModel:setChangeValue(value)
    self.__changeValue = value
end

function EffectChangeAttrModel:getOwnerCombFinishRolePopText()
    local text = self.__effectInfo:getActiveEffectOwnRolePop()

    if text ~= nil then
        --@RefType [src.app.FightSystem.FightUtil.FightDesc#FightDesc]
        local desc = FightDesc:create()

        desc:setText(text)

        desc:setAttacker(self.__characterSystem:getCharacter(self.__attackerId))

        desc:setBuffTarget(self.__characterSystem:getCharacter(self.__targetId))

        desc:setDefender(self.__characterSystem:getCharacter(self.__defenderId))

        desc:setBuffOwner(self.__characterSystem:getCharacter(self.__effectOwnerId))

        desc:setBuffActualValue(math.abs(self.__changeValue))

        return desc:getString()
    end

    return nil
end

function EffectChangeAttrModel:getCombFinishPrintDesc()
    local text = self.__effectInfo:getActiveDesc()

    if text ~= nil then
        --@RefType [src.app.FightSystem.FightUtil.FightDesc#FightDesc]
        local desc = FightDesc:create()

        desc:setText(text)

        desc:setAttacker(self.__characterSystem:getCharacter(self.__attackerId))

        desc:setBuffTarget(self.__characterSystem:getCharacter(self.__targetId))

        if self.__defenderId then
            desc:setDefender(self.__characterSystem:getCharacter(self.__defenderId))
        end

        desc:setBuffOwner(self.__characterSystem:getCharacter(self.__effectOwnerId))

        desc:setBuffActualValue(math.abs(self.__changeValue))

        return desc
    end

    return nil
end

function EffectChangeAttrModel:getAnyCombFinishRolePopText()
    local text = self.__effectInfo:getRolePopText()

    if text ~= nil then
        --@RefType [src.app.FightSystem.FightUtil.FightDesc#FightDesc]
        local desc = FightDesc:create()

        desc:setText(text)

        desc:setAttacker(self.__characterSystem:getCharacter(self.__attackerId))

        desc:setBuffTarget(self.__characterSystem:getCharacter(self.__targetId))

        if self.__defenderId then
            desc:setDefender(self.__characterSystem:getCharacter(self.__defenderId))
        end

        desc:setBuffOwner(self.__characterSystem:getCharacter(self.__effectOwnerId))

        desc:setBuffActualValue(math.abs(self.__changeValue))

        return desc:getString()
    end

    return nil
end

return newClass("EffectChangeAttrModel", {}, EffectChangeAttrModel)
0000000000000000