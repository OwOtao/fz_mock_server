local ShenShiTask = {}

--@RefType [src.app.models.HomelandModel.MapMeetModel.MapMeetUtil#MapMeetUtil]
local MapMeetUtil = require("app.models.HomelandModel.MapMeetModel.MapMeetUtil")

local RoleLife = require("app.models.HomelandModel.RoleLife")

local ss_res = requireWithEncrypt("script.others.familyspecial")["Life"]

-- id = tostring(taskId),
-- locMark = "",
-- exTime = "",
-- maps = {fb10,fb20}
-- npcs = {
--     npcId = mapRoomId,
--     npcId2 = mapRoomId1,
--     npcId3 = mapRoomId2,
-- }

--@desc: 查看NPC的身世任务是否完成
--@author:Liang SongQiang
--@time:2018-08-01 23:15:27
function ShenShiTask:checkTaskIsFinish(npc)
    local status = self:getTaskStatus(npc)

    if tonumber(status) == 2 then
        return true
    end

    return false
end

--@desc:获取NPC的身世状态
--@author:Liang SongQiang
--@time:2018-08-01 23:16:04
function ShenShiTask:getTaskStatus(npc)
    -- 0 为未解锁，1 为已解锁，2为已接受，3为已完成

    if npc.extra == nil then
        print(npc.name, npc.id)
    end

    local status = npc.extra.shenshi_status or 0

    return status
end

--@desc: 开放身世任务
--@author:Liang SongQiang
--@time:2018-08-01 23:21:35
--@npc: [src.app.models.role.Role#Role]
function ShenShiTask:unlockTask(npc, map, isLvUp,traits)
    local update_data = {
        {
            rwId = npc.id,
            extra = {
                shenshi_status = 1
            }
        }
    }

    HttpManagerEx:updateEmployeeExtra(
        map.mid,
        update_data,
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    npc.extra.shenshi_status = 1

                    local HomelandRoleUtil = require("app.models.HomelandModel.HomelandRoleUtil")
                    if isLvUp == true then
                        HomelandRoleUtil:DeblockRoleTrait(npc, traits)
                    end
                    HomelandRoleUtil:updateRoleFunc(npc, map)

                    local HomelandDesc = require("app.models.HomelandModel.HomelandDesc")
                    local text = HomelandDesc:getChatByShenShiDesc(npc.shenShi, npc.name) or ""
                    RichPrint("main", text)
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

--@desc: 打开身世任务的
--@author:Liang SongQiang
--@time:2018-08-01 23:43:06
--@npc: [src.app.models.role.Role#Role]
function ShenShiTask:openTaskDialog(npc, map)
    local lifeId = npc.shenShi

    --@RefType [src.app.models.HomelandModel.HomelandDesc#HomelandDesc]
    local HomelandDesc = require("app.models.HomelandModel.HomelandDesc")
    local title = HomelandDesc:getShenShiTaskDialogTitle(lifeId, npc)

    local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
    --@RefType [src.app.views.layer.DialogLayer.DialogALayer#DialogALayer]
    local dialog = DialogALayer:getInstance()
    dialog:hide()
    dialog:show(title)
    dialog:setButton1(
        "同意",
        function()
            self:acceptTask(npc, map)
        end
    )
    dialog:setButton2(
        "拒绝",
        function()
        end
    )
    dialog:setWeChatVisible(false)
end

function ShenShiTask:acceptTask(npc, map)
    local role = User:getRole()
    local roleTask = role:getAttr("ssTask")

    if not MapIsEmpty(roleTask) then
        PopText("请先处理未完成的身世任务。")
        return
    end

    local lifeId = npc.shenShi

    --@RefType [src.app.models.HomelandModel.HomelandDesc#HomelandDesc]
    local HomelandDesc = require("app.models.HomelandModel.HomelandDesc")
    local title = HomelandDesc:getShenShiTaskDialogTitle(lifeId, npc)

    local update_data = {
        {
            rwId = npc.id,
            extra = {
                shenshi_status = 2
            }
        }
    }

    HttpManagerEx:updateEmployeeExtra(
        map.mid,
        update_data,
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    npc.extra.shenshi_status = 2

                    --@RefType [src.app.models.HomelandModel.HomelandRoleUtil#HomelandRoleUtil]
                    local HomelandRoleUtil = require("app.models.HomelandModel.HomelandRoleUtil")
                    HomelandRoleUtil:updateRoleFunc(npc, map)

                    local taskId = RoleLife:getLifeTaskId(lifeId)

                    self:createTask(taskId, npc)

                    local text = HomelandDesc:getAcceptTaskText(lifeId, npc.name)

                    RichPrint("main", text)
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

function ShenShiTask:createTask(taskId, npc)
    --@RefType [src.app.models.role.Role#Role]
    local role = User:getRole()

    local task = MapMeetUtil:getTaskById(taskId)

    local roleTask = {
        id = task.id,
        locMark = task.locMark,
        --@desc 仆人ID
        serId = npc.id,
        maps = {},
        npc = {}
    }
    local result_npc_list, map_list = self:createTaskMapNpcData(taskId)
    roleTask.maps = map_list
    roleTask.npc = result_npc_list

    if task.mark then
        role:setFlag(task.mark, 1)
    end

    role:setAttr("ssTask", roleTask)

    print("---------------创建身世任务-------------")
    Helper:print_lua_table(roleTask.npc)

    Helper:print_lua_table(roleTask.maps)
    print("--------------------------------------\n")
end

--@desc 身世任务的NPC数据生成。
function ShenShiTask:createTaskMapNpcData(taskId)
    local task = MapMeetUtil:getTaskById(taskId)
    local result_npc_list, map_list = {}, {}
    --[[
        因为接任务时是在家园中。需要从列表中查询出满足区域条件的副本。
    ]]
    if task.locMark == "同副本" then
        result_npc_list = MapMeetUtil:initNpcListBySameMap(taskId)
    elseif task.locMark == "不同副本" then
        result_npc_list = MapMeetUtil:initNpcListByDiffMap(taskId)
    end

    --@desc 添加涉及副本
    do
        local tempFbIndex = {}
        for npcId, roomId in pairs(result_npc_list) do
            local fbId = string.split(roomId, "_")[1]
            tempFbIndex[fbId] = true
        end

        for k, v in pairs(tempFbIndex) do
            table.insert(map_list, k)
        end
    end

    return result_npc_list, map_list
end

--@desc:身世
--@author:Liang SongQiang
--@time:2018-08-06 23:38:05
function ShenShiTask:createTaskInMap(map)
    --@RefType [src.app.models.role.Role#Role]
    local role = User:getRole()

    local shenShiTask = role:getAttr("ssTask")

    if not shenShiTask or MapIsEmpty(shenShiTask) then
        print("您没有身世任务。")
        return
    end

    MapMeetUtil:createTaskInMap(map, shenShiTask.id, shenShiTask.maps, shenShiTask.npc)
end

--@desc 完成身世任务
function ShenShiTask:clearTask()
    --@RefType [src.app.models.role.Role#Role]
    local role = User:getRole()

    local ssTask = role:getAttr("ssTask")

    if not ssTask or MapIsEmpty(ssTask) then
        return
    end

    local map_list = ssTask.maps

    if MapIsEmpty(map_list) then
        return
    end

    local npc_item_list = MapMeetUtil:getNpcOrItemIdByTask(ssTask.id)

    --@desc 遍历关联副本
    for i, mapId in ipairs(map_list) do
        local map = role:getMapById(mapId)
        MapMeetUtil:clearMapNpc(npc_item_list, map)
    end

    local task_res = MapMeetUtil:getTaskById(ssTask.id)

    local mark = task_res.mark
    if mark then
        role:setFlag(task_res.mark, nil)
    end

    role:setAttr("ssTask", nil)

    if PRINT_MODE == 1 then
        Helper:print_lua_table(role:getAttr("ssTask"))
        print("清除任务成功")
    end
    -- RichPrint("main", "偶遇任务删除成功。")
end


function ShenShiTask:checkCurrTaskNpc( npcId )
    --@RefType [src.app.models.role.Role#Role]
    local role = User:getRole()

    local shenShiTask = role:getAttr("ssTask")

    if MapIsEmpty(shenShiTask) then
        return false
    end

    if shenShiTask.serId == npcId then
        return true
    end

    return false
end

--@desc: 数据修复
--@author:Liang SongQiang
--@time:2018-08-07 24:00:19
--@map: [src.app.models.map.BaseMap#BaseMap]
function ShenShiTask:repairData(map)
    --@RefType [src.app.models.role.Role#Role]
    local role = User:getRole()

    local roleTask = role:getAttr("ssTask")


    local npcs = map:getRoles()

    --@desc 身世任务存在，对应id的仆人不存在的情况。
    if MapIsEmpty(roleTask) == false and npcs[roleTask.serId] == nil then
        self:clearTask()
        return
    end

    --@desc 避免回档后低概率出现的BUG。
    if MapIsEmpty(roleTask) == false and npcs[roleTask.serId] ~= nil then
        local status = self:getTaskStatus(npcs[roleTask.serId])

        if status == 0 then
            self:clearTask()
            return
        end
    end


    for npcId, npc in pairs(npcs) do
        if npc.type == "role" and npc.jobType ~= nil then
            local status = self:getTaskStatus(npc)
            if status == 2 then
                if not roleTask or MapIsEmpty(roleTask) then
                    local taskId = RoleLife:getLifeTaskId(npc.shenShi)
                    self:createTask(taskId, npc)
                    break
                end
            elseif status == 3 then
                if roleTask and not MapIsEmpty(roleTask) and roleTask.serId == npcId then
                    self:clearTask()
                    break
                end
            end
        end
    end
end

--@desc: 薪资减半
--@author:Liang SongQiang
--@time:2018-08-20 16:06:43
--@map: [src.app.models.map.BaseMap#BaseMap]
function ShenShiTask:rewardPayHalf(npc, s_callback, f_callback)
    local mid = User:getRole():getHouseId()
    HttpManagerEx:getShenShiReward(
        1,
        npc.id,
        mid,
        "",
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    if s_callback then
                        s_callback(data)
                    end
                else
                    if f_callback then
                        f_callback()
                    end
                    PopText(errmsg)
                end
            else
                if f_callback then
                    f_callback()
                end
                PopText(errmsg)
            end
        end,
        IS_SHOW_WAITING
    )
end

function ShenShiTask:rewardFreeDay( day,npc,s_callback, f_callback)
    local mid = User:getRole():getHouseId()
    HttpManagerEx:getShenShiReward(
        2,
        npc.id,
        mid,
        day,
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    if s_callback then
                        s_callback(data)
                    end
                else
                    if f_callback then
                        f_callback()
                    end
                    PopText(errmsg)
                end
            else
                if f_callback then
                    f_callback()
                end
                PopText(errmsg)
            end
        end,
        IS_SHOW_WAITING
    )
end



return ShenShiTask
000000