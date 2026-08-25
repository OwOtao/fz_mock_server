local class = require("third.class.NewClass")
local TableProxy = require("third.tableProxy.TableProxy")

local ServerActionSystem = {}

function ServerActionSystem:create()
    return ServerActionSystem.new()
end

function ServerActionSystem:ctor()
    self.__isNotSerializable = true
end

function ServerActionSystem:setPlayer(player)
    self.__player = player

    if self.__player.serverActionSystem == nil then
        self.__player.serverActionSystem = {
            dataVersion = 1,
            requestId = 1
        }
    end
end

function ServerActionSystem:__saveAction(dataVersion, callback, ...)
    self:setDataVersion(dataVersion)

    if callback then
        callback(...)
    end

    User:save()
end

function ServerActionSystem:getDataVersion()
    local dataVersion = self.__player.serverActionSystem.dataVersion
    if type(dataVersion) == "string" then
        dataVersion = tonumber(JMForLua:decrypt(dataVersion)) or 1
    end
    LogSystem:log("新版练功", "getDataVersion:", dataVersion)
    return dataVersion
end

function ServerActionSystem:setDataVersion(dataVersion)
    LogSystem:log("行为版本系统", "setDataVersion:", dataVersion)
    dataVersion = tonumber(dataVersion)
    if type(dataVersion) ~= "number" then
        PopText("行为版本异常，请联系客服, error:" .. tostring(dataVersion) .. "," .. type(dataVersion))
        error("dataVersion must be number but get:" .. tostring(dataVersion) .. ", type:" .. type(dataVersion))
        return
    end
    self.__player.serverActionSystem.dataVersion = dataVersion
end

function ServerActionSystem:getRequestId()
    local requestId = self.__player.serverActionSystem.requestId

    if type(requestId) == "string" then
        requestId = tonumber(JMForLua:decrypt(requestId)) or 1
    end
    requestId = requestId + 1
    self.__player.serverActionSystem.requestId = requestId

    LogSystem:log("新版练功", "requestId:", requestId)

    return requestId
end

function ServerActionSystem:getLianGongState(codeVersion, callback)
    HttpManagerEx:getLianGongState(
        self:getDataVersion(),
        codeVersion,
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    callback(true, data.state)
                else
                    callback(false)
                end
                return true
            end
        end
    )
end

function ServerActionSystem:getLianGongData(codeVersion, callback)
    HttpManagerEx:getLianGongData(
        self:getDataVersion(),
        codeVersion,
        function(status, errcode, errmsg, data, isEncrypted)
            if status == 200 then
                if errcode == 0 then
                    callback(true, "", data.startAction, data.useXgsCount)
                elseif errcode == 1 then
                    callback(true, "", "")
                else
                    callback(false, errmsg)
                end
                return true
            end
        end
    )
end

function ServerActionSystem:lianGongStart(actionData, codeVersion, time, callback)
    HttpManagerEx:lianGongStart(
        self:getRequestId(),
        self:getDataVersion(),
        codeVersion,
        actionData,
        time,
        function(status, errcode, errmsg, data, isEncrypted)
            print(status, errcode, errmsg, data, isEncrypted)
            if status == 200 then
                if errcode == 0 then
                    self:__saveAction(data.dataVer, callback, true)
                else
                    callback(false, errmsg)
                end
                return true
            end
        end
    )
end

function ServerActionSystem:lianGongFinish(actionData, codeVersion, time, callback)
    HttpManagerEx:lianGongFinish(
        self:getRequestId(),
        self:getDataVersion(),
        codeVersion,
        actionData,
        time,
        function(status, errcode, errmsg, data, isEncrypted)
            print(status, errcode, errmsg, data, isEncrypted)
            if status == 200 then
                if errcode == 0 then
                    self:__saveAction(data.dataVer, callback, true, data.msg)
                else
                    callback(false, errmsg)
                end
                return true
            end
        end
    )
end

function ServerActionSystem:lianGongUseXingGongSan(codeVersion, time, callback)
    HttpManagerEx:lianGongUseXingGongSan(
        self:getRequestId(),
        self:getDataVersion(),
        codeVersion,
        time,
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    self:__saveAction(data.dataVer, callback, true)
                else
                    callback(false, errmsg)
                end
            end
            return true
        end
    )
end

function ServerActionSystem:getXiuLianState(codeVersion, callback)
    HttpManagerEx:getXiuLianState(
        self:getDataVersion(),
        codeVersion,
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    callback(true, data.state)
                else
                    callback(false)
                end
                return true
            end
        end
    )
end

function ServerActionSystem:getXiuLianData(codeVersion, callback)
    HttpManagerEx:getXiuLianData(
        self:getDataVersion(),
        codeVersion,
        function(status, errcode, errmsg, data, isEncrypted)
            if status == 200 then
                if errcode == 0 then
                    callback(true, "", data.startAction, data.useXgsCount)
                elseif errcode == 1 then
                    callback(true, "", "")
                else
                    callback(false, errmsg)
                end
                return true
            end
        end
    )
end

function ServerActionSystem:xiuLianStart(actionData, codeVersion, time, callback)
    HttpManagerEx:xiuLianStart(
        self:getRequestId(),
        self:getDataVersion(),
        codeVersion,
        actionData,
        time,
        function(status, errcode, errmsg, data, isEncrypted)
            print(status, errcode, errmsg, data, isEncrypted)
            if status == 200 then
                if errcode == 0 then
                    self:__saveAction(data.dataVer, callback, true)
                else
                    callback(false, errmsg)
                end
                return true
            end
        end
    )
end

function ServerActionSystem:xiuLianFinish(actionData, codeVersion, time, callback)
    HttpManagerEx:xiuLianFinish(
        self:getRequestId(),
        self:getDataVersion(),
        codeVersion,
        actionData,
        time,
        function(status, errcode, errmsg, data, isEncrypted)
            print(status, errcode, errmsg, data, isEncrypted)
            if status == 200 then
                if errcode == 0 then
                    self:__saveAction(data.dataVer, callback, true, data.msg)
                else
                    callback(false, errmsg)
                end
                return true
            end
        end
    )
end

function ServerActionSystem:xiuLianUseXingGongSan(codeVersion, time, callback)
    HttpManagerEx:xiuLianUseXingGongSan(
        self:getRequestId(),
        self:getDataVersion(),
        codeVersion,
        time,
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    self:__saveAction(data.dataVer, callback, true)
                else
                    callback(false, errmsg)
                end
            end
            return true
        end
    )
end

function ServerActionSystem:getXinShenValue(codeVersion, callback)
    HttpManagerEx:getXinShenValue(
        self:getDataVersion(),
        codeVersion,
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    callback(true, data)
                else
                    callback(false, errmsg)
                end
            end
            return true
        end
    )
end

function ServerActionSystem:upgradeXinShenLevel(codeVersion, time, callback)
    HttpManagerEx:upgradeXinShenLevel(
        self:getRequestId(),
        self:getDataVersion(),
        codeVersion,
        time,
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    self:__saveAction(data.dataVer, callback, true, data)
                else
                    callback(false, errmsg)
                end
            end
            return true
        end
    )
end

function ServerActionSystem:getXinShenLevel(codeVersion, callback)
    HttpManagerEx:getXinShenLevel(
        self:getDataVersion(),
        codeVersion,
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    callback(true, data)
                else
                    callback(false, errmsg)
                end
            end
            return true
        end
    )
end

function ServerActionSystem:getXinShenRecoverStartTime(codeVersion, callback)
    HttpManagerEx:getXinShenRecoverStartTime(
        self:getDataVersion(),
        codeVersion,
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    callback(true, data)
                else
                    callback(false, errmsg)
                end
            end
            return true
        end
    )
end

function ServerActionSystem:recoverXinShenValue(value, codeVersion, time, callback)
    HttpManagerEx:recoverXinShenValue(
        value,
        self:getDataVersion(),
        codeVersion,
        time,
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    self:__saveAction(data.dataVer, callback, true, data)
                else
                    callback(false, errmsg)
                end
            end
            return true
        end
    )
end

function ServerActionSystem:getLianGongTiLi(codeVersion, callback)
    HttpManagerEx:getLianGongTiLi(
        self:getDataVersion(),
        codeVersion,
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    callback(true, "", data)
                else
                    callback(false, errmsg)
                end
            end
            return true
        end
    )
end

function ServerActionSystem:getItemCount(itemId, codeVersion, callback)
    HttpManagerEx:getItemCount(
        itemId,
        self:getDataVersion(),
        codeVersion,
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    callback(true, data)
                else
                    callback(false, errmsg)
                end
            end
            return true
        end
    )
end

function ServerActionSystem:getItemMap(callback)
    HttpManagerEx:getItemMap(
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    callback(true, data)
                else
                    callback(false, errmsg)
                end
            end
            return true
        end
    )
end

function ServerActionSystem:refreshItemMapCache(codeVersion, callback)
    HttpManagerEx:refreshItemMapCache(
        self:getDataVersion(),
        codeVersion,
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    callback(true, data)
                else
                    callback(false, errmsg)
                end
            end
            return true
        end
    )
end

function ServerActionSystem:addItemCount(itemId, count, codeVersion, callback)
    HttpManagerEx:addItemCount(
        itemId,
        count,
        self:getDataVersion(),
        codeVersion,
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    self:__saveAction(data.dataVer, callback, true, data)
                else
                    callback(false, errmsg)
                end
            end
            return true
        end
    )
end

function ServerActionSystem:useItem(itemId, codeVersion, callback)
    HttpManagerEx:useItem(
        itemId,
        self:getDataVersion(),
        codeVersion,
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    self:__saveAction(data.dataVer, callback, true, data)
                else
                    callback(false, errmsg)
                end
            end
            return true
        end
    )
end

function ServerActionSystem:createFistInfo(codeVersion, callback)
    HttpManagerEx:createFistInfo(
        self:getDataVersion(),
        codeVersion,
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    self:__saveAction(data.dataVer, callback, true, "", data)
                else
                    callback(false, errmsg)
                end
            end
            return true
        end
    )
end

function ServerActionSystem:getFistFootInFo(codeVersion, callback)
    HttpManagerEx:getFistFootInFo(
        self:getDataVersion(),
        codeVersion,
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    self:__saveAction(data.dataVer, callback, true, "", data)
                elseif errcode == 2 then --拳脚系统还未开启
                    callback(false, errmsg)
                else
                    callback(false, errmsg)
                end
            end
            return true
        end
    )
end

--@desc: 开始修行任务
--@author:LvBin
--@time:2022-09-17 11:03:29
--@taskId:
--@callback:
--@return
function ServerActionSystem:startFistTask(taskId, codeVersion, callback)
    HttpManagerEx:startFistTask(
        taskId,
        self:getDataVersion(),
        codeVersion,
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    self:__saveAction(data.dataVer, callback, true, "", data)
                else
                    callback(false, errmsg)
                end
            end
            return true
        end
    )
end

--@desc: 中途停止修行任务
--@author:LvBin
--@time:2022-09-17 11:02:34
--@callback:
--@return
function ServerActionSystem:stopFistTask(taskId, codeVersion, callback)
    HttpManagerEx:stopFistTask(
        taskId,
        self:getDataVersion(),
        codeVersion,
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    self:__saveAction(data.dataVer, callback, true, "", data)
                else
                    callback(false, errmsg)
                end
            end
            return true
        end
    )
end

--@desc: 加速修行任务
--@author:LvBin
--@time:2022-09-17 11:02:34
--@cost: 加速消耗资源数量
--@callback:
--@return
function ServerActionSystem:speedUpFistTask(taskId, cost, codeVersion, callback)
    HttpManagerEx:speedUpFistTask(
        taskId,
        cost,
        self:getDataVersion(),
        codeVersion,
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    self:__saveAction(data.dataVer, callback, true, "", data)
                else
                    callback(false, errmsg)
                end
            end
            return true
        end
    )
end

--@desc: 完成修行任务
--@author:LvBin
--@time:2022-09-17 11:02:34
--@bagEnough: 背包格子是否够 0不够 1够
--@callback:
--@return
function ServerActionSystem:finishFistTask(taskId, bagEnough, codeVersion, callback)
    HttpManagerEx:finishFistTask(
        taskId,
        bagEnough,
        self:getDataVersion(),
        codeVersion,
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    self:__saveAction(data.dataVer, callback, true, "", data)
                else
                    callback(false, errmsg)
                end
            end
            return true
        end
    )
end

--[[
    @desc: 技巧升级
    author:{author}
    time:2022-10-12 15:39:10
    --@techniqueId:
	--@codeVersion:
	--@callback: 
    @return:
]]
function ServerActionSystem:upgradeTechnique(techniqueId, codeVersion, callback)
    HttpManagerEx:upgradeTechnique(
        techniqueId,
        self:getDataVersion(),
        codeVersion,
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    self:__saveAction(data.dataVer, callback, true, "", data)
                else
                    callback(false, errmsg)
                end
            end
            return true
        end
    )
end

--[[
    @desc: 抽取特性
    author:{author}
    time:2022-10-12 15:40:18
    --@techniqueId:
	--@codeVersion:
	--@callback: 
    @return:
]]
function ServerActionSystem:extractCharacter(techniqueId, codeVersion, callback)
    HttpManagerEx:extractCharacter(
        techniqueId,
        self:getDataVersion(),
        codeVersion,
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    self:__saveAction(data.dataVer, callback, true, "", data)
                else
                    callback(false, errmsg)
                end
            end
            return true
        end
    )
end

--[[
    @desc: 替换特性
    author:{author}
    time:2022-10-12 15:40:56
    --@techniqueId:
	--@codeVersion:
	--@callback: 
    @return:
]]
function ServerActionSystem:replaceCharacter(techniqueId, codeVersion, callback)
    HttpManagerEx:replaceCharacter(
        techniqueId,
        self:getDataVersion(),
        codeVersion,
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    self:__saveAction(data.dataVer, callback, true, "", data)
                else
                    callback(false, errmsg)
                end
            end
            return true
        end
    )
end

--[[
    @desc: 重置天赋页
    author:{author}
    time:2022-10-12 15:42:21
    --@talentPageId:
	--@codeVersion:
	--@callback: 
    @return:
]]
function ServerActionSystem:resetTalentPage(talentPageId, codeVersion, callback)
    HttpManagerEx:resetTalentPage(
        talentPageId,
        self:getDataVersion(),
        codeVersion,
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    self:__saveAction(data.dataVer, callback, true, "", data)
                elseif errcode == 2 then
                    --@desc 当前重置页未消耗感悟点，不需要重置
                    callback(false, errmsg)
                else
                    callback(false, errmsg)
                end
            end
            return true
        end
    )
end

--[[
    @desc: 获取天赋页信息
    author:{author}
    time:2022-10-13 16:40:03
    --@codeVersion:
	--@callback: 
    @return:
]]
function ServerActionSystem:getTalentPageInfo(codeVersion, callback)
    HttpManagerEx:getTalentPageInfo(
        self:getDataVersion(),
        codeVersion,
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    callback(true, "", data)
                else
                    callback(false, errmsg)
                end
            end
            return true
        end
    )
end

--@desc: Get actual talent page count.
function ServerActionSystem:getTalentPageCount(codeVersion, callback, isRetry)
    local retryType = isRetry == true and HTTP_MANAGER_RETRY_TYPE_RETRY or HTTP_MANAGER_RETRY_TYPE_OK

    HttpManagerEx:getTalentPageCount(
        self:getDataVersion(),
        codeVersion,
        function(status, errcode, errmsg, data)
            if status == 200 and errcode == 0 then
                callback(true, "", data)
                return true
            end

            if isRetry == true then
                return false
            end

            callback(false, errmsg)
            return true
        end,
        IS_SHOW_WAITING,
        retryType
    )
end
--[[
    @desc: 获取特性池详情
    author:{author}
    time:2022-10-13 16:40:59
    --@poolId: 特性池id
	--@codeVersion:
	--@callback: 
    @return:
]]
function ServerActionSystem:getCharacterPoolInfo(poolId, codeVersion, callback)
    HttpManagerEx:getCharacterPoolInfo(
        poolId,
        self:getDataVersion(),
        codeVersion,
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    callback(true, "", data)
                else
                    callback(false, errmsg)
                end
            end
            return true
        end
    )
end

--@desc: 更新拳脚系统标记
--@author:LvBin
--@time:2022-10-19 14:20:48
--@addFlags: 添加的标记数组
--@deleteFlags: 删除的标记数组
--@codeVersion:
--@callback:
--@return
function ServerActionSystem:updataFistFlag(addFlags, deleteFlags, codeVersion, callback)
    HttpManagerEx:updataFistFlag(
        addFlags,
        deleteFlags,
        self:getDataVersion(),
        codeVersion,
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    self:__saveAction(data.dataVer, callback, true, "", data)
                else
                    callback(false, errmsg)
                end
            end
            return true
        end
    )
end

--[[
    @desc: 获取修行任务列表
    author:{author}
    time:2022-10-15 15:05:23
	--@codeVersion:
	--@callback: 
    @return:
]]
function ServerActionSystem:getFistTasks(codeVersion, callback)
    HttpManagerEx:getFistTasks(
        self:getDataVersion(),
        codeVersion,
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    callback(true, "", data)
                else
                    callback(false, errmsg)
                end
            end
            return true
        end
    )
end

--@desc: 技巧心得切换
--@author:Seven
--@time:2023-01-09 10:53:04
--@pageNum: 技巧页码
--@codeVersion:
--@callback: 回调
function ServerActionSystem:changeTelentPage(pageNum, codeVersion, callback)
    HttpManagerEx:switchTalentPage(
        pageNum,
        codeVersion,
        self:getDataVersion(),
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    self:__saveAction(data.dataVer, callback, true, data)
                else
                    callback(false, nil, errcode, errmsg)
                end
            end
            return true
        end
    )
end

return class("ServerActionSystem", {}, ServerActionSystem)
000