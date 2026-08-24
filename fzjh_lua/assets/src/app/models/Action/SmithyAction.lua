local class = require("third.class.NewClass")

local SmithyAction = {}

-- 状态，0：未解锁，1：可领取，2：已领取
local RewardState = {
    NotReward = 0,
    Reward = 1,
    AfterReward = 2,
}

local RewardSort = {
    [RewardState.Reward] = 1,
    [RewardState.NotReward] = 2,
    [RewardState.AfterReward] = 3,
}

function SmithyAction:create()
    return SmithyAction:new()
end

function SmithyAction:ctor()
end

function SmithyAction:setRole(role)
    self.__role = role
end

function SmithyAction:getRole()
    return self.__role
end

function SmithyAction:getRewardList()
    return self.__rewardList
end

function SmithyAction:getActionInfo(func)
    HttpManagerEx:getSmithyInfo(function(status, errcode, errmsg, data)
		if status ==200 and errcode == 0 then
            self.__name = data.act_name

            local desc = ""

            desc = desc .. data.detail_time .. "\n"

            if MapIsEmpty(data.detail_desc) == false then
                for i, v in ipairs(data.detail_desc) do
                    desc = desc .. v .. "\n"
                end
            end

            self.__desc = desc

            self:__initShowRewardList(data.list)

            self.cuiLianCount = data.quench_count

            if func then
                func()
            end
		else
			PopText(errmsg)
		end
	end,IS_SHOW_WAITING)
end

function SmithyAction:getActionName()
    return self.__name
end

function SmithyAction:getActionDesc()
    return self.__desc
end

function SmithyAction:getCuiLianCount()
    return self.cuiLianCount
end


function SmithyAction:__initShowRewardList(list)
    self.__rewardList = {}

    if MapIsEmpty(list) == false then
        for k,v in pairs(list) do
            local rewardInfo = {}
            rewardInfo.rid = v.rid
            rewardInfo.state = v.state
            rewardInfo.rewards = v.rewards

            if v.state == RewardState.AfterReward then
                rewardInfo.enable = false
                rewardInfo.btnName = "已领取"
                rewardInfo.loadTexture = "Image/UI/TaskUI/anniuhui.png"
            elseif v.state == RewardState.NotReward then
                rewardInfo.enable = false
                rewardInfo.btnName = "领取"
                rewardInfo.loadTexture = "Image/UI/TaskUI/anniuhui.png"
            elseif v.state == RewardState.Reward then
                rewardInfo.enable = true
                rewardInfo.btnName = "领取"
                rewardInfo.loadTexture = "Image/UI/TaskUI/anniu.png"
            end

            local text = ""
            local textInfo = {}
            for k,v in pairs(v.rewards) do
                local str = v.name.."X"..v.number
                table.insert(textInfo,str)
            end

            for k,v in ipairs(textInfo) do
                text = text..v
                if k < #textInfo then
                    text = text.."、"
                end
            end

            rewardInfo.text2 = text

            rewardInfo.text1 = v.text

            table.insert(self.__rewardList,rewardInfo)
        end
    end

    table.sort(self.__rewardList,function(a,b)
        if RewardSort[a.state] < RewardSort[b.state] then
            return true
        elseif RewardSort[a.state] == RewardSort[b.state] then
            return a.rid < b.rid
        else
            return false
        end 
    end)
end

function SmithyAction:checkStateIsReward(state)
    return state == RewardState.Reward
end

function SmithyAction:checkBagCanGetReward(rewards)
    local items = {}

    for k,v in pairs(rewards) do
        if v.itype == 1 then
            if items[v.id] then
                items[v.id] = tonumber(v.number) + items[v.id]
            else
                items[v.id] = tonumber(v.number)
            end
        end
    end

    if self.__role:checkCanBuyTwoOrMoreThings(items, false) == false then
        return false
    else
        return true
    end
end

function SmithyAction:doReward(rewardId, isEmail, callback)
    HttpManagerEx:getSmithyReward(rewardId,isEmail,function(status, errcode, errmsg, data)
        if status == 200 and errcode == 0 then
            local rewardList = data.rewards
            if MapIsEmpty(rewardList) == false then
                for k,v in pairs(rewardList) do
                    if v.itype == 1 then --物品
                        self.__role:addItemCount(v.id,v.number)
                    elseif v.itype == 2 then --属性
                        self.__role:addAttr(v.id,v.number)
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

return class("SmithyAction", {}, SmithyAction)
000000000000