local CheFuModel = {} --]]

local CHEFUID = "chefu100"

--@RefType [app.models.map.UserMapRelation#UserMapRelation]
local UserMapRelation = require("app.models.map.UserMapRelation")

-- fb206：王家村、飞来村 、白云村、清水村、十里村
-- fb207：莲花村、三水村、芦苇村、渔歌村、瑶歌村
-- fb208：日暮村、海棠村、东林村、大兴村、玉带村
-- fb209：金刀村、石湖村、泗水村、青山村、杏花村

local cheFuBaseInfo = {
    id = CHEFUID,
    sex = "野兽",
    type = "role",
    name = "车夫",
    dsc = "他就是车夫，虽穿着寻常粗布麻衣，但眉目如画，行走之间器宇不凡，气质难以掩盖。",
}

local villageId = {
    ["fb206"] = true,
    ["fb207"] = true,
    ["fb208"] = true,
    ["fb209"] = true
}

local ignoreMapId = {
    ["fb200"] = true,
    ["fb201"] = true,
    ["fb203"] = true,
    ["fb204"] = true,
    ["fb210"] = true,
    ["fb211"] = true,
    ["fb212"] = true,
    ["fb213"] = true,
    ["fb214"] = true,
    ["fb215"] = true,
    ["fb216"] = true,
    ["fb217"] = true,
    --@desc 盛唐阁
    ["fb305"] = true,
    --梦境前置任务地图
    ["fb219"] = true,
}

local commmonMapId = {
    fb301 = "fb10",
    fb302 = "fb15",
    fb303 = "fb20",
    fb304 = "fb25"
}


local bigCityId = {
    ["fb10"] = true,
    ["fb15"] = true,
    ["fb20"] = true,
    ["fb25"] = true
}

local AddGoToPingAnMapId = {
    ["fb01"] = true,
    ["fb02"] = true,
    ["fb03"] = true,
    ["fb04"] = true,
    ["fb05"] = true,
    ["fb06"] = true,
    ["fb07"] = true,
    ["fb08"] = true,
    ["fb09"] = true,
    ["fb11"] = true,
    ["fb12"] = true,
    ["fb13"] = true,
    ["fb14"] = true,
    ["fb16"] = true,
    ["fb17"] = true,
    ["fb18"] = true,
    ["fb19"] = true
}

--@desc: 创建车夫，根据当前副本来生成车夫的功能。
--@author:Liang SongQiang
--@time:2018-06-29 15:50:06
--@map: [app.models.map.BaseMap#BaseMap]
function CheFuModel:createCheFu(map)
    if ignoreMapId[map.id] then
        return
    end

    if map.mid ~= nil or map.mid == "" then
        return
    end
    --梦境副本无车夫
    if (map:getMapType() == MAP_TYPE.DREAMMAP or map:getMapType() == MAP_TYPE.FONDDREAMMAP) and DEBUG_MODE ~= 1 then
        return
    end

    if Map:getMapVersionByMapId(map.id) == EDITOR_MAP_VERSION then
        return self:createCheFuInEditorMap(map)
    else
        return self:createCheFuInOldMap(map)
    end
end

function CheFuModel:createCheFuInEditorMap(map)
    local chefu = clone(cheFuBaseInfo)
    chefu.operations = {}
    
    self:addTalkOperation(chefu, map)
    self:addGoHomeOperation(chefu)
    self:addLeaveMapOperation(chefu)
    self:addYaoQingHanOperation(chefu)
    
    if DEBUG_MODE == 1 then
        local results = {
            OperationFactory:createResult("进入下一层")
        }
    
        local opertaion = OperationFactory:createNoConditionBtnOperation("进入下一层", results)
        
        table.insert(chefu.operations, opertaion)
        
        local opertaion1 = OperationFactory:createNoConditionBtnOperation("周公之术", {OperationFactory:createResult("周公之术")})
        table.insert(chefu.operations, opertaion1)

        local opertaion2 = OperationFactory:createNoConditionBtnOperation("梦境交易", {OperationFactory:createResult("梦境交易")})
        table.insert(chefu.operations, opertaion2)

        local opertaion3 = OperationFactory:createNoConditionBtnOperation("南柯梦境决斗", {OperationFactory:createResult("南柯梦境决斗","1")})
        table.insert(chefu.operations, opertaion3)
        
        local opertaion4 = OperationFactory:createNoConditionBtnOperation("南柯梦境开箱", {OperationFactory:createResult("南柯梦境开箱",5)})
        table.insert(chefu.operations, opertaion4)
    end

    return chefu
end

function CheFuModel:addTalkOperation(template, map)
    template.words = {
        "少侠，前方便是" .. tostring(map.name) .. "。"
    }

    local results = {
        OperationFactory:createResult("交谈")
    }

    local opertaion = OperationFactory:createNoConditionBtnOperation("交谈", results)

    table.insert(template.operations, opertaion)
end

function CheFuModel:addGoHomeOperation(template)
    --@RefType [app.models.role.Role#Role]
    local role = User:getRole()
    local fq = role:getHomelandAttr("fq")

    if not fq or MapIsEmpty(fq) then
        return
    end

    if fq.status == 0 then
        return
    end

    local results = {
        OperationFactory:createResult("回家")
    }

    local opertaion = OperationFactory:createNoConditionBtnOperation("回家", results)

    table.insert(template.operations, opertaion)
end

function CheFuModel:addLeaveMapOperation(template)
    local results = {
        OperationFactory:createResult("副本离开")
    }

    local opertaion = OperationFactory:createNoConditionBtnOperation("离开", results)

    table.insert(template.operations, opertaion)
end

function CheFuModel:addYaoQingHanOperation(template)
    local role = User:getRole()
    local HomelandUtil = require("app.models.HomelandModel.HomelandUtil")
    if HomelandUtil:sysIsOpen(false) == false then
        return
    end

    local results = {
        OperationFactory:createResult("邀请函前往")
    }

    local opertaion = OperationFactory:createNoConditionBtnOperation("递函", results)

    table.insert(template.operations, opertaion)
end

-------------------------------------------------------------------
--[[
    以下方法是旧副本相关
]]

--@desc:创建旧副本相关条件结果 
--@author:Liang SongQiang
--@time:2019-01-03 10:52:05
function CheFuModel:createCheFuInOldMap(map)
    --@desc 如果是小村庄，车夫要重新生成。
    if villageId[map.id] then
        map.roles[CHEFUID] = nil
    end

    --@desc 操作按钮计数器
    self._actionCount = 1

    if villageId[map.id] then
        map.name = UserMapRelation:getVillageName(Helper:getDef(map.villageIndex, 1))
    end
    local template = clone(cheFuBaseInfo)
    template.canSee = true
    template.canTalk = true
    template.canKill = false
    template.conditionAndResults = {
        {
            conditionRelation = "and",
            conditions = {
                {
                    arg1 = "玩家操作",
                    arg2 = "交谈"
                }
            },
            results = {
                {
                    --type = "离开副本",
                    arg1 = "文本输出",
                    arg2 = "YEL车夫：少侠，前方便是" .. tostring(map.name) .. "。"
                }
            }
        }
    }


    if bigCityId[map.id] then
        self:initInBigCity(template, map)
    elseif villageId[map.id] then
        self:initVillageMap(template, map)
    else
        self:initNorLocalMap(template, map)
    end

    
    if DEBUG_MODE == 1 then
        local cr =
            self:createBtnAction(
            "去酆都",
            {
                arg1 = "副本跳转",
                arg2 = "fb201",
                arg3 = "fb201_50",
                arg4 = 100,
                arg10 = 0,
                arg11 = 1,
            }
        )
    
        self:addAction(template, cr)

        local cr =
            self:createBtnAction(
            "完成古迹任务",
            {
                arg1 = "完成古迹任务",
                arg2 = 1,
            }
        )

        self:addAction(template, cr)

        local cr =
            self:createBtnAction(
            "武学上限突破奖励",
            {
                arg1 = "武学上限突破奖励",
                arg2 = 1,
            }
        )

        self:addAction(template, cr)

        local cr =
            self:createBtnAction(
            "散人提升门外武学准备条件",
            {
                arg1 = "散人提升门外武学准备条件",
            }
        )

        self:addAction(template, cr)

    end

    
    if PRINT_MODE == 1 then
        print("--------------------------------")
        Helper:print_lua_table(template)
        print("--------------------------------\n")
    end

    local chefu = Helper:tableCover(require("app.models.npc.BaseNpc"):create(), template)

    return chefu
end

function CheFuModel:initInBigCity(template, map)
    self:addGoToPingAn(template, map)
    self:initNorLocalMap(template, map)
    self:addGoVillageAction(template, map)
end

--@desc: 初始化普通副本
--@author:Liang SongQiang
--@time:2018-06-29 21:38:50
function CheFuModel:initNorLocalMap(template, map)
    if AddGoToPingAnMapId[map.id] then
        self:addGoToPingAn(template, map)
    end
    self:addGoHomeAction(template, map)
    self:addLeaveMapAction(template, map)
    self:addGoMapWithYaoQingHan(template, map)
end

function CheFuModel:initVillageMap(template, map)
    self:addBackToLocalMap(template, map)
    self:addGoToPingAn(template, map)
    self:addLeaveMapAction(template, map)
end

--@desc 车夫的初始模板
function CheFuModel:getDefaultTemplate(map)
    if villageId[map.id] then
        map.name = UserMapRelation:getVillageName(Helper:getDef(map.villageIndex, 1))
    end

    return {
        id = CHEFUID,
        sex = "野兽",
        type = "role",
        name = "车夫",
        dsc = "他就是车夫，虽穿着寻常粗布麻衣，但眉目如画，行走之间器宇不凡，气质难以掩盖。",
        canSee = true,
        canTalk = true,
        canKill = false,
        conditionAndResults = {
            {
                conditionRelation = "and",
                conditions = {
                    {
                        arg1 = "玩家操作",
                        arg2 = "交谈"
                    }
                },
                results = {
                    {
                        --type = "离开副本",
                        arg1 = "文本输出",
                        arg2 = "YEL车夫：少侠，前方便是" .. tostring(map.name) .. "。"
                    }
                }
            }
        }
    }
end

--@desc 加入离开功能
function CheFuModel:addLeaveMapAction(template)
    local cr =
        self:createBtnAction(
        "离开",
        {
            arg1 = "副本离开"
        }
    )

    self:addAction(template, cr)
end

--@desc 加入寻址功能
function CheFuModel:addGoVillageAction(template)
    local role = User:getRole()
    local HomelandUtil = require("app.models.HomelandModel.HomelandUtil")
    if HomelandUtil:sysIsOpen(false) == false then
        return
    end
    local cr =
        self:createBtnAction(
        "前往",
        {
            arg1 = "询址"
        }
    )

    self:addAction(template, cr)
end

--@desc 回家
function CheFuModel:addGoHomeAction(template)
    --@RefType [app.models.role.Role#Role]
    local role = User:getRole()
    local fq = role:getHomelandAttr("fq")

    if not fq or MapIsEmpty(fq) then
        return
    end

    if fq.status == 0 then
        return
    end

    local cr =
        self:createBtnAction(
        "回家",
        {
            arg1 = "回家"
        }
    )

    self:addAction(template, cr)
end

--@desc 邀请函前往
function CheFuModel:addGoMapWithYaoQingHan(template)
    local role = User:getRole()
    local HomelandUtil = require("app.models.HomelandModel.HomelandUtil")
    if HomelandUtil:sysIsOpen(false) == false then
        return
    end

    local cr =
        self:createBtnAction(
        "递函",
        {
            arg1 = "邀请函前往"
        }
    )

    self:addAction(template, cr)
end

--@desc 回城
function CheFuModel:addBackToLocalMap(template, map)
    local cr =
        self:createBtnAction(
        "回城",
        {
            arg1 = "回城"
        }
    )

    self:addAction(template, cr)
end

--@desc 回城
function CheFuModel:addGoToPingAn(template, map)
    local cr =
        self:createBtnAction(
        "去平安小镇",
        {
            arg1 = "进入平安小镇"
        }
    )

    self:addAction(template, cr)
end

--@desc: 生成一个操作对应的条件结果。
--@author:Liang SongQiang
--@time:2018-06-29 20:17:32
--@actionName:操作名字（按钮名字）
--@resultTb: {arg1 = "xxx",arg2= "xxx"}
function CheFuModel:createBtnAction(actionName, resultTb)
    local t = {
        conditionAndResults = {
            conditionRelation = "and",
            conditions = {
                {
                    arg1 = "玩家操作",
                    arg2 = "操作" .. self._actionCount
                }
            },
            results = {}
        }
    }

    t["caozuo" .. self._actionCount] = true
    t["caozuoName" .. self._actionCount] = actionName

    table.insert(t.conditionAndResults.results, resultTb)

    return t
end

--@desc:加入操作按钮name
--@author:Liang SongQiang
--@time:2018-06-29 20:34:55
function CheFuModel:addAction(template, cr)
    for k, v in pairs(cr) do
        if k ~= "conditionAndResults" then
            template[k] = v
        else
            table.insert(template.conditionAndResults, v)
        end
    end

    self._actionCount = self._actionCount + 1
end

return CheFuModel
00000000000000