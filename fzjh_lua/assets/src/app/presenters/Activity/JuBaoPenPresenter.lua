local JuBaoPenPresenter = class("JuBaoPenPresenter", cc.Layer)

function JuBaoPenPresenter:create()
    local p = JuBaoPenPresenter:new()
    p:init()
    return p
end

function JuBaoPenPresenter:init()
    self._actionUI = require("app.views.ui.ActionUI.XiangNangMiGeUI"):create()

    self._actionUI:addTo(self)

    self._selectRewardUI = require("app.views.ui.ActionUI.RewardSelectUI"):create()

    self._selectRewardUI:addTo(self)

    self._selectRewardUI:hideUI()

    self:__setRuleFunc()

    local JuBaoPen = require("app.models.Action.JuBaoPen")

    self._interactor = JuBaoPen:create()

    self._actionUI:setButtonBack(
        function()
            self:hideLayer()
        end
    )

    self._selectRewardUI:setButtonBack(
        function()
            self._selectRewardUI:hideUI()
        end
    )
end

function JuBaoPenPresenter:showLayer()
    self._role = User:getRole()

    self._interactor:setRole(self._role)
    
    self:__initData()

    self._interactor:setAfterRewardCallback(function()
        self._interactor:init(
            function()
                self:__initUI()
            end
        )
    end)
end

function JuBaoPenPresenter:setActionId(actionId)
    self._interactor:setActionId(actionId)
end

function JuBaoPenPresenter:__initData()
    self._interactor:init(
        function()
            self:__initUI()

            self._actionUI:showUI()
        end
    )
end

function JuBaoPenPresenter:__initUI()
    self._actionUI:setTextTitle(self._interactor:getActionName())

    self._actionUI:setDesc(self._interactor:getActionDesc())

    self._actionUI:setText1("累计充值："..self._interactor:getCurrencyNum().."元")

    self._actionUI:setButtonName("去充值")

    self._actionUI:setButtonInfoFunc(function()
        MainControllLayer:pushLayer("StoreLayer")
		local StoreLayer =MainControllLayer:getLayer("StoreLayer")
		StoreLayer:showWithAction(function()
			self:__initData()
		end)
		self._actionUI:hideUI()
    end)

    local listData = self._interactor:getRewardLevelList()
    for __,itemInfo in pairs(listData) do
        local text = ""
        if self._interactor:checkRewardTypeIsSelect(itemInfo.rewardType) == false or self._interactor:checkStateIsRewarded(itemInfo.state) then
            if MapIsEmpty(itemInfo.rewardIdList) == false then
                for k, rewardId in pairs(itemInfo.rewardIdList) do
                    local rewards = self._interactor:getRewardById(rewardId)
                    for __, reward in pairs(rewards) do
                        text = text .. reward.name .. "X" ..reward.number ..","
                    end
                end

                text = string.sub(text, 1, -2)
            end
        else
            text = "内含多种组合奖励，请点击右方按钮进入多选奖励界面，选择所需奖励"
        end

        itemInfo.text = "累计充值" .. tostring(itemInfo.needMoney) .. "元\n" .. text
        itemInfo.loadTexture = "Image/UI/TaskUI/anniu.png"
        itemInfo.btnName = "领取"

        if self._interactor:checkRewardTypeIsSelect(itemInfo.rewardType) then
            itemInfo.btnName = "进入"
        end

        if self._interactor:checkStateIsRewarded(itemInfo.state) then
            itemInfo.btnName = "已领取"
            itemInfo.loadTexture = "Image/UI/TaskUI/anniuhui.png"
        end

        itemInfo.func = function()
            if self._interactor:checkStateIsRewarded(itemInfo.state) then
                PopText("奖励已领取")
                return
            end

            if self._interactor:checkRewardTypeIsSelect(itemInfo.rewardType) then
                self._selectRewardUI:setText2("累计充值："..self._interactor:getCurrencyNum().."元")
                local rewardIds = itemInfo.rewardIdList
                if MapIsEmpty(rewardIds) == false then
                    local rewards = {}

                    for i = 1, #rewardIds do
                        local rewardInfo = {}

                        local rewardList = self._interactor:getRewardById(rewardIds[i])
                        local text = ""
                        for __, reward in pairs(rewardList) do
                            text = text .. reward.name .. "X" ..reward.number ..","
                        end
                        text = string.sub(text, 1, -2)

                        rewardInfo.text = text
                        rewardInfo.btnName = "领取"
                        rewardInfo.loadTexture = "Image/UI/MapUI/anniu05.png"
                        rewardInfo.func = function()
                            if self._interactor:checkStateIsReward(itemInfo.state) == false then
                                PopText("还没达到领取条件")
                                return
                            end

                            local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
                            local dialog = DialogALayer:getInstance()
                            dialog:show("是否确定领取选中奖励", text)
                            dialog:setButton1("确定", function()
                                self:__doReward(itemInfo.id, rewardIds[i])
                            end)
                        
                            dialog:setButton2("取消", function()
                                dialog:hide()
                            end)
                        
                            dialog:setWeChatVisible(false)
                        end

                        table.insert(rewards, rewardInfo)
                    end
                    self._selectRewardUI:showListView(rewards)
                    self._selectRewardUI:showUI()
                else
                    error("当前档位奖励错误！ 档位id:"..tostring(itemInfo.rewardLevel))
                end
            else
                if self._interactor:checkStateIsReward(itemInfo.state) == false then
                    PopText("还没达到领取条件")
                    return
                end

                self:__doReward(itemInfo.id, itemInfo.rewardIdList[1])
            end
        end
    end

    self._actionUI:showListView(listData)
end

function JuBaoPenPresenter:__doReward(id, rewardId)
    local rewards = self._interactor:getRewardById(rewardId)
    local isEmail = self._interactor:checkBagIsEnough(rewards) == true and 1 or 0
    self._interactor:doReward(id, rewardId, isEmail,function()
        self._selectRewardUI:hideUI()
        self._interactor:init(
            function()
                self:__initUI()
            end
        )
    end)
end

function JuBaoPenPresenter:hideLayer()
    PopupLayerController:hideLayer(
        "JuBaoPenPresenter",
        function(layer)
            self._actionUI:hideUI()
        end
    )
end

function JuBaoPenPresenter:initRule(ruleInfo)
	self.__ruleInfo = ruleInfo
end

function JuBaoPenPresenter:__setRuleFunc()
	self._actionUI:setButtonRuleFunc(function()
        self:__showRule()
    end)
end

function JuBaoPenPresenter:__showRule()
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

Helper:classDefNodeGetInstance(JuBaoPenPresenter)

return JuBaoPenPresenter
00000000