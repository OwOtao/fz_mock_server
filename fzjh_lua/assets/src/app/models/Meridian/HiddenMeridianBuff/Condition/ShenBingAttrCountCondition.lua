local newClass = require("third.class.NewClass")

local BaseCondition = require("app.models.Meridian.HiddenMeridianBuff.Condition.BaseCondition")

local ShenBingAttrCountCondition = {}

function ShenBingAttrCountCondition:create(...)
    local p = ShenBingAttrCountCondition.new()
    p:init(...)
    return p
end

function ShenBingAttrCountCondition:check()
    local count = 0

    local attrId = self:getAttrId()

    local compareLogic = self:getParam()[1]

    local compareValue = self:getParam()[2]
    
    local function getAttrValue(weaponAttr)
        if attrId == "yindu" then
            return weaponAttr:getWeaponYingDu(self:getRole())
        elseif attrId == "rendu" then
            return weaponAttr:getWeaponRenDu(self:getRole())
        elseif attrId == "weight" then
            return weaponAttr:getWeaponWeight(self:getRole())
        elseif attrId == "damage" then
            return weaponAttr:getWeaponDamage(self:getRole())
        elseif attrId == "effctNum" then
            return weaponAttr:getWeaponEffectNum(self:getRole())
        else
            error("ShenBingAttrCountCondition:check() error 神兵属性类解锁条件 属性id未定义"..attrId)
        end
    end

    local shenBingItems = self:getRole():getAttr("shenBingItems")

    for i,v in ipairs(shenBingItems) do
        local weaponAttr = self:getRole():getOneItemByKey(v.id)

        if Helper:compareTwoNumberWithCN(getAttrValue(weaponAttr), compareValue, compareLogic) then
            count = count + 1
        end
	end

    return self:compare(count)
end

return newClass("ShenBingAttrCountCondition", {BaseCondition}, ShenBingAttrCountCondition)
000000