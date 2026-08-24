local HomelandRoleTemplate = {}

--@RefType [src.app.models.HomelandModel.CRFactory#CRFactory]
local CRFactory = require("app.models.HomelandModel.CRFactory")

local commonResultName = {
    ["仆人交谈"] = true,
    ["闲聊"] = true,
    ["赏赐"] = true,
    ["身世概况"] = true
}

--根据人物特性初始化条件结果
function HomelandRoleTemplate:initConditionAndResultsByRoleBuff(role, map)
    local RoleTrait = require("app.models.HomelandModel.RoleTrait")
    local traitList = RoleTrait:getTraitList(role)
    if MapIsEmpty(traitList) == true then
        return
    end

    --房主能触发的特性
    local tempFzTraitList = {
        [28] = "firstComeInItemsAdd",
        [29] = "firstRandomComeInmoneyAdd",
        [30] = "firstComeInmoneyAdd",
        [34] = "firstCoomInRoomFindChapman",
        [69] = "firstComeInItemsReduce"
    }

    --非房主能触发的特性
    local noFzTraitList = {}

    local resultTraitList = {}

    for i, traitId in ipairs(traitList) do
        if traitId ~= nil and traitId ~= "" then
            local info = RoleTrait:getTraitInfo(traitId)
            assert(
                info,
                "HomelandRoleTemplate:initConditionAndResultsByRoleBuff 没有这个特点对应的信息 traitId =" ..
                    traitId .. "，role.name" .. role.name
            )

            local traitType = info.type

            if map:isUserMap() == true then
                if tempFzTraitList[traitType] then
                    resultTraitList[tempFzTraitList[traitType]] = true
                end
            else
                if noFzTraitList[traitType] then
                    resultTraitList[noFzTraitList[traitType]] = true
                end
            end
        end
    end

    if MapIsEmpty(resultTraitList) then
        return
    end
    Helper:print_lua_table(resultTraitList)

    local roomId = role.fjId
    if roomId == nil then
        assert(false, "HomelandRoleTemplate:initConditionAndResultsByRoleBuff" .. role.name .. "没有房间id")
    end

    local tb = {
        ["firstCoomInRoomFindChapman"] = {
            conditionRelation = "and",
            conditions = {
                {
                    arg1 = "玩家进入房间",
                    arg2 = roomId
                },
                {
                    arg1 = "玩家时间标记等于",
                    arg2 = "firstCoomInRoomFindChapman" .. role.id,
                    arg3 = 0
                }
            },
            results = {
                {
                    arg1 = "生成黑市商人",
                    arg2 = roomId,
                    arg3 = role:getBuffAttr("firstCoomInRoomFindChapman")
                },
                {
                    arg1 = "玩家时间标记设置",
                    arg2 = "firstCoomInRoomFindChapman" .. role.id,
                    arg3 = 1
                }
            }
        },
        ["firstComeInItemsAdd"] = {
            conditionRelation = "and",
            conditions = {
                {
                    arg1 = "玩家进入房间",
                    arg2 = roomId
                },
                {
                    arg1 = "玩家时间标记等于",
                    arg2 = "firstComeInItemsAdd" .. role.id,
                    arg3 = 0
                }
            },
            results = {
                {
                    arg1 = "第一次进入房间概率获得物品",
                    arg2 = role:getBuffAttr("firstComeInItemsAdd")
                },
                {
                    arg1 = "玩家时间标记设置",
                    arg2 = "firstComeInItemsAdd" .. role.id,
                    arg3 = 1
                }
            }
        },
        ["firstComeInItemsReduce"] = {
            conditionRelation = "and",
            conditions = {
                {
                    arg1 = "玩家进入房间",
                    arg2 = roomId
                },
                {
                    arg1 = "玩家时间标记等于",
                    arg2 = "firstComeInItemsReduce" .. role.id,
                    arg3 = 0
                }
            },
            results = {
                {
                    arg1 = "第一次进入房间概率丢失物品",
                    arg2 = role:getBuffAttr("firstComeInItemsReduce")
                },
                {
                    arg1 = "玩家时间标记设置",
                    arg2 = "firstComeInItemsReduce" .. role.id,
                    arg3 = 1
                }
            }
        },
        ["firstRandomComeInmoneyAdd"] = {
            conditionRelation = "and",
            conditions = {
                {
                    arg1 = "玩家进入房间",
                    arg2 = roomId
                },
                {
                    arg1 = "玩家时间标记等于",
                    arg2 = "firstRandomComeInmoneyAdd" .. role.id,
                    arg3 = 0
                }
            },
            results = {
                {
                    arg1 = "第一次进入房间概率获得金钱",
                    arg2 = role:getBuffAttr("firstRandomComeInmoneyAdd")
                },
                {
                    arg1 = "玩家时间标记设置",
                    arg2 = "firstRandomComeInmoneyAdd" .. role.id,
                    arg3 = 1
                }
            }
        },
        ["firstComeInmoneyAdd"] = {
            conditionRelation = "and",
            conditions = {
                {
                    arg1 = "玩家进入房间",
                    arg2 = roomId
                },
                {
                    arg1 = "玩家时间标记等于",
                    arg2 = "firstComeInmoneyAdd" .. role.id,
                    arg3 = 0
                }
            },
            results = {
                {
                    arg1 = "第一次进入房间获得金钱",
                    arg2 = role:getBuffAttr("firstComeInmoneyAdd")
                },
                {
                    arg1 = "玩家时间标记设置",
                    arg2 = "firstComeInmoneyAdd" .. role.id,
                    arg3 = 1
                }
            }
        }
    }

    for k, v in pairs(tb) do
        if resultTraitList[k] == true then
            table.insert(role.conditionAndResults, v)
        end
    end
end

--@desc: 初始化人物模板
--@author:Liang SongQiang
--@time:2018-06-15 15:43:00
function HomelandRoleTemplate:initRoleConditions(role, map)
    role.conditionAndResults = {}

    self:addNormalCR(role, map)

    --@desc 根据人物类型初始化
    self:addJobTypeCR(role, map)

    --@RefType [src.app.models.role.Role#Role]
    local player = User:getRole()

    local mid = player:getHouseId()

    if tostring(mid) ~= tostring(map.mid) then
        self:entryOtherUserMap(role, map)
    else
        self:unlockRoleFunc(role, map)
        
        -- @desc 根据人物特性初始化条件结果
        self:initConditionAndResultsByRoleBuff(role, map)
        
        -- --根据是否在对应房间 
        --@RefType [src.app.models.HomelandModel.HomelandRoleUtil#HomelandRoleUtil]
        local HomelandRoleUtil = require("app.models.HomelandModel.HomelandRoleUtil")
        if not HomelandRoleUtil:checkRoleIsInRightRoom( role,map ) then
            self:closeSpecialFunc(role)
        end
        
        -- @desc 根据人物状态条件初始化
        self:initByStatus(role)
    end
    

end

--@desc: 初始化人物条件结果
--@author:Liang SongQiang
--@time:2018-08-06 14:22:11
--@role:[src.app.models.role.Role#Role]
--@map: [src.app.models.map.BaseMap#BaseMap]
function HomelandRoleTemplate:createCrToRole(role, map)
    if not role.conditionAndResults then
        role.conditionAndResults = {}
    end
end

--@desc: 加载通用的条件结果
--@author:Liang SongQiang
--@time:2018-08-06 14:24:28
--@role:[src.app.models.role.Role#Role]
--@map: [src.app.models.map.BaseMap#BaseMap]
function HomelandRoleTemplate:addNormalCR(role, map)
    --@desc 装载通用条件结果
    local cType = role.cType == "管家" and role.cType or "仆人"

    switch(
        cType,
        {
            ["管家"] = function()

                if DEBUG_MODE == 1 then
                    CRFactory:createBtnCR(role, "测试", "完美闭关")
                    CRFactory:openOrCloseBtnFunc(role,"完美闭关","open")
                end

                CRFactory:createBtnCR(role, "交谈", "管家交谈")
                
                if map:isUserMap() then
                    CRFactory:createBtnCR(role, "搬家", "搬家")
                    CRFactory:createBtnCR(role, "房屋事务", "房屋事务")
                    CRFactory:createBtnCR(role, "招募仆人", "招募仆人")
                    CRFactory:createBtnCR(role, "房屋改造", "房屋改造")
                    CRFactory:createBtnCR(role, "赏赐", "赏赐")
                    CRFactory:createBtnCR(role, "户型图", "户型图")
                    CRFactory:createBtnCR(role, "仆人管理", "仆人管理")
                else
                    CRFactory:createBtnCR(role, "送邀请函", "送邀请函")
                    CRFactory:createBtnCR(role, "求购土地", "求购土地")
                end
            end,
            ["仆人"] = function()
                CRFactory:createBtnCR(role, "交谈", "仆人交谈")
                CRFactory:createBtnCR(role, "闲聊", "闲聊")
                CRFactory:createBtnCR(role, "赏赐", "赏赐")

                do
                    local lifeId = role.shenShi
                    --@RefType [src.app.models.HomelandModel.RoleLife#RoleLife]
                    local RoleLife = require("app.models.HomelandModel.RoleLife")
                    local title = RoleLife:getLifeTitle(lifeId)
                    CRFactory:createBtnCR(role, title, "身世概况")
                end
            end
        }
    )
end

--@desc: 根据职业增加条件结果
--@author:Liang SongQiang
--@time:2018-08-06 14:53:24
--@role:[src.app.models.role.Role#Role]
--@map: [src.app.models.map.BaseMap#BaseMap]
function HomelandRoleTemplate:addJobTypeCR(role, map)
    local cType = role.cType

    switch(
        cType,
        {
            ["绣女"] = function()
                CRFactory:createBtnCR(role, "饰品处理", "重复饰品处理")
                CRFactory:createBtnCR(role, "制作面具", "随机制作饰品")
            end,
            ["老农"] = function()
                CRFactory:createBtnCR(role, "收取", "老农收取")
            end,
            ["厨子"] = function()
                CRFactory:createBtnCR(role, "做饭", "做饭")
            end,
            ["门客"] = function()
                CRFactory:createBtnCR(role, "派遣", "派遣")
            end,
            ["铁匠"] = function()
                local HomelandRoleUtil = require("app.models.HomelandModel.HomelandRoleUtil")
                local lv = HomelandRoleUtil:getFidelityLv(role.defaultZhongCheng)
                local duanzaoLv = (lv + 2) * 80
                
                --仆人特性：提升锻造等级
                local addDuanZaoLv = role:getBuffAttr("duanzaoLv")
                duanzaoLv = duanzaoLv + addDuanZaoLv
                if DEBUG_MODE == 1 then
                    print("仆人特性提升的锻造等级 = ",addDuanZaoLv)
                end
                CRFactory:createBtnCR(role, "加工", "神兵加工")
                CRFactory:createBtnCR(role, "修理", "修理兵器", 4, duanzaoLv, role.name)
                CRFactory:createBtnCR(role, "淬炼", "淬炼兵器", 4, duanzaoLv, role.name)
                CRFactory:createBtnCR(role, "锻器", "锻器", 2, role.name)
            end,
            ["陪练"] = function()
                CRFactory:createBtnCR(role, "对练", "练习主动招式")
                CRFactory:createBtnCR(role, "招式指点", "招式指点")
            end
            -- ["书童"] = function(role, map)
            -- end
            -- ["护院"] = function(role, map)
            -- end
        }
    )
end

--@desc: 进入他人的副本
--@author:Liang SongQiang
--@time:2018-08-06 15:33:30
--@role:[src.app.models.role.Role#Role]
--@map: [src.app.models.map.BaseMap#BaseMap]
function HomelandRoleTemplate:entryOtherUserMap(role, map)
    --@desc 装载通用条件结果
    local cType = role.cType

    switch(
        cType,
        {
            ["管家"] = function()
                CRFactory:openOrCloseBtnFunc(role, "管家交谈", "open")
                CRFactory:openOrCloseBtnFunc(role, "送邀请函", "open")

                if map.dpId and map.dpId ~= "" then
                    CRFactory:openOrCloseBtnFunc(role, "求购土地", "open")
                end

                --@desc 进入别人家园时需调整管家初始位置
                do
                    --@RefType [src.app.models.map.UserMap#UserMap]
                    local UserMap = require("app.models.map.UserMap")

                    local linkDir = UserMap:getHouseDirByIndex(map.dirMark)

                    local currRoom = map:getRoomById(role.fjId)
                    local goRoomId = currRoom.link[linkDir]

                    local tb = {
                        conditionRelation = "and",
                        conditions = {
                            {
                                arg1 = "玩家要进入房间",
                                arg2 = goRoomId
                            },
                            {
                                arg1 = "地图标记等于",
                                arg2 = "roleHouseStatus",
                                arg3 = 0
                            }
                        },
                        results = {
                            {
                                arg1 = "阻止玩家移动"
                            },
                            {
                                arg1 = "阻拦"
                            },
                            {
                                arg1 = "文本输出",
                                arg2 = "YEL管家：少侠，此处是私人住宅，请留步。"
                            }
                        }
                    }

                    table.insert(role.conditionAndResults, tb)

                    role.fjId = goRoomId
                end
            end,
            default = function()
                CRFactory:openOrCloseBtnFunc(role, "仆人交谈", "open")
            end
        }
    )
end

--@desc: 解锁人物的相关功能
--@author:Liang SongQiang
--@time:2018-08-06 15:54:58
--@role:[src.app.models.role.Role#Role]
--@map: [src.app.models.map.BaseMap#BaseMap]
function HomelandRoleTemplate:unlockRoleFunc(role, map)
    --@RefType [src.app.models.HomelandModel.HomelandRoleUtil#HomelandRoleUtil]
    local HomelandRoleUtil = require("app.models.HomelandModel.HomelandRoleUtil")

    local lv = HomelandRoleUtil:getFidelityLv(role.defaultZhongCheng)

    switch(
        role.cType,
        {
            ["管家"] = function()
                --@RefType [src.app.models.role.Role#Role]
                local player = User:getRole()

                local state = player:getHouseStatus()

                CRFactory:openOrCloseBtnFunc(role, "管家交谈", "open")
                if state == 0 then
                    CRFactory:openOrCloseBtnFunc(role, "搬家", "open")
                    CRFactory:openOrCloseBtnFunc(role, "房屋事务", "open")
                    CRFactory:openOrCloseBtnFunc(role, "招募仆人", "close")
                    CRFactory:openOrCloseBtnFunc(role, "房屋改造", "close")
                    CRFactory:openOrCloseBtnFunc(role, "赏赐", "close")
                    CRFactory:openOrCloseBtnFunc(role, "仆人管理", "close")
                else
                    CRFactory:openOrCloseBtnFunc(role, "搬家", "close")
                    CRFactory:openOrCloseBtnFunc(role, "赏赐", "open")
                    CRFactory:openOrCloseBtnFunc(role, "房屋事务", "open")
                    CRFactory:openOrCloseBtnFunc(role, "仆人管理", "open")
                    if lv >= 3 then
                        CRFactory:openOrCloseBtnFunc(role, "招募仆人", "open")
                    end
                    
                    if lv >= 4 then
                        CRFactory:openOrCloseBtnFunc(role, "房屋改造", "open")
                    end
                    
                    local openHuXing = {
                        huxing005 = true,
                        huxing006 = true,
                        huxing007 = true,
                        huxing008 = true,
                        huxing009 = true,
                        huxing010 = true,
                        huxing011 = true,
                        huxing012 = true,
                  }

                  if openHuXing[map.hxId] == true then
                      CRFactory:openOrCloseBtnFunc(role,"户型图","open")
                  end
                end

            end,
            ["绣女"] = function()
                if lv >= 2 then
                    role.canSale = 1
                    role.baseId = "xiunv00" .. (lv - 1)
                end

                if lv > 1 then
                    CRFactory:openOrCloseBtnFunc(role, "重复饰品处理", "open")
                end

                if lv > 6 or DEBUG_MODE == 1 then
                    CRFactory:openOrCloseBtnFunc(role, "随机制作饰品", "open")
                end
            end,
            ["老农"] = function()
                role.canSale = 1
                if lv >= 1 and lv <= 4 then
                    role.baseId = "laonong001"
                elseif lv > 4 and lv < 7 then
                    role.baseId = "laonong002"
                elseif lv == 7 then
                    role.baseId = "laonong003"
                end
            end,
            ["铁匠"] = function()
                if lv >= 6 then
                    role.canSale = 1
                    role.baseId = "tiejiang00" .. (lv - 5)
                end
                CRFactory:openOrCloseBtnFunc(role, "神兵加工", "open")
                CRFactory:openOrCloseBtnFunc(role, "修理兵器", "open")
                if lv >= 2 then
                    CRFactory:openOrCloseBtnFunc(role, "淬炼兵器", "open")
                end
                if lv >= 7 then
                    CRFactory:openOrCloseBtnFunc(role, "锻器", "open")
                end
            end,
            ["书童"] = function()
                if lv >= 6 then
                    role.canSale = 1
                    role.baseId = "shutong001"
                end
            end,
            ["厨子"] = function()
                CRFactory:openOrCloseBtnFunc(role, "做饭", "open")
            end,
            ["门客"] = function()
                CRFactory:openOrCloseBtnFunc(role, "派遣", "open")
            end,
            ["陪练"] = function()
                CRFactory:openOrCloseBtnFunc(role, "练习主动招式", "open")
                CRFactory:openOrCloseBtnFunc(role, "招式指点", "open")
            end
        }
    )

    if role.cType ~= "管家" then
        CRFactory:openOrCloseBtnFunc(role, "仆人交谈", "open")
        CRFactory:openOrCloseBtnFunc(role, "闲聊", "open")
        CRFactory:openOrCloseBtnFunc(role, "赏赐", "open")

        --@RefType [src.app.models.HomelandModel.MapMeetModel.ShenShiTask#ShenShiTask]
        local ShenShiTask = require("app.models.HomelandModel.MapMeetModel.ShenShiTask")

        local status = ShenShiTask:getTaskStatus(role)

        if status == 1 or status == 2 then
            CRFactory:openOrCloseBtnFunc(role, "身世概况", "open")
            CRFactory:openOrCloseBtnFunc(role, "闲聊", "close")
        elseif status == 3 then
            CRFactory:openOrCloseBtnFunc(role, "身世概况", "close")
            CRFactory:openOrCloseBtnFunc(role, "闲聊", "open")
        end
    end
end

function HomelandRoleTemplate:initByStatus(role)
    local HomelandRoleUtil = require("app.models.HomelandModel.HomelandRoleUtil")
    local currRoleStatus = HomelandRoleUtil:getRoleCurrStatus(role)
    switch(
        currRoleStatus,
        {
            ["闹事"] = function()
                local withoutName = {
                    ["仆人交谈"] = true
                }
                local btnFunc = Helper:getDef(role.btnFuncIndex, {})

                role.canSale = 0
                for resultName, btnIndex in pairs(btnFunc) do
                    if withoutName[resultName] ~= true then
                        CRFactory:openOrCloseBtnFunc(role, resultName, "close")
                    end
                end

            end,
            ["正常"] = function()
            end,
            default = function()
                assert(false, "HomelandRoleTemplate:initByStatus 检查人物状态")
            end
        }
    )
end

--@desc: 关闭相关的特殊功能
--@author:Liang SongQiang
--@time:2018-08-06 20:27:02
--@role: [src.app.models.role.Role#Role]
function HomelandRoleTemplate:closeSpecialFunc(role)
    local btnFunc = Helper:getDef(role.btnFuncIndex, {})

    role.canSale = 0
    for resultName, btnIndex in pairs(btnFunc) do
        if commonResultName[resultName] ~= true then
            CRFactory:openOrCloseBtnFunc(role, resultName, "close")
        end
    end
end

return HomelandRoleTemplate
0000000000