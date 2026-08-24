--[[
    author:Seven
    time:2025-09-18 14:34:56
    desc: 主动招式熟练度
]]
local newClass = require("third.class.NewClass")

--@SuperType [src.app.models.Store.DuplicatePurchaseCheck.ADuplicatePurchaseCheck#ADuplicatePurchaseCheck]
local DuplicatePurchaseCheck301 = {}

--@author:Seven
--@time:2025-09-18 14:42:32
--@role: [src.app.models.role.Role#Role]
--@return: bool true:不允许购买 false:允许购买
function DuplicatePurchaseCheck301:checkDuplicatePurchase(role)
    local result = false
    local msg = nil

    local active_id = self._res:getSearchvalue()

    local exp = role:getSkillZhaoExp(active_id)

    if self:_compareValue(exp) then
        result = true
        msg = "商品对应的主动技能，您已研习至超出此商品的可购买范围！"
    end

    return result , msg
end

return newClass("DuplicatePurchaseCheck301", {require("app.models.Store.DuplicatePurchaseCheck.ADuplicatePurchaseCheck")}, DuplicatePurchaseCheck301)
00