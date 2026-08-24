--@SuperType [src.app.models.map.MapHandle.Modules.BaseModule#BaseModule]
local QiXi2018 = class("QiXi2018", require("app.models.map.MapHandle.Modules.BaseModule"))

local qixi_res = require("script.others.xiqi")

--@RefType [src.app.models.map.MapInfo#MapInfo]
local MapInfo = require("app.models.map.MapInfo")

--@RefType [src.app.models.Action.ChineseValentine.2018.QiXiUtil#QiXiUtil]
local QiXiUtil = require("app.models.Action.ChineseValentine.2018.QiXiUtil")

--@desc 涉及副本ID ：格式{["id"] = true} 默认为nil，无限制
QiXi2018.mapId = {["fb210"] = true}

--@desc 涉及房间 : 格式{["id"] = true} 默认为nil，无限制
QiXi2018.roomId = nil

--@desc 开启状态，默认开启
QiXi2018.status = 1

--@desc 活动时间 : 格式：20171001，默认值0 表示无时间限制
QiXi2018.activityTime = 0

--@RefType [src.app.models.map.BaseMap#BaseMap]
local function addRole2Map(map)
    --@RefType [src.app.models.role.Role#Role]
    local role = User:getRole()

    local timeRecord = role:getAttr("qx2018")

    local npc_list = map:getRoles()

    for npcId,map_npc in pairs(npc_list) do
        if map_npc.__qxMark == 1 then
            if map_npc.realSex == "男" then
                map:removeRoomRole("fb210_03",map_npc.id,false)
                map.roles[map_npc.id] = nil
                
            elseif map_npc.realSex == "女" then
                map:removeRoomRole("fb210_04",map_npc.id,false)
                map.roles[map_npc.id] = nil
            end
        end
    end

    local day
    if timeRecord == nil or MapIsEmpty(timeRecord) then
        day = 1
    else
        local nowTime = GetTime()

        local lastTime = timeRecord[#timeRecord].t

        if Helper:diffWithDate(nowTime, lastTime) >= 1 then
            day = #timeRecord + 1
        else
            day = #timeRecord
        end
    end

    if day > 7 then
        print("第8天不创建人物！！！！！！")
        return
    end

    local rolelist = qixi_res.People

    local male_list = {}
    local female_list = {}

    for roleId, role_res in pairs(rolelist) do
        if role_res.day == day then
            if role_res.sex == "男" then
                table.insert(male_list, role_res)
            elseif role_res.sex == "女" then
                table.insert(female_list, role_res)
            end
        end
    end

    map._malelist = {}
    for i, male_data in ipairs(male_list) do
        local npc = QiXiUtil:createRole(male_data)
        if npc ~= nil then
            MapInfo:addMapRole(map, npc)
            MapInfo:addRoleToRoom(map, "fb210_03", npc.id)
            table.insert(map._malelist, npc.id)
        end
    end

    map._fmalelist = {}
    for i, fmale_data in ipairs(female_list) do
        local npc = QiXiUtil:createRole(fmale_data)
        if npc ~= nil then
            MapInfo:addMapRole(map, npc)
            MapInfo:addRoleToRoom(map, "fb210_04", npc.id)
            table.insert(map._fmalelist, npc.id)
        end
    end

    local nowTime = GetTime()

    map.__createRoleTime = nowTime
end

QiXi2018.doResult = {
    ["七夕任务开启"] = function(map, result, environment)
        --@RefType [src.app.models.role.Role#Role]
        -- local role = User:getRole()
        -- role:setDayFlag("水池显示", 1)

        addRole2Map(map)

        -- map:removeRoomRole("fb210_04", "ShuiChi")
        -- map:removeRoomRole("fb210_03", "ShuiChi")
    end,
    ["七夕剧情交谈"] = function(map, result, environment)
        local npc = environment.currRole
        local text = QiXiUtil:getTalkDesc(npc)
        RichPrint("main", "YEL" .. npc.name .. "：" .. text)
    end,
    ["七夕喜好"] = function(map, result, environment)
        local npc = environment.currRole

        PopupLayerController:showLayer(
            "QiXiLikeLayer",
            function(layer)
                layer:showLayer(npc)
            end
        )
    end,
    ["七夕使用道具"] = function(map, result, environment)
        local npc = environment.currRole
        PopupLayerController:showLayer(
            "QiXiCheckInfoLayer",
            function(layer)
                layer:showLayer(npc)
            end
        )
    end,
    ["牵线"] = function(map, result, environment)
        local npc = environment.currRole

        local maleList = map._malelist
        local fmalelist = map._fmalelist

        if MapIsEmpty(maleList) or MapIsEmpty(fmalelist) then
            PopText("今日配对已完成。")
            return
        end
        PopupLayerController:showLayer(
            "MatchLayer",
            function(layer)
                layer:showLayer(npc, map)
            end
        )
    end,
    ["七夕结果列表"] = function(map, result, environment)
        HttpManagerEx:getQiXiRecord(
            function(status, errcode, errmsg, data)
                if status == 200 then
                    if errcode == 0 then
                        if not MapIsEmpty(data) then

                            if DEBUG_MODE == 1 then
                                Helper:print_lua_table(data)
                            end
                            -- body
                            PopupLayerController:showLayer(
                                "QiXiResultLayer",
                                function(layer)
                                    layer:showLayer(data)
                                end
                            )
                        else
                            PopText("你还没有结果可查看。")
                        end
                    else
                        PopText(errmsg)
                        print(errcode, errmsg)
                    end
                else
                    PopText(errmsg)
                    print(errcode, errmsg)
                end
            end,
            IS_SHOW_WAITING
        )
    end
}

function QiXi2018:entryMap(map, currTime)
    if map.id ~= "fb210" then
        return
    end

    -- local role = User:getRole()
    -- -- local leaveTime = role:getFlag(map.id)

    -- -- if leaveTime and leaveTime ~= 0 then
    -- --     local useTime = currTime - leaveTime
    -- --     -- 地图刷新时间设置为5分钟
    -- --     if useTime >= MAP_REFRESH_INTERVAL then
    -- --     else
    -- --     end
    -- -- else
    -- -- end
    
    -- if role:getDayFlag("水池显示") > 0 then
    --     addRole2Map(map)
    -- else
    --     self:createShuChi(map, currTime)
    -- end
    -- self:createQingYu(map)
    -- self:createQingYu(map)

    -- self:createRoles(map, currTime)
end

function QiXi2018:createShuChi(map, currTime)
    local roleId = "ShuiChi"
    local roomId = "fb210_02"
    local role =
        Helper:tableCover(
        require("app.models.npc.BaseNpc"):create(),
        {
            id = roleId,
            sex = "野兽",
            type = "item",
            name = "水池",
            dsc = "这是大殿中的水池，仔细看却发现里面并没有水，透过点点薄雾可以看到远处星星点点的灯火。",
            canSee = true,
            canUse1 = 1,
            useName1 = "向下望去",
            conditionAndResults = {
                {
                    conditionRelation = "and",
                    conditions = {
                        {
                            arg1 = "玩家操作",
                            arg2 = "使用1"
                        }
                    },
                    results = {
                        {
                            arg1 = "七夕任务开启"
                        }
                    }
                }
            }
        }
    )

    MapInfo:addMapRole(map, role)
    MapInfo:addRoleToRoom(map, "fb210_03", roleId)
    MapInfo:addRoleToRoom(map, "fb210_04", roleId)
end

function QiXi2018:createQingYu(map)
    local roleId = "qingyuan"
    local roomId = "fb210_01"
    local role =
        Helper:tableCover(
        require("app.models.npc.BaseNpc"):create(),
        {
            id = roleId,
            sex = "野兽",
            type = "item",
            name = "青玉案",
            dsc = "这是由青玉制成的案子，平平整整，看上去十分威严。案上面摆放着一些书卷，书卷上整整齐齐的写着几个名字。",
            canSee = true,
            canUse1 = 1,
            useName1 = "查看结果",
            conditionAndResults = {
                {
                    conditionRelation = "and",
                    conditions = {
                        {
                            arg1 = "玩家操作",
                            arg2 = "使用1"
                        }
                    },
                    results = {
                        {
                            arg1 = "七夕结果列表"
                        }
                    }
                }
            }
        }
    )

    -- MapInfo:addMapRole(map, role)
    -- MapInfo:addRoleToRoom(map, roomId, roleId)
end

return QiXi2018
0000000000000