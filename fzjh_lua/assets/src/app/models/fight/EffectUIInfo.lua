local newClass = require("third.class.NewClass")


local EffectUIInfo = {
    --属性id
    __attrId = nil,
    --效果给角色造成的最终伤害值
    __value = 0,
    --头顶弹出数值，为效果表现伤害值
    __popValue = 0,
    --头顶弹出文本或伤害的颜色
    __popTextColor = nil,
    --头顶弹出文本，如反弹、偏转状态提示
    __popText = nil
}

function EffectUIInfo:create(info)
    local p = EffectUIInfo.new()
    p:init(info)
    return p
end

function EffectUIInfo:init(info) 
    self.__attrId = info.attr
    self.__value = info.value
    self.__popValue = info.popValue
    self.__popText = info.popText
    self.__popTextColor = info.popTextColor
end

function EffectUIInfo:getAttrId()
    return self.__attrId
end

function EffectUIInfo:getValue()
    return self.__value
end

function EffectUIInfo:getPopText()
    return self.__popText
end

function EffectUIInfo:getPopTextColor()
    return self.__popTextColor
end

function EffectUIInfo:getPopValue()
    return self.__popValue
end

return newClass("EffectUIInfo", {}, EffectUIInfo)
00000