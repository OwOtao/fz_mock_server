local newClass =
    require("third.class.NewClass")

local DoChangeCharacterModel = {
    __effectChangeAttrList = {},
    __resultMap = {}
}

function DoChangeCharacterModel:create(character)
    local p = DoChangeCharacterModel.new()
    p:__init(character)
    return p
end

function DoChangeCharacterModel:__init(character)
    assert(character ~= nil, "DoChangeCharacterModel:__init character 不能为空")

    --@RefType [src.app.FightSystem.FightRole.FightCharacter#FightCharacter]
    self.__character = character
end

function DoChangeCharacterModel:addEffectChangeAttr(effectChangeAttr)
    table.insert(self.__effectChangeAttrList, effectChangeAttr)
end

function DoChangeCharacterModel:__addAttrValue(attrName, value)
    if self.__resultMap[attrName] == nil then
        self.__resultMap[attrName] = 0
    end

    self.__resultMap[attrName] = self.__resultMap[attrName] + value
end

function DoChangeCharacterModel:getCombFinishPrintDesc()
    local descList = {}

    if #self.__effectChangeAttrList > 0 then
        for i = 1, #self.__effectChangeAttrList do
            --@RefType [src.app.FightSystem.FightRole.AttackSystem.AttackModel.EffectChangeAttrModel#EffectChangeAttrModel]
            local effectChangeAttr = self.__effectChangeAttrList[i]

            local desc = effectChangeAttr:getCombFinishPrintDesc()

            if desc ~= nil then
                table.insert(descList, desc)
            end
        end
    end

    return descList
end

function DoChangeCharacterModel:getOwnerCombFinishRolePopText()
    local textList = {}

    if #self.__effectChangeAttrList > 0 then
        for i = 1, #self.__effectChangeAttrList do
            --@RefType [src.app.FightSystem.FightRole.AttackSystem.AttackModel.EffectChangeAttrModel#EffectChangeAttrModel]
            local effectChangeAttr = self.__effectChangeAttrList[i]

            local text = effectChangeAttr:getOwnerCombFinishRolePopText()

            if text ~= nil then
                table.insert(textList, text)
            end
        end
    end

    return textList
end

function DoChangeCharacterModel:getAnyCombFinishRolePopTextList()
    local textList = {}

    if #self.__effectChangeAttrList > 0 then
        for i = 1, #self.__effectChangeAttrList do
            --@RefType [src.app.FightSystem.FightRole.AttackSystem.AttackModel.EffectChangeAttrModel#EffectChangeAttrModel]
            local effectChangeAttr = self.__effectChangeAttrList[i]

            local text = effectChangeAttr:getAnyCombFinishRolePopText()

            if text ~= nil then
                table.insert(textList, text)
            end
        end
    end

    return textList
end

function DoChangeCharacterModel:doChangeAttrs()
    if #self.__effectChangeAttrList > 0 then
        for i = 1, #self.__effectChangeAttrList do
            --@RefType [src.app.FightSystem.FightRole.AttackSystem.AttackModel.EffectChangeAttrModel#EffectChangeAttrModel]
            local effectChangeAttr = self.__effectChangeAttrList[i]

            self:__addAttrValue(effectChangeAttr:getChangeAttrName(), effectChangeAttr:getChangeValue())
        end
    end

    local result = {}
    if not MapIsEmpty(self.__resultMap) then
        result = self.__character:doChangeAttrMap(self.__resultMap)
    end
    return result
end

function DoChangeCharacterModel:doCharacterCombFinishPopText()
    local textList = self:getOwnerCombFinishRolePopText()
    if #textList > 0 then
        for i = 1, #textList do
            local text = textList[i]

            self.__character:PopText(text)
        end
    end
end

function DoChangeCharacterModel:doCharacterCombFinishPrintDesc()
    local descList = self:getCombFinishPrintDesc()
    if #descList > 0 then
        self.__character:printDesces(descList)
    end
end

function DoChangeCharacterModel:doAnyCharacterCombFinishPopText()
    local textList = self:getAnyCombFinishRolePopTextList()
    if #textList > 0 then
        for i = 1, #textList do
            local text = textList[i]

            self.__character:PopText(text)
        end
    end
end

return newClass("DoChangeCharacterModel", {}, DoChangeCharacterModel)
0000000000000