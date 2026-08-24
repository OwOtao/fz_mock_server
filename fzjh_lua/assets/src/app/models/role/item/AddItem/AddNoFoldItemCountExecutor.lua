local class = require("third.class.NewClass")
local IAddItemCountExecutor = require("app.models.role.item.AddItem.IAddItemCountExecutor")

local function log(...)
    if PRINT_MODE == 1 then
        print("AddFoldItemCountExecutor:", ...)
    end
end

local AddNoFoldItemCountExecutor =
    class(
    "AddNoFoldItemCountExecutor",
    {IAddItemCountExecutor},
    {
        ctor = function(self)
            self._items = nil
            self._addCount = 0
            self._itemId = nil

            -- 匹配器
            self._matcher = function(item)
                return item.itemId == self._itemId
            end

            -- @desc 添加的物品列表
            self._addItems = {}

            -- @desc 移除的物品列表
            self._removeItems = {}
        end,
        create = function(self)
            local p = self.new()
            return p
        end,
        setItems = function(self, items)
            self._items = items
        end,
        setAddCount = function(self, addCount)
            self._addCount = addCount
        end,
        setItemId = function(self, itemId)
            self._itemId = itemId
        end,
        setMatchFunc = function(self, matchFunc)
            self._matcher = matchFunc
        end,
        setItemCreateFunc = function(self, itemCreateFunc)
            self._itemCreateFunc = itemCreateFunc
        end,
        execute = function(self)
            assert(type(self._items) == "table")
            assert(type(self._addCount) == "number")
            assert(type(self._itemId) == "string")

            local addCount = self._addCount

            if addCount > 0 then
                self:__noFoldAdd(math.abs(addCount))
            elseif addCount < 0 then
                self:__noFoldSub(math.abs(addCount))
            end
        end,
        getModifys = function(self)
            local addItems = {}
            if MapIsEmpty(self._addItems) == false then
                for k,v in pairs(self._addItems) do
                    table.insert(addItems,v)
                end
            end
        
            local removeItems = {}
            if MapIsEmpty(self._removeItems) == false then
                for k,v in pairs(self._removeItems) do
                    table.insert(removeItems,v)
                end
            end
            
            return addItems, removeItems
        end,
        printItemsInfo = function(self)
            log("ItemsInfo:")
            Helper:print_lua_table(self._items)
        end,
        printModifysInfo = function(self)
            log("ModifysInfo:")
            log("  addItems:")
            Helper:print_lua_table(self._addItems)
            log("  removeItems:")
            Helper:print_lua_table(self._removeItems)
        end,
        __init = function(self, items, addCount, itemId)
            self._items = items
            self._addCount = addCount
            self._itemId = itemId
        end,
        -- @desc 不叠加的增加物品方法
        __noFoldAdd = function(self, addCount)
            local items = self._items
            local itemId = self._itemId

            for i = 1, addCount do
                self:__addItemCountByIndex(#items + 1, 1)
            end
        end,
        -- @desc 不叠加的减少物品方法
        __noFoldSub = function(self, subCount)
            local items = self._items
            local itemId = self._itemId

            local currSubCount = 0
            for i = #items, 1, -1 do
                if currSubCount < subCount then
                    local item = items[i]
                    if self:__itemMatch(item) then
                        self:__subItemCountByIndex(i, 1)
                        currSubCount = currSubCount + 1
                    end
                end
            end
        end,
        __addItemCountByIndex = function(self, index, count)
            log("__addItemCountByIndex", index, count)
            local item = self._items[index]
            if item == nil then
                self._items[index] = self:__createItem()
                item = self._items[index]
            end
            item.count = item.count + count

            local addItemInfo = self._addItems[item.id]
            if addItemInfo == nil then
                self._addItems[item.id] = {item = item, count = 0}
                addItemInfo = self._addItems[item.id]
            end

            addItemInfo.count = addItemInfo.count + count
        end,
        __subItemCountByIndex = function(self, index, count)
            log("__subItemCountByIndex", index, count)

            local item = self._items[index]
            if item == nil then
                log("不能删除找不到的物品, index = ", index)
                return false
            end
            item.count = item.count - count

            local removeItemInfo = self._removeItems[item.id]
            if removeItemInfo == nil then
                self._removeItems[item.id] = {item = item, count = 0}
                removeItemInfo = self._removeItems[item.id]
            end

            removeItemInfo.count = removeItemInfo.count + count

            if item.count == 0 then
                table.remove(self._items, index)
            elseif item.count > 0 then
            else
                error("物品数量不能小于0")
            end
        end,
        __itemMatch = function(self, item)
            return self._matcher(item)
        end,
        __createItem = function(self)
            return self._itemCreateFunc()
        end
    }
)

return AddNoFoldItemCountExecutor
0000