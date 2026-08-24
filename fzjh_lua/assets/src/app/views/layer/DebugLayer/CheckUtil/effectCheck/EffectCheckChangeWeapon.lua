local newClass = require("third.class.NewClass")
local BaseCheck = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckBaseCheck")
local EffectCheckConst = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckConst")
local ChangeWeapon = {}
--[[
    武器切换
    参数1;arg1
    参数2;arg2
    参数3;arg3
]]

function ChangeWeapon:create(effect)
    local p = ChangeWeapon.new()
    p:init(effect)
    return p
end

return newClass("ChangeWeapon", {BaseCheck}, ChangeWeapon)
000000000