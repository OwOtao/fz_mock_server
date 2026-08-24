local Connection = setmetatable({},
{
    __index = function(tb, key)
        return function()end
    end
})

local FightClient =
{
    _connection = nil, -- 连接
    _roles = {}, -- 角色列表
    _eventCallback = function()end, -- 回调方法
}

--服务器创建
function FightClient:create()
    local p = clone(FightClient)
    p:init()
    return p
end

--服务器初始化
function FightClient:init()
    self._connection = Connection
    self._roles = {}
    self._eventCallback = function()end

    -- 监听事件
    self._connection:addEventListener(function(params)
        local tb = json.decode(params.data)
        -- logt("FightClient EventListener", params)

        logt("title = " .. tostring(params.title) .. ", type = " .. tostring(tb.type) .. ", action = " .. tostring(tb.action), params)

        switch(params.title,
        {
            room = function()
                switch(tb.type,
                {
                    [TYPE_RESULT] = function()
                        switch(tb.action,
                        {
                            [CREATE] = function()
                                logt("创建房间成功", params)
                                self:callEventCallback("创建房间成功")
                            end,
                            [ENTER] = function()
                                logt("加入房间成功", params)
                                self:callEventCallback("加入房间成功")
                            end,
                            [USER_INFO] = function()
                                logt("上传角色数据成功", params)
                                self:callEventCallback("上传角色数据成功")
                            end,
                            [INFO] = function()
                                logt("获得房间数据成功", params)
                                print("tb.members count = " .. tostring(#tb.members))
                                for i, member in ipairs(tb.members) do
                                    logt("menber " .. i, member, ",\n member.info = ", member.info)
                                    local info = json.decode(member.info)
                                    self:callEventCallback("收到角色数据", info)
                                end
                                self:callEventCallback("获得房间数据成功")
                            end,
                            [READY] = function()
                                logt("准备完成", params)
                                self:callEventCallback("准备完成")
                            end,
                            default = function()
                                logt("FightClient", "收到未实现 action 事件: "..tostring(tb.action))
                            end
                        })
                    end,
                    [TYPE_SET] = function()
                        switch(tb.action,
                        {
                            [ALL_READY] = function()
                                logt("全都准备好了", params)
                                -- self:callEventCallback("全都准备好了")
                            end,
                            [USER_INFO] = function()
                                logt("收到角色数据", params, "\n")
                                for i, user in ipairs(tb.user) do
                                    local info = json.decode(user.info)
                                    logt("info", info)
                                    self:callEventCallback("收到角色数据", info)
                                end
                            end,
                            [START] = function()
                                logt("战斗开始", params)
                                self:callEventCallback("战斗开始")
                            end,
                            default = function()
                                logt("FightClient", "收到未实现 action 事件: "..tostring(tb.action))
                            end
                        })
                    end,
                    [TYPE_GET] = function()
                        switch(tb.action,
                        {
                            default = function()
                                logt("FightClient", "收到未实现 action 事件: "..tostring(tb.action))
                            end
                        })
                    end,
                    default = function()
                        logt("FightClient", "收到未实现 type 事件: "..tostring(tb.type))
                    end
                })
            end,
            fps = function()
                logt("收到主动招式", params)
                tb = json.decode(tb)
                self:callEventCallback("收到主动招式", tb.f, tb.rid, tb.zid)
            end,
            auto = function()
                -- logt("被动招式", params)
                tb = json.decode(tb)
                -- logt("tb type(tb) = " .. type(tb), tb)
                self:callEventCallback("收到被动招式", tb)
            end,
            default = function()
                logt("FightClient", "收到未实现 title 事件: "..tostring(params.title))
            end
        })
    end)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 设置事件监听
function FightClient:setEventCallback(eventCallback)
    self._eventCallback = Helper:getDef(eventCallback, function()end)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 调用时间监听方法
function FightClient:callEventCallback(...)
    self._eventCallback(...)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 创建房间
function FightClient:createRoom(roomName)
    self._connection:createRoom(roomName)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 加入房间
function FightClient:enterRoom(roomId)
    self._connection:enterRoom(roomId)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 上传角色数据
function FightClient:uploadRoles(roles)
    self._connection:sendUserInfo(roles)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 准备
function FightClient:ready()
    self._connection:ready()
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 得到房间信息
function FightClient:getRoomInfo()
    self._connection:getRoomInfo()
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 发送被动
function FightClient:sendAutoData(data)
    if type(data) == "table" then
        data = json.encode(data)
    end
    self._connection:sendAutoData(data)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 发送主动数据
function FightClient:sendActiveData(frame, data)
    if type(data) == "table" then
        data = json.encode(data)
    end
    self._connection:sendActiveData(frame, data)
end


-- 监控方法调用
Decorator:beforeAll(FightClient,
function(funcName, ...)
    logt("调用 FightClient 方法", "funcName = FightClient:"..tostring(funcName))
end)
return FightClient
0000000