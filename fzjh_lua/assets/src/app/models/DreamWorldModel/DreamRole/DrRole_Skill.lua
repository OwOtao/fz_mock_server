local DrRole_Skill = clone(require("app.models.role.Role_Skill"))

function DrRole_Skill:prepareSkill(type, skillName)
    if skillName == "" then
        return false
    end

    local result,msg = self:canPrepareSkill(type, skillName)
    if not result then
        PopText(msg)
        return false
    end

    if self.skillPrepare == nil then
        self.skillPrepare = {}
    end

    if skillName ~= nil and string.len(skillName) > 0 then
        if type == "quanjiao2" then
            local skill1 = Skill:getSkill(self.skillPrepare["quanjiao1"])
            local skill2 = Skill:getSkill(skillName)
            if skill1 ~= nil then
                RichPrint("main", "你决定将[" .. tostring(skill2.name) .. "]组合[" .. tostring(skill1.name) .. "]做为你的[HIW基本拳脚NOR]。")
            else
                PopText("请先装备主拳脚武功！")
                return
            end
        end
    end

    if type == "quanjiao1" then
        self.skillPrepare["quanjiao2"] = nil
    end

    local weaponSkillType = {
        ["jianfa"] = true,
        ["gunfa"] = true,
        ["daofa"] = true,
        ["anqi"] = true,
        ["bianfa"] = true,
        ["shuangchi"] = true,
        ["qinfa"] = true
    }

    if weaponSkillType[type] == true and skillName ~= nil then
        for k, v in pairs(weaponSkillType) do
            if k == type then
                self.skillPrepare[k] = skillName
            else
                self.skillPrepare[k] = nil
            end
        end

        --@desc 准备兵器类武学，初始化兵器类型
        local DreamEquip = require("app.models.DreamWorldModel.DreamEquip")
        DreamEquip:changeByPrepareSkill(type, skillName, self)
    else
        self.skillPrepare[type] = skillName
    end

    if type == "neigong" then
        self:checkAttr("neigong")
    end

    self:updateActiveZhaoStatus()

    return true
end

function DrRole_Skill:getSkillLvLimit(skillId)
	return 1000
end

return DrRole_Skill
000000