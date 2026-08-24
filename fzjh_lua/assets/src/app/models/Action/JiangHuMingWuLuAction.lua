local class = require("third.class.NewClass")

local JiangHuMingWuLuAction = {}

-- local FLAG_NAME = "baijianyiren"

function JiangHuMingWuLuAction:create()
    return JiangHuMingWuLuAction:new()
end

function JiangHuMingWuLuAction:ctor()
    self.__actionId = 0

    self.__name = ""

    self.__desc = ""

    self.__lotteryList = {}

    self.__buttonInfos = {}
end

-- local testData = {
--     ["act_name"] = "江湖名武录",
--     ["detail_time"] = "",
--     ["detail_desc"] = {""},
--     ["lottery_list"] = {
--         {
--             id = 12,
--             itemId = "jingxinwan",
--             itype = 10,
--             inde = 9,
--             name = "静心丸",
--             price = 50,
--             number = 1,
--             dsc1 = "颗散发着淡淡香气的药丸，具有凝神静心的功效，可以提升闭关修炼成功率，并且不会走火入魔。",
--             dsc2 = "使用后可以提升闭关修炼成功率，并且不会走火入魔。",
--             share = "",
--             icon = "Image/UI/StoreUI/jingxinwan.png",
--             to = 0,
--             from = 0,
--             showType = 0,
--             prob = 0.15
--         },
--         {
--             id = 38,
--             itemId = "qiannengdan",
--             itype = 0,
--             inde = 1000,
--             name = "潜能丹",
--             price = 0,
--             number = 1,
--             dsc1 = "",
--             dsc2 = "",
--             share = "",
--             icon = "Image/UI/StoreUI/zhuzi.png",
--             to = 0,
--             from = 0,
--             showType = 0,
--             prob = 0.15
--         },
--         {
--             id = 3599,
--             itemId = "xinggongsan",
--             itype = 0,
--             inde = 0,
--             name = "行功散",
--             price = 0,
--             number = 1,
--             dsc1 = "这是一粒淡蓝色的药丸，散发着浓重的药味。",
--             dsc2 = "",
--             share = "",
--             icon = "Image/UI/StoreUI/jingxinwan.png",
--             to = 0,
--             from = 0,
--             showType = 1,
--             prob = 0.15
--         },
--         {
--             id = 2699,
--             itemId = "liuyunganlu",
--             itype = 10,
--             inde = 0,
--             name = "HIG流云甘露NOR",
--             price = 80,
--             number = 1,
--             dsc1 = "这是一瓶用玉瓶装着的流云甘露",
--             dsc2 = "据说使用后会提升人物的精力，比天香玉露更胜一筹。",
--             share = "",
--             icon = "Image/UI/StoreUI/liuyunganlu.png",
--             to = 0,
--             from = 0,
--             showType = 1,
--             prob = 0.15
--         }
--     },
--     button = {
--         {
--             ["name"] = "抽一次",
--             ["times"] = 1,
--             ["removeCurrency"] = 80,
--             ["imagePath"] = "Image/UI/StoreUI/lingpai2.png"
--         },
--         {
--             ["name"] = "抽五次",
--             ["times"] = 5,
--             ["removeCurrency"] = 400,
--             ["imagePath"] = "Image/UI/StoreUI/lingpai2.png"
--         }
--     },
--     exchange_currency = {
--         ["id"] = "wuxueminglu",
--         ["name"] = "武学名录",
--         ["count"] = 0
--     },
--     currency = {
--         id = "jianghuling",
--         name = "江湖令",
--         count = 0
--     },
--     buy_good = {
--         id = 5580,
--         itemId = "yxjianghuling1",
--         name = "江湖令"
--     }
-- }
function JiangHuMingWuLuAction:setRole(role)
    self._role = role
end

function JiangHuMingWuLuAction:init(callback)
    HttpManagerEx:getMingWuLotteryList(
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    self.__actionId = data.act_id

                    self.__name = data.act_name

                    local desc = ""

                    desc = desc .. data.detail_time .. "\n"

                    if MapIsEmpty(data.detail_desc) == false then
                        for i, v in ipairs(data.detail_desc) do
                            desc = desc .. v .. "\n"
                        end
                    end

                    self.__endTime = data.end_time

                    self.__desc = desc

                    self.__lotteryList = data.lottery_list

                    self.__exchangeCurrencyId = data.exchange_currency.id

                    self.__exchangeCurrencyName = data.exchange_currency.name

                    self.__exchangeCurrencyCount = data.exchange_currency.count

                    self.__currencyId = data.currency.id

                    self.__currencyName = data.currency.name

                    self.__currencyCount = data.currency.count

                    self.__buyGoodId = data.buy_good.id

                    self.__buyGoodItemId = data.buy_good.itemId

                    self.__buyGoodName = data.buy_good.name

                    self.__buttonInfos = data.button

                    self.__act_times = data.act_times

                    self.__exchageRewardList = self:__initExchangeList()

                    callback()
                else
                    PopText(errmsg)
                end
            else
                PopText(errmsg)
            end
        end,
        IS_SHOW_WAITING
    )
end

function JiangHuMingWuLuAction:__initExchangeList()
    local configList = require("script.others.jianghumingwulu.lua")["Sheet1"]

    local list = {}

    local maxId = 0

    for k, v in pairs(configList) do
        if self.__act_times == v.time then
            --@desc 这个兑换类型当成
            v.rewardType = 1
            table.insert(list, v)

            if v.id > maxId then
                maxId = v.id
            end
        end
    end

    table.sort(
        list,
        function(a, b)
            if a.id < b.id then
                return true
            end

            return false
        end
    )

    return list
end

function JiangHuMingWuLuAction:getActionName()
    return self.__name
end

function JiangHuMingWuLuAction:getActionDesc()
    return self.__desc
end

function JiangHuMingWuLuAction:getActionEndTime()
    return self.__endTime
end

function JiangHuMingWuLuAction:getAllRewards()
    return self.__lotteryList
end

function JiangHuMingWuLuAction:getExchageRewardList()
    return self.__exchageRewardList
end

function JiangHuMingWuLuAction:getShowRewards()
    local list = {}

    if MapIsEmpty(self.__lotteryList) == false then
        for i, v in ipairs(self.__lotteryList) do
            if #list == 4 then
                break
            end

            if v.showType == 1 then
                table.insert(list, v)
            end
        end
    end

    return list
end

function JiangHuMingWuLuAction:getExchangeCurrencyId()
    return self.__exchangeCurrencyId
end

function JiangHuMingWuLuAction:getExchangeCurrencyName()
    return self.__exchangeCurrencyName
end

function JiangHuMingWuLuAction:getExchangeCurrencyCount()
    return self.__exchangeCurrencyCount
end

function JiangHuMingWuLuAction:setExchangeCurrencyCount(value)
    self.__exchangeCurrencyCount = value
end

function JiangHuMingWuLuAction:getCurrencyId()
    return self.__currencyId
end

function JiangHuMingWuLuAction:getCurrecnyName()
    return self.__currencyName
end

function JiangHuMingWuLuAction:getCurrencyCount()
    return self.__currencyCount
end

function JiangHuMingWuLuAction:setCurrencyCount(value)
    self.__currencyCount = value

    if self:getCurrecnyName() == "yuanbao" then
        self._role:setAttr("yuanbao", self.__currencyCount)
    end
end

function JiangHuMingWuLuAction:getBuyGoodId()
    return self.__buyGoodId
end

function JiangHuMingWuLuAction:getBuyGoodItemId()
    return self.__buyGoodItemId
end

function JiangHuMingWuLuAction:getButtonInfo()
    return self.__buttonInfos
end

function JiangHuMingWuLuAction:getExchangeRewardInfo(index)
    return self.__exchageRewardList[index]
end

function JiangHuMingWuLuAction:doLottery(index, callback)
    local btnInfo = self.__buttonInfos[index]

    if self:getCurrencyCount() < btnInfo.removeCurrency then
        --@desc 抽奖消耗的数量不足
        return callback(2)
    end

    local role_weight = self._role:getAttr("weight")

    if role_weight - #self._role:getItems() < btnInfo.times then
        PopText("您的背包不足" .. btnInfo.times .. "格，请先清理背包。")
        return
    end

    HttpManagerEx:doMingWuLottery(
        btnInfo.times,
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    local rewards = data.prize

                    if MapIsEmpty(rewards) == false then
                        for i = 1, #rewards do
                            local reward = rewards[i]

                            if reward.sendFrom == "client" then
                                self._role:addItemCount(reward.itemId, reward.number)
                            end
                        end
                    end

                    self:setExchangeCurrencyCount(data.exchange_currency)

                    self:setCurrencyCount(data.currency)

                    callback(1, data)
                elseif errcode == 3 then
                    callback(2)
                else
                    PopText(errmsg)
                end
            else
                PopText(errmsg)
            end
        end,
        IS_SHOW_WAITING
    )
end

-- function JiangHuMingWuLuAction:rewardIsExchanged(reward)
--     local records = self._role:getInheritFlag(FLAG_NAME)

--     if records == 0 then
--         return false
--     end

--     if records[reward.mianju] == true then
--         return true
--     else
--         return false
--     end
-- end

function JiangHuMingWuLuAction:exchangeReward(index, successCallback)
    local currExchangeReward = self:getExchangeRewardInfo(index)

    if currExchangeReward.rewardType == 1 then
        return self:__exchangeItemReward(currExchangeReward, successCallback)
    end
end

function JiangHuMingWuLuAction:__exchangeItemReward(reward, successCallback)
    local items = self._role:getAttr("items")
    if self._role:getAttr("weight") - #items < 1 then
        PopText("您的背包不足1格，请先清理背包。")
        return false
    end

    -- if self:rewardIsExchanged(reward) == true then
    --     local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
    --     local dialog = DialogALayer:getInstance()
    --     dialog:hide()
    --     local str1 = "你曾在过往拜访过此名人，继续拜访将获得重复面具，是否继续拜访？"
    --     dialog:show(str1)
    --     dialog:setBack(false)
    --     dialog:setButton2(
    --         "取消",
    --         function()
    --         end
    --     )
    --     dialog:setButton1(
    --         "确定",
    --         function()
    --             self:__exchangeItem(reward, successCallback)
    --         end
    --     )
    -- else
    local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
    local dialog = DialogALayer:getInstance()
    dialog:hide()
    local str1 = "是否要花费" .. tostring(reward.need) .. "张" .. self:getExchangeCurrencyName() .. "兑换" .. tostring(Helper:getDef(reward.title,"")) .. "" .. tostring(reward.name) .. "？"
    local str2 = "是否要花费YEL" .. tostring(reward.need) .. "NOR张" .. self:getExchangeCurrencyName() .. "兑换" .. tostring(Helper:getDef(reward.title,"")) .. "" .. tostring(reward.name) .. "？"
    dialog:show(str1)
    dialog:setRichText(str2)
    dialog:setBack(false)
    dialog:setButton2("取消", EMPTY_FUNC)
    dialog:setButton1(
        "确定",
        function()
            self:__exchangeItem(reward, successCallback)
        end
    )
end
-- end

function JiangHuMingWuLuAction:__exchangeItem(reward, successCallback)
    HttpManagerEx:detectionGoods(
        self:getExchangeCurrencyId(),
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    if tonumber(data.numbers) < tonumber(reward.need) then
                        self:setExchangeCurrencyCount(data.numbers)
                        PopText("你没有足够的" .. self:getExchangeCurrencyName())
                        return
                    end

                    HttpManagerEx:checkItemIsCanUse(
                        self:getExchangeCurrencyId(),
                        reward.need,
                        function(status, errcode, errmsg, data)
                            if status == 200 then
                                if errcode == 0 then
                                    -- local records = self._role:getInheritFlag(FLAG_NAME)
                                    -- if records == nil or type(records) ~= "table" then
                                    --     records = {}
                                    -- end
                                    -- records[reward.mianju] = true

                                    -- self._role:setInheritFlag(FLAG_NAME, records)

                                    self._role:addItemCount(reward.itemId, 1)

                                    self:setExchangeCurrencyCount(data.numbers)

                                    successCallback(reward.rewardType, reward)
                                else
                                    PopText(errmsg)
                                end
                            else
                                PopText(errmsg)
                            end
                        end,
                        IS_SHOW_WAITING
                    )
                else
                    PopText(errmsg)
                end
            else
                PopText(errmsg)
            end
        end,
        IS_SHOW_WAITING
    )
end

return class("JiangHuMingWuLuAction", {}, JiangHuMingWuLuAction)
0000000