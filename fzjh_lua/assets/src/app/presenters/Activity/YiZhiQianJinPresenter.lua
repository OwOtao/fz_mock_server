local YiZhiQianJinPresenter = class("YiZhiQianJinPresenter", cc.Layer)

function YiZhiQianJinPresenter:create()
    local p = YiZhiQianJinPresenter:new()
    p:init()
    return p
end

function YiZhiQianJinPresenter:init()
    self.__actionUI = require("app.views.ui.ActionUI.YuanBaoConsumeActionUI"):create()

    self.__actionUI:addTo(self)

    self.__actionUI:setButtonBack(
        function()
            self:hideLayer()
        end
    )

    self:__setRuleFunc()

    local YiZhiQianJin = require("app.models.Action.YiZhiQianJin")

    self.__interactor = YiZhiQianJin:create()
end

function YiZhiQianJinPresenter:showLayer()
    self.__showRewardIndex = 1
    self.__interactor:setRole(User:getRole())
    self.__interactor:init(
        function()
            self:__initUI(function()
                self.__actionUI:showUI()
            end)
        end
    )
end

function YiZhiQianJinPresenter:hideLayer()
    PopupLayerController:hideLayer(
        "YiZhiQianJinPresenter",
        function(layer)
            self.__actionUI:hideUI()
        end
    )
end

function YiZhiQianJinPresenter:__initUI(func)
    self.__actionUI:setHelp1Text("点击奖励可查看道具详情")

    self.__actionUI:setHelp2Text("点击左右箭头查看其他奖励")

    self.__actionUI:setTextTitle(self.__interactor:getActionName())

    self.__actionUI:setDesc(self.__interactor:getActionDesc())

    self.__actionUI:setRightBtnFunc(function()
        self:__initRightPanelInfo()
    end)

    self.__actionUI:setLeftBtnFunc(function()
        self:__initLeftPanelInfo()
    end)

	self.__actionUI:setButtonPayFunc(function()
		MainControllLayer:pushLayer("StoreLayer")
		local StoreLayer = MainControllLayer:getLayer("StoreLayer")
		StoreLayer:showWithAction(function()
			PopupLayerController:showLayer("YiZhiQianJinPresenter",function(layer)
				layer:showLayer()
                layer:initRule(self.__ruleInfo)
			end)
		end)
		self:hideLayer()
	end)

    self:__initNowPanelInfo()

    if func then
        func()
    end
end

function YiZhiQianJinPresenter:__initNowPanelInfo()
    local list = self.__interactor:getList()

    if MapIsEmpty(list) == false then
        local info = list[self.__showRewardIndex]

        local uiInfo = {}

        for i, v in ipairs(info.reward) do
            table.insert(uiInfo, self:__getGoodsUIInfo(v))
        end

        self:__initPanelInfo(info)
        self.__actionUI:initNowPanelInfo(uiInfo)
        self.__actionUI:setHongDianVisible(info.state == 1)
    end
end

function YiZhiQianJinPresenter:__initLeftPanelInfo()
    if self.__showRewardIndex == 1 then
        return
    end

    self.__showRewardIndex = self.__showRewardIndex - 1
    local list = self.__interactor:getList()

    if MapIsEmpty(list) == false then
        local info = list[self.__showRewardIndex]

        local uiInfo = {}

        for i, v in ipairs(info.reward) do
            table.insert(uiInfo, self:__getGoodsUIInfo(v))
        end

        self:__initPanelInfo(info)
        self.__actionUI:initNextPanelInfo(uiInfo)
        self.__actionUI:switchNextByLeft()
        self.__actionUI:setHongDianVisible(info.state == 1)
    end
end

function YiZhiQianJinPresenter:__initRightPanelInfo()
    local list = self.__interactor:getList()

    if MapIsEmpty(list) == false then
        if self.__showRewardIndex == #list then
            return
        end

        self.__showRewardIndex = self.__showRewardIndex + 1

        local info = list[self.__showRewardIndex]
        
        local uiInfo = {}

        for i, v in ipairs(info.reward) do
            table.insert(uiInfo, self:__getGoodsUIInfo(v))
        end

        self:__initPanelInfo(info)
        self.__actionUI:initNextPanelInfo(uiInfo)
        self.__actionUI:switchNextByRight()
        self.__actionUI:setHongDianVisible(info.state == 1)
    end
end

function YiZhiQianJinPresenter:__initPanelInfo(info)
    if MapIsEmpty(info) == false then
        self.__actionUI:setLoadingBarText(tostring(self.__interactor:getSpendNum()).."/"..tostring(info.tier_amount))
        self.__actionUI:setLoadingBarPercent(self.__interactor:getSpendNum() / info.tier_amount * 100)
        self.__actionUI:setTipsText("累计消耗"..tostring(info.tier_amount).."元宝即可获得以下奖励")
        self.__actionUI:setRewardBtnTouchEnable(true)
 
        if self.__interactor:checkStateIsGetReward(info.state) then
            self.__actionUI:setRewardBtnName("已领取")
        else
            self.__actionUI:setRewardBtnName("领取")
        end

        self.__actionUI:setRewardBtnFunc(function()
            if self.__interactor:checkStateIsUnlock(info.state) then
                PopText("未消耗足够元宝")
                return
            end

            if self.__interactor:checkStateIsGetReward(info.state) then
                PopText("已领取该档位奖励")
                return
            end

            local isBagEnough = self.__interactor:checkCanGetReward(info.reward)
            local isEmail = isBagEnough == true and 0 or 1

            self.__interactor:doReward(info.rid, isEmail, function()
                self.__interactor:init(
                    function()
                        self:__initNowPanelInfo()
                    end
                )
            end)
        end)
    end
end

function YiZhiQianJinPresenter:__getGoodsUIInfo(goodsInfo)
    local goods = self.__interactor:getGoodsInfo(goodsInfo.id)
    local name = goods:getName()
    local icon = goods:getIcon()
    local number = goodsInfo.num
    local func = function()
        PopupLayerController:showLayer("GoodsInfoMainPresenter",function(layer)
            layer:showLayer({{id = goodsInfo.id}})
        end)
    end

    return {name = name, icon = icon, number = number, func = func}
end

function YiZhiQianJinPresenter:initRule(ruleInfo)
	self.__ruleInfo = ruleInfo
end

function YiZhiQianJinPresenter:__setRuleFunc()
	self.__actionUI:setButtonRuleFunc(function()
        self:__showRule()
    end)
end

function YiZhiQianJinPresenter:__showRule()
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

Helper:classDefNodeGetInstance(YiZhiQianJinPresenter)

return YiZhiQianJinPresenter
0000000000000000