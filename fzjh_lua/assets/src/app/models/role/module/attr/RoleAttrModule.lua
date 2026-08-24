local Rx = require("third.rx.rx")
local Module = require("third.module.Module")
local RoleAttrModule = class("RoleAttrModule", Module)

local function log(...)
	if DEBUG_MODE == 1 then
		print("RoleAttrModule:", ...)
		local strList = table.map({...}, function(v) return tostring(v) end)
	end
end

function RoleAttrModule:ctor()
    -- 模块名
    self._name = "RoleAttrModule"


    -- 记录订阅, 用于放置反复订阅
    self._watchFinalAttrChangeWithDependMapSubscription = nil
end

function RoleAttrModule:onAttach(target)
end

-- 监控基本属性变化
function RoleAttrModule:watchAttrChange(target, attrName, callback)
    local minitorAttrName = attrName
    -- 监控属性变化
    local setAttr = target:getObservable()
        :filter(function(eventName, attrName) return eventName == "setAttr" and attrName == minitorAttrName end)
        :map(function(eventName, attrName, value) return value end)

    local addAttr = target:getObservable()
        :filter(function(eventName, attrName) return eventName == "addAttr" and attrName == minitorAttrName  end)
        :map(function(eventName, attrName, value) return value end)

    local setAttr_change = setAttr
            -- :distinctUntilChanged(function(value, oldValue) return value == oldValue end)

    local addAttr_change = addAttr:filter(function(value) return value ~= 0 end)

    local final = Rx.Observable.merge(setAttr_change, addAttr_change)
        :map(function() return target:getAttr(attrName) end)
        -- :distinctUntilChanged(function(value, oldValue) 
        --     return value == oldValue end)
        :scan(
            function(acc, value) 
                if type(acc) == "table" then
                    return {oldValue = acc.value, value = value}
                else
                    return {oldValue = acc, value = value}
                end
            end, target:getAttr(attrName))
        :map(
            function(acc) 
                return acc.value, acc.oldValue, acc.value - acc.oldValue
            end)

    return final:retry():subscribe(function(new, old, change)
            callback(new, old, change)
        end, 
        function(errmsg)
            print("出错", errmsg)
        end)
end

-- 监控最终属性变化
function RoleAttrModule:watchFinalAttrChange(target, attrName, callback)
    local minitorAttrName = attrName

    -- 设置属性
    local setAttr_change = target:getObservable()
        :filter(function(eventName, attrName) return eventName == "setAttr" and attrName == minitorAttrName end)
        :map(function(eventName, attrName, value) return value end)

    -- 增加属性
    local addAttr_change = target:getObservable()
        :filter(function(eventName, attrName, value) return eventName == "addAttr" and attrName == minitorAttrName and value ~= 0 end)

    -- 老buff系统更新
    local oldRoleBuffUpdate = target:getObservable()
        :filter(function(eventName) return eventName == "updateRoleBuff" end)

    -- 新buff系统更新
    local roleBuffUpdate = target:getObservable()
        :filter(function(eventName) return eventName == "roleBuffUpdate" end)

    local final = Rx.Observable.merge(setAttr_change, addAttr_change, oldRoleBuffUpdate, roleBuffUpdate)
        :map(function()
            return target:getFinalAttr(attrName) end)
        -- :distinctUntilChanged(function(value, oldValue) 
        --     return value == oldValue end)
        :scan(
            function(acc, value) 
                if type(acc) == "table" then
                    return {oldValue = acc.value, value = value}
                else
                    return {oldValue = acc, value = value}
                end
            end, target:getFinalAttr(attrName))
        :map(
            function(acc) 
                return acc.value, acc.oldValue, acc.value - acc.oldValue
            end)

    return final:retry():subscribe(
        function(new, old, change)            
            callback(new, old, change)
        end, function(errmsg)
            print("出错", errmsg)
        end)
end

-- 监控所有属性
function RoleAttrModule:watchAllFinalAttrChange(target, callback)
    -- 记录订阅
    local subscriptions = {}
    
    local attrWatchMap = {
        "qi",
        "qiMax",
        "qiPercent",
        "neili",
        "neiliMax",
        "dreamPoints"
    }

    -- 遍历观察属性观察表
    for _, attrName in ipairs(attrWatchMap) do
        local subscription = self:watchFinalAttrChange(target, attrName, 
            function(new, old, change)
                callback(attrName, new, old, change)
            end)
            
        table.insert(subscriptions, subscription)
    end

    -- 返回订阅, 用于取消
    return Rx.Subscription.create(
        function ()
            for i = 1, #subscriptions do
                if subscriptions[i] then subscriptions[i]:unsubscribe() end
            end
        end)
end

-- 通过属性监控表, 监控属性变化
function RoleAttrModule:watchFinalAttrChangeWithDependMap(target, attrDependMap, attrWatchMap)
    
    -- 如果已经订阅, 则取消订阅
    if self._watchFinalAttrChangeWithDependMapSubscription ~= nil then
        self._watchFinalAttrChangeWithDependMapSubscription:unsubscribe()
        self._watchFinalAttrChangeWithDependMapSubscription = nil
    end

    self._watchFinalAttrChangeWithDependMapSubscription = self:doWatchFinalAttrChangeWithMap(target, attrDependMap, attrWatchMap)
end

function RoleAttrModule:doWatchFinalAttrChangeWithMap(target, attrDependMap, attrWatchMap)

    -- 方法调用深度记录
    local depth = 0

    -- 当前属性依赖表
    local currAttrDependMap = attrDependMap

    -- 记录订阅
    local subscriptions = {}

    -- 遍历观察属性观察表
    for attrName, watcher in pairs(attrWatchMap) do
        local subscription = self:watchFinalAttrChange(target, attrName, 
            function(new, old, change)

                -- 深度为0, 则初始化属性依赖表
                if depth == 0 then
                    currAttrDependMap = attrDependMap
                end

                -- 查表确定是否有依赖, 有则发送通知
                if currAttrDependMap[attrName] then
                    depth = depth + 1
                    log(string.rep(" ", depth - 1).."最终属性变化:", attrName, new, old, change)
                    
                    -- 异常处理, 避免影响控制流程
                    xpcall(
                        function()
                            local oldMap = currAttrDependMap
                            currAttrDependMap = currAttrDependMap[attrName]
                            watcher(new, old, change)
                            currAttrDependMap = oldMap
                        end,
                        function(errmsg)
                            print("errmsg:", errmsg)
                        end)

                    depth = depth - 1
                end
            end)

        table.insert(subscriptions, subscription)
    end

    -- 返回订阅, 用于取消
    return Rx.Subscription.create(
        function ()
            for i = 1, #subscriptions do
                if subscriptions[i] then subscriptions[i]:unsubscribe() end
            end
        end)
end

return RoleAttrModule
00000