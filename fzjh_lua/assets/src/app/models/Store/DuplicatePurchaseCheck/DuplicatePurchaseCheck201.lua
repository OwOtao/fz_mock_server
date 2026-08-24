--[[
    author:Seven
    time:2025-09-18 14:34:56
    desc: 客户端背包物品检测
]]
local newClass = require("third.class.NewClass")

local ItemHelper = require("app.models.item.ItemHelper")

--@SuperType [src.app.models.Store.DuplicatePurchaseCheck.ADuplicatePurchaseCheck#ADuplicatePurchaseCheck]
local DuplicatePurchaseCheck201 = {}

--@author:Seven
--@time:2025-09-18 14:42:32
--@role: [src.app.models.role.Role#Role]
--@return: bool true:不允许购买 false:允许购买
function DuplicatePurchaseCheck201:checkDuplicatePurchase(role)
    local result = false
    local msg = nil

    local itemId = self._res:getSearchvalue()

    local count = ItemHelper.getRoleOwnedTotalCountWithItemId(role, itemId)

    if self:_compareValue(count) then
        result = true
        msg = "已达到商品可持有数量的限制，无法购买"
    end

    return result, msg
end

return newClass("DuplicatePurchaseCheck201", {require("app.models.Store.DuplicatePurchaseCheck.ADuplicatePurchaseCheck")}, DuplicatePurchaseCheck201)
0