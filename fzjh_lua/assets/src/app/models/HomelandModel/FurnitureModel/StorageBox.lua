local StorageBox = {}

local boxRes = requireWithEncrypt("script.others.familylist")["储物箱"]

local HAS_MAX_STORAGE_BOX = 6

local maxCount = nil

function StorageBox:getBox(boxId)
    return boxRes[boxId] or {}
end

function StorageBox:getBoxName(boxId)
    local box = self:getBox(boxId)
    return box.name or ""
end

function StorageBox:getBoxDesc(boxId)
    local box = self:getBox(boxId)
    return box.dsc or ""
end

function StorageBox:getAddCapacity(boxId)
    local box = self:getBox(boxId)

    return tonumber(box.addCapacity) or 0
end

function StorageBox.getCkMaxUpgradeCapacityCapacity()
    if maxCount ~= nil then
        return maxCount
    end

    maxCount = 0

    local maxCapactiy = 0
    for k, v in pairs(boxRes) do
        if v.addCapacity > maxCapactiy then
            maxCapactiy = v.addCapacity
        end
    end

    maxCount = maxCapactiy * HAS_MAX_STORAGE_BOX

    return maxCount
end

function StorageBox.getCanBuyMaxCount()
    return HAS_MAX_STORAGE_BOX
end

return StorageBox
0000000000000000