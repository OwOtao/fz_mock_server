--@SuperType [src.app.models.map.MapHandle.Modules.BaseModule#BaseModule]
local FestivalModule = class("FestivalModule", require("app.models.map.MapHandle.Modules.BaseModule"))

--@desc 涉及副本ID ：格式{["id"] = true} 默认为nil，无限制
FestivalModule.mapId = nil

--@desc 涉及房间 : 格式{["id"] = true} 默认为nil，无限制
FestivalModule.roomId = nil

--@desc 开启状态，默认开启
FestivalModule.status = 1

--@desc 活动时间 : 格式：20171001，默认值0 表示无时间限制
FestivalModule.activityTime = 0

--@desc 子模块
FestivalModule.childModule = {
    ["QiXi2018"] = "app.models.map.MapHandle.Modules.FestivalModule.qixi_2018",
    ["ZhongQiu2018"] = "app.models.map.MapHandle.Modules.FestivalModule.ZhongQiu2018",
    ["DongZhi2018"] = "app.models.map.MapHandle.Modules.FestivalModule.Dongzhi2018",
    ["HeroFeastModule"] = "app.models.map.MapHandle.Modules.FestivalModule.HeroFeastModule",
    ["NewYearChuanMenModule"] = "app.models.map.MapHandle.Modules.FestivalModule.NewYearChuanMenModule",
    ["QiXi2019"] = "app.models.map.MapHandle.Modules.FestivalModule.QiXi2019",
    ["ActivityCalendar"] = "app.models.map.MapHandle.Modules.FestivalModule.ActivityCalendar",
    ["WuJueChallenge"] = "app.models.map.MapHandle.Modules.FestivalModule.WuJueChallenge",
}

--获得七夕情缘奖励
local function getQiXiQingYuanReward()
    print("---------------------------------------------------")
    print("-----------------获得七夕情缘奖励----------------------")
    local role = User:getRole()
    local tryNum = role:getInheritFlag("七夕情缘任务情侣促和次数")
    local tryNum1 = role:getInheritFlag("七夕情缘任务情侣拆散次数")
    local isdo = role:getInheritFlag("七夕情缘奖励是否获取")
    if isdo == 0 then
        if tryNum + tryNum1 == 7 then
            if tryNum == 0 then
                -- role:getOneItemByKey("qiriqingyuan6")
                role:addItemCount("qiriqingyuan6", 1)
                role:setFlag("七夕情缘奖励", 1)
                role:setInheritFlag("七夕情缘奖励是否获取", 1)
            elseif tryNum == 1 then
                role:addItemCount("qiriqingyuan1", 1)
                role:addItemCount("qiriqingyuan2", 6)
                role:setFlag("七夕情缘奖励", 2)
                role:setInheritFlag("七夕情缘奖励是否获取", 1)
            elseif tryNum == 2 then
                role:addItemCount("qiriqingyuan1", 2)
                role:addItemCount("qiriqingyuan2", 5)
                role:setFlag("七夕情缘奖励", 2)
                role:setInheritFlag("七夕情缘奖励是否获取", 1)
            elseif tryNum == 3 then
                role:addItemCount("qiriqingyuan1", 3)
                role:addItemCount("qiriqingyuan2", 4)
                role:setFlag("七夕情缘奖励", 2)
                role:setInheritFlag("七夕情缘奖励是否获取", 1)
            elseif tryNum == 4 then
                role:addItemCount("qiriqingyuan1", 4)
                role:addItemCount("qiriqingyuan2", 3)
                role:setFlag("七夕情缘奖励", 3)
                role:setInheritFlag("七夕情缘奖励是否获取", 1)
            elseif tryNum == 5 then
                role:addItemCount("qiriqingyuan1", 5)
                role:addItemCount("qiriqingyuan2", 2)
                role:setFlag("七夕情缘奖励", 3)
                role:setInheritFlag("七夕情缘奖励是否获取", 1)
            elseif tryNum == 6 then
                role:addItemCount("qiriqingyuan1", 6)
                role:addItemCount("qiriqingyuan2", 1)
                role:setFlag("七夕情缘奖励", 3)
                role:setInheritFlag("七夕情缘奖励是否获取", 1)
            elseif tryNum == 7 then
                role:addItemCount("qiriqingyuan5", 1)
                role:setFlag("七夕情缘奖励", 4)
                role:setInheritFlag("七夕情缘奖励是否获取", 1)
            end
        end
    end
end

--@desc 条件结果的方法
FestivalModule.doResult = {
    ["七夕文本动画"] = function(map, result, environment)
        local text = string.split(result.arg2, "|")
        local resultsStrs = result.arg3
        local TeacherAnimationLayer = require("app.views.layer.TeacherLayer.TeacherAnimationLayer")
        local teacherAnimationLayer = TeacherAnimationLayer:getInstance()

        for i, v in ipairs(text) do
            text[i] = string.gsub(text[i], "$IN", User:getRoleAttr("inherit").name)
        end

        teacherAnimationLayer:setVisible(false)
        teacherAnimationLayer:createTextFromArrayForQiXi(text)
        teacherAnimationLayer:show(
            function()
                if resultsStrs ~= nil then
                    map:doNoRoleResults(resultsStrs, environment)
                end
            end
        )
    end,
    ["七夕文本动画1"] = function(map, result, environment)
        local text = string.split(result.arg2, "|")
        local resultsStrs = result.arg3
        local TeacherAnimationLayer = require("app.views.layer.TeacherLayer.TeacherAnimationLayer")
        local teacherAnimationLayer = TeacherAnimationLayer:getInstance()

        for i, v in ipairs(text) do
            text[i] = string.gsub(text[i], "$IN", User:getRoleAttr("inherit").name)
        end

        teacherAnimationLayer:setVisible(false)
        teacherAnimationLayer:createTextFromArrayForQiXi1(text)
        teacherAnimationLayer:show(
            function()
                if resultsStrs ~= nil then
                    map:doNoRoleResults(resultsStrs, environment)
                end
            end
        )
    end,

    ["中秋灯谜"] = function(map, result, environment)
        if User:getRole():getDayFlag("灯谜活动答题")==1 then 
         PopText("今天你已经猜过灯谜了！")
        else
            PopupLayerController:showLayer(
                "MidAutumnFestivalLanternRiddleLayer",
                function(layer)
                    local questions=User:getRole():getDayFlag("灯谜活动答题结果")
                    local questionsTab=User:getRole():getDayFlag("灯谜活动已答题")
                    if type(questionsTab)~="table" then 
                        questionsTab=nil
                    end
                     if type(questions)~="string" then 
                        questions=nil
                    end
                    layer:showLayer(questionsTab,questions) 
                end
            )
        end
    end,
    ["中秋礼券领取"] = function(map, result, environment)
        local activityName = result.arg2 
        if not activityName or activityName == "" then 
            print("中秋礼券领取 arg2 配置有问题",result.arg2)
            return
        end
        local FestivalLanternRiddleRewardModel = require("app.models.Action.FestivalLanternRiddle.FestivalLanternRiddleRewardModel")
        FestivalLanternRiddleRewardModel:getFestivalReward(activityName,map)
      
    end,
    ["中秋播放动画"] = function(map, result, environment)
        local imageTab=string.split(result.arg2, ";") 
        local timeTab= string.split(result.arg3, ";")
        local image1=imageTab[1]
        local image2=imageTab[2]
        local duration1=tonumber(timeTab[1])
        local duration2=tonumber(timeTab[2])
        local musicName
        if result.arg5 then 
            musicName=result.arg5
        end
        PopupLayerController:showLayer("ShowActionLayer", function(layer)

            layer:setEndFunc(function ()     
                if result.arg4 then
                    map:doNoRoleResults(result.arg4, environment)
                end
            end)

            layer:showLayer(duration1,duration2,image1,image2,musicName,function ()
            end)
        end)
    end,
    ["中秋文本动画"] = function(map, result, environment)
        local text = string.split(result.arg2, "|")
        local resultsStrs = result.arg3
        local resultsFails = result.arg4
        local musicName = result.arg5
        local TeacherAnimationLayer = require("app.views.layer.TeacherLayer.TeacherAnimationLayer")
        local teacherAnimationLayer = TeacherAnimationLayer:getInstance()

        for i, v in ipairs(text) do
            text[i] = string.gsub(text[i], "$IN", User:getRoleAttr("inherit").name)
        end

        User:getRole():setFlag("PVP活动状态", "忙碌")

        teacherAnimationLayer:setVisible(false)
        teacherAnimationLayer:createTextFromArrayForMidAutumn(
            text,
            function()
                teacherAnimationLayer:removeFromParent()
                User:getRole():setFlag("PVP活动状态", "空闲中")
                Audio:stopMusic(musicName)
                if resultsStrs ~= nil then
                    map:doNoRoleResults(resultsFails, environment)
                end
            end,
            musicName
        )
        teacherAnimationLayer:show(
            function()
                if resultsStrs ~= nil then
                    User:getRole():setFlag("PVP活动状态", "空闲中")
                    Audio:stopMusic(musicName)
                    map:doNoRoleResults(resultsStrs, environment)
                    --@desc 刷新当前房间条件结果
                    map:doRoomConditionAndResult(map.__MapLayer._currRoom.id)
                end
            end
        )
    end,
    ["中元节交互"] = function(map, result, environment)
        local text = {
            ["查看"] = {
                [1] = "你站在镜子前，镜中倒映出你的容貌。",
                [2] = "你看向铜镜，镜子映照出你的模样，但似乎又有点不同。",
                [3] = "你站在镜子前，看着镜内的自己身后似乎有一团黑影，你忙不迭回身看去，但似乎什么都没有。"
            },
            ["推开"] = {
                [1] = "你用力推着棺材盖，突然从棺材里发出阵阵哭声，十分阴森怪异，你赶忙停止了动作。",
                [2] = "你尝试着推开棺材盖，但这棺材盖十分牢实，你费了九牛二虎之力也无法打开。"
            },
            ["坐下"] = {
                [1] = "你坐上了这个破旧蒲团，想打坐一会，却发现无论如何也静不下心，十分奇怪。",
                [2] = "你盘膝坐在这个蒲团上，运功打坐，突然发现蒲团里似乎有什么东西在动，吓得你一跳而起。",
                [3] = "你坐在蒲团上打坐了一番，许久才收功起身。"
            },
            ["观察"] = {
                [1] = "你查看着这个石像，发现也没什么奇怪的地方。",
                [2] = "你摸着这个石像，从你的手掌处传来丝丝阴凉，你感觉十分舒服。",
                [3] = "你打量着这个石像，发现石像的眼睛被雕刻得十分逼真，你用手摩挲着石像眼睛，发现质感十分奇怪。",
                [4] = "你看了一眼石像，发现它似乎也在看着你。"
            }
        }
        local word = Helper:getDef(text[result.arg2], {})
        RichPrint("main", word[math.random(1, #word)])
    end,
    ["孤魂野鬼送礼"] = function(map, result, environment)
        local currRole = environment.currRole
        local player = User:getRole()
        print("送礼ID:", currRole.baseId, result.arg2)
        local function checkCanRewardAndGetRewardList(list)
            local reward = {}
            for k, v in pairs(list) do
                if v.func then
                    print("$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$")
                    local random
                    list[k].id, list[k].type, list[k].count, list[k].name, list[k].extraId = v.func()
                    print(list[k].id, list[k].type, list[k].count, list[k].name, random)
                    if list[k].type == "item" and list[k].id ~= nil then
                        list[k].name = User:getRole():getOneItemByKey(list[k].id).name
                    end
                elseif v.rate then
                    local random = Helper:RandomByWeight({[1] = v.rate, [2] = 100 - v.rate})
                    if random == 2 then
                        list[k] = nil
                    end
                end
            end
            for k, v in pairs(list) do
                if v.id ~= nil and v.type == "item" then
                    reward[v.id] = v.count
                end
            end
            if User:getRole():checkCanBuyTwoOrMoreThings(reward) == false then
                return false, list
            end
            return true, list
        end
        local function getReward(item, npcId)
            print("")
            local usualList = {
                ["npc201_24"] = {
                    --孟婆
                    [1] = {
                        name = "冥币",
                        count = 25,
                        type = "item",
                        extraId = "mingbi"
                    },
                    [2] = {
                        id = "yueli",
                        name = "江湖阅历",
                        count = 10,
                        type = "attr"
                    },
                    [3] = {
                        id = "wangchuanjiu1",
                        name = "忘川酒",
                        count = 1,
                        rate = 10,
                        type = "item"
                    }
                },
                ["npc201_02"] = {
                    --判官
                    [1] = {
                        name = "冥币",
                        count = 40,
                        type = "item",
                        extraId = "mingbi"
                    },
                    [2] = {
                        id = "wabaojiangli4",
                        name = "善恶令",
                        count = 1,
                        type = "item"
                    },
                    [3] = {
                        id = "tie106",
                        name = "补天石",
                        count = 1,
                        rate = 20,
                        type = "item"
                    }
                },
                ["npc15_106"] = {
                    --道士
                    [1] = {
                        name = "冥币",
                        count = 20,
                        type = "item",
                        extraId = "mingbi"
                    },
                    [2] = {
                        id = "pot",
                        name = "潜能",
                        count = 2000,
                        type = "attr"
                    },
                    [3] = {
                        name = "江湖美誉",
                        count = 1,
                        rate = 50,
                        type = "item",
                        extraId = "meiyu"
                    }
                }
            }
            local specialList = {
                ["npc201_24"] = {
                    --孟婆  npc201_24
                    [1] = {
                        id = "mengpotang1",
                        name = "孟婆汤",
                        count = 1,
                        type = "item"
                    }
                },
                ["npc201_02"] = {
                    --判官
                    [1] = {
                        name = "冥币",
                        count = 200,
                        type = "item",
                        extraId = "mingbi"
                    }
                },
                ["npc15_106"] = {
                    --道士
                    [1] = {
                        name = "书页",
                        count = 1,
                        type = "item",
                        func = function()
                            local rate = {[1] = 5, [2] = 5, [3] = 60, [4] = 30}
                            local random = Helper:RandomByWeight(rate)
                            if random == 1 then
                                return "yeshushuji32", "item", 1, "黄庭经"
                            elseif random == 2 then
                                return "yeshushuji33", "item", 1, "茅山志"
                            elseif random == 3 then
                                return "pot", "attr", 20000, "潜能"
                            elseif random == 4 then
                                return nil, "item", 5, "江湖美誉", "meiyu"
                            end
                        end
                    }
                }
            }
            if DEBUG_MODE == 1 then
                local usualList = {
                    ["npc201_24"] = {
                        --孟婆
                        [1] = {
                            name = "冥币",
                            count = 20,
                            type = "item",
                            extraId = "mingbi"
                        },
                        [2] = {
                            id = "yueli",
                            name = "江湖阅历",
                            count = 10,
                            type = "attr"
                        },
                        [3] = {
                            id = "wangchuanjiu1",
                            name = "忘川酒",
                            count = 1,
                            rate = 10,
                            type = "item"
                        }
                    },
                    ["npc201_02"] = {
                        --判官
                        [1] = {
                            name = "冥币",
                            count = 30,
                            type = "item",
                            extraId = "mingbi"
                        },
                        [2] = {
                            id = "wabaojiangli4",
                            name = "善恶令",
                            count = 1,
                            type = "item"
                        },
                        [3] = {
                            id = "tie106",
                            name = "补天石",
                            count = 1,
                            rate = 20,
                            type = "item"
                        }
                    },
                    ["npc15_106"] = {
                        --道士
                        [1] = {
                            name = "冥币",
                            count = 15,
                            type = "item",
                            extraId = "mingbi"
                        },
                        [2] = {
                            id = "pot",
                            name = "潜能",
                            count = 1000,
                            type = "attr"
                        },
                        [3] = {
                            name = "江湖美誉",
                            count = 1,
                            rate = 50,
                            type = "item",
                            extraId = "meiyu"
                        }
                    }
                }
                local specialList = {
                    ["npc201_24"] = {
                        --孟婆  npc201_24
                        [1] = {
                            id = "mengpotang1",
                            name = "孟婆汤",
                            count = 1,
                            type = "item"
                        }
                    },
                    ["npc201_02"] = {
                        --判官
                        [1] = {
                            name = "冥币",
                            count = 100,
                            type = "item",
                            extraId = "mingbi"
                        }
                    },
                    ["npc15_106"] = {
                        --道士
                        [1] = {
                            name = "书页",
                            count = 1,
                            type = "item",
                            func = function()
                                local rate = {[1] = 40, [2] = 40, [3] = 10}
                                local random = Helper:RandomByWeight(rate)
                                print(
                                    "获取随**********************************************************************机物品",
                                    random
                                )
                                if random == 1 then
                                    print(
                                        "获取随**********************************************************************机物品",
                                        random
                                    )
                                    return "yeshushuji32", "item", 1, "黄庭经"
                                elseif random == 2 then
                                    print(
                                        "获取随**********************************************************************机物品",
                                        random
                                    )
                                    return "yeshushuji33", "item", 1, "茅山志"
                                elseif random == 3 then
                                    print(
                                        "获取随**********************************************************************机物品",
                                        random
                                    )
                                    return "pot", "attr", 3000, "潜能"
                                else
                                    assert(nil)
                                end
                            end
                        }
                    }
                }
            end
            local list = {}
            if item.itemId == "guhunyeguijiangli2" then
                list = Helper:getDef(specialList[npcId], {})
            else
                list = Helper:getDef(usualList[npcId], {})
            end
            local can_reward, list = checkCanRewardAndGetRewardList(list)
            if can_reward == false then
                PopText("背包空间不足")
            else
                local needWeb = false
                for k, v in pairs(list) do
                    if v.id == nil then
                        needWeb = true
                    end
                end
                if needWeb == false then
                    print("送礼不需要请求服务器")
                    for k, v in pairs(list) do
                        local reward_item = {}
                        if v.type == "item" then
                            if v.id then
                                reward_item = User:getRole():getOneItemByKey(v.id)
                                User:getRole():addItemCount(v.id, v.count)
                                PopText("获取物品" .. reward_item.name .. "X" .. tostring(v.count))
                            end
                        else
                            User:getRole():addAttr(v.id, v.count)
                            PopText(v.name .. "增加" .. tostring(v.count))
                        end
                    end
                    map:doNoRoleResults(result.arg2, environment)
                    User:getRole():addItemCount(item.itemId, -1)
                else
                    print("有货币奖励，需要请求服务器")
                    local spReward = {}
                    for k, v in pairs(list) do
                        if v.id == nil then
                            spReward[v.extraId] = v.count
                        end
                    end
                    -- Helper:print_lua_table(spReward)
                    -- HttpManagerEx:viewCurrencyByType("gongxiandian",function(status, errcode, errmsg, data)
                    HttpManagerEx:updateCurrencyByTable(
                        "add",
                        spReward,
                        "ghyg",
                        function(status, errcode, errmsg, data)
                            if status == 200 and errcode == 0 then
                                local reward_item = {}
                                for k, v in pairs(list) do
                                    local _count
                                    if v.type == "item" then
                                        if v.id ~= nil then
                                            reward_item = User:getRole():getOneItemByKey(v.id)
                                            User:getRole():addItemCount(v.id, v.count)
                                            _count = tostring(v.count)
                                        else
                                            reward_item.name = v.name
                                            if v.extraId == "meiyu" then
                                                _count = tostring(v.count)
                                            else
                                                _count = tostring(v.count) .. "亿"
                                            end
                                        end
                                        PopText("获取物品" .. reward_item.name .. "X" .. _count)
                                    else
                                        User:getRole():addAttr(v.id, v.count)
                                        PopText(v.name .. "增加" .. tostring(v.count))
                                    end
                                end
                                map:doNoRoleResults(result.arg2, environment)
                                User:getRole():addItemCount(item.itemId, -1)
                            else
                                PopText("连接服务器失败!")
                                -- PopText
                                print(
                                    "&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&连接服务器失败&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&"
                                )
                                print(errmsg)
                            end
                        end
                    )
                end
            end
        end
        local function checkItemAndGetReward(item)
            if item == nil then
                RichPrint("main", "我不接受你的物品！")
                return
            end
            getReward(item, environment.currRole.baseId)
        end
        local item = player:getItem("guhunyeguijiangli2")
        if item == nil then
            item = player:getItem("guhunyeguijiangli1")
        end
        HttpManagerEx:countSingleRecordWithType(
            "zhongyuanjie",
            function(status, errcode, errmsg, data)
                if status == 200 and errcode == 0 then
                    checkItemAndGetReward(item)
                else
                    PopText("连接服务器失败!")
                end
            end,
            IS_SHOW_WAITING
        )
        -- checkItemAndGetReward(item)
    end,
    ["拜年委托"] = function(map, result, environment)
        local SpringFestival = require("app.models.SpringFestival.SpringFestival")
        SpringFestival:doBaiNian(environment.currRole, map.id, map)
    end,
    ["拜年"] = function(map, result, environment)
        -- 每日上限10次
        local role = User:getRole()
        local count = role:getDayFlag("每天自由拜年次数")
        if count >= 10 then
            PopText("今天已经获得了10份奖励，明天再来吧。")
            return
        end

        local BaiNianBagLayer = require("app.views.layer.ActionLayer.BaiNianBagLayer")
        BaiNianBagLayer:getInstance():showLayer(environment.currRole, map)
    end,
    ["放风筝"] = function(map, result, environment)
        local role = User:getRole()
        local gameTimes = role:getDayFlag("weekhztc")

        local ActivityCalendarUtils = require("app.models.Action.ActivityCalendarUtils")
        local activityId = GameConst:getDefaultValue("bafangyouli_xiazongzhiyuan")
        if ActivityCalendarUtils:checkActivityIsOpen(activityId) == false then
            RichPrint("main","YEL"..environment.currRole.name.."：少侠，风筝大赛已结束了。")
            return
        end 

        if gameTimes >= 2 then 
            RichPrint("main","YEL"..environment.currRole.name.."：一日只能进行两次风筝大赛，少侠可明日再来。")
            return
        end
        local showStr = "刘鹤君：参与风筝大赛，可获得丰厚奖励，每日两次机会，少侠是否参与风筝大赛？"

        if gameTimes > 0 then 
            showStr = "刘鹤君：参与风筝大赛，可获得丰厚奖励，每日两次机会，今日已参与"..tostring(gameTimes).."次，少侠是否参与风筝大赛？"
        end

        local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
        local dialog = DialogALayer:getInstance()
        dialog:hide()
        dialog:show(showStr)
        dialog:setButton1("确定", function()
            dialog:hide()
            HttpManagerEx:addCurrencyNumber({["jiaozi"] =50 },"DailyTies_weekhztc","weekact", function(status, errcode, errmsg, data)
                if 200 == status and 0 == errcode then
                    local popStr1,popStr2 = ""
                    if MapIsEmpty(data.currency) == false then
                        for currency,valueData in pairs(data.currency) do
                            if valueData.value > 0 then 
                                --增加XX新货币，共拥有XX新货币。
                                popStr1 = "增加"..tostring(valueData.value)..role:getCHAttrName(currency).."，共拥有"..tostring(valueData.count)..role:getCHAttrName(currency)
                            end
                            if valueData.desc ~= nil and valueData.desc ~= ""  then
                                popStr2 = valueData.desc
                            end
                        end
                    end
                    HttpManagerEx:checkGoodsValid({"yuhuiling"}, function(status, errcode, errmsg, data)
                        if 200 == status and 0 == errcode then
                            local haveYuHuiLing = false
                            for k,v in pairs(data) do 
                                if "yuhuiling" == v.itemId and v.number > 0 then 
                                    haveYuHuiLing = true 
                                end
                            end
                            RichPrint("main","你决定参加风筝大赛，刘鹤君在你风筝上勾勒了几笔并祝愿道：愿君夺魁。")
                            PopupLayerController:showLayer("KiteLayer", function(layer)
                                layer:showLayer(haveYuHuiLing)
                                layer:PopYouZiLingText(popStr1,popStr2)
                            end)
                        else
                            PopText("网络请求出错,请换个网络环境再试!")
                        end
                    end, IS_SHOW_WAITING)
                else
                    PopText("网络请求出错,请换个网络环境再试!")
                end
            end, IS_SHOW_WAITING)
        end)
        dialog:setButton2("算了", function()
            RichPrint("main","你决定暂时不参加风筝大赛，刘鹤君没有多加勉强，只让你想清楚时再来找他。")
        end)
        dialog:setWeChatVisible(false)
    end,

    ["放风筝奖励"] = function(map, result, environment)
        local theFlyType=User:getRole():getDayFlag("风筝类型") or 0
        local theFlyScore=User:getRole():getDayFlag("放风筝积分") or 0
        local function getRewardList(score,flyType)
            if score >= 0 and score <=21 then
                local reward = {
                    [1] = {
                        {
                            itemId = "jingmai103",
                            number = 3,
                            type = "物品"
                        }
                    },
                    [2] = {
                        {
                            itemId = "cuilianjinnang3",
                            number = 1,
                            type = "物品"
                        }
                    },
                    [3] = {
                        {
                            itemId = "money",
                            number = 5000,
                            type = "属性",
                            name = "碎银"
                        }
                    },
                    [4] = {
                        {
                            itemId = "jiu107",
                            number = 1,
                            type = "物品"
                        }
                    },
                }
                return reward[flyType]
            elseif score > 21 and score <= 74 then
                local reward = {
                    [1] = {
                        {
                            itemId = "jingmai103",
                            number = 3,
                            type = "物品"
                        },
                        {
                            itemId = "jingmai101",
                            number = 1,
                            type = "物品"
                        }
                    },
                    [2] = {
                        {
                            itemId = "cuilianjinnang3",
                            number = 2,
                            type = "物品"
                        }
                    },
                    [3] = {
                        {
                            itemId = "money",
                            number = 10000,
                            type = "属性",
                            name = "碎银"
                        },
                         {
                            itemId = "gold",
                            number = 100,
                            type = "属性",
                            name = "黄金"
                        }
                    },
                    [4] = {
                        {
                            itemId = "jiu107",
                            number = 1,
                            type = "物品"
                        },
                        {
                            itemId = "jiu108",
                            number = 1,
                            type = "物品"
                        }
                    },
                }
                return reward[flyType]
            elseif score > 74 and score <= 116 then
                local reward = {
                    [1] = {
                        {
                            itemId = "jingmai103",
                            number = 3,
                            type = "物品"
                        },
                        {
                            itemId = "jingmai101",
                            number = 1,
                            type = "物品"
                        },
                        {
                            itemId = "zuoyouhubo2",
                            number = 1,
                            type = "物品"
                        }
                    },
                    [2] = {
                        {
                           itemId = "cuilianjinnang3",
                            number = 3,
                            type = "物品"
                        }
                    },
                    [3] = {
                        {
                            itemId = "money",
                            number = 20000,
                            type = "属性",
                            name = "碎银"
                        },
                        {
                            itemId = "gold",
                            number = 200,
                            type = "属性",
                            name = "黄金"
                        }
                    },
                    [4] = {
                        {
                            itemId = "jiu108",
                            number = 1,
                            type = "物品"
                        },
                        {
                            itemId = "jiu107",
                            number = 1,
                            type = "物品"
                        },
                        {
                            itemId = "yuandan4",
                            number = 1,
                            type = "物品"
                        }
                    },
                }
                return reward[flyType]
            elseif score > 116 and score <= 240 then
                local reward = {
                    [1] = {
                        {
                            itemId = "jingmai103",
                            number = 5,
                            type = "物品"
                        },
                        {
                            itemId = "jingmai101",
                            number = 2,
                            type = "物品"
                        },
                        {
                            itemId = "zuoyouhubo2",
                            number = 1,
                            type = "物品"
                        },
                        {
                            itemId = "jingmai100",
                            number = 1,
                            type = "物品"
                        }
                    },
                    [2] = {
                        {
                            itemId = "cuilianjinnang3",
                            number = 5,
                            type = "物品"
                        }
                    },
                    [3] = {
                        {
                            itemId = "money",
                            number = 50000,
                            type = "属性",
                            name = "碎银"
                        },
                        {
                            itemId = "gold",
                            number = 300,
                            type = "属性",
                            name = "黄金"
                        }
                    },
                    [4] = {
                        {
                            itemId = "jiu106",
                            number = 1,
                            type = "物品"
                        },
                        {
                            itemId = "jiu107",
                            number = 1,
                            type = "物品"
                        },
                        {
                            itemId = "daxiataocan",
                            number = 1,
                            type = "物品"
                        }
                    },
                }
                return reward[flyType]
            end
        end
        local function getDayReward(score) 
            local reward = getRewardList(score,theFlyType)
            if MapIsEmpty(reward) == true then
                if DEBUG_MODE == 1 then
                    print("function KiteLayer:getDayReward(score),",score,theFlyType)
                end
            else
                local role = User:getRole()
                for k,v in pairs(reward) do 
                    if v.type == "物品" then
                        local itemAttr = role:getOneItemByKey(v.itemId)
                        if itemAttr then
                            if role:checkCanBuyThings(v.itemId,v.number) == true then
                                role:addItemCount(v.itemId,v.number)
                                PopText("获得物品"..itemAttr.name.."X"..tostring(v.number))
                            end
                        end
                    else
                        role:addAttr(v.itemId,v.number)
                        PopText(v.name.."+"..tostring(v.number))
                    end
                end
            end 
        end
        local role = User:getRole()
        if role:getDayFlag("放风筝奖励领取")==false then 
            if role:getAttr("weight") - #role:getItems() < 4 then
                PopText("背包空间不足，无法领取奖励")
                return
            end
            getDayReward(math.floor(theFlyScore))
            role:setDayFlag("放风筝奖励领取",true)
            local putText={
                "YEL刘鹤君：少侠放风筝的技术有待加强，若能寻出窍门，想必会更好。",
                "YEL刘鹤君：少侠放风筝的技术尚算可以，之后若多加练习，定会更好，这是本次的奖励。",
                "YEL刘鹤君：少侠放风筝的技术着实不错，但若能将手中的线收放自如，可待夺魁，这是本次的奖励。",
                "YEL刘鹤君：少侠放风筝的技术真让在下佩服，能乘风而上者多，如少侠般借力青云者少之又少，这是本次的奖励。",
            }
            local textIndex=1
            if theFlyScore>=0 and theFlyScore<=40 then 
                textIndex=1
            elseif theFlyScore>40 and theFlyScore<=90 then 
                textIndex=2
            elseif theFlyScore>90 and theFlyScore<=160 then 
                textIndex=3
            elseif theFlyScore>160 and theFlyScore<=240 then 
                textIndex=4
            end
            RichPrint("main",putText[textIndex])
            role:setDayFlag("风筝付费",0)
        else
            RichPrint("main","YEL"..environment.currRole.name.."：少侠需先进行风筝大赛，才可领取奖励。")
        end
    end,
    ["放风筝试玩"] = function(map, result, environment)
        PopupLayerController:showLayer(
            "KiteLayer",
            function(layer)
                layer:showTestLayer() --试玩
            end
        )
    end,
    ["风鸢礼券兑换"] = function(map, result, environment)
        PopupLayerController:showLayer("FlyKiteRewardLayer", function(layer)
            layer:showLayer()
        end)
    end,
    ["元宵答题奖励"] = function(map, result, environment)
        local rewardType = math.random(1, 3)
        local val = 0

        -- 随机一项奖励
        if rewardType == 1 then
            val = math.random(500, 1000)
            User:addRoleAttr("exp", val)
            PopText("获得" .. "经验" .. val)
        elseif rewardType == 2 then
            val = math.random(2000, 4000)
            User:addRoleAttr("pot", val)
            PopText("获得" .. "潜能" .. val)
        elseif rewardType == 3 then
            val = math.random(5000, 10000)
            User:addRoleAttr("money", val)
            PopText("获得" .. "碎银" .. val)
        end
    end,
    ["祈福纸带"] = function(map, result, environment)
        PopupLayerController:showLayer(
            "ChineseValentineLayer",
            function(layer)
                layer:show(true)
            end
        )
    end,
    ["祈福树"] = function(map, result, environment)
        local Layer = require("app.views.layer.ChineseValentineLayer.PrayTreeLayer")
        local layer = Layer:getInstance()
        local role = User:getRole()
        layer:setRoles(role)
    end,
    ["祈福查看"] = function(map, result, environment)
        PopupLayerController:showLayer(
            "ChineseValentineCheckListLayer",
            function(layer)
                layer:show()
            end
        )
    end,
    ["七夕有缘人"] = function(map, result, environment)
        local chNum = {"一", "二", "三", "四", "五", "六", "七"}
        --判断背包是否能储存
        HttpManagerEx:getSeventhReward1(
            function(status, errcode, errmsg, data)
                if status == 200 and errcode == 0 then
                    local result = true
                    if PRINT_MODE == 1 then
                        print("this is prize data: ")
                        Helper:print_lua_table(data)
                    end

                    if data.daoju then
                        result = User:getRole():checkCanBuyTwoOrMoreThings(data.daoju)
                    end
                    if result == false then
                        return
                    end
                    HttpManagerEx:getSeventhReward2(
                        function(status, errcode, errmsg, data)
                            if status == 200 and errcode == 0 then
                                local role = User:getRole()

                                if data.first == true then
                                    RichPrint("main", "YEL元苦大师：阿弥陀佛，施主之诚感动上天，这些乃是施主所求，乃是佛主托我交于施主，还望施主万莫推辞")
                                    if data.daoju then
                                        for id, count in pairs(data.daoju) do
                                            local item = role:getOneItemByKey(id)
                                            if item == nil then
                                                if DEBUG_MODE == 1 then
                                                    PopText("没有该物品的资源" .. tostring(id))
                                                end
                                            else
                                                role:addItemCount(id, tonumber(count))
                                                PopText(
                                                    "你获得了 " ..
                                                        tostring(item.name) .. " X " .. tostring(count) .. item.unit
                                                )
                                            end
                                        end
                                    end

                                    if data.shuxing then
                                        for attrName, attrVal in pairs(data.shuxing) do
                                            local v = role:getAttr(attrName)
                                            role:setAttr(attrName, attrVal + v)
                                            PopText(role:getCHAttrName(attrName) .. " +" .. attrVal)
                                            RichPrint("main", role:getCHAttrName(attrName) .. " +" .. attrVal)
                                        end
                                    end

                                    if data.currency then
                                        for name, val in pairs(data.currency) do
                                            switch(
                                                name,
                                                {
                                                    gongxiandian = function()
                                                        RichPrint("main", "师门贡献点 +" .. val)
                                                        -- PopText("师门贡献点 +" .. val)
                                                    end,
                                                    meiyu = function()
                                                        RichPrint("main", "江湖美誉 +" .. val)
                                                        -- PopText("江湖美誉 +" .. val)
                                                    end
                                                }
                                            )
                                        end
                                    end
                                else
                                    RichPrint("main", "YEL元苦大师：施主已还愿过了，无需再还愿了。")
                                end

                            -- --每次点击还愿都从服务器更新房间和应缘标记信息
                            -- local openMark = Helper:getDef(data.open_mark,"")
                            -- local prayRoomId = Helper:getDef(data.room_id,"")
                            -- role:setAttr("openMark", openMark)
                            -- role:setAttr("prayRoomId",prayRoomId)
                            -- --解决交互数据刷新不及时的情况
                            -- FubenClient:setValue("prayRoomId",prayRoomId)

                            -- local roommate = ""

                            -- local my_roomate = Helper:getDef(data.my_roommate,{})
                            -- --判断此小组只有一人的情况
                            -- if #my_roomate ~= 0 then
                            -- 	for _,name in ipairs(my_roomate) do
                            -- 		if _ == #my_roomate then
                            -- 			roommate = roommate .. name
                            -- 		else
                            -- 			roommate = roommate .. name.."，"
                            -- 		end
                            -- 	end
                            -- 	local num= chNum[#my_roomate]
                            -- 	local str = "YEL玄心大师：昨日佛主托梦于我，"..roommate.."与施主有缘，若能找到此"..num.."人，当能一解施主之惑。"
                            -- 	RichPrint("main", str)
                            -- elseif #my_roomate == 0 then
                            -- 	local str = "YEL玄心大师：少侠来的不巧啊，此时无人与少侠有缘，莫要着急，少侠过两天再来试试，说不定便有人来应缘了也不一定呐。"
                            -- 	RichPrint("main",str)
                            -- end
                            end
                        end
                    )
                else
                    if errmsg == "你还没有祈福七次，没有奖励可以领取" then
                        RichPrint("main", "YEL元苦大师：阿弥陀佛，祈福心诚则灵，施主这诚意还不够啊。")
                    else
                        PopText(errmsg)
                    end
                end
            end
        )
    end,
    -- 七夕情缘任务
    ["多次数任务"] = function(map, result, environment)
        local succResultNum = result.arg2 -- 多日任务的上限X
        local list = string.split(result.arg3, ";") -- 完成任务条件结果集
        local outResultList = result.arg4 -- 超出次数条件结果集
        local role = User:getRole()
        local tryNum = role:getInheritFlag("七夕情缘任务次数")
        local textList = {}

        for i, v in ipairs(list) do
            textList[i] = string.gsub(v, ",", ";")
        end
        local isDoTask = role:getDayFlag("七夕情缘任务")

        if tryNum <= 7 then
            if 0 < isDoTask then
                RichPrint("main", "超过今日任务次数")
            else
                if tryNum > succResultNum then
                    RichPrint("main", "超过今日任务次数")
                else
                    tryNum = tryNum + 1
                    role:setInheritFlag("七夕情缘任务次数", tryNum)
                    local str = textList[tryNum]
                    role:setDayFlag("七夕情缘任务", 1)
                    map:doNoRoleResults(str, environment)
                end
            end
        else
            print("tryNum大于7")
            RichPrint("main", "已经完成过该任务")
        end
    end,
    --七夕情缘情侣促和
    ["情侣促和数量变化"] = function(map, result, environment)
        local role = User:getRole()
        local tryNum = role:getInheritFlag("七夕情缘任务情侣促和次数")
        print("情侣促和")
        HttpManagerEx:resetActiveTask(
            "make_cp",
            function(status, errcode, errmsg, data)
                if status == 200 then
                    if errcode == 0 then
                        tryNum = tryNum + 1
                        role:setInheritFlag("七夕情缘任务情侣促和次数", tryNum)
                        -- RichPrint("main","情侣促和"..tryNum)
                        getQiXiQingYuanReward()
                    else
                        PopText(errmsg)
                    end
                else
                    PopText(errmsg)
                end
            end,
            IS_SHOW_WAITING
        )
    end,
    --七夕情缘情侣拆散
    ["情侣拆散数量变化"] = function(map, result, environment)
        local role = User:getRole()
        local tryNum = role:getInheritFlag("七夕情缘任务情侣拆散次数")
        print("情侣拆散")
        HttpManagerEx:resetActiveTask(
            "break_cp",
            function(status, errcode, errmsg, data)
                if status == 200 then
                    if errcode == 0 then
                        tryNum = tryNum + 1
                        role:setInheritFlag("七夕情缘任务情侣拆散次数", tryNum)
                        -- RichPrint("main","情侣拆散"..tryNum)
                        getQiXiQingYuanReward()
                    else
                        PopText(errmsg)
                    end
                else
                    PopText(errmsg)
                end
            end,
            IS_SHOW_WAITING
        )
    end,
    ["梦回七夕积分变化"] = function(map, result, environment)
        local role = User:getRole()
        local change = result.arg2
        local jifen = role:getFlag("梦回七夕积分")
        local jifen = change + jifen
        -- RichPrint("main","梦回七夕积分:"..jifen.."变化值:"..change)
        role:setFlag("梦回七夕积分", jifen)
    end,
    ["梦回七夕积分设置"] = function(map, result, environment)
        local change = result.arg2
        local role = User:getRole()
        role:setFlag("梦回七夕积分", change)
        -- RichPrint("main","梦回七夕积分设置为:"..change)
    end,
    ["梦回七夕奖励"] = function(map, result, environment)
        -- 0	参与奖励：1000潜能，1阅历
        -- 2~6	5000潜能，5阅历
        -- 7~12	10000潜能，10阅历
        -- 13~24	12000潜能，20阅历
        -- 25~35	15000潜能，30阅历
        -- 36~41	20000潜能，50阅历
        -- 42以上	精力上限+10，20000潜能，50阅历
        local resultList = result.arg2
        -- 新增参数,作用未知
        local resultList1 = result.arg3
        local resultList2 = result.arg4
        local resultList3 = result.arg5
        local resultList4 = result.arg6
        local role = User:getRole()
        local jifen = role:getFlag("梦回七夕积分")
        local num = role:getDayFlag("梦回七夕奖励次数")
        if num == 0 then
            if jifen == 0 then
                HttpManagerEx:resetActiveTask(
                    "dream_1",
                    function(status, errcode, errmsg, data)
                        if status == 200 then
                            if errcode == 0 then
                                role:addAttr("pot", 1000)
                                role:addAttr("yueli", 1)
                                PopText("阅历+ " .. 1)
                                PopText("潜能+ " .. 1000)
                                role:setDayFlag("梦回七夕奖励次数", 1)
                                map:doNoRoleResults(resultList1, environment)
                            else
                                PopText(errmsg)
                            end
                        else
                            PopText(errmsg)
                        end
                    end,
                    IS_SHOW_WAITING
                )
            elseif jifen > 1 and jifen < 7 then
                HttpManagerEx:resetActiveTask(
                    "dream_2",
                    function(status, errcode, errmsg, data)
                        if status == 200 then
                            if errcode == 0 then
                                role:addAttr("pot", 5000)
                                role:addAttr("yueli", 5)
                                PopText("阅历+ " .. 5)
                                PopText("潜能+ " .. 5000)
                                role:setDayFlag("梦回七夕奖励次数", 1)
                                map:doNoRoleResults(resultList1, environment)
                            else
                                PopText(errmsg)
                            end
                        else
                            PopText(errmsg)
                        end
                    end,
                    IS_SHOW_WAITING
                )
            elseif jifen >= 7 and jifen < 13 then
                HttpManagerEx:resetActiveTask(
                    "dream_3",
                    function(status, errcode, errmsg, data)
                        if status == 200 then
                            if errcode == 0 then
                                role:addAttr("pot", 10000)
                                role:addAttr("yueli", 10)
                                PopText("阅历+ " .. 10)
                                PopText("潜能+ " .. 10000)
                                role:setDayFlag("梦回七夕奖励次数", 1)
                                map:doNoRoleResults(resultList2, environment)
                            else
                                PopText(errmsg)
                            end
                        else
                            PopText(errmsg)
                        end
                    end,
                    IS_SHOW_WAITING
                )
            elseif jifen >= 13 and jifen < 25 then
                HttpManagerEx:resetActiveTask(
                    "dream_4",
                    function(status, errcode, errmsg, data)
                        if status == 200 then
                            if errcode == 0 then
                                role:addAttr("pot", 12000)
                                role:addAttr("yueli", 20)
                                PopText("阅历+ " .. 20)
                                PopText("潜能+ " .. 12000)
                                role:setDayFlag("梦回七夕奖励次数", 1)
                                map:doNoRoleResults(resultList2, environment)
                            else
                                PopText(errmsg)
                            end
                        else
                            PopText(errmsg)
                        end
                    end,
                    IS_SHOW_WAITING
                )
            elseif jifen >= 25 and jifen < 36 then
                HttpManagerEx:resetActiveTask(
                    "dream_5",
                    function(status, errcode, errmsg, data)
                        if status == 200 then
                            if errcode == 0 then
                                role:addAttr("pot", 15000)
                                role:addAttr("yueli", 30)
                                PopText("阅历+ " .. 30)
                                PopText("潜能+ " .. 15000)
                                role:setDayFlag("梦回七夕奖励次数", 1)
                                map:doNoRoleResults(resultList3, environment)
                            else
                                PopText(errmsg)
                            end
                        else
                            PopText(errmsg)
                        end
                    end,
                    IS_SHOW_WAITING
                )
            elseif jifen >= 36 and jifen < 42 then
                HttpManagerEx:resetActiveTask(
                    "dream_6",
                    function(status, errcode, errmsg, data)
                        if status == 200 then
                            if errcode == 0 then
                                role:addAttr("pot", 20000)
                                role:addAttr("yueli", 50)
                                PopText("阅历+ " .. 50)
                                PopText("潜能+ " .. 20000)
                                role:setDayFlag("梦回七夕奖励次数", 1)
                                map:doNoRoleResults(resultList3, environment)
                            else
                                PopText(errmsg)
                            end
                        else
                            PopText(errmsg)
                        end
                    end,
                    IS_SHOW_WAITING
                )
            elseif jifen >= 42 then
                HttpManagerEx:resetActiveTask(
                    "dream_7",
                    function(status, errcode, errmsg, data)
                        if status == 200 then
                            if errcode == 0 then
                                role:addAttr("pot", 20000)
                                role:addAttr("yueli", 50)
                                role:setInheritFlag("QiXi_JingMax", role:getInheritFlag("QiXi_JingMax") + 10)
                                if role:getInheritFlag("QiXi_mianju") == 0 then
                                    role:setInheritFlag("QiXi_mianju", 1)
                                end
                                PopText("精力上限+ " .. 10)
                                PopText("阅历+ " .. 50)
                                PopText("潜能+ " .. 20000)
                                role:setDayFlag("梦回七夕奖励次数", 1)
                                map:doNoRoleResults(resultList4, environment)
                            else
                                PopText(errmsg)
                            end
                        else
                            PopText(errmsg)
                        end
                    end,
                    IS_SHOW_WAITING
                )
            end
            map:doNoRoleResults(resultList, environment)
        else
            RichPrint("main", "梦回七夕奖励当天领取次数已用完")
        end
    end,
    ["梦回七夕额外奖励"] = function(map, result, environment)
        local sucList = result.arg2
        local badList = result.arg3
        local gainedList = result.arg4
        local role = User:getRole()
        local isGain = role:getInheritFlag("QiXi_mianju")
        if 0 == isGain then
            map:doNoRoleResults(badList, environment)
        elseif 1 == isGain then
            role:addItemCount("mianju1034", 1)
            local item = Item:getOneItemByKey("mianju1034")
            PopText("获得神秘面具：" .. item.name)
            map:doNoRoleResults(sucList, environment)
            role:setInheritFlag("QiXi_mianju", 2)
        elseif 2 == isGain then
            map:doNoRoleResults(gainedList, environment)
        end
    end,
    ["礼券增加"] = function(map, result, environment)
        local giftNum = Helper:getDef(result.arg2, 0)
        --获取礼券增加的数量后通知服务器
        HttpManagerEx:addActivityPoint(
            giftNum,
            "zhounianqin_jf",
            function(status, errcode, errmsg, data)
                if status == 200 and errcode == 0 then
                    if DEBUG_MODE == 1 then
                        print("礼券成功增加:" .. data.number)
                    end
                    PopText("获得礼券:" .. data.number .. "。" .. "(您的当前礼券为:" .. data.total_points .. ")")
                else
                    PopText(errmsg)
                end
            end
        )
    end,
    ["礼券交易界面"] = function(map, result, environment)
        local player = User:getRole()
        local npcID = result.arg2
        local itemStr = Helper:getDef(result.arg3, "")

        local npc = map:getRole(npcID)
        if itemStr == "" then
            if DEBUG_MODE == 1 then
                PopText("礼券交易界面的result.arg3为nil")
            end
            return
        end
        local itemsList = string.split(itemStr, ";")
        PopupLayerController:showLayer(
            "LiQuanLayer",
            function(layer)
                layer:show()
                layer:setRoles(player, npc, itemsList)
            end
        )
        -- local liquan = require("app.views.layer.LiQuanLayer.LiQuanLayer")
        -- liquan:setRoles(player,npc,itemsList)
    end,
    ["腊八施粥"] = function(map, result, environment)
        print("------------------------------------------------------------------------")
        local log, maxCount = result.arg2, result.arg3
        -- if DEBUG_MODE == 1 then
        -- 	log,maxCount = "您正在施粥，不可随意走动。","3;4;5"
        -- end
        local LaBaShiZhou = require("app.models.Action.LaBa.LaBaShiZhou")
        LaBaShiZhou:start(log, maxCount)
        LaBaShiZhou:setSuccessFunc(
            function()
                map:doNoRoleResults(result.arg4, environment)
            end
        )
    end,
    ["腊八施粥操作"] = function(map, result, environment)
        local LaBaShiZhou = require("app.models.Action.LaBa.LaBaShiZhou")
        LaBaShiZhou:dealOperation(result.arg2, result.arg3, currRole.id)
    end,
    ["小吃排队"] = function(map, result, environment)
        if User:getRole():getFlag("PVP活动状态") == "忙碌" then
            return
        end
        local successResult, failedResult = result.arg2, result.arg3
        PopupLayerController:showLayer(
            "StreetSnackLayer",
            function(layer)
                layer:setResultCallFunc(
                    function()
                        -- PopText("进入制作流程")
                        User:getRole():setFlag("PVP活动状态", "空闲中")
                        map:doNoRoleResults(successResult, environment)
                    end,
                    function()
                        -- PopText("离开队伍")
                        User:getRole():setFlag("PVP活动状态", "空闲中")
                        map:doNoRoleResults(failedResult, environment)
                    end
                )
                -- layer:start()
                layer:showLayer()
            end
        )
    end,
    ["生肖糖人"] = function(map, result, environment)
        local ChineseZodiacCandyPeopel = require("app.models.SpringFestival.TheDogYear.ChineseZodiacCandyPeopel")
        ChineseZodiacCandyPeopel:start(
            function()
                map:doNoRoleResults(result.arg2, environment)
            end
        )
    end,

    ["副本房间玩家人数"] = function(map, result, environment)
        assert(tonumber(result.arg2) and result.arg3 and result.arg4)
        local nodeNum = tonumber(result.arg2)
        local time_node_list = string.split(result.arg3, ";") --时间段0,4;4,6
        local num_node_list = string.split(result.arg4, ";")
        --时间段对应的取随机数的范围0,4;4,6
        assert(#time_node_list == #num_node_list, result.arg3 .. "," .. result.arg4)
        if DEBUG_MODE == 1 then
            print("***********************************************")
            print("***********************************************")
            Helper:print_lua_table(time_node_list)
            print("***********************************************")

            Helper:print_lua_table(num_node_list)
            print("***********************************************")
            print("***********************************************")
            print("***********************************************")
        end

        local mapLayer = MainControllLayer:getLayer("MapLayer")
        local roomRoleNum = #mapLayer._currRoom.playList
        local reNum = 0
        if roomRoleNum > nodeNum then
            reNum = roomRoleNum
            if DEBUG_MODE == 1 then
                print("----------------副本房间玩家人数        当前房间人数--------------------", reNum)
            end
        else
            local currHour = tonumber(Helper:date("%H", GetTime()))
            for k, timeNode in pairs(time_node_list) do
                local timeList = string.split(timeNode, ",")
                assert(#timeList == 2)
                if tonumber(timeList[1]) < currHour and tonumber(timeList[2]) >= currHour then
                    local numList = string.split(num_node_list[k], ",")
                    assert(#numList == 2)
                    reNum = math.random(tonumber(numList[1], tonumber(numList[2])))
                    if DEBUG_MODE == 1 then
                        print("-------------副本房间玩家人数     随机人数---------------", reNum)
                    end
                    break
                end
            end
        end
        if DEBUG_MODE == 1 then
            print("===========副本房间玩家人数========最终返回人数===", reNum)
        end
        return reNum
    end,
    ["戏台文本"] = function(map, result, environment)
        local textList = {}

        --文本中需要用到人数的需用特殊符号替换:当前等待人数：$N(now number),还需等待人数:$W(need wait number),总人数$T(total number)
        -- textList[1] = result.arg2 --开始排队文本
        -- textList[2] = result.arg3 --等待过程中排队信息的文本
        -- textList[3] = result.arg4 --发生随机事件人数+1文本
        -- textList[4] = result.arg5 --发生随机事件人数-1文本
        -- textList[5] = result.arg6 --等待时间结束文本
        -- textList[6] = result.arg7 --达到最大人数文本
        -- textList[7] = result.arg8 --离队文本
        for i = 2, 100 do
            if result["arg" .. tostring(i)] then
                textList[i - 1] = result["arg" .. tostring(i)]
            else
                break
            end
        end
        local str = ""
        for k, text in ipairs(textList) do
            str = str .. text
            if k ~= #textList then
                str = str .. ";"
            end
        end
        return str
    end,
    ["戏台排队"] = function(map, result, environment)
        if User:getRole():getFlag("PVP活动状态") == "忙碌" then
            return
        end
        local nowNumber, needNumber = result.arg2, tonumber(result.arg3)
        --当前人数，开始需求人数
        local max_wait_time = tonumber(result.arg4) --最长等待时间
        print("--------------result.arg5-------------------", result.arg5)
        local tmp = map:doNoRoleResults(result.arg5, environment)
        -- print("--------------------------",tmp)
        local text = nil
        for k, v in pairs(tmp) do
            text = string.split(k, ";")
            print(k)
        end
        tmp = map:doNoRoleResults(result.arg2, environment)
        for k, v in pairs(tmp) do
            nowNumber = tonumber(k)
        end

        -- assert(#text == 7)
        --result.arg6,result.arg7--成功，失败条件结果集合

        PopupLayerController:showLayer(
            "XiTaiQueueUpLayer",
            function(layer)
                layer:setStartPlayFunc(
                    function()
                        map:doNoRoleResults(result.arg6, environment)
                    end
                )

                layer:setLeaveXiTaiFunc(
                    function()
                        map:doNoRoleResults(result.arg7, environment)
                    end
                )

                layer:setText(text)
                layer:setStartPeople(nowNumber)
                layer:setNeedCount(needNumber)
                layer:setMaxWaitTime(max_wait_time)
                layer:showLayer()
            end
        )
    end,
    ["门派团圆饭"] = function(map, result, environment)
        -- local textList = string.split(result.arg2,";") --文本
        -- local posXList = string.split(result.arg3,";") --X坐标
        -- local posYList = string.split(result.arg4,";") --Y坐标
        -- local timeList = string.split(result.arg5,";") --时间间隔
        local delayTime = tonumber(result.arg7)
        local textList = {
            "CRO灯影幢幢 觥筹交错",
            "CRO满桌酒菜虽算不上绝味",
            "CRO但每道菜都是用心而作",
            "CRO你眼中充斥着同门的笑颜",
            "CRO耳畔回响着隐隐的爆竹声",
            "CRO顿时有一种恍如隔世的感觉",
            "CRO一载走南闯北 一载饱经风霜",
            "CRO彼时的尔虞我诈 彼时的刀光剑影",
            "CRO此时都化作暖意 充盈于心",
            "CRO恍惚之间 碗中已添满菜肴",
            "CRO埋首吃饭时 眼中已溢满晶莹",
            "CRO千言万语 尽在不言",
            "CRO愿这一刻能一直延续",
            "CRO愿眼前人能一世平安",
            "CRO愿岁月静好 愿千里团圆"
        }
        local posXList = {150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150}
        local posYList = {1700, 1620, 1540, 1380, 1300, 1220, 1060, 980, 900, 740, 660, 580, 500, 420, 340}
        local timeList = {3.5, 2.5, 2.5, 4.5, 2.5, 2.5, 4.5, 2.5, 2.5, 4.5, 2.5, 2.5, 2.5, 2.5, 2.5}

        -- result.arg6 成功条件结果集
        if DEBUG_MODE ~= 1 then
            assert(#textList == #posXList and #textList == #posYList and #textList == #timeList, "参数格式不统一")
        end
        local text = {}
        if true then
            for k, time in ipairs(timeList) do
                local tab = {
                    text = assert(textList[k]),
                    posY = assert(posYList[k]),
                    posX = assert(posXList[k]),
                    time = time
                }
                table.insert(text, tab)
            end
        end
        local DialogJLayer = require("app.views.layer.DialogLayer.DialogJLayer")
        local dialog = DialogJLayer:getInstance()
        dialog:setMusic("tuanyuanfan", delayTime)
        dialog:setEffect("chunjiebianpao", delayTime)
        dialog:showLayer(
            text,
            function()
                map:doNoRoleResults(result.arg6, environment)
            end
        )
    end,
    ["元宵灯谜玩法"] = function(map, result, environment)
        local player = User:getRole()
        local currRole = environment.currRole
        local dengmiList = player:getTimeLimitFlag(currRole.userid)
        print("----------------getTimeLimitFlag------------------------", dengmiList, currRole.userid)
        local maxCount = player:getDayFlag("灯谜每日答题次数")
        if Helper:getDef(maxCount, 0) >= 6 then
            RichPrint("main", "你今天已经答得够多了，还是留一些灯谜给别人吧。")
            return
        end
        if currRole.answerValue == 1 then
            RichPrint("main", "你已经猜对该灯谜了，还是去别的地方看看吧。")
            return
        elseif currRole.answerValue == 0 then
            RichPrint("main", "你刚刚答错了这个灯谜，还是去别的地方看看吧。")
            return
        end
        if Helper:getDef(currRole.remainTimes, 0) <= 0 then
            local time =
                Helper:getRange(
                math.ceil(Helper:getDef(currRole.dismissTime, GetTime()) - GetTime() - currRole.subTime),
                1
            )
            RichPrint("main", "这个灯谜已经被人抢先答完了，下一批灯谜灯笼在" .. time .. "秒后刷新。")
            return
        else
            print(
                "------------------Helper:getDef(currRole.remainTimes,0)Helper:getDef(currRole.remainTimes,0)-------------------",
                Helper:getDef(currRole.remainTimes, 0)
            )
        end
        -- 答对的调用
        local resultsStrs1 = result.arg2
        -- 答错的调用
        local resultsStrs2 = result.arg3
        User:getRole():setFlag("PVP活动状态", "忙碌")
        PopupLayerController:showLayer(
            "QALayer",
            function(layer)
                layer:showLayer(
                    function()
                        if resultsStrs1 ~= nil then
                            map:doNoRoleResults(resultsStrs1, environment)
                        end
                        -- RichPrint("main","你答对了这个灯谜，一旁的青衣书生笑嘻嘻地将一个礼品交到你手里。")
                        FubenClient:minusDenglong(tostring(User:getUserId()), currRole.userid, 1)
                        currRole.remainTimes = currRole.remainTimes - 1
                        player:setDayFlag("灯谜每日答题次数", maxCount + 1)
                        User:getRole():setFlag("PVP活动状态", "空闲中")
                    end,
                    function()
                        if resultsStrs2 ~= nil then
                            map:doNoRoleResults(resultsStrs2, environment)
                        end
                        -- RichPrint("main","你答错了这个灯谜，一旁的青衣书生拍了拍你的肩膀，勉励了你一番。")
                        FubenClient:minusDenglong(tostring(User:getUserId()), currRole.userid, 0)
                        User:getRole():setFlag("PVP活动状态", "空闲中")
                    end
                )
            end
        )
    end,
    ["解救人质成功"] = function (map, result, environment)
        --@desc 成功执行的条件结果集
        local successStr = result.arg2

        --@desc 失败执行的条件结果集
        local failStr = result.arg3
        
        local role = User:getRole()
        
        local items = {
            "shuangshiyiwp1",
            "shuangshiyiwp2",
            "shuangshiyiwp3"
        }
        --math.random( 1,2) 
        local random = 2 
        local awardList = {}
        for i = 1,random do
            local itemId = items[math.random( 1,#items)]
            if awardList[itemId] then
                awardList[itemId] = awardList[itemId] + 1
            else
                awardList[itemId] = 1
            end
        end

        HttpManagerEx:getDiscountCoupon(awardList,
            function(status, errcode, errmsg, data)
                if status == 200 then
                    if errcode == 0 then
                        if data.success == 0 then
                            if not MapIsEmpty(awardList) then
                                for itemId,count in pairs(awardList) do
                                    if not role:checkCanBuyTwoOrMoreThings({[itemId] = count}) then
                                        map:dropItem(environment.currRoomId,itemId,count)
                                        map.__MapLayer:delayRefreshMap()
                                    else
                                        local itemAttr = Item:getOneItemByKey(itemId)
                                        role:addItemCount(itemId,count)
                                        PopText("获得"..itemAttr.name.."X"..count)
                                    end
                                    
                                end
                            end

                            if successStr then
                                map:doNoRoleResults(successStr,environment)
                            end
                        else
                            if failStr then
                                map:doNoRoleResults(failStr,environment)
                            end
                        end
                    end
                else
                    PopText(errmsg)
                end
            end,
            IS_SHOW_WAITING
        )
    end,
    ["礼券积分兑换"]= function(map, result, environment)
        local itemData=string.split(result.arg2, ";")
        local itemID=itemData[1]
        local itemPrice=tonumber(itemData[2])
        local itemInfo={
            itemId = itemID, 
            time = GetTime(), 
            count = 1, 
            price = itemPrice, 
            type = "buy", 
            userid = User:getUserId()
        }

        local func = function(transId)
            local tab = {
                itemId = itemID,
                client_trans_id = transId,
                shop_id = "zhounianqin_jf"
            }
            HttpManagerEx:shopExchangeGoods(tab, function(status, errcode, errmsg, data)
                if status == 200 then
                    if errcode == 0 then           
                        local item = User:getRole():getOneItemByKey(tab.itemId)
                        -- if item == nil then
                        --     item = {}
                        --     item.name = User:getRole():getCHAttrName(tab.itemId)
                        -- else
                        --     if item.type == "秘籍残页" or item.type == "书页" then
                        --         User:getRole():addItemCount(tab.itemId,1)
                        --     end
                        -- end
                        local desc = "你购买一"..tostring(item.unit)..tostring(item.name).."花费了"..tostring(itemPrice) .. "礼券"
                        PopText(desc)
                        --物品添加策划执行
                        map:doNoRoleResults(result.arg3,environment) 
                        -- PopText("获得物品"..item.name.."X"..tostring(points).."礼券")
                    
                        TransCheck:updateTrans(transId, RESPONSE_STATUS_SUCCESS)
                    elseif errcode == 2 then  --次数达上限
                        print("errmsg:",errmsg,"errcode:",errcode)
                        map:doNoRoleResults(result.arg5,environment) 
                        TransCheck:updateTrans(transId, RESPONSE_STATUS_FAILED)
                    elseif errcode == 3 then  --积分不够
                        print("errmsg:",errmsg,"errcode:",errcode)
                        map:doNoRoleResults(result.arg4,environment) 
                        TransCheck:updateTrans(transId, RESPONSE_STATUS_FAILED)
                    else
                        PopText(errmsg)
                        TransCheck:updateTrans(transId, RESPONSE_STATUS_FAILED)
                    end
                else
                    PopText(errmsg)
                end
            end, IS_SHOW_WAITING)
        end
        TransCheck:setTransWithWebOrderId(func, itemInfo, 1, 6)
    end,

    ["字牌道具兑换"]= function(map, result, environment)
        if User:getRole():getInheritFlag("2020新年字牌道具兑换次数")>=30 then 
            RichPrint("main","YEL"..environment.currRole.name.."：眼下小老儿手中笔墨已干，无法再给少侠写字了。")
            return 
        end
        if User:getRole():getAttr("weight") - #User:getRole():getItems()<1 then 
            PopText("背包空间不足，无法进行兑换")
            return 
        end
        local SFTokenCollection2019 = require("app.models.SpringFestival.2019.SFTokenCollection2019")
        SFTokenCollection2019:initConfig()
        local item_probability={
            [1]=30,
            [2]=50,
            [3]=70,
            [4]=90,
            [5]=100,
        }
        local rewardList={
            {"pot",8888,"潜能"},
            {"pot",15000,"潜能"},
            {"yueli",30,"阅历"},
            {"yueli",20,"阅历"},
        }
        local renwuItemId="sanjuecard1"
        local itemNum = 1
        local role=User:getRole()
        if role:getItem(renwuItemId)~=nil then 
            HttpManagerEx:checkItemIsCanUse(
            renwuItemId,
            itemNum,
            function(status, errcode, errmsg, data)
                if status == 200 then
                    if errcode == 0 then
                        RichPrint("main", "YEL"..environment.currRole.name.."：既有三绝帖，小老儿又岂会吝啬这点笔墨，少侠且看这字牌写的如何。")
                        if role:getInheritFlag("2020新年字牌特殊道具")==1 then 
                            for i=1,5 do 
                                item_probability[i]= item_probability[i]+i*2.5
                            end
                        end
                        role:setInheritFlag("2020新年字牌道具兑换次数",1+role:getInheritFlag("2020新年字牌道具兑换次数"))
                        local startIndex=1
                        local itemId=""
                        if role:getInheritFlag("2020新年字牌道具兑换次数")==20 and role:getInheritFlag("2020新年字牌特殊道具")~=1 then 
                            startIndex=91
                        end
                        local randomIndex=math.random(startIndex,100)
                        print("几率值：",randomIndex)
                        if randomIndex<=item_probability[1] then 
                            itemId="2020xcjzwp001"
                        elseif randomIndex<=item_probability[2] then
                            itemId="2020xcjzwp002"
                        elseif randomIndex<=item_probability[3] then
                            itemId="2020xcjzwp003"
                        elseif randomIndex<=item_probability[4] then
                            itemId="2020xcjzwp004"
                        elseif randomIndex<=item_probability[5] then
                            itemId="2020xcjzwp005"
                            role:setInheritFlag("2020新年字牌特殊道具",1)
                        end

                        role:addItemCount("sanjuecard1", -1)
                        local rewardIndex=math.random(1,4)
                        role:addAttr(rewardList[rewardIndex][1], rewardList[rewardIndex][2])
                        PopText("获得"..rewardList[rewardIndex][3]..rewardList[rewardIndex][2])
                        SFTokenCollection2019:initConfig()
                        SFTokenCollection2019:addToken(itemId,1)
                    else
                        RichPrint("main", "YEL"..environment.currRole.name.."：若无三绝帖，小老儿可不会这般轻易下笔，少侠还是寻得再来。")                           
                        print("errmsg", errmsg, "errcode", errcode)
                    end
                else
                    PopText(errmsg)
                end
            end,
            IS_SHOW_WAITING)
        else
            RichPrint("main", "YEL"..environment.currRole.name.."：若无三绝帖，小老儿可不会这般轻易下笔，少侠还是寻得再来。")
        end
         
    end,

    ["挂灯笼奖励"] = function ( map, result, environment)
        local successText={
            ["yxdl1"]="YEL你轻轻点足便将此灯挂于古树之上，一时微风乍起，树上红绸飞舞，双鲤鱼盏光芒点点，如在朱海波澜间翻涌，你暗暗许愿，愿：鱼跃金门，游龙在天，江湖相携。",
            ["yxdl2"]="YEL你将青纹墨侠灯挂于古树梢，只见灯心一点明随风摇曳，那灯上侠客就如起舞弄剑，生生使出一招你从未见过的武学。你微微合眼，愿：江湖快意，青山留名，不负恩仇。",
            ["yxdl3"]="YEL随着惊鸿练裳灯被你挂上古树，一时六面翻转，灯中六幅江湖美人图明暗浮现，如相互持器对峙要较量一二。你浅浅一笑，愿：百刃皆解，取胜不败，剑鸣江湖。",
            ["yxdl4"]="YEL琼宫白玉灯内的流香倾泻，如云如瀑似要将整个琼宫湮灭，古说嫦娥应悔偷灵药，又不知子非鱼安知鱼之乐之理。你恍惚一笑，愿：浮生自在，正邪两念，何要人说。",
            ["yxdl5"]="YEL你踏上云梯，轻轻一送便将八仙云莲灯挂于古树之上。琉璃五彩，八宝如临，反将其他花灯都比得黯然失色。迎着众人艳羡的目光，你缓缓闭眼，愿：岁如华灯，生如五彩，剑指河山。",
        }
        local failText={
            ["yxdl1"]="YEL缺少“双鲤鱼盏”，无法挂置。",
            ["yxdl2"]="YEL缺少“青纹墨侠灯”，无法挂置。",
            ["yxdl3"]="YEL缺少“惊鸿练裳灯”，无法挂置。",
            ["yxdl4"]="YEL缺少“琼宫白玉灯”，无法挂置。",
            ["yxdl5"]="YEL缺少“八仙云莲灯”，无法挂置。",
        }
        local denglongInfo={
            ["yxdl1"]={"2019yxdl001","yxdlaward1",50},
            ["yxdl2"]={"2019yxdl002","yxdlaward2",100},
            ["yxdl3"]={"2019yxdl003","yxdlaward3",150},
            ["yxdl4"]={"2019yxdl004","yxdlaward4",200},
            ["yxdl5"]={"2019yxdl005","yxdlaward5",300},
        }

        local role =User:getRole()
        local strId =result.id
        local  resultId=string.gsub(strId,"rlt_","")

        if role:getDayFlag("yxghd")>=3 then 
            RichPrint("main", "YEL花灯挂置太多，他人可能就没位置了，还是明日再来吧。")
            return 
        end

        if role:getFlag("元宵挂特殊灯笼")>=18 and resultId== "yxdl5" then
            RichPrint("main", "YEL元宵佳节内，挂置八仙云莲灯太多了，还是留些空位给其他侠士吧。")
            return 
        end

        local function getReward(itemid, rsid, yinpiaoNum)
            HttpManagerEx:updateCurrencyByType(
                "add",
                "yinpiao",
                yinpiaoNum,
                "actask01",
                function(status, errcode, errmsg, data)
                    if status == 200 then
                        if errcode == 0 then
                            role:addItemCount(itemid, -1)

                            RichPrint("main", successText[resultId])
                            RichPrint("main", "获得奖励 :银票" .. "+" .. tostring(yinpiaoNum))

                            if itemid == "2019yxdl005" then
                                role:setFlag("元宵挂特殊灯笼", role:getFlag("元宵挂特殊灯笼") + 1)
                            end

                            role:setDayFlag("yxghd", role:getDayFlag("yxghd") + 1)

                            --@RefType [src.app.models.Record.Reward.ARewardRecord#ARewardRecord]
                            local ARewardRecord = require("app.models.Record.Reward.ARewardRecord")

                            local openRewardGet =
                                require("app.models.reward.OpenRewardGet"):create(
                                role,
                                {rsid},
                                ARewardRecord.RTYPE.MAP_RESULT,
                                "rewardArrayWithRewardScheme",
                                {
                                    mapid = map.id,
                                    npcid = environment.currRole.id,
                                    rlt = "挂灯笼奖励"
                                }
                            )
                            openRewardGet:doGetReward(
                                function(rewardArray)
                                    for i, reward in ipairs(rewardArray) do
                                        if reward.type == "物品" then
                                            if map:addItemCount(reward.id, reward.value) == false then
                                                map:dropItem(map:getCurrRoomId(), reward.id)
                                                map.__MapLayer:delayRefreshMap()
                                            else
                                                User:getRole():addItemCount(reward.id, reward.value)
                                                PopText("获得 " .. Item:getOneItemByKey(reward.id).name .. " x " .. reward.value)
                                            end
                                        elseif reward.type == "属性" then
                                            if type(User:getRole():getCHAttrName(reward.id)) == "string" then
                                                PopText("获得" .. role:getCHAttrName(reward.id) .. tostring(reward.value))
                                            end
                                            User:getRole():addAttr(reward.id, reward.value)
                                            map:richPrintText(User:getRole(), reward.id, reward.value) -- 角色属性变化文本显示
                                        end
                                    end
                                end
                            )
                        else
                            print(errcode, errmsg)
                        end
                    end
                end,
                IS_SHOW_WAITING
            )
        end

        if role:getItemCount(denglongInfo[resultId][1])>=1 then 
            getReward(denglongInfo[resultId][1],denglongInfo[resultId][2],denglongInfo[resultId][3])
        else
            RichPrint("main",failText[resultId])
        end
    end,

    ["无间林提交奖励"] = function(map, result, environment)
        local itemInfo={   --品质从高到低
            "znq3wj1","znq3wj2","znq3wj3","znq3wj4"
        }
        local itemFlag={
            "znq3bj1","znq3bj2","znq3bj3","znq3bj4"
        }
        local rewardItemList={
            [1] = {
                {
                    itemId = "jiu106",
                    number = 1,
                    type = "物品"
                },
                {
                    itemId = "menpaicanye4",
                    number = 1,
                    type = "物品"
                }
            },
            [2] = {
                {
                    itemId = "jiu106",
                    number = 1,
                    type = "物品"
                }
            },
            [3] = {
                {
                    itemId = "qiannengdan",
                    number = 1,
                    type = "物品"
                }
            },
            [4] = {
                {
                    itemId = "cuilianjinnang3",
                    number = 1,
                    type = "物品"
                }
            },
        }
        local exchangeItem={
            ["menpaicanye4"]="sanren8"
        }
        local rewardPrestigeList={
            100,50,40,30
        }
        local rewardYueLiList={
            100,50,40,30
        } 
        local isHaveItem=false
        local currItemIndex
        local role = User:getRole()
        for i=4,1,-1 do 
            if role:getItemCount(itemInfo[i])>0 then 
                isHaveItem=true
                currItemIndex = i
                break
            end
        end
        if isHaveItem==false then 
            RichPrint("main", result.arg2)
            return
        end
        local function getRewardFunc()
            if role:getAttr("weight") - #role:getItems() < #rewardItemList[currItemIndex] then
                PopText("背包空间不足，无法领取奖励")
                RichPrint("main", result.arg4)
                return
            end
            local currItemAttr = role:getOneItemByKey(itemInfo[currItemIndex])
            RichPrint("main", "你将找寻到的情报物品“"..currItemAttr.name.."”递交，捕风卫满意的点了点头，欣然的将奖励发放与你。")
            
            if role:hasFamily() then 
                local FamilyPrestige=require("app.models.family.FamilyPrestige") 
                local addFlag="activity_znq3wj_"..itemInfo[currItemIndex]

                for k,v in pairs(rewardItemList[currItemIndex]) do 
                    if v.type == "物品" then
                        local itemAttr = role:getOneItemByKey(v.itemId)
                        if itemAttr then
                            role:addItemCount(v.itemId,v.number)
                            PopText("获得物品"..itemAttr.name.."X"..tostring(v.number))
                        end
                    else
                        role:addAttr(v.itemId,v.number)
                        PopText(v.name.."+"..tostring(v.number))
                    end
                end

                if role:getInheritFlag(itemFlag[currItemIndex])>0 then 
                    role:setInheritFlag(itemFlag[currItemIndex], role:getInheritFlag(itemFlag[currItemIndex])-1)
                end
                role:addItemCount(itemInfo[currItemIndex],-1)

                FamilyPrestige:addUserPrestige(rewardPrestigeList[currItemIndex],addFlag,function (data)
                    if data.num~=0 and data.num~=nil then 
                        PopText("师门声望".."+"..tostring(rewardPrestigeList[currItemIndex]))
                    end
                end)
            else
                for k,v in pairs(rewardItemList[currItemIndex]) do 
                    if v.type == "物品" then
                        local currItemId=v.itemId
                        if exchangeItem[v.itemId] then 
                            currItemId=exchangeItem[v.itemId]
                        end
                        local itemAttr = role:getOneItemByKey(currItemId)
                        if itemAttr then
                            role:addItemCount(currItemId,v.number)
                            PopText("获得物品"..itemAttr.name.."X"..tostring(v.number))
                        end
                    else
                        role:addAttr(currItemId,v.number)
                        PopText(v.name.."+"..tostring(v.number))
                    end
                end

                if role:getInheritFlag(itemFlag[currItemIndex])>0 then 
                    role:setInheritFlag(itemFlag[currItemIndex], role:getInheritFlag(itemFlag[currItemIndex])-1)
                end

                role:addAttr("yueli",rewardYueLiList[currItemIndex])
                PopText("阅历".."+"..tostring(rewardYueLiList[currItemIndex]))
                role:addItemCount(itemInfo[currItemIndex],-1)
            end
        end
        if isHaveItem and currItemIndex then 
            if role:getInheritFlag(itemFlag[currItemIndex])>0 then 
                getRewardFunc()
            else
                HttpManagerEx:checkItemIsCanUse(
                    itemInfo[currItemIndex],1,
                    function(status, errcode, errmsg, data)
                        if status == 200 then
                            if errcode == 0 then
                                getRewardFunc() 
                            else
                                RichPrint("main", result.arg3)
                                print("errmsg", errmsg, "errcode", errcode)
                            end
                        else
                            PopText(errmsg)
                        end
                    end,
                IS_SHOW_WAITING)
            end
        end
    end,

    ["无间林入场判断"] = function(map, result, environment)
        if not result.arg2 or result.arg2=="" then 
            print("无间林入场判断 策划配置出错")
            return
        end
        print("result.arg2:",result.arg2,"result.arg3:",result.arg3)
        local itemFlag = result.arg3
        local role = User:getRole()
        if role:getItemCount(result.arg2)<1 then 
            map:doNoRoleResults(result.arg5,environment) 
            return
        end
        if itemFlag~=nil and role:getInheritFlag(itemFlag)>0 then 
            role:setInheritFlag(itemFlag, role:getInheritFlag(itemFlag)-1)
            role:addItemCount(result.arg2,-1)
            map:doNoRoleResults(result.arg4,environment) 
        else
            HttpManagerEx:checkItemIsCanUse(
                result.arg2,1,
                function(status, errcode, errmsg, data)
                    if status == 200 then
                        if errcode == 0 then
                            role:addItemCount(result.arg2,-1)
                            map:doNoRoleResults(result.arg4,environment) 
                        else
                            map:doNoRoleResults(result.arg5,environment) 
                            print("errmsg", errmsg, "errcode", errcode)
                        end
                    else
                        PopText(errmsg)
                    end
                end,
            IS_SHOW_WAITING)
        end
    end,

    ["周年庆兑换书籍"] = function(map, result, environment)
        --
        if not result.arg2 or result.arg2=="" then 
            print("周年庆兑换书籍 策划配置出错")
            return 
        end
        local role =User:getRole()
        local itemList= string.split(result.arg2,";") 
        local bookSkillId
        if result.arg3 then 
            bookSkillId=string.split(result.arg3,";")
        end
        local bookSkills={}
        for i=1,#itemList do
            if itemList[i] and bookSkillId[i] then
                bookSkills[itemList[i]]=bookSkillId[i]
            end
        end

        local exchange_itemId = result.arg4 --兑换使用物品
        local exchange_item = Item:getOneItemByKey(exchange_itemId)
        if MapIsEmpty(exchange_item) then
            print(false,"没有该物品,物品id:"..exchange_itemId)
            return 
        end

        local exchange_itemName = exchange_item.name
        local npcName = environment.currRole.name

        local text =npcName.."：老夫路经此地，正在寻找一枚名为“"..exchange_itemName.."”的令牌，少侠如若寻得可找我换一些珍藏之物。"
        local function exchangeBtnFunc(itemId)
            local itemId = itemId  --物品Id
            local button_confirm_name = "兑换" --确定按钮名字
            local button_close_name = "不了"   --取消按钮名字
            local itemData = Item:getOneItemByKey(itemId)

            local textList = {
            Text_tital = itemData.name,
            Text_type = itemData:getItemShowType(),
            Text_dsc = itemData.dsc,
            Text_price = "兑换需要："..exchange_itemName,
            Text_affirm = "RAN确定兑换"..itemData.name.."吗？",
            }

            local function confirmBtnFunc(itemId)
                if role:getItemCount(exchange_itemId)<1 then 
                    RichPrint("main", "YEL"..npcName.."：少侠若寻得"..exchange_itemName.."，可寻老夫换一些珍藏之物。")
                    return
                end

                if role:getItemCount(itemId)>0 and bookSkills[itemId]~=nil then 
                    print("itemId:",itemId)
                    PopText("你已拥有该秘籍，无法兑换。")
                    return
                end

                if MapIsEmpty(bookSkills)==false and bookSkills[itemId] then 
                    local itemskill=role:getSkill(bookSkills[itemId])
                    if  MapIsEmpty(itemskill)==false then
                        print("bookSkills[itemId]:",bookSkills[itemId])
                        PopText("你已拥有该秘籍，无法兑换。")
                        return
                    end
                end

                if role:checkCanBuyThings(itemId,1) == false then 
                    return
                end
                
                HttpManagerEx:checkItemIsCanUse(
                        exchange_itemId,1,
                        function(status, errcode, errmsg, data)
                            if status == 200 then
                                if errcode == 0 then
                                    role:addItemCount(itemId, 1)
                                    role:addItemCount(exchange_itemId, -1)
                                    RichPrint("main", "YEL"..npcName.."：少侠可要拿好了。")
                                else
                                    RichPrint("main", "YEL"..npcName.."：少侠若寻得"..exchange_itemName.."，可寻老夫换一些珍藏之物。")
                                end
                            else
                                PopText(errmsg)
                            end
                        end,
                    IS_SHOW_WAITING)  
            end
            PopupLayerController:showLayer("ShoppingDialogLayer",function(layer)
                layer:showLayer(textList,function()
                end)
                layer:setButton_confirm(button_confirm_name, function()
                    confirmBtnFunc(itemId)
                end)
                layer:setButton_close(button_close_name, function()
                    RichPrint("main", "YEL"..npcName.."：少侠若寻得"..exchange_itemName.."，可寻老夫换一些珍藏之物。")
                end)
            end)
        end
        local btnList={}
        local funcList={}
        for i = 1, 6 do
            funcList[i] = function()
                if itemList[i] ~= nil then
                    exchangeBtnFunc(itemList[i])
                end
            end
            local itemAttr = role:getOneItemByKey(itemList[i])
            if itemAttr then
               btnList[i]= "RAN"..itemAttr.name
            end
        end
        
        PopupLayerController:showLayer(
            "ChooseButtonLayer",
            function(layer)
                layer:initLayer(text, 
                    btnList[1], 
                    funcList[1], 
                    btnList[2], 
                    funcList[2],
                    btnList[3], 
                    funcList[3], 
                    btnList[4], 
                    funcList[4], 
                    btnList[5], 
                    funcList[5], 
                    btnList[6], 
                    funcList[6]
                )
            end
        )
    end,
    ["钓鱼玩法"] = function(map, result, environment)
		HttpManagerEx:getActionTimes("FishingGame",function(status, errcode, errmsg, data)
			if status == 200 then
				if errcode == 0 then
					local count = result.arg2 --每日可玩次数
					local animDuration = result.arg3 --动画时间
					local currCount = data.num --今日已玩过的次数

                    PopupLayerController:showLayer("DialogUseLayer", function(layer)
                        layer:show()

                        if tonumber(currCount) == 0 then
                            layer:setTextDesc("本次免费")
                        else
                            layer:setTextDesc("本次需花费"..data.remove.."元宝")
                        end

                        layer:setTitle("是否确定进行钓鱼？")
                        layer:setTextUseGoods("今日剩余次数："..tostring(count - tonumber(currCount)))
                        
                        --确定按钮
                        layer:setButton1(function()
                            if currCount >= count and DEBUG_MODE ~= 1 then
                                PopText("少侠，今日已经钓了很多次了，明日再来吧。")
                                return
                            end
                            local role = User:getRole()
                            HttpManagerEx:submitAction("FishingGame",1,function(status, errcode, errmsg, data)
                                if status == 200 and errcode == 0 then
                                    HttpManagerEx:addCurrencyNumber({["jiaozi"] =50 },"DailyTies_weekslcd","weekact", function(status, errcode, errmsg, data)
                                        if 200 == status and 0 == errcode then
                                            local popStr1, popStr2= ""
                                            if MapIsEmpty(data.currency) == false then
                                                for currency,valueData in pairs(data.currency) do
                                                    if valueData.value > 0 then 
                                                        --增加XX新货币，共拥有XX新货币。
                                                        popStr1 ="增加"..tostring(valueData.value)..role:getCHAttrName(currency).."，共拥有"..tostring(valueData.count)..role:getCHAttrName(currency)
                                                    end
                                                    if valueData.desc ~= nil and valueData.desc ~= ""  then
                                                        popStr2 = valueData.desc
                                                    end
                                                end
                                            end
                                            HttpManagerEx:checkGoodsValid({"yuhuiling"}, function(status, errcode, errmsg, data)
                                                if 200 == status and 0 == errcode then
                                                    local haveYuHuiLing = false
                                                    for k,v in pairs(data) do 
                                                        if "yuhuiling" == v.itemId and v.number > 0 then 
                                                            haveYuHuiLing = true 
                                                        end
                                                    end
                                                    PopupLayerController:showLayer("FishingGameLayer", function(layer)
                                                        layer:showLayer(animDuration,haveYuHuiLing)
                                                        layer:PopYouZiLingText(popStr1,popStr2)
                                                    end)
                                                else
                                                    PopText("网络请求出错,请换个网络环境再试!")
                                                end
                                            end, IS_SHOW_WAITING)
                                        else
                                            PopText("网络请求出错,请换个网络环境再试!")
                                        end
                                    end, IS_SHOW_WAITING)
                                else
                                    PopText(errmsg)
                                end
                            end, IS_SHOW_WAITING)
                        end)
                        --取消按钮
                        layer:setButton2()
                    end)
				else
					PopText(errmsg)
				end
			end
		end,
		IS_SHOW_WAITING)
	end,
	["鱼市"] = function(map, result, environment)
		PopupLayerController:showLayer("FishingMarketLayer", function(layer)
			layer:showLayer("exchangeFish")
		end)
	end,

    ["售鱼"] = function(map, result, environment)
        if not result.arg2 or result.arg2=="" then 
            print("售鱼 策划配置出错 arg2")
            return
        end
        local fishList=string.split(result.arg2,";")
        PopupLayerController:showLayer("FishingMarketLayer", function(layer)
            layer:showLayer("shoppingFish",fishList)
        end)
    end,

    ["赠鱼"] = function(map, result, environment)
        local role = User:getRole()
        if role:getDayFlag("每日赠鱼")==2 then  --0 没做  1 已经接了 2 已经完成
            RichPrint("main", "YEL马三德：今日真是多谢少侠了，上次我前去钓鱼还摔入湖了，说来真是惭愧。")  
        else
            local FishingGameUtil = require("app.models.Action.Fishing.FishingGameUtil")
            local currFishList= FishingGameUtil:getFishGiftToNpcList()
            local currFishTask = FishingGameUtil:getCurrTaskOfFishGift(role:getDayFlag("赠鱼任务id"))

            local bagSpace = currFishTask.space
            local isHaveFish=true
            for k,v in ipairs(currFishList) do 
                if MapIsEmpty(v)==false then 
                    isHaveFish=FishingGameUtil:cheakFishIsEnough(tostring(v.id),v.num)
                    if isHaveFish==false then 
                        break
                    end
                end
            end
            if role:getDayFlag("每日赠鱼")==0 then 
                role:setDayFlag("每日赠鱼",1)
                RichPrint("main", currFishTask.fishOktext)
                return
            end
            if isHaveFish then
                if role:getAttr("weight") - #role:getItems() < bagSpace then
                    PopText("背包空间不足，无法领取奖励")
                    return
                end
                for k,v in ipairs(currFishList) do 
                    if MapIsEmpty(v)==false then 
                       FishingGameUtil:fishExchange(tostring(v.id),v.num) 
                    end
                end
                local extraAwardId = currFishTask.awardid
                print("奖励策略id  extraAwardId = ",extraAwardId)
                local rewardArray = RewardManager:getRewardArrayWithRewardSchemeWithoutRestriction(
                    extraAwardId,
                    role:getAttr("exp"),
                    role:getFinalAttr("luck"),
                    role:getKongfu()
                )

                local estRewardList = {
                    ["属性"] = {},
                    ["物品"] = {}
                }

                if not MapIsEmpty(rewardArray) then
                    for i, reward in ipairs(rewardArray) do
                        if reward.type == "物品" then
                            estRewardList["物品"][reward.id] = tonumber(reward.value)
                        elseif reward.type == "属性" then
                            estRewardList["属性"][reward.id] = tonumber(reward.value)
                        else
                            if DEBUG_MODE == 1 then
                                assert(false, "奖励策略奖励类型填写错误")
                            end
                        end
                    end
                end

                local attrTab = estRewardList["属性"]
                local itemTab = estRewardList["物品"]
                if not MapIsEmpty(attrTab) then
                    for attr,attrValue in pairs(attrTab) do
                        role:addAttr(attr,attrValue)
                        PopText("获得" .. role:getCHAttrName(attr) ..tostring(attrValue))
                    end
                end

                if not MapIsEmpty(itemTab) then
                    for itemId,itemValue in pairs(itemTab) do
                        local item = Item:getOneItemByKey(itemId)
                        if item then
                            local name = item.name
                            role:addItemCount(itemId, itemValue)
                            PopText("获得".. name.." x " .. itemValue)
                        else
                            assert(false,"物品不存在  itemId = "..itemId)
                        end
                    end
                end
                role:setDayFlag("每日赠鱼",2)
                RichPrint("main", currFishTask.fishFinishText)
            else
                RichPrint("main", currFishTask.fishOktext)
            end
        end 
    end,
    
     ["累充档位判断"] = function(map, result, environment)
        -- arg2 :  档位
        -- arg3 :  符合条件执行的结果集
        -- arg4 :  不符合条件执行的结果集
        local num = result.arg2
        local succeedStrs = result.arg3
        local defeatedStrs = result.arg4
        HttpManagerEx:getActionSpendInfo("totalPay1",function (status, errcode, errmsg, data, isEncrypted)
            if status == 200 and errcode == 0 then
                if DEBUG_MODE == 1 then
                    Helper:print_lua_table(data)
                end
                if not MapIsEmpty(data) then
                    if data[tostring(num)] == nil then
                        print("填的充值档位有误")
                        return
                    end

                    if data[tostring(num)] == 2 then
                        local role = User:getRole()
                        if role:checkCanBuyTwoOrMoreThings({["dao101"] = 1},false) then
                            print("兑换成功")
                            map:doNoRoleResults(succeedStrs, environment)
                        else
                            PopText("背包空间不足，需最少预留一个空位")
                        end
                    else
                        print("兑换失败")
                        map:doNoRoleResults(defeatedStrs, environment)
                    end
                end
            else
                PopText(errmsg)
            end
        end,IS_SHOW_WAITING)
	end,   
    ["兑换锦鲤"] = function(map, result, environment)
        -- result.arg2 --所需其它鱼类
        local FishingGameUtil = require("app.models.Action.Fishing.FishingGameUtil")
        local needList = {}
        local fishTypeList = string.split(result.arg2,";")
        for i,v in ipairs(fishTypeList) do
            local fishInfo = string.split(v,",")
            local fishId = fishInfo[1]
            local fishNum = tonumber(fishInfo[2])

            table.insert( needList, {fishId = fishId,fishNum = fishNum })
        end
        
        local text = "是否要用"
        for i,v in ipairs(needList) do
            local fishName = FishingGameUtil:getFishAttr(v.fishId).fishname
            local num = v.fishNum

            if num > 0 then
                if i == 1 then
                    text = text..num.."只"..fishName
                else
                    text = text.."、"..num.."只"..fishName
                end
            end
        end
        text = text.."兑换一只锦鲤？"

		local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
        local dialog = DialogALayer:getInstance()
        dialog:hide()
        dialog:show(text)
        dialog:setRichText(text)
        dialog:setButton1("确定", function()
            local result = true
            for i,v in ipairs(needList) do
                if FishingGameUtil:cheakFishIsEnough(v.fishId,v.fishNum) == false then
                    result = false
                    break
                end 
            end
            if result == true then
                --兑换消耗鱼类
                for i,v in ipairs(needList) do
                    FishingGameUtil:fishExchange(v.fishId,v.fishNum)
                end
                --获得锦鲤
                local fishId = "101"
                local role = User:getRole()
                local fishTab = role:getInheritFlag("周活钓鱼玩法结果")
                if fishTab == 0 or fishTab == nil then
                    fishTab = {}
                end

                if fishTab[fishId] then
                    fishTab[fishId] = fishTab[fishId] + 1
                else
                    fishTab[fishId] = 1
                end
                role:setInheritFlag("周活钓鱼玩法结果",fishTab)
                PopText("兑换成功，获得锦鲤X1")
            else
                PopText("数量不足，无法兑换")
            end
        end)
        dialog:setButton2("取消", function()
        end)
        dialog:setWeChatVisible(false)
	end,

    ["字牌道具元宝兑换"] = function(map, result, environment)
        local itemId = result.arg2
        local maxExchangeTimes = result.arg3
        print("itemId:",itemId)
        if not itemId then 
            print("字牌道具元宝兑换:arg2配置有问题")
        end
        
        if User:getRole():getAttr("weight") - #User:getRole():getItems()<1 then 
            PopText("背包空间不足，无法进行兑换")
            return 
        end

        HttpManagerEx:getActionTimes(itemId,function(status, errcode, errmsg, data)
            if status == 200 and errcode == 0 then
                if data.num>=maxExchangeTimes then 
                    RichPrint("main", "YEL"..environment.currRole.name.."：少侠，字牌都被兑换完了。")
                    return
                end
                local text_price = "兑换需要："..tostring(data.remove).."元宝" 
                local button_confirm_name = "兑换" --确定按钮名字
                local button_close_name = "不了"   --取消按钮名字
                local isShowNum = 1 --是否显示已经拥有的数量
                local itemData = Item:getOneItemByKey(itemId)
                local tipsStr =  "确定兑换"..itemData.name.."吗？" --显示功能提示文本

                local textList = {
                    Text_tital = itemData.name,
                    Text_type = itemData:getItemShowType(),
                    Text_dsc = itemData.dsc,
                    Text_price = text_price,
                    Text_affirm = tipsStr,
                    Text_havenum = isShowNum == 1 and "已拥有:".. User:getRole():getItemTotalCount(itemData.id)..itemData.unit or "",
                }

                local function confirmExchangeItem()
                    local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
                    local text = "你确定花费"..tostring(data.remove).."元宝兑换"..itemData.name.."么？"
                    local dialog = DialogALayer:getInstance()
                    dialog:hide()
                    dialog:show(text)
                    dialog:setRichText(text)
                    dialog:setButton1("确定", function()
                        HttpManagerEx:submitAction(itemId,1,function(status, errcode, errmsg, data)
                            if status == 200 then
                                if errcode == 0 then
                                    local SFTokenCollection2019 = require("app.models.SpringFestival.2019.SFTokenCollection2019")
                                    SFTokenCollection2019:initConfig()
                                    SFTokenCollection2019:addToken(itemId,1)
                                    RichPrint("main", "YEL"..environment.currRole.name.."：来，少侠这是你的字牌，拿好嘞。")
                                elseif errcode == 1 then
                                    RichPrint("main", "YEL"..environment.currRole.name.."：少侠，你身上的元宝不够呀，我这不能赊账呢。")
                                else
                                    PopText(errmsg)
                                end
                            else
                                PopText(errmsg)
                            end
                        end, IS_SHOW_WAITING)
                    end)
                    dialog:setButton2("取消", function()
                        RichPrint("main", "YEL"..environment.currRole.name.."：少侠，想要兑换字牌的时候可来寻我。")
                    end)
                    dialog:setWeChatVisible(false)
                end
            
                PopupLayerController:showLayer("ShoppingDialogLayer",function(layer)
                    layer:showLayer(textList,function()
                    end)
                    layer:setButton_confirm(button_confirm_name, function()
                        confirmExchangeItem()
                    end)
                    layer:setButton_close(button_close_name, function()
                        RichPrint("main", "YEL"..environment.currRole.name.."：少侠，想要兑换字牌的时候可来寻我。")
                    end)
                end)
            else
                PopText(errmsg)
            end
        end,
        IS_SHOW_WAITING)
    end,

    ["招魂奖励"] = function(map, result, environment)
        local net_rewards = {}
        local local_rewards = {}
        net_rewards["mingbi"] = 100
        net_rewards["zhounianqin_jf"] = 50
        local_rewards["pot"] = 5000
        local_rewards["exp"] = 5000
        local CN = {
            ["mingbi"] = "亿冥币",
            ["zhounianqin_jf"] = "清明礼券",
            ["pot"] = "潜能",
            ["exp"] = "经验",
        }

        local role = User:getRole()
        if  GetTime() > Helper:getTimeStampWithStringDate("20200404", 0)  and GetTime() < Helper:getTimeStampWithStringDate("20200418", 0) then
            HttpManagerEx:addCurrencyNumber(
                net_rewards,
                "DailyTies",
                "qingmingzh",
                function(status, errcode, errmsg, data)
                    if status == 200 and errcode == 0 then
                        if MapIsEmpty(data.currency) == false then
                            for currency,valueData in pairs(data.currency) do
                                if valueData.value > 0 then 
                                    PopText("获得"..tostring(valueData.value)..CN[currency])
                                end
                                if valueData.desc ~= nil and valueData.desc ~= ""  then
                                    PopText(valueData.desc)
                                end
                            end
                            for attr,value in pairs(local_rewards) do 
                                role:addAttr(attr,value)
                                PopText("获得"..tostring(value)..CN[attr])
                            end
                        end
                    else
                        PopText(errmsg)
                    end
                end,
                IS_SHOW_WAITING
            )
        else
            PopText("活动已结束")
        end
    end,

    ["周活动奖励"] = function(map, result, environment)
        --arg2 交子数量 arg3 属性奖励（pot,500;exp,500） arg4 条件结果集 arg5 活动名
        --特殊buff加成属性
        local haveBuffAttr = {
            ["pot"] = true,
            ["exp"] = true,
        }
	    PopupLayerController:showLayer("GlobalShadeLayer",function (layer)
            layer:setPopText("")
            layer:showLayer()
        end)
        local role = User:getRole()
        local jiaoziNum = Helper:getDef(result.arg2,0) 
        local attrList = Helper:getDef(result.arg3,"")
        local addType = Helper:getDef(result.arg5,"")
        local isBuff = false
        attrList = string.split(attrList,";")
        local function addLocalReward(func)
            HttpManagerEx:checkGoodsValid({"yuhuiling"}, function(status, errcode, errmsg, data)
                if 200 == status and 0 == errcode then
                    for k,v in pairs(data) do 
                        if "yuhuiling" == v.itemId and v.number > 0 then 
                            isBuff = true 
                        end
                    end
                    for k,v in pairs(attrList) do 
                        local attrInfo = string.split(v,",")
                        local addAttrName,addAttrNum = attrInfo[1],tonumber(attrInfo[2])
                        
                        
                        local addValue = 0 
                        if isBuff  and haveBuffAttr[addAttrName] then 
                            local buffAddValue = role:getDayFlag("yuhuiling_"..addAttrName)
                            addValue = YUHUILING_BUFF * addAttrNum 
                            if addValue > YUHUILING_NUM_LIMIT - buffAddValue then 
                                addValue = math.max(YUHUILING_NUM_LIMIT - buffAddValue,0)
                            end
                            role:setDayFlag("yuhuiling_"..addAttrName,buffAddValue + addValue)
                        end
                        
                        addAttrNum = addAttrNum + addValue
                        role:addAttr(addAttrName,addAttrNum)
                        PopText("获得"..tostring(addAttrNum)..role:getCHAttrName(addAttrName))
                    end
                    if result.arg4 then
                        map:doNoRoleResults(result.arg4, environment)
                    end
                else
                    PopText("网络请求出错,请换个网络环境再试!")
                end
                if func then 
                    func()
                end
            end, IS_SHOW_WAITING)
        end
        if jiaoziNum > 0 then 
            HttpManagerEx:addCurrencyNumber({["jiaozi"] =jiaoziNum },"DailyTies_"..addType,"weekact", function(status, errcode, errmsg, data)
                    if 200 == status and 0 == errcode then
                        if MapIsEmpty(data.currency) == false then
                            for currency,valueData in pairs(data.currency) do
                                if valueData.value > 0 then 
                                    --增加XX新货币，共拥有XX新货币。
                                    PopText("增加"..tostring(valueData.value)..role:getCHAttrName(currency).."，共拥有"..tostring(valueData.count)..role:getCHAttrName(currency))
                                end
                                if valueData.desc ~= nil and valueData.desc ~= ""  then
                                    PopText(valueData.desc)
                                end
                            end
                        end
                        addLocalReward(function()
                            PopupLayerController:hideLayer("GlobalShadeLayer",function ( layer )
                                layer:hideLayer()
                            end)
                        end)
                    else
                        PopText("网络请求出错,请换个网络环境再试!")
                        PopupLayerController:hideLayer("GlobalShadeLayer",function ( layer )
                            layer:hideLayer()
                        end)
                    end
                end, IS_SHOW_WAITING)
        else
            addLocalReward(function()
                PopupLayerController:hideLayer("GlobalShadeLayer",function ( layer )
                    layer:hideLayer()
                end)
            end)
        end
    end,

    ["扳手腕"] = function(map, result, environment)
         if User:getRole():getAttr("weight") - #User:getRole():getItems() < 1 then 
            PopText("背包空间不足，无法进行游戏")
            return 
        end
        -- arg2=成功结果集  arg3=失败结果集  arg4=滚动轴的速度 arg5=描述文本 arg6=游戏次数 arg7 胜利奖励 arg8 失败奖励
        print(result.arg2,result.arg3,result.arg4,result.arg5,result.arg6,result.arg7,result.arg8)
        local successResultsFun
        local failedResultsFun
        local speed = result.arg4
        local descText = result.arg5
        local gameTimes = result.arg6
        local successReward = result.arg7
        local failReward = result.arg8

        if result.arg2 then 
            successResultsFun = function()
                map:doNoRoleResults(result.arg2, environment)
            end
        end

        if result.arg3 then 
            failedResultsFun = function()
                map:doNoRoleResults(result.arg3, environment)
            end
        end

        PopupLayerController:showLayer("WristbandCompetitionLayer",function(layer)
            layer:showLayer(gameTimes,speed,descText,successResultsFun,failedResultsFun,successReward,failReward)
        end)

    end,

    ["活动获取冥币"] = function(map, result, environment)
        local addCurrency = result.arg2
        local addType = result.arg3
        if not addType or not addCurrency then
            assert(false,"活动获取冥币 arg2 或者 arg3 为空")
        end
        local role = User:getRole()
        local mianju = role:getPortraitId()
        local isMianju = 0
        if mianju == "mianju1069" or mianju == "mianju1070" then
            addCurrency = addCurrency * (1 + 0.25)
            isMianju = 1
        end

        HttpManagerEx:addDeadCurrency(addType, addCurrency,isMianju, function(status, errcode, errmsg, data)
                if status == 200 then
                    if errcode == 0 then
                        if data.number > 0 then
                            PopText("冥币 + " .. data.number .. "亿")
                        end
                    else
                        PopText(errmsg)
                    end
                else
                    PopText(errmsg)
                end
            end, IS_SHOW_WAITING)
    end,

    ["中秋月饼机关"] = function(map, result, environment)
        local game_time = result.arg2

		local succResult = result.arg3

        local failedResult = result.arg4
        
        local text_str = result.arg5

        PopupLayerController:showLayer("HuaRongDaoLayer",function (layer)
			
			layer:setSuccessCallBack(function ()
				map:doNoRoleResults(succResult, environment)
			end)
			
			layer:setFailCallBack(function ()
				map:doNoRoleResults(failedResult, environment)
            end)
            
            local HuaRongDaoModel = require("app.models.MiniGame.HuaRongDaoModel")

            local guanqia = HuaRongDaoModel:getRandGuanQia()
			
			layer:showLayer(tonumber(game_time),text_str,guanqia)
		end)
    end,

    ["施粥玩法"] = function(map, result, environment)
        local npcList = string.split(result.arg2,";")
        local randRange= string.split(result.arg3,";")
        local min_num,max_num = tonumber(randRange[1]), tonumber(randRange[2])

        local LaBaShiZhou_2021 = require("app.models.Action.LaBa.LaBaShiZhou_2021")
        LaBaShiZhou_2021:setEndTime(GetTime() + result.arg5)
        LaBaShiZhou_2021:setSingleRefreshTime(result.arg4)
        LaBaShiZhou_2021:startGame()
        
        local gameFunc = function()
            local singleNpcList = LaBaShiZhou_2021:getSingleNpcList()

            if MapIsEmpty(singleNpcList) == false then
                for i = 1,#singleNpcList do
                    if singleNpcList[i] then
                        map:removeRoomRole(environment.currRoomId, singleNpcList[i],false)
                    end
                end
            end

            local randomNpcList = LaBaShiZhou_2021:getNpcList(npcList,min_num,max_num)
            local singleNpcList = {}
            
            for i = 1,#randomNpcList do
                local npc = LaBaShiZhou_2021:createLaBaShiZhouNpc(randomNpcList[i])
                map:createRole(npc)
                map:addRoomRole(environment.currRoomId, npc.id,false)
                table.insert(singleNpcList,npc.id)

                if i == #randomNpcList then
                    map.__MapLayer:delayRefreshMap()
                    break
                end
            end

            LaBaShiZhou_2021:setSingleNpcList(singleNpcList)
            LaBaShiZhou_2021:startSingleGame(#singleNpcList)
        end

        gameFunc()

        map.labaSchedule =  map:setSchedule(function ()
            if LaBaShiZhou_2021:checkIsEnd() then
                map:unSchedule(map.labaSchedule)
                map.labaSchedule = nil

                local singleNpcList = LaBaShiZhou_2021:getSingleNpcList()

                if MapIsEmpty(singleNpcList) == false then
                    for i = 1,#singleNpcList do
                        if singleNpcList[i] then
                            map:removeRoomRole(environment.currRoomId, singleNpcList[i],false)
                        end
                        if i == #singleNpcList then
                            map.__MapLayer:delayRefreshMap()
                            break
                        end 
                    end
                end

                local rewardId = LaBaShiZhou_2021:getRewardId()

                if DEBUG_MODE == 1 then
                    if User:getRole():getDayFlag("2021_labashizhou_test_rewardId") ~= 0 then
                        rewardId = User:getRole():getDayFlag("2021_labashizhou_test_rewardId")
                    end
                end

                local role = User:getRole()

                --@RefType [src.app.models.Record.Reward.ARewardRecord#ARewardRecord]
                local ARewardRecord = require("app.models.Record.Reward.ARewardRecord")
                --@RefType [src.app.models.reward.OpenRewardGet#OpenRewardGet]
                local openRewardGet =
                    require("app.models.reward.OpenRewardGet"):create(
                    role,
                    {rewardId},
                    ARewardRecord.RTYPE.MAP_RESULT,
                    "rewardArrayWithRewardScheme",
                    {
                        mapid = map.id,
                        npcid = environment.currRole.id,
                        rlt = result.arg1
                    }
                )
                openRewardGet:doGetReward(
                    function(rewardArray)
                        for i, reward in ipairs(rewardArray) do
                            if reward.type == "物品" then
                                if map:addItemCount(reward.id, reward.value) == false then
                                    map:dropItem(map:getCurrRoomId(), reward.id, reward.value)
                                    map.__MapLayer:delayRefreshMap()
                                else
                                    role:addItemCount(reward.id, reward.value)
                                    PopText("获得 " .. Item:getOneItemByKey(reward.id).name .. " x " .. reward.value)
                                end
                            elseif reward.type == "属性" then
                                if type(role:getCHAttrName(reward.id)) == "string" then
                                    PopText("获得" .. role:getCHAttrName(reward.id) .. tostring(reward.value))
                                end
                                role:addAttr(reward.id, reward.value)
                            end
                        end
                    end
                )

                if result.arg6 then
                    map:doNoRoleResults(result.arg6,environment)
                end
                
                return
            end

            if LaBaShiZhou_2021:checkIsRefreshNpc() then
                gameFunc()
            end
        end)
    end,

    ["清除领粥Npc"] = function(map, result, environment)
        local LaBaShiZhou_2021 = require("app.models.Action.LaBa.LaBaShiZhou_2021")
        local singleNpcList = LaBaShiZhou_2021:getSingleNpcList()
        
        if MapIsEmpty(singleNpcList) == false then
            for i = 1,#singleNpcList do
                if singleNpcList[i] then
                    map:removeRoomRole(environment.currRoomId, singleNpcList[i],false)
                end
                if i == #singleNpcList then
                    map.__MapLayer:delayRefreshMap()
                    break
                end 
            end
        end
    end,

    ["施粥"] = function(map, result, environment)
        if map:checkRoleIsInRoom(environment.currRoomId, environment.currRole.id) == false then
            RichPrint("main","你端着一碗热粥，却在纠结到底给还是不给。犹犹豫豫间，这个人已经离开了。")
            return
        end

        local LaBaShiZhou_2021 = require("app.models.Action.LaBa.LaBaShiZhou_2021")
        local role = environment.currRole
        LaBaShiZhou_2021:shizhou(role.labaId,function(isRepeat)
            LaBaShiZhou_2021:removeNpc(role.id)
            if isRepeat then
                RichPrint("main","这人刚才才拿过一碗粥，你盛了一碗热粥递了过去，人群中响起对你的质疑之声。")
            else
                RichPrint("main","此人今日还未拿过一碗粥，你盛了一碗热粥递了过去，人群中传来对你的赞扬之声。")
            end
        end)
        map:removeRoomRole(environment.currRoomId,role.id,false)
    end,

    ["驱赶"] = function(map, result, environment)
        if map:checkRoleIsInRoom(environment.currRoomId, environment.currRole.id) == false then
            RichPrint("main","你端着一碗热粥，却在纠结到底给还是不给。犹犹豫豫间，这个人已经离开了。")
            return
        end
        
        local LaBaShiZhou_2021 = require("app.models.Action.LaBa.LaBaShiZhou_2021")
        local role = environment.currRole
        LaBaShiZhou_2021:qugan(role.labaId,function(isRepeat)
            LaBaShiZhou_2021:removeNpc(role.id)
            if isRepeat then
                RichPrint("main","这人刚才才拿过一碗粥，你将此人赶了出去，人群中传来对你的赞扬之声。")
            else
                RichPrint("main","此人今日还未拿过一碗粥，你将此人赶了出去，人群中响起对你的质疑之声。")
            end
        end)
        map:removeRoomRole(environment.currRoomId,role.id,false)
    end,

}

--中元节孤魂野鬼
function FestivalModule:createGhostsNPC(map)
    -- add by XiaoZhiWei 2017/11/28 18:07:00 活动已关闭
    if true then
        return
    end

    --判断是否在活动期间
    local ghosts = require("app.models.Activities.ghosts")
    local _ghosts = ghosts:testFun()
    if type(_ghosts) ~= "table" then
        print("************************type(_ghosts) ~= table****************************")
        return
    end
    _ghosts = Helper:getDef(ghosts:setRoomWithComeInMap(map.id, _ghosts), {})
    -- Helper:print_lua_table(_ghosts)
    local function createItemGhost(role, overTime, roomId)
        local MapInfo = require("app.models.map.MapInfo")
        role.canSee = true
        role.specialType = "中元节物品"
        -- [1] = "zhongyuanrernwu16",	--镜子
        -- [2] = "zhongyuanrernwu17",	--棺材
        -- [3] = "zhongyuanrernwu18",	--破旧蒲团
        -- [4] = "zhongyuanrernwu19"	--石像
        local tab = {
            ["zhongyuanrernwu16"] = "查看", --镜子
            ["zhongyuanrernwu17"] = "推开", --棺材
            ["zhongyuanrernwu18"] = "坐下", --破旧蒲团
            ["zhongyuanrernwu19"] = "观察" --石像
        }
        if tab[role.baseId] ~= nil then
            role.canUse1 = true
            role.useName1 = tab[role.baseId]
            role.conditionAndResults = {
                {
                    conditionRelation = "and",
                    conditions = {
                        {
                            type = "玩家操作",
                            arg1 = "玩家操作",
                            arg2 = "使用1"
                        }
                    },
                    results = {
                        {
                            type = "架起",
                            arg1 = "中元节交互",
                            arg2 = tab[role.baseId]
                        }
                    }
                }
            }
        end
        MapInfo:addRoleToRoomByRoomId(map, roomId, role)
        map:InSertTaskToDelayTasks(
            role.id,
            overTime + GetTime(),
            function()
                map:removeRoomRole(roomId, role.id)
            end
        )
    end
    local function getPlayerFaceDsc()
        local list = {
            [1] = "BLU面色铁青，目无神采，浑身湿漉漉的，似乎刚从水中捞出来一样。",
            [2] = "HIW无面无相，手拿蒲扇，十分吓人。",
            [3] = "HIM长发飘然，面无血色，阴森恐怖。",
            [4] = "HIY头生三眼，脑大少发，畸形渗人。",
            [5] = "HIM黑青面庞，白眼无瞳，脸上异纹横生，眉间还有一抹殷红，浑身煞气，令人生惧。"
        }
        return list[math.random(1, #list)]
    end
    local function createGhost(list, roomId)
        print("roomId:", roomId, map:getRoomNameById(roomId))
        local overTime = User:getRole():getTimeLimitFlagTime("ghosts")
        if list.npcBaseId == "zhongyuanrernwu14" then
            --服务器请求数据
            HttpManagerEx:getPlayGhost(
                function(status, errcode, errmsg, data)
                    if status == 200 and errcode == 0 then
                        print("********************玩家性别*************************", data.sex)
                        Helper:print_lua_table(data)
                        list.sex = data.sex
                        list.name = data.name
                        local role = ghosts:createGhostsNPC(list)
                        data = Helper:tableCover(data, role)
                        role.sex = data.sex
                        if role.id == nil then
                            return
                        end
                        role.canSeeInheritHistory = false
                        role.ghostPlayer = 1
                        role.playerFaceDsc = getPlayerFaceDsc()
                        map:createRole(role)
                        map:addRoomRole(roomId, role.id, true)
                        map:InSertTaskToDelayTasks(
                            role.id,
                            overTime + GetTime(),
                            function()
                                map:removeRoomRole(roomId, role.id)
                            end
                        )
                        local npc = map:getRole(role.id)
                        npc.words = string.split("嗯？有什么事情么？;中元时节，晚上最好不要出来。", ";")
                    elseif status == 200 and errcode == -1 then
                        local npc = ghosts:createNPCList(3)
                        ghosts:replacePlayerWithGhost(npc, roomId, map.id)
                        createGhost(npc, roomId)
                        if type(npc.other) == "table" then
                            for k, v in pairs(npc.other) do
                                createGhost(v, roomId)
                            end
                        end
                    end
                end,
                IS_SHOW_WAITING
            )
        else
            local role = ghosts:createGhostsNPC(list)
            if role.type == "role" then
                if role.id == nil then
                    return
                end
                -- role.corpseReward = 1
                map:createRole(role)
                map:addRoomRole(roomId, role.id, true)
                map:InSertTaskToDelayTasks(
                    role.id,
                    overTime + GetTime(),
                    function()
                        map:removeRoomRole(roomId, role.id)
                    end
                )
                local npc = map:getRole(role.id)
                npc.words = ghosts:getRoleWordByDscType(npc, "dscA")
            else
                createItemGhost(role, overTime, roomId)
            end
        end
    end
    local ghostList = {}
    -- Helper:print_lua_table(_ghosts[map.id])
    for k, v in pairs(Helper:getDef(_ghosts[map.id], {})) do
        -- createGhost(v,v.roomId)
        local tab = {
            role = v,
            roomId = v.roomId
        }
        if v.canSee == false then
        else
            tab.role.corpseReward = 1
            table.insert(ghostList, tab)
        end
        if type(v.other) == "table" and v.type ~= "item" then
            for i, j in pairs(v.other) do
                -- createGhost(j,v.roomId)
                local tab = {
                    role = j,
                    roomId = v.roomId
                }
                tab.role.corpseReward = 2
                table.insert(ghostList, tab)
            end
        end
    end
    for i = 1, #ghostList do
        local random = math.random(1, #ghostList)
        createGhost(ghostList[random].role, ghostList[random].roomId)
        table.remove(ghostList, random)
    end
end

function FestivalModule:entryMap(map,currTime)
    local role = User:getRole()
    local leaveTime = role:getFlag(map.id)

    if leaveTime and leaveTime ~= 0 then
        local useTime = currTime - leaveTime
        if useTime >= MAP_REFRESH_INTERVAL then
            self:createGhostsNPC(map)
        --孤魂野鬼
        end
    end
end

return FestivalModule
000000