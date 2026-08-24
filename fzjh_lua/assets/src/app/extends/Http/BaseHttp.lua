--[[
Descripttion: http基础模块
version: 
Author: LvBin
Date: 2024-06-26 14:45:41
--]]
local Request = require("third.http.Request")

local waitTexts = require("script.others.serverPrompts")["提示语"]

local BaseHttp = {
    __localTime = 0
}

local function init()
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

    --安卓1.4.0 请求地址替换
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

    -- DOMAIN = string.gsub(DOMAIN, "1798", "9003")
end

init()

--@desc: 获取解密的response数据并且检查是否作弊
--@author:LvBin
--@time:2024-06-27 14:46:56
--@url:
	--@response:
	--@status:
	--@request: 
--@return
function BaseHttp:getDecyptResponseWithCheckCheat(url, response, status, request)
    -- add by XiaoZhiWei 2018/01/18 18:01:09 暂时关闭sig校验
    if status ~= 200 then
        -- 网络异常情况
        return nil, "网络连接失败,请检查网络是否正常"
    else
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

        if map["vercode"] ~= nil then
            User:setRoleAttr("http_vercode", map["vercode"])
        end

        local SKIP_URL = {
            "get_time",
            "get_token",
            "report_cheat",
            "getWebConfig",
        }

        local isSkip = false

        for _,v in ipairs(SKIP_URL) do
            if string.find(url,v) then
                isSkip = true
                break
            end
        end
        
        -- add by XiaoZhiWei 2018/06/14 20:37:19 华为不需要验证签名
        if Game:getChannelId() == "huawei" or isSkip then
            return response
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

--@desc: 设置头信息
--@author:LvBin
--@time:2024-06-27 14:48:38
--@headers: 
--@return
function BaseHttp:getHeaders(headers)
    local time = self:getWebTime()
    -- 得到nouce and sig
    local nouce, sig = self:getNouceAndSig(time)

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
            vercode = User:getRoleAttr("http_vercode"),
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

--@desc: 判断返回的data是否有加密处理
--@author:LvBin
--@time:2024-06-27 14:50:03
--@data: 
--@return
function BaseHttp:checkDataIsEncrypted(data)
    if data == nil then return nil end
    return data ~= JMForLua:decrypt(data) -- 解密前后的文本内容不相等,则是加密过的数据
end

--@desc: 对Post请求数据进行加密处理
--@author:LvBin
--@time:2024-06-27 14:52:24
--@data:
	--@isNeedEncrypt: 
--@return
function BaseHttp:encryptPostData(data, isNeedEncrypt)
    -- 如果数据是空的则不需要加密处理了
    if data ~= nil and isNeedEncrypt == true then
        if Game:isNeedNewEncript() == true then
            local httpEncryptVersion = GameChannelContext:getHttpEncryptVersion()
            return JMForLua:encrypt(data, httpEncryptVersion)
        else
            return JMForLua:encrypt(data)
        end
    else
        return data
    end
end

--@desc: 发送请求
--@author:LvBin
--@time:2024-06-27 15:02:09
--@doType:
	--@url:
	--@sendData:
	--@headers:
	--@callback:
	--@isNeedWait:
	--@isNeedEncrypt: 
--@return
function BaseHttp:send(doType, url, sendData, headers, callback, isNeedWait, isNeedEncrypt)
    LogSystem:log("http:send:", doType, url, sendData, headers, callback, isNeedWait, isNeedEncrypt)
    
    self:updateWebTime() -- 刷新时间

    isNeedWait = Helper:getDef(isNeedWait, false) -- 等待默认为false
    -- 检查url是否齐全
    if string.find(url, DOMAIN) == nil and string.find(url, "api/service_ios/") == nil and string.find(url, "api/service/") == nil and string.find(url, "api/service_android/") == nil then
        url = DOMAIN..url
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
    :setHeaders(self:getHeaders(headers))
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

--@desc: 网络请求返回值处理方法
--@author:LvBin
--@time:2024-06-27 15:05:06
--@func: 
--@return
function BaseHttp:createGetResponseFunction(func)
    local function proxyFunc(response, status)
        -- 使用xpcall捕获打印异常 add by TangJian 2016/11/04 10:04:09
        local success, arg1, arg2, arg3, arg4, arg5 = xpcall(function()
            local responseData = nil
            if status == 200 then
                if self:checkDataIsEncrypted(response) == true then
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
                isEncrypted = self:checkDataIsEncrypted(responseData.data)
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

function BaseHttp:setWebTime(time)
    self.__localTime = time
end

function BaseHttp:getWebTime()
    return self.__localTime
end

function BaseHttp:updateWebTime()
    self.__localTime = self.__localTime + 0.0001
end

--@desc: 获取随机nouce 以及加密 sig
--@author:LvBin
--@time:2024-06-26 17:17:25
--@time: 
--@return
function BaseHttp:getNouceAndSig(time)
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

-- 等待界面提示语
-- eventId 事件id
function BaseHttp:getWaittingText(eventId)
    if waitTexts and waitTexts[eventId] then
        return waitTexts[eventId].text
    end

    return "请稍后..."
end

return BaseHttp
0000000000000000