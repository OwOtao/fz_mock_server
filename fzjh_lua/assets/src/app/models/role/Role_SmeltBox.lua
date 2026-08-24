local Role_SmeltBox = {}

-- 获取item在冶炼箱的数量
function Role_SmeltBox:getSmeltBoxItemCount(itemId)
	local count = 0
	for k,v in pairs(self.smeltBox) do
		if v.itemId == itemId then
			count = count + v.count
		end
	end
	return count
end

function Role_SmeltBox:addItemToSmeltBox(itemId,count)
	return self:addNoLimitItem(self.smeltBox,itemId,count)
end

-- --增减item物品在冶炼箱的数量
-- function Role_SmeltBox:addItemToSmeltBox_old(itemId,count)
--     if itemId == nil or type(count) ~= "number" then
-- 		assert(false, "Role_SmeltBox:addItemToSmeltBox(itemId,count) 参数出错")
-- 	end

-- 	local itemAttr = self:getOneItemByKey(itemId)
-- 	if not itemAttr then
-- 		print("物品不存在 itemId = ",itemId)
-- 		return
-- 	end

-- 	local items = self:getItemsWithItemId(itemId, "smeltBox")
-- 	if not MapIsEmpty(items) then
-- 		for i,v in ipairs(items) do
-- 			if math.floor(count) > 0 then
-- 				v.count = v.count + count
-- 			elseif count < 0 then
-- 				v.count = v.count + count
-- 				if v.count <= 0 then
-- 					count = v.count
-- 					table.remove(self.smeltBox, v.index)
-- 				else
-- 					count = 0
-- 				end
-- 			else
-- 				break
-- 			end
-- 		end
-- 	else
-- 		if count > 0 then
-- 			local item = {id = self:getItemOnlyId(), count = count , itemId = itemId}
-- 			table.insert(self.smeltBox, self:createSafeItem(item))
-- 		end
-- 	end

-- 	return true
-- end


function Role_SmeltBox:getSmeltBoxItems(filterFunc)
	self.smeltBox = self:deleteOverTimeItem(self.smeltBox)
	local items={}
	--@desc 增加过滤方法
	if filterFunc then
		if not MapIsEmpty(self.smeltBox) then
			for k,v in pairs(self.smeltBox) do
				if filterFunc(v) then
					table.insert( items,v )
				end
			end
		end
	else
		items = self.smeltBox
	end

	return items
end

function Role_SmeltBox:getSmeltBoxItemByItemId(itemId)
	for i, item in ipairs(self.smeltBox) do
		if item.itemId == itemId then
			return item, i
		end
	end
end


return Role_SmeltBox0000000000000