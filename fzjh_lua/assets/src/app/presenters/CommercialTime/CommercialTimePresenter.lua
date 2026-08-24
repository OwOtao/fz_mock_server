local CommercialTimePresenter = class("CommercialTimePresenter", cc.Layer)

local function getTimeStr(time)
    if not time then
        return ""
    end
    local str = ""
    if time > 86400 then
        str = math.floor(time/86400).."天"..math.floor(time % 86400 / 3600).."时"
    elseif time > 3600 then
        str = math.floor(time/3600).."时"..math.floor(time % 3600 / 60).."分"
    elseif time > 60 then
        str = math.floor(time/60).."分"..math.floor(time % 60).."秒"
    else
        str = math.floor(time).."秒"
    end
    return str
end

local AndroidADErrorText = {
    ["广告出错"] ="广告播放失败，错误1，无法获得奖励,请稍后重试",
    ["播放错误"] ="广告播放失败，错误2，无法获得奖励,请稍后重试",
    ["广告观看不符合条件，不可发放奖励"] ="广告观看不符合条件，不可发放奖励",
    ["广告展示失败"] ="广告播放失败，错误3，无法获得奖励,请稍后重试",
    ["广告加载失败"] ="广告播放失败，错误4，无法获得奖励,请稍后重试",
    ["初始化失败"] ="广告播放失败，错误5，请重启重试",
    ["未知错误"] = "广告播放失败，错误6，无法获得奖励,请稍后重试",
}

local IosADErrorText = {
    ["初始化失败"] ="广告播放失败，错误01，请重启重试",
    ["广告加载失败"] ="广告播放失败，错误02，无法获得奖励,请稍后重试",
    ["广告展示失败"] ="广告播放失败，错误03，无法获得奖励,请稍后重试",
}

local ViewType = {
    USE_GUANYINGQUAN = 0, --使用观影券
    FREE = 1,
	PRIVILEGE = 2 --使用特权
}

local GetRewardType = {
    BAG = 0,
    EMAIL = 1
}

local IOS_REWARD_STATUS = false

function CommercialTimePresenter:create()
    local p = CommercialTimePresenter:new()
    p:init()
    return p
end

function CommercialTimePresenter:init()
    self._UI = require("app.views.ui.CommercialTimeUI.CommercialTimeUI"):create()

    self._UI:addTo(self)

    self._UI:setButtonBack(
        function()
            self:hideLayer()
        end
    )

    self._UI:setVisible(false)

    self:__setTimeRemaining("")

    self._input = require("src.app.models.CommercialTime.CommercialTime"):create()

	self._input:setRole(User:getRole())

    self._time = GetTime()
end

function CommercialTimePresenter:showLayer()
    self:initData()

    self._UI:showUI()
end

function CommercialTimePresenter:setHideCallFunc(func)
    self._backCallFunc = func
end

function CommercialTimePresenter:initData()
    self._input:init(function()
        self:initUI()

		self:update()

		if self.handle == nil then
			self.handle = self:schedule(function(ft)
				self:update(ft)
			end,1)
		end
    end)
end

function CommercialTimePresenter:initUI()
    self:__setTitle(self._input:getActionName())
    self:__setCurrencyNum(self._input:getCurrencyName().."："..self._input:getCurrencyNum().."个")
    self:__showList(self._input:getRewardInfo())
    self:__setRuleFunc()

	if self._input:isPromotionActive() then
		self._UI:setButtonActivityVisible(true)

		self._UI:setButtonActivityFunc(function()
			PopupLayerController:showLayer("CommercialTimePrivilegePresenter",function(layer)
				layer:showLayer()
				layer:setCallBack(function()
					self:initData()
				end)
			end)
		end)

		self._UI:setButtonPrivilegePosX(800)

		self._UI:setPrivilegeDescPosX(800)
	else
		self._UI:setButtonActivityVisible(false)

		self._UI:setButtonPrivilegePosX(540)

		self._UI:setPrivilegeDescPosX(540)
	end

	self._UI:setButtonPrivilegeFunc(function()
		self:__showBuyPrivilegeUI()
	end)

	if self._input:getRole():isViewingHallPrivilege() then
		self._UI:setText1Color({r = 255, g = 255, b = 255})

		self._UI:setTextRemainingWatches("本日跳过次数剩余："..tostring(self._input:getRole():getViewingHallPrivilegeRemainingWatches()))
	else
		self._UI:setText1Color({r = 255, g = 0, b = 0})

		self._UI:setTextRemainingWatches("")
	end
end

function CommercialTimePresenter:__setRuleFunc()
	self._UI:setButtonRuleFunc(function()
        self:__showRule()
    end)
end

function CommercialTimePresenter:__showRule()
	PopupLayerController:showLayer("ActionRuleUI",function(layer)
        layer:showUI()
        layer:setTextTitle("活动规则")
        layer:showPanel_1(self._input:getActionRule())
        layer:setButtonBack(function()
            PopupLayerController:hideLayer("ActionRuleUI",function(layer)
                layer:hideUI()
            end)
        end)
    end)
end

function CommercialTimePresenter:__setTitle(title)
    self._UI:setTextTitle(title)
end

function CommercialTimePresenter:__setTimeRemaining(time)
    self._UI:setText1(time)
end

function CommercialTimePresenter:__setCurrencyNum(num)
    self._UI:setText2(num)
end

function CommercialTimePresenter:__showList(list)
    self._UI:clearListView()

    if MapIsEmpty(list) == false then
        for i, v in ipairs(list) do
            local item,panel,posX
            if math.mod(i, 2) == 0 then
                panel = self._UI:getListViewLastItem()
                posX = 520
            else
                panel = self._UI:cloneItemPanel()
                self._UI:addListViewItem(panel)
                posX = 10
            end

            v.textName = v.name.."X"..v.num
            
            if v.rType == 1 then
                item = self._UI:createItem(posX)
                self._UI:initItem(item,v)
            elseif v.rType == 2 then
                item = self._UI:createItem_1(posX)
                self._UI:initItem_1(item,v)
            end

            self._UI:addPanelItem(panel, item)
            
            if v.time then
                local time = v.time
                local timeStr = getTimeStr(time)
                self._UI:setItemRemainingTime(item, timeStr)
                self._UI:setItemSchedule(item, function(ft)
                    if time <= 0 then
                        self._UI:stopItemAllSchedule(item)
                        self._input:init(function()
                            self:initUI()
                        end)
                        return
                    end 

                    local str = getTimeStr(time)
                    self._UI:setItemRemainingTime(item, str)
                    time = time - 1
                end,1)
            else
                self._UI:stopItemAllSchedule(item)
            end

            self._UI:setItemFunc(item, function()
                if self._input:checkIsViewTimesLimit() == true then
                    PopText("达到总观影上限次数")
                    return
                end
				
				local time = self._input:getCoolDownTime()

                local desc = "本次观影可获得"..v.name.."X"..v.num.."，是否继续？（提示：点击空白处可关闭此界面。）"
                if time > 0 then
                    desc = "本次观影可获得"..v.name.."X"..v.num.."，是否继续？广告冷却时间："..time.."秒（提示：点击空白处可关闭此界面。）"
                end
                local extraDesc = "（使用观影券可跳过本次广告）"
                local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
                local dialog = DialogALayer:getInstance()
                dialog:hide()
                dialog:show(desc)
                dialog:setRichText(desc)
                dialog:setButton1("前往观影", function()
					if self._input:checkIsInAdCD() == true then
						PopText("广告正在冷却...")
						return
					end

					--@desc: 当乐渠道无需观看广告，直接领取奖励
					if Game:getChannelId() == "dangle" or device.platform == "windows" then
						self:__getReward(v,ViewType.FREE)
					else
						self:__viewAD(function()
							self:__getReward(v,ViewType.FREE)
						end)
					end

                    if self.__coolDownSchedule == true then
                        dialog:unscheduleWithTag("coolDown")
                        self.__coolDownSchedule = false
                    end
                end)
                dialog:setButton2("使用观影券",function()
                    self:__useGuanYingQuan(function()
                        self:__getReward(v,ViewType.USE_GUANYINGQUAN)
                    end)

                    if self.__coolDownSchedule == true then
                        dialog:unscheduleWithTag("coolDown")
                        self.__coolDownSchedule = false
                    end
                end)

				if self._input:getRole():isViewingHallPrivilege() and self._input:getRole():getViewingHallPrivilegeRemainingWatches() > 0 then
					dialog:setButton3("使用跳过次数", function()
						self:__getReward(v,ViewType.PRIVILEGE)

						if self.__coolDownSchedule == true then
							dialog:unscheduleWithTag("coolDown")
							self.__coolDownSchedule = false
						end
					end)
					extraDesc = "（使用跳过次数/观影券可跳过本次广告）"
				end

				dialog:setWeChatVisible(false)
				dialog:setExtraDescVisible(true)
                dialog:setExtraDesc(extraDesc)

                if self._input:checkIsInAdCD() then
                    dialog:unscheduleWithTag("coolDown")
                    self.__coolDownSchedule = true
                    dialog:schedule(function()
                        local time = self._input:getCoolDownTime()
                        
                        if time <= 0 then
                            local desc = "本次观影可获得"..v.name.."X"..v.num.."，是否继续？（提示：点击空白处可关闭此界面。）"
                            dialog:setRichText(desc)
                            dialog:unscheduleWithTag("coolDown")
                            self.__coolDownSchedule = false
                            return
                        end

                        local desc = "本次观影可获得"..v.name.."X"..v.num.."，是否继续？广告冷却时间："..time.."秒（提示：点击空白处可关闭此界面。）"
                        dialog:setRichText(desc)
                    end,1,"coolDown")
                end
            end)

            self._UI:setItemBgFunc(item, function()
                if self._input:checkIsViewTimesLimit() == true then
                    PopText("达到总观影上限次数")
                    return
                end

                if v.state == false then
                    PopText("此奖励本日已兑换完毕，请明天再来")
                    return
                end
            end)
        end
    end
end

function CommercialTimePresenter:__getReward(reward, type)
    local isEmail = GetRewardType.BAG
    if self._input:checkCanGetReward(reward) == false then
        isEmail = GetRewardType.EMAIL
    end

    self._input:doReward(reward.rid, type, isEmail,function()
        self._input:init(function()
            self:initUI()
        end)
    end)
end

function CommercialTimePresenter:__useGuanYingQuan(callback)
    if self._input:getCurrencyNum() <= 0 then
        PopText("观影劵不足，使用失败")
        return
    end

    if callback then
        callback()
    end
end

function CommercialTimePresenter:__viewAD(callback)
    local function _func()
        if self._input:checkIsInAdCD() == true then
            PopText("广告正在冷却...")
            return
        end

        -- 显示广告等待界面
        local waitingLayer = WaitingLayer:createInRunningScene()
        local delayActionTag = self:delayFunc(5, function()
            if waitingLayer then
                waitingLayer:hideAndRemoveSelf() -- 隐藏并且删除自身
                waitingLayer = nil
            end

            if self.__showADLayer then
                local ADLayer = PopupLayerController:getLayer("ADLayer")
                ADLayer:setButtonBackEnabled(true)
            end
        end)

        IOS_REWARD_STATUS = false -- 每次点击广告的时候重置状态
       
        -- add by XiaoZhiWei 2018/05/30 16:13:35 Unity 广告
        -- ios广告返回事件类型
        -- 初始化失败
        -- 广告加载失败
        -- 点击广告
        -- 广告展示开始
        -- 广告展示完成
        -- 广告展示失败
        local function UnityAds()
            SdkMethod:UnityAds_SetCallback(
            function(eventName)
                -- 如果回调有响应, 则停止等待界面
                if waitingLayer then
                    self:stopActionByTag(delayActionTag)
                    waitingLayer:hideAndRemoveSelf() -- 隐藏并且删除自身
                    waitingLayer = nil
                end

                pcall(function()
                    if eventName == "unityAdsVideoCompleted" then
                        if callback then
                            callback()
                        end
                    elseif eventName == "广告展示完成" then
                        if callback then
                            callback()
                        end
                    elseif eventName == "广告发放奖励" then
                        IOS_REWARD_STATUS = true
                    elseif eventName == "广告关闭完成" then
                        if IOS_REWARD_STATUS == true and callback then
                            callback()
                        end
                    elseif IosADErrorText[eventName] then
                       PopText(IosADErrorText[eventName])
                    else
                    end
                end, function(msg) PopText("msg = "..tostring(msg)) end)
            end)
            SdkMethod:UnityAds_ShowVideo()
        end
        --安卓广告返回事件类型
        -- 广告关闭
        -- 广告点击
        -- 广告出错
        -- 广告完成
        -- 可发放奖励
        -- 广告跳过
        -- 播放错误
        -- 广告观看不符合条件，不可发放奖励
        -- 广告被打开
        -- 广告展示失败
        -- 关闭广告
        -- 广告加载成功
        -- 展示广告
        -- 广告加载失败
        -- 点击广告
        --新版事件类型
        -- 初始化成功
        -- 初始化失败
        -- 广告加载成功
        -- 广告加载失败
        -- 广告点击成功
        -- 广告展示开始
        -- 广告展示完成
        -- 广告展示失败
        -- 广告关闭完成
        -- 广告发放奖励

        -- 广告页面打开
        -- 广告页面关闭
        -- 未知错误
        local function UPLTVAds()
            SdkMethod:UPLTV_SetCallback(function(eventName)
                -- 如果回调有响应, 则停止等待界面
                if waitingLayer then
                    self:stopActionByTag(delayActionTag)
                    waitingLayer:hideAndRemoveSelf() -- 隐藏并且删除自身
                    waitingLayer = nil
                end

                if self.__showADLayer == true then
                    local ADLayer = PopupLayerController:getLayer("ADLayer")
                    ADLayer:setHideCallback()
                    ADLayer:hideLayer()
                    self.__showADLayer = nil
                end

                pcall(function()
                    if eventName == "可发放奖励" then
                        if callback then
                            callback()
                        end
                    elseif eventName == "广告发放奖励" then
                        if callback then
                            callback()
                        end 
                    elseif AndroidADErrorText[eventName] then
                        PopText(AndroidADErrorText[eventName])
                    else
                    end
                end, function(msg) PopText("msg = "..tostring(msg)) end)
            end)
            if SdkMethod:UPLTV_isReady() == true then
                SdkMethod:UPLTV_show("android_ads")
            else
                PopText("广告还没有准备好")
            end
        end

        -- add by XiaoZhiWei 2018/05/30 16:19:51 判断是用哪种广告
        if device.platform == "android" then 
             -- 显示网页
            PopupLayerController:showLayer("ADLayer",function(layer)
                layer:setButtonBackEnabled(false)
                layer:setHideCallback(function()
                    if callback then
                        callback()
                    end
                    self.__showADLayer = nil
                end)
                layer:showLayer()
                self.__showADLayer = true
            end)

            if Game:isOpenUPLTVAds() == false then --未接广告直接小树林
                if waitingLayer then
                    self:stopActionByTag(delayActionTag)
                    waitingLayer:hideAndRemoveSelf() -- 隐藏并且删除自身
                    waitingLayer = nil
                end

                if self.__showADLayer then
                    local ADLayer = PopupLayerController:getLayer("ADLayer")
                    ADLayer:setButtonBackEnabled(true)
                end
            else
                UPLTVAds()
            end   
        else
            UnityAds()
        end
    end

    -- 只能在设备网络处于wifi状态下才能看广告
    if SdkMethod:GetNetWorkType() == "WIFI" then
        _func()
    else
        ButtonPopLayer:createCustomInRunningScene("HIR检测到当前未在wifi环境下,观看广告需要消耗大量流量,是否使用流量看广告?",
        "看广告",
        function()
            _func()
        end,
        "不看了",
        function()end)
        return
    end
end

function CommercialTimePresenter:hideLayer()
    PopupLayerController:hideLayer(
        "CommercialTimePresenter",
        function(layer)
			if self.handle then
				self:unschedule(self.handle)
				self.handle = nil
			end

            self._UI:hideUI()
            if self._backCallFunc then
                self._backCallFunc()
            end

            if self.__coolDownSchedule == true then
                local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
                local dialog = DialogALayer:getInstance()
                dialog:unscheduleWithTag("coolDown")
                dialog:hide()
                self.__coolDownSchedule = false
            end
        end
    )
end

function CommercialTimePresenter:update(ft)
    if not self._time then
        return
    end

    local nowTime = GetTime()

    if Helper:diffWithDate(self._time,nowTime) ~= 0 then
        self:initData()
        self._time = GetTime()
    end
        
    local duration = Helper:getTodayRemainingTime(nowTime)

    local year, month, day, hour, minute, second = Helper:getExpiredTime(duration)

    self:__setTimeRemaining("剩余时间："..tostring(hour).."小时"..tostring(minute).."分")

	if self._input:getRole():isViewingHallPrivilege() then
		local privilegeTime = self._input:getRole():getViewingHallPrivilegeExpiredTime() - nowTime

		day = math.floor( privilegeTime / (3600 * 24))

		hour = math.floor((privilegeTime / 3600) % 24)
		
		minute = math.floor((privilegeTime / 60) % 60)

    	self._UI:setTextPrivilegeTime("特权剩余时间："..tostring(day).."天"..tostring(hour).."小时"..tostring(minute).."分")
	else
		self._UI:setTextPrivilegeTime("未拥有观影堂特权")
	end
end

function CommercialTimePresenter:__showBuyPrivilegeUI()
	PopupLayerController:showLayer("CommercialTimePrivilegeComfirmPresent", function(layer)
		local showData = 
		{
			title = "请确定购买",
			text1 = "确定购买可获得【观影堂特权】",
			text2 = "具体说明\n1.每日8次跳过广告直接领取奖励次数。\n2.每购买一次，持续时间为14天。  ",
			text3 = "将花费：18元/次",
			imagePath = "Image/UI/StoreUI/guanying.png",
			func1 = function()
				layer:hideLayer()

				self._input:buyPrivilege(function()
					self:initData()
				end)
			end,
			func2 = function()
				layer:hideLayer()
			end,
		}

		layer:showLayer(showData)
	end)
end

Helper:classDefNodeGetInstance(CommercialTimePresenter)

return CommercialTimePresenter
0000000000