local HeroFeastModel = {}

local resource = require("script.others.dinner")
local RoleTitleResManager = require("app.models.role.titleSystem.RoleTitleResManager")
local RoleTitleConst = require("app.models.role.titleSystem.RoleTitleConst")
local Dinner = resource.dinner
local Text = resource.text
local Hero = resource.hero
local Wine = resource.wine

--计算当前是第几次宴会
function HeroFeastModel:calCurrHeroFeastTimes()
    local currTime = GetTime()
    local startTime = Helper:getTimeStampWithStringDate("20210211", 0)
    local dayNum = Helper:diffWithDate(currTime, startTime)
    --活动是2021.2.11 - 2021.2.17 23:59
    if dayNum >= 0 and dayNum <= 6 then
    else
        PopText("已经过了举办宴席的时间！")
        assert(false,"已经过了举办宴席的时间！")
    end

    return tostring(Helper:diffWithDate(currTime, startTime) + 1)
end

--根据时间获取英雄宴相关数据 默认取当前时间
function HeroFeastModel:getHeroFeastDataByTime(times)
    local index = times
    if index == nil then
        index = self:calCurrHeroFeastTimes()
    end
    return Dinner[tostring(index)]
end

--检查是否是活动时间内
function HeroFeastModel:checkIsActivityTime()
    if (GetTime() > Helper:getTimeStampWithStringDate("20210211", 0) and GetTime() < Helper:getTimeStampWithStringDate("20210217", 24)) then
        return true        
    end

    return false
end

-- 获取所需食物Id和数量数组
function HeroFeastModel:getFoodIdAndNumArry()
    local data = self:getHeroFeastDataByTime()
    local foodIdAndNumArry = {}

    local foodDemand = data.foodDemand
    local foodDemandList = string.split(foodDemand,";")

    for i ,v in ipairs(foodDemandList) do
        local foodAndNum = string.split(v,",")
        local foodId = foodAndNum[1]
        local num = tonumber(foodAndNum[2])
        table.insert( foodIdAndNumArry,{id = foodId,num = num})
    end

    return foodIdAndNumArry
end

--获取基础奖励
function HeroFeastModel:getBaseAwardId()
    local data = self:getHeroFeastDataByTime()
    return data.baseAward
end

--获取第三阶段物品奖励和属性奖励 
function HeroFeastModel:getThirdStageAward(times)
    if times == nil then
        return
    end
    local data = self:getHeroFeastDataByTime(times)
    if MapIsEmpty(data) then
        return
    end
    local itemAward = {}
    local attrAward = {}

    --物品奖励
    local itemsStr = data.itemAward
    if itemsStr then
        local itemAwardList = string.split(itemsStr,";")
        for i ,v in ipairs(itemAwardList) do
            local itemAndNum = string.split(v,",")
            local itemId = itemAndNum[1]
            local num = tonumber(itemAndNum[2])
            itemAward[itemId] = num
        end
    end

    --属性奖励
    local attrsStr = data.attrAward
    if attrsStr then
        local attrAwardList = string.split(attrsStr,";")
        for i ,v in ipairs(attrAwardList) do
            local attrAndNum = string.split(v,",")
            local attr = attrAndNum[1]
            local num = tonumber(attrAndNum[2])
            attrAward[attr] = num
        end
    end

    return itemAward,attrAward
end

--检查食物材料够不够
function HeroFeastModel:checkFoodNumIsEnough()
    local foodIdAndNumArry = self:getFoodIdAndNumArry()
    local role = User:getRole()

    for i ,v in ipairs(foodIdAndNumArry) do
        local foodId = v.id
        local haveCount = role:getItemCount(foodId)
        if haveCount < v.num then
            return false
        end
    end

    return true
end

--获取酒水资源配表
function HeroFeastModel:getWineAttr(wineId)
    return Wine[wineId]
end

--获取英雄资源配表
function HeroFeastModel:getHeroAttr(heroId)
    return Hero[heroId]
end

--获取动画输出的文本根据文本id
function HeroFeastModel:getTextByTextId(textId)
    if textId == nil or Text[textId] == nil then
        assert(false,"检查资源表酒水对应的文本id")
    end
    return Text[textId].text
end

--检查是否能获得英雄宴称号
function HeroFeastModel:checkCanGetHeroFeastTitle()
    local role = User:getRole()
    local flagTab = role:getInheritFlag("2021英雄宴奖励")

    if type(flagTab) == "table" then
        for i = 1,7 do
            if flagTab[tostring(i)] then
            else
                return false
            end
        end
    else
        return false
    end

    return true
end

--获得英雄宴称号 宴风尘
function HeroFeastModel:getHeroFeastTitle()
    local role = User:getRole()

    local basicTitleId = RoleTitleConst.SpecialBasicTitleId.YanFengChen
	local title = RoleTitleResManager:getBasicTitleClassById(basicTitleId)

	if title and role:hasBasicTitle(basicTitleId) == false then
		role:addBasicTitle(basicTitleId)
		local name = title:getColorName()
		PopText("获得"..name.."称号")
	end
end

--获得英雄宴称号 宴四海
function HeroFeastModel:getHeroFeastTitle2()
    local role = User:getRole()
    
    local basicTitleId = RoleTitleConst.SpecialBasicTitleId.YanSiHai
	local title = RoleTitleResManager:getBasicTitleClassById(basicTitleId)

	if title and role:hasBasicTitle(basicTitleId) == false then
		role:addBasicTitle(basicTitleId)
		local name = title:getColorName()
		PopText("获得"..name.."称号")
	end
end

--获得英雄宴称号 宴岁暮
function HeroFeastModel:getHeroFeastTitle3()
    local role = User:getRole()

    local basicTitleId = RoleTitleConst.SpecialBasicTitleId.YanSuiMu
	local title = RoleTitleResManager:getBasicTitleClassById(basicTitleId)
    
	if title and role:hasBasicTitle(basicTitleId) == false then
		role:addBasicTitle(basicTitleId)
		local name = title:getColorName()
		PopText("获得"..name.."称号")
	end
end

return HeroFeastModel000000000000