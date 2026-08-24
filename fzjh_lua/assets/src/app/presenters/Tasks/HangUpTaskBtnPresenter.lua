local newClass = require("third.class.NewClass")

local TaskConst = require("app.models.Task2.TaskConst")

local Role = require("app.models.role.Role")

local HangUpTaskBtnPresenter = {}

function HangUpTaskBtnPresenter:create()
    return HangUpTaskBtnPresenter.new()
end

function HangUpTaskBtnPresenter:init()
    self.__ui:setBtnClickMusic("daAnNiu")
    self.__ui:setInnerBtnClickMusic("daAnNiu")
    self:updateUI()
end

function HangUpTaskBtnPresenter:updateUI()
    self.__ui:setBtnName(self.__task:getName())

    self:__updateBtnStatus()
end

function HangUpTaskBtnPresenter:setTask(task)
    --@RefType [src.app.models.Task2.PlayerHangUpTask#PlayerHangUpTask]
    self.__task = task
end

function HangUpTaskBtnPresenter:setUI(ui)
    --@RefType [TaskBtnUI1]
    self.__ui = ui
end

function HangUpTaskBtnPresenter:setMainTaskPresenter(mainTaskPresenter)
    --@RefType [MainTaskPresenter]
    self.__mainTaskPresenter = mainTaskPresenter
end

function HangUpTaskBtnPresenter:getUI()
    return self.__ui
end

function HangUpTaskBtnPresenter:getId()
    return self.__task:getId()
end

function HangUpTaskBtnPresenter:getSortLevel()
    return self:__getTaskTypeSortValue() + self:__getUnlockTypeSortValue() - tonumber(self.__task:getId())
end

function HangUpTaskBtnPresenter:__getUnlockTypeSortValue()
    if not self:__isUnlock() then
        return 1000000
    else
        return 2000000
    end
end

function HangUpTaskBtnPresenter:__getTaskTypeSortValue()
    if self:__isHangUpType() then
        return 200000
    elseif self:__isWorkType() then
        return 100000
    else
        return 0
    end
end

function HangUpTaskBtnPresenter:__isHangUpType()
    return self.__task:getCurrType() == TaskConst.HangUpTaskType.HangUp
end

function HangUpTaskBtnPresenter:__isWorkType()
    return self.__task:getCurrType() == TaskConst.HangUpTaskType.Work
end

function HangUpTaskBtnPresenter:__isUnlock()
    return self.__task:isUnlock()
end

function HangUpTaskBtnPresenter:disableTask()
    self.__ui:setButtonDisable()

    local str = ""

    local strList = self.__task:getUnlockStrs()

    for i = 1, 2 do
        local str = strList[i]

        if str then
            self.__ui["setDisableText" .. i](self.__ui, str)
            self.__ui["setDisableTextVisible" .. i](self.__ui, true)
        else
            self.__ui["setDisableTextVisible" .. i](self.__ui, false)
        end
    end
end

function HangUpTaskBtnPresenter:__updateBtnStatus()
    self.__ui:setBtnNameColor({r = 2, g = 214, b = 2})

    self.__ui:setButtonEnable()

    local taskCurrType = self.__task:getCurrType()

    if taskCurrType == TaskConst.HangUpTaskType.CLOSE then
        return self:disableTask()
    elseif taskCurrType == TaskConst.HangUpTaskType.OPEN_DISABLE then
        self.__ui:setButtonDisable()
        self.__ui:setDisableTextVisible1(true)
        self.__ui:setDisableText1("已解锁，需结束当前挂机方可解锁")
        self.__ui:setDisableTextVisible2(false)
    elseif taskCurrType == TaskConst.HangUpTaskType.HangUp then
        self.__ui:setProgressPercent(100)

        self.__ui:setInnerBtnVisible(true)

        local currStatus = self.__task:getStatus()

        if currStatus == TaskConst.HangUpTaskStatus.HangUpStatus.Idle then
            self.__ui:setInnerBtnName("任务开始")

            self.__ui:setInnerTextVisible(false)

            self.__ui:setBtnClickFunc(EMPTY_FUNC)

            self.__ui:setInnerBtnClickFunc(
                function()
                    self.__mainTaskPresenter:showStartHangUpTaskInfo(self.__task:getId())
                end
            )
        elseif currStatus == TaskConst.HangUpTaskStatus.HangUpStatus.HangUp then
            self.__ui:setInnerBtnVisible(false)

            self.__ui:setInnerTextVisible(true)

            self.__ui:setInnerText("任务中\n··· ···")

            self.__ui:setBtnClickFunc(
                function()
                    Game:getWebTime(
                        function(currTime)
                            self.__mainTaskPresenter:showHangUpDetail(self.__task:getId())
                        end
                    )
                end
            )
        else
            error("挂机类型下，当前状态未知：" .. currStatus)
        end
    elseif taskCurrType == TaskConst.HangUpTaskType.Work then
        local currStatus = self.__task:getStatus()

        if currStatus == TaskConst.HangUpTaskStatus.WorkStatus.Idle then
            self.__ui:setInnerBtnVisible(false)

            self.__ui:setProgressPercent(100)

            self.__ui:setInnerTextVisible(true)

            local workRewards = self.__task:getWorkRewards()

            local str = "任务奖励\n"

            for i, reward in ipairs(workRewards) do
                --@RefType [src.app.models.Task2.PlayerHangUpTaskReward#PlayerHangUpTaskReward]
                reward = reward
                local text = string.format("%s %s", Role:getCHAttrName(reward:getRewardAttrName()), reward:getValue())

                str = str .. text

                if i ~= #workRewards then
                    str = str .. "\n"
                end
            end

            self:setStatusText(str)

            self.__ui:setBtnClickFunc(
                function()
                    self.__mainTaskPresenter:hangUpTaskWork(self.__task:getId())
                end
            )
        elseif currStatus == TaskConst.HangUpTaskStatus.WorkStatus.Cooldown then
            self.__ui:setBtnNameColor({r = 255, g = 255, b = 255})
            self.__ui:setInnerBtnVisible(false)

            self.__ui:setProgressVisible(true)

            self.__ui:setBtnClickFunc(
                function()
                    self.__mainTaskPresenter:hangUpTaskWorkCd(self.__task:getId(), self.__task:getCDText())
                end
            )
        elseif currStatus == TaskConst.HangUpTaskStatus.WorkStatus.DailyMax then
            self.__ui:setInnerBtnVisible(false)

            self.__ui:setProgressPercent(100)

            self.__ui:setInnerTextVisible(true)

            self:setStatusText("本日已完成")
        end
    end
end

function HangUpTaskBtnPresenter:updateHangUpTaskCD(time)
    local timeDsc = ""

    local hour, min, sec = Helper:sec2timeDsc(time)
    if hour and hour ~= 0 then
        timeDsc = timeDsc .. tostring(hour) .. "小时"
    end
    if min and min ~= 0 then
        timeDsc = timeDsc .. tostring(min) .. "分"
    end
    if sec and sec ~= 0 then
        timeDsc = timeDsc .. tostring(sec) .. "秒"
    end

    local str = "任务冷却中"

    if timeDsc ~= "" then
        str = str .. "\n" .. timeDsc
    end

    self:setStatusText(str)
end

function HangUpTaskBtnPresenter:setBtnProgress(value)
    self.__ui:setProgressPercent(value)
end

function HangUpTaskBtnPresenter:setStatusText(str)
    self.__ui:setInnerText(str)
end

return newClass("HangUpTaskBtnPresenter", {}, HangUpTaskBtnPresenter)
000000000000000