--
-- Author: TanQinJian
-- Date: 2019-06-20 11:22:22
--
local AnniversaryOfThird = {}
local ActivityCalendarUtils = require("app.models.Action.ActivityCalendarUtils")
local canGetRewardMap={
	["fb217"]=true
}
--获得比武奖励
-- fightResult 1,4 赢,2,5输 ,3平手，异常
function AnniversaryOfThird:getPVPBiWuAward(currMapId,fightResult)
    if DEBUG_MODE == 1 then
        print("fightResult = ",fightResult,"currMapId = ",currMapId)
    end
    if currMapId == nil or fightResult == nil then
        return 
    end

    if DEBUG_MODE == 1 then 
    else
        local activityId = GameConst:getDefaultValue("bafangyouli_wujianhuiwu")
        if ActivityCalendarUtils:checkActivityIsOpen(activityId) == false then
            return
        end
    end

    if canGetRewardMap[currMapId] ~= true then 
    	return
    end

    local role = User:getRole()
    local num =  role:getDayFlag("wujianlin_PVP_reward")
    if num >= 3 then
    else
        --成功奖励列表
        local familySucAwardList = {
            meiyu = 2,
            prestige = 10 
        }

        --失败奖励列表
        local familyDefAwardList = {
            meiyu = 1,
            prestige = 5
        }

         --成功奖励列表
        local youXiaSucAwardList = {
            meiyu = 2,
            weiwang = 5
        }

        --失败奖励列表
        local youXiaDefAwardList = {
            meiyu = 1,
            weiwang = 2
        }

        --最终奖励列表
        local finalAwardList = {}
        local sucAwardList = {} 
        local defAwardList = {}

        if role:hasFamily() then 
            sucAwardList = familySucAwardList
            defAwardList = familyDefAwardList
        else
            sucAwardList = youXiaSucAwardList
            defAwardList = youXiaDefAwardList
        end
        
        if fightResult == 1 or fightResult == 4 then
            finalAwardList = sucAwardList
        elseif fightResult == 2 or fightResult == 5 then
            finalAwardList = defAwardList
        else
            print("战斗结果异常")
            return
        end

        for k,v in pairs(finalAwardList) do
            k = tostring(k)
            if k == "prestige" then --只有师门
           		local FamilyPrestige=require("app.models.family.FamilyPrestige") 
	            FamilyPrestige:addUserPrestige(v,"wujianlin_PVP_reward",function (data)
                    local addPrestige = data.num
                    if addPrestige ~= nil and addPrestige ~= 0 then
                        PopText(role:getCHAttrName("prestige") .. " +" .. addPrestige)
                    end
	            end)
            elseif k == "meiyu" then --师门散人都获得美誉
                HttpManagerEx:updateCurrencyByType("add","meiyu",v,nil, function(status, errcode, errmsg, data)
                    if status == 200 then
                        if errcode == 0 then
                            --奖励次数  
                            role:setDayFlag("wujianlin_PVP_reward",num + 1)
                            PopText(role:getCHAttrName(k) .. " +".. v)
                        else
                            print(errcode,errmsg)
                        end
                    end
                end, IS_SHOW_WAITING)
            else
                role:addAttr(k, v)
                PopText(role:getCHAttrName(k) .. " +".. v)
            end
        end
    end
end

return AnniversaryOfThird0000000