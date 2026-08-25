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
        local isUnlocked = role:getHiddenMeridianSystem():isUnlocked() == true
        local value = isUnlocked and 1 or 0

        if self:_compareValue(value) then
            result = true
            msg = (isUnlocked and "已开启" or "未开启") .. "隐脉系统"
        end
    end
    
    return result , msg
end

return newClass("DuplicatePurchaseCheck1001", {require("app.models.Store.DuplicatePurchaseCheck.ADuplicatePurchaseCheck")}, DuplicatePurchaseCheck1001)
000000