--@SuperType [src.app.models.map.MapHandle.Modules.BaseModule#BaseModule]
local CustomNpcUtil = class("CustomNpcUtil", require("app.models.map.MapHandle.Modules.BaseModule"))
local MapInfo = require("app.models.map.MapInfo")

--@desc 开启状态，默认开启
CustomNpcUtil.status = 1
--@desc  黑市商人个数
local chapmanCount = 1
-- 黑市商人3小时刷新冷却
local CHAPMAN_COLD_TIME = 10800

--欧冶子冷却时间
local OU_COLD_TIME = 10800
local ouCount = 1

CustomNpcUtil.doResult = {
    ["回家"] = function(map, result, environment)
        if JIAYUAN_SYSTEM_IS_OPEN == false then
            PopText("该功能暂时未开放")
            return
        end
    
		local role = User:getRole()
		local maplayer = map.__MapLayer
        
        local mid = role:getHouseId()
		
		if mid == nil then
			RichPrint("main","YEL车夫：少侠，您还没有房子嘞，您要不去本城市侩那看看房屋？")
			return
		end

		local UserMap = require("app.models.map.UserMap")
		local useId = User:getUserId()
        UserMap:getUserMap(mid,useId,function(myMap,isSuccess)
            if isSuccess == false then
                return
            end
            
			myMap._isComingIn = true
			RichPrint("main", "HIC你进入大车，对车夫吆喝了几句。")
			RichPrint("main", "HIC车夫扬起手中鞭，吆喝道：看车！去"..tostring(myMap.name).."了。")

			local entryMapLayer = MainControllLayer:getLayer("EntryMapLayer")
			entryMapLayer:maxZ()
			entryMapLayer:show()

			local titleLayer = MainControllLayer:getLayer("TitleLayer")
			local mapRoleLayer = MainControllLayer:getLayer("MapRoleLayer")
			mapRoleLayer:onResume()
			titleLayer:hide(true)

			maplayer:delayFunc(1,
			function(obj)
				myMap:setCallBackAndConnect(function()
					local mapLayer = MainControllLayer:getLayer("MapLayer")
					-- map:setMapForTask()	--主动任务，地图调整
					mapLayer:setMap(myMap)
                    -- FubenClient:comeIn(myMap.id, mapLayer._currRoom.id, myMap:getRoomNameById(mapLayer._currRoom.id), Helper:getOnlyId())
					entryMapLayer:hide(function()
						RichPrint("main", "HIC你身形一转，跃下马来，姿势十分优美。")
					end) -- 隐藏界面

					-- 释放地图动画层
					MainControllLayer:removeLayer("EntryMapLayer")						
					MainControllLayer:pushLayer("MapLayer")
                    -- titleLayer:changeTitleUI()
                    MessageCenter:notify("EnterMap",{map=map})
				end)
			end)
		end)
	end,
}

--@desc:
--@author:Liang SongQiang
--@time:2018-03-30 10:27:55
function CustomNpcUtil:entryMap(map,currTime)
    --@RefType [src.app.models.role.Role#Role]
    local role = User:getRole()
    local leaveTime = role:getFlag(map.id)

    if leaveTime and leaveTime ~= 0 then
        local useTime = currTime - leaveTime
        -- 地图刷新时间设置为5分钟
        if useTime >= MAP_REFRESH_INTERVAL then
            print("CustomNpcUtil : 地图初始化")
            self:createNpc(map, currTime)
        else
            self:removeNpc(map, currTime)
        end
    else
        self:createNpc(map, currTime)
    end

    local CheFuModel = require("app.models.npc.CheFuModel")

    local chefu = CheFuModel:createCheFu(map)
    if chefu then
        local roomId = map.__MapLayer:getDefaultRoom().id
        MapInfo:addMapRole(map,chefu)
        MapInfo:addRoleToRoom(map,roomId,chefu.id)
    end

    self:initNewStoreNpc(map)
end

function CustomNpcUtil:createChapman(map, currTime)
    -- 黑市商人个数
    if DEBUG_MODE == 1 then
        chapmanCount = 1
        CHAPMAN_COLD_TIME = 1
    end
    local role = User:getRole()
    if currTime - role:getFlag("黑市商人出现时间") > CHAPMAN_COLD_TIME then
        -- 黑市商人出现概率1/2
        local num = math.random(1, 2)
        if DEBUG_MODE == 1 then
            num = 1
        end
        if num == 1 then
            for i = 1, chapmanCount do
                local roleId = "chapman" .. i
                local roomId
                map,
                    roomId =
                    MapInfo:addMapRoleByRandom(
                    map,
                    Helper:tableCover(
                        require("app.models.npc.BaseNpc"):create(),
                        {
                            id = roleId,
                            sex = "野兽",
                            type = "role",
                            name = "黑市商人",
                            dsc = "他是黑市商人，看上去三四十来岁，生的尖嘴猴腮，浑身充满了铜臭味。",
                            canSee = true,
                            canTalk = true,
                            canSale = true,
                            canKill = false,
                            conditionAndResults = {
                                {
                                    conditionRelation = "and",
                                    conditions = {
                                        {
                                            type = "地图标记等于",
                                            arg1 = "地图标记等于",
                                            arg2 = "黑市商人" .. roleId,
                                            arg3 = 0
                                        }
                                    },
                                    results = {
                                        {
                                            type = "玩家标记设置当前时间",
                                            arg1 = "玩家标记设置当前时间",
                                            arg2 = "黑市商人出现时间"
                                        }
                                    }
                                },
                                {
                                    conditionRelation = "and",
                                    conditions = {
                                        {
                                            type = "玩家操作",
                                            arg1 = "玩家操作",
                                            arg2 = "交谈"
                                        }
                                    },
                                    results = {
                                        {
                                            type = "文本输出",
                                            arg1 = "文本输出",
                                            arg2 = "YEL黑市商人：最近官府查的严，得经常挪地儿，唉，生意不好做啊。"
                                        }
                                    }
                                },
                                {
                                    conditionRelation = "and",
                                    conditions = {
                                        {
                                            type = "玩家进入房间",
                                            arg1 = "玩家进入房间"
                                        },
                                        {
                                            type = "地图标记大于",
                                            arg1 = "地图标记大于",
                                            arg2 = "黑市商人" .. roleId,
                                            arg3 = 0
                                        }
                                    },
                                    results = {
                                        {
                                            type = "删除人物",
                                            arg1 = "删除人物",
                                            arg2 = roleId
                                        },
                                        {
                                            type = "文本输出",
                                            arg1 = "文本输出",
                                            arg2 = "你才一个转身，回头便发现黑市商人已不知所踪了。"
                                        }
                                    }
                                },
                                {
                                    conditionRelation = "and",
                                    conditions = {},
                                    results = {
                                        {
                                            type = "地图标记变化",
                                            arg1 = "地图标记变化",
                                            arg2 = "黑市商人" .. roleId,
                                            arg3 = 1
                                        }
                                    }
                                }
                            }
                        }
                    )
                )

                print("==================  黑市商人 ====================", roomId)

                if roomId then
                    if not map.clearList then
                        map.clearList = {}
                    end
                    map.clearList["chapman" .. i] = roomId
                end
                local result, text = role:setCurrMap(map)
                if result == true then
                    map:setFlag("黑市商人" .. roleId, 0)
                else
                    PopText(text)
                end
            end
        end
    else
        local sec = currTime - User:getRole():getFlag("黑市商人出现时间")
        print("黑市商人剩余冷却时间 = " .. 10800 - sec)
    end
end

--@desc: 清除多余的黑市商人
--@author:Liang SongQiang
--@time:2018-03-30 15:03:52
--@map:[src.app.models.map.BaseMap#BaseMap]
function CustomNpcUtil:clearChapman(map, currTime)
    --@RefType [src.app.models.role.Role#Role]
    local role = User:getRole()

    if currTime - role:getFlag("黑市商人出现时间") < CHAPMAN_COLD_TIME then
        for i = 1, chapmanCount do
            local chapmanId = "chapman" .. i
            if map.clearList[chapmanId] and map.roles[chapmanId] then
                local roomId = map.clearList[chapmanId]
                map.roles[chapmanId] = nil
                local roomRoles = map:getRoomRoleList(roomId)
                if not MapIsEmpty(roomRoles) then
                    for _, v in pairs(roomRoles) do
                        if v == chapmanId then
                            table.remove(roomRoles, _)
                            map.clearList[chapmanId] = nil
                            break
                        end
                    end
                end
            end
        end
    end
end

function CustomNpcUtil:createOuYeZi(map, currTime)
    if DEBUG_MODE == 1 then
        OU_COLD_TIME = 5
    end
    print("-------------------开始神兵任务---------------------", User:getRole():getInheritFlag("开始神兵任务"))
    if User:getRole():getInheritFlag("开始神兵任务") < 2 then -- 完成唐门之乱任务
        return
    end
    print(
        "-----------------------欧冶子出现时间间隔------------------------------",
        currTime - User:getRole():getFlag("欧冶子出现时间")
    )
    if currTime - User:getRole():getFlag("欧冶子出现时间") > OU_COLD_TIME then
        local random = math.random(1, 2)
        if DEBUG_MODE == 1 then
            random = 1
        end
        if random == 1 then
            for i = 1, ouCount do
                local roleId = "ouyezi" .. i
                local list = {
                    ["fb08"] = {"fb08_18", "fb08_17"},
                    ["fb13"] = {"fb13_19", "fb13_06"},
                    ["fb18"] = {"fb18_40", "fb18_34"},
                    ["fb19"] = {"fb19_17"},
                    ["fb21"] = {"fb21_23", "fb21_31"},
                    ["fb22"] = {"fb22_11"},
                    ["fb24"] = {"fb24_17", "fb24_35"},
                    ["fb27"] = {"fb27_38", "fb27_20"},
                    ["fb33"] = {"fb33_08", "fb33_01"},
                    ["fb39"] = {"fb39_48", "fb39_35"}
                }
                local roomId = nil
                if DEBUG_MODE == 1 then
                    roomId = "fb01_01"
                else
                    if list[map.id] == nil then
                        return
                    end
                    roomId = list[map.id][math.random(1, #list[map.id])]
                    if roomId == nil then
                        print("++++++++++++++++++++创建欧冶子谁家房间Id出错了++++++++++++++++++++++++++")
                        return
                    end
                end
                print("------------------------欧冶子出现的房间----------------------------", roomId)
                MapInfo:addRoleToRoomByRoomId(
                    map,
                    roomId,
                    Helper:tableCover(
                        require("app.models.npc.BaseNpc"):create(),
                        {
                            id = roleId,
                            sex = "野兽",
                            type = "role",
                            name = "欧冶子",
                            dsc = "他是黑市商人，看上去三四十来岁，生的尖嘴猴腮，浑身充满了铜臭味。",
                            conditionAndResults = {}
                        }
                    )
                )
                print("------------------------------------------------------------------------")
                User:getRole():setFlag("欧冶子出现时间", GetTime())
            end
        end
    end
end

function CustomNpcUtil:createTieJiang(map, currTime)
    if map.id ~= "fb15" then
        return
    end
    
    local roleId = "TieJiang"
    if map.roles[roleId] then
        return
    end

    local roomId = "fb15_44"
    local role = Helper:tableCover(
        require("app.models.npc.BaseNpc"):create(),
        {
            id = roleId,
            sex = "男",
            type = "role",
            name = "铁匠",
            dsc = "他看起来约三十几岁，他生得HIG神清气爽，骨格清奇，宛若仙人NOR。\n他的武功看不出强弱，出手似乎HIG很轻NOR。\n曾机缘巧合得欧冶子授得几式锻造之术，为报恩情，便一直跟随其左右。欧冶子云游四海之时便会留下他看守玄兵古洞。",
            canSee = true,
            canKill = false,
            caozuo1 = 1,
            caozuoName1 = "交谈",                      
            conditionAndResults = {
                {
                    conditionRelation = "and",
                    conditions = {
                        {
                            --type = "玩家操作",
                            arg1 = "玩家操作",
                            arg2 = "操作1"
                        }
                    },
                    results = {
                        {
                            type = "玩家操作",
                            arg1 = "铁匠入驻玄兵洞",
                        }
                    }
                }                           
            }  
        }
    )

    MapInfo:addMapRole(map,role)
    MapInfo:addRoleToRoom(map,roomId,roleId)
     
end
-- function CustomNpcUtil:clearOuyezi(map, currTime)
-- 	--@RefType [src.app.models.role.Role#Role]
-- 	local role = User:getRole()
-- 	if currTime - User:getRole():getFlag("欧冶子出现时间") < OU_COLD_TIME then
-- 		for i = 1, ouCount do
--             local ouyeziId = "ouyezi" .. i
--             if map.clearList[ouyeziId] and map.roles[ouyeziId] then
--                 local roomId = map.clearList[ouyeziId]
--                 map.roles[ouyeziId] = nil
--                 local roomRoles = map:getRoomRoleList(roomId)
--                 for _, v in pairs(roomRoles) do
--                     if v == ouyeziId then
--                         table.remove(roomRoles, _)
--                         map.clearList[ouyeziId] = nil
--                         break
--                     end
--                 end
--             end
--         end
--     end
-- end

local ignoreMap = {
    ["fb200"] = true,
    ["fb201"] = true,
    ["fb203"] = true,
    ["fb204"] = true
}

--@desc: 创建NPC
--@author:Liang SongQiang
--@time:2018-03-30 10:40:51
--@map: [src.app.models.map.BaseMap#BaseMap]
function CustomNpcUtil:createNpc(map, currTime)
    -- self:createChapman(map, currTime)

    if self:isCreateChapmanByAction(currTime) then
        CHAPMAN_COLD_TIME = 3600
        self:createChapmanByAction(map, currTime)
    else
         CHAPMAN_COLD_TIME = 10800
        self:createChapman(map, currTime)
    end
    self:createOuYeZi(map, currTime)
end

function CustomNpcUtil:isCreateChapmanByAction(currTime)
    local startTime = os.time({day=10, month=7, year=2018, hour=0, min=0, sec=0})
    local endTime = os.time({day=25, month=7, year=2018, hour=23, min=59, sec=59})
    if currTime >= startTime and currTime <= endTime then
        return true
    end
    return false
end

--周年庆活动期间
function CustomNpcUtil:createChapmanByAction(map, currTime)
    -- 黑市商人个数
    if DEBUG_MODE == 1 then
        chapmanCount = 1
        CHAPMAN_COLD_TIME = 1
    end
    local role = User:getRole()
    if map.id ~= "fb205" then
        return
    end
    if currTime - role:getFlag("黑市商人出现时间") > CHAPMAN_COLD_TIME then
        -- 黑市商人出现概率1/2
        -- local num = 1
        if DEBUG_MODE == 1 then
            -- num = 1
        end

        -- 获取房间随机数
        local CanRandomroomList = {"fb205_01","fb205_02","fb205_03","fb205_04","fb205_05","fb205_06","fb205_07",
                                "fb205_08","fb205_09","fb205_10","fb205_11","fb205_12","fb205_13","fb205_14",
                                "fb205_15","fb205_16","fb205_17","fb205_18","fb205_19","fb205_20","fb205_21",
                                "fb205_22","fb205_23","fb205_57","fb205_58","fb205_59","fb205_60","fb205_61",
                                "fb205_62","fb205_63","fb205_64","fb205_65","fb205_66","fb205_67","fb205_68",
                                "fb205_69","fb205_70","fb205_71","fb205_72","fb205_73"}
        local randomIndex = math.random(#CanRandomroomList)
        -- 确定随机房间
        local roomId = CanRandomroomList[randomIndex]
        print("getRandomRoomId 获取随机房间 " .. roomId)

        -- if num == 1 then
        for i = 1, chapmanCount do
            local roleId = "chapman" .. i

                MapInfo:addRoleToRoomByRoomId(
                map,
                roomId,
                Helper:tableCover(
                    require("app.models.npc.BaseNpc"):create(),
                    {
                        id = roleId,
                        sex = "野兽",
                        type = "role",
                        name = "黑市商人",
                        dsc = "他是黑市商人，看上去三四十来岁，生的尖嘴猴腮，浑身充满了铜臭味。",
                        canSee = true,
                        canTalk = true,
                        canSale = true,
                        canKill = false,
                        conditionAndResults = {
                            {
                                conditionRelation = "and",
                                conditions = {
                                    {
                                        type = "地图标记等于",
                                        arg1 = "地图标记等于",
                                        arg2 = "黑市商人" .. roleId,
                                        arg3 = 0
                                    }
                                },
                                results = {
                                    {
                                        type = "玩家标记设置当前时间",
                                        arg1 = "玩家标记设置当前时间",
                                        arg2 = "黑市商人出现时间"
                                    }
                                }
                            },
                            {
                                conditionRelation = "and",
                                conditions = {
                                    {
                                        type = "玩家操作",
                                        arg1 = "玩家操作",
                                        arg2 = "交谈"
                                    }
                                },
                                results = {
                                    {
                                        type = "文本输出",
                                        arg1 = "文本输出",
                                        arg2 = "YEL黑市商人：最近官府查的严，得经常挪地儿，唉，生意不好做啊。"
                                    }
                                }
                            },
                            {
                                conditionRelation = "and",
                                conditions = {
                                    {
                                        type = "玩家进入房间",
                                        arg1 = "玩家进入房间"
                                    },
                                    {
                                        type = "地图标记大于",
                                        arg1 = "地图标记大于",
                                        arg2 = "黑市商人" .. roleId,
                                        arg3 = 0
                                    }
                                },
                                results = {
                                    {
                                        type = "删除人物",
                                        arg1 = "删除人物",
                                        arg2 = roleId
                                    },
                                    {
                                        type = "文本输出",
                                        arg1 = "文本输出",
                                        arg2 = "你才一个转身，回头便发现黑市商人已不知所踪了。"
                                    }
                                }
                            },
                            {
                                conditionRelation = "and",
                                conditions = {},
                                results = {
                                    {
                                        type = "地图标记变化",
                                        arg1 = "地图标记变化",
                                        arg2 = "黑市商人" .. roleId,
                                        arg3 = 1
                                    }
                                }
                            }
                        }
                    }
                )
            )

            print("=========2=========  黑市商人 ====================", roomId)

            if roomId then
                if not map.clearList then
                    map.clearList = {}
                end
                map.clearList["chapman" .. i] = roomId
            end
            local result, text = role:setCurrMap(map)
            if result == true then
                map:setFlag("黑市商人" .. roleId, 0)
            else
                PopText(text)
            end
        end
        -- end
    else
        local sec = currTime - User:getRole():getFlag("黑市商人出现时间")
        print("黑市商人剩余冷却时间2 = " .. 3600 - sec)
    end
end

--@desc: 移除多余的NPC
--@author:Liang SongQiang
--@time:2018-03-30 15:43:12
--@map:[src.app.models.map.BaseMap#BaseMap]
function CustomNpcUtil:removeNpc(map, currTime)
    if not map.clearList and MapIsEmpty(map.clearList) then
        return
    end

    self:clearChapman(map, currTime)
    -- self:clearOuyezi(map,currTime)
end

function CustomNpcUtil:initNewStoreNpc(map)
    local StoreHelper = require("app.models.Store.StoreHelper")
    StoreHelper:initMapNewStore(map)
end

return CustomNpcUtil
0000000000