local BuffSystemResource = {}

local buffAdderDefaultDatas = require("script.newbattle.demo.buffAdderDefault")["添加器类型默认值"]

local buffAdderDatas = table.mapToArray(require("script.newbattle.demo.buffAdder")["Buff添加器"])

local shenBingBuffAdderDatas = table.mapToArray(require("script.newbattle.demo.shenBingBuffAdder")["新版战斗特性调用表id"])

local enterFightBuffAdderDatas = require("script.newbattle.demo.enterFightBuffAdder")["入场Buff添加器"]

local weightedBuffAdderDatas = require("script.newbattle.demo.RandWeightAdders")["data"]

function BuffSystemResource:init()
    self:initBuffAdder()
    self:initShenBingBuffAdder()
    self:initEnterFightBuffAdder()
end

function BuffSystemResource:initBuffAdder()
    self.__buffAdders = {}
    for k, v in pairs(buffAdderDatas) do
        if self.__buffAdders[v.buffLauncher] == nil then
            self.__buffAdders[v.buffLauncher] = {}
        end
        table.insert(self.__buffAdders[v.buffLauncher], inherit(v, buffAdderDefaultDatas["1"]))
    end

    for k, v in pairs(self.__buffAdders) do
        table.sort(
            v,
            function(a, b)
                return a.order < b.order
            end
        )
    end
end

function BuffSystemResource:initShenBingBuffAdder()
    self.__shenBingBuffAdders = {}
    for k, v in pairs(shenBingBuffAdderDatas) do
        if self.__shenBingBuffAdders[v.buffLauncher] == nil then
            self.__shenBingBuffAdders[v.buffLauncher] = {}
        end
        table.insert(self.__shenBingBuffAdders[v.buffLauncher], inherit(v, buffAdderDefaultDatas["2"]))
    end

    for k, v in pairs(self.__shenBingBuffAdders) do
        table.sort(
            v,
            function(a, b)
                return a.order < b.order
            end
        )
    end
end

function BuffSystemResource:initEnterFightBuffAdder()
    self.__enterFightBuffAdders = {}
    for k, v in pairs(enterFightBuffAdderDatas) do
        if self.__enterFightBuffAdders[v.buffLauncher] == nil then
            self.__enterFightBuffAdders[v.buffLauncher] = {}
        end
        table.insert(self.__enterFightBuffAdders[v.buffLauncher], inherit(v, buffAdderDefaultDatas["3"]))
    end

    for k, v in pairs(self.__enterFightBuffAdders) do
        table.sort(
            v,
            function(a, b)
                return a.order < b.order
            end
        )
    end
end

function BuffSystemResource:getBuffAdderData(id)
    return self.__buffAdders[id]
end

function BuffSystemResource:getShenBingBuffAdderData(id)
    return self.__shenBingBuffAdders[id]
end

function BuffSystemResource:getEnterFightBuffAdderData(id)
    return self.__enterFightBuffAdders[id]
end

--@desc: 获取加权随机Buff添加器列表
--@author:Seven
--@time:2026-01-12
--@launcherId: 添加器系列ID
--@return: 加权随机添加器资源列表
function BuffSystemResource:getWeightedBuffAddersByLauncher(launcherId)
    if self.__weightedBuffAddersByLauncher == nil then
        self.__weightedBuffAddersByLauncher = {}

        for id, data in pairs(weightedBuffAdderDatas) do
            local launcher = data.buffLauncher
            if self.__weightedBuffAddersByLauncher[launcher] == nil then
                self.__weightedBuffAddersByLauncher[launcher] = {}
            end

            local WeightedBuffAdderRes = require("app.FightSystem.FightBuff.BasicBuffAdder.WeightedBuffAdderRes")
            table.insert(self.__weightedBuffAddersByLauncher[launcher], WeightedBuffAdderRes:create(data))
        end
    end

    return self.__weightedBuffAddersByLauncher[launcherId] or {}
end

BuffSystemResource:init()

return BuffSystemResource
000000000000000