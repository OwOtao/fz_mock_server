local NewClass = require("third.class.NewClass")
local AbstractUseItem = require("app.models.role.item.UseItem.AbstractRoleUseItem")
local RoleTitleConst = require("app.models.role.titleSystem.RoleTitleConst")
local RoleTitleResManager = require("app.models.role.titleSystem.RoleTitleResManager")
local RoleUseItem_XiMiChengHao = {}

function RoleUseItem_XiMiChengHao:__doUseItem()
    local role = self._role
    local item = self._item

    local basicTitleId = RoleTitleConst.SpecialBasicTitleId.XiMi
    local title = RoleTitleResManager:getBasicTitleClassById(basicTitleId)
    local name = title:getColorName()

    if role:hasBasicTitle(basicTitleId) == false then
        role:addBasicTitle(basicTitleId)
    end

    role:addItemCount(item.id, -1)

    self:__popText("获得"..name.."称号")

    self:__onUseAft()

    return true
end

return NewClass("RoleUseItem_XiMiChengHao", {AbstractUseItem}, RoleUseItem_XiMiChengHao)
00000000000