--[[
    author:Seven
    time:2025-09-18 11:37:59
    desc: 检测商品重复购买抽象类
]]
local abstract = require("third.class.abstract")

local IDuplicatePurchaseCheck = require("app.models.Store.DuplicatePurchaseCheck.IDuplicatePurchaseCheck")

local LogSystem = require("app.models.LogSystem.LogSystem")

--@SuperType [src.app.models.Store.DuplicatePurchaseCheck.IDuplicatePurchaseCheck#IDuplicatePurchaseCheck]
local ADuplicatePurchaseCheck = {
    _res = nil
}

function ADuplicatePurchaseCheck:_compareValue(currentValue)
    local judgingCondition = self._res:getJudgingcondition()
    local judgingValue = self._res:getJudgingvalue()

    if judgingCondition == "=" then
        return currentValue == judgingValue
    elseif judgingCondition == ">" then
        return tonumber(currentValue) > tonumber(judgingValue)
    elseif judgingCondition == "<" then
        return tonumber(currentValue) < tonumber(judgingValue)
    elseif judgingCondition == ">=" then
        return tonumber(currentValue) >= tonumber(judgingValue)
    elseif judgingCondition == "<=" then
        return tonumber(currentValue) <= tonumber(judgingValue)
    else
        error("ADuplicatePurchaseCheck:_compareValue() - not support judgingCondition : " .. tostring(judgingCondition))
    end
end

--@desc:检测是否重复购买
--@author:Seven
--@time:2025-09-28 11:46:42
--@role: [src.app.models.role.Role#Role]
--@res: [src.app.models.Store.DuplicatePurchaseCheck.DuplicatePurchaseCheckHelper#GoodsSearchResourceClass]
--@return: bool
function ADuplicatePurchaseCheck:duplicateCheck(role, res)
    self._res = res

    local result, msg = self:checkDuplicatePurchase(role)
    LogSystem:log(string.format("商品重复购买检测 ： - 检测条件ID:【%d】, 检测结果:【%s】", res:getId(), tostring(result)))

    self._res = nil

    return result, msg
end

return abstract("ADuplicatePurchaseCheck", {IDuplicatePurchaseCheck}, ADuplicatePurchaseCheck)
00