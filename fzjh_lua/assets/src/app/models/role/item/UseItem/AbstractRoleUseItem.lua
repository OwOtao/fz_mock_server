local abstract = require("third.class.abstract")
local Item = require("app.models.item.Item")


local AbstractUseItemInterface = {}

function AbstractUseItemInterface:useItem()
end

local AbstractUseItemBody = {}

-- 构造方法
function AbstractUseItemBody:ctor()
    self._onPreUse = function()
    end

    self._onAtrUse = function()
    end

    self._role = nil

    self._item = nil

    self._withReward = false

    self._useNum = 1
end

function AbstractUseItemBody:setPreUseFunc(func)
    assert(type(func) == "function")
    self._onPreFunc = func
end

function AbstractUseItemBody:setAtfUseFunc(func)
    assert(type(func) == "function")
    self._onAtrUse = func
end

function AbstractUseItemBody:setRole(role)
    assert(type(role) == "table")
    self._role = role
end

function AbstractUseItemBody:setItem(item)
    assert(type(item) == "table")
    self._item = item
end

function AbstractUseItemBody:setUseItemNum(num)
    self._useNum = num
end

function AbstractUseItemBody:useItem()
    if self:__canUseItem() then
        local useSuccess = self:__doUseItem()

        return useSuccess
    end
    return false
end

function AbstractUseItemBody:__canUseItem()
    return true
end

function AbstractUseItemBody:__doUseItem()
    return true
end

-- @desc 获取宝箱中的奖励
function AbstractUseItemBody:__getReward()
    local item = self._item
    local role = self._role

    -- 非副本使用情况 并且 列表不为空
    if item._withReward and item.itemList ~= nil and string.len(item.itemList) > 0 then
        local itemId, count = item:randomItemsAndCount()
        local item = Item:getOneItemByKey(itemId)
        if item then
            role:addItemCount(item.id, count)

            local str = "获得物品" .. item.name
            if count > 1 then
                str = str .. " X" .. tostring(count)
            end

            role._iOutput:popText(str)
        end
    end
end

function AbstractUseItemBody:__onUseAft()
    if type(self._onAtrUse) == "function" then
        self._onAtrUse()
    end
end

function AbstractUseItemBody:__popText(str)
    self._role._iOutput:popText(str)
end

function AbstractUseItemBody:__richPrint(str)
    self._role._iOutput:richPrint(str)
end

return abstract("AbstractUseItem", {AbstractUseItemInterface}, AbstractUseItemBody)
0000