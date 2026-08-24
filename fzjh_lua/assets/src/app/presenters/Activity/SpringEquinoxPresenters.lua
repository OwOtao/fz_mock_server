local SpringEquinoxPresenters = class("SpringEquinoxPresenters", cc.Layer)

function SpringEquinoxPresenters:create()
    local p = SpringEquinoxPresenters:new()
    p:init()
    return p
end

function SpringEquinoxPresenters:init()
    self._actionUI = require("app.views.ui.ActionUI.SpringEquinoxUI"):create()

    self._actionUI:addTo(self)

    self._actionUI:setButton1Name("去充值")

	self._actionUI:setButton1Func(function()
		MainControllLayer:pushLayer("StoreLayer")
		local StoreLayer= MainControllLayer:getLayer("StoreLayer")
		StoreLayer:showWithAction(function()
			self:__initData(function()
                self:__initRewardUI()

                self._actionUI:setText2("本日累计充值："..self._interactor:getTotalMoney().."元")

                self._actionUI:showUI()

                self:__updateTime()
            end)
		end)
		self._actionUI:hideUI()
        self._actionUI:unscheduleAll()
	end)

    self._actionUI:setButtonBackFunc(function()
        self:hideLayer()
    end)

    self:__setRuleFunc()

    local SpringEquinox = require("app.models.Action.SpringEquinox")

    self._interactor = SpringEquinox:create()
end

function SpringEquinoxPresenters:showLayer()
    self._role = User:getRole()

    self._time = GetTime()
    
    self._interactor:setRole(self._role)
    
    self:__initData(function()
        self:__initGiftUI()

        self:__initRewardUI()

        self._actionUI:setText2("本日累计充值："..self._interactor:getTotalMoney().."元")

        self._actionUI:showUI()

        self:__updateTime()
    end)
end

function SpringEquinoxPresenters:__initData(func)
    self._interactor:init(function()
        if func then
            func()
        end
    end)
end

function SpringEquinoxPresenters:__initGiftUI()
    local giftList = self._interactor:getGiftList()

    local uiList = {}

    for i, v in ipairs(giftList) do
        local name = v.giftName
        local img = v.giftIcon
        local num = 1
        local func = function()
            PopupLayerController:showLayer("GiftInfoPresenter",function(layer)
                local dsc = ""
                local goodsList = self._interactor:getGiftGoodsInfoList(v.giftId)
                local rewardText = self._interactor:getGoodsListText(goodsList)
                if v.giftType == 1 then
                    dsc = "打开即可获得以下全部道具：\n\n"..rewardText
                elseif v.giftType == 2 then
                    dsc = "凭运气能开出以下其中1种道具：\n\n"..rewardText
                end

                local goodsIdList = {}

                for i = 1, #goodsList, 1 do
                    table.insert(goodsIdList, goodsList[i].id)
                end

                local giftData = {
                    name = v.giftName,
                    id = v.giftId,
                    icon = v.giftIcon,
                    goodsIdList = goodsIdList,
                    dsc = dsc
                }

                local giftClass = require("app.presenters.GiftInfo.Gift"):create(giftData)

                layer:setGift(giftClass)

                layer:showUI()
            end)
        end

        table.insert(uiList, {name = name, img = img, num = num, func = func})
    end

    self._actionUI:initPanelItems(uiList)
end

function SpringEquinoxPresenters:__initRewardUI()
    local rewardList = self._interactor:getRewardList()
    
    local uiList = {}

    for i, reward in ipairs(rewardList) do
        local text1 = "本轮累计充值"..tostring(reward.needMoney).."元"
        local text2 = ""

        local giftList = reward.giftList

        for i = 1, #giftList, 1 do
            local gift = self._interactor:getGiftInfoByGiftId(giftList[i].giftId)

            text2 = text2 .. gift.giftName .. "X" .. giftList[i].giftNum

            if i < #giftList then
                text2 = text2 .. "、"
            end
        end

        local btnName = "领取"

        local texture = "Image/UI/MapUI/anniu05.png"

        local enabled = true

        if tonumber(reward.state) ~= 1 then
            texture = "Image/UI/TeacherUI/anniu_ddfs.png"
            enabled = false
        end

        if tonumber(reward.state) == 2 then
            texture = "Image/UI/TeacherUI/anniu_ddfs.png"
            btnName = "已领取"
        end

        local func = function()
            self._interactor:getRewards(reward.id, function()
                self:__initData(function()
                    self:__initRewardUI()
                end)
            end)
        end
        
        table.insert(uiList, {text1 = text1, text2 = text2, enabled = enabled, btnName = btnName, texture = texture, func = func})
    end

    self._actionUI:initListView(uiList)
end

function SpringEquinoxPresenters:__updateTime(time)
    self._lastTime = nil

    if self._handle then
        self:unschedule(self._handle)
        self._handle = nil
    end

    self._handle = self:schedule(
        function()
			local nowTime = GetTime()

            local duration = Helper:getTodayRemainingTime(nowTime)

            local year, month, day, hour, minute, second = Helper:getExpiredTime(duration)

            local trueHour = hour

            if hour < 9 then
                trueHour = trueHour + 15
            else
                trueHour = trueHour - 9
            end

            local currTime = trueHour * 3600 + minute * 60 + second

            if not self._lastTime then
                self._lastTime = currTime
            end

            if currTime > self._lastTime then
                self:__initData(function()
                    self:__initRewardUI()
                    self._actionUI:setText2("本日累计充值："..self._interactor:getTotalMoney().."元")
                end)
            end

            self._lastTime = currTime

            self._actionUI:setText1(tostring(trueHour).."小时"..tostring(minute).."分"..tostring(second).."秒".."后刷新")
    	end, 0.5)
end

function SpringEquinoxPresenters:hideLayer()
    PopupLayerController:hideLayer(
        "SpringEquinoxPresenters",
        function(layer)
            self._actionUI:hideUI()
        end
    )
end

function SpringEquinoxPresenters:setText_desc(actionDesc)
    local desc = ""

    if MapIsEmpty(actionDesc) == false then
        for i, v in ipairs(actionDesc) do
            desc = desc .. v .. "\n"
        end
    end

    self._actionUI:setText_desc(desc)
end

function SpringEquinoxPresenters:setText_title(actionName)
    self._actionUI:setText_title(actionName)
end

function SpringEquinoxPresenters:initRule(ruleInfo)
	self.__ruleInfo = ruleInfo
end

function SpringEquinoxPresenters:__setRuleFunc()
	self._actionUI:setButtonRuleFunc(function()
        self:__showRule()
    end)
end

function SpringEquinoxPresenters:__showRule()
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

Helper:classDefNodeGetInstance(SpringEquinoxPresenters)

return SpringEquinoxPresenters
0