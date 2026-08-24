--[[
    防具
]]
local interface = require("third.class.interface")

local IArmor = {}

--@desc: 这是武器名称
--@author:Seven
--@time:2021-06-30 17:34:18
--@name: 武器名称
function IArmor:setName(name)
end

--@desc: 获取武器名字
--@author:Seven
--@time:2021-06-30 17:32:52
function IArmor:getName()
end

--@desc: 获取保护力
--@author:Seven
--@time:2021-06-30 17:52:32
function IArmor:getProtect()
end

--@desc: 设置防护力
--@author:Seven
--@time:2021-06-30 17:58:32
function IArmor:setProtect(value)
end

return interface("IArmor", IArmor)
0000000