local class = require("third.class.NewClass")

local FisrtCharge = {}

function FisrtCharge:create()
    return FisrtCharge:new()
end

function FisrtCharge:ctor()
    self._actionId = 0

    self._name = ""

    self._desc = ""

    self._rewardList = {}
end

function FisrtCharge:setRole(role)
    self._role = role
end

function FisrtCharge:setActionId(actionId)
    self._actionId = actionId
end

function FisrtCharge:getRewardList()
    return self._rewardList
end

function FisrtCharge:init(callback)
    HttpManagerEx:getSpringNewReward(function(status, errcode, errmsg, data)
        if status == 200 and errcode == 0 then
            self._name = data.name

            local desc = ""

            if MapIsEmpty(data.detail_desc) == false then
                for i, v in ipairs(data.detail_desc) do
                    desc = desc .. v .. "\n"
                end
            end

            self._chargeState = data.hasup == 1

            self._desc = desc

            self:__dealWithRewardInfo(data.base)

            if callback then
                callback()
            end
        else
            PopText(errmsg)
        end
    end,IS_SHOW_WAITING) 
end

function FisrtCharge:getActionName()
    return self._name
end

function FisrtCharge:getActionDesc()
    return self._desc
end

function FisrtCharge:getChargeState()
    return self._chargeState
end

function FisrtCharge:__doReward(rewardId,callback)
    HttpManagerEx:receiveSpringNewReward(rewardId,function(status, errcode, errmsg, data)
        if status == 200 and errcode == 0 then
            local rewardList =self:__dealWithReward(data.reward) 

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

            if callback then
                callback()
            end
        else
            PopText(errmsg)
        end
    end,IS_SHOW_WAITING)
end

function FisrtCharge:setAfterRewardCallback(func)
    self._afterRewardCallback = Helper:getDef(func,EMPTY_FUNC)
end

function FisrtCharge:__checkCanGetReward(rewards)
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

function FisrtCharge:__dealWithReward(reward)
    local info = {}

    if MapIsEmpty(reward) == false then
        for k,v in pairs(reward) do
            if MapIsEmpty(v) == false then
                local _info = {}

                _info.id = v.itemId
                _info.number = v.num
                _info.name = v.name
                _info.type = v.type

                table.insert(info,_info)
            end
        end
    end

    return info
end

function FisrtCharge:__dealWithRewardInfo(rewardInfo)
    local info = {}

    if MapIsEmpty(rewardInfo) == false then
        for k,v in pairs(rewardInfo) do
            if MapIsEmpty(v) == false then
                local _info = {}
                _info.text1 = v.day
                _info.text2 = v.desc
                _info.state = v.status
                _info.rid = v.day
                _info.image = v.imagePath

                if _info.state == 2 then
                    _info.text1_color = cc.c3b(164, 144, 109)
                    _info.text2_color = cc.c3b(191, 191, 191)
                else
                    _info.text1_color = cc.c3b(251, 232, 56)
                    _info.text2_color = cc.c3b(255, 255, 255)
                end

                if _info.state == 1 then
                    _info.btnImg = "Image/UI/TaskUI/anniu.png"
                else
                    _info.btnImg = "Image/UI/TaskUI/anniuhui.png"
                end
                

                local reward = self:__dealWithReward(v.reward)

                _info.getReward = function()
                    if self._chargeState == false then
                        PopText("还没符合领取条件，请先充值")
                        return
                    end

                    if _info.state == 0 then
                        PopText("登录天数不足，请符合条件后再领取")
                        return
                    end

                    if self:__checkCanGetReward(reward) then
                        self:__doReward(v.day,function()
                            if self._afterRewardCallback then
                                self._afterRewardCallback()
                            end
                        end)
                    end
                end

                table.insert(info,_info)
            end
        end
    end

    table.sort(info,function(a,b)
        if a and b and a.rid < b.rid then
            return  true
        else
            return false
        end
    end)

    self._rewardList = info
end

return class("FisrtCharge", {}, FisrtCharge)
0000000