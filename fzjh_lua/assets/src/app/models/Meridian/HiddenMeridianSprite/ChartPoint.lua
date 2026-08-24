local newClass = require("third.class.NewClass")

local ChartPoint = {}

function ChartPoint:create(...)
    local p = ChartPoint.new()
    p:init(...)
    return p
end

function ChartPoint:ctor()
    self.__acupoint = {}

    self.__typePath = ""

    self.__levelPath = ""

    self.__selectPath = ""
end

--@desc: 
--@author:LvBin
--@time:2025-02-28 17:00:22
--@acupointIndex: 窍关索引位置
--@return
function ChartPoint:init(acupoint,acupointIndex)
    self.__acupoint = acupoint 

    self.__acupointIndex = acupointIndex

    self.__typePath = switch(acupoint:getType(),{
        [1] = "red",
        [2] = "blue",
        [3] = "green",
    })

    self.__levelPath = switch(acupoint:getClass(),{
        [1] = "circle",
        [2] = "square",
        [3] = "diamond",
    })

    self.__selectPath = "Image/BaseUI/yellow-select-"..self.__levelPath..".png"
end

function ChartPoint:getImage()
    local imgPath = "Image/BaseUI/"

    local name = "btn"

    if self.__acupoint:isActivated() then
        if self.__acupoint:isAttachBuff() then
            name = name.."-"..self.__typePath
        else
            name = name.."-".."brown"
        end
    else
        if self.__acupointIndex == 1 then
            name = name.."-".."white"
        else
            name = name.."-".."grey"
        end
    end

    name = name.."-"..self.__levelPath..".png"

    return imgPath .. name
end

function ChartPoint:getSelectImage()
    return self.__selectPath
end

return newClass("ChartPoint", {}, ChartPoint)
0000