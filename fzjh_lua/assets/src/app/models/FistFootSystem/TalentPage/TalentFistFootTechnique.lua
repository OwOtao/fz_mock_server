--[[
    author:Seven
    time:2023-01-09 15:31:44
    desc: 技巧心得（天赋页）拳脚技巧类
]]
--[[
    author:Seven
    time:2022-10-18 18:43:53
    desc: 玩家拳脚系统技巧类
]]
local FistFootResManager = require("app.models.FistFootSystem.FistFootResManager")
local FistFootEffect = require("app.models.FistFootSystem.FistFootEffect.FistFootEffect")
local PlayerFistFootTechnique = require("app.models.FistFootSystem.FistFootTechniques.PlayerFistFootTechnique")

local newClass = require("third.class.NewClass")

--@SuperType [src.app.models.FistFootSystem.FistFootTechniques.PlayerFistFootTechnique#PlayerFistFootTechnique]
local TalentFistFootTechnique = {
    __effects = {},
    __unusedeffects = {}
}

function TalentFistFootTechnique:create(t_id, lv)
    local p = TalentFistFootTechnique.new()
    p:__init(t_id, lv)
    return p
end

function TalentFistFootTechnique:removeEffect(index)
    error("removeEffect 该类不支持该操作")
end

function TalentFistFootTechnique:insertUnusedEffect(effect)
    error("insertUnusedEffect 该类不支持该操作")
end

function TalentFistFootTechnique:removeUnusedEffect(index)
    error("removeUnusedEffect 该类不支持该操作")
end

--@desc: 升级
--@author:Seven
--@time:2022-10-19 11:03:17
--@lv: 提升到到的等级
function TalentFistFootTechnique:upgradeLevel(lv)
    error("upgradeLevel 该类不支持该操作")
end

--@desc: 序列化，临时过度方案
--@author:Seven
--@time:2022-10-18 19:08:06
function TalentFistFootTechnique:serialization()
    error("serialization 该类不支持该操作")
end

return newClass("TalentFistFootTechnique", {PlayerFistFootTechnique}, TalentFistFootTechnique)
00000000