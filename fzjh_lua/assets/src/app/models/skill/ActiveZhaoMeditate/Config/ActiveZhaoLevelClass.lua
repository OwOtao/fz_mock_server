local class = require("third.class.NewClass")

local ActiveZhaoLevelClass = {}

function ActiveZhaoLevelClass:create(res)
    return ActiveZhaoLevelClass.new(res)
end

function ActiveZhaoLevelClass:getId()
    return self.id
end

function ActiveZhaoLevelClass:getUpgradeNeedSkillTotal()
    return self.upgradeNeedSkillTotal
end

function ActiveZhaoLevelClass:getUpgradeNeedSkillList()
    return self.upgradeNeedSkillList
end

function ActiveZhaoLevelClass:getUpgradeNeedDesc()
    return self.upgradeNeedDesc
end

function ActiveZhaoLevelClass:getUpgradeCost()
    return self.upgradeCost
end

function ActiveZhaoLevelClass:getUpgradeEffectDesc()
    return self.upgradeEffectDesc
end

function ActiveZhaoLevelClass:getCanyeToProficiencyAdd()
    return self.canyeToProficiencyAdd
end

function ActiveZhaoLevelClass:getPowerToProficiencyAdd()
    return self.powerToProficiencyAdd
end

function ActiveZhaoLevelClass:getCanyeToPowerAdd()
    return self.canyeToPowerAdd
end

function ActiveZhaoLevelClass:getWeeklyEnergyLimit()
    return self.weeklyEnergyLimit
end		

return class("ActiveZhaoLevelClass", {}, ActiveZhaoLevelClass)
00