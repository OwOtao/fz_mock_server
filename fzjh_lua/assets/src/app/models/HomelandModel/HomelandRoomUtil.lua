local HomelandRoomUtil = {}

local HomelandRoleUtil = require("app.models.HomelandModel.HomelandRoleUtil")
local Skill = require("app.models.skill.Skill")
local familytype = require("script.others.familytype")
local familylist = requireWithEncrypt("script.others.familylist")
local FangQiModel = require("app.models.HomelandModel.FangQiModel")

local hxList = familytype["户型总览"]
local duilianList = familylist["对联"]
local doorListMap = familylist["大门信息"]
local normalList = familylist["普通房间"]
local specialList = familylist["特殊房屋"]
local fangqiMoBan = familylist["房契模板"]
local speciaRoomTypeList = familylist["特殊房间类型"]

local function initSpecialList()
    for k,v in pairs(specialList) do
        v.name = v.roomname
    end
end

local function initNormalList()
    for k,v in pairs(normalList) do
        v.roomdsc = v.desc
    end
end

initNormalList()
initSpecialList()

--获取普通房屋资源配表
function HomelandRoomUtil:getNormalRoomAttr(roomType)
    for k, v in pairs(normalList) do
        if v.roomid == roomType then
            return v
        end
    end

    if DEBUG_MODE == 1 then
        print("没有找到对应普通房间",roomType)
    end
end

--获取特殊房屋资源配表
--roomType 当前房屋编号
function HomelandRoomUtil:getSpeciaRoomAttr(roomType)
    for k, v in pairs(specialList) do
        if v.roomid == roomType then
            return v
        end
    end
    
    if DEBUG_MODE == 1 then
        print("没有找到对应特殊房间",roomType)
    end
end

--房间是否可改造
--upgrade1 0不能改造   1能改造
--return true or false
function HomelandRoomUtil:roomIsRemould(roomType)
    if self:roomIsSpecial(roomType) then
        local roomAttr = self:getSpeciaRoomAttr(roomType)
        local upgrade1 = 0
        if roomAttr then
            upgrade1 = roomAttr.upgrade1
        end
        if upgrade1 == 1 then
            return true
        end
        return false
    else
        return true
    end
end

--获取房间家具存放上限
function HomelandRoomUtil:getRoomFurnitureLimit(roomType)
    local furniturelimit = 0
    local roomAttr
    if self:roomIsSpecial(roomType) then
        roomAttr = self:getSpeciaRoomAttr(roomType)
    else
        roomAttr = self:getNormalRoomAttr(roomType)
    end

    return Helper:getDef(tonumber(roomAttr.furniturelimit), 0)
end

--@desc: 获取房间里面有多少家具
--@author:Liang SongQiang
--@time:2018-06-08 14:58:12
--@map:[src.app.models.map.BaseMap#BaseMap]
--@roomId: 房间ID
function HomelandRoomUtil:getRoomFurnitureCount(map, roomId)
    local currRoom = map:getRoomById(roomId)

    local count = 0
    if MapIsEmpty(currRoom.roleList) then
        return 0
    end

    for k, v in pairs(currRoom.roleList) do
        local obj = map:getRole(v)
        if obj.jjId then
            count = count + 1
        end
    end

    return count
end

--房间是否可拆除
--普通房间可以拆除，特殊房间读取字段dismantle 0不能   1能
--return true or false
function HomelandRoomUtil:roomIsDismantle(roomType)
    if not self:roomIsSpecial(roomType) then
        return true
    end

    local roomAttr = self:getSpeciaRoomAttr(roomType)
    local dismantle = 0
    if roomAttr then
        dismantle = roomAttr.dismantle
    end
    if dismantle == 1 then
        return true
    end
    return false
end

--@desc: 检查该房间是否可以放置该家具
--@author:Liang SongQiang
--@time:2018-06-08 16:47:41
--@roomType:房间类型
--@furnitureType: 家具类型
function HomelandRoomUtil:checkCanPlaceFurnitureType(roomType, furnitureType)
    local roomAttr = self:getSpeciaRoomAttr(roomType)

    --@desc 不是特殊房间
    if not roomAttr then
        return true
    end

    --@desc 没有限制
    if roomAttr.flimit == nil then
        return true
    end
    
    local f_limit_list = string.split(roomAttr.flimit, ";")
    if MapIsEmpty(f_limit_list) then
        return true
    end

    for k, v in pairs(f_limit_list) do
        if tonumber(v) == furnitureType then
            return true
        end
    end

    return false
end

-- 获取大门资源配表
function HomelandRoomUtil:getDoorAttr(doorid)
    for k, v in pairs(doorListMap) do
        if v.doorid == doorid then
            return v
        end
    end
end

-- 获取对联资源配表
function HomelandRoomUtil:getDuilianAttr(duilianId)
    for k, v in pairs(duilianList) do
        if v.id == duilianId then
            return v
        end
    end
end

--能否进入大门
function HomelandRoomUtil:canEnterTheDoor(currDoorId)
    if self:skillCondition(currDoorId) and self:attrCondition(currDoorId) then
        return true
    else
        return false
    end
end

function HomelandRoomUtil:attrCondition(currDoorId)
    if currDoorId == nil then
        assert(nil, "HomelandRoomUtil:attrCondition 参数错误")
    end
    local role = User:getRole()
    local currDoorAttr = self:getDoorAttr(currDoorId)

    local caozuotiaojian = currDoorAttr.caozuotiaojian

    if caozuotiaojian then
        local caozuotiaojianAttr = string.split(caozuotiaojian, ";")
        if #caozuotiaojianAttr ~= 3 then
            assert(nil, "判断条件资源格式不匹配 id = " .. currDoorId)
        end
        local attr = caozuotiaojianAttr[1]
        local logic = caozuotiaojianAttr[2]
        local value = caozuotiaojianAttr[3]

        if Helper:compareTwoNumberWithCN(role:getAttr(attr), value, logic) ~= true then
            return false
        else
            return true
        end
    end
    return true
end

function HomelandRoomUtil:skillCondition(currDoorId)
    if currDoorId == nil then
        assert(nil, "HomelandRoomUtil:skillCondition 参数错误")
    end
    local role = User:getRole()
    local currDoorAttr = self:getDoorAttr(currDoorId)

    local caozuotiaojian1 = currDoorAttr.caozuotiaojian1

    if not caozuotiaojian1 then
        return true
    end

    local caozuotiaojianAttr1 = string.split(caozuotiaojian1, ";")
    if #caozuotiaojianAttr1 ~= 3 then
        assert(nil, "判断条件资源格式不匹配 id = " .. currDoorId)
    end
    local skillId = caozuotiaojianAttr1[1]
    local logic = caozuotiaojianAttr1[2]
    local value = caozuotiaojianAttr1[3]

    local skill = Skill:getSkill(skillId)
    local roleSkill = role:getSkill(skillId)
    local skillLv
    if MapIsEmpty(skill) == true then
        assert(nil, "没有该武功信息")
    elseif MapIsEmpty(roleSkill) == true then
        return false
    else
        skillLv = Skill:getLv(roleSkill.exp)
    end
    if Helper:compareTwoNumberWithCN(skillLv, value, logic) ~= true then
        return false
    else
        return true
    end

    return true
end

--房间是否可召唤管家
--普通房间可以召唤，特殊房间读取字段callup 0不能   1能
--return true or false
function HomelandRoomUtil:roomIsCallup(roomType)
    if self:roomIsSpecial(roomType) then
        local roomAttr = self:getSpeciaRoomAttr(roomType)
        local callup = 0
        if roomAttr then
            callup = roomAttr.callup
        end
        if callup == 1 then
            return true
        end
        return false
    else
        return true
    end
end

--根据忠诚度获取当前副本普通房间和特殊房间总上限
function HomelandRoomUtil:getCommonAndSpecialroomLimit(fidelity)
    if fidelity == nil then
    	return
    end
    local commonRoomcount = 0
    local specialRoomcount = 0
    local roomList = {
        [1] = {common = 0, special = 0},
        [2] = {common = 0, special = 0},
        [3] = {common = 0, special = 0},
        [4] = {common = 15, special = 15},
        [5] = {common = 17, special = 17},
        [6] = {common = 21, special = 21},
        [7] = {common = 35, special = 35}
    }
    local lv = HomelandRoleUtil:getFidelityLv(fidelity)
    print("lv = ", lv)
    commonRoomcount = roomList[lv].common
    specialRoomcount = roomList[lv].special

    return commonRoomcount, specialRoomcount
end

--获取当前副本特殊房间和普通房间的数量
function HomelandRoomUtil:getCurrMapCommonAndSpecialroomCount()
    local normalCount = 0
    local specialCount = 0
    local role = User:getRole()
    local currMap = role:getCurrMap()
    local mapRooms = currMap.room

    for k, v in pairs(mapRooms) do
        local roomType = v.roomType
        if HomelandRoomUtil:roomIsSpecial(roomType) then
            specialCount = specialCount + 1
        else
            normalCount = normalCount + 1
        end
    end
    return normalCount, specialCount
end
--判断当前房间是特殊房间还是普通房间
--return true or false
function HomelandRoomUtil:roomIsSpecial(roomType)
    if roomType == nil then
        return
    end

    for k, v in pairs(specialList) do
        if v.roomid == roomType then
            return true
        end
    end
    return false
end

--通过户型id获取资源配表
function HomelandRoomUtil:getHuxinAttr(hxId)
    for k, v in pairs(hxList) do
        if v.hxId == hxId then
            return v
        end
    end
end

--获得额外提升的房间建造上限
function HomelandRoomUtil:getExtraRoomLimitNum(map,roomtype)
    if roomtype == nil or map == nil then
        return 0
    end
    local num = 0
    switch(roomtype,{
        ["客房"] = function()
            if map:getRoomCountByType("tsfangjian021") > 0 then
                num = 2
            end
        end
    })

    return num
end
--判断特殊房间是否达到建造上限
--roomtype 房间类型(中文)
function HomelandRoomUtil:roomIsLimit(map,roomtype)
    local roomLimit = 0
    for k,v in pairs(speciaRoomTypeList) do
        if v.roomtype == roomtype then
            roomLimit = v.admit
            break
        end
    end

    --加上额外提升的房间建造上限
    roomLimit = roomLimit + self:getExtraRoomLimitNum(map,roomtype)

    local roomList =  map.room
    local count = 0
    for k,v in pairs(roomList) do
        local specialRoomData
        if v.roomType then
            specialRoomData = self:getSpeciaRoomAttr(v.roomType)
        end

        if specialRoomData and specialRoomData.roomtype == roomtype then
            count = count + 1
        end
    end

    if count < roomLimit then
        return false
    elseif count == roomLimit then
        return true 
    else
        assert(false,roomtype.."数量超过建造上限")
    end
end


--当前房屋是否可以扩建,能扩建插入扩建事务
function HomelandRoomUtil:currRoomCanExtend(gjZhongCheng)
    if gjZhongCheng == nil then
        return
    end

    local role = User:getRole()
    local fq = role:getHomelandAttr("fq")

    --@desc 房契模板ID
    local fqId = fq.fqId
    print("房契模板ID = ",fqId)
    local fangqiMobanAttr = FangQiModel:getFangQiTemplateById(fqId)
    local ret = false
    -- 房屋提升所需管家忠诚度;levelloyal	房屋升级id;levelid
    if fangqiMobanAttr.levelup == 1 and fangqiMobanAttr.levelloyal and gjZhongCheng >= fangqiMobanAttr.levelloyal then
        ret =  true
    end
    if ret == true then
        local data = {
			userid = User:getRole().userid,
			affair_id = 1,
			affair_val = {},
			biz_type = 1,
			from_id = "",
			-- expired_time = GetTime() + 3600 * 48,
			objId = fqId
		}
		HttpManagerEx:pushAffair(
			data,
			function(status, errcode, errmsg, data)
				if status == 200 then
					if errcode == 0 then
						print("你给服务器插入了一条事务")
					else
						print("errcode : ", errcode)
						-- PopText(errmsg)
					end
				else
					PopText(errmsg)
				end
			end
    	)
    end
end

--@desc: 根据房间类型判断当前房间信息是否刷新入口
--@author:Liang SongQiang
--@time:2018-06-13 17:12:29
--@RefType [src.app.models.map.BaseMap#BaseMap]
--@roomType: 房间类型
function HomelandRoomUtil:updateRoomAttr(map, room)
    if not map or not map.id or not room then
        return
    end

    local roomType = room.roomType
    if roomType == nil or roomType == "" then
        return
    end

    --@desc[src.app.models.HomelandModel.HomelandDesc#HomelandDesc]
    local HomelandDesc = require("app.models.HomelandModel.HomelandDesc")

    local specialRoom = {
        ["tsfangjian007"] = function(map, room)
            --@desc 藏剑室
            --@RefType [src.app.models.role.Role#Role]
            local role = User:getRole()

            local collectScore = 1

            if map:getMapType() == MAP_TYPE.MYHOME then
                collectScore =  Helper:getDef(role:getAttr("collectScore"), 1)
                if map.extra.collectScore ~= collectScore then
                    local UserMap = require("app.models.map.UserMap")
                    UserMap:updateMapExtraAttr(map.mid,{collectScore = collectScore},0)
                    map.extra.collectScore = collectScore
                end
            else
                collectScore = Helper:getDef(map.extra.collectScore,1)
                map.extra.collectScore = collectScore
            end

            local currType = ShenBingDesc:getCollectScore(collectScore)

            local qiangBi = nil
            local roleList = room.roleList
            for k, v in pairs(roleList) do
                local role = map:getRole(v)
                if role.iType == "墙壁" then
                    qiangBi = role
                    break
                end
            end
            
            if qiangBi == nil then
                return 
            end

            --@desc 根据currType获取墙壁描述
            local qDesc = HomelandDesc:getQiangBiDesc(currType)
            if qiangBi.dsc ~= qDesc then
                qiangBi.dsc = qDesc
            end

            --@desc 根据currType获取房间描述
            local desc = HomelandDesc:getCangJianShiDesc(currType)
            if desc ~= room.dsc then
                room.dsc = desc
                map.__MapLayer:delayRefreshMap()
            end
        end,
        ["tsfangjian008"] = function(map, room)
            --@desc 藏衣室
            --@RefType [src.app.models.role.Role#Role]
            local role = User:getRole()

            local collectScore = 1

            local fq = role:getHomelandAttr("fq")

            local yiGui = nil
            local roleList = room.roleList
            for k, v in pairs(roleList) do
                local role = map:getRole(v)
                if role.iType == "衣柜" then
                    yiGui = role
                    break
                end
            end
            
            if yiGui == nil then
                return 
            end
            
            if map:getMapType() == MAP_TYPE.MYHOME then
                collectScore =  Helper:getDef(role:getAttr("collectScore"), 1)
                if map.extra.collectScore ~= collectScore then
                    local UserMap = require("app.models.map.UserMap")
                    UserMap:updateMapExtraAttr(map.mid,{collectScore = collectScore},0)
                end
            else
                collectScore = Helper:getDef(map.extra.collectScore,1)
            end

            local currType = ShenBingDesc:getCollectScore(collectScore)

            --@desc 根据currType获取衣柜描述
            local yDesc = HomelandDesc:getYiGuiDesc(currType)
            if yiGui.dsc ~= yDesc then
                yiGui.dsc = yDesc
            end

            --@desc 根据currType获取房间描述
            local desc = HomelandDesc:getCangYiShiDesc(currType)
            if desc ~= room.dsc then
                room.dsc = desc
                map.__MapLayer:delayRefreshMap()
            end
        end,
        ["tsfangjian003"] = function(map, room)
            --@desc 门前
            if room.location == nil or room.location ~= map.location then
                local text = "这里是" .. map.location .. "的门前，前方是一座宅院，门口的大门紧闭着，还需要走进些才能看得更清楚。"
                room.dsc = text
                room.desc = text
            end
        end,
        ["tsfangjian004"] = function(map, room)
            --@desc 大门
            -- if not map.extra or not room.extra.doorId then
            --     map.extra.doorId = "damen001"
            -- end
        end,
        ["tsfangjian006"] = function(map, room)
            if map:getMapType() ~= MAP_TYPE.MYHOME then
                return
            end
            --@desc 书房
            --@RefType [src.app.models.role.Role#Role]
            local role = User:getRole()
            
            local index

            local BookLiterary = require("app.models.book.BookLiterary")
            index = BookLiterary:getEvaluateDesc()
            
            local text = HomelandDesc:getShuFangDesc(index)

            if text ~= room.dsc then
                room.dsc = text
                room.desc = text
                HttpManagerEx:revampRoomAttr(
                    room.id,
                    map.mid,
                    {desc = room.desc},
                    function(status, errcode, errmsg, data)
                        if status == 200 and errcode == 0 then
                            print("书房描述上传成功。")
                        else
                            print(errmsg)
                            if DEBUG_MODE == 1 then
                                PopText(errmsg)
                            end
                        end
                    end
                )
                map.__MapLayer:delayRefreshMap()
            end

        end,
        ["tsfangjian013"] = function(map, room)
            local role = User:getRole()
            local mid = role:getHouseId()

            if tonumber(map.mid) == tonumber(mid) then
                local SeedModel = require("app.models.HomelandModel.SeedModel")
                SeedModel:checkLandIsFish(map)
            end
        end,
        ["tsfangjian005"] = function(map, room)
            if map:getMapType() ~= MAP_TYPE.MYHOME then
                return
            end

            local text = HomelandDesc:getChuWuGuiDesc(map,room)
            if text == nil then
                return
            end

            if text ~= room.dsc then
                room.dsc = text
                room.desc = text
                HttpManagerEx:revampRoomAttr(
                    room.id,
                    map.mid,
                    {desc = room.desc},
                    function(status, errcode, errmsg, data)
                        if status == 200 and errcode == 0 then
                            print("仓库描述上传成功。")
                        else
                            print(errmsg)
                            if DEBUG_MODE == 1 then
                                PopText(errmsg)
                            end
                        end
                    end
                )
                map.__MapLayer:delayRefreshMap()
            end
        end
    }

    if specialRoom[roomType] then
        specialRoom[roomType](map, room)
    end
end

--@desc:更新房间数量 
--@author:Liang SongQiang
--@time:2018-06-21 24:10:45
function HomelandRoomUtil:updateRoleRoomCount(map)
    --@RefType [src.app.models.role.Role#Role]
    local role = User:getRole()
    local fq = role:getHomelandAttr("fq")

    if not fq then
        if DEBUG_MODE == 1 then
            assert(false,"没有房契，不应该调用这个接口（HomelandRoomUtil:updateRoleRoomCount），检查代码")
        end
        return
    end

    local roomCount = 0
    for k,v in pairs(map.room) do
        roomCount = roomCount + 1
    end

    local roleRoomCount = role:getHomelandAttr("roomnum")
    if roleRoomCount ~= roomCount then
        role:setHomelandAttr("roomnum",roleRoomCount)
    end
end


--@desc: 增加房间数量
--@author:Liang SongQiang
--@time:2018-06-21 11:44:24
function HomelandRoomUtil:addRoomCount(num)
    --@RefType [src.app.models.role.Role#Role]
    local role = User:getRole()

    local fq = role:getHomelandAttr("fq")

    if not fq then
        if DEBUG_MODE == 1 then
            assert(false, "没有房契，不应该调用这个接口（HomelandRoomUtil:addRoomCount，检查代码")
        end
        return
    end

    local count = role:getHomelandAttr("roomnum") + 1

    role:setHomelandAttr("roomnum",count)
end

--@desc: 屋外跳转信息设置
--@author:Liang SongQiang
--@time:2018-06-21 14:53:42
function HomelandRoomUtil:updateDoorOutInfo(map)
    if map.dpId and map.dpId ~= "" then
        self:outDoorByDp(map)
    else
        if map.mid then
            self:outDoorByNoDp(map)
        end
    end
end


function HomelandRoomUtil:outDoorByDp(map)
    local DiQiModel = require("app.models.HomelandModel.DiQiModel")

    local commonMapId , cRoomId = DiQiModel:getCommonMapLocation(map.dpId)
    
    --@RefType [src.app.models.role.Role#Role]
    local role = User:getRole()
    local cMap = role:getMapById(commonMapId)
    local cRoomName = cMap.room[cRoomId].name

    local mapRoom
    for k,v in pairs(map.room) do
        if v.roomType == "tsfangjian002" then
            mapRoom = v
            break
        end
    end

    if mapRoom == nil then
        return
    end

    mapRoom.name = cRoomName
    map.toMapId = commonMapId
    map.toRoomId = cRoomId
end

--@desc: 没有地皮的跳转
--@author:Liang SongQiang
--@time:2018-06-21 15:20:50
--@map: [src.app.models.map.BaseMap#BaseMap]
function HomelandRoomUtil:outDoorByNoDp(map)
    local role = User:getRole()

    local fq = role:getHomelandAttr("fq")

    if not fq then
        assert(false,"没有房契信息，HomelandRoomUtil:outDoorByNoDp")
        return
    end

    --@RefType [src.app.models.map.UserMapRelation#UserMapRelation]
    local UserMapRelation = require("app.models.map.UserMapRelation")
    map.toMapId = UserMapRelation:getVillageFbId(map.loc_mark[3])
    map.toRoomIndex = map.loc_sort

    if map.toMapId == nil then
        assert(false,"此处应有玩家副本对应的副本ID，请检查代码")
    end

    local toMap = role:getMapById(map.toMapId)

    local toRoomId = ""
    for k,room in pairs(toMap:getRoomMap()) do
        if room.flag1 == map.toRoomIndex then
            toRoomId = room.dpRoomId
            break
        end
    end

    if toRoomId == "" then
        assert(false,"map.loc_sort ："..map.loc_sort)
    end
    
    local toRoom = toMap:getRoomById(toRoomId)
    local toRoomName = toRoom.name
    
    local mapRoom
    for k,v in pairs(map.room) do
        if v.roomType == "tsfangjian002" then
            mapRoom = v
            break
        end
    end

    if mapRoom == nil then
        return
    end
    
    mapRoom.name = toRoomName
    map.toRoomId = toRoomId
    map.toMapId = map.toMapId
end


function HomelandRoomUtil:jumpToMapInOutDoor(map,room)
    local toMapId = map.toMapId

    local toRoomId = map.toRoomId

    --@RefType [src.app.models.map.UserMap#UserMap]
    local UserMap = require("app.models.map.UserMap")

    local commonMap = {
        fb301 = true,
        fb302 = true,
        fb303 = true,
        fb304 = true
    }

    if commonMap[toMapId] then
        local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
        local dialog = DialogALayer:getInstance()
        dialog:hide()
        dialog:delayFunc(0.1, function()
            -- add by XiaoZhiWei 2017/09/27 16:25:01 跳转前先断开链接
            -- FubenClient:disconnect()
            
            map.__MapLayer:delayFunc(0.1,function ()
                local role = User:getRole()
                local toMap = User:getRole():getMapById(toMapId)

                local lastTime = role:getFlag(toMapId)
                if lastTime == 0 and toMap._isComingIn == nil then
                    print("副本跳转 第一次进入副本 初始化 " .. map.id)
                    toMap = role:initMapById(toMapId)
                elseif (lastTime ~= 0 and GetTime() - lastTime >= MAP_REFRESH_INTERVAL) or toMap._isComingIn == nil then
                    print("副本跳转 超过副本时间 或者游戏重新启动 初始化 " .. toMap.id)
                    toMap = role:initMapById(toMapId)
                else
                    print("副本跳转 直接进入")
                end

                toMap._isComingIn = true
                toMap:setCallBackAndConnect(function()
                    map.__MapLayer:setMap(toMap)
                    map.__MapLayer:replaceRoom(toRoomId,UserMap:getHouseNegativeDirByIndex(map.dirMark))
                    map.__MapLayer:delayRefreshMap()
                end)
            end)
        end)
    else
        UserMap:goVillageMap(map,map.loc_mark,false)
    end
end

--[[检查房间能否拆除和改造，根据家具类型,房间内是能收起的家具，不能拆，
是不能收起的家具，拆除房间后，需要通知服务器移除家具]]

local speicalFurnitureType = {  --特殊家具收起因有条件限制，shouqi配置成不可收起，特殊处理了收起功能，拆除改造时一样需要判断
    ["25"] = true, --梦境香炉
    ["26"] = true  --神功书案
}

function HomelandRoomUtil:checkRoomCanDismantleByFurnitureType(map)
    local currRoomId = map:getCurrRoomId()

    local haveFurniture = false
    local furnitureTab = {}
    local currRoleList = map:getRoomRoleList(currRoomId)
    for k,v in pairs(currRoleList) do
        local roles = map:getRole(v)
        if roles and roles.type == "item" then
            table.insert(furnitureTab,roles)
            haveFurniture = true
        end
    end
    
    if haveFurniture == false then
        return true
    end

    for i = #furnitureTab ,1 ,-1 do
        local itemAttr = Item:getOneItemByKey(furnitureTab[i].jjId)

        if itemAttr then
            if itemAttr.shouqi == 1 then
                return false
            elseif speicalFurnitureType[tostring(itemAttr.itype)] then
                return false
            end
        end
    end

    return true
end

--[[检查房间能否拆除或者改造 根据特殊情况
1.客房-有门客正在派遣，2.客房-派遣奖励未领取，3.田圃-是否有种植情况
roomType:房间类型，action 改造/拆除]]
function HomelandRoomUtil:checkRoomCanChangeBySpecialSituation(map,roomId,action)
    local room = map:getRoomById(roomId)
    if not room then
        assert(false, "该副本没有这个房间，请检查代码，roomId为" .. roomId)
    end
    local roomType = room.roomType
    if not roomType then
        assert(false, "HomelandRoomUtil:checkRoomCanChangeBySpecialSituation，请检查代码，roomType为" .. roomType)
    end
    local DispatchTaskManager = require("app.models.HomelandModel.DispatchTaskModel.DispatchTaskManager")
    local SeedModel = require("app.models.HomelandModel.SeedModel")
    if roomType == "tsfangjian012" then --客房
        -- if DispatchTaskManager:checkHasDispatchTask() then
        --    return false,"有任务正在派遣中，不可"..action
        -- end

        -- if DispatchTaskManager:checkHasReward() then
        --     return false,"您有派遣任务奖励未领取，无法"..action
        -- end
        local status = self:getRoomCanChangStatus(map,roomId)
        if status == 1 then
            return false,"您有派遣任务未完成或者有奖励未领取，无法"..action
        end
    elseif roomType == "tsfangjian013" then --田圃
        if SeedModel:checkHavePlant(roomId) then
            return false,"您有土地正在种植或者有植物未收取，无法"..action
        end
    end

    local xianglus = self:getCurrRoomFurnitureByType(map,25)
    if MapIsEmpty(xianglus) == false then
        return false,"您的香炉中有香正在燃烧，无法进行"..action
    end

    return true
end

--更新大门房间和大门物品描述
function HomelandRoomUtil:updateDoorRoomAndDoorItemDsc(item,room,map)
    
    local doorId = map.extra.doorId
    local duilianId = map.extra.couplet
    
    if doorId == nil then
        doorId = "damen001"
        map.extra.doorId = doorId
    end
    local doorInfo = self:getDoorAttr(doorId)

    item.useName3 = doorInfo.caozuo
    item.name = doorInfo.doorname
    item.dsc = doorInfo.doordsc

    room.desc = doorInfo.doorroomdsc
    room.dsc = room.desc
   
    if duilianId == nil then
        item.dsc = item.dsc .."\n  \n".."门上挂着一块小木牌，木牌上写着“YEL"..map._houseOwner.." 宅NOR”。"
        return
    end
   
    local duilianInfo = self:getDuilianAttr(duilianId)
    
    room.dsc = room.dsc .. duilianInfo.roomdsc
    item.dsc = item.dsc .. "\n  \n" .. duilianInfo.doordsc
    item.dsc = item.dsc .."\n  \n".."门上挂着一块小木牌，木牌上写着“YEL"..map._houseOwner.." 宅NOR”。"
end

--检查房间人数是否达到上限
function HomelandRoomUtil:checkRoomRolesIsLimet(fjId,currMap,extraNumArray)
    local room = currMap:getRoomById(fjId)
    if not room then
        assert(false,"房间信息不存在 Fjid = "..fjId)
    end
    local roomType = room.roomType

    if not roomType then
        return false
    end

    local roomAttr = self:getSpeciaRoomAttr(roomType)
    if not roomAttr then
        return false
    end

    local roomLimit = roomAttr.peoplelimit
    if roomLimit == 0 then
        return true
    end

    local roleTypeAttr = HomelandRoleUtil:getRoleTypeDataByRoomType(roomType)
	if roleTypeAttr == nil then
		return false
	end
	local peopletYpe = roleTypeAttr.peopletYpe
    local currRoomRoleNum = 0
    
    for i,roleId in ipairs(room.roleList) do
        local role = currMap:getRole(roleId)
        if role.type == "role" and role.jobType and role.jobType == peopletYpe then
            currRoomRoleNum = currRoomRoleNum + 1
        end 
    end
    
    if extraNumArray and extraNumArray[fjId] and type(extraNumArray[fjId]) == "number" then
        currRoomRoleNum = currRoomRoleNum + extraNumArray[fjId]
    end

    if currRoomRoleNum >= roomLimit then
        return true
    end

    return false
end

--设置特殊情况下房间能否拆除和能否改造的状态
--status 房间状态，0为能，1为不能
function HomelandRoomUtil:setRoomCanChangStatus(map,roomId,status)
    local room = map:getRoomById(roomId)
    if not room then
         assert(false, "该副本没有这个房间，请检查代码，roomId为" .. roomId)
    end
    room.CanChangStatus = status
end

--获得特殊情况下房间能否拆除和能否改造的状态
function HomelandRoomUtil:getRoomCanChangStatus(map,roomId)
    local room = map:getRoomById(roomId)
    if not room then
         assert(false, "该副本没有这个房间，请检查代码，roomId为" .. roomId)
    end
    
    return Helper:getDef(room.CanChangStatus,0) 
end

--获得大门房间id
function HomelandRoomUtil:getDaMenRoomId(map)
    if map == nil then
        assert(false,"HomelandRoomUtil:getDaMenRoomId(map) 检查参数")
    end
    local DaMenId
    local rooms = map:getRoomMap()
    for roomId, room in pairs(rooms) do
        if room and room.roomType == "tsfangjian004" then
            DaMenId = roomId
            break
        end
    end
    
    return assert(DaMenId,"这个副本没有大门 DaMenId = ",DaMenId)
end

--获取当前房间指定特殊家具
function HomelandRoomUtil:getCurrRoomFurnitureByType(map,furnitureType)
   if map == nil then
        assert(false,"HomelandRoomUtil:getDaMenRoomId(map) 检查参数")
    end
    local furnitureTab = {}
    local currRoomId = map:getCurrRoomId()
    local currRoleList = map:getRoomRoleList(currRoomId)
    for k,v in pairs(currRoleList) do
        local roles = map:getRole(v)
        if roles and roles.type == "item" and roles.itype == furnitureType then
            table.insert(furnitureTab,roles)
        end
    end
    return furnitureTab
end

return HomelandRoomUtil
000000000