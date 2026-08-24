-- add by XiaoZhiWei 2017/09/13 19:14:36 未调用


-- local ZengYuLayer = class("ZengYuLayer", require("app.views.base.BaseLayer"))

-- function ZengYuLayer:create()
--     local p = ZengYuLayer:new()
--     p:init()
--     return p
-- end

-- function ZengYuLayer:init()
--     self._UI = require("Layer/YongBingUI/ZengYuUI.lua").create()['root']
--     self._UI:addTo(self)

--     Helper:convertUI(self)-- 获得所有子节点

--     self:setBack()

--     self:hide()-- 隐藏自身
-- end

-- -----------------------------------------------------------------------------------------------------------
-- -- @author XiaoZhiWei
-- -- @time 2017/04/26 22:09:16
-- -- @desc 渲染显示
-- function ZengYuLayer:showLayer()
-- 	self:refresh()
-- 	self:show(true)
-- end

-- -----------------------------------------------------------------------------------------------------------
-- -- @author XiaoZhiWei
-- -- @time 2017/05/03 10:23:49
-- -- @desc 刷新界面
-- function ZengYuLayer:refresh()
-- 	local role = User:getRole()
-- 	self:setBagList(role:getZengYuItemList())
-- 	self:setWeight(#role:getItems(), role:getAttr("weight"))
-- end

-- -----------------------------------------------------------------------------------------------------------
-- -- @author XiaoZhiWei
-- -- @time 2017/04/26 21:58:31
-- -- @desc 显示物品信息
-- function ZengYuLayer:showItemDesc(item, itemAttr)
-- 	if itemAttr == nil or item == nil then
-- 		return
-- 	end
-- 	local panel = self.Panel_itemDesc
-- 	Helper:convertUIByParent(panel)
-- 	self:itemDescShow(true)

-- 	local role = User:getRole()
-- 	panel.Image_back.Panel_title.Text_name:setString("DWT")
-- 	panel.Image_back.Panel_title.Text_name:setString(itemAttr.name)
-- 	panel.Image_back.Panel_title.Text_zhuangbei:setString(itemAttr.type)
-- 	panel.Image_back.TextField_desc:setString(itemAttr:getDsc())
-- 	panel.Text_onlyid:setString(itemAttr.id)
-- 	panel.Image_back.Image_button.Text_chuan:setString("赠\n予")
-- 	panel.Image_back.Image_button:setTouchEnabled(true)
-- 	panel.Image_back:setTouchEnabled(true)
-- 	panel.Image_back.Image_button:releaseFunc(function()
-- 		role:giveItem(item, role:getCurrMap():getYongBingRole())
-- 		self:itemDescHide(true)
-- 		self:refresh()
--     end)
-- end


-- -- 物品描述显示
-- function ZengYuLayer:itemDescShow(anim)
-- 	self.Panel_itemDesc:setTouchEnabled(true)
-- 	self.Is_show = true
-- 	local self = self.Panel_itemDesc
-- 	self:setVisible(true)
-- 	local actionTag = self:getActionTagByName("move")
-- 	self:stopActionByTag(actionTag)
-- 	self:move(cc.p(380, 1710))
-- 	local action = cc.Sequence:create(
-- 		cc.Spawn:create(
-- 			cc.MoveTo:create(UI_ANIM_DURATION, cc.p(380, 1540)),
-- 			cc.FadeIn:create(UI_ANIM_DURATION)
-- 		),
-- 		cc.CallFunc:create(
-- 			function()
-- 			end))
-- 	action:setTag(actionTag)
-- 	self:runAction(action)
-- end

-- -- 物品描述隐藏
-- function ZengYuLayer:itemDescHide(anim)
-- 	self.Panel_itemDesc:setTouchEnabled(false)
-- 	Helper:callChildrenByParent(self.Panel_itemDesc,function(parent,child)
-- 	 	child:setTouchEnabled(false)
-- 	 end)
-- 	self.Is_show = false
-- 	local self = self.Panel_itemDesc
-- 	local actionTag = self:getActionTagByName("move")
-- 	self:stopActionByTag(actionTag)
-- 	self:setCascadeOpacityEnabled(true)
-- 	self:callAllChild(function(child)
-- 			child:setCascadeOpacityEnabled(true)
-- 		end)
-- 	local action = cc.Sequence:create(
-- 		cc.Spawn:create(
-- 			cc.MoveTo:create(UI_ANIM_DURATION, cc.p(380, 1710)),
-- 			cc.FadeOut:create(UI_ANIM_DURATION)
-- 			),
-- 		cc.CallFunc:create(
-- 			function()
-- 			end))
-- 	action:setTag(actionTag)
-- 	self:runAction(action)
-- end

-- -----------------------------------------------------------------------------------------------------------
-- -- @author XiaoZhiWei
-- -- @time 2017/05/03 10:20:41
-- -- @desc 设置背包容量
-- function ZengYuLayer:setWeight(nowCount, totalWeight)
-- 	nowCount = Helper:mathFloor(Helper:getDef(nowCount, 0))
-- 	totalWeight = Helper:mathFloor(Helper:getDef(totalWeight, 30)) 
-- 	self.Text_weight:setString(nowCount.."/"..totalWeight)
-- end

-- -----------------------------------------------------------------------------------------------------------
-- -- @author XiaoZhiWei
-- -- @time 2017/04/26 15:27:41
-- -- @desc 设置赠与背包列表
-- function ZengYuLayer:setBagList(items)
-- 	items = Helper:getDef(items, {})
-- 	local listLength = #self.ListView_list:getItems()
-- 	if listLength < #items then
-- 		listLength = #items
-- 	end
-- 	local item
-- 	for i=1,listLength do
-- 		if i > #items then
-- 			self.ListView_list:removeLastItem()
-- 		else
-- 			local itemAttr = Item:getOneItemByKey(items[i].itemId)
-- 			if itemAttr ~= nil then
-- 				item = self.ListView_list:getItem(i - 1)
-- 				if item == nil then
-- 					item = self:cloneItem()
-- 					self.ListView_list:pushBackCustomItem(item)
-- 				else
-- 				end
-- 				if itemAttr.type == "药品" or itemAttr.type == "药材" then
-- 					item.Text_name:setString(itemAttr.name.." X"..items[i].count)
-- 				else
-- 					item.Text_name:setString(itemAttr.name)
-- 				end
-- 				item:releaseFunc(function()
-- 					self:showItemDesc(items[i], itemAttr)
-- 				end)
-- 			end
-- 		end
-- 	end
-- end

-- -----------------------------------------------------------------------------------------------------------
-- -- @author XiaoZhiWei
-- -- @time 2017/04/26 15:41:20
-- -- @desc 克隆物品列表
-- function ZengYuLayer:cloneItem()
-- 	local item = self.Panel_item:clone()
-- 	Helper:convertUI(item)
-- 	item.Text_name:enableOutline(cc.c4b(0, 0, 0, 255), 5)
-- 	return item
-- end

-- -----------------------------------------------------------------------------------------------------------
-- -- @author XiaoZhiWei
-- -- @time 2017/04/27 10:39:59
-- -- @desc 背景点击事件
-- function ZengYuLayer:setBack()
-- 	local func = function()
-- 		local RoleObserveLayer = require("app.views.layer.RoleLayer.RoleObserveLayer")
-- 	 	local roleObserveLayer = RoleObserveLayer:getInstance()
--         roleObserveLayer.mapLayer = require("app.views.layer.ControllLayer"):getInstance():getLayer("MapLayer")
--         roleObserveLayer:showLayer()
--         roleObserveLayer:setMapRole(User:getRole():getCurrMap():getYongBingRole())
--         self:itemDescHide(true)
--         self:hide(true)
-- 	end

-- 	self.Panel_back:releaseFunc(function()
-- 		func()
-- 	end)
-- end

-- Helper:classDefNodeGetInstance(ZengYuLayer)
-- return ZengYuLayer
000000000000000