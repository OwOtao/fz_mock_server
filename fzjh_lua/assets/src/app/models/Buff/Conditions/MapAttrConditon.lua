local BaseBuffCondition = require("app.models.Buff.Conditions.BaseBuffCondition")
--@SuperType [BaseBuffCondition]
local MapAttrConditon = class("MapAttrConditon", BaseBuffCondition)

function MapAttrConditon:create()
    local p = MapAttrConditon:new()
    p:init()
    return p
end

function MapAttrConditon:init()
    self.type = 5
end

function MapAttrConditon:check(context)
    local map = context.map

    if map == nil then
        print("当前并非在地图中，该条件无法通过。")
        return false
    end

    local condType = self.arg1

    local attrType = self.arg2

    local condValue = self.arg3

    local value = map:getMapAttr(AttrName[attrType])

    if value == nil then
        error("地图属性未定义，buff id :" .. self.buff:getId() .. "  attrType : " .. self.arg2)
    end

    -- 0=等于，1小于，2大于,3小于等于，4大于等于
    local res =
        switch(
        condType,
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


return MapAttrConditon0