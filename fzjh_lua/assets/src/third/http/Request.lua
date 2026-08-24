local class = require("third.class.NewClass")
local LogSystem = require("app.models.LogSystem.LogSystem")

local Request = {}

function Request:create()
    local o = Request.new()
    return o
end

function Request:ctor()
    -- 创建请求
    self.__xhr = cc.XMLHttpRequest:new()

    self.__method = nil
    self.__url = nil
    self.__postData = nil
    self.__headers = nil
    self.__responseCallback = nil
end

--[[
    @desc: 设置请求方式
    author:TangJian
    time:2022-04-11 16:29:45
    --@type: 
    @return:
]]
function Request:setMethod(type)
    self.__method = type
    return self
end

--[[
    @desc: 设置url
    author:TangJian
    time:2022-04-11 16:29:43
    --@url: 
    @return:
]]
function Request:setUrl(url)
    self.__url = url
    return self
end

--[[
    @desc: 设置请求头
    author:TangJian
    time:2022-04-11 16:29:42
    --@headers: 
    @return:
]]
function Request:setHeaders(headers)
    self.__headers = headers
    return self
end

--[[
    @desc: 设置post数据
    author:TangJian
    time:2022-04-11 16:29:40
    --@data: 
    @return:
]]
function Request:setPostData(data)
    self.__postData = data
    return self
end

--[[
    @desc: 设置响应回调
    author:TangJian
    time:2022-04-11 16:29:37
    --@callback: 
    @return:
]]
function Request:setResponseCallback(callback)
    self.__responseCallback = callback
    return self
end

--[[
    @desc: 发送请求
    author:TangJian
    time:2022-04-11 16:29:29
    @return:
]]
function Request:send()
    -- 创建请求
    self.__xhr = cc.XMLHttpRequest:new()
    self.__xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    self.__xhr:open(self.__method, self.__url, true)
    self.__xhr:registerScriptHandler(
        function()
            self.__responseCallback(self.__xhr.status, self.__xhr.response, self)
        end
    )

    -- 设置超时
    self.__xhr.timeout = 10

    -- 设置头
    if self.__headers then
        for k, v in pairs(self.__headers) do
            self.__xhr:setRequestHeader(k, v)
        end
    end

    LogSystem:log("http:Request:send:", self.__method, self.__url, self.__headers, self.__postData)

    self.__xhr:send(self.__postData)

    return self
end

--[[
    @desc: 获得所有请求头
    author:TangJian
    time:2022-04-11 16:29:20
    @return:
]]
function Request:getAllResponseHeaders()
    return self.__xhr:getAllResponseHeaders()
end

--[[
    @desc: 释放请求
    author:TangJian
    time:2022-04-11 16:29:09
    @return:
]]
function Request:release()
    -- self.__xhr:release()
    self.__xhr = nil
end

return class("Request", {}, Request)
000000000000