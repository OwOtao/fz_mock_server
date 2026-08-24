local newClass = require("third.class.NewClass")

local BaseBag = {
    --背包拥有者
    __role = nil,
    --背包可售卖的道具列表
    __sellList = {},
    --背包已售卖的道具列表
    __soldList = {},
    --背包道具索引
    __index = 1,
    --背包道具信息
    __listData = {}
}

function BaseBag:create(role)
    local p = BaseBag.new()
    p:init(role)
    return p
end

function BaseBag:init(role)
    self.__role = role
    self:initList()
end

--[[
    @desc: 初始化列表
    author:tanqinjian
    time:2025-08-15 14:55:35
    @return:
]]
function BaseBag:initList()
end

--[[
    @desc: 获取背包可售卖列表
    author:tanqinjian
    time:2025-08-15 14:54:38
    @return:
]]
function BaseBag:getSellList()
    return self.__sellList
end
--[[
    @desc: 获取背包已出售列表
    author:tanqinjian
    time:2025-08-15 14:54:55
    @return:
]]
function BaseBag:getSoldList()
    return self.__soldList
end

--[[
    @desc: 通过索引获取道具数据
    author:tanqinjian
    time:2025-08-15 14:55:08
    --@index: 道具索引
    @return:
]]
function BaseBag:getItemBaseData(index)
    return self.__listData[tostring(index)]
end

--[[
    @desc: 玩家购买操作
    author:tanqinjian
    time:2025-08-15 14:31:27
    --@index:道具索引
	--@count:购买数量
    @return:
]]
function BaseBag:buy(index, count)
    local isTrue = false

    for i, v in ipairs(self.__sellList) do
        if v.index == index then
            v.count = v.count + count
            isTrue = true
            break
        end
    end

    if isTrue == false then
        table.insert(self.__sellList, {count = count, index = index})
    end

    for i, v in ipairs(self.__soldList) do
        if v.index == index then
            v.count = v.count - count

            if v.count == 0 then
                table.remove(self.__soldList, i)
            end

            break
        end
    end
end

--[[
    @desc: 玩家售卖操作
    author:tanqinjian
    time:2025-08-15 14:38:56
    --@index:道具索引
	--@count:售卖数量
    @return:
]]
function BaseBag:sell(index, count)
    for i, v in ipairs(self.__sellList) do
        if v.index == index then
            v.count = v.count - count

            if v.count == 0 then
                table.remove(self.__sellList, i)
            end

            break
        end
    end

    local isTrue = false

    for i, v in ipairs(self.__soldList) do
        if v.index == index then
            v.count = v.count + count
            isTrue = true
            break
        end
    end

    if isTrue == false then
        table.insert(self.__soldList, {count = count, index = index})
    end
end

function BaseBag:refreshBag()
    self.__listData = {}
    self.__index = 1
    self.__sellList = {}
    self.__soldList = {}
    
    self:initList()
end

return newClass("BaseBag", {}, BaseBag)
0000000000