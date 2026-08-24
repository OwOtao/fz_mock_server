local class = require("third.class.NewClass")

local PracticeOfSkill = {}

-- 状态，0：未解锁，1：可领取，2：已领取
local RewardState = {
    NotReward = 0,
    Reward = 1,
    AfterReward = 2,
}

local RewardSort = {
    [RewardState.Reward] = 1,
    [RewardState.NotReward] = 2,
    [RewardState.AfterReward] = 3,
}

function PracticeOfSkill:create()
    return PracticeOfSkill:new()
end

function PracticeOfSkill:ctor()
end

function PracticeOfSkill:setActionId(actionId)
    self.__actionId = actionId
end

function PracticeOfSkill:setRole(role)
    self.__role = role
end

function PracticeOfSkill:setSkillId(skillId)
    self.__skillId = skillId
end

function PracticeOfSkill:getZhaoData()
    local retData = {}

    local zhaos = self.__role:getSkillZhaoList(self.__skillId)
    
    for i,zhao in ipairs(zhaos) do
        retData[zhao:getId()] = Helper:mathFloor(self.__role:getSkillZhaoExp(zhao:getId()))
    end

    return retData
end

function PracticeOfSkill:setAfterRewardFunc(func)
    self.__afterRewardFunc = func
end

function PracticeOfSkill:getRole()
    return self.__role
end

function PracticeOfSkill:getSkillLv()
    return self.__role:getSkillLv(self.__skillId)
end

function PracticeOfSkill:getSkillName()
    local skill = Skill:getSkill(self.__skillId)
    return skill.name
end

function PracticeOfSkill:getActionInfo(func)
    local skillLv = self:getSkillLv()

    HttpManagerEx:getPracticeSkillRewardList(self.__actionId, {[self.__skillId] = self:getSkillLv()},self:getZhaoData(),function(status, errcode, errmsg, data)
		if status ==200 and errcode == 0 then
            self.__name = data.act_name

            local desc = ""

            if MapIsEmpty(data.detail_desc) == false then
                for i, v in ipairs(data.detail_desc) do
                    desc = desc .. v .. "\n"
                end
            end

            self.__desc = desc

            self:__initShowRewardList(data.list)

            if MapIsEmpty(data.unlock_info) == false then
                local goods = data.unlock_info
                self.__goodsJackpotId = goods.jackpotId
                self.__goodsText = goods.payText
                self.__goodsProductKey = goods.productKey
                self.__goodsPayType = goods.payType
                self.__goodsState = goods.payState
            end

            if func then
                func()
            end
		else
			PopText(errmsg)
		end
	end,IS_SHOW_WAITING)
end

function PracticeOfSkill:getActionName()
    return self.__name
end

function PracticeOfSkill:getActionDesc()
    return self.__desc
end

function PracticeOfSkill:getGoodsText()
    return self.__goodsText
end

function PracticeOfSkill:getGoodsIsUnlock()
    return self.__goodsState == 1
end

function PracticeOfSkill:getListByTypeId(id)
    local list = {}

    for i, v in ipairs(self.__rewardList) do
        if v.rewardTypeId == id then
            table.insert(list, v)
        end
    end

    return list
end

function PracticeOfSkill:getRewardFisrtTypeIdAndName()
    if self.__rewardType[1] then
        return self.__rewardType[1].id, self.__rewardType[1].name
    end
end

function PracticeOfSkill:getRewardSecondTypeIdAndName()
    if self.__rewardType[2] then
        return self.__rewardType[2].id, self.__rewardType[2].name
    end
end

function PracticeOfSkill:__initShowRewardList(list)
    self.__rewardList = {}
    self.__rewardType = {}

    if MapIsEmpty(list) == false then
        local rewardType = {}

        for k,v in pairs(list) do
            local rewardInfo = {}
            rewardInfo.rid = v.rid
            rewardInfo.state = v.state
            rewardInfo.text = v.text
            rewardInfo.rewardTypeId = v.jackpotId
            rewardInfo.rewards = v.rewards

            if v.state == RewardState.AfterReward then
                rewardInfo.enable = true
                rewardInfo.btnName = "已领取"
                rewardInfo.loadTexture = "Image/UI/TaskUI/anniuhui.png"
            elseif v.state == RewardState.NotReward then
                rewardInfo.enable = false
                rewardInfo.btnName = "领取"
                rewardInfo.loadTexture = "Image/UI/TaskUI/anniuhui.png"
            elseif v.state == RewardState.Reward then
                rewardInfo.enable = true
                rewardInfo.btnName = "领取"
                rewardInfo.loadTexture = "Image/UI/TaskUI/anniu.png"
            end

            if not rewardType[v.jackpotId] then
                rewardType[v.jackpotId] = true
                local info = {
                    id = v.jackpotId,
                    name = v.jackpotName
                }
                table.insert(self.__rewardType, info)
            end

            rewardInfo.text2 = v.giftText

            rewardInfo.text1 = v.text

            table.insert(self.__rewardList,rewardInfo)
        end
    end

    table.sort(self.__rewardList,function(a,b)
        if a.rid < b.rid then
            return true
        else
            return false
        end
    end)

    table.sort(self.__rewardType, function(a,b)
        return a.id < b.id
    end)
end

function PracticeOfSkill:checkStateIsReward(state)
    return state == RewardState.Reward
end

function PracticeOfSkill:checkBagCanGetReward(rewards)
    local items = {}

    for k,v in pairs(rewards) do
        if v.type == 1 or v.type == 2 then
            if items[v.id] then
                items[v.id] = tonumber(v.number) + items[v.id]
            else
                items[v.id] = tonumber(v.number)
            end
        end
    end

    if self.__role:checkCanBuyTwoOrMoreThings(items,true) == false then
        return false
    else
        return true
    end
end

function PracticeOfSkill:doReward(rewardId,isEmail,callback)
    local dataVer = self.__role:getServerActionSystem():getDataVersion()
    HttpManagerEx:getPracticeSkillReward(
        self.__actionId,
        rewardId,
        isEmail,
        dataVer,
        function(status, errcode, errmsg, data)
            if status == 200 and errcode == 0 then
                local rewardList = data.rewards
                if MapIsEmpty(rewardList) == false then
                    for i, v in ipairs(rewardList) do
                        if v.type == 1 or v.type == 2 then --物品
                            self.__role:addItemCount(v.id, v.number)
                        elseif v.type == 3 then --属性
                            self.__role:addAttr(v.id, v.number)
                        end

                        PopText("获得" .. v.name .. "X" .. tostring(v.number))
                    end
                end

                if data.dataVer then
                    self.__role:getServerActionSystem():setDataVersion(data.dataVer)
                end

                if data.msg then
                    PopText(data.msg)
                end

                if callback then
                    callback()
                end
            else
                PopText(errmsg)
            end
        end,
        IS_SHOW_WAITING
    )

end

function PracticeOfSkill:unlockReward(callback)
    if self.__goodsPayType == 2 then --人民币
        self:__payRMB(callback)
    else
        HttpManagerEx:unlockPracticeSkillPayReward(self.__actionId, self.__goodsJackpotId,function(status, errcode, errmsg, data)
            if status == 200 and errcode == 0 then
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
end

function PracticeOfSkill:__payRMB(callback)
    Game:openPayLayer(function()
        if self.Is_Click == true then
            return
        end
        if self.__goodsProductKey == nil then
            return
        end
        self.Is_Click = true
    
        HttpManagerEx:checkActionPaySign(
            self.__goodsProductKey, self.__actionId,
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
                                    if callback then
                                        callback()
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
                        SdkMethod:IosPurchase_BuyItem(self.__goodsProductKey)
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

return class("PracticeOfSkill", {}, PracticeOfSkill)
0000000000000