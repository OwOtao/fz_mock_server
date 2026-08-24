local NewClass = require("third.class.NewClass")
local AbstractUseItem = require("app.models.role.item.UseItem.AbstractRoleUseItem")
local RoleTitleConst = require("app.models.role.titleSystem.RoleTitleConst")
local RoleTitleResManager = require("app.models.role.titleSystem.RoleTitleResManager")
local RoleUseItem_QiXi2023 = {}

function RoleUseItem_QiXi2023:__doUseItem()
    local item = self._item
    local itemId = item.id
    local role = self._role
    local basicTitleId = RoleTitleConst.SpecialBasicTitleId.HongChenQueXian
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

return NewClass("RoleUseItem_QiXi2023", {AbstractUseItem}, RoleUseItem_QiXi2023)
000000000