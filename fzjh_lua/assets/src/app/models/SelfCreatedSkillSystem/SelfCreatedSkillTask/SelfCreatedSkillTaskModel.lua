--[[
    该脚本为临时任务整理脚本，后续需与主动任务相关的东西进行整合，要删除。
    且该脚本只针对一个任务处理
]]
local SelfCreatedSkillTaskModel = {}

local TASK_ID = "task22"

local SHOW_DIGONG_FLAG = "digongguji"

function SelfCreatedSkillTaskModel:__getLocalRoleTaskInfo()
    local role = User:getRole()
    local roleTask = role:getTask(TASK_ID)

    if roleTask == nil then
        roleTask = {
            state = TASK_STATE_IDLE,
            startTime = 0,
            endTime = nil,
            dCount = 0,
            zCount = 0
        }
        role:setTask(TASK_ID, roleTask)
    end

    return roleTask
end

function SelfCreatedSkillTaskModel:loginUpdate(info)
    return self:__updateTaskInfo(info)
end

function SelfCreatedSkillTaskModel:__updateTaskInfo(taskInfo)
    if MapIsEmpty(taskInfo) == true then
        assert(false, "task22 地宫古迹任务更新数据为空值")
    end

    local roleTask = self:__getLocalRoleTaskInfo()

    roleTask.state = taskInfo.state
    roleTask.startTime = taskInfo.start_time
    roleTask.endTime = taskInfo.end_time
    roleTask.dCount = taskInfo.dcount
    roleTask.zCount = taskInfo.zcount

    roleTask.roleLv = taskInfo.extra.roleLv
    roleTask.luck = taskInfo.extra.luck
    roleTask.kongfu = taskInfo.extra.kongfu
    roleTask.exp = taskInfo.extra.exp

    self:__updateTaskFlag(taskInfo.state)
end

function SelfCreatedSkillTaskModel:acceptTask(callback)
    local role = User:getRole()
    HttpManagerEx:acceptTask(
        TASK_ID,
        {
            roleLv = role:getLv(),
            luck = Helper:mathFloor(role:getFinalAttr("luck")),
            kongfu = Helper:mathFloor(role:getKongfu()),
            exp = Helper:mathFloor(role:getAttr("exp"))
        },
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 4 then
                    PopText("服务器错误,请重试。")
                    return false
                end
                if errcode == 0 then
                    self:__updateTaskInfo(data)
                end

                callback(errcode, self:__getLocalRoleTaskInfo())

                return true
            else
                PopText(errmsg)
                return false
            end
        end,
        IS_SHOW_WAITING,
        HTTP_MANAGER_RETRY_TYPE_RETRY
    )
end

function SelfCreatedSkillTaskModel:completeTask(updateData, callback)
    HttpManagerEx:finishTask(
        TASK_ID,
        updateData.extra,
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 4 then
                    PopText("服务器错误,请重试。")
                    return false
                end

                if errcode == 0 then
                    self:__updateTaskInfo(data)
                end

                callback(errcode, self:__getLocalRoleTaskInfo())

                return true
            else
                PopText(errmsg)
                return false
            end
        end,
        IS_SHOW_WAITING,
        HTTP_MANAGER_RETRY_TYPE_RETRY
    )
end

function SelfCreatedSkillTaskModel:cancelTask(callback)
    -- local roleTask = self:__getLocalRoleTaskInfo()
    -- roleTask.state = TASK_STATE_IDLE
    -- local role = User:getRole()
    -- role:setAttr("money", role:getAttr("money") - 100)
    -- PopText("消耗100碎银")
    -- callback()
end

function SelfCreatedSkillTaskModel:resetTask(callback)
    HttpManagerEx:resetTask(
        TASK_ID,
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 4 then
                    PopText("服务器错误,请重试。")
                    return false
                end

                if errcode == 0 then
                    self:__updateTaskInfo(data)
                end

                callback(errcode, self:__getLocalRoleTaskInfo())

                return true
            else
                PopText(errmsg)
                return false
            end
        end,
        IS_SHOW_WAITING,
        HTTP_MANAGER_RETRY_TYPE_RETRY
    )
end

function SelfCreatedSkillTaskModel:submitTask(callback)
    --@desc FZJH-4718
    HttpManagerEx:submitTask(
        TASK_ID,
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 4 then
                    PopText("服务器错误,请重试。")
                    return false
                end

                local rewards = {
                    client = {},
                    server = {}
                }

                if errcode == 0 or errcode == 5 then
                    self:__updateTaskInfo(data.task)
                end

                if errcode == 0 then
                    local clientReward = {
                        attrs = data.reward.client.attrs
                    }

                    if MapIsEmpty(clientReward.attrs) == false then
                        local role = User:getRole()
                        for attrName, value in pairs(clientReward.attrs) do
                            role:addAttr(attrName, value)
                        end
                    end

                    rewards.client = clientReward
                    rewards.server = data.reward.server
                end

                callback(errcode, self:__getLocalRoleTaskInfo(), rewards)

                return true
            else
                PopText(errmsg)
                return false
            end
        end,
        IS_SHOW_WAITING,
        HTTP_MANAGER_RETRY_TYPE_RETRY
    )
end

function SelfCreatedSkillTaskModel:getTaskInfo(callback)
    HttpManagerEx:getTaskInfo(
        TASK_ID,
        function(status, errcode, errmsg, data)
            if status == 200 and errcode == 0 then
                self:__updateTaskInfo(data)

                callback(self:__getLocalRoleTaskInfo())

                return true
            else
                PopText(errmsg)
                return false
            end
        end,
        IS_SHOW_WAITING,
        HTTP_MANAGER_RETRY_TYPE_RETRY
    )
end

function SelfCreatedSkillTaskModel:__updateTaskFlag(state)
    local role = User:getRole()
    if state == TASK_STATE_ACCEPT then
        role:setFlag(SHOW_DIGONG_FLAG, 1)
    elseif state == TASK_STATE_COMPLETE then
        role:setFlag(SHOW_DIGONG_FLAG, 0)
    end
end

function SelfCreatedSkillTaskModel:isShowDiGong()
    local role = User:getRole()

    return role:getFlag(SHOW_DIGONG_FLAG) == 1
end

return SelfCreatedSkillTaskModel
000000