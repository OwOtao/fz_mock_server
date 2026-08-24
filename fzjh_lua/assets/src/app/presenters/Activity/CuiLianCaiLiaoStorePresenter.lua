local CuiLianCaiLiaoStorePresenter = class("CuiLianCaiLiaoStorePresenter", cc.Layer)

function CuiLianCaiLiaoStorePresenter:create()
    local p = CuiLianCaiLiaoStorePresenter:new()
    p:init()
    return p
end

function CuiLianCaiLiaoStorePresenter:init()
    self._actionUI = require("app.views.ui.ActionUI.CuiLianCaiLiaoStoreUI"):create()

    self._actionUI:addTo(self)


    local CuiLianCaiLiaoStore = require("app.models.Action.CuiLianCaiLiaoStore")

    self._actionUI:setButtonBack(
        function()
            self:hideLayer()
        end
    )

    self._actionUI:setBuyPanelVisible(false)

    self:__setRuleFunc()

    self._interactor = CuiLianCaiLiaoStore:create()
end

function CuiLianCaiLiaoStorePresenter:showLayer()
    self._role = User:getRole()

    self._interactor:setRole(self._role)

    self:__initData(function()
        self:__initUI()
        self._actionUI:showUI()
    end)
end

function CuiLianCaiLiaoStorePresenter:setActionId(actionId)
    self._interactor:setActionId(actionId)
end

function CuiLianCaiLiaoStorePresenter:__initData(func)
    self._interactor:init(
        function()
            if func then
                func()
            end
        end
    )
end

function CuiLianCaiLiaoStorePresenter:__initUI()
    self._actionUI:setTextTitle(self._interactor:getActionName())
    self._actionUI:setDesc(self._interactor:getActionDesc())

    self._actionUI:setTitie1Func(function()
        self:showListview_1UI()
    end)

    self._actionUI:setTitie2Func(function()
        self:showListview_2UI()
    end)


    self:__refreshUI()
    self:showListview_1UI()
end

function CuiLianCaiLiaoStorePresenter:showListview_1UI()
    self._actionUI:setTitie1Visible(true)
    self._actionUI:setTitie2Visible(false)
    self._actionUI:setListViewVisible(1, true)
    self._actionUI:setListViewVisible(2, false)
    self._actionUI:setImage2Visible(false)

    self:initSelect_1Button()

    local goodsTypeList = self._interactor:getGoodsType()

    if not self.__selectType then
        self.__selectType = goodsTypeList[1]
    end

    local goodsList = self._interactor:getGoodsInfoByType(self.__selectType)

    for i = 1, #goodsTypeList do
        if goodsTypeList[i] ~= self.__selectType then
            self._actionUI:setPanelSelectBtnTexture(i, "Image/BaseUI/panel-blue2-bg.png")
        else
            self._actionUI:setPanelSelectBtnTexture(i, "Image/BaseUI/panel-blue1-bg.png")
        end
    end

    self:initListView1(goodsList)
end

function CuiLianCaiLiaoStorePresenter:showListview_2UI()
    self._actionUI:setTitie1Visible(false)
    self._actionUI:setTitie2Visible(true)
    self._actionUI:setListViewVisible(1, false)
    self._actionUI:setListViewVisible(2, true)
    self._actionUI:setImage2Visible(true)

    self:initSelect_2Button()

    local exchangeTypeList = self._interactor:getExchangeTypeList()

    if not self.__selectType2 then
        self.__selectType2 = exchangeTypeList[1]
    end

    local exchangeList = self._interactor:getExchangeInfoByType(self.__selectType2)

    for i = 1, #exchangeTypeList do
        if exchangeTypeList[i] ~= self.__selectType2 then
            self._actionUI:setPanelSelectBtnTexture(i, "Image/BaseUI/panel-blue2-bg.png")
        else
            self._actionUI:setPanelSelectBtnTexture(i, "Image/BaseUI/panel-blue1-bg.png")
        end
    end

    self:initListView2(exchangeList)
end 

function CuiLianCaiLiaoStorePresenter:__refreshUI()
    local name1, num1 = self._interactor:getCurrencyById("yuanbao")
    local name2, num2 = self._interactor:getCurrencyById("liujinye")

    self._actionUI:setText1(name1.."："..num1)
    self._actionUI:setText2("当前可用"..name2.."："..num2)
    self._actionUI:setText3("已获得"..name2.."："..self._interactor:getJifen().."/"..self._interactor:getJifenLimit())
end

function CuiLianCaiLiaoStorePresenter:initListView1(list)
    if MapIsEmpty(list) == false then
        for i, v in ipairs(list) do
            v.func = function()
                if v.state == 0 then
                    self:doBuy(v)
                elseif v.state == 1 then
                    self:doReward(v)
                end
            end
        end

        self._actionUI:showListView_1(list)
    end
end

function CuiLianCaiLiaoStorePresenter:initListView2(list)
    if MapIsEmpty(list) == false then
        for i, v in ipairs(list) do
            v.func = function()
                PopupLayerController:showLayer("CuiLianCaiLiaoStoreSelectPresenter",function(layer)
                    layer:setTitle("")
                    local currencyName = self._interactor:getCurrencyById("liujinye")
                    layer:setTextDesc_1("    是否消耗"..v.name.."进行兑换"..currencyName.."？")
                    layer:setTextDesc_2("兑换可获得")
                    layer:setTextDesc_3(currencyName,v.price)
                    layer:setText_1Str(currencyName)

                    layer:setText_2Str(self._interactor:getJifen().."/"..self._interactor:getJifenLimit())

                    layer:setItemName(currencyName)

                    layer:setUnitPrice(v.price)

                    layer:setBuyNumber(1)

                    layer:setMaxBuyNumber(v.maxCount)

                    layer:setSelectText("1/"..tostring(v.maxCount))

                    layer:showLayer()

                    layer:setButton_1Func(function(buyNumber)
                        local rewards = {
                            id = v.goodsId,
                            num = buyNumber
                        }

                        if self._interactor:checkCanGetReward(rewards) then
                            self._interactor:doExchange(v.id, buyNumber, function()
                                self:__initData(function()
                                    PopText("兑换成功")
                                    self:__refreshUI()
                                    local exchangeList = self._interactor:getExchangeInfoByType(self.__selectType2)
                                    self:initListView2(exchangeList)
                                end)
                            end)
                        else
                            PopText("背包空间不足")
                        end
                    end)

                    layer:setButton_2Func(function()
                        layer:hideLayer()
                    end)
                end)
            end
        end

        self._actionUI:showListView_2(list)
    end
end

function CuiLianCaiLiaoStorePresenter:initSelect_1Button()
    self._actionUI:setPanelSelectPositionY(980)
    local list = self._interactor:getGoodsType()
    for index, type in ipairs(list) do
        self._actionUI:setPanelSelectBtnNameAndFunc(index, type, function()
            local goodsList = self._interactor:getGoodsInfoByType(type)
            self.__selectType = type
            self:initListView1(goodsList)

            for i = 1, #list do
                if i ~= index then
                    self._actionUI:setPanelSelectBtnTexture(i, "Image/BaseUI/panel-blue2-bg.png")
                else
                    self._actionUI:setPanelSelectBtnTexture(i, "Image/BaseUI/panel-blue1-bg.png")
                end
            end
        end)
    end
end

function CuiLianCaiLiaoStorePresenter:initSelect_2Button()
    self._actionUI:setPanelSelectPositionY(888)
    local list = self._interactor:getExchangeTypeList()
    for index, type in ipairs(list) do
        self._actionUI:setPanelSelectBtnNameAndFunc(index, type, function()
            local exchangeList = self._interactor:getExchangeInfoByType(type)
            self.__selectType2 = type
            self:initListView2(exchangeList)

            for i = 1, #list do
                if i ~= index then
                    self._actionUI:setPanelSelectBtnTexture(i, "Image/BaseUI/panel-blue2-bg.png")
                else
                    self._actionUI:setPanelSelectBtnTexture(i, "Image/BaseUI/panel-blue1-bg.png")
                end
            end
        end)
    end
end

function CuiLianCaiLiaoStorePresenter:doBuy(goods)
    local priceNum = goods.price[1].number
    local priceUnit = goods.price[1].priceUnit
    local currencyName = self._interactor:getCurrencyById(priceUnit)

    local text = "购买当前礼包可获得"..goods.text2.."，是否使用"..priceNum..currencyName.."购买？"
    local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
    local dialog = DialogALayer:getInstance()
    dialog:show()
    dialog:setRichText(text)
    dialog:setButton1("确定", function()
        self._interactor:doBuy(goods.id, priceUnit, function()
            PopText("购买成功")

            self:__initData(function()
                self:__refreshUI()
                self:showListview_1UI()
            end)
        end)
    end)
    dialog:setButton2("取消", function()
        dialog:hide()
    end)
    dialog:setWeChatVisible(false)
end

function CuiLianCaiLiaoStorePresenter:doReward(goods)
    local is_email = not self._interactor:checkCanGetReward(goods.rewards)

    self._interactor:doReward(goods.id, is_email,function()
        self:__initData(function()
            self:__refreshUI()
            self:showListview_1UI()
        end)
    end)
end

function CuiLianCaiLiaoStorePresenter:hideLayer()
    PopupLayerController:hideLayer(
        "CuiLianCaiLiaoStorePresenter",
        function(layer)
            self._actionUI:hideUI()
        end
    )
end

function CuiLianCaiLiaoStorePresenter:initRule(ruleInfo)
	self.__ruleInfo = ruleInfo
end

function CuiLianCaiLiaoStorePresenter:__setRuleFunc()
	self._actionUI:setButtonRuleFunc(function()
        self:__showRule()
    end)
end

function CuiLianCaiLiaoStorePresenter:__showRule()
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

Helper:classDefNodeGetInstance(CuiLianCaiLiaoStorePresenter)

return CuiLianCaiLiaoStorePresenter
00000000000000