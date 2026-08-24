local RoomUpgradeModel = {}

--@RefType [src.app.models.HomelandModel.HomelandRoomUtil#HomelandRoomUtil]
local HomelandRoomUtil = require("app.models.HomelandModel.HomelandRoomUtil")

--@desc:设置mid
function RoomUpgradeModel:setMid(mid)
    self.mid = mid
end

function RoomUpgradeModel:setCurrRoom(room)
    self._currRoom = room
end

--@desc 设置副本
function RoomUpgradeModel:setCurrMap(map)
    self._map = map
end

--@desc: 设置花费的价格
function RoomUpgradeModel:setCost(value)
    if type(value) ~= "number" then
        value = 0
    end

    self.cost = value

end

--@desc: 设置当前房间的数据
function RoomUpgradeModel:setCurrFjAttr(Attr)
    self.CurrFjAttr = Attr
end

--@desc: 设置改造前房间的数据
function RoomUpgradeModel:setLastFjAttr(Attr)
    self.LastFjAttr = Attr
end

--@desc: 通知服务器处理
function RoomUpgradeModel:upgradeRoom(map,currFjAttr,lastFjAttr,callback)
    if map == nil or currFjAttr == nil or lastFjAttr == nil then
        assert(false,"RoomUpgradeModel:upgradeRoom 检查参数")   
    end
    self.mid = ""
    self.fj_update = {}
    self.jj_update = {}
    self.pr_update = {}
    self.CurrFjAttr = {}
    self._currRoom = nil
    self.cost = 0

    if map.mid == nil then
        print("该副本不可拆除房间。")
        return
    end

    self:setMid(map.mid)

    self:setCurrMap(map)

    self:setCurrRoom(map:getRoomById(map:getCurrRoomId()))

    self:setCurrFjAttr(currFjAttr)

    self:setLastFjAttr(lastFjAttr)

    self:setCost(self.CurrFjAttr.upgradecost)

    local fjId = self._currRoom.id
    HttpManagerEx:transformRoom(fjId,self.mid,self.CurrFjAttr,self.cost,nil,
    function(status, errcode, errmsg, data)
        if status == 200 and errcode == 0 then
            self.CurrFjAttr.roomType = self.CurrFjAttr.roomid 
            Helper:tableCover(self._map.room[fjId],self.CurrFjAttr)
            self._map.room[fjId].dsc = self.CurrFjAttr.roomdsc

            self:processPrUpdateData()

            do
                --@desc 增加内置家具
                --@RefType [src.app.models.HomelandModel.FurnitureModel.FurnitureModel#FurnitureModel]
                local FurnitureModel = require("app.models.HomelandModel.FurnitureModel.FurnitureModel")
                if DEBUG_MODE == 1 then
                    Helper:print_lua_table(data)
                end
                if data.specialFurn and not MapIsEmpty(data.specialFurn) then
                    for k,furn in pairs(data.specialFurn) do
                        furn.fjId = fjId
                        local itemBox = FurnitureModel:initFurnitureForUserMap(map,furn)

                        self._map:createRole(itemBox)
                        self._map:addRoomRole(fjId, itemBox.id, true)
                        --刷新家具计数
                        self._map:addFurTypeCount(itemBox.itype,1)
                    end
                end
            end
            local HomelandRoomUtil = require("app.models.HomelandModel.HomelandRoomUtil")
            HomelandRoomUtil:updateRoomAttr(self._map,self._map.room[fjId])

            --@desc 刷新计数
            self._map:addRoomTypeCount(self.LastFjAttr.roomid, -1)
            self._map:addRoomTypeCount(self.CurrFjAttr.roomid, 1)
            --@RefType [src.app.models.HomelandModel.HomelandUtil#HomelandUtil]
            local HomelandUtil = require("app.models.HomelandModel.HomelandUtil")
            HomelandUtil:updateRoomFlag(self._map)

            if self.LastFjAttr.roomname == "空房" then
                local text = "你将空房改造的要求告诉给管家，管家沉吟一番，然后点点头，随即领命而去。很快，管家购置来木材、石料等物资，并雇了几个泥瓦匠，热火朝天地干了起来。很快，空房不复之前的模样，新的房间慢慢地有模有样了。"
                text = text.."\n".."HIY"..self.CurrFjAttr.roomname.."的数量+1NOR"
                RichPrint("main",text)
            end

            self._map._mapLayer:delayRefreshMap()
            PopText("改造成功！")
            RichPrint("main","您花费了"..data.remove_point.."银票。")
            
            if callback then
                callback(data)
            end

        else
            PopText(errmsg)
        end
    end, IS_SHOW_WAITING)
end


function RoomUpgradeModel:processPrUpdateData()
    local currMap = self._map
    local currRoomType = self.CurrFjAttr.roomid
    local lastRoomType = self.LastFjAttr.roomid
    local fjId = self._currRoom.id
	--@RefType [src.app.models.HomelandModel.HomelandRoleUtil#HomelandRoleUtil]
	local HomelandRoleUtil = require("app.models.HomelandModel.HomelandRoleUtil")
    local PuRenModel = require("app.models.HomelandModel.HomelandRoleModel.PuRenModel")

    local up_data = {}

    local npcs = currMap:getRoomRoleList(fjId)

    --处理本房间的人和物
    for i = #npcs, 1, -1 do
        local npcId = npcs[i]
        local npc = currMap:getRole(npcId)
        if npc.fjId == fjId then
            if npc.type == "role" then
                local rwId = npc.id
                local rooms = currMap:getRoomMap()
                local finalFjId
                for roomId, room in pairs(rooms) do
                    --有同类型的房间且房间没有被锁
                    if room and room.lock ~= true and roomId ~= fjId and room.roomType == lastRoomType then
                        --房间人物没有达到上限
                        if HomelandRoomUtil:checkRoomRolesIsLimet(roomId, currMap) == false then
                            currMap:removeRoomRole(npc.fjId,npcId,false)
                            table.insert( up_data,{rwId = npcId,fjId = roomId ,extra = {}})
                            npc.fjId = roomId
                            currMap:addRoomRole(roomId,npcId)
                            PuRenModel:updateMapPuRenInfo("changeRoom", currMap, npcId, roomId)
                            break
                        end
                    end
                end

                local DaMenId = HomelandRoomUtil:getDaMenRoomId(currMap)
                --房间人物移动至大门
                if npc.fjId == fjId then
                    currMap:removeRoomRole(npc.fjId,npcId,false)
                    table.insert( up_data,{rwId = npcId,fjId = DaMenId ,extra = {}})
                    npc.fjId = DaMenId
                    currMap:addRoomRole(DaMenId,npcId)
                    PuRenModel:updateMapPuRenInfo("changeRoom", currMap, npcId, DaMenId)
                end

                if npc.cType ~= "管家" then
                    self:initRoleConditions(npc,currMap)
                end
            elseif npc.type == "item" then
                currMap:removeRoomRole(npc.fjId,npcId,false)
                -- 刷新家具计数
                currMap:addFurTypeCount(npc.itype,-1)
            end
        end
    end

    --处理其它房间的人
    local roleTypeAttr = HomelandRoleUtil:getRoleTypeDataByRoomType(currRoomType)
	if roleTypeAttr then
        local peopletYpe = roleTypeAttr.peopletYpe

        local mapRole = currMap:getRoles()
        for npcId,npc in pairs(mapRole) do
            if npc.fjId ~= fjId and npc.type == "role" and npc.jobType and npc.jobType == peopletYpe  then
                if HomelandRoomUtil:checkRoomRolesIsLimet(fjId,currMap) == false then
                    local isRight = HomelandRoleUtil:roleIsInCurrRoom(currMap,npc)
                    if isRight == false then
                        currMap:removeRoomRole(npc.fjId,npcId,false)
                        table.insert( up_data,{rwId = npcId,fjId = fjId,extra = {}})
                        npc.fjId = fjId
                        currMap:addRoomRole(fjId,npcId)
                        PuRenModel:updateMapPuRenInfo("changeRoom", currMap, npcId, fjId)
                    end
                end
            end
        end
	end

	local room = currMap:getRoomById(fjId)
	local rolesTab = room.roleList
	
	for i,npcId in ipairs(rolesTab) do
		local npc = currMap:getRole(npcId)
		if npc.type == "role" and npc.cType ~= "管家"  then
			self:initRoleConditions(npc,currMap)
		end
	end

	if MapIsEmpty(up_data) then
		return
	end

	HomelandRoleUtil:updataRoleAttr(self.mid,up_data)
end

--初始化移动的人物的条件结果
function RoomUpgradeModel:initRoleConditions(npc,currMap)
    if npc == nil then
        return
    end
    npc.conditionAndResults = {}
    local HomelandRoleTemplate = require("app.models.HomelandModel.HomelandRoleModel.HomelandRoleTemplate")
    HomelandRoleTemplate:initRoleConditions(npc, currMap)
end


return RoomUpgradeModel
00000000