local class = require("third.class.NewClass")

local rewardState = {
    NOT_PAY = 0,--未充值
    NOT_REWARD = 1, --未领取
    AWARDED = 2, --已领取
}

local DieJinChongZhi = {}

function DieJinChongZhi:create()
    return DieJinChongZhi:new()
end

function DieJinChongZhi:ctor()
    self._actionId = "DieJinChongZhi"

    self._name = "江湖秘宝"

    self._desc = "2021年5月15日0点-2021年5月31日23点59分，活动期间每天可购买超值礼包，每种礼包将会有不同的购买次数，购买后请及时领取，购买次数将于每天0点刷新。"

    self._todayRewardInfo = {}

    self._otherRewardInfo = {}
end

function DieJinChongZhi:setRole(role)
    self._role = role
end

function DieJinChongZhi:setActionId(actionId)
    self._actionId = actionId
end

function DieJinChongZhi:setAfterRewardCallback(func)
    self._afterRewardCallback = Helper:getDef(func,EMPTY_FUNC)
end

function DieJinChongZhi:init(callback)
    HttpManagerEx:getTotalSpendDetail(self._actionId,function(status, errcode, errmsg, data)
        if status == 200 and errcode == 0 then
            self._name = data.name

            self._desc = data.detail_desc

            local desc = ""

            if MapIsEmpty(data.detail_desc) == false then
                for i, v in ipairs(data.detail_desc) do
                    desc = desc .. v .. "\n"
                end
            end

            self._desc = desc
            --累计充值天数
            self._days = data.day
            --当天充值金额
            self._spendNumber = data.spend_number
            --当前所需金额
            self._standardNumber = data.standard_number
            
            self:__dealWithRewardInfo(data.award_list)

            if callback then
                callback()
            end
        else
            PopText(errmsg)
        end
    end,IS_SHOW_WAITING)
end

function DieJinChongZhi:getActionName()
    return self._name
end

function DieJinChongZhi:getActionDesc()
    return self._desc
end

function DieJinChongZhi:getActionId()
    return self._actionId
end

function DieJinChongZhi:getStandardNumber()
    return self._standardNumber
end

function DieJinChongZhi:getCurrSpendNumber()
    return self._spendNumber
end

function DieJinChongZhi:getCurrDays()
    return self._days
end

function DieJinChongZhi:getTodayRewardInfo()
    return self._todayRewardInfo
end

function DieJinChongZhi:getOherRewardInfo()
    return self._otherRewardInfo
end

function DieJinChongZhi:__doReward(rewardId,callback)
    HttpManagerEx:getTotalSpendAward(self._actionId,rewardId,function(status, errcode, errmsg, data)
        if status == 200 and errcode == 0 then
            local rewardList = data.award_box
            if MapIsEmpty(rewardList) == false then
                for k,v in pairs(rewardList) do
                    if v.type == 1 then --物品
                        self._role:addItemCount(v.id,v.number)
                    elseif v.type == 2 then --属性
                        self._role:addAttr(v.id,v.number)
                    end

                    PopText("获得"..v.name.."X"..tostring(v.number))
                end
            end

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

function DieJinChongZhi:__checkCanGetReward(rewards)
    local items = {}

    for k,v in pairs(rewards) do
        if v.type == 1 then
            if items[v.id] then
                items[v.id] = tonumber(v.number) + items[v.id]
            else
                items[v.id] = tonumber(v.number)
            end
        end
    end

    if self._role:checkCanBuyTwoOrMoreThings(items,true) == false then
        return false
    else
        return true
    end
end

function DieJinChongZhi:__dealWithRewardInfo(rewardInfo)
    self._otherRewardInfo = {}
    self._todayRewardInfo = {}
    Helper:print_lua_table(rewardInfo)
    if MapIsEmpty(rewardInfo) == false then
        for k,v in pairs(rewardInfo) do
            if MapIsEmpty(v) == false then
                local _info = {}
                _info.awardType = v.award_type
                if v.award_type == 1 then
                    _info.text1 = "累计充值"..tostring(v.total_day).."天"
                else
                    _info.text1 = "今日充值奖励"
                end

                _info.text2 = v.award_string
                _info.rid = k
                _info.btnName = "领取"
                _info.status = v.status
                _info.texture = "Image/UI/TaskUI/anniu.png"

                if v.status == rewardState.AWARDED then
                    _info.btnName = "已领取"
                    _info.texture = "Image/UI/TaskUI/anniuhui.png"
                end

                _info.btnFunc = function()
                    if v.status == rewardState.AWARDED then
                        PopText("此奖励已领取。")
                        return
                    end
                    if v.status == rewardState.NOT_PAY then
                        PopText("累计天数不足"..tostring(v.total_day).."天，领取失败。")
                        return
                    end
                    if self:__checkCanGetReward(v.award_box) then
                        self:__doReward(k,function()
                            if self._afterRewardCallback then
                                self._afterRewardCallback()
                            end
                        end)
                    end
                end

                if v.award_type == 1  then
                    table.insert(self._otherRewardInfo,_info)
                else
                    table.insert(self._todayRewardInfo,_info)
                end
            end
        end
    end

    local stateSort = {
        [rewardState.NOT_PAY] = 1,
        [rewardState.NOT_REWARD] = 1,
        [rewardState.AWARDED] = 2
    }

    table.sort(self._otherRewardInfo, function(a,b)
        if stateSort[a.status] < stateSort[b.status] then
            return true
        elseif stateSort[a.status] == stateSort[b.status] or a.status == b.status then
            if a.rid < b.rid then
                return true
            else
                return false
            end
        else
            return false
        end
    end)
end

return class("DieJinChongZhi", {}, DieJinChongZhi)
0000000000000000