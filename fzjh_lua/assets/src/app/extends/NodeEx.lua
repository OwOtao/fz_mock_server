-- 扩展node的方法
--@SuperType [luaIde#cc.Node]
local Node = cc.Node
local AsyncFunction = require("third.async.AsyncFunction")

-- 设置zorder
function Node:setZ(z)
    return self:setLocalZOrder(z)
end
function Node:maxZ()
    local scene = self:getParent()
    if scene then
        local children = scene:getChildren()
        local maxZ, maxNode = nil
        if children then
            for key, var in pairs(children) do
                if maxZ == nil then
                    maxZ = var:getLocalZOrder()
                else
                    maxZ = math.max(maxZ, var:getLocalZOrder())
                end
            end
            self:setLocalZOrder(maxZ)
            
            -- 判断是否需要层级 + 1
            for key, var in pairs(children) do
                if self ~= var and maxZ == var:getLocalZOrder() then
                    self:setLocalZOrder(maxZ + 1)
                    break
                end
            end
        
        end
    end
end

function Node:getMinX()
    -- local size = self:getContentSize()
    local size = cc.size(self:getFinalSize())
    local anchorPoint = self:getAnchorPoint()
    if self:isIgnoreAnchorPointForPosition() then
        anchorPoint.x = 0
        anchorPoint.y = 0
    end
    if PRINT_MODE == 1 then
        print("size = " .. size.width .. ", " .. size.height)
        print("anchorPoint = " .. anchorPoint.x .. ", " .. anchorPoint.y)
    end
    local minX = -(size.width * anchorPoint.x)
    return minX
end

function Node:getMaxX()
    -- local size = self:getContentSize()
    local size = cc.size(self:getFinalSize())
    local anchorPoint = self:getAnchorPoint()
    if self:isIgnoreAnchorPointForPosition() then
        anchorPoint.x = 0
        anchorPoint.y = 0
    end
    if PRINT_MODE == 1 then
        print("size = " .. size.width .. ", " .. size.height)
        print("anchorPoint = " .. anchorPoint.x .. ", " .. anchorPoint.y)
    end
    local maxX = size.width * (1 - anchorPoint.x)
    return maxX
end

function Node:getMinY()
    -- local size = self:getContentSize()
    local size = cc.size(self:getFinalSize())
    local anchorPoint = self:getAnchorPoint()
    if self:isIgnoreAnchorPointForPosition() then
        anchorPoint.x = 0
        anchorPoint.y = 0
    end
    if PRINT_MODE == 1 then
        print("size = " .. size.width .. ", " .. size.height)
        print("anchorPoint = " .. anchorPoint.x .. ", " .. anchorPoint.y)
    end
    local minY = -(size.height * anchorPoint.y)
    return minY
end

function Node:getMaxY()
    -- local size = self:getContentSize()
    local size = cc.size(self:getFinalSize())
    local anchorPoint = self:getAnchorPoint()
    if self:isIgnoreAnchorPointForPosition() then
        anchorPoint.x = 0
        anchorPoint.y = 0
    end
    if PRINT_MODE == 1 then
        print("size = " .. size.width .. ", " .. size.height)
        print("anchorPoint = " .. anchorPoint.x .. ", " .. anchorPoint.y)
    end
    local maxY = size.height * (1 - anchorPoint.y)
    return maxY
end

function Node:setFinalSize(desWidth, desHeight)
    local size = self:getContentSize()
    if desWidth then
        local srcWidth = size.width
        local scaleX = desWidth / srcWidth
        self:setScaleX(scaleX)
    end
    if desHeight then
        local srcHeight = size.height
        local scaleY = desHeight / srcHeight
        self:setScaleY(scaleY)
        if PRINT_MODE == 1 then
            print("desHeight = " .. desHeight)
            print("srcHeight = " .. srcHeight)
            print("scaleY = " .. scaleY)
        end
    end
end

function Node:getFinalSize()
    local size = self:getContentSize()
    return size.width * self:getScaleX(), size.height * self:getScaleY()
end

function Node:getOnlyId()
    if self.OnlyId == nil then
        self.OnlyId = 0
    end
    self.OnlyId = self.OnlyId + 1
    return self.OnlyId
end

-- 添加节点事件
function Node:addNodeEvent(eventName, callback)
    if self.addNodeEventTb == nil then
        self.addNodeEventTb = {}
    end
    local eventList = self.addNodeEventTb[eventName]
    if eventList == nil then
        self.addNodeEventTb[eventName] = {}
        eventList = self.addNodeEventTb[eventName]
        
        self:onNodeEvent(eventName,
            function(...)
                for i = 1, #eventList do
                    local func = eventList[i].func
                    if func then
                        func(...)
                    end
                end
            end)
    end
    local id = self:getOnlyId()
    table.insert(eventList, {id = id, func = callback})
    return id
end

-- 移除节点事件
function Node:delNodeEvent(eventName, id)
    if self.addNodeEventTb == nil or self.addNodeEventTb[eventName] == nil then
        if PRINT_MODE == 1 then
            print("NodeEvent为空")
        end
        return false
    end
    local eventList = self.addNodeEventTb[eventName]
    for i = 1, #eventList do
        local event = eventList[i]
        if event.id == id then
            table.remove(eventList, i)
            return true
        end
    end
end

-- actionTag
function Node:getActionTagByName(name)-- 得到定时器id, 用这个无需担心定时器id重复.
    if not self._actionTag then
        self._actionTag = {tagMap = {}, currTagId = 1}
    end
    local actionTag = self._actionTag.tagMap[name]
    if not actionTag then
        actionTag, self._actionTag.tagMap[name] = self._actionTag.currTagId, self._actionTag.currTagId
        self._actionTag.currTagId = self._actionTag.currTagId + 1
    end
    return actionTag
end

-- 执行特定action
function Node:runActionWithName(name, action)
    assert(name and action)
    local tag = self:getActionTagByName(name)
    self:stopActionByTag(tag)
    action:setTag(tag)
    return self:runAction(action)
end
-- 通过名称停止action
function Node:stopActionByName(name)
    local tag = self:getActionTagByName(name)
    return self:stopActionByTag(tag)
end
-- 注册调度器回调函数
local SCHEDULE_LOCAL = true
local SCHEDULE_HANDLE = 1
-- local FRAME_DURATION = 1 / 60
function Node:schedule(listener, interval, tag, isUseSysTime)
    if isUseSysTime == nil then isUseSysTime = false end
    assert(type(listener) == "function")
    interval = interval or 0
    if not self._schedulerList then
        self._schedulerList = {}
        self:onUpdate(
            function(elapsed)
                -- if self.class then
                --     print("instance.class.__cname", self.class.__cname)
                -- end
                
                -- 防变速作弊, add by tangjian 20160812
                if isUseSysTime then
                    else
                    elapsed = cc.Director:getInstance():getAnimationInterval()
                end
                
                local needRemove = false
                for i = 1, #self._schedulerList do
                    local schedule = self._schedulerList[i]
                    if schedule.valid then
                        schedule.elapsed = schedule.elapsed + elapsed
                        if schedule.elapsed >= schedule.interval then
                            schedule.elapsed = schedule.elapsed - schedule.interval
                            -- add by XiaoZhiWei 2017/10/10 12:22:38 调度器需要正确的返回间隔时间
                            if schedule.interval > 0 then
                                elapsed = schedule.interval
                            end
                            schedule.func(elapsed)
                        end
                    elseif schedule.stop == true then
                        --暂停不做任何处理 
                    else
                        needRemove = true
                    end
                end
                if needRemove then
                    for i = 1, #self._schedulerList do
                        local schedule = self._schedulerList[i]
                        if schedule and not schedule.valid then
                            table.remove(self._schedulerList, i)
                        end
                    end
                end
            end)
    end
    SCHEDULE_HANDLE = SCHEDULE_HANDLE + 1
    local schedule =
        {
            tag = tag,
            valid = true,
            stop = false,
            handle = SCHEDULE_HANDLE,
            interval = interval,
            elapsed = 0
        }
    schedule.func = listener
    table.insert(self._schedulerList, schedule)
    return SCHEDULE_HANDLE
end
function Node:unschedule(handle)
    if self._schedulerList == nil then
        return
    end
    for i, schedule in ipairs(self._schedulerList) do
        if schedule.handle == handle then
            schedule.valid = false
            break
        end
    end
end
function Node:unscheduleAll()
    if self._schedulerList == nil then
        return
    end
    for i, schedule in ipairs(self._schedulerList) do
        schedule.valid = false
    end
end
--设置暂停
function Node:pauseSchedulerAndActions(handle) 
    if self._schedulerList == nil then
        return
    end
    for i, schedule in ipairs(self._schedulerList) do
        if schedule.handle == handle then
            schedule.valid = false
            schedule.stop = true
            break
        end
    end
end
function Node:resumeSchedulerAndActions(handle)
    if self._schedulerList == nil then
        return
    end
    for i, schedule in ipairs(self._schedulerList) do
        if schedule.handle == handle then
            schedule.valid = true
            schedule.stop = false
            break
        end
    end
end
-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/08 22:23:27
-- @desc 通过tag注销调度器
function Node:unscheduleWithTag(tag)
    if self._schedulerList == nil then return end
    local removeArray = {}
    for i, v in ipairs(self._schedulerList) do
        if tag == v.tag then
            table.insert(removeArray, v.handle)
        end
    end
    for i, handle in ipairs(removeArray) do
        self:unschedule(handle)
    end
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/08 22:05:34
-- @desc 注册tag唯一的调度器, 如果已经有该 tag 存在, 则不注册
function Node:scheduleUnique(listener, interval, tag)
    self:unscheduleWithTag(tag)
    return self:schedule(listener, interval, tag)
end
-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/08 22:05:00
-- @desc 通过tag得到调度器 handle
function Node:getSchedulesHandleWithTag(tag)
    if self._schedulerList == nil then return {} end
    local handles = {}
    for i, schedule in ipairs(self._schedulerList) do
        if schedule.tag == tag then
            table.insert(handles, schedule.handle)
        end
    end
    return handles
end
function Node:getSchedulesWithTag(tag)
    if self._schedulerList == nil then return {} end
    local handles = {}
    for i, schedule in ipairs(self._schedulerList) do
        if schedule.tag == tag then
            table.insert(handles, schedule)
        end
    end
    return handles
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 延时函数调用
function Node:delayFunc(delay, func)
    if delay == nil or delay < 0 then
        AsyncFunction:asyncCall(func, self)
        return
    end
    local actionTag = Helper:getOnlyId()
    local action = cc.Sequence:create(cc.DelayTime:create(delay), cc.CallFunc:create(
        function()
            AsyncFunction:asyncCall(func, self)
        end))
    action:setTag(actionTag)
    self:runAction(action)
    return actionTag
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/26 17:46:50
-- @desc 延时函数调用
function Node:uniqueDelayFunc(name, delay, func)
    local actionTag = Helper:getOnlyId()
    local action = cc.Sequence:create(cc.DelayTime:create(delay), cc.CallFunc:create(
        function()
            AsyncFunction:asyncCall(func, self)
        end))
    action:setTag(actionTag)
    self:runActionWithName(name, action)
    return actionTag
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 暂停所有子节点
function Node:pauseSelfAndChildren()
    self:pause()    
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 恢复所有子节点
function Node:resumeSelfAndChildren()
    self:resume()
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 给所有子节点调用方法
function Node:callAllChild(func)
    local children = self:getChildren()
    for k, child in pairs(children) do
        func(child)
        child:callAllChild(func)
    end
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 设置所有子节点透明度是否级联变化
function Node:setSelfAndChildrenCascadeOpacityEnabled(b)
    self:setCascadeOpacityEnabled(b)
    self:callAllChild(
        function(child)
            child:setCascadeOpacityEnabled(b)
        end)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/06/21 21:42:15
-- @desc 设置所有子节点颜色是否级联变化
function Node:setSelfAndChildrenCascadeColorEnabled(b)
    self:setCascadeColorEnabled(b)
    self:callAllChild(
        function(child)
            child:setCascadeColorEnabled(b)
        end)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 级联透明度设置
function Node:setCascadeOpacity(opacity)
    self:setSelfAndChildrenCascadeOpacityEnabled(true)
    self:setOpacity(opacity)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/12/19 20:59:19
-- @desc 遍历取消按钮点击事件 (防止跨界面按钮的时间发生)
function Node:setSelfAndChildrenCancelButtonFunc()
    local children = self:getChildren()
    for k,v in ipairs(children) do
        v:setSelfAndChildrenCancelButtonFunc()
    end 
    if self.isTouchEnabled and self:isTouchEnabled() == true then
        self:setTouchEnabled(false)
        self:setTouchEnabled(true)
    end
end

-- add by XiaoZhiWei 2017/12/20 09:48:46 方法重载
Decorator:replace(Node, "setVisible",
function(funcName, func, self, bool)
    if bool == false then
        self:setSelfAndChildrenCancelButtonFunc()
    end
    return func(self, bool)
end)


-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/04/25 18:46:47
-- @desc 触摸事件注册
function Node:addTouchEventListener(touchBeganFunc, touchMovedFunc, touchEndedFunc)
    if touchBeganFunc == nil then
        touchBeganFunc = function(touch, event)
        end
    end

    if touchMovedFunc == nil then
        touchMovedFunc = function(touch, event)
        end
    end

    if touchEndedFunc == nil then
        touchEndedFunc = function(touch, event)
        end
    end

    local listenner = nil

    if device.platform == "windows" or true then
        -- 创建时间监听 add by TangJian 2017/04/25 18:45:43
        listenner = cc.EventListenerTouchOneByOne:create()

    	-- 注册按下事件 add by TangJian 2017/04/25 18:45:40
        listenner:registerScriptHandler(function(touch, event)
    		--print("onTouch x, y = ", touch:getLocation().x, touch:getLocation().y)
            return touchBeganFunc(touch, event)
        end, cc.Handler.EVENT_TOUCH_BEGAN)

    	-- 注册移动事件 add by TangJian 2017/04/25 18:45:53
        listenner:registerScriptHandler(function(touch, event)
    		--print("onTouchMoved x, y = ", touch:getLocation().x, touch:getLocation().y)
            touchMovedFunc(touch, event)
        end, cc.Handler.EVENT_TOUCH_MOVED)

    	-- 注册松开事件 add by TangJian 2017/04/25 18:46:04
        listenner:registerScriptHandler(function(touch, event)
            --print("onTouched x, y = ", touch:getLocation().x, touch:getLocation().y)
            touchEndedFunc(touch, event)
        end, cc.Handler.EVENT_TOUCH_ENDED)
    -- else
    --     listenner = cc.EventListenerTouchAllAtOnce:create()

    --     -- 注册按下事件 add by TangJian 2017/04/25 18:45:40
    --     listenner:registerScriptHandler(function(touchs, event)
    --         --print("onTouch x, y = ", touch:getLocation().x, touch:getLocation().y)
    --         return touchBeganFunc(touchs, event)
    --     end, cc.Handler.EVENT_TOUCHES_BEGAN)

    --     -- 注册移动事件 add by TangJian 2017/04/25 18:45:53
    --     listenner:registerScriptHandler(function(touchs, event)
    --         --print("onTouchMoved x, y = ", touch:getLocation().x, touch:getLocation().y)
    --         touchMovedFunc(touchs, event)
    --     end, cc.Handler.EVENT_TOUCHES_MOVED)

    --     -- 注册松开事件 add by TangJian 2017/04/25 18:46:04
    --     listenner:registerScriptHandler(function(touchs, event)
    --         --print("onTouched x, y = ", touch:getLocation().x, touch:getLocation().y)
    --         touchEndedFunc(touchs, event)
    --     end, cc.Handler.EVENT_TOUCHES_ENDED)
    end

	-- 添加时间监听到时间分发 add by TangJian 2017/04/25 18:46:29
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listenner, self)
end
00000