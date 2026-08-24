local TeacherBuildGuaJiPresenter = class("TeacherBuildGuaJiPresenter", cc.Layer)

local TeacherBuildResManager = require("app.models.TeacherBuildSystem.TeacherBuildResManager")

function TeacherBuildGuaJiPresenter:create()
    local p = TeacherBuildGuaJiPresenter:new()
    p:init()
    return p
end

function TeacherBuildGuaJiPresenter:init()
    self.__ui = require("app.views.ui.TeacherBuildUI.TeacherBuildGuaJiUI"):create()

    self.__ui:addTo(self)
end

function TeacherBuildGuaJiPresenter:updateLayerSkinUI(skin_config)
    if self.__ui.updateSkin then
        self.__ui:updateSkin(skin_config)
    end
end

function TeacherBuildGuaJiPresenter:showLayer()
    self.__nextTime = 0

    self.__showTime = 0

    self.__textCount = 0

    self.__taskInfo = self.__role:getTeacherBuildSystem():getGuaJiInfo()

    self.__task = self.__role:getTeacherBuildSystem():getTask(self.__taskInfo.taskId)

    self.__ui:initRichText()

    self:removeSchedule()

    local TitleLayer = MainControllLayer:getLayer("TitleLayer")

    if self.__role:getTeacherBuildSystem():isCompleteGuaJi() then
        TitleLayer:setLayerTitleName("TeacherBuildGuaJiPresenter", "日常完成")
        self:showCompleteButton()
    else
        TitleLayer:setLayerTitleName("TeacherBuildGuaJiPresenter", "日常进行中")
        self:showUnCompleteButton()
        self.__schedule =
            self:schedule(
            function(ft)
                self:__update(ft)
            end,
            0
        )
    end

    self:refreshResidueTime()

    self:showTimeText()

    self:showSpeedText()

    self:showSpeedName()

    self:showRewardTexts()

    self.__ui:show()
end

function TeacherBuildGuaJiPresenter:removeSchedule()
    if self.__schedule then
        self:unschedule(self.__schedule)
    end

    self.__schedule = nil
end

function TeacherBuildGuaJiPresenter:setRole(role)
    self.__role = role
end

function TeacherBuildGuaJiPresenter:__update(ft)
    if self.__nextTime <= self.__showTime then
        if self.__textCount == 1 then
            self.__ui:addText("")
        end
        self.__ui:addText(self:getRandomText())
        self.__nextTime = 5
        self.__showTime = 0

        self.__textCount = self.__textCount + 1
    end

    if self.__role:getTeacherBuildSystem():isCompleteGuaJi() then
        self:removeSchedule()

        local TitleLayer = MainControllLayer:getLayer("TitleLayer")
        TitleLayer:setTextTitle("日常完成")

        self:showCompleteButton()
    end

    self:refreshResidueTime()

    self:showTimeText()

    self:showSpeedText()

    self.__showTime = self.__showTime + ft
end

function TeacherBuildGuaJiPresenter:getRandomText()
    local textList = TeacherBuildResManager:getEventTextGroup()[tostring(self.__task.incidentsid)]

    local text = textList[math.random(1, #textList)]

    return text
end

function TeacherBuildGuaJiPresenter:refreshResidueTime()
    local endTime = self.__taskInfo.startTime + tonumber(self.__task.time) * 3600 - self.__taskInfo.speedUpTime

    self.__residueTime = math.max(endTime - GetTime(), 0)
end

function TeacherBuildGuaJiPresenter:showTimeText()
    local hour, min, sec = Helper:sec2timeDsc(self.__residueTime)

    self.__ui:setTimeText(hour .. "小时" .. min .. "分钟" .. sec .. "秒")
end

function TeacherBuildGuaJiPresenter:showSpeedName()
    self.__ui:setSpeedName(self.__role:getTeacherBuildSystem():getSpeedUpName() .. "：")
end

function TeacherBuildGuaJiPresenter:showSpeedText()
    self.__ui:setSpeedText(self.__role:getTeacherBuildSystem():getSpeedUp())
end

function TeacherBuildGuaJiPresenter:showRewardTexts()
    self.__ui:setRewardTexts(self.__task.awardtext)
end

function TeacherBuildGuaJiPresenter:showCompleteButton()
    self.__ui:setButton1("", false, EMPTY_FUNC)
    self.__ui:setButton3("", false, EMPTY_FUNC)
    self.__ui:setButton2(
        "完成日常",
        true,
        function()
            local awards = self.__task.awards

            self.__role:getTeacherBuildSystem():finishTeacherBuildTask(
                function(isOk, msg, data)
                    if isOk then
                        self:removeSchedule()
                        self.__ui:hide()

                        local rewardList = data.reward

                        for i,v in ipairs(rewardList) do
                            local id = v[1]
                            local num = tonumber(v[2])
                    
                            if self.__role:getTeacherBuildSystem():getCHAttrName(id) then
                                PopText("获得：" .. self.__role:getTeacherBuildSystem():getCHAttrName(id) .. "*" .. num)
                            end
                        end

                        if type(data.msg) == "string" then
                            PopText(data.msg)
                        end
                        
                        MainControllLayer:popLayer()
                    else
                        PopText(msg)
                    end
                end
            )
        end
    )
end

function TeacherBuildGuaJiPresenter:showUnCompleteButton()
    self.__ui:setButton2("", false, EMPTY_FUNC)
    self.__ui:setButton1(
        "终止日常",
        true,
        function()
            local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
            local dialog = DialogALayer:getInstance()
            dialog:hide()
            local text = "目前正在进行" .. self.__task.name .. "师门日常中，若终止将会无法获取师门日常奖励，是否需要终止终止？"
            dialog:show(text)
            dialog:setButton1(
                "确定",
                function()
                    self.__role:getTeacherBuildSystem():stopTeacherBuildTask(
                        function(isOk, msg)
                            if isOk then
                                self:removeSchedule()
                                self.__ui:hide()

                                MainControllLayer:popLayer()
                            else
                                PopText(msg)
                            end
                        end
                    )
                end
            )
            dialog:setButton2(
                "取消",
                function()
                end
            )
            dialog:setWeChatVisible(false)
        end
    )
    self.__ui:setButton3(
        "快速完成",
        true,
        function()
            PopupLayerController:showLayer(
                "TeacherBuildSpeedUpPresenter",
                function(layer)
                    layer:setRole(self.__role)
                    layer:setResidueTime(self.__residueTime)
                    layer:showLayer()
                end
            )
        end
    )
end

Helper:classDefNodeGetInstance(TeacherBuildGuaJiPresenter)
return TeacherBuildGuaJiPresenter
0000000000000000