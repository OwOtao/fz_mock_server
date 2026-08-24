local class = require("third.class.NewClass")
local IAddItemCountExecutor = require("app.models.role.item.AddItem.IAddItemCountExecutor")

local function log(...)
    if PRINT_MODE == 1 then
        print("AddNoLimitItemExecutor:", ...)
    end
end

local AddNoLimitItemExecutor = {}

function AddNoLimitItemExecutor:ctor()
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
end

function AddNoLimitItemExecutor:create()
    local p = self.new()
    return p
end

function AddNoLimitItemExecutor:setItems(items)
    self._items = items
end

function AddNoLimitItemExecutor:setAddCount(addCount)
    self._addCount = addCount
end

function AddNoLimitItemExecutor:setItemId(itemId)
    self._itemId = itemId
end

function AddNoLimitItemExecutor:setMatchFunc(matchFunc)
    self._matcher = matchFunc
end

function AddNoLimitItemExecutor:setItemCreateFunc(itemCreateFunc)
    self._itemCreateFunc = itemCreateFunc
end

function AddNoLimitItemExecutor:execute()
    assert(type(self._items) == "table")
    assert(type(self._addCount) == "number")
    assert(type(self._itemId) == "string")

    local addCount = self._addCount

    if addCount < 0 then
        self:__sub(math.abs(addCount))
    elseif addCount > 0 then
        self:__add(math.abs(addCount))
    end
end

function AddNoLimitItemExecutor:getModifys()
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
end

function AddNoLimitItemExecutor:printItemsInfo()
    log("ItemsInfo:")
    Helper:print_lua_table(self._items)
end

function AddNoLimitItemExecutor:printModifysInfo()
    log("ModifysInfo:")
    log("  addItems:")
    Helper:print_lua_table(self._addItems)
    log("  removeItems:")
    Helper:print_lua_table(self._removeItems)
end

function AddNoLimitItemExecutor:__add(count)
    local items = self._items

    if count < 0 then
        return
    end

    local item, index = self:__getItemInItems(self._itemId)

    if item == nil then
        self:__addItemCountByIndex(#items + 1, count)
    else
        self:__addItemCountByIndex(index, count)
    end
end

function AddNoLimitItemExecutor:__addItemCountByIndex(index, count)
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
end

function AddNoLimitItemExecutor:__sub(count)
    local items = self._items

    if count < 0 then
        return
    end

    local item, index = self:__getItemInItems(self._itemId)

    for i = #items, 1, -1 do
        local item = items[i]
        if self:__itemMatch(item) then
            if item.count < count then
                count = item.count
            end

            self:__subItemCountByIndex(i, count)
            break
        end
    end
end

function AddNoLimitItemExecutor:__subItemCountByIndex(index, count)
    log("__subItemCountByIndex", index, count)

    local item = self._items[index]

    if item == nil then
        if item == nil then
            log("不能删除找不到的物品, index = ", index)
            return false
        end
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
        error("AddNoLimitItemExecutor:物品数量不能小于0")
    end
end

function AddNoLimitItemExecutor:__getItemInItems(itemId)
    local items = self._items

    for i = #items, 1, -1 do
        local item = items[i]
        if self:__itemMatch(item) then
            return item, i
        end
    end
    return nil
end

function AddNoLimitItemExecutor:__itemMatch(item)
    return self._matcher(item)
end

function AddNoLimitItemExecutor:__createItem()
    return self._itemCreateFunc(self._itemId)
end

return class("AddNoLimitItemExecutor", {IAddItemCountExecutor}, AddNoLimitItemExecutor)
00000000