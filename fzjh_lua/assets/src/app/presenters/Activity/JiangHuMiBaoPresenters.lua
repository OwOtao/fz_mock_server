local JiangHuMiBaoPresenters = class("JiangHuMiBaoPresenters", cc.Layer)

function JiangHuMiBaoPresenters:create()
    local p = JiangHuMiBaoPresenters:new()
    p:init()
    return p
end

function JiangHuMiBaoPresenters:init()
    self._actionUI = require("app.views.ui.ActionUI.JiangHuMiBaoUI"):create()

    self._actionUI:addTo(self)

    local JiangHuMiBao = require("app.models.Action.JiangHuMiBao")

    self._actionUI:setButtonBack(
        function()
            self:hideLayer()
        end
    )

    self:__setRuleFunc()

    self._interactor = JiangHuMiBao:create()
end

function JiangHuMiBaoPresenters:showLayer()
    self._role = User:getRole()

    self._interactor:setRole(self._role)
    
    self:__initData()

    self._time = GetTime()

    self._interactor:setAfterRewardCallback(function()
        self._interactor:init(function()
            self._actionUI:showListView(self._interactor:getMiBaoInfo())
        end)
    end)
end

function JiangHuMiBaoPresenters:setActionId(actionId)
    self._interactor:setActionId(actionId)
end

function JiangHuMiBaoPresenters:__initData()
    self._interactor:init(
        function()
            self._actionUI:setTextTitle(self._interactor:getActionName())

            self._actionUI:setDesc(self._interactor:getActionDesc())

            self._actionUI:showListView(self._interactor:getMiBaoInfo())

            self._actionUI:showUI()

            self:__update()
        end
    )
end

function JiangHuMiBaoPresenters:hideLayer()
    PopupLayerController:hideLayer(
        "JiangHuMiBaoPresenters",
        function(layer)
            self._actionUI:hideUI()
        end
    )
end

function JiangHuMiBaoPresenters:__update()
    self._endTime = self._interactor:getEndTime()

    if self._schedule then
        self._actionUI:unschedule(self._schedule)
        self._schedule = nil
    end

    self._schedule = self._actionUI:schedule(
        function()
            local nowTime = GetTime()

            if nowTime > self._endTime then
                self._actionUI:unschedule(self._schedule)
                self._schedule = nil
                return
            end

            if Helper:diffWithDate(self._time,nowTime) ~= 0 then
                self._interactor:init(function()
                    self._actionUI:showListView(self._interactor:getMiBaoInfo())
                end)
                self._time = GetTime()
            end
        end,0.1)
end

function JiangHuMiBaoPresenters:initRule(ruleInfo)
	self.__ruleInfo = ruleInfo
end

function JiangHuMiBaoPresenters:__setRuleFunc()
	self._actionUI:setButtonRuleFunc(function()
        self:__showRule()
    end)
end

function JiangHuMiBaoPresenters:__showRule()
	PopupLayerController:showLayer("ActionRuleUI",function(layer)
        layer:showUI()
        layer:setTextTitle("活动规则")
        layer:showPanel_1(self.__ruleInfo)
        layer:setButtonBack(function()
            PopupLayerController:hideLayer("ActionRuleUI",function(layer)
                layer:hideUI()
            end)
        end)
    end)
end

Helper:classDefNodeGetInstance(JiangHuMiBaoPresenters)

return JiangHuMiBaoPresenters
000000000000