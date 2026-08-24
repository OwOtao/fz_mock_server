local NewShenBingBagLayer = class("NewShenBingBagLayer", cc.Layer)


local Resource = require("app.Resource")

function NewShenBingBagLayer:create()
	local p = NewShenBingBagLayer:new()
	p:init()
	return p
end

function NewShenBingBagLayer:init()
	self._UI = require("Layer/MapUI/MapBagUI.lua").create() ['root']
	self._UI:addTo(self)
	Helper:convertUIByParent(self)
	self:initButton()
	self:setTextMoney()
	self:setTextWeight()
end

function NewShenBingBagLayer:showLayer()
	self:show()
end


function NewShenBingBagLayer:initButton()
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


--@desc: 设置右边按钮的点击方法
function NewShenBingBagLayer:btnRightClickFunc(func, name)
	if name == nil then
		self.btnRight:setVisible(false)
		return
	end
	
	self.btnRight.Text_buttonName:setString(name)
	self.btnRight:releaseFunc(function()
		Audio:playEffect("xiaoAnNiu")
		if func then
			func()
		end
	end)
end


--@desc: 设置左边按钮的点击方法
function NewShenBingBagLayer:btnLeftClickFunc(func, name)
	if func == nil or name == nil then
		self.btnLeft:setVisible(false)
		return
	end
	self.btnLeft:setVisible(true)
	name = Helper:getDef(name, "取消")
	self.btnLeft.Text_buttonName:setString(name)
	self.btnLeft:releaseFunc(function()
		Audio:playEffect("xiaoAnNiu")
		if func then
			func()
		end
	end)
end


--@desc: 设置左边List标题
function NewShenBingBagLayer:setLeftName(name)
	name = Helper:getDef(name, "背包")
	self.Image_title.Text_title1:setString(tostring(name))
end

--@desc: 设置右边List标题
function NewShenBingBagLayer:setRightName(name)
	name = Helper:getDef(name, "")
	self.Image_title.Text_title2:setString(tostring(name))
end

--@desc: 设置右上角文本，显示money
function NewShenBingBagLayer:setTextMoney(text)
	if not text then
		self.Text_money:setVisible(false)
		return
	end
	self.Text_money:setVisible(true)
	self.Text_money:setString(text)
end

--@desc: 设置左上角文本
function NewShenBingBagLayer:setTextWeight(text)
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
function NewShenBingBagLayer:destory()
	PopupLayerController:hideLayer("NewShenBingBagLayer",function(layer)
		layer.ListView_1:removeAllItems()
		layer.ListView_2:removeAllItems()

		if self.schedule_1 then
			self:unschedule(self.schedule_1)
			self.schedule_1 = nil
		end

		if self.schedule_2 then
			self:unschedule(self.schedule_2)
			self.schedule_2 = nil
		end
		
		layer:hide()
	end)
end

function NewShenBingBagLayer:setConditionPushLeftFunc(func)
	self._conditionPushLeftFunc = func
end

function NewShenBingBagLayer:setConditionPushRightFunc(func)
	self._conditionPushRightFunc = func
end

function NewShenBingBagLayer:setAfterPushFunc(func)
	self._afterPushFunc = func
end

function NewShenBingBagLayer:pushItemToRight(item,func)
	if self._outGoingCKFunc then
		local result = self._outGoingCKFunc(item,function()
			if self._afterPushFunc then
				self._afterPushFunc()
			end

			if func then
				func()
			end
			self:refreshUI()
		end)
		return result
	else
		return false
	end
end

function NewShenBingBagLayer:pushItemToLeft(item,func)
	if self._bePutCKFunc then
		local result = self._bePutCKFunc(item,function()
			if self._afterPushFunc then
				self._afterPushFunc()
			end

			if func then
				func()
			end
			
			self:refreshUI()
		end)
		return result
	else
		return false
	end
	
end

function NewShenBingBagLayer:setOutGoingCKFunc(func)
	self._outGoingCKFunc = func or EMPTY_FUNC
end

function NewShenBingBagLayer:setBePutCKFunc(func)
	self._bePutCKFunc = func or EMPTY_FUNC
end

function NewShenBingBagLayer:setLeftItemsInfo(itemsInfo)
	self._leftItemsInfo = itemsInfo or {}
end

function NewShenBingBagLayer:setRightItemsInfo(itemsInfo)
	self._rightItemsInfo = itemsInfo or {}
end

function NewShenBingBagLayer:getLeftItemsInfo()
	return self._leftItemsInfo
end

function NewShenBingBagLayer:getRightItemsInfo()
	return self._rightItemsInfo
end

function NewShenBingBagLayer:getLeftItemPanel()
	local row = self.Panel_item1:clone()
	Helper:convertUI(row)
	row:setVisible(true)
	row.Text_name:enableOutline(cc.c4b(0, 0, 0, 255), 5)
	return row
end

function NewShenBingBagLayer:getRightItemPanel()
	local row = self.Panel_item2:clone()
	Helper:convertUI(row)
	row:setVisible(true)
	row.Text_name:enableOutline(cc.c4b(0, 0, 0, 255), 5)
	return row
end

function NewShenBingBagLayer:refreshUI()
	local leftItems = self:getLeftItemsInfo()
	local rightItems = self:getRightItemsInfo()
	
	self:__initLeftBag(leftItems)
	self:__initRightBag(rightItems)
end

function NewShenBingBagLayer:__initLeftItemPanel(itemPanel,itemInfo)
    if MapIsEmpty(itemInfo) == false then
        itemPanel.Text_name:setColor(cc.c3b(255, 255, 255))
        itemPanel.Text_name:setString(itemInfo.name)
        itemPanel:releaseFunc(
            function()
				if self._conditionPushRightFunc and self._conditionPushRightFunc(itemInfo) then
					self:pushItemToRight(itemInfo)
				end
            end
        )
    end
end

function NewShenBingBagLayer:__initRightItemPanel(itemPanel,itemInfo)
    if MapIsEmpty(itemInfo) == false then
        itemPanel.Text_name:setColor(cc.c3b(255, 255, 255))
        itemPanel.Text_name:setString(itemInfo.name)
		itemPanel.Text_num:setColor(cc.c3b(255, 255, 255))
        itemPanel.Text_num:setString(Helper:getDef(itemInfo.text, "X 1"))
        itemPanel:releaseFunc(
            function()
				if self._conditionPushLeftFunc and self._conditionPushLeftFunc(itemInfo) then
					self:pushItemToLeft(itemInfo)
				end
            end
        )
    end
end

function NewShenBingBagLayer:__initLeftBag(leftItems)
    self.ListView_1:setSwallowTouches(false)

    local showItemsInfo = leftItems
    if MapIsEmpty(showItemsInfo) then
		self.ListView_1:removeAllItems()
		if self.schedule_1 then
			self:unschedule(self.schedule_1)
			self.schedule_1 = nil
		end
        return
    end

    local roleItemNum = #showItemsInfo
    local listSize = self.ListView_1:getContentSize()
    local itemSize = self.Panel_item1:getContentSize()
    local itemsMargin = self.ListView_1:getItemsMargin()
    local itemMaxCount = Helper:mathFloor(listSize.height/(itemSize.height + itemsMargin)) + 2
    local isSchedule = true

    if roleItemNum < itemMaxCount then
        itemMaxCount = roleItemNum
        isSchedule = false
    end

    self.ListView_1:setItemHeight(itemSize.height)

    self.ListView_1:setItemInitFunc(function(item,info)
        self:__initLeftItemPanel(item,info)
    end)

    self.ListView_1:setItemCreateFunc(function()
        return self:getLeftItemPanel()
    end)

    self.ListView_1:showListView(showItemsInfo,itemMaxCount)


    if isSchedule then
        if self._lastContentPos_1 then
            if self._lastContentPos_1.y > self.ListView_1:getInnerContainerPosition().y then
                self.ListView_1:setInnerContainerPosition(self._lastContentPos_1)
            end
        else
            self.ListView_1:jumpToTop()
        end

		local isTrue = self.ListView_1:refreshReuseItems()
		while isTrue do
			isTrue = self.ListView_1:refreshReuseItems()
		end

		if not self.schedule_1 then
			self.schedule_1 = self:schedule(function()
				self.ListView_1:refreshReuseItems()
				self._lastContentPos_1 = self.ListView_1:getLastInnerContainerPosition()
			end)
		end
			
    end
end

function NewShenBingBagLayer:__initRightBag(rightItems)
    self.ListView_2:setSwallowTouches(false)

    local showItemsInfo = rightItems

    if MapIsEmpty(showItemsInfo) then
		self.ListView_2:removeAllItems()
		if self.schedule_2 then
			self:unschedule(self.schedule_2)
			self.schedule_2 = nil
		end
        return
    end

    local roleItemNum = #showItemsInfo
    local listSize = self.ListView_2:getContentSize()
    local itemSize = self.Panel_item2:getContentSize()
    local itemsMargin = self.ListView_2:getItemsMargin()

	local itemMaxCount = Helper:mathFloor(listSize.height/(itemSize.height + itemsMargin)) + 2
    local isSchedule = true

    if roleItemNum < itemMaxCount then
        itemMaxCount = roleItemNum
        isSchedule = false
    end

    self.ListView_2:setItemHeight(itemSize.height)

    self.ListView_2:setItemInitFunc(function(item,info)
		self:__initRightItemPanel(item,info)
    end)

    self.ListView_2:setItemCreateFunc(function()
        return self:getRightItemPanel()
    end)

    self.ListView_2:showListView(showItemsInfo,itemMaxCount)

	

    if isSchedule then
        if self._lastContentPos_2 then
            if self._lastContentPos_2.y > self.ListView_2:getInnerContainerPosition().y then
				self.ListView_2:setInnerContainerPosition(self._lastContentPos_2)
            end
        else
            self.ListView_2:jumpToTop()
        end

		local isTrue = self.ListView_2:refreshReuseItems()
		while isTrue do
			isTrue = self.ListView_2:refreshReuseItems()
		end

		if self.schedule_2 == nil then
			self.schedule_2 = self:schedule(function()
				self.ListView_2:refreshReuseItems()
				self._lastContentPos_2 = self.ListView_2:getLastInnerContainerPosition()
			end)
		end
    end
end

Helper:classDefNodeGetInstance(NewShenBingBagLayer)
return NewShenBingBagLayer0