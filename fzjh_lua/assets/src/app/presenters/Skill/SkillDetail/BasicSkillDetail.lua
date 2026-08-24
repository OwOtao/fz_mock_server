--[[
    author:Seven
    time:2022-11-02 20:27:03
    desc: 武功详情界面展示用model（匹配新版武学）

    TODO: 目前只用于棋局内技能详情展示，后续可转移至所有需要查看配置武学详情的界面使用
]]
local newClass = require("third.class.NewClass")

local BasicSkillManager = require("app.models.skill.BasicSkill.BasicSkillManager")

local BasicSkill = require("app.models.skill.BasicSkill.BasicSkill")

local SkillConst = require("app.models.skill.SkillConst")

local SkillClassifyManager = require("app.FightSystem.FightSkill.SkillClassifyManager")

local BasicActiveSkillManager = require("app.models.skill.BasicSkill.BasicActiveSkillManager")

local AnimResManager = require("app.FightSystem.ResourceManager.AnimResManager")

local Desc = require("app.FightSystem.FightBuff.Desc")

local SkillThirdType = SkillConst.SkillThirdType

--@desc 暂时程序写死，后续考虑配置到武学分类表
local WEAPON_REPLACE = {
    [tostring(SkillThirdType.JIAN_FA)] = "宝剑",
    [tostring(SkillThirdType.DAO_FA)] = "宝刀",
    [tostring(SkillThirdType.FU_FA)] = "斧子",
    [tostring(SkillThirdType.GUN_FA)] = "棍子",
    [tostring(SkillThirdType.QIANG_FA)] = "兵刃",
    [tostring(SkillThirdType.BIAN_FA)] = "鞭子",
    [tostring(SkillThirdType.AN_QI)] = "暗器",
    [tostring(SkillThirdType.SHUANG_CHI)] = "兵刃",
    [tostring(SkillThirdType.QIN_FA)] = "乐器"
}

local BasicSkillDetail = {}

function BasicSkillDetail:create(skillId)
    local p = BasicSkillDetail.new()

    return p:__init(skillId)
end

function BasicSkillDetail:__init(skillId)
    self.__basicSkill = BasicSkillManager:getBasicSkill(skillId)

    local isAttackType = false

    self:__walkSkillTypes(
        function(type_id)
            if BasicSkill.IsAttackType(type_id) == true then
                isAttackType = true

                return true
            end

            return false
        end
    )

    if isAttackType == true then
        self.__autoZhaoCombList = BasicSkillManager:getBasicSkillAutoZhaoCombinations(self.__basicSkill:getId())
    else
        self.__autoZhaoCombList = {}
    end

    self.__activeCombList = {}

    for i, active_skill_id in ipairs(self.__basicSkill:getActiveZhaos()) do
        local activeZhaoCombination = BasicActiveSkillManager:getBasicActiveSkill(active_skill_id)

        table.insert(self.__activeCombList, activeZhaoCombination)
    end

    return self
end

function BasicSkillDetail:getName()
    return self.__basicSkill:getName()
end

function BasicSkillDetail:getSkillDetailText()
    return self.__basicSkill:getDsc()
end

function BasicSkillDetail:getAutoZhaoList()
    return self.__autoZhaoCombList
end

function BasicSkillDetail:getAttackAnimResIdList()
    local list = {}

    self:__walkZhaoCombList(
        function(v, index)
            --@RefType [src.app.models.skill.BasicSkill.AutoZhao.BasicAutoZhaoCombination#BasicAutoZhaoCombination]
            local autoComb = v

            local attackZhaoIdInfos = autoComb:getAtkList()

            for i, zhaoInfoId in ipairs(attackZhaoIdInfos) do
                --@RefType [src.app.models.skill.BasicSkill.AutoZhao.BasicAutoZhaoInfo#BasicAutoZhaoInfo]
                local zhaoInfo = BasicSkillManager:getBasicSkillAutoZhaoInfo(zhaoInfoId)
                table.insert(list, zhaoInfo:getAnimResId())
            end
        end
    )

    return list
end

function BasicSkillDetail:getWeaponResId()
    local w_types = self.__basicSkill:getWeaponTypes()

    local count = table.getn(w_types)

    local randIndex = math.random(1, count)

    return w_types[randIndex]
end

function BasicSkillDetail:getCombActionText(combZhaoId)
    local comb = nil

    self:__walkZhaoCombList(
        function(v, index)
            if v:getId() == combZhaoId then
                comb = v
                return true
            end
        end
    )

    if comb == nil then
        assert(false, "BasicSkillDetail:getCombDsc 获取招式组合错误，招式组合id：" .. combZhaoId)
    end

    local actionText = comb:getActionText()

    local replaceArray = {}
    table.insert(replaceArray, {"$N", "你"})
    table.insert(replaceArray, {"$n", "对方"})
    table.insert(replaceArray, {"$l", "身体"})

    self:__walkSkillTypes(
        function(skill_type_id)
            if BasicSkill.IsAttackType(skill_type_id) then
                local third_type = SkillClassifyManager:getClassifyThirdType(skill_type_id)
                table.insert(replaceArray, {"$Nw", Helper:getDef(WEAPON_REPLACE[tostring(third_type)], "")})
                return true
            end
        end
    )

    --@RefType [src.app.FightSystem.FightBuff.Desc#Desc]
    local desc_class = Desc:create(actionText, replaceArray)

    local desc = desc_class:getString()

    --@desc 去除颜色
    for _, v in ipairs(GetColorList()) do
        local s, e = string.find(desc, v.id)
        if s ~= nil and e ~= nil then
            desc = string.gsub(desc, v.id, "")
        end
    end

    return desc
end

function BasicSkillDetail:getSkillTypes()
    return self.__basicSkill:getSkillType()
end

function BasicSkillDetail:__walkSkillTypes(func)
    for _, skill_type_id in ipairs(self:getSkillTypes()) do
        if func(skill_type_id) == true then
            break
        end
    end
end

function BasicSkillDetail:getActiveSkillCombList()
    return self.__activeCombList
end

function BasicSkillDetail:isShowAnim()
    local isShowAnim = false

    self:__walkSkillTypes(
        function(type_id)
            if BasicSkill.IsAttackType(type_id) == true then
                isShowAnim = true

                return true
            end

            return false
        end
    )

    return isShowAnim
end

function BasicSkillDetail:__walkZhaoCombList(func)
    for i, v in ipairs(self.__autoZhaoCombList) do
        if func(v, i) == true then
            break
        end
    end
end

function BasicSkillDetail:getStandAnimName()
    local resId = self.__basicSkill:getBattleIdleAnim()
    if resId == 0 then
        return nil
    end

    return AnimResManager:getOtherAnimName(resId)
end

function BasicSkillDetail:getBattleRunAnim()
    return AnimResManager:getOtherAnimName(self.__basicSkill:getBattleRunAnim())
end

return newClass("BasicSkillDetail", {}, BasicSkillDetail)
000000000