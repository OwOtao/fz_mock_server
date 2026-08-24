local Rx = require("third.rx.rx")

local Module = require("third.module.Module")
local RoleObservableModule = class("RoleObservableModule", Module)

function RoleObservableModule:ctor()
    -- 模块名
    self._name = "RoleObservableModule"

    -- 可观察主题
    self._eventSubject = nil
end

-- 可观测事件对象
function RoleObservableModule:getObservable(target)
    self:lazyInit()
    return self._eventSubject
end

-- 发送事件
function RoleObservableModule:dispatchEvent(target, name, ...)
    if self._eventSubject then
        self._eventSubject:onNext(name, ...)
    end
end

-- 懒加载
function RoleObservableModule:lazyInit()
    if self._eventSubject == nil then
        self._eventSubject = Rx.Subject.create()
    end
end

return RoleObservableModule
000000000000000