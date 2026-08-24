local NewClass = require("third.class.NewClass")
local IntelligenceConstants = require("app.models.intelligenceSystem.IntelligenceConstants")
local Intelligence = {
    -- id = nil,
    -- type = nil,    --情报类型
    -- type2 = nil,   --情报子类型
    -- con = nil,     --情报解锁条件
    -- arg = nil,     --条件参数
    -- title = nil,   --情报标题
    -- text = nil,    --情报文本
    -- arg1 = nil     --情报开关
}

function Intelligence:create(data)
    local p = Intelligence.new(data)
    return p
end

function Intelligence:getId()
    return tostring(self.id)
end

function Intelligence:getType()
    return self.type
end

function Intelligence:getType2()
    return self.type2
end

function Intelligence:getCondition1()
    return self.con1
end

function Intelligence:getConditionArg1()
    return self.arg1
end

function Intelligence:getCondition2()
    return self.con2
end

function Intelligence:getConditionArg2()
    return self.arg2
end

function Intelligence:getCondition3()
    return self.con3
end

function Intelligence:getConditionArg3()
    return self.arg3
end

function Intelligence:getTitle()
    return self.title
end

function Intelligence:getText()
    return self.text
end

function Intelligence:isOpen()
    return self.open == IntelligenceConstants.OpenType.Open and true or false
end

return NewClass("Intelligence", {}, Intelligence)0000000