local NewClass = require("third.class.NewClass")

local IFistFootEffect = require("app.models.FistFootSystem.FistFootEffect.IFistFootEffect")

local FistFootEffect = {}

function FistFootEffect:create(data)
    local p = FistFootEffect.new(data)
    return p
end

--流水id (无用)
function FistFootEffect:getId()
    return self.id
end

--特性id
function FistFootEffect:getPeculiarityid()
    return self.peculiarityid
end

--特性等级
function FistFootEffect:getLevel()
    return self.level
end

--特性名称
function FistFootEffect:getName()
    return self.name
end

--特性描述
function FistFootEffect:getText()
    return self.text
end

--触发条件类型
function FistFootEffect:getConditiontype()
    return self.conditiontype
end

--主动招式效果ID
function FistFootEffect:getSpecialEffectId()
    return self.specialEffect[1]
end

--主动招式效果参数
function FistFootEffect:getSpecialEffectArgs()
    return {
		self.specialEffect[2],
		self.specialEffect[3],
		self.specialEffect[4],
	}
end

--公式
function FistFootEffect:getFormula()
    return self.formula
end

--技巧特性携带常态buff
function FistFootEffect:getPermanentBuffId()
    return self.permanentBuffId
end

--技巧特性buff添加器
function FistFootEffect:getBuffLauncherAdd()
    return self.buffLauncherAdd
end

--解锁条件（拳脚等级）
function FistFootEffect:getCondition()
    return self.condition
end

--解锁条件（技巧等级）
function FistFootEffect:getScondition()
    return self.Scondition
end

--所需标记
function FistFootEffect:getSign()
    return self.sign
end

--特性开启文本
function FistFootEffect:getOpentext()
    return self.opentext
end

return NewClass("FistFootEffect", {IFistFootEffect}, FistFootEffect)
00000000000