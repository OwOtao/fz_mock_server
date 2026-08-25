local GoodsHelper = require("app.models.Store.GoodsHelper")

local ActionRewardsHelper = {}

--检测背包是否可以领取奖励礼包
--return bool:true|false msg:"不能领取原因文本"
-- rewards = {
--     {
--         id = "商品表id",
--         num = "数量"
--     },
--     ...
-- }
function ActionRewardsHelper:checkBagCanGetRewards(rewards, role)
    local isTrue = GoodsHelper:checkRoleBagGoods(role, rewards)
    local msg = ""

    if isTrue == false then
        msg = "背包容量达到上限，无法将物品放入背包"
    end

    return isTrue, msg
end

--打印礼包奖励获取提示
-- rewards = {
--     {
--         id = "商品表id",
--         num = "数量"
--     },
--     ...
-- }
function ActionRewardsHelper:printGetRewardsText(rewards)
    if MapIsEmpty(rewards) == false then
        for i,v in ipairs(rewards) do
            local goods = GoodsHelper:getGoodsResClass(v.id)

            if goods:getItemId() == "jmskillpage" then
                PopText("你已领悟解锁护元经脉，可以进行配置调整")
            else
                PopText("获得"..goods:getName().."X"..tostring(v.num))
            end
        end
    end
end

--[[
    @desc: 获取奖励文本
    author:tanqinjian
    time:2025-08-30 18:28:44
    --@rewards: {{id = "商品表id", num = "数量"},...}
    @return:string 奖励文本
]]
function ActionRewardsHelper:getRewardText(rewards)
    local text = ""

    if MapIsEmpty(rewards) == false then
        for i = 1, #rewards, 1 do
            local goods = GoodsHelper:getGoodsResClass(rewards[i].id)

            text = text..goods:getName().."X"..tostring(rewards[i].num)

            if i < #rewards then
                text = text .. "、"
            end
        end
    end

    return text
end

return ActionRewardsHelper
00000000