local class = require("third.class.NewClass")
local SmithyActionPresenter = {}

function SmithyActionPresenter:create(SmithyActionView,SmithyActionModel)
    local p = SmithyActionPresenter:new()
    p:init(SmithyActionView,SmithyActionModel)
    return p
end

function SmithyActionPresenter:init(SmithyActionView,SmithyActionModel)
    self.__input = SmithyActionModel
    self.__output = SmithyActionView
end

function SmithyActionPresenter:setRole(role)
    self.__input:setRole(role)
end

function SmithyActionPresenter:showLayer()
    self.__input:getActionInfo(function()
        self.__output:showLayer(function()
            self.__output:showUI()
            self:__initUI()
        end)
    end)

    self:__setRuleFunc()

    self.__output:setButtonBack(function()
        self.__output:hideLayer(function()
            self.__output:hideUI()
        end)
    end)
end

function SmithyActionPresenter:__initUI()
    self.__output:setTextTitle(self.__input:getActionName())
    self.__output:setTextDesc(self.__input:getActionDesc())

    self.__output:setText_3Str("当前乐器神兵淬炼次数："..tostring(self.__input:getCuiLianCount().."次"))

    self.__output:setText_3StrColor(cc.c3b(255,255,255))

    self:__initList()
end

function SmithyActionPresenter:__initList()
    local rewardList = self.__input:getRewardList()

    for k,rewardInfo in ipairs(rewardList) do
        rewardInfo.func = function()
            if self.__input:checkStateIsReward(rewardInfo.state) then
                local isBagEnough = self.__input:checkBagCanGetReward(rewardInfo.rewards)
                local isEmail = isBagEnough == true and 0 or 1
                self.__input:doReward(rewardInfo.rid, isEmail,function()
                    self.__input:getActionInfo(function()
                        self:__initList()
                    end)
                end)
            end
        end
    end
    
    self.__output:showListView(rewardList)
end

function SmithyActionPresenter:initRule(ruleInfo)
	self.__ruleInfo = ruleInfo
end

function SmithyActionPresenter:__setRuleFunc()
	self.__output:setButtonRuleFunc(function()
        self:__showRule()
    end)
end

function SmithyActionPresenter:__showRule()
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

return class("SmithyActionPresenter", {}, SmithyActionPresenter)

00