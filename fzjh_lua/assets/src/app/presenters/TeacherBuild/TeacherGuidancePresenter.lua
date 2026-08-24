local TeacherGuidancePresenter = class("TeacherGuidancePresenter", cc.Layer)

function TeacherGuidancePresenter:create()
    local p = TeacherGuidancePresenter:new()
    p:init()
    return p
end

function TeacherGuidancePresenter:init()
    self.__ui = require("app.views.ui.TeacherBuildUI.TeacherGuidanceUI"):create()

    self.__ui:addTo(self)
end

function TeacherGuidancePresenter:setInput(input)
    self.__interactor = input
end

function TeacherGuidancePresenter:showLayer()
    local titleLayer = MainControllLayer:getLayer("TitleLayer")
    titleLayer:setSetUpButtonName("规则")
    titleLayer:setButton_setupFunc(
        function()
            PopupLayerController:showLayer(
                "ActionRuleUI",
                function(layer)
                    layer:showUI()
                    layer:setTextTitle("规则")
                    layer:showPanel_1(
                        "1、师门指点是针对门派弟子在修炼隐脉时的专属提速方式，经过指点后可以在修炼隐脉时获得更高的修炼效率。\n2、每周一0点会根据少侠当前师门名衔自动获取对应的师门指点次数，师门名衔越高，指点次数越多，指点效果也越好。\n3、若出现特殊回档的情况，师门指点次数都会通过邮件进行返还，领取时不得超过当周指点次数最大值。\n4、提升师门名衔后，师门指点次数和效果将于下周一0点才会刷新。\n5、每周使用的师门指点次数，不得超出当周师门名衔对应最大值的两倍，达到两倍后则无法进行指点。\n6、传承、重置、离开师门都会清空当周的师门指点次数。"
                    )
                    layer:setButtonBack(
                        function()
                            PopupLayerController:hideLayer(
                                "ActionRuleUI",
                                function(layer)
                                    layer:hideUI()
                                end
                            )
                        end
                    )
                end
            )
        end
    )

    if self.__handle then
        self:unschedule(self.__handle)
        self.__handle = nil
    end

    if self.__animHandle then
        self:unschedule(self.__animHandle)
        self.__animHandle = nil
    end

    self:initUI()

    self.__enterTime = GetTime()

    self.__ui:show()
end

local function getTimeStr(time)
    local hours = math.floor(time / 3600)
    local minutes = math.floor((time % 3600) / 60)
    local seconds = math.floor(time % 60)

    return hours .. "时" .. minutes .. "分" .. seconds .. "秒"
end

function TeacherGuidancePresenter:initUI()
    self.__ui:setDscText(GameConst:getDefaultValue("teacherGuidance_dsc"))
    self.__ui:setTouXianText("当前师门名衔：" .. self.__interactor:getFeatClassName())
    self.__ui:setButtonFunc(
        function()
            if self.__interactor:isIdleState() then
                PopText("当前不在修炼状态，无法进行指点")
                return
            end

            if not Helper:isThisWeek(self.__enterTime, GetTime()) then
                return self.__interactor:init(
                    function()
                        self.__enterTime = GetTime()

                        self:refreshUI()

                        PopText("师门指点次数已刷新，请重新进行操作")
                    end
                )
            end

            local count = self.__interactor:getGuidanceCount()

            if count <= 0 then
                -- 因为要服务器触发回档逻辑，因此还是需要通知服务器
                self.__interactor:giveAdvice(
                    function()
                        --@desc 正常此处应该是不会运行，除非卡到了服务器收到消息时刚好跨了周期刷新
                        PopText("指点成功")
                        self:refreshUI()
                    end,
                    function(failMsg)
                        PopText(failMsg)
                    end
                )
            else
                local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")

                local dialog = DialogALayer:getInstance()

                local reduceTime = self.__interactor:getReduceTime()
                local remainingTime = self.__interactor:getRemainingTime()

                dialog:show("本次请求指点可减少" .. getTimeStr(reduceTime) .. "，目前修炼剩余时间为" .. getTimeStr(remainingTime) .. "。成功指点后会消耗一次师门指点次数，是否请求指定？")
                dialog:setButton1(
                    "确定",
                    function()
                        self.__interactor:giveAdvice(
                            function()
                                PopText("指点成功")
                                self:refreshUI()
                            end,
                            function(failMsg)
                                PopText(failMsg)
                            end
                        )
                    end
                )

                dialog:setButton2(
                    "取消",
                    function()
                        dialog:hide()
                    end
                )

                dialog:setWeChatVisible(false)
            end

            -- PopText("指点次数已耗尽，无法指点解惑")
        end
    )

    local reduceTime = self.__interactor:getReduceTime()

    self.__ui:setReduceTimeText("本次指点可减少时间：" .. getTimeStr(reduceTime))

    self:refreshUI()

    self.__handle =
        self:schedule(
        function(ft)
            self:updateTime()
        end,
        1
    )
end

function TeacherGuidancePresenter:refreshUI()
    local isIdleState = self.__interactor:isIdleState()

    self.__ui:setNoStateTextVisible(isIdleState)
    self.__ui:setStateVisible(not isIdleState)
    self.__ui:setGuidanceCountText("本周剩余指点次数：" .. tostring(self.__interactor:getGuidanceCount()))

    if isIdleState == false then
        if self.__interactor:isBreakThroughState() then
            self.__ui:setStateText("当前修炼情况：破境")
        elseif self.__interactor:isAcupointActivate() then
            self.__ui:setStateText("当前修炼情况：冲脉")
        end

        if not self.__animHandle then
            self.__animator = self.__ui:initAnimator()
            self.__animator:play("jingmai", true)

            self.__animHandle =
                self:schedule(
                function(ft)
                    self.__animator:update(ft)
                end,
                0
            )
        end

        self.__ui:setStateTimeText(getTimeStr(self.__interactor:getRemainingTime()))
    end
end

function TeacherGuidancePresenter:updateTime()
    if self.__interactor:isIdleState() == false then
        self.__interactor:refreshState()
        local time = self.__interactor:getRemainingTime()
        if time <= 0 then
            self.__ui:setNoStateTextVisible(true)
            self.__ui:setStateVisible(false)

            if self.__handle then
                self:unschedule(self.__handle)
                self.__handle = nil
            end

            if self.__animHandle then
                self:unschedule(self.__animHandle)
                self.__animHandle = nil
            end
        else
            self.__ui:setStateTimeText(getTimeStr(self.__interactor:getRemainingTime()))
        end
    else
        self.__ui:setNoStateTextVisible(true)
        self.__ui:setStateVisible(false)

        if self.__handle then
            self:unschedule(self.__handle)
            self.__handle = nil
        end

        if self.__animHandle then
            self:unschedule(self.__animHandle)
            self.__animHandle = nil
        end
    end
end

Helper:classDefNodeGetInstance(TeacherGuidancePresenter)
return TeacherGuidancePresenter
0