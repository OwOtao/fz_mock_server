--[[
    author:Seven
    time:2022-11-24 15:50:59
    desc: 战斗用拳脚系统分支类
]]
local newClass = require("third.class.NewClass")

local FistFootResManager = require("app.models.FistFootSystem.FistFootResManager")

local ACarryBuffAddToCharacter = require("app.FightSystem.FightRole.CharacterBuff.Utils.ACarryBuffAddToCharacter")

local BuffConf = require("app.FightSystem.Configuration.BuffConf")

--@SuperType [src.app.FightSystem.FightRole.CharacterBuff.Utils.ACarryBuffAddToCharacter#ACarryBuffAddToCharacter]
local FightFistFootBranch = {}

function FightFistFootBranch:create(branchType, b_lv)
    return FightFistFootBranch.new():__init(branchType, b_lv)
end

function FightFistFootBranch:__init(branchType, b_lv)
    self.__basicFistFootBranch = FistFootResManager:getFistFootBranch(branchType, b_lv)

    self.__techList = {}

    return self
end

function FightFistFootBranch:getBranchType()
    return tostring(self.__basicFistFootBranch:getType())
end

--@desc: 拳脚分支武炼值
--@author:Seven
--@time:2022-11-28 14:59:26
function FightFistFootBranch:getDamage()
    return self.__basicFistFootBranch:getDamage()
end

--@desc: 当前分支谙技值
--@author:Seven
--@time:2022-11-28 15:01:03
function FightFistFootBranch:getJqdamage()
    local value = 0

    self:__walkTechList(
        function(tech)
            --@RefType [src.app.FightSystem.FightRole.FistFoot.FightFistFootTechnique#FightFistFootTechnique]
            local tech = tech
            value = value + tech:getJqdamage()
        end
    )

    return value
end

function FightFistFootBranch:__walkTechList(func)
    if table.getn(self.__techList) > 0 then
        for _, tech in ipairs(self.__techList) do
            func(tech)
        end
    end
end

--@desc: 添加该分支类型下的技巧
--@author:Seven
--@time:2022-11-25 16:17:32
--@tech: [src.app.FightSystem.FightRole.FistFoot.FightFistFootTechnique#FightFistFootTechnique]
function FightFistFootBranch:insertTechnique(tech)
    table.insert(self.__techList, tech)
end

function FightFistFootBranch:getTechniques()
    return self.__techList
end

--@desc: 获取当前拳脚分支全部特性
--@author:Seven
--@time:2022-11-28 15:49:59
function FightFistFootBranch:getFirstFootEffects()
    local effects = {}
    self:__walkTechList(
        function(tech)
            --@RefType [src.app.FightSystem.FightRole.FistFoot.FightFistFootTechnique#FightFistFootTechnique]
            local tech = tech

            for _, v in ipairs(tech:getEffects()) do
                table.insert(effects, v)
            end
        end
    )

    return effects
end

function FightFistFootBranch:getPermanentBuffs()
    if self.__permanentBuffs == nil then
        self.__permanentBuffs = {}

        local effects = self:getFirstFootEffects()

        for _, effect in ipairs(effects) do
            --@RefType [src.app.FightSystem.FightRole.FistFoot.FightFistFootEffect#FightFistFootEffect]
            local effect = effect

            if effect:hasPermanentBuff() then
                table.insert(self.__permanentBuffs, BuffConf:getNormalBuffRes(effect:getPermanentBuffId()))
            end
        end
    end

    return self.__permanentBuffs
end

function FightFistFootBranch:getBuffAdderGroupIds()
    if self.__buffAdderInit == nil then
        local effects = self:getFirstFootEffects()

        local list = {}
        for _, effect in ipairs(effects) do
            --@RefType [src.app.FightSystem.FightRole.FistFoot.FightFistFootEffect#FightFistFootEffect]
            local effect = effect

            if effect:hasBuffLauncherAdd() then
                table.insert(list, effect:getBuffLauncherAdd())
            end
        end

        self.__buffAdderGroupIds = list

        self.__buffAdderInit = true
    end

    return self.__buffAdderGroupIds
end

function FightFistFootBranch:getCarryBuffArray()
    local array = self:getPermanentBuffs()
    if MapIsEmpty(array) then
        return {}
    end

    local list = {}
    for _, normalRes in ipairs(array) do
        --@RefType [src.app.FightSystem.FightRole.CharacterBuff.Buffs.Builder.BasicCharacterBuffBuilder#BasicCharacterBuffBuilder]
        local buffBuilder = require("app.FightSystem.FightRole.CharacterBuff.Buffs.Builder.BasicCharacterBuffBuilder"):create()
        local origin_value_4 = normalRes.addBuffdynamicArg4

        local arg4
        if origin_value_4 == nil then
            arg4 = 0
        else
            if tonumber(origin_value_4) == nil then
                arg4 = origin_value_4
            else
                arg4 = tonumber(origin_value_4)
            end
        end
        
        local buff =
            buffBuilder:setBuffId(normalRes.addBuffID):setCharacter(self.__character):setBuffCreator(self.__character):setFight(self.__character:getFight()):setBuffDynamicArgValue(
            "dynamicArg1",
            normalRes.addBuffdynamicArg1
        ):setBuffDynamicArgValue("dynamicArg2", normalRes.addBuffdynamicArg2):setBuffDynamicArgValue("dynamicArg3", normalRes.addBuffdynamicArg3):setBuffDynamicArgValue(
            "dynamicArg4",
            arg4
        ):build()

        table.insert(list, buff)
    end

    return list
end

function FightFistFootBranch:getCarryBuffAdderGroupArray()
    local idList = self:getBuffAdderGroupIds()

    if MapIsEmpty(idList) then
        return
    end

    local CharacterBuffAdderGroupFactory = require("app.FightSystem.FightRole.CharacterBuff.BuffAdders.CharacterBuffAdderGroupFactory")

    local list = {}

    for _, id in ipairs(idList) do
        table.insert(list, CharacterBuffAdderGroupFactory:getAutoBuffAdderGroup(id, self.__character, self.__character:getFight()))
    end

    return list
end

return newClass("FightFistFootBranch", {ACarryBuffAddToCharacter}, FightFistFootBranch)
00000000000