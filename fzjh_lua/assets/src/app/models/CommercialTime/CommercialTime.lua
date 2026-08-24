local class = require("third.class.NewClass")

local resConfig = require("script.activity.viewingHallactivity")["Sheet1"].viewingHallactivity

local CommercialTime = {}

function CommercialTime:create()
    return CommercialTime:new()
end

function CommercialTime:ctor()
    self._actionId = 0

    self._name = "观影堂"

    self._desc = ""

    self._currencyName = "观影券"

    self._currencyNum = 0

    self._rewardInfo = {}
end

function CommercialTime:setRole(role)
    self._role = role
end

function CommercialTime:getRole()
    return self._role
end

function CommercialTime:setActionId(actionId)
    self._actionId = actionId
end

function CommercialTime:setRefreshFunc(func)
    self._refreshFunc = Helper:getDef(func,EMPTY_FUNC)
end

function CommercialTime:setAfterExchangeFunc(func)
    self._afterExchangeFunc = Helper:getDef(func,EMPTY_FUNC)
end

function CommercialTime:init(callback)
    HttpManagerEx:getTime(function(status, errcode, errmsg, data)
        if status == 200 and errcode == 0 and data.time ~= nil then
            SetTime(tonumber(data.time))
            HttpManagerEx:getViewingHall(function(status, errcode, errmsg, data)
                if status == 200 and errcode == 0 then
                    local desc = ""
        
                    if MapIsEmpty(data.ruleDesc) == false then
                        for i, v in ipairs(data.ruleDesc) do
                            desc = desc .. v .. "\n"
                        end
                    end
        
                    self._ruleDesc = desc
                    self._lastViewTime = data.lastViewTime
                    self._coolDownTime = data.coolDown
                    self._isReachLimit = data.isReachLimit
                    self._currencyNum = data.guanyingquan
					
					self.__isPromotionActive = data.isPromotionActive

					self._role:setViewingHallPrivilegeExpiredTime(data.privilege_expired_time)
					self._role:setViewingHallPrivilegeRemainingWatches(data.privilege_remaining_watches)
					
                    --gem_list  展示的奖励数据
                    self:__dealWithRewardInfo(data.rewards)
        
                    if callback then
                        callback()
                    end
                else
                    PopText(errmsg)
                end
            end,IS_SHOW_WAITING)
        end
    end)
 
end

function CommercialTime:getActionName()
    return self._name
end

function CommercialTime:getCoolDownTime()
    return Helper:mathFloor(self._coolDownTime + self._lastViewTime - GetTime())
end

function CommercialTime:checkIsViewTimesLimit()
    return self._isReachLimit
end

function CommercialTime:getCurrencyName()
    return self._currencyName
end

function CommercialTime:getCurrencyNum()
    return self._currencyNum
end

function CommercialTime:getActionRule()
    return self._ruleDesc
end

function CommercialTime:getRewardInfo()
    return self._rewardInfo
end

function CommercialTime:doReward(rid,is_free,is_email,func)
    HttpManagerEx:getViewingReward(rid,is_free,is_email,function(status, errcode, errmsg, data)
        if status == 200 then
			if errcode == 0 then
				local rewardList = data.reward
				if MapIsEmpty(rewardList) == false then
					if rewardList.itemType == 1 then --物品
						self._role:addItemCount(rewardList.id,rewardList.number)
					elseif rewardList.itemType == 2 then --属性
						self._role:addAttr(rewardList.id,rewardList.number)
					end

					PopText("获得"..rewardList.name.."X"..tostring(rewardList.number))
				end

				if data.msg then
					PopText(data.msg)
				end

				local DailyTasksActivity = require("app.models.Action.DailyTasksActivity")
        		DailyTasksActivity:addDailyTaskPoint("guanggao")

				if func then
					func()
				end
			elseif errcode == 1 or errcode == 2 then --errcode:1.没有观影券 2.没有观影堂特权
				if func then
					func()
				end

				PopText(errmsg)
			end
        else
            PopText(errmsg)
        end
    end,IS_SHOW_WAITING)
end

--判断是否处于广告CD true 为是
function CommercialTime:checkIsInAdCD()
    local currTime = GetTime()
    if self._lastViewTime + self._coolDownTime > currTime then
        return true
    else
        return false
    end 
end

function CommercialTime:checkCanGetReward(reward)
    if reward.type ~= 1 then --1为客户端物品
        return true
    end
    if self._role:checkCanBuyTwoOrMoreThings({[reward.id] = reward.num},false) == false then
        return false
    else
        return true
    end
end

function CommercialTime:__dealWithRewardInfo(rewardInfo)
    self._rewardInfo = {}

    if MapIsEmpty(rewardInfo) == false then
        local currTime = GetTime()
        for __,reward in pairs(rewardInfo) do
            local __info = {}
            __info.rid = reward.id
            __info.id = reward.itemId
            __info.name = reward.name
            __info.num = reward.number
            __info.icon = reward.icon
            __info.type = reward.itemType
            __info.rType = reward.awardType
            __info.state = reward.getTimes < reward.maxTimes
            __info.times = "次数："..tostring(reward.getTimes).."/"..tostring(reward.maxTimes)
            if reward.endTime and reward.endTime ~= "" then
                __info.time = reward.endTime - currTime
            end
            table.insert(self._rewardInfo,__info)
        end
    end

    table.sort(self._rewardInfo,function(a, b)
        if a.state == b.state then
            if a.rType == b.rType then
                return a.rid < b.rid
            else
                return a.rType > b.rType
            end
        elseif a.state == false then
            return false
        elseif b.state == false then
            return true
        end
    end)
end

--@desc:特权活动是否开启
--@author:LvBin
--@time:2025-08-13 15:15:24
--@return
function CommercialTime:isPromotionActive()
	return self.__isPromotionActive == 1
end

--@desc: 申请购买观影堂特权
--@author:LvBin
--@time:2025-08-15 16:37:36
--@callback: 
--@return
function CommercialTime:buyPrivilege(callback)
	if self.Is_Click == true then
		return
	end

	local key = resConfig.productkey

	self.Is_Click = true
	HttpManagerEx:checkPaySign(key,function(status, errcode, errmsg, data, isEncrypted)
		if status == 200 then
			if errcode == 0 then
				local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
				local dialog = DialogALayer:getInstance()
				dialog:show("正在充值,请稍后")
				dialog:setBack(false)
				dialog:setButton1()
				dialog:setButton2()
				
				SdkMethod:IosPurchase_SetCallback(function(eventName)
					if not eventName or string.len(eventName) <= 0 then
						PopText("异常，请联系客服人员")
						return
					end
					local errcode = tonumber(eventName)
			
					local text 
					if errcode == 1 then
						text = "仅支持IOS7以上系统"
					elseif errcode == 2 then
						text = "不允许程序内付费，玩家关闭了应用内购买功能"
					elseif errcode == 3 then
						text = "没有该商品"
					elseif errcode == 4 then
						text = "购买出错"
						HttpManagerEx:updateOrderState()
					elseif errcode == 7 then
						text = "已经购买过此商品"
					elseif errcode == 9 then
						text = "交易失败"
						HttpManagerEx:updateOrderState()
					elseif errcode == 12 then
						text = "错误的头信息"
					elseif 13 <= errcode and errcode <= 14  then
						text = "服务器异常，物品可能延迟到账"
					elseif 15 <= errcode and errcode <= 20  then
						text = "请勿使用非法渠道购买物品"
					elseif errcode == 21 then
						text = "未知错误"
					elseif errcode == 22 then
						text = "订单ID获取失败,请重新尝试"
					elseif errcode == 23 then
						text = "交易失败，订单ID非法。"
					elseif errcode == 24 then
						text = "订单异常，服务器无法获取订单信息。"
					elseif errcode == 25 then
						text = "角色存档数据不存在，请联系客服。"
					elseif errcode == 26 then
						text = "取消登录"
					elseif errcode == 27 then
						text = "放弃支付"
						HttpManagerEx:updateOrderState()
					elseif errcode == 28 then
						text = "登录成功"
					elseif errcode == 29 then
						text = "登录失败"
					elseif errcode == 30 then
						text = "订单已提交或处理中"
					elseif errcode == 31 then
						text = "登录状态过期"
					else
						text = ""
					end
			
					if errcode == 0 then
						Mob.pay(18, 21, "观影堂特权", 1, 18)
						PopText("购买观影堂特权成功")
						
						if callback then
							callback()
						end
						
						self.Is_Click = false

						dialog:hide()
					else
						PopText(text)
					end
			
					if text ~= "" then
						self.Is_Click = false
						dialog:hide()
					end
				end)
				SdkMethod:IosPurchase_BuyItem(key)
			else
				self.Is_Click = false
				PopText(errmsg)
			end
		else
			self.Is_Click = false
			PopText(errmsg)
		end
	end, IS_SHOW_WAITING)
end

return class("CommercialTime", {}, CommercialTime)
00000000000000