local newClass = require("third.class.NewClass")

local BaseCondition = require("app.models.Meridian.HiddenMeridianBuff.Condition.BaseCondition")

local RoleAttrFightCondition = {}

function RoleAttrFightCondition:create(...)
    local p = RoleAttrFightCondition.new()
    p:init(...)
    return p
end

function RoleAttrFightCondition:check()
    local value = switch(
        self:getAttrId(),
        {
            ["atk"] = self:getRole():getAtk(),
            ["def"] = self:getRole():getDef(),
            ["dodge"] = self:getRole():getDodge(),
            ["damage"] = self:getRole():getPowerDamage(),
            ["protect"] = self:getRole():getFangHu(),
            ["default"] = assert(nil,"ShenBingAttrCountCondition:check() error 角色战斗属性类解锁条件 属性id未定义"..self:getAttrId())
        }
    )

    return self:compare(value)
end

return newClass("RoleAttrFightCondition", {BaseCondition}, RoleAttrFightCondition)
00000000000000