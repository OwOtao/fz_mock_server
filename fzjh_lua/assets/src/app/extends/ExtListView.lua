
local ErrmsgRecord = require("app.models.Record.ErrmsgRecord.ErrmsgRecord")

local function addErrmsgRecord(itemData, index)
	if itemData[index] == nil then
		local msg = table.tostring(itemData)
		ErrmsgRecord:addErrmsg("listview error tag:" .. tostring(index) .. " ; " ..msg)
	end
end

if ccui.ListView.removeLastItemOld == nil then
	ccui.ListView.removeLastItemOld = ccui.ListView.removeLastItem
	ccui.ListView.removeLastItem = function(self)
		local lastSize = self:getInnerContainerSize()
		local position = self:getInnerContainerPosition()
		ccui.ListView.removeLastItemOld(self)
		self:requestDoLayout()
		self:doLayout()
		local currSize = self:getInnerContainerSize()

		local posX = position.x
		local posY = position.y + (lastSize.height - currSize.height)

		if posY > 0 then
			posY = 0
		end

		self:setInnerContainerPosition({x = posX, y = posY})
	end
end

if ccui.ListView.pushBackCustomItemOld == nil then
	ccui.ListView.pushBackCustomItemOld = ccui.ListView.pushBackCustomItem
	ccui.ListView.pushBackCustomItem = function(self, ...)
		local lastSize = self:getInnerContainerSize()
		local position = self:getInnerContainerPosition()
		ccui.ListView.pushBackCustomItemOld(self, ...)
		self:requestDoLayout()
		self:doLayout()
		local currSize = self:getInnerContainerSize()

		local posX = position.x
		local posY = position.y + (lastSize.height - currSize.height)

		if posY > 0 then
			posY = 0
		end

		self:setInnerContainerPosition({x = posX, y = posY})
	end
end

if ccui.ListView.insertCustomItemOld == nil then
	ccui.ListView.insertCustomItemOld = ccui.ListView.insertCustomItem
	ccui.ListView.insertCustomItem = function(self, ...)
		local lastSize = self:getInnerContainerSize()
		local position = self:getInnerContainerPosition()
		ccui.ListView.insertCustomItemOld(self, ...)
		self:requestDoLayout()
		self:doLayout()
		local currSize = self:getInnerContainerSize()

		local posX = position.x
		local posY = position.y + (lastSize.height - currSize.height)

		if posY > 0 then
			posY = 0
		end

		self:setInnerContainerPosition({x = posX, y = posY})
	end
end

if ccui.ListView.removeItemOld == nil then
	ccui.ListView.removeItemOld = ccui.ListView.removeItem
	ccui.ListView.removeItem = function(self, ...)
		local lastSize = self:getInnerContainerSize()
		local position = self:getInnerContainerPosition()
		ccui.ListView.removeItemOld(self, ...)
		self:requestDoLayout()
		self:doLayout()
		local currSize = self:getInnerContainerSize()

		local posX = position.x
		local posY = position.y + (lastSize.height - currSize.height)

		if posY > 0 then
			posY = 0
		end

		self:setInnerContainerPosition({x = posX, y = posY})
	end
end

-----------------------------------------------------------------------------------------------------------
	-------------------------------------------listview复用接口----------------------------------------
-----------------------------------------------------------------------------------------------------------
--[[
	先通过 ListView:setItemHeight(itemHeight) 设置复用item的height 直接传值方便计算
	注册item创建方法 ListView:setItemCreateFunc(itemCreateFunc)
	注册item初始化方法 ListView:setItemInitFunc(itemInitFunc)
	通过 ListView:showListView(itemData,reuseItemNum) 展示itemData（item数据）与reuseItemNum(复用item数量)
	通过 计时器调用 ListView:refreshReuseItems() 刷新
]]
local ReuseListView = ccui.ListView

function ReuseListView:showListView(itemData,reuseItemNum)
	local itemNum = #itemData

	if itemNum <= 0 or reuseItemNum <= 0 then
		return
	end

	local itemsMargin = self:getItemsMargin()
	local listSize = self:getContentSize()

	self:__initItem(itemData,reuseItemNum)
	self:__setItemData(itemData)
	self:__setReuseItemNum(reuseItemNum)

	self:setInnerContainerSize({width = listSize.width, height = itemNum * self.__itemHeight + (itemNum - 1) * itemsMargin})
	
	if self._resetPos then
		self:getInnerContainer():forceDoLayout()
	end
end

function ReuseListView:__initItem(itemData,reuseItemNum)
	local items = self:getItems()
	local itemPanel_num = #items

	local isAddItem,isRemoveItem = false,false

	if itemPanel_num < reuseItemNum then
		isAddItem = true
	end

	if itemPanel_num > reuseItemNum then
		isRemoveItem = true
	end

	if isAddItem then
		for i = 1,reuseItemNum - itemPanel_num do
			local item = self:__itemCreateFunc()
			item:setAnchorPoint(0.0000, 0.0000)
			self:pushBackCustomItem(item)
			item:setTag(itemPanel_num + i)
		end

		local items = self:getItems()

		for index,item in pairs(items) do
			local tag = item:getTag()

			addErrmsgRecord(itemData, tag)

			self.__itemInitFunc(item,itemData[tag])
		end
	end

	if isRemoveItem then
		for i = itemPanel_num - 1,reuseItemNum,-1 do
			self:removeItem(i)
		end

		local items = self:getItems()

		for index,item in pairs(items) do
			item:setTag(index)

			addErrmsgRecord(itemData, index)

			self.__itemInitFunc(item,itemData[index])
		end
	end

	self._resetPos = true

	if itemPanel_num == reuseItemNum then
		local items = self:getItems()
		local data_change_num = #itemData - self.__lastItemNum
		if data_change_num == 0 then
			for index,item in pairs(items) do
				local tag = item:getTag()

				addErrmsgRecord(itemData, tag)

				self.__itemInitFunc(item,itemData[tag])
			end
			self._resetPos = false
		else
			local tag = 1
			local posY = (reuseItemNum - 1) * (self.__itemHeight + self:getItemsMargin())
			for index,item in pairs(items) do
				item:setTag(tag)
				item:setPositionY(posY)

				addErrmsgRecord(itemData, tag)

				self.__itemInitFunc(item,itemData[tag])
				tag = tag + 1
				posY = posY - self.__itemHeight - self:getItemsMargin()
			end
		end
	end
end

function ReuseListView:getLastInnerContainerPosition()
	return self.__lastContentPos or self:getInnerContainerPosition()
end

function ReuseListView:setItemInitFunc(itemInitFunc)
	if type(itemInitFunc) ~= "function" then
		itemInitFunc = function()end
	end
	self.__itemInitFunc = itemInitFunc
end

function ReuseListView:setItemCreateFunc(itemCreateFunc)
	if type(itemCreateFunc) ~= "function" then
		itemCreateFunc = function()end
	end
	self.__itemCreateFunc = itemCreateFunc
end

function ReuseListView:setItemHeight(height)
	if type(height) == "number" then
		self.__itemHeight = height
	else
		assert(false,"the type of height is error".."type :"..tostring(type(height)))
	end
end

--以下算法坐标计算 基于listview 锚点为（0,0）、子控件panel 锚点为（0,0）
function ReuseListView:refreshReuseItems()
	local items = self:getItems()
	local isScorll = false
    if not items or type(items) ~= "table" or _G.next(items) == nil then
		return 
	end

	if  type(self.__reuseItemNum) ~= "number" then
		return
	end

	if  type(self.__itemData) ~= "table" or #self.__itemData == 0 then
		return
	end

	if #self.__itemData <= self.__reuseItemNum then
		return
	end

    local currInnerContainerPos = self:getInnerContainerPosition()
    local listViewSize = self:getContentSize()
    local itemsMargin = self:getItemsMargin()
    local itemData = self.__itemData
	local reuseItemNum = self.__reuseItemNum
    local bufferZone = self:__getViewOffset()
	local maxItemheight = self.__itemHeight
	local actualViewSizeHeight = math.floor(listViewSize.height/(self.__itemHeight + itemsMargin)) * (self.__itemHeight + itemsMargin)

	local direction = self:getDirection()

	if direction == LISTVIEW_DIR_VERTICAL then
		assert(maxItemheight," the maxItemheight is null")

		local totalHeight = maxItemheight * #itemData + (#itemData - 1) * itemsMargin
		local showViewSizeHeight = (maxItemheight + itemsMargin) * reuseItemNum

		for index,item in pairs(items) do
			local posX,posY = item:getPositionX(),item:getPositionY()
			local _tag = item:getTag()
			
			local worldPos = item:getParent():convertToWorldSpace(cc.p(posX,posY))
			local viewPos = self:convertToNodeSpace(cc.p(worldPos.x,worldPos.y))
			local itemPos = viewPos.y
			
			if itemPos >bufferZone + actualViewSizeHeight then
				isScorll = true
				if posY - showViewSizeHeight >= 0 then
					local itemID = _tag + reuseItemNum
					if itemData[itemID] then
						item:setPositionY(posY - showViewSizeHeight)
						item:setTag(itemID)
						self.__itemInitFunc(item,itemData[itemID])
					else
						isScorll = false
					end
				else
					isScorll = false
				end
			elseif itemPos < -bufferZone then
				isScorll = true
				if posY + showViewSizeHeight <= totalHeight then
					local itemID = _tag - reuseItemNum
					if itemData[itemID] then
						self.__itemInitFunc(item,itemData[itemID])
						item:setPositionY(posY + showViewSizeHeight)
						item:setTag(itemID)
					else
						isScorll = false
					end
				else
					isScorll = false
				end
			end
		end
	end

	self.__lastContentPos = self:getInnerContainerPosition()
	return isScorll
end

function ReuseListView:__getViewOffset()
	local direction = self:getDirection()

	if direction == LISTVIEW_DIR_VERTICAL then
		return self.__itemHeight + self:getItemsMargin() + 2
	end

	return 0
end

function ReuseListView:__setItemData(itemData)
	self.__itemData = itemData
	self.__lastItemNum = #itemData
end

function ReuseListView:__setReuseItemNum(reuseItemNum)
	self.__reuseItemNum = reuseItemNum
end




00