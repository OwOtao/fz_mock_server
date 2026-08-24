local RoomRemoveModel = {
    mid = "",
    fj_update = {},
    jj_update = {},
    pr_update = {},
    cost = {
        value = 0,
        unit = "yinpiao"
    }
}

--@RefType [src.app.models.HomelandModel.HomelandRoomUtil#HomelandRoomUtil]
local HomelandRoomUtil = require("app.models.HomelandModel.HomelandRoomUtil")

--@desc:设置mid
function RoomRemoveModel:setMid(mid)
    self.mid = mid
end

function RoomRemoveModel:setCurrRoom(room)
    self._currRoom = room
end

--@desc 设置要拆除的副本
function RoomRemoveModel:setCurrMap(map)
    self._map = map
end

--@desc 支持的货币
local cost_unit = {
    ["yinpiao"] = true
}
--@desc: 设置花费的价格
function RoomRemoveModel:setCost(value, unit)
    if type(value) ~= "number" then
        value = 0
    end

    if unit == nil or cost_unit[unit] ~= true then
        unit = "yinpiao"
    end

    self.cost.value = value

    self.cost.unit = unit
end

local transform = {
    up = "down",
    down = "up",
    left = "right",
    right = "left",
    leftUp = "rightDown",
    leftDown = "rightUp",
    rightDown = "leftUp",
    rightUp = "leftDown"
}
--@desc: 初始化拆除要变更的房间数据
function RoomRemoveModel:initRoomUpdateData()
    local room_link = self._currRoom.link

    if MapIsEmpty(room_link) then
        return
    end

    self.fj_update[self._currRoom.id] = {isdeleted = "Y"}
    for _, dir in pairs(transform) do
        self.fj_update[self._currRoom.id][dir] = ""
    end

    --@desc 请求服务器清除相邻房间的索引
    for dir, roomId in pairs(room_link) do
        self.fj_update[roomId] = {
            [transform[dir]] = ""
        }
        self._sideRoomId = roomId
    end
end

--@desc: 初始化拆除要变更的房间中仆人和家具的数据
function RoomRemoveModel:initNpcAndFurUpdateData()
    local npcs = self._map:getRoomRoleList(self._currRoom.id)

    local addPrCount = {}

    for i = #npcs, 1, -1 do
        local npcId = npcs[i]
        local npc = self._map:getRole(npcId)
        if npc.fjId == self._currRoom.id then
            if npc.type == "role" then
                local rwId = npc.id
                local finalFjId = self._sideRoomId
                local rooms = self._map:getRoomMap()
                for fjId, room in pairs(rooms) do
                    if
                        room and room.lock ~= true and fjId ~= self._currRoom.id and
                            room.roomType == self._currRoom.roomType
                     then
                        if HomelandRoomUtil:checkRoomRolesIsLimet(fjId, self._map, addPrCount) == false then
                            finalFjId = fjId
                            if addPrCount[fjId] and type(addPrCount[fjId]) == "number" then
                                addPrCount[fjId] = addPrCount[fjId] + 1
                            else
                                addPrCount[fjId] = 1
                            end
                            break
                        end
                    end
                end
                self.pr_update[rwId] = {fjId = finalFjId}
                local PuRenModel = require("app.models.HomelandModel.HomelandRoleModel.PuRenModel")
                PuRenModel:updateMapPuRenInfo("changeRoom", self._map, rwId, finalFjId)
            elseif npc.type == "item" then
                local idstr = string.split(npc.id, "_")
                local id = idstr[2]
                if id ~= nil then
                    self.jj_update[id] = {isdeleted = "Y"}
                end
            end
        end
    end
end

--@desc: 通知服务器处理
function RoomRemoveModel:removeRoom(map, roomId, callback)
    self.mid = ""
    self.fj_update = {}
    self.jj_update = {}
    self.pr_update = {}
    self._sideRoomId = nil
    self._currRoom = nil

    self.cost = {
        value = 0,
        unit = "yinpiao"
    }
    if map.mid == nil then
        print("该副本不可拆除房间。")
        return
    end

    self:setMid(map.mid)

    self:setCurrMap(map)

    self:setCurrRoom(self._map:getRoomById(roomId))

    self:initRoomUpdateData()

    self:initNpcAndFurUpdateData()

    HttpManagerEx:updateHomeAttr(
        self.mid,
        self.fj_update,
        self.pr_update,
        self.jj_update,
        self.cost,
        function(status, errcode, errmsg, data)
            if 200 == status then
                if 0 == errcode then
                    if callback then
                        callback()
                    end

                    local npcs = self._map:getRoomRoleList(self._currRoom.id)
                    for i = #npcs, 1, -1 do
                        local npcId = npcs[i]
                        local npc = self._map.roles[npcId]
                        self._map:removeRoomRole(self._currRoom.id, npcId)
                        if npc.type == "role" then
                            if self.pr_update[npcId] then
                                local joinfjId = self.pr_update[npcId].fjId
                                self._map:addRoomRole(joinfjId, npcId)
                                npc.fjId = joinfjId
                                local HomelandRoleTemplate =
                                    require("app.models.HomelandModel.HomelandRoleModel.HomelandRoleTemplate")
                                npc.conditionAndResults = {}
                                HomelandRoleTemplate:initRoleConditions(npc, self._map)
                            else
                                self._map:addRoomRole(self._sideRoomId, npcId)
                            end
                        elseif npc.type == "item" then
                            --@desc 刷新家具计数
                            self._map:addFurTypeCount(npc.itype,-1)
                        else
                        end
                    end

                    local toRoomId, toDir
                    for dir, roomId in pairs(self._currRoom.link) do
                        self._map.room[roomId][transform[dir]] = nil
                        self._map.room[roomId].link[transform[dir]] = nil
                        toRoomId = roomId
                        toDir = dir
                    end

                    --@desc 刷新计数
                    self._map:addRoomTypeCount(self._currRoom.roomType, -1)
                    --@RefType [src.app.models.HomelandModel.HomelandUtil#HomelandUtil]
                    local HomelandUtil = require("app.models.HomelandModel.HomelandUtil")
                    HomelandUtil:updateRoomFlag(self._map)
                    

                    local role = User:getRole()
                    MainControllLayer:getLayer("MapLayer"):entryRoom(self._currRoom.id, toRoomId, toDir)
                    self._map.room[self._currRoom.id] = nil

                    MainControllLayer:getLayer("MapLayer"):delayRefreshMap()
                    PopText("拆除成功!")
                else
                    PopText("拆除失败！")
                    print("errcode = " .. errcode, "errmsg : " .. errmsg)
                end
            else
                PopText("网络请求出错,请换个网络环境再试!")
            end
        end,
        IS_SHOW_WAITING
    )
end

return RoomRemoveModel
00