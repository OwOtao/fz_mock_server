local MeridianResources = require("app.models.Meridian.MeridianResources")

local addMeridianImprintingDebugLayer = class("addMeridianImprintingDebugLayer", cc.Layer)

function addMeridianImprintingDebugLayer:create()
    local p = addMeridianImprintingDebugLayer:new()
    p:init()
    return p
end

function addMeridianImprintingDebugLayer:init()
    self.__ui = require("app.views.ui.SkillUI.MeridianSkillPeiYuanUI"):create()

    self.__ui:addTo(self)
end

function addMeridianImprintingDebugLayer:showLayer()
    self.__selectId = nil

    self.__role = User:getRole()

    self.__meridianSys = self.__role:getMeridianSystem()

    self:setTitle()

    self:setButtonBack()

    self:setTextLeftName()

    self:setTextRightName()

    self:initLeftListView()

    self:initRightListView()

    self:setTextLeftSpeed()

    self:setTextRightSpeed()

    self:setButtonLeft()

    self:setButtonRight()

    self:refreshImprintingDetail()

    self.__ui:setTextLeftTip("已经拥有的印记")

    self.__ui:setTextRightTip("选择添加的印记")

    self.__ui:showUI()
end

function addMeridianImprintingDebugLayer:setTitle(text)
    self.__ui:setTitle("添加印记(所有天赋页)")
end

function addMeridianImprintingDebugLayer:setButtonBack()
    self.__ui:setButtonBack(
        function()
            PopupLayerController:hideLayer("addMeridianImprintingDebugLayer",function()
                self.__ui:hideUI()
            end)
        end
    )
end

function addMeridianImprintingDebugLayer:setTextLeftName()
    local text = ""

    self.__ui:setTextLeftName(text)
end

function addMeridianImprintingDebugLayer:setTextRightName()
    local text = ""
    if self.__selectId then
        local imprinting = MeridianResources:getMeridianImprintingRes(self.__selectId)

        text = imprinting:getName()
    end
    
    self.__ui:setTextRightName(text)
end

function addMeridianImprintingDebugLayer:initLeftListView()
    local array = {}

    local list = self.__meridianSys:getCurrentPageMeridianImprintings()
    for i, v in ipairs(list) do
        table.insert(array, MeridianResources:getMeridianImprintingRes(v:getImprintingId()))
    end

    table.sort(
        array,
        function(a, b)
            return a:getIndexId() < b:getIndexId()
        end
    )

    local retArray = {}

    for i,v in ipairs(array) do
        v = v
        local retTab = {}

        retTab.name = v:getName()

        retTab.func = function()
        end

        table.insert(retArray, retTab)
    end

    self.__ui:setLeftListView(retArray)
end

function addMeridianImprintingDebugLayer:initRightListView()
    local array = {}

    local allImprResList = MeridianResources:getAllMeridianImprintingRes()
    for i, v in ipairs(allImprResList) do
        if not self.__meridianSys:roleHasImpriting(v:getImprintingId()) then
            table.insert(array, v)
        end
    end

    table.sort(
        array,
        function(a, b)
            return a:getIndexId() < b:getIndexId()
        end
    )
    
    local retArray = {}

    for i,v in ipairs(array) do
        local retTab = {}

        retTab.name = v:getName()

        retTab.func = function()
            self.__selectId = v:getImprintingId()

            self:setTextRightName()

            self:setTextLeftSpeed()

            self:setTextRightSpeed()

            self:refreshImprintingDetail()
        end

        table.insert(retArray, retTab)
    end

    self.__ui:setRightListView(retArray)
end

function addMeridianImprintingDebugLayer:setTextLeftSpeed()
    self.__ui:setTextLeftSpeed("所需0真气")
end

function addMeridianImprintingDebugLayer:setTextRightSpeed()
    self.__ui:setTextRightSpeed("所需0真气")
end

function addMeridianImprintingDebugLayer:setButtonLeft()
    self.__ui:setButtonLeft("添加印记",function()
        if self.__selectId == nil then
            PopText("请选择需添加的经脉印记")
            return
        end

        self:addMeridianImprinting()
    end)
end

function addMeridianImprintingDebugLayer:setButtonRight()
    self.__ui:setButtonRight("添加印记",function()
        if self.__selectId == nil then
            PopText("请选择需添加的经脉印记")
            return
        end

        self:addMeridianImprinting()
    end)
end

function addMeridianImprintingDebugLayer:addMeridianImprinting()
    self.__meridianSys:addMeridianImprinting(self.__selectId)

    self.__role:updateRoleBuff()

    self.__selectId = nil

    self:setTextLeftName()

    self:setTextRightName()

    self:initLeftListView()

    self:initRightListView()

    self:refreshImprintingDetail()

    PopText("添加印记成功")
end

function addMeridianImprintingDebugLayer:refreshImprintingDetail()
    if self.__selectId == nil then
        self.__ui:hideImprintingDetail()
    else
        self.__ui:showImprintingDetail()

        local changeImprinting = MeridianResources:getMeridianImprintingRes(self.__selectId)

        local retData = {
            name = changeImprinting:getName(),
            type = changeImprinting:getType(),
            text = changeImprinting:getText(),
        }

        self.__ui:setImprintingDetail(retData)
    end
end

Helper:classDefNodeGetInstance(addMeridianImprintingDebugLayer)
return addMeridianImprintingDebugLayer
0000