local BaseBuffEffect = class("BaseBuffEffect")

-- 1-buff增益
-- 2-属性恢复
-- 3-人物获取一个物品
-- 4-物品抽取
-- 5-对象增益（例如某些功能概率的加成）

function BaseBuffEffect:create()
    local p = BaseBuffEffect:new()

    p:init()

    return p
end

function BaseBuffEffect:ctor()
    
end

function BaseBuffEffect:init()
    self.id = 0
    self.effectType = 0
    self.attrType = 0
    self.vauleType = 0
    self.value = 0
    --@desc 默认不叠加
    self.isMutiply = 0

    self.effectValue = {}

    self.effectAttrName = nil

    self.effectAddValue = 0

    self:onInit()
end

function BaseBuffEffect:onInit()
    
end


function BaseBuffEffect:setBuff(buff)
    --@RefType[BaseBuff]
    self.buff = buff
end

function BaseBuffEffect:setId(id)
    self.id = id
end

function BaseBuffEffect:getEffectType()
    return self.effectType
end


function BaseBuffEffect:setValueType(valueType)
    if valueType == nil then
        error("valueType is null , buff id : " .. self.buff:getId())
        return
    end
    self.vauleType = valueType
end

function BaseBuffEffect:setValue(value)
    self.value = value
end

function BaseBuffEffect:setisMutiply(isMutiply)
    self.isMutiply = isMutiply
end

function BaseBuffEffect:setAttrType(attrType)
    self.attrType = attrType
end


function BaseBuffEffect:trigger(context)
end

function BaseBuffEffect:onRemove()
end

function BaseBuffEffect:analysisValue(context)
    if self.vauleType == 0 then
        return self.value
    elseif self.vauleType == 1 then
        local currValue

        local attrName = AttrName[self.attrType]

        if attrName == nil then
            error("Role buff effect get attr is not declare , buff id : " .. self.buff:getId())
        end
    
        local role = context.role
        if self.attrType < 300 then
            currValue = role:getBaseAttr(attrName)
        elseif self.attrType > 300 and self.attrType < 1200 then
            currValue = role:getFinalAttr(attrName)
        else
            currValue = role:getAttr(attrName)
        end

        local addValue = currValue * (self.value / 100)

        return Helper:getDef(tonumber(addValue), 0)
    elseif self.vauleType == 2 then
        return self.value
    else
        error("buff效果类型未定义 : " .. self.vauleType .. "   id :" .. self.buff:getId())
    end
end

function BaseBuffEffect:getEffectValue()
    return self.effectValue
end

return BaseBuffEffect
0000000000000000