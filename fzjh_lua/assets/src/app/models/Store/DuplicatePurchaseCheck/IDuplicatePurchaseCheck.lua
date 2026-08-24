--[[
    author:Seven
    time:2025-09-18 11:30:59
    desc: 检测商品重复购买接口
]]
local interface = require("third.class.interface")
local IDuplicatePurchaseCheck = {}

function IDuplicatePurchaseCheck:checkDuplicatePurchase(role)
    -- body
    error("IDuplicatePurchaseCheck:checkDuplicatePurchase() - not implement")
end

return interface("IDuplicatePurchaseCheck", IDuplicatePurchaseCheck)
0000000000