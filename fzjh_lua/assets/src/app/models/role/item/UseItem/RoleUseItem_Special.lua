--[[
Descripttion: 
version: 
Author: LvBin
Date: 2023-01-30 16:52:58
--]]
local NewClass = require("third.class.NewClass")
local AbstractUseItem = require("app.models.role.item.UseItem.AbstractRoleUseItem")

local RoleUseItem_Special = {}

function RoleUseItem_Special:__doUseItem()
    local item = self._item
    local role = self._role

    --@desc 使用物品，获得服务器奖励
    if item.rewardid ~= "" and item.rewardid ~= nil and item.rewardid ~= 0 then
        self:__getWebReward(3,item.rewardid,role)
    elseif item.rewardIds ~= "" and item.rewardIds ~= nil and item.rewardIds ~= 0 then
        self:__getWebReward(1,item.rewardIds,role)
    end

    return true
end

--@desc 获服务器奖励
function RoleUseItem_Special:__getWebReward(rewardType,rewardId,role)
    local item = self._item

    if rewardType == nil or rewardId == nil or MapIsEmpty(role) then
        return
    end

    local context = {
        params = {
            rewardType = rewardType,
            rewardId = rewardId,
            roleAttr = {lv = role:getLv(), menpaiId = role:getFamilyId(), qiMax = role:getFinalAttr("qiMax"), neiliMax = role:getFinalAttr("neiliMax")}
        },
        role = role,
        map = User:getRole():getCurrMap(),
        callback = function(rewardData)
            role:addItemCount(item.id , -1)
            PopText("消耗"..item.name.."X1")

            self:__onUseAft()
        end
    }

    User:getRole():getDreamSystem():getWebReward(context)
end


return NewClass("RoleUseItem_Special", {AbstractUseItem}, RoleUseItem_Special)
000000000