local NewClass = require("third.class.NewClass")
local AbstractUseItem = require("app.models.role.item.UseItem.AbstractRoleUseItem")
local RoleTitleConst = require("app.models.role.titleSystem.RoleTitleConst")

local RoleUseItem_QiXiChengHao = {}

function RoleUseItem_QiXiChengHao:__doUseItem()
    local role = self._role
    local item = self._item
    local chenghaoID = item.id

    if type(chenghaoID) ~= "string" then
        return false
    end

    local num
    if chenghaoID == "qxchenghaobuchang" then
        num = 4
    elseif chenghaoID == "qxchenghaobuchang2" then
        num = 3
    elseif chenghaoID == "qxchenghaobuchang3" then
        num = 2
    elseif chenghaoID == "qxchenghaobuchang4" then
        num = 1
    end

    role:addItemCount(chenghaoID, -1)

    local titles = {
        ["1"] = RoleTitleConst.SpecialBasicTitleId.QiXi1,
        ["2"] = RoleTitleConst.SpecialBasicTitleId.QiXi2,
        ["3"] = RoleTitleConst.SpecialBasicTitleId.QiXi3,
        ["4"] = RoleTitleConst.SpecialBasicTitleId.QiXi4
    }

    for i, titleId in pairs(titles) do
        if i == tostring(num) then
            role:addBasicTitle(titleId)
        else
            role:deleteBasicTitle(titleId)
        end
    end

    role._iOutput:popText("获得" .. item.name .. " X " .. 1)

    self:__onUseAft()

    return true
end

return NewClass("RoleUseItem_QiXiChengHao", {AbstractUseItem}, RoleUseItem_QiXiChengHao)
0000000000