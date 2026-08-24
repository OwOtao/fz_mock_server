local BuffManager = class("BuffManager")

local BuffData = require("script.Buff.BuffAll")["buff"]

function BuffManager:ctor()
    self.buffList = {}

    self._subscribeDict = {}

    self.statusInfoDict = {}

    self.changeNotifyFunc = {}

    self._subscriptions = {}

    self.role = nil
end

function BuffManager:create()
    local p = BuffManager:new()
    return p
end

function BuffManager:init(role)
    self.role = role

    self:deserialization()
end


function BuffManager:updateBuffStatuInfo()
    if #self.buffList <= 0 then
        return
    end

    local updateBuffList = {}
    for i = 1, #self.buffList do
        local buff = self.buffList[i]

        local status = buff:getStatusInfo()

        local statuInfoCache = self.statusInfoDict[buff:getId()]

        if statuInfoCache ~= status then
            self.statusInfoDict[buff:getId()] = status
            table.insert(updateBuffList, buff:getId())
        end
    end

    if MapIsEmpty(updateBuffList) == false and MapIsEmpty(self.changeNotifyFunc) == false then
        for _, func in pairs(self.changeNotifyFunc) do
            func(updateBuffList)
        end
    end
end

function BuffManager:registerUpdateFunc(func)
    local indexId = "buffUpdateFunc" .. Helper:getOnlyId()

    self.changeNotifyFunc[indexId] = func

    return indexId
end

function BuffManager:unregisterUpdateFunc(indexId)
    if self.changeNotifyFunc[indexId] ~= nil then
        self.changeNotifyFunc[indexId] = nil
    end
end

local createNewBuff = function(buffid, manager)
    local id = tostring(buffid)

    local buffData = BuffData[id]

    if buffData == nil then
        error("没有找到buff数据： " .. buffid)
    end

    -- local className = BuffTriggerTypeClassName[buffData.triggerType]
    local BuffClass
    if buffData.script ~= nil and buffData.script ~= "" then
        BuffClass = require("app.models.Buff.SubBuff." .. buffData.script)
        local buff = BuffClass:create(buffData, manager)

        return buff
    else
        --@RefType[BaseBuff]
        BuffClass = require("app.models.Buff.BaseBuff")
        return BuffClass:create(buffData, manager)
    end
end

function BuffManager:addBuff(buffid)
    local buff = self:getBuff(buffid)

    if buff == nil then
        buff = createNewBuff(buffid, self)
        buff:setRole(self.role)
        table.insert(self.buffList, buff)
    end

    buff:add()
    self:updateBuffStatuInfo()

    self:serialization()

    return buff
end

function BuffManager:getBuff(id)
    for i, buff in ipairs(self.buffList) do
        if buff:getId() == id then
            return buff
        end
    end
    return nil
end

function BuffManager:removeBuff(buffid)
    local length = #self.buffList

    if length > 0 then
        local isNeedUpdateInfo = false
        for i = length, 1, -1 do
            local buff = self.buffList[i]
            if buff:getId() == buffid then
                buff:remove()
                if buff:getLayers() == 0 then
                    self:destoryBuff(buff)
                else
                    isNeedUpdateInfo = true
                end
                break
            end
        end

        if isNeedUpdateInfo == true then
            self:updateBuffStatuInfo()
        end
    end
end

function BuffManager:removeAllBuff()
    local length = #self.buffList
    if length > 0 then
        for i = length, 1, -1 do
            local buff = self.buffList[i]
            self:destoryBuff(buff)
        end

        self:serialization()
    end
end

function BuffManager:destoryBuff(buff)
    local index = table.indexof(self.buffList, buff)

    if index then
        local statuInfoCache = self.statusInfoDict[buff:getId()]

        if statuInfoCache ~= nil then
            self.statusInfoDict[buff:getId()] = nil
        end

        buff:destory()
        table.remove(self.buffList, index)

        for eventName, v in pairs(self._subscribeDict) do
            if v[buff] == true then
                v[buff] = nil
            end
        end

        --@desc 移除buff后通知
        for _, func in pairs(self.changeNotifyFunc) do
            func({buff:getId()})
        end

        self:serialization()
    end
end

function BuffManager:destory()
    -- MessageCenter:removeObjListener(self)
    if #self._subscriptions > 0 then
        for i, v in ipairs(self._subscriptions) do
			v:unsubscribe()
		end
		self._subscriptions = {}
    end

    self.buffList = {}

    self._subscribeDict = {}

    self.statusInfoDict = {}

    self.changeNotifyFunc = {}

    self.role = nil
end

--@desc: 获取buff加成属性值
--@author:Seven_L
--@time:2020-07-21 14:39:05
--@attrName: buff加成属性名
function BuffManager:getEffecetValue(attrName)
    local value = 0

    if #self.buffList > 0 then
        for i = 1, #self.buffList do
            local buff = self.buffList[i]

            value = value + buff:getEffectValue(attrName)

            -- print("buff manager : ", attrName, value, buff:getEffectValue(attrName))
        end
    end

    return value
end

function BuffManager:serialization()
    if #self.buffList == 0 then
        return
    end

    local buffs = {}

    for i, buff in ipairs(self.buffList) do
        local saveInfo = buff:serialization()
        table.insert(buffs, saveInfo)
    end

    self.role:setAttr("buffs", buffs)
end

--@desc: 反序列化
--@author:Seven_L
--@time:2020-07-21 10:17:51
function BuffManager:deserialization()
    local buffsInfo = self.role:getAttr("buffs")

    if #buffsInfo > 0 then
        for i, buffinfo in ipairs(buffsInfo) do
            local buffId = buffinfo.id
            local buff = createNewBuff(buffId, self)
            buff:setRole(self.role)
            buff:deserialization(buffinfo)

            table.insert(self.buffList, buff)
        end
        self:updateBuffStatuInfo()
    end
end

--@desc: 事件订阅
--@author:Seven_L
--@time:2020-07-30 14:59:04
--@eventName:
--@buff:
function BuffManager:subscribe(eventName, buff)
    if self._subscribeDict[eventName] == nil then
        self._subscribeDict[eventName] = {}

        local subscription = self.role:getObservable():filter(
            function(eName)
                return eventName == eName
            end
        ):subscribe(
            function(eName, event)
                self:notify(eName, event)
                self:updateBuffStatuInfo()
            end,
            function(errorMsg)
                error(errorMsg)
            end
        )
        table.insert(self._subscriptions, subscription)
    end

    if self._subscribeDict[eventName][buff] == nil then
        self._subscribeDict[eventName][buff] = true
    end
end

function BuffManager:notify(eventName, event)
    if eventName == "FightEndEvent" then
        print("=============================================" , eventName,self.role.name)
    end
    if MapIsEmpty(self._subscribeDict[eventName]) == true then
        return
    end

    for buff, _ in pairs(self._subscribeDict[eventName]) do
        buff:receive(eventName, event)
    end
end

function BuffManager:update()
    if #self.buffList <= 0 then
        return
    end
    for i = 1, #self.buffList do
        local buff = self.buffList[i]
        if buff:isTimed() then
            buff:update()
        end
    end
end

function BuffManager:printBuffsInfo()
    if #self.buffList > 0 then
        for i = 1, #self.buffList do
            local buff = self.buffList[i]
            buff:printInfo()
        end
    end
end

return BuffManager
000000000000