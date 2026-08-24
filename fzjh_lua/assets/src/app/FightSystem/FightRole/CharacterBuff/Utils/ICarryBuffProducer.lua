--[[
    author:Seven
    time:2024-01-15 20:19:15
    desc: 定义携带buff给角色添加功能接口
]]
local interface = require("third.class.interface")
local ICarryBuffProducer = {}

function ICarryBuffProducer:getCarryBuffArray()
end

function ICarryBuffProducer:getCarryBuffAdderGroupArray()
end

return interface("ICarryBuffProducer", ICarryBuffProducer)
0000