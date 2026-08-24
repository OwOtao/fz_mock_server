local LogSystem = require("app.models.LogSystem.LogSystem")
local waitTexts = require("script.others.serverPrompts")["提示语"]
--[[
	http 请求部分逻辑
]]
local WaitingLayer = require("app.views.layer.PopLayer.WaitingLayer")
local Http = {}

local Request = require("third.http.Request")

-- local DOMAIN
if string.find(Game:getDomain(), "1713") then
    DOMAIN = string.gsub(Game:getDomain(), "1713", "1706") .. "api/v5/"
elseif string.find(Game:getDomain(), "1702") then
    if Game:getPlatformId() == "android" then
        DOMAIN = string.gsub(Game:getDomain(), "1702", "1712") .. "api/v5/"
    else
        DOMAIN = string.gsub(Game:getDomain(), "1702", "1706") .. "api/v5/"
    end
else
    DOMAIN = Game:getDomain() .. "api/v5/"
end

-- add by XiaoZhiWei 2018/01/10 16:21:56 安卓1.4.0 请求地址替换
if Game:getPlatformId() == "android" and Game:getVersion() == "1.4.0" then
    if Game:isTesting() == true then
    else
        DOMAIN = string.gsub(DOMAIN, "http://fzjh.api.helloyanming.com:1706/", "http://fzjh.android.helloyanming.com/")
    end
end


-- -- 服务器切换
-- if string.find(DOMAIN, "fzjh.test.helloyanming.com") then
--     DOMAIN = string.gsub(DOMAIN, "fzjh.test.helloyanming.com", "fzjh.test.xiaohoutiaotiao.com")
-- end
-- -- if string.find(DOMAIN, "fzjh.test.xiaohoutiaotiao.com") then
-- DOMAIN = "http://fzjh.test.xiaohoutiaotiao.com:9901/api/v5/"
-- -- end

-- local PRINT_MODE = 1

-- -- DOMAIN = string.gsub(DOMAIN, "1706", "9004")

local localTime = 0

-- 初始化时间戳
--[[
1 同一帧内不能出现两次相同的时间戳
2 使用最新的时间戳 
]]
function Http:setWebTime(time)
    if PRINT_MODE == 1 then
        print("time = "..time)
    end
    localTime = time
end

function Http:updateWebTime()
    localTime = localTime + 0.0001
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2016/11/14 11:10:58
-- @desc 获取随机nouce 以及加密 sig
function Http:getNouceAndSig(time)
    local nouce = ""
    for i = 1, 6 do
        local index = math.random(65, 122)
        while (index > 90 and index < 97) or index == 101 do
            index = math.random(65, 122)
        end
        nouce = nouce..string.char(index)
    end
    local sig = YXHelper:doMd5ForHttpRequest(nouce, time)
    if PRINT_MODE == 1 then
        print("sig = "..tostring(sig))
        print("nouce = "..tostring(nouce))
    end
    return nouce, sig
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2016/11/14 11:12:01
-- @desc 获取解密response数据,不存在返回nil
function Http:getDecyptResponse(response)
    if response == nil or string.len(response) <= 0 then
        User:getRole():addUrlResoponseInfo(url, localTime, status)
        return nil, "得到数据为空,请重新获取数据"
    end

    -- local responseData = json.decode(JMForLua:decrypt(response))
    -- if MapIsEmpty(responseData) == true then
    --     User:getRole():addUrlResoponseInfo(url, localTime, status)
    --     return nil, "数据异常,无法解析请联系客服人员"
    -- end
    return JMForLua:decrypt(response)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2016/11/25 11:50:42
-- @desc 获取解密的response数据并且检查是否作弊,
function Http:getDecyptResponseWithCheckCheat(url, response, status, request)
    -- add by XiaoZhiWei 2018/01/18 18:01:09 暂时关闭sig校验
    if status ~= 200 then
        -- 网络异常情况
        return nil, "网络连接失败,请检查网络是否正常"
    else
        -- add by XiaoZhiWei 2018/06/14 20:37:19 华为和测试服不需要验证签名
        if Game:getChannelId() == "huawei" or Game:isTesting() == true then
            return response
        end

        if string.find(url, "get_time") or string.find(url, "get_token") or string.find(url, "report_cheat") or string.find(url, "getWebConfig") then
            return response
        end

        -- add by XiaoZhiWei 2018/01/19 16:16:44 校验sig
        local head = request:getAllResponseHeaders()
        local list = string.split(head, "\n")
        local map = {}
        for i,v in ipairs(list) do
            if string.len(v) > 0 then
                local vList = string.split(v, ": ")
                local value = string.gsub(vList[2], " ", "")
                value = string.gsub(value, "\n", "")
                value = string.gsub(value, "\r", "")
                map[string.lower(vList[1])] = value
            end
        end

        if T_TOKEN == "" then
            Collection:addProxyRecord(User:getUserId(), "porxy.TokenIsNull."..tostring(url), 0, 0)
            Collection:uploadProxy()
            return [[{"errcode":1001}]]
        end
        if map["time"] == nil or map["nonce"] == nil or map["signature"] == nil then
            Collection:addProxyRecord(User:getUserId(), "porxy.HeaderError."..tostring(url), 0, 0)
            Collection:uploadProxy()
            return [[{"errcode":1002}]]
        end
        local sigList = {map["time"], map["nonce"], response, T_TOKEN}
        local localSig = md5:getMd5(table.concat(sigList, "&"))
        if PRINT_MODE == 1 then
            print(map["signature"], ":",  map["time"],":", map["nonce"],":", response, ":", T_TOKEN, ":", localSig, ":", map["signature"] == localSig)
        end
        if map["signature"] == localSig then
            return response
        else
            Collection:addProxyRecord(User:getUserId(), "porxy.SigError."..tostring(url), 0, 0)
            Collection:uploadProxy()
            return [[{"errcode":1003}]]
        end
    end
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2016/11/14 11:49:21
-- @desc 设置头信息
local function  getHeaders(headers)
    local time = localTime
    -- 得到nouce and sig
    local nouce, sig = Http:getNouceAndSig(time)

    local version = Game:getHotVersion()
    if string.find(DOMAIN, "http://fzjh.test.helloyanming.com") or string.find(DOMAIN, "http://fzjh.test.xiaohoutiaotiao.com") then
        version = 100000
    end

    -- 默认头
    local sendHeaders =
        {
            uuid = Game:getIdfv(),
            userid = User:getUserId(),
            sig = sig,
            time = time,
            nouce = nouce,
            device = Game:getDevInfo(),
            ver = Game:getVersion(),
            hotver = version,
            platform = Game:getPlatformId(),
            timezone = Helper:mathFloor((28800 - Helper:getTimeZone()) / 3600),
            channel = Game:getChannelId(),
            package = Game:getPackageId(),
            age = AGE,
        }

    if Game:getPlatformId() == "android" then
        sendHeaders.pkname = SdkMethod:getPackageName()
        sendHeaders.pksig = SdkMethod:getSignature()
    end


    -- 覆盖头
    for k, v in pairs(Helper:getDef(headers, {})) do
        sendHeaders[k] = v
    end

    -- 设置头
    for k, v in pairs(sendHeaders) do
        if PRINT_MODE == 1 then
            print("Headers["..k.."]= "..tostring(v))
        end
    end
    return sendHeaders
end

-- 判断返回的data是否有加密处理
local function checkDataIsEncrypted(data)
    if data == nil then return nil end
    return data ~= JMForLua:decrypt(data) -- 解密前后的文本内容不相等,则是加密过的数据
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2016/11/14 18:54:24
-- @desc 对Post请求数据进行加密处理
function Http:encryptPostData(data, isNeedEncrypt)
    -- 如果数据是空的则不需要加密处理了
    if data ~= nil and isNeedEncrypt == true then
        if Game:isNeedNewEncript() == true then
             -- 只有外侧服1.1 和 1.2 两个版本仍在使用xxtea加密，其余正在维护的版本均已使用aes加密算法
            if (Game:getChannelId() == "test" and (Game:getVersion() == "1.1" or Game:getVersion() == "1.2")) then
                return JMForLua:encrypt(data, 1)
            else
                return JMForLua:encrypt(data, "FZJH03")
            end
        else
            return JMForLua:encrypt(data)
        end
    else
        return data
    end
end

function Http:send(doType, url, sendData, headers, callback, isNeedWait, isNeedEncrypt)
    LogSystem:log("http:send:", doType, url, sendData, headers, callback, isNeedWait, isNeedEncrypt)
    
    self:updateWebTime() -- 刷新时间

    isNeedWait = Helper:getDef(isNeedWait, false) -- 等待默认为false
    -- 检查url是否齐全
    if string.find(url, DOMAIN) == nil and string.find(url, "api/service_ios/") == nil and string.find(url, "api/service/") == nil and string.find(url, "api/service_android/") == nil then
        url = DOMAIN..url
    end

    -- 请求处理开始
    if PRINT_MODE == 1 then
        print("toUrl = "..tostring(toUrl))
    end

     -- 发送请求
     local tmpSendData = sendData
     if type(tmpSendData) == "table" then
         tmpSendData = json.encode(tmpSendData)
     else
         tmpSendData = tostring(tmpSendData)
     end
 
     if PRINT_MODE == 1 then
         print("加密前 = "..tmpSendData)
     end

     --加密处理
    tmpSendData = self:encryptPostData(tmpSendData ,isNeedEncrypt)
    if PRINT_MODE == 1 then
        print("加密后 = "..tmpSendData)
    end

    -- 创建请求
    local request = Request:create()
    :setUrl(url)
    :setMethod(doType)
    :setHeaders(getHeaders(headers))
    :setPostData(tmpSendData)
    :setResponseCallback(function(status, response, request)
        -- 校验response 
        if string.find(url, "upload_error_msg") ~= nil or string.find(url, "upload_user_file_5/fankui") ~= nil then
        else
            local text = nil
            response, text = self:getDecyptResponseWithCheckCheat(url, response, status, request)
        end
        response = Helper:getDef(response, "")
        
        if PRINT_MODE == 1 then
            print("response:"..tostring(response))
            print("Decyptresponse:"..tostring(response))
            print("status:"..tostring(status))
            print( "url = "..url )
        end

        if callback then
            callback(response, status)
        end

        request:release()
    end):send()
end

function Http:retryWithHeader(waitText, doType, url, sendData, headers, callback, isNeedWait, retryType, isNeedEncrypt)
    Game:addBlockAsyncFunc("retryWithHeader" .. url, function()
        local waitingLayer = WaitingLayer:createInRunningScene()
        waitingLayer:setText(waitText or "请稍后...")
    
        local isFinished = false

        if PRINT_MODE == 1 then
            print("url = "..tostring(url))
        end

        -- 记录局部变量的table
        local localTable = {}


        if doType == "post" then
            isNeedEncrypt = Helper:getDef(isNeedEncrypt, NEED_ENCRYPT)
        else
            isNeedEncrypt = false -- add by XiaoZhiWei 2018/09/19 18:37:04 原有的版本get请求没有这个参数,所以传递false
        end
        -- 发送请求
        function localTable.doSend()
            local isFinished = false
            local callbackParams = {}
            local callback = function(response, status)
                callbackParams.response = response
                callbackParams.status = status
                isFinished = true
            end
            self:send(doType, url, sendData, headers, callback, isNeedWait, isNeedEncrypt)

            while isFinished == false do
                coroutine.yield()
            end
            
            waitingLayer:hideAndStopAction()
            localTable.callback(callbackParams.response, callbackParams.status)
        end

        -- 重试方法
        function localTable.callback(...)
            if retryType == nil or retryType == 0 then
                callback(...)
                isFinished = true
                return
            end
            -- 返回值如果为true 才会隐藏
            local notNeedRetry, status, errcode = callback(...)
            if not notNeedRetry then
                if retryType == HTTP_MANAGER_RETRY_TYPE_RETRY then
                    local buttonPopLayer = ButtonPopLayer:createCustomInRunningScene("网络错误, 请重试", "重试",
                        function()
                        end)
                    buttonPopLayer:setErrorText(string.gsub(url, DOMAIN, "") .. ";" .. tostring(status) .. ";" .. tostring(errcode))
                    
                    -- 获取按钮事件
                    local touchEventType = nil
                    repeat
                        touchEventType = buttonPopLayer:getButton1CurrTouchEvent()
                        coroutine.yield()
                    until touchEventType == ccui.TouchEventType.ended
                    
                    -- 按钮事件为松开，移除重试界面并且再次请求
                    buttonPopLayer:hideAndRemoveSelf()
                    localTable.doSend()
                elseif retryType == HTTP_MANAGER_RETRY_TYPE_RETRY_CANCEL then
                    local buttonPopLayer = ButtonPopLayer:createCustomInRunningScene("网络错误, 请重试", "重试",
                        function()
                            localTable.doSend()
                        end,
                        "取消",
                        function()
                            isFinished = true
                        end)
                    buttonPopLayer:setErrorText(string.gsub(url, DOMAIN, "") .. ";" .. tostring(status) .. ";" .. tostring(errcode))
                else
                    local buttonPopLayer = ButtonPopLayer:createCustomInRunningScene("网络错误, 请重试", "重试",
                        function()
                        end)
                    buttonPopLayer:setErrorText(string.gsub(url, DOMAIN, "") .. ";" .. tostring(status) .. ";" .. tostring(errcode))

                    -- 获取按钮事件
                    local touchEventType = nil
                    repeat
                        touchEventType = buttonPopLayer:getButton1CurrTouchEvent()
                        coroutine.yield()
                    until touchEventType == ccui.TouchEventType.ended

                    -- 按钮事件为松开，移除重试界面并且再次请求
                    buttonPopLayer:hideAndRemoveSelf()
                    localTable.doSend()
                end
            else
                isFinished = true
            end
        end
        -- 请求网络
        localTable.doSend()

        while isFinished == false do
            coroutine.yield()
        end

        waitingLayer:hideAndRemoveSelf()
    end)
end

local requestId = 1
-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 可重试, 带头 post请求       增加一个是否加密的参数 isNeedEncrypt 传true，对sendData加密
function Http:retryPostWithHeader(...)
    self:retryWithHeader("请稍后...", "post", ...)
end

--[[
    @desc: 可重试, 带头 带等待文本的post请求
    author:TangJian
    time:2022-03-15 14:37:36
    --@waitText:
	--@args: 
    @return:
]]
function Http:retryPostWithHeaderAndWaitText(waitText, ...)
    self:retryWithHeader(waitText, "post", ...)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 可重试, 带头 get请求
function Http:retryGetWithHeader(...)
    self:retryWithHeader("请稍后...", "get", ...)
end

--[[
    @desc: 可重试, 带头,带等待文本的get请求
    author:TangJian
    time:2022-03-15 14:36:33
    --@waitText:
	--@args: 
    @return:
]]
function Http:retryGetWithHeaderAndWaitText(waitText, ...)
    self:retryWithHeader(waitText, "get", ...)
end

----------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 网络请求返回值处理方法
function Http:createGetResponseFunction(func)
    local function proxyFunc(response, status)
        -- 使用xpcall捕获打印异常 add by TangJian 2016/11/04 10:04:09
        local success, arg1, arg2, arg3, arg4, arg5 = xpcall(function()
            local responseData = nil
            if status == 200 then
                if checkDataIsEncrypted(response) == true then
                    responseData = json.decode(JMForLua:decrypt(response))-- 对response进行解密 add by TangJian 2016/11/04 10:03:57
                else
                    PopText("请公平公正的参与游戏")
                    responseData = json.decode(JMForLua:decrypt(response))
                    return  false, status, responseData.errcode
                end
            else
                PopText("网络连接失败, 请检查网络是否正常")
            end
            responseData = Helper:getDef(responseData, {})
            if PRINT_MODE == 1 then
            	print("response : ", JMForLua:decrypt(response))
            end
            local isEncrypted = nil -- 判断是否有加密处理
            if type(responseData.data) == "string" then
                isEncrypted = checkDataIsEncrypted(responseData.data)
                responseData.data = json.decode(JMForLua:decrypt(responseData.data))
            end

            --防沉迷
            if responseData.errcode == 12580 then
                PopupLayerController:showLayer("PopWindowsLayer", function(layer)
                    local title = "确定"
                    local text = Helper:getDef(responseData.errmsg, "出错, 请联系客服 errcode = " .. tostring(responseData.errcode))
                    local canHide = false
                    local func = function()
                    layer:hide()
                    self:removeFirstRequest()
                    cc.Director:getInstance():endToLua()
                    end
                    layer:showLayer(title,text,canHide,func)
                end)
                return true
            end

            if responseData.errcode == 615 and FILE_IS_LOADING == true then --停服更新
                CoroutineStack:clear()
                local DialogHLayer = require("app.views.layer.DialogLayer.DialogHLayer")
                local dialog = DialogHLayer:getInstance()
                local str = "游戏正在维护中，点击后即将进行存档备份，以免对账号造成损失。"
                dialog:setText(str)
                dialog:setTitle("服务器维护中")
                dialog:show()
                dialog:setBackOpacity(255)
                dialog:setButton1("确定",function()
                    local runningScene = cc.Director:getInstance():getRunningScene()
                    runningScene:setVisible(false)

                    dialog:hide()

                    HttpManagerEx:uploadUserData("shangchuan", function(status, errcode, errmsg, data, isEncrypted)
                        if status == 200 and errcode == 0 then
                            PopText("数据上传成功")
                            SdkMethod:exit()
                        else
                            PopText(errmsg)
                        end
                    end, IS_SHOW_WAITING, nil, true)
                end)
                
                return true
            end
            
            local errmsg = ""
            if status == 200 then
                errmsg = Helper:getDef(responseData.errmsg, "出错, 请联系客服 errcode = " .. tostring(responseData.errcode))
            else
                errmsg = "网络连接失败, 请检查网络是否正常"
            end
            
            LogSystem:log("http:send:callback:", status, responseData.errcode, responseData.data, isEncrypted, errmsg)

            return func(status, responseData.errcode, errmsg, Helper:getDef(responseData.data, {}), isEncrypted), status, responseData.errcode
        end, function(errmsg)print("Http:createGetResponseFunction", "(" .. errmsg .. ")")print(debug.traceback()) end)

        -- 顺利执行, 则返回回调的返回值 add by TangJian 2016/11/04 10:04:04
        if success then
            return arg1, arg2, arg3, arg4, arg5
        end
        return false -- 执行出错, 直接返回false add by TangJian 2016/11/04 10:04:06
    end
    return proxyFunc
end

-- 等待界面提示语
-- eventId 事件id
function Http:getWaittingText(eventId)
    if waitTexts and waitTexts[eventId] then
        return waitTexts[eventId].text
    end

    return "请稍后..."
end

return Http  000000000