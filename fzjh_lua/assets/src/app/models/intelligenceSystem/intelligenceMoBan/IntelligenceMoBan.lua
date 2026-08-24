local NewClass = require("third.class.NewClass")
local IntelligenceConstants = require("app.models.intelligenceSystem.IntelligenceConstants")
local IntelligenceMoBan = {
    -- id = nil,
    -- activity_num = nil,    --活动情报数量
    -- plot_num = nil,   --剧情情报数量
    -- technique_open = nil,     --能否生成技巧类情报
    -- probability = nil,   --生成概率
    -- type = nil,    --购买货币类型
    -- price = nil     --货币数量
}

function IntelligenceMoBan:create(data)
    local p = IntelligenceMoBan.new(data)
    return p
end

function IntelligenceMoBan:getId()
    return tostring(self.id)
end

function IntelligenceMoBan:getActivityNum()
    return self.activity_num
end

function IntelligenceMoBan:getPlotNum()
    return self.plot_num
end

function IntelligenceMoBan:getTechniqueOpen()
    return self.technique_open
end

function IntelligenceMoBan:getProbability()
    return self.probability
end

function IntelligenceMoBan:getCurrencyType()
    return self.type
end

function IntelligenceMoBan:getPrice()
    return self.price
end

return NewClass("IntelligenceMoBan", {}, IntelligenceMoBan)0000000000