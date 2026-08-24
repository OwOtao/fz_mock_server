local DispatchTaskManager = {}

--@RefType [src.app.models.HomelandModel.DispatchTaskModel.DispatchTaskUtils#DispatchTaskUtils]
local DispatchTaskUtils = require("app.models.HomelandModel.DispatchTaskModel.DispatchTaskUtils")

--@RefType [src.app.models.HomelandModel.HomelandRoleUtil#HomelandRoleUtil]
local HomelandRoleUtil = require("app.models.HomelandModel.HomelandRoleUtil")

--@desc: 获取NPC能够派遣的任务。
--@author:Liang SongQiang
--@time:2018-05-02 16:59:13
--@npc: [src.app.models.role.Role#Role]
function DispatchTaskManager:getCanDispatchTaskList(npc)
    local totalTaskList = DispatchTaskUtils:getDispatchTaskList()

    --@desc 符合执行的任务列表
    local canTaskList = {}

    local function checkCanTask(task)
        if task.open == 0 then
            return false
        end

        
        --@RefType [src.app.models.role.Role#Role]
        local player = User:getRole()
        local roleKongfu = npc:getKongfu()
        
        local roleTask = DispatchTaskUtils:getDispatchTaskRelationRoleTask(task.taskid)
        
        local needCompletedMapId = DispatchTaskUtils:getActivityTaskJindu(task.taskid)

        if needCompletedMapId ~= 0 then
            print("========================="..task.taskid.."=======================")
            print("------------- 人物需要完成的副本："..needCompletedMapId,player:isMapCompleted(needCompletedMapId),"任务需求完成副本：",needCompletedMapId)
            print("------------- 状态：",roleTask.state)
            print("------------- 人物功夫值：",roleKongfu,"任务功夫值",task.gongfu)
            print("================================================================\n")
        end

        if roleTask.state ~= TASK_STATE_IDLE then
            return false
        end
        
        if roleKongfu < task.gongfu then
            return false
        end

        if needCompletedMapId ~= 0 and player:isMapCompleted(needCompletedMapId) ~= true then
            return false
        end
        
        return true
    end

    for k, task in pairs(totalTaskList) do
        if checkCanTask(task) then
            table.insert(canTaskList, task)
        end
    end

    return canTaskList
end

--@desc: 获取最后随机的的三个任务列表
--@author:Liang SongQiang
--@time:2018-05-03 09:58:31
--@role: [src.app.models.role.Role#Role]
function DispatchTaskManager:getDoDispatchTaskList(npc)
    local nowTime = GetTime()

    --@RefType [src.app.models.role.Role#Role]
    local player = User:getRole()
    local roleDispatchTask = player:getAttr("DispatchTask")

    if roleDispatchTask.npcTaskList == nil then
        roleDispatchTask.npcTaskList = {}
    end

    local npcTaskList = roleDispatchTask.npcTaskList
    local resultList = {}

    if not MapIsEmpty(npcTaskList) and npcTaskList[npc.id] then
        local taskCache = npcTaskList[npc.id]

        if Helper:diffWithDate(nowTime, taskCache.createTime) == 0 then
            for i = 1, 3 do
                if taskCache["task" .. i] then
                    local task = DispatchTaskUtils:getTaskById(taskCache["task" .. i])
                    table.insert(resultList, task)
                end
            end
            return resultList
        end
    end

    local canTaskList = self:getCanDispatchTaskList(npc)

    local num = 0
    if #canTaskList > 3 then
        num = 3
    else
        num = #canTaskList
    end

    for i = 1, num do
        local taskIndex = Helper:RandomByWeight(canTaskList, "taskweight")
        if not npcTaskList[npc.id] then
            npcTaskList[npc.id] = {}
        end

        npcTaskList[npc.id]["task" .. i] = canTaskList[taskIndex].taskid

        table.insert(resultList, canTaskList[taskIndex])
        table.remove(canTaskList, taskIndex)
    end
    npcTaskList[npc.id].createTime = nowTime

    if PRINT_MODE == 1 then
        print("================随机获得的任务列表===================")
        Helper:print_lua_table(resultList)
        print("===================================\n")
    end

    return resultList
end

--@desc:判断该任务是否能够派遣
--@author:Liang SongQiang
--@time:2018-06-04 16:13:24
--@map: [src.app.models.map.BaseMap#BaseMap]
--@taskId: 派遣任务ID
--@npc: 要派遣的NPC
function DispatchTaskManager:checkCanDoTaskById(map, taskId, npc)
    local msg = ""

    local roleTask = DispatchTaskUtils:getDispatchTaskRelationRoleTask(taskId)

    if roleTask.state == TASK_STATE_DISPATCH then
        msg = "该任务正在派遣中。"
        return false, msg
    end

    if roleTask.state == TASK_STATE_ACCEPT then
        msg = "你已接取了该任务，无法派遣。"
        return false, msg
    end

    if roleTask.state == TASK_STATE_TO_SUBMIT then
        msg = "该主动任务你还有奖励未领取，无法派遣。"
        return false, msg
    end

    local dCount = self:getDayFinishTaskCountById(taskId)
    if dCount >= roleTask.cCount then
        msg = "该任务今日已达到完成次数。"
        return false, msg
    end

    local roomId = npc.fjId

    if map:checkRoleIsInRoom(roomId, "reward_package_" .. npc.id) then
        msg = "上次派遣的包裹还未领取。"
        return false, msg
    end

    return true
end

--@desc: 获得预计次数
--@author:Liang SongQiang
--@time:2018-05-03 09:51:37
--@role:[src.app.models.role.Role#Role]
--@taskId: 任务ID
function DispatchTaskManager:getEstFinishCount(role, taskId)
    local dispatchTask = DispatchTaskUtils:getTaskById(taskId)
    local dayCount = self:getDayFinishTaskCountById(taskId)
    print(role:getKongfu(),dispatchTask.gongfu)

    local lv = HomelandRoleUtil:getFidelityLv(role:getAttr("defaultZhongCheng"))

    local factor = (2*role:getKongfu()-dispatchTask.gongfu+800)/(dispatchTask.gongfu+200)*(lv+1)/8

    local estCount = math.floor(dispatchTask.tasktime * factor)

    if dispatchTask.tasktime - dayCount < estCount then
        estCount = dispatchTask.tasktime - dayCount
    end

    return math.max(estCount, 1)
end

--@desc: 计算预计完成时间
--@author:Liang SongQiang
--@time:2018-05-02 17:12:22
--@role:[src.app.models.role.Role#Role]
--@taskId: 任务ID
function DispatchTaskManager:getEstTime(role, taskId, estCount)
    local dispatchTask = DispatchTaskUtils:getTaskById(taskId)

    local lv = HomelandRoleUtil:getFidelityLv(role:getAttr("defaultZhongCheng"))

    -- (dispatchTask.gongfu+200)/(role:getKongfu()+200)*18000/(lv+8)

    --[[
        if 时间参数 < 600 then	
            时间参数 = 600;
        end	
        if 时间参数 > 2000 then	
            时间参数 = 2000;
        end	

        *预计完成时间 = 时间参数 * 基本完成时间 * 预计完成次数/1000*
    ]]
    local factor = (dispatchTask.gongfu+200)/(role:getKongfu()+200)*18000/(lv+8)

    if factor < 600 then
        factor = 600
    elseif factor > 2000 then
        factor = 2000
    end

    local buffName = DispatchTaskUtils:getTaskTraitBufferName(taskId)

    --@desc 特性加成,降低任务完成时间。
    local traitFactor = 0
    if buffName ~= nil then
        traitFactor = role:getBuffAttr(buffName)
        traitFactor = Helper:getRange(traitFactor,0,1)
    end
    
    local time = estCount / 1000 * dispatchTask.finishtime * factor

    local minTime = (estCount * dispatchTask.finishtime) * 0.7

    local maxTime = (estCount * dispatchTask.finishtime) * 1.2
    
    if DEBUG_MODE == 1 then
        print("预计完成时间 = ",time)
        print("最少时间 = ",minTime)
        print("最大时间 = ",maxTime)
    end
    
    if time < minTime then
        time = minTime
    end

    if time > maxTime then
        time = maxTime
    end

    time = time * (1 - traitFactor)

    return time
end

--@desc: 获得预计奖励
--@author:Liang SongQiang
--@time:2018-05-03 11:45:28
--@role:[src.app.models.role.Role#Role]
--@taskId: 派遣任务ID
function DispatchTaskManager:getEstReward(role, taskId, estCount, estTime)
    local dispatchTask = DispatchTaskUtils:getTaskById(taskId)

    local rewardList = {}
    if dispatchTask.tasktype == "主动任务" then
        rewardList = DispatchTaskUtils:getActivityTaskReward(role, taskId, estCount, estTime)
    elseif dispatchTask.tasktype == "其他任务" then
        rewardList = DispatchTaskUtils:getNormalTaskReward(role, taskId)
    end

    return rewardList
end

--@desc: 生成派遣任务的数据结构
--@author:Liang SongQiang
--@time:2018-05-04 17:16:42
--@role:[src.app.models.role.Role#Role]
--@taskId: 任务ID
function DispatchTaskManager:initTaskData(role, taskId)
    local structure = {}

    structure.npcId = role.id

    structure.taskId = taskId

    structure.count = self:getEstFinishCount(role, taskId)

    structure.estFinishTime = self:getEstTime(role, taskId, structure.count)

    structure.reward = self:getEstReward(role, taskId, structure.count, structure.estFinishTime)

    structure.tasktype = DispatchTaskUtils:getTaskById(taskId).tasktype

    structure.successRate = DispatchTaskUtils:getSuccessRate(role, taskId)

    structure.speedState = DispatchTaskUtils:getFinishSpeed(role, taskId)

    return structure
end

--@desc: 派遣任务
--@author:Liang SongQiang
--@time:2018-05-02 17:01:29
--@taskId: 派遣的任务ID
--@map: [src.app.models.map.BaseMap#BaseMap]
function DispatchTaskManager:dispatchTask(data, map)
    local nowTime = GetTime()
    data.startTime = nowTime

    local result_finishTime = 0
    if data.speedState == 0 then
        result_finishTime = data.estFinishTime
    elseif data.speedState == 1 then
        result_finishTime = data.estFinishTime * (math.random(110, 130) / 100)
    elseif data.speedState == 2 then
        result_finishTime = data.estFinishTime * (math.random(70, 90) / 100)
    end
    data.endTime = nowTime + result_finishTime
    print("===================== normalTime",nowTime, data.estFinishTime, data.endTime)

    --@RefType [src.app.models.role.Role#Role]
    local player = User:getRole()

    local mid = player:getHouseId()
    local uploadData = {
        {
            rwId = data.npcId,
            extra = {
                stay_room_time = data.endTime
            }
        }
    }

    local function add_daily_point()
        local DailyTasksActivity = require("app.models.Action.DailyTasksActivity")
		DailyTasksActivity:addDailyTaskPoint("paiqian")
    end

    HttpManagerEx:updateEmployeeExtra(
        mid,
        uploadData,
        function(status, errcode, errmsg, data1)
            if status == 200 then
                if errcode == 0 then

                    local roleTask = DispatchTaskUtils:getDispatchTaskRelationRoleTask(data.taskId)

                    roleTask.state = TASK_STATE_DISPATCH
                
                    local todayCount = self:getDayFinishTaskCountById(data.taskId)

                    local npc = map:getRole(data.npcId)
                    local roomId = npc.fjId
                
                    --@desc 派遣时需把人物当天次数加上
                    roleTask.dCount = todayCount + data.count
                    roleTask.startTime = data.startTime
                    roleTask.endTime = data.endTime
                    roleTask.estCount = data.count
                    roleTask.estFinishTime = data.estFinishTime
                    roleTask.reward = data.reward
                    roleTask.npcId = data.npcId
                    roleTask.speedState = data.speedState
                    --@desc 派遣时所在的房间
                    roleTask.roomId = roomId
                
                    --@desc 锁门
                    map:lockRoom(roomId,"您有派遣任务未完成或者有奖励未领取，无法进行")


                    --@RefType [src.app.models.HomelandModel.HomelandDesc#HomelandDesc]
                    local HomelandDesc = require("app.models.HomelandModel.HomelandDesc")
                
                    local textArr = HomelandDesc:getStartDispatchTaskDesc(data.taskId,map,data.npcId,data.successRate)
                
                    PopupLayerController:showLayer("GlobalShadeLayer",function (layer)
                        layer:showLayer()
                        layer:setPopText("请专心眼前之事")
                    end)

                    add_daily_point()

                    local count = 1
                    map:setSchedule(function ()
                        print("-------------------",count)
                        RichPrint("main",textArr[count])

                        if count == 3 then
                            if map:checkRoleIsInRoom(roomId, npc.id) then
                                map:removeRoomRole(roomId, npc.id)
                                map.__MapLayer:delayRefreshMap()
                            end
                        end

                        if count == #textArr then
                            --@desc 生成纸条
                            self:createZhiTiao(map, data.npcId)
                            map.__MapLayer:refreshMap()
                            PopupLayerController:hideLayer("GlobalShadeLayer",function (layer)
                                layer:hideLayer()
                            end)
                        end
                        count = count + 1
                    end,2,0,#textArr)

                    return true
                else
                    print(errmsg,errcode)
                    return false
                end
            else
                print(errmsg,errcode)
                return false
            end
        end,
        IS_SHOW_WAITING,
        HTTP_MANAGER_RETRY_TYPE_RETRY
    )

    return true
end

--@desc: 根据NPC Id查看任务进度
--@author:Liang SongQiang
--@time:2018-05-02 17:04:12
--@taskId:任务ID
function DispatchTaskManager:getDispatchTaskProgressByTaskId(npcId)
    --@RefType [src.app.models.role.Role#Role]
    local player = User:getRole()

    local tasks = player:getAttr("tasks")

    local percent = 0
    for taskId, task in pairs(tasks) do
        if task.state == TASK_STATE_DISPATCH and task.npcId == npcId then
            --事件进度=（当前时间-任务开始时间）/实际任务时间
            local k1 = GetTime() - task.startTime
            local k2 = task.endTime - task.startTime
            print("已经执行时间：", k1)
            print("完成任务需要时间：", k2)
            percent = (k1 / k2) * 100

            print("完成进度：", percent)
            return percent, taskId, task.speedState, task.startTime,task.endTime
        end
    end

    return percent
end

--@desc: 获取当天任务已完成的次数
--@author:Liang SongQiang
--@time:2018-05-02 21:03:09
--@taskId:派遣任务ID
--@return 此任务今天已完成的次数
function DispatchTaskManager:getDayFinishTaskCountById(taskId)
    local dispatchTask = DispatchTaskUtils:getTaskById(taskId)

    local roleTask = DispatchTaskUtils:getDispatchTaskRelationRoleTask(taskId)

    roleTask.startTime = Helper:getDef(roleTask.startTime, 0)

    if Helper:diffWithDate(GetTime(), roleTask.startTime) > 0 then
        roleTask.dCount = 0
    end

    print("DispatchTaskManager:getDayFinishTaskCountById ", taskId, roleTask.dCount)

    return Helper:getDef(roleTask.dCount, 0)
end

--@desc: 检查派遣任务是否完成
--@author:Liang SongQiang
--@time:2018-05-31 22:17:38
function DispatchTaskManager:checkTaskFinish(map)
    --@RefType [src.app.models.role.Role#Role]
    local player = User:getRole()

    local tasks = player:getAttr("tasks")

    for taskId, task in pairs(tasks) do
        if task.state == TASK_STATE_DISPATCH then
            if DEBUG_MODE == 1 then
            	if not task.reward then
                	assert(false, "DispatchTaskManager:finishTask 人物存档出错，派遣任务没有奖励")
            	end

            	if not task.estCount then
                	assert(false, "DispatchTaskManager:finishTask 人物存档出错，派遣任务没有预计次数")
            	end
            end

            --@desc 判断是否完成 task.endTime初始化为0，所以需要判断
            local nowTime = GetTime()
            if task.endTime ~= 0 and task.endTime <= nowTime then
                local npcId = task.npcId
                local roomId = task.roomId

                --@desc 任务完成，解除房间锁定
                map:unlockRoom(roomId)

                --设置地图状态锁
                map:addMapLock("dispatch"..npcId,"您有派遣任务未完成或者有奖励未领取，无法进行")

                --@desc 如果成功完成，则生成奖励包裹
                self:finishTask(taskId, task)
                self:createRewardPackage(map,npcId,roomId)
                DispatchTaskUtils:deleteZhiTiao(map, npcId)
                DispatchTaskUtils:restorationNpc(map, npcId)
                map.__MapLayer:delayRefreshMap()
            end
        end
    end
end

--@desc: 进入副本时检查是否需要上锁房间
--@author:Liang SongQiang
--@time:2018-09-27 10:40:01
--@map: [src.app.models.map.BaseMap#BaseMap]
function DispatchTaskManager:checkNeedLockRoom(map)
    --@RefType [src.app.models.role.Role#Role]
    local role = User:getRole()

    local tasks = role:getAttr("tasks")
    
    if MapIsEmpty(tasks) then
        return
    end
    
   
    for taskId,task in pairs(tasks) do
        if task.state == TASK_STATE_DISPATCH then
            local roomId = task.roomId
            local room = map:getRoomById(roomId)
            if room.lock ~= true then
                map:lockRoom(roomId,"您有派遣任务未完成或者有奖励未领取，无法进行")
            end
        end
    end
end

--@desc 检查是否有任务正在派遣中
function DispatchTaskManager:checkHasDispatchTask()
    local isDispatchTask = false
    --@RefType [src.app.models.role.Role#Role]
    local role = User:getRole()

    local tasks = role:getAttr("tasks")

    for taskId, task in pairs(tasks) do
        if task.state == TASK_STATE_DISPATCH then
            isDispatchTask = true
            break
        end
    end

    return isDispatchTask
end

--@desc 检查派遣任务是否有奖励未领取
function DispatchTaskManager:checkHasReward()
    --@RefType [src.app.models.role.Role#Role]
    local role = User:getRole()

    local dispatchTaskRewards = role:getAttr("DispatchTask").taskReward

    if not dispatchTaskRewards or MapIsEmpty(dispatchTaskRewards) then
        print("没有派遣奖励需要领取。")
        return false
    end

    return true
end



--@desc: 完成任务
--@author:Liang SongQiang
--@time:2018-05-03 15:42:06
function DispatchTaskManager:finishTask(taskId, task)
    --@RefType [src.app.models.role.Role#Role]
    local player = User:getRole()

    local result = false

    -- --@desc 如果失败了，那么需要判断是否此时登录是否已经过了一天，如果没有，那么需要把失败后预计完成的次数返回。
    -- if task.isSuccess == 0 then
    --     local nowTime = GetTime()
    --     if Helper:diffWithDate(nowTime, task.startTime) == 0 then
    --         task.dCount = task.dCount - task.estCount
    --     end
    -- elseif task.isSuccess == 1 then
    -- end
    local roleDispatchTask = player:getAttr("DispatchTask")

    local taskReward = Helper:getDef(roleDispatchTask.taskReward, {})

    local t_id = taskId
    if Helper:diffWithDate(task.endTime,task.startTime) > 0  then
        t_id = taskId.."_y"
    end

    local t = {
        npcId = task.npcId,
        roomId = task.roomId,
        reward = task.reward,
        taskId = t_id
    }

    table.insert(taskReward, t)

    roleDispatchTask.taskReward = taskReward

    --@desc 记录总完成次数
    task.zCount = Helper:getDef(task.zCount, 0) + task.dCount

    DispatchTaskUtils:updateActivityTaskRewardsCount(taskId, task)

    --@desc 检查历练任务
    do
        local liLianTaskId = player:getFlag("历练")
        if liLianTaskId == taskId then
            local liLianTask = player:getTask("task15")

            local liLianTaskCount = player:getFlag("历练随机任务已完成次数")
            local liLianTaskNeedCount = player:getFlag(liLianTaskId)

            if liLianTaskCount < liLianTaskNeedCount then
                liLianTaskCount = math.min(liLianTaskCount + task.estCount, liLianTaskNeedCount)
                player:setFlag("历练随机任务已完成次数", liLianTaskCount)

                if liLianTaskCount >= liLianTaskNeedCount then
                    liLianTask.state = TASK_STATE_TO_SUBMIT
                    player:setFlag("历练", "nil")
                    player:setFlag("历练随机任务名", "")
                    player:setFlag("历练随机任务已完成次数", 0)
                    player:setFlag(User:getRole():getFlag("历练"), 0)
                end
            end

            if PRINT_MODE == 1 then
                -- 历练任务完成次数
                print(User:getRole():getFlag("历练随机任务已完成次数"))
                print(User:getRole():getFlag("历练随机任务名"))
                -- 任务ID
                print(User:getRole():getFlag("历练"))

                -- 历练任务需要完成的次数
                print(User:getRole():getFlag(liLianTaskId))
            end
        end
    end

    result = true

    --@RefType 完成任务时需判断当天次数是否清空，派遣任务按照开始派遣的时间算。
    if Helper:diffWithDate(task.endTime,task.startTime) > 0  then
        task.dCount = 0
    end

    self:resetTask(task)

    return result
end

--@desc: 重置任务
--@author:Liang SongQiang
--@time:2018-11-07 11:32:02
function DispatchTaskManager:resetTask(task)
    --@desc 恢复任务数据
    task.state = TASK_STATE_IDLE
    task.estCount = nil
    task.roomId = nil
    task.npcId = nil
    task.reward = nil
    task.speedState = nil
    task.isSuccess = nil
    task.estFinishTime = nil
end

--@desc: 修复回档造成服务器数据不同步的情况
--@author:Liang SongQiang
--@time:2018-11-07 12:02:27
function DispatchTaskManager:repairTaskDataNpcIsNull(map,task)

    --@RefType [src.app.models.role.Role#Role]
    local player = User:getRole()
    
    local disp = player:getAttr("DispatchTask")

    if MapIsEmpty(disp.npcTaskList) == false then
        if MapIsEmpty(disp.npcTaskList[task.npcId]) == false then
            disp.npcTaskList[task.npcId] = nil
        end
    end

    task.dCount = math.max(task.dCount - task.estCount,0)

    self:resetTask(task)
end

--@desc: 获取派遣任务名字
--@author:Liang SongQiang
--@time:2018-05-29 15:36:53
--@taskId:任务ID
function DispatchTaskManager:getDispatchTaskName(taskId)
    local task = DispatchTaskUtils:getTaskById(taskId)
    return task.taskname
end

--@desc: 生成包裹奖励
--@author:Liang SongQiang
--@time:2018-06-02 16:17:46
function DispatchTaskManager:createRewardPackage(map,npcId,roomId)
    --@RefType [src.app.models.role.Role#Role]
    local player = User:getRole()

    local fq = player:getHomelandAttr("fq")

    -- --@desc 如果不是自己的副本，不用考虑包裹的生成
    if map:getMapType() ~= MAP_TYPE.MYHOME then
        return
    end

    DispatchTaskUtils:createReawdPackage(map, npcId,roomId)
end

function DispatchTaskManager:createZhiTiao(map, npcId)
    --@RefType [src.app.models.role.Role#Role]
    local player = User:getRole()

    local fq = player:getHomelandAttr("fq")

    -- --@desc 如果不是自己的副本，不用考虑包裹的生成
    if map.mid == nil or tonumber(map.mid) ~= tonumber(fq.mid) then
        return
    end

    DispatchTaskUtils:createZhiTiao(map, npcId)
end

--@desc: 领取奖励
--@author:Liang SongQiang
--@time:2018-05-29 18:21:51
function DispatchTaskManager:getReward(map, npcId)
    --@RefType [src.app.models.role.Role#Role]
    local player = User:getRole()

    local dispatchTaskRewards = player:getAttr("DispatchTask").taskReward

    for i, dReward in ipairs(dispatchTaskRewards) do
        if npcId == dReward.npcId then
            local ret, msg = DispatchTaskUtils:getReward(dReward)

            if not ret then
                PopText(msg)
                return ret
            end

            DispatchTaskUtils:deleteRewardPackage(map, npcId)

            --设置房间能否拆除和改造状态
            local HomelandRoomUtil = require("app.models.HomelandModel.HomelandRoomUtil")
            -- local npc = map:getRole(npcId)
            local roomId = map:getCurrRoomId()
            HomelandRoomUtil:setRoomCanChangStatus(map,roomId,nil)
            table.remove(dispatchTaskRewards, i)

            map.__MapLayer:refreshMap()

            return ret
        end
    end

    return false
end

return DispatchTaskManager
000