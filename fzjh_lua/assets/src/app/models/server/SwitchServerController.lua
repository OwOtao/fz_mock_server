local IS_ONLINE = true

local LOCAL_DATA_KEY = md5:getMd5("SwitchServerController")

local SwitchServerController = {
    -- server
    userInfo = {}, -- 用户信息 add by TangJian 2017/07/04 15:44:04
    serverList = {}, -- 分区信息 add by TangJian 2017/07/04 15:44:10
    selectServerName = "分区选择" -- 选择的分区名称 add by TangJian 2017/07/04 16:22:10
}

function SwitchServerController:create()
    local p = clone(SwitchServerController)
    p:init()
    return p
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/07/04 15:45:58
-- @desc 初始化
function SwitchServerController:init()
    self._refreshUIFM = FunctionManager:create()
end


-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/07/04 15:45:31
-- @desc 保存数据
function SwitchServerController:saveData()
    local version = GameChannelContext:getSwitchServerSaveDataVersion()
    DataBase:setLuaTable(LOCAL_DATA_KEY, self, version)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/07/04 19:00:50
-- @desc 添加ui刷新事件监听
function SwitchServerController:addUIRefreshFunc(func)
    self._refreshUIFM:addFunction(func)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/06/27 22:04:28
-- @desc 获得服务器列表
-- {"errcode":0,
-- 	"data":{
-- 		"list":[
-- 			{"id":1,"partision_name":"ios_ios","platform":"ios","channel":"ios"},
-- 			{"id":2,"partision_name":"ios_fzjh","platform":"ios","channel":"fzjh"}
-- 		],
-- 		"user":{"active_partision":0}
-- 	}
-- }
function SwitchServerController:updateServerList(callback)
    if IS_ONLINE then
        HttpManagerEx:getServerList2(
            function(status, errcode, errmsg, data)
                if status == 200 and errcode == 0 and type(data.list) == "table" then
                    -- 更新服务器列表 add by TangJian 2017/06/27 22:18:35
                    self:setServerList(data.list)

                    -- 更新user信息 add by TangJian 2017/06/27 22:19:55
                    self:setUserInfo(data.user)

                    callback("成功")
                    return true
                else
                    callback("失败", errmsg)
                end
            end,
            true
        )
    else
        local serverList = {
            {id = 1, partision_name = "ios_ios", platform = "ios", channel = "ios"},
            {id = 2, partision_name = "ios_fzjh", platform = "ios", channel = "fzjh"}
        }
        self:setServerList(serverList)

        local userInfo = {should_migrate = true, email = false, active_partision = 0}
        self:setUserInfo(userInfo)
        callback("成功")
    end
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/06/28 18:17:55
-- @desc 迁移服务器
function SwitchServerController:migrateToNewPackage(email, code, serverId, callback)
    if IS_ONLINE then
        local func = function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    callback("成功")
                else
                    callback("失败", errmsg)
                end
                return true
            else
                callback("失败", errmsg)
            end
        end

        HttpManagerEx:migrateToNewPackage2(email, code, serverId, func, IS_SHOW_WAITING, HTTP_MANAGER_RETRY_TYPE_RETRY)
    else
        callback("成功")
    end
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/06/28 22:58:48
-- @desc 切换服务器
function SwitchServerController:switchServer(serverId, callback)
    if IS_ONLINE then
        local func = function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    if data.msg ~= nil and data.msg ~= "" then
                        PopText(data.msg)
                    end

                    Game:setChannelId(self:getServerChannelIdByServerId(serverId))

                    if Game:isNeedNewEncript() == true then
                        local WaitingLayer = require("app.views.layer.PopLayer.WaitingLayer")
                        local waitingLayer = WaitingLayer:createInRunningScene()

                        --@desc 尝试次数
                        local tryhandshankcount = 0

                        local cbk

                        local conectResult = function(result)
                            tryhandshankcount = tryhandshankcount + 1

                            if tryhandshankcount > 5 then
                                if waitingLayer then
                                    waitingLayer:hideAndRemoveSelf()
                                end
                                callback("失败")
                                PopText("切换失败")
                                return
                            end

                            if result == "TRUE" then
                                -- 移除waitingLayer
                                if waitingLayer then
                                    waitingLayer:hideAndRemoveSelf()
                                end

                                -- add by XiaoZhiWei 2018/01/19 21:11:50 切换成功调用刷新一次token
                                HttpManagerEx:getToken(
                                    function(status, errcode, errmsg, data, isEncrypt)
                                        if status == 200 and errcode == 0 then
                                            T_TOKEN = Helper:getDef(data.token, "")
                                            callback("成功")
                                            return true
                                        end
                                    end,
                                    IS_SHOW_WAITING,
                                    HTTP_MANAGER_RETRY_TYPE_RETRY
                                )
                            else
                                if cbk then
                                    cbk()
                                else
                                    if waitingLayer then
                                        waitingLayer:hideAndRemoveSelf()
                                    end
                                end
                            end
                        end

                        -- 更新服务器密钥, 直到成功为止
                        cbk = function()
                            cpp.Game:getInstance():connectServer(
                                function(result)
                                    conectResult(result)
                                end
                            )
                        end

                        if SdkMethod.setUUID ~= nil then
                            SdkMethod:setUUID(data.uuid)
                        end
                        cbk()
                    else
                        -- add by XiaoZhiWei 2018/01/19 21:11:50 切换成功调用刷新一次token
                        HttpManagerEx:getToken(
                            function(status, errcode, errmsg, data, isEncrypt)
                                if status == 200 and errcode == 0 then
                                    T_TOKEN = Helper:getDef(data.token, "")
                                    return true
                                end
                            end,
                            IS_SHOW_WAITING,
                            HTTP_MANAGER_RETRY_TYPE_RETRY
                        )
                        callback("成功")
                    end

                    if device.platform == "windows" then
                        cc.UserDefault:getInstance():setStringForKey("WINDOWS_ID_FV_KEY", data.uuid)
                    end
                else
                    callback("失败")
                    PopText(errmsg)
                end
                return true
            end
        end

        Account:uploadUserDataWithoutSave(
            function(status)
                if status == "上传成功" then
                    DataBase:resetRoleData()
                    HttpManagerEx:switchServer2(serverId, func, IS_SHOW_WAITING, HTTP_MANAGER_RETRY_TYPE_RETRY)
                elseif status == "上传失败" then
                    Account:uploadAndDeleteUserData(
                        function(status)
                            if status == "上传并且删除存档成功" then
                                DataBase:resetRoleData()
                                HttpManagerEx:switchServer2(serverId, func, IS_SHOW_WAITING, HTTP_MANAGER_RETRY_TYPE_RETRY)
                            else
                                callback("失败")
                                PopText("切换失败")
                            end
                        end
                    )
                end
            end
        )
    else
        Game:setChannelId(serverId)
        callback("成功")
    end
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/06/27 22:20:48
-- @desc 设置服务器列表
function SwitchServerController:setServerList(list)
    self.serverList = {}
    for i, v in ipairs(list) do
        table.insert(
            self.serverList,
            {id = v.id, name = v.partition_title, desc = v.partition_desc, channel = v.channel, partition_name = v.partition_name, should_select_migrate = v.should_select_migrate}
        )
    end
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/06/28 17:03:49
-- @desc 得到服务器列表
function SwitchServerController:getServerList()
    return self.serverList
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/06/27 22:21:56
-- @desc 设置用户信息
-- "user":{"should_migrate":false,"email":false,"active_partision":0}
function SwitchServerController:setUserInfo(userInfo)
    -- self.userInfo.needInherit = Helper:getDef(userInfo.should_migrate, false)
    self.userInfo.email = Helper:getDef(userInfo.email, "")
    self.userInfo.activeServerId = Helper:getDef(userInfo.active_partition, 0)
    -- self.userInfo.needSelectInherit = Helper:getDef(userInfo.should_select_migrate, true)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/06/28 17:04:14
-- @desc 得到用户信息
function SwitchServerController:getUserInfo()
    return self.userInfo
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/06/29 16:30:21
-- @desc 得到通过服务器编号channelId
function SwitchServerController:getServerChannelIdByServerId(serverId)
    if self.serverList then
        for k, v in pairs(self.serverList) do
            if v.id == serverId then
                -- if Game:getPlatformId() == "android" then
                return v.partition_name
            -- end
            -- return v.channel
            end
        end
    end
    -- 如果没有 默认为 fzjh add by TangJian 2017/07/05 17:32:23
    return "fzjh"
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/06/29 16:25:37
-- @desc 得到当前服务器id
function SwitchServerController:getActiveServerName()
    if self.serverList and self.userInfo and self.userInfo.activeServerId then
        -- 兼容安卓
        for k, v in pairs(self.serverList) do
            if v.id == self.userInfo.activeServerId then
                return v.name
            end
        end
    end
end

function SwitchServerController:getActiveServerId()
    return self.userInfo.activeServerId
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/07/04 16:22:23
-- @desc 设置选择的分区名
function SwitchServerController:setSelectServerName(name)
    self.selectServerName = name
    self._refreshUIFM:callFunctions()
end

function SwitchServerController:setSelectServerId(id)
    self.userInfo.activeServerId = id

    self._refreshUIFM:callFunctions()
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/07/04 16:23:03
-- @desc 获得选择的分区名
function SwitchServerController:getSelectServerName()
    return self.selectServerName
end

function SwitchServerController:getCurrentServerName()
    local name = "分区选择"

    if self.serverList and self.userInfo and self.userInfo.activeServerId then
        -- 兼容安卓
        for k, v in pairs(self.serverList) do
            if v.id == self.userInfo.activeServerId then
                name = v.name
            end
        end
    end

    return name
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/06/27 22:35:33
-- @desc 打印成员变量
function SwitchServerController:printMember()
    print("userInfo:", luaTableEncode(self.userInfo))
    print("serverList:", luaTableEncode(self.serverList))
end

return SwitchServerController
00