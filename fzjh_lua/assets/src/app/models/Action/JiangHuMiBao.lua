local class = require("third.class.NewClass")

local GoodsHelper = require("app.models.Store.GoodsHelper")
local ActionRewardsHelper = require("app.models.Action.ActionRewardsHelper")

local rewardState = {
    NOT_PAY = 0,--未充值
    NOT_REWARD = 1, --可领取
    AWARDED = 2, --已领取
}

local JiangHuMiBao = {}

function JiangHuMiBao:create()
    return JiangHuMiBao:new()
end

function JiangHuMiBao:ctor()
    self._actionId = "jianghumibao"

    self._name = "江湖秘宝"

    self._desc = "2021年5月15日0点-2021年5月31日23点59分，活动期间每天可购买超值礼包，每种礼包将会有不同的购买次数，购买后请及时领取，购买次数将于每天0点刷新。"

    self._miBaoInfo = {}

end

function JiangHuMiBao:setRole(role)
    self._role = role
end

function JiangHuMiBao:setActionId(actionId)
    self._actionId = actionId
end

function JiangHuMiBao:init(callback)
    HttpManagerEx:getSpendRewardList(self._actionId,function(status, errcode, errmsg, data)
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

            self._endTime = data.act_end

            self:__dealWithRewardInfo(data.list)

            if callback then
                callback()
            end
        else
            PopText(errmsg)
        end
    end,IS_SHOW_WAITING)
end

function JiangHuMiBao:getActionName()
    return self._name
end

function JiangHuMiBao:getActionDesc()
    return self._desc
end

function JiangHuMiBao:getEndTime()
    return self._endTime
end

function JiangHuMiBao:getMiBaoInfo()
    return self._miBaoInfo
end

function JiangHuMiBao:setAfterRewardCallback(func)
    self._afterRewardCallback = Helper:getDef(func,EMPTY_FUNC)
end

function JiangHuMiBao:__toPay(productKey)
    Game:openPayLayer(function()
        if self.Is_Click == true then
            return
        end
        if productKey == nil then
            return
        end
        self.Is_Click = true
    
        local dataVer = self._role:getServerActionSystem():getDataVersion()
        local currencyVersion = self._role:getCurrencyVersion()

        HttpManagerEx:checkJHMBActionPaySign(
            productKey,self._actionId,dataVer,currencyVersion,
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
                                    if self._afterRewardCallback then
                                        self._afterRewardCallback()
                                    end
                                    PopText("购买成功")
                                    self.Is_Click = false
                                    dialog:hide()
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

function JiangHuMiBao:__doSpecialGoods(rid,costType,cost,func)
    if costType == 4 then
        if self._role:getAttr("money") < cost then
            PopText("碎银不足")
            return
        end
    end

    local dataVer = self._role:getServerActionSystem():getDataVersion()
    local currencyVersion = self._role:getCurrencyVersion()

    HttpManagerEx:buySpendReward(self._actionId, rid, dataVer, currencyVersion, function(status, errcode, errmsg, data)
        if status == 200 and errcode == 0 then
            if costType == 4 then
                self._role:addAttr("money",cost)
            end
            PopText("购买成功")
            if func then
                func()
            end
        else
            PopText(errmsg)
        end
    end,IS_SHOW_WAITING)
    
end

function JiangHuMiBao:__doReward(rewardId,callback)
    local dataVer = self._role:getServerActionSystem():getDataVersion()
    local currencyVersion = self._role:getCurrencyVersion()

    HttpManagerEx:getSpendReward(self._actionId,rewardId, dataVer, currencyVersion, function(status, errcode, errmsg, data)
        if status == 200 and errcode == 0 then
            local GrantGoodRequest = require("app.models.Store.GrantGoodRequest")

            GoodsHelper:fromNetworkGrantGoods(self._role,GrantGoodRequest:create({goodsList = data.reward, dataVersion = data.dataVer, currencyVersion = data.currencyVersion}))

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

function JiangHuMiBao:__checkCanBuy(rewards)
    return ActionRewardsHelper:checkRewardsCanBuy(rewards, self._role)
end

function JiangHuMiBao:__checkCanGetReward(rewards)
    return ActionRewardsHelper:checkBagCanGetRewards(rewards, self._role)
end

function JiangHuMiBao:__dealWithRewardInfo(rewardInfo)
    local info = {}

    if MapIsEmpty(rewardInfo) == false then
        for k,v in pairs(rewardInfo) do
            if MapIsEmpty(v) == false then
                local _info = {}
                _info.text1 = v.libaoName
                _info.text2 = "本日剩余购买"..v.count.."次"
                _info.rid = v.rid
                _info.reward = v.reward
                _info.btnName = "领取"
                _info.btnVisible = true
                _info.productKey = v.productKey

                local str = ""
                for k, reward in pairs(v.reward) do
                    local goods = GoodsHelper:getGoodsResClass(reward.id)
                    str = str .. goods.name.."X"..reward.num.."、"
                end

                _info.text3 = string.sub(str, 1, -4)

                if v.state == rewardState.NOT_PAY then
                    _info.btnName = v.price
                end

                if v.state == rewardState.AWARDED then
                    _info.btnVisible = false
                end

                if v.limit_type == 2 then
                    _info.text2 = "活动期间剩余购买"..v.count.."次"
                end

                _info.btnFunc = function()
                    if v.state == rewardState.NOT_PAY then
                        local isCanBuy, searchInfo = self:__checkCanBuy(v.reward)
                        if isCanBuy then
                            if v.pay_type == 1 then  --0免费 1 人民币 2 银票 3元宝  4碎银
                                self:__toPay(v.productKey)
                            else
                                local cost = Helper:getDef(tonumber(v.productKey),0)
                                if v.pay_type == 2 or v.pay_type == 3 or v.pay_type == 4 then
                                    local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
                                    local dialog = DialogALayer:getInstance()
                                    dialog:show("是否花费"..v.price.."购买"..v.libaoName.."？")
                                    dialog:setButton1("确定", function()
                                        self:__doSpecialGoods(v.rid,v.pay_type,cost,function()
                                            if self._afterRewardCallback then
                                                self._afterRewardCallback()
                                            end
                                        end)
                                    end)
                                    dialog:setButton2("取消", function()
                                        dialog:hide()
                                    end)
                                    dialog:setWeChatVisible(false)
                                else
                                    self:__doSpecialGoods(v.rid,v.pay_type,cost,function()
                                        if self._afterRewardCallback then
                                            self._afterRewardCallback()
                                        end
                                    end)
                                end
                            end
                        else
                            local msg = ""
                            
                            if searchInfo.searchType == "101" then
                                msg = "已学习对应武学，无需再次购买！"
                            elseif searchInfo.searchType == "301" then
                                msg = "您该主动技能即将/已经达到熟练度上限，无需购买！"
                            elseif searchInfo.searchType == "201" or searchInfo.searchType == "401" or searchInfo.searchType == "501" or searchInfo.searchType == "701" then
                                msg = "已达到商品可持有数量的限制，不可购买！"
                            elseif searchInfo.searchType == "1001" or searchInfo.searchType == "1002" then
                                msg = "不满足购买条件，无法购买!"
                            elseif searchInfo.searchType == "601" then
                                msg = "您的等级不符合该礼包道具的最低使用要求，目前不能购买！"
                            end
                            PopText(msg)
                        end
                    elseif v.state == rewardState.NOT_REWARD then
                        local isTrue, msg = self:__checkCanGetReward(v.reward)
                        
                        if isTrue then
                            self:__doReward(v.rid,function()
                                if self._afterRewardCallback then
                                    self._afterRewardCallback()
                                end
                            end)
                        else
                            PopText(msg)
                        end
                    elseif v.state == rewardState.AWARDED then
                        PopText("此奖励已领取。")
                    end
                end

                table.insert(info,_info)
            end
        end
    end

    self._miBaoInfo = info
end

return class("JiangHuMiBao", {}, JiangHuMiBao)
00000000