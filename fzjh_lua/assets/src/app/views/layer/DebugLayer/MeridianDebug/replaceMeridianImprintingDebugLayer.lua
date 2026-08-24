local MeridianResources = require("app.models.Meridian.MeridianResources")

local replaceMeridianImprintingDebugLayer = class("replaceMeridianImprintingDebugLayer", cc.Layer)

function replaceMeridianImprintingDebugLayer:create()
    local p = replaceMeridianImprintingDebugLayer:new()
    p:init()
    return p
end

function replaceMeridianImprintingDebugLayer:init()
    self.__ui = require("app.views.ui.SkillUI.MeridianSkillPeiYuanUI"):create()

    self.__ui:addTo(self)
end

function replaceMeridianImprintingDebugLayer:showLayer()
    self.__selectId = nil

    self.__changeId = nil

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

    self.__ui:showUI()
end

function replaceMeridianImprintingDebugLayer:setTitle(text)
    self.__ui:setTitle("印记替换")
end

function replaceMeridianImprintingDebugLayer:setButtonBack()
    self.__ui:setButtonBack(
        function()
            PopupLayerController:hideLayer("replaceMeridianImprintingDebugLayer",function()
                self.__ui:hideUI()
            end)
        end
    )
end

function replaceMeridianImprintingDebugLayer:setTextLeftName()
    local text = ""
    if self.__selectId then
        local imprinting = MeridianResources:getMeridianImprintingRes(self.__selectId)

        text = imprinting:getName()
    end
    
    self.__ui:setTextLeftName(text)
end

function replaceMeridianImprintingDebugLayer:setTextRightName()
    local text = ""
    if self.__changeId then
        local imprinting = MeridianResources:getMeridianImprintingRes(self.__changeId)

        text = imprinting:getName()
    end
    
    self.__ui:setTextRightName(text)
end

function replaceMeridianImprintingDebugLayer:initLeftListView()
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
            self.__selectId = v:getImprintingId()

            self:setTextLeftName()
        end

        table.insert(retArray, retTab)
    end

    self.__ui:setLeftListView(retArray)
end

function replaceMeridianImprintingDebugLayer:initRightListView()
    local array = {}

    local allImprResList = MeridianResources:getAllMeridianImprintingRes()
    for i, v in ipairs(allImprResList) do
        if not self.__meridianSys:currPageHasMeridianImprinting(v:getImprintingId()) then
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
            self.__changeId = v:getImprintingId()

            self:setTextRightName()

            self:setTextLeftSpeed()

            self:setTextRightSpeed()

            self:refreshImprintingDetail()
        end

        table.insert(retArray, retTab)
    end

    self.__ui:setRightListView(retArray)
end

function replaceMeridianImprintingDebugLayer:setTextLeftSpeed()
    self.__ui:setTextLeftSpeed("所需0真气")
end

function replaceMeridianImprintingDebugLayer:setTextRightSpeed()
    self.__ui:setTextRightSpeed("所需0真气")
end

function replaceMeridianImprintingDebugLayer:setButtonLeft()
    self.__ui:setButtonLeft("印记替换",function()
        if self.__selectId == nil then
            PopText("请选择需更换的经脉印记")
            return
        end

        if self.__changeId == nil then
            PopText("请选择更换的目标印记")
            return
        end
        
        self:replaceMeridianImprinting()
    end)
end

function replaceMeridianImprintingDebugLayer:setButtonRight()
    self.__ui:setButtonRight("印记替换",function()
        if self.__selectId == nil then
            PopText("请选择需更换的经脉印记")
            return
        end

        if self.__changeId == nil then
            PopText("请选择更换的目标印记")
            return
        end
        
        self:replaceMeridianImprinting()
    end)
end

function replaceMeridianImprintingDebugLayer:replaceMeridianImprinting()
    self.__meridianSys:replaceMeridianImprinting(self.__meridianSys:getCurrUsingMeridianImprintingPageNumber(), self.__selectId, self.__changeId)

    self.__role:updateRoleBuff()

    self.__selectId = nil

    self.__changeId = nil

    self:setTextLeftName()

    self:setTextRightName()

    self:initLeftListView()

    self:initRightListView()

    self:refreshImprintingDetail()

    PopText("印记替换成功")
end

function replaceMeridianImprintingDebugLayer:refreshImprintingDetail()
    if self.__changeId == nil then
        self.__ui:hideImprintingDetail()
    else
        self.__ui:showImprintingDetail()

        local changeImprinting = MeridianResources:getMeridianImprintingRes(self.__changeId)

        local retData = {
            name = changeImprinting:getName(),
            type = changeImprinting:getType(),
            text = changeImprinting:getText(),
        }

        self.__ui:setImprintingDetail(retData)
    end
end

Helper:classDefNodeGetInstance(replaceMeridianImprintingDebugLayer)
return replaceMeridianImprintingDebugLayer
0000000