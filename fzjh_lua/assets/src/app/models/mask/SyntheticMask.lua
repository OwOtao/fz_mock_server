local NewClass = require("third.class.NewClass")

local specialSyntheticMask = require("script.others.specialSyntheticMask")["面具配置"]

local specialMaskgift = require("script.activity.specialMaskgift")["Sheet1"]

local SyntheticMask = {}

function SyntheticMask:create(id)
    local p = SyntheticMask.new()
    p:init(id)
    return p
end

function SyntheticMask:init(id)
    self.__maskRes = assert(specialSyntheticMask[tonumber(id)], "没有找到特殊面具合成数据 id = " .. id)

    self.__giftRes = assert(specialMaskgift[tonumber(id)], "没有找到墨千秋合成奖励资源 id = " .. id)
end
						
function SyntheticMask:getId()
    return self.__maskRes.id
end

function SyntheticMask:getGoodsId()
    return self.__maskRes.goodsId
end

function SyntheticMask:getSeries()
    return self.__maskRes.series
end

function SyntheticMask:getSorts()
    return self.__maskRes.sorts
end

function SyntheticMask:getMakeCondition()
    return self.__maskRes.makecondition
end

function SyntheticMask:getRewardsdays()
    return self.__giftRes.rewardsdays
end

function SyntheticMask:getRewards()
    return self.__giftRes.rewards
end

function SyntheticMask:getBegintime()
    return self.__giftRes.begintime
end

function SyntheticMask:getFinishtime()
    return self.__giftRes.finishtime
end

function SyntheticMask:getRewardLimit()
    return self.__giftRes.limit
end

return NewClass("SyntheticMask", {}, SyntheticMask)
0000