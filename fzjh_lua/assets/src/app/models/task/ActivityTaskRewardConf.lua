local ActivityTaskRewardConf = {}

local config = {
    {
        --@desc 活动开始时间
        s_time = "20260420",
        --@desc 活动结束时间
        e_time = "20260427",
        tasks = {
            ["task16"] = {
                getReward = function(self, taskId,params)
                    if params.dCount >= 1 then
                        return
                    end

                    --@RefType [src.app.models.SpringFestival.2019.SFTokenCollection2019#SFTokenCollection2019]
                    local SFTokenCollection2019 = require("app.models.SpringFestival.2019.SFTokenCollection2019")
                    SFTokenCollection2019:initConfig()

                    local itemId = SFTokenCollection2019:randomToken()

                    local flagName = SFTokenCollection2019:getItemFlag(itemId)

                    return {
                        {
                            type = "物品",
                            name = itemId,
                            value = 1,
                            inheritFlag = flagName,
                            inheritFlagValue = 1
                        }
                    }
                end
            },
            ["task17"] = {
                getReward = function(self, taskId,params)
                    if params.dCount >= 1 then
                        return
                    end

                    --@RefType [src.app.models.SpringFestival.2019.SFTokenCollection2019#SFTokenCollection2019]
                    local SFTokenCollection2019 = require("app.models.SpringFestival.2019.SFTokenCollection2019")
                    SFTokenCollection2019:initConfig()
                    
                    local itemId = SFTokenCollection2019:randomToken()

                    local flagName = SFTokenCollection2019:getItemFlag(itemId)

                    return {
                        {
                            type = "物品",
                            name = itemId,
                            value = 1,
                            inheritFlag = flagName,
                            inheritFlagValue = 1
                        }
                    }
                end
            }
        }
    },
    {
        --@desc 活动开始时间
        s_time = "20250724",
        --@desc 活动结束时间
        e_time = "20250808",
        tasks = {
            ["task16"] = {
                getReward = function(self, taskId,params)
                    if params.dCount >= 3 then
                        return
                    end

                    return {
                        {
                            type = "物品",
                            name = "voteitem2",
                            value = 2,
                        }
                    }
                end
            },
            ["task17"] = {
                getReward = function(self, taskId,params)
                    if params.dCount >= 1 then
                        return
                    end

                    return {
                        {
                            type = "物品",
                            name = "voteitem2",
                            value = 2,
                        }
                    }
                end
            },
            ["task21"] = {
                getReward = function(self, taskId,params)
                    if params.dCount >= 1 then
                        return
                    end

                    return {
                        {
                            type = "物品",
                            name = "voteitem2",
                            value = 2,
                        }
                    }
                end
            }
        }
    }
}

--@desc: 获取主动任务活动期奖励
--@author:Liang SongQiang
--@time:2019-01-17 17:57:24
--@taskId: 任务ID
--@params: 自定义属性
function ActivityTaskRewardConf:getTaskLocalReward(taskId , params )
    local rewards = {}
    local now_time = GetTime()
    for _, activity in ipairs(config) do
        if activity.s_time == nil or activity.e_time == nil then
            assert(false, "改活动没有配置开始时间或结束时间。")
        end

        if DEBUG_MODE == 1 or
            (now_time >= Helper:getTimeStampWithStringDate(activity.s_time, 0) and
                now_time < Helper:getTimeStampWithStringDate(activity.e_time, 0))
         then
            local tasks = activity.tasks

            if tasks[taskId] then
                local activity_reward = tasks[taskId]:getReward(taskId,params)
                if MapIsEmpty(activity_reward) == false then
                    for _, v in ipairs(activity_reward) do
                        table.insert(rewards, v)
                    end
                end
            end
        end
    end

    return rewards
end

return ActivityTaskRewardConf
00000000000