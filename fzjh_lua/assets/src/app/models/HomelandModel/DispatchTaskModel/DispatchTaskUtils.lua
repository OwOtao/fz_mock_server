local DispatchTaskUtils = {}

local dispatchTasks = requireWithEncrypt("script.others.familylist")["派遣表"]

--@RefType [src.app.models.HomelandModel.HomelandRoleUtil#HomelandRoleUtil]
local HomelandRoleUtil = require("app.models.HomelandModel.HomelandRoleUtil")

local LiLianTaskHelper = require("app.models.task.LiLianTaskHelper")

local dispatchTasklist = {}

local activityTaskRelations = {}
function DispatchTaskUtils:init()
    activityTaskRelations = {
        ["task1"] = {
            relationId = "task1",
            traitBufferName = "daniaoCDReduce",
            reward = {
                {
                    type = "属性",
                    name = "exp",
                    value = 5
                },
                {
                    type = "属性",
                    name = "pot",
                    value = 5
                }
            }
        },
        ["task2"] = {
            relationId = "task2",
            traitBufferName = "xipanziCDReduce",
            reward = {
                {
                    type = "属性",
                    name = "exp",
                    value = 10
                },
                {
                    type = "属性",
                    name = "pot",
                    value = 10
                }
            }
        },
        ["task16"] = {
            relationId = "task16",
            traitBufferName = "feizeiCDReduce",
            specialReward = {
                --@desc 兼容原主线任务特殊奖励结构
                _flag = "飞贼任务奖励",
                _taskId = "task16"
            },
            dayReward = Task:getTask("task16").dayReward,
            reward = {
                {
                    type = "属性",
                    name = "exp",
                    value = function(lv, exp, fy, sklv, confVer)
                        local task16Config = LiLianTaskHelper:getTaskConfigInfo("task16", confVer)
                        return math.floor(Formula:getFormula("jingyan2")(exp, fy, sklv, task16Config.jobreward1,lv))
                    end
                },
                {
                    type = "属性",
                    name = "pot",
                    value = function(lv, exp, fy, sklv, confVer)
                        local task16Config = LiLianTaskHelper:getTaskConfigInfo("task16", confVer)
                        return math.floor(Formula:getFormula("qianneng2")(exp, fy, sklv, task16Config.jobreward2))
                    end
                },
                {
                    type = "属性",
                    name = "yueli",
                    value = function(lv, exp, fy, sklv, confVer)
                        return LiLianTaskHelper:getTaskConfigInfo("task16", confVer).jobreward4
                    end
                }
            }
        },
        ["task17"] = {
            relationId = "task17",
            traitBufferName = "nanyangCDReduce",
            specialReward = {
                --@desc 兼容原主线任务特殊奖励结构
                _flag = "南阳匪贼任务奖励",
                _taskId = "task17"
            },
            dayReward = Task:getTask("task17").dayReward,
            reward = {
                {
                    type = "属性",
                    name = "exp",
                    value = function(lv, exp, fy, sklv, confVer)
                        local task17Config = LiLianTaskHelper:getTaskConfigInfo("task17", confVer)
                        return math.floor(Formula:getFormula("jingyan2")(exp, fy, sklv, task17Config.jobreward1,lv))
                    end
                },
                {
                    type = "属性",
                    name = "pot",
                    value = function(lv, exp, fy, sklv, confVer)
                        local task17Config = LiLianTaskHelper:getTaskConfigInfo("task17", confVer)
                        return math.floor(Formula:getFormula("qianneng2")(exp, fy, sklv, task17Config.jobreward2))
                    end
                },
                {
                    type = "属性",
                    name = "yueli",
                    value = function(lv, exp, fy, sklv, confVer)
                        return LiLianTaskHelper:getTaskConfigInfo("task17", confVer).jobreward4
                    end
                }
            }
        },
        ["task19"] = {
            relationId = "task19",
            traitBufferName = "songxinCDReduce",
            specialReward = {
                --@desc 兼容原主线任务特殊奖励结构
                _flag = "信使任务奖励",
                _taskId = "task19"
            },
            dayReward = Task:getTask("task19").dayReward,
            reward = {
                {
                    type = "属性",
                    name = "pot",
                    value = function(lv, exp, fy, sklv, confVer)
                        local task19Config = LiLianTaskHelper:getTaskConfigInfo("task19", confVer)
                        return math.floor(Formula:getFormula("qianneng2")(exp, fy, sklv, task19Config.jobreward2))
                    end
                },
                {
                    type = "属性",
                    name = "money",
                    value = function(lv, exp, fy, sklv, confVer)
                        local task19Config = LiLianTaskHelper:getTaskConfigInfo("task19", confVer)
                        return math.floor(Formula:getFormula("suiyin2")(exp, fy, sklv, task19Config.jobreward3))
                    end
                }
            }
        },
        ["task20"] = {
            relationId = "task20",
            traitBufferName = "etuCDReduce",
            specialReward = {
                --@desc 兼容原主线任务特殊奖励结构
                _flag = "缉拿任务奖励",
                _taskId = "task20"
            },
            dayReward = Task:getTask("task20").dayReward,
            reward = {
                {
                    type = "属性",
                    name = "pot",
                    value = function(lv, exp, fy, sklv, confVer)
                        local task20Config = LiLianTaskHelper:getTaskConfigInfo("task20", confVer)
                        return math.floor(Formula:getFormula("qianneng2")(exp, fy, sklv, task20Config.jobreward2))
                    end
                },
                {
                    type = "属性",
                    name = "money",
                    value = function(lv, exp, fy, sklv, confVer)
                        local task20Config = LiLianTaskHelper:getTaskConfigInfo("task20", confVer)
                        return math.floor(Formula:getFormula("suiyin2")(exp, fy, sklv, task20Config.jobreward3))
                    end
                }
            }
        },
        ["task21"] = {
            relationId = "task21",
            traitBufferName = "gusiCDReduce",
            specialReward = {
                _taskItems = {"atassitem13"}
            },
            dayReward = Task:getTask("task21").dayReward,
            reward = {
                {
                    type = "属性",
                    name = "exp",
                    value = function(lv, exp, fy, sklv, confVer)
                        local task21Config = LiLianTaskHelper:getTaskConfigInfo("task21", confVer)
                        return math.floor(Formula:getFormula("jingyan2")(exp, fy, sklv, task21Config.jobreward1,lv))
                    end
                },
                {
                    type = "属性",
                    name = "pot",
                    value = function(lv, exp, fy, sklv, confVer)
                        local task21Config = LiLianTaskHelper:getTaskConfigInfo("task21", confVer)
                        return math.floor(Formula:getFormula("qianneng2")(exp, fy, sklv, task21Config.jobreward2))
                    end
                }
            }
        }
    }

    local ignoreId = {
        ["task13"] = true,
        ["task14"] = true,
        ["task15"] = true
    }

    for k, v in pairs(dispatchTasks) do
        if v.open ~= 0 then
            dispatchTasklist[v.taskid] = v
        end
    end
end

DispatchTaskUtils:init()

--@desc: 根据任务ID获取任务属性
--@author:Liang SongQiang
--@time:2018-05-02 21:13:09
--@taskId: 任务ID
function DispatchTaskUtils:getTaskById(taskId)
    if taskId == nil then
        return
    end

    return dispatchTasklist[taskId]
end

function DispatchTaskUtils:getDispatchTaskList()
    return dispatchTasklist
end

--@desc: 获取主动任务需求进度
--@author:Liang SongQiang
--@time:2019-03-14 18:43:50
function DispatchTaskUtils:getActivityTaskJindu(taskId)
    local activityTask = activityTaskRelations[taskId]
    local jindu = 0
    if activityTask then
        local releationTask = Task:getTask(activityTask.relationId)
        if releationTask.jindu then
            jindu = releationTask.jindu
        end
    end

    return jindu
end

--@desc: 如果任务派遣，完成之前把玩家的关联的主动任务状态更改为派遣
--@author:Liang SongQiang
--@time:2018-05-03 10:41:31
function DispatchTaskUtils:changePlayerTaskState(taskId)
    --@RefType [src.app.models.role.Role#Role]
    local role = User:getRole()
    local roleTask = self:getDispatchTaskRelationRoleTask(taskId)

    if not roleTask then
        print("DispatchTaskUtils:changePlayerTaskState（）:  roleTask 不存在")
        return
    end

    roleTask.state = TASK_STATE_DISPATCH
    if activityTaskRelations[taskId] then
        roleTask.aConfVer = LiLianTaskHelper:getConfigVersionByTime(GetTime())
    end
end

function DispatchTaskUtils:getTaskTime(taskId, confVer)
    local d_task = self:getTaskById(taskId)
    assert(d_task, "DispatchTaskUtils:getTaskTime 派遣任务不存在，taskId:" .. tostring(taskId))

    local taskTime = d_task.tasktime
    if taskTime == "activemaxtime" then
        taskTime = LiLianTaskHelper:getTaskConfigInfo(taskId, confVer).maxtime
    end

    taskTime = tonumber(taskTime)
    assert(taskTime, "DispatchTaskUtils:getTaskTime 派遣任务次数配置错误，taskId:" .. tostring(taskId) .. ", tasktime:" .. tostring(d_task.tasktime))

    return taskTime
end

--@desc: 获取派遣任务关联的任务
--@author:Liang SongQiang
--@time:2018-05-03 11:13:01
--@taskId: 派遣任务ID
function DispatchTaskUtils:getDispatchTaskRelationRoleTask(taskId, confVer)
    local roleTaskId

    if activityTaskRelations[taskId] then
        roleTaskId = activityTaskRelations[taskId].relationId
    end

    local taskTime = self:getTaskTime(taskId, confVer)

    --@RefType [src.app.models.role.Role#Role]
    local role = User:getRole()

    local roleTask
    if not roleTaskId then
        print("DispatchTaskUtils:getDispatchTaskRelationRoleTask（）:  roleTaskId 不存在", taskId)
        roleTask = role:getTask(taskId)
        if roleTask == nil then
            local tempTask = {
                state = TASK_STATE_IDLE,
                startTime = 0,
                endTime = nil,
                dCount = 0,
                cCount = taskTime,
                zCount = 0
            }
            role:setTask(taskId, tempTask)

            roleTask = role:getTask(taskId)
        end
    else
        print("------------------------------------",roleTaskId)
        roleTask = role:getTask(roleTaskId)

        if roleTask == nil then
            print("role task is nil ",roleTaskId)
            local tempTask = {
                state = TASK_STATE_IDLE,
                startTime = 0,
                endTime = nil,
                dCount = 0,
                cCount = taskTime,
                zCount = 0
            }
            role:setTask(taskId, tempTask)
            
            roleTask = role:getTask(taskId)
        end
        
    end

    if not roleTask then
        print("DispatchTaskUtils:getDispatchTaskRelationRoleTask（）:  roleTask 不存在", taskId, roleTaskId)
        return nil
    end

    if roleTask.cCount ~= taskTime then
        roleTask.cCount = taskTime
    end

    return roleTask
end

function DispatchTaskUtils:getActivityTaskSpecialItems(taskId, specialReward, confVer)
    if specialReward._taskItems then
        return specialReward._taskItems
    end

    local taskConfig = LiLianTaskHelper:getTaskConfigInfo(Helper:getDef(specialReward._taskId, taskId), confVer)
    return Helper:getDef(string.split(taskConfig.taskitem, ";"), {})
end

--@desc:获得主动任务奖励
--@author:Liang SongQiang
--@time:2018-05-03 14:07:37
--@role: [src.app.models.role.Role#Role]
--@taskId:任务ID
--@taskCount: 今天还能完成的次数
--@estTime: 预计完成时间
function DispatchTaskUtils:getActivityTaskReward(role, taskId, taskCount, estTime, confVer)
    local player = User:getRole()

    local taskRelation = activityTaskRelations[taskId]
    if confVer == nil then
        confVer = LiLianTaskHelper:getConfigVersionByTime(GetTime())
    end

    -- 预计收益=历练任务剩余次数收益*math.min（任务过期时间/预计完成时间,1）
    -- 任务过期时间=24点---当前时间

    local nowTime = GetTime()

    local coefficient = math.min(Helper:getTodayRemainingTime(nowTime) / estTime, 1)

    --@desc 存放各个主动需获取到的特殊奖励物品，例如：失窃的包裹,虎威山寨宝箱...
    local estRewardList = {
        ["属性"] = {},
        ["物品"] = {},
        ["day"] = {},
        
        --@desc 活动奖励。
        ["activity"] = {},
    }

    --@desc 普通奖励
    for i, reward in ipairs(taskRelation.reward) do
        if reward.type == "属性" then
            if type(reward.value) == "function" then
                local lv = player:getLv()
                local exp = player:getAttr("exp")
                local sklv = player:getKongfu()
                local fy = player:getFinalAttr("luck")
                estRewardList["属性"][reward.name] = reward.value(lv, exp, fy, sklv, confVer) * taskCount
            elseif type(reward.value) == "number" then
                estRewardList["属性"][reward.name] = tonumber(reward.value) * taskCount
            else
                assert(false, "传值出错，value只能是number 和 function，传了" .. type(reward.value))
            end
        elseif reward.type == "物品" then
            estRewardList["物品"][reward.name] = tonumber(reward.value)
        end
    end

    print("========== 加入普通奖励 ==============")
    Helper:print_lua_table(estRewardList)
    print("============== end  =================\n")

    --@desc 特殊奖励
    --@desc 特殊物品数量
    if taskRelation.specialReward then
        local factor = taskCount / self:getTaskTime(taskId, confVer)

        if factor >= 0.5 then
            local specialCount = 0
            local taskItems = self:getActivityTaskSpecialItems(taskId, taskRelation.specialReward, confVer)
            if taskRelation.specialReward._flag then
                local tempCount = 0
                for k, v in pairs(taskItems) do
                    tempCount = tempCount + 1
                end
    
                print("---------------------------", player:getDayFlag(taskRelation.specialReward._flag))
                specialCount = tempCount - player:getDayFlag(taskRelation.specialReward._flag)
            else
                specialCount = 1
            end
    
            for i = 1, specialCount do
                local tempIndex = 1
                if taskRelation.specialReward._flag then
                    tempIndex = player:getDayFlag(taskRelation.specialReward._flag) + i
                end
                estRewardList["物品"][taskItems[tempIndex]] = 1
            end
            
            --@desc 判断是否有特殊奖励
            estRewardList.isSp = 1
    
            print("========== 加入特殊奖励 ==============")
            Helper:print_lua_table(estRewardList)
            print("============== end  =================\n")
        else
            estRewardList.isSp = 0
        end
    end

    if taskRelation.dayReward then
        for i,day_reward in ipairs(taskRelation.dayReward) do
            local _flag = day_reward._flag

            --@desc 今天领取过的次数
            local today_count = player:getDayFlag(_flag)

            --@desc 剩余次数
            local r_count = day_reward._count - today_count

            if r_count > taskCount then
                r_count = taskCount
            end

            if r_count > 0 and day_reward:condi()  then
                local temp = {
                    flag = day_reward._flag,
                    count = r_count
                }

                local total_value = 0
                if type(day_reward.value) == "function" then

                    local t_count = today_count
                    for i=1,r_count do
                        local a_value = day_reward:value(t_count,true,confVer)
                        total_value = total_value + a_value
                        t_count = t_count + 1
                    end
                elseif type(day_reward.value) == "number" then
                    total_value = day_reward.value * r_count
                else
                    assert(false,"每日奖励银票数值配置出错："..self.id)
                end
                
                temp.t_value = total_value

                if estRewardList["day"][day_reward._type] == nil then
                    estRewardList["day"][day_reward._type] = {}
                end
                table.insert(estRewardList["day"][day_reward._type],temp)
            end
        end
        print("========== 加入每日奖励 ==============")
        Helper:print_lua_table(estRewardList)
        print("============== end  =================\n")
    end

    --@RefType [src.app.models.task.ActivityTaskRewardConf#ActivityTaskRewardConf]
    local ActivityTaskRewardConf = require("app.models.task.ActivityTaskRewardConf")
    local roleTask = player:getTask(taskId)
    local dCount = Helper:getDef(roleTask.dCount,0)
    --@desc 模拟完成次数
    for i=1,taskCount do
        local activity_rewards = ActivityTaskRewardConf:getTaskLocalReward(taskId,{dCount = dCount})
        if MapIsEmpty(activity_rewards) == false then
            for _, reward in ipairs(activity_rewards) do
                table.insert(estRewardList.activity, reward)
            end
        end
        dCount = dCount + 1
    end
    
    print("========== 加入活动奖励 ==============")
    Helper:print_lua_table(estRewardList)
    print("============== end  =================\n")

    return estRewardList
end

--@desc: 普通任务奖励
--@author:Liang SongQiang
--@time:2018-05-29 14:40:20
--@role:[src.app.models.role.Role#Role]
--@taskId:任务ID
function DispatchTaskUtils:getNormalTaskReward(role, taskId)
    local dispatchTask = self:getTaskById(taskId)

    if not dispatchTask then
        print("派遣任务不存在", taskId)
        print(debug.traceback())

        return false
    end


    --@RefType [src.app.models.role.Role#Role]
    local player = User:getRole()

    local rewardArray =
        RewardManager:getRewardArrayWithRewardSchemeWithoutRestriction(
        dispatchTask.reward,
        player:getAttr("exp"),
        player:getFinalAttr("luck"),
        player:getKongfu()
    )

    -- print("-----------------------------------")
    -- Helper:print_lua_table(rewardArray)
    -- print("-----------------------------------")

    --@desc 存放各个主动需获取到的特殊奖励物品，例如：失窃的包裹,虎威山寨宝箱...
    local estRewardList = {
        ["属性"] = {},
        ["物品"] = {}
    }

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

    return estRewardList
end

--@desc: 获取完成速率
--@author:Liang SongQiang
--@time:2018-06-02 15:01:50
--@role:[src.app.models.role.Role#Role]
--@taskId: 任务ID
function DispatchTaskUtils:getFinishSpeed(role, taskId)
    --[[
        延迟完成概率 = 250/(忠诚度+999) + 25/(门客武功值-任务武功值+100)
        正常完成概率 = 0.5 
        加速完成概率 = 0.5 - 延迟完成概率
    ]]
    local dispatchTask = self:getTaskById(taskId)

    local k1 = role:getKongfu()
    local k2 = dispatchTask.gongfu
    local z = role.defaultZhongCheng

    local speedState

    local speedRate = math.random(1, 100)
    local delayRate = (250/(z + 999) + 25 / (k1 - k2 + 100)) * 100
    local normalRate = 0.5 * 100
    local upRate = delayRate - normalRate

    local s1 = normalRate
    local s2 = normalRate + delayRate
    local s3 = 100

    if speedRate > 0 and speedRate <= s1 then
        --@desc 正常
        speedState = 0
    elseif speedRate > s1 and speedRate <= s2 then
        --@desc 延迟
        speedState = 1
    elseif speedRate > s2 and speedRate <= s3 then
        --@desc 加速
        speedState = 2
    end

    return speedState
end

--@desc: 获取任务能否完成的概率
--@author:Liang SongQiang
--@time:2018-06-02 14:55:48
--@role:[src.app.models.role.Role#Role]
--@taskId: 任务ID
function DispatchTaskUtils:getSuccessRate(role, taskId)
    --[[
        任务成功率
        (门客武功值-任务武功值)>100，则等于1.
        (门客武功值-任务武功值)<=0，则等于0。
        其他情况=(门客武功值-任务武功值)/100
    ]]
    local dispatchTask = self:getTaskById(taskId)

    local f = role:getKongfu() - dispatchTask.gongfu

    if f > 100 then
        return 1
    end

    if f <= 0 then
        return 0
    end

    local rate

    rate = f / 100

    return rate
end

--@desc: 创建NPC模板
--@author:Liang SongQiang
--@time:2018-06-02 14:22:47
--@npcId:派遣的NPC ID
function DispatchTaskUtils:initZhiTiaoTemplate(npc)
    local zhitiao = {
        type = "item",
        subType = "item",
        id = "zt_" .. npc.id,
        npcId = npc.id,
        npcName = npc.name,
        name = "纸条",
        dsc = "这是一张纸条，依稀写着一些字句。",
        canSee = true, -- 可见
        canPickUp = false, -- 拾取
        canUse = false, -- 使用
        canExtract = false, -- 提取
        canOpen = false, -- 打开
        canPushIn = false, -- 能放入
        canUse1 = 1,
        useName1 = "查看",
        canUse2 = 1,
        useName2 = "飞鸽传书",
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
                        arg1 = "派遣任务进度"
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
                        arg1 = "飞鸽传书"
                    }
                }
            }
        }
    }

    return zhitiao
end

--@desc:生成字条
--@author:Liang SongQiang
--@time:2018-06-02 12:29:15
--@map:[src.app.models.map.BaseMap#BaseMap]
--@npcId: 派遣的NPC ID
function DispatchTaskUtils:createZhiTiao(map, npcId)
    local npc = map:getRole(npcId)

    local roomId = npc.fjId

    if not roomId then
        assert(false, "npc 属性没有房间ID，请检查代码，npcId为" .. npcId)
    end

    local template = self:initZhiTiaoTemplate(npc)

    map:createRole(template)
    map:addRoomRole(roomId, template.id)

    --设置房间能否拆除和改造状态
    local HomelandRoomUtil = require("app.models.HomelandModel.HomelandRoomUtil")
    HomelandRoomUtil:setRoomCanChangStatus(map,roomId,1)

    if map:checkRoleIsInRoom(roomId, npc.id) then
        map:removeRoomRole(roomId, npc.id)
    end
end

--@desc:删除纸条
--@author:Liang SongQiang
--@time:2018-06-04 14:52:19
--@map:[src.app.models.map.BaseMap#BaseMap]
--@npcId: npcId
function DispatchTaskUtils:deleteZhiTiao(map, npcId)
    local npc = map:getRole(npcId)

    local roomId = npc.fjId

    local ztId = "zt_" .. npcId
    if map:checkRoleIsInRoom(roomId, ztId) then
        map:removeRoomRole(roomId, ztId)
        map.roles[ztId] = nil
    end
end

--@desc:领取奖励后删除包裹
--@author:Liang SongQiang
--@time:2018-06-04 15:35:47
--@map:[src.app.models.map.BaseMap#BaseMap]
--@npcId: npcId
function DispatchTaskUtils:deleteRewardPackage(map, npcId)
    -- local npc = map:getRole(npcId)

    local roomId = map:getCurrRoomId()

    -- if npc then
    --     roomId = npc.fjId
    -- else
    --     roomId = map:getCurrRoomId()
    -- end

    local rpId = "reward_package_" .. npcId
    if map:checkRoleIsInRoom(roomId, rpId) then
        map:removeRoomRole(roomId, rpId)
        map.roles[rpId] = nil

        --设置房间能否拆除和改造状态
        local HomelandRoomUtil = require("app.models.HomelandModel.HomelandRoomUtil")
        HomelandRoomUtil:setRoomCanChangStatus(map,roomId,nil)
    end

    -- --设置地图状态事件
    map:deleteOneMapLock("dispatch"..npcId)
end

--@desc: 创建包裹模板
--@author:Liang SongQiang
--@time:2018-06-05 10:24:21
function DispatchTaskUtils:initReawdPackageTemplate(npcId)
    local package = {
        type = "item",
        subType = "item",
        id = "reward_package_" .. npcId,
        name = "包裹",
        dsc = "这是一个包裹，是门客出门一趟带回来的。",
        canSee = true, -- 可见
        canPickUp = false, -- 拾取
        canUse = false, -- 使用
        canExtract = false, -- 提取
        canOpen = false, -- 打开
        canPushIn = false, -- 能放入
        canUse1 = 1,
        useName1 = "领取",
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
                        arg1 = "派遣奖励"
                    }
                }
            }
        }
    }

    return package
end

--@desc:生成奖励包裹
--@author:Liang SongQiang
--@time:2018-06-05 10:24:07
function DispatchTaskUtils:createReawdPackage(map, npcId,roomId)
    local template = self:initReawdPackageTemplate(npcId,roomId)

    if not roomId then
        assert(false, "没有房间ID，请检查代码 " .. npcId)
    end

    map:createRole(template)

    map:addRoomRole(roomId, template.id)

    --设置房间能否拆除和改造状态
    local HomelandRoomUtil = require("app.models.HomelandModel.HomelandRoomUtil")
    HomelandRoomUtil:setRoomCanChangStatus(map,roomId,1)
end

--@desc:领取奖励后把NPC重新加入房间
--@author:Liang SongQiang
--@time:2018-06-05 10:23:42
function DispatchTaskUtils:restorationNpc(map, npcId)
    local npc = map:getRole(npcId)

    local roomId = npc.fjId

    if not map:checkRoleIsInRoom(roomId, npcId) then
        map:addRoomRole(roomId, npc.id)
    end
end

--@desc: 将人物存档中的奖励格式转换成包裹领取奖励的格式
--@author:Liang SongQiang
--@time:2019-01-17 16:47:04
--@dReward: 人物存档中的奖励格式
function DispatchTaskUtils:createReward(dReward)
    local role = User:getRole()

    local rewards = {}

    local taskId = dReward.taskId

    local itemsList = dReward.reward["物品"]
    if not MapIsEmpty(itemsList) then
        for itemId, count in pairs(itemsList) do
            table.insert(
                rewards,
                {
                    name = itemId,
                    value = count,
                    type = "物品"
                }
            )
        end
    end

    local attrList = dReward.reward["属性"]
    if not MapIsEmpty(attrList) then
        for attr_name, attr_value in pairs(attrList) do
            table.insert(
                rewards,
                {
                    name = attr_name,
                    value = attr_value,
                    type = "属性"
                }
            )
        end
    end

    --@desc 活动类奖励
    local activity_rewards = dReward.reward["activity"]
    if not MapIsEmpty(activity_rewards) then
        for _, reward in ipairs(activity_rewards) do
            table.insert(rewards, reward)
        end
    end

    return rewards
end


--@desc: 领取奖励
--@author:Liang SongQiang
--@time:2018-06-05 10:25:36
function DispatchTaskUtils:getReward(dReward)
    --@RefType [src.app.models.role.Role#Role]
    local role = User:getRole()
    local ret, msg = true, ""

    local rewards = self:createReward(dReward)

    do
        --@desc 检查背包是否已满
        local checkList = {}
        for _,reward in ipairs(rewards) do
            if reward.type == "物品" then
                if checkList[reward.name] == nil then
                    checkList[reward.name] = reward.value
                else
                    checkList[reward.name] = checkList[reward.name] + reward.value
                end
            end
        end
        if MapIsEmpty(checkList) == false then
            if not role:checkCanBuyTwoOrMoreThings(checkList,false) then
                ret = false
                msg = "您的背包空间不足，无法打开包裹。"
                return ret,msg
            end
        end
    end

	local taskId = dReward.taskId

    local day_reward_map = dReward.reward["day"]

    if MapIsEmpty(day_reward_map) == false then
		local yinpiao_reward_list= day_reward_map["yinpiao"]
		if not MapIsEmpty(yinpiao_reward_list) then
			local add_value = 0
			for i,reward in ipairs(yinpiao_reward_list) do
				add_value = add_value + Helper:getDef(reward.t_value,0)
			end

			HttpManagerEx:updateCurrencyByType("add","yinpiao",add_value,taskId, function(status, errcode, errmsg, data)
				if status == 200 then
					if errcode == 0 then
						PopText("银票".."+"..tostring(add_value))
					elseif errcode == 2 then
						--@银票已经领取,不打断流程
					else
						ret = false
						msg = errmsg
					end
				else
					ret = false
					msg = errmsg
				end
			end, IS_SHOW_WAITING)
		end
    end
	
	if ret == true then
		if MapIsEmpty(day_reward_map) == false then
			for _type,reward_list in pairs(day_reward_map) do
				switch(_type,{
					["pijuan"] = function ()
						local add_value = 0
						for i,reward in ipairs(reward_list) do
							add_value = add_value + Helper:getDef(reward.t_value,0)
						end
						role:addAttr("pijuan",add_value)
					end,
				})
			end
		end
		
		for _,reward in ipairs(rewards) do
			if reward.type == "属性" then
				role:addAttr(reward.name, reward.value)
				PopText(role:getCHAttrName(reward.name) .. " + " .. reward.value)
			elseif reward.type == "物品" then
				role:addItemCount(reward.name, reward.value)
				local item = Item:getOneItemByKey(reward.name)
				PopText("你获得了" .. item.name .. " X" .. reward.value)
	
				if reward.flagName ~= nil then
					role:setDayFlag(reward.flagName,role:getDayFlag(reward.flagName) + reward.flagValue)
				end
	
				if reward.dayFlagName ~= nil then
					role:setDayFlag(reward.dayFlagName,role:getDayFlag(reward.dayFlagName) + reward.dayFlagValue)
				end
	
				if reward.inheritFlag ~= nil then
					role:setInheritFlag(reward.inheritFlag,role:getInheritFlag(reward.inheritFlag) + reward.inheritFlagValue)
				end
			end
		end
	end

    return ret,msg
end

--@desc: 派遣完成主动任务时更新主动任务历练任务的奖励物品数量
--@author:Liang SongQiang
--@time:2018-06-12 22:12:11
--@taskId: 任务Id
function DispatchTaskUtils:updateActivityTaskRewardsCount(taskId, roleTask)
    if not activityTaskRelations[taskId] then
        return
    end
    
    local startTime = roleTask.startTime

    local nowTime = GetTime()
    if Helper:diffWithDate(nowTime, startTime) > 0 then
        return
    end

    --@RefType [src.app.models.role.Role#Role]
    local role = User:getRole()
    local taskRelation = activityTaskRelations[taskId]
    if taskRelation.specialReward and taskRelation.specialReward._flag and roleTask.reward.isSp == 1 then
        local tempCount = 0
        local taskItems = self:getActivityTaskSpecialItems(taskId, taskRelation.specialReward, LiLianTaskHelper:getRoleTaskConfigVersion(roleTask))
        for k, v in pairs(taskItems) do
            tempCount = tempCount + 1
        end
        role:setDayFlag(taskRelation.specialReward._flag, tempCount)
    end

    if not MapIsEmpty(roleTask.reward.day) then
        local day_reward_map = roleTask.reward.day
        for _type,day_reward in pairs(day_reward_map) do
            for i,reward in ipairs(day_reward) do
                local today_count = role:getDayFlag(reward.flag)

                -- print("更新主动任务 ："..taskId.." 每日奖励次数",today_count,reward.count)

                role:setDayFlag(reward.flag,today_count + reward.count)
            end
        end
    end
end

--@desc 获取特性标记名字。
function DispatchTaskUtils:getTaskTraitBufferName(taskId)
    local buffName
    if activityTaskRelations[taskId] then
        buffName = activityTaskRelations[taskId].traitBufferName
    end
    
    return buffName
end

--@desc 清除门客生成的派遣任务列表
function DispatchTaskUtils:clearNpcDispatchTaskList(npcId)
    local player = User:getRole()
    local roleDispatchTask = player:getAttr("DispatchTask")

    if roleDispatchTask.npcTaskList == nil then
        return
    end

    local npcTaskList = roleDispatchTask.npcTaskList
    if npcTaskList[npcId] then
        npcTaskList[npcId] = nil
    end
end

return DispatchTaskUtils
000000000000000