--[[
    author:Seven
    time:2022-11-07 12:07:56
    desc: 主动技能基础类
]]
local newClass = require("third.class.NewClass")

local ActiveSkillConf = require("app.FightSystem.Configuration.ActiveSkillConf")

local BasicActiveSkillManager = require("app.models.skill.BasicSkill.BasicActiveSkillManager")

local BasicActiveSkill = {}

BasicActiveSkill.LEARN_METHOD = {
    --@desc 填表条件学习
    FROM_CONDITION = 0,
    --@desc 残页学习
    FROM_BOOK = 1
}

function BasicActiveSkill:create(active_id)
    return BasicActiveSkill.new():__init(active_id)
end

function BasicActiveSkill:__init(active_id)
    --@desc 因暂时没有表格配置主动技能相关共同属性，所以基础类暂用1重主动技能的数据
    self.__res = ActiveSkillConf:getActiveSkillResByAIdAndLevel(active_id, 1)

    return self
end

-- 主动招式编号
function BasicActiveSkill:getId()
    return self.__res.id
end

-- 主动招式ID
function BasicActiveSkill:getActiveId()
    return self.__res.activeId
end

-- 主动招式名称
function BasicActiveSkill:getActiveName()
    return self.__res.activeName
end

-- 主动技能描述
function BasicActiveSkill:getDesc()
    return self.__res.desc
end

-- 主动招式类型
function BasicActiveSkill:getActiveType()
    return self.__res.activeType
end

-- 主动招式学习方式
function BasicActiveSkill:getLearnMethod()
    return self.__res.learnMethod
end

-- 主动招式学习条件
function BasicActiveSkill:getLearnConditions()
    if self.__learnClasses == nil then
        self.__learnClasses = {}

        if self.__res.learnConditions ~= nil then            
            local listStr = string.split(self.__res.learnConditions, "|")
            if not MapIsEmpty(listStr) then
                local conditions = {}
                for _, conditionStr in ipairs(listStr) do
                    local condArgs = string.split(conditionStr, "#")
    
                    table.insert(conditions, condArgs)
                end
    
                if not MapIsEmpty(conditions) then
                    for _, conditionArgs in ipairs(conditions) do
                        table.insert(self.__learnClasses, BasicActiveSkillManager:createLearnCondition(conditionArgs))
                    end
                end
            end
        end
    end

    return self.__learnClasses
end

-- 主动招式使用条件（界面显示用）
function BasicActiveSkill:getUseConditions()
    if self.__useConditionClasses == nil then
        self.__useConditionClasses = {}

        if self.__res.useConditions ~= nil then
            local listStr = string.split(self.__res.useConditions, "|")
            if not MapIsEmpty(listStr) then
                local conditions = {}
                for _, conditionStr in ipairs(listStr) do
                    local condArgs = string.split(conditionStr, "#")
    
                    table.insert(conditions, condArgs)
                end
    
                if not MapIsEmpty(conditions) then
                    for _, conditionArgs in ipairs(conditions) do
                        table.insert(self.__useConditionClasses, BasicActiveSkillManager:createUseCondition(conditionArgs))
                    end
                end
            end
        end
    end

    return self.__useConditionClasses
end

function BasicActiveSkill:getTiliCost()
    return self.__res.tiliCost
end

function BasicActiveSkill:getNeiliCost()
    return self.__res.neiliCost
end

return newClass("BasicActiveSkill", {}, BasicActiveSkill)
00000000000