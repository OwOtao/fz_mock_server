--[[
    author:Seven
    time:2025-09-18 14:34:56
    desc: 武学等级检测
]]
local newClass = require("third.class.NewClass")

--@SuperType [src.app.models.Store.DuplicatePurchaseCheck.ADuplicatePurchaseCheck#ADuplicatePurchaseCheck]
local DuplicatePurchaseCheck101 = {}

--@author:Seven
--@time:2025-09-18 14:42:32
--@return: bool true:不允许购买 false:允许购买
function DuplicatePurchaseCheck101:checkDuplicatePurchase(role)
    local result = false
    local msg = nil

    local skill_id = self._res:getSearchvalue()

    local skill_exp = role:getSkillExp(skill_id)

    local skill = Skill:getSkill(skill_id)

    local lv = skill:getLv(skill_exp)

    if self:_compareValue(lv) then
        result = true
        msg = "商品对应的武学，您已练习至超出此商品的可购买范围！"
    end

    return result, msg
end

return newClass("DuplicatePurchaseCheck101", {require("app.models.Store.DuplicatePurchaseCheck.ADuplicatePurchaseCheck")}, DuplicatePurchaseCheck101)
0000000000000000