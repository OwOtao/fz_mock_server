local newClass = require("third.class.NewClass")

local HiddenMeridianResources = require("app.models.Meridian.HiddenMeridianResources.HiddenMeridianResources")

local Acupoint = {}

function Acupoint:create(...)
    local p = Acupoint.new()
    return p:init(...)
end

function Acupoint:ctor()
    self.__res = {}

    self.__isActivated = false --是否激活

    self.__buffId = nil --窍关上安装的玄络id
end

function Acupoint:init(id,roleAcupointData)
    self.__res = HiddenMeridianResources:getAcupointRes(id)

    if not MapIsEmpty(roleAcupointData) then
        if roleAcupointData.isActivated ~= nil then
            self.__isActivated = roleAcupointData.isActivated
        end
    
        if roleAcupointData.buffId ~= nil then
            self.__buffId = roleAcupointData.buffId
        end
    end

    return self
end

function Acupoint:getId()
    return self.__res.id
end

function Acupoint:getName()
    return self.__res.name
end

function Acupoint:getType()
    return self.__res.type
end

function Acupoint:getTextIntroduction()
    return self.__res.introduction
end

function Acupoint:getClass()
    return self.__res.class
end

function Acupoint:getResource()
    return self.__res.resource
end

function Acupoint:getTime()
    return self.__res.time
end

--@desc: 窍关是否激活(完成冲脉)
--@author:LvBin
--@time:2025-02-21 12:35:49
--@return true or false
function Acupoint:isActivated()
    return self.__isActivated
end

--@desc: 窍关是否已装备玄络buff
--@author:LvBin
--@time:2025-02-20 16:06:53
--@return true or false
function Acupoint:isAttachBuff()
    return self.__buffId ~= nil
end

--@desc: 获取窍关装备的玄络buffId
--@author:LvBin
--@time:2025-02-27 11:56:34
--@return
function Acupoint:getAttachBuffId()
    return self.__buffId
end

return newClass("Acupoint", {}, Acupoint)
00000000000000