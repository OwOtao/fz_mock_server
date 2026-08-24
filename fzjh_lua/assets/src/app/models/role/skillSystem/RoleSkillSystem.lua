local newClass = require("third.class.NewClass")

local Skill = require("app.models.skill.Skill")

local SkillConst = require("app.models.skill.SkillConst")

local RoleSkillSystem = {}

function RoleSkillSystem:create(role)
    local p = RoleSkillSystem.new()
    p.__isNotSerializable = true
    p:__init(role)
    return p
end

function RoleSkillSystem:__init(role)
    self.__role = role

    local ver = self.__role:getAttr("skillSysVer")

    if ver == 0 then
        --@desc 把技能界面中 “知识” 一栏超出1000级的武学，设置成1000级（该修复上线版本并未开放该栏目武学突破，因此所有在该栏中的武学只要超出都应该强行设置成1000级）
        local skill_map = self.__role.skills

        local function isNeedSkill(skillId)
            if skillId == SkillConst:getZhiShiSkillParamContent("skillID_pointSwitch") then
                return false
            end
            
            return true
        end

        if not MapIsEmpty(skill_map) then
            for skill_id, info in pairs(skill_map) do
                if isNeedSkill(skill_id) then
                    local skill = Skill:getSkill(skill_id)

                    if skill ~= nil and (skill.type == SKILL_TYPE_DUSHU or skill.type == SKILL_TYPE_SPECIAL or skill.type == SKILL_TYPE_HUIFU or skill.type == SKILL_TYPE_DUNDI or skill.type == SKILL_TYPE_ZHISHI) then
                        local maxLv = 1000
                        local currExp = info.exp
                        local maxExp
                        
                        if skill_id == SkillConst:getZhiShiSkillParamContent("skillID_transform") then
                            maxExp = skill:getExp(maxLv)
                        elseif skill_id == "zhougongzhishu" then
                            local zhouGongZhiShu = inherit({id = skill_id, exp = info.exp}, require("app.models.skill.skills.ZhouGongZhiShuSkill"))
                            maxExp = 3 * (maxLv - 1) ^ 2 + 6250 * (maxLv - 1) + 5000
                        else
                            maxExp = skill:getExp(maxLv)
                        end
    
                        if maxExp < currExp then
                            info.exp = maxExp
                        end
                    end
                end
            end
        end
        self.__role:setAttr("skillSysVer", 1)
    end
end

return newClass("RoleSkillSystem", {}, RoleSkillSystem)
000000000000