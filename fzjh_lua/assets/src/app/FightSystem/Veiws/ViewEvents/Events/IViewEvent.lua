--[[
    author:Seven
    time:2023-10-18 20:30:44
    desc: 战场视图事件接口
]]
local interface = require("third.class.interface")

local IViewEvent = {}

--@desc: 执行事件
--@author:Seven
--@time:2023-10-18 20:32:29
--@mainView: [FightMainView]
function IViewEvent:doViewEvent(mainView)
end

return interface("IViewEvent", IViewEvent)
00