-- --[[
--     data = ['dream_goods' => '梦呓商品列表' , 'num' => '每日元宝刷新次数', 'reYb' => '下次扣除元宝', 'yuanbao' => '拥有的元宝', 'dreamCoins' => '梦境币']
-- ]]
-- local DreamSalesLayer = class("DreamSalesLayer", LayerEx)

-- --@RefType [src.app.models.DreamWorldModel.DreamSalesModel#DreamSalesModel]
-- local DreamSalesModel = require("app.models.DreamWorldModel.DreamSalesModel")

-- function DreamSalesLayer:create()
--     local p = DreamSalesLayer:new()
--     p:init()
--     return p
-- end

-- function DreamSalesLayer:init()
--     self._UI = require("Layer/MapUI/MapBagUI.lua").create()["root"]
--     self._UI:addTo(self)
--     Helper:convertUIByParent(self)
--     self:initButtons()

--     self.Text_money:setVisible(false)

--     self.Image_title.Text_title2:setString("梦呓商人")

--     self.Text_desc1:setString(User:getRole():getCHAttrName("dreamCoins")..":")

--     self:setVisible(false)
-- end

-- function DreamSalesLayer:hideLayer()
--     PopupLayerController:hideLayer(
--         "DreamSalesLayer",
--         function(layer)
--             layer:hide()
--         end
--     )
-- end

-- function DreamSalesLayer:initButtons()
--     local createBtn = function()
--         local roleButton = Resource:getUIByName("Button_4")
--         Helper:convertUI(roleButton)
--         roleButton.Text_buttonName:enableOutline(cc.c4b(0, 0, 0, 255), 5)
--         return roleButton
--     end

--     local button_right = createBtn()
--     -- local button_left = createBtn()
--     self:addChild(button_right)
--     -- self:addChild(button_left)
--     -- button_left:move(cc.p(270, 200))
--     button_right:move(cc.p(810, 130))

--     button_right:setVisible(true)
--     button_right.Text_buttonName:setString("确定")
--     button_right:releaseFunc(
--         function()
--             Audio:playEffect("xiaoAnNiu")

--             self:hideLayer()
--         end
--     )

--     local button_left = createBtn()
--     self:addChild(button_left)
--     button_left:move(cc.p(270, 130))

--     button_left:setVisible(true)
--     button_left.Text_buttonName:setString("立即刷新")
--     button_left:releaseFunc(
--         function()
--             Audio:playEffect("xiaoAnNiu")
--             local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
--             --@RefType [app.views.layer.DialogLayer.DialogALayer#DialogALayer]
--             local dialog = DialogALayer:getInstance()
--             dialog:show("此次刷新需要花费" .. self.refreshYuanBao .. "元宝，你确定吗？")
--             dialog:setWeChatVisible(false)
--             dialog:setButton1(
--                 "确定",
--                 function()
--                     DreamSalesModel:refreshGoodList(
--                         function(data)
--                             PopText("你消耗了" .. self.refreshYuanBao .. "元宝")

--                             self:refreshlist(data)
--                         end
--                     )
--                 end
--             )
--             dialog:setButton2(
--                 "取消",
--                 function()
--                 end
--             )
--         end
--     )
-- end

-- function DreamSalesLayer:showLayer(data)
--     self.role = User:getRole()

--     self._curr_money = Helper:getDef(data.dreamCoins, 0)

--     self:refreshlist(data)

--     self:refeshMoney()

--     self:show()
-- end

-- function DreamSalesLayer:refreshlist(data)
--     self.rightItems = data.dream_goods

--     self.leftItems = self.role:getItems()

--     self:initRightList()

--     self:initLeftList()

--     self:setTextDesc(data.reYb)
-- end

-- function DreamSalesLayer:refeshMoney()
--     self.Text_weight:setString(tostring(math.floor(self._curr_money)))
-- end

-- function DreamSalesLayer:initRightList()
--     -- if MapIsEmpty(self.rightItems) == true then
--     --     self.ListView_2:removeAllItems()
--     --     return
--     -- end

--     for index, sellerItem in ipairs(self.rightItems) do
--         local panel_row = self.ListView_2:getItem(index - 1)
--         if panel_row == nil then
--             panel_row = self.Panel_item2:clone()
--             Helper:convertUIByParent(panel_row)
--             self.ListView_2:pushBackCustomItem(panel_row)
--         end

--         panel_row:setVisible(true)
--         panel_row.Text_name:setColor(cc.c3b(208, 208, 208)) --设置颜色
--         local outlineColor = cc.c4b(24, 24, 24, 255)
--         local outlineWidth = 5
--         panel_row.Text_name:enableOutline(outlineColor, outlineWidth)
--         panel_row.Text_num:enableOutline(outlineColor, outlineWidth)

--         panel_row.Text_name:setString(tostring(Helper:getDef(sellerItem.nameColor ,"").. sellerItem.name))

--         panel_row.Text_num:setString(tostring(math.abs(sellerItem.price)) .. User:getRole():getCHAttrName("dreamCoins"))

--         panel_row:releaseFunc(
--             function()
--                 self:clickRightItem(sellerItem)
--             end
--         )
--     end

--     local listCount = #self.ListView_2:getItems()
--     if listCount - #self.rightItems > 0 then
--         for i = listCount - 1, #self.rightItems, -1 do
--             self.ListView_2:removeItem(i)
--         end
--     end
-- end

-- --@desc: 学习技能
-- --@author:Liang SongQiang
-- --@time:2019-09-29 12:11:48
-- --@sellerItem: 要学习的技能数据
-- function DreamSalesLayer:clickRightItem(sellerItem)
--     --@desc 学习技能
--     DreamSalesModel:buySkill(
--         sellerItem,
--         function(data, errmsg)
--             if errmsg ~= nil or errmsg == "" then
--                 PopText(errmsg)
--                 return
--             end

--             self._curr_money = data.point

--             self:refeshMoney()
--         end
--     )
-- end

-- --@desc: 初始化左边列表
-- --@author:Liang SongQiang
-- --@time:2019-10-09 10:17:59
-- function DreamSalesLayer:initLeftList()
--     local listItemCount = 0
--     for index, roleItem in ipairs(self.leftItems) do
--         --@region 列表UI初始化设置
--         local panel_row = self.ListView_1:getItem(listItemCount)
--         if panel_row == nil then
--             panel_row = self.Panel_item1:clone()
--             Helper:convertUIByParent(panel_row)
--             self.ListView_1:pushBackCustomItem(panel_row)
--         end
--         panel_row:setVisible(true)
--         panel_row.Text_name:setColor(cc.c3b(208, 208, 208))
--         --设置默认颜色
--         local outlineColor = cc.c4b(24, 24, 24, 255)
--         local outlineWidth = 5
--         panel_row.Text_name:enableOutline(outlineColor, outlineWidth)
--         --@endregion

--         if roleItem ~= nil then
--             listItemCount = listItemCount + 1

--             local item = self.role:getOneItemByKey(roleItem.itemId)

--             if roleItem.wpType == "神兵" then
--                 panel_row.Text_name:setString(item.name)
--             else
--                 panel_row.Text_name:setString(tostring(item.name) .. " X " .. tostring(roleItem.count))
--             end

--             panel_row:releaseFunc(
--                 function()
--                     PopText("该处不可出售或丢弃物品")
--                 end
--             )
--         else
--             if PRINT_MODE == 1 then
--                 print("item is not found of itemId : " .. roleItem.itemId)
--             end
--         end
--     end

--     local listCount = #self.ListView_1:getItems()
--     if listCount - listItemCount > 0 then
--         for i = listCount - 1, listItemCount, -1 do
--             self.ListView_1:removeItem(i)
--         end
--     end
-- end

-- function DreamSalesLayer:setTextDesc(yuanbao)
--     yuanbao = Helper:getDef(yuanbao, 0)
--     self.refreshYuanBao = yuanbao
--     self.Text_desc:setVisible(true)
--     if yuanbao == 0 then
--         self.Text_desc:setString("每天0点自动刷新\n此次刷新免费")
--     else
--         self.Text_desc:setString("每天0点自动刷新\n或花费" .. tostring(self.refreshYuanBao) .. "元宝")
--     end
-- end

-- Helper:classDefNodeGetInstance(DreamSalesLayer)
-- return DreamSalesLayer
0000000000000