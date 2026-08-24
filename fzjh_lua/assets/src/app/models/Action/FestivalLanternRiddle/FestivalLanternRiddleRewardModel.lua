--
-- Author: TanQinJian
-- Date: 2019-02-13 15:29:42
--
local FestivalLanternRiddleRewardModel = {}

function FestivalLanternRiddleRewardModel:YuanXiao_Reward()
    local role = User:getRole()
    if role:getDayFlag("灯谜活动奖励领取") == 0 then
        PopText("今日尚未参与猜灯谜，无法领取奖励。")
        return
    elseif role:getDayFlag("灯谜活动奖励领取") == true then
        PopText("今日奖励已领取。")
        return
    end

    local trueQuestionsNum = role:getDayFlag("灯谜活动答对题数")

    local itemRewards = {
        id = "2021dengmiq",
        num = 0
    }
    if trueQuestionsNum < 4 then
        -- item1="2019yxdl006"
        -- num1=1
        -- item2="2019yxdl001"
        -- num2=1
        itemRewards.num = 2
    elseif trueQuestionsNum < 9 then
        -- item1="2019yxdl006"
        -- num1=2
        -- item2="2019yxdl002"
        -- num2=1
        itemRewards.num = 4
    elseif trueQuestionsNum < 14 then
        -- item1="2019yxdl006"
        -- num1=2
        -- item2="2019yxdl003"
        -- num2=1
        itemRewards.num = 6
    elseif trueQuestionsNum < 19 then
        -- item1="2019yxdl006"
        -- num1=3
        -- item2="2019yxdl004"
        -- num2=1
        itemRewards.num = 8
    else
        -- item1="2019yxdl006"
        -- num1=4
        -- item2="2019yxdl005"
        -- num2=1
        itemRewards.num = 10
    end

    if role:checkCanBuyTwoOrMoreThings({[itemRewards.id] = itemRewards.num}, false) == false then
        PopText("背包空间不足，无法领取奖励")
        return
    end

    local addPot = trueQuestionsNum * trueQuestionsNum * 100 + 1000
    local addExp = trueQuestionsNum * trueQuestionsNum * 75
    role:setDayFlag("灯谜活动答题", 1)
    role:setDayFlag("灯谜活动答题结果", "")
    role:setDayFlag("灯谜活动已答题", {})
    role:addAttr("pot", addPot)
    PopText("获得潜能 " .. addPot)
    role:addAttr("exp", addExp)
    PopText("获得经验 " .. addExp)

    local item = role:getOneItemByKey(itemRewards.id)
    if item ~= nil then
        role:addItemCount(itemRewards.id, itemRewards.num)
        PopText("您获得了" .. item.name .. " X" .. tostring(itemRewards.num))
    else
        print("缺少物品资源!!!!!!!!", itemRewards.id)
    end

    role:setDayFlag("灯谜活动奖励领取", true)
end

function FestivalLanternRiddleRewardModel:MidAutumn_Reward()
    local role = User:getRole()

    if role:getDayFlag("灯谜活动奖励领取") == false then
        local trueQuestionsNum = role:getDayFlag("灯谜活动答对题数")
        local addPot = trueQuestionsNum * trueQuestionsNum * 80 + 1000
        local addExp = trueQuestionsNum * trueQuestionsNum * 60 + 1000
    
        local itemNum = 0
        
        if trueQuestionsNum < 11 then
            itemNum = 2
        elseif trueQuestionsNum < 16 then
            itemNum = 4
        else
            itemNum = 6
        end
        
        local item = role:getOneItemByKey("2021dengmiq")
 
        if not item then
            assert(false,"缺少物品资源!!!!!!!!", "2021dengmiq")
        end

        if itemNum>0 and role:checkCanBuyTwoOrMoreThings({["2021dengmiq"] = itemNum}, false) == false then
            PopText("背包空间不足，无法领取奖励")
            return
        end

        if role:getDayFlag("灯谜活动奖励领取") == false then
            role:setDayFlag("灯谜活动奖励领取", true)
           
            if role:getInheritFlag("2021_zhongqiu_dengmiquan") < 7 then    
                if item and itemNum > 0 then
                    role:addItemCount("2021dengmiq", itemNum)
                    PopText("您获得了" .. item.name .. " X" .. tostring(itemNum))
                end
                role:setInheritFlag("2021_zhongqiu_dengmiquan",role:getInheritFlag("2021_zhongqiu_dengmiquan")+1)
            end
            
            role:addAttr("pot", addPot)
            role:addAttr("exp", addExp)

            PopText("你获得了" .. addExp .. "经验")
            PopText("你获得了" .. addPot .. "潜能")
        end

        -- local tab = {
        --     shop_id = "zhounianqin_jf",
        --     number = 50,  --必得50礼券
        --     type = "zhongqiudengmi"
        -- }
        -- HttpManagerEx:addCurrency(
        --     tab,
        --     function(status, errcode, errmsg, data)
        --         if status == 200 and errcode == 0 then
        --             if role:getDayFlag("灯谜活动奖励领取") == false then
        --                 role:setDayFlag("灯谜活动奖励领取", true)
                       
        --                 if data.number>0 then
        --                 PopText("领取今日奖励成功:" .. data.number .. " " .. "(目前礼券总数:" .. data.total_points .. ")")
        --                 end
                        
        --             if role:getInheritFlag("2021_zhongqiu_dengmiquan") < 7 then    
        --                 if item and itemNum > 0 then
        --                     role:addItemCount("2021dengmiq", itemNum)
        --                     PopText("您获得了" .. item.name .. " X" .. tostring(itemNum))
        --                 end
        --                 role:setInheritFlag("2021_zhongqiu_dengmiquan",role:getInheritFlag("2021_zhongqiu_dengmiquan")+1)
        --             end
        --                 role:addAttr("pot", addPot)
        --                 role:addAttr("exp", addExp)
        --                 PopText("你获得了" .. addExp .. "经验")
        --                 PopText("你获得了" .. addPot .. "潜能")
        --             end
        --         else
        --             PopText(errmsg)
        --         end
        --     end,
        --     IS_SHOW_WAITING
        -- )
    elseif role:getDayFlag("灯谜活动奖励领取") == 0 then
        PopText("今日尚未参与猜灯谜，无法领取奖励。")
    else
        PopText("今日奖励已领取。")
    end
end

--周年庆答题奖励
function FestivalLanternRiddleRewardModel:ZhouNian_Reward(map)
    if map == nil then
        print("map = nil")
        return
    end
    local role = User:getRole()
    if role:getDayFlag("灯谜活动奖励领取") == 0 then
        PopText("今日尚未参与猜灯谜，无法领取奖励。")
        return
    elseif role:getDayFlag("灯谜活动奖励领取") == true then
        PopText("今日奖励已领取。")
        return
    end

    local trueQuestionsNum = role:getDayFlag("灯谜活动答对题数")

    local jiaoziNum = 50
    local isBuff = false
    local attrReward = {
        pot = trueQuestionsNum * trueQuestionsNum * 80 + 1000,
        exp = trueQuestionsNum * trueQuestionsNum * 60 + 1000
    }

    HttpManagerEx:addCurrencyNumber({["jiaozi"] =jiaoziNum },"DailyTies_riddle","weekact", function(status, errcode, errmsg, data)
        if 200 == status and 0 == errcode then
            if MapIsEmpty(data.currency) == false then
                for currency,valueData in pairs(data.currency) do
                    if valueData.value > 0 then 
                         PopText("增加"..tostring(valueData.value)..role:getCHAttrName(currency).."，共拥有"..tostring(valueData.count)..role:getCHAttrName(currency))
                    end
                    if valueData.desc ~= nil and valueData.desc ~= ""  then
                        PopText(valueData.desc)
                    end
                end
            end
            HttpManagerEx:checkGoodsValid({"yuhuiling"}, function(status, errcode, errmsg, data)
                if 200 == status and 0 == errcode then
                    for k,v in pairs(data) do 
                        if "yuhuiling" == v.itemId and v.number > 0 then 
                            isBuff = true
                        end
                    end

                    if  role:getDayFlag("灯谜活动奖励领取") ~= true then 
                         --属性奖励
                        for k,v in pairs(attrReward) do
                            local buffAddValue = role:getDayFlag("yuhuiling_"..k)
                            local addValue = 0 
                            if isBuff  then 
                                addValue = YUHUILING_BUFF * v 

                                addValue = math.min(addValue,YUHUILING_NUM_LIMIT - buffAddValue)
                            end
                            
                            role:setDayFlag("yuhuiling_"..k,buffAddValue + addValue)

                            local finalNum = v + addValue
                            role:addAttr(k,finalNum)
                            PopText("获得"..tostring(finalNum)..role:getCHAttrName(k))
                        end
                        --物品奖励
                        local rewardList = {}

                        local logTab={}
                        --保底机制
                        if role:getInheritFlag("weekxqdm_gameTimes") == 22 then
                            table.insert(rewardList,{itemId = "mianju1108",count = 1})
                            local ActivityCalendarUtils = require("app.models.Action.ActivityCalendarUtils")
                            ActivityCalendarUtils:getSpecialTitle("weekxqdm")
                        else
                            if trueQuestionsNum >= 16 then
                                table.insert(rewardList,{itemId = "2020zhdchip03",count = 3})
                                if 3 >= math.random(1,100) then
                                    table.insert(rewardList,{itemId = "mianju1108",count = 1})
                                    table.insert(logTab,{["mianju1108"] = 1})
                                end
                            elseif trueQuestionsNum >= 11 then
                                table.insert(rewardList,{itemId = "2020zhdchip03",count = 2})
                                if 2 >= math.random(1,100) then
                                    table.insert(rewardList,{itemId = "mianju1108",count = 1})
                                    table.insert(logTab,{["mianju1108"] = 1})
                                end
                            else
                                table.insert(rewardList,{itemId = "2020zhdchip03",count = 1})
                                if 1 >= math.random(1,100) then
                                    table.insert(rewardList,{itemId = "mianju1108",count = 1})
                                    table.insert(logTab,{["mianju1108"] = 1})
                                end
                            end
                        end 
                        
                        for i,v in ipairs(rewardList) do
                            local itemId = v.itemId
                            local count = v.count
                            if not map:addItemCount(itemId, count) then
                                local currRoomId = map:getCurrRoomId()
                                map:dropItem(currRoomId,itemId,count)

                            else
                                local itemAttr = Item:getOneItemByKey(itemId)
                                role:addItemCount(itemId,count,nil,nil,"zhouniandengmi")
                                PopText("获得"..itemAttr.name.."X"..count)
                            end
                        end

                        role:setDayFlag("灯谜活动奖励领取", true)
                    end
                else
                    PopText("网络请求出错,请换个网络环境再试!")
                end
            end, IS_SHOW_WAITING)
        else
            PopText("网络请求出错,请换个网络环境再试!")
        end
    end, IS_SHOW_WAITING)
end

function FestivalLanternRiddleRewardModel:getFestivalReward(type,map)
    if type == "yuanxiao" then
        self:YuanXiao_Reward()
    elseif type == "zhongqiu" then
        self:MidAutumn_Reward()
    elseif type == "zhounian" then
        self:ZhouNian_Reward(map)
    else
        print("活动不对")
    end
end
return FestivalLanternRiddleRewardModel
00000