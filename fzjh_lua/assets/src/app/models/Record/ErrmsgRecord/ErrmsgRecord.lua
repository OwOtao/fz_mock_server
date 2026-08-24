--[[
Descripttion: 
version: 
Author: LvBin
Date: 2024-06-06 15:19:31
--]]
local ErrmsgRecord = {
    __collectionMsgTab = {
        msg = {}
    },
    __lastClearTime = 0,
    __cacheMsg = {}
}

local maxCount = 10

local clearCacheMsgTime = 600

function ErrmsgRecord:init()
    self.__handle = Game:schedule(
        function(ft)
            self:submitErrmsg()

            self.__lastClearTime = self.__lastClearTime + ft
            
            if self.__lastClearTime >= clearCacheMsgTime then
                self.__cacheMsg = {}

                self.__lastClearTime = 0
            end
        end, 
        5
    )
end

local function escapeJSONString(str)
    str = string.gsub(str,"'", "\"")
    return str
end


--@desc: 添加错误信息
--@author:LvBin
--@time:2024-06-06 17:08:06
--@msg: 
--@return
function ErrmsgRecord:addErrmsg(msg)
    if type(msg) ~= "string" then
        return
    end

    if self.__handle == nil then
        self:init()
    end

    msg = escapeJSONString(msg)

    if self.__cacheMsg[msg] == true then
        return
    end

    table.insert(self.__collectionMsgTab.msg, msg)

    self.__cacheMsg[msg] = true

    if self:checkIsNeedSubmit() then
        self:submitErrmsg()
    end
end

--@desc: 移除错误信息信息
--@author:LvBin
--@time:2024-06-06 17:29:04
--@return
function ErrmsgRecord:removeErrmsg()
    self.__collectionMsgTab.msg = {}
end


--@desc: 提交错误信息
--@author:LvBin
--@time:2024-06-06 17:05:59
--@msgInfo: 
--@return
function ErrmsgRecord:submitErrmsg()
    if #self.__collectionMsgTab.msg > 0 then
        local Record = require("app.models.Record.Record")
    
        Record:addLogData(Record.RECORD_TYPE.ERR_MSG, self:__serialize())
    
        self:removeErrmsg()

        self:__destroy()
    end
end

function ErrmsgRecord:__serialize()
    local recordTab = {}

    for i,msg in ipairs(self.__collectionMsgTab.msg) do
        table.insert(recordTab, msg)
    end

    return recordTab
end

function ErrmsgRecord:__destroy()
    if self.__handle ~= nil then
        Game:unschedule(self.__handle)
    end

    self.__handle = nil
end

function ErrmsgRecord:checkIsNeedSubmit()
    if #self.__collectionMsgTab.msg >= maxCount then
        return true
    end

    return false
end

return ErrmsgRecord
0