local class = require("third.class.NewClass")
local wareHouseConfig = require("script.others.wareHouseUpgrade")["仓库"]
--[[
    基于基础仓库，不包括家园仓库
]]
local WareHouse = {}

local originalLevel = 1000

local CurrencyType = {
    ["1"] = "碎银",
    ["2"] = "元宝"
}

function WareHouse:create()
    return WareHouse:new()
end

function WareHouse:ctor()
    self._wareHouseLevel = originalLevel
end

function WareHouse:setRole(role)
    self._role = role
end

--初始化仓库等级
function WareHouse:initWareHouseLevel()
    self._wareHouseLevel = self:__getLevelBywareHouseSpace()
end

--初始化仓库升级次数
function WareHouse:initWareHouseUpgradeCount()
    self._role:setAttr("ckUpCount",self._wareHouseLevel - originalLevel) 
end

function WareHouse:getWareHouseLevel()
    return self._wareHouseLevel
end

--升级空间
function WareHouse:upgradeWareHouse(func)
    HttpManagerEx:upgradeUserBag(2,self._wareHouseLevel + 1,function(status, errcode, errmsg, data)
        if status == 200 and errcode == 0 then
            if MapIsEmpty(data) == false then
                local afterSpace = self:__getWareHouseSpaceByLevel(self._wareHouseLevel + 1)

                if data.count then
                    PopText("消耗"..tostring(data.count)..CurrencyType[tostring(data.currency)].."把基础仓库升级到"..afterSpace.."格")
                end

                --碎银
                if data.currency == 1 then
                    self._role:addAttr("money", -data.count)
                end

                self._wareHouseLevel = self._wareHouseLevel + 1

                self:__updateRoleWareHouseSpace()

                self._role:addAttr("ckUpCount",1)

                if func then
                    func()
                end
            end
        else
            PopText(errmsg)
        end
    end,IS_SHOW_WAITING)
end

--获取升级空间
function WareHouse:getUpgradeSpace()
    local wareHouseSpace = self:__getWareHouseSpaceByLevel()
    local lastWareHouseSpace = self:__getWareHouseSpaceByLevel(self._wareHouseLevel - 1)
    return wareHouseSpace - lastWareHouseSpace
end

--与服务器数据进行校正 level 服务器下发
function WareHouse:correctLevelTrue(level)

    local space = self:__getWareHouseSpaceByLevel(level)
    local currSpace = self._role:getAttr("baseCkLimit")

    if space ~= currSpace then
        self:__updateRoleWareHouseSpace(space)
        self._wareHouseLevel = level
        self:initWareHouseUpgradeCount()
        if space > self._role:getAttr("ckLimit") then
            self._role:setAttr("ckLimit",space)
        end
    end
end

--获取当前仓库空间
function WareHouse:getWareHouseSpace(level)
    return self:__getWareHouseSpaceByLevel(level)
end

function WareHouse:checkIsMax()
    local maxSpace = self:getMaxSpace()
    local roleSpace = self._role:getAttr("baseCkLimit")

    return maxSpace == roleSpace
end

--获取当前仓库可升级最大空间
function WareHouse:getMaxSpace()
    return self.getMaxCount()
end

function WareHouse:checkCanUpgrade()
    if self:__getLevelUpgradeCurrencyType(self._wareHouseLevel + 1) == 1 then
        if self._role:getAttr("money") >= self:getLevelUpgradeCurrencyCount(self._wareHouseLevel + 1) then
            return true
        else
            return false
        end
    end
    return true
end

--获取当前升级所需货币类型
function WareHouse:getLevelUpgradeCurrencyName(level)
    return CurrencyType[tostring(self:__getLevelUpgradeCurrencyType(level))]
end

--获取当前升级所需货币数量
function WareHouse:getLevelUpgradeCurrencyCount(level)
    if MapIsEmpty(wareHouseConfig) == false then
        for __,config in pairs(wareHouseConfig) do
            if config.id == level then
                return config.count
            end
        end
    end
end

--获取当前升级所需货币类型
function WareHouse:__getLevelUpgradeCurrencyType(level)
    if MapIsEmpty(wareHouseConfig) == false then
        for __,config in pairs(wareHouseConfig) do
            if config.id == level then
                return config.currency
            end
        end
    end
end

--刷新人物仓库空间
function WareHouse:__updateRoleWareHouseSpace(wareHouseSpace)
    wareHouseSpace = Helper:getDef(wareHouseSpace,self:__getWareHouseSpaceByLevel()) 
    self._role:setAttr("baseCkLimit",wareHouseSpace)
end

--通过空间获取当前仓库等级
function WareHouse:__getLevelBywareHouseSpace()
    local currWareHouseSpace = self._role:getAttr("baseCkLimit")

    if MapIsEmpty(wareHouseConfig) == false then
        for __,config in pairs(wareHouseConfig) do
            if config.bagcount == currWareHouseSpace then
                return config.id
            end
        end
    end

    Collection:memoryCheat(User:getUserId(), "WareHouseSpaceError.LevelBywareHouseSpace", currWareHouseSpace, self:getMaxSpace())

    error("wareHouse:__getLevelBywareHouseSpace wareHouseUpgrade 配置表中未找到当前仓库空间对应仓库等级，仓库空间："..tostring(currWareHouseSpace))
end

--通过等级获取当前仓库空间
function WareHouse:__getWareHouseSpaceByLevel(level)
    level = Helper:getDef(level,self._wareHouseLevel)

    if MapIsEmpty(wareHouseConfig) == false then
        for __,config in pairs(wareHouseConfig) do
            if config.id == level then
                return config.bagcount
            end
        end
    end

    Collection:memoryCheat(User:getUserId(), "WareHouseSpaceError.WareHouseSpaceByLevel", level)

    error("wareHouse:__getWareHouseSpaceByLevel wareHouseUpgrade 配置表中未找到当前仓库等级对应仓库空间，仓库等级："..tostring(level))
end

function WareHouse.getMaxCount()
    local maxSpace = 0

    if MapIsEmpty(wareHouseConfig) == false then
        for __,config in pairs(wareHouseConfig) do
            if config.bagcount > maxSpace then
                maxSpace = config.bagcount
            end
        end
    end

    return maxSpace
end

return class("WareHouse", {}, WareHouse)
00000000000000