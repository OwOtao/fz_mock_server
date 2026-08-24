local BagUpgradePresenters = class("BagUpgradePresenters", cc.Layer)

function BagUpgradePresenters:create()
    local p = BagUpgradePresenters:new()
    p:init()
    return p
end

function BagUpgradePresenters:init()
    self._UI = require("app.views.ui.AttrUI.BagUpgradeUI"):create()

    self._UI:addTo(self)

    local Bag = require("app.models.role.bag.Bag")

    local WareHouse = require("app.models.role.bag.WareHouse")

    self._UI:setButtonclose(
        function()
            self:hideLayer()
        end
    )

    self._bagInteractor = Bag:create()

    self._wareHouseInteractor = WareHouse:create()
end

function BagUpgradePresenters:showLayer()
    self._role = User:getRole()

    self._bagInteractor:setRole(self._role)

    self._bagInteractor:initBagLevel()

    self._bagInteractor:initBagUpgradeCount()

    self._wareHouseInteractor:setRole(self._role)

    self._wareHouseInteractor:initWareHouseLevel()
    
    self:__initData()

    self._UI:showUI()
end

function BagUpgradePresenters:__initData()
    local isMaxBag,maxBagCount = self._bagInteractor:checkIsMax(),self._bagInteractor:getMaxSpace()
    local isMaxWareHouse,maxWareHouseCount = self._wareHouseInteractor:checkIsMax(),self._wareHouseInteractor:getMaxSpace()
    local addSpace = 0
    local text1,text2

    if isMaxBag == false then
        local currBagLevel = self._bagInteractor:getBagLevel()
        local bagUpgradeCostName = self._bagInteractor:getLevelUpgradeCurrencyName(currBagLevel + 1)
        local bagUpgradeCostCount = self._bagInteractor:getLevelUpgradeCurrencyCount(currBagLevel + 1)
        local bagSpace = self._bagInteractor:getBagSpace(currBagLevel + 1)
        text1 = "花费"..bagUpgradeCostCount..bagUpgradeCostName.."可升级背包到"..bagSpace.."格"
    else
        text1 = "已升级到最大格数"..maxBagCount.."格"
    end

    if isMaxWareHouse == false then
        local currWareHouseLevel = self._wareHouseInteractor:getWareHouseLevel()
        local wareHouseUpgradeCostName = self._wareHouseInteractor:getLevelUpgradeCurrencyName(currWareHouseLevel + 1)
        local wareHouseUpgradeCostCount = self._wareHouseInteractor:getLevelUpgradeCurrencyCount(currWareHouseLevel + 1)
        local wareHouseSpace = self._wareHouseInteractor:getWareHouseSpace(currWareHouseLevel + 1)
        local beforeWareHouseSpace = self._wareHouseInteractor:getWareHouseSpace(currWareHouseLevel)
        addSpace = wareHouseSpace - beforeWareHouseSpace
        text2 = "花费"..wareHouseUpgradeCostCount..wareHouseUpgradeCostName.."可升级仓库到"..wareHouseSpace.."格"
    else
        text2 = "已升级到最大格数"..maxWareHouseCount.."格"
    end

    self._UI:setButton1Name("升级背包")
    self._UI:setButton1Func(function()
        Audio:playEffect("xiaoAnNiu")

        if isMaxBag then
            PopText("当前背包已是最大格数，升级失败")
            return
        end

        if self._bagInteractor:checkCanUpgrade() == true then
            self._bagInteractor:upgradeBag(function()
                Audio:playEffect("gouMai")
                self:__initData()
            end)
        else
            PopText("升级所需货币不足，升级失败")
        end
    end)

    self._UI:setButton2Name("升级仓库")
    self._UI:setButton2Func(function()
        Audio:playEffect("xiaoAnNiu")

        if isMaxWareHouse then
            PopText("当前仓库已是最大格数，升级失败")
            return
        end

        if self._wareHouseInteractor:checkCanUpgrade() == true then
            self._wareHouseInteractor:upgradeWareHouse(function()
                 --仓库实际空间 也需要同步扩大
                 if addSpace > 0 then
                    self._role:addAttr("ckLimit",addSpace)
                end
                Audio:playEffect("gouMai")
                self:__initData()
            end)
        else
            PopText("升级所需货币不足，升级失败")
        end
    end)

    self._UI:setTextDesc1(text1)
    self._UI:setTextDesc2(text2)
    self._UI:setTextTitle("请选择升级背包或仓库")
end

function BagUpgradePresenters:setHideFunc(func)
    self.__hideCallback = func
end

function BagUpgradePresenters:hideLayer()
    PopupLayerController:hideLayer(
        "BagUpgradePresenters",
        function(layer)
            self._UI:hideUI()
            if self.__hideCallback then
                self.__hideCallback()
            end
        end
    )
end

Helper:classDefNodeGetInstance(BagUpgradePresenters)

return BagUpgradePresenters
000000000