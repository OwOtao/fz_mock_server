--[[
Descripttion: 玩家门派
version: 
Author: LvBin
Date: 2026-07-15 15:46:56
--]]
local newClass = require("third.class.NewClass")

--@SuperType [src.app.models.Store.DuplicatePurchaseCheck.ADuplicatePurchaseCheck#ADuplicatePurchaseCheck]
local DuplicatePurchaseCheck602 = {}

local Family = require("app.models.family.Family")

local function getFamilyStateText(value)
    if value == 1 then
        return "已加入"
    elseif value == 0 then
        return "未加入"
    end

    error("DuplicatePurchaseCheck602:getFamilyStateText 只支持 1 或 0，当前值：" .. tostring(value))
end

function DuplicatePurchaseCheck602:checkDuplicatePurchase(role)
    local result = false
    
    local msg = nil

    local family = Family:getFamily(self._res:getSearchvalue())
    
	local currentValue = 0
	
    if role:getFamilyId() == self._res:getSearchvalue() then
        currentValue = 1
    end

    if self:_compareValue(currentValue) then
        result = true
        msg = string.format("当前%s【%s】门派", getFamilyStateText(self:_getJudgingValue()), family:getName())
    end

    return result , msg
end

return newClass("DuplicatePurchaseCheck602", {require("app.models.Store.DuplicatePurchaseCheck.ADuplicatePurchaseCheck")}, DuplicatePurchaseCheck602)
000