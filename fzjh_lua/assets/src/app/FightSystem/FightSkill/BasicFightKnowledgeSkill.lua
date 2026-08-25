--[[
    author:Seven
    time:2026-05-19 19:49:51
    desc: 战斗中使用的知识类武学数据
]]
local newClass = require("third.class.NewClass")

--@RefType [src.app.FightSystem.FightSkill.BasicFightSkill#BasicFightSkill]
local BasicFightSkill = require("app.FightSystem.FightSkill.BasicFightSkill")

local ACarryBuffAddToCharacter = require("app.FightSystem.FightRole.CharacterBuff.Utils.ACarryBuffAddToCharacter")

--@SuperType [src.app.FightSystem.FightSkill.BasicFightSkill#BasicFightSkill]
local BasicFightKnowledgeSkill = {}

function BasicFightKnowledgeSkill:create(id)
    return BasicFightKnowledgeSkill.new():__init(id)
end

function BasicFightKnowledgeSkill:__init(id)
    BasicFightSkill.__init(self, id)
    return self
end

function BasicFightKnowledgeSkill:getCarryBuffArray()
    return {}
end

--@desc: 该buff添加器组应用于入场时拥有该技能的知识类武学
--@author:Seven
--@time:2026-05-19 19:56:27
--@return 添加器id数组
function BasicFightKnowledgeSkill:getCarryBuffAdderGroupArray()
    local idList = self.__basicSkill:getEnteredLauncherAdd()

    if MapIsEmpty(idList) then
        return
    end

    local list = {}

    local CharacterBuffAdderGroupFactory = require("app.FightSystem.FightRole.CharacterBuff.BuffAdders.CharacterBuffAdderGroupFactory")

    for _, id in ipairs(idList) do
        table.insert(list, CharacterBuffAdderGroupFactory:getEnterFightBuffAdderGroup(id, self.__character, self.__character:getFight()))
    end

    return list
end

-- 以下方法不可修改
function BasicFightKnowledgeSkill:getSkillTypes()
    error("目前只支持了知识类武学，当前武学不该调用此方法 getSkillTypes" .. self:getId())
end

function BasicFightKnowledgeSkill:getAutoZhaoAtkDamageClass()
    error("目前只支持了知识类武学，当前武学不该调用此方法 getAutoZhaoAtkDamageClass" .. self:getId())
end

function BasicFightKnowledgeSkill:getZhaoJiaDefDamageClass()
    error("目前只支持了知识类武学，当前武学不该调用此方法 getZhaoJiaDefDamageClass" .. self:getId())
end

function BasicFightKnowledgeSkill:getZhaoJiaDefDamageParam()
    error("目前只支持了知识类武学，当前武学不该调用此方法 getZhaoJiaDefDamageParam" .. self:getId())
end

function BasicFightKnowledgeSkill:isAttackSkill()
    return false
end

function BasicFightKnowledgeSkill:isBingQiSkill()
    return false
end

function BasicFightKnowledgeSkill:isQuanJiaoSkill()
    return false
end

function BasicFightKnowledgeSkill:isNeiGongSkill()
    return false
end

function BasicFightKnowledgeSkill:isDodgeSkill()
    return false
end

function BasicFightKnowledgeSkill:isParrySkill()
    return false
end

return newClass("BasicFightKnowledgeSkill", {BasicFightSkill, ACarryBuffAddToCharacter}, BasicFightKnowledgeSkill)
0000000