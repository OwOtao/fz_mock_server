--[[
    该模块提供获取有效属性(先天加后天)方法
]]

local Module = require("third.module.Module")
local RoleModule_GetAttr_GetTotalAttr = class("RoleModule_GetAttr_GetTotalAttr", Module)

local attr_name = {
    ["currStr"] = {"str", "secStr"},
    ["currDex"] = {"dex", "secDex"},
    ["currCon"] = {"con", "secCon"},
    ["currInt"] = {"int", "secInt"}
}

function RoleModule_GetAttr_GetTotalAttr.getBaseAttr(module, self, attrName)
    if attr_name[attrName] ~= nil then
        local attrName1 = attr_name[attrName][1] -- 先天属性值
        local attrName2 = attr_name[attrName][2] -- 后天属性值
        if not self[attrName1] or type(self[attrName1]) ~= "number" then
            self[attrName1] = 0
        end
        if not self[attrName2] or type(self[attrName2]) ~= "number" then
            self[attrName2] = 0
        end
        local value = tonumber(self[attrName1] + self:getFinalAttr(attrName2))
        
        return true, value
    end

    return false
end

return RoleModule_GetAttr_GetTotalAttr
00000000