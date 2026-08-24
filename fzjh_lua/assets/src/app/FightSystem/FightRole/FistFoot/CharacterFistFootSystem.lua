--[[
    author:Seven
    time:2022-11-24 16:50:44
    desc: 战斗角色拳脚系统
]]
local newClass = require("third.class.NewClass")

local ABasicCharacterFuncSystem = require("app.FightSystem.FightRole.BasicFuncSystem.ABasicCharacterFuncSystem")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local BasicSkill = require("app.models.skill.BasicSkill.BasicSkill")

local SkillConst = require("app.models.skill.SkillConst")

--@RefType src.app.models.skill.SkillConst#SkillConst.SkillSecondType
local SKILL_SECOND_TYPE = SkillConst.SkillSecondType

--@SuperType [src.app.FightSystem.FightRole.BasicFuncSystem.ABasicCharacterFuncSystem#ABasicCharacterFuncSystem]
local CharacterFistFootSystem = {}

function CharacterFistFootSystem:create(character)
    return CharacterFistFootSystem.new():__init(character)
end

function CharacterFistFootSystem:__init(character)
    self.__character = character

    self.__branchMap = {}

    --@RefType [src.app.FightSystem.FightRole.FistFoot.Attrs.FightFistFootAttr#FightFistFootAttr]
    self.__attr = require("app.FightSystem.FightRole.FistFoot.Attrs.FightFistFootAttr"):create(self)

    return self
end

function CharacterFistFootSystem:onInit()
end

function CharacterFistFootSystem:onDestory()
end

function CharacterFistFootSystem:onUpdate(ft)
end

--@desc: 添加拳脚分支
--@author:Seven
--@time:2022-11-24 16:57:40
--@branch: [src.app.FightSystem.FightRole.FistFoot.FightFistFootBranch#FightFistFootBranch]
function CharacterFistFootSystem:addBranch(branch)
    if self.__branchMap[branch:getBranchType()] ~= nil then
        assert(false, "CharacterFistFootSystem:addBranch 战斗拳脚系统：" .. branch:getBranchType() .. " 已有数据，不可重复添加该类型分支")
    end

    self.__branchMap[branch:getBranchType()] = branch

    branch:setCharacter(self.__character)
end

function CharacterFistFootSystem:__walkBranchMap(func)
    for branchId, branch in pairs(self.__branchMap) do
        func(branchId, branch)
    end
end

function CharacterFistFootSystem:getFistFootAttr(name)
    return self.__attr:getAttr(name)
end

--@desc: 获取拳脚分支
--@author:Seven
--@time:2022-11-28 15:58:10
--@branch_type: 拳脚分支类型
--@return: [src.app.FightSystem.FightRole.FistFoot.FightFistFootBranch#FightFistFootBranch]
function CharacterFistFootSystem:__getBranch(branch_type)
    return self.__branchMap[tostring(branch_type)]
end

--@desc: 获取拳脚系统相关分支的fdamage
--@author:Seven
--@time:2022-11-24 20:39:18
--@skillType: 技能类型id
function CharacterFistFootSystem:getFdamage(b_type)
    local branch = self:__getBranch(b_type)

    if branch == nil then
        return 0
    end

    return branch:getDamage()
end

function CharacterFistFootSystem:getJqdamage(b_type)
    local branch = self:__getBranch(b_type)

    if branch == nil then
        return 0
    end

    return branch:getJqdamage()
end

--@desc: 获取拳脚分支自带常态buff资源
--@author:Seven
--@time:2024-01-16 16:23:11
--@b_type: 拳脚分支类型
function CharacterFistFootSystem:__getPermanentBuffs(b_type)
    local list = {}
    local branch = self:__getBranch(b_type)

    if branch ~= nil then
        list = branch:getPermanentBuffs()
    end

    return list
end

function CharacterFistFootSystem:__getBuffAdderGroupIds(b_type)
    local adder = {}
    local branch = self:__getBranch(b_type)

    if branch ~= nil then
        adder = branch:getBuffAdderGroupIds()
    end

    return adder
end

function CharacterFistFootSystem:getBuffAdderGroupIds()
    local ids = {}

    if self.__character:weaponIsEmptyHand() then
        return ids
    end

    local prepSkill = self.__character:getPrepSkill(SKILL_SECOND_TYPE.QUAN_JIAO)
    if prepSkill then
        local skillTypes = prepSkill:getSkillTypes()

        for _, skill_type_id in ipairs(skillTypes) do
            if BasicSkill.IsAttackType(skill_type_id) then
                table.appendArray(ids, self:__getBuffAdderGroupIds(skill_type_id))
            end
        end
    end

    return ids
end

--@desc: 获取角色当前准备拳脚武学的拳脚分支类型id
--@author:Seven
--@time:2024-01-16 20:36:16
--@return: string | nil
function CharacterFistFootSystem:__getCharacterFistFootBranchId()
    local prepSkill = self.__character:getPrepSkill(SKILL_SECOND_TYPE.QUAN_JIAO)
    if prepSkill then
        local skillTypes = prepSkill:getSkillTypes()

        for _, skill_type_id in ipairs(skillTypes) do
            if BasicSkill.IsAttackType(skill_type_id) then
                return skill_type_id
            end
        end
    end

    return nil
end

--@desc: 激活拳脚系统携带buff
--@author:Seven
--@time:2024-01-16 17:41:52
function CharacterFistFootSystem:enableCarryBuff()
    local branchId = self:__getCharacterFistFootBranchId()
    if branchId == nil then
        return
    end

    local branch = self:__getBranch(branchId)

    if branch == nil then
        return
    end

    self.__enableCarryBuffBranchId = branchId

    FightUtil:printFormatLog("%s 拳脚分支【%s】自带buff添加 ：", self.__character:getAttr("name"), tostring(branchId))

    branch:addCarryBuffToCharacter()
end

--@desc: 禁用拳脚系统携带buff
--@author:Seven
--@time:2024-01-16 17:42:06
function CharacterFistFootSystem:disableCarryBuff()
    local branchId = self.__enableCarryBuffBranchId
    if branchId == nil then
        return
    end

    local branch = self:__getBranch(branchId)
    if branch == nil then
        return
    end

    FightUtil:printFormatLog("%s 拳脚分支【%s】自带buff 移除 ：", self.__character:getAttr("name"), tostring(branchId))
    branch:removeCarryBuffFromCharacter()
    self.__enableCarryBuffBranchId = nil
end

--@desc: 激活拳脚系统携带buff添加器
--@author:Seven
--@time:2024-01-16 17:42:24
function CharacterFistFootSystem:enableCarryBuffAdder()
    local branchId = self:__getCharacterFistFootBranchId()
    if branchId == nil then
        return
    end

    local branch = self:__getBranch(branchId)
    if branch == nil then
        return
    end

    FightUtil:printFormatLog("%s 拳脚系统分支【%s】自带buff添加器 添加 ：", self.__character:getAttr("name"), tostring(branchId))
    self.__enableCarryBuffAdderBranchId = branchId
    branch:addCarryBuffAdderToCharacter()
end

--@desc: 禁用拳脚系统携带buff添加器
--@author:Seven
--@time:2024-01-16 17:42:33
function CharacterFistFootSystem:disableCarryBuffAdder()
    local branchId = self.__enableCarryBuffAdderBranchId
    if branchId == nil then
        return
    end

    local branch = self:__getBranch(branchId)
    if branch == nil then
        return
    end

    FightUtil:printFormatLog("%s 拳脚系统分支【%s】自带buff添加器 移除 ：", self.__character:getAttr("name"), tostring(branchId))
    branch:removeCarryBuffAdderFromCharacter()
    self.__enableCarryBuffAdderBranchId = nil
end

return newClass("CharacterFistFootSystem", {ABasicCharacterFuncSystem}, CharacterFistFootSystem)
00000000