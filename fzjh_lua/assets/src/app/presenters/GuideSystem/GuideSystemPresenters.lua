local GuideSystemPresenters = class("GuideSystemPresenters", cc.Layer)

function GuideSystemPresenters:create()
    local p = GuideSystemPresenters:new()
    p:init()
    return p
end

function GuideSystemPresenters:init()
    self._actionUI = require("app.views.ui.GuideSystemUI.GuideSystemUI"):create()

    self._actionUI:addTo(self)

    self._actionUI:setButtonBackFunc(function()
        self._actionUI:hideUI()
        self:hideLayer()
    end)

    self._actionUI:setPanelInfoFunc()

    self._actionUI:setPointVisible(false)

    local GuideSystem = require("app.models.GuideSystem.GuideSystem")

    self._interactor = GuideSystem:create()

    self._titleType = 1  -- 1 是所有 2 是进行中 3 是所有
end

function GuideSystemPresenters:showLayer()
    self._role = User:getRole()
    
    self._interactor:setRole(self._role)
    
    self:__initData()
end 

function GuideSystemPresenters:__initData()
    self._interactor:init(
        function()
            self:setTitleName(self._interactor:getName())
            self:setPoint(self._interactor:getPoint())
            self:showListInfos()
            self:setTitle_1Func()
            self:setTitle_2Func()
            self:setTitle_3Func()
            self._actionUI:showUI()
        end
    )
end

function GuideSystemPresenters:hideLayer()
    PopupLayerController:hideLayer(
        "GuideSystemPresenters",
        function(layer)
            self._actionUI:hideUI()
        end
    )
end

function GuideSystemPresenters:setTitleName(name)
    self._actionUI:setTitleName(name)
end

function GuideSystemPresenters:setPoint(point)
	self._actionUI:setPoint(point)
end

function GuideSystemPresenters:setTipsVisible(visible)
	self._actionUI:setTipsVisible(visible)
end

function GuideSystemPresenters:setTitle_1Func()
    self._actionUI:setTitle_1Func(function()
        self._titleType = 1
        self:showListInfos()
    end)
end

function GuideSystemPresenters:setTitle_2Func()
    self._actionUI:setTitle_2Func(function()
        self._titleType = 2
        self:showListInfos()
    end)
end

function GuideSystemPresenters:setTitle_3Func()
    self._actionUI:setTitle_3Func(function()
        self._titleType = 3
        self:showListInfos()
    end)
end

function GuideSystemPresenters:refreshUI()
    self:setPoint(self._interactor:getPoint())
    self:showListInfos()
end

function GuideSystemPresenters:showListInfos()
    local list
    if self._titleType == 1 then
        list = self._interactor:getAllList()
        
        if MapIsEmpty(list) == false then
            for k,v in pairs(list) do
                v.func_1 = function()
                    self._actionUI:setPanelInfoVisible(true)
                    self._actionUI:setPanelInfoDescText(v.desc)
                    self._actionUI:setPanelInfoNameText(v.title)
                end
    
                v.func_2 = function()
                    if v.state == 0 then
                        self._interactor:acceptTask(v.id,function()
                            self._interactor:init(function()
                                self:refreshUI()
                            end)
                        end)
                    elseif v.state == 1 then
                        PopupLayerController:showLayer("BiLuPresenters",function(layer)
                            layer:setTitleName(v.title)
                            layer:setTaskId(v.taskId)
                            layer:showLayer()
                        end)
                    elseif v.state == 2 then
                        self._interactor:finishTask(v.id,function()
                            self._interactor:init(function()
                                self:refreshUI()
                            end)
                        end)
                    end
                end
            end
        end
    elseif self._titleType == 2 then
        list = self._interactor:getCurrList()
        
        if MapIsEmpty(list) == false then
            for k,v in pairs(list) do
                v.func_1 = function()
                    self._actionUI:setPanelInfoVisible(true)
                    self._actionUI:setPanelInfoDescText(v.desc)
                    self._actionUI:setPanelInfoNameText(v.title)
                end
    
                v.func_2 = function()
                    if v.state == 1 then
                        PopupLayerController:showLayer("BiLuPresenters",function(layer)
                            layer:setTitleName(v.title)
                            layer:setTaskId(v.taskId)
                            layer:showLayer()
                        end)
                    elseif v.state == 2 then
                        self._interactor:finishTask(v.id,function()
                            self._interactor:init(function()
                                self:refreshUI()
                            end)
                        end)
                    end
                end
            end
        end
    elseif self._titleType == 3 then
        list = self._interactor:getFinishList()
        if MapIsEmpty(list) == false then
            for k,v in pairs(list) do
                v.func_1 = function()
                    self._actionUI:setPanelInfoVisible(true)
                    self._actionUI:setPanelInfoDescText(v.desc)
                    self._actionUI:setPanelInfoNameText(v.title)
                end
    
                v.func_2 = function()
                end
            end 
        end
    end

    local sort_index = {['2'] = 1,['0'] = 2,['1'] = 3,['3'] = 4}

    table.sort(list, function (a,b)
        if sort_index[tostring(a.state)] < sort_index[tostring(b.state)] then
            return true
        elseif sort_index[tostring(a.state)] > sort_index[tostring(b.state)] then
            return false
        else
            local index_a = string.gsub( a.id,"group","" )
            local index_b = string.gsub( b.id,"group","" )
            if tonumber(index_a) < tonumber(index_b) then
                return false
            else
                return true
            end
        end
    end)
    
    if MapIsEmpty(list) == false then
        self._actionUI:showInfos(list)
        self._actionUI:setTipsVisible(false) 
    else
        self._actionUI:showInfos()
        self._actionUI:setTipsVisible(true) 
    end
end

Helper:classDefNodeGetInstance(GuideSystemPresenters)

return GuideSystemPresenters
000000000