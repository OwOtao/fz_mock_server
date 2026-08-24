local class = require("third.class.NewClass")

local ReputationStore = {}

function ReputationStore:create()
    return ReputationStore:new()
end

function ReputationStore:ctor()
    self._name = ""

    self._desc = ""

    self._maxBuyTimes = 30

    self._buyTimes = 0

    self._refreshCost = 100

    self._refreshCostName = "元宝"

    self._currencyName = "功绩"

    self._rewardList = {}
end

function ReputationStore:setRole(role)
    self._role = role
end

function ReputationStore:init(isRefresh,callback)
    local menpai = self._role:getFamilyId()
    if not menpai then
        assert(false, "需要加入门派才能进入")
        return
    end

    HttpManagerEx:getSectMeritStore(menpai,isRefresh,function(status, errcode, errmsg, data)
        if status == 200 and errcode == 0 then

            self._buyTimes = data.buyTimes

            self._maxBuyTimes = data.buyLimit

            self._refreshCost = data.refreshCost

            self._desc = string.format("本商店每周一0点会刷新商品和库存，本门弟子可以通过消耗个人功绩购买本商店商品，每周商店限购%s次，每次刷新可以更换在售商品。",data.buyLimit)

            self:__dealWithInfo(data.list)
            
            if callback then
                callback()
            end
        else
            PopText(errmsg)
        end
    end,IS_SHOW_WAITING)
end

function ReputationStore:getActionDesc()
    return self._desc
end

function ReputationStore:getRewardList()
    return self._rewardList
end

function ReputationStore:getBuyTimes()
    return self._buyTimes
end

function ReputationStore:getRefreshCost()
    return self._refreshCost
end

function ReputationStore:getRefreshCostCNName()
    return self._refreshCostName
end

function ReputationStore:checkIsMaxBuyTimes()
    return tonumber(self._buyTimes) >= tonumber(self._maxBuyTimes)
end

function ReputationStore:isCanRefresh()
    if self:checkIsMaxBuyTimes() == false then
        return true
    end

    return false
end

function ReputationStore:buyGoods(rewardId,callback)
    HttpManagerEx:buyMeritGoods(self._role:getFamilyId(), rewardId,function(status, errcode, errmsg, data)
        if status == 200 and errcode == 0 then
            PopText("购买成功")

            if data.reputation then
                self._role:getTeacherBuildSystem():setReputation(data.reputation)
            end

            if callback then
                callback()
            end
        else
            PopText(errmsg)
        end
    end,IS_SHOW_WAITING)
end

function ReputationStore:doReward(rewardId, isEmail, callback)
    local dataVer = self._role:getServerActionSystem():getDataVersion()

    HttpManagerEx:getMeritGoods(self._role:getFamilyId(), rewardId, dataVer, isEmail, function(status, errcode, errmsg, data)
        if status == 200 and errcode == 0 then
            local rewardList = data.goods
            Helper:print_lua_table(rewardList)
            if MapIsEmpty(rewardList) == false then
                if rewardList.type == 1 then --物品
                    self._role:addItemCount(rewardList.id,rewardList.number)
                elseif rewardList.type == 2 then --属性
                    self._role:addAttr(rewardList.id,rewardList.number)
                end

                PopText("获得"..rewardList.name.."X"..tostring(rewardList.number))
            end

            if data.dataVer then
                self._role:getServerActionSystem():setDataVersion(data.dataVer)
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

function ReputationStore:checkCanGetReward(rewards)
    local items = {}

    for k,v in pairs(rewards) do
        if v.type == 1 then
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

function ReputationStore:__dealWithInfo(rewardInfo)
    self._rewardList = {}

    if MapIsEmpty(rewardInfo) == false then
        for k,v in pairs(rewardInfo) do
            if MapIsEmpty(v) == false then
                local _info = {}
                _info.id = v.id

                local goods = v.goods
                _info.rewards = {
                    {
                    type = goods.type,
                    id = goods.id,
                    number = goods.number
                    }
                }

                _info.state = v.state
                _info.stock = v.stock
                _info.icon = goods.icon
                _info.text1 = goods.name.."X"..tostring(goods.number)
                _info.text2 = v.thresholdText
                _info.text3 = "库存："..v.stock
                _info.text4 = ""
                _info.price = v.price

                if v.state == 0 then
                    _info.btnName = v.price..self._currencyName
                    if v.origPrice then
                        _info.text4 = "原价："..v.origPrice..self._currencyName
                    end
                elseif v.state == 1 then
                    _info.btnName = "领取"
                elseif v.state == 2 then
                    _info.btnName = "售罄"
                end

                table.insert(self._rewardList,_info)
            end
        end
    end

end


return class("ReputationStore", {}, ReputationStore)
000000000000