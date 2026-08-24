local class = require("third.class.NewClass")
local ActionRewardsHelper = require("app.models.Action.ActionRewardsHelper")
local GoodsHelper = require("app.models.Store.GoodsHelper")
local GrantGoodRequest = require("app.models.Store.GrantGoodRequest")

local SpringEquinox = {}

function SpringEquinox:create()
    return SpringEquinox:new()
end

function SpringEquinox:ctor()
	self.__giftList = {
		-- {
		-- 	--礼包id
		-- 	giftId = 1,
		-- 	--奖励项id列表
		-- 	ridList = {
		-- 	"1001",
		-- 	"1002",
		-- 	"1003",
		-- 	"1004",
		-- 	},
		-- 	giftIcon = "Image/UI/StoreUI/xiangzi1.png",
		-- 	giftName = "福利礼包",
		-- 	--礼包类型（1， 全部获取 2 随机抽取一个）
		-- 	giftType = 1
		-- },
		-- {
		-- 	--礼包id
		-- 	giftId = 2,
		-- 	--奖励项id列表
		-- 	ridList = {
		-- 	"2001",
		-- 	"2002",
		-- 	"2003",
		-- 	"2004",
		-- 	"2005",
		-- 	"2006",
		-- 	"2007",
		-- 	"2008",
		-- 	"2009",
		-- 	"2010",
		-- 	"2011",
		-- 	},
		-- 	giftIcon = "Image/UI/StoreUI/xiangzi1.png",
		-- 	giftName = "幸运礼包",
		-- 	--礼包类型（1， 全部获取 2 随机抽取一个）
		-- 	giftType = 2,
		-- }
	}

	self.__goodsList = {
		-- ["1001"]={goodsId = "300006",num = 1},
		-- ["1002"]={goodsId = "400005",num = 200},
		-- ["1003"]={goodsId = "400017",num = 40},
		-- ["1004"]={goodsId = "300004",num = 1},
		-- ["2001"]={goodsId = "300530",num = 1},
		-- ["2002"]={goodsId = "200013",num = 1},
		-- ["2003"]={goodsId = "200014",num = 1},
		-- ["2004"]={goodsId = "200015",num = 1},
		-- ["2005"]={goodsId = "200016",num = 1},
		-- ["2006"]={goodsId = "300035",num = 1},
		-- ["2007"]={goodsId = "200020",num = 2},
		-- ["2008"]={goodsId = "200018",num = 2},
		-- ["2009"]={goodsId = "200019",num = 2},
		-- ["2010"]={goodsId = "300036",num = 2},
		-- ["2011"]={goodsId = "300014",num = 1},
	}

	self.__rewardList = {
		-- {
		-- 	id = 1,
		-- 	needMoney = 50,
		-- 	giftList = {
		-- 		{
		-- 			giftId = 1,
		-- 			giftNum = 2
		-- 		},
		-- 		{
		-- 			giftId = 2,
		-- 			giftNum = 4
		-- 		},
		-- 	},
		-- 	--0 不可领取 1 可领取 2已领取
		-- 	state = 1 
		-- },
	}
end

function SpringEquinox:setRole(role)
    self._role = role
end

local stateSort = {
	["1"] = 1, --可领取
	["0"] = 2, --待领取
	["2"] = 3  --已领取
}

function SpringEquinox:init(func)
    HttpManagerEx:getRechargeBenefitsInfo(function (status, errcode, errmsg, data, isEncrypted)
		if status == 200 and errcode == 0 then
			--礼包信息
			self.__giftList = data.giftList
			--奖励id与商品关联信息
			self.__goodsList = data.goodsList
			--奖励信息
			self.__rewardList = data.rewardList

			table.sort(self.__rewardList, function(a, b)
				if tonumber(a.state) == tonumber(b.state) then
					return tonumber(a.id) < tonumber(b.id)
				else
					return stateSort[tostring(a.state)] < stateSort[tostring(b.state)]
				end
			end)
			--累计充值数量
			self.__totalMoney = data.totalRecharge

            if func then
                func()
            end
		else
			PopText(errmsg)
		end
	end,IS_SHOW_WAITING)
end

function SpringEquinox:getTotalMoney()
	return self.__totalMoney
end

function SpringEquinox:getGoodsInfoByRid(rid)
	return self.__goodsList[tostring(rid)]
end

function SpringEquinox:getGiftInfoByGiftId(giftId)
	for k, v in ipairs(self.__giftList) do
		if v.giftId == giftId then
			return v
		end
	end
end

function SpringEquinox:getGiftList()
	return self.__giftList
end

function SpringEquinox:getRewardList()
	return self.__rewardList
end

function SpringEquinox:getGiftGoodsInfoList(giftId)
	local goodsInfoList = {}

	for k, v in ipairs(self.__giftList) do
		if v.giftId == giftId then
			local list = v.ridList

			for k, rid in ipairs(list) do
				local goodsInfo = self:getGoodsInfoByRid(rid)
				table.insert(goodsInfoList, {id = goodsInfo.goodsId, num = goodsInfo.num})
			end

			break
		end
	end

	return goodsInfoList
end

function SpringEquinox:getRewardGoodsInfoList(id)
	local rewardGoodsInfoList = {}

	for k, reward in ipairs(self.__rewardList) do
		if reward.id == id then
			for i, giftInfo in ipairs(reward.giftList) do
				local gift = self:getGiftInfoByGiftId(giftInfo.giftId)

				if gift.giftType == 1 then
					local goodsInfoList = self:getGiftGoodsInfoList(giftInfo.giftId)

					for __, goodsInfo in ipairs(goodsInfoList) do
						table.insert(rewardGoodsInfoList, {id = goodsInfo.id, num = giftInfo.giftNum * goodsInfo.num})
					end

				elseif gift.giftType == 2 then
					--随机礼包默认使用武器作为一个背包空间判断
					table.insert(rewardGoodsInfoList, {id = "300009", num = giftInfo.giftNum})
				end
			end
		end
	end

	return rewardGoodsInfoList
end

function SpringEquinox:getGoodsListText(goodsList)
	return ActionRewardsHelper:getRewardText(goodsList)
end

function SpringEquinox:checkCanGetReward(rewards)
	return ActionRewardsHelper:checkBagCanGetRewards(rewards, self._role)
end

function SpringEquinox:getRewards(id, func)
	local rewardGoodsList = self:getRewardGoodsInfoList(id)

	local isEmail = 1

	if self:checkCanGetReward(rewardGoodsList) then
		isEmail = 0
	end

    local dataVer = self._role:getServerActionSystem():getDataVersion()

    local currencyVersion = self._role:getCurrencyVersion()

	HttpManagerEx:getRechargeBenefitsReward(id, isEmail, dataVer, currencyVersion, function(status, errcode, errmsg, data, isEncrypted)
		if status == 200 and errcode == 0 then
            GoodsHelper:fromNetworkGrantGoods(self._role,GrantGoodRequest:create({goodsList = data.reward, dataVersion = data.dataVer, currencyVersion = data.currencyVersion}))
			
			ActionRewardsHelper:printGetRewardsText(data.reward)

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


return class("SpringEquinox", {}, SpringEquinox)
00