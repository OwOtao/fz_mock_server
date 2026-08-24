local YongBingBagLayer = class("YongBingBagLayer", LayerEx)
--[[
	佣兵交易界面,继承自副本交易界面
]]

function YongBingBagLayer:create()
    local p = YongBingBagLayer:new()
    p:init()
    return p
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/05/05 15:26:53
-- @desc 界面初始化
function YongBingBagLayer:init()
	self._UI = require("Layer/MapUI/MapBagUI.lua").create()['root']
	self._UI:addTo(self)

	Helper:convertUIByParent(self)

	self:initButtons()
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/05/05 15:26:46
-- @desc 显示界面
function YongBingBagLayer:showLayer(leftRole, rightRole, func)
	self:setButton2(func)
	self.Image_title.Text_title2:setString(rightRole:getName())
	self:refreshLayer(leftRole, rightRole)
	self:show()
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/05/05 16:03:04
-- @desc 刷新列表
function YongBingBagLayer:refreshLayer(leftRole, rightRole)
	self:setBagListLeft(leftRole:getZengYuItemList(), leftRole, rightRole)
	self:setBagListRight(leftRole:getMapNpcItemList(rightRole.AttrModifyId), leftRole, rightRole)
	self:setWeight(leftRole:getNowWeight(), leftRole:getAttr("weight"))
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/05/05 15:36:51
-- @desc 设置左边背包
function YongBingBagLayer:setBagListLeft(list, leftRole, rightRole)
	if MapIsEmpty(list) == true or leftRole == nil or rightRole == nil then
		self.ListView_1:removeAllItems()
		return
	end
	local length = #self.ListView_1:getItems()
	if length < #list then
		length = #list
	end
	for i=1,length do
		if i > #list then
			self.ListView_1:removeLastItem()
		else
			local itemAttr = Item:getOneItemByKey(list[i].itemId)
			if itemAttr ~= nil then
				local item = self.ListView_1:getItem(i -1)
				if item == nil then
					item = self:createLeftItem()
					self.ListView_1:pushBackCustomItem(item)
				end
				-- 对于无颜色物品需重置item颜色
				item.Text_name:setColor(cc.c3b(255,255,255))
				if itemAttr.type == "药品" or itemAttr.type == "药材" then
					item.Text_name:setString(itemAttr.name.." X"..list[i].count)
				else
					item.Text_name:setString(itemAttr.name)
				end
				item:releaseFunc(function()
					leftRole:giveItem(list[i], rightRole, function() self:refreshLayer(leftRole, rightRole) end)
				end)
			end
		end
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/05/05 16:24:06
-- @desc 设置右边背包
function YongBingBagLayer:setBagListRight(list, leftRole, rightRole)
	if MapIsEmpty(list) == true or leftRole == nil or rightRole == nil then
		self.ListView_2:removeAllItems()
		return
	end
	local length = #self.ListView_2:getItems()
	if length < #list then
		length = #list
	end
	for i=1,length do
		if i > #list then
			self.ListView_2:removeLastItem()
		else
			local itemAttr = Item:getOneItemByKey(list[i].itemId)
			if itemAttr ~= nil then
				local item = self.ListView_2:getItem(i -1)
				if item == nil then
					item = self:createRightItem()
					self.ListView_2:pushBackCustomItem(item)
				end
				-- 对于无颜色物品需重置item颜色
				item.Text_name:setColor(cc.c3b(255,255,255))
				item.Text_name:setString(itemAttr.name)
				item:releaseFunc(function()
					-- leftRole:giveItem(list[i], rightRole)
					
					self:refreshLayer(leftRole, rightRole)
				end)
			end
		end
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/05/05 15:39:24
-- @desc  创建左边背包栏目
function YongBingBagLayer:createLeftItem()
	local row = self.Panel_item1:clone()
	Helper:convertUI(row)

	row:setVisible(true)
	local outlineColor = cc.c4b(24, 24, 24, 255)
	local outlineWidth = 5
	row.Text_name:enableOutline(outlineColor, outlineWidth)
	return row
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/05/05 16:27:24
-- @desc 创建右边背包栏目
function YongBingBagLayer:createRightItem()
	local row = self.Panel_item2:clone()
	Helper:convertUI(row)
	row:setVisible(true)
	local outlineColor = cc.c4b(24, 24, 24, 255)
	local outlineWidth = 5
	row.Text_name:enableOutline(outlineColor, outlineWidth)
	row.Text_num:enableOutline(outlineColor, outlineWidth)
	row.Text_num:setVisible(false)
	return row
end


--按钮初始化
function YongBingBagLayer:initButtons()
	local button1 = self:createButton() --关闭按钮
	local button2 = self:createButton() --确定按钮
	self:addChild(button1)
	self:addChild(button2)
	button1:move(cc.p(270, 200))
	button2:move(cc.p(810, 200))
	self.Button_1 = button1
	self.Button_2 = button2
	button1:setVisible(false)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/05/05 14:59:50
-- @desc 创建按钮
function YongBingBagLayer:createButton()
	local roleButton = Resource:getUIByName("Button_4")
	Helper:convertUI(roleButton)
	roleButton.Text_buttonName:enableOutline(cc.c4b(0, 0, 0, 255), 5)
	return roleButton
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/05/05 15:00:00
-- @desc 设置按钮2
function YongBingBagLayer:setButton2(func)
	self.Button_2.Text_buttonName:setString("确定")
	self.Button_2:releaseFunc(function()
		if func then
			func()
		end
		PopupLayerController:hideLayer("YongBingBagLayer", function(layer)
			self:hide()
		end)
	end)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/05/09 16:44:15
-- @desc 设置背包重量
function YongBingBagLayer:setWeight(nowCount, maxCount)
	nowCount = Helper:getDef(nowCount, 0)
	maxCount = Helper:getDef(maxCount, 0)
	self.Text_weight:setString(nowCount.."/"..maxCount)
end


Helper:classDefNodeGetInstance(YongBingBagLayer)
return YongBingBagLayer0000000000