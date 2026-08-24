-- local DrCuilianLayer = class("DrCuilianLayer", LayerEx)

-- --@RefType [src.app.models.DreamWorldModel.DreamEquip#DreamEquip]
-- local DreamEquip = require("app.models.DreamWorldModel.DreamEquip")

-- function DrCuilianLayer:create()
--     local p = DrCuilianLayer:new()
--     p:init()
--     return p
-- end

-- function DrCuilianLayer:init()
--     self._UI = require("Layer/DreamWorldUI/DrCuiLianUI.lua").create()["root"]
--     self._UI:addTo(self)
--     Helper:convertUIByParent(self)

--     self:initRichText()

--     self.Button_Give:releaseFunc(
--         function()
--             local result, errmsg = DreamEquip:cuilian(self.role, self.equip_weapon)
--             if result == true then
--                 self:print("淬炼成功")
--                 self:refreshUI()
--             else
--                 if errmsg ~= nil then
--                     PopText(errmsg)
--                 end
--             end
--         end
--     )

--     self.Image_title.Button_back:releaseFunc(
--         function()
--             self:hideLayer()
--         end
--     )
-- end

-- function DrCuilianLayer:hideLayer()
--     PopupLayerController:hideLayer(
--         "DrCuilianLayer",
--         function(layer)
--             layer:hide()
--         end
--     )
-- end

-- function DrCuilianLayer:showLayer(role, map)
--     if role == nil then
--         self:hideLayer()
--         return false
--     end

--     self.map = map

--     self.equip_weapon = role:getEquipByName("weapon")
--     if self.equip_weapon == nil then
--         PopText("你未装备武器")
--         self:hideLayer()
--         return false
--     end

--     self.Text_gold:setString("『"..User:getRole():getCHAttrName("dreamPoints").."』")

--     self.role = role

--     self:refreshUI()

--     self:show()
-- end

-- function DrCuilianLayer:refreshUI()
--     self.weapon_info = self.role:getOneItemByKey(self.equip_weapon.itemId)
--     self:initDreamPoints()
--     self:initWeaponInfo()
--     self:initAttrPanel()
-- end

-- function DrCuilianLayer:initDreamPoints()
--     if self.map ~= nil and self.map:getMapType() == MAP_TYPE.DREAMMAP then
--         local role = self.map:getPlayer()
--         self.dreamPoints = role:getAttr("dreamPoints")
--     else
--         self.dreamPoints = 0
--     end
--     self.Text_gold_num:setString(self.dreamPoints)
-- end

-- function DrCuilianLayer:initWeaponInfo()
--     local num = 0

--     local stage = self.weapon_info.armsstage

--     num = stage * 100

--     self.Text_num:setString("该神兵已成功淬炼：" .. num .. "次")
--     self.Image_Desc.Text_name:setString(self.weapon_info.name)
--     self.Image_Desc.Text_damge:setString("伤害力+" .. tostring(Helper:mathFloor(self.weapon_info:getWeaponDamage())))
--     self.Image_Desc.Text_dsc:setString(self.weapon_info.dsc)
-- end

-- function DrCuilianLayer:initRichText()
--     local x, y = self.Image_help.Panel_talk:getPosition()
--     local size = self.Image_help.Panel_talk:getContentSize()

--     if self.RichText_print then
--         self.RichText_print:removeFromParent()
--         self.RichText_print = nil
--     end

--     local richTextScroll = ExtRichTextScroll:create()
--     self.Image_help.Panel_talk:getParent():addChild(richTextScroll)
--     richTextScroll:move(cc.p(27, 22))
--     richTextScroll:setSize(size)
--     richTextScroll:setDirection(kCCScrollViewDirectionVertical)
--     richTextScroll:getRichText():setVerticalSpace(5)
--     self.RichText_print = richTextScroll

--     self.RichText_print:setBounceEnabled(true)
-- end

-- local ShenBingDesc = require("app.models.ShenBing.ShenBingDesc")

-- function DrCuilianLayer:initAttrPanel()
--     local attr_panel = self.Panel_Attr

--     self:initYinDuDsc(attr_panel.Panel_attr_1)
--     self:initJianRenDsc(attr_panel.Panel_attr_2)
--     self:initZhuangTaiDsc(attr_panel.Panel_attr_3)
--     self:initZhongLiangDsc(attr_panel.Panel_attr_4)
--     self:initEffectDsc(attr_panel.Panel_attr_5)
-- end

-- function DrCuilianLayer:initYinDuDsc(panel)
--     local descList = ShenBingDesc:getYingDuDesc(self.weapon_info)

--     panel.Text_name:setString("【硬度】")

--     panel.Text_name_dsc:setString(descList.hard1level)

--     panel.Panel_touch:releaseFunc(
--         function()
--             local tip_desc1 = "一把武器的硬度决定了它击碎他人的武器的难易程度。"
--             local tip_desc2 = descList.hard1text
--             local value = "硬度值：" .. Helper:mathFloor(self.weapon_info:getWeaponYingDu())
--             self:openTips(panel, tip_desc1, tip_desc2, value)
--         end
--     )
-- end

-- function DrCuilianLayer:initJianRenDsc(panel)
--     local descList = ShenBingDesc:getRenDuDesc(self.weapon_info)

--     panel.Text_name:setString("【坚韧】")

--     panel.Text_name_dsc:setString(descList.Tenacity1level)

--     panel.Panel_touch:releaseFunc(
--         function()
--             local tip_desc1 = "一把武器的坚韧度决定了它被他人武器击碎的难易程度。"
--             local tip_desc2 = descList.hard1text
--             local value = "韧度值：" .. Helper:mathFloor(self.weapon_info:getWeaponRenDu())
--             self:openTips(panel, tip_desc1, tip_desc2, value)
--         end
--     )
-- end

-- function DrCuilianLayer:initZhuangTaiDsc(panel)
--     local str, text = ShenBingDesc:getShenBingStatusDesc(self.weapon_info)

--     panel.Text_name:setString("【状态】")

--     panel.Text_name_dsc:setString(str)

--     panel.Panel_touch:releaseFunc(
--         function()
--             local tip_desc1 = "一把武器状态决定它的伤害力，未达完美状态的武器可经修理达到完美状态。"
--             local tip_desc2 = text
--             self:openTips(panel, tip_desc1, tip_desc2)
--         end
--     )
-- end

-- function DrCuilianLayer:initZhongLiangDsc(panel)
--     local descList = ShenBingDesc:getWeightDesc(self.weapon_info)

--     panel.Text_name:setString("【重量】")

--     panel.Text_name_dsc:setString(descList.weight1level)

--     panel.Panel_touch:releaseFunc(
--         function()
--             local tip_desc1 = "一把武器的重量值不仅决定了它是否容易被人击飞与击飞他人武器的难易程度，同时它也会影响攻击速度。"
--             local tip_desc2 = descList.weight1text
--             local value = "重量值：" .. Helper:mathFloor(self.weapon_info:getWeaponWeight())
--             self:openTips(panel, tip_desc1, tip_desc2, value)
--         end
--     )
-- end

-- function DrCuilianLayer:initEffectDsc(panel)
--     local effects = {
--         effect1 = ShenBingDesc:getEffctOne(self.weapon_info),
--         effect2 = ShenBingDesc:getEffctTwo(self.weapon_info),
--         effect3 = ShenBingDesc:getEffctThree(self.weapon_info)
--     }

--     local str = ""

--     for i = 1, 3 do
--         local effect = effects["effect" .. i]
--         if effect ~= nil then
--             str = effect.name .. " "
--         end
--     end

--     if str == "" then
--         str = "HIW无NOR"
--     end

--     panel.Text_name:setString("【特性】")

--     panel.Text_name_dsc:setString(str)

--     panel.Panel_touch:releaseFunc(
--         function()
--             local tip_desc1 = "一把武器的特性决定了它的各种效果。"
--             self:openTips(panel, tip_desc1)
--         end
--     )
-- end

-- --@desc: 打开信息提示窗
-- --@author:Liang SongQiang
-- --@time:2019-09-26 17:05:09
-- function DrCuilianLayer:openTips(panel, tip_desc1, tip_desc2, value)
--     if tip_desc1 ~= nil then
--         self.Panel_Tip.Text_desc1:setString(tip_desc1)
--         self.Panel_Tip.Text_desc1:setVisible(true)
--     else
--         self.Panel_Tip:setVisible(false)
--     end

--     if tip_desc2 ~= nil then
--         self.Panel_Tip.Text_desc2:setString(tip_desc1)
--         self.Panel_Tip.Text_desc2:setVisible(true)
--     else
--         self.Panel_Tip.Text_desc2:setVisible(false)
--     end

--     if value ~= nil then
--         self.Panel_Tip.Text_Val:setString(value)
--         self.Panel_Tip.Text_Val:setVisible(true)
--     else
--         self.Panel_Tip.Text_Val:setVisible(false)
--     end

--     self.Panel_Tip:setVisible(true)
--     self.Panel_Tip:releaseFunc(
--         function()
--             self.Panel_Tip:setVisible(false)
--             panel.Image_7:setVisible(true)
--         end
--     )
-- end

-- function DrCuilianLayer:setYinDuTip(panel)
--     local descList = ShenBingDesc:getYingDuDesc(self.weapon_info)
--     panel.Text_name:setString("【硬度】")
--     panel.Text_name_dsc:setString(descList.hard1level)
-- end

-- local textColor = cc.c3b(102, 153, 153)
-- function DrCuilianLayer:print(str, verticalSpace)
--     local textHeight = self.RichText_print:getRichText():getNewContentSizeHeight()
--     if textHeight >= 6888 then
--         self:initRichText()
--     end

--     self.RichText_print:pushBackText(str, textColor, 255, Resource:getFontPath("default"), 42)

--     if verticalSpace ~= nil and type(verticalSpace) == "number" then
--         self.RichText_print:pushBackNewLine(verticalSpace)
--     else
--         self.RichText_print:pushBackNewLine()
--     end
-- end

-- Helper:classDefNodeGetInstance(DrCuilianLayer)
-- return DrCuilianLayer
000000000000