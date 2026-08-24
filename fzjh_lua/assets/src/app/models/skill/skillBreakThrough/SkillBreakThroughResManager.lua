local SkillBreakThroughResManager = {
    __skillBreakThroughMap_id = {},
    __skillBreakThroughMap_level = {},

    __zhaoBreakThroughMap_id = {},
    __zhaoBreakThroughMap_type = {},

    __breakThroughItems = {}
}

local function loadRes()
    local skillBreakThrough = requireWithEncrypt("script.skill.skillBreakThrough")["武学突破"]
    SkillBreakThroughResManager.__skillBreakThroughMap_id = skillBreakThrough

    for id,v in pairs(skillBreakThrough) do
        SkillBreakThroughResManager.__skillBreakThroughMap_level[v.class] = v
    end

    local zhaoBreakThrough = requireWithEncrypt("script.skill.zhaoBreakThrough")["技能突破"]
    SkillBreakThroughResManager.__zhaoBreakThroughMap_id = zhaoBreakThrough

    for k,v in pairs(zhaoBreakThrough) do
        if SkillBreakThroughResManager.__zhaoBreakThroughMap_type[tostring(v.activeSkillType)] == nil then
            SkillBreakThroughResManager.__zhaoBreakThroughMap_type[tostring(v.activeSkillType)] = {}
        end
        SkillBreakThroughResManager.__zhaoBreakThroughMap_type[tostring(v.activeSkillType)][v.Blevel] = v
    end

    local breakThroughItems = requireWithEncrypt("script.skill.breakThroughItems")["Items"]
    SkillBreakThroughResManager.__breakThroughItems = breakThroughItems
end

loadRes()

function SkillBreakThroughResManager:getSkillBreakThroughMapById(skillBreId)
    return assert(self.__skillBreakThroughMap_id[tostring(skillBreId)],"没有突破信息 skillBreId = "..skillBreId)
end

function SkillBreakThroughResManager:getSkillBreakThroughMaxLevel()
    return #self.__skillBreakThroughMap_level
end

function SkillBreakThroughResManager:getSkillBreakThroughMapByLevel(level)
    return assert(self.__skillBreakThroughMap_level[tonumber(level)],"没有突破信息 level = "..level)
end

function SkillBreakThroughResManager:getZhaoBreakThroughMapById(zhaoBreId)
    return assert(self.__zhaoBreakThroughMap_id[tostring(zhaoBreId)],"没有招式突破信息 zhaoBreId = "..zhaoBreId)
end

function SkillBreakThroughResManager:getZhaoBreakThroughMaxLevelByActiveSkillType(activeSkillType)
    return #self.__zhaoBreakThroughMap_type[tostring(activeSkillType)]
end

function SkillBreakThroughResManager:getZhaoBreDataByZhaoLvAndActiveSkillType(activeSkillType,zhaoLv)
    return self.__zhaoBreakThroughMap_type[tostring(activeSkillType)][zhaoLv]
end

function SkillBreakThroughResManager:getBreakThroughItem(itemId)
    return assert(self.__breakThroughItems[tostring(itemId)],"没有招式突破物品 itemId = "..itemId)
end

return SkillBreakThroughResManager
0000000000000