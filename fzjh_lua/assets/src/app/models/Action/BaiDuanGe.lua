local class = require("third.class.NewClass")
local GoodsHelper = require("app.models.Store.GoodsHelper")
local ActionRewardsHelper = require("app.models.Action.ActionRewardsHelper")
local GrantGoodRequest = require("app.models.Store.GrantGoodRequest")

local BaiDuanGe = {}

function BaiDuanGe:create()
    return BaiDuanGe:new()
end

function BaiDuanGe:ctor()
    self.__actionId = 0

    self.__name = ""

    self.__desc = ""

    self.__rewardList = {}
    --[[
        {
			"tag_name": "布衣之约",
            "unlock_type": 1,（1：免费解锁；3：月卡解锁；2：人民币解锁）
            "state": 1,（0：未解锁；1：已解锁）
			"lock_desc":"需成为江湖名士才能领取此页奖励。",
			"product_key":"com.mkjump.fzjha.product119",（人民币解锁时下发）
            "daily_reward": [
                    {
                            "rid": 1,
                            "reward": [
                                    {
                                        "id": "400038",
                                        "num": 60
                                    },,,,,,
                            ],
                            "state": 0
                    },,,,,,
                ]
        },
    ]]
end

function BaiDuanGe:init(callback)
    HttpManagerEx:getLoginRewardList(self.__actionId,function(status, errcode, errmsg, data)
        if status == 200 and errcode == 0 then
            self.__name = data.act_name

            local desc = ""

            if MapIsEmpty(data.detail_desc) == false then
                for i, v in ipairs(data.detail_desc) do
                    desc = desc .. v .. "\n"
                end
            end

            self.__desc = desc

            self.__rewardList = data.list

            if callback then
                callback()
            end
        else
            PopText(errmsg)
        end
    end,IS_SHOW_WAITING)
end

function BaiDuanGe:getActionName()
    return self.__name
end

function BaiDuanGe:getActionDesc()
    return self.__desc
end

function BaiDuanGe:setRole(role)
    self.__role = role
end

function BaiDuanGe:setActionId(actionId)
    self.__actionId = actionId
end

function BaiDuanGe:getRewardUnlockState(rewardIndex)
    for i, reward in ipairs(self.__rewardList) do
        if i == rewardIndex then
            return reward.state == 1
        end
    end
end

function BaiDuanGe:getRewardState(rewardIndex)
    for i, reward in ipairs(self.__rewardList) do
        if i == rewardIndex then
            local rewardList = reward.daily_reward
            
            local isTrue = false

            for i, v in ipairs(rewardList) do
                if v.state == 1 then
                    isTrue = true
                    break
                end
            end

            return isTrue
        end
    end
end

function BaiDuanGe:getRewardTitle(rewardType)
    for i, reward in ipairs(self.__rewardList) do
        if i == rewardType then
            return reward.tag_name
        end
    end
end

function BaiDuanGe:getRewardProductKey(rewardType)
    for i, reward in ipairs(self.__rewardList) do
        if i == rewardType then
            return reward.product_key
        end
    end
end

function BaiDuanGe:getRewardConditionText(rewardType)
    for i, reward in ipairs(self.__rewardList) do
        if i == rewardType then
            return reward.lock_desc
        end
    end
end

function BaiDuanGe:getRewardList(rewardType)
    for i, reward in ipairs(self.__rewardList) do
        if i == rewardType then
            return reward.daily_reward
        end
    end
end

function BaiDuanGe:getRewardCount()
    return #self.__rewardList
end

function BaiDuanGe:getRewardText(goodsList)
    return ActionRewardsHelper:getRewardText(goodsList)
end

function BaiDuanGe:checkBagCanGetReward(goodsList)
    local isTrue, msg = ActionRewardsHelper:checkBagCanGetRewards(goodsList, self.__role)
    return isTrue, msg
end

function BaiDuanGe:doReward(rid, isEmail, callback)
    local dataVer = self.__role:getServerActionSystem():getDataVersion()
    local currencyVersion = self.__role:getCurrencyVersion()

    HttpManagerEx:getLoginReward(self.__actionId, rid, isEmail, dataVer, currencyVersion, function(status, errcode, errmsg, data)
        if status == 200 and errcode == 0 then

            GoodsHelper:fromNetworkGrantGoods(self.__role,GrantGoodRequest:create({goodsList = data.reward, dataVersion = data.dataVer, currencyVersion = data.currencyVersion}))

            ActionRewardsHelper:printGetRewardsText(data.reward)

            if data.msg then
                PopText(data.msg)
            end

            if callback then
                callback()
            end
        else
            PopText(errmsg)
        end
    end,IS_SHOW_WAITING)
end

function BaiDuanGe:toPay(productKey, func)
    Game:openPayLayer(function()
        if self.Is_Click == true then
            return
        end
        if productKey == nil then
            return
        end
        self.Is_Click = true
    
        local dataVer = self.__role:getServerActionSystem():getDataVersion()
        local currencyVersion = self.__role:getCurrencyVersion()

        HttpManagerEx:checkJHMBActionPaySign(
            productKey,self.__actionId,dataVer,currencyVersion,
            function(status, errcode, errmsg, data, isEncrypted)
                if status == 200 then
                    if errcode == 0 then
                        local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
                        local dialog = DialogALayer:getInstance()
                        dialog:show("正在充值,请稍后")
                        dialog:setBack(false)
                        dialog:setButton1()
                        dialog:setButton2()
    
                        SdkMethod:IosPurchase_SetCallback(
                            function(eventName)
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
                                elseif 13 <= errcode and errcode <= 14 then
                                    text = "服务器异常，物品可能延迟到账"
                                elseif 15 <= errcode and errcode <= 20 then
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
                                    PopText("购买成功")
                                    self.Is_Click = false
                                    dialog:hide()
                                    
                                    if func then
                                        func()
                                    end
                                else
                                    PopText(text)
                                end
    
                                if text ~= "" then
                                    self.Is_Click = false
                                    dialog:hide()
                                end
                            end
                        )
                        SdkMethod:IosPurchase_BuyItem(productKey)
                    else
                        self.Is_Click = false
                        PopText(errmsg)
                    end
                else
                    self.Is_Click = false
                    PopText(errmsg)
                end
            end,
            IS_SHOW_WAITING
        )
    end)
end

return class("BaiDuanGe", {}, BaiDuanGe)
000000000000