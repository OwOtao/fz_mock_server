local class = require("third.class.NewClass")

local YuanBaoRewardState = {
    NOT_UNLOCK = 0,
    NOT_REWARD = 1,
    REWARD = 2,
    REWARDED = 3
}

local RewardState = {
    NOT_REWARD = 0,
    REWARD = 1,
    REWARDED = 2
}

local AnniversaryLoginReward = {}

function AnniversaryLoginReward:create()
    return AnniversaryLoginReward:new()
end

function AnniversaryLoginReward:ctor()
    self._actionId = 0

    self._name = ""

    self._desc = ""

    self._rewardList = {}

    self._yuanbaoNum = 0

    self._yuanbaoTime = 0

    self._yuanbaoRid = ""
end

function AnniversaryLoginReward:setRole(role)
    self._role = role
end

function AnniversaryLoginReward:setActionId(actionId)
    self._actionId = actionId
end

function AnniversaryLoginReward:init(callback)
    HttpManagerEx:getAnniversaryLoginList(function(status, errcode, errmsg, data)
        if status == 200 and errcode == 0 then
            self._name = data.act_name

            self._desc = data.detail_desc

            self._yuanbaoTime = data.start_time

            if MapIsEmpty(data.yuanbao_data) == false then
                self._yuanbaoNum = data.yuanbao_data.num
                self._yuanbaoState = data.yuanbao_data.state
                self._yuanbaoRid = data.yuanbao_data.rid
            end

            local desc = ""

            if MapIsEmpty(data.detail_desc) == false then
                for i, v in ipairs(data.detail_desc) do
                    desc = desc .. v .. "\n"
                end
            end

            self._desc = desc

            self:__dealWithRewardInfo(data.list)

            if callback then
                callback()
            end
        else
            PopText(errmsg)
        end
    end,IS_SHOW_WAITING)
end

function AnniversaryLoginReward:getActionName()
    return self._name
end

function AnniversaryLoginReward:getActionDesc()
    return self._desc
end

function AnniversaryLoginReward:getYuanBaoNum()
    return self._yuanbaoNum
end

function AnniversaryLoginReward:getRewardList()
    return self._rewardList
end

function AnniversaryLoginReward:checkYuanBaoRewardIslock()
    return self._yuanbaoState == YuanBaoRewardState.NOT_UNLOCK
end

function AnniversaryLoginReward:checkCanGetYuanbaoReward()
    return self._yuanbaoState == YuanBaoRewardState.REWARD
end

function AnniversaryLoginReward:checkYuanbaoRewardIsGet()
    return self._yuanbaoState == YuanBaoRewardState.REWARDED
end

function AnniversaryLoginReward:getYuanBaoRewardTime()
    return self._yuanbaoTime
end

function AnniversaryLoginReward:doYuanBaoReward(callback)
    if self._yuanbaoState == YuanBaoRewardState.REWARD then
        local dataVer = self._role:getServerActionSystem():getDataVersion()
        HttpManagerEx:getAnniversaryLoginReward(self._yuanbaoRid, false, dataVer,function(status, errcode, errmsg, data)
            if status == 200 and errcode == 0 then
                local rewardList = data.reward
                if MapIsEmpty(rewardList) == false then
                    for k,v in pairs(rewardList) do
                        if v.type == 1 then --物品
                            self._role:addItemCount(v.id,v.num)
                        elseif v.type == 2 then --属性
                            self._role:addAttr(v.id,v.num)
                        end
    
                        PopText("获得"..v.name.."X"..tostring(v.num))
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
end

function AnniversaryLoginReward:__doReward(rewardId, isEnough, callback)
    local dataVer = self._role:getServerActionSystem():getDataVersion()
    HttpManagerEx:getAnniversaryLoginReward(rewardId, isEnough, dataVer, function(status, errcode, errmsg, data)
        if status == 200 and errcode == 0 then
            local rewardList = data.reward
            if MapIsEmpty(rewardList) == false then
                for k,v in pairs(rewardList) do
                    if v.type == 1 then --物品
                        self._role:addItemCount(v.id,v.num)
                    elseif v.type == 2 then --属性
                        self._role:addAttr(v.id,v.num)
                    end

                    PopText("获得"..v.name.."X"..tostring(v.num))
                end
            end

            if data.dataVer then
                self._role:getServerActionSystem():setDataVersion(data.dataVer)
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

function AnniversaryLoginReward:setAfterRewardCallback(func)
    self._afterRewardCallback = Helper:getDef(func,EMPTY_FUNC)
end

function AnniversaryLoginReward:__checkCanGetReward(rewards)
    local items = {}

    for k,v in pairs(rewards) do
        if v.type == 1 then
            if items[v.id] then
                items[v.id] = tonumber(v.num) + items[v.id]
            else
                items[v.id] = tonumber(v.num)
            end
        end
    end

    if self._role:checkCanBuyTwoOrMoreThings(items,true) == false then
        return false
    else
        return true
    end
end

function AnniversaryLoginReward:__dealWithRewardInfo(rewardInfo)
    local info = {}

    if MapIsEmpty(rewardInfo) == false then
        local function getRewardDesc(rewards)
            local str = ""
            for k,v in pairs(rewards) do
                str = str .. v.name.." X "..tostring(v.num).."、"
            end

            str = string.sub(str,1,-4)
            return str
        end

        for k,v in pairs(rewardInfo) do
            if MapIsEmpty(v) == false then
                local _info = {}
                _info.state = v.state
                _info.rid = v.rid
                if v.state == RewardState.REWARD then
                    _info.enable = true
                    _info.loadTexture = "Image/BaseUI/btn-orangeRed.png"
                else
                    _info.enable = false
                    _info.loadTexture = "Image/BaseUI/btn-grey.png"
                end

                _info.btnName = "领取"

                if v.state == RewardState.REWARDED then
                    _info.btnName = "已领取" 
                end

                _info.text1 = "登录第"..tostring(v.day).."天"
                _info.text2 = getRewardDesc(v.rewards)
                _info.getReward = function()
                    if v.state == RewardState.REWARDED then

                    end
                    local isEnough = self:__checkCanGetReward(v.rewards) == false
                    self:__doReward(v.rid,isEnough,function()
                        if self._afterRewardCallback then
                            self._afterRewardCallback()
                        end
                    end)
                end

                table.insert(info,_info)
            end
        end
    end

    self._rewardList = info
    table.sort(self._rewardList,function(a,b)
        return a.rid < b.rid
    end)
end

return class("AnniversaryLoginReward", {}, AnniversaryLoginReward)
0000000000