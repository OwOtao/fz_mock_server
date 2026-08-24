local class = require("third.class.NewClass")

local JiangHuYiRenLuAction = {}

local FLAG_NAME = "baijianyiren"

function JiangHuYiRenLuAction:create()
    return JiangHuYiRenLuAction:new()
end

function JiangHuYiRenLuAction:ctor()
    self.__actionId = 0

    self.__baifangmingtie = 0

    self.__name = ""

    self.__desc = ""

    self.__lotteryList = {}

    self.__buttonInfos = {}
end

-- local testData = {
--     data = {
--         act_id = "jianghuyirenlu",
--         act_name = "江湖异人录",
--         act_desc = "111111",
--         lottery_list = {
--             {
--                 itemId = "homemoney200",
--                 name = "HIC银票票据(200)NOR",
--                 num = 3,
--                 showType = 1,
--                 prob = 0.24,
--                 icon = "Image/UI/StoreUI/xiyanshui.png"
--             },
--             {
--                 itemId = "xinggongsan",
--                 name = "行功散",
--                 num = 1,
--                 showType = 1,
--                 prob = 0.24,
--                 icon = "Image/UI/StoreUI/xiyanshui.png"
--             },
--             {
--                 itemId = "sancaidan",
--                 name = "HIY三才丹NOR",
--                 num = 1,
--                 showType = 1,
--                 prob = 0.2,
--                 icon = "Image/UI/StoreUI/xiyanshui.png"
--             },
--             {
--                 itemId = "jiu106",
--                 name = "醉梦生",
--                 num = 1,
--                 showType = 1,
--                 prob = 0.17,
--                 icon = "Image/UI/StoreUI/xiyanshui.png"
--             },
--             {
--                 itemId = "yirenitem1",
--                 name = "异人名帖",
--                 num = 1,
--                 showType = 0,
--                 prob = 0.15,
--                 icon = "Image/UI/StoreUI/xiyanshui.png"
--             }
--         },
--         button = {
--             {
--                 name = "抽两次",
--                 time = 1,
--                 removeYb = 100
--             },
--             {
--                 name = "抽五次",
--                 time = 5,
--                 removeYb = 450
--             }
--         },
--         baifangmingtie = 21
--     }
-- }

function JiangHuYiRenLuAction:setRole(role)
    self._role = role
end

function JiangHuYiRenLuAction:init(callback)
    HttpManagerEx:getMingRenLotteryList(
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

                    self.__act_times = data.act_times

                    self.__desc = desc

                    self.__lotteryList = data.lottery_list

                    self.__baifangmingtie = tonumber(data.baifangmingtie)

                    self.__buttonInfos = data.button

                    self.__exchageRewardList = self:__initExchangeList()

                    self._role:setAttr("yuanbao", data.yuanbao)

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

function JiangHuYiRenLuAction:__initExchangeList()
    local configList = require("script.others.jianghuyirenlu.lua")["Sheet1"]

    local list = {}

    local maxId = 0

    for k, v in pairs(configList) do
        --@desc 这个兑换类型当成
        if self.__act_times == v.time then
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

    local lastItem = {
        ["id"] = maxId + 1,
        ["rewardType"] = 2,
        ["thankText"] = "",
        ["name"] = "CYN饰品材料NOR",
        ["mianju"] = "",
        ["title"] = "HIY等量兑换NOR",
        ["pic"] = [[Image/UI/StoreUI/mianju1001.png]],
        ["need"] = 0,
        ["introText"] = [[拜会名帖可在此兑换饰品材料，1张拜会名帖可兑换1个饰品材料。若少侠未兑换完心仪面具，不建议在此处兑换材料。]]
    }
    table.insert(list, lastItem)

    return list
end

function JiangHuYiRenLuAction:getActionName()
    return self.__name
end

function JiangHuYiRenLuAction:getActionDesc()
    return self.__desc
end

function JiangHuYiRenLuAction:getAllRewards()
    return self.__lotteryList
end

function JiangHuYiRenLuAction:getExchageRewardList()
    return self.__exchageRewardList
end

function JiangHuYiRenLuAction:getCurrYuanBaoNum()
    return self._role:getAttr("yuanbao")
end

function JiangHuYiRenLuAction:getShowRewards()
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

function JiangHuYiRenLuAction:setYiRenItem(count)
    self.__baifangmingtie = count
end

function JiangHuYiRenLuAction:getCurrBaiFangMingTie()
    return self.__baifangmingtie
end

function JiangHuYiRenLuAction:getButtonInfo()
    return self.__buttonInfos
end

function JiangHuYiRenLuAction:getExchangeRewardInfo(index)
    return self.__exchageRewardList[index]
end

function JiangHuYiRenLuAction:doLottery(index, callback)
    local btnInfo = self.__buttonInfos[index]

    local role_weight = self._role:getAttr("weight")

    if role_weight - #self._role:getItems() < btnInfo.times then
        PopText("您的背包不足".. btnInfo.times .. "格，请先清理背包。" )
        return
    end

    HttpManagerEx:doMingRenLottery(
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

                    self._role:setAttr("yuanbao", data.yuanbao)

                    self:setYiRenItem(tonumber(data.baifangmingtie))

                    callback(data)
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

function JiangHuYiRenLuAction:rewardIsExchanged(reward)
    local records = self._role:getInheritFlag(FLAG_NAME)

    if records == 0 then
        return false
    end

    if records[reward.mianju] == true then
        return true
    else
        return false
    end
end

function JiangHuYiRenLuAction:exchangeReward(index, successCallback)
    local currExchangeReward = self:getExchangeRewardInfo(index)

    if currExchangeReward.rewardType == 1 then
        return self:__exchangeItemReward(currExchangeReward, successCallback)
    else
        return self:__exchangeSpclReward(currExchangeReward, successCallback)
    end
end

function JiangHuYiRenLuAction:__exchangeSpclReward(reward, successCallback)
    local currCount = self:getCurrBaiFangMingTie()

    if currCount <= 0 then
        PopText("您的名帖数量不足，无法兑换。")
        return
    end

    local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
    local dialog = DialogALayer:getInstance()
    dialog:hide()
    local str1 = "将消耗" .. currCount .. "拜会名帖，兑换" .. currCount .. "饰品材料，是否兑换？"
    dialog:show(str1)
    dialog:setBack(false)
    dialog:setButton2(
        "取消",
        function()
        end
    )
    dialog:setButton1(
        "确定",
        function()
            HttpManagerEx:bfmingtieExchangeSpcl(
                function(status, errcode, errmsg, data)
                    if status == 200 then
                        if errcode == 0 then
                            --{baifangmingtie = data.baifangmingtie, removeBfmt = 2, spcl = 333, addSpcl = 2}
                            self:setYiRenItem(tonumber(data.baifangmingtie))

                            successCallback(reward.rewardType, {removebfmt = data.removebfmt, addspcl = data.addspcl})
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
    )
end

function JiangHuYiRenLuAction:__exchangeItemReward(reward, successCallback)
    local items = self._role:getAttr("items")
    if self._role:getAttr("weight") - #items < 1 then
        PopText("您的背包不足1格，请先清理背包。")
        return false
    end

    if self:rewardIsExchanged(reward) == true then
        local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
        local dialog = DialogALayer:getInstance()
        dialog:hide()
        local str1 = "你曾在过往拜访过此名人，继续拜访将获得重复面具，是否继续拜访？"
        dialog:show(str1)
        dialog:setBack(false)
        dialog:setButton2(
            "取消",
            function()
            end
        )
        dialog:setButton1(
            "确定",
            function()
                self:__exchangeItem(reward, successCallback)
            end
        )
    else
        local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
        local dialog = DialogALayer:getInstance()
        dialog:hide()
        local str1 = "是否要花费" .. tostring(reward.need) .. "张名帖拜会【" .. tostring(reward.title) .. "】" .. tostring(reward.name) .. "？"
        local str2 = "是否要花费YEL" .. tostring(reward.need) .. "NOR张名帖拜会【" .. tostring(reward.title) .. "】" .. tostring(reward.name) .. "？"
        dialog:show(str1)
        dialog:setRichText(str2)
        dialog:setBack(false)
        dialog:setButton2(
            "取消",
            function()
            end
        )
        dialog:setButton1(
            "确定",
            function()
                self:__exchangeItem(reward, successCallback)
            end
        )
    end
end

function JiangHuYiRenLuAction:__exchangeItem(reward, successCallback)
    HttpManagerEx:detectionGoods(
        "baifangmingtie",
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    if self.__baifangmingtie ~= tonumber(data.numbers) then
                        self:setYiRenItem(tonumber(data.numbers))
                    end

                    if tonumber(data.numbers) < tonumber(reward.need) then
                        PopText("你没有足够的名帖！")
                        return
                    end

                    HttpManagerEx:checkItemIsCanUse(
                        "baifangmingtie",
                        reward.need,
                        function(status, errcode, errmsg, data)
                            if status == 200 then
                                if errcode == 0 then
                                    local records = self._role:getInheritFlag(FLAG_NAME)
                                    if records == nil or type(records) ~= "table" then
                                        records = {}
                                    end
                                    records[reward.mianju] = true

                                    self._role:setInheritFlag(FLAG_NAME, records)

                                    self._role:addItemCount(reward.mianju, 1)

                                    self:setYiRenItem(data.numbers)

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

return class("JiangHuYiRenLuAction", {}, JiangHuYiRenLuAction)
0000000000000000