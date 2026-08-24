local XinShenResManager = {
    __mindUpgradeMapById = {},
    __mindUpgradeMapByLevel = {},
    __maxLevel = 0,
    __mindRecoverItems = {}
}

local function loadRes()
    local maxMindUpgrade = require("script.skill.maxMindUpgrade")["心神上限升级"]
    XinShenResManager.__mindUpgradeMapById = maxMindUpgrade

    XinShenResManager.__maxLevel = 0

    for id,v in pairs(maxMindUpgrade) do
        XinShenResManager.__mindUpgradeMapByLevel[tostring(v.stage)] = v

        XinShenResManager.__maxLevel = XinShenResManager.__maxLevel + 1
    end

    local mindRecoverItems = require("script.skill.mindRecoverItems")["心神回复道具"]

    XinShenResManager.__mindRecoverItems = mindRecoverItems
end

loadRes()

function XinShenResManager:getXinShenMaxUpgradeDataById(id)
    return self.__mindUpgradeMapById[tostring(id)]
end

function XinShenResManager:getXinShenMaxUpgradeDataByLevel(level)
    return self.__mindUpgradeMapByLevel[tostring(level)]
end

function XinShenResManager:getMaxLevel()
    return self.__maxLevel
end

function XinShenResManager:getMindRecoverItem(itemId)
    return self.__mindRecoverItems[tostring(itemId)]
end

return XinShenResManager0000000000000000