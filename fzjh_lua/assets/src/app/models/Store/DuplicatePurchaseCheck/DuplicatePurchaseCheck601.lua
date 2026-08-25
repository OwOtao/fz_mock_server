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
    else
        assert(false, "DuplicatePurchaseCheck601:checkDuplicatePurchase 没有这个属性的判断支持" .. tostring(attr_name))
    end
    
    if self:_compareValue(attr_value) then
        result = true
        msg = string.format("当前人物等级%s【%s】级", self:_getCompareSymbolText(), tostring(self:_getJudgingValue()))
    end

    return result , msg
end

return newClass("DuplicatePurchaseCheck601", {require("app.models.Store.DuplicatePurchaseCheck.ADuplicatePurchaseCheck")}, DuplicatePurchaseCheck601)
000000000