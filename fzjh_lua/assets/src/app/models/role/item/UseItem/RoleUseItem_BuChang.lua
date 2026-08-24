local NewClass = require("third.class.NewClass")
local AbstractUseItem = require("app.models.role.item.UseItem.AbstractRoleUseItem")

local UseItem_BuChang = {}

function UseItem_BuChang:__doUseItem()
    local role = self._role
    local item = self._item

    self._role:addItemCount("qixibuchangdaoju1", -1)
    self._role:setInheritFlag("QiXi_JingMax", self._role:getInheritFlag("QiXi_JingMax") + 10)

    self._role._iOutput:popText("精力上限 + 10")

    self._role._iOutput:richPrint(item.useDsc)

    self:__onUseAft()

    return true
end

return NewClass("UseItem_BuChang", {AbstractUseItem}, UseItem_BuChang)
00000000000