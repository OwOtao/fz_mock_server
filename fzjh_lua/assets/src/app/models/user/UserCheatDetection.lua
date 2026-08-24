--@RefType [src.app.models.role.bag.Bag#Bag]
local Bag = require("app.models.role.bag.Bag")
local StorageBox = require("app.models.HomelandModel.FurnitureModel.StorageBox")
--@RefType [src.app.models.role.bag.WareHouse#WareHouse]
local WareHouse = require("app.models.role.bag.WareHouse")

local UserCheatDetection = {}

function UserCheatDetection:checkSaveData()
    local role_data = DataBase:getRoleData()
    if role_data == nil then
        return
    end

    local weight = role_data.weight

    if weight > Bag.getBagMaxCount() then
        Collection:memoryCheat(User:getRoleAttr("userid"), "loginCheck|outOfLimit|weight", weight, Bag.getBagMaxCount())
    end

    local ckLimit = role_data.ckLimit or -1
    local baseCkLimit = role_data.baseCkLimit or -1

    if ckLimit < 0 or baseCkLimit < 0 then
        local role_data_str = table.tostring(role_data)
        Collection:memoryCheat(User:getRoleAttr("userid"), "loginCheck|data_error|" .. tostring(role_data_str), ckLimit, baseCkLimit)
    end

    local storageBoxMaxCapacity = StorageBox.getCkMaxUpgradeCapacityCapacity()
    local wareHouseMaxCapacity = WareHouse.getMaxCount()

    if ckLimit > (storageBoxMaxCapacity + wareHouseMaxCapacity) then
        local ck_str = string.format("(StorageMax:%s/WareHouseMax:%s)", storageBoxMaxCapacity, wareHouseMaxCapacity)
        Collection:memoryCheat(User:getRoleAttr("userid"), "loginCheck|outOfLimit|ckLimit" .. tostring(ck_str), ckLimit, storageBoxMaxCapacity + wareHouseMaxCapacity)
    end

    if baseCkLimit > wareHouseMaxCapacity then
        Collection:memoryCheat(User:getRoleAttr("userid"), "loginCheck|outOfLimit|baseCkLimit", baseCkLimit, wareHouseMaxCapacity)
    end

    Collection:forceUploadCheat()
end

return UserCheatDetection
00