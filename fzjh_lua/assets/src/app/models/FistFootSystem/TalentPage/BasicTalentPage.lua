--[[
    author:Seven
    time:2023-01-09 14:59:28
    desc: 技巧心得(天赋页) 基础类
]]
local newClass = require("third.class.NewClass")

local BasicTalentPage = {}

function BasicTalentPage:create(talentData)
    return BasicTalentPage.new():__init(talentData)
end

function BasicTalentPage:__init(talentData)
    self:__setFeelPoint(talentData.feelPoint)
    self:__initTalentPageTech(talentData.branchInfo)
    self:__initTalentPageEffect(talentData.branchInfo)

    return self
end

function BasicTalentPage:__setFeelPoint(feelPoint)
    self.__feelPoint = feelPoint
end

function BasicTalentPage:__initTalentPageTech(branchDatas)
    self.__techniqueMapByBranchType = {}

    local TalentFistFootTechnique = require("app.models.FistFootSystem.TalentPage.TalentFistFootTechnique")

    for branchType, info in pairs(branchDatas) do
        self.__techniqueMapByBranchType[tostring(branchType)] = {}

        for _, t_info in pairs(info.techniqueList) do
            --@RefType [src.app.models.FistFootSystem.TalentPage.TalentFistFootTechnique#TalentFistFootTechnique]
            local tech = TalentFistFootTechnique:create(t_info.id, t_info.lv)
            self.__techniqueMapByBranchType[tostring(branchType)][tostring(tech:getTechniqueId())] = tech
        end
    end
end

function BasicTalentPage:__initTalentPageEffect(branchDatas)
    local FistFootResManager = require("app.models.FistFootSystem.FistFootResManager")

    for branchType, info in pairs(branchDatas) do
        for _, e_info in pairs(info.characterInUse) do
            local tech = self:__getTechniqueById(branchType, e_info.techniqueId)
            local effect = FistFootResManager:getFistFootEffect(e_info.characterId, tech:getLevel())
            tech:insertEffect(effect)
        end
    end
end

--@desc: 获取技巧类
--@author:Seven
--@time:2023-01-09 15:45:34
--@b_type: 分支ID
--@t_id: 技巧ID
--@return [src.app.models.FistFootSystem.TalentPage.TalentFistFootTechnique#TalentFistFootTechnique]
function BasicTalentPage:__getTechniqueById(b_type, t_id)
    return self.__techniqueMapByBranchType[tostring(b_type)][tostring(t_id)]
end

--@desc: 总谙技值
--@author:Seven
--@time:2023-01-09 16:14:43
function BasicTalentPage:getTotalJqdamage()
    local value = 0

    for _, classMap in pairs(self.__techniqueMapByBranchType) do
        for _, tech in pairs(classMap) do
            --@RefType [src.app.models.FistFootSystem.TalentPage.TalentFistFootTechnique#TalentFistFootTechnique]
            local tech = tech

            value = value + tech:getJqdamage()
        end
    end

    return value
end

--@desc: 感悟点
--@author:Seven
--@time:2023-01-09 16:14:33
function BasicTalentPage:getFeelPoint()
    return self.__feelPoint
end

function BasicTalentPage:getAllEffects()
    local list = {}
    for _, classMap in pairs(self.__techniqueMapByBranchType) do
        for _, tech in pairs(classMap) do
            --@RefType [src.app.models.FistFootSystem.TalentPage.TalentFistFootTechnique#TalentFistFootTechnique]
            local tech = tech
            for _, v in pairs(tech:getEffects()) do
                table.insert(list, v)
            end
        end
    end

    table.sort(
        list,
        function(a, b)
            return tonumber(a:getId()) < tonumber(b:getId())
        end
    )

    return list
end

return newClass("BasicTalentPage", {}, BasicTalentPage)
0000000000000