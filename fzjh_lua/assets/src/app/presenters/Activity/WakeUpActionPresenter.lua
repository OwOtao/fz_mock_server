local WakeUpActionPresenter = class("WakeUpActionPresenter", cc.Layer)

function WakeUpActionPresenter:create()
    local p = WakeUpActionPresenter:new()
    p:init()
    return p
end

function WakeUpActionPresenter:init()
    self.__output = require("app.views.ui.ActionUI.WakeUpActionUI"):create()

    self.__output:addTo(self)

    self:__setRuleFunc()

    self.__input = require("app.models.Action.WakeUpAction"):create()

    self.__output:setButtonBack(function()
        self.__output:hideUI()
    end)

    self._showListType = 1
end

function WakeUpActionPresenter:setActionId(actionId)
    self.__input:setActionId(actionId)
end

function WakeUpActionPresenter:showLayer()
    self.__input:setRole(User:getRole())

    self._showListType = 1
    
    self.__input:getActionInfo(function()
        self:__initUI()
        self.__output:showUI()
    end)
end

function WakeUpActionPresenter:__initUI()
    self.__output:setTextTitle(self.__input:getActionName())
    self.__output:setDesc(self.__input:getActionDesc())

    local id1 , name1 = self.__input:getRewardFisrtTypeIdAndName()
    local id2 , name2 = self.__input:getRewardSecondTypeIdAndName()

    self.__output:setTitle_1Name(name1)

    self.__output:setTitle_2Name(name2)

    self.__output:setTitle_1Func(function()
        self:__showList_1(id1)
        self._showListType = 1
    end)

    self.__output:setTitle_2Func(function()
        local isUnlock = self.__input:getGoodsIsUnlock()
        if isUnlock == false then
            PopText("需要解锁"..name2.."才可进行领取。")
        end

        self:__showList_2(id2)
        self._showListType = 2
    end)

    if self._showListType == 1 then
        self:__showList_1(id1)
    else
        self:__showList_2(id2)
    end

    self.__output:setText_1Str("当前梦境达到最高层数："..tostring(self.__input:getFloor().."层"))

    local isUnlock = self.__input:getGoodsIsUnlock()

    if isUnlock == true then
        self.__output:setButton_1Name("已解锁")
        self.__output:setButton_1Texture("Image/UI/TaskUI/anniuhui.png")
    else
        self.__output:setButton_1Name(self.__input:getGoodsPrice()..self.__input:getGoodsCurrencyName())
        self.__output:setButton_1Texture("Image/UI/TaskUI/anniu.png")
    end

    self.__output:setButton_1Func(function()
        if isUnlock == false then
            local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
            local dialog = DialogALayer:getInstance()
            dialog:show("是否消耗"..self.__input:getGoodsPrice()..self.__input:getGoodsCurrencyName().."解锁"..name2)
            dialog:setButton1("确定", function()
                self.__input:unlockReward(function()
                    self.__input:getActionInfo(function()
                        self:__initUI()
                    end)
                end)
            end)

            dialog:setButton2("取消", function()
                dialog:hide()
            end)

            dialog:setWeChatVisible(false)
        else
            PopText("已购买【"..name2.."】，不能重复购买")
        end
    end)
end

function WakeUpActionPresenter:__showList_1(id)
    self.__output:setTitle_1TextColor(cc.c3b(255,255,255))
    self.__output:setTitle_2TextColor(cc.c3b(208,208,208))
    self.__output:setTitle_1BackGroundColorOpacity(255)
    self.__output:setTitle_2BackGroundColorOpacity(0)
    self.__output:setTitle_1Visible(true)
    self.__output:setTitle_2Visible(false)
    self.__output:setTitle_1Enable(false)
    self.__output:setTitle_2Enable(true)

    self:__showListView(self.__input:getListByTypeId(id))
end

function WakeUpActionPresenter:__showList_2(id)
    self.__output:setTitle_2TextColor(cc.c3b(255,255,255))
    self.__output:setTitle_1TextColor(cc.c3b(208,208,208))
    self.__output:setTitle_1BackGroundColorOpacity(0)
    self.__output:setTitle_2BackGroundColorOpacity(255)
    self.__output:setTitle_2Visible(true)
    self.__output:setTitle_1Visible(false)
    self.__output:setTitle_2Enable(false)
    self.__output:setTitle_1Enable(true)

    self:__showListView(self.__input:getListByTypeId(id))
end

function WakeUpActionPresenter:__showListView(list)
    if MapIsEmpty(list) == false then
        for k,rewardInfo in ipairs(list) do
            rewardInfo.func = function()
                if self.__input:checkStateIsReward(rewardInfo.state) then
                    local isBagEnough = self.__input:checkBagCanGetReward(rewardInfo.rewards)
                    local isEmail = isBagEnough == true and 0 or 1
                    self.__input:doReward(rewardInfo.rid, isEmail,function()
                        self.__input:getActionInfo(function()
                            local id1 , name1 = self.__input:getRewardFisrtTypeIdAndName()
                            local id2 , name2 = self.__input:getRewardSecondTypeIdAndName()
                            if self._showListType == 1 then
                                self:__showList_1(id1)
                            else
                                self:__showList_2(id2)
                            end
                        end)
                    end)
                end
            end
        end
        
        self.__output:showListView(list)
    end
end

function WakeUpActionPresenter:initRule(ruleInfo)
	self.__ruleInfo = ruleInfo
end

function WakeUpActionPresenter:__setRuleFunc()
	self.__output:setButtonRuleFunc(function()
        self:__showRule()
    end)
end

function WakeUpActionPresenter:__showRule()
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

Helper:classDefNodeGetInstance(WakeUpActionPresenter)

return WakeUpActionPresenter

0000000000000000