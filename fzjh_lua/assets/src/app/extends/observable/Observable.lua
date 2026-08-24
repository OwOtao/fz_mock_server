local assertIsInstance = require("third.assertIsInstance.assertIsInstance")
local IObservable = require("app.extends.observable.IObservable")
local inherit = require("third.inherit.inherit")
local Rx = require("third.rx.rx")

local function log(...)
    print("Observable:", ...)
end

local Observable = {}

function Observable:create()
    local p = inherit({}, Observable)
    p:init()
    return p
end

--@desc 初始化
function Observable:init()
    self._subscriptions = {}
    self._subject = Rx.Subject.create()
end

--@desc 订阅消息
function Observable:subscribe(eventName, callback)
    assert(type(eventName) == "string")
    assert(type(callback) == "function")

    local subscription =
        self._subject
            :filter(function(name) return name == eventName end)
            :retry()
            :subscribe(
                function(...)
                    log(...)
                    callback(...)
                end,
                function(errmsg)
                    print("errmsg:", errmsg)
                    error(errmsg)
                end
            )

    table.insert(self._subscriptions, subscription)
    return subscription
end

--@desc 分发消息
function Observable:notify(eventName, ...)
    self._subject:onNext(eventName, ...)
end

--@desc 订阅个数
function Observable:getSubscriptionCount()
    return #self._subscriptionss
end

return assertIsInstance(Observable, IObservable)
0000000