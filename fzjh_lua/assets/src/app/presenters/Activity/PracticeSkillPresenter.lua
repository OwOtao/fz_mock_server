local PracticeSkillPresenter = class("PracticeSkillPresenter", cc.Layer)

function PracticeSkillPresenter:create()
    local p = PracticeSkillPresenter:new()
    p:init()
    return p
end

function PracticeSkillPresenter:init()
    self.__output = require("app.views.ui.ActionUI.WakeUpActionUI"):create()

    self.__output:addTo(self)

    self:__setRuleFunc()

    self.__input = require("app.models.Action.PracticeOfSkill"):create()

    self.__output:setButtonBack(function()
        self.__output:hideUI()
    end)

    self._showListType = 1
end

function PracticeSkillPresenter:setActionId(actionId)
    self.__input:setActionId(actionId)

    self.__input:setSkillId(actionId)
end

function PracticeSkillPresenter:showLayer()
    self.__input:setRole(User:getRole())

    self._showListType = 1
    
    self.__input:getActionInfo(function()
        self:__initUI()
        self.__output:showUI()
    end)
end

function PracticeSkillPresenter:__initUI()
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

    self.__output:setText_2Str("解锁"..name2)

    if self._showListType == 1 then
        self:__showList_1(id1)
    else
        self:__showList_2(id2)
    end

    local skillLv = self.__input:getSkillLv()
    if skillLv == 0 then
        self.__output:setText_1Str(self.__input:getSkillName().."未领悟")
    else
        self.__output:setText_1Str(self.__input:getSkillName().."等级："..tostring(self.__input:getSkillLv()).."级")
    end

    local isUnlock = self.__input:getGoodsIsUnlock()

    if isUnlock == true then
        self.__output:setButton_1Name("已解锁")
        self.__output:setButton_1Texture("Image/UI/TaskUI/anniuhui.png")
    else
        self.__output:setButton_1Name(self.__input:getGoodsText())
        self.__output:setButton_1Texture("Image/UI/TaskUI/anniu.png")
    end

    self.__output:setButton_1Func(function()
        if isUnlock == false then
            local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
            local dialog = DialogALayer:getInstance()
            dialog:show("是否消耗"..self.__input:getGoodsText().."解锁"..name2)
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

function PracticeSkillPresenter:__showList_1(id)
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

function PracticeSkillPresenter:__showList_2(id)
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

function PracticeSkillPresenter:__showListView(list)
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

function PracticeSkillPresenter:initRule(ruleInfo)
	self.__ruleInfo = ruleInfo
end

function PracticeSkillPresenter:__setRuleFunc()
	self.__output:setButtonRuleFunc(function()
        self:__showRule()
    end)
end

function PracticeSkillPresenter:__showRule()
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

Helper:classDefNodeGetInstance(PracticeSkillPresenter)

return PracticeSkillPresenter

00000000