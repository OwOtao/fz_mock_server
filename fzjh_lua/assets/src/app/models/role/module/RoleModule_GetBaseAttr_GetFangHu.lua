local Module = require("third.module.Module")
local RoleModule_GetBaseAttr_GetFangHu = class("RoleModule_GetBaseAttr_GetFangHu", Module)

function RoleModule_GetBaseAttr_GetFangHu:ctor()
    self._name = "RoleModule_GetBaseAttr_GetFangHu"
end

function RoleModule_GetBaseAttr_GetFangHu.getBaseAttr(module, self, attrName)
    if attrName == "protect" then
        -- 基础防护力
        local baseValue = self:getEffectCon()
    
        return true, baseValue
    end
    return false
end


function RoleModule_GetBaseAttr_GetFangHu:getBuffAttr(target, attrName)
    if attrName ~= "protect" then
        return 0
    end

    local value = 0

    return value
end

return RoleModule_GetBaseAttr_GetFangHu
000000000000