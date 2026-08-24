local DrRole_Item = clone(require("app.models.role.Role_Item"))

--@desc: 装备物品
--@part: 部位
--@item: 装备的物品
function DrRole_Item:equipItem(part, item)
    local equip_data = {id = item.id, itemId = item.itemId}
    self.equips[part] = equip_data
    --@desc 添加装备带来的buff
    local itemAttr = self:getOneItemByKey(item.itemId)
    if itemAttr and itemAttr.buffid then
        local buffidList = string.split(tostring(itemAttr.buffid), ";")
        for i, buffId in ipairs(buffidList) do
            self:addItemBuff(buffId, 1)
        end
	end
	

	local prepareWeapon=self.prepareWeapon
	if item and part=="weapon" and MapIsEmpty(prepareWeapon)==false and prepareWeapon.id == item.id then 
		self.prepareWeapon={}
    end
    

    --@desc 装备兵器，根据准备的兵器类武学初始化兵器类型
    do
        if item and part=="weapon" then
            local DreamEquip = require("app.models.DreamWorldModel.DreamEquip")
            DreamEquip:equipWeapon(self,equip_data)
        end
    end
end

return DrRole_Item
00000000