--[[
    author:Seven
    time:2022-11-07 20:25:11
    desc: 主动技能基础管理
]]
local ActiveSkillConf = require("app.FightSystem.Configuration.ActiveSkillConf")

local BasicActiveZhaoInfo = require("app.models.skill.BasicSkill.ActiveZhao.BasicActiveZhaoInfo")

local BasicActiveSkillManager = {
    __basicActiveSkillMap = {},
    --@desc 主动技能招式组合基础类
    __basicActiveZhaoCombinationMap = {},
    --@desc 主动招式信息基础类
    __basicZhaoInfoMap = {}
}

--@desc: 获取主动技能基础类
--@author:Seven
--@time:2022-09-19 19:48:57
--@actSkill_id: 主动技能ID
--@return: src.app.models.skill.BasicSkill.BasicActiveSkill#BasicActiveSkill
function BasicActiveSkillManager:getBasicActiveSkill(actSkill_id)
    if self.__basicActiveSkillMap[actSkill_id] then
        return self.__basicActiveSkillMap[actSkill_id]
    end
    local BasicActiveSkill = require("app.models.skill.BasicSkill.BasicActiveSkill")

    self.__basicActiveSkillMap[actSkill_id] = BasicActiveSkill:create(actSkill_id)

    return self.__basicActiveSkillMap[actSkill_id]
end

--@desc: 获取主动技能
--@author:Seven
--@time:2022-12-05 20:36:51
--@active_id: 主动技能id
--@lv: 主动技能等级
--@return: [src.app.models.skill.BasicSkill.ActiveZhao.BasicActiveZhaoCombination#BasicActiveZhaoCombination]
function BasicActiveSkillManager:getBasicActiveZhaoCombination(active_id, lv)
    local BasicActiveZhaoCombination = require("app.models.skill.BasicSkill.ActiveZhao.BasicActiveZhaoCombination")

    if self.__basicActiveZhaoCombinationMap[tostring(active_id) .. tostring(lv)] == nil then
        local res = ActiveSkillConf:getActiveSkillResByAIdAndLevel(active_id, lv)
        self.__basicActiveZhaoCombinationMap[tostring(active_id) .. tostring(lv)] = BasicActiveZhaoCombination:create(res)
    end

    return self.__basicActiveZhaoCombinationMap[tostring(active_id) .. tostring(lv)]
end

function BasicActiveSkillManager:createUseCondition(condArgs)
    local useCondType = condArgs[1]

    local condClass =
        switch(
        useCondType,
        {
            ["1"] = function()
                return require("app.FightSystem.FightSkill.ActiveSkillUseCondition.AttrUseCondition")
            end,
            ["2"] = function()
                return require("app.FightSystem.FightSkill.ActiveSkillUseCondition.SkillLevelConditon")
            end,
            ["3"] = function()
                return require("app.FightSystem.FightSkill.ActiveSkillUseCondition.PrepSkillCondition")
            end,
            ["4"] = function()
                return require("app.FightSystem.FightSkill.ActiveSkillUseCondition.UseWeaponCondition")
            end,
            ["5"] = function()
                return require("app.FightSystem.FightSkill.ActiveSkillUseCondition.CharacterFamilyMatchCondition")
            end,
            ["6"] = function()
                return require("app.FightSystem.FightSkill.ActiveSkillUseCondition.PrepAndUseSkillCondition")
            end,
            ["7"] = function()
                return require("app.FightSystem.FightSkill.ActiveSkillUseCondition.PrepAndUseSkillMatchFamilyCondition")
            end
        }
    )

    return condClass:create(condArgs[2], condArgs[3], condArgs[4])
end

function BasicActiveSkillManager:createLearnCondition(condArgs)
    local useCondType = condArgs[1]

    local condClass =
        switch(
        useCondType,
        {
            ["1"] = function()
                return require("app.models.skill.BasicSkill.ActiveSkillLearnCondition.AttrLearnCondition")
            end,
            ["2"] = function()
                return require("app.models.skill.BasicSkill.ActiveSkillLearnCondition.SkillLevelLearnConditon")
            end
        }
    )

    return condClass:create(condArgs[2], condArgs[3], condArgs[4])
end

function BasicActiveSkillManager:createReleaseCondition(condArgs)
    local releaseType = condArgs[1]
    local conditionClass =
        switch(
        releaseType,
        {
            ["1"] = function()
                return require("app.FightSystem.FightSkill.ActiveSkillRelaseCondition.AttrPercentCondition")
            end,
            ["2"] = function()
                return require("app.FightSystem.FightSkill.ActiveSkillRelaseCondition.SwitchWeaponTypeCondition")
            end,
            ["3"] = function()
                return require("app.FightSystem.FightSkill.ActiveSkillRelaseCondition.SwitchWeaponFightStateCondition")
            end,
            default = function ()
                error("BasicActiveSkillManager:createReleaseCondition 未知释放类型参数 " .. tostring(releaseType))
            end
        }
    )

    return conditionClass:create(condArgs[2], condArgs[3], condArgs[4], condArgs[5], condArgs[6])
end

--@desc: 获取主动招式id
--@author:Seven
--@time:2023-02-18 17:41:06
--@zhao_id: 招式id
--@return [src.app.models.skill.BasicSkill.ActiveZhao.BasicActiveZhaoInfo#BasicActiveZhaoInfo]
function BasicActiveSkillManager:getBasicSkillActiveZhaoInfo(zhao_id)
    local zhaoInfo = self.__basicZhaoInfoMap[tostring(zhao_id)]

    if zhaoInfo == nil then
        local res = ActiveSkillConf:getActiveZhaoInfo(zhao_id)

        if res == nil then
            assert(false, "被动招式 ：" .. tostring(zhao_id) .. "资源未找到")
        end

        zhaoInfo = BasicActiveZhaoInfo:create(res)
    end

    return zhaoInfo
end

return BasicActiveSkillManager
00000