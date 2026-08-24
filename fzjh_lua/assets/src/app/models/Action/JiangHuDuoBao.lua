local class = require("third.class.NewClass")

local JiangHuDuoBao = {}

function JiangHuDuoBao:create()
    return JiangHuDuoBao:new()
end

local LEVELNAME = {
    ["1"] = "ORA传说珍宝",
    ["2"] = "PURPLE稀有珍宝",
    ["3"] = "HIW高级珍宝",
}

function JiangHuDuoBao:ctor()
    self._actionId = 0

    self._name = "江湖夺宝"

    self._desc = "江湖夺宝江湖夺宝江湖夺宝江湖夺宝江湖夺宝"

    self._showItemInfo = {}

    self._rewardInfo = {}
end

function JiangHuDuoBao:setRole(role)
    self._role = role
end

function JiangHuDuoBao:setActionId(actionId)
    self._actionId = actionId
end

function JiangHuDuoBao:setRefreshFunc(func)
    self._refreshFunc = Helper:getDef(func,EMPTY_FUNC)
end

function JiangHuDuoBao:init(callback)
    HttpManagerEx:getLotteryTreasureList(self._actionId,function(status, errcode, errmsg, data)
        if status == 200 and errcode == 0 then
            self._name = data.act_name

            self._desc = data.detail_desc

            local desc = ""

            if MapIsEmpty(data.detail_desc) == false then
                for i, v in ipairs(data.detail_desc) do
                    desc = desc .. v .. "\n"
                end
            end

            self._desc = desc

            self._name = data.name
            --当前货币名
            self._currencyName = data.currency_name
            --当前货币数量
            self._currencyNum = data.currency_num
            --当前抽奖次数
            self._currLotteryTimes = data.curr_lottery_times
            --当前所需货币数量
            self._payNum = data.pay_num
            --当前所需货币类型
            self._payCurrencyType = data.pay_currency_type
            --当前所需货币拥有数量
            self._payCurrencyNum = data.pay_currency_num
            --当前状态 0未抽奖，1待领取
            self._state = data.lottery_status
            --待领取奖励数据
            self._rewardInfo = data.lottery_gem
            --gem_list  展示的奖励数据
            self:__dealWithRewardInfo(data.gem_list)
            --当前所需货币数据
            self._payCurrencyInfo = data.payCurrencyInfo
            --是不是空奖池
            self._isEmptyPool = data.is_empty_pool

            if callback then
                callback()
            end
        else
            PopText(errmsg)
        end
    end,IS_SHOW_WAITING)
end

function JiangHuDuoBao:getActionName()
    return self._name
end

function JiangHuDuoBao:getCurrencyName()
    return self._currencyName
end

function JiangHuDuoBao:getCurrencyNum()
    return self._currencyNum
end

function JiangHuDuoBao:getPayNum()
    return self._payNum
end

function JiangHuDuoBao:getPayCurrencyName()
    return self._payCurrencyInfo.name
end

function JiangHuDuoBao:getPayCurrencyBuyLimit()
    return self._payCurrencyInfo.buyLimit
end

function JiangHuDuoBao:getPayCurrencyInfo()
    return self._payCurrencyInfo
end

function JiangHuDuoBao:getPayCurrencyNum()
    return self._payCurrencyNum
end

function JiangHuDuoBao:getCurrLotteryTiems()
    return self._currLotteryTimes
end

function JiangHuDuoBao:getLotteryState()
    return self._state
end

function JiangHuDuoBao:getActionDesc()
    return self._desc
end

function JiangHuDuoBao:getShowItemInfo()
    return self._showItemInfo
end

function JiangHuDuoBao:getRewardInfo()
    return self._rewardInfo
end

function JiangHuDuoBao:checkRewardTypeIsSelect()
    if self._rewardInfo then
        return self._rewardInfo.rewardType == 2
    end

    error("JiangHuDuoBao:checkRewardTypeIsSelect 不存在奖励")
end

function JiangHuDuoBao:checkIsEmptyPool()
    return self._isEmptyPool == 0
end

function JiangHuDuoBao:doReward(reward)
    local is_email = not self:__checkCanGetReward(reward)
    local rewardId = reward.rid
    local dataVer = self._role:getServerActionSystem():getDataVersion()
    local currencyVersion = self._role:getCurrencyVersion()

    HttpManagerEx:lotteryTreasureReward(self._actionId, rewardId, is_email, dataVer, currencyVersion, function(status, errcode, errmsg, data)
        if status == 200 and errcode == 0 then
            local rewards = data.rewards
            if MapIsEmpty(rewards) == false then
                if rewards.type == 1 or rewards.type == 2 then --物品
                    self._role:addItemCount(rewards.id,rewards.number)
                elseif rewards.type == 3 then --属性
                    self._role:addAttr(rewards.id,rewards.number)
                end

                PopText("获得"..rewards.name.."X"..tostring(rewards.number))
            end

            if data.dataVer then
                self._role:getServerActionSystem():setDataVersion(data.dataVer)
            end

            if data.yashi_expired_time then  --江湖雅士体验卡额外处理
                self._role:updateYaShiStatus(data.yashi_expired_time)
            end

            if data.currencyVersion then
                self._role:setCurrencyVersion(data.currencyVersion)
            end

            if data.msg then
                PopText(data.msg)
            end

            if self._refreshFunc then
                self._refreshFunc()
            end
        else
            PopText(errmsg)
        end
    end,IS_SHOW_WAITING)
end

function JiangHuDuoBao:doLotterty()
    if self._payCurrencyType == "money" and self._role:getAttr(self._payCurrencyType) < self._payNum then
        PopText("抽奖失败，你的碎银不足")
        return
    end

    HttpManagerEx:lotteryTreasureResult(self._actionId,function(status, errcode, errmsg, data)
        if status == 200 and errcode == 0 then
            if MapIsEmpty(data.rewards) == false then
                PopText("恭喜你本次夺宝获得"..data.rewards.text)
            end

            if self._payCurrencyType == "money" then
                self._role:addAttr(self._payCurrencyType,-self._payNum)
            end

            if self._refreshFunc then
                self._refreshFunc()
            end
        else
            PopText(errmsg)
        end
    end,IS_SHOW_WAITING)
end

function JiangHuDuoBao:buyCurrency(number, callback)
    HttpManagerEx:buyLotteryTreasureCurrency(self._actionId, number,function(status, errcode, errmsg, data)
        if status == 200 and errcode == 0 then
            if callback then
                callback(data.status)
            end
        else
            PopText(errmsg)
        end
    end,IS_SHOW_WAITING)
end

function JiangHuDuoBao:__checkCanGetReward(rewards)
    --1 与 2 为本地道具
    if (rewards.type ~= 1 and rewards.type ~= 2) then
        return true
    end
    if self._role:checkCanBuyTwoOrMoreThings({[rewards.id] = rewards.number},true) == false then
        return false
    else
        return true
    end
end

function JiangHuDuoBao:__dealWithRewardInfo(rewardInfo)
    local info = {}

    if MapIsEmpty(rewardInfo) == false then
        for k,v in pairs(rewardInfo) do
            if MapIsEmpty(v) == false then
                if not info[tostring(v.level)] then
                    info[tostring(v.level)] = {}
                end
                table.insert(info[tostring(v.level)],v) 
            end
        end
    end

    local info_1 = {}
    if MapIsEmpty(info) == false then
        for k,v in pairs(info) do
            local _info = {}
            _info.name = LEVELNAME[k]
            _info.level = k
            _info.data = v
            table.insert(info_1,_info)
        end

        table.sort(info_1,function(a,b)
            if tonumber(a.level) < tonumber(b.level) then
                return true
            else
                return false
            end
        end)
    end

    self._showItemInfo =  info_1
end


return class("JiangHuDuoBao", {}, JiangHuDuoBao)
0