--[[
Descripttion: 
version: 
Author: LvBin
Date: 2025-02-27 15:56:38
--]]
local HiddenMeridianResources = require("app.models.Meridian.HiddenMeridianResources.HiddenMeridianResources")

local Acupoint = require("app.models.Meridian.Acupoint")

local newClass = require("third.class.NewClass")

local HiddenMeridianChart = {}

function HiddenMeridianChart:create(...)
    local p = HiddenMeridianChart.new()
    return p:init(...)
end

function HiddenMeridianChart:ctor()
    self.__res = {}

    self.__acupointMap = {
        -- acupointId = {
        --     isActivated = false, --是否激活
        --     buffId = nil --窍关上安装的玄络id
        -- }
    }

    --@RefType 窍关列表 [src.app.models.account.Account#Account]
    self.__acupointList = {}
end

function HiddenMeridianChart:init(id,acupointMap)
    self.__res = HiddenMeridianResources:getHiddenMeridianChartRes(id)

    if not MapIsEmpty(acupointMap) then
        self.__acupointMap = acupointMap
    end

    local acupointList = {}

    for i = 1,99 do
        local acupointId = self:getGroove(i)
        if acupointId then
            local roleAcupointData = self.__acupointMap[acupointId]

            local acupoint = Acupoint:create(acupointId,roleAcupointData)

            table.insert(self.__acupointList, acupoint)
        else
            break
        end
    end

    return self
end

function HiddenMeridianChart:getId()
    return self.__res.id
end

function HiddenMeridianChart:getName()
    return self.__res.name
end

function HiddenMeridianChart:getClass()
    return self.__res.class
end

function HiddenMeridianChart:getResource()
    return self.__res.resource
end

function HiddenMeridianChart:getTime()
    return self.__res.time
end

function HiddenMeridianChart:getImageIndex()
    return self.__res.imageIndex
end

function HiddenMeridianChart:getGroove(index)
    return self.__res["groove"..index]
end

function HiddenMeridianChart:getPrecondition(index)
    return self.__res["precondition"..index]
end

function HiddenMeridianChart:getAcupointList()
    return self.__acupointList
end

function HiddenMeridianChart:getAcupointIndex(acupointId)
    for index,acupoint in ipairs(self.__acupointList) do
        if acupoint:getId() == acupointId then
            return index
        end
    end
end

--@desc: 检查指定窍关是否已激活
--@author:LvBin
--@time:2025-03-01 10:49:31
--@acupointId: 窍关id
--@return
function HiddenMeridianChart:isAcupointActivated(acupointId)
    if self.__acupointMap[acupointId] and self.__acupointMap[acupointId].isActivated then
        return true
    end

    return false
end

--@desc: 检查指定窍关是否已解锁
--@author:LvBin
--@time:2025-02-20 16:06:53
--@acupointIndex: 窍关位置索引
--@return true or false
function HiddenMeridianChart:isAcupointUnlocked(acupointIndex)
    local precondition = self:getPrecondition(acupointIndex)

    if precondition == nil then
        return true
    end

    for i,conditionList in ipairs(precondition) do
        if not self:__checkConditionList(conditionList) then
            return false
        end
    end  

    return true
end

function HiddenMeridianChart:__checkConditionList(conditionList)
    if MapIsEmpty(conditionList) then
        return true
    end

    for i,acupointId in ipairs(conditionList) do
        if self:isAcupointActivated(acupointId) then
            return true
        end
    end  

    return false
end

return newClass("HiddenMeridianChart", {}, HiddenMeridianChart)
0000000000