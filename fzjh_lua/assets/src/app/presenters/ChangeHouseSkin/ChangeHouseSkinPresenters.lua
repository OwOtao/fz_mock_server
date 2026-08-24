local ChangeHouseSkinPresenters = class("ChangeHouseSkinPresenters", cc.Layer)
local PreviewSkinPresenters = require("app.presenters.ChangeHouseSkin.PreviewSkinPresenters")

local HouseSkin = require("app.models.ChangeHouseSkin.HouseSkin")

local PANEL_CLASSFIY = {
    -- 已拥有
    OWN = 1,
    -- 未拥有
    NOT_OWN = 2
}

function ChangeHouseSkinPresenters:create()
    local p = ChangeHouseSkinPresenters:new()
    p:init()
    return p
end

function ChangeHouseSkinPresenters:init()
    --@RefType [ChangeHouseSkinUI]
    self._UI = require("app.views.ui.ChangeHouseSkinUI.ChangeHouseSkinUI"):create()

    self._UI:addTo(self)

    --@RefType [src.app.models.ChangeHouseSkin.ChangeHouseSkin#ChangeHouseSkin]
    self._interactor = require("app.models.ChangeHouseSkin.ChangeHouseSkin"):create()

    self._UI:setButtonBack(
        function()
            self:hideLayer()
        end
    )
end

function ChangeHouseSkinPresenters:setRole(role)
    self._interactor:setRole(role)
end

function ChangeHouseSkinPresenters:showLayer()
    self._UI:setTextTitle("苍黄翻复")
    self._UI:setTitle_1Name("未拥有")
    self._UI:setTitle_2Name("已拥有")

    self.__currPanel = PANEL_CLASSFIY.NOT_OWN

    self._UI:setTitle_1Func(
        function()
            self.__currPanel = PANEL_CLASSFIY.NOT_OWN
            self:refeshUI()
        end
    )

    self._UI:setTitle_2Func(
        function()
            self.__currPanel = PANEL_CLASSFIY.OWN

            self:refeshUI()
        end
    )

    self._interactor:fetchSkinThemeData(
        function()
            if MapIsEmpty(self._interactor:getStoreList()) then
                self.__currPanel = PANEL_CLASSFIY.OWN
            end
            self:refeshUI()
            self._UI:showUI()
        end
    )
end

function ChangeHouseSkinPresenters:hideLayer()
    PopupLayerController:hideLayer(
        "ChangeHouseSkinPresenters",
        function(layer)
            self._UI:hideUI()
        end
    )
end

function ChangeHouseSkinPresenters:refeshUI()
    self._UI:setText1Str("拥有" .. self._interactor:getCurrencyName() .. "：" .. tostring(self._interactor:getCurrencyNum()))

    local skinThemeList = nil
    if self.__currPanel == PANEL_CLASSFIY.NOT_OWN then
        skinThemeList = self._interactor:getStoreList()
        self._UI:setTitle_1BackGroundColorOpacity(255)
        self._UI:setTitle_2BackGroundColorOpacity(0)
        self._UI:setTitle_1Visible(true)
        self._UI:setTitle_2Visible(false)
        self._UI:setTitle_1Enable(false)
        self._UI:setTitle_2Enable(true)
        if MapIsEmpty(skinThemeList) then
            self._UI:setText2Visible(true)
            self._UI:setText2Str("目前没有更多界面兑换")
        else
            self._UI:setText2Visible(false)
        end
    elseif self.__currPanel == PANEL_CLASSFIY.OWN then
        self._UI:setTitle_1BackGroundColorOpacity(0)
        self._UI:setTitle_2BackGroundColorOpacity(255)
        self._UI:setTitle_2Visible(true)
        self._UI:setTitle_1Visible(false)
        self._UI:setTitle_2Enable(false)
        self._UI:setTitle_1Enable(true)
        skinThemeList = self._interactor:getPurchasedList()
        self._UI:setText2Visible(false)
    end

    for i, v in ipairs(skinThemeList) do
        --@RefType [src.app.models.ChangeHouseSkin.ChangeHouseSkin#SkinThemeView]
        local skinThemeView = v

        local itemNode = self._UI:getItemByIndex(i)

        itemNode.Text_1:setString(skinThemeView:getSkinName())
        itemNode.Image_1:loadTexture(skinThemeView:getBgTexture())
        itemNode.Button_1:setCapInsets({x = 15, y = 11, width = 260, height = 70})

        if not skinThemeView:getPurchased() then
            -- 未购买
            itemNode.Text_2:setVisible(true)
            itemNode.Text_2:setString(skinThemeView:getCurrencyText())
            itemNode.Text_4:setVisible(false)

            itemNode.Button_1:setVisible(true)
            itemNode.Button_1:setTouchEnabled(true)
            itemNode.Button_1.Text_buttonName:setString(skinThemeView:getOperationName())
            itemNode.Button_1:loadTextureNormal(skinThemeView:getBtnTexture())

            itemNode.Button_1:releaseFunc(
                function()
                    local previewPresenter = PreviewSkinPresenters:create()
                    self:addChild(previewPresenter)

                    local currSkinId = HouseSkin:getSkinId()

                    previewPresenter:showLayer(
                        {
                            changeHouseSkin = self._interactor,
                            skinThemeView = skinThemeView,
                            mode = PreviewSkinPresenters.SHOW_MODE.STORE,
                            canghuangling = self._interactor:getCurrencyNum(),
                            buyFail = function()
                                -- 失败有可能是已购买后服务器已完成客户端未收到消息导致，所以直接重新拉取状态
                                self._interactor:fetchSkinThemeData(
                                    function()
                                        self._UI:removeAllItems()
                                    end
                                )
                            end
                        },
                        function()
                            return self:refeshUI()
                        end
                    )
                end
            )

            if skinThemeView:getIsLimit() then
                itemNode.Image_2:setVisible(true)
                itemNode.Text_3:setVisible(true)
                itemNode.Text_3:setString("限时购买")
            else
                itemNode.Image_2:setVisible(false)
                itemNode.Text_3:setVisible(false)
            end
        else
            itemNode.Text_2:setVisible(false)

            itemNode.Image_2:setVisible(false)
            itemNode.Text_3:setVisible(false)

            if skinThemeView:isUsing() then
                itemNode.Button_1:setVisible(false)
                itemNode.Button_1:setTouchEnabled(false)
                itemNode.Text_4:setVisible(true)
                itemNode.Text_4:setString("使用中...")
            else
                itemNode.Button_1:setTouchEnabled(true)
                itemNode.Text_4:setVisible(false)
                itemNode.Button_1:setVisible(true)
                itemNode.Button_1.Text_buttonName:setString(skinThemeView:getOperationName())
                itemNode.Button_1:loadTextureNormal(skinThemeView:getBtnTexture())

                itemNode.Button_1:releaseFunc(
                    function()
                        local previewPresenter = PreviewSkinPresenters:create()
                        self:addChild(previewPresenter)

                        local currSkinId = HouseSkin:getSkinId()

                        previewPresenter:showLayer(
                            {
                                changeHouseSkin = self._interactor,
                                skinThemeView = skinThemeView,
                                mode = PreviewSkinPresenters.SHOW_MODE.OWNER,
                                canghuangling = self._interactor:getCurrencyNum()
                            },
                            function()
                                if currSkinId == HouseSkin:getSkinId() then
                                    return
                                end
                                return self:refeshUI()
                            end
                        )
                    end
                )
            end
        end
    end

    local itemNodeCount = self._UI:getItemsCount()
    if itemNodeCount > #skinThemeList then
        for i = #skinThemeList + 1, itemNodeCount do
            self._UI:removeLastItem()
        end
    end
end

Helper:classDefNodeGetInstance(ChangeHouseSkinPresenters)

return ChangeHouseSkinPresenters
0000000000