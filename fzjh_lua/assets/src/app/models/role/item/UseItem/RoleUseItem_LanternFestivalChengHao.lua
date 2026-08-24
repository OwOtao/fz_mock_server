local NewClass = require("third.class.NewClass")
local AbstractUseItem = require("app.models.role.item.UseItem.AbstractRoleUseItem")
local RoleTitleConst = require("app.models.role.titleSystem.RoleTitleConst")
local RoleTitleResManager = require("app.models.role.titleSystem.RoleTitleResManager")

local RoleUseItem_LanternFestivalChengHao = {}

function RoleUseItem_LanternFestivalChengHao:__doUseItem()
    local item = self._item
    local itemId = item.id
    local role = self._role


    local basicTitleId = RoleTitleConst.SpecialBasicTitleId.LanternFestival
    local title = RoleTitleResManager:getBasicTitleClassById(basicTitleId)
    local name = title:getColorName()

    if role:hasBasicTitle(basicTitleId) == false then
        role:addBasicTitle(basicTitleId)
    end

    role:addItemCount(itemId, -1)

    self:__popText("获得"..name.."称号")
    self:__onUseAft()

    return true
end

return NewClass("RoleUseItem_LanternFestivalChengHao", {AbstractUseItem}, RoleUseItem_LanternFestivalChengHao)
0000000