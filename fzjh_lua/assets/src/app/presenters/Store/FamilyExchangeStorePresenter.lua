local FamilyExchangeStorePresenter = class("FamilyExchangeStorePresenter", cc.Layer)

function FamilyExchangeStorePresenter:create()
    local p = FamilyExchangeStorePresenter:new()
    p:init()
    return p
end

function FamilyExchangeStorePresenter:init()
    self._ui = require("app.views.ui.ActionUI.NewRandomGiftUI"):create()

    self._ui:addTo(self)

    local FamilyExchangeStore = require("app.models.Store.FamilyExchangeStore")

    self._ui:setButtonBack(
        function()
            self:hideLayer()
        end
    )

    self._ui:setPanelInfoVisible(false)
    self._ui:setPanelInfoBtnVisible(false)
    self._ui:setButtonRuleVisible(false)
    self._ui:setPanelCurrencyVisible(true)
    self._ui:setButton1Visible(false)
    self._ui:setText2Visible(false)
    self._ui:setText1("")
    self._ui:setPanelCurrencyText(1, "")
    self._ui:setPanelCurrencyText(2, "")
    self._ui:setListViewSize({width = 1050.0000, height = 1168.0000})

    self._interactor = FamilyExchangeStore:create()
end

function FamilyExchangeStorePresenter:showLayer()
    self._role = User:getRole()

    self._interactor:setRole(self._role)
    
    self:__initData()
end

function FamilyExchangeStorePresenter:setTitleName(name)
    self._ui:setTextTitle(name)
end

function FamilyExchangeStorePresenter:__initData()
    self._interactor:init(
        function()
            self._ui:setDesc(self._interactor:getActionDesc())

            local currencys = self._interactor:getCurrencys()

            local index = 3
            for k, v in pairs(currencys) do
                self._ui:setPanelCurrencyText(index, v.name.."："..v.number)
                index = index + 1
            end

            self:__showListView()

            self._ui:showUI()
        end
    )
end

function FamilyExchangeStorePresenter:__showListView()
    self._ui:clearListView()

    local rewardList = self._interactor:getRewardList()
    for k,v in pairs(rewardList) do
        v.text1 = "兑换"..v.text1
        v.func = function()
            if v.state == 2 then
                PopText("该奖励已兑换光了，请下周再次兑换")
                return
            end

            local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
            local dialog = DialogALayer:getInstance()
            dialog:show()
            local text = "是否花费"..v.btnName..v.text1.."？完成购买后若超出上限，则通过邮箱发放。"
            dialog:setRichText(text)
            dialog:setButton1("确定", function()
                self:__buyFunc(v)
            end)
            dialog:setButton2("取消", function()
                dialog:hide()
            end)
            dialog:setWeChatVisible(false)
        end

        local panel = self._ui:cloneListViewPanelItem2()
        self._ui:initPanelItem2(panel, v)
        self._ui:addItemToListView(panel)
    end
end

function FamilyExchangeStorePresenter:__buyFunc(info)
    self._interactor:buyGoods(info.id, function()
        self._interactor:init(function()
            self:__showListView()
            local currencys = self._interactor:getCurrencys()
            
            local index = 3
            for k, v in pairs(currencys) do
                self._ui:setPanelCurrencyText(index, v.name.."："..v.number)
                index = index + 1
            end
        end)
    end)
end

function FamilyExchangeStorePresenter:hideLayer()
    PopupLayerController:hideLayer(
        "FamilyExchangeStorePresenter",
        function(layer)
            self._ui:hideUI()
        end
    )
end

Helper:classDefNodeGetInstance(FamilyExchangeStorePresenter)

return FamilyExchangeStorePresenter
0000000000000000