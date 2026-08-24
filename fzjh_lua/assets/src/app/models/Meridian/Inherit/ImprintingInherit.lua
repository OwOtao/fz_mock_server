--[[
Descripttion: 经脉印记传承类
version: 
Author: LvBin
Date: 2025-01-20 17:54:40
--]]

local class = require("third.class.NewClass")

local Inherit = require("app.models.inherit.Inherit")

local MeridianResources = require("app.models.Meridian.MeridianResources")

local ImprintingInherit = {}

function ImprintingInherit:create(role)
    local p = ImprintingInherit:new()
    p:__init(role)
    return p
end

function ImprintingInherit:ctor()
    self.__inheritImprintingData = {}
end

function ImprintingInherit:__init(role)
    self.__role = role

    --@RefType [src.app.models.Meridian.System.IMeridianRoleSystem#IMeridianRoleSystem]
    self.__meridianRoleSystem = self.__role:getMeridianSystem()
end

function ImprintingInherit:getRole()
    return self.__role
end

function ImprintingInherit:getTextTitle()
    return "经脉传承"
end

function ImprintingInherit:getConfirmButtonName()
    return "确定传承"
end

function ImprintingInherit:getImprintingInfoButtonName()
    return "选\n择"
end

function ImprintingInherit:getMeridianImprintingRes(imprintingId)
    return MeridianResources:getMeridianImprintingRes(imprintingId)
end

function ImprintingInherit:getConfirmText1()
    local inheritName = self.__role:getAttr("inherit").name
    return "你心有所感，打算将真气注入 " .. inheritName .. " 的体内，为其留下最后的馈赠。虽然将来 " .. inheritName .. " 还要自修行，但起码也比同龄人先行一步、起点更高了吧。"
end

function ImprintingInherit:getConfirmText2()
    local count = self:getImprintingInheritCount()
    return "本次传承，作为继承人可以保留" .. count .. "条经脉天赋。\n你打算留下："
end

--@desc: 获取传承能选择的经脉印记数量
--@author:LvBin
--@time:2025-01-21 11:30:25
--@return
function ImprintingInherit:getImprintingInheritCount()
	local inheritCount = self.__role:getAttr("inheritCount")
    
    return inheritCount + 1
end

--@desc: 获取经脉天赋页列表
--@author:LvBin
--@time:2025-01-21 12:04:14
--@return
function ImprintingInherit:getMeridianImprintingPages()
    return self.__meridianRoleSystem:getMeridianImprintingPages()
end

--@desc: 获取指定页经脉印记列表
--@author:LvBin
--@time:2025-01-21 12:05:40
--@return
function ImprintingInherit:getPageMeridianImprintings(pageIndex)
    return self.__meridianRoleSystem:getPageMeridianImprintings(pageIndex)
end

--@desc: 传承是否需要选择经脉天赋(经脉数量不足时不需要选择)
--@author:LvBin
--@time:2025-01-20 17:37:32
--@return
function ImprintingInherit:needSelectMeridianImprintingForInherit()
    local pages = self:getMeridianImprintingPages()
    
    local canSelectCount = self.__role:getAttr("inheritCount") + 1

    for i,page in ipairs(pages) do
        if page:isUnlock() then
            local pageIndex = page:getPageIndex()

            local pageImprintingList = self:getPageMeridianImprintings(pageIndex)

            local imprintingCount = #pageImprintingList

            if self.__meridianRoleSystem:hasMeridianImprintingByPage(pageIndex,"zuoyouhuboyin") then
                imprintingCount = imprintingCount - 1
            end

            if imprintingCount > canSelectCount then
                return true
            end
        end
    end

    return false
end

--@desc: 初始化传承默认选择经脉天赋数据(经脉印记数量不足选择上限时,左右互博不选，其余全部选择)
--@author:LvBin
--@time:2025-01-21 11:29:27
--@return
function ImprintingInherit:initInheritDefaultSelectMeridianImprintingData()
    local pages = self:getMeridianImprintingPages()

    for i,page in ipairs(pages) do
        if page:isUnlock() then
            local pageIndex = page:getPageIndex()

            local pageImprintingList = self:getPageMeridianImprintings(pageIndex)

            for i,imprinting in ipairs(pageImprintingList) do
                local imprintingId = imprinting:getImprintingId()
                
                if imprintingId ~= "zuoyouhuboyin" then
                    self:selectInheritMeridianImprinting(pageIndex,imprintingId)
                end
            end

        end
    end
end

--@desc: 选择要进行传承的经脉印记
--@author:LvBin
--@time:2025-01-21 11:29:03
--@pageIndex:
	--@imprintingId: 
--@return
function ImprintingInherit:selectInheritMeridianImprinting(pageIndex,imprintingId)
    if self.__inheritImprintingData[pageIndex] == nil then
        self.__inheritImprintingData[pageIndex] = {}
    end
    table.insert(self.__inheritImprintingData[pageIndex], imprintingId)
end

--@desc: 删除要进行传承的经脉印记
--@author:LvBin
--@time:2025-01-21 11:29:03
--@pageIndex:
	--@imprintingId: 
--@return
function ImprintingInherit:delectInheritMeridianImprinting(pageIndex,imprintingId)
    if self.__inheritImprintingData[pageIndex] == nil then
        self.__inheritImprintingData[pageIndex] = {}
    end

    for i,v in ipairs(self.__inheritImprintingData[pageIndex]) do
        if v == imprintingId then
            table.remove(self.__inheritImprintingData[pageIndex], i)
        end

    end
end

--@desc: 获取传承已经选择的经脉印记数据
--@author:LvBin
--@time:2025-01-21 11:39:44
--@return
function ImprintingInherit:getInheritImprintingData()
    return self.__inheritImprintingData
end

--@desc: 指定页是否已经选过指定印记
--@author:LvBin
--@time:2025-01-21 11:28:34
--@pageIndex:
	--@imprintingId: 
--@return
function ImprintingInherit:isSelectMeridianImprinting(pageIndex,imprintingId)
    if MapIsEmpty(self.__inheritImprintingData[pageIndex]) then
        return false
    else
        for _,v in ipairs(self.__inheritImprintingData[pageIndex]) do
            if v == imprintingId then
                return true
            end
        end
    end

    return false
end

--@desc: 指定页还能否选择印记
--@author:LvBin
--@time:2025-01-21 11:32:25
--@return
function ImprintingInherit:canSelectMeridianImprinting(pageIndex)
    local selectCountMax = self:getImprintingInheritCount()

    local currPageSelectlist = self.__inheritImprintingData[pageIndex]

    if MapIsEmpty(currPageSelectlist) then
        return true
    end

    if #currPageSelectlist < selectCountMax then
        return true
    end

    return false,"最多只能保留" .. selectCountMax .. "条经脉天赋"
end

--@desc: 能否进行传承
--@author:LvBin
--@time:2025-01-21 11:34:54
--@return
function ImprintingInherit:canInherit()
    local pages = self:getMeridianImprintingPages()

    for i,page in ipairs(pages) do
        if page:isUnlock() then
            local pageIndex = page:getPageIndex()

            local pageSelectlist = self.__inheritImprintingData[pageIndex]

            if MapIsEmpty(pageSelectlist) or #pageSelectlist ~= self:getImprintingInheritCount() then
                return false,"还未选择需要保留的经脉天赋"
            end
        end
    end

    return true
end

--@desc: 传承
--@author:LvBin
--@time:2025-01-21 12:01:35
--@return
function ImprintingInherit:inherit()
    local pages = self:getMeridianImprintingPages()

    for i,page in ipairs(pages) do
        if page:isUnlock() then
            local pageIndex = page:getPageIndex()

            if self.__meridianRoleSystem:hasMeridianImprintingByPage(pageIndex,"zuoyouhuboyin") then
                self:selectInheritMeridianImprinting(pageIndex,"zuoyouhuboyin")
            end
        end
    end

    Inherit:doInherit(self.__inheritImprintingData)
end

function ImprintingInherit:getCurrUsingMeridianImprintingPageNumber()
    return self.__meridianRoleSystem:getCurrUsingMeridianImprintingPageNumber()
end

return class("ImprintingInherit", {}, ImprintingInherit)
0000000