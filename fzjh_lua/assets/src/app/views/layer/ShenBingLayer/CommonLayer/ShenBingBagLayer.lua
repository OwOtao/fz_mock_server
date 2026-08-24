local ShenBingBagLayer = class("ShenBingBagLayer", cc.Layer)

--@RefType [app.views.layer.ShenBingLayer.CommonLayer.binding#binding]
local binding = require("app.views.layer.ShenBingLayer.CommonLayer.binding")

local Resource = require("app.Resource")

local leftTable = {}
local rightTable = {}

local ignoreTbKey = {
	__index = true,
	__newindex = true,
	bind____ = true,
	maxn____ = true
}

function ShenBingBagLayer:create()
	local p = ShenBingBagLayer:new()
	p:init()
	return p
end

function ShenBingBagLayer:init()
	self._UI = require("Layer/MapUI/MapBagUI.lua").create() ['root']
	self._UI:addTo(self)
	Helper:convertUIByParent(self)
	self:setCondiPushRightList()
	self:setCondiPushLeftList()
	self:initButton()
	self:setTextMoney()
	self:setTextWeight()
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/01/22 16:49:27
-- @desc 修复ListView中不显示问题
function ShenBingBagLayer:showLayer()
	self.ListView_2:jumpToTop()
	self.ListView_1:jumpToTop()
	self:show()
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/01/10 17:55:30
-- @desc 防作弊
function ShenBingBagLayer:createSafeItem(itemData)
	-- local itemId = tostring(itemData.itemId)
	-- return createEncryptTable(itemData)
	-- add by XiaoZhiWei 2017/08/30 12:14:13 修改为防作弊方式
	return createSafeTable("ShenBingBagLayer.item."..tostring(itemData.itemId), itemData, function(itemData, valueName, valueFrom, valueTo)
		Collection:memoryCheat(User:getUserId(), valueName, valueFrom, valueTo)
	end)
end

--@desc: 创建下方两个按钮
--@author:Liang SongQiang
--@time:2017-12-19 18:21:01
function ShenBingBagLayer:initButton()
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
	self.btnRight = button_right
	self.btnLeft = button_left
end


--@desc: 给右边列表添加item,item结构不支持内嵌table
--@author:Liang SongQiang
--@time:2017-12-15 21:00:55
--@itemData: {itemId="xxx",count=10}  
--@clickRowFuc: item的点击自定义方法，可为nil
function ShenBingBagLayer:pushItemToRightList(itemData, rightFunc,leftFunc)
	if itemData == nil and type(itemData) ~= "table" then
		print("itemData 传值错误！！！！！")
		return
	end
	
	if itemData.count == nil then
		itemData.count = 1
	end
	itemData = self:createSafeItem(itemData)
	if itemData._tag and rightTable[itemData._tag] then
		local data = rightTable[itemData._tag]
		data.count = data.count + itemData.count
		return
	end
	
	
	local item = Item:getOneItemByKey(itemData.itemId)
	
	--@desc 如果该物品可叠加的情况
	if item.canFold == ITEM_STATE_TRUE then
		for k, v in pairs(rightTable) do
			if itemData.itemId == v.itemId and v.count < 99 and v.count + itemData.count < 99 then
				v.count = v.count + itemData.count
				return
			end
		end
	end
	
	
	local row = self.Panel_item2:clone()
	Helper:convertUI(row)
	row:setVisible(true)
	row.Text_name:enableOutline(cc.c4b(0, 0, 0, 255), 5)
	
	--@desc 创建可绑定数据结构
	local tempData = binding.bindable({
		name = item.name,
		count = 0
	})
	
	row.data = binding.bindable({
		count = 0
	})
	
	row.Text_name:setString(tostring(tempData.name))
	--@desc 绑定数据，当tempData.count 改变时，row.data也会改变，并且会运行自定义方法
	local tag = binding.bind(tempData, "count", row.data, "count", function(newVal, oldVal)
		row.Text_num:setString(tostring("X " .. newVal))
		return newVal
	end)
	
	for k, v in pairs(itemData) do
		tempData[k] = v
		if k ~= "count" then
			row.data[k] = v
		end
	end
	
	if leftFunc then
		tempData.clickLeftFunc = leftFunc
	end

	if rightFunc then
		tempData.clickRightFunc = rightFunc
	end
	
	if not tempData._tag then
		tempData._tag = Helper:getOnlyId()
	end
	rightTable[tempData._tag] = tempData
	
	self.ListView_2:pushBackCustomItem(row)
	
	
	row:releaseFunc(function()
		local temp = {}
		for k, v in pairs(getmetatable(tempData)) do
			if not ignoreTbKey[k] then
				temp[k] = v
			end
		end
		if tempData.count > 1 then
			temp.count = 1
		end
		-- print("-------------------pushItemToRightList------------------------")
		-- Helper:print_lua_table(temp)
		if self:checkCanPushLeftList(temp) then
			if tempData.clickRightFunc then
				-- tempData.clickrightFunc(temp)
				tempData.clickRightFunc(temp, 
					function() 
						self:pushItemToLeftList(temp)
						tempData.count = tempData.count - 1
					
						if tempData.count == 0 then
							self.ListView_2:removeItem(self.ListView_2:getIndex(row))

				--@desc 移除row的时候把对应的数据结构清除
							rightTable[tempData._tag] = nil
			
							--@desc 解除绑定
							binding.unbind(tempData, "count", tag)
						end
					 end)
			else
				self:pushItemToLeftList(temp)
				
				tempData.count = tempData.count - 1
				
				if tempData.count == 0 then
					self.ListView_2:removeItem(self.ListView_2:getIndex(row))

					--@desc 移除row的时候把对应的数据结构清除
					rightTable[tempData._tag] = nil

					--@desc 解除绑定
					binding.unbind(tempData, "count", tag)
				end
			end
			
		end
	end)
end

--@desc: 给左边列表添加item,item结构不支持内嵌table
--@author:Liang SongQiang
--@time:2017-12-16 18:23:45
--@itemData: [app.models.item.BaseItem#BaseItem]
--@clickFunc: item的点击自定义方法，可为nil
function ShenBingBagLayer:pushItemToLeftList(itemData, leftFunc,rightFunc)
	if itemData == nil and type(itemData) ~= "table" then
		print("itemData 传值错误！！！！！")
		return
	end
	

	if itemData.count == nil then
		itemData.count = 1
	end
	
	itemData = self:createSafeItem(itemData)

	if itemData._tag and leftTable[itemData._tag] then
		local data = leftTable[itemData._tag]
		data.count = data.count + itemData.count
		return
	end
	
	
	local item = Item:getOneItemByKey(itemData.itemId)
	if item == nil then
		print("----------------------------:",itemData.itemId)
	end
	if item.canFold == ITEM_STATE_TRUE then
		for k, v in pairs(leftTable) do
			if itemData.itemId == v.itemId and v.count < 99 and v.count + itemData.count < 99 then
				v.count = v.count + itemData.count
				return
			end
		end
	end
	
	
	local row = self.Panel_item1:clone()
	Helper:convertUI(row)
	row:setVisible(true)
	row.Text_name:enableOutline(cc.c4b(0, 0, 0, 255), 5)
	
	local tempData = binding.bindable({
		name = item.name,
		count = 0
	})
	
	row.data = binding.bindable({
		count = 0
	})
	
	local tag = binding.bind(tempData, "count", row.data, "count", function(newVal, oldVal)
		if newVal > 1 then
			row.Text_name:setString(tostring(item.name) .. " X " .. tostring(newVal))
		else
			row.Text_name:setString(tostring(item.name))
		end
		
		return newVal
	end)
	
	for k, v in pairs(itemData) do
		tempData[k] = v
		if k ~= "count" then
			row.data[k] = v
		end
	end
	
	if leftFunc then
		tempData.clickLeftFunc = leftFunc
	end
	
	if rightFunc then
		tempData.clickRightFunc = rightFunc
	end

	if not tempData._tag then
		tempData._tag = Helper:getOnlyId()
	end
	leftTable[tempData._tag] = tempData
	
	self.ListView_1:pushBackCustomItem(row)
	
	row:releaseFunc(function()
		local temp = {}
		for k, v in pairs(getmetatable(tempData)) do
			if  not ignoreTbKey[k] then
				temp[k] = v
			end
		end
		if tempData.count > 1 then
			temp.count = 1
		end
		print("-------------------pushItemToLeftList------------1111------------")
		Helper:print_lua_table(temp)
		if self:checkCanPushRightList(temp) then
			if tempData.clickLeftFunc then
				tempData.clickLeftFunc(temp, 
					function() 
						self:pushItemToRightList(temp)
						
						tempData.count = tempData.count - 1
						
						if tempData.count == 0 then
							self.ListView_1:removeItem(self.ListView_1:getIndex(row))
							leftTable[tempData._tag] = nil
							binding.unbind(tempData, "count", tag)
						end
					 end)
			else
				self:pushItemToRightList(temp)		
				tempData.count = tempData.count - 1
				
				if tempData.count == 0 then
					self.ListView_1:removeItem(self.ListView_1:getIndex(row))
					leftTable[tempData._tag] = nil
					binding.unbind(tempData, "count", tag)
				end
			end
		end
	end)
	
end


--@desc: 设置右边按钮的点击方法
--@author:Liang SongQiang
--@time:2017-12-16 18:22:32
--@func: 按钮的执行逻辑,参数为右边列表的item信息
--@name: 按钮显示文本 
function ShenBingBagLayer:btnRightClickFunc(func, name)
	if name == nil then
		self.btnRight:setVisible(false)
		return
	end
	
	self.btnRight.Text_buttonName:setString(name)
	self.btnRight:releaseFunc(function()
		Audio:playEffect("xiaoAnNiu")
		local rightList = self.ListView_2:getItems()
		local leftList = self.ListView_1:getItems()
		local callbackRightList = {}
		local callbackLeftList = {}
		
		for k, v in pairs(rightList) do
			local temp = {}
			for k, v in pairs(getmetatable(v.data)) do
				if  not ignoreTbKey[k] then
					temp[k] = v
				end
			end
			table.insert(callbackRightList, temp)
		end

		for k, v in pairs(leftList) do
			local temp = {}
			for k, v in pairs(getmetatable(v.data)) do
				if  not ignoreTbKey[k] then
					temp[k] = v
				end
			end
			table.insert(callbackLeftList, temp)
		end

		func(callbackLeftList,callbackRightList)
	end)

end


--@desc: 设置左边按钮的点击方法
--@author:Liang SongQiang
--@time:2017-12-16 18:21:48
--@func: 按钮的执行逻辑
--@name: 按钮显示文本 
function ShenBingBagLayer:btnLeftClickFunc(func, name)
	if func == nil or name == nil then
		self.btnLeft:setVisible(false)
		return
	end
	self.btnLeft:setVisible(true)
	name = Helper:getDef(name, "取消")
	self.btnLeft.Text_buttonName:setString(name)
	self.btnLeft:releaseFunc(function()
		Audio:playEffect("xiaoAnNiu")
		local rightList = self.ListView_2:getItems()
		local leftList = self.ListView_1:getItems()
		local callbackRightList = {}
		local callbackLeftList = {}
		
		for k, v in pairs(rightList) do
			local temp = {}
			for k, v in pairs(getmetatable(v.data)) do
				if  not ignoreTbKey[k] then
					temp[k] = v
				end
			end
			table.insert(callbackRightList, temp)
		end

		for k, v in pairs(leftList) do
			local temp = {}
			for k, v in pairs(getmetatable(v.data)) do
				if  not ignoreTbKey[k] then
					temp[k] = v
				end
			end
			table.insert(callbackLeftList, temp)
		end

		func(callbackLeftList,callbackRightList)
		-- func()
	end)
end

--@desc: 设置是否可以放入右边list的条件
--@author:Liang SongQiang
--@time:2017-12-16 18:17:51
--@func: 自定义条件
function ShenBingBagLayer:setCondiPushRightList(func)
	self.checkCanPushRightList = function(self, currItem)
		local rightList = self.ListView_2:getItems()
		local leftList = self.ListView_1:getItems()
		if func then
			local tempLeft = {}
			local tempRight = {}
			
			for k, v in pairs(rightList) do
				local temp = {}
				for k, v in pairs(getmetatable(v.data)) do
					if  not ignoreTbKey[k] then
						temp[k] = v
					end
				end
				table.insert(tempRight, temp)
			end
			
			for k, v in pairs(tempLeft) do
				local temp = {}
				for k, v in pairs(getmetatable(v.data)) do
					if  not ignoreTbKey[k] then
						temp[k] = v
					end
				end
				table.insert(tempLeft, temp)
			end
			
			return func(tempLeft, tempRight, currItem)
		else
			return true
		end
	end
end

--@desc: 设置是否可以放入左边list的条件
--@author:Liang SongQiang
--@time:2017-12-16 18:17:24
--@func: 自定义条件
function ShenBingBagLayer:setCondiPushLeftList(func)
	self.checkCanPushLeftList = function(self, currItem)
		local rightList = self.ListView_2:getItems()
		local leftList = self.ListView_1:getItems()
		if func then
			local tempLeft = {}
			local tempRight = {}
			
			for k, v in pairs(rightList) do
				local temp = {}
				for k, v in pairs(getmetatable(v.data)) do
					if not ignoreTbKey[k] then
						temp[k] = v
					end
				end
				table.insert(tempRight, temp)
			end
			
			for k, v in pairs(tempLeft) do
				local temp = {}
				for k, v in pairs(getmetatable(v.data)) do
					if not ignoreTbKey[k] then
						temp[k] = v
					end
				end
				table.insert(tempLeft, temp)
			end
			
			return func(tempLeft, tempRight, currItem)
		else
			return true
		end
	end
end

--@desc: 设置左边List标题
--@author:Liang SongQiang
--@time:2017-12-16 18:16:38
function ShenBingBagLayer:setLeftName(name)
	name = Helper:getDef(name, "背包")
	self.Image_title.Text_title1:setString(tostring(name))
end

--@desc: 设置右边List标题
--@author:Liang SongQiang
--@time:2017-12-16 18:16:14
function ShenBingBagLayer:setRightName(name)
	name = Helper:getDef(name, "")
	self.Image_title.Text_title2:setString(tostring(name))
end

--@desc: 设置右上角文本，显示money
--@author:Liang SongQiang
--@time:2017-12-19 18:25:17
--@text: 文本
function ShenBingBagLayer:setTextMoney(text)
	if not text then
		self.Text_money:setVisible(false)
		return
	end
	self.Text_money:setVisible(true)
	self.Text_money:setString(text)
end

--@desc: 设置左上角文本
--@author:Liang SongQiang
--@time:2017-12-19 18:20:03
--@text: 设置左上角文本
function ShenBingBagLayer:setTextWeight(text)
	if not text then
		self.Text_desc1:setVisible(false)
		self.Text_weight:setVisible(false)
		return
	end
	self.Text_weight:setString(text)
	self.Text_desc1:setVisible(true)
	self.Text_weight:setVisible(true)
end


--@desc: 界面销毁
--@author:Liang SongQiang
--@time:2017-12-16 18:17:14
function ShenBingBagLayer:destory()
	leftTable = {}
	rightTable = {}
	self:setCondiPushRightList()
	self:setCondiPushLeftList()
	PopupLayerController:hideLayer("ShenBingBagLayer",function(layer)
		layer.ListView_1:removeAllItems()
		layer.ListView_2:removeAllItems()
		layer:hide()

	end)
end


Helper:classDefNodeGetInstance(ShenBingBagLayer)
return ShenBingBagLayer000000