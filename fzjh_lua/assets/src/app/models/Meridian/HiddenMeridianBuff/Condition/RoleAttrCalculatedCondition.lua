local newClass = require("third.class.NewClass")

local BaseCondition = require("app.models.Meridian.HiddenMeridianBuff.Condition.BaseCondition")

local BookLiterary = require("app.models.book.BookLiterary")

local RoleAttrCalculatedCondition = {}

function RoleAttrCalculatedCondition:create(...)
    local p = RoleAttrCalculatedCondition.new()
    p:init(...)
    return p
end

function RoleAttrCalculatedCondition:check()
    local value = 0
    if self:getAttrId() == "pokedexPoint" then
        value = self:getRole():getPokedexPoint()
    elseif self:getAttrId() == "bookPoint" then
        value = BookLiterary:getBookPoint(self:getRole())
    elseif self:getAttrId() == "totalCollectScore" then
        value = ((self:getRole():getAttr("collectScore") + 100) / 12) ^ 1.3
    else
        error("RoleAttrCalculatedCondition:check() error 角色计算属性类解锁条件 属性id未定义"..self:getAttrId())
    end

    return self:compare(value)
end

return newClass("RoleAttrCalculatedCondition", {BaseCondition}, RoleAttrCalculatedCondition)
000