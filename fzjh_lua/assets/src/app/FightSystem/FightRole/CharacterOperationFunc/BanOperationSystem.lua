--[[
    author:Seven
    time:2024-03-01 15:14:07
    desc: 角色操作禁用系统
]]
local newClass = require("third.class.NewClass")

local ABasicCharacterFuncSystem = require("app.FightSystem.FightRole.BasicFuncSystem.ABasicCharacterFuncSystem")

local FightCommons = require("app.FightSystem.FightCommons")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

--@SuperType [src.app.FightSystem.FightRole.BasicFuncSystem.ABasicCharacterFuncSystem#ABasicCharacterFuncSystem]
local BanOperationSystem = {}

function BanOperationSystem:create()
    return BanOperationSystem.new()
end

function BanOperationSystem:onInit()
    self.__banList = {}
    self.__infoIdIndex = 6000
end

function BanOperationSystem:addBanOperation(banType, banTips)
    if table.contains(FightCommons.BAN_OPERATION_TYPE, banType) then
        error("BanOperationSystem:addBanOperation banType 没有定义 : " .. tostring(banType))
    end

    local banOperation = {}
    banOperation.banType = banType
    banOperation.banTips = banTips
    banOperation.id = self:__getNewStateInfoId()
    table.insert(self.__banList, banOperation)
    return banOperation.id
end

function BanOperationSystem:removeBanOperation(id)
    for i = 1, table.getn(self.__banList) do
        if self.__banList[i].id == id then
            table.remove(self.__banList, i)
            return true, self.__banList[i].id
        end
    end
end

--@desc: 是否禁用操作
--@author:Seven
--@time:2024-03-01 15:23:29
--@banType:
--@return:
function BanOperationSystem:isBanOperation(banType)
    for i = 1, table.getn(self.__banList) do
        local banInfo = self.__banList[i]
        if banInfo.banType == banType then
            return true, banInfo.banTips
        end
    end
    return false
end

function BanOperationSystem:__getNewStateInfoId()
    self.__infoIdIndex = self.__infoIdIndex + 1
    return self.__infoIdIndex
end

function BanOperationSystem:onDestory()
    self.__banList = nil
    self.__infoIdIndex = nil
end

function BanOperationSystem:onUpdate(ft)
end

return newClass("BanOperationSystem", {ABasicCharacterFuncSystem}, BanOperationSystem)
0000000