--[[
隐藏经脉系统是否开启
判断条件可填写 = 符号，逻辑为判断玩家【该系统是否开启】,1=开启，0=未开启
]]
local newClass = require("third.class.NewClass")

--@SuperType [src.app.models.Store.DuplicatePurchaseCheck.ADuplicatePurchaseCheck#ADuplicatePurchaseCheck]
local DuplicatePurchaseCheck1001 = {}

function DuplicatePurchaseCheck1001:checkDuplicatePurchase(role)
    local result = false
    
    local msg = nil

    local searchValue = self._res:getSearchvalue()

    if searchValue == "hiddenMeridianSystem" then
        local value = role:getHiddenMeridianSystem():isUnlocked() == true and 1 or 0

        if self:_compareValue(value) then
            result = true
            if msg == nil then
                msg = "不满足购买条件，无法购买!"
            end
        end
    end
    
    return result , msg
end

return newClass("DuplicatePurchaseCheck1001", {require("app.models.Store.DuplicatePurchaseCheck.ADuplicatePurchaseCheck")}, DuplicatePurchaseCheck1001)
00000000000000