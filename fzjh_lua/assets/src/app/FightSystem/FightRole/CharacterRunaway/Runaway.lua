--[[
    author:Seven
    time:2023-11-06 20:06:59
    desc:
]]
local newClass = require("third.class.NewClass")

local FightCommons = require("app.FightSystem.FightCommons")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local BattleConstConf = require("app.FightSystem.Configuration.BattleConstConf")

local TextResManager = require("app.FightSystem.ResourceManager.TextResManager")

local Runaway = {}

function Runaway:create()
    return Runaway.new():__init()
end

function Runaway:__init()
    self.__cd = 0

    return self
end

function Runaway:getId()
    return "runaway"
end

function Runaway:getName()
    return BattleConstConf:get("battleAction_runAway_name")
end

function Runaway:getCoolDownTime()
    return BattleConstConf:get("battleAction_runAway_cd")
end

function Runaway:setCD(cd)
    if cd == nil then
        assert(false, self:getName() .. " 设置技能CD参数错误" .. tostring(cd))
    end

    if cd < 0 then
        assert(false, self:getName() .. "设置技能CD不可为负数")
    end

    self.__cd = cd
end

function Runaway:getCD()
    return self.__cd
end

return newClass("Runaway", {}, Runaway)
0