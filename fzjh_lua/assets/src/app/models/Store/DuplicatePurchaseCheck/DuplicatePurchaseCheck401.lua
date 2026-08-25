--[[
    author:Seven
    time:2025-09-18 14:34:56
    desc: 收否拥有面具
]]
local newClass = require("third.class.NewClass")

--@SuperType [src.app.models.Store.DuplicatePurchaseCheck.ADuplicatePurchaseCheck#ADuplicatePurchaseCheck]
local DuplicatePurchaseCheck401 = {}

local function getOwnStateText(value)
    if value == 1 then
        return "已拥有"
    elseif value == 0 then
        return "未拥有"
    end

    error("DuplicatePurchaseCheck401:getOwnStateText 只支持 1 或 0，当前值：" .. tostring(value))
end

--@author:Seven
--@time:2025-09-18 14:42:32
--@role: [src.app.models.role.Role#Role]
--@return: bool true:不允许购买 false:允许购买
function DuplicatePurchaseCheck401:checkDuplicatePurchase(role)
    local result = false
    local msg = nil

    assert(self._res:getJudgingcondition() == "=", 'DuplicatePurchaseCheck401:checkDuplicatePurchase 401 只支持"="判断')

    local mask_item_id = self._res:getSearchvalue()

    local item = Item:getOneItemByKey(mask_item_id)

    if item == nil then
        assert(false, "DuplicatePurchaseCheck401:checkDuplicatePurchase 面具资源没有找到，检查面具id是否正确" .. tostring(mask_item_id))
    end

    if item.type ~= "面具" and item.type ~= "信物" then
        assert(false, "DuplicatePurchaseCheck401:checkDuplicatePurchase 资源id不是面具/信物类型，检查面具id是否正确" .. tostring(mask_item_id))
    end

    local count = role:getDecorativeCount(mask_item_id)

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

return newClass("DuplicatePurchaseCheck401", {require("app.models.Store.DuplicatePurchaseCheck.ADuplicatePurchaseCheck")}, DuplicatePurchaseCheck401)
000