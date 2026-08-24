
local BaseBuff = require("app.models.Buff.BaseBuff")
--@SuperType [BaseBuff]
local PercentAttrBuff = class("PercentAttrBuff", BaseBuff)

local ChengeType = {
    Attr = 1,
    FinalAttr = 2
}

function PercentAttrBuff:create(luaData,manager)
    local p = PercentAttrBuff:new()
    p:init(luaData,manager)
    return p
end


function PercentAttrBuff:onInit()
    self.name = "PercentAttrBuff"

    self.effectValue = {}

    self.conditions = {}

    if self.luaData.scriptArgs == nil or self.luaData.scriptArgs == "" then
        assert(false, "buff id : " .. self:getId() .. "的脚本参数填写错误！！！")
    end

    local args = string.split(self.luaData.scriptArgs, ";")
    if #args < 3 then
        assert(false, "buff id : " .. self:getId() .. "的脚本参数填写数量不足3！！！")
    end

    self._attrName = args[1] --变化属性
    self._baseAttrName = args[2] --基础属性
    self._percent = tonumber(args[3])  --变化百分比
    self._changeType = Helper:getDef(tonumber(args[4]),2)  --变化类型
end


function PercentAttrBuff:trigger(context)
    local role = context.role
    local currValue
    local baseName = self._baseAttrName
    if self._changeType == ChengeType.Attr then
        currValue = role:getAttr(baseName)
    else
        currValue = role:getFinalAttr(baseName)
    end

    local addValue = Helper:mathFloor(currValue * self._percent)

    context.role:addAttr(self._attrName, addValue)

    local str = ""

    local symbol = ""
    if addValue >= 0 then
        symbol = "+"
    else
        symbol = "-"
    end

    PopText(User:getRole():getCHAttrName(self._attrName) .. " " .. symbol .. addValue)
end

return PercentAttrBuff
00000000000