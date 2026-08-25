--[[
    --@desc 活动开始时间
    s_time = "20200119",
    --@desc 活动结束时间
    e_time = "20200202",
]]
local ActivityCalendarUtils = require("app.models.Action.ActivityCalendarUtils")

local hztcStartTime, hztcEndTime = ActivityCalendarUtils:getActivityTime(GameConst:getDefaultValue("bafangyouli_huizitiancheng"))

hztcStartTime = Helper:date("%Y%m%d", hztcStartTime)

hztcEndTime = Helper:date("%Y%m%d", hztcEndTime)

local SFTokenCollection2019 = {
    configs = {
        {
            --[[
            exchangeItems = 
                {
                    [itemId（可兑换的物品ID）] = {
                        --@desc 用列表，按顺序遍历
                        {
                            itemId = xx,(需要的物品ID)
                            count = xx,(需拥有的物品数量)
                        },
        
                    }
                }
            ]]
            startTime = hztcStartTime,
            endTime = hztcEndTime,
            --@desc 兑换消耗物品的Flag
            exChangeItemFlag = {
                ["2020weekhztc1"] = "weekhztcjz1",
                ["2020weekhztc2"] = "weekhztcjz2",
                ["2020weekhztc3"] = "weekhztcjz3",
                ["2020weekhztc4"] = "weekhztcjz4",
                --["weekhztcjzwp005"] = "weekhztcjz5"
            },
            exchangeItems = {
                {
                    showTextList = {
                        "追影随风枪残篇之一×1",
                        "追影随风枪残篇之二×1",
                        "风定天南残页×1",
                    },
                    --@desc 可兑换的物品Id
                    exchangItemId = "2020weekzj01",
                    --@desc 传承标记
                    flag = "weekhztcjzb1",
                    --@desc 可兑换次数
                    num = 6,
                    --@desc 兑换需要消耗的物品
                    needItems = {
                        --@desc 用列表，按顺序遍历
                        {
                            itemId = "2020weekhztc1",
                            count = 1
                        },
                        {
                            itemId = "2020weekhztc2",
                            count = 1
                        }
                    },
                    attrRewards = {
                        ["exp"] = 12000,
                        ["pot"] = 10000
                    }
                },
                {
                    showTextList = {
                        "追影随风枪残篇之二x1",
                        "追影随风枪残篇之三×1",
                        "风定天南残页×1",
                    },
                    --@desc 可兑换的物品Id
                    exchangItemId = "2020weekzj02",
                    --@desc 传承标记
                    flag = "weekhztcjzb2",
                    --@desc 可兑换次数
                    num = 6,
                    --@desc 兑换需要消耗的物品
                    needItems = {
                        --@desc 用列表，按顺序遍历
                        {
                            itemId = "2020weekhztc3",
                            count = 1
                        },
                        {
                            itemId = "2020weekhztc4",
                            count = 1
                        }
                    },
                    attrRewards = {
                        ["exp"] = 12000,
                        ["pot"] = 10000
                    }
                },
                {
                    showTextList = {
                        "追影随风枪残篇之一×1",
                        "追影随风枪残篇之二×1",
                        "追影随风枪残篇之三×1",
                        "追影随风枪残篇之四×1",
                        "风定天南残页×1",
                    },
                    --@desc 可兑换的物品Id
                    exchangItemId = "2020weekzj03",
                    --@desc 传承标记
                    flag = "weekhztcjzb3",
                    --@desc 可兑换次数
                    num = 4,
                    --@desc 兑换需要消耗的物品
                    needItems = {
                        --@desc 用列表，按顺序遍历
                        {
                            itemId = "2020weekhztc1",
                            count = 1
                        },
                        {
                            itemId = "2020weekhztc2",
                            count = 1
                        },
                        {
                            itemId = "2020weekhztc3",
                            count = 1
                        },
                        {
                            itemId = "2020weekhztc4",
                            count = 1
                        }
                    },
                    attrRewards = {
                        ["exp"] = 15000,
                        ["pot"] = 12000
                    }
                },
                -- {
                --     showTextList = {
                --         "阴风爪×1",
                --         "锁天笼地残页×5",
                --     },
                --     --@desc 可兑换的物品Id
                --     exchangItemId = "2020jizibox4",
                --     --@desc 传承标记
                --     flag = "2020xcjzb4",
                --     --@desc 可兑换次数
                --     num = 1,
                --     --@desc 兑换需要消耗的物品
                --     needItems = {
                --         --@desc 用列表，按顺序遍历
                --         {
                --             itemId = "2020xcjzwp001",
                --             count = 1
                --         },
                --         {
                --             itemId = "2020xcjzwp002",
                --             count = 1
                --         },
                --         {
                --             itemId = "2020xcjzwp003",
                --             count = 1
                --         },
                --         {
                --             itemId = "2020xcjzwp004",
                --             count = 1
                --         },
                --         {
                --             itemId = "2020xcjzwp005",
                --             count = 1
                --         }
                --     }
                -- }
            }
        },
        {
            --[[
               exchangeItems = 
                {
                    [itemId（可兑换的物品ID）] = {
                        --@desc 用列表，按顺序遍历
                        {
                            itemId = xx,(需要的物品ID)
                            count = xx,(需拥有的物品数量)
                        },
        
                    }
                }
            ]]
            startTime = "20210201",
            endTime = "20210301",
            --@desc 兑换消耗物品的Flag
            exChangeItemFlag = {
                ["2020weekhztc1"] = "weekhztcjz1",
                ["2020weekhztc2"] = "weekhztcjz2",
                ["2020weekhztc3"] = "weekhztcjz3",
                ["2020weekhztc4"] = "weekhztcjz4",
                --["weekhztcjzwp005"] = "weekhztcjz5"
            },
            exchangeItems = {
                {
                    showTextList = {
                        "追影随风枪残篇之一×1",
                        "追影随风枪残篇之二×1",
                        "风定天南残页×1",
                    },
                    --@desc 可兑换的物品Id
                    exchangItemId = "2020weekzj01",
                    --@desc 传承标记
                    flag = "weekhztcjzb1",
                    --@desc 可兑换次数
                    num = 24,
                    --@desc 兑换需要消耗的物品
                    needItems = {
                        --@desc 用列表，按顺序遍历
                        {
                            itemId = "2020weekhztc1",
                            count = 1
                        },
                        {
                            itemId = "2020weekhztc2",
                            count = 1
                        }
                    },
                    attrRewards = {
                        ["exp"] = 12000,
                        ["pot"] = 10000
                    }
                },
                {
                    showTextList = {
                        "追影随风枪残篇之二x1",
                        "追影随风枪残篇之三×1",
                        "风定天南残页×1",
                    },
                    --@desc 可兑换的物品Id
                    exchangItemId = "2020weekzj02",
                    --@desc 传承标记
                    flag = "weekhztcjzb2",
                    --@desc 可兑换次数
                    num = 24,
                    --@desc 兑换需要消耗的物品
                    needItems = {
                        --@desc 用列表，按顺序遍历
                        {
                            itemId = "2020weekhztc3",
                            count = 1
                        },
                        {
                            itemId = "2020weekhztc4",
                            count = 1
                        }
                    },
                    attrRewards = {
                        ["exp"] = 12000,
                        ["pot"] = 10000
                    }
                },
                {
                    showTextList = {
                        "追影随风枪残篇之一×1",
                        "追影随风枪残篇之二×1",
                        "追影随风枪残篇之三×1",
                        "追影随风枪残篇之四×1",
                        "风定天南残页×1",
                    },
                    --@desc 可兑换的物品Id
                    exchangItemId = "2020weekzj03",
                    --@desc 传承标记
                    flag = "weekhztcjzb3",
                    --@desc 可兑换次数
                    num = 16,
                    --@desc 兑换需要消耗的物品
                    needItems = {
                        --@desc 用列表，按顺序遍历
                        {
                            itemId = "2020weekhztc1",
                            count = 1
                        },
                        {
                            itemId = "2020weekhztc2",
                            count = 1
                        },
                        {
                            itemId = "2020weekhztc3",
                            count = 1
                        },
                        {
                            itemId = "2020weekhztc4",
                            count = 1
                        }
                    },
                    attrRewards = {
                        ["exp"] = 15000,
                        ["pot"] = 12000
                    }
                },
                -- {
                --     showTextList = {
                --         "阴风爪×1",
                --         "锁天笼地残页×5",
                --     },
                --     --@desc 可兑换的物品Id
                --     exchangItemId = "2020jizibox4",
                --     --@desc 传承标记
                --     flag = "2020xcjzb4",
                --     --@desc 可兑换次数
                --     num = 1,
                --     --@desc 兑换需要消耗的物品
                --     needItems = {
                --         --@desc 用列表，按顺序遍历
                --         {
                --             itemId = "2020xcjzwp001",
                --             count = 1
                --         },
                --         {
                --             itemId = "2020xcjzwp002",
                --             count = 1
                --         },
                --         {
                --             itemId = "2020xcjzwp003",
                --             count = 1
                --         },
                --         {
                --             itemId = "2020xcjzwp004",
                --             count = 1
                --         },
                --         {
                --             itemId = "2020xcjzwp005",
                --             count = 1
                --         }
                --     }
                -- }
            }
        }
    }
}

function SFTokenCollection2019:initConfig()
    self.config = {}

    local currTime = GetTime()

    for k,config in pairs(self.configs) do
        if MapIsEmpty(config) == false then
            if currTime > Helper:getTimeStampWithStringDate(config.startTime, 0) and currTime < Helper:getTimeStampWithStringDate(config.endTime, 0) then
                self.config = config
                break
            end
        end
    end
end

function SFTokenCollection2019:getConfig()
    return self.config
end

function SFTokenCollection2019:randomToken()
    local list = {
        "2020weekhztc1",
        "2020weekhztc2",
        "2020weekhztc3",
        "2020weekhztc4"
    }
    local itemId = ""
    local role = User:getRole()

    --@desc 筛选随机数组。
    local random_list = {}
    for _, itemId in ipairs(list) do
        local isAdd = true
        local item_flag = self.config.exChangeItemFlag[itemId]
        for index, compare_itemId in ipairs(list) do
            if compare_itemId ~= itemId then
                local compare_flag = self.config.exChangeItemFlag[compare_itemId]

                if role:getInheritFlag(item_flag) - role:getInheritFlag(compare_flag) >= 2 then
                    isAdd = false
                    break
                else
                    isAdd = true
                end
            end
        end

        if isAdd then
            table.insert(random_list, itemId)
        end
    end

    itemId = random_list[math.random(1, #random_list)]

    return itemId
end

function SFTokenCollection2019:getItemFlag(itemId)    
    return self.config.exChangeItemFlag[itemId]
end

function SFTokenCollection2019:addToken(itemId, count)
    local role = User:getRole()

    local flagName = self.config.exChangeItemFlag[itemId]

    role:addItemCount(itemId, count)

    role:setInheritFlag(flagName, role:getInheritFlag(flagName) + count)

    local item = role:getOneItemByKey(itemId)

    PopText("您获得了" .. item.name .. " X1")
end

return SFTokenCollection2019
00