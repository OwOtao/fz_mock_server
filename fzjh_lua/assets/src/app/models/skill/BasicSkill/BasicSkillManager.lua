--[[
    author:Seven
    time:2022-09-19 18:36:51
    desc: 基础技能管理
]]
local skillRes = require("script.newbattle.demo.skillRes")["武学"]

local zhaoComb_res = require("script.newbattle.demo.autoZhaoComb")["被动招式"]

local autoZhaoInfo_res = require("script.newbattle.demo.autoZhaoInfo")["被动招式"]

local parryClassRes = require("script.newbattle.demo.skillParryClass")["招架系列"]

local dodgeClassRes = require("script.newbattle.demo.skillDodgeClass")["轻功系列"]

local BasicSkill = require("app.models.skill.BasicSkill.BasicSkill")

local BasicAutoZhaoInfo = require("app.models.skill.BasicSkill.AutoZhao.BasicAutoZhaoInfo")

local BasicSkillManager = {
    __basicSkillMap = {},
    __basicSkillZhaoCombMap = {},
    __basicZhaoInfoMap = {}
}

--@desc 存放被动技能对应的招式组合
local d_zhaoComb = {}

--@region 初始化 资源信息
local initAutoZhaoCombRes = function()
    local zhaoComb_res = require("script.newbattle.demo.autoZhaoComb")["被动招式"]

    for _, comb_data in pairs(zhaoComb_res) do
        if comb_data.skillId == nil then
            assert(false, "武功被动招式组合填写错误：[id: " .. comb_data.id .. "] 所属武学ID未填写")
        end

        if d_zhaoComb[comb_data.skillId] == nil then
            d_zhaoComb[comb_data.skillId] = {}
        end

        table.insert(d_zhaoComb[comb_data.skillId], comb_data)
    end
end
initAutoZhaoCombRes()
--@endregion

--@region parry class 和 dodge class 分组
local parryClassGroupedRes = {}
local function groupedParryClass()
    for k, v in pairs(parryClassRes) do
        if parryClassGroupedRes[tostring(v.parryClass)] == nil then
            parryClassGroupedRes[tostring(v.parryClass)] = {}
        end

        table.insert(parryClassGroupedRes[tostring(v.parryClass)], v)
    end
end

local dodgeClassGroupedRes = {}
local function groupedDodgeClass()
    for k, v in pairs(dodgeClassRes) do
        if dodgeClassGroupedRes[tostring(v.dodgeClass)] == nil then
            dodgeClassGroupedRes[tostring(v.dodgeClass)] = {}
        end

        table.insert(dodgeClassGroupedRes[tostring(v.dodgeClass)], v)
    end
end

groupedParryClass()

groupedDodgeClass()
--@endregion

--@desc:
--@author:Seven
--@time:2022-09-19 19:48:57
--@skill_id:
--@return: src.app.models.skill.BasicSkill.BasicSkill#BasicSkill
function BasicSkillManager:getBasicSkill(skill_id)
    if self.__basicSkillMap[skill_id] then
        return self.__basicSkillMap[skill_id]
    end

    local res = skillRes[skill_id]

    if not res then
        assert(false, "BasicSkillManager:getBasicSkill 没有技能（id：" .. skill_id .. "）的配置")
    end

    local basicSkill = BasicSkill:create(res)

    self.__basicSkillMap[skill_id] = basicSkill

    return basicSkill
end

--@desc: 获取招式组合列表
--@author:Seven
--@time:2022-11-02 20:47:30
--@skill_id: 武学id
--@return:list
function BasicSkillManager:getBasicSkillAutoZhaoCombinations(skill_id)
    local list = self.__basicSkillZhaoCombMap[skill_id]

    if list then
        return list
    end

    local skillCombs_res = d_zhaoComb[skill_id]

    if skillCombs_res == nil then
        assert(false, "技能id：" .. tostring(skill_id) .. ",没有该技能id对应的招式组合")
    end

    local list = {}

    local BasicAutoZhaoCombination = require("app.models.skill.BasicSkill.AutoZhao.BasicAutoZhaoCombination")
    for _, info in ipairs(skillCombs_res) do
        -- @RefType[src.app.FightSystem.FightRole.AttackSystem.AutoSkill.AutoZhaoCombination#AutoZhaoCombination]
        local zhao_comb = BasicAutoZhaoCombination:create(info)

        -- zhao_comb:loadFromRes(info)
        table.insert(list, zhao_comb)
    end

    table.sort(
        list,
        function(a, b)
            return a:getZhaoId() < b:getZhaoId()
        end
    )

    self.__basicSkillZhaoCombMap[skill_id] = list

    return list
end

--@desc: 获取被动招式基础类
--@author:Seven
--@time:2022-11-19 16:49:38
--@zhao_id: 被动招式id
--@return: src.app.models.skill.BasicSkill.AutoZhao.BasicAutoZhaoInfo#BasicAutoZhaoInfo
function BasicSkillManager:getBasicSkillAutoZhaoInfo(zhao_id)
    local zhaoInfo = self.__basicZhaoInfoMap[tostring(zhao_id)]

    if zhaoInfo == nil then
        local res = autoZhaoInfo_res[tostring(zhao_id)]

        if res == nil then
            assert(false, "被动招式 ：" .. tostring(zhao_id) .. "资源未找到")
        end

        zhaoInfo = BasicAutoZhaoInfo:create(res)
    end

    return zhaoInfo
end

--@region 闪避系列
local BasicSkillDodgeClass = require("app.models.skill.BasicSkill.BasicSkillDodgeClass")
local dodgeGroupClassCache = {}
function BasicSkillManager:getBasicSkillDodgeClasses(dodgeClassGroup)
    local list = dodgeGroupClassCache[tostring(dodgeClassGroup)]
    if list ~= nil then
        return list
    else
        list = {}
        local dodge_class_res = dodgeClassGroupedRes[tostring(dodgeClassGroup)]

        if dodge_class_res == nil then
            assert(false, "无法找到闪避系列dodgeClass为" .. tostring(dodgeClassGroup) .. "的相应配置。")
        end

        for _, v in ipairs(dodge_class_res) do
            local dodge_class = BasicSkillDodgeClass:create(v)
            table.insert(list, dodge_class)
        end

        dodgeGroupClassCache[tostring(dodgeClassGroup)] = list

        return list
    end
end
--@endregion

--@region 格挡系列
local BasicSkillParryClass = require("app.models.skill.BasicSkill.BasicSkillParryClass")
local parryGroupClassCache = {}
function BasicSkillManager:getBasicSkillParryClasses(parryClassGroup)
    local list = parryGroupClassCache[tostring(parryClassGroup)]
    if list ~= nil then
        return list
    else
        list = {}
        local parry_class_res = parryClassGroupedRes[tostring(parryClassGroup)]

        if parry_class_res == nil then
            assert(false, "无法找到格挡系列parryClass为" .. tostring(parryClassGroup) .. "的相应配置。")
        end

        for _, v in ipairs(parry_class_res) do
            local parry_class = BasicSkillParryClass:create(v)
            table.insert(list, parry_class)
        end
        parryGroupClassCache[tostring(parryClassGroup)] = list

        return list
    end
end

--@endregion

return BasicSkillManager
0000