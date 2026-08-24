local BaseBuffEffect = require("app.models.Buff.Effects.BaseBuffEffect")

--@SuperType [BaseBuffEffect]
local AttrValueBuffEffect = class("AttrValueBuffEffect", BaseBuffEffect)

function AttrValueBuffEffect:create()
    local p = AttrValueBuffEffect:new()
    p:init()
    return p
end

function AttrValueBuffEffect:onInit()
    self.effectType = 2
end

function AttrValueBuffEffect:trigger(context)
    local addValue = self:analysisValue(context)

    local attrName = AttrName[self.attrType]

    if attrName == nil then
        error("效果值对象未定义 ：" .. self.attrType .. "   buff id " .. self.buff:getId())
    end

    local layers = Helper:getDef(context.layers,1)

    self.effectAttrName = attrName

    self.effectAddValue = addValue * layers

    context.role:addAttr(attrName, addValue)

    local str = ""

    local symbol = ""
    if addValue >= 0 then
        symbol = "+"
    end

    if attrName == "qiPercent" then
        PopText(User:getRole():getCHAttrName(attrName) .. " " .. symbol .. Helper:mathFloor(addValue*context.role:getFinalAttr("qiMax")))
    else
        PopText(User:getRole():getCHAttrName(attrName) .. " " .. symbol .. Helper:mathFloor(addValue))
    end
end

function AttrValueBuffEffect:remove()
end

return AttrValueBuffEffect
00000000000000