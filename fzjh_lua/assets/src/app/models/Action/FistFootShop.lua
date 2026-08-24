local class = require("third.class.NewClass")

local GoodsHelper = require("app.models.Store.GoodsHelper")

local ShopDayConf = require("script.activity.fistFoot.dayConf")["天数设定"]

local ShopCostConf = require("script.activity.fistFoot.costConf")["消耗设定"]

local ShopRewardConf = require("script.activity.fistFoot.rewardConf")["奖励设定"]

local FistFootShop = {}

function FistFootShop:create()
    return FistFootShop:new()
end

function FistFootShop:ctor()
    self.__actionId = 0

    self.__name = ""

    self.__desc = ""

    self.__dailyDefaultCost = 0

    self.__daySelectCost = 0

    self.__specialOfferState = 0 --0，特惠购买未开启；1，开启；2，已购买

    self.__specialOfferStartDate = nil

    self.__specialOfferCost = 0

    self.__specialOfferUseDiscountRate = 0

    self.__specialOfferGainList = {}

    self.__discountRate = 0

    self.__dailySelectList = {}
end

function FistFootShop:setRole(role)
    self.__role = role
end

function FistFootShop:setActionId(actionId)
    self.__actionId = actionId
end

function FistFootShop:getFistFootShopInfo(callback)
    HttpManagerEx:getFistFootShopInfo(function(status, errcode, errmsg, data)
        if status == 200 and errcode == 0 then
            self.__name = data.activityName

            local desc = ""

            if MapIsEmpty(data.activityDesc) == false then
                for i, v in ipairs(data.activityDesc) do
                    desc = desc .. v .. "\n"
                end
            end

            self.__desc = desc

            self.__dailyDefaultCost = data.dailyDefaultCost

            self:setDaySelectCost(data.dailySelectCost)

            self:setSpecialOfferState(data.specialOfferState)

            self.__specialOfferStartDate = data.specialOfferStartDate
            
            self:setSpecialOfferOrder(data.specialOfferOrder)

            self:setDiscountRate(data.discountRate)
            
            self:setDailySelectList(data.dailySelectList)

            if callback then
                callback()
            end
        else
            PopText(errmsg)
        end
    end,IS_SHOW_WAITING)
end

--@desc: 设置每日选择消耗
--@author:LvBin
--@time:2024-11-07 11:36:01
--@daySelectCost:
	--@callback: 
--@return
function FistFootShop:setFistFootShopDailyCost(daySelectCost,callback)
    HttpManagerEx:setFistFootShopDailyCost(
        daySelectCost,
        function(status, errcode, errmsg, data)
            if status == 200 and errcode == 0 then
                self:setDaySelectCost(daySelectCost)

                if callback then
                    callback()
                end
            else
                PopText(errmsg)
            end
        end,
    IS_SHOW_WAITING)
end

--@desc: 购买每日商品
--@author:LvBin
--@time:2024-11-07 20:23:35
--@callback: 
--@return
function FistFootShop:buyFistFootShopDailyGoods(dayId,callback)
    local dataVer = self.__role:getServerActionSystem():getDataVersion()

    HttpManagerEx:buyFistFootShopDailyGoods(
        dayId,
        dataVer,
        function(status, errcode, errmsg, data)
            if status == 200 and errcode == 0 then
                self:setDiscountRate(data.discountRate)
                
                self:setSpecialOfferState(data.specialOfferState)

                table.insert(self.__dailySelectList,data.tierId)
                
                if data.dataVer then
                    self.__role:getServerActionSystem():setDataVersion(data.dataVer)
                end

                if callback then
                    callback(data.reward)
                end

                if data.msg then
                    PopText(data.msg)
                end
            else
                PopText(errmsg)
            end
        end,
    IS_SHOW_WAITING)
end

--@desc: 特惠购买
--@author:LvBin
--@time:2024-11-07 18:17:18
--@specialOfferCost:特惠购买自定义金额
--@callback: 
--@return
function FistFootShop:buyFistFootShopSpecialOffer(specialOfferCost,callback)
    local dataVer = self.__role:getServerActionSystem():getDataVersion()
    
    HttpManagerEx:buyFistFootShopSpecialOffer(
        specialOfferCost,
        dataVer,
        function(status, errcode, errmsg, data)
            if status == 200 and errcode == 0 then
                self.__specialOfferCost = data.specialOfferCost

                self.__specialOfferUseDiscountRate = data.useDiscountRate

                self.__specialOfferGainList = data.reward

                self:setSpecialOfferState(data.specialOfferState)

                if data.dataVer then
                    self.__role:getServerActionSystem():setDataVersion(data.dataVer)
                end
                
                if callback then
                    callback(data.reward)
                end

                if data.msg then
                    PopText(data.msg)
                end
            else
                PopText(errmsg)
            end
        end,
    IS_SHOW_WAITING)
end

function FistFootShop:getActionName()
    return self.__name
end

function FistFootShop:getActionDesc()
    return self.__desc
end

function FistFootShop:setDailySelectList(list)
    self.__dailySelectList = list
end

function FistFootShop:getDailySelectList()
    return self.__dailySelectList
end

function FistFootShop:getDailyDefaultCost()
    return self.__dailyDefaultCost
end

--@desc: 选择的每日消耗元宝数
--@author:LvBin
--@time:2024-11-05 15:02:10
--@costNum: 
--@return
function FistFootShop:setDaySelectCost(costNum)
    self.__daySelectCost = costNum
end

function FistFootShop:getDaySelectCost()
    return self.__daySelectCost
end

function FistFootShop:setSpecialOfferState(specialOfferState)
    self.__specialOfferState = specialOfferState
end

function FistFootShop:getSpecialOfferState()
    return self.__specialOfferState
end

function FistFootShop:getSpecialOfferStartDate()
    return self.__specialOfferStartDate
end

function FistFootShop:setSpecialOfferOrder(specialOfferOrder)
    if MapIsEmpty(specialOfferOrder) then
        return
    end

    self.__specialOfferCost = specialOfferOrder.cost

    self.__specialOfferUseDiscountRate = specialOfferOrder.useDiscountRate

    self.__specialOfferGainList = specialOfferOrder.gain
end

function FistFootShop:getSpecialOfferCost()
    return self.__specialOfferCost
end

function FistFootShop:getSpecialOfferUseDiscountRate()
    return self.__specialOfferUseDiscountRate
end

function FistFootShop:getSpecialOfferGainList()
    return self.__specialOfferGainList
end

function FistFootShop:setDiscountRate(discountRate)
    self.__discountRate = discountRate
end

function FistFootShop:getDiscountRate()
    return self.__discountRate
end

function FistFootShop:__getYuanBaoCostConf()
    return ShopCostConf.yuanbao
end

function FistFootShop:getDayCostMinLimit()
    return self:__getYuanBaoCostConf().minlimit
end

function FistFootShop:getDayCostMaxLimit()
    return self:__getYuanBaoCostConf().maxlimit
end

function FistFootShop:getDayCostMultiple()
    return self:__getYuanBaoCostConf().multiple
end

function FistFootShop:getSpecialOfferRewards()
    return self:__getYuanBaoCostConf().rewards
end

function FistFootShop:getCostIcon()
    return self:__getYuanBaoCostConf().icon
end

function FistFootShop:getShopDayList()
    return ShopDayConf
end

--@desc: 获取指定天数的特惠购买基数
--@author:LvBin
--@time:2024-11-07 16:49:46
--@dayId: 
--@return
function FistFootShop:getDiscountByDayId(dayId)
    return ShopDayConf[dayId].discount
end

--@desc: 获取最后一天的特惠购买基数
--@author:LvBin
--@time:2024-11-07 16:26:26
--@return
function FistFootShop:getLastDayDiscount()
    return ShopDayConf[#ShopDayConf].discount
end

function FistFootShop:getItemPrice(id)
    return ShopRewardConf[tostring(id)].price
end

function FistFootShop:getItemName(id)
    local goodsId = ShopRewardConf[tostring(id)].goodsId

    local goods = GoodsHelper:getGoodsResClass(goodsId)

    return goods:getName()
end

function FistFootShop:getItemIcon(id)
    local goodsId = ShopRewardConf[tostring(id)].goodsId

    local goods = GoodsHelper:getGoodsResClass(goodsId)

    return goods:getIcon()
end

--@desc: 计算天数购买道具获取数量
--@author:LvBin
--@time:2024-11-06 15:40:50
--@numAdd:数量加成
--@id: 道具id
--@quota: 占比
--@return
function FistFootShop:ceilDayItemNum(id,numAdd,quota)
    local price = self:getItemPrice(id)

    local daySelectCost = self:getDaySelectCost() == 0 and self:getDailyDefaultCost() or self:getDaySelectCost()

    local num = math.floor(numAdd * daySelectCost * quota / price)

    return num
end

--@desc: 计算特殊优惠购买道具获取数量
--@author:LvBin
--@time:2024-11-07 16:39:27
--@id:
--@discountRate: 当前累计充值天数特惠基数
--@costNum:玩家自定义元宝数
--@quota: 道具占比
--@return
function FistFootShop:ceilSpecialOfferItemNum(id,discountRate,costNum,quota)
    local price = self:getItemPrice(id)

    local num = math.floor(discountRate * costNum * quota / price)

    return num
end

--@desc: 是否获得过这个档位
--@author:LvBin
--@time:2024-11-07 11:50:19
--@dayId:天数id
--@tierId:档位id
--@return
function FistFootShop:isGetTier(dayId,tierId)
    local dailySelectList = self:getDailySelectList()

    for i,v in ipairs(dailySelectList) do
        if i == dayId and v == tierId then
            return true
        end
    end

    return false
end

--@desc: 指定天数是否买过
--@author:LvBin
--@time:2024-11-07 11:50:19
--@dayId:天数id
--@tierId:档位id
--@return
function FistFootShop:isBuyDay(dayId)
    local dailySelectList = self:getDailySelectList()

    return #dailySelectList >= dayId
end


--@desc: 是否购买过每日道具
--@author:LvBin
--@time:2024-11-07 11:53:13
--@return
function FistFootShop:isBuyDailyItem()
    local dailySelectList = self:getDailySelectList()

    if #dailySelectList > 0 then
        return true
    end

    return false
end

--@desc: 已经购买了几天
--@author:LvBin
--@time:2024-11-07 20:36:01
--@return
function FistFootShop:buyDailyNum()
    local dailySelectList = self:getDailySelectList()

    return #dailySelectList
end

return class("FistFootShop", {}, FistFootShop)
0000