--[[
    author:Seven
    time:2025-09-18 14:34:56
    desc: 收否拥有挂饰
]]
local newClass = require("third.class.NewClass")

--@SuperType [src.app.models.Store.DuplicatePurchaseCheck.ADuplicatePurchaseCheck#ADuplicatePurchaseCheck]
local DuplicatePurchaseCheck501 = {}

local function getOwnStateText(value)
    if value == 1 then
        return "已拥有"
    elseif value == 0 then
        return "未拥有"
    end

    error("DuplicatePurchaseCheck501:getOwnStateText 只支持 1 或 0，当前值：" .. tostring(value))
end

--@author:Seven
--@time:2025-09-18 14:42:32
--@role: [src.app.models.role.Role#Role]
--@return: bool true:不允许购买 false:允许购买
function DuplicatePurchaseCheck501:checkDuplicatePurchase(role)
    local result = false
    local msg = nil

    assert(self._res:getJudgingcondition() == "=", 'DuplicatePurchaseCheck501:checkDuplicatePurchase 501 只支持"="判断')

    local appearnce_id = self._res:getSearchvalue()

    local item = Item:getOneItemByKey(appearnce_id)

    if item == nil then
        assert(false, "DuplicatePurchaseCheck501:checkDuplicatePurchase 挂饰资源没有找到，检查挂饰id是否正确" .. tostring(appearnce_id))
    end

    if item.type ~= "挂饰" then
        assert(false, "DuplicatePurchaseCheck501:checkDuplicatePurchase 资源id不是挂饰类型，检查挂饰id是否正确" .. tostring(appearnce_id))
    end

    local count = role:getDecorativeCount(appearnce_id)

    local currentValue = 0
    if count >= 1 then
        currentValue = 1
    end

    if self:_compareValue(currentValue) then
        result = true
        msg = string.format("%s【%s】", getOwnStateText(currentValue), item.name)
    end

    return result, msg
end

return newClass("DuplicatePurchaseCheck501", {require("app.models.Store.DuplicatePurchaseCheck.ADuplicatePurchaseCheck")}, DuplicatePurchaseCheck501)
0000