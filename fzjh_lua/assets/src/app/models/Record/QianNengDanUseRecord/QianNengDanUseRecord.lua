local QianNengDanUseRecord = {
    __recordStartTime = 1722441600 --2024/08/01 零点
}

-- --潜能丹使用记录
-- qianNengDanRecords = {
-- 	qndolduse = 0,
-- 	qndolduselv = 0,
-- 	qndoldusetime = nil,
-- 	qnd500use = 0,
-- 	qnd1000use = 0,
-- 	qnd1500use = 0,
-- 	qnd2000use = 0,
-- 	qnd2600use = 0,
-- 	qnd3400use = 0,
-- 	qnd4400use = 0,
-- 	qnd5500use = 0,
-- 	qnd6500use = 0,
-- }

local function getTagByLv(lv)
    if lv < 1 then
        error("QianNengDanUseRecord getTagByLv lv is error")
    end

    local tag = "qnd6500use"

    if lv <= 500 then
        tag = "qnd500use"
    elseif lv <= 1000 then
        tag = "qnd1000use"
    elseif lv <= 1500 then
        tag = "qnd1500use"
    elseif lv <= 2000 then
        tag = "qnd2000use"
    elseif lv <= 2600 then
        tag = "qnd2600use"
    elseif lv <= 3400 then
        tag = "qnd3400use"
    elseif lv <= 4400 then
        tag = "qnd4400use"
    elseif lv <= 5500 then
        tag = "qnd5500use"
    end

    return tag
end

local function getQndolduse(recordStartTime, roleCreateTime)
    return math.ceil(recordStartTime/86400 - roleCreateTime/86400) * math.min(860/(recordStartTime/86400 - roleCreateTime/86400),1.2)
end

function QianNengDanUseRecord:initBaseData(role)
    local roleCreateTime = role:getAttr("createTime")

    if not roleCreateTime then
        return
    end

    local qianNengDanRecords = role:getAttr("qianNengDanRecords")

    if MapIsEmpty(qianNengDanRecords) then
        qianNengDanRecords = {
            version = 1 
        }
    end

    if qianNengDanRecords.version == 1 then
        qianNengDanRecords.qndoldusetime = GetTime()

        if roleCreateTime < self.__recordStartTime then
            qianNengDanRecords.qndolduse = getQndolduse(self.__recordStartTime, roleCreateTime)
            qianNengDanRecords.qndolduselv = role:getLv()
        else
            qianNengDanRecords.qndolduse = 0
            qianNengDanRecords.qndolduselv = 0
        end

        if qianNengDanRecords.qndolduselv > 0 and qianNengDanRecords.qndolduse > 0 then
            local tag = getTagByLv(qianNengDanRecords.qndolduselv)

            if not qianNengDanRecords[tag] then
                qianNengDanRecords[tag] = 0
            end

            qianNengDanRecords[tag] = qianNengDanRecords[tag] + qianNengDanRecords.qndolduse
        end

        qianNengDanRecords.version = 2

        role:setAttr("qianNengDanRecords", qianNengDanRecords)
    end
end

function QianNengDanUseRecord:record(role, num)
    local lv = role:getLv()
   
    local tag = getTagByLv(lv)

    local qianNengDanRecords = role:getAttr("qianNengDanRecords")

    if MapIsEmpty(qianNengDanRecords) then
        self:initBaseData(role)
        qianNengDanRecords = role:getAttr("qianNengDanRecords")
    end

    if not qianNengDanRecords[tag] then
        qianNengDanRecords[tag] = 0
    end

    qianNengDanRecords[tag] = qianNengDanRecords[tag] + num

    role:setAttr("qianNengDanRecords", qianNengDanRecords)
end

--测试接口
function QianNengDanUseRecord:testSetStartRecordTime(time)
    self.__recordStartTime = time
end

function QianNengDanUseRecord:testClearBaseData(role)
    local qianNengDanRecords = role:getAttr("qianNengDanRecords")

    if MapIsEmpty(qianNengDanRecords) == false then
        role:setAttr("qianNengDanRecords", {})
    end
end

return QianNengDanUseRecord
00000000000