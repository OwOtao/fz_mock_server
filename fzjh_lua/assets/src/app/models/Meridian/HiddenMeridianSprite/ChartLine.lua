--[[
Descripttion: 
version: 
Author: LvBin
Date: 2025-02-28 16:43:45
--]]
local newClass = require("third.class.NewClass")

local Line = class("Line")

function Line:create(...)
    local p = Line:new()
    p:init(...)
    return p
end

function Line:ctor()
    self.__id = ""
    self.__imagePath = ""
end

function Line:init(id,imagePath)
    self.__id = id
    self.__imagePath = imagePath
end

function Line:getId()
    return self.__id
end

function Line:getImagePath()
    return self.__imagePath
end

local ChartLine = {}

function ChartLine:create(...)
    local p = ChartLine.new()
    p:init(...)
    return p
end

function ChartLine:ctor()
    self.__lineList = {}
end

--@desc: 
--@author:LvBin
--@time:2025-02-28 17:00:22
--@hiddenMeridianChart: [src.app.models.Meridian.HiddenMeridianChart#HiddenMeridianChart]
--@return
function ChartLine:init(hiddenMeridianChart)
    self.__hiddenMeridianChart = hiddenMeridianChart

    self.__lineList = {}

    for acupointIndex = 1, 99 do
        local acupointId = hiddenMeridianChart:getGroove(acupointIndex)

        local preAcupointIdList = self:__getPreAcupointIdList(acupointIndex)

        if acupointId and #preAcupointIdList > 0 then
            for _i, preAcupointId in ipairs(preAcupointIdList) do
                local preAcupointIndex = self.__hiddenMeridianChart:getAcupointIndex(preAcupointId) 
                if preAcupointIndex then
                    local lineId = "Image_line_"..preAcupointIndex.."_"..acupointIndex
                    local imgPath = ""
                    if self.__hiddenMeridianChart:isAcupointActivated(acupointId) and self.__hiddenMeridianChart:isAcupointActivated(preAcupointId) then
                        imgPath = "Image/BaseUI/light-line.png"
                    else
                        imgPath = "Image/BaseUI/grey-line.png"
                    end
                    local line = Line:create(lineId,imgPath)
                     
                    table.insert(self.__lineList,line)
                end
            end
        end
    end
end

function ChartLine:__getPreAcupointIdList(index)
    local preconditions = self.__hiddenMeridianChart:getPrecondition(index)
    local preAcupointIdList = {}
    if not MapIsEmpty(preconditions) then
        for i,precondition in ipairs(preconditions) do
            if not MapIsEmpty(precondition) then
                for _i,acupointId in ipairs(precondition) do
                    if acupointId then
                        table.insert(preAcupointIdList, acupointId)
                    end
                end
            end
        end
    end
    return preAcupointIdList
end

function ChartLine:getLineList()
    return self.__lineList
end

return newClass("ChartLine", {}, ChartLine)
00000