local newClass = require("third.class.NewClass")

local LianGongParamsManager = require("app.models.role.lianGong.LianGongParamsManager")

local XinShenResManager = require("app.models.role.xinShen.XinShenResManager")

local XinShenSystem = {
    __codeVersion = 1
}

function XinShenSystem:create()
    return XinShenSystem.new(TableProxy:createEncryptedTable({}))
end

function XinShenSystem:ctor()
    self.__isNotSerializable = true
end

function XinShenSystem:setPlayer(player)
    self.__player = player
end

function XinShenSystem:getPlayer()
    return self.__player
end

--@desc: 获取当前心神和心神最大值
--@author:LvBin
--@time:2022-04-11 10:32:07
--@callback:
--@return
function XinShenSystem:getXinShenValue(callback)
    self.__player:getServerActionSystem():getXinShenValue(
        self.__codeVersion,
        function(ok, data)
            if ok then
                callback(ok, data)
            else
                callback(ok, data)
            end
        end
    )
end

--@desc: 升级心神上限
--@author:LvBin
--@time:2022-04-11 10:33:45
--@callback:
--@return
function XinShenSystem:upgradeXinShenLevel(callback)
    self.__player:getServerActionSystem():upgradeXinShenLevel(
        self.__codeVersion,
        GetTime(),
        function(ok, data)
            if ok then
                callback(ok, data)
            else
                callback(ok, data)
            end
        end
    )
end

--@desc: 获取当前心神上限等级
--@author:LvBin
--@time:2022-04-11 17:44:06
--@callback:
--@return
function XinShenSystem:getXinShenLevel(callback)
    self.__player:getServerActionSystem():getXinShenLevel(
        self.__codeVersion,
        function(ok, data)
            if ok then
                callback(ok, data)
            else
                callback(ok, data)
            end
        end
    )
end

--@desc: 获取心神恢复时间
--@author:LvBin
--@time:2022-04-13 14:27:15
--@callback:
--@return
function XinShenSystem:getXinShenRecoverStartTime(callback)
    self.__player:getServerActionSystem():getXinShenRecoverStartTime(
        self.__codeVersion,
        function(ok, data)
            if ok then
                callback(ok, data)
            else
                callback(ok, data)
            end
        end
    )
end

--@desc: 恢复心神值
--@author:LvBin
--@time:2022-04-18 19:15:18
--@value: 恢复多少
--@callback:
--@return
function XinShenSystem:recoverXinShenValue(value, callback)
    self.__player:getServerActionSystem():recoverXinShenValue(
        value,
        self.__codeVersion,
        GetTime(),
        function(ok, data)
            if ok then
                callback(ok, data)
            else
                callback(ok, data)
            end
        end
    )
end

--@desc: 获取回复心神物品列表
--@author:LvBin
--@time:2022-06-11 16:13:57
--@callback:
--@return
function XinShenSystem:getItemMap(callback)
    self.__player:getServerActionSystem():getItemMap(
        function(ok, data)
            if ok then
                callback(ok, data)
            else
                callback(ok, data)
            end
        end
    )
end

--@desc: 添加回复心神物品
--@author:LvBin
--@time:2022-06-11 16:14:21
--@itemId:
--@count:
--@callback:
--@return
function XinShenSystem:addItemCount(itemId, count, callback)
    self.__player:getServerActionSystem():addItemCount(
        itemId,
        count,
        self.__codeVersion,
        function(ok, data)
            if ok then
                callback(ok, data)
            else
                callback(ok, data)
            end
        end
    )
end

--@desc: 使用回复心神物品
--@author:LvBin
--@time:2022-06-11 16:14:21
--@itemId:
--@callback:
--@return
function XinShenSystem:useItem(itemId, callback)
    self.__player:getServerActionSystem():useItem(
        itemId,
        self.__codeVersion,
        function(ok, data)
            if ok then
                callback(ok, data)
            else
                callback(ok, data)
            end
        end
    )
end

--@desc: 获取心神上限升级数据根据心神id
--@author:LvBin
--@time:2022-04-11 10:56:35
--@id: 心神id
--@return
function XinShenSystem:getXinShenMaxUpgradeDataById(id)
    return XinShenResManager:getXinShenMaxUpgradeDataById(id)
end

--@desc: 获取心神上限升级数据根据心神等级
--@author:LvBin
--@time:2022-04-11 11:03:44
--@level:心神等级
--@return
function XinShenSystem:getXinShenMaxUpgradeDataByLevel(level)
    return XinShenResManager:getXinShenMaxUpgradeDataByLevel(level)
end

--@desc: 获取心神等级上限
--@author:LvBin
--@time:2022-04-11 12:01:16
--@return
function XinShenSystem:getMaxLevel()
    return XinShenResManager:getMaxLevel()
end

--@desc: 获取心神基础上限
--@author:LvBin
--@time:2022-04-11 12:16:13
--@return
function XinShenSystem:getBaseXinShenMax()
    return LianGongParamsManager:getConfContent("17")
end

--@desc: 获取心神恢复间隔时间(秒)
--@author:LvBin
--@time:2022-04-13 15:46:43
--@return
function XinShenSystem:getXinShenRecoverInterval()
    return LianGongParamsManager:getConfContent("24")
end

--@desc: 获取每次心神恢复值
--@author:LvBin
--@time:2022-04-13 15:46:57
--@return
function XinShenSystem:getXinShenRecoverValue()
    return LianGongParamsManager:getConfContent("25")
end

function XinShenSystem:getItemData(itemId)
    return XinShenResManager:getMindRecoverItem(itemId)
end

return newClass("XinShenSystem", {}, XinShenSystem)
000000000000