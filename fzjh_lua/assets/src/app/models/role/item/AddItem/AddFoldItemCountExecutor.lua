local class = require("third.class.NewClass")
local IAddItemCountExecutor = require("app.models.role.item.AddItem.IAddItemCountExecutor")

local function log(...)
    if PRINT_MODE == 1 then
        print("AddFoldItemCountExecutor:", ...)
    end
end

local AddFoldItemCountExecutor = {}

function AddFoldItemCountExecutor:ctor()
    self._items = nil
    self._addCount = 0
    self._itemId = nil

    self._matcher = function(item)
        return item.itemId == self._itemId
    end

    -- @desc 添加的物品列表
    self._addItems = {}

    -- @desc 移除的物品列表
    self._removeItems = {}
end

function AddFoldItemCountExecutor:create()
    local p = self.new()
    return p
end

function AddFoldItemCountExecutor:setItems(items)
    self._items = items
end

function AddFoldItemCountExecutor:setAddCount(addCount)
    self._addCount = addCount
end

function AddFoldItemCountExecutor:setItemId(itemId)
    self._itemId = itemId
end

function AddFoldItemCountExecutor:setMatchFunc(matchFunc)
    self._matcher = matchFunc
end

function AddFoldItemCountExecutor:setItemCreateFunc(itemCreateFunc)
    self._itemCreateFunc = itemCreateFunc
end

function AddFoldItemCountExecutor:execute()
    assert(type(self._items) == "table")
    assert(type(self._addCount) == "number")
    assert(type(self._itemId) == "string")

    -- @desc 对物品排序, 数量少的在后边
    local rollbackFunc =
        table.sortWithRollback(
        self._items,
        function(a, b)
            return a.count > b.count
        end
    )

    local addCount = self._addCount

    if addCount > 0 then
        self:__foldAdd(math.abs(addCount))
    elseif addCount < 0 then
        self:__foldSub(math.abs(addCount))
    end

    rollbackFunc()
end

function AddFoldItemCountExecutor:getModifys()
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

function AddFoldItemCountExecutor:printItemsInfo()
    log("ItemsInfo:")
    Helper:print_lua_table(self._items)
end

function AddFoldItemCountExecutor:printModifysInfo()
    log("ModifysInfo:")
    log("  addItems:")
    Helper:print_lua_table(self._addItems)
    log("  removeItems:")
    Helper:print_lua_table(self._removeItems)
end

-- @desc 叠加的增加物品方法
function AddFoldItemCountExecutor:__foldAdd(addCount)
    local itemId = self._itemId
    local remainingCount = addCount

    -- 添加剩余item
    self:__foldAddItemGroup(itemId, remainingCount)
end

-- @desc 叠加的减少物品方法
function AddFoldItemCountExecutor:__foldSub(subCount)
    local items = self._items
    local itemId = self._itemId

    local currSubCount = subCount

    for i = #items, 1, -1 do
        local item = items[i]
        if self:__itemMatch(item) then
            if currSubCount <= 0 then
                break
            end

            if currSubCount >= item.count then
                currSubCount = currSubCount - item.count
                self:__subItemCountByIndex(i, item.count)
            else
                self:__subItemCountByIndex(i, currSubCount)
                currSubCount = 0
            end
        end
    end
end

-- @desc 叠加的按组添加物品
function AddFoldItemCountExecutor:__foldAddItemGroup(itemId, addCount)
    local items = self._items

    if addCount <= 0 then
        return
    end

    local remainingCount = addCount
    while true do
        -- 先寻找有空位的item, 填满
        local item, itemIndex = self:__foldGetItemWithSpace(itemId)
        if item ~= nil then
            local needCount = 99 - item.count
            if remainingCount >= needCount then
                self:__addItemCountByIndex(itemIndex, needCount)
                remainingCount = remainingCount - needCount
            else
                self:__addItemCountByIndex(itemIndex, remainingCount)
                remainingCount = 0
            end
        end

        -- 再添加新的组
        if remainingCount > 99 then
            self:__addItemCountByIndex(#items + 1, 99)
            remainingCount = remainingCount - 99
        elseif remainingCount > 0 then
            self:__addItemCountByIndex(#items + 1, remainingCount)
            remainingCount = 0
            break
        else
            break
        end
    end
end

-- @获取还有空位的item数据
function AddFoldItemCountExecutor:__foldGetItemWithSpace(itemId)
    local items = self._items

    for i = #items, 1, -1 do
        local item = items[i]
        if self:__itemMatch(item) and item.count < 99 then
            return item, i
        end
    end
    return nil
end

function AddFoldItemCountExecutor:__addItemCountByIndex(index, count)
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

function AddFoldItemCountExecutor:__subItemCountByIndex(index, count)
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
end

function AddFoldItemCountExecutor:__itemMatch(item)
    return self._matcher(item)
end

function AddFoldItemCountExecutor:__createItem()
    return self._itemCreateFunc()
end

return class("AddFoldItemCountExecutor", {IAddItemCountExecutor}, AddFoldItemCountExecutor)
0000