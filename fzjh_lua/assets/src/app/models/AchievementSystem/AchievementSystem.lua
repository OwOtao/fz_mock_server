local NewClass = require("third.class.NewClass")

local AchievementSystem = {
    __role = nil, -- 角色, 主要用来获取属性状态等
    __clientRecordData = {}, -- 客户端记录
    __serverRecordData = {}, -- 服务端记录
    __updateRate = 20,        -- 更新频率
    __lastUpdateTime = 0,     -- 最后更新时间
    __uploadRate = 20,        -- 上传频率
    __lastUploadTime = 0,     -- 最后上传时间
    __lastRecordTime = 0 ,    -- 最后记录时间
    __maxUploadRecordNums = 20,--单次最大上传记录
    __clientRecordIndex = 0,  --记录下标
    __uploadedRecord = {},
    __clientRecordDataPath = "AchievementSystem_Record", --本地保存数据路径
}

function AchievementSystem:create()
    local p = AchievementSystem:new()
    p:init()
    return p
end

function AchievementSystem:init()
end

function AchievementSystem:initData(role,userId)
    self.__role = role
    self.__clientRecordDataPath = "AchievementSystem_Record"..tostring(userId)
    --获取本地解锁记录
    self:getLocalRecord()
    --获取线上解锁记录
    self:updateRecord()
    --默认更新一次
    self.__lastUpdateTime = 0
end

--更新状态
function AchievementSystem:update()
    local curTime = GetTime()

    if curTime - self.__lastUpdateTime >= self.__updateRate then
        -- 遍历记录资源中的所有属性类型
        self:__updateAttrTypeRecord()
        self:__updateItemTypeRecord()
        self:__updateSkillTypeRecord()
        self.__lastUpdateTime = curTime
    end

    if self.__lastRecordTime - self.__lastUploadTime >= self.__uploadRate then
        self:updateRecord()
    end
end

-- 上传本地记录到服务器并获取最新解锁列表
function AchievementSystem:updateRecord(func)
    self.__lastUploadTime = GetTime()
    local needUploadRecordDate = self:__getNeedUploadRecordDate()

    HttpManagerEx:updateUnlockRecord(needUploadRecordDate,function(status, errcode, errmsg, data)
        if status == 200 and errcode == 0 then
            self:__removeUploadRecordData()
            if MapIsEmpty(data) == false and MapIsEmpty(data.recordList) == false then
                --{{jid = 记录id ,expired_time = 到期时间（时间戳,0表示永远）,values = 记录次数}}
                self.__serverRecordData = data.recordList
            end
            if func then
                func()
            end
        else
            PopText(errmsg)
        end
    end, IS_SHOW_WAITING)
end

--获取已经解锁的记录点
function AchievementSystem:getUnlockRecord()
    local unlockRecords = {}

    for k, v in pairs(self.__serverRecordData) do
        unlockRecords[v.jid] = v.values
    end

    for k, v in pairs(self.__clientRecordData) do
        if unlockRecords[v.jid] then
            unlockRecords[v.jid] = unlockRecords[v.jid] + 1
        else
            unlockRecords[v.jid] = 1
        end
    end

    return unlockRecords
end

--初始化本地记录点
function AchievementSystem:getLocalRecord()
    local recordData = DataBase:getLuaTable(self.__clientRecordDataPath)
    if MapIsEmpty(recordData) == false then
        self.__clientRecordData = recordData
    end
end

--通过记录点id获取记录点
function AchievementSystem:getRecordById(recordId)
    local recordsRes = self:__getRecordsRes()["1"]
    local record = recordsRes:getRecordById(recordId)

    return record
end

-- 添加记录
function AchievementSystem:add(record)
    if MapIsEmpty(record) then
        return
    end

    local currTime = GetTime()
    local recordDate =  {jid = record.id, itype = record.type, lifes = record.life, lifeParam = record.lifeParam, inherit = record.inherit, values = record.value}

    self.__clientRecordData[self.__clientRecordIndex] = recordDate
    self.__clientRecordIndex = self.__clientRecordIndex + 1

    self.__lastRecordTime = currTime

    DataBase:setLuaTable(self.__clientRecordDataPath, self.__clientRecordData)
end

--获取需要上传的记录
function AchievementSystem:__getNeedUploadRecordDate()
    local needUploadRecordDate = {}
    local recordNum = 0

    for k,v in pairs(self.__clientRecordData) do
        if recordNum >= self.__maxUploadRecordNums then
            break
        end

        table.insert(needUploadRecordDate,v)
        self.__uploadedRecord[k] = true
        recordNum = recordNum + 1
    end

    return needUploadRecordDate
end

--移除本地已经上传的记录
function AchievementSystem:__removeUploadRecordData()
    for k,v in pairs(self.__clientRecordData) do
        if self.__uploadedRecord[k] then
            self.__clientRecordData[k] = nil
            self.__uploadedRecord[k] = nil
        end
    end
    DataBase:setLuaTable(self.__clientRecordDataPath, self.__clientRecordData)
end

-- 更新属性类型的记录
function AchievementSystem:__updateAttrTypeRecord()
    local recordsRes = self:__getRecordsRes()["1"]
    local attrRecords = recordsRes:getAttrTypeRecords()
    --(recordId, recordType, types, parameters, seconds)
    for k, v in pairs(attrRecords) do
        if self:__checkRecordIsNeedToAdd(v,"attr") then
            self:add(v)
        end
    end
end

-- 更新物品类型的记录
function AchievementSystem:__updateItemTypeRecord()
    local recordsRes = self:__getRecordsRes()["1"]
    local itemRecords = recordsRes:getItemTypeRecords()
    
    for k, v in pairs(itemRecords) do
        if self:__checkRecordIsNeedToAdd(v,"item") then
            self:add(v)
        end
    end
end

-- 更新技能类型的记录
function AchievementSystem:__updateSkillTypeRecord()
    local recordsRes = self:__getRecordsRes()["1"]
    local skillRecords = recordsRes:getSkillTypeRecords()
    
    for k, v in pairs(skillRecords) do
        if self:__checkRecordIsNeedToAdd(v,"skill") then
            self:add(v)
        end
    end
end

-- 更新图鉴类型的记录
function AchievementSystem:updateTujianTypeRecord()
    local recordsRes = self:__getRecordsRes()["1"]
    local tujianRecords = recordsRes:getTujianTypeRecords()
    
    for k, v in pairs(tujianRecords) do
        if self:__checkRecordIsNeedToAdd(v,"tujian") then 
            self:add(v)
        end
    end
end

--检查是否需要记录
function AchievementSystem:__checkRecordIsNeedToAdd(record,recordType)
    if MapIsEmpty(record) or not recordType then
        print("AchievementSystem:__checkIsNeedToRecord record is nil")
        return false
    end

    if record.value == 0 then   --value为零 则只需要记录一次 
        if self:__checkIsRecorded(record.id) then
            return false
        end
    end

    local recordConditionsRes = self:__getRecordConditionsRes()["1"]
    local currRecordCondition

    if recordType == "attr" then
        currRecordCondition = recordConditionsRes:getAttrTypeConditionsByRecordId(record.id)
        return recordConditionsRes:checkAttrCondition(record.id,self:__getRoleAttr(currRecordCondition.Params))
    elseif recordType == "skill" then
        currRecordCondition = recordConditionsRes:getSkillTypeConditionsByRecordId(record.id)
        return recordConditionsRes:checkSkillCondition(record.id,self:__getSkillLv(currRecordCondition.Params))
    elseif recordType == "item" then
        currRecordCondition = recordConditionsRes:getItemTypeConditionsByRecordId(record.id)
        return recordConditionsRes:checkItemCondition(record.id,self:__getItemCount(currRecordCondition.Params))
    elseif recordType == "tujian" then
        currRecordCondition = recordConditionsRes:gettujianGraspTypeConditionsByRecordId(record.id)
        if currRecordCondition then
            return recordConditionsRes:checkTujianCondition(record.id,self:__getRoleGraspkillNumBySkillType(currRecordCondition.Params))
        else
            currRecordCondition = recordConditionsRes:gettujianSeeTypeConditionsByRecordId(record.id)
            return recordConditionsRes:checkTujianCondition(record.id,self:__getRoleSeeSkillNumBySkillType(currRecordCondition.Params))
        end
    end

    return false
end

--只需记录一次的记录是否已经记录
function AchievementSystem:__checkIsRecorded(recordId)
    for index,record in pairs(self.__serverRecordData) do
        if tonumber(recordId) == tonumber(record.jid) then
            return true
        end
    end

    for index,recordInfo in pairs(self.__clientRecordData) do
        if tonumber(recordId) == tonumber(recordInfo.jid) then
            return true
        end
    end

    return false
end

-- 获取角色属性
function AchievementSystem:__getRoleAttr(attrName)
    return self.__role:getAttr(attrName)
end

--获取角色物品数量
function AchievementSystem:__getItemCount(itemId)
    return self.__role:getItemCount(itemId)
end

--获取角色技能等级
function AchievementSystem:__getSkillLv(skillId)
    return self.__role:getSkillLv(skillId)
end

--获取角色某类型武学见闻数量
function AchievementSystem:__getRoleSeeSkillNumBySkillType(skillType)
    local TuJianUtil = require("app.models.TuJian.TuJianUtil")

    if skillType == "all" then
        return TuJianUtil:getSeeWuXueNum(self.__role)
    else
        return TuJianUtil:getRoleSeeSkillNumBySkillType(skillType,self.__role)
    end
    
end

--获取角色某类型武学已掌握数量
function AchievementSystem:__getRoleGraspkillNumBySkillType(skillType)
    local TuJianUtil = require("app.models.TuJian.TuJianUtil")

    if skillType == "all" then
        return TuJianUtil:getZhangWoWuXueNum(self.__role)
    else
        local skillTab = TuJianUtil:getRoleSkillsTable(self.__role)
        return #skillTab[skillType]
    end
end


-- 获取记录表资源
function AchievementSystem:__getRecordsRes()
    -- 载入资源, 并且校验
    return {
        ["1"] = require("app.models.AchievementSystem.AchievementRecord"),
    }   
end

-- 获取记录触发条件资源
function AchievementSystem:__getRecordConditionsRes()
    -- 载入资源, 并且校验
    return {
        ["1"] = require("app.models.AchievementSystem.AchievementUnlockConditions"),
    }
end

--获取解锁点解锁条件资源
function AchievementSystem:__getUnlockRes()
    -- 载入资源, 并且校验
    return {
        ["1"] = require("script.others.Records")["Unlock"],
    }
end


--判断当前解锁点是否解锁
function AchievementSystem:checkUnlockPointIsUnlock(unlockId)
    local unlockConditions = self:__getUnlockRes()["1"]
    local unlockPointConditions

    for k,v in pairs(unlockConditions) do
        if v.Unlockid == unlockId then
            unlockPointConditions = v
            break
        end
    end

    if not unlockPointConditions then
        print("unlockId :",unlockId," is not found")
        return
    end

    local records_conditions = {}
    local condition_num = 0

    for i = 1, 10 do
        if unlockPointConditions["recordid"..tostring(i)] then
            records_conditions[tostring(unlockPointConditions["recordid"..tostring(i)])] = unlockPointConditions["recordvalue"..tostring(i)]
            condition_num = condition_num + 1
        end
    end

    local unlockRecords = self:getUnlockRecord()

    for k, v in pairs(unlockRecords) do
        if records_conditions[tostring(k)] then
            condition_num = condition_num - 1
            if v < records_conditions[tostring(k)] then
                print("解锁点id：",unlockId,"当前记录点：",k,"记录次数：",v,"需要次数：",records_conditions[tostring(k)])
                return false
            end
        end 
    end

    if condition_num > 0 then
        print("解锁点id",unlockId,"缺少",condition_num,"个记录点")
        return false
    end

    return true
end

--获取解锁点集合
function AchievementSystem:getUnlockPoints()
    local unlockConditions = self:__getUnlockRes()["1"]
    local unlockPoints = {}

    for k,v in pairs(unlockConditions) do
        if self:checkUnlockPointIsUnlock(v.Unlockid) then
            table.insert(unlockPoints,v.Unlockid)
        end
    end

    return unlockPoints
end

--获取解锁点文本
function AchievementSystem:getUnlockText(unlockId)
    local unlockConditions = self:__getUnlockRes()["1"]

    for k,v in pairs(unlockConditions) do
        if tostring(v.Unlockid) == tostring(unlockId) then
            return v.unlockText
        end
    end

    assert(nil,"解锁点资源不存在  unlockId = "..unlockId)
end

------------------------------testFunc---------------------------------
-- 打印服务器解锁记录点
function AchievementSystem:printServerRecordData()
    print("----------打印服务器解锁记录点----------")
    for k,v in pairs(self.__serverRecordData) do
        print("----------------------------")
        Helper:print_lua_table(v)
    end
end

-- 打印本地解锁记录点
function AchievementSystem:printClientRecordData()
    print("----------打印本地解锁记录点----------")
    for k,v in pairs(self.__clientRecordData) do
        print("---------------",v.jid)
    end
end

--打印已经解锁的记录点
function AchievementSystem:printUnlockRecord()
    local nolockPoints = self:getUnlockRecord()
    print("----------打印解锁的记录点----------")
    for k,v in pairs(nolockPoints) do
        print("---------------unlockRecordId",k,v)
    end
end

--打印解锁的解锁点
function AchievementSystem:printUnlockPoints()
    local nolockPoints = self:getUnlockPoints()
    print("----------打印解锁的解锁点----------")
    for k,v in pairs(nolockPoints) do
        print("---------------unlockId",v)
    end
end

--清除上传cd
function AchievementSystem:clearCd()
    self.__lastRecordTime = 0
    self.__lastUpdateTime = 0
    self.__lastUploadTime = 0
end

return NewClass("AchievementSystem", nil, AchievementSystem)
0000000000