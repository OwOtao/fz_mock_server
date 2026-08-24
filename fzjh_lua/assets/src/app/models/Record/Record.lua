local LogSystem = require("app.models.LogSystem.LogSystem")

local Record = {
    __lastTime = GetTime(),
    __itemRecordFilePath = nil,
    LOG_TYPE = {
        ITEM = 0,
        ACTION_FLAG = 1
    }
}

function Record:addRecordCount(type, act, id)
    local record = DataBase:getLuaTable("Record")
    record = Helper:getDef(record, {})

    table.insert(record, {stat_type = type, act = act, id = id, t = GetTime()})
    DataBase:setLuaTable("Record", record)
    if #record >= 10 then
        HttpManagerEx:addRecordCount(
            record,
            function(status, errcode, errmsg, data, isEncrypted)
                if status == 200 and errcode == 0 then
                else
                    PopText(errmsg)
                end
            end,
            IS_SHOW_WAITING
        )
        DataBase:setLuaTable("Record", {})
    end
end

-- 检测物品是否需要记录使用
function Record:checkUseItemNeedRecord(itemId)
    local itemList = {
        {type = "jingmai", itemId = "jingmai101"},
        {type = "jingmai", itemId = "jingmai103"},
        {type = "jingmai", itemId = "jingmai105"}
    }

    for k, v in pairs(itemList) do
        if v.itemId == itemId then
            self:addRecordCount(v.type, "useItem", itemId)
            break
        end
    end
end

--纯粹后台记录 不涉及逻辑 数据保留在本地 本次记录与上次提交服务器隔一分钟则再次提交服务器
--[[
1 本地文件添加数据
2 判断时间是否需要上传服务器 上传频率 60s一次
3 上传服务器成功后 把本地中上传数据删除
]]
--上传频率 60s一次
local SUBMIT_INTERVAL = 60
local MAX_COUNT = 20

function Record:addLog(logType, logData, source)
    if MapIsEmpty(logData) then
        return
    end

    if not self.__itemRecordFilePath then
        self.__itemRecordFilePath = User:getUserId() .. "ItemRecord"
    end

    if not source then
        source = "其他"
    end

    if not logType then
        error("Record:addLog ，日志记录类型不可为空")
    end

    local logRecords = DataBase:getLuaTable(self.__itemRecordFilePath)
    logRecords = Helper:getDef(logRecords, {})
    local recordNum = User:getRole():getInheritFlag("itemRecordNum")

    if recordNum > 10000000 then
        recordNum = 0
    end

    for k, v in pairs(logData) do
        local recordData = {}
        recordData["id"] = recordNum + 1
        recordData["lType"] = logType
        if logType == 0 then
            recordData["itemId"] = k
            recordData["num"] = v
            recordData["tag"] = source
            if DEBUG_MODE == 1 then
                local itemAttr = Item:getOneItemByKey(recordData["itemId"])
                if MapIsEmpty(itemAttr) == false then
                    print("物品变化：", itemAttr.name, recordData["num"])
                end
            end
        elseif logType == 1 then
            recordData["aFlag"] = k
            recordData["cCount"] = v
            recordData["tag"] = source
        else
            error("Record:addLog ，日志记录类型未知 ： " .. logType)
        end
        table.insert(logRecords, recordData)
    end

    User:getRole():setInheritFlag("itemRecordNum", recordNum + 1)

    --保存记录
    DataBase:setLuaTable(self.__itemRecordFilePath, logRecords)
end

function Record:submitLog()
    local lastTime = self.__lastTime

    local currTime = GetTime()

    if not self.__itemRecordFilePath then
        self.__itemRecordFilePath = User:getUserId() .. "ItemRecord"
    end

    local localRecords = DataBase:getLuaTable(self.__itemRecordFilePath)
    if MapIsEmpty(localRecords) then
        self.__lastTime = currTime
        return
    end

    --数据排序
    local function recordDataSort(recordData)
        local records = {}
        for k, v in pairs(recordData) do
            table.insert(records, v)
        end

        table.sort(records, function(a, b)
            return a.id < b.id
        end)

        return records
    end

    --删除数据
    local function removeAfterData(updateRecord)
        --存在异步情况 需获取本地最新数据
        local localData = DataBase:getLuaTable(self.__itemRecordFilePath)
        for k, recordInfo in ipairs(updateRecord) do
            for index, localRecordInfo in pairs(localData) do
                --根据唯一id进行标记处理
                if localRecordInfo["id"] == recordInfo["id"] then
                    localData[index] = nil
                    break
                end
            end
        end

        DataBase:setLuaTable(self.__itemRecordFilePath, localData)
    end

    --需要上传的数据 控制下上传数据 避免数据过大
    local function getNeedUpdateData(itemRecord)
        local needUpdateData = {}
        local needNum = #itemRecord > MAX_COUNT and MAX_COUNT or #itemRecord

        for i = 1, needNum, 1 do
            table.insert(needUpdateData, itemRecord[i])
        end

        return needUpdateData
    end

    local updateRecord = getNeedUpdateData(recordDataSort(localRecords))

    HttpManagerEx:reportGainLog(
        updateRecord,
        function(status, errcode, errmsg, data)
            if status == 200 and errcode == 0 then
                --对上传数据进行删除
                removeAfterData(updateRecord)
                self.__lastTime = currTime
            end
        end
    )
end

function Record:isNeedSubmit()
    if self.__lastTime == 0 then
        self.__lastTime = GetTime()
    end
    return (GetTime() - self.__lastTime) >= SUBMIT_INTERVAL
end

Record.RECORD_TYPE = {
    STRA_REWARD = 101, --打开策略奖励日志
    USE_ITEM_REWARD = 102, --使用物品直接发放奖励日志,
    ATTR_CHANGE = 103, --角色属性变化日志,
    M_HUAYUAN = 104, --经脉化元日志
    NATURAL_ATTR_ADJUSTMENT = 105, --先天属性方案调整或切换日志
    SHENSHU_DROP = 106, --神书掉落日志
    YiRONGSHU = 107,--易容术日志
    GENDER_TRANSITION = 108,  --阴阳嬗变日志
    SKILL_ADVANCE = 109, --技能升级日志
    ERR_MSG = 500, --客户端报错信息
    SKILL_YANJIU_LIMITLV = 600, --修复基本武学研究等级限制
    MERIDIAN_PAGE_REPAIR = 700, --经脉页回档修复
    MERIDIAN_PAGE_CHEAT = 701, --经脉页作弊
    SHENSHU_TASK = 110,  --神书任务开启
}

function Record:addLogData(log_type, log_data)
    if not log_type then
        error("Record:addLogData ，日志记录类型不可为空")
    end

    if not log_data then
        error("Record:addLogData ，日志记录数据不可为空")
    end

    local __recordIndex = User:getRole():getInheritFlag("_logIndex")
    if __recordIndex > 10000 then
        User:getRole():setInheritFlag("_logIndex", 0)
        __recordIndex = 0
    end

    log_data.__lindex = __recordIndex + 1
    log_data.__time = Helper:preciseDecimal(GetTime(), 3)
    User:getRole():setInheritFlag("_logIndex", log_data.__lindex)
    self:__addRecord({type = log_type, logData = log_data})
end

function Record:__addRecord(record_data)
    if self.__recordData == nil then
        self.__recordData = {}
    end

    table.insert(self.__recordData, record_data)

    self:updateUpload()
end

function Record:updateUpload()
    if self.__uploading == true then
        return
    end

    local currenttime = GetLocalTime()

    if self.__lastUploadTime == nil then
        self.__lastUploadTime = 0
    end

    if currenttime - self.__lastUploadTime < 0 then
        --@desc 避免调时间导致的问题
        self.__lastUploadTime = currenttime
    end

    if currenttime - self.__lastUploadTime >= 5 then
        self:__uploadRecord()
    end
end

function Record:__uploadRecord()
    self.__lastUploadTime = GetLocalTime()
    if self.__recordData == nil then
        return
    end

    local count = table.getn(self.__recordData)
    if count <= 0 then
        return
    end

    local isShowWaiting, isRetry
    if count > 99 then
        isShowWaiting = IS_SHOW_WAITING
        isRetry = HTTP_MANAGER_RETRY_TYPE_RETRY
    end

    self.__uploading = true
    HttpManagerEx:uploadAcquisitionLog(
        self.__recordData,
        function(status, errcode, errmsg, data)
            local isUploadSuccess = false

            if status == 200 and errcode == 0 then
                -- LogSystem:log("Record Log", "日志上传成功", self.__recordData)
                self.__recordData = {}
                isUploadSuccess = true
            end

            if isUploadSuccess == false then
                if isRetry ~= nil then
                    return false
                else
                    self.__uploading = false
                    return true
                end
            else
                self.__uploading = false
                return true
            end
        end,
        isShowWaiting,
        isRetry
    )
end

return Record
0