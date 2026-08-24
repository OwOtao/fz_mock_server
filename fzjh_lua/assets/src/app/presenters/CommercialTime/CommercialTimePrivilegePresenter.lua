local CommercialTimePrivilegePresenter = class("CommercialTimePrivilegePresenter", cc.Layer)

local resConfig = require("script.activity.viewingHallactivity")["Sheet1"].viewingHallactivity

local RewardStatus = {
    LOCKED = 0, --未解锁
    UNLOCKED_UNCLAIMED = 1, --已解锁未领取
	CLAIMED = 2 --已领取
}

function CommercialTimePrivilegePresenter:create()
    local p = CommercialTimePrivilegePresenter:new()
    p:init()
    return p
end

function CommercialTimePrivilegePresenter:init()
    self.__ui = require("app.views.ui.CommercialTimeUI.CommercialTimePrivilegeUI"):create()

    self.__ui:addTo(self)

    self.__ui:setButtonBack(
        function()
            self:hideLayer()
        end
    )

	self:__setRuleFunc()

    self.__ui:setVisible(false)
end

function CommercialTimePrivilegePresenter:showLayer()
	self.__callback = nil
	
	self.__role = User:getRole()

	self:__initUI()

	self.__ui:showUI()
end

function CommercialTimePrivilegePresenter:setCallBack(allback)
	self.__callback = allback
end

function CommercialTimePrivilegePresenter:__initUI()
	HttpManagerEx:getViewingHallPrivilegeInfo(function(status, errcode, errmsg, data)
		if status == 200 and errcode == 0 then
			self.__ui:setTextTitle(data.act_name)

			self.__ruleInfo = ""
			if MapIsEmpty(data.rule_desc) == false then
				for i,desc in ipairs(data.rule_desc) do
					self.__ruleInfo = self.__ruleInfo .. desc .."\n"
				end
			end

			self.__ui:setTextDsc("活动时间："..data.detail_time)

			self.__ui:setTextPrivilege("特权说明：\n"..data.detail_desc[1])

			self.__ui:setTextExtra("RED惊喜大升级：\n"..data.detail_desc[2])

			self.__ui:setTextRuler("活动规则：\n"..data.detail_desc[3].."\n"..data.detail_desc[4])

			self.__role:setViewingHallPrivilegeExpiredTime(data.privilege_expired_time)
			
			self.__ui:setTextPrivilegeTimes("本角色活动期间内已购买“观影堂特权”次数："..data.buy_times)

			self:__setButtons(data.status)

			self:__update()

			if self.handle == nil then
				self.handle = self:schedule(function(ft)
					self:__update(ft)
				end,1)
			end
		else
			PopText(errmsg)
		end
	end,IS_SHOW_WAITING)
end

function CommercialTimePrivilegePresenter:__update()
	if self.__role:isViewingHallPrivilege() then
		local privilegeTime = self.__role:getViewingHallPrivilegeExpiredTime() - GetTime()

		local day = math.floor( privilegeTime / (3600 * 24))

		local hour = math.floor((privilegeTime / 3600) % 24)
		
		local minute = math.floor((privilegeTime / 60) % 60)

    	self.__ui:setTextExpiredTime("本角色“观影堂特权”持续时间为："..tostring(day).."天"..tostring(hour).."小时"..tostring(minute).."分")
	else
		self.__ui:setTextExpiredTime("")
	end
end

function CommercialTimePrivilegePresenter:__setButtons(status)
	if status == RewardStatus.LOCKED then
		self.__ui:setButtonExtraName("未达到领取条件")

		self.__ui:setButtonExtraPosX(280)

		self.__ui:setButtonExtraEnable(false)
		
		self.__ui:setPrivilegeDescVisible(true)
		
		self.__ui:setButtonPrivilegeVisible(true)
	elseif status == RewardStatus.UNLOCKED_UNCLAIMED then
		self.__ui:setButtonExtraName("领取加送"..resConfig.days.."天")

		self.__ui:setButtonExtraPosX(280)

		self.__ui:setButtonExtraEnable(true)
		
		self.__ui:setPrivilegeDescVisible(true)
		
		self.__ui:setButtonPrivilegeVisible(true)
	elseif status == RewardStatus.CLAIMED then
		self.__ui:setButtonExtraName("已领取加送天数")

		self.__ui:setButtonExtraPosX(540)

		self.__ui:setButtonExtraEnable(false)
		
		self.__ui:setPrivilegeDescVisible(false)
		
		self.__ui:setButtonPrivilegeVisible(false)
	else
		error("RewardStatus is undefined status = "..status)
	end

	self.__ui:setButtonExtraFunc(function()
		HttpManagerEx:getViewingHallPrivilegeReward(function(status, errcode, errmsg, data)
			if status == 200 and errcode == 0 then
				self.__role:setViewingHallPrivilegeExpiredTime(data.privilege_expired_time)

				self:__setButtons(data.status)

				self:__update()

				PopText("已成功领取"..resConfig.days.."天观影堂特权天数！")
			else
				PopText(errmsg)
			end
		end,IS_SHOW_WAITING)
	end)
	
	self.__ui:setButtonPrivilegeFunc(function()
		self:__showBuyPrivilegeUI()
	end)
end

function CommercialTimePrivilegePresenter:hideLayer()
    PopupLayerController:hideLayer(
        "CommercialTimePrivilegePresenter",
        function(layer)
			if self.handle then
				self:unschedule(self.handle)
				self.handle = nil
			end
			
			if self.__callback then
				self.__callback()
			end

            self.__ui:hideUI()
        end
    )
end

function CommercialTimePrivilegePresenter:__setRuleFunc()
	self.__ui:setButtonRuleFunc(function()
        self:__showRule()
    end)
end

function CommercialTimePrivilegePresenter:__showRule()
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

function CommercialTimePrivilegePresenter:__showBuyPrivilegeUI()
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

				local commercialTime = require("src.app.models.CommercialTime.CommercialTime"):create()

				commercialTime:setRole(self.__role)

				commercialTime:buyPrivilege(function()
					self:__initUI()
				end)
			end,
			func2 = function()
				layer:hideLayer()
			end,
		}

		layer:showLayer(showData)
	end)
end

Helper:classDefNodeGetInstance(CommercialTimePrivilegePresenter)

return CommercialTimePrivilegePresenter
00000000000000