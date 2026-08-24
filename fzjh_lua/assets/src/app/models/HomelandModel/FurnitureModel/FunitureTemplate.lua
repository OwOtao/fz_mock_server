local FunitureTemplate = {}

local defaultConAndResult =
    function(itemAttr, cType)
    local tb =
        switch(
        cType,
        {
            ["收起"] = {
                canUse10 = 1,
                useName10 = "收起",
                conditionAndResults = {
                    conditionRelation = "and",
                    conditions = {
                        {
                            arg1 = "玩家操作",
                            arg2 = "使用10"
                        }
                    },
                    results = {
                        {
                            arg1 = "家具收起"
                        }
                    }
                }
            },
            ["操作"] = {
                canUse9 = 1,
                useName9 = itemAttr.useName,
                conditionAndResults = {
                    conditionRelation = "and",
                    conditions = {
                        {
                            arg1 = "玩家操作",
                            arg2 = "使用9"
                        }
                    },
                    results = {
                        {
                            arg1 = "家具使用"
                        }
                    }
                }
            }
        }
    )
    return tb
end

local templateByType = {
    ["蒲团"] = function(itemAttr)
        return {
            canUse1 = 1,
            useName1 = "闭关",
            canUse2 = 1,
            useName2 = "调息",
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
                            arg1 = "副本闭关"
                        }
                    }
                },
                {
                    conditionRelation = "and",
                    conditions = {
                        {
                            arg1 = "玩家操作",
                            arg2 = "使用2"
                        }
                    },
                    results = {
                        {
                            arg1 = "副本调息"
                        }
                    }
                }
            }
        }
    end,
    ["灶台"] = function(itemAttr)
        return {
            canUse1 = 1,
            useName1 = "制作菜肴",
            canUse2 = 0,
            useName2 = "装盒",
            canUse3 = 0,
            useName3 = "吃饭",
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
                            arg1 = "文本输出",
                            arg2 = "你看着灶台老半天，不知该如何制作菜肴，还是找个会厨艺的人来吧。"
                        }
                    }
                },
                {
                    conditionRelation = "and",
                    conditions = {
                        {
                            arg1 = "玩家操作",
                            arg2 = "使用2"
                        }
                    },
                    results = {
                        {
                            arg1 = "装盒"
                        }
                    }
                },
                {
                    conditionRelation = "and",
                    conditions = {
                        {
                            arg1 = "玩家操作",
                            arg2 = "使用3"
                        }
                    },
                    results = {
                        {
                            arg1 = "吃饭"
                        }
                    }
                }
            }
        }
    end,
    ["床"] = function(itemAttr)
        return {
            canUse1 = 1,
            useName1 = "休息",
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
                            arg1 = "休息"
                        }
                    }
                },
                {
                    conditionRelation = "and",
                    conditions = {
                        {
                            arg1 = "玩家进入房间",
                        }
                    },
                    results = {
                        {
                            arg1 = "副本疲倦值文本提示"
                        }
                    }
                }
            }
        }
    end,
    ["书案"] = function(itemAttr)
        return {
            canUse1 = 1,
            useName1 = "写邀请函",
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
                            arg1 = "发送邀请函"
                        }
                    }
                }
            }
        }
    end,
    ["药炉"] = function(itemAttr)
        return {
            canUse1 = 1,
            useName1 = "制药",
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
                            arg1 = "配制毒药",
                            arg2 = itemAttr.fun,
                            arg3 = itemAttr.value
                        }
                    }
                }
            }
        }
    end,
    ["熔炼炉"] = function(itemAttr)
        local values = string.split(itemAttr.value, ";")

        if #values ~= 2 then
            assert(false, "家具表熔炼炉value值填写错误，ID：" .. itemAttr.id)
        end

        return {
            canUse1 = 1,
            useName1 = "熔炉",
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
                            arg1 = "家园熔炉",
                            arg2 = values[1],
                            arg3 = values[2]
                        }
                    }
                }
            }
        }
    end,
    ["储物箱"] = function(itemAttr)
        return {
            canUse1 = 1,
            useName1 = "打开",
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
                            arg1 = "储物箱"
                        }
                    }
                }
            }
        }
    end,
    ["土地"] = function(itemAttr)
        return {
            canUse1 = 1,
            useName1 = "播种",
            canUse2 = 0,
            useName2 = "查看",
            canUse3 = 0,
            useName3 = "照料",
            canUse4 = 0,
            useName4 = "铲除",
            canUse5 = 0,
            useName5 = "收取",
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
                            arg1 = "播种"
                        }
                    }
                },
                {
                    conditionRelation = "and",
                    conditions = {
                        {
                            arg1 = "玩家操作",
                            arg2 = "使用2"
                        }
                    },
                    results = {
                        {
                            arg1 = "种植进度"
                        }
                    }
                },
                {
                    conditionRelation = "and",
                    conditions = {
                        {
                            arg1 = "玩家操作",
                            arg2 = "使用3"
                        }
                    },
                    results = {
                        {
                            arg1 = "照料"
                        }
                    }
                },
                {
                    conditionRelation = "and",
                    conditions = {
                        {
                            arg1 = "玩家操作",
                            arg2 = "使用4"
                        }
                    },
                    results = {
                        {
                            arg1 = "铲除"
                        }
                    }
                },
                {
                    conditionRelation = "and",
                    conditions = {
                        {
                            arg1 = "玩家操作",
                            arg2 = "使用5"
                        }
                    },
                    results = {
                        {
                            arg1 = "种植收取"
                        }
                    }
                }
            }
        }
    end,
    -- ["副本木人"] = function(itemAttr)
    --     return {
    --         canUse1 = 1,
    --         useName1 = "练功",
    --         conditionAndResults = {
    --             {
    --                 conditionRelation = "and",
    --                 conditions = {
    --                     {
    --                         arg1 = "玩家操作",
    --                         arg2 = "使用1"
    --                     }
    --                 },
    --                 results = {
    --                     {
    --                         arg1 = "副本练功"
    --                     }
    --                 }
    --             }
    --         }
    --     }
    -- end,
    -- ["永久木人"] = function(itemAttr)
    --     return {
    --         canUse1 = 1,
    --         useName1 = "练功",
    --         conditionAndResults = {
    --             {
    --                 conditionRelation = "and",
    --                 conditions = {
    --                     {
    --                         arg1 = "玩家操作",
    --                         arg2 = "使用1"
    --                     }
    --                 },
    --                 results = {
    --                     {
    --                         arg1 = "副本练功"
    --                     }
    --                 }
    --             }
    --         }
    --     }
    -- end,
    ["门"] = function(itemAttr)
        return {
            canUse1 = 1,
            useName1 = "改造大门",
            canUse2 = 1,
            useName2 = "改造门联",
            canUse3 = 0,
            useName3 = "敲门",
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
                            arg1 = "大门改造"
                        }
                    }
                },
                {
                    conditionRelation = "and",
                    conditions = {
                        {
                            arg1 = "玩家操作",
                            arg2 = "使用2"
                        }
                    },
                    results = {
                        {
                            arg1 = "改造对联"
                        }
                    }
                },
                {
                    conditionRelation = "and",
                    conditions = {
                        {
                            arg1 = "玩家操作",
                            arg2 = "使用3"
                        }
                    },
                    results = {
                        {
                            arg1 = "敲门"
                        }
                    }
                }
            }
        }
    end,
    ["饰品箱"] = function(itemAttr)
        return {
            canUse1 = 1,
            useName1 = "查看",
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
                            arg1 = "饰品箱"
                        }
                    }
                }
            }
        }
    end,
    ["茶案"] = function(itemAttr)
        return {
            canUse1 = 1,
            useName1 = "品书",
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
                            arg1 = "品书"
                        }
                    }
                }
            }
        }
    end,
    ["井"] = function(itemAttr)
        return {
            canUse1 = 1,
            useName1 = "打水",
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
                            arg1 = "打水"
                        }
                    }
                }
            }
        }
    end,
    ["饭桌"] = function(itemAttr)
        return {
            canUse1 = 1,
            useName1 = "设宴",
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
                            arg1 = "设宴"
                        }
                    }
                }
            }
        }
    end,
    ["庭院"] = function(itemAttr)
        return {
            canUse1 = 1,
            useName1 = "观景",
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
                            arg1 = "观景"
                        }
                    }
                }
            }
        }
    end,
    ["锻造炉"] = function(itemAttr)
        return {
            canUse1 = 1,
            useName1 = "锻造",
            canUse2 = 1,
            useName2 = "神兵改名",
            canUse3 = 1,
            useName3 = "修理",
            canUse4 = 1,
            useName4 = "熔兵",
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
                            arg1 = "家园锻造",
                            arg2 = 1400,
                        }
                    }
                },
                {
                    conditionRelation = "and",
                    conditions = {
                        {
                            arg1 = "玩家操作",
                            arg2 = "使用2"
                        }
                    },
                    results = {
                        {
                            arg1 = "神兵改名"
                        }
                    }
                },
                {
                    conditionRelation = "and",
                    conditions = {
                        {
                            arg1 = "玩家操作",
                            arg2 = "使用3"
                        }
                    },
                    results = {
                        {
                            arg1 = "修理兵器",
                            arg2 = 1
                        }
                    }
                },
                {
                    conditionRelation = "and",
                    conditions = {
                        {
                            arg1 = "玩家操作",
                            arg2 = "使用4"
                        }
                    },
                    results = {
                        {
                            arg1 = "熔兵"
                        }
                    }
                }
            }
        }
    end,
    ["晶台"] = function(itemAttr)
        return {
            canUse1 = 1,
            useName1 = "查看",
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
                            arg1 = "完美闭关"
                        }
                    }
                }
            }
        }
    end,
    ["书柜"] = function(itemAttr)
        return {
            canUse1 = 1,
            useName1 = "查看藏书",
            canUse2 = 1,
            useName2 = "查看秘籍",
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
                            arg1 = "查看藏书"
                        }
                    }
                },
                {
                    conditionRelation = "and",
                    conditions = {
                        {
                            arg1 = "玩家操作",
                            arg2 = "使用2"
                        }
                    },
                    results = {
                        {
                            arg1 = "查看秘籍"
                        }
                    }
                }
            }
        }
    end,
    ["墙壁"] = function(itemAttr)
        return {
            canUse1 = 1,
            useName1 = "查看",
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
                            arg1 = "查看悬兵洞"
                        }
                    }
                }
            }
        }
    end,
    ["衣柜"] = function(itemAttr)
        return {
            canUse1 = 1,
            useName1 = "查看",
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
                            arg1 = "查看藏衣阁"
                        }
                    }
                }
            }
        }
    end,
    ["香炉"] = function(itemAttr)
        return {
            canUse1 = 1,
            useName1 = "添香",
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
                            arg1 = "副本香炉"
                        }
                    }
                }
            }
        }
    end,
    ["假人"] = function(itemAttr)
        return {
            canUse1 = 1,
            useName1 = "修炼",
            canUse2 = 1,
            useName2 = "销毁",
            conditionAndResults = {
                {
                    conditionRelation = "and",
                    conditions = {
                        {
                            arg1 = "假人耐久为零",
                        },
                    },
                    results = {
                        {
                            arg1 = "假人破损"
                        },
                    }
                },
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
                            arg1 = "修炼武功"
                        }
                    }
                },
                 {
                    conditionRelation = "and",
                    conditions = {
                        {
                            arg1 = "玩家操作",
                            arg2 = "使用2"
                        }
                    },
                    results = {
                        {
                            arg1 = "假人销毁"
                        }
                    }
                },
            }
        }
    end,
    ["梦境香炉"] = function(itemAttr)
        return {
            canUse1 = 1,
            useName1 = "添香",
            canUse2 = 1,
            useName2= "收起",
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
                            arg1 = "梦境香炉添香"
                        }
                    }
                },
                {
                    conditionRelation = "and",
                    conditions = {
                        {
                            arg1 = "玩家操作",
                            arg2 = "使用2"
                        }
                    },
                    results = {
                        {
                            arg1 = "梦境香炉收起"
                        }
                    }
                }
            }
        }
    end,

    ["神功书案"] = function(itemAttr)
        return {
            canUse1 = 1,
            useName1 = "创作",
            canUse2 = 1,
            useName2 = "查看",
            canUse3 = 1,
            useName3= "收起",
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
                            arg1 = "自创武学"
                        }
                    }
                },
                {
                    conditionRelation = "and",
                    conditions = {
                        {
                            arg1 = "玩家操作",
                            arg2 = "使用2"
                        }
                    },
                    results = {
                        {
                            arg1 = "查看自创招式"
                        }
                    }
                },
                {
                    conditionRelation = "and",
                    conditions = {
                        {
                            arg1 = "玩家操作",
                            arg2 = "使用3"
                        }
                    },
                    results = {
                        {
                            arg1 = "神功书案收起"
                        }
                    }
                }
            }
        }
    end,

    ["神功书架"] = function(itemAttr)
        return {
            canUse1 = 1,
            useName1 = "查看武学",
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
                            arg1 = "查看自创武学"
                        }
                    }
                }
            }
        }
    end,
}

--@desc 根据房间改变状态
--room  服务器下发的房间信息
local templateByRoom = {
    ["蒲团"] = function(template, room,map)
        if room.roomType == "tsfangjian015" then
            --@desc调息室
            template.canUse1 = false
            template.canUse2 = true
        elseif room.roomType == "tsfangjian018" then
            --@desc 闭关室
            template.canUse1 = true
            template.canUse2 = false
        else
            template.canUse1 = false
            template.canUse2 = false
        end
    end,
    ["门"] = function(template, room,map)
        --@RefType [src.app.models.HomelandModel.HomelandRoomUtil#HomelandRoomUtil]
        local HomelandRoomUtil = require("app.models.HomelandModel.HomelandRoomUtil")

        HomelandRoomUtil:updateDoorRoomAndDoorItemDsc(template,room,map)
    end
}

--@desc 自定义状态改变
local templateByCustom = {
    ["门"] = function(template, room,map)
        --@RefType [src.app.models.role.Role#Role]
        local role = User:getRole()

        --@RefType [src.app.models.map.UserMap#UserMap]
        local UserMap = require("app.models.map.UserMap")

        local linkDir = UserMap:getHouseDirByIndex(map.dirMark)

        local goRoomId = room.link[linkDir]

        local fq = role:getHomelandAttr("fq")

        if not fq or tonumber(fq.mid) ~= tonumber(room.mid) then
            local tb = {
                conditionRelation = "and",
                conditions = {
                    {
                        arg1 = "玩家要进入房间",
                        arg2 = goRoomId
                    },
                    {
                        arg1 = "地图标记等于",
                        arg2 = "doorIsOpen",
                        arg3 = 0
                    }
                },
                results = {
                    {
                        arg1 = "阻止玩家移动"
                    },
                    {
                        arg1 = "弹出文本",
                        arg2 = "大门拦住了你。"
                    }
                }
            }
            table.insert(template.conditionAndResults, tb)

            template.canUse1 = 0
            template.canUse2 = 0
            template.canUse3 = 1
        end
    end,

    ["神功书案"] = function(template, room,map)
        --@RefType [src.app.models.role.Role#Role]
        local player = User:getRole()
        local selfCreatedSkillSystem = player:getSelfCreatedSkillSystem()
        if selfCreatedSkillSystem:checkIsCreating() then
            template.canUse1 = 0
        else
            template.canUse2 = 0
        end
    end,

}

function FunitureTemplate:initByCustom(template, iType, room, map)
    if not templateByCustom[iType] then
        return
    end

    local fun = templateByCustom[iType]

    fun(template, room, map)
end

--@desc:根据房间类型初始化模板
--@author:Liang SongQiang
--@time:2018-06-01 11:57:12
--@iType:家具类型
--@room:房间信息
function FunitureTemplate:initByRoom(template, iType, room, map)
    if not templateByRoom[iType] then
        return
    end

    local fun = templateByRoom[iType]

    fun(template, room, map)
end

--@desc: 根据家具类型和放置房间初始化模板信息
--@author:Liang SongQiang
--@time:2018-06-01 11:49:39
--@furniture:家具初始模板
--@room: 放置房间
function FunitureTemplate:intTemplate(furniture, room, map)
    --@RefType [src.app.models.role.Role#Role]
    local role = User:getRole()
    local fq = role:getHomelandAttr("fq")

    local iType = furniture.iType

    local itemAttr = Item:getOneItemByKey(furniture.jjId)
    local template = {}
    if not template.conditionAndResults then
        template.conditionAndResults = {}
    end

    if itemAttr.shouqi == 1 and fq and fq.mid == map.mid then
        local tb = defaultConAndResult(itemAttr, "收起")
        for k, v in pairs(tb) do
            if k ~= "conditionAndResults" then
                template[k] = v
            else
                table.insert(template.conditionAndResults, v)
            end
        end
    end

    if itemAttr.usepossible == 1 and itemAttr.useName then
        local tb = defaultConAndResult(itemAttr, "操作")
        for k, v in pairs(tb) do
            if k ~= "conditionAndResults" then
                template[k] = v
            else
                table.insert(template.conditionAndResults, v)
            end
        end
    end

    if not templateByType[iType] then
        Helper:tableCover(furniture, template)
        return furniture
    end

    local func = templateByType[iType]
    for k, v in pairs(clone(func(itemAttr))) do
        if k ~= "conditionAndResults" then
            template[k] = v
        else
            for index, conditionAndResult in pairs(v) do
                table.insert(template.conditionAndResults, conditionAndResult)
            end
        end
    end

    self:initByRoom(template, iType, room, map)

    self:initByCustom(template, iType, room, map)

    Helper:tableCover(furniture, template)

    return furniture
end

return FunitureTemplate
0000000000