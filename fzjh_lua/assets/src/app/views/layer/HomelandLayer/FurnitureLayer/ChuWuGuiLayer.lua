local ChuWuGuiLayer = class("ChuWuGuiLayer", cc.Layer)

function ChuWuGuiLayer:create()
    local p = ChuWuGuiLayer:new()
    p:init()
    return p
end

function ChuWuGuiLayer:init()
    self._UI = require("Layer/MapUI/MapBagUI.lua").create()["root"]
    self._UI:addTo(self)
    Helper:convertUIByParent(self)
    self:initButtons()

    self.Text_money:setVisible(true)

    self.Image_title.Text_title2:setString("仓库")
end

function ChuWuGuiLayer:showLayer()
    self:showBagItems()

    self:showCangKuItems()

    self:refreshUI()

    self:show()
end

function ChuWuGuiLayer:showBagItems()
    --@RefType [app.models.role.Role#Role]
    local role = User:getRole()

    local items = role:getItems()

    self:sortTable(items)

    local addItems = {}

    --@desc 排除不能放入仓库的
    for i, v in ipairs(items) do
        local itemAttr = Item:getOneItemByKey(v.itemId)
        if itemAttr.deposit ~= 0 and itemAttr.deposit ~= false and itemAttr.id ~= "juejinchan" and itemAttr.id ~= "xunbaoluopan1"

        then
            table.insert(addItems, v)
        end
    end

    for i, v in ipairs(addItems) do
        local itemAttr = Item:getOneItemByKey(v.itemId)
        local row = self.ListView_1:getItem(i - 1)
        if not row then
            row = self.Panel_item1:clone()
            self.ListView_1:pushBackCustomItem(row)
            Helper:convertUIByParent(row)
        end

        row.Text_name:setTextColor({r = 255, g = 255, b = 255})
        if v.count > 1 then
            row.Text_name:setString(itemAttr.name .. " X" .. v.count)
        else
            row.Text_name:setString(itemAttr.name)
        end

        row:releaseFunc(
            function()
                self:pushCangKu(v, itemAttr)
                self:showCangKuItems()
                self:showBagItems()
                self:refreshUI()
            end
        )
    end

    local itemCount = #addItems
    local listCount = #self.ListView_1:getItems()
    if listCount - itemCount > 0 then
        local removePosition = listCount - itemCount
        for i = listCount - 1, itemCount, -1 do
            self.ListView_1:removeItem(i)
        end
    end
end

function ChuWuGuiLayer:showCangKuItems()
    --@RefType [app.models.role.Role#Role]
    local role = User:getRole()

    local ckItems = role:getckItems()

    if not MapIsEmpty(ckItems) then
        --背包放入仓库的时候，放在list的最前面
        for i = #ckItems, 1, -1 do
            local item = ckItems[i]

            local row = self.ListView_2:getItem(#ckItems - i)

            if row == nil then
                row = self.Panel_item2:clone()
                self.ListView_2:pushBackCustomItem(row)
                Helper:convertUIByParent(row)
            end

            local itemAttr = Item:getOneItemByKey(item.itemId)

            row.Text_name:setTextColor({r = 255, g = 255, b = 255})

            row.Text_name:setString(itemAttr.name)

            row.Text_num:setString("X" .. item.count)

            row:releaseFunc(function ()
                local role = User:getRole()
                local ckItems = role:getckItems()
                local item, i = role:getItemWithOnlyId(item.id)
                local ckitems = role:getAttr("ckitems")
                local items = role:getAttr("items")
        
                if not role:addItemCount(item.itemId, item.count,item.time,item.id) then
                    return
                end
        
                if not MapIsEmpty(ckItems) then
                    table.remove(ckItems, i)
                end
        
                --弹出一句话。显示放入仓库什么物品
                local itemAttr = Item:getOneItemByKey(item.itemId)
                PopText("将" .. itemAttr.name .. " X" .. item.count .. "放回背包")
                self:showCangKuItems()
                self:showBagItems()
                self:refreshUI()
            end)

        end
    end

    -- 删除多出来的widget
    for i = #ckItems + 1, #self.ListView_2:getItems() do
        self.ListView_2:removeLastItem()
    end
end

function ChuWuGuiLayer:pushCangKu(item, itemAttr)
    --@RefType [app.models.role.Role#Role]
    local role = User:getRole()

    local bagItems = role:getItems()

    local item, index = role:getItemWithOnlyId(item.id)

    if role:checkItemIsEquip(item.id) then
        PopText("装备已经穿上，请先卸下再放入仓库。")
        return
    end

    if role:checkIsPrepareWeapon(item.id) then
        PopText("装备已经准备，请先取消准备再放入仓库。")
        return 
    end

    if role:checkItemIsDamage(item) then
        PopText("损坏的兵器不能放入仓库！")
        return
    end

    if itemAttr.deposit == 0 or itemAttr.deposit == false then
        PopText("贵重物品还是不要放入仓库为好。")
        return
    end
    if not role:addItemCountck(item.itemId, item.count, item.time, item.id) then
        return
    end
    if not MapIsEmpty(bagItems) then
        table.remove(bagItems, index)
    end
    --弹出一句话。显示放入仓库什么物品
    local itemAttr = Item:getOneItemByKey(item.itemId)
    PopText("将" .. itemAttr.name .. " X" .. item.count .. "放入仓库")
end

function ChuWuGuiLayer:sortTable(bagItems)
    if type(bagItems) ~= "table" then
        return nil
    end
    local role = User:getRole()
    if not MapIsEmpty(bagItems) then
        table.sort(
            bagItems,
            function(a, b)
                local itemAttr_a = Item:getOneItemByKey(a.itemId)
                local itemAttr_b = Item:getOneItemByKey(b.itemId)

                if not itemAttr_a or not itemAttr_b then
                    return false
                end

                local rest = true
                if itemAttr_a.type == "房契" then
                    return true
                elseif itemAttr_b.type == "房契" then
                    return false
                end

                if itemAttr_a.type == "地契" and itemAttr_b.type == "地契" then
                    return false
                end

                if itemAttr_a.type == "地契" then
                    return true
                elseif itemAttr_b.type == "地契" then
                    return false
                end

                if itemAttr_a.canEquip == ITEM_STATE_TRUE and itemAttr_b.canEquip == ITEM_STATE_TRUE then
                    if role:checkItemIsEquip(a.id) and role:checkItemIsEquip(b.id) then
                        rest = a.itemId > b.itemId
                    elseif role:checkItemIsEquip(a.id) and not role:checkItemIsEquip(b.id) then
                        rest = true
                    elseif not role:checkItemIsEquip(a.id) and role:checkItemIsEquip(b.id) then
                        rest = false
                    else
                        rest = a.itemId > b.itemId
                    end
                elseif itemAttr_a.canEquip == ITEM_STATE_FALSE and itemAttr_b.canEquip == ITEM_STATE_FALSE then
                    rest = a.itemId > b.itemId
                elseif itemAttr_a.canEquip == ITEM_STATE_TRUE and itemAttr_b.canEquip == ITEM_STATE_FALSE then
                    rest = true
                elseif itemAttr_a.canEquip == ITEM_STATE_FALSE and itemAttr_b.canEquip == ITEM_STATE_TRUE then
                    rest = false
                end
                return rest
            end
        )
    end
    return bagItems
end

local function roleCreateSafeTable(key, tab)
    key = Helper:getDef(key, tostring(User:getUserId()))
    return createSafeTable(
        key,
        tab,
        function(tab, valueName, valueFrom, valueTo)
            Collection:memoryCheat(User:getUserId(), valueName, valueFrom, valueTo)
        end
    )
end

function ChuWuGuiLayer:initButtons()
    local createBtn = function()
        local roleButton = Resource:getUIByName("Button_4")
        Helper:convertUI(roleButton)
        roleButton.Text_buttonName:enableOutline(cc.c4b(0, 0, 0, 255), 5)
        return roleButton
    end

    local button_right = createBtn()
    local button_left = createBtn()
    self:addChild(button_right)
    self:addChild(button_left)
    button_left:move(cc.p(270, 200))
    button_right:move(cc.p(810, 200))

    button_right:setVisible(true)
    button_right.Text_buttonName:setString("确定")
    button_right:releaseFunc(
        function()
            -- self:checkRoomDsc()

            Audio:playEffect("xiaoAnNiu")

            self:hideLayer()
        end
    )

    button_left:setVisible(true)
    button_left.Text_buttonName:setString("取消")
    button_left:releaseFunc(
        function()
            Audio:playEffect("xiaoAnNiu")

            self:hideLayer()
        end
    )
end

function ChuWuGuiLayer:hideLayer()
    PopupLayerController:hideLayer(
        "ChuWuGuiLayer",
        function(layer)
            layer:hide()
        end
    )
end


function ChuWuGuiLayer:refreshUI()
    --@RefType [app.models.role.Role#Role]
    local role= User:getRole()

    local bagItems = role:getItems()

    local ckItems = role:getckItems()

    self.Text_weight:setString((#bagItems) .. "/" .. User:getRoleAttr("weight"))
    self.Text_money:setString("储物箱：" .. (#ckItems) .. "/" .. User:getRoleAttr("ckLimit"))
end

Helper:classDefNodeGetInstance(ChuWuGuiLayer)
return ChuWuGuiLayer
000000000000000