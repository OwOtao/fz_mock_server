--[[
    author:Seven
    time:2023-01-10 12:11:23
    desc: 武器切换功能抽象类
]]
local interface = require("third.class.interface")

local TextResManager = require("app.FightSystem.ResourceManager.TextResManager")

local ISwitchFunc = {}

function ISwitchFunc:canSwitch(sys)
end

return interface("ISwitchFunc", ISwitchFunc)
0