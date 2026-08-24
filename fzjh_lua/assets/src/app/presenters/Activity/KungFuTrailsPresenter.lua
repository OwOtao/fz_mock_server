local KungFuTrailsPresenter = class("KungFuTrailsPresenter", cc.Layer)

function KungFuTrailsPresenter:create()
    local p = KungFuTrailsPresenter:new()
    p:init()
    return p
end

function KungFuTrailsPresenter:init()
    self._actionUI = require("app.views.ui.ActionUI.KungFuTrailsUI"):create()

    self._actionUI:addTo(self)

    self:__setRuleFunc()

    self._interactor = require("app.models.Action.KungFuTrails"):create()

    self._actionUI:setButtonBack(
        function()
            self:hideLayer()
        end
    )
end

function KungFuTrailsPresenter:showLayer()
    self._role = User:getRole()

    self._interactor:setRole(self._role)
    
    self:__initData()
end

function KungFuTrailsPresenter:setActionId(actionId)
    self._interactor:setActionId(actionId)
end

function KungFuTrailsPresenter:__initData()
    self._interactor:init(
        function()
            self._showListType = 1

            self:__initUI()

            self._actionUI:showUI()
        end
    )
end

function KungFuTrailsPresenter:__initUI()
    self._actionUI:setTextTitle(self._interactor:getActionName())

    self._actionUI:setDesc(self._interactor:getActionDesc())

    local id1 , name1 = self._interactor:getTaskFisrtTypeIdAndName()
    local id2 , name2 = self._interactor:getTaskSecondTypeIdAndName()

    self._actionUI:setTitle_1Name(name1)

    self._actionUI:setTitle_2Name(name2)

    self._actionUI:setTitle_1Func(function()
        self:__showList_1(id1)
        self._showListType = 1
    end)

    self._actionUI:setTitle_2Func(function()
        self:__showList_2(id2)
        self._showListType = 2
    end)

    if self._showListType == 1 then
        self:__showList_1(id1)
    else
        self:__showList_2(id2)
    end
end

function KungFuTrailsPresenter:__showList_1(id)
    self._actionUI:setTitle_1TextColor(cc.c3b(255,255,255))
    self._actionUI:setTitle_2TextColor(cc.c3b(208,208,208))
    self._actionUI:setTitle_1BackGroundColorOpacity(255)
    self._actionUI:setTitle_2BackGroundColorOpacity(0)
    self._actionUI:setTitle_1Visible(true)
    self._actionUI:setTitle_2Visible(false)
    self._actionUI:setTitle_1Enable(false)
    self._actionUI:setTitle_2Enable(true)

    self:__showListView(self._interactor:getListByTypeId(id))
end

function KungFuTrailsPresenter:__showList_2(id)
    self._actionUI:setTitle_2TextColor(cc.c3b(255,255,255))
    self._actionUI:setTitle_1TextColor(cc.c3b(208,208,208))
    self._actionUI:setTitle_1BackGroundColorOpacity(0)
    self._actionUI:setTitle_2BackGroundColorOpacity(255)
    self._actionUI:setTitle_2Visible(true)
    self._actionUI:setTitle_1Visible(false)
    self._actionUI:setTitle_2Enable(false)
    self._actionUI:setTitle_1Enable(true)

    self:__showListView(self._interactor:getListByTypeId(id))
end

function KungFuTrailsPresenter:__showListView(list)
    if MapIsEmpty(list) == false then
        for i, v in ipairs(list) do
            if self._interactor:checkStateIsReward(v.state) then
                v.loadTexture = "Image/UI/MapUI/anniu05.png"
                v.enable = true
            else
                v.loadTexture = "Image/UI/TeacherUI/anniu_ddfs.png"
                v.enable = false
            end
    
            if self._interactor:checkStateIsRewarded(v.state) then
                v.btnName = "已领取"
            else
                v.btnName = "领取"
            end
    
            v.func = function()
                if self._interactor:checkBagIsEnough(v.taskReward) == true then
                    PopText("背包空间不足，无法领取奖励。")
                    return
                end

                self._interactor:doReward(v.id,function()
                    self._interactor:init(
                        function()
                            self:__initUI()
                        end
                    )
                end)
            end
        end

        self._actionUI:showListView(list)
    end
end


function KungFuTrailsPresenter:hideLayer()
    PopupLayerController:hideLayer(
        "KungFuTrailsPresenter",
        function(layer)
            self._actionUI:hideUI()
        end
    )
end

function KungFuTrailsPresenter:initRule(ruleInfo)
	self.__ruleInfo = ruleInfo
end

function KungFuTrailsPresenter:__setRuleFunc()
	self._actionUI:setButtonRuleFunc(function()
        self:__showRule()
    end)
end

function KungFuTrailsPresenter:__showRule()
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

Helper:classDefNodeGetInstance(KungFuTrailsPresenter)

return KungFuTrailsPresenter
00000000000000