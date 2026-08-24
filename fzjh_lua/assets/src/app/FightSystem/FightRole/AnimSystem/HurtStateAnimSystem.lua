--[[
    author:Seven
    time:2023-02-10 12:07:42
    desc: 受击动画组管理系统 包含格挡、闪避动画
    ]]
local newClass = require("third.class.NewClass")

local ABasicCharacterFuncSystem = require("app.FightSystem.FightRole.BasicFuncSystem.ABasicCharacterFuncSystem")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local FightCommons = require("app.FightSystem.FightCommons")

local AnimResManager = require("app.FightSystem.ResourceManager.AnimResManager")

local CharacterDefaultConf = require("app.FightSystem.Configuration.CharacterDefaultConf")

--@SuperType [src.app.FightSystem.FightRole.BasicFuncSystem.ABasicCharacterFuncSystem#ABasicCharacterFuncSystem]
local HurtStateAnimSystem = {}

function HurtStateAnimSystem:create()
    return HurtStateAnimSystem.new()
end

function HurtStateAnimSystem:onInit()
    self.__hurtExpressionList = {}

    --@desc 用于生成
    self.__hurtExprIndexId = 15000
end

function HurtStateAnimSystem:onDestory()
end

function HurtStateAnimSystem:onUpdate(ft)
end

--@desc: 添加影响受击相关的受击类型
--@author:Seven
--@time:2023-02-10 12:16:54
--@hurtExpression: 受击类型
--@sortPriority: 受击类型优先级
--@return: 受击动画类型对象id（自动生成）
function HurtStateAnimSystem:addHurtExpression(hurtExpression, sortPriority)
    local id = self:__getNewHurtExprIndexId()
    local hurtInfo = {
        id = id,
        expression = hurtExpression,
        priority = sortPriority
    }

    FightUtil:printFormatLog("HurtStateAnimSystem:addHurtExpression %s 添加受击动画类型，id：%s，类型：%s，优先级：%s", self.__character:getAttr("name"), id, hurtExpression, sortPriority)

    table.insert(self.__hurtExpressionList, hurtInfo)

    self:__sortHurtExpressionList()

    return id
end

function HurtStateAnimSystem:removeHurtExpression(id)
    if table.getn(self.__hurtExpressionList) <= 0 then
        return
    end

    local removeIndex
    local removeInfo
    self:__walkHurtExpressionList(
        function(index, hurtInfo)
            if hurtInfo.id == id then
                removeInfo = hurtInfo
                removeIndex = index
                return true
            end
        end
    )

    if removeIndex == nil then
        error("HurtStateAnimSystem:removeHurtExpression ，移除失败，id 无匹配：" .. tostring(id))
    end

    
    table.remove(self.__hurtExpressionList, removeIndex)
    
    FightUtil:printFormatLog("HurtStateAnimSystem:removeHurtExpression %s 移除受击动画类型，id：%s，类型：%s，优先级：%s", self.__character:getAttr("name"), id, removeInfo.expression, removeInfo.priority)

    return removeInfo
end

--@desc: 遍历受击动画类型信息
--@author:Seven
--@time:2023-02-10 15:07:55
function HurtStateAnimSystem:__walkHurtExpressionList(func)
    if table.getn(self.__hurtExpressionList) <= 0 then
        return
    end

    for i, v in ipairs(self.__hurtExpressionList) do
        if func(i, v) == true then
            break
        end
    end
end

function HurtStateAnimSystem:__sortHurtExpressionList()
    if table.getn(self.__hurtExpressionList) <= 0 then
        return
    end
    table.sort(
        self.__hurtExpressionList,
        function(a, b)
            return a.priority >= b.priority
        end
    )
end

function HurtStateAnimSystem:__getNewHurtExprIndexId()
    self.__hurtExprIndexId = self.__hurtExprIndexId + 1
    return self.__hurtExprIndexId
end

--@desc: 获取受击动画和声音信息
--@author:Seven
--@time:2023-02-10 14:59:26
--@hurtExpression: 受击类型
function HurtStateAnimSystem:__getHurtExpressionAnimAndSoundTable(hurtExpression)
    local map = {}
    local hurtSoundId = CharacterDefaultConf:getHurtSoundId(self.__character:getSpecies())
    if hurtExpression == 1 then
        local parryClasses = self.__character:getParrySkill():getParryClasses()
        for hitPos, parryClassList in pairs(parryClasses) do
            if map[hitPos] == nil then
                map[hitPos] = {}
            end
            if #parryClassList > 0 then
                for _, parryClass in ipairs(parryClassList) do
                    local animName = AnimResManager:getOtherAnimName(parryClass:getActionNormal())

                    table.insert(
                        map[hitPos],
                        {
                            hurtAnimName = animName,
                            hurtSoundId = hurtSoundId
                        }
                    )
                end
            end
        end
    elseif hurtExpression == 2 then
        local dodgeClasses = self.__character:getDodgeSkill():getDodgeClasses()
        for hitPos, dodgeClassList in pairs(dodgeClasses) do
            if map[hitPos] == nil then
                map[hitPos] = {}
            end
            if #dodgeClassList > 0 then
                for _, dodgeClass in ipairs(dodgeClassList) do
                    local animName = AnimResManager:getOtherAnimName(dodgeClass:getActionNormal())
                    table.insert(
                        map[hitPos],
                        {
                            hurtAnimName = animName,
                            hurtSoundId = hurtSoundId
                        }
                    )
                end
            end
        end
    else
        error("HurtStateAnimSystem:__getHurtExpressionAnimAndSoundTable 获取受击动画相关信息类型参数错误，hurtExpression：" .. tostring(hurtExpression))
    end

    return map
end

--@desc: 获取受击动画组
--@author:Seven
--@time:2023-02-10 12:13:09
function HurtStateAnimSystem:getHurtAnimAndSoundMap()
    if table.getn(self.__hurtExpressionList) <= 0 then
        return self:__getDefaultHurtAnimAndSoundMap()
    end

    local hurtInfo = self.__hurtExpressionList[1]

    return self:__getHurtExpressionAnimAndSoundTable(hurtInfo.expression)
end

--@desc: 默认受击动画数组
--@author:Seven
--@time:2023-02-10 14:43:47
function HurtStateAnimSystem:__getDefaultHurtAnimAndSoundMap()
    --@desc 默认动画目前只受角色种族影响，因此战斗开始后并不会改变，可做缓存处理
    if self.__defaultHurtAnimMap == nil then
        --@desc 设置受击动画组
        local HIT_POS = FightCommons.HIT_POS

        local species = self.__character:getSpecies()

        local hurtSoundId = CharacterDefaultConf:getHurtSoundId(species)

        local animMap = {}

        for _, hitPos in pairs(HIT_POS) do
            animMap[hitPos] = {}
            table.insert(
                animMap[hitPos],
                {
                    hurtAnimName = CharacterDefaultConf:getHurtAnim(species, hitPos),
                    hurtSoundId = hurtSoundId
                }
            )
        end

        self.__defaultHurtAnimMap = animMap
    end

    return self.__defaultHurtAnimMap
end

--@desc: 获取格挡动画
--@author:Seven
--@time:2023-02-10 12:14:24
function HurtStateAnimSystem:getParryAnimAndSoundMap()
    local map = {}
    local parryClasses = self.__character:getParrySkill():getParryClasses()
    for hitPos, parryClassList in pairs(parryClasses) do
        if map[hitPos] == nil then
            map[hitPos] = {}
        end
        if #parryClassList > 0 then
            for _, parryClass in ipairs(parryClassList) do
                local animName = AnimResManager:getOtherAnimName(parryClass:getActionNormal())

                table.insert(
                    map[hitPos],
                    {
                        hurtAnimName = animName,
                        hurtSoundId = parryClass:getSoundNormal()
                    }
                )
            end
        end
    end

    return map
end

--@desc: 获取轻功闪躲动画组和躲闪音效
--@author:Seven
--@time:2023-02-10 12:15:04
function HurtStateAnimSystem:getDodgeAnimAndSoundMap()
    local map = {}
    local dodgeClasses = self.__character:getDodgeSkill():getDodgeClasses()
    for hitPos, dodgeClassList in pairs(dodgeClasses) do
        if map[hitPos] == nil then
            map[hitPos] = {}
        end
        if #dodgeClassList > 0 then
            for _, dodgeClass in ipairs(dodgeClassList) do
                local animName = AnimResManager:getOtherAnimName(dodgeClass:getActionNormal())
                table.insert(
                    map[hitPos],
                    {
                        hurtAnimName = animName,
                        hurtSoundId = dodgeClass:getSoundNormal(),
                        dodgeOffset = dodgeClass:getOffsetNormal()
                    }
                )
            end
        end
    end

    return map
end

return newClass("HurtStateAnimSystem", {ABasicCharacterFuncSystem}, HurtStateAnimSystem)
000000000000