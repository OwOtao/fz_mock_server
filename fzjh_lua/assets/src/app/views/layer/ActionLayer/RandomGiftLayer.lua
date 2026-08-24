local RandomGiftLayer = class("RandomGiftLayer", LayerEx)

function RandomGiftLayer:create()
    local p = RandomGiftLayer:new()
    p:init()
    return p
end

function RandomGiftLayer:init()
    local UI = require("Layer/ActionUI/RandomGiftUI.lua").create()["root"]
    UI:addTo(self)

    Helper:convertUIByParent(self)

    self.Button_back:releaseFunc(
        function()
            self:hideLayer()
        end
    )

    self.Panel_ItemInfo:releaseFunc(
        function()
            self.Panel_ItemInfo:setVisible(false)
        end
    )

    self.Text_dsc:setVisible(false)

    self.Text_3:releaseFunc(
        function()
            PopupLayerController:showLayer(
                "GlobalShadeLayer",
                function(layer)
                    layer:showLayer()
                    layer:setPopText("请稍等")
                end
            )

            HttpManagerEx:getDiyInfos(
                function(status, errcode, errmsg, data)
                    if status == 200 then
                        if errcode == 0 then
                            for i, v in ipairs(data) do
                                local info = Item:getOneItemByKey(v.itemId)

                                if info ~= nil then
                                    local item_panel = self.RewardsShowPanel.ListView_1:getItem(i - 1)
                                    local listView = self.RewardsShowPanel.ListView_1
                                    if item_panel == nil then
                                        item_panel = self.RewardsShowPanel.ItemInfoPanel:clone()
                                        listView:pushBackCustomItem(item_panel)
                                    end

                                    Helper:convertUIByParent(item_panel)

                                    item_panel.Text_Name:setColor({r = 184, g = 184, b = 184})

                                    item_panel.Text_Count:setColor({r = 184, g = 184, b = 184})

                                    item_panel.Text_Name:setString(Helper:getNoColorStr(info.name))

                                    item_panel.Text_Count:setString(v.number)

                                end
                            end

                            local row_count = #self.RewardsShowPanel.ListView_1:getItems()
                            if row_count - #data > 0  then
                                for i=row_count-1,#data,-1 do
                                    self.RewardsShowPanel.ListView_1:removeItem(i)
                                end
                            end

                            self.RewardsShowPanel:maxZ()
                            self.RewardsShowPanel:setVisible(true)
                        end
                    else
                        print("errcode = " .. errcode)
                        PopText(errmsg)
                    end

                    PopupLayerController:hideLayer(
                        "GlobalShadeLayer",
                        function(layer)
                            layer:hideLayer()
                        end
                    )
                end,
                IS_SHOW_WAITING
            )
        end
    )

    self.RewardsShowPanel:releaseFunc(
        function()
            self.RewardsShowPanel:setVisible(false)
        end
    )

    self:setVisible(false)
end

function RandomGiftLayer:hideLayer()
    PopupLayerController:hideLayer(
        "RandomGiftLayer",
        function(layer)
            layer:hide()
        end
    )
end

function RandomGiftLayer:setDesc(desc)
    local richText = self.Text_dsc:getParent():getChildByTag(10001)
    if richText == nil then
        richText = ExtRichTextScroll:create()
        richText:setAnchorPoint(0.5, 0.5)
        richText:setSize({width = 971.00, height = 290.00})
        -- richText:move(cc.p(17.10, 1474.23))
        richText:move(cc.p(534.14, 1625.46))
        richText:setTag(10001)
        self.Text_dsc:getParent():addChild(richText)
        richText:setVerticalSpace(5)
        richText:setDirection(kCCScrollViewDirectionVertical)
    else
        richText:getRichText():removeAllElement()
    end
    richText:pushBackText(desc, cc.c3b(208, 208, 208), 255, Resource:getFontPath("default"), 36)
end

function RandomGiftLayer:setName(name)
    self.Text_title:setString(tostring(name))
end

function RandomGiftLayer:showLayer(action)
    local timeStartStr = Helper:getTimeStrCNFormat(action["start"])
    local timeEndStr = Helper:getTimeStrCNFormat(action["end"])

    local detail_desc_list = action.detail_desc

    local str = ""

    for i, desc in ipairs(detail_desc_list) do
        desc = string.gsub(desc, "#start#", timeStartStr)
        desc = string.gsub(desc, "#end#", timeEndStr)
        str = str .. desc .. "\n"
    end
    self:setDesc(str)
    self:setName(action.name)

    Game:getWebTime(
        function(time)
            self.time = time

            HttpManagerEx:getDiyGoods(
                "N",
                function(status, errcode, errmsg, data)
                    if status == 200 then
                        if errcode == 0 or errcode == 1 then
                            self:setInfo(data, errcode)
                            self:show()
                        else
                            self:hideLayer()
                            print("errcode = " .. errcode)
                            PopText(errmsg)
                        end
                    else
                        self:hideLayer()
                        print("errcode = " .. errcode)
                        PopText(errmsg)
                    end
                end,
                IS_SHOW_WAITING
            )
        end
    )
end

function RandomGiftLayer:setInfo(data, status)
    self._boughtStatus = status

    if self._boughtStatus == 1 then
        self.Image_sellout:setVisible(true)
    else
        self.Image_sellout:setVisible(false)
    end

    self:showList(data.list)
    self:setBoughtTime(data.diygift_times)
    self:setRefreshCount(data.refresh_times)
    self:setLeftBtnFunc(data.refresh_yuanbao)
    self:setDiscountImg(tonumber(data.discount))
    self.Text_5:setString(data.discountYb .. "元宝")
    self.Text_6:setString("原价" .. data.totalYb .. "元宝")

    self:setRightBtnFunc(data.list, data.totalYb, data.discount, data.discountYb)
end

function RandomGiftLayer:setDiscountImg(discount)
    if discount == nil or discount <= 0 or discount >= 1 then
        self.Discount_Img:setVisible(false)
    else
        self.Discount_Img:setVisible(true)
    end

    local discount_name = "discount" .. discount * 10 .. ".png"
    self.Discount_Img:loadTexture("Image/UI/StoreUI/" .. discount_name, 0)
end

function RandomGiftLayer:showList(list)
    for i = 1, 6 do
        local index = i - 1

        local item_ui = self.GiftPanel["item_" .. index]

        local info = list[i]

        if info ~= nil then
            item_ui:setVisible(true)
            item_ui.Text_name:setColor({r = 0, g = 0, b = 0})
            item_ui.Text_name:setString(Helper:getNoColorStr(info.name))
            item_ui.Text_num:setString(info.number)

            if self._boughtStatus == 1 then
                item_ui:loadTextureNormal("Image/UI/StoreUI/itembg02.png", 0)
            else
                item_ui:loadTextureNormal("Image/UI/StoreUI/itembg01.png", 0)
            end

            item_ui:releaseFunc(
                function()
                    self:setItemInfo(info.itemId)
                end
            )
        else
            item_ui:setVisible(false)
        end
    end
end

function RandomGiftLayer:setItemInfo(itemId)
    local item = Item:getOneItemByKey(itemId)

    self.Panel_ItemInfo:maxZ()

    self.Panel_ItemInfo:setVisible(true)

    self.Panel_ItemInfo.Image_back.Panel_title.Text_name:setString(item.name)

    self.Panel_ItemInfo.Image_back.Panel_title.Text_zhuangbei:setString(item:getItemShowType())

    self.Panel_ItemInfo.Image_back.Text_desc:setString(item:getDsc())
end

function RandomGiftLayer:setRefreshCount(count)
    self.Text_1:setString("当日已重置礼包：" .. count .. "次")
end

function RandomGiftLayer:setBoughtTime(count)
    self.Text_2:setString("活动期间已购买礼包：" .. count .. "次")
end

function RandomGiftLayer:setLeftBtnFunc(refreshYb)
    refreshYb = Helper:getDef(refreshYb, 0)

    local refresh = function()
        local diff = Helper:diffWithDate(GetTime(), self.time)

        if diff ~= 0 then
            PopText("出错，请重新进入。")
            self:hideLayer()
            return
        end

        PopupLayerController:showLayer(
            "DialogALayer2",
            function(layer)
                local title = "是否确定重置礼包，重置成功将从奖品池内随机抽取4组或6组奖品组成礼包，再随机打折。"

                local tips = "需要花费"
                if refreshYb > 0 then
                    tips = tips .. refreshYb .. "元宝"
                else
                    tips = tips .. "本次免费"
                end
                layer:showLayer(title)

                layer:setButton1(
                    "确定",
                    function()
                        PopupLayerController:showLayer(
                            "GlobalShadeLayer",
                            function(layer)
                                layer:showLayer()
                                layer:setPopText("请稍等。")
                            end
                        )

                        HttpManagerEx:getDiyGoods(
                            "Y",
                            function(status, errcode, errmsg, data)
                                PopupLayerController:hideLayer(
                                    "GlobalShadeLayer",
                                    function(layer)
                                        layer:hideLayer()
                                    end
                                )
                                if status == 200 then
                                    if errcode == 0 or errcode == 1 then
                                        Helper:print_lua_table(data)

                                        self:setInfo(data, errcode)
                                        PopText("刷新成功")
                                    else
                                        print("errcode = " .. errcode)
                                        PopText(errmsg)
                                    end
                                else
                                    print("errcode = " .. errcode)
                                    PopText(errmsg)
                                end
                            end,
                            IS_SHOW_WAITING
                        )
                    end,
                    tips
                )
                layer:setButton2("取消", EMPTY_FUNC)
            end
        )
    end

    self.Button_Left:releaseFunc(
        function()
            if self._boughtStatus == 1 then
                PopText("礼包已达购买上限。")
            else
                refresh()
            end
        end
    )
end

function RandomGiftLayer:setRightBtnFunc(list, totalYb, discount, discountYb)
    local bought = function()
        local title = "HIW是否确定花费" .. discountYb .. "元宝购买礼包，其中包含"

        local items_dsc = ""

        for i, v in ipairs(list) do
            items_dsc = items_dsc .. Helper:getNoColorStr(v.name) .. "x" .. v.number .. Helper:getDef(v.unit, "") .. "，"
        end
        items_dsc = string.sub(items_dsc, 1, -4)
        items_dsc = items_dsc .. "。NOR"

        title = title .. items_dsc

        PopupLayerController:showLayer(
            "DialogALayer2",
            function(layer)
                layer:showLayer(title)
                layer:setButton1(
                    "确定",
                    function()
                        local role = User:getRole()

                        local item_list = {}
                        for i, v in ipairs(list) do
                            if item_list[v.itemId] == nil then
                                item_list[v.itemId] = tonumber(v.number)
                            else
                                item_list[v.itemId] = item_list[v.itemId] + tonumber(v.number)
                            end
                        end

                        if role:checkCanBuyTwoOrMoreThings(item_list, true) == false then
                            return
                        end

                        PopupLayerController:showLayer(
                            "GlobalShadeLayer",
                            function(layer)
                                layer:showLayer()
                                layer:setPopText("请稍等。")
                            end
                        )

                        HttpManagerEx:buyDiyGoods(
                            function(status, errcode, errmsg, data)
                                PopupLayerController:hideLayer(
                                    "GlobalShadeLayer",
                                    function(layer)
                                        layer:hideLayer()
                                    end
                                )
                                if status == 200 then
                                    if errcode == 0 or errcode == 1 then
                                        Helper:print_lua_table(data)

                                        for i, v in ipairs(list) do
                                            role:addItemCount(v.itemId, v.number)
                                            PopText("你获得了 " .. v.name .. " X " .. v.number .. v.unit)
                                        end

                                        self:setInfo(data, errcode)
                                    else
                                        print("errcode = " .. errcode)
                                        PopText(errmsg)
                                    end
                                else
                                    print("errcode = " .. errcode)
                                    PopText(errmsg)
                                end
                            end,
                            IS_SHOW_WAITING
                        )
                    end,
                    "需要花费" .. discountYb .. "元宝"
                )
                layer:setButton2("取消", EMPTY_FUNC)
            end
        )
    end

    self.Button_Right:releaseFunc(
        function()
            if self._boughtStatus == 1 then
                PopText("礼包已达购买上限。")
            else
                bought()
            end
        end
    )
end

Helper:classDefNodeGetInstance(RandomGiftLayer)
return RandomGiftLayer
0000