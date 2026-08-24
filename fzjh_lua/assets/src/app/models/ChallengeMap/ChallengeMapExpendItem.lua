--[[
Descripttion: 
version: 
Author: LvBin
Date: 2025-04-12 16:47:44
--]]
local newClass = require("third.class.NewClass")

local ChallengeMapExpendItem = {}

function ChallengeMapExpendItem:create(...)
    local p = ChallengeMapExpendItem.new()
    p:init(...)
    return p
end

function ChallengeMapExpendItem:ctor()
end

function ChallengeMapExpendItem:init(role,res)
    self.__res = res

    self.__role = role
end

function ChallengeMapExpendItem:check()
    local retItems = {}

    for i, items in ipairs(self.__res) do
        local isOk, item = self:__checkItems(items)

        if not isOk then
            return false,{},"进入该副本需的"..self:__getItemsText(items) .. "不足，无法开始"
        end

        table.insert(retItems,item)
    end

    return true,retItems,""
end

function ChallengeMapExpendItem:getTexts()
    local retTexts = {}

    for i, items in ipairs(self.__res) do
        table.insert(retTexts,self:__getItemsText(items))
    end

    return retTexts
end

function ChallengeMapExpendItem:__checkItems(items)
    for i, item in ipairs(items) do
        local itemId = item[1]

        local count = item[2]
        
        local roleCount = self.__role:getItemCount(itemId)

        if roleCount >= count then
            return true,{id = itemId,num = count}
        end
    end

    return false
end

function ChallengeMapExpendItem:__getItemsText(items)
    local text = ""

    for i, item in ipairs(items) do
        local itemId = item[1]

        local count = item[2]
        
        local roleCount = self.__role:getItemCount(itemId)
        
        local itemName = Item:getOneItemByKey(itemId).name

        if i == 1 then
            text = itemName.."*"..count
        else
            text = text .. "或" .. itemName .. "*" .. count
        end
    end

    return text
end

return newClass("ChallengeMapExpendItem", {}, ChallengeMapExpendItem)
0000000000000