--[[
隐藏经脉是否全部窍关点亮
判断条件可填写 = 符号，逻辑为判断玩家【隐藏经脉是否全部窍关点亮】,1=是，0=否
]]
local newClass = require("third.class.NewClass")

--@SuperType [src.app.models.Store.DuplicatePurchaseCheck.ADuplicatePurchaseCheck#ADuplicatePurchaseCheck]
local DuplicatePurchaseCheck1002 = {}

function DuplicatePurchaseCheck1002:checkDuplicatePurchase(role)
    local result = false
    
    local msg = nil

    local searchValue = self._res:getSearchvalue()

    if searchValue == "minditemfull" then
        local value = 0

        if role:getHiddenMeridianSystem():isHiddenMeridianChartMaxLv() and role:getHiddenMeridianSystem():acupointAllActivate() then
            value = 1
        end

        if self:_compareValue(value) then
            result = true
            if msg == nil then
                msg = "不满足购买条件，无法购买!"
            end
        end
    end
    
    return result , msg
end

return newClass("DuplicatePurchaseCheck1002", {require("app.models.Store.DuplicatePurchaseCheck.ADuplicatePurchaseCheck")}, DuplicatePurchaseCheck1002)
00000000000