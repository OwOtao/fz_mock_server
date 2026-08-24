--[[
Descripttion: 经脉印记重筑类
version: 
Author: LvBin
Date: 2025-01-20 17:54:40
--]]

local class = require("third.class.NewClass")

local MeridianResources = require("app.models.Meridian.MeridianResources")

local MeridianHelper = require("app.models.Meridian.MeridianHelper")

local ImprintingRebuild = {}

function ImprintingRebuild:create(role)
    local p = ImprintingRebuild:new()
    p:__init(role)
    return p
end

function ImprintingRebuild:ctor()
    self.__rebuildImprintingData = {}
end

function ImprintingRebuild:__init(role)
    self.__role = role

    --@RefType [src.app.models.Meridian.System.IMeridianRoleSystem#IMeridianRoleSystem]
    self.__meridianRoleSystem = self.__role:getMeridianSystem()
end

function ImprintingRebuild:getRole()
    return self.__role
end

function ImprintingRebuild:getTextTitle()
    return "经脉重筑"
end

function ImprintingRebuild:getConfirmButtonName()
    return "确定重筑"
end

function ImprintingRebuild:getImprintingInfoButtonName()
    return "选\n择"
end

function ImprintingRebuild:getMeridianImprintingRes(imprintingId)
    return MeridianResources:getMeridianImprintingRes(imprintingId)
end

function ImprintingRebuild:getConfirmText1()
    return "你小心翼翼地导引着真气逆行，当你觉得几乎要脱力时，一种返璞归真、如封似闭的感觉入体，不禁心中大喜：看来重筑有望！"
end

function ImprintingRebuild:getConfirmText2()
    local count = self:getImprintingRebuildCount()
    return "本次经脉重筑，你可以保留" .. count .. "条经脉天赋。\n你打算留下："
end

--@desc: 获取重筑能选择的经脉印记数量
--@author:LvBin
--@time:2025-01-21 11:30:25
--@return
function ImprintingRebuild:getImprintingRebuildCount()
	local inheritCount = self.__role:getAttr("inheritCount")
    
    return inheritCount
end

--@desc: 获取经脉天赋页列表
--@author:LvBin
--@time:2025-01-21 12:04:14
--@return
function ImprintingRebuild:getMeridianImprintingPages()
    return self.__meridianRoleSystem:getMeridianImprintingPages()
end

--@desc: 获取指定页经脉印记列表
--@author:LvBin
--@time:2025-01-21 12:05:40
--@return
function ImprintingRebuild:getPageMeridianImprintings(pageIndex)
    return self.__meridianRoleSystem:getPageMeridianImprintings(pageIndex)
end

--@desc: 选择要进行重筑的经脉印记
--@author:LvBin
--@time:2025-01-21 11:29:03
--@pageIndex:
	--@imprintingId: 
--@return
function ImprintingRebuild:selectRebuildMeridianImprinting(pageIndex,imprintingId)
    if self.__rebuildImprintingData[pageIndex] == nil then
        self.__rebuildImprintingData[pageIndex] = {}
    end
    table.insert(self.__rebuildImprintingData[pageIndex], imprintingId)
end

--@desc: 获取指定页已选择经脉印记数量
--@author:LvBin
--@time:2025-02-18 11:50:09
--@pageIndex: 
--@return
function ImprintingRebuild:getSelectImprintingNum(pageIndex)
    local selectNum = 0

    if self.__rebuildImprintingData[pageIndex] ~= nil then
        selectNum = #self.__rebuildImprintingData[pageIndex]
    end

    return selectNum
end

--@desc: 删除要进行重筑的经脉印记
--@author:LvBin
--@time:2025-01-21 11:29:03
--@pageIndex:
	--@imprintingId: 
--@return
function ImprintingRebuild:delectRebuildMeridianImprinting(pageIndex,imprintingId)
    if self.__rebuildImprintingData[pageIndex] == nil then
        self.__rebuildImprintingData[pageIndex] = {}
    end
    
    for i,v in ipairs(self.__rebuildImprintingData[pageIndex]) do
        if v == imprintingId then
            table.remove(self.__rebuildImprintingData[pageIndex], i)
        end

    end
end

--@desc: 获取重筑已经选择的经脉印记数据
--@author:LvBin
--@time:2025-01-21 11:39:44
--@return
function ImprintingRebuild:getRebuildImprintingData()
    return self.__rebuildImprintingData
end

--@desc: 指定页是否已经选过指定印记
--@author:LvBin
--@time:2025-01-21 11:28:34
--@pageIndex:
	--@imprintingId: 
--@return
function ImprintingRebuild:isSelectMeridianImprinting(pageIndex,imprintingId)
    if MapIsEmpty(self.__rebuildImprintingData[pageIndex]) then
        return false
    else
        for _,v in ipairs(self.__rebuildImprintingData[pageIndex]) do
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
function ImprintingRebuild:canSelectMeridianImprinting(pageIndex)
    local selectCountMax = self:getImprintingRebuildCount()

    if self:getSelectImprintingNum(pageIndex) < selectCountMax then
        return true
    end

    return false,"最多只能保留" .. selectCountMax .. "条经脉天赋"
end

--@desc: 能否进行重筑
--@author:LvBin
--@time:2025-01-21 11:34:54
--@return
function ImprintingRebuild:canRebuild()
    local pages = self:getMeridianImprintingPages()

    for i,page in ipairs(pages) do
        if page:isUnlock() then
            local pageIndex = page:getPageIndex()

            if self:getSelectImprintingNum(pageIndex) ~= self:getImprintingRebuildCount() then
                return false,"还未选择需要保留的经脉天赋"
            end
        end
    end

    return true
end

--@desc: 重筑
--@author:LvBin
--@time:2025-01-21 12:01:35
--@return
function ImprintingRebuild:rebuild(callFunc)
    local pages = self:getMeridianImprintingPages()

    for i,page in ipairs(pages) do
        if page:isUnlock() then
            local pageIndex = page:getPageIndex()

            if self.__meridianRoleSystem:hasMeridianImprintingByPage(pageIndex,"zuoyouhuboyin") then
                self:selectRebuildMeridianImprinting(pageIndex,"zuoyouhuboyin")
            end
        end
    end

    HttpManagerEx:submitAction("JingMaiChongZhu",1,function(status, errcode, errmsg, data)
        if status == 200 then
            if errcode == 0 then
                MeridianHelper:doRebuildMeridian(self.__role, self.__rebuildImprintingData)
                self.__role:setAttr("meridianExp",0)
                self.__role:setFlag("冲穴真气", 0)
                local meridian =
                    {
                        meridianCount = 0,
                        acupointCount = 0,
                        acupointState = 1,
                        alreadyDisease = 0,
                        alreadyDisorder = 0,
                        attrList = {},
                        attrTotal =
                        {
                            ["qiMax"] = 0, 			-- 气血上限
                            ["neiLiLimit"] = 0,		-- 内力上限
                            ["atk"] = 0,			-- 攻击力
                            ["dodge"] = 0,			-- 闪躲力
                            ["def"] = 0,			-- 防御力
                            ["damage"] = 0,			-- 伤害力
                            ["protect"] = 0,		-- 防护力
                        },
                    }
                    
                self.__role:setAttr("meridian", meridian)

                self.__role:updateRoleBuff()
                
                callFunc(true, "重筑成功", data)
            else
                callFunc(false, errmsg)
            end
        else
            callFunc(false, errmsg)
        end
    end,
    IS_SHOW_WAITING)
end

function ImprintingRebuild:getCurrUsingMeridianImprintingPageNumber()
    return self.__meridianRoleSystem:getCurrUsingMeridianImprintingPageNumber()
end

return class("ImprintingRebuild", {}, ImprintingRebuild)
00000000000000