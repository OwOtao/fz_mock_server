local NewClass = require("third.class.NewClass")
local AbstractUseItem = require("app.models.role.item.UseItem.AbstractRoleUseItem")
local SkillBreakThroughResManager = require("app.models.skill.skillBreakThrough.SkillBreakThroughResManager")

local RoleUseItem_XuJuanLiHe = {}

function RoleUseItem_XuJuanLiHe:__canUseItem()
    return true
end

function RoleUseItem_XuJuanLiHe:__doUseItem()
    local role = self._role
    local item = self._item
    local currencyVersion = role:getCurrencyVersion()

    HttpManagerEx:consumeSpecialProps(item.id, 1, currencyVersion, function(status, errcode, errmsg, data)
        if status == 200 and errcode == 0 then
            local rewards = data.rewards

            for index,info in pairs(rewards) do
                local itemName = SkillBreakThroughResManager:getBreakThroughItem(info.id).name
                self:__popText("获得"..itemName.."X"..tostring(info.num))
            end

            role:addItemCount(item.id, -1)

            if data.currencyVersion then
                role:setCurrencyVersion(data.currencyVersion)
            end
            
            self:__onUseAft()
        else
            self:__popText(errmsg)
        end
    end,IS_SHOW_WAITING)

    return true
end

return NewClass("RoleUseItem_XuJuanLiHe", {AbstractUseItem}, RoleUseItem_XuJuanLiHe)
00