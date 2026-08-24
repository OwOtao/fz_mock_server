local BaseBuffEffect = require("app.models.Buff.Effects.BaseBuffEffect")

--@SuperType [BaseBuffEffect]
local AttrBuffEffect = class("AttrBuffEffect", BaseBuffEffect)

function AttrBuffEffect:create()
    local p = AttrBuffEffect:new()
    p:init()
    return p
end

function AttrBuffEffect:onInit()
    self.effectType = 1
end

function AttrBuffEffect:trigger(context)
    local attrName = AttrName[self.attrType]

    
    if attrName == nil then
        error("效果值对象未定义 ：" .. self.attrType .. "   buff id " .. self.buff:getId())
    end

    self.effectValue[attrName] = self.value

    print("增益【"..attrName.."】: " .. self.value)
end


function AttrBuffEffect:remove()
    self.effectValue = {}
end

return AttrBuffEffect
00000000000000