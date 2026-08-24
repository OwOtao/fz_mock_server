--@SuperType [src.app.models.map.MapHandle.Modules.BaseModule#BaseModule]
local ZhongQiu2018 = class("ZhongQiu2018", require("app.models.map.MapHandle.Modules.BaseModule"))

--@RefType [src.app.models.map.MapInfo#MapInfo]
local MapInfo = require("app.models.map.MapInfo")

--@desc 开启状态，默认开启
ZhongQiu2018.status = 1

--@desc 活动时间 : 格式：20171001，默认值0 表示无时间限制
ZhongQiu2018.activityTime = 0


ZhongQiu2018.doResult = {
    ["设置中秋宝箱位置"] = function(map, result, environment)
        local player = User:getRole()
        local baoxiang_flag = player:getDayFlag("中秋宝箱位置")
        local currRole = environment.currRole
        local npcId = currRole.id

        if baoxiang_flag == 0 then
            return
        end
        
        if baoxiang_flag[npcId] then
            baoxiang_flag[npcId] = nil
            player:setDayFlag("中秋宝箱位置",baoxiang_flag)
        end
    end
}

function ZhongQiu2018:entryMap(map, currTime)
    local mapIdList = {fb211 = true, fb212 = true,fb213 = true,}

    if mapIdList[map.id] == true then
        self:createBaoxiang(map, currTime)
    end

end


local RoomList1 = {
    "fb211_09","fb211_12","fb211_15","fb211_21","fb211_24","fb211_16",
    "fb211_11","fb211_14","fb211_19","fb211_23","fb211_18","fb211_20",
    "fb211_04","fb211_05","fb211_06","fb211_10","fb211_29","fb211_30","fb211_31","fb211_25"
}
local RoomList2 = {    
    "fb212_13","fb212_16","fb212_17","fb212_20",
    "fb212_11","fb212_14","fb212_21","fb212_24",
    "fb212_04","fb212_05","fb212_06","fb212_27","fb212_28","fb212_29"
}
local RoomList3 = {
    "fb213_11","fb213_12","fb213_13",
    "fb213_16","fb213_17","fb213_18",
    "fb213_05","fb213_09","fb213_20","fb213_24"
}

function ZhongQiu2018:createBaoxiang(map, currTime)
    if ZHONGQIU_2018_IS_OPEN ~= true then
        return
    end

    local player = User:getRole()
    local baoxiang_flag = player:getDayFlag("中秋宝箱位置")

    if baoxiang_flag == 0 then
        local tab = {} --记录宝箱所在的房间位置

        local bxIdList = {
            "baoxiang001",
            "baoxiang002",
            "baoxiang003",
            "baoxiang004",
            "baoxiang005",
            "baoxiang006",
            "baoxiang007",
            "baoxiang008",
            "baoxiang009",
        }

        for i = 1,9 do
            if i <= 3 then
                local randombxIdNum = math.random(1,#bxIdList)
                local randomRoomIdNum = math.random(1,#RoomList1)
                tab[table.remove(bxIdList,randombxIdNum)] = table.remove(RoomList1,randomRoomIdNum)
            elseif i <= 6 then
                local randombxIdNum = math.random(1,#bxIdList)
                local randomRoomIdNum = math.random(1,#RoomList2)
                tab[table.remove(bxIdList,randombxIdNum)] = table.remove(RoomList2,randomRoomIdNum)
            elseif i <= 9 then
                local randombxIdNum = math.random(1,#bxIdList)
                local randomRoomIdNum = math.random(1,#RoomList3)
                tab[table.remove(bxIdList,randombxIdNum)] = table.remove(RoomList3,randomRoomIdNum)
            end
            
        end

        baoxiang_flag = tab
        player:setDayFlag("中秋宝箱位置",baoxiang_flag)
    end

    print("---------------------中秋宝箱位置--------------------------")
    Helper:print_lua_table(baoxiang_flag)
    print("---------------------中秋宝箱位置--------------------------\n")
    for baoxiangId ,roomId in pairs(baoxiang_flag) do
        local roomMap = map:getRoomMap()

        --副本下必须有这个房间才能添加
        if roomMap[roomId] ~= nil then
            MapInfo:addRoleToRoom(map, roomId, baoxiangId)
        end
    end
end


return ZhongQiu2018
000000