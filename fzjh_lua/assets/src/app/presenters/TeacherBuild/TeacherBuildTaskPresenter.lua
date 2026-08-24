local TeacherBuildTaskPresenter = class("TeacherBuildTaskPresenter", cc.Layer)

local TeacherBuildConst = require("app.models.TeacherBuildSystem.TeacherBuildConst")

function TeacherBuildTaskPresenter:create()
    local p = TeacherBuildTaskPresenter:new()
    p:init()
    return p
end

function TeacherBuildTaskPresenter:init()
    self.__ui = require("app.views.ui.TeacherBuildUI.TeacherBuildTaskUI"):create()

    self.__ui:addTo(self)

    self.__taskTypeList = {
        {
            taskType = TeacherBuildConst.TaskType.Reputation,
            text = TeacherBuildConst.TaskTypeName.Reputation
        },
        {
            taskType = TeacherBuildConst.TaskType.Gbpoint,
            text = TeacherBuildConst.TaskTypeName.Gbpoint
        },
        {
            taskType = TeacherBuildConst.TaskType.Renown,
            text = TeacherBuildConst.TaskTypeName.Renown
        },
        {
            taskType = TeacherBuildConst.TaskType.Bmaterials,
            text = TeacherBuildConst.TaskTypeName.Bmaterials
        },
    }
end

function TeacherBuildTaskPresenter:updateLayerSkinUI(skin_config)
    if self.__ui.updateSkin then
        self.__ui:updateSkin(skin_config)
    end
end

function TeacherBuildTaskPresenter:setRole(role)
    self.__role = role
end

function TeacherBuildTaskPresenter:setTasks(tasks)
    self.__taskList = tasks
    self:__initTasks()
end

function TeacherBuildTaskPresenter:showLayer()
    self.__task = nil

    self.__taskType = TeacherBuildConst.TaskType.Reputation

    self:setTaskTypeSelect()

    self:setText()

    self:setButtonStart()

    self.__ui:show()
end

function TeacherBuildTaskPresenter:setTaskTypeSelect()
    local list = {}

    for i, v in ipairs(self.__taskTypeList) do
        local __info = {}
        __info.text = v.text
        __info.func = function()
            if self.__taskType ~= v.taskType then
                self.__taskType = v.taskType
                self:__showList()
                self:__initTaskTypeColor()
            end
        end
        table.insert(list, __info)
    end

    self.__ui:setTypeSelectList(list)
    self:__showList()
    self:__initTaskTypeColor()
end

function TeacherBuildTaskPresenter:setButtonStart()
    self.__ui:setButtonStart(
        function()
            if self.__task == nil then
                PopText("请先选择对应的日常任务")
            else
                --同步服务器时间
                HttpManagerEx:getTime(function(status, errcode, errmsg, data, isEncrypted)
                    if status == 200 and errcode == 0 and data.time ~= nil then
                        SetTime(tonumber(data.time))
                        --开始挂机任务
                        self.__role:getTeacherBuildSystem():startTeacherBuildTask(self.__task.taskid,function(isOk,msg)
                            if isOk then
                                self.__ui:hide()
                                MainControllLayer:popLayer()
        
                                MainControllLayer:pushLayer("TeacherBuildGuaJiPresenter")
                                local teacherBuildGuaJiPresenter = MainControllLayer:getLayer("TeacherBuildGuaJiPresenter")
                                teacherBuildGuaJiPresenter:setRole(self.__role)
                                teacherBuildGuaJiPresenter:showLayer()
                            else
                                PopText(msg)
                            end
                        end)
                    else
                        PopText(errmsg)
                    end
                end)
            end
        end
    )
end

function TeacherBuildTaskPresenter:setText()
    local numDay = self.__role:getTeacherBuildSystem():getTaskNumDay()

    local numLimit = self.__role:getTeacherBuildSystem():getTaskNumLimit()
    
    local text1 = "本日可完成日常:"..numDay.."/"..numLimit

    local speedUpName = self.__role:getTeacherBuildSystem():getSpeedUpName()

    local speedUp = self.__role:getTeacherBuildSystem():getSpeedUp()
    
    local speedUpLimit = self.__role:getTeacherBuildSystem():getSpeedUpLimit()
    
    local text2 = speedUpName..":"..speedUp.."/"..speedUpLimit

    self.__ui:setText1(text1)
    
    self.__ui:setText2(text2)
    
    self.__ui:setText3("")
end

function TeacherBuildTaskPresenter:__initTasks()
    local taskList = self.__taskList
    local retArray = {}

    if not MapIsEmpty(taskList) then
        table.sort(taskList, function(a,b)
            if a.state == b.state then
                return tonumber(a.taskId) < tonumber(b.taskId)
            else
                if a.state == TeacherBuildConst.TaskStateType.Unlock and b.state ~= TeacherBuildConst.TaskStateType.Unlock then
                    return true
                elseif a.state ~= TeacherBuildConst.TaskStateType.Unlock and b.state == TeacherBuildConst.TaskStateType.Unlock then
                    return false
                else
                    return a.state > b.state
                end
            end
        end)
    
        local taskTypeAdd = {}
        for i,v in ipairs(taskList) do
            local task = self.__role:getTeacherBuildSystem():getTask(v.taskId)
            local retData = {}
            retData.taskType = task.type
            retData.taskId = v.taskId
            if v.state == TeacherBuildConst.TaskStateType.Lock then
                retData.isState = 1
                retData.condition = task.text
                retData.diImage = "Image/UI/FistFootUI/di_task_black.png"
            elseif v.state == TeacherBuildConst.TaskStateType.Unlock then
                retData.isState = 2
                retData.name = task.name
                local awardtext = task.awardtext
                retData.reward1 = awardtext[1] or ""
                retData.reward2 = awardtext[2] or ""
                retData.diImage = "Image/UI/FistFootUI/di_task_white.png"
                retData.time = task.time.."小时"
            elseif v.state == TeacherBuildConst.TaskStateType.Cd then
                retData.isState = 3
                retData.name = task.name
                local awardtext = task.awardtext
                retData.reward1 = awardtext[1] or ""
                retData.reward2 = awardtext[2] or ""
                retData.diImage = "Image/UI/FistFootUI/di_task_grey.png"
                local timeText = ""
                if task.cd[1] == TeacherBuildConst.TaskCdType.Interval then
                    local hour, min, sec = Helper:sec2timeDsc(v.cdTime)
                    if hour > 0 then
                        timeText = hour.."小时"..min.."分钟后刷新"
                    else
                        min = math.max(min,1)
    
                        timeText = min.."分钟后刷新"
                    end
                elseif task.cd[1] == TeacherBuildConst.TaskCdType.Fixed then
                    local week = task.cd[3]
                    local hour = task.cd[4]
                    timeText = "周"..Helper:numberCast(week)..hour.."点刷新"
                end
                
                retData.time = timeText
            end
            
            table.insert(retArray,retData)
        end
    end

    self.__tasksInfo = retArray
end

function TeacherBuildTaskPresenter:__getTaskList()
    local list = {}
    for i, v in ipairs(self.__tasksInfo) do
        if v.taskType == self.__taskType then
            table.insert(list, v)
        end
    end

    return list
end

function TeacherBuildTaskPresenter:__showList()
    local list = self:__getTaskList()
    self.__ui:clearListViewTask()

    if MapIsEmpty(list) == false then
        for i, v in ipairs(list) do
            v.func = function()
                self.__task = self.__role:getTeacherBuildSystem():getTask(v.taskId)
    
                self.__ui:setLightTask(i)
            end 
        end
        self.__ui:setNotTaskVisible(false)
        self.__ui:setListViewTask(list)
    else
        self.__ui:setNotTaskVisible(true)
    end
end

function TeacherBuildTaskPresenter:__initTaskTypeColor()
    for i, v in ipairs(self.__taskTypeList) do
        if v.taskType == self.__taskType then
            self.__ui:setTypeSelectTextColor((i - 1) * 2,{r = 255, g = 255, b = 255})
        else
            self.__ui:setTypeSelectTextColor((i - 1) * 2,{r = 142, g = 142, b = 142})
        end
    end
end


Helper:classDefNodeGetInstance(TeacherBuildTaskPresenter)
return TeacherBuildTaskPresenter
0000