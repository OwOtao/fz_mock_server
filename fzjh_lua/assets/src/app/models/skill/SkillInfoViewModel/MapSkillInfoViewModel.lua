--[[
Descripttion: 
version: 
Author: LvBin
Date: 2025-01-03 11:22:29
--]]
local class = require("third.class.NewClass")

local SkillInfoViewModel = require("app.models.skill.SkillInfoViewModel.SkillInfoViewModel")

local SkillConst = require("app.models.skill.SkillConst")

local MapSkillInfoViewModel = {}

function MapSkillInfoViewModel:create(role)
    local p = MapSkillInfoViewModel:new()
    p:init(role)
    return p
end

return class("MapSkillInfoViewModel", {SkillInfoViewModel}, MapSkillInfoViewModel)000000000000