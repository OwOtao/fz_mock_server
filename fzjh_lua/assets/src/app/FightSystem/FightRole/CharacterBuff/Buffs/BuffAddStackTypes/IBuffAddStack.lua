--[[
    author:Seven
    time:2023-10-09 20:46:47
    desc: buff添加时前，叠加类型及叠加规则执行接口
]]
local interface = require("third.class.interface")

local IBuffAddStack = {}

function IBuffAddStack:tryAddToCharacter(buff, character)
end

return interface("IBuffAddStack", IBuffAddStack)
0000000000