local GuaJiTaskSkinUI = class("GuaJiTaskSkinUI", cc.Layer)

local HangUpTaskBtnPresenter = require("app.presenters.Tasks.HangUpTaskBtnPresenter")

local TaskTextFactory = require("app.models.Task2.TaskTextFactory")

local Role = require("app.models.role.Role")

local TaskConst = require("app.models.Task2.TaskConst")

local TaskBtnUI1 = require("app.views.ui.TaskUI.TaskBtnUI1")

local HouseSkinConfig = require("app.models.ChangeHouseSkin.HouseSkinConfig")

local TaskFactory = require("app.models.Task2.TaskFactory")

function GuaJiTaskSkinUI:create()
    local p = GuaJiTaskSkinUI.new()
    p:__init()
    return p
end

function GuaJiTaskSkinUI:__init()
    --@RefType [MainTasksUI]
    self.__ui = require("app.views.ui.TaskUI.MainTasksUI"):create()

    self.__ui:addTo(self)

    self.__currPage = 0

    self.__currList = nil

    self.__taskItems = {}

    -- self:setHangUpTaskInterator(User:getRole():getHangUpSystem())

    -- self:setLiLianTaskInterator(User:getRole():getLiLianTaskSystem())

    self.__taskWorking = false
    self.__currPage = 1

    self:addBgUI()
end

function GuaJiTaskSkinUI:clear()
    self.__ui:clearView()
end

function GuaJiTaskSkinUI:setHangUpTaskInterator(interator)
end

function GuaJiTaskSkinUI:setLiLianTaskInterator(interator)
end

function GuaJiTaskSkinUI:setSkinId(skinId)
    self.__skinId = skinId
end

function GuaJiTaskSkinUI:onEnable()
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

    self.__ui:show()
end

function GuaJiTaskSkinUI:onDisable()
    self:unscheduleAll()
    self.__ui:hide()
    self:hide()
end

function GuaJiTaskSkinUI:__refreshPageListSort(pageNum)

end

function GuaJiTaskSkinUI:changePage(pageNum)
    self.__currPage = pageNum

    self.__currList = self.__taskItems[pageNum]
end

function GuaJiTaskSkinUI:getBtnPresenter(pageNum, id)
    
end

function GuaJiTaskSkinUI:initHangUpTaskConfigs()
    local hangUpTaskRes = require("script.HangUpTask.hangUpTaskConfig")["挂机任务"]
    for taskId,task in pairs(hangUpTaskRes) do
        table.insert(self.__hangUpTaskConfigs,task)
    end
end

--@region 挂机相关
function GuaJiTaskSkinUI:__createHangUpTaskPage()
    self.__ui:createPage(1, "任务")

    local list = {}

    local taskList = {
        {
            name = "池边打鱼",
            stateText = "任务奖励\n经验 200\n潜能 200",
            state = 1,
        },
        {
            name = "斟茶倒水",
            stateText = "任务中\n已进行：5分钟",
            state = 2,
        },
        {
            name = "看守谷场",
            stateText = "任务奖励\n经验 280\n潜能 280",
            state = 3,
        },
        {
            name = "码头运货",
            stateText = "经验值 > 15000000",
            state = 4,
        },
        {
            name = "街边卖艺",
            stateText = "通关“鹊起无名卷”第十章",
            state = 5,
        },
    }

	local resPath = HouseSkinConfig:getGuaJiTaskSkin(self.__skinId)

    for i= 1, 5 do
        local btnUI = TaskBtnUI1:create(resPath)

        btnUI:setBtnName(taskList[i].name)
        if taskList[i].state == 1 then
            btnUI:setButtonEnable()
            btnUI:setInnerBtnName("开始任务")
            btnUI:setInnerTextVisible(false)
        elseif taskList[i].state == 2 then
            btnUI:setInnerTextVisible(true)
            btnUI:setButtonEnable()
            btnUI:setInnerBtnVisible(false)
            btnUI:setInnerText(taskList[i].stateText)
        elseif taskList[i].state == 3 then
            btnUI:setInnerTextVisible(true)
            btnUI:setButtonEnable()
            btnUI:setInnerBtnVisible(false)
            btnUI:setInnerText(taskList[i].stateText)
        else
            btnUI:setDisableText1(taskList[i].stateText)
            btnUI:setButtonDisable()
            btnUI:setDisableTextVisible2(false)
        end

        self.__ui:addItemToPage(1, btnUI)

        table.insert(list, btnUI)
    end

    self.__taskItems[1] = list

    self:__refreshPageListSort(1)

    self.__ui:pageViewJumpToTop(1)
end

function GuaJiTaskSkinUI:__refreshAllHangUpBtn()
    local list = self.__taskItems[1]

    if #list > 0 then
        for i = 1, #list do

        end
    end
end

function GuaJiTaskSkinUI:showStartHangUpTaskInfo(taskId)

end

function GuaJiTaskSkinUI:startHangUpTask(taskId)

end

function GuaJiTaskSkinUI:showHangUpDetail(taskId)

end

function GuaJiTaskSkinUI:__showDetailExceptInfo()

end

function GuaJiTaskSkinUI:hideHangUpDetail()
    self.__detailPanelShow = false
    self.__ui:setPageViewVisible(true)
    self.__ui:hideDetailPanel()
end

function GuaJiTaskSkinUI:autoStopHangUpTask(taskId)
end

function GuaJiTaskSkinUI:manualStopHangUpTask(taskId)
end

function GuaJiTaskSkinUI:hangUpTaskWork(taskId)
end

function GuaJiTaskSkinUI:hangUpTaskWorded(taskId, text)
end

function GuaJiTaskSkinUI:hangUpTaskWorkCd(taskId, text)
    self:printMsg(text)
end

function GuaJiTaskSkinUI:updateHangUpTaskBtnProgress(taskId, value)
end

function GuaJiTaskSkinUI:hangUpTaskDailyMax(taskId)
end

function GuaJiTaskSkinUI:updateHangUpTaskCD(taskId, time)

end

function GuaJiTaskSkinUI:updateHangUpTaskUI(taskId)

end

function GuaJiTaskSkinUI:showHangUpingTime(taskId, time)

    -- local timeDsc = ""

    -- local hour, min, sec = Helper:sec2timeDsc(time)
    -- if hour and hour ~= 0 then
    --     timeDsc = timeDsc .. tostring(hour) .. "小时"
    -- end
    -- if min and min ~= 0 then
    --     timeDsc = timeDsc .. tostring(min) .. "分"
    -- end

    -- if timeDsc ~= "" then
    --     timeDsc = "\n已进行：" .. timeDsc
    -- end


end
--@endregion

--@region 主动历练任务
function GuaJiTaskSkinUI:__createLilianTaskPage()
    -- --@RefType [src.app.models.Task2.LiLianTaskSystem#LiLianTaskSystem]
    -- local tasks = self.__liLianInterator:getZhuDongTasks()

    -- if MapIsEmpty(tasks) then
    --     return
    -- end
    -- self.__ui:createPage(2, "历练")

    -- local list = {}

    -- local TaskBtnUI = require("app.views.ui.TaskUI.TaskBtnUI")

    -- if self.__liLianInterator:isOpenLiLianTask() then
    --     local zTask = self.__liLianInterator:getLiLianTask()

    --     local btnUI = TaskBtnUI:create()

    --     table.insert(list, btnUI)

    --     self.__ui:addItemToPage(2, btnUI)
    -- end

    -- for i, zTask in ipairs(tasks) do
    --     local btnUI = TaskBtnUI:create()

    --     table.insert(list, btnUI)

    --     self.__ui:addItemToPage(2, btnUI)
    -- end

    -- self.__ui:pageViewJumpToTop(2)

    -- self.__taskItems[2] = list
end

function GuaJiTaskSkinUI:acceptLiLianTask(taskId)

end

function GuaJiTaskSkinUI:submitLiLianTask(taskId)

end

function GuaJiTaskSkinUI:updateSubmitLiLianTask(taskId)

end

function GuaJiTaskSkinUI:acceptZhuDongTask(taskId)

end

function GuaJiTaskSkinUI:submitZhuDongTask(taskId)

end

function GuaJiTaskSkinUI:updateSubmitZhuDongTask(taskId)

end

function GuaJiTaskSkinUI:updateLiLianTaskCount()

end

function GuaJiTaskSkinUI:updateZhuDongTaskCount(taskId)

end

--@endregion

function GuaJiTaskSkinUI:popMessage(msg)
    PopText(msg)
end

function GuaJiTaskSkinUI:printMsg(msg)
end

function GuaJiTaskSkinUI:addBgUI()
    local sprite_1 = cc.Sprite:create("Image/UI/MainUI/backgurand.jpg")
    sprite_1:setPosition(540.0000, 960.0000)
    self.__ui:addChild(sprite_1,-99)

    local sprite_2 = cc.Sprite:create("Image/UI/MainUI/changjing01.png")
    sprite_2:setAnchorPoint(0.0000, 0.0000)
    sprite_2:setPosition(0.0000, 0.0000)
    self.__ui:addChild(sprite_2,-98)
end

function GuaJiTaskSkinUI:initSkinAnimator(animResPath, animName)
	self.__ui:initSkinAnimator(animResPath, animName)
end

function GuaJiTaskSkinUI:playSkinAnim()
	self.__ui:playSkinAnim()
end

function GuaJiTaskSkinUI:updataSkinAnim(ft)
	self.__ui:updataSkinAnim(ft)
end

function GuaJiTaskSkinUI:setSkinUIVisible(visible)
    self.__ui:setSkinUIVisible(visible)
end

return GuaJiTaskSkinUI
0000000000