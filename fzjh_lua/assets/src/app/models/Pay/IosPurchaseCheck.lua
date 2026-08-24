--[[
    author:Seven
    time:2023-09-05 10:12:42
    desc: ios 订单检测
]]
local IosPurchaseCheck = {}

function IosPurchaseCheck:init()
    self.__lastCheckTime = 0

    self.__checkInterval = 5 * 60
end

function IosPurchaseCheck:updatePurchase()
    local current = GetTime()
    if current - self.__lastCheckTime >= 60 then
        self:checkPurchase()
    end
end

function IosPurchaseCheck:checkPurchase()
    if SdkMethod.IosPurchase_CheckUnchekReceipt ~= nil then
        SdkMethod:IosPurchase_CheckUnchekReceipt()
    end
    self.__lastCheckTime = GetTime()
    LogSystem:log("[other] : ...ios 订单检测...")
end

function IosPurchaseCheck:update()
    local current = GetTime()

    if current - self.__lastCheckTime >= self.__checkInterval then
        self:checkPurchase()
    end
end

IosPurchaseCheck:init()

return IosPurchaseCheck
0000000000000000