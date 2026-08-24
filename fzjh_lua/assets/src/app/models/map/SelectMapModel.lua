local SelectMapModel = {
    --@desc 当前卷
    _volumeId = "volume_1",
    --@desc 当前Id
    _mapId = "fb01",
    _volumes = {},
    --@desc 向左移动
    DIR_LEFT = 1,
    --@desc 向右移动
    DIR_RIGHT = -1,
    --@desc 不移动
    DIR_NOT = 0
}

function SelectMapModel:initVolume()
    local mapVols = {}

    --@RefType [src.app.models.role.Role#Role]
    local role = User:getRole()

    local m_volume = role:getAttr("m_volume")

    local function initVolData(vol)
        local data = {
            id = vol.id,
            name = vol.name,
            isOpen = false
        }

        if m_volume[vol.id] then
            data.isOpen = true
        end

        return data
    end

    for i, vol in ipairs(Map:getMapVolume()) do
        if tonumber(string.split(vol.id, "volume_")[2]) ~= 0 then
            --@desc 不是隐藏副本需要显示
            table.insert(mapVols, initVolData(vol))
        else
            --@desc 调试模式下显示隐藏副本
            if DEBUG_MODE == 1 then
                local data = initVolData(vol)
                data.isOpen = true
                table.insert(mapVols, data)
            end
        end
    end
    self._volumes = mapVols
end

function SelectMapModel:getNextMapId()
    local map_id_list = Map:getMapIdListInVolume(self._volumeId)

    local nowIndex = Map:getMapIndexInVolume(self._mapId)

    return map_id_list[nowIndex + 1]
end

function SelectMapModel:getPreMapId()
    local map_id_list = Map:getMapIdListInVolume(self._volumeId)

    local nowIndex = Map:getMapIndexInVolume(self._mapId)

    return map_id_list[nowIndex - 1]
end

--@desc 获取当前卷
function SelectMapModel:getCurrVolumeId()
    return self._volumeId
end

--@desc 设置当前卷ID
--@author:Liang SongQiang
--@time:2019-01-04 11:56:00
--@volumeId: 卷Id
function SelectMapModel:setCurrVolumeId(volumeId)
    if volumeId == nil then
        return
    end

    self._volumeId = volumeId
end

--@desc: 设置当前副本ID
--@author:Liang SongQiang
--@time:2019-01-04 11:55:38
--@mapId:副本ID
function SelectMapModel:setCurrMapId(mapId)
    if mapId == nil then
        return
    end

    self._mapId = mapId
end

--@desc: 获取当前副本
--@author:Liang SongQiang
--@time:2019-01-04 11:53:09
function SelectMapModel:getCurrMapId()
    return self._mapId
end

function SelectMapModel:getMapVolume()
    if DEBUG_MODE == 2 then
        self._volumes = {}
    end

    if MapIsEmpty(self._volumes) then
        self:initVolume()
    end

    return self._volumes
end

function SelectMapModel:getVolumeById(volumeId)
    return Map:getVolumeByVolumeId(volumeId)
end

function SelectMapModel:getRefreshTimeDsc(time)
    local dsc = ""

    if time > 0 then
        local second = math.ceil(time % 60)
        local minute = math.floor(time / 60)
        if tonumber(second) < 10 then
            second = "0" .. tostring(second)
        end
        if second == 60 then
            second = "00"
            minute = minute + 1
        end

        dsc = tostring(minute) .. ":" .. tostring(second)
    end

    return dsc
end

--@desc: 获取当前副本详细描述
--@author:Liang SongQiang
--@time:2019-01-04 12:27:57
function SelectMapModel:getDetailDsc()
    return Map:getDefaultMapById(self._mapId).detailDsc
end

--@desc: 获取UI方向 先对比卷的排序再判断副本排序。
--@author:Liang SongQiang
--@time:2019-01-04 15:35:50
--@mapId: 跳转的副本ID
function SelectMapModel:getDirection(mapId)
    if self._mapId == mapId then
        return self.DIR_NOT
    end

    local volumeId = Map:getVolumeIdByMapId(mapId)

    local next_volume_index = Map:getVolumeIndexByVolumeId(volumeId)

    local now_gruop_index = Map:getVolumeIndexByVolumeId(self._volumeId)

    if now_gruop_index > next_volume_index then
        return self.DIR_RIGHT
    elseif now_gruop_index < next_volume_index then
        return self.DIR_LEFT
    elseif now_gruop_index == next_volume_index then
        local next_map_index = Map:getMapIndexInVolume(mapId)
        local now_map_index = Map:getMapIndexInVolume(self._mapId)

        if next_map_index > now_map_index then
            return self.DIR_LEFT
        elseif next_map_index < now_map_index then
            return self.DIR_RIGHT
        end
    end
end

--@desc: 进入地图
--@author:Liang SongQiang
--@time:2019-01-09 15:56:21
function SelectMapModel:entryMap()
    local mapId = self:getCurrMapId()

    HttpManagerEx:getConfigFuben(
        mapId,
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    if data.status == 1 then
                        self:_enterMap(mapId)
                    else
                        PopText("此章节暂未开放，敬请期待")
                    end
                else
                    PopText(errmsg)
                end
            end
        end,
        IS_SHOW_WAITING
    )
end

function SelectMapModel:_enterMap(mapId)
    if "fb205" == mapId then  --平安小镇单独处理
        local PingAnTown = require("app.models.map.PingAnTown")
		PingAnTown:entryTown()
        return 
    end

    local map = Map:getMapById(mapId)
    local mapState = Map:getMapState(mapId)

    if DEBUG_MODE == 2 and mapState == MAP_STATE.NOTOPEN then
        PopText("关卡未解锁，请到商城购买")
        return
    end

    if DEBUG_MODE == 2 then
        if mapState == MAP_STATE.UNLOCK then
            print("未解锁 ：" .. map.entryDesc)
            local unlockDest = Helper:getDef(map.entryDesc, "")
            PopText(map.entryDesc)
            return
        end

        if Map:getMapVersionByMapId(mapId) == EDITOR_MAP_VERSION then
            --@desc 编辑器副本无需刷新
        else
            --@desc 时间判断
            local refreshTime = Map:getMapRefreshTime(mapId)
            if refreshTime > 0 and map._isComingIn == nil then
                local second = math.floor(refreshTime % 60)
                local min = math.floor(refreshTime / 60)
                PopText("副本冷却中，剩余冷却时间 " .. tostring(min) .. " 分" .. tostring(second) .. " 秒")
                return
            else
                --@desc 已超过刷新时间
                if refreshTime < 0 then
                    map = Map:initMapById(mapId)
                end
            end
        end
    end

    -- 播放进入地图动画
    local entryMapLayer = MainControllLayer:getLayer("EntryMapLayer")
    entryMapLayer:maxZ()
    entryMapLayer:show()

    local titleLayer = MainControllLayer:getLayer("TitleLayer")
    titleLayer:hide(true)

    MainControllLayer:getLayer("PrintLayer"):initRichText()
    -- 输出文本
    RichPrint("main", "HIC你进入大车，对车夫吆喝了几句。")
    RichPrint("main", "HIC车夫扬起手中鞭，吆喝道：看车！去" .. tostring(map.name) .. "了。")

    entryMapLayer:delayFunc(
        1,
        function(obj)
            map:setCallBackAndConnect(
                function()
                    local mapLayer = MainControllLayer:getLayer("MapLayer")

                    mapLayer:setMap(map)
                    if Map:getMapVersionByMapId(map.id) == EDITOR_MAP_VERSION and map._isComingIn ~= true then
                        map:refreshBranchEvent()
                    end
                    map._isComingIn = true

                    entryMapLayer:hide(
                        function()
                            RichPrint("main", "HIC你身形一转，跃下马来，姿势十分优美。")
                        end
                    ) -- 隐藏界面

                    -- 释放地图动画层
                    MainControllLayer:removeLayer("EntryMapLayer")

                    MainControllLayer:pushLayer("MapLayer")
                    -- titleLayer:changeTitleUI()

                    MessageCenter:notify("EnterMap",{map=map})
                end
            )
        end
    )
end

--@desc: 重置副本
--@author:Liang SongQiang
--@time:2019-05-09 14:44:20
function SelectMapModel:resetNewMap()
    local mapList = Map:getMapIdListInVolume(self._volumeId)

    local curr_volume_info = Map:getVolumeByVolumeId(self._volumeId)

    local resetMapInfoList = {
        [self._volumeId] = {self._mapId}
    }

    local mapReset = require("script.newmap.mapReset.mapReset")

    local reset_relation_str = mapReset[self._mapId]["mapRelation"]

    if reset_relation_str ~= nil then
        local reset_relation_list = string.split(reset_relation_str, ";")

        for i, info in ipairs(reset_relation_list) do
            local array = string.split(info, ",")

            local volume_id = array[1]

            local map_ids_str = array[2]

            local map_id_list = string.split(map_ids_str, "|")

            if MapIsEmpty(map_id_list) == false then
                if resetMapInfoList[volume_id] == nil then
                    resetMapInfoList[volume_id] = {}
                end

                for _, mapId in ipairs(map_id_list) do
                    table.insert(resetMapInfoList[volume_id], mapId)
                end
            end
        end
    end

    local player = User:getRole()

    local mapStore = player:getAttr("mapStore")

    for volume_id, map_list in pairs(resetMapInfoList) do
        local resetMapIdList = map_list

        for i = #resetMapIdList, 1, -1 do
            local mapId = resetMapIdList[i]

            if player:isMapCompleted(mapId) then
            else
                local currMapStore = mapStore[mapId]
                if MapIsEmpty(currMapStore) == true then
                    table.remove(resetMapIdList, i)
                else
                    local needRemove = true
                    for branchId, currNodeId in pairs(currMapStore) do
                        if currNodeId ~= "origin" then
                            needRemove = false
                            break
                        end
                    end
                    if needRemove == true then
                        table.remove(resetMapIdList, i)
                    end
                end
            end
        end
    end

    local map_count = 0

    for k, v in pairs(resetMapInfoList) do
        map_count = map_count + #v
    end

    if map_count <= 0 then
        PopText("当前副本章节无法重置。")
        return
    end

    HttpManagerEx:getActionTimes(
        "refreshFuben",
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    local totalCost = 0

                    local mapText = ""
                    local resetMapIdList = {}
                    for volume_id, map_list in pairs(resetMapInfoList) do
                        local volume_name = Map:getVolumeByVolumeId(volume_id).name

                        mapText = mapText .. volume_name .. "的"

                        for i, mapId in ipairs(map_list) do
                            local cost = 0
                            if mapReset[mapId] ~= nil then
                                cost = mapReset[mapId]["price"]
                            end

                            totalCost = totalCost + Helper:getDef(cost, 0)
                            local defaultMap = Map:getDefaultMapById(mapId)

                            mapText = mapText .. defaultMap.title .. "，"

                            table.insert(resetMapIdList, mapId)
                        end
                    end

                    mapText = string.sub(mapText, 1, -4)

                    local costText = ""
                    local costTips = "此次免费"
                    if data.num > 0 then
                        costText = "花费" .. totalCost .. "元宝"
                        costTips = totalCost .. "元宝"
                    end

                    local text = "是否确定" .. costText .. "重置" .. mapText .. "？"
                    local DialogGLayer = require("app.views.layer.DialogLayer.DialogGLayer")
                    local dialog = DialogGLayer:getInstance()
                    dialog:initPanel("")
                    dialog:setText_desc_1(text)

                    dialog:setText_desc_4(costTips)
                    dialog:SetVisible()
                    dialog:setButton2(EMPTY_FUNC)
                    dialog:setButton1(
                        function()
                            local WaitingLayer = require("app.views.layer.PopLayer.WaitingLayer")
                            local waitingLayer = WaitingLayer:createInRunningScene()

                            HttpManagerEx:refreshFubenByYuanBao(
                                resetMapIdList,
                                function(status, errcode, errmsg, refreshData)
                                    if status == 200 then
                                        -- return true
                                        if errcode == 0 then
                                            for _, mapId in ipairs(resetMapIdList) do
                                                Map:resetMapById(mapId)
                                            end

                                            local pop = "重置成功。"

                                            if refreshData.remove_yuanbao > 0 then
                                                pop = "重置成功，元宝: -" .. refreshData.remove_yuanbao
                                            end
                                            PopText(pop)
                                        else
                                            PopText(errmsg)
                                        end
                                    else
                                        -- return false
                                        PopText(errmsg)
                                    end
                                    waitingLayer:hide()
                                end,
                                IS_SHOW_WAITING
                            )
                        end
                    )
                else
                    PopText(errmsg)
                end
            end
        end,
        IS_SHOW_WAITING
    )
end

return SelectMapModel
000000000000000