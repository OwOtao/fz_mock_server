local class = require("third.class.NewClass")

local GoodsHelper = require("app.models.Store.GoodsHelper")
local ActionRewardsHelper = require("app.models.Action.ActionRewardsHelper")

local CangJingGe = {}

local levelInfo = {
    {
        id = 1,
        name = "ORN特级NOR"
    },
    {
        id = 2,
        name = "QIZ顶级NOR"
    },
    {
        id = 3,
        name = "LQS高级NOR"
    },
    {
        id = 4,
        name = "LIME中级NOR"
    },
    {
        id = 5,
        name = "GRA普通NOR"
    },
}

function CangJingGe:create()
    return CangJingGe:new()
end

function CangJingGe:ctor()
    self._actionId = 0

    self._name = ""

    self._desc = ""

    self._maxBuyTimes = 30

    self._buyTimes = 0

    self._refreshCost = 100

    self._refreshCostName = "元宝"

    self._rewardList = {}

    self._rewardPoolInfo = {}

    self._yaShiBuyInfo = {}
end

function CangJingGe:setRole(role)
    self._role = role
end

function CangJingGe:setActionId(actionId)
    self._actionId = actionId
end

function CangJingGe:init(isRefresh, level, callback)
    HttpManagerEx:getSutraPavilionList(self._actionId,isRefresh, level, function(status, errcode, errmsg, data)
        if status == 200 and errcode == 0 then
            self._name = data.act_name

            self._desc = data.detail_desc

            local desc = ""

            if MapIsEmpty(data.detail_desc) == false then
                for i, v in ipairs(data.detail_desc) do
                    desc = desc .. v .. "\n"
                end
            end

            self._buyTimes = data.buy_times

            self._maxBuyTimes = data.buy_limit

            self._refreshCostName = data.refresh_currency

            self._refreshCost = data.refresh_cost

            self._desc = desc

            self._yaShiBuyInfo = data.yashiDiscountStatus

            self._yashiExpiredTime = data.yashiExpiredTime

            self:__dealWithRewardInfo(data.list)

            self:__dealWithRewardPoolInfo(data.rewardPool)

            if callback then
                callback()
            end
        else
            PopText(errmsg)
        end
    end,IS_SHOW_WAITING)
end

function CangJingGe:getActionName()
    return self._name
end

function CangJingGe:getActionDesc()
    return self._desc
end

function CangJingGe:getLevelInfo()
    return levelInfo
end

function CangJingGe:getRewardListByLevel(level)
    local list = {}

    for i, v in ipairs(self._rewardList) do
        if v.levelType == level then
            table.insert(list, v)
        end
    end

    return list
end

function CangJingGe:getRewardPoolList()
    return self._rewardPoolInfo
end

--[[
    @desc: 
    author:tanqinjian
    time:2025-06-04 17:40:24
    @return: 
    {
        --品质 对应数量残页购买情况
        ["1"] = {
            ["1"] = 0,
            ["3"] = 1,
            ["5"] = 1
            }, 
        ...
    }
]]
function CangJingGe:getYaShiBuyInfo()
    return self._yaShiBuyInfo
end

function CangJingGe:isYaShi()
    self._role:updateYaShiStatus(self._yashiExpiredTime)
    return self._role:isYaShi()
end

function CangJingGe:getBuyTimes()
    return self._buyTimes
end

function CangJingGe:getRefreshCost()
    return self._refreshCost
end

function CangJingGe:getRefreshCostCNName()
    return self._role:getCHAttrName(self._refreshCostName)
end

function CangJingGe:checkIsMaxBuyTimes()
    return tonumber(self._buyTimes) >= tonumber(self._maxBuyTimes)
end

function CangJingGe:checkIsHideSelect()
    return self._role:getDayFlag("cjgSelectHide") == 1
end

function CangJingGe:setHideSelect(hide)
    if hide == true then
        self._role:setDayFlag("cjgSelectHide", 1)
    else
        self._role:setDayFlag("cjgSelectHide", nil)
    end
end

function CangJingGe:isCanRefresh()
    if self:checkIsMaxBuyTimes() == false then
        if self._refreshCostName == "money" then
            if self._role:getAttr("money") < self._refreshCost then
                PopText("所需消耗碎银不足，刷新失败")
                return false
            end
            self._role:addAttr("money", -self._refreshCost)
        end
        return true
    end

    return false
end

function CangJingGe:buyGoods(rewardId,callback)
    HttpManagerEx:buySutraPavilionGoods(self._actionId,rewardId,function(status, errcode, errmsg, data)
        if status == 200 and errcode == 0 then
            PopText("购买成功")

            if callback then
                callback()
            end
        else
            PopText(errmsg)
        end
    end,IS_SHOW_WAITING)
end

function CangJingGe:doReward(rewardId, isEmail, callback)
    local dataVer = self._role:getServerActionSystem():getDataVersion()

    HttpManagerEx:getSutraPavilionGoods(self._actionId, rewardId, isEmail, dataVer,function(status, errcode, errmsg, data)
        if status == 200 and errcode == 0 then
            local reward = data.reward

            local rewardList = {
                {
                    id = reward.id,
                    num = reward.num
                }
            }

            local GrantGoodRequest = require("app.models.Store.GrantGoodRequest")

            GoodsHelper:fromNetworkGrantGoods(self._role,GrantGoodRequest:create({goodsList = rewardList, dataVersion = data.dataVer}))

            ActionRewardsHelper:printGetRewardsText(rewardList)
            
            if data.msg then
                PopText(data.msg)
            end

            if callback then
                callback()
            end
        else
            PopText(errmsg)
        end
    end,IS_SHOW_WAITING)
end

function CangJingGe:checkCanGetReward(rewards)
    return ActionRewardsHelper:checkBagCanGetRewards(rewards, self._role)
end

function CangJingGe:__dealWithRewardInfo(rewardInfo)
    self._rewardList = {}

    local isYashi = self:isYaShi()

    if MapIsEmpty(rewardInfo) == false then
        for k,v in pairs(rewardInfo) do
            if MapIsEmpty(v) == false then
                local _info = {}
                
                if v.originalCost ~= nil and v.originalCost ~= "" then
                    _info.text4 = "原价："..v.originalCost..v.currencyName
                    _info.lineVisible  = true
                else
                    _info.lineVisible  = false
                    _info.text4 = ""
                end
                
                _info.text5 = "库存："..v.stock

                if isYashi == true and self._yaShiBuyInfo[tostring(v.levelType)][tostring(v.number)] == 0 then
                    _info.yaShiBuy = true
                else
                    _info.yaShiBuy = false
                end

                if v.state == 0 then
                    if _info.yaShiBuy then
                        _info.btnName2 = v.discountPrice..v.currencyName
                    else
                        _info.btnName2 = v.price..v.currencyName
                    end
                elseif v.state == 1 then
                    _info.btnName2 = "领取"
                elseif v.state == 2 then
                    _info.btnName2 = "已领取"
                elseif v.state == 3 then
                    _info.btnName2 = "已售罄"
                end

                _info.levelType = v.levelType
                _info.btnName2Visible = true
                _info.id = v.id
                _info.state = v.state
                
                local yaShiStr = "雅士折扣价："..v.discountPrice..v.currencyName

                if _info.yaShiBuy == false then
                    yaShiStr = ""
                end

                _info.rewards = {}

                local itemInfo = {
                    id = v.goodsId,
                    num = v.number,
                }

                table.insert(_info.rewards, itemInfo)

                local goods = GoodsHelper:getGoodsResClass(v.goodsId)
                local itemId = goods:getItemId()

                _info.icon = goods:getIcon()

                local itemAttr = Item:getItemByKey(itemId)

                local skill = Skill:getSkill(itemAttr.skillid)

                _info.text1 = goods:getName().."X"..tostring(v.number)
                _info.text2 = "所属武学："..skill.name
                _info.text3 = yaShiStr

                table.insert(self._rewardList,_info)
            end
        end
    end
end

function CangJingGe:__dealWithRewardPoolInfo(rewardPool)
    self._rewardPoolInfo = {}

    if MapIsEmpty(rewardPool) == false then
        local typePool = {}
        for k,v in pairs(rewardPool) do
            if not typePool[tostring(v.levelType)] then
                typePool[tostring(v.levelType)] = {}
            end

            local goods = GoodsHelper:getGoodsResClass(v.goodsId)
            local str = goods:getName().."X"..v.number
            table.insert(typePool[tostring(v.levelType)], str)
        end

        local function getLevelName(level)
            for i, v in ipairs(levelInfo) do
                if v.id == level then
                    return v.name.."品质："
                end
            end
        end
        
        for k,v in pairs(typePool) do
            local pool = {}
            pool.text = getLevelName(tonumber(k))
            pool.index = tonumber(k)
            pool.info = v
            table.insert(self._rewardPoolInfo, pool)
        end
        
        table.sort(self._rewardPoolInfo,function(a,b)
            if a.index < b.index then
                return  true
            else
                return false
            end
        end)
    end
end

return class("CangJingGe", {}, CangJingGe)
0000000000000