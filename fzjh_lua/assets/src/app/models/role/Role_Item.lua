local AddItemCountExecutorFactory = require("app.models.role.item.AddItem.AddItemCountExecutorFactory")
local RoleUseItemFactory = require("app.models.role.item.UseItem.RoleUseItemFactory")

local Role_Item = {}

-- @author XiaoZhiWei
-- @time 2017/08/21 10:33:41
-- @desc 角色创建安全的列表table
local function roleCreateSafeTable(key, tab)
	key = Helper:getDef(key, tostring(User:getUserId()))
	return createSafeTable(key, tab, function(tab, valueName, valueFrom, valueTo)
		Collection:memoryCheat(User:getUserId(), valueName, valueFrom, valueTo)
	end)
end

-- 物品
function Role_Item:getItem(itemId)
	for i, item in ipairs(self.items) do
		if item.itemId == itemId then
			return item, i
		end
	end
	for i, item in ipairs(self.shuxiang) do
		if item.itemId == itemId then
			return item, i
		end
	end
	--@desc 搜索药囊
	for i, item in ipairs(self.medicinalBox) do
		if item.itemId == itemId then
			return item, i
		end
	end
	for i, item in ipairs(self.smeltBox) do
		if item.itemId == itemId then
			return item, i
		end
	end
	if PRINT_MODE == 1 then
		print("没有该物品!!!")
	end
	return nil
end

-- 获取装备箱物品
function Role_Item:getzbItem(itemId)
	for i, item in ipairs(self.equipsBox) do
		if item.itemId == itemId then
			return item, i
		end
	end

	return nil
end

--获取装饰箱物品
function Role_Item:getDecorative(itemId)
	for i, item in ipairs(self.decorative) do
		if item.itemId == itemId then
			return item, i
		end
	end

	return nil
end

-- @author XiaoZhiWei
-- @time 2017/03/29 18:17:08
-- @desc 获取招式书箱物品
function Role_Item:getZhaoShuXiang(itemId)
	for i, item in ipairs(self.zhaoShuXiang) do
		if item.itemId == itemId then
			return item, i
		end
	end

	return nil
end

-- 获得书页列表
function Role_Item:getBookItems()
	local items = self.shuxiang
	if #items <= 0 then
		if PRINT_MODE == 1 then
			print(self:getName().."的书箱是空的")
		end
	end
	return items
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/04/08 16:37:09
-- @desc 获得武功残页列表
function Role_Item:getZhaoShuXiangItems()
	local items = self.zhaoShuXiang
	if MapIsEmpty(items) == true then
		if PRINT_MODE == 1 then
			print(self:getName().."的秘籍残页是空的")
		end
	end
	return items
end

-- 物品 通过唯一ID查找，不仅仅查找背包里的，还有仓库里的
function Role_Item:getItemWithOnlyId(onlyId)
	assert(onlyId, "Role_Item:getItemWithOnlyId(onlyId) -> 数据异常不能传空值")
	for i, item in ipairs(self.items) do
		if item.id == onlyId then
			return item, i
		end
	end
	for i, item in ipairs(self.ckitems) do
		if item.id == onlyId then

			return item,i
		end
	end
	for i, item in ipairs(self.equipsBox) do
		if item.id == onlyId then

			return item,i
		end
	end
	for i,item in ipairs(self.medicinalBox) do
		if item.id == onlyId then

			return item,i
		end
	end
	for i,item in ipairs(self.smeltBox) do
		if item.id == onlyId then

			return item,i
		end
	end
	return nil
end

-- 仓库通过物品ItemId获取改物品的列表 （物品分为多组的情况）
function Role_Item:getItemsWithItemIdck(itemId)
	return self:getItemsWithItemId(itemId, "ck")
end

-- 通过物品ItemId获取改物品的列表 （物品分为多组的情况）
function Role_Item:getItemsWithItemId(itemId, bagType)
	local items 		-- 储存位置所有物品列表
	local list = {} 	-- 返回数据存储列表

	if itemId == nil then  -- itemId 不存在直接返回空列表 不做多余的操作
		return list
	end

	if bagType == nil then -- 默认是背包（bag）类型
		bagType = "bag"
	end

	if bagType == "bag" then -- 背包
		items = self.items
	elseif bagType == "ck" then -- 仓库
		items = self.ckitems
	elseif bagType == "shuxiang" then -- 书箱
		items = self.shuxiang
	elseif bagType == "decorative" then -- 装饰箱
		items = self.decorative
	elseif bagType == "zhaoShuXiang" then -- 招式书箱
		items = self.zhaoShuXiang
	elseif bagType == "literaryBox" then -- 文学书箱
		items = self.literaryBox
	elseif bagType == "equipsBox" then -- 装备箱
		items = self.equipsBox
	elseif bagType == "medicinalBox" then -- 药囊
		items = self.medicinalBox
	elseif bagType == "smeltBox" then -- 冶炼箱
		items = self.smeltBox
	else
		return list
	end

	for i, item in ipairs(items) do
		if item.itemId == itemId then
			item.index = i
			table.insert(list, item)
		end
	end
	return list
end

-- 修改仓库物品数目
function Role_Item:addItemCountck(itemId, count,time,onlyId)
	if not itemId then
		assert(nil, "Role_Item:addItemCountck(itemId, count) -> can not use nil itemId")
	end
	if PRINT_MODE == 1 then
		print("Role_Item:addItemCountck("..tostring(itemId)..", "..tostring(count)..")")
	end

	assert(type(count) == "number")
	local itemAttr = self:getOneItemByKey(itemId)
	if not itemAttr then
		if PRINT_MODE == 1 then
			print("物品不存在")
		end
		return nil
	end

	if not self:checkCanBuyThingsck(itemId,count) then
		-- PopText("仓库容量达到上限，无法将物品放入仓库")
		return
	end

	-- 判断是否可堆叠
	local item, ckitems

	if itemAttr.canFold == ITEM_STATE_FALSE then   --不能堆叠
		if count > 0 then
            for i=1,count do
                --@desc 给武器淬毒或其它增加效果的功能后，需使用onlyId进行索引
                local id = onlyId or self:getItemOnlyId()
				item = {id = id, count = 1 , itemId = itemId,time = time}
				table.insert(self.ckitems, roleCreateSafeTable("player.ckitems."..tostring(itemId), item))
			end
		elseif count < 0 then
			items = self:getItemsWithItemIdck(itemId)
			if not MapIsEmpty(ckitems) then
				for i=1,math.floor(-count) do
					table.remove(self.ckitems, ckitems[i].index)
				end
			end
		end
	elseif itemAttr.canFold == ITEM_STATE_TRUE then   --能堆叠
		ckitems = self:getItemsWithItemIdck(itemId)
		if not MapIsEmpty(ckitems) then
			for i,v in ipairs(ckitems) do
				if math.floor(count) > 0 then
					v.count = v.count + count
					-- 最大堆叠数99
					if v.count > 99 then
						count = v.count - 99
						v.count = 99
					else
						count = 0
					end
				elseif count < 0 then
					v.count = v.count + count
					if v.count <= 0 then
						count = v.count
						table.remove(self.ckitems, v.index)
					else
						count = 0
					end
				else
					break
				end
			end
			if count > 99 then
				local num = count
				local length = math.ceil(num/99)
				for i=1,length do
					item = {id = self:getItemOnlyId(), count = 99 , itemId = itemId,time = time}
					if i == length then
						item.count = math.floor(math.mod(count, 99))
					end
					table.insert(self.ckitems, roleCreateSafeTable("player.ckitems."..tostring(itemId), item))
				end
			elseif count > 0 then
				item = {id = self:getItemOnlyId(), count = count , itemId = itemId,time = time}
				table.insert(self.ckitems, roleCreateSafeTable("player.ckitems."..tostring(itemId), item))
			end
		else
			if count > 0 then
				item = {id = self:getItemOnlyId(), count = count , itemId = itemId,time = time}
				table.insert(self.ckitems, roleCreateSafeTable("player.ckitems."..tostring(itemId), item))
			end
		end
	end
	return true
end

-- 检查物品是否能使用
function Role_Item:itemCanUse(itemId, count)
	if itemId == nil then
		return false
	end

	local items = self:getItemsWithItemId(itemId)
	-- 如果背包 没有该物品，则不能使用
	if MapIsEmpty(items) == true then
	else
		for i,item in pairs(items) do
			-- 判断背包物品数量是否 大于需要减去的数量
			if count > item.count then
				count = count - item.count
			else
				return true
			end
		end
	end

	items = self:getItemsWithItemId(itemId, "shuxiang")
	if MapIsEmpty(items) == true then
	else
		for i,item in pairs(items) do
			-- 判断书箱物品数量是否 大于需要减去的数量
			if count > item.count then
				count = count - item.count
			else
				return true
			end
		end
	end

	return false
end

-- @desc 使用物品
function Role_Item:useItem(itemId, func, specialType, useItemNum)
	return self._roleItemSystem:useItem(itemId, func, specialType, useItemNum)
end

function Role_Item:addItemCount(itemId, count, time, onlyId, tag)
	local addCount = count

	if addCount == 0 then
		print("Role_Item:addItemCount count is 0 : " , itemId)
		return
	end

    if not itemId then
        assert(nil, "Role_Item:addItemCount(itemId, count) -> can not use nil itemId")
    end

    if PRINT_MODE == 1 then
        print("Role_Item:addItemCount(" .. tostring(itemId) .. ", " .. tostring(count) .. ")")
    end

    assert(type(count) == "number")
    local itemAttr = self:getOneItemByKey(itemId)
    if not itemAttr then
        if PRINT_MODE == 1 then
            print("物品不存在")
        end
        return nil
    end

    local function recordItemFun()
        local Record = require("app.models.Record.Record")
        local logData = {}
        logData[itemId] = count
        local logOrigin = tag

        if self:getAttr("userid") ~= User:getUserId() then
            return EMPTY_FUNC
        end

        return function()
            Record:addLog(Record.LOG_TYPE.ITEM, logData, logOrigin)
        end
    end

    local recordFun = recordItemFun()

    local result, item = self:changeItemCount(itemId, count, time, onlyId)

    if result == true then
        -- 副本内使用普通物品
        if count < 0 and self:getCurrMapId() ~= nil and self:getCurrMap() ~= nil and self:getCurrMap():getRoleIsInMap() == true and MainControllLayer:getCurrLayer() == "MapLayer" then
            local mapLayer = MainControllLayer:getLayer("MapLayer")
            --触发条件 使用普通物品 判断是否在可使用的房间内
            self:getCurrMap():doRoomConditionAndResult(
                mapLayer._currRoom.id,
                {
                    operation = "使用普通物品",
                    useItemId = itemId,
                    currRoomId = mapLayer._currRoom.id,
                    mapLayer = mapLayer,
                    func = function()
                    end
                }
            )
        end

        if count < 0 and item then
            --@desc 删除淬毒效果
            local PoisonUtil = require("app.models.Poison.PoisonUtil")
            if PoisonUtil:checkWeaponIsPoison(item.id) then
                PoisonUtil:clearPoisonWeapon(item.id)
            end
        end

        --@desc 物品变化导致携带的buff变化
        self:addItemBuffByItemId(itemId, addCount)
        MessageCenter:notify("itemChangeEvent", {role = self, itemId = itemId, count = addCount})
        recordFun()
    end

    return result, item
end


function Role_Item:changeItemCount(itemId,count,time,onlyId)
	if not itemId then
		assert(false, "Role_Item:changeItemCount(itemId, count) -> can not use nil itemId")
	end

	if PRINT_MODE == 1 then
		print("Role_Item:changeItemCount("..tostring(itemId)..", "..tostring(count)..")")
	end
	assert(type(count) == "number")

	local itemAttr = self:getOneItemByKey(itemId)
	if not itemAttr then
		if PRINT_MODE == 1 then
			print("物品不存在")
		end
		return false
	end

	if itemAttr.type == "书页" or itemAttr.type == "武学秘宝" then
		local result , outputItem = self:addKongFuBook(itemId,count)
		return result , outputItem
	end

	if itemAttr.type == "秘籍残页" then
		local result , outputItem = self:addZhaoShuXiang(itemId,count)
		return result , outputItem
	end

	if (itemAttr.type == "毒药" or itemAttr.type == "制药材料")  then
		local MedicinalBoxModel = require("app.models.Poison.MedicinalBoxModel")
		local result , outputItem = MedicinalBoxModel:addItemToMedicinalBox(itemId,count,self)
		return result , outputItem
	end

	if itemAttr.type == "淬炼材料" or itemAttr.type == "锻造材料" then
		local result , outputItem = self:addItemToSmeltBox(itemId,count)

		return result , outputItem
	end

	if count < 0 and self:itemCanUse(itemId, ( - count)) == false then
		-- 不能使用该物品，因为背包里面没有
		return false
	end

	-- 只有增加数大于0才需要判断背包容量
	if count > 0 and not self:checkCanBuyThings(itemId,count) then
		return false
	end

	-- @desc 获取时间
	if time == nil then
		time = self:getItemTimeLimit(itemAttr)
	end

	--倒计时限时道具默认使用持续时间最短的
	if count < 0 and type(itemAttr.timeend) == "number" then
		onlyId = self:getItemTimeLeastOnlyId(itemId)
	end

	local item = self:doAddItemCount(itemId, count, time, onlyId)

	return true , item
end

function Role_Item:addKongFuBook(itemId,count)
	return self:addNoLimitItem(self.shuxiang,itemId,count)
end


function Role_Item:addZhaoShuXiang(itemId,count)
	return self:addNoLimitItem(self.zhaoShuXiang,itemId,count)
end

function Role_Item:addNoLimitItem(items,itemId,count)
	local outputItem = nil

	local itemAttr = self:getOneItemByKey(itemId)

	local addKongFuBookCountExecutor = AddItemCountExecutorFactory:getAddKongFuBookCountExecutor()

	addKongFuBookCountExecutor:setItems(items)
	addKongFuBookCountExecutor:setItemId(itemId)
	addKongFuBookCountExecutor:setAddCount(count)
	addKongFuBookCountExecutor:setItemCreateFunc(function (itemId)
		local item = {id = self:getItemOnlyId(), count = 0 , itemId = itemId}
		return self:createSafeItem(item)
	end)
	addKongFuBookCountExecutor:execute()

	local addItems,removeItems = addKongFuBookCountExecutor:getModifys()

	--@desc 暂时返回一个数据
	if MapIsEmpty(addItems) == false then
		outputItem = addItems[#addItems].item
	elseif MapIsEmpty(removeItems) == false then

		outputItem = removeItems[#removeItems].item	
	end

	return true,outputItem
end


function Role_Item:doAddItemCount(itemId, count, time, onlyId)
    local outputItem = nil
    local itemAttr = self:getOneItemByKey(itemId)

    local addItems, removeItems =
        self:addItemCountWithExecutor(
        itemId,
        count,
        function(item)
            if onlyId ~= nil then
                return item.id == onlyId
            else
                return item.itemId == itemId
            end
        end,
        function()
            --@desc 给武器淬毒或其它增加效果的功能后，需使用onlyId进行索引
            local itemOnlyId = onlyId or self:getItemOnlyId()
            local item = {itemId = itemId, count = 0, id = itemOnlyId, time = time}
            item = self:createSafeItem(item)
            if itemAttr.wpType == "神兵" then
                item.type = "神兵"
            end
            return item
        end
	)


    --@desc 暂时返回一个数据
	if MapIsEmpty(addItems) == false then
        outputItem = addItems[#addItems].item
	elseif MapIsEmpty(removeItems) == false then
		outputItem = removeItems[#removeItems].item
	else
		assert(false,"doAddItemCount is no change , please check!!!")
		return nil
	end
	
    return outputItem
end


function Role_Item:addItemCountWithExecutor(itemId, count, matchFunc, itemCreator)
	local itemAttr = self:getOneItemByKey(itemId)
	if not itemAttr then
		if PRINT_MODE == 1 then
			print("物品不存在")
		end
		return nil
	end

	local addItemCountExecutor = nil
	if itemAttr.canFold == ITEM_STATE_TRUE then
		addItemCountExecutor = AddItemCountExecutorFactory:getFoldAddItemCountExecutor()
	else
		addItemCountExecutor = AddItemCountExecutorFactory:getNoFoldAddItemCountExecutor()
	end

	addItemCountExecutor:setItems(self.items)
	addItemCountExecutor:setItemId(itemId)
	addItemCountExecutor:setAddCount(count)
	addItemCountExecutor:setMatchFunc(matchFunc)
	addItemCountExecutor:setItemCreateFunc(
		function(itemId)
			return itemCreator(itemId)
        end
	)
	
	addItemCountExecutor:execute()

	return addItemCountExecutor:getModifys()
end


-- 获取item数量
function Role_Item:getItemCount(itemId)
	local count = 0
	for k,v in pairs(self.items) do
		if v.itemId == itemId then
			count = count + v.count
		end
	end
	for k,v in pairs(self.medicinalBox) do
		if v.itemId == itemId then
			count = count + v.count
		end
	end
	for k,v in pairs(self.smeltBox) do
		if v.itemId == itemId then
			count = count + v.count
		end
	end
	return count
end

--获取物品数量(包括背包+仓库+装饰箱+药囊+书匣+武功书箱+招式书箱+家园储物柜)
function Role_Item:getItemTotalCount(itemId)
	if itemId == nil then
		return 0
	end

	--放置物品的箱子
	local boxList = {
		"items", --背包
		"ckitems", --仓库
		"decorative", --装饰箱
		"medicinalBox", --药囊
		"literaryBox", --书匣
		"shuxiang",	--武功书箱
		"zhaoShuXiang", --招式书箱
		"cwItems", --家园储物柜
		"smeltBox",--冶炼箱
	}

	local count = 0
	for i = 1,10 do
		local boxName = boxList[i]
		if boxName == nil then
			break
		end
		local itemsList = self:getAttr(boxName)
		if not MapIsEmpty(itemsList) then
			for k,v in pairs(itemsList) do
				if v.itemId == itemId then
					count = count + v.count
				end
			end
		end
	end

	return count
end

-- 获得饰品数量
function Role_Item:getDecorativeCount(itemId)
	local count = 0
	for k,v in pairs(self.decorative) do
		if v.itemId == itemId then
			count = count + v.count
		end
	end
	return count
end

-- 获得书页数量
function Role_Item:getBookCaseItemCount(itemId)
	local count = 0
	for k,v in pairs(self.shuxiang) do
		if v.itemId == itemId then
			count = count + v.count
		end
	end
	return count
end

-- 获取装饰箱容量上限
function Role_Item:getDecorativeLimit()
	local count = 0
	count = self.decorativeLimit
	return count
end

--@desc 获得挂饰数量
function Role_Item:getAppearanceCount()
	local count = 0
	for k,v in pairs(self.decorative) do
		if v.portraitType == "appearance" then
			count = count + 1
		end
	end
	return count
end

--获得装备箱同一件装备数量
function Role_Item:getEquipsCount(itemId)
	local count = 0
	for k,v in pairs(self.equipsBox) do
		if v.itemId == itemId then
			count = count + v.count
		end
	end
	return count
end

--仓库列表
function Role_Item:getckItems()
	self.ckitems = self:deleteOverTimeItem(self.ckitems)
	local items = self.ckitems
	if #items <= 0 then
		-- if PRINT_MODE == 1 then
		-- 	print(self:getName().."的仓库是空的")
		-- end
	end
	return items
end

-- 仓库物品
function Role_Item:getckItem(itemId)
	for i, item in ipairs(self.ckitems) do
		if item.itemId == itemId then
			return item, i
		end
	end
	if PRINT_MODE == 1 then
		print("仓库没有该物品!!!")
	end
	return nil
end

--物品列表
function Role_Item:getItems(filterFunc)
	self.items = self:deleteOverTimeItem(self.items)
	
	self:autoFoldItems()

	local items={}
	--@desc 增加过滤方法
	if filterFunc then
		for k,v in pairs(self.items) do
			if filterFunc(v) then
				table.insert( items,v )
			end
		end
	else
		items = self.items
	end

	if #items <= 0 then
		if PRINT_MODE == 1 then
			-- print(self:getName().."的背包是空的")
		end
	end
	return items
end


local itemCanFoldCache = {}
local function itemCanFold(self, itemId)
	
    local canFold = itemCanFoldCache[itemId]
    if canFold == nil then
        canFold = self:getOneItemByKey(itemId).canFold == ITEM_STATE_TRUE
        itemCanFoldCache[itemId] = canFold    
    end
    return canFold
end

--自动堆叠
function Role_Item:autoFoldItems()
	local lastItemMap = {}
    local itemCount = #self.items
    local i = 1
    
    while i <= itemCount do
        local item = self.items[i]
        local lastItem = lastItemMap[item.itemId]
        if lastItem == nil then
            if item.count < 99 then
                lastItemMap[item.itemId] = item
            end
        else
            if itemCanFold(self, item.itemId) then
                local newCount = lastItem.count + item.count
                if newCount <= 99 then
                    lastItem.count = newCount
                    table.remove(self.items, i)
                    i = i - 1
                    itemCount = itemCount - 1
                else
                    lastItem.count = 99
                    item.count = newCount - 99
                    lastItemMap[item.itemId] = item
                end
            else
                -- 不用堆叠的物品不处理
            end
        end
        i = i + 1
    end
end

-- 装备一件道具 部位以及装备的唯一Id
function Role_Item:setEquipByName(part, item)
	assert(part, "Role_Item:setEquipByName(part, item) -> 数据异常,part不能传空值")
	local equips = self.equips
	

	if item == nil and self.equips[part] ~= nil then
		self:removeEquipItem(part)
	elseif item == nil and self.equips[part] == nil then
	else
		if self.equips[part] == nil then
			self:equipItem(part,item)
		elseif self.equips[part] ~= nil and self.equips[part].id ~= item.id then
			self:removeEquipItem(part)
			self:equipItem(part,item)
		end
	end

	-- 刷新BUFF
	self:updateRoleBuff()
	self:updateActiveZhaoStatus() -- add by XiaoZhiWei 2017/03/14 19:39:18 切换武器也需要更新武功招式列表
end

--@desc: 装备物品
--@author:Seven
--@time:2020-09-02 17:17:28
--@part: 部位
--@item: 装备的物品
function Role_Item:equipItem(part, item)
    self.equips[part] = {id = item.id, itemId = item.itemId}
    --@desc 添加装备带来的buff
    local itemAttr = self:getOneItemByKey(item.itemId)
    if itemAttr and itemAttr.buffid then
        local buffidList = string.split(tostring(itemAttr.buffid), ";")
        for i, buffId in ipairs(buffidList) do
            self:addItemBuff(buffId, 1)
        end
	end
	

	local prepareWeapon=self.prepareWeapon
	if item and part=="weapon" and MapIsEmpty(prepareWeapon)==false and prepareWeapon.id == item.id then 
		self.prepareWeapon={}
	end
end

--@desc: 移除装备
--@author:Seven
--@time:2020-09-02 17:21:14
--@part: 部位
function Role_Item:removeEquipItem(part)
	if self.equips[part] ~= nil then
		--@desc 移除buff
		local itemId = self.equips[part].itemId
		if itemId ~= nil then
			local itemAttr = self:getOneItemByKey(itemId)
			if itemAttr and itemAttr.buffid then
				local buffidList = string.split(tostring(itemAttr.buffid),";")
				for i,buffId in ipairs(buffidList) do
					self:addItemBuff(buffId,-1)
				end
			end
		end
	end
	self.equips[part] = nil
end

-- 检查装备是否已穿戴 id
function Role_Item:checkItemIsEquip(id)
	if not id then
		return false
	end
	local equips = self.equips
	for k,equip in pairs(equips) do
		if equip.id == id then
			return true
		end
	end
	return false
end

--准备武器
function Role_Item:setPrepareWeapon(item)
	if not item then 
		self.prepareWeapon={}
		return
	end

	local currEquipWeapon=self:getEquipByName("weapon")
	if not MapIsEmpty(currEquipWeapon) then 
		if currEquipWeapon.id ==item.id then 
			self:setEquipByName("weapon", nil)
		end
	end
	self.prepareWeapon={id = item.id , itemId = item.itemId}
end

--获得准备的武器
function Role_Item:getPrepareWeapon()
	if MapIsEmpty(self.prepareWeapon) then 
		print("未准备武器")
		return
	end
	local prepareWeapon=self.prepareWeapon
	return prepareWeapon
end
--id  物品唯一id item.id
function Role_Item:checkIsPrepareWeapon(id)
	if not id then 
		return false
	end
	if MapIsEmpty(self.prepareWeapon) then 
		return false
	end
	local prepareWeapon=self.prepareWeapon 
	if prepareWeapon.id == id then 
		return true
	end
	return false 
end

function Role_Item:checkItemIsDamage(item)
	assert(item,"检查参数item")
	if item.type == "神兵" then
		local weapon = self:getOneItemByKey(item.itemId)
		if weapon.wanhaodu == 0 then
			return true
		end
	else
		if item.wanhaodu and item.wanhaodu == 0 then
			return	true
		end
	end
	return false
end

-- 检查装备是否已穿戴 itemId
function Role_Item:checkItemIsEquipbyItemId(itemId)
	if not itemId then
		return false
	end
	local equips = self.equips
	for k,equip in pairs(equips) do
		if equip.itemId == itemId then
			return true
		end
	end
	return false
end

function Role_Item:getEquipMap()
    return self.equips
end

-- 获取某一个部位的装备
function Role_Item:getEquipByName(name)
	-- local equips = self.equips
	-- if MapIsEmpty(equips) then
	-- 	if PRINT_MODE == 1 then
	-- 		-- print("Role_Item:getEquipByName(name) -> 没有穿戴任何装备")
	-- 	end
	-- 	return
	-- end
	-- return equips[name]
	return self.equips[name]
end

-- @author GaoHanZheng
-- @time 2017/09/14 10:17:11
-- @desc 限时道具时间
function Role_Item:getItemTimeLimit(item)
	if type(item) ~= "table" then
		return 
	end
	local time = nil
	if type(item.timeend) == "number" then
		if item.canFold == ITEM_STATE_TRUE then
			assert(nil,"限时时间的道具不可堆叠")
		end
		time = GetTime() + item.timeend
	elseif type(item.timeend) == "string" then
		local list = string.split(item.timeend,"$S")
		assert(list[2],"限时道具限定日期错误")
		time = Helper:getTimeStampWithStringDate(tostring(tonumber(list[2])+1), 0)--
	end
	return time
end

function Role_Item:setItemTimeByItemId(itemId,time)
	if type(itemId) ~= "string" and type(time) ~= "number" then
		return
	end
	for k,v in pairs(self.items) do 
		if v.itemId == itemId then
			v.time = time
		end
	end
end

--限时道具默认使用最早消失的
function Role_Item:getItemTimeLeastOnlyId(itemId)
	if not itemId  then
		return nil
	end

	local onlyId
	local time

	for k,v in pairs(self.items) do 
		if v.itemId == itemId and v.time then
			if not time then
				time = v.time
				onlyId = v.id
			end

			if time > v.time then
				time = v.time
				onlyId = v.id
			end
		end
	end

	return onlyId
end
-- @author GaoHanZheng
-- @time 2017/09/14 11:25:47
-- @desc 
function Role_Item:deleteOverTimeItem(items)
	if type(items) ~= "table" then
		return items
	end
	local can_p = false
	local print_str = "CYN您的"
	-- local list = {}
	local Record = require("app.models.Record.Record")
	local logData = {}
	local logOrigin = "物品过期"
	for i=#items,1,-1 do
		if type(items[i]) == "table" and type(items[i].time) == "number" and items[i].time <= GetTime() then
			can_p = true
			-- table.insert(list,self:getOneItemByKey(items[i].itemId).name)
			local item = Helper:getDef(self:getOneItemByKey(items[i].itemId),{})
			print_str = print_str.. Helper:getDef(item.name,"")..","
			if item.type == "邀请函" then
				local YaoQingHanModel = require("app.models.HomelandModel.YaoQingHanModel")
				YaoQingHanModel:deleteYaoQingHanInfo(items[i].itemId)
			elseif item.type == "地契" then
				local DiQiModel = require("app.models.HomelandModel.DiQiModel")
				DiQiModel:recycleLand(items[i].itemId)
			elseif item.type == "食盒" then
				self:setHomelandAttr("dinner",{})
			end

			logData[items[i].itemId] = -items[i].count
			table.remove(items,i)
		end
	end
	if can_p == true then
		if string.len(print_str) > 1 then
			print_str = string.sub(print_str,1,string.len(print_str)-1) .. "物品已经过期。"
			RichPrint("main",print_str)
		end
	end
	Record:addLog(Record.LOG_TYPE.ITEM,logData,logOrigin)
	return items
end

-- @author GaoHanZheng
-- @time 2017/09/14 12:06:25
-- @desc 使用限时道具时刷新 背包，删除过期道具
function Role_Item:refreshItems()
	self.items = self:deleteOverTimeItem(self.items)
	self.ckitems = self:deleteOverTimeItem(self.ckitems)
	-- assert(nil)
end

-- @author GaoHanZheng
-- @time 2017/09/14 12:19:54
-- @desc 找到不可堆叠限时道具中最早过期的index
function Role_Item:sortFirstVoerTimeItem(itemList)
	local function sortList(list)
		table.sort(list,function(a,b)
			if DEBUG_MODE == 1 then
				assert(tonumber(a.time),"time 不能为nil")
				assert(tonumber(b.time),"time 不能为nil")
			end
			return tonumber(a.time) < tonumber(b.time)
		end)
		return list
	end
	return sortList(itemList)
end

-- @author TangJian
-- @desc 创建安全的物品table
function Role_Item:createSafeItem(itemData)
	local itemId = tostring(itemData.itemId)
	return createSafeTable("player.items."..itemId, itemData, function(role, valueName, valueFrom, valueTo)
		Collection:memoryCheat(self.userid, valueName, valueFrom, valueTo)
	end)
end

-- 获取物品唯一ID
function Role_Item:getItemOnlyId()
	if not self._ItemOnlyId then
		self._ItemOnlyId = 1
	else
		self._ItemOnlyId = self._ItemOnlyId + 1
	end
	while self:getItemWithOnlyId(self._ItemOnlyId) ~= nil do
		self._ItemOnlyId = self._ItemOnlyId + 1
	end
	return self._ItemOnlyId
end

-- @author TangJian
-- @desc 获得物品
function Role_Item:getOneItemByKey(itemId)
	if itemId == nil then
		return
	end

	if not self._shenbingCache  then
		self._shenbingCache = {}
	end

	if self._shenbingCache[itemId] then
		return self._shenbingCache[itemId]
	end

	if self.shenBingItems then
		for i,v in ipairs(self.shenBingItems) do
			if itemId == v.id then
				local item = Helper:tableCover(require("app.models.item.BaseItem"):create(), v)
				item.equipPart = "weapon"
				item.name = item.nameColor .. item.name.."NOR"
				--初始化神兵子类型
				item:initShenbingType2()
				Item:initWeaponFlyAndBreak(item,item.type,item:getCurrWeaponType2())

				-- 设置为不可以移动至仓库
				item.deposit = 0
				item = inherit(TableProxy:createDataValidationTableRecursive(item), item)
				self._shenbingCache[itemId] = item
				return item
			end
		end
	end

	if not self._ItemCache  then
		self._ItemCache = {}
	end
	if self._ItemCache[itemId]  then
		return self._ItemCache[itemId]
	end

	local fq = self:getHomelandAttr("fq")
	if fq.id == itemId then
		local FangQiModel = require("app.models.HomelandModel.FangQiModel")
		local item = Helper:tableCover(require("app.models.item.BaseItem"):create(),fq)
		item.name = fq.name
		item.type = "房契"
		item.dsc = FangQiModel:getDsc()
		item.deposit = 0
		item.itemCanSale = 0
		item.canUse = 1
		return item
	end
	

	local dq = self:getHomelandAttr("dq")
	if not MapIsEmpty(dq) then
		local DiQiModel = require("app.models.HomelandModel.DiQiModel")
		for k,dqData in pairs(dq) do
			if dqData.id == itemId then
				local item = Helper:tableCover(require("app.models.item.BaseItem"):create(),dqData)
				item.name = dqData.name
				item.type = "地契"
				item.dsc = DiQiModel:getDsc(dqData.dpId)
				item.deposit = 0
				item.itemCanSale = 0
				item.canUse = 1
				item.timeend = dqData.timeend
				return item
			end
		end
	end
	

	local yq = self:getHomelandAttr("yq")
	if not MapIsEmpty(yq) then
		for k,v in pairs(yq) do
			if v.id == itemId then
				local item = Helper:tableCover(require("app.models.item.BaseItem"):create(), v)
				local YaoQingHanModel = require("app.models.HomelandModel.YaoQingHanModel")
				item.dsc = YaoQingHanModel:getDesc(item)
				item.deposit = 0
				item.itemCanSale = 0
				item.canUse = 0
				self._ItemCache[itemId] = item
				return item
			end
		end
	end
	return Item:getItemByKey(itemId)
end


-- @desc 通过ItemId获取itemType方法, 增加缓存
-- @return 返回为字符串. 如果找不到类型, 则返回"nil"
local itemTypes = {}
function Role_Item:getItemType(itemId)
	local itemType = itemTypes[itemId]
	if itemType then
		return itemType
	end

	local itemAttr = self:getOneItemByKey(itemId)

	 if itemAttr then
		itemTypes[itemId] = itemAttr.type
		return itemAttr.type
	 end

	 if DEBUG_MODE == 1 then
		local text = "找不到物品:" .. tostring(itemId)
		 print(text)
		 PopText(text)
	 end

	 itemTypes[itemId] = "nil"
	 return "nil"
end

function Role_Item:deleteItemByTypeFromItemsAndCkItems(_type)
	if _type == nil then
		return
	end

	local ShenShuHelper = require("app.models.shenshu.shenshu")

	if ShenShuHelper:isSongLi(self) and ShenShuHelper:checkIsInSongLiTime(self) == false then
		local items = self:getItems()
		local list = {}
		if items then
			for i = #items,1,-1 do 
				local itemType = self:getItemType(items[i].itemId)
				if itemType == _type then
					list[items[i].itemId] = items[i].count
				end
			end
		end

		for itemId, count in pairs(list) do
			self:addItemCount(itemId, -count, nil, nil, "神书过期")
		end

		ShenShuHelper:clearSongLiInfo(self)
	end

	if ShenShuHelper:isFindBook(self) and ShenShuHelper:checkIsInFindBook(self) == false then
		RichPrint("main", "HIY江湖传闻，有一神秘组织已经找到了剩余神书，神书的传闻渐渐消散。")
		ShenShuHelper:endFindBook(self)
	end
end

-- 添加书籍入书箱
function Role_Item:addLiteraryBox(itemId, count)
	if not itemId then
		assert(nil, "Role_Item:addLiteraryBox(itemId, count) -> can not use nil itemId")
	end

	if PRINT_MODE == 1 then
		print("Role_Item:addLiteraryBox("..tostring(itemId)..", "..tostring(count)..")")
	end

	assert(type(count) == "number")

	local itemAttr = self:getOneItemByKey(itemId)
	if not itemAttr then
		if PRINT_MODE == 1 then
			print("物品不存在")
		end
		return nil
	end

	local items = self:getItemsWithItemId(itemId, "literaryBox")
	if not MapIsEmpty(items) then
		for i,v in ipairs(items) do
			if math.floor(count) > 0 then
				v.count = v.count + count
			elseif count < 0 then
				v.count = v.count + count
				if v.count <= 0 then
					count = v.count
					table.remove(self.literaryBox, v.index)
				else
					count = 0
				end
			else
				break
			end
		end
	else
		if count > 0 then
			local BookLiterary = require("app.models.book.BookLiterary")
			local literaryId = BookLiterary:getLiteraryByItemId(itemId).id
			local item = {id = self:getItemOnlyId(), count = count , itemId = itemId, literaryId = literaryId, exp = BookLiterary:getExp(1)}
			table.insert(self.literaryBox, self:createSafeItem(item))
		end
	end

	return true
end

--装备箱列表
function Role_Item:getzbItems()
	self.equipsBox = self:deleteOverTimeItem(self.equipsBox)
	local items = self.equipsBox
	if #items <= 0 then
		if PRINT_MODE == 1 then
			print(self:getName().."的装备箱是空的")
		end
	end
	return items
end

---添加装备入装备箱
function Role_Item:addequips(itemId, count)
	if not itemId then
		assert(nil,"Role_Item:addequips(itemId, count) -> can not use nil itemId")
	end

	if PRINT_MODE == 1 then
		print("Role_Item:addequips("..tostring(itemId)..", "..tostring(count)..")")
	end

	assert(type(count) == "number")

	local itemAttr = self:getOneItemByKey(itemId)
	if not itemAttr then
		if PRINT_MODE == 1 then
			print("物品不存在")
		end
		return nil
	end
	if self:getEquipsCount(itemId) > 0 then
		PopText("装备箱已收藏该装备，无法放入。")
		return false
	end

	local items = self:getItemsWithItemId(itemId,"equipsBox")
	if not MapIsEmpty(items) then
		for i,v in ipairs(items) do
			if math.floor(count) > 0 then
				v.count = v.count + count
			elseif count < 0 then
				v.count = v.count + count
				if v.count <= 0 then
					count = v.count
					table.remove(self.equipsBox, v.index)
				else
					count = 0
				end
			else
				break
			end
		end
	else
		if count > 0 then
			
			local item = {id = self:getItemOnlyId(), count = count , itemId = itemId}
			table.insert(self.equipsBox, self:createSafeItem(item))
		end
	end

	return true 

end

-- 添加装饰入装饰箱
function Role_Item:addDecorative(itemId, count)
	if not itemId then
		assert(nil, "Role_Item:addDecorative(itemId, count) -> can not use nil itemId")
	end

	if PRINT_MODE == 1 then
		print("Role_Item:addDecorative("..tostring(itemId)..", "..tostring(count)..")")
	end

	assert(type(count) == "number")

	local itemAttr = self:getOneItemByKey(itemId)
	if not itemAttr then
		if PRINT_MODE == 1 then
			print("物品不存在")
		end
		return nil
	end

	if itemAttr.type == "挂饰" then
	else
		if self:getDecorativeCount(itemId) <= 0 and self:getDecorativeLimit() - 1 <= #self.decorative - self:getAppearanceCount() then
			PopText("装饰箱容量已达上限，无法放入。")
			return false
		end
	end

	local items = self:getItemsWithItemId(itemId, "decorative")
	if not MapIsEmpty(items) then
		for i,v in ipairs(items) do
			if math.floor(count) > 0 then
				v.count = v.count + count
			elseif count < 0 then
				v.count = v.count + count
				if v.count <= 0 then
					count = v.count
					table.remove(self.decorative, v.index)
				else
					count = 0
				end
			else
				break
			end
		end
	else
		if count > 0 then
			local portraitType
			if itemAttr.type == "面具" then
				portraitType = "mask"
			elseif itemAttr.type == "信物" then
				portraitType = "token"
			elseif itemAttr.type == "挂饰" then
				portraitType = "appearance"
			end
			local item = {id = self:getItemOnlyId(), count = count , itemId = itemId, portraitType = portraitType}
			table.insert(self.decorative, self:createSafeItem(item))
		end
	end

	return true
end
--检测物品是否直接添加
function Role_Item:checkIsNoLimitItem(itemId)
    local itemAttr = self:getOneItemByKey(itemId)
    if itemAttr.type == "书页" or itemAttr.type == "武学秘宝" then
        return true
    end

    if itemAttr.type == "秘籍残页" then
        return true
    end

    if (itemAttr.type == "毒药" or itemAttr.type == "制药材料")  then
        return true
    end

    if itemAttr.type == "淬炼材料" or itemAttr.type == "锻造材料" then
        return true
    end

    return false
end

-- 检查是否能够移动到仓库
function Role_Item:checkCanBuyThingsck(itemId, num)
	return self:checkCanBuyThings(itemId, num, "ck")
end

-- 检查是否能够购买物品 bagType bag 背包 ck 仓库
function Role_Item:checkCanBuyThings(itemId, num, bagType, isNeedPop)
	if not itemId or not num then
		return false
	end
	local bagName, items, itemCount 	-- 储存位置名称  取储存位置物品列表  储存位置的上限
	if bagType == nil then 				-- 如果储存位置类型为空 默认是背包 bag
		bagType = "bag"
	end
	if isNeedPop == nil then
		isNeedPop = true
	end
	if bagType == "ck" then 			-- 如果类型是仓库 ck 则名字和列表初始化为仓库所对应的
		items = self:getckItems()
		bagName = "仓库"
		itemCount = self.ckLimit
	elseif bagType == "bag" then 		-- 背包
		items = self:getItems()
		bagName = "背包"
		itemCount = self.weight
	else
		return false --  异常情况 不允许操作
	end

	local itemList = self:getItemsWithItemId(itemId, bagType)
	local itemAttr = self:getOneItemByKey(itemId)
	if itemAttr == nil then
		PopText("无法找到该资源，请尝试重启游戏。")
		return false
	end
	--残页书页等不进入背包物品不受限制
	if bagType == "bag" and self:checkIsNoLimitItem(itemId) then
		return true
	end

	if (itemAttr.priceUnit=="yuanbao" or itemAttr.canFold==ITEM_STATE_TRUE) and itemAttr.name~="先发制人"  then  --(主要处理可堆叠的物品)
		for i,item in ipairs(itemList) do 																		-- 遍历当前物品列表
			if item.count + num >= 99  then 	-- 上限为99，当前格子超出的情况下。填充到满状态，剩余部分在下个格子计算 直到全都计算完或者数量计算完
				num = num - 99 + item.count
			elseif i == #itemList and item.count + num > 99 and #items + 1 > itemCount  then
				break
			else
				num=0
			end
		end
		num = math.ceil(num/99)  		-- 计算超出部分需要的格子数量
	end

	if #items + num > itemCount then --
		if isNeedPop == true then
			PopText(tostring(bagName).."容量达到上限，无法将物品放入"..tostring(bagName))
		end
		return false
	end
	return true
end

----判断一次是否能加入多个物品，传入一个table,k是物品的id，v是物品的数量
function Role_Item:checkCanBuyTwoOrMoreThings(tb, isNeedPop) --NEEDTOCHECK
	if MapIsEmpty(tb) then
		return true  -- add by XiaoZhiWei 2017/06/13 12:21:25 物品列表为空,返回值应该是true
	end
	if isNeedPop == nil then
		isNeedPop = true
	end
	local player = clone(self)
	for k,v in pairs(tb) do
		if v and k then
			if player:checkCanBuyThings(k,v , "bag",isNeedPop) then
				player:changeItemCount(k, tonumber(v),nil,nil)
			else
				return false
			end
		end
	end
    return true
end

--获得外观出场动画
function Role_Item:getAppearanceStartFightAnimId()
	local appearance = self:getAttr("appearance")
	local animName = nil
	if appearance then
		local itemId = appearance
		local itemAttr = self:getOneItemByKey(itemId)

		if itemAttr then
			animName = itemAttr.startAnim
		end
	end

	return animName
end

--获得外观出场动画时长
function Role_Item:getAppearanceStartFightTime()
	local appearance = self:getAttr("appearance")
	local animTime = nil

	if appearance then
		local itemId = appearance
		local itemAttr = self:getOneItemByKey(itemId)

		if itemAttr then
			animTime = itemAttr.startFrame
		end
	end

	return animTime
end

--获得外观胜利动画
function Role_Item:getAppearanceWinFightAnimId()
	local appearance = self:getAttr("appearance")
	local animName = nil
	if appearance then
		local itemId = appearance
		local itemAttr = self:getOneItemByKey(itemId)

		if itemAttr then
			animName = itemAttr.winAnim
		end
	end
	return animName
end

--获得外观胜利动画
function Role_Item:getAppearanceWinFightTime()
	local appearance = self:getAttr("appearance")
	local animTime = nil

	if appearance then
		local itemId = appearance
		local itemAttr = self:getOneItemByKey(itemId)

		if itemAttr then
			animTime = itemAttr.winFrame
		end
	end
	return animTime
end

--@desc 初始化物品带来的buff
function Role_Item:initItemBuff()
	local roleItems = self:getItems()
	if MapIsEmpty(roleItems) == false then
		for i,v in ipairs(roleItems) do
			self:addItemBuffByItemId(v.itemId,v.count)
		end
	end

	local equips = self.equips
	for k,equip in pairs(equips) do
		local itemId = equip.itemId
		local itemAttr = self:getOneItemByKey(itemId)
		if itemAttr and itemAttr.buffid then
			local buffidList = string.split(tostring(itemAttr.buffid),";")
			for i,buffId in ipairs(buffidList) do
				self:addItemBuff(buffId,1)
			end
		end
	end
end

--@desc 增加物品带来的buff
--@count: 增加数量，为负数就是移除buff
function Role_Item:addItemBuffByItemId(itemId,count)
	if itemId == nil or type(count) ~= "number" or count == 0 then
		return
	end

	local itemAttr = self:getOneItemByKey(itemId)

	--@desc 可装备的物品不用管
	if not itemAttr or not itemAttr.buffid or itemAttr.canEquip == 1 then
		return
	end

	local buffidList = string.split(tostring(itemAttr.buffid),";")
	for i,buffId in ipairs(buffidList) do
		self:addItemBuff(buffId,count)
	end
end

function Role_Item:addItemBuff(buffId,count)
	if buffId == nil or type(count) ~= "number" or count == 0 then
		return
	end

	if count > 0 then
		for i = 1,count do
			self:addBuffV2(buffId)
		end
	elseif count < 0 then
		for i = 1,math.abs(count) do
			self:removeBuffV2(buffId)
		end
	end
end

return Role_Item000000000000