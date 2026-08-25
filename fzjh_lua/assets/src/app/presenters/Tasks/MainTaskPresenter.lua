local MainTaskPresenter = class("MainTaskPresenter", cc.Layer)

local HangUpTaskBtnPresenter = require("app.presenters.Tasks.HangUpTaskBtnPresenter")

local TaskTextFactory = require("app.models.Task2.TaskTextFactory")

local Role = require("app.models.role.Role")

local TaskConst = require("app.models.Task2.TaskConst")

local TaskBtnUI1 = require("app.views.ui.TaskUI.TaskBtnUI1")

local BTN_STYLE_PREFIX = "Layer.TaskUI.BtnStyle."

function MainTaskPresenter:create(...)
    local p = MainTaskPresenter.new()
    p:__init(...)
    return p
end

function MainTaskPresenter:__init(hangUpTaskSystem, liLianTaskSystem)
    --@RefType [MainTasksUI]
    self.__ui = require("app.views.ui.TaskUI.MainTasksUI"):create()

    self.__ui:addTo(self)

    self.__currPage = 0

    self.__currList = nil

    self.__taskItems = {}

    if hangUpTaskSystem == nil then
        hangUpTaskSystem = User:getRole():getHangUpSystem()
    end

    self:setHangUpTaskInterator(hangUpTaskSystem)

    if liLianTaskSystem == nil then
        liLianTaskSystem = User:getRole():getLiLianTaskSystem()
    end

    self:setLiLianTaskInterator(liLianTaskSystem)

    self.__taskWorking = false
    self.__currPage = 1
end

function MainTaskPresenter:clear()
    self.__ui:clearView()
end

function MainTaskPresenter:setHangUpTaskInterator(interator)
    --@RefType [src.app.models.Task2.HangUpTaskSystem#HangUpTaskSystem]
    self.__hangUpInterator = interator
end

function MainTaskPresenter:setLiLianTaskInterator(interator)
    --@RefType [src.app.models.Task2.LiLianTaskSystem#LiLianTaskSystem]
    self.__liLianInterator = interator
end

function MainTaskPresenter:updateLayerSkinUI(skin_config)
    if skin_config.HangUpTaskBtnStyle then
        self.__hangUpTaskBtnStyle = skin_config.HangUpTaskBtnStyle
    end

    if skin_config.LiLianTaskBtnStyle then
        self.__liLianTaskBtnStyle = skin_config.LiLianTaskBtnStyle
    end
end

function MainTaskPresenter:onEnable()
    self.__hangUpInterator:setOutput(self)
    self.__liLianInterator:setOutput(self)

    self.__liLianInterator:updateAllTasks()

    self:clear()
    self:__createHangUpTaskPage()
    self:__createLilianTaskPage()
    self:changePage(self.__currPage)
    self.__ui:setCurrentPage(self.__currPage)

    self:hideHangUpDetail()

    self.__ui:setSwitchPageCallbackFunc(
        function(pageNum)
            self:changePage(pageNum)
        end
    )

    if self.__hangUpInterator:checkHangUpTaskFinish() then
        self.__hangUpInterator:autoStopHangUp()
    end

    self.__timeTag =
        self:schedule(
        function(ft)
            self.__hangUpInterator:update(ft)

            if self.__detailPanelShow then
                self:__updateDetailPanelInfo(ft)
            end
        end,
        0
    )

    self.__ui:show()
end

function MainTaskPresenter:onDisable()
    self:unscheduleAll()
    self.__hangUpInterator:setOutput(nil)
    self.__liLianInterator:setOutput(nil)
    self.__ui:hide()
    self:hide()
end

function MainTaskPresenter:__refreshPageListSort(pageNum)
    local list = self.__taskItems[pageNum]

    table.sort(
        list,
        function(a, b)
            return a:getSortLevel() > b:getSortLevel()
        end
    )

    for i = 1, #list do
        local presenter = list[i]

        local ui = presenter:getUI()

        self.__ui:changeItemOrder(1, ui, i)
    end
end

function MainTaskPresenter:changePage(pageNum)
    self.__currPage = pageNum

    self.__currList = self.__taskItems[pageNum]
end

function MainTaskPresenter:getBtnPresenter(pageNum, id)
    local list = self.__taskItems[pageNum]

    if #list > 0 then
        for i = 1, #list do
            local presenter = list[i]
            if presenter:getId() == id then
                return presenter
            end
        end
    end

    error(string.format("MainTaskPresenter:getBtnPresenter ： 该页%s没有找到id为%s的按钮", pageNum, id))
end

--@region 挂机相关
function MainTaskPresenter:__createHangUpTaskPage()
    self.__ui:createPage(1, "任务")

    local list = {}

    self.__hangUpInterator:updateTaskTypeAndStatus()

    local playerHangUpList = self.__hangUpInterator:getHangUpTasks()

    local resPath = BTN_STYLE_PREFIX .. "GuaJiTaskSkin_0UI"
    if self.__hangUpTaskBtnStyle then
        resPath = BTN_STYLE_PREFIX .. self.__hangUpTaskBtnStyle
    end

    for i = 1, #playerHangUpList do
        local pHangUpTask = playerHangUpList[i]

        local btnUI = TaskBtnUI1:create(resPath)

        --@RefType [src.app.presenters.Tasks.HangUpTaskBtnPresenter#HangUpTaskBtnPresenter]
        local btnPresenter = HangUpTaskBtnPresenter:create()
        btnPresenter:setTask(pHangUpTask)
        btnPresenter:setUI(btnUI)
        btnPresenter:setMainTaskPresenter(self)
        btnPresenter:init()

        self.__ui:addItemToPage(1, btnUI)

        table.insert(list, btnPresenter)
    end

    self.__taskItems[1] = list

    self:__refreshPageListSort(1)

    self.__ui:pageViewJumpToTop(1)
end

function MainTaskPresenter:__refreshAllHangUpBtn()
    local list = self.__taskItems[1]

    if #list > 0 then
        for i = 1, #list do
            local presenter = list[i]
            presenter:updateUI()
        end
    end
end

function MainTaskPresenter:showStartHangUpTaskInfo(taskId)
    PopupLayerController:showLayer(
        "HangUpTaskStartInfoPresenter",
        function(layer)
            --@RefType [HangUpTaskStartInfoPresenter]
            layer = layer

            layer:setHangUpSystem(self.__hangUpInterator)

            layer:setTaskId(taskId)

            layer:showLayer()
        end
    )
end

function MainTaskPresenter:startHangUpTask(taskId)
    local presenter = self:getBtnPresenter(1, taskId)
    presenter:updateUI()
    self:__refreshPageListSort(1)
    self:showHangUpDetail(taskId)

    local textClass = TaskTextFactory:getRandomHangUpTaskText(taskId, TaskConst.HangUpTaskTextType.StartHangUp)

    self.__ui:addDetailText(textClass:getShowDesc())

    self.__detailTextNextTime = textClass:getTime()
end

function MainTaskPresenter:showHangUpDetail(taskId)
    self.__ui:setDetailPanelBtnFunc(
        "停止任务",
        function()
            Game:addBlockAsyncFunc(
                "取消任务",
                function()
                    self.__hangUpInterator:manualStopHangUpTask(taskId)
                end
            )
        end
    )

    self.__ui:setDetailPanelClickFunc(
        function()
            self:hideHangUpDetail()
        end
    )

    self.__ui:showDetailPanel()

    self.__ui:setPageViewVisible(false)

    self.__detailPanelShow = true

    --@RefType [src.app.models.Task2.PlayerHangUpTask#PlayerHangUpTask]
    self.__currDetaiHangUpTask = self.__hangUpInterator:getHangUpTask(taskId)

    local CalAfterStartExceptReward = require("app.models.Task2.HangUpReward.CalAfterStartExceptReward")

    local calExceptRewardClass = CalAfterStartExceptReward:create()
    calExceptRewardClass:setPlayerHangUpTask(self.__currDetaiHangUpTask)
    calExceptRewardClass:setPlayer(self.__hangUpInterator:getPlayer())
    --@RefType [src.app.models.Task2.HangUpReward.CalAfterStartExceptReward#CalAfterStartExceptReward]
    self.__currDetailHangUpTaskRewards = calExceptRewardClass

    self:__showDetailExceptInfo()
    self:__showLuckAdditionInfo()
    self:__showYaShiAdditionInfo()
    self:__showExceptTotalInfo()

    self.__detailTextNextTime = 0

    self.__detailShowTime = 0
end

function MainTaskPresenter:__showDetailExceptInfo()
    self.__ui:setDetailInfoPanelTitle1("任务预计总收益（小时）")
    local rewards = self.__currDetailHangUpTaskRewards:getRewards()

    for i = 1, 3 do
        --@RefType [src.app.models.Task2.TaskAttrReward#TaskAttrReward]
        local rewardInfo = rewards[i]
        if rewardInfo then
            self.__ui["setDetailInfoPanelTextVisible1_" .. i](self.__ui, true)
            local value = rewardInfo:getValue() * 3600
            self.__ui["setDetailInfoPanelTextStr1_" .. i](self.__ui, string.format("%s：%d", rewardInfo:getNameText(), value))
        else
            self.__ui["setDetailInfoPanelTextVisible1_" .. i](self.__ui, false)
        end
    end
end

function MainTaskPresenter:__showLuckAdditionInfo()
    self.__ui:setDetailInfoPanelTitle2("福缘收益加成（小时）")
    local rewards = self.__currDetailHangUpTaskRewards:getLuckAddRewards()
    for i = 1, 3 do
        --@RefType [src.app.models.Task2.TaskAttrReward#TaskAttrReward]
        local rewardInfo = rewards[i]
        if rewardInfo then
            self.__ui["setDetailInfoPanelTextVisible2_" .. i](self.__ui, true)
            local value = rewardInfo:getValue() * 3600
            self.__ui["setDetailInfoPanelTextStr2_" .. i](self.__ui, string.format("%s：%d", rewardInfo:getNameText(), value))
        else
            self.__ui["setDetailInfoPanelTextVisible2_" .. i](self.__ui, false)
        end
    end
end

function MainTaskPresenter:__showYaShiAdditionInfo()
    if self.__hangUpInterator:getPlayer():isYaShi() then
        self.__ui:setDetailInfoPanelTitle3("江湖雅士加成")
        local rewards = self.__currDetailHangUpTaskRewards:getYaShiAddRewards()
        for i = 2, 3 do
            self.__ui["setDetailInfoPanelTextVisible3_" .. i](self.__ui, false)
        end
        self.__ui:setDetailInfoPanelTextVisible3_1(true)
        self.__ui:setDetailInfoPanelTextStr3_1(string.format("基础收益增加%s%%", Helper:getRoundNumber(TaskConst:getHangUpTaskConfigValue("yaShiAwardExpAdd") * 100)))
    else
        self.__ui:setDetailInfoPanelTitle3("江湖雅士加成（未开启，需在商城中购买）")
        self.__ui:setDetailInfoPanelTextVisible3_1(false)
        self.__ui:setDetailInfoPanelTextVisible3_2(false)
        self.__ui:setDetailInfoPanelTextVisible3_3(false)
    end
end

function MainTaskPresenter:__showExceptTotalInfo()
    self.__ui:setDetailInfoPanelTitle4("累计预估收益（小时）")
    local currTime = GetTime()
    local startTime = self.__currDetaiHangUpTask:getStartTime()
    local elapsed = currTime - startTime

    if elapsed < 1800 then
        self.__ui:setDetailInfoPanelTitleVisible4_1(false)
        for i = 2, 3 do
            self.__ui["setDetailInfoPanelTextVisible4_" .. i](self.__ui, false)
        end

        self.__ui:setDetailInfoPanelTextVisible4_1(true)
        self.__ui:setDetailInfoPanelTextStr4_1("暂无（最低需累计任务30分钟后才显示）")
    else
        local timeDsc = "已挂机："
        local hour, min = Helper:sec2timeDsc(elapsed)
        if hour and hour ~= 0 then
            timeDsc = timeDsc .. tostring(hour) .. "小时"
        end
        if min and min ~= 0 then
            timeDsc = timeDsc .. tostring(min) .. "分"
        end

        self.__ui:setDetailInfoPanelTitle4_1(timeDsc)

        self.__ui:setDetailInfoPanelTitleVisible4_1(true)
        local rewards = self.__currDetailHangUpTaskRewards:getRewards()
        for i = 1, 3 do
            --@RefType [src.app.models.Task2.TaskAttrReward#TaskAttrReward]
            local rewardInfo = rewards[i]
            if rewardInfo then
                self.__ui["setDetailInfoPanelTextVisible4_" .. i](self.__ui, true)
                local attrShowName = rewardInfo:getNameText()
                local value = rewardInfo:getValue() * elapsed
                self.__ui["setDetailInfoPanelTextStr4_" .. i](self.__ui, string.format("%s：%d", attrShowName, value))
            else
                self.__ui["setDetailInfoPanelTextVisible4_" .. i](self.__ui, false)
            end
        end
    end
end

function MainTaskPresenter:__updateDetailPanelInfo(ft)
    if self.__currDetaiHangUpTask == nil then
        error("挂机详细界面流程有问题")
    end

    if self.__detailTextNextTime <= self.__detailShowTime then
        local textClass = TaskTextFactory:getRandomHangUpTaskText(self.__currDetaiHangUpTask:getId(), TaskConst.HangUpTaskTextType.HangUping)
        self.__ui:addDetailText(textClass:getShowDesc())
        self.__detailTextNextTime = textClass:getTime()
        self.__detailShowTime = 0
    end

    self.__detailShowTime = self.__detailShowTime + ft
end

function MainTaskPresenter:hideHangUpDetail()
    self.__detailPanelShow = false
    self.__ui:setPageViewVisible(true)
    self.__ui:hideDetailPanel()
end

function MainTaskPresenter:autoStopHangUpTask(taskId)
    self:__afterStopHangUpTask()

    local textClass = TaskTextFactory:getRandomHangUpTaskText(taskId, TaskConst.HangUpTaskTextType.AutoStopHangUp)

    self:printMsg(Helper:getDef(textClass:getShowDesc(), ""))

    if self.__detailPanelShow then
        self:hideHangUpDetail()
    end
end

function MainTaskPresenter:manualStopHangUpTask(taskId)
    local TaskTextFactory = require("app.models.Task2.TaskTextFactory")

    local textClass = TaskTextFactory:getRandomHangUpTaskText(taskId, TaskConst.HangUpTaskTextType.ManualStopHangUp)

    self:printMsg(Helper:getDef(textClass:getShowDesc(), ""))

    self:__afterStopHangUpTask()

    if self.__detailPanelShow then
        self:hideHangUpDetail()
    end
end

function MainTaskPresenter:__afterStopHangUpTask()
    self:__refreshAllHangUpBtn()
    self:__refreshPageListSort(1)
end

function MainTaskPresenter:hangUpTaskWork(taskId)
    if self.__taskWorking then
        self:popMessage("请稍后。")
        return
    end

    self.__taskWorking = true
    self.__hangUpInterator:workForTask(taskId)
end

function MainTaskPresenter:hangUpTaskWorded(taskId, text)
    self:printMsg(text)
    self:__refreshAllHangUpBtn()
    self:__refreshPageListSort(1)
    self.__taskWorking = false
end

function MainTaskPresenter:hangUpTaskWorkCd(taskId, text)
    self:printMsg(text)
end

function MainTaskPresenter:updateHangUpTaskBtnProgress(taskId, value)
    local presenter = self:getBtnPresenter(1, taskId)
    presenter:setBtnProgress(value)
end

function MainTaskPresenter:hangUpTaskDailyMax(taskId)
    self:updateHangUpTaskUI(taskId)
end

function MainTaskPresenter:updateHangUpTaskCD(taskId, time)
    local presenter = self:getBtnPresenter(1, taskId)
    presenter:updateHangUpTaskCD(time)
end

function MainTaskPresenter:updateHangUpTaskUI(taskId)
    local presenter = self:getBtnPresenter(1, taskId)
    presenter:updateUI()
end

function MainTaskPresenter:showHangUpingTime(taskId, time)
    local presenter = self:getBtnPresenter(1, taskId)

    local timeDsc = ""

    local hour, min, sec = Helper:sec2timeDsc(time)
    if hour and hour ~= 0 then
        timeDsc = timeDsc .. tostring(hour) .. "小时"
    end
    if min and min ~= 0 then
        timeDsc = timeDsc .. tostring(min) .. "分"
    end

    if timeDsc ~= "" then
        timeDsc = "\n已进行：" .. timeDsc
    end

    presenter:setStatusText("任务中" .. timeDsc)
end
--@endregion

--@region 主动历练任务
function MainTaskPresenter:__createLilianTaskPage()
    --@RefType [src.app.models.Task2.LiLianTaskSystem#LiLianTaskSystem]
    local tasks = self.__liLianInterator:getZhuDongTasks()

    if MapIsEmpty(tasks) then
        return
    end
    self.__ui:createPage(2, "历练")

    local list = {}

    local TaskBtnUI = require("app.views.ui.TaskUI.TaskBtnUI")
    local resPath = BTN_STYLE_PREFIX .. "LiLianTaskSkin_0UI"

    if self.__liLianTaskBtnStyle then
        resPath = BTN_STYLE_PREFIX .. self.__liLianTaskBtnStyle
    end

    if self.__liLianInterator:isOpenLiLianTask() then
        local zTask = self.__liLianInterator:getLiLianTask()

        local LiLianTaskBtnPresenter = require("app.presenters.Tasks.LiLianTaskBtnPresenter")
        local btnUI = TaskBtnUI:create(resPath)
        local btnPresenter = LiLianTaskBtnPresenter:create()

        btnPresenter:setTask(zTask)

        btnPresenter:setUI(btnUI)

        btnPresenter:setMainTaskPresenter(self)

        btnPresenter:init()

        table.insert(list, btnPresenter)

        self.__ui:addItemToPage(2, btnUI)
    end

    local ZhuDongTaskBtnPresenter = require("app.presenters.Tasks.ZhuDongTaskBtnPresenter")
    for i, zTask in ipairs(tasks) do
        local btnUI = TaskBtnUI:create(resPath)
        --@RefType [src.app.presenters.Tasks.ZhuDongTaskBtnPresenter#ZhuDongTaskBtnPresenter]
        local btnPresenter = ZhuDongTaskBtnPresenter:create()

        btnPresenter:setTask(zTask)

        btnPresenter:setUI(btnUI)

        btnPresenter:setMainTaskPresenter(self)

        btnPresenter:init()

        table.insert(list, btnPresenter)

        self.__ui:addItemToPage(2, btnUI)
    end

    self.__ui:pageViewJumpToTop(2)

    self.__taskItems[2] = list
end

function MainTaskPresenter:acceptLiLianTask(taskId)
    self.__liLianInterator:acceptLiLianTask(taskId)
end

function MainTaskPresenter:submitLiLianTask(taskId)
    self.__liLianInterator:submitLiLianTask(taskId)
end

function MainTaskPresenter:updateSubmitLiLianTask(taskId)
    self:getBtnPresenter(2, taskId):updateUI()
end

function MainTaskPresenter:acceptZhuDongTask(taskId)
    self.__liLianInterator:acceptZhuDongTask(taskId)
end

function MainTaskPresenter:showZhuDongTask(taskId)
    self.__liLianInterator:showZhuDongTask(taskId)
end

function MainTaskPresenter:submitZhuDongTask(taskId)
    self.__liLianInterator:submitZhuDongTask(taskId)
end

function MainTaskPresenter:updateSubmitZhuDongTask(taskId)
    self:getBtnPresenter(2, taskId):updateUI()
end

function MainTaskPresenter:updateLiLianTaskCount()
    self.__liLianInterator:updateLiLianTaskCount()
end

function MainTaskPresenter:updateZhuDongTaskCount(taskId)
    self.__liLianInterator:updateZhuDongTaskCount(taskId)
end

--@endregion

function MainTaskPresenter:popMessage(msg)
    PopText(msg)
end

function MainTaskPresenter:printMsg(msg)
    RichPrint("main", msg)
end

Helper:classDefNodeGetInstance(MainTaskPresenter)
return MainTaskPresenter
000000