--[[
    author:Seven
    time:2025-09-18 14:34:56
    desc: 收否拥有挂饰
]]
local newClass = require("third.class.NewClass")

--@SuperType [src.app.models.Store.DuplicatePurchaseCheck.ADuplicatePurchaseCheck#ADuplicatePurchaseCheck]
local DuplicatePurchaseCheck501 = {}

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
        msg = "已达到商品可持有数量的限制，无法购买"
    end

    return result, msg
end

return newClass("DuplicatePurchaseCheck501", {require("app.models.Store.DuplicatePurchaseCheck.ADuplicatePurchaseCheck")}, DuplicatePurchaseCheck501)
00