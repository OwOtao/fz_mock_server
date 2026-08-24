--[[
    author:Seven
    time:2025-01-17 14:59:35
    desc: 培元功能接口
]]
local interface = require("third.class.interface")

local IPeiYuanFunc = {}

--@desc: 是否满足销毁
--@author:Seven
--@time:2025-01-17 15:14:10
--@succFunc: func()
--@failFunc: func(failmsg)
function IPeiYuanFunc:meetCost(succFunc, failFunc)
end

--@desc: 培元
--@author:Seven
--@time:2025-01-17 15:01:08
--@succfunc: func()
--@failfunc: func(failmsg)
function IPeiYuanFunc:peiyuan(succfunc, failfunc)
end

return interface("IPeiYuanFunc", IPeiYuanFunc)
000000