local class = require("third.class.NewClass")

local NewRandomGift = {}

local rewardType = {
    ["1"] = "门派奖励道具：",
    ["2"] = "珍贵奖励道具：",
    ["3"] = "稀有奖励道具：",
    ["4"] = "普通奖励道具：",
}

function NewRandomGift:create()
    return NewRandomGift:new()
end

function NewRandomGift:ctor()
    self._actionId = 0

    self._name = ""

    self._desc = ""

    self._maxBuyTimes = 30

    self._buyTimes = 0

    self._refreshCost = 100

    self._refreshCostName = "元宝"

    self._rewardList = {}

    self._rewardPoolInfo = {}
end

function NewRandomGift:setRole(role)
    self._role = role
end

function NewRandomGift:setActionId(actionId)
    self._actionId = actionId
end

function NewRandomGift:init(isRefresh,callback)
    local menpai = self._role:getFamilyId()
    HttpManagerEx:getLuckBoxList(self._actionId,menpai,isRefresh,function(status, errcode, errmsg, data)
        if status == 200 and errcode == 0 then
            self._name = data.act_name

            self._desc = data.detail_desc

            local desc = ""

            if MapIsEmpty(data.detail_desc) == false then
                for i, v in ipairs(data.detail_desc) do
                    desc = desc .. v .. "\n"
                end
            end

            self._buyTimes = data.buy_times

            self._maxBuyTimes = data.buy_limit

            self._refreshCostName = data.refresh_currency

            self._refreshCost = data.refresh_cost

            self._desc = desc

            self:__dealWithRewardInfo(data.list)

            self:__dealWithRewardPoolInfo(data.display_list)

            if callback then
                callback()
            end
        else
            PopText(errmsg)
        end
    end,IS_SHOW_WAITING)
end

function NewRandomGift:getActionName()
    return self._name
end

function NewRandomGift:getActionDesc()
    return self._desc
end

function NewRandomGift:getRewardList()
    return self._rewardList
end

function NewRandomGift:getRewardPoolList()
    return self._rewardPoolInfo
end

function NewRandomGift:getBuyTimes()
    return self._buyTimes
end

function NewRandomGift:getRefreshCost()
    return self._refreshCost
end

function NewRandomGift:getRefreshCostCNName()
    return self._role:getCHAttrName(self._refreshCostName)
end

function NewRandomGift:checkIsMaxBuyTimes()
    return tonumber(self._buyTimes) >= tonumber(self._maxBuyTimes)
end

function NewRandomGift:isCanRefresh()
    if self:checkIsMaxBuyTimes() == false then
        if self._refreshCostName == "money" then
            if self._role:getAttr("money") < self._refreshCost then
                PopText("所需消耗碎银不足，刷新失败")
                return false
            end
            self._role:addAttr("money", -self._refreshCost)
        end
        return true
    end

    return false
end

function NewRandomGift:__buyGoods(rewardId,callback)
    local dataVer = self._role:getServerActionSystem():getDataVersion()
    local currencyVersion = self._role:getCurrencyVersion()
    HttpManagerEx:buyLuckBoxGood(self._actionId, rewardId, dataVer, currencyVersion, function(status, errcode, errmsg, data)
        if status == 200 and errcode == 0 then
            PopText("购买成功")

            if callback then
                callback()
            end

        else
            PopText(errmsg)
        end
    end,IS_SHOW_WAITING)
end

function NewRandomGift:__doReward(rewardId,callback)
    local dataVer = self._role:getServerActionSystem():getDataVersion()
    local currencyVersion = self._role:getCurrencyVersion()

    HttpManagerEx:getLuckBoxGood(self._actionId, rewardId, dataVer, currencyVersion, function(status, errcode, errmsg, data)
        if status == 200 and errcode == 0 then
            local rewardList = data.reward
            Helper:print_lua_table(rewardList)
            if MapIsEmpty(rewardList) == false then
                if rewardList.itype == 1 or rewardList.itype == 2 then --物品
                    self._role:addItemCount(rewardList.id,rewardList.number)
                elseif rewardList.itype == 3 then --属性
                    self._role:addAttr(rewardList.id,rewardList.number)
                end

                PopText("获得"..rewardList.name.."X"..tostring(rewardList.number))
            end

            if data.dataVer then
                self._role:getServerActionSystem():setDataVersion(data.dataVer)
            end

            if data.currencyVersion then
                self._role:setCurrencyVersion(data.currencyVersion)
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
    end,IS_SHOW_WAITING)
end

function NewRandomGift:setAfterRewardCallback(func)
    self._afterRewardCallback = Helper:getDef(func,EMPTY_FUNC)
end

function NewRandomGift:setAfterBuyCallBack(func)
    self._afterBuyCallback = Helper:getDef(func,EMPTY_FUNC)
end

function NewRandomGift:__checkCanGetReward(rewards)
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

    if self._role:checkCanBuyTwoOrMoreThings(items,true) == false then
        return false
    else
        return true
    end
end

function NewRandomGift:__dealWithRewardInfo(rewardInfo)
    self._rewardList = {}

    if MapIsEmpty(rewardInfo) == false then
        for k,v in pairs(rewardInfo) do
            if MapIsEmpty(v) == false then
                local _info = {}
                _info.icon = v.icon
                _info.text1 = v.name.."X"..tostring(v.number)
                _info.text2 = "原价"..v.buy_cost..self._role:getCHAttrName(v.buy_currency)

                if v.state == 0 then
                    _info.btnName = v.dis_cost..self._role:getCHAttrName(v.buy_currency).."购买"
                elseif v.state == 1 then
                    _info.btnName = "领取"
                elseif v.state == 2 then
                    _info.btnName = "已领取"
                end

                if v.aft_price == 0 then
                    _info.btnName = "免费"
                end
            
                _info.rid = v.rid
                _info.state = v.state
                
                _info.rewards = {
                    {
                    type = v.itype,
                    id = v.id,
                    number = v.number
                    }
                }

                _info.func = function()
                    if v.state == 0 then
                        self:__buyGoods(v.rid,function()
                            if self._afterBuyCallback then
                                self._afterBuyCallback()
                            end
                        end)
                    elseif v.state == 1 and self:__checkCanGetReward(_info.rewards) then
                        self:__doReward(v.rid,function()
                            if self._afterRewardCallback then
                                self._afterRewardCallback()
                            end
                        end)
                    elseif v.state == 2 then
                        PopText("此奖励已领取，刷新后可继续购买新商品")
                    end
                end

                table.insert(self._rewardList,_info)
            end
        end
    end

end

function NewRandomGift:__dealWithRewardPoolInfo(rewardPool)
    self._rewardPoolInfo = {}

    if MapIsEmpty(rewardPool) == false then
        local typePool = {}
        for k,v in pairs(rewardPool) do
            if not typePool[v.rtype] then
                typePool[v.rtype] = {}
            end

            table.insert(typePool[v.rtype],v.text)
        end

        for k,v in pairs(typePool) do
            local pool = {}
            pool.index = k
            pool.text = rewardType[tostring(k)]
            pool.info = v
            table.insert(self._rewardPoolInfo, pool)
        end
        
        table.sort(self._rewardPoolInfo,function(a,b)
            if a.index < b.index then
                return  true
            else
                return false
            end
        end)
    end
end

return class("NewRandomGift", {}, NewRandomGift)
00000000