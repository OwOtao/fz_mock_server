local newClass = require("third.class.NewClass")

local ZhaoHurtDegreeFactory = require("app.FightSystem.Factory.FightSkillFactory.ZhaoHurtDegreeFactory")

local HurtDegree = require("app.FightSystem.FightSkill.HurtDegree")

local function getCharacterSkillLevel(character, skillId)
    if skillId == nil or skillId == "" then
        error("伤害强度：skilllv 动态变量属性ID不可为空")
    end

    if type(character.getSkillLevel) == "function" then
        return character:getSkillLevel(skillId)
    end

    return 0
end

local HurtDegreeGroup = {__id = ""}

function HurtDegreeGroup:create(id)
    local p = self.new()
    if id == nil then
        error("招式伤害组创建失败，id 不可为空")
    end
    p.__id = id
    return p
end

function HurtDegreeGroup:getId()
    return self.__id
end

--@desc: 当前伤害的创建对象
--@author:Seven
--@time:2021-07-05 10:53:43
function HurtDegreeGroup:setCharacter(character)
    --@RefType: [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
    self.__character = character
end

function HurtDegreeGroup:__createHurtDegrees()
    return ZhaoHurtDegreeFactory:createHurtDegreeByGroupID(self:getId())
end

function HurtDegreeGroup:getHurtValue()
    local hurtDegreeValue = 0

    local hurtDegreeList = self:__createHurtDegrees()

    for _, hurtDegree in ipairs(hurtDegreeList) do
        --@RefType [src.app.FightSystem.FightSkill.HurtDegree#HurtDegree]
        local hurtDegree = hurtDegree

        local attrTypeClass = hurtDegree:getAttTypeClass()

        local __owner = self.__character

        if attrTypeClass ~= nil then
            local conditionAttr = hurtDegree:getAttrType()
            if conditionAttr == nil then
                error("伤害强度：id " .. hurtDegree:getId() .. " 判断条件值未填写")
            end
            switch(
                attrTypeClass,
                {
                    ["role"] = function()
                        hurtDegree:setCurrConditionValue(__owner:getAttr(conditionAttr))
                    end,
                    ["weapon"] = function()
                        hurtDegree:setCurrConditionValue(__owner:getWeapon():getWeaponAttr(conditionAttr))
                    end,
                    ["buff"] = function()
                        hurtDegree:setCurrConditionValue(__owner:getBuffSystemAttr(conditionAttr))
                    end,
                    ["fistfoot"] = function()
                        hurtDegree:setCurrConditionValue(__owner:getFistFootAttr(conditionAttr))
                    end,
                    ["default"] = function()
                        error("伤害强度：id " .. hurtDegree:getId() .. " 判断条件类型未知或未定义：" .. tostring(attrTypeClass))
                    end
                }
            )
        end

        -- 设置动态变量
        local variables = hurtDegree:getVariables()
        if not MapIsEmpty(variables) then
            local __dynamicVarValues = {}
            for i, v_obj in ipairs(variables) do
                local value_type = v_obj.value_type
                local value_name = v_obj.value_name

                switch(
                    value_type,
                    {
                        [HurtDegree.VAR_TYPE.ROLE] = function()
                            local value = __owner:getAttr(value_name)
                            table.insert(__dynamicVarValues, value)
                        end,
                        [HurtDegree.VAR_TYPE.WEAPON] = function()
                            local value = __owner:getWeapon():getWeaponAttr(value_name)
                            table.insert(__dynamicVarValues, value)
                        end,
                        [HurtDegree.VAR_TYPE.BUFF_ATTR] = function()
                            local value = __owner:getBuffSystemAttr(value_name)
                            table.insert(__dynamicVarValues, value)
                        end,
                        [HurtDegree.VAR_TYPE.FISTFOOT] = function()
                            local value = __owner:getFistFootAttr(value_name)
                            table.insert(__dynamicVarValues, value)
                        end,
                        [HurtDegree.VAR_TYPE.BUFFID_NUM] = function()
                            local value = __owner:getBuffLayerCountByBuffId(value_name)
                            table.insert(__dynamicVarValues, value)
                        end,
                        [HurtDegree.VAR_TYPE.BATTLE] = function()
                            if value_name == "battleAvgqiatk" then
                                local __target = nil

                                if self.__character:hasTarget() then
                                    __target = self.__character:getTarget()
                                end

                                local FightFormula = require("app.FightSystem.FightFormula")

                                local value = FightFormula:calBattleQiAvgDamage(__owner, __target)

                                table.insert(__dynamicVarValues, value)
                            else
                                error("伤害强度：id " .. hurtDegree:getId() .. " 动态变量类型variablesList中battle动态变量value_name未知或未定义：" .. tostring(value_name))
                            end
                        end,
                        [HurtDegree.VAR_TYPE.SKILL_LEVEL] = function()
                            local value = getCharacterSkillLevel(__owner, value_name)
                            table.insert(__dynamicVarValues, value)
                        end,
                        ["default"] = function()
                            error("伤害强度：id " .. hurtDegree:getId() .. " 动态变量类型variablesList未知或未定义：" .. tostring(value_type))
                        end
                    }
                )
            end

            hurtDegree:setDynamicVariables(__dynamicVarValues)
        end

        -- 设置目标动态变量
        local targetVariables = hurtDegree:getVariablesTarget()
        if MapIsEmpty(targetVariables) == false then
            -- 此流程不可存在目标不存在的情况，如果有，需修改处理
            local __target = __owner:getTarget()

            local __targetDynamicVars = {}
            for _, v_obj in ipairs(targetVariables) do
                local value_type = v_obj.value_type
                local value_name = v_obj.value_name

                switch(
                    value_type,
                    {
                        [HurtDegree.VAR_TYPE.ROLE] = function()
                            local value = __target:getAttr(value_name)
                            table.insert(__targetDynamicVars, value)
                        end,
                        [HurtDegree.VAR_TYPE.WEAPON] = function()
                            local value = __target:getWeapon():getWeaponAttr(value_name)
                            table.insert(__targetDynamicVars, value)
                        end,
                        [HurtDegree.VAR_TYPE.BUFF_ATTR] = function()
                            local value = __target:getBuffSystemAttr(value_name)
                            table.insert(__targetDynamicVars, value)
                        end,
                        [HurtDegree.VAR_TYPE.FISTFOOT] = function()
                            local value = __target:getFistFootAttr(value_name)
                            table.insert(__targetDynamicVars, value)
                        end,
                        [HurtDegree.VAR_TYPE.BUFFID_NUM] = function()
                            local value = __target:getBuffLayerCountByBuffId(value_name)
                            table.insert(__targetDynamicVars, value)
                        end,
                        [HurtDegree.VAR_TYPE.BATTLE] = function()
                            if value_name == "battleAvgqiatk" then
                                local FightFormula = require("app.FightSystem.FightFormula")
                                local value = FightFormula:calBattleQiAvgDamage(__target, __owner)

                                table.insert(__targetDynamicVars, value)
                            else
                                error("伤害强度：id " .. hurtDegree:getId() .. " 动态变量类型variablesList中battle动态变量value_name未知或未定义：" .. tostring(value_name))
                            end
                        end,
                        [HurtDegree.VAR_TYPE.SKILL_LEVEL] = function()
                            local value = getCharacterSkillLevel(__target, value_name)
                            table.insert(__targetDynamicVars, value)
                        end,
                        ["default"] = function()
                            error("伤害强度：id " .. hurtDegree:getId() .. " 目标动态变量类型variablesListTarget未知或未定义：" .. tostring(value_type))
                        end
                    }
                )
            end

            hurtDegree:setTargetDynamicVariables(__targetDynamicVars)
        end

        if hurtDegree:matchCondititon() then
            hurtDegreeValue = hurtDegree:getHurtValue()
            break
        end
    end

    return hurtDegreeValue
end

return newClass("HurtDegreeGroup", {}, HurtDegreeGroup)
0