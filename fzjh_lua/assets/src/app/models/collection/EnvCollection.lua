--[[
    author:Seven
    time:2023-08-25 21:01:32
    desc:
]]
local newClass = require("third.class.NewClass")

local EnvCollection = {}

local luaFilePath = cc.FileUtils:getInstance():getWritablePath() .. "luaTablePath/"

function EnvCollection:create()
    return EnvCollection.new():__init()
end

function EnvCollection:__init()
    self.__env = {}
    return self
end

function EnvCollection:__getLuaTablePathContents()
    local t = {}
    local fileList = cc.FileUtils:getInstance():listFiles(luaFilePath)

    for i, filePath in ipairs(fileList) do
        local fileName = filePath:match("[^/]+$")
        if fileName ~= nil and fileName ~= "Shade" then
            t[fileName] = cc.FileUtils:getInstance():getStringFromFile(filePath)
        end
    end

    return t
end


local otherFiles = {"4238b0eab7da9df636a17e1974e26541", "b96448f3931cfa66e45d68dc10e99ed3"}
function EnvCollection:__getOtherFileContents()
    local info = {}
    for i, v in ipairs(otherFiles) do
        local path = cc.FileUtils:getInstance():fullPathForFilename(v)
        if path ~= "" then
            info[v] = cc.FileUtils:getInstance():getStringFromFile(path)
        end
    end

    return info
end

function EnvCollection:__setEnv(key, tb)
    if self.__env[key] == nil then
        self.__env[key] = tb
    else
        print("EnvCollection ：" .. tostring(key) .. "已存在")
    end
end

function EnvCollection:__collect()
    self:__setEnv("luaPath", self:__getLuaTablePathContents())

    self:__setEnv("otherFiles", self:__getOtherFileContents())
end

function EnvCollection:__upload(callback)
    HttpManagerEx:uploadClientEnvMessage(
        self.__env,
        function(status, errcode, errmsg, data)
            local result, message
            if status == 200 then
                if errcode == 0 then
                    result = true
                    message = "感谢反馈"
                elseif errcode == 1 then
                    result = false
                    message = errmsg
                elseif errcode == 2 then
                    result = false
                    message = "上传失败"
                elseif errcode == -2 then
                    result = false
                    message = "上传失败"
                else
                    result = false
                    message = "上传失败"
                end
            end

            if callback then
                callback(result, errcode, message)
            end
            return true
        end
    )
end

function EnvCollection:uploadEnv(callback)
    self:__collect()

    self:__upload(callback)
end

return newClass("EnvCollection", {}, EnvCollection)
000