--[[
Descripttion: 武学进阶类 
version: 
Author: LvBin
Date: 2024-07-19 18:20:37
--]]
local newClass = require("third.class.NewClass")

local SkillAdvance = {}

function SkillAdvance:create(res)
    return SkillAdvance.new():__init(res)
end

function SkillAdvance:__init(res)
    self.__res = res
    return self
end

function SkillAdvance:getId()
    return self.__res.id
end

function SkillAdvance:getSkill()
    return self.__res.kungfuexp
end

function SkillAdvance:getSkillId()
    return self:getSkill()[1]
end

function SkillAdvance:getSkillLv()
    return tonumber(self:getSkill()[2]) 
end

function SkillAdvance:getActiveZhao1()
    return self.__res.skillexp
end

function SkillAdvance:getActiveZhaoId1()
    return self:getActiveZhao1()[1]
end

function SkillAdvance:getActiveZhaoExp1()
    return tonumber(self:getActiveZhao1()[2]) 
end

function SkillAdvance:getActiveZhao2()
    return self.__res.skillexp2
end

function SkillAdvance:getActiveZhaoId2()
    return self:getActiveZhao2()[1]
end

function SkillAdvance:getActiveZhaoExp2()
    return tonumber(self:getActiveZhao2()[2]) 
end

function SkillAdvance:getItems()
    return self.__res.Items
end

function SkillAdvance:getItemId()
    return self:getItems()[1]
end

function SkillAdvance:getItemNum()
    return tonumber(self:getItems()[2])
end

function SkillAdvance:getNeedSkill()
    return self.__res.requirekungfuexp
end

function SkillAdvance:getNeedSkillId()
    return self:getNeedSkill()[1]
end

function SkillAdvance:getNeedSkillLv()
    return tonumber(self:getNeedSkill()[2])
end

function SkillAdvance:getNeedActiveZhao1()
    return self.__res.requireskillexp
end

function SkillAdvance:getNeedActiveZhaoId1()
    return self:getNeedActiveZhao1()[1]
end

function SkillAdvance:getNeedActiveZhaoExp1()
    return tonumber(self:getNeedActiveZhao1()[2])
end

function SkillAdvance:getNeedActiveZhao2()
    return self.__res.requireskillexp2
end

function SkillAdvance:getNeedActiveZhaoId2()
    return self:getNeedActiveZhao2()[1]
end

function SkillAdvance:getNeedActiveZhaoExp2()
    return tonumber(self:getNeedActiveZhao2()[2])
end

function SkillAdvance:getActiveZhaoName1()
    return Skill:getActiveZhao(self:getActiveZhaoId1()):getName()
end

function SkillAdvance:getActiveZhaoName2()
    return Skill:getActiveZhao(self:getActiveZhaoId2()):getName()
end

function SkillAdvance:getSkillName()
    return Skill:getSkill(self:getSkillId()):getNoColorName()
end

function SkillAdvance:getNeedSkillName()
    return Skill:getSkill(self:getNeedSkillId()):getNoColorName()
end

function SkillAdvance:getNeedActiveZhaoName1()
    return Skill:getActiveZhao(self:getNeedActiveZhaoId1()):getName()
end

function SkillAdvance:getNeedActiveZhaoName2()
    return Skill:getActiveZhao(self:getNeedActiveZhaoId2()):getName()
end

return newClass("SkillAdvance", {}, SkillAdvance)
00000000000000