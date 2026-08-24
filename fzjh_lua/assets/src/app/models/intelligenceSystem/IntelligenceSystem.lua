local NewClass = require("third.class.NewClass")
local IntelligenceNpcModel = require("app.models.intelligenceSystem.IntelligenceNpcModel")
local IntelligenceManager = require("app.models.intelligenceSystem.IntelligenceManager")

local IntelligenceSystem = {
    _intelligenceNpcModel = nil,
    _intelligenceManager = nil
}

function IntelligenceSystem:create()
    local p = IntelligenceSystem.new()
    p:init()
    return p
end

function IntelligenceSystem:init()
    self._intelligenceNpcModel = IntelligenceNpcModel
    self._intelligenceManager = IntelligenceManager:create(self)
end

function IntelligenceSystem:addNpc(map)
    self._intelligenceNpcModel:addNpc(map)
end

function IntelligenceSystem:talk()
    self._intelligenceNpcModel:talk()
end

--@desc 获取情报列表
function IntelligenceSystem:getIntelligenceList(callback)
    self._intelligenceManager:getIntelligenceList(callback)
end

--@desc 获取技巧类情报
function IntelligenceSystem:getTechniqueList(callback)
    self._intelligenceManager:getTechniqueList(callback)
end

--@desc 上传情报数据
function IntelligenceSystem:uploadIntelligenceData(params,callback)
    self._intelligenceManager:uploadIntelligenceData(params,callback)
end

--@desc 购买情报
function IntelligenceSystem:buyIntelligence(price,currency_type,callback)
    self._intelligenceManager:buyIntelligence(price,currency_type,callback)
end

--@desc 阅读情报
function IntelligenceSystem:readIntelligence(intelligence_id,intelligence_type,callback)
    self._intelligenceManager:readIntelligence(intelligence_id,intelligence_type,callback)
end

return NewClass("IntelligenceSystem", {}, IntelligenceSystem)0000000