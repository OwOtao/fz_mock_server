local NewClass = require("third.class.NewClass")
local AbstractUseItem = require("app.models.role.item.UseItem.AbstractRoleUseItem")
local RoleTitleConst = require("app.models.role.titleSystem.RoleTitleConst")
local RoleTitleResManager = require("app.models.role.titleSystem.RoleTitleResManager")

local RoleUseItem_QiaoDuoTianGongChengHao = {}

function RoleUseItem_QiaoDuoTianGongChengHao:__doUseItem()
    local item = self._item
    local itemId = item.id
    local role = self._role

    HttpManagerEx:detectionGoods(itemId,
        function(status, errcode, errmsg, data)
            if status == 200 and errcode == 0 then
                if data and tonumber(data.numbers) > 0 then
                    local basicTitleId = RoleTitleConst.SpecialBasicTitleId.QiaoDuoTianGong
                    local title = RoleTitleResManager:getBasicTitleClassById(basicTitleId)
                    local name = title:getColorName()

                    if role:hasBasicTitle(basicTitleId) == false then
                        role:addBasicTitle(basicTitleId)
                    end
                
                    role:addItemCount(itemId, -1)
                
                    self:__popText("获得"..name.."称号")
                    self:__onUseAft()
                else
                    self:__popText(errmsg)
                end
            else
                self:__popText(errmsg)
            end
        end,
    IS_SHOW_WAITING)

    return true
end

return NewClass("RoleUseItem_QiaoDuoTianGongChengHao", {AbstractUseItem}, RoleUseItem_QiaoDuoTianGongChengHao)
0000000