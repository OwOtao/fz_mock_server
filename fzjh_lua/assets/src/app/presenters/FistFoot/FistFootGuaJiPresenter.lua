local FistFootGuaJiPresenter = class("FistFootGuaJiPresenter", cc.Layer)

local FistFootResManager = require("app.models.FistFootSystem.FistFootResManager")

local SkillClassifyManager = require("app.FightSystem.FightSkill.SkillClassifyManager")

local FistFootConst = require(("app.models.FistFootSystem.FistFootConst"))

function FistFootGuaJiPresenter:create()
    local p = FistFootGuaJiPresenter:new()
    p:init()
    return p
end

function FistFootGuaJiPresenter:init()
    self.__ui = require("app.views.ui.FistFootUI.FistFootGuaJiUI"):create()

    self.__ui:addTo(self)
end

function FistFootGuaJiPresenter:showLayer()
    self.__nextTime = 0

    self.__showTime = 0

    self.__textCount = 0

    self.__taskInfo = self.__role:getFistFootSystem():getGuaJiInfo()

    self.__task = self.__role:getFistFootSystem():getTask(self.__taskInfo.taskId)

    self.__ui:initRichText()

    self:removeSchedule()

    local TitleLayer = MainControllLayer:getLayer("TitleLayer")

    if self.__role:getFistFootSystem():isCompleteGuaJi() then
        TitleLayer:setLayerTitleName("FistFootGuaJiPresenter", "修行完成")
        self:showCompleteButton()
    else
        TitleLayer:setLayerTitleName("FistFootGuaJiPresenter", "修行中")
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

function FistFootGuaJiPresenter:removeSchedule()
    if self.__schedule then
        self:unschedule(self.__schedule)
    end

    self.__schedule = nil
end

function FistFootGuaJiPresenter:setRole(role)
    self.__role = role
end

function FistFootGuaJiPresenter:__update(ft)
    if self.__nextTime <= self.__showTime then
        if self.__textCount == 1 then
            self.__ui:addText("")
        end
        self.__ui:addText(self:getRandomText())
        self.__nextTime = 5
        self.__showTime = 0

        self.__textCount = self.__textCount + 1
    end

    if self.__role:getFistFootSystem():isCompleteGuaJi() then
        self:removeSchedule()

        local TitleLayer = MainControllLayer:getLayer("TitleLayer")
        TitleLayer:setTextTitle("修行完成")

        self:showCompleteButton()
    end

    self:refreshResidueTime()

    self:showTimeText()

    self:showSpeedText()

    self.__showTime = self.__showTime + ft
end

function FistFootGuaJiPresenter:getRandomText()
    local textList = FistFootResManager:getEventTextGroup()[tostring(self.__task.incidentsid)]

    local text = textList[math.random(1, #textList)]

    return text
end

function FistFootGuaJiPresenter:refreshResidueTime()
    local endTime = self.__taskInfo.startTime + tonumber(self.__task.time) * 3600 - self.__taskInfo.speedUpTime

    self.__residueTime = math.max(endTime - GetTime(), 0)
end

function FistFootGuaJiPresenter:showTimeText()
    local hour, min, sec = Helper:sec2timeDsc(self.__residueTime)

    self.__ui:setTimeText(hour .. "小时" .. min .. "分钟" .. sec .. "秒")
end

function FistFootGuaJiPresenter:showSpeedName()
    self.__ui:setSpeedName(User:getRole():getCHAttrName("accpoint") .. "：")
end

function FistFootGuaJiPresenter:showSpeedText()
    self.__ui:setSpeedText(self.__role:getFistFootSystem():getAccpoint())
end

function FistFootGuaJiPresenter:showRewardTexts()
    self.__ui:setRewardTexts(self.__task.awardtext)
end

function FistFootGuaJiPresenter:showCompleteButton()
    self.__ui:setButton1("", false, EMPTY_FUNC)
    self.__ui:setButton3("", false, EMPTY_FUNC)
    self.__ui:setButton2(
        "完成修行",
        true,
        function()
            local awards = self.__task.awards
            local items = {}
            local bagEnough = 0
            for i, award in ipairs(awards) do
                if award[1] == FistFootConst.AwardType.Item then
                    if items[award[2]] then
                        items[award[2]] = tonumber(award[3]) + items[award[2]]
                    else
                        items[award[2]] = tonumber(award[3])
                    end
                end
            end

            if self.__role:checkCanBuyTwoOrMoreThings(items, false) == true then
                bagEnough = 1
            end

            self.__role:getFistFootSystem():finishFistTask(
                bagEnough,
                function(isOk, msg, data)
                    if isOk then
                        local awardList = data.reward
                        for i, v in ipairs(awardList) do
                            if v[1] == FistFootConst.AwardType.Exp then
                                local name = SkillClassifyManager:getClassifyInfo(tostring(v[2])).thirdTypeName
                                PopText("获得：" .. name .. "阅历*" .. v[3])
                            elseif v[1] == FistFootConst.AwardType.RefExp then
                                PopText("获得：潜思经验*" .. v[2])
                            elseif v[1] == FistFootConst.AwardType.Item then
                                if bagEnough == 1 then
                                    local name = Item:getOneItemByKey(v[2]).name
                                    PopText("获得：" .. name .. "*" .. v[3])
                                else
                                    PopText("背包空间不足，已发放至邮箱，请及时领取。")
                                end
                            elseif v[1] == FistFootConst.AwardType.Net then
                                local name = User:getRole():getCHAttrName(v[2])
                                PopText("获得：" .. name .. "*" .. v[3])
                            end
                        end

                        if data.msg then
                            PopText(data.msg)
                        end

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
end

function FistFootGuaJiPresenter:showUnCompleteButton()
    self.__ui:setButton2("", false, EMPTY_FUNC)
    self.__ui:setButton1(
        "终止修行",
        true,
        function()
            local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
            local dialog = DialogALayer:getInstance()
            dialog:hide()
            local text = "目前正在进行" .. self.__task.name .. "中，若终止修行会无法获取修行奖励，是否需要终止修行？"
            dialog:show(text)
            dialog:setButton1(
                "确定",
                function()
                    self.__role:getFistFootSystem():stopFistTask(
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
                "SpeedUpGuaJiPresenter",
                function(layer)
                    layer:setRole(self.__role)
                    layer:setResidueTime(self.__residueTime)
                    layer:showLayer()
                end
            )
        end
    )
end

Helper:classDefNodeGetInstance(FistFootGuaJiPresenter)
return FistFootGuaJiPresenter
000000000000000