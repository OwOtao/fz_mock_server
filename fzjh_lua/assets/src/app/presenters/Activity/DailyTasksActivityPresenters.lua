local DailyTasksActivityPresenters = class("DailyTasksActivityPresenters", cc.Layer)

function DailyTasksActivityPresenters:create()
    local p = DailyTasksActivityPresenters:new()
    p:init()
    return p
end

function DailyTasksActivityPresenters:init()
    self._actionUI = require("app.views.ui.ActionUI.DailyTasksActivityUI"):create()

    self._actionUI:addTo(self)

    local DailyTasksActivity = require("app.models.Action.DailyTasksActivity")

    self._actionUI:setButtonBack(
        function()
            self:hideLayer()
        end
    )

    self:__setRuleFunc()

    self._interactor = DailyTasksActivity:create()
end

function DailyTasksActivityPresenters:showLayer()
    self._interactor:setRole(User:getRole())
    
    self:__initData()

    self._time = GetTime()

    self:__updateTime()
end

function DailyTasksActivityPresenters:__initData()
    self._interactor:init(function()
        self:__initUI()
        self._actionUI:showUI()
    end)
end

function DailyTasksActivityPresenters:__initUI()
    self._actionUI:setTextDesc(self._interactor:getActionDesc())
    self._actionUI:setTextTitle(self._interactor:getActionName())
    self._actionUI:setTextStr(1,"当前积分："..tostring(self._interactor:getScore()).."积分")
    self._actionUI:setHongDianVisible(self._interactor:getRewardState())

    self:__showTaskList()
    self.__showList = 1

    self._actionUI:setTitle_1Func(function()
        self:__showTaskList()
        self.__showList = 1
    end)

    self._actionUI:setTitle_2Func(function()
        self:__showRewardList()
        self.__showList = 2
    end)
end

function DailyTasksActivityPresenters:__showTaskList()
    local list = self._interactor:getTaskInfo()
    local uiList = {}

    for k,v in pairs(list) do
        local taskInfo = {}
        local id = v.tid
        local state = v.state
        local task = self._interactor:getTaskConfig(v.tid)
        local text1 = task.name
        local text2 = task.dsc
        local text3 = "可获得积分："..task.points.."分"
        local loadTexture = "Image/UI/ActionUI/incomplete.png"

        if v.state == 1 then
            loadTexture = "Image/UI/ActionUI/complete.png"
        end

        table.insert(uiList, {id = id, state = state, text1 = text1, text2 = text2, text3 = text3, loadTexture = loadTexture})
    end

    table.sort(uiList,function(a,b)
        if a.state > b.state then
            return false
        elseif a.state == b.state then
            if a.id < b.id then
                return true
            else
                return false 
            end
        else
            return true
        end
    end)

    self._actionUI:showPanelItem_1List(uiList)
    self._actionUI:setTitle_1BackGroundColorOpacity(255)
    self._actionUI:setTitle_2BackGroundColorOpacity(0)
    self._actionUI:setTitle_1Visible(true)
    self._actionUI:setTitle_2Visible(false)
    self._actionUI:setTitle_1Enable(false)
    self._actionUI:setTitle_2Enable(true)
end

function DailyTasksActivityPresenters:__showRewardList()
    local list = self._interactor:getRewardList()
    local uiList = {}

    for i, v in ipairs(list) do
        local text1 = v.grade.."积分"
        local text2 = self._interactor:getRewardText(v.rid)
        local loadTexture = "Image/UI/TaskUI/anniu.png"
        local btnName = "领取"

        if v.state == 2 then
            loadTexture = "Image/UI/TaskUI/anniuhui.png"
            btnName = "已领取"
        end

        if v.state == 0 then
            loadTexture = "Image/UI/TaskUI/anniuhui.png"
        end

        local func = function()
            if v.state == 0 then
                PopText("今日积分不足，不可领取")
                return
            elseif v.state == 2 then
                PopText("此奖励已领取")
                return
            end

            local rewards = self._interactor:getReward(v.rid)
            local isTrue = self._interactor:checkBagCanGetReward(rewards)
            local isEmail = not isTrue

            self._interactor:doReward(v.rid, isEmail, function()
                self._interactor:init(function()
                    self:__showRewardList()
                    self._actionUI:setHongDianVisible(self._interactor:getRewardState())
                end)
            end)
        end

        local func1 = function()
            PopupLayerController:showLayer("GoodsInfoMainPresenter",function(layer)
                layer:showLayer(self._interactor:getReward(v.rid))
            end)
        end

        table.insert(uiList, {text1 = text1, text2 = text2, loadTexture = loadTexture, btnName = btnName, func = func, func1 = func1})
    end

    self._actionUI:showPanelItemList(uiList)
    self._actionUI:setTitle_1BackGroundColorOpacity(0)
    self._actionUI:setTitle_2BackGroundColorOpacity(255)
    self._actionUI:setTitle_2Visible(true)
    self._actionUI:setTitle_1Visible(false)
    self._actionUI:setTitle_2Enable(false)
    self._actionUI:setTitle_1Enable(true)
end

function DailyTasksActivityPresenters:__updateTime(time)
    if self.__handle then
        self:unschedule(self.__handle)
        self.__handle = nil
    end

    self.__handle = self:schedule(function()
        local nowTime = GetTime()

        if Helper:diffWithDate(self._time, nowTime) ~= 0 then
            self:__initData()
            self._time = GetTime()
        end
        local duration = Helper:getTodayRemainingTime(nowTime)

        local year, month, day, hour, minute, second = Helper:getExpiredTime(duration)

        self._actionUI:setTextStr(2, "刷新剩余时间"..tostring(hour).."小时"..tostring(minute).."分"..tostring(second).."秒")
    end,0.1)
end

function DailyTasksActivityPresenters:hideLayer()
    PopupLayerController:hideLayer(
        "DailyTasksActivityPresenters",
        function(layer)
            self._actionUI:hideUI()

            if self.__handle then
                self:unschedule(self.__handle)
                self.__handle = nil
            end
        end
    )
end

function DailyTasksActivityPresenters:initRule(ruleInfo)
	self.__ruleInfo = ruleInfo
end

function DailyTasksActivityPresenters:__setRuleFunc()
	self._actionUI:setButtonRuleFunc(function()
        self:__showRule()
    end)
end

function DailyTasksActivityPresenters:__showRule()
	PopupLayerController:showLayer("ActionRuleUI",function(layer)
        layer:showUI()
        layer:setTextTitle("活动规则")
        layer:showPanel_1(self.__ruleInfo)
        layer:setButtonBack(function()
            PopupLayerController:hideLayer("ActionRuleUI",function(layer)
                layer:hideUI()
            end)
        end)
    end)
end

Helper:classDefNodeGetInstance(DailyTasksActivityPresenters)

return DailyTasksActivityPresenters
000000