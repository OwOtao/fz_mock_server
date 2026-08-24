local class = require("third.class.NewClass")
local GoodsHelper = require("app.models.Store.GoodsHelper")
local ActionRewardsHelper = require("app.models.Action.ActionRewardsHelper")
local GrantGoodRequest = require("app.models.Store.GrantGoodRequest")

local CuiLianTypeSort = {
    ["剑"] = 1,
    ["刀"] = 2,
    ["枪棍"] = 3,
    ["鞭"] = 4,
    ["双持"] = 5,
    ["乐器"] = 6,
    ["暗器"] = 7,
}

local CuiLianCaiLiaoStore = {}

function CuiLianCaiLiaoStore:create()
    return CuiLianCaiLiaoStore:new()
end

function CuiLianCaiLiaoStore:ctor()
    self._actionId = 0

    self._name = "江湖夺宝"

    self._desc = "江湖夺宝江湖夺宝江湖夺宝江湖夺宝江湖夺宝"

    self._goodsInfo = {}

    self._goodsType = {}

    self._exchangeInfo = {}

    self._exchangeType = {}

    self._currencyList = {}
end

function CuiLianCaiLiaoStore:setRole(role)
    self._role = role
end

function CuiLianCaiLiaoStore:setActionId(actionId)
    self._actionId = actionId
end

function CuiLianCaiLiaoStore:init(callback)
    local currencyVersion = self._role:getCurrencyVersion()
    HttpManagerEx:getCuiLianCaiLiaoStoreList(self._actionId, currencyVersion, function(status, errcode, errmsg, data)
        if status == 200 and errcode == 0 then
            self._name = data.act_name

            local desc = ""

            if MapIsEmpty(data.detail_desc) == false then
                for i, v in ipairs(data.detail_desc) do
                    desc = desc .. v .. "\n"
                end
            end

            self._desc = desc

            --已获得积分
            self._jifen = data.integral_number
            --积分上限
            self._jifenLimit = data.integral_limit

            self._currencyList = data.currency_list
            --gem_list  展示的奖励数据
            self:__dealWithGoodsInfo(data.buy_list)

            self:__dealWithExchangeInfo(data.exchange_list)

            if data.currencyVersion then
                self._role:setCurrencyVersion(data.currencyVersion)
            end

            if callback then
                callback()
            end
        else
            PopText(errmsg)
        end
    end,IS_SHOW_WAITING)
end

function CuiLianCaiLiaoStore:getJifen()
    return self._jifen
end

function CuiLianCaiLiaoStore:getJifenLimit()
    return self._jifenLimit
end

function CuiLianCaiLiaoStore:getCurrencyById(currencyId)
    for k, v in pairs(self._currencyList) do
        if currencyId == v.id then
            return v.name, v.number
        end
    end
end

function CuiLianCaiLiaoStore:getActionName()
    return self._name
end

function CuiLianCaiLiaoStore:getActionDesc()
    return self._desc
end

function CuiLianCaiLiaoStore:getGoodsInfoByType(goodsType)
    local info = {}
    for i, v in ipairs(self._goodsInfo) do
        if goodsType == v.type then
            table.insert(info, v)
        end
    end

    table.sort(info, function(a, b)
        if a.state == 2 and b.state ~= 2 then
            return false
        elseif b.state == 2 and a.state ~= 2 then
            return true
        else
            return a.id > b.id
        end
    end)

    return info
end

function CuiLianCaiLiaoStore:getGoodsType()
    return self._goodsType
end

function CuiLianCaiLiaoStore:getExchangeTypeList()
    return self._exchangeType
end

function CuiLianCaiLiaoStore:getExchangeInfoByType(exchangeType)
    local info = {}
    for i, v in ipairs(self._exchangeInfo) do
        if exchangeType == v.type then
            table.insert(info, v)
        end
    end

    return info
end

function CuiLianCaiLiaoStore:doBuy(id, currencyId, func)
    local currencyVersion = self._role:getCurrencyVersion()
    HttpManagerEx:buyCuiLianCaiLiaoStoreGoods(self._actionId, id, currencyId, currencyVersion, function(status, errcode, errmsg, data)
        if status == 200 and errcode == 0 then
            if data.currencyVersion then
                self._role:setCurrencyVersion(data.currencyVersion)
            end

            if func then
                func()
            end
        else
            PopText(errmsg)
        end
    end,IS_SHOW_WAITING)

end

function CuiLianCaiLiaoStore:doReward(rid, is_email, func)
    local dataVer = self._role:getServerActionSystem():getDataVersion()

    HttpManagerEx:getCuiLianCaiLiaoStoreReward(self._actionId, rid, is_email, dataVer, function(status, errcode, errmsg, data)
        if status == 200 and errcode == 0 then
            GoodsHelper:fromNetworkGrantGoods(self._role,GrantGoodRequest:create({goodsList = data.rewards, dataVersion = data.dataVer, yashiExpiredTime = data.yashi_expired_time}))

            ActionRewardsHelper:printGetRewardsText(data.rewards)

            if data.msg then
                PopText(data.msg)
            end

            if func then
                func()
            end
        else
            PopText(errmsg)
        end
    end,IS_SHOW_WAITING)
end

function CuiLianCaiLiaoStore:doExchange(id, num, callback)
    local currencyVersion = self._role:getCurrencyVersion()

    HttpManagerEx:exchangeCuiLianCaiLiaoStoreIntegral(self._actionId, id, num, currencyVersion,function(status, errcode, errmsg, data)
        if status == 200 and errcode == 0 then
            local goodsList = data.items

            for k, goodsInfo in pairs(goodsList) do
                local goods = GoodsHelper:getGoodsResClass(goodsInfo.id)
                PopText("扣除"..goods:getName().."X"..tostring(math.abs(goodsInfo.num)))
            end

            GoodsHelper:fromNetworkGrantGoods(self._role,GrantGoodRequest:create({goodsList = goodsList}))

            if data.currencyVersion then
                self._role:setCurrencyVersion(data.currencyVersion)
            end

            if callback then
                callback()
            end
        else
            PopText(errmsg)
        end
    end,IS_SHOW_WAITING)
end

function CuiLianCaiLiaoStore:checkCanGetReward(rewards)
    local isTrue, msg = ActionRewardsHelper:checkBagCanGetRewards(rewards, self._role)

    if msg then
        PopText(msg)
    end
    
    return isTrue
end

function CuiLianCaiLiaoStore:__dealWithGoodsInfo(list)
    self._goodsInfo = {}
    self._goodsType = {}
    local typeAddList = {}
    for k, v in pairs(list) do
        local info = {}
        info.id = v.id
        info.type = v.type
        info.state = v.state
        info.rewards = v.rewards
        info.text1 = v.text
        info.price = v.price
        info.stock = v.stock

        local str = ""
        for k, v in pairs(v.rewards) do
            local goods = GoodsHelper:getGoodsResClass(v.id)
            str = str .. goods:getName() .. "X"..v.num .. "、"
        end

        info.text2 = string.sub(str, 1, -4)
        info.text3 = "原价："..v.original_price
        info.text4 = "剩余购买" .. v.stock .. "次"


        local priceNum = v.price[1].number
        local priceUnit = v.price[1].priceUnit
        local currencyName = self:getCurrencyById(priceUnit)

        info.btnName = priceNum..currencyName
        info.loadTexture = "Image/UI/MapUI/anniu05.png"
        info.enable = true

        if v.state == 1 then
            info.btnName = "领取"
        elseif v.state == 2 then
            info.btnName = "已售罄"
            info.loadTexture = "Image/UI/MapUI/anniu04.png"
            info.enable = false
        end

        if not typeAddList[v.type] then
            typeAddList[v.type] = true
            table.insert(self._goodsType, v.type)
        end

        table.insert(self._goodsInfo, info)
    end

    table.sort(self._goodsType, function(a, b)
        if CuiLianTypeSort[a] < CuiLianTypeSort[b] then
            return true
        else
            return false
        end
    end)
end

function CuiLianCaiLiaoStore:__dealWithExchangeInfo(list)
    self._exchangeInfo = {}
    self._exchangeType = {}
    local typeAddList = {}
    local currencyName = self:getCurrencyById("liujinye")
    for k, v in pairs(list) do
        local info = {}
        info.id = v.id
        info.type = v.type
        info.goodsId = v.goodsId

        local goods = GoodsHelper:getGoodsResClass(v.goodsId)
        info.name = goods:getName()
        info.maxCount = self._role:getItemCount(goods:getItemId())
        info.price = v.integral

        info.text1 = goods:getName()
        info.text2 = "当前拥有："..info.maxCount
        info.text3 = "单个可兑换"..currencyName.."："..v.integral
        info.loadTexture = "Image/UI/MapUI/anniu05.png"
        info.btnName = "兑换"
        info.enable = true

        if info.maxCount <= 0 then
            info.loadTexture = "Image/UI/MapUI/anniu04.png"
            info.enable = false
        end

        if not typeAddList[v.type] then
            typeAddList[v.type] = true
            table.insert(self._exchangeType, v.type)
        end
       
        table.insert(self._exchangeInfo, info)
    end

    table.sort(self._exchangeType, function(a, b)
        if CuiLianTypeSort[a] < CuiLianTypeSort[b] then
            return true
        else
            return false
        end
    end)
end


return class("CuiLianCaiLiaoStore", {}, CuiLianCaiLiaoStore)
00000