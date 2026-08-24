local HangUpTaskStartInfoPresenter = class("HangUpTaskStartInfoPresenter", LayerEx)

local CalPlayerCurrExceptReward= require("app.models.Task2.HangUpReward.CalPlayerCurrExceptReward")

function HangUpTaskStartInfoPresenter:create()
    local p = HangUpTaskStartInfoPresenter.new()
    p:__init()
    return p
end

function HangUpTaskStartInfoPresenter:__init()
    --@RefType [SixInfoAndTwoBtnShowUI]
    self.__ui = require("app.views.ui.Dialog.SixInfoAndTwoBtnShowUI"):create()

    self.__ui:addTo(self)

    self.__ui:setPnlBackgroundFunc(
        function()
            self:hideLayer()
        end
    )

    self:setVisible(false)
end

function HangUpTaskStartInfoPresenter:setHangUpSystem(system)
    --@RefType [src.app.models.Task2.HangUpTaskSystem#HangUpTaskSystem]
    self.__hangUpSystem = system
end

function HangUpTaskStartInfoPresenter:setTaskId(taskId)
    self.__taskId = taskId
end

function HangUpTaskStartInfoPresenter:__initInfo()
    local playerHangUpTask = self.__hangUpSystem:getHangUpTask(self.__taskId)

    --@RefType [src.app.models.Task2.HangUpReward.CalPlayerCurrExceptReward#CalPlayerCurrExceptReward]
    local calReawrdClass = CalPlayerCurrExceptReward:create()
    calReawrdClass:setPlayer(self.__hangUpSystem:getPlayer())
    calReawrdClass:setPlayerHangUpTask(playerHangUpTask)
    local rewards = calReawrdClass:getRewards()

    self.__ui:setTextVisible1(true)
    self.__ui:setTextInfo1("人物评价：", self.__hangUpSystem:getPlayer():getKongfuDsc())

    self.__ui:setTextVisible2(true)
    self.__ui:setTextInfo2("福缘：", self.__hangUpSystem:getPlayer():getFinalAttr("luck"))

    self.__ui:setTextVisible3(true)
    if self.__hangUpSystem:currIsYaShiAddition() then
        local TaskConst = require("app.models.Task2.TaskConst")
        self.__ui:setTextInfo3("江湖雅士：", string.format("增加%s%%基础收益", Helper:getRoundNumber(TaskConst:getHangUpTaskConfigValue("yaShiAwardExpAdd") * 100)))
    else
        self.__ui:setTextInfo3("江湖雅士：", "需在商城购买")
    end

    for i = 4, 6 do
        --@RefType [src.app.models.Task2.TaskAttrReward#TaskAttrReward]
        local reward = rewards[i - 3]

        if reward == nil then
            self.__ui["setTextVisible" .. i](self.__ui, false)
        else
            self.__ui["setTextVisible" .. i](self.__ui, true)

            self.__ui["setTextInfo" .. i](self.__ui, reward:getNameText() .. "：", Helper:mathFloor(reward:getValue() * 3600) .. "/小时")
        end
    end
end

--@desc:
--@author:Seven
--@time:2021-09-10 15:59:40
--@task: [src.app.models.Task2.PlayerHangUpTask#PlayerHangUpTask]
function HangUpTaskStartInfoPresenter:showLayer()
    self:__initInfo()
    self.__ui:setButtonUpVisible(true)
    self.__ui:setButtonUpFunction(
        "开始任务",
        function()
            self.__hangUpSystem:startHangUpTask(self.__taskId)
            self:hideLayer()
        end
    )

    self.__ui:setButtonBottomVisible(true)
    self.__ui:setButtonBottomFunction(
        "取消",
        function()
            self:hideLayer()
        end
    )

    self:show()
end

function HangUpTaskStartInfoPresenter:hideLayer()
    PopupLayerController:hideLayer(
        "HangUpTaskStartInfoPresenter",
        function(layer)
            self:hide()
        end
    )
end

Helper:classDefNodeGetInstance(HangUpTaskStartInfoPresenter)
return HangUpTaskStartInfoPresenter
000000000000