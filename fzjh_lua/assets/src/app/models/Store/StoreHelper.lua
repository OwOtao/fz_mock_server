local StoreHelper = {}
local StoreConfig = require("script.store.storeConfig")["Sheet1"]

--由于师门副本不刷新，需要记录师门副本商人状态
local familyMapNpcState = {}

function StoreHelper:initMapNewStore(map)
    for npcId, config in pairs(StoreConfig) do
        local storeMapInfo = config.location

        if map.id == storeMapInfo[1] then
            local npc = map:getRole(npcId)
            npc.isNewStore = true
            npc.roleCanSellItem = config.sell
            npc.bagType = config.Backpacktype
            
            if self:checkStoreIsInTime(npcId) == false then
                if Map:getMapVersionByMapId(map.id) == EDITOR_MAP_VERSION then
                    if MapIsEmpty(npc.operations) == false then
                        for i, operation in ipairs(npc.operations) do
                            if operation.operationButton == "交易" and operation.isVisible ~= 0 then
                                familyMapNpcState[npcId] = operation.isVisible
                                operation.isVisible = 0
                                break
                            end
                        end
                    end
                else
                    npc.canSale = 0
                end
            else
                if Map:getMapVersionByMapId(map.id) == EDITOR_MAP_VERSION then
                    if MapIsEmpty(npc.operations) == false then
                        for i, operation in ipairs(npc.operations) do
                            if operation.operationButton == "交易" and familyMapNpcState[npcId] then
                                operation.isVisible = familyMapNpcState[npcId]
                                break
                            end
                        end
                    end
                end
            end
        end
    end
end

function StoreHelper:checkIsNewStore(npc)
    return npc.isNewStore == true
end

function StoreHelper:checkStoreIsInTime(npcId)
    local config = StoreConfig[npcId]

    if config then
        local startTime = config.start_time
        local endTime = config.end_time

        if not startTime or not endTime then
            return true
        end

        local stratTimeArray = string.split(tostring(startTime), ";")
        local stratDate = stratTimeArray[1]
        local stratHour = Helper:getDef(stratTimeArray[2],"12")
        local stratMinute = Helper:getDef(stratTimeArray[3],"00")

        local endTimeArray = string.split(tostring(endTime), ";")
        local endDate = endTimeArray[1]
        local endHour = Helper:getDef(endTimeArray[2],"24")
        local endMinute = Helper:getDef(endTimeArray[3],"00") 

        local nowTime = GetTime()
        local stratTime,endTime

        if type(tonumber(stratDate)) == "number" then
            stratTime = Helper:getTimeStampWithStringDate(tostring(stratDate), tonumber(stratHour)) + tonumber(stratMinute)*60
        else
            error(npcId.."开始时间格式错误")
        end

        if type(tonumber(endDate)) == "number" then
            endTime = Helper:getTimeStampWithStringDate(tostring(endDate), tonumber(endHour)) + tonumber(endMinute)*60
        else
            error(npcId.."结束时间格式错误")
        end

        if nowTime >= stratTime and nowTime <= endTime then
            return true
        end
    end

    return false
end

function StoreHelper:PopEndText(npcId)
    PopText("交易时间已结束")
end

function StoreHelper:getStoreLocation(npcId)
    local config = StoreConfig[npcId]
    assert(config, "StoreHelper:getStoreLocation npcId is error, npcId:"..tostring(npcId))
    return config.location
end

function StoreHelper:getStoreRefreshText(npcId)
    for storeId, config in pairs(StoreConfig) do
        if storeId == npcId then
            local refreshData = config.Refreshtime
            local text = ""
            if #refreshData > 1 then
                text = switch(refreshData[1],{
                    [1] = function()
                        return ""
                    end,
                    [2] = function ()
                        return "每日"..tostring(refreshData[2]).."点"
                    end,
                    [3] = function ()
                        return "每周"..tostring(refreshData[2])..tostring(refreshData[3]).."点"
                    end,
                    [4] = function ()
                        return "每月"..tostring(refreshData[2]).."日"..tostring(refreshData[3]).."点"
                    end,
                    [5] = function ()
                        return "每"..tostring(refreshData[2]).."月"..tostring(refreshData[3]).."日"..tostring(refreshData[4]).."点"
                    end,
                    [6] = function ()
                        local timeStr = refreshData[2]
                        local time1 = string.sub(timeStr, 1 , 4)
                        local time2 = string.sub(timeStr, 5 , 6)
                        local time3 = string.sub(timeStr, 7 , 8)
                        local time4 = string.sub(timeStr, 9 , 10)
                        
                        return tostring(time1).."年"..tostring(time2).."月"..tostring(time3).."日"..tostring(time4).."点"
                    end,
                    default = ""
                })
            end
            return text 
        end
    end
end

return StoreHelper0000000000000000