local NewClass = require("third.class.NewClass")
local ISelfCreatedZhaoAffix = require("app.models.SelfCreatedSkillSystem.ISelfCreatedZhaoAffix")
local SelfCreatedSkillManager = require("app.models.SelfCreatedSkillSystem.SelfCreatedSkillManager.SelfCreatedSkillManager")

local SelfCreatedZhaoAffix = {}

function SelfCreatedZhaoAffix:create(data)
    local p = SelfCreatedZhaoAffix.new(data)
    p._data = SelfCreatedSkillManager:getZhaoAffix(data.effectId)
    return p
end

function SelfCreatedZhaoAffix:getEffectId()
    return self.effectId
end

function SelfCreatedZhaoAffix:getGrade()
    return self.needLv
end

function SelfCreatedZhaoAffix:getEffectValue1()
    return self.value1
end

function SelfCreatedZhaoAffix:getEffectValue2()
    return self.value2
end

function SelfCreatedZhaoAffix:getEffectValue3()
    return self.value3
end

function SelfCreatedZhaoAffix:getName()
    return self._data.affixName
end

--特性描述
function SelfCreatedZhaoAffix:getDsc()
    local dsc = self._data.affixtext
    if string.find(dsc,"$n1") then
        dsc = string.gsub(dsc,"$n1",math.abs(self:getEffectValue1()))
    end
    
    if string.find(dsc,"$n2") then
        dsc = string.gsub(dsc,"$n2",math.abs(self:getEffectValue2()))
    end

    if string.find(dsc,"$n3") then
        dsc = string.gsub(dsc,"$n3",math.abs(self:getEffectValue3()))
    end
    return dsc
end

--特性作用效果类型1
function SelfCreatedZhaoAffix:getEffectType1()
    return self._data.effectType1
end

--特性作用效果类型1参数
function SelfCreatedZhaoAffix:getEffectParam1()
    return self._data.effectParam1
end

--特性作用效果类型2
function SelfCreatedZhaoAffix:getEffectType2()
    return self._data.effectType2
end

--特性作用效果类型2参数
function SelfCreatedZhaoAffix:getEffectParam2()
    return self._data.effectParam2
end

--特性作用效果类型3
function SelfCreatedZhaoAffix:getEffectType3()
    return self._data.effectType3
end

--特性作用效果类型3参数
function SelfCreatedZhaoAffix:getEffectParam3()
    return self._data.effectParam3
end

--@desc 获取词缀加成值
--[[--@type: 1=影响招式模板性能属性固定值N、2=影响招式模板性能属性百分比N%、3=附带属性内功攻击N、4=抵御属性内功攻击N
--@param: 填写受影响的招式模板性能字段名。
效果类型=3或者4，填写属性类型：positive=阳性、negative=阴性、mixed=混元、poisonous=毒性…（可自定义新增）]]
function SelfCreatedZhaoAffix:getAffixValue(type,param)
    local value = 0
    
    for i = 1,99 do
        if self._data["effectType"..i] and self._data["effectParam"..i] and self["value"..i] then
            if self._data["effectType"..i] == type and self._data["effectParam"..i] == param then
                if type == 2 then
                    value = value + (self["value"..i]/100)
                else
                    value = value + self["value"..i]
                end
            end
        else
            break
        end
    end
    return value
end

return NewClass("SelfCreatedZhao", { ISelfCreatedZhaoAffix }, SelfCreatedZhaoAffix)0000