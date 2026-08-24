local class = require("third.class.NewClass")
local BagConfig = require("script.others.bagUpgrade")["背包"]

local Bag = {}

local originalLevel = 1000

local CurrencyType = {
    ["1"] = "碎银",
    ["2"] = "元宝",
}

function Bag:create()
    return Bag:new()
end

function Bag:ctor()
    self._BagLevel = originalLevel
end

function Bag:setRole(role)
    self._role = role
end

--初始化背包等级
function Bag:initBagLevel()
    self._BagLevel = self:__getLevelByBagSpace()
end

--初始化背包升级次数
function Bag:initBagUpgradeCount()
    self._role:setAttr("wUpCount",self._BagLevel - originalLevel) 
end

function Bag:getBagLevel()
    return self._BagLevel
end

--升级空间
function Bag:upgradeBag(func)
    HttpManagerEx:upgradeUserBag(1,self._BagLevel + 1,function(status, errcode, errmsg, data)
        if status == 200 and errcode == 0 then
            if MapIsEmpty(data) == false then
                local afterSpace = self:__getBagSpaceByLevel(self._BagLevel + 1)

                if data.count then
                    PopText("消耗"..tostring(data.count)..CurrencyType[tostring(data.currency)].."把背包升级到"..afterSpace.."格")
                end

                --碎银
                if data.currency == 1 then
                    self._role:addAttr("money", -data.count)
                end

                self._BagLevel = self._BagLevel + 1

                self:__updateRoleBagSpace()

                self._role:addAttr("wUpCount",1)

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
function Bag:getUpgradeSpace()
    local BagSpace = self:__getBagSpaceByLevel()
    local lastBagSpace = self:__getBagSpaceByLevel(self._BagLevel - 1)
    return BagSpace - lastBagSpace
end

--与服务器数据进行校正 level 服务器下发
function Bag:correctLevelTrue(level)

    local space = self:__getBagSpaceByLevel(level)
    local currSpace = self._role:getAttr("weight")

    if space ~= currSpace then
        self:__updateRoleBagSpace(space)
        self._BagLevel = level
        self:initBagUpgradeCount()
    end
end

--获取当前背包空间
function Bag:getBagSpace(level)
    return self:__getBagSpaceByLevel(level)
end

function Bag:checkIsMax()
    local maxSpace = self:getMaxSpace()
    local roleSpace = self._role:getAttr("weight")

    return maxSpace == roleSpace
end

--本地货币需要检测货币是否足够
function Bag:checkCanUpgrade()
    if self:__getLevelUpgradeCurrencyType(self._BagLevel + 1) == 1 then
        if self._role:getAttr("money") >= self:getLevelUpgradeCurrencyCount(self._BagLevel + 1) then
            return true
        else
            return false
        end
    end
    return true
end

--获取当前背包可升级最大空间
function Bag:getMaxSpace()
    local maxSpace = 0

    if MapIsEmpty(BagConfig) == false then
        for __,config in pairs(BagConfig) do
            if config.bagcount > maxSpace then
                maxSpace = config.bagcount
            end
        end
    end

    return maxSpace
end

--获取当前升级所需货币类型
function Bag:getLevelUpgradeCurrencyName(level)
    return CurrencyType[tostring(self:__getLevelUpgradeCurrencyType(level))]
end

--获取当前升级所需货币数量
function Bag:getLevelUpgradeCurrencyCount(level)
    if MapIsEmpty(BagConfig) == false then
        for __,config in pairs(BagConfig) do
            if config.id == level then
                return config.count
            end
        end
    end
end

--获取当前升级所需货币类型
function Bag:__getLevelUpgradeCurrencyType(level)
    if MapIsEmpty(BagConfig) == false then
        for __,config in pairs(BagConfig) do
            if config.id == level then
                return config.currency
            end
        end
    end
end

--刷新人物背包空间
function Bag:__updateRoleBagSpace(BagSpace)
    BagSpace = Helper:getDef(BagSpace,self:__getBagSpaceByLevel()) 
    self._role:setAttr("weight",BagSpace)
end

--通过空间获取当前背包等级
function Bag:__getLevelByBagSpace()
    local currBagSpace = self._role:getAttr("weight")

    if MapIsEmpty(BagConfig) == false then
        for __,config in pairs(BagConfig) do
            if config.bagcount == currBagSpace then
                return config.id
            end
        end
    end

    Collection:memoryCheat(User:getUserId(), "bagSpaceError.LevelByBagSpace", currBagSpace, self:getMaxSpace())

    error("Bag:__getLevelByBagSpace bagUpgrade 配置表中未找到当前仓库空间对应仓库等级，仓库空间："..tostring(currBagSpace))
end

--通过等级获取当前背包空间
function Bag:__getBagSpaceByLevel(level)
    level = Helper:getDef(level,self._BagLevel)

    if MapIsEmpty(BagConfig) == false then
        for __,config in pairs(BagConfig) do
            if config.id == level then
                return config.bagcount
            end
        end
    end

    Collection:memoryCheat(User:getUserId(), "bagSpaceError.BagSpaceByLevel", level)

    error("Bag:__getBagSpaceByLevel bagUpgrade 配置表中未找到当前仓库等级对应仓库空间，仓库等级："..tostring(level))
end

local maxBgCount = nil
function Bag.getBagMaxCount()
    if maxBgCount then
        return maxBgCount
    end
    maxBgCount = 0
    for k, v in pairs(BagConfig) do
        if v.bagcount > maxBgCount then
            maxBgCount = v.bagcount
        end
    end

    return maxBgCount
end

return class("Bag", {}, Bag)
0000000000000000