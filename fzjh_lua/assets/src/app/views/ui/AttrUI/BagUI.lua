local BagUI = class("BagUI", cc.Layer)

function BagUI:create()
	local p = BagUI:new()
	p:init()
	return p
end

--
function BagUI:init()
	self._round = require("Layer/AttrUI/BagUI.lua").create()['root']
	self._round:addTo(self)
	Helper:convertUIByParent(self) -- 获得所有子节点

	self:createWeaponItenDesc()
	self.Panel_item:setVisible(false)
	self.Panel_itemDesc:setVisible(false)

	self.Image_di:releaseFunc(
	function()
		if self.__currShowPanel then
			self.__currShowPanel:hideLayer(true)
			self.__currShowPanel = nil
		else
			self:itemDescHide(true)
		end
	end)

	self.Panel_cangku.Image_cangku:releaseFunc(function()
		if self.__currShowPanel then
			self.__currShowPanel:hideLayer(true)
			self.__currShowPanel = nil
		else
			self:itemDescHide(true)
		end
	end)
	self:showItemList()
	self:showcangkuItem()

	self.Button_add:releaseFunc(function()
		PopupLayerController:showLayer("BagUpgradePresenters",function(layer)
			layer:showLayer()
			layer:setHideFunc(function()
				self:setWeight()
				self:setckLimit()
				self:setCoin(User:getRole():getNumAttr("gold"), User:getRole():getNumAttr("money"))
			end)
		end)
	end)

	self:setVisible(false)

	self:schedule(function(ft)
		self:update(ft)
	end,0)
end

function BagUI:updateSkin(skin_config)
	if skin_config.CangkuPic then
		self.Panel_cangku.Image_cangku:loadTexture(skin_config.CangkuPic,0)
	end
end

--@desc 背包数量有变化 刷新UI界面
function BagUI:checkUserItem()
	local role = User:getRole()

	if not self.__lastBagNum then
		self.__lastBagNum = role:getNowWeight()
		return
	end

	local currBagItemNum = role:getNowWeight()
	if self.__lastBagNum ~= currBagItemNum then
		self.__lastBagNum = currBagItemNum
		self:__showBagItemList()
		self:setWeight()
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/01/10 11:09:59
-- @desc 兵器描述框
function BagUI:createWeaponItenDesc()
	self.Panel_weaponItemDesc = self.Panel_itemDesc:clone()
	self.Panel_weaponItemDesc:setVisible(false)
end
-- add by XiaoZhiWei 2018/01/11 15:05:52 药品cd条动画
function BagUI:showCDAndCalc()
	if self._showItemAttr ~= nil and self._showItem ~= nil then
		if self._showItemAttr == nil or self._showItemAttr.type ~= "药品" or self._showItemAttr.cooldown == nil 
			or (self._showItemAttr.attr and self._showItemAttr.attr[1] ~= "qiPercent") then -- add by LvBin 2019/06/13 11:11:52 目前只有作用qiPercent的药品才用到cd时间
			self.Panel_itemDesc.Image_back.Panel_title.LoadingBar_CD:setVisible(false)
			return
		else
			self.Panel_itemDesc.Image_back.Panel_title.LoadingBar_CD:setVisible(true)
		end
		local role = User:getRole()
		local currTime = GetTime()
		local userTime = role:getFlag("药品使用时间")
		local coolDown = self._showItemAttr.cooldown
		if userTime == 0 or(currTime - userTime > coolDown) then
			self.Panel_itemDesc.Image_back.Panel_title.LoadingBar_CD:setVisible(false)
		else
			self.Panel_itemDesc.Image_back.Panel_title.LoadingBar_CD:setVisible(true)
			local percent =((GetTime() - userTime) / coolDown) * 100
			percent = 100 - percent
			if percent <= 0 then
				percent = 0
			elseif percent >= 100 then
				percent = 100
			end
			self.Panel_itemDesc.Image_back.Panel_title.LoadingBar_CD:setPercent(percent)
		end
	end
end

-- add by XiaoZhiWei 2018/01/11 15:06:06 物品有效时间刷新
function BagUI:refreshTime()
	if self._showItemAttr ~= nil and self._showItem ~= nil then
		if type(self._showItemAttr.timeend) == "number" or type(self._showItemAttr.timeend) == "string" then
			self.Panel_itemDesc.Image_back.TextField_time:setVisible(true)
			if type(self._showItem.time) ~= "number" then
				self._showItem.time = User:getRole():getItemTimeLimit(User:getRole():getOneItemByKey(self._showItem.itemId))
				User:getRole():setItemTimeByItemId(self._showItem.itemId,self._showItem.time)
			end
			if self._showItem.time >= GetTime() then
				local remainTime=Helper:diffWithSecond(self._showItem.time,GetTime())
				local remainDay=math.floor(remainTime/(60*60*24))
				local remainHour=math.floor(remainTime/(60*60)%24)
				local remainMinute=math.floor(remainTime / 60 % 60)
				local remainSecond=math.floor(remainTime%60)
				local str=""
				if remainDay>0 then 
					str=str..tostring(remainDay).."日"
				end
				if remainHour>0 then 
					str=str..tostring(remainHour).."时"
				end
				if remainMinute>0 then 
					str=str..tostring(remainMinute).."分"
				end
				if remainSecond>=0 then 
					str=str..tostring(remainSecond).."秒"
				end

				if self._showItemAttr.type == "地契" then
					str = "搬入剩余时间："..str.."\n"
					str = str .. "到时若是没有搬入该地，土地将会被回收。"
				else
					str = "(该道具将在"..str .. "后被销毁)"
				end
				self.Panel_itemDesc.Image_back.TextField_time:setString(str)
			else
				self.Panel_itemDesc.Image_back.TextField_time:setString("该物品已经过期！")
				self.Panel_itemDesc:setVisible(false)
				self:setShowItem()
			end
		else
			self.Panel_itemDesc.Image_back.TextField_time:setVisible(false)
		end
	else
		self.Panel_itemDesc.Image_back.TextField_time:setVisible(false)
	end
end

-- 显示药品冷却时间以及计算
function BagUI:setShowItem(itemAttr,item)
	self._showItemAttr = itemAttr
	self._showItem  = item
end


local partSortRules={
		["头帽"]=1,["上装"]=2,["下装"]=3,["腰带"]=4,
		["腰坠"]=5,["鞋子"]=6,["项链"]=7,["手部"]=8,["戒指"]=9
	}

---给背包排序
function BagUI:sortTable(bagItems)
	if type(bagItems) ~= "table" then
		return nil
	end
	local role = User:getRole()
	if not MapIsEmpty(bagItems) then
		table.sort(bagItems, function(a, b)
			local itemAttr_a = User:getRole():getOneItemByKey(a.itemId)
			local itemAttr_b = User:getRole():getOneItemByKey(b.itemId)

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
					
					if partSortRules[itemAttr_a.type] and partSortRules[itemAttr_b.type] then 
						rest = partSortRules[itemAttr_a.type] < partSortRules[itemAttr_b.type]
					end
					--装备中有武器的话 武器排前面
					local weaponData = role:getEquipByName("weapon")
					if weaponData then 
						if weaponData.itemId == a.itemId then 
							rest=true
						elseif weaponData.itemId == b.itemId then 
							rest=false
						end
					end
				elseif role:checkItemIsEquip(a.id) and not role:checkItemIsEquip(b.id) then
					rest = true
					--准备武器排前面
					if role:checkIsPrepareWeapon(b.id) then 
						local weaponData = role:getEquipByName("weapon")
						if weaponData and weaponData.id == a.id then 
						else
							rest = false
						end
					end
				elseif not role:checkItemIsEquip(a.id) and role:checkItemIsEquip(b.id) then
					rest = false
					--准备武器排前面
					if role:checkIsPrepareWeapon(a.id) then 
						local weaponData = role:getEquipByName("weapon")
						if weaponData and weaponData.id == b.id then 
						else
							rest = true
						end
					end
				else
					rest = a.itemId > b.itemId
					if role:checkIsPrepareWeapon(a.id) then 
						rest = true
					elseif role:checkIsPrepareWeapon(b.id) then 
						rest = false
					end
				end
			elseif itemAttr_a.canEquip == ITEM_STATE_FALSE and itemAttr_b.canEquip == ITEM_STATE_FALSE then
				rest = a.itemId > b.itemId
			elseif itemAttr_a.canEquip == ITEM_STATE_TRUE and itemAttr_b.canEquip == ITEM_STATE_FALSE then
				rest = true
			elseif itemAttr_a.canEquip == ITEM_STATE_FALSE and itemAttr_b.canEquip == ITEM_STATE_TRUE then
				rest = false
			end

			
			-- @desc 同一个物品, 按照数目排序
			if rest == false then
				if a.itemId == b.itemId then
					return a.count > b.count
				end
			end

			return rest
		end)
	end
	return bagItems
end

-- 显示列表  7/20
function BagUI:showItemList()
	self.Text_noItem:setVisible(false)

	self:__showBagItemList()

	self:setWeight()

	local role = User:getRole()

	self:setCoin(role:getNumAttr("gold"), role:getNumAttr("money"))
end

--显示仓库物品，这在里在顯示物品
function BagUI:showcangkuItem()
	local role = User:getRole()
	local ckItems = role:getckItems()

	self.Text_noItem_ck:setVisible(false)

	if #ckItems <= 0 then
		self.Text_noItem_ck:setVisible(true)
		self.Text_noItem_ck:setZ(- 10)
	end

	if MapIsEmpty(ckItems) then
		self.Text_noItem_ck:setVisible(true)
		self.Panel_cangku.ListView_cangku:setVisible(false)
	else
		self:__showCKItemList()
	end

	--仓库容量显示
	self:setckLimit()
end

function BagUI:__getBagItemList()
	local role = User:getRole()
	local bagItems = role:getItems()
	local addList = {"shuxiang", "decorativeBox", "literaryBox","smeltBox"}

	if POISONSYS then
		if role:getInheritFlag("毒药系统") >= 1 or DEBUG_MODE == 1 then
			addList = {"shuxiang", "decorativeBox", "literaryBox","medicinalBox","smeltBox",}
		end
	end

	if role:getSelfCreatedSkillSystem():isOpenSystem() then
		table.insert(addList, "bookRack")
	end

	--@desc 挑战副本新增背包容器
	table.insert(addList, "volumeBox")

	local bagItemsInfo = {}

	for i,v in ipairs(addList) do
		local itemInfo =
		{
			id = role:getItemOnlyId(),
			itemId = v,
			count = 1
		}

		local itemAttr = role:getOneItemByKey(v)
		itemInfo.text = itemAttr.name

		itemInfo.func = function()
			self:clickOneItem(itemInfo, itemAttr)
		end

		table.insert(bagItemsInfo,itemInfo)
	end

	if MapIsEmpty(bagItems) == false then
		--背包排序。可装备的物品排在前面，已经装备的排在可装备的前面.然后再根据他的id来排序
		bagItems = self:sortTable(bagItems)

		for i = 1, #bagItems do
			local item = bagItems[i]
			local itemAttr = role:getOneItemByKey(item.itemId)
			local itemInfo = {}

			if role:checkItemIsEquip(item.id) then
				itemInfo.equipVisible = true
				local weaponData = role:getEquipByName("weapon")
				if weaponData and weaponData.id == item.id then 
					itemInfo.equipWeaponIconVisible = true
					itemInfo.equipVisible = false
				end
			end

			if role:checkIsPrepareWeapon(item.id) then 
				itemInfo.prepareWeaponIconVisible = true
			end 

			if itemAttr.canFold == ITEM_STATE_FALSE then
				if item.wanhaodu == 0 then
					itemInfo.text = itemAttr.name.."NOR(损)"
				else
					itemInfo.text = itemAttr.name
				end
				--神兵武器颜色自带   8/04
				if itemAttr.wpType == "神兵" then
					itemInfo.text = itemAttr.nameColor..itemInfo.text
				end
			else
				itemInfo.text = itemAttr.name.." X"..item.count
			end

			itemInfo.func = function()
				self:clickOneItem(item, itemAttr)
			end

			table.insert(bagItemsInfo,itemInfo)
		end
	end

	return bagItemsInfo
end

function BagUI:__showBagItemList()
	self.ListView_item:setVisible(true)
    self.ListView_item:setSwallowTouches(false)

    local showItemsInfo = self:__getBagItemList()

    if MapIsEmpty(showItemsInfo) then
        self.ListView_item:removeAllItems()
        if self.listViewSchedule then
            self:unschedule(self.listViewSchedule)
            self.listViewSchedule = nil
        end
        return
    end

    local roleItemNum = #showItemsInfo
    local listSize = self.ListView_item:getContentSize()
    local itemSize = self.Panel_item:getContentSize()
    local itemsMargin = self.ListView_item:getItemsMargin()
    local itemMaxCount = Helper:mathFloor(listSize.height/(itemSize.height + itemsMargin)) + 2
    local isSchedule = true

    if roleItemNum < itemMaxCount then
        itemMaxCount = roleItemNum
        isSchedule = false
    end

	if not self.__lastBagItemNum then
		self.__lastBagItemNum = roleItemNum
	end

    self.ListView_item:setItemHeight(itemSize.height)

    self.ListView_item:setItemInitFunc(function(item,info)
        self:__initBagItemUI(item,info)
    end)

    self.ListView_item:setItemCreateFunc(function()
        return self:__getBagItemPanel()
    end)

    self.ListView_item:showListView(showItemsInfo,itemMaxCount)

    if isSchedule then
        if self.__bagListPos then
			local posY = math.min(self.__bagListPos.y - (roleItemNum - self.__lastBagItemNum) *  (itemSize.height + itemsMargin),self.ListView_item:getInnerContainerSize().height)
			posY = math.min(0,posY)
			if posY > self.ListView_item:getInnerContainerPosition().y then
                self.ListView_item:setInnerContainerPosition({x = self.__bagListPos.x, y = posY})
            end
        else
            self.ListView_item:jumpToTop()
        end

        local isTrue = self.ListView_item:refreshReuseItems()
		while isTrue do
			isTrue = self.ListView_item:refreshReuseItems()
		end

		if self.listViewSchedule then
            self:unschedule(self.listViewSchedule)
            self.listViewSchedule = nil
        end

        self.listViewSchedule = self:schedule(function()
            self.ListView_item:refreshReuseItems()
            self.__bagListPos = self.ListView_item:getInnerContainerPosition()
        end)
    end

	self.__lastBagItemNum = roleItemNum
end

function BagUI:__getBagItemPanel()
	local panel = self.Panel_item:clone()

	Helper:convertUIByParent(panel)
	panel:setVisible(true)
	panel:setTouchEnabled(true)
	panel.Image_tiao.Text_name:enableOutline({r = 0, g = 0, b = 0, a = 255}, 5)

	return panel
end

function BagUI:__initBagItemUI(itemPanel,itemInfo)
    itemPanel.Image_equipWeaponIcon:setVisible(itemInfo.equipWeaponIconVisible or false)

    if itemInfo.equipWeaponIconVisible then
        itemPanel.Image_equipWeaponIcon:loadTexture("Image/UI/AttrUI/beibao2.png",0)
    end

    itemPanel.Image_prepareWeaponIcon:setVisible(itemInfo.prepareWeaponIconVisible or false)

    if itemInfo.prepareWeaponIconVisible then
        itemPanel.Image_prepareWeaponIcon:loadTexture("Image/UI/AttrUI/beibao1.png",0)
    end

	itemPanel.Image_tiao.Text_name:setColor(cc.c3b(208,208,208))---设置默认颜色
    itemPanel.Image_tiao.Text_name:setString(itemInfo.text)
    itemPanel.Panel_dian:setVisible(itemInfo.equipVisible or false)
    itemPanel.Image_back:setVisible(itemInfo.backVisible or false)
    
	itemPanel:releaseFunc(function()
		if itemInfo.func then
            itemInfo.func()
        end

		self:__hideBagListViewItemPanelBack()

		itemPanel.Image_back:setVisible(true)
    end)
end

function BagUI:__hideBagListViewItemPanelBack()
	local items = self.ListView_item:getItems()
	for i = 1,#items do
		items[i].Image_back:setVisible(false)
	end
end

function BagUI:__getCKItemPanel()
	local panel = self.Panel_item_ck:clone()

	Helper:convertUIByParent(panel)
	panel:setVisible(true)
	panel:setTouchEnabled(true)
	panel.Text_name:enableOutline({r = 0, g = 0, b = 0, a = 255}, 5)
	panel.Item_count:enableOutline({r = 0, g = 0, b = 0, a = 255}, 5)

	return panel
end

function BagUI:__getCKItemList()
	local role = User:getRole()
	local ckItems = role:getckItems()
	local itemList = {}

	if MapIsEmpty(ckItems) == false then
		--背包放入仓库的时候，放在list的最前面
		for i = #ckItems, 1, - 1 do
			local item = ckItems[i]
			local itemInfo = {}
			local itemAttr = role:getOneItemByKey(item.itemId)

			itemInfo.name = itemAttr.name
			itemInfo.count = item.count
			itemInfo.func = function()
				local ckItems = role:getckItems()
				local item, i = role:getItemWithOnlyId(item.id)
				
				if not role:addItemCount(item.itemId, item.count,item.time,item.id,"放回背包") then
					return
				end

				if not MapIsEmpty(ckItems) then
					table.remove(ckItems, i)
				end

				--弹出一句话。显示放入仓库什么物品
				PopText("将" .. itemAttr.name .. " X" .. item.count .. "放回背包")

				self:showItemList()
				self:showcangkuItem()
			end

			table.insert(itemList,itemInfo)
		end
	end

	return itemList
end

function BagUI:__showCKItemList()
	self.Panel_cangku.ListView_cangku:setVisible(true)
    self.Panel_cangku.ListView_cangku:setSwallowTouches(false)

    local showItemsInfo = self:__getCKItemList()

    if MapIsEmpty(showItemsInfo) then
        self.Panel_cangku.ListView_cangku:removeAllItems()
        if self.CKlistViewSchedule then
            self:unschedule(self.CKlistViewSchedule)
            self.CKlistViewSchedule = nil
        end
        return
    end

    local roleItemNum = #showItemsInfo
    local listSize = self.Panel_cangku.ListView_cangku:getContentSize()
    local itemSize = self.Panel_item_ck:getContentSize()
    local itemsMargin = self.Panel_cangku.ListView_cangku:getItemsMargin()
    local itemMaxCount = Helper:mathFloor(listSize.height/(itemSize.height + itemsMargin)) + 2
    local isSchedule = true

    if roleItemNum < itemMaxCount then
        itemMaxCount = roleItemNum
        isSchedule = false
    end

	if not self.__lastItemNum then
		self.__lastItemNum = roleItemNum
	end

    self.Panel_cangku.ListView_cangku:setItemHeight(itemSize.height)

    self.Panel_cangku.ListView_cangku:setItemInitFunc(function(item,info)
        self:__initCKItemUI(item,info)
    end)

    self.Panel_cangku.ListView_cangku:setItemCreateFunc(function()
        return self:__getCKItemPanel()
    end)

    self.Panel_cangku.ListView_cangku:showListView(showItemsInfo,itemMaxCount)

    if isSchedule then
        if self.__CkListPos then
			local posY = math.min(self.__CkListPos.y - (roleItemNum - self.__lastItemNum) *  (itemSize.height + itemsMargin),self.Panel_cangku.ListView_cangku:getInnerContainerSize().height)
			posY = math.min(0,posY)
			if posY > self.Panel_cangku.ListView_cangku:getInnerContainerPosition().y then
                self.Panel_cangku.ListView_cangku:setInnerContainerPosition({x = self.__CkListPos.x, y = posY})
            end
        else
            self.Panel_cangku.ListView_cangku:jumpToTop()
        end

        local isTrue = self.Panel_cangku.ListView_cangku:refreshReuseItems()
		while isTrue do
			isTrue = self.Panel_cangku.ListView_cangku:refreshReuseItems()
		end

		if self.CKlistViewSchedule then
            self:unschedule(self.CKlistViewSchedule)
            self.CKlistViewSchedule = nil
        end 

        self.CKlistViewSchedule = self:schedule(function()
            self.Panel_cangku.ListView_cangku:refreshReuseItems()
            self.__CkListPos = self.Panel_cangku.ListView_cangku:getInnerContainerPosition()
        end)
    end

	self.__lastItemNum = roleItemNum
end

function BagUI:__initCKItemUI(itemPanel,itemInfo)
	itemPanel.Text_name:setColor(cc.c3b(208,208,208))---设置默认颜色
    itemPanel.Text_name:setString(itemInfo.name)
	itemPanel.Item_count:setString(itemInfo.count)
    itemPanel.Panel_dian:setVisible(false)
    itemPanel.Image_back:setVisible(false)
	itemPanel.Image_tiao:setVisible(false)
    
	itemPanel:releaseFunc(function()
		if itemInfo.func then
            itemInfo.func()
        end
    end)
end

-- 7/19
-- 背包点击一个物品，放入仓库
function BagUI:clickOneItem(item, itemAttr)
	if not item or type(item) ~= "table" then
		return
	end
	do
		if itemAttr.type == "家具" then
			if self.weaponShow then
				PopupLayerController:hideLayer("BagDescLayer",function ( layer )
					layer:hideLayer()
					self.weaponShow = false
				end,0)
			else
				self.Panel_itemDesc:setVisible(false)
			end

			self:itemDescHide(true)
			PopupLayerController:showLayer("FurnitureBackLayer",function (layer)
				layer:setRightButtonVisible(false)
				layer:setLeftButtonVisible(true)
				layer:setLeftButton("放仓\n入库",function ()
					--@desc 放入仓库
					self:pushCangKu(item,itemAttr)
					layer:hideLayer()
					self.__currShowPanel = nil
				end)
				
				layer:showLayer(item,itemAttr)
	
				self.__currShowPanel = layer
			end)
			return
		end
	
		self:hideCurrShowPanel()
	end

	if not self.weaponShow then
		self.Panel_itemDesc:setVisible(false)
	else
		PopupLayerController:hideLayer("BagDescLayer",function(layer)
			layer:hideLayer()
			self.weaponShow = false
		end,0)
	end

	-- 如果是书箱点击直接打开
	if item.itemId == "shuxiang" then
		self.Panel_itemDesc:setVisible(false)
		PopupLayerController:showLayer("BookCaseLayer", function(layer)
			layer:showLayer(true)
		end)
		return
	end

	-- 打开装饰箱
	if item.itemId == "decorativeBox" then
		self.Panel_itemDesc:setVisible(false)
        PopupLayerController:showLayer("DecorativeBoxLayer", function(layer)
        	layer:showLayer(function()
				self:showItemList()
		    	self:showcangkuItem()
		    end)
		end)
		return
	end

	-- 打开书匣
	if item.itemId == "literaryBox" then
		self.Panel_itemDesc:setVisible(false)
		PopupLayerController:showLayer("BookLiteraryLayer", function(layer)
			layer:showLayer(true)
		end)
		return
	end

	-- 打开药囊
	if item.itemId == "medicinalBox" then
		self.Panel_itemDesc:setVisible(false)
		PopupLayerController:showLayer(
			"MedicinalLayer",
			function(layer)
				layer:showLayer(true)
			end
		)
		return
	end
	--打开冶炼箱
	if item.itemId == "smeltBox" then
        self.Panel_itemDesc:setVisible(false)
        PopupLayerController:showLayer("SmeltBoxLayer",function(layer)
			layer:showLayer(true)
		end)
        return
	end
	
	--@desc 打开书架
	if item.itemId == "bookRack" then
        self.Panel_itemDesc:setVisible(false)
        PopupLayerController:showLayer("BookRackUI",function(layer)
			layer:showLayer()
		end)
        return
	end

	--@desc 打开续卷箱
	if item.itemId == "volumeBox" then
		self.Panel_itemDesc:setVisible(false)
		
		HttpManagerEx:getZhaoBreakThroughItems(User:getRole():getCurrencyVersion(),
			function(status, errcode, errmsg, data)
				if status == 200 and errcode == 0 then
					PopupLayerController:showLayer("VolumeBoxPresent",function(layer)
						layer:showLayer(data.matters_list)
					end)
				else
					PopText(errmsg)
				end
			end,
			IS_SHOW_WAITING
		)
        return
	end
	
	local role = User:getRole()
    local bagItems = User:getRole():getItems()
	local itemDesc = self.Panel_itemDesc
	self:setShowItem(itemAttr,item)
	
	if itemAttr.type == "面具" or itemAttr.type == "信物" or itemAttr.type == "挂饰" then
		self.Panel_itemDesc.Image_back.Image_button_cangku.Text_cangku:setString("放饰\n装箱")
	elseif itemAttr.type == "特殊" then
		-- Helper:print_lua_table(itemAttr)
		if itemAttr.id == "lingshi1"then
			self.Panel_itemDesc.Image_back.Image_button_cangku.Text_cangku:setString("询问")
		end
	elseif itemAttr.type == "书页" or itemAttr.type == "武学秘宝" then
		self.Panel_itemDesc.Image_back.Image_button_cangku.Text_cangku:setString("放书\n入箱")
	elseif itemAttr.type == "书籍" or itemAttr.type == "锻造图谱" or itemAttr.type == "毒术书籍" then
		self.Panel_itemDesc.Image_back.Image_button_cangku.Text_cangku:setString("放书\n入匣")
	elseif itemAttr.upgrade ~= nil then
		self.Panel_itemDesc.Image_back.Image_button_cangku.Text_cangku:setString("升\n级")
	elseif itemAttr.wpType == "神兵" then
		self.Panel_itemDesc.Image_back.Image_button_cangku.Text_cangku:setString("详\n情")
	elseif itemAttr.type == "房契" then
		self.Panel_itemDesc.Image_back.Image_button_cangku.Text_cangku:setString("前\n往")
	elseif itemAttr.type == "淬炼材料" or itemAttr.type == "锻造材料" then
		self.Panel_itemDesc.Image_back.Image_button_cangku.Text_cangku:setString("放炼\n冶箱")
	else
		self.Panel_itemDesc.Image_back.Image_button_cangku.Text_cangku:setString("放仓\n入库")
	end
	self.Panel_itemDesc.Image_back.Image_button_cangku:setVisible(true)

	self:setPanelItemDesc(item)
	--self:setButtonBack()
	if itemAttr.canUse == ITEM_STATE_FALSE and itemAttr.canEquip == ITEM_STATE_FALSE then
		-- 已经穿戴的面具特殊处理
		if role:checkItemIsEquip(item.id) and itemAttr.type == "面具" then
			itemAttr.equipPart = "head"
			self:setImageButton("卸\n下")
		elseif itemAttr.id == "shimenwupin29" or itemAttr.id == "shimenwupin30" or itemAttr.id == "shimenwupin32" or itemAttr.id == "shimenwupin33" then
			self:setImageButton("使\n用")
		elseif itemAttr.type == "家具" then
			self:setImageButton()
			--@TODO 2018-09-06 09:57:12 暂时不放出
			--if itemAttr.iType == "背包木人" or itemAttr.iType == "永久木人" then
			--	self:setImageButton("练\n功")
			--end
		elseif itemAttr.id == "szjdj2" then
			self:setImageButton("查\n看")
		else
			self:setImageButton()
		end
	else
		if itemAttr.canUse == ITEM_STATE_FALSE then

			if role:checkItemIsEquip(item.id) then
				self:setImageButton("卸\n下")
			else
				self:setImageButton("穿\n上")
			end
		elseif itemAttr.combo == ITEM_STATE_TRUE then
			self:setImageButton("合\n成")
		elseif itemAttr.id == "zhongyuanlazhu1" or itemAttr.id == "zhongyuannuomi1" or itemAttr.id == "zhongyuuangouyuan1" or itemAttr.id == "zhongyuantaomujian1" or itemAttr.id == "zhongyuantaotongqian1" then
			self:setImageButton()
		elseif itemAttr.type == "锻造图谱" then
			self:setImageButton("学\n习")
		elseif itemAttr.type == "历练任务" then
			if User:getRole():getSkill("wuxingdunfa") ~= nil then
				if User:getRole():getTask(User:getRole():getAttr("currTaskId")) ~= nil then
					if User:getRole():getTask(User:getRole():getAttr("currTaskId")).state == TASK_STATE_TO_SUBMIT then
						self:setImageButton()
					else
						self:setImageButton("快前\n速往")
					end
				end
			else
				self:setImageButton()
			end
		elseif itemAttr.type == "房契" or itemAttr.type == "地契" then
			self:setImageButton("查\n看")
		else
			self:setImageButton("使\n用")
		end
	end

	-- 背包内不可使用 书页 武学秘宝
	if itemAttr.type == "书页" or itemAttr.type == "武学秘宝" then
		self:setImageButton()
	end
	if itemAttr.equipPart == "weapon" then
		self.weaponShow = true
		self:itemDescHide(true)
		PopupLayerController:showLayer("BagDescLayer",function(layer)
			-- layer:hideLayer()

			layer:setRefreshListFunc(function()
				self:showItemList()
			end)
			layer:setBackFunc(function()
				self:ButtonHelp()
			end)
			layer:setEquipItemFunc(function(item, itemAttr)
				self:equipOneItem(item, itemAttr)
			end)
			layer:setPrepareButtonVisible(true,item)
			layer:setCangKuButtonVisible("放仓\n入库")
			layer:setCangKuFunc(function()
				self:showcangkuItem()
			end)
			layer:setPrepareFunc(function(btnType)
			end)
			layer:showLayer(item,itemAttr)
		end)
	else
		if self.__currShowPanel then
			self.__currShowPanel:hideLayer()
			self.__currShowPanel = nil
		else
			if self.weaponShow then
				PopupLayerController:hideLayer("BagDescLayer",function(layer)
					layer:hideLayer()
					self.weaponShow = false
				end,0)
			end
			self:itemDescShow(true)
		end

	end

	itemDesc.Image_back.Image_button:setTouchEnabled(true)
	itemDesc.Image_back:setTouchEnabled(true)
	itemDesc.Image_back.Image_button:releaseFunc(function()
		if itemAttr.canUse == ITEM_STATE_FALSE then
			if itemAttr.id == "shimenwupin29" or itemAttr.id == "shimenwupin30" or itemAttr.id == "shimenwupin32" or itemAttr.id == "shimenwupin33" then
				itemAttr:useItem(function()
					self:showItemList()
				end)
			elseif itemAttr.id == "szjdj2" then 
			    local text = "少侠亲启：\n      剪去三秋趣未穷，聆得五载枯有枝。\n \n      小女姓凌，随父调任知府之职而居姑苏宝地。深闺女子见识粗鄙，但也曾闻听少侠侠名。今有一段愁情相告，亦有一事相托。\n \n      神功现世向来为武林人所争，这本与小女毫无关联，只因一场赏菊会，让小女有幸识得丁大哥缘定三生。不料父亲为夺取神功，竟将丁大哥锁入牢中，致使我们再无相见之日。\n \n      多年来，我每日会在凌府二楼的窗槛上为丁大哥放上一束花束，以托相思。可怜如今......貌丑无盐，已不愿再出闺门半步。遂恳请少侠相助，至凌府摆放花束。少侠登楼放花时，或遇他人为难，只需将此信交出即可。"
			    PopupLayerController:showLayer(
			        "PopTextLayer2",
			        function(layer)
			            layer:showLayer(true)
			            layer:setTitle(itemAttr.name)
			            layer:setTitle2()
			            layer:print(text)
			            layer:setLogVisible(false)
			            layer:setBtn1(
            			)
			            layer:setBtn2(
			                "关闭",
			                function()
			                    layer:hideLayer()
			                end
			            )
			        end
			    )
			else
				self:equipOneItem(item, itemAttr)
				self:showItemList()
			end
		elseif itemAttr.type == "历练任务" then
			local TaskItemModel = require("app.models.TaskItems.TaskItemModel")
			TaskItemModel:useTaskItem(itemAttr)
		elseif itemAttr.type == "房契" then
			local fqModel = require("app.models.HomelandModel.FangQiModel")
			fqModel:viewFangQi()
			self:itemDescHide(false)
		elseif itemAttr.type == "地契" then
			local DiQiModel = require("app.models.HomelandModel.DiQiModel")
			DiQiModel:viewDiQi(itemAttr.id,itemAttr.dpId)
			self:itemDescHide(false)
		else
			local item,i=role:getItemWithOnlyId(item.id)

			-- 使用消耗品方法
			itemAttr:useItem(function()
				self:showItemList()
			end,nil,nil,nil,nil,item.count)
		end
		self:itemDescHide(true)
    end)

	--处理神兵不让放入仓库
	if (itemAttr.type == "特殊" and itemAttr.id ~= "lingshi1") or itemAttr.type == "邀请函" or itemAttr.id =="szjdj2" then
		itemDesc.Image_back.Image_button_cangku:setVisible(false)
	else
	    --c处理放入仓库
		itemDesc.Image_back.Image_button_cangku:setVisible(true)
	    itemDesc.Image_back.Image_button_cangku:setTouchEnabled(true)
	    itemDesc.Image_back:setTouchEnabled(true)
	    itemDesc.Image_back.Image_button_cangku:releaseFunc(function()
	    	self:itemDescHide(true)

	    	local item,i=role:getItemWithOnlyId(item.id)
	    	if item == nil then
		    	self:showItemList()
		    	self:showcangkuItem()
		    	return
	    	end
			local ckItems = role:getAttr("ckitems")

	    	if itemAttr.type == "面具" or itemAttr.type == "信物" or itemAttr.type == "挂饰" then
	    		if role:checkItemIsEquip(item.id) then
	    			PopText("装备已经穿上，请先卸下再放入装饰箱")
		    		return
	    		end
				if role:getDecorativeCount(itemAttr.id) > 0 then
					local typeDsc = "你已经拥有相同的饰品，装饰箱内相同饰品只显示一个，是否放入？（可在家园雇佣绣女，将多余饰品转化为饰品材料）"
	    			local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
					local dialog = DialogALayer:getInstance()
					dialog:hide()
					dialog:show(typeDsc)
					dialog:setRichText(typeDsc)
					dialog:setButton1("是", function()
						if role:addDecorative(item.itemId, item.count) ~= true then
							return
						end
						if not MapIsEmpty(bagItems) then
					    	table.remove(bagItems,i)
					    end
		    			PopText("将"..itemAttr.name.." X"..item.count.."放入装饰箱")
		    			self:showItemList()
					end)

					dialog:setButton2("否", function()
						dialog:hide()
					end)
	    		else
	    			if role:addDecorative(item.itemId, item.count) ~= true then
						return
					end
					if not MapIsEmpty(bagItems) then
				    	table.remove(bagItems,i)
				    end
	    			PopText("将"..itemAttr.name.." X"..item.count.."放入装饰箱")
	    			self:showItemList()
	    		end
	    		return
	    	end
	    	if itemAttr.wpType == "神兵" then
	    		-- PopText("查看神兵")
				local ItemDescInfo = require("app.models.item.ItemDescInfo")
				local weaponInfo = ItemDescInfo:getShenBingDescInfo(itemAttr, role)
	    		PopupLayerController:showLayer(
					"WeaponDescInfoPresenter",
					function(layer)
						layer:setData(weaponInfo)
						layer:showLayer()
					end
				)
	    		return
	    	end
	    	if itemAttr.type == "特殊" then
				local RoleTaskControllor = require("app.views.layer.RoleLayer.RoleTaskControllor")
				if RoleTaskControllor:clickMapLayer(role) == false then
					return
				end
	    		local ShenShu = require("app.views.layer.ShenShu.ShenShuLayer")
				ShenShu:shouLayer(2,nil,function()
					User:getRole():addItemCount("lingshi1",-1)
					self:showItemList()
				end)
				return
			end
	    	if itemAttr.type == "书页" or itemAttr.type == "武学秘宝" then
	    		if role:addItemCount(item.itemId, item.count,item.time) ~= true then
	    			return
	    		end
	    		if not MapIsEmpty(bagItems) then
		    		table.remove(bagItems,i)
		    	end
		    	local itemAttr = User:getRole():getOneItemByKey(item.itemId)
		    	PopText("将"..itemAttr.name.." X"..item.count.."放入书箱")
	    		self:showItemList()
	    		self:showcangkuItem()
	    		return
	    	end
	    	if itemAttr.upgrade ~= nil then
	    		if role:checkItemIsEquip(item.id) then
	    			PopText("装备已经穿上，请先卸下再升级")
		    		return
	    		end
	    		itemAttr:upgradeItem(role, function()
	    			if not MapIsEmpty(bagItems) then
			    		table.remove(bagItems,i)
			    	end
	    		end)
	    		self:showItemList()
	    		self:showcangkuItem()
	    		return
	    	end

	    	if itemAttr.type == "书籍" or itemAttr.type == "锻造图谱" or itemAttr.type == "毒术书籍" then
	    		if role:addLiteraryBox(item.itemId, item.count) ~= true then
	    			return
	    		end

	    		local BookLiterary = require("app.models.book.BookLiterary")

    			PopText("将"..itemAttr.name.." X"..item.count.."放入书匣")

	    		local count = role:getLiteraryCount(BookLiterary:getLiteraryByItemId(item.itemId).id)
		    	if count <= 10 and count * BookLiterary:getLiteraryByItemId(item.itemId).jifen <= BookLiterary:getLiteraryByItemId(item.itemId).jifenlimit then
		    		PopText("藏书评价 + " .. BookLiterary:getLiteraryByItemId(item.itemId).jifen)
		  		end

				  
				if not MapIsEmpty(bagItems) then
		    		table.remove(bagItems,i)
				end

				if count == 1 then
					if itemAttr.type == "毒术书籍" then
						PoisonFormula:unlockPoisonFormulaByBookLvUp(0,1,item.itemId)
					elseif itemAttr.type == "锻造图谱" then
						ForgeSkill:addUserFoegeKnowledge(item.itemId)
					end
				end
				
	    		self:showItemList()
	    		self:showcangkuItem()
	    		return
	    	end

			if itemAttr.type == "房契" then
				local FangQiModel = require("app.models.HomelandModel.FangQiModel")
				FangQiModel:useItemToUserMap()
	    		return
	    	end

			if itemAttr.type == "淬炼材料" or itemAttr.type == "锻造材料" then
	    		if role:addItemCount(item.itemId, item.count,item.time) ~= true then
	    			return
	    		end
	    		if not MapIsEmpty(bagItems) then
		    		table.remove(bagItems,i)
		    	end
		    	local itemAttr = User:getRole():getOneItemByKey(item.itemId)
		    	PopText("将"..itemAttr.name.." X"..item.count.."放入冶炼箱")
	    		self:showItemList()
	    		return
	    	end

			self:pushCangKu(item,itemAttr)
	    end)
	end
end

--@desc:放入仓库的逻辑 
--@author:Liang SongQiang
--@time:2018-09-07 20:06:33
function BagUI:pushCangKu(item,itemAttr)
	local role = User:getRole()

	local bagItems = role:getItems()

	local item,index=role:getItemWithOnlyId(item.id)

	if role:checkItemIsEquip(item.id) then
		PopText("装备已经穿上，请先卸下再放入仓库。")
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
	if not role:addItemCountck(item.itemId,item.count,item.time,item.id) then
		return
	end
	if not MapIsEmpty(bagItems) then
		table.remove(bagItems,index)
		local Record = require("app.models.Record.Record")
		local logData = {}
		logData[item.itemId] = -item.count
		Record:addLog(Record.LOG_TYPE.ITEM,logData,"放入仓库")
	end
	--弹出一句话。显示放入仓库什么物品
	local itemAttr = User:getRole():getOneItemByKey(item.itemId)
	PopText("将"..itemAttr.name.." X"..item.count.."放入仓库")
	self:showItemList()
	self:showcangkuItem()
end

-- 装备一件物品
function BagUI:equipOneItem(item, itemAttr)
	if MapIsEmpty(item) then
		return
	end
	if item.type == "神兵" then
		local weapon = User:getRole():getOneItemByKey(item.itemId)
		if weapon.wanhaodu == 0 then
			PopText("该武器已被损坏")
			return
		end
	else
		if item.wanhaodu and item.wanhaodu == 0 then
			PopText("该武器已被损坏")	
			return
		end
	end
	local role = User:getRole()

	local desc = ""
	if not User:getRole():checkItemIsEquip(item.id) then
		self:setImageButton("卸\n下")
		role:setEquipByName(itemAttr.equipPart, item)

		desc = itemAttr.equipText
		if itemAttr.wpType == "神兵" then
			desc = ShenBingDesc:getWeaponEquipText(itemAttr)
		end
	else
		self:setImageButton("穿\n上")
		role:setEquipByName(itemAttr.equipPart, nil)
		desc = itemAttr.unwieldText
		if itemAttr.wpType == "神兵" then
			desc = ShenBingDesc:getWeaponTakeOffText(itemAttr)
		end
	end
	desc = string.gsub(desc, "$N", "你")
	desc = string.gsub(desc, "$w", itemAttr.name)
	desc = string.gsub(desc, "$W", itemAttr.name)
	RichPrint("main", "WHT" .. tostring(desc))
end

-- 按钮名字
function BagUI:setImageButton(str)
	if not str then
		self.Panel_itemDesc.Image_back.Image_button:setVisible(false)
	else
		self.Panel_itemDesc.Image_back.Image_button:setVisible(true)
		self.Panel_itemDesc.Image_back.Image_button.Text_chuan:setString(str)
	end
end

-- 弹出窗描述信息
function BagUI:setPanelItemDesc(item)
	local role = User:getRole()
	local tab = role:getOneItemByKey(item.itemId)
	local itemDesc = ""

	self.Panel_itemDesc.Image_back.Panel_title.Text_name:setString("DWT")
	self.Panel_itemDesc.Image_back.Panel_title.Text_name:setString(tab.name)
	self.Panel_itemDesc.Image_back.Panel_title.Text_zhuangbei:setString(tab.type)
	
	if tab.type == "神书" then
		local str
		local ShenShuHelper = require("app.models.shenshu.shenshu")
		local list = ShenShuHelper:getTaskSongLiNpcList(role)
		
		for k, v in pairs(list) do
			if v.bookId == item.itemId then
				-- Helper:print_lua_table(v)
				if tab.name and v.name then
					str = "这是一本书，上面写着" .. tab.name .. "几个大字，听说" .. v.name .. "正在寻找这本书籍，该书籍每晚24点将会消失。"
				end
			end
		end
		if str then
			itemDesc = str
		end
		-- self.Panel_itemDesc.Image_back.TextField_desc:setString("这是一本神书")
	elseif type(tab.timeend) == "number" or type(tab.timeend) =="string" then
		itemDesc = tab:getDsc()
		self:setShowItem(tab,item)
	elseif tab.id =="item201_17new21" then
		itemDesc = role:getAttr("ghostInfo").itemDes
	else
		itemDesc = tab:getDsc()
	end

	self:__initItemDesc(itemDesc)
	self.Panel_itemDesc.Text_onlyid:setString(item.id)
end

function BagUI:__initItemDesc(str)
	self.Panel_itemDesc.Image_back.ListView_desc:removeAllItems()

	local panel = self.Panel_desc:clone()
	local text = self.TextField_desc:clone()
	text:setColor(cc.c3b(97,97,97))
	text:setTextAreaSize({width = 610, height = 0})
    text:ignoreContentAdaptWithSize(true)
    text:setString(str)

    local contentSize = text:getAutoRenderSize()
    panel:setSize({width = 610, height = contentSize.height})
    panel:addChild(text)
	text:setPosition(cc.p(0,0))

	if contentSize.height > 300 then
		self.Panel_itemDesc.Image_back.ListView_desc:setTouchEnabled(true)
	else
		self.Panel_itemDesc.Image_back.ListView_desc:setTouchEnabled(false)
	end

	self.Panel_itemDesc.Image_back.ListView_desc:pushBackCustomItem(panel)
end

-- 物品描述显示
function BagUI:itemDescShow(anim)
	self.Panel_itemDesc:setTouchEnabled(true)
	local panel = self.Panel_itemDesc
	panel:setVisible(true)
	local actionTag = panel:getActionTagByName("move")
	panel:stopActionByTag(actionTag)
	panel:move(cc.p(380, 1610))
	local action = cc.Sequence:create(
		cc.Spawn:create(
		cc.MoveTo:create(UI_ANIM_DURATION, cc.p(380, 1440)),
		cc.FadeIn:create(UI_ANIM_DURATION)
		), cc.CallFunc:create(
			function()
	end))
	action:setTag(actionTag)
	panel:runAction(action)
end

-- 物品描述隐藏
function BagUI:itemDescHide(anim)
	self.Panel_itemDesc:setTouchEnabled(false)
	Helper:callChildrenByParent(self.Panel_itemDesc, function(parent, child)
		child:setTouchEnabled(false)
	end)
	self.Is_show = false
	local panel = self.Panel_itemDesc
	local actionTag = panel:getActionTagByName("move")
	panel:stopActionByTag(actionTag)
	panel:setCascadeOpacityEnabled(true)
	panel:callAllChild(function(child)
		child:setCascadeOpacityEnabled(true)
	end)
	local action = cc.Sequence:create(
		cc.Spawn:create(
		cc.MoveTo:create(UI_ANIM_DURATION, cc.p(380, 1536)),
		cc.FadeOut:create(UI_ANIM_DURATION)
	),
	cc.CallFunc:create(
		function()
			self:setShowItem()
	end))
	action:setTag(actionTag)
	panel:runAction(action)
end

--7/20
--设置金币数量
function BagUI:setCoin(gold, silver)
	gold = Helper:getDef(gold, 0)
	silver = Helper:getDef(silver, 0)

	local Panel_money = self.Panel_money

	--设置gold silver的数目
	local goldNUm = Panel_money.Text_Gold_Num:setString(" " .. tostring(gold))
	local silver = Panel_money.Text_silver:setString(" " .. tostring(silver) .. "碎银")

	--	获取Text_Gold_Num和Text_gold的大小
	local goldNUmSzie = Panel_money.Text_Gold_Num:getContentSize()
	local goldSize = Panel_money.Text_gold:getContentSize()
	--将Panel_money和获取Text_Gold_Num和Text_gold的大小设置到对应位置上去
	Panel_money.Text_gold:setPositionX(Panel_money.Text_Gold_Num:getPositionX() + goldNUmSzie.width)
	Panel_money.Text_silver:setPositionX(Panel_money.Text_gold:getPositionX() + goldSize.width)
end

--设置背包重量
function BagUI:setWeight()
	local role = User:getRole()
	local weight = #role:getItems() .. "/" .. role:getAttr("weight")
	self.Text_weight:setString(weight)
end

--设置仓库上限
function BagUI:setckLimit()
	local role = User:getRole()
	local ckLimit = #role:getckItems() .. "/" .. role:getAttr("ckLimit")
	self.Text_ck_limit:setString(ckLimit)
end

function BagUI:setButtonBack()
	local printLayer = MainControllLayer:getLayer("PrintLayer")
	local title = MainControllLayer:getLayer("TitleLayer")
	printLayer:setPanelVisible(true)
	printLayer:setPanleReleaseFunc(function()
		if self.__currShowPanel then
			self.__currShowPanel:hideLayer()
			self.__currShowPanel = nil
		else
			self.Panel_itemDesc:setVisible(false)
		end

		self:ButtonHelp()
	end)
	title:ButtonBack(function()
		if self.__currShowPanel then
			self.__currShowPanel:hideLayer()
			self.__currShowPanel = nil
		else
			self.Panel_itemDesc:setVisible(false)
		end
		self:ButtonHelp()
	end)
end

function BagUI:ButtonHelp()
	local printLayer = MainControllLayer:getLayer("PrintLayer")
	local title = MainControllLayer:getLayer("TitleLayer")
	self:setShowItem(nil,nil)
	title:setTitleBack()
	printLayer:setPanelVisible(false)
end

-- add by XiaoZhiWei 2018/01/11 14:52:24 处理背包已满,神兵无法领取的问题
function BagUI:resolveBagIsFullShenBingCanNot()
	local role = User:getRole()
	local shenBingweapon = User:getRole().shenBingweapon
	local BagItems = role:getItems()

	--判断神兵是否在背包里
	local function shenBingweaponIsInBag()
		for i, item in ipairs(BagItems) do
			local itemAttr = role:getItemWithOnlyId(item.id)
			if itemAttr.itemId == shenBingweapon.id then
				return true
			end
		end
		return false
	end
	--判断背包是否满了
	local function bagItemsIsFull()
		if #BagItems >= role:getAttr("weight") then
			return true
		end
		return false
	end

	--所有玩家都要执行一次，如果神兵打造了，又在背包里，设置标志
	if shenBingweapon.status == "2" and shenBingweaponIsInBag() then
		shenBingweapon.IsInBagItems = true
	elseif shenBingweapon.status == "2" and not shenBingweaponIsInBag() then
		--如果背包有格子，直接加进去
		if not bagItemsIsFull() then
			--将神兵放入背包
			if role:addItemCount(shenBingweapon.id, 1) then
				shenBingweapon.IsInBagItems = true
			end
		else
			PopText("背包满了。神兵无法放入背包！")
		end
	end
end

function BagUI:update(ft)
    if self.__currShowPanel then
        self.__currShowPanel:update(ft)
    end
    self:showCDAndCalc()
    self:refreshTime()
    self:checkUserItem()
end

-- add by XiaoZhiWei 2018/01/11 15:09:06 唤醒
function BagUI:onResume()
	self._lastClick = 1
	self._ckLastClick = 1
	self:showItemList()
	self:showcangkuItem()
end

-- add by XiaoZhiWei 2018/01/11 15:09:11 暂停
function BagUI:onPause()
	self:itemDescHide()
end

function BagUI:hideCurrShowPanel()
	if self.__currShowPanel then
		self.__currShowPanel:hideLayer()
		self.__currShowPanel = nil
	end
end

return BagUI000000000