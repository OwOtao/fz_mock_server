local Rx = require("third.rx.rx")

local awakeFuncName = "onAwake"
local enableFuncName = "onEnable"
local disableFuncName = "onDisable"
local destroyFuncName = "onDestroy"

local old_pause = cc.Node.pause
local old_resume = cc.Node.resume

local NeedAddBlockAsyncFunc = {
    [awakeFuncName] = true,
    [enableFuncName] = true
}

local recordWithLifeCycleClassNameMap = {}

local function log(...)
    if PRINT_MODE == 1 then
        print("LifeCycle:", ...)
    end
end

local function addLifeCycleTo(className, class)
    recordWithLifeCycleClassNameMap[className] = true

    local function callTableFunc(self, funcName, ...)
        if self.__withLifeCycle then
            -- awake只执行一次, 在第一次onEnable之前
            if self.___isAwaked == nil and funcName == enableFuncName then
                self.___isAwaked = true
                callTableFunc(self, awakeFuncName)
            end

            self._lifeCycleEventSubject:onNext(funcName)
        else
            log("类型" .. className .. "没有添加生命周期方法, 请看LifeCycleSupport.lua")
        end
    end

    -- 给class支持生命周期方法
    if class.__oldCreate == nil then
        class.__oldCreate = class.create
        class.create = function(...)
            log("create", className, " with life cycle event")

            local p = class.__oldCreate(...)

            -- 初始化生命周期
            p:__initLifeCycle()

            return p
        end
    end

    -- 初始化生命周期
    function class:__initLifeCycle()
        -- 表示拥有生命周期方法
        self.__withLifeCycle = true
        self.__isActived = false

        -- 注册事件监听
        self:registerScriptHandler(
            function(state)
                if state == "enter" then
                    self.__isActived = true
                    callTableFunc(self, enableFuncName)
                elseif state == "exit" then
                    callTableFunc(self, disableFuncName)
                elseif state == "cleanup" then
                    callTableFunc(self, destroyFuncName)
                end
            end
        )

        self._lifeCycleEventSubject = Rx.Subject.create()

        self._lifeCycleEventSubject:subscribe(
            function(eventName)
                log(className, eventName, self)

                if self[eventName] then
                    if NeedAddBlockAsyncFunc[eventName] then
                        Game:addBlockAsyncFunc(
                            "LifeCycleSupport." .. self[".classname"] .. "." .. eventName .. ".",
                            function()
                                self[eventName](self)
                            end
                        )
                    else
                        self[eventName](self)
                    end
                end
            end
        )
    end

    -- 支持暂停后调用暂停方法
    if class.__old_pause == nil then
        class.__old_pause = old_pause

        class.pause = function(self)
            local children = self:getChildren()
            for k, child in pairs(children) do
                class.pause(child)
            end

            class.__old_pause(self)

            if self.onPause then
                self:onPause()
            end

            if self.__isActived == nil or self.__isActived == true then
                self.__isActived = false
                -- 调用暂停方法
                callTableFunc(self, disableFuncName)
            end
        end
    end

    -- 支持恢复后调用恢复方法
    if class.__old_resume == nil then
        class.__old_resume = old_resume

        class.resume = function(self, ...)
            local children = self:getChildren()
            for k, child in pairs(children) do
                class.resume(child)
            end

            class.__old_resume(self, ...)

            if self.onResume then
                self:onResume()
            end

            if self.__isActived == nil or self.__isActived == false then
                self.__isActived = true
                -- 调用暂停方法
                callTableFunc(self, enableFuncName)
            end
        end
    end
end

-- 无脑自动添加生命周期方法
local function addLifeCycleToToNameSpace(name, nameSpace)
    for k, v in pairs(nameSpace) do
        local className = name .. "." .. k

        if type(v) == "table" and type(v.create) == "function" and type(v.setPosition) == "function" then
            addLifeCycleTo(className, v)
        else
            print("不能添加生命周期方法:", k, v)
        end
    end
end

-- 给不同的Node的子类添加生命周期
addLifeCycleTo("ccui.Widget", ccui.Widget)
addLifeCycleTo("ccui.Layout", ccui.Layout)

-- 支持layer
-- addLifeCycleTo("cc.Layer", cc.Layer)
-- addLifeCycleTo("ExtPageView", ExtPageView)

-- -- node最后添加
addLifeCycleTo("cc.Node", cc.Node)
addLifeCycleTo("cc.Layer", cc.Layer)

-- local oldClass = class
-- class = function(className, cls)
--     local ret = oldClass(className, cls)

--     if cls == cc.Layer or cls == cc.Node then
--         addLifeCycleTo(className, ret)
--     end

--     return ret
-- end

return addLifeCycleTo
00