local FondSkill = {
    _skillMap = {},
    _activeZhaoMap = {}
}
local FondDrSkill = require("app.models.FondDream.Skill.FondDrSkill")

function FondSkill:getSkill(skillId)
    if self._skillMap[skillId] == nil then
        self._skillMap[skillId] = FondDrSkill:create(skillId)
    end
    return self._skillMap[skillId]
end

function FondSkill:getSkillZhaoList(skillId)
    if skillId == nil then
        return {}
    end
    local skill = self:getSkill(skillId)
    if skill._baseZhaoList == nil then
        local retList = {}
        local zhaoList = skill.zhaoList
        if MapIsEmpty(zhaoList) == false then
            for i, zhaoId in ipairs(zhaoList) do
                table.insert(retList, self:getActiveZhao(zhaoId))
            end
        end
        skill._baseZhaoList = retList
    end
    
    return skill._baseZhaoList
end

function FondSkill:getActiveZhao(id)
    if self._activeZhaoMap[id] == nil then
        local FondActiveZhao = require("app.models.FondDream.ActiveZhao.FondActiveZhao")
        local ActiveFactory = require("app.FightSystem.Factory.FightSkillFactory.ActiveFactory")
        local activeInfo = ActiveFactory:getActiveInfo(id)
        local activeId = activeInfo.activeId
        local activeLevel = activeInfo.activeLevel
        self._activeZhaoMap[id] = FondActiveZhao:create(activeId,activeLevel)
    end
    
    return self._activeZhaoMap[id]
end


return inherit({},FondSkill,require("app.models.skill.Skill"))00000000000