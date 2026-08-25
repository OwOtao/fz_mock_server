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
        local item = Item:getOneItemByKey(itemId)

        assert(item ~= nil and item.name ~= nil, "DuplicatePurchaseCheck201:checkDuplicatePurchase 客户端道具资源没有找到，检查物品id是否正确" .. tostring(itemId))

        result = true
        msg = string.format("已拥有【%s】且数量%s%s", item.name, self:_getCompareSymbolText(), tostring(self:_getJudgingValue()))
    end

    return result, msg
end

return newClass("DuplicatePurchaseCheck201", {require("app.models.Store.DuplicatePurchaseCheck.ADuplicatePurchaseCheck")}, DuplicatePurchaseCheck201)
00000000000000