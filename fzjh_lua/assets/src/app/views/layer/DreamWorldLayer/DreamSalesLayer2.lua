local DreamSalesLayer2 = class("DreamSalesLayer2", LayerEx)

--@RefType [src.app.models.DreamWorldModel.DreamSalesModel#DreamSalesModel]
local DreamSalesModel2 = require("app.models.DreamWorldModel.DreamSalesModel2")

function DreamSalesLayer2:create()
    local p = DreamSalesLayer2:new()
    p:init()
    return p
end

function DreamSalesLayer2:init()
    self._UI = require("Layer/MapUI/MapBagUI.lua").create()["root"]
    self._UI:addTo(self)
    Helper:convertUIByParent(self)
    self:initButtons()

    self.Text_money:setVisible(false)

    self.Text_desc1:setString(User:getRole():getCHAttrName("dreamPoints") .. ":")

    self:setVisible(false)
end

function DreamSalesLayer2:hideLayer()
    PopupLayerController:hideLayer(
        "DreamSalesLayer2",
        function(layer)
            layer:hide()
        end
    )
end

function DreamSalesLayer2:initButtons()
    local createBtn = function()
        local roleButton = Resource:getUIByName("Button_4")
        Helper:convertUI(roleButton)
        roleButton.Text_buttonName:enableOutline(cc.c4b(0, 0, 0, 255), 5)
        return roleButton
    end

    local button_right = createBtn()
    self:addChild(button_right)
    button_right:move(cc.p(810, 130))

    button_right:setVisible(true)
    button_right.Text_buttonName:setString("确定")
    button_right:releaseFunc(
        function()
            Audio:playEffect("xiaoAnNiu")

            self:hideLayer()
        end
    )
end

function DreamSalesLayer2:showLayer(map, sell_list,salesName,sallerId)
    self.role = map:getPlayer()

    self.map = map

    self.sallerId = sallerId

    self.rightItems = sell_list

    self.leftItems = self.role:getItems()

    self.Image_title.Text_title2:setString(salesName)

    self.Text_weight:setPosition(220, 1710.0000)

    self:setBuyItemCall()

    self:refreshlist()

    self:refeshMoney()

    self:show()
end

function DreamSalesLayer2:refreshlist()
    self:initRightList()

    self:initLeftList()
end

function DreamSalesLayer2:refeshMoney()
    self.Text_weight:setString(tostring(math.floor(self.role:getAttr("dreamPoints"))))
end

function DreamSalesLayer2:initRightList()
    for index, sellerItem in ipairs(self.rightItems) do
        local panel_row = self.ListView_2:getItem(index - 1)
        if panel_row == nil then
            panel_row = self.Panel_item2:clone()
            Helper:convertUIByParent(panel_row)
            self.ListView_2:pushBackCustomItem(panel_row)
        end

        panel_row:setVisible(true)
        panel_row.Text_name:setColor(cc.c3b(208, 208, 208)) --设置颜色
        local outlineColor = cc.c4b(24, 24, 24, 255)
        local outlineWidth = 5
        panel_row.Text_name:enableOutline(outlineColor, outlineWidth)
        panel_row.Text_num:enableOutline(outlineColor, outlineWidth)

        panel_row.Text_name:setString(sellerItem.name)

        panel_row.Text_num:setString(tostring(math.abs(sellerItem.drcost)) .. self.role:getCHAttrName("dreamPoints"))

        panel_row:releaseFunc(
            function()
                self:clickRightItem(sellerItem)
            end
        )
    end

    local listCount = #self.ListView_2:getItems()
    if listCount - #self.rightItems > 0 then
        for i = listCount - 1, #self.rightItems, -1 do
            self.ListView_2:removeItem(i)
        end
    end
end

--@desc: 购买物品
--@author:Liang SongQiang
--@time:2019-09-29 12:11:48
--@sellerItem: 要学习的技能数据
function DreamSalesLayer2:clickRightItem(sellerItem) 
    DreamSalesModel2:buyItem(
        self.map,
        sellerItem,
        self.buyItemCallback
    )
end

function DreamSalesLayer2:setBuyItemCall()
    local sellerType = DreamSalesModel2:getSellerType()

    if sellerType == 1 then
        self.buyItemCallback = function()
            self:refreshlist()
            self:refeshMoney()
        end
    elseif sellerType == 2 then
        self.buyItemCallback = function()
            self:hideLayer()
            self.map:removeRoomRole(self.map:getCurrRoomId(),self.sallerId)
            self.map.__MapLayer:delayRefreshMap()
            RichPrint("main","只听得一句“有缘再见”，你尚未回过神来，方才还在你眼前之人已然消失不见了。")
        end
    else
        assert(nil,"未知商人类型"..sellerType)
    end

    return self.buyItemCallback
end

function DreamSalesLayer2:clickLeftItem(item)
    DreamSalesModel2:saleItem(
        self.map,
        item,
        function()
            self:initLeftList()
            self:refeshMoney()
        end
    )
end

function DreamSalesLayer2:initLeftList()
    local listItemCount = 0
    for index, roleItem in ipairs(self.leftItems) do
        --@region 列表UI初始化设置
        local panel_row = self.ListView_1:getItem(listItemCount)
        if panel_row == nil then
            panel_row = self.Panel_item1:clone()
            Helper:convertUIByParent(panel_row)
            self.ListView_1:pushBackCustomItem(panel_row)
        end
        panel_row:setVisible(true)
        panel_row.Text_name:setColor(cc.c3b(208, 208, 208))
        --设置默认颜色
        local outlineColor = cc.c4b(24, 24, 24, 255)
        local outlineWidth = 5
        panel_row.Text_name:enableOutline(outlineColor, outlineWidth)
        --@endregion

        if roleItem ~= nil then
            listItemCount = listItemCount + 1

            local item = self.role:getOneItemByKey(roleItem.itemId)

            if roleItem.wpType == "神兵" then
                panel_row.Text_name:setString(item.name)
            else
                panel_row.Text_name:setString(tostring(item.name) .. " X " .. tostring(roleItem.count))
            end

            panel_row:releaseFunc(
                function()
                    -- PopText("该处不可出售或丢弃物品")
                    self:clickLeftItem(item)
                end
            )
        else
            if PRINT_MODE == 1 then
                print("item is not found of itemId : " .. roleItem.itemId)
            end
        end
    end

    local listCount = #self.ListView_1:getItems()
    if listCount - listItemCount > 0 then
        for i = listCount - 1, listItemCount, -1 do
            self.ListView_1:removeItem(i)
        end
    end
end

Helper:classDefNodeGetInstance(DreamSalesLayer2)
return DreamSalesLayer2
00