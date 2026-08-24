local newClass = require("third.class.NewClass")
local SelfCreatedSkillConstants = require("app.models.SelfCreatedSkillSystem.SelfCreatedSkillConstants")
local SelfCreatedSkillManager = require("app.models.SelfCreatedSkillSystem.SelfCreatedSkillManager.SelfCreatedSkillManager")

local ZhaoCreator = {
    __index = nil,
    __zhaoName = nil,
    __zhaoColorId = nil,
    __zhaoDscId = nil,
    __quality = nil,
	__lv = nil,
    __useType = nil,
    __zhaoId = nil,
    __atkAffixs = {},
    __defAffixs = {}
}

function ZhaoCreator:create()
    local p = ZhaoCreator.new()
    return p
end

function ZhaoCreator:initialize(data)
    self:setIndex(data.index)

    self:setZhaoName(data.name)
    
    self:setColorId(data.colorId)

    self:setZhaoDscId(data.dscId)

    self:setQuality(data.quality)

	self:setLv(data.lv)

    self:setUseType(data.useType)

    self:setZhaoId(data.templateId)

    self:setAtkAffixs(data.atkAffixs)

    self:setDefAffixs(data.defAffixs)
end

function ZhaoCreator:deserializable()
    return {
        index = self.__index,
        name = self.__zhaoName,
        colorId = self.__zhaoColorId,
        dscId = self.__zhaoDscId,
        quality = self.__quality,
		lv = self.__lv,
        useType = self.__useType,
        templateId = self.__zhaoId,
        atkAffixs = self.__atkAffixs,
        defAffixs = self.__defAffixs
    }
end

function ZhaoCreator:setIndex(index)
    self.__index = index
end

function ZhaoCreator:getIndex()
    return self.__index
end

function ZhaoCreator:setQuality(quality)
    self.__quality = quality
end

function ZhaoCreator:setLv(lv)
	self.__lv = lv
end

function ZhaoCreator:setUseType(useType)
    self.__useType = useType
end

function ZhaoCreator:setZhaoId(id)
    self.__zhaoId = id
end

function ZhaoCreator:setZhaoName(name)
    self.__zhaoName = name
end

function ZhaoCreator:getZhaoName()
    return self.__zhaoName
end

function ZhaoCreator:setZhaoDscId(zhaoDscId)
    self.__zhaoDscId = zhaoDscId
end

function ZhaoCreator:getZhaoDscId()
    return self.__zhaoDscId
end

-- @desc 随机名称
function ZhaoCreator:createRandomName()
    local randomResult = {
        {"words1","words2"},
        {"words1","words1","words2"},
        {"words1","words1","words1","words2"},
        {"words3","words2"},
        {"words1","words3","words2"},
        {"words3","words1","words2"},
        {"words3","words3","words2"},
        {"words1","words3"},
    }
    local result = randomResult[math.random(1,#randomResult)]
    local zhaoNameMap = SelfCreatedSkillManager:getZhaoNameMap()
    local name = ""
    for i,v in ipairs(result) do
        name = name..zhaoNameMap[v][math.random(1,#zhaoNameMap[v])]
    end

    return name
end

function ZhaoCreator:setColorId(colorId)
    self.__zhaoColorId = colorId
end

function ZhaoCreator:setAtkAffixs(affixs)
    self.__atkAffixs = affixs
end

function ZhaoCreator:setDefAffixs(affixs)
    self.__defAffixs = affixs
end

function ZhaoCreator:getColorId()
    return self.__zhaoColorId
end

return newClass("ZhaoCreator", {}, ZhaoCreator)
00000000000000