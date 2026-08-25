--[[
    author:Seven
    time:2025-01-16 18:27:40
    desc: 经脉印记天赋页对象
]]
local newClass = require("third.class.NewClass")

local MeridianResources = require("app.models.Meridian.MeridianResources")

local isImpl = require("third.assertIsInstance.assertIsInstance")

local BasicMeridianImprintingPage = {}

local PAGE_NAME_INDEX = {
    [1] = "朝元经脉",
    [2] = "护元经脉"
}

BasicMeridianImprintingPage.PAGE_NAME_INDEX = PAGE_NAME_INDEX

function BasicMeridianImprintingPage:create(...)
    local p = BasicMeridianImprintingPage.new()
    return p:__init(...)
end

function BasicMeridianImprintingPage:__init(index, imprintings)
    self.__index = index

    if imprintings ~= nil and type(imprintings) == "table" then
        self.__imprintings = {}
        for _, v in ipairs(imprintings) do
            table.insert(self.__imprintings, v)
        end
        self.__isUnlock = true
    else
        self.__imprintings = {}
        self.__isUnlock = false
    end

    return self
end

function BasicMeridianImprintingPage:getPageIndex()
    return self.__index
end

function BasicMeridianImprintingPage:getImprintingPageName()
    return PAGE_NAME_INDEX[self.__index] or "未知经脉页"
end

function BasicMeridianImprintingPage:unlock()
    self.__isUnlock = true
end

--@desc: 该是否解锁经脉印记天赋页
--@author:Seven
--@time:2025-01-16 18:32:34
--@return: boolean
function BasicMeridianImprintingPage:isUnlock()
    return self.__isUnlock
end

--@desc: 获取经脉印记天赋页的经脉印记列表
--@time:2025-01-16 18:33:00
--@return: list [src.app.models.Meridian.BasicMeridianImprinting#BasicMeridianImprinting]
function BasicMeridianImprintingPage:getImprintings()
    if not self.__isUnlock then
        return nil
    end
    
    return self.__imprintings
end

--@desc: 查找经脉印记天赋页的经脉印记，如果没有返回nil,否则返回经脉印记天赋对象和索引位置
--@author:Seven
--@time:2025-01-17 11:31:58
--@imprId: 印记ID
--@return [src.app.models.Meridian.BasicMeridianImprinting#BasicMeridianImprinting], number
function BasicMeridianImprintingPage:findImprinting(imprId)
    for index, v in ipairs(self.__imprintings) do
        if v:getImprintingId() == imprId then
            return v, index
        end
    end

    return nil, -1
end

--@desc: 给该页添加经脉印记
--@author:Seven
--@time:2025-01-16 20:36:00
--@impriting: [src.app.models.Meridian.BasicMeridianImprinting#BasicMeridianImprinting]
function BasicMeridianImprintingPage:addImprinting(impriting)
    if not self.__isUnlock then
        error("BasicMeridianImprintingPage:addImprinting page is unlock , can't add imprinting")
    end
    table.insert(self.__imprintings, impriting)
end

--@desc: 移除该页的经脉印记，如果没有返回nil, 删除成功返回删除的经脉印记天赋对象
--@author:Seven
--@time:2025-01-16 20:44:09
--@imprId: 经脉印记ID
--@return [src.app.models.Meridian.BasicMeridianImprinting#BasicMeridianImprinting]
function BasicMeridianImprintingPage:removeImprinting(imprId)
    for i, v in ipairs(self.__imprintings) do
        if v:getImprintingId() == imprId then
            return table.remove(self.__imprintings, i)
        end
    end

    error("BasicMeridianImprintingPage:removeImprinting not found imprinting id:" .. tostring(imprId))
end

--@desc: 移除该页的经脉印记，如果没有返回nil, 删除成功返回删除的经脉印记天赋对象,根据索引位置删除印记对象，索引从1开始，如果索引超出范围会报错，返回nil,否则返回删除的印记对象
--@time:2025-01-16 20:45:00
--@index: 索引位置
--@return [src.app.models.Meridian.BasicMeridianImprinting#BasicMeridianImprinting]
function BasicMeridianImprintingPage:removeImprintingFromIndex(index)
    if index < 1 or index > #self.__imprintings then
        error("BasicMeridianImprintingPage:removeImprintingFromIndex index out of range:" .. tostring(index))
    end

    return table.remove(self.__imprintings, index)
end

function BasicMeridianImprintingPage:clearImprintings()
    self.__imprintings = {}
end

return newClass("BasicMeridianImprintingPage", {}, BasicMeridianImprintingPage)
0000