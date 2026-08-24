local MessageCenter = {
    events = {}
}

--@desc:添加监听者
--@author:Seven_L
--@time:2020-03-10 11:24:23
--@m_type: {string} 消息类型
--@m_listener: {function} 监听回调
--@m_obj: 监听者
function MessageCenter:addListener(m_type, m_listener, m_obj)
    if m_type == nil or m_listener == nil or m_obj == nil then
        assert(false, "args is error!!")
    end

    if self.events[m_type] == nil then
        self.events[m_type] = {}
    end

    for i, v in ipairs(self.events[m_type]) do
        local listener = v[1]
        local obj = v[2]

        if listener == m_listener and obj == m_obj then
            error("this listener is already exits")

            return
        end
    end

    table.insert(self.events[m_type], {m_listener, m_obj})
end

--@desc: 移除监听
--@author:Seven_L
--@time:2020-03-10 11:19:17
--@m_type: {string} 消息类型
--@m_obj: {any} 监听对象
--@return
function MessageCenter:removeListener(m_type, m_listener, m_obj)
    local arr = self.events[m_type]
    if arr == nil or #arr == 0 or m_obj == nil then
        return
    end

    for i, v in ipairs(arr) do
        if v[1] == m_listener and v[2] == m_obj then
            table.remove(arr, i)

            if table.getn(arr) == 0 then
                self.events[m_type] = nil
            end

            return
        end
    end
end

--@desc: 移除某一对象的所有监听事件
--@author:Seven_L
--@time:2020-03-10 14:55:03
--@m_obj: 监听对象
function MessageCenter:removeObjListener(m_obj)
    if m_obj == nil then
        assert(false, "MessageCenter:removeObjListener  args is error!!")
    end
    for k, events in pairs(self.events) do
        for i = table.getn(events), 1, -1 do
            local event = events[i]
            if event[2] == m_obj then
                table.remove(events, i)
            end
        end

        if table.getn(events) == 0 then
            self.events[k] = nil
        end
    end
end

--@desc: 清除所有监听者
--@author:Seven_L
--@time:2020-03-10 14:44:36
--@return
function MessageCenter:clearAllListener()
    for k, v in pairs(self.events) do
        self.events[k] = nil
    end
end

--@desc: 消息通知
--@author:Seven_L
--@time:2020-03-10 14:51:00
--@m_type: 消息类型
--@args: 自定义参数
function MessageCenter:notify(m_type, ...)
    local arr = self.events[m_type]

    if MapIsEmpty(arr) == true then
        return
    end

    for i, v in ipairs(arr) do
        v[1](...)
    end
end

--@region 测试用例
local TestMessageCase = {
    notifyTest = function()
        MessageCenter:clearAllListener()
        local obj = {
            a = "a"
        }

        local function listener(str)
            obj.a = str
        end

        MessageCenter:addListener("chang_a", listener, obj)

        local s = "ccccccccccc"
        MessageCenter:notify("chang_a", s)

        assert(obj.a == s, "notifyTest is wrong")

        print("notifyTest successful")

        MessageCenter:clearAllListener()
    end,
    addListenerTest = function()
        MessageCenter:clearAllListener()
        local obj = {
            a = "a"
        }

        local function listener(str)
            obj.a = str
        end

        MessageCenter:addListener("chang_a", listener, obj)

        local event = MessageCenter.events["chang_a"][1]

        assert(event[1] == listener and event[2] == obj, "add listener wrong")

        print("addListenerTest successful")

        MessageCenter:clearAllListener()
    end,
    removeListenerTest = function()
        MessageCenter:clearAllListener()
        
        local obj = {
            a = "a"
        }

        local function listener(str)
            obj.a = str
        end

        MessageCenter:addListener("chang_a", listener, obj)

        MessageCenter:removeListener("chang_a", listener, obj)

        assert(MapIsEmpty(MessageCenter.events) == true, "removeListener is wrong")

        print("removeListenerTest successful")
    end,
    removeObjListenerTest = function()
        MessageCenter:clearAllListener()
        local obj = {a = "a", b = "b"}

        local function listenerA(str)
            obj.a = str
        end

        local function listenerB(str)
            obj.b = str
        end

        MessageCenter:addListener("chang_a", listenerA, obj)

        MessageCenter:addListener("chang_b", listenerB, obj)

        MessageCenter:removeObjListener(obj)

        assert(MapIsEmpty(MessageCenter.events) == true, "removeObjListenerTest is wrong")

        print("removeObjListenerTest successful")
    end
}

--@desc: 测试
--@author:Seven_L
--@time:2020-03-10 16:14:36
function MessageCenter:testCase()
    for k, v in pairs(TestMessageCase) do
        v()
    end
end
--@endregion 


return MessageCenter
000000000000