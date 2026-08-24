-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 账户
local Account = class("Account",
    {
        _gameInfo = {},
        _uploadTime = 0,
    })

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 测试
function Account:test()
    Account:createAccount(
        function(eventName)
            print(eventName)
        end)
end


function Account:ctor()
end

function Account:getGameInfo()
    return Helper:getDef(clone(self._gameInfo), {})
end

function Account:getUploadTime()
    return self._uploadTime
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 创建账户流程
function Account:createAccount(callback)
    callback = Helper:getDef(callback, function() end)
    
    local userid = 0 -- 用户id
    -- 判断本地是否有存档
    local roleData = DataBase:getRoleData()
    if type(roleData) == "table" then
        if type(roleData.userid) == "number" then
            if roleData.userid > 0 then
                userid = roleData.userid
            else
                userid = -1 -- 有存档, 但是userid无效 赋值为 -1
            end
        else
            userid = -1 -- 有存档, 但是userid无效 赋值为 -1
        end
    else
        userid = 0 -- 没存档 uerid 赋值为 0
    end
    
    
    -- print("userid = " .. tostring(userid))
    
    -- 请求服务器创建帐号
    HttpManagerEx:createAccount(userid,
        function(status, errcode, errmsg, data)
            if status == 200 then
                local eventName
                if errcode == 0 then
                    eventName = "开始游戏"
                elseif errcode == 1 then
                    eventName = "上传并删除档案"
                elseif errcode == 2 then
                    eventName = "覆盖档案"
                elseif errcode == 201 then
                    eventName = "公告展示"
                else
                    eventName = errcode
                end
                if PRINT_MODE == 1 then
                    print("eventName = " .. tostring(eventName))
                end
                callback(eventName, errmsg, data)
                return true
            end
        end, IS_SHOW_WAITING, HTTP_MANAGER_RETRY_TYPE_RETRY)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 上传存档
function Account:uploadUserData(callback,isNeedWait,isNeedRetry)
    callback = Helper:getDef(callback, EMPTY_FUNC)

    self:__uploadUserData("Account",function(status, errcode, errmsg, data, isEncrypted)
        if status == 200 then
            if errcode == 0 then
                callback("上传成功")
                -- print("上传成功")
                self._uploadTime = GetTime()
            else
                callback("上传失败")
                -- print("上传失败")
            end
            return true
        end
    end, isNeedWait, isNeedRetry)
end

function Account:__uploadUserData(protocol , callback , isNeedWait , isNeedRetry)
    if protocol == nil or type(protocol) ~= "string" then
        error("Account:__uploadUserData : protocol is error : " .. tostring(protocol))
    end

    callback = Helper:getDef(callback, EMPTY_FUNC)

    if isNeedWait == false then
        isNeedWait = nil
    else
        isNeedWait = IS_SHOW_WAITING
    end

    if isNeedRetry == false then
        isNeedRetry = nil
    else
        isNeedRetry = HTTP_MANAGER_RETRY_TYPE_RETRY
    end
    
    HttpManagerEx:uploadUserData(protocol, callback, isNeedWait, isNeedRetry)
end

--@desc: 点击开始游戏时上传存档
--@author:LvBin
--@time:2024-01-24 10:54:50
--@callback:
--@isNeedWait:
--@isNeedRetry: 
--@return
function Account:startGameUpload(callback)
    callback = Helper:getDef(callback, EMPTY_FUNC)
    self:__uploadUserData("kaishi",
        function(status, errcode, errmsg, data, isEncrypted)
            
            if status == 200 then
                if errcode == 0 then
                    if data.dataVer ~= nil then
                        User:getRole():getServerActionSystem():setDataVersion(data.dataVer)
                    end
                    callback("上传成功")
                    self._uploadTime = GetTime()
                else
                    callback("上传失败" , errcode, errmsg)

                    return false
                end
                return true
            end
        end, IS_SHOW_WAITING, HTTP_MANAGER_RETRY_TYPE_RETRY)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/07/06 16:57:55
-- @desc 上传存档不保存
function Account:uploadUserDataWithoutSave(callback)
    callback = Helper:getDef(callback, EMPTY_FUNC)
    
    HttpManagerEx:uploadUserDataWithoutSave("Account",
        function(status, errcode, errmsg, data, isEncrypted)
            
            if status == 200 then
                if errcode == 0 then
                    callback("上传成功")
                    -- print("上传成功")
                else
                    callback("上传失败")
                    -- print("上传失败")
                end
                return true
            end
        end, IS_SHOW_WAITING, HTTP_MANAGER_RETRY_TYPE_RETRY)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 上传无用存档并删除存档
function Account:uploadAndDeleteUserData(callback)
    callback = Helper:getDef(callback, function() end)
    
    local roleData, data = DataBase:getRoleData()
    if roleData == nil then
        roleData = data  -- 直接将文件内保存的内容,复制给RoleData并且上传
    end
    HttpManagerEx:uploadUselessUserData(roleData,
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    Account:deleteLocalData()
                    callback("上传并且删除存档成功", errmsg)
                else
                    callback("上传并且删除存档失败", errmsg)
                end
                return true
            end
        end, IS_SHOW_WAITING, HTTP_MANAGER_RETRY_TYPE_RETRY)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 下载存档
function Account:downloadUserData(callback)
    -- print("下载档案")
    
    callback = Helper:getDef(callback, function() end)
    
    HttpManagerEx:downloadUserDataTang(
        function(status, errcode, errmsg, data)
            -- print("status = " .. tostring(status))
            -- print("errcode = " .. tostring(errcode))
            -- print("data = " .. tostring(data))
            if status == 200 then
                if errcode == 0 then
                    local roleData = data
                    if PRINT_MODE == 1 then
                        print("type(roleData) = "..tostring(type(roleData)))
                        print("roleData = "..luaTableEncode(roleData))
                        print("roleData[1] = "..luaTableEncode(roleData[1]))
                    end
                    callback("有存档", roleData[1], errmsg)
                elseif errcode == 2 then
                    PopText(errmsg)
                    callback("频繁下载")
                else
                    callback("无存档", nil, errmsg)
                end
                return true
            end
        end, IS_SHOW_WAITING, HTTP_MANAGER_RETRY_TYPE_RETRY)
end

--获取设备的绑定信息
function Account:getBindInfo(callback)
    callback = Helper:getDef(callback, EMPTY_FUNC)
    
    HttpManagerEx:getBindInfo(
    function(status, errcode, errmsg, data)
        if status == 200 then
            data.is_logout = switch(data.is_logout, {[0] = false, default = true})
            data.is_bind = switch(data.is_bind, {[0] = false, default = true})
            if errcode == 0 then
                if data.email and data.email ~= "0" then
                    callback("有邮箱", errmsg, data.email, data.phone, data.is_bind, data.is_logout)
                else 
                    callback("未绑定", errmsg, data.email, data.phone, data.is_bind, data.is_logout)
                end
                if data.phone and data.phone ~= 0 then
                    callback("有手机号", errmsg, data.email, data.phone, data.is_bind, data.is_logout)
                else  
                    callback("没手机号", errmsg, data.email, data.phone, data.is_bind, data.is_logout)
                end
                --data.auth 测试服权限
                if data.auth and data.auth ~= 0 then
                    callback("内测邮箱认证", errmsg, data.email, data.phone, data.is_bind, data.is_logout, data.auth)
                else
                    callback("内测邮箱未认证", errmsg, data.email, data.phone, data.is_bind, data.is_logout)
                end
            elseif errcode == 1 then
                callback("找不到帐号", errmsg, data.email, data.phone, data.is_bind, data.is_logout)
            else
                callback("异常", errmsg, data.email, data.phone, data.is_bind, data.is_logout)
            end
            return true
        end
    end, IS_SHOW_WAITING, HTTP_MANAGER_RETRY_TYPE_RETRY)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 获得设备绑的email
function Account:getEmail(callback)
    callback = Helper:getDef(callback, EMPTY_FUNC)

    -- add by XiaoZhiWei 2019/02/27 18:03:42 当开启检查的时候,邮箱绑定模拟成已绑定
    if Game:isCheckNewPackage() == NEED_CHECK_AND_IS_OPEN then
        callback("有邮箱", "", "", true, false)
        return
    else
        HttpManagerEx:getEmailTang(
        function(status, errcode, errmsg, data)
            if status == 200 then
                data.is_logout = switch(data.is_logout, {[1] = true, default = false})
                data.is_bind = switch(data.is_bind, {[1] = true, default = false})
                if errcode == 0 then
                    callback("有邮箱", errmsg, data.email, data.is_bind, data.is_logout)
                elseif errcode == 1 then
                    callback("找不到帐号", errmsg, data.email, data.is_bind, data.is_logout)
                else
                    callback("无邮箱", errmsg, data.email, data.is_bind, data.is_logout)
                end
                return true
            end
        end, IS_SHOW_WAITING, HTTP_MANAGER_RETRY_TYPE_RETRY)
    end
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 登录
-- send_email
-- request
-- event_type 验证码类型 1绑定, 2登入, 3=登出
-- {"event_type": 1, "email": "1112@qq.com"}
-- response
-- 30分钟过期时间
-- {"errcode":0, "data":{"expired_time": TIMESTAMP}}

function Account:sendVerifyCode(sendType, sendKey, eventType, callback)
    callback = Helper:getDef(callback, EMPTY_FUNC)
    
    -- 类型转换
    eventType =
        switch(eventType,
            {
                ["绑定"] = 1,
                ["登录"] = 2,
                ["登出"] = 3,
                ["继承"] = 4,
                default = eventType
            })
    
    -- print("email = " .. tostring(email))
    -- print("eventType = " .. tostring(eventType))
    HttpManagerEx:sendVerifyCode(sendType, sendKey, eventType,
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    local expired_time = data.expired_time
                    callback("发送成功", expired_time, errmsg)
                    -- print("发送成功 expired_time = " .. tostring(expired_time))
                else
                    callback("发送失败", expired_time, errmsg)
                    -- print("发送失败")
                end
                return true
            end
        end, IS_SHOW_WAITING, HTTP_MANAGER_RETRY_TYPE_RETRY)
end

function Account:sendEmail(event_type, email, callback)
    callback = Helper:getDef(callback, EMPTY_FUNC)
    
    -- 类型转换
    event_type =
        switch(event_type,
            {
                ["绑定"] = 1,
                ["登录"] = 2,
                ["登出"] = 3,
                ["继承"] = 4,
                default = event_type
            })
    
    -- print("email = " .. tostring(email))
    -- print("event_type = " .. tostring(event_type))
    HttpManagerEx:sendEmailTang(email, event_type,
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    local expired_time = data.expired_time
                    callback("发送成功", expired_time, errmsg)
                    -- print("发送成功 expired_time = " .. tostring(expired_time))
                else
                    callback("发送失败", expired_time, errmsg)
                    -- print("发送失败")
                end
                return true
            end
        end, IS_SHOW_WAITING, HTTP_MANAGER_RETRY_TYPE_RETRY)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 登录
function Account:loginDevice(email, verify_code, callback)
    callback = Helper:getDef(callback, EMPTY_FUNC)
    
    HttpManagerEx:loginDevice(email, verify_code,
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    callback("登录成功", errmsg)
                else
                    callback("登录失败", errmsg)
                end
                return true
            end
        end, IS_SHOW_WAITING, HTTP_MANAGER_RETRY_TYPE_RETRY)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 登出
function Account:logoutDevice(email, verify_code, callback)
    callback = Helper:getDef(callback, EMPTY_FUNC)
    
    Account:uploadUserData(
        function(eventName, errmsg)
            if eventName == "上传成功" then
                
                HttpManagerEx:logoutDevice(email, verify_code,
                    function(status, errcode, errmsg, data)
                        if status == 200 then
                            if errcode == 0 then
                                callback("登出成功", errmsg)
                            else
                                callback("登出失败", errmsg)
                            end
                            return true
                        end
                    end, IS_SHOW_WAITING, HTTP_MANAGER_RETRY_TYPE_RETRY)
            
            else
                callback("登出失败", errmsg)
            end
        end)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 登出 没有绑定邮箱的设备
function Account:logoutUnbindDevice(callback)
    callback = Helper:getDef(callback, EMPTY_FUNC)
    
    Account:uploadUserData(
        function(eventName, errmsg)
            if eventName == "上传成功" then
                
                HttpManagerEx:logoutUnbindDevice(
                    function(status, errcode, errmsg, data)
                        if status == 200 then
                            if errcode == 0 then
                                callback("登出成功", errmsg)
                            else
                                callback("登出失败", errmsg)
                            end
                            return true
                        end
                    end, IS_SHOW_WAITING, HTTP_MANAGER_RETRY_TYPE_RETRY)
            
            else
                callback("登出失败", errmsg)
            end
        end)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 不保存登出
function Account:logoutDeviceWithoutSave(email, verify_code, callback)
    callback = Helper:getDef(callback, EMPTY_FUNC)
    
    Account:uploadUserDataWithoutSave(
        function(eventName, errmsg)
            if eventName == "上传成功" then
                
                HttpManagerEx:logoutDevice(email, verify_code,
                    function(status, errcode, errmsg, data)
                        if status == 200 then
                            if errcode == 0 then
                                callback("登出成功", errmsg)
                            else
                                callback("登出失败", errmsg)
                            end
                            return true
                        end
                    end, IS_SHOW_WAITING, HTTP_MANAGER_RETRY_TYPE_RETRY)
            
            else
                callback("登出失败", errmsg)
            end
        end)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 不保存登出 没有绑定邮箱的设备
function Account:logoutUnbindDeviceWithoutSave(callback)
    callback = Helper:getDef(callback, EMPTY_FUNC)
    
    Account:uploadUserDataWithoutSave(
        function(eventName, errmsg)
            if eventName == "上传成功" then
                
                HttpManagerEx:logoutUnbindDevice(
                    function(status, errcode, errmsg, data)
                        if status == 200 then
                            if errcode == 0 then
                                callback("登出成功", errmsg)
                            else
                                callback("登出失败", errmsg)
                            end
                            return true
                        end
                    end, IS_SHOW_WAITING, HTTP_MANAGER_RETRY_TYPE_RETRY)
            
            else
                callback("登出失败", errmsg)
            end
        end)
end

-- 获取服务器角色相关数据
function Account:getGameUserInfo(callback)
    callback = Helper:getDef(callback, EMPTY_FUNC)

    local currencyVersion = User:getRole():getCurrencyVersion()

    if not currencyVersion then
        local WaitingLayer = require("app.views.layer.PopLayer.WaitingLayer")
        local waitingLayer = WaitingLayer:createInRunningScene()
        waitingLayer:setText("获取角色相关数据版本异常，请联系客服。")
        return
    end

    HttpManagerEx:getGameUserInfo(Helper:getDef(User:getRoleAttr("notice_version"), 0), currencyVersion, function(status, errcode, errmsg, data)
        if status == 200 then
            if errcode == 0 then
                self._gameInfo = data
                callback("获取成功", data, errmsg)
                return true
            else
                callback("获取失败", nil, errmsg)
            end
        end
    end, IS_SHOW_WAITING, HTTP_MANAGER_RETRY_TYPE_RETRY)
end

--@desc: 跳转到账号注销网页
--@author:LvBin
--@time:2023-12-08 11:56:34
--@callback: 
--@return
function Account:gotoLogoutAccountWeb(callback)
    callback = Helper:getDef(callback, EMPTY_FUNC)

    Account:uploadUserData(
        function(eventName, errmsg)
            if eventName == "上传成功" then
                HttpManagerEx:getLogoutAccountUrl(
                    function(status, errcode, errmsg, data)
                        if status == 200 then
                            if errcode == 0 then
                                User:deleteRole()
                                cc.UserDefault:getInstance():deleteValueForKey("userid")
                                callback(true, errmsg, data)
                            else
                                callback(false, errmsg)
                            end
                            return true
                        end
                    end,
                    IS_SHOW_WAITING,
                    HTTP_MANAGER_RETRY_TYPE_RETRY
                )
            else
                callback(false, errmsg)
            end
        end
    )
end

--@desc:删除本地存档
--@time:2023-12-08 11:56:34
function Account:deleteLocalData()
    User:deleteRole()
    cc.UserDefault:getInstance():deleteValueForKey("userid")
end

return Account:create()
0000