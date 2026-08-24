local newClass = require("third.class.NewClass")

local SkillConst = require("app.models.skill.SkillConst")

local RolePrepareSkill = require("app.models.RolePrepareSkill.RolePrepareSkill")

local TestRolePrepareSkill = {}

function TestRolePrepareSkill:create(role)
    local p = TestRolePrepareSkill.new()
    p:setRole(role)
    return p
end

--@desc: 技能能否被装备(门派心法和师门建筑的限制条件)
--@author:LvBin
--@time:2023-09-19 16:43:04
--@type: 装备类型
--@skillId: 
--@return
function TestRolePrepareSkill:skillCanEquipByFamily(type,skillId)
	return true
end


return newClass("TestRolePrepareSkill", {RolePrepareSkill}, TestRolePrepareSkill)
0