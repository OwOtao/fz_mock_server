--[[
    author:Seven
    time:2022-10-18 18:43:53
    desc: 玩家拳脚系统技巧类
]]
local FistFootResManager = require("app.models.FistFootSystem.FistFootResManager")
local FistFootEffect = require("app.models.FistFootSystem.FistFootEffect.FistFootEffect")
local newClass = require("third.class.NewClass")

local PlayerFistFootTechnique = {
    __effects = {},
    __unusedeffects = {}
}

function PlayerFistFootTechnique:create(t_id, lv)
    local p = PlayerFistFootTechnique.new()
    p:__init(t_id, lv)
    return p
end

function PlayerFistFootTechnique:__init(t_id, lv)
    --@RefType [src.app.models.FistFootSystem.FistFootTechniques.BasicFistFootTechnique#BasicFistFootTechnique]
    self.__basicTechnique = FistFootResManager:getBasicFistFootTechnique(t_id, lv)
end

function PlayerFistFootTechnique:getId()
    return self.__basicTechnique:getId()
end

function PlayerFistFootTechnique:getTechniqueId()
    return tostring(self.__basicTechnique:getSkillid())
end

function PlayerFistFootTechnique:getLevel()
    return self.__basicTechnique:getSkilllv()
end

function PlayerFistFootTechnique:getBranchType()
    return self.__basicTechnique:getType()
end

function PlayerFistFootTechnique:getJqdamage()
    return Helper:getDef(self.__basicTechnique:getJqdamage(), 0)
end

--@desc: 添加特性
--@author:Seven
--@time:2022-10-18 18:55:53
--@effect: [src.app.models.FistFootSystem.FistFootEffect.FistFootEffect#FistFootEffect]
function PlayerFistFootTechnique:insertEffect(effect)
    table.insert(self.__effects, effect)
end

--@desc: 移除特性
--@author:Seven
--@time:2022-10-18 18:57:18
--@index: 位置索引
--@return: [src.app.models.FistFootSystem.FistFootEffect.FistFootEffect#FistFootEffect]
function PlayerFistFootTechnique:removeEffect(index)
    return table.remove(self.__effects, index)
end

function PlayerFistFootTechnique:getEffects()
    return self.__effects
end

function PlayerFistFootTechnique:getUnusedEffects()
    return self.__unusedeffects
end

function PlayerFistFootTechnique:insertUnusedEffect(effect)
    table.insert(self.__unusedeffects, effect)
end

function PlayerFistFootTechnique:removeUnusedEffect(index)
    if table.getn(self.__unusedeffects) <= 0 then
        return nil
    end
    return table.remove(self.__unusedeffects, index)
end

--@desc: 升级
--@author:Seven
--@time:2022-10-19 11:03:17
--@lv: 提升到到的等级
function PlayerFistFootTechnique:upgradeLevel(lv)
    self.__basicTechnique = FistFootResManager:getBasicFistFootTechnique(self:getTechniqueId(), lv)

    local newEffects = {}
    for i = table.getn(self.__effects), 1, -1 do
        local removeEffect = self:removeEffect(i)

        table.insert(newEffects, FistFootResManager:getFistFootEffect(removeEffect:getPeculiarityid(), self:getLevel()))
    end

    self.__effects = newEffects

    local newUnusedEffects = {}
    for i = table.getn(self.__unusedeffects), 1, -1 do
        local removeEffect = self:removeUnusedEffect(i)

        table.insert(newUnusedEffects, FistFootResManager:getFistFootEffect(removeEffect:getPeculiarityid(), self:getLevel()))
    end

    self.__unusedeffects = newUnusedEffects
end

--@desc: 序列化，临时过度方案
--@author:Seven
--@time:2022-10-18 19:08:06
function PlayerFistFootTechnique:serialization()
    local effects = {}

    for i, e in ipairs(self.__effects) do
        --@RefType [src.app.models.FistFootSystem.FistFootEffect.FistFootEffect#FistFootEffect]
        local e = e
        table.insert(
            effects,
            {
                techniqueId = self.__basicTechnique:getSkillid(),
                characterId = e:getPeculiarityid()
            }
        )
    end

    local unusedEffects = {}

    for i, e in ipairs(self.__unusedeffects) do
        --@RefType [src.app.models.FistFootSystem.FistFootEffect.FistFootEffect#FistFootEffect]
        local e = e
        table.insert(
            unusedEffects,
            {
                techniqueId = self.__basicTechnique:getSkillid(),
                characterId = e:getPeculiarityid()
            }
        )
    end

    local t_info = {
        branchId = self:getBranchType(),
        id = self.__basicTechnique:getSkillid(),
        lv = self.__basicTechnique:getSkilllv()
    }

    return t_info, effects, unusedEffects
end

return newClass("PlayerFistFootTechnique", {}, PlayerFistFootTechnique)
0000000000