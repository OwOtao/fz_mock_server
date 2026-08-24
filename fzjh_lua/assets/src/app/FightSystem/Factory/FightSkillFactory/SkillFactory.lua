local SkillFactory = {}

local skillRes = require("script.newbattle.demo.skillRes")["武学"]

local parryClassRes = require("script.newbattle.demo.skillParryClass")["招架系列"]

local dodgeClassRes = require("script.newbattle.demo.skillDodgeClass")["轻功系列"]

--@RefType[src.app.FightSystem.FightSkill.NormalFightSkill#NormalFightSkill]
local NormalFightSkill = require("app.FightSystem.FightSkill.NormalFightSkill")

local SelfCreatedFightSkill = require("app.FightSystem.FightSkill.SelfCreatedFightSkill")

local NormalFightDodgeClass = require("app.FightSystem.FightSkill.NormalFightDodgeClass")

local NormalFightParryClass = require("app.FightSystem.FightSkill.NormalFightParryClass")

local SelfCreatedSkill = require("app.models.SelfCreatedSkillSystem.SelfCreatedSkill.SelfCreatedSkill")

--@region parry class 和 dodge class 分组
local parryClassGrouped = {}
local function groupedParryClass()
    for k, v in pairs(parryClassRes) do
        if parryClassGrouped[tostring(v.parryClass)] == nil then
            parryClassGrouped[tostring(v.parryClass)] = {}
        end

        table.insert(parryClassGrouped[tostring(v.parryClass)], v)
    end
end

local dodgeClassGrouped = {}
local function groupedDodgeClass()
    for k, v in pairs(dodgeClassRes) do
        if dodgeClassGrouped[tostring(v.dodgeClass)] == nil then
            dodgeClassGrouped[tostring(v.dodgeClass)] = {}
        end

        table.insert(dodgeClassGrouped[tostring(v.dodgeClass)], v)
    end
end

groupedParryClass()

groupedDodgeClass()
--@endregion

--@desc: 初始化战斗技能
--@author:Seven
--@time:2021-05-29 15:25:42
--@skill_id:
--@return [src.app.FightSystem.FightSkill.NormalFightSkill#NormalFightSkill]
function SkillFactory:createSkill(skill_id,lv)
    local skillData = skillRes[skill_id]

    if not skillData then
        assert(false, "没有技能（id：" .. skill_id .. "）的配置")
    end

    local f_skill = NormalFightSkill:create()

    f_skill:loadFromRes(skillData)

    if skillData.parryClass ~= 0 then
        local pClassGroup = skillData.parryClass

        local parry_class_res = parryClassGrouped[tostring(pClassGroup)]

        if parry_class_res == nil then
            assert(false, "技能（id：" .. skill_id .. "）的parryClass无法找到相应配置。")
        end

        for _, v in ipairs(parry_class_res) do
            --@RefType [src.app.FightSystem.FightSkill.NormalFightParryClass#NormalFightParryClass]
            local parry_class = NormalFightParryClass:create()
            parry_class:setParryRes(v)
            f_skill:addParryClass(parry_class:getHitPos(),parry_class)
        end
    end

    if skillData.dodgeClass ~= 0 then
        local dClassGroup = skillData.dodgeClass

        local dodge_class_res = dodgeClassGrouped[tostring(dClassGroup)]

        if dodge_class_res == nil then
            assert(false, "技能（id：" .. skill_id .. "）的dodgeClass无法找到相应配置。")
        end

        for _, v in ipairs(dodge_class_res) do
            --@RefType [src.app.FightSystem.FightSkill.NormalFightDodgeClass#NormalFightDodgeClass]
            local dodge_class = NormalFightDodgeClass:create()
            dodge_class:setDodgeRes(v)
            f_skill:addDodgeClass(dodge_class:getHitPos(),dodge_class)
        end
    end

    lv = Helper:getDef(lv,1)
    lv = math.max(lv,1)

    f_skill:setLevel(lv)

    return f_skill
end

--@desc: 创建自创武学战斗技能
--@author:LvBin
--@time:2022-01-10 16:35:50
--@return [src.app.FightSystem.FightSkill.SelfCreatedFightSkill#SelfCreatedFightSkill]
function SkillFactory:createSelfCreateSkill(selfSkillData,lv)
    local f_skill = SelfCreatedFightSkill:create()

    local skill = SelfCreatedSkill:create(selfSkillData)

    f_skill:initData(skill)

    if skill:getParryClass() ~= 0 then
        local pClassGroup = skill:getParryClass()

        local parry_class_res = parryClassGrouped[tostring(pClassGroup)]

        if parry_class_res == nil then
            assert(false, "技能（id：" .. skill.id .. "）的parryClass无法找到相应配置。")
        end

        for _, v in ipairs(parry_class_res) do
            --@RefType [src.app.FightSystem.FightSkill.NormalFightParryClass#NormalFightParryClass]
            local parry_class = NormalFightParryClass:create()
            parry_class:setParryRes(v)
            f_skill:addParryClass(parry_class:getHitPos(),parry_class)
        end
    end

    if skill:getDodgeClass() ~= 0 then
        local dClassGroup = skill:getDodgeClass()

        local dodge_class_res = dodgeClassGrouped[tostring(dClassGroup)]

        if dodge_class_res == nil then
            assert(false, "技能（id：" .. skill.id .. "）的dodgeClass无法找到相应配置。")
        end

        for _, v in ipairs(dodge_class_res) do
            --@RefType [src.app.FightSystem.FightSkill.NormalFightDodgeClass#NormalFightDodgeClass]
            local dodge_class = NormalFightDodgeClass:create()
            dodge_class:setDodgeRes(v)
            f_skill:addDodgeClass(dodge_class:getHitPos(),dodge_class)
        end
    end

    lv = Helper:getDef(lv,1)
    lv = math.max(lv,1)

    f_skill:setLevel(lv)

    return f_skill
end

return SkillFactory
00000000