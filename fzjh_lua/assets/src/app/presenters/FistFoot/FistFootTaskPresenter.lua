local FistFootTaskPresenter = class("FistFootTaskPresenter", cc.Layer)

local FistFootConst = require("app.models.FistFootSystem.FistFootConst")

local SkillConst = require("app.models.skill.SkillConst")

local SkillClassifyManager = require("app.FightSystem.FightSkill.SkillClassifyManager")

function FistFootTaskPresenter:create()
    local p = FistFootTaskPresenter:new()
    p:init()
    return p
end

function FistFootTaskPresenter:init()
    self.__ui = require("app.views.ui.FistFootUI.FistFootTaskUI"):create()

    self.__ui:addTo(self)
end

function FistFootTaskPresenter:setRole(role)
    self.__role = role
end

function FistFootTaskPresenter:setType(type)
    self.__type = type

    self.__thirdType = SkillClassifyManager:getClassifyThirdType(tostring(type))
end

function FistFootTaskPresenter:setTasks(tasks)
    self.__tasks = tasks
end

function FistFootTaskPresenter:showLayer()
    self.__index = 1

    self.__task = nil

    self:initTaskList()

    self:setPanelTitle()
    
    self:setListViewTask()

    self:setText()

    self:setButtonStart()

    self.__ui:show()
end

function FistFootTaskPresenter:setPanelTitle()
    local titles = {"锻体","技巧","砺炼",} 
    for i ,name in ipairs(titles) do
        self.__ui:setPanelTitleFunc(i,
            function()
                if self.__index == i then
                    return
                end

                self.__index = i

                self.__task = nil

                self:setListViewTask()

                self:setText()

                self.__ui:setLightTitle(self.__index)
            end
        )
        self.__ui:setPanelTitleName(i,name)
    end

    self.__ui:setLightTitle(self.__index)
end

function FistFootTaskPresenter:setListViewTask()
    local taskList = self.__taskList[tostring(self.__index)]
    local retArray = {}
    if not MapIsEmpty(taskList) then
        table.sort(taskList, function(a,b)
            if a.state == b.state then
                return tonumber(a.taskId) < tonumber(b.taskId)
            else
                if a.state == FistFootConst.TaskStateType.Unlock and b.state ~= FistFootConst.TaskStateType.Unlock then
                    return true
                elseif a.state ~= FistFootConst.TaskStateType.Unlock and b.state == FistFootConst.TaskStateType.Unlock then
                    return false
                else
                    return a.state > b.state
                end
            end
        end)
    
    
        for i,v in ipairs(taskList) do
            local task = self.__role:getFistFootSystem():getTask(v.taskId)
            local retData = {}
            if v.state == FistFootConst.TaskStateType.Lock then
                retData.isState = 1
                retData.condition = task.opentext
                retData.diImage = "Image/UI/FistFootUI/di_task_black.png"
            elseif v.state == FistFootConst.TaskStateType.Unlock then
                retData.isState = 2
                retData.name = task.name
                local awardtext = task.awardtext
                retData.reward1 = awardtext[1] or ""
                retData.reward2 = awardtext[2] or ""
                retData.diImage = "Image/UI/FistFootUI/di_task_white.png"
                retData.time = task.time.."小时"
            elseif v.state == FistFootConst.TaskStateType.Cd then
                retData.isState = 3
                retData.name = task.name
                local awardtext = task.awardtext
                retData.reward1 = awardtext[1] or ""
                retData.reward2 = awardtext[2] or ""
                retData.diImage = "Image/UI/FistFootUI/di_task_grey.png"
                local timeText = ""
                if task.cd[1] == FistFootConst.TaskCdType.Interval then
                    local hour, min, sec = Helper:sec2timeDsc(v.cdTime)
                    if hour > 0 then
                        timeText = hour.."小时"..min.."分钟后刷新"
                    else
                        min = math.max(min,1)
    
                        timeText = min.."分钟后刷新"
                    end
                elseif task.cd[1] == FistFootConst.TaskCdType.Fixed then
                    local week = task.cd[3]
                    local hour = task.cd[4]
                    timeText = "周"..Helper:numberCast(week)..hour.."点刷新"
                end
                
                retData.time = timeText
            end
    
            retData.func = function()
                self.__task = task
    
                self.__ui:setLightTask(i)
            end
            
            table.insert(retArray,retData)
        end

        self.__ui:setNotTaskVisible(false)
    else
        self.__ui:setNotTaskVisible(true)
    end

    self.__ui:setListViewTask(retArray)
end

function FistFootTaskPresenter:initTaskList()
    local taskList = {
        ["1"] = {},
        ["2"] = {},
        ["3"] = {}
    }

    for i,v in ipairs(self.__tasks) do
        local task = self.__role:getFistFootSystem():getTask(v.taskId)

        if self.__thirdType == SkillConst.SkillThirdType.QUAN_FA and task.type == FistFootConst.TaskType.Quan then
            table.insert(taskList["1"], v)
        elseif self.__thirdType == SkillConst.SkillThirdType.ZHANG_FA and task.type == FistFootConst.TaskType.Zhang then
            table.insert(taskList["1"], v)
        elseif self.__thirdType == SkillConst.SkillThirdType.ZHUA_FA and task.type == FistFootConst.TaskType.Zhua then
            table.insert(taskList["1"], v)
        elseif self.__thirdType == SkillConst.SkillThirdType.TUI_FA and task.type == FistFootConst.TaskType.Tui then
            table.insert(taskList["1"], v)
        elseif self.__thirdType == SkillConst.SkillThirdType.ZHI_FA and task.type == FistFootConst.TaskType.Zhi then
            table.insert(taskList["1"], v)
        end

        if task.type == FistFootConst.TaskType.Character then
            table.insert(taskList["2"], v)
        end

        if task.type == FistFootConst.TaskType.Plot or task.type == FistFootConst.TaskType.Loop then
            table.insert(taskList["3"], v)
        end
    end

    self.__taskList = taskList
end

function FistFootTaskPresenter:setButtonStart()
    self.__ui:setButtonStart(
        function()
            if self.__task == nil then
                PopText("请先选择所需修行的方式")
            else
                --同步服务器时间
                HttpManagerEx:getTime(function(status, errcode, errmsg, data, isEncrypted)
                    if status == 200 and errcode == 0 and data.time ~= nil then
                        SetTime(tonumber(data.time))
                        --开始挂机任务
                        self.__role:getFistFootSystem():startFistTask(self.__task.taskid,function(isOk,msg)
                            if isOk then
                                self.__ui:hide()
                                MainControllLayer:popLayer()
        
                                MainControllLayer:pushLayer("FistFootGuaJiPresenter")
                                local fistFootGuaJiPresenter = MainControllLayer:getLayer("FistFootGuaJiPresenter")
                                fistFootGuaJiPresenter:setRole(self.__role)
                                fistFootGuaJiPresenter:showLayer()
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

function FistFootTaskPresenter:isBranchMaxLv()
    local lv = self.__role:getFistFootSystem():getBranchLv(self.__type)
    local maxLv = self.__role:getFistFootSystem():getBranchMaxLv(self.__type)

    if lv >= maxLv then
        return true
    end

    return false
end

function FistFootTaskPresenter:isReflectMaxLv()
    local lv = self.__role:getFistFootSystem():getReflectLv()
    local maxLv = self.__role:getFistFootSystem():getReflectMaxLv()

    if lv >= maxLv then
        return true
    end

    return false
end

function FistFootTaskPresenter:setText()
    local taskList = self.__taskList[tostring(self.__index)]
    local text1,text2,text3 = "","",""
    if not MapIsEmpty(taskList) then
        if self.__index == 1 then
            local exp = self.__role:getFistFootSystem():getBranchExp(self.__type)
            local lv = self.__role:getFistFootSystem():getBranchLv(self.__type)
            text1 = "锻境等级："..lv
    
            if self:isBranchMaxLv() then
                text2 = "升级所需：已达到最大等级"
            else
                local nextInfo = self.__role:getFistFootSystem():getBranchMap(self.__type,lv + 1)
                text2 = "升级所需："..exp.."/"..nextInfo.exp
            end
        elseif self.__index == 2 then
            local reflectExp = self.__role:getFistFootSystem():getReflectExp()
            local lv = self.__role:getFistFootSystem():getReflectLv()
            local feelPoint = self.__role:getFistFootSystem():getFeelPoint()

            text1 = "剩余感悟点数："..feelPoint
            text2 = "潜思等级："..lv

            if self:isReflectMaxLv() then
                text3 = "升级所需：已达到最大等级"
            else
                local nextInfo = self.__role:getFistFootSystem():getReflectData(lv + 1)
                text3 = "升级所需："..reflectExp.."/"..nextInfo.exp
            end
        elseif self.__index == 3 then
            text1 = "每天0点更新获取更多的砺炼修行任务"
        end
    end

    self.__ui:setText1(text1)
    self.__ui:setText2(text2)
    self.__ui:setText3(text3)
end


Helper:classDefNodeGetInstance(FistFootTaskPresenter)
return FistFootTaskPresenter
000000000000000