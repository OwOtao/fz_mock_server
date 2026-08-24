--[[
Descripttion: 
version: 
Author: LvBin
Date: 2024-08-05 15:17:57
--]]
local NewClass = require("third.class.NewClass")
local MaskAttr = require("app.models.mask.MaskAttr")
local MaskUpgradeRes = require("script.others.maskUpgrade")["Sheet1"]
local BorderConfigManager = require("app.models.HeadViewSystem.BorderConfigManager")

local MaskGrade = {}

function MaskGrade:create(gradeId)
    local p = MaskGrade.new(gradeId)
    p._data = assert(MaskUpgradeRes[tostring(gradeId)],"没有这个面具阶段gradeId = "..gradeId)
    return p
end

function MaskGrade:getId()
    return self._data.id
end

function MaskGrade:getMaskId()
    return self._data.maskId
end

function MaskGrade:getMaskName()
    return self._data.maskName
end

function MaskGrade:getMaskType()
    return self._data.maskType
end

function MaskGrade:getMaskLevel()
    return self._data.maskLevel
end

function MaskGrade:getUpgradeCondition()
    return self._data.upgradeCondition
end

function MaskGrade:getEquipText()
    return self._data.equipText
end

function MaskGrade:getUnwieldText()
    return self._data.unwieldText
end

function MaskGrade:getCaiLiao()
    return self._data.cailiao
end

function MaskGrade:canUpgrcade()
    return self._data.canUpgrade == 1 and true or false
end

--@desc: 能否分解
--@author:LvBin
--@time:2024-11-23 14:39:13
--@return
function MaskGrade:canDeal()
    return self._data.canDeal == 1 and true or false
end

function MaskGrade:getMaskAttrIds()
    return self._data.artsId
end

function MaskGrade:getTimeMask()
    return self._data.timeMask
end

function MaskGrade:getWearCondition()
    return self._data.WearCondition
end

function MaskGrade:isTimeMask()
    return not MapIsEmpty(self:getTimeMask())
end

function MaskGrade:getCurrTimeArtsId()
    local timeMask = self:getTimeMask()
    if not MapIsEmpty(timeMask) then
        local hour = tonumber(Helper:date("%H", GetTime()))
        local index = #timeMask
        for i,v in ipairs(timeMask) do
            if hour >= tonumber(timeMask[i]) then
                index = i
            end
        end
        return self:getMaskAttrIds()[index]
    end
    return self:getMaskAttrIds()[1]
end

return NewClass("MaskGrade", {}, MaskGrade)
000000000000000