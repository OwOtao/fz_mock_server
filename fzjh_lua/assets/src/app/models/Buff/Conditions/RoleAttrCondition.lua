--[[
    2 - 人物属性
        arg1 : 0=等于，1小于，2大于,3小于等于，4大于等于
        arg2 : (人物属性代码，参考sheet1)
        arg3 : 具体值或百分比值 例如 10 or 10%
]]
local BaseBuffCondition = require("app.models.Buff.Conditions.BaseBuffCondition")
--@SuperType [BaseBuffCondition]
local RoleAttrCondition = class("RoleAttrCondition", BaseBuffCondition)

function RoleAttrCondition:create()
    local p = RoleAttrCondition:new()
    p:init()
    return p
end

function RoleAttrCondition:init()
    self.type = 2
end

function RoleAttrCondition:onCheck()
    local role = self.context.role

    local cond = self.arg1

    local attrName = AttrName[self.arg2]

    if attrName == nil then
        error("Role buff conditon get attr is not declare , buff id : " .. self.buff:getId())
    end

    local value
    if self.arg2 < 300 then
        value = role:getBaseAttr(attrName)
    elseif self.arg2 > 300 and self.arg2 < 1200 then
        value = role:getFinalAttr(attrName)
    else
        value = role:getAttr(attrName)
    end

    local condValue

    if type(self.arg3) == "string" then

        local StringUtil = require("app.extends.StringUtil")
        local percent = Helper:getDef(tonumber(StringUtil:subString(self.arg3, "%%", false)) / 100, 1)

        --#TODO 获取某个值的百分比，先用属性名限制
        --@desc 需算出对比值
        local maxAttrName = attrName.."Max"
        local maxValue = self.context.role:getFinalAttr(maxAttrName)
        condValue = maxValue * percent
        
    elseif type(self.arg3) == "number" then
        condValue = self.arg3
    else
        error("Role Attr condition arg3 type is error")
    end

    -- 0=等于，1小于，2大于,3小于等于，4大于等于
    local res =
        switch(
        cond,
        {
            [0] = function()
                if value == condValue then
                    return true
                end
                
                return false
            end,
            [1] = function()
                if value < condValue then
                    return true
                end

                return false
            end,
            [2] = function()
                if value > condValue then
                    return true
                end

                return false
            end,
            [3] = function()
                if value <= condValue then
                    return true
                end
                return false
            end,
            [4] = function()
                if value >= condValue then
                    return true
                end

                return false
            end
        }
    )

    return res
end


return RoleAttrCondition000000000