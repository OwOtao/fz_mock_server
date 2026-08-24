--[[
    author:Seven
    time:2022-11-19 16:20:06
    desc: 被动招式基础信息
]]

local class = require("third.class.NewClass")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

--@RefType [src.app.models.skill.BasicSkill.BasicZhaoInfo#BasicZhaoInfo]
local BasicZhaoInfo = require("app.models.skill.BasicSkill.BasicZhaoInfo")

--@SuperType [src.app.models.skill.BasicSkill.BasicZhaoInfo#BasicZhaoInfo]
local BasicActiveZhaoInfo = {}

function BasicActiveZhaoInfo:create(res)
    return BasicActiveZhaoInfo.new():__init(res)
end

return class("BasicActiveZhaoInfo", {BasicZhaoInfo}, BasicActiveZhaoInfo)
0000000