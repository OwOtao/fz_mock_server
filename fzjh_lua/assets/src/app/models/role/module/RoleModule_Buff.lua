local Module = require("third.module.Module")
local RoleModule_Buff = class("RoleModule_Buff", Module)

function RoleModule_Buff:ctor()
    self._name = "RoleModule_Buff"
end

function RoleModule_Buff:getBuffAttr(target, attrName)
    if not target._roleBuff then
        return 0
    end
    local value = target._roleBuff:getAttr(attrName)
    if value ~= nil then
        return value
    else
        return 0
    end
end

return RoleModule_Buff
0000000000