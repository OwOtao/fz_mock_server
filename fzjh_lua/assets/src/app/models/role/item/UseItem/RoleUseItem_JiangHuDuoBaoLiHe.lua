local NewClass = require("third.class.NewClass")
local AbstractUseItem = require("app.models.role.item.UseItem.AbstractRoleUseItem")

local RoleUseItem_JiangHuDuoBaoLiHe = {}

local configs = {
    ["21duobaolihe01"] = {
        ["mianju1164"] = 1,
        ["renyannianxingwu"] = 1
    },
    ["21duobaolihe02"] = {
        ["mianju1165"] = 1,
        ["renyannianxingwu"] = 1
    },
    ["21itemsxnmg01"] = {
        ["mianju1166"] = 1,
        ["renyannianxingwu"] = 1
    },
    ["21duobaolihe03"] = {
        ["mianju1167"] = 1,
        ["renyannianxingwu"] = 1
    },
    ["22duobaolihe01"] = {
        ["mianju1181"] = 1,
        ["fourwillowxingwu"] = 1
    },
    ["22duobaolihe02"] = {
        ["mianju1184"] = 1,
        ["fourwillowxingwu"] = 1
    },
}

function RoleUseItem_JiangHuDuoBaoLiHe:__canUseItem()
    local item = self._item

    if configs[item.id] then
        if self._role:checkCanBuyTwoOrMoreThings(configs[item.id],true) == false then
            return false
        end
    end
    
    return true
end

function RoleUseItem_JiangHuDuoBaoLiHe:__doUseItem()
    local role = self._role
    local item = self._item

    HttpManagerEx:checkItemIsCanUse(item.id,1,function(status, errcode, errmsg, data)
        if status == 200 and errcode == 0 then
            role:addItemCount(item.id, -1)

            local rewards = configs[item.id]

            for itemId,itemNum in pairs(rewards) do
                role:addItemCount(itemId,itemNum)
                self:__popText("获得"..self._role:getOneItemByKey(itemId).name.."X"..tostring(itemNum))
            end
            
            self:__onUseAft()
        else
            self:__popText(errmsg)
        end
    end,IS_SHOW_WAITING)

    return true
end

return NewClass("RoleUseItem_JiangHuDuoBaoLiHe", {AbstractUseItem}, RoleUseItem_JiangHuDuoBaoLiHe)
0000000000