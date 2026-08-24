--[[
    author:Seven
    time:2025-09-18 14:34:56
    desc: 玩家角色属性
]]
local newClass = require("third.class.NewClass")

--@SuperType [src.app.models.Store.DuplicatePurchaseCheck.ADuplicatePurchaseCheck#ADuplicatePurchaseCheck]
local DuplicatePurchaseCheck601 = {}

--@author:Seven
--@time:2025-09-18 14:42:32
--@role: [src.app.models.role.Role#Role]
--@return: bool true:允许购买 false:不允许购买
function DuplicatePurchaseCheck601:checkDuplicatePurchase(role)
    local result = false
    
    local msg = nil

    local attr_name = self._res:getSearchvalue()

    local attr_value = nil
    
    if attr_name == "level" then
        attr_value = role:getLv()
        msg = "您的等级不符合该礼包道具的最低使用要求，目前不能购买"
    else
        assert(false, "DuplicatePurchaseCheck601:checkDuplicatePurchase 没有这个属性的判断支持" .. tostring(attr_name))
    end
    
    if self:_compareValue(attr_value) then
        result = true
        if msg == nil then
            msg = "你的属性不符合角色属性要求，目前不能购买"
        end
    end

    return result , msg
end

return newClass("DuplicatePurchaseCheck601", {require("app.models.Store.DuplicatePurchaseCheck.ADuplicatePurchaseCheck")}, DuplicatePurchaseCheck601)
000000000000000