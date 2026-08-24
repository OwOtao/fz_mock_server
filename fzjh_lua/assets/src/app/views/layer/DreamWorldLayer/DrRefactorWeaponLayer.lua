local DrRefactorWeaponLayer = class("DrRefactorWeaponLayer", LayerEx)

--@RefType [src.app.models.DreamWorldModel.DreamEquip#DreamEquip]
local DreamEquip = require("app.models.DreamWorldModel.DreamEquip")

function DrRefactorWeaponLayer:create()
    local p = DrRefactorWeaponLayer:new()
    p:init()
    return p
end

function DrRefactorWeaponLayer:init()
    self._UI = require("Layer/ShenBing/ShenBingRemake.lua").create()["root"]
    self._UI:addTo(self)
    Helper:convertUIByParent(self)

    self.Panel_Back:releaseFunc(
        function()
            self:hideLayer()
        end
    )
    self:hide()
end

function DrRefactorWeaponLayer:hideLayer()
    PopupLayerController:hideLayer(
        "DrRefactorWeaponLayer",
        function(layer)
            layer:hide()
        end
    )
end

function DrRefactorWeaponLayer:showLayer(role, cost_points, desc)
    if role == nil then
        self:hideLayer()
        return false
    end

    self.equip_weapon = role:getEquipByName("weapon")
    self.cost_points = cost_points
    if self.equip_weapon == nil then
        PopText("你未装备武器")
        self:hideLayer()
        return false
    end

    local role_item, index = role:getItemWithOnlyId(self.equip_weapon.id)

    local weapon = role:getOneItemByKey(role_item.itemId)

    if weapon == nil then
        self:hideLayer()
        return false
    end

    self.role = role

    self:initChooseBtnLv2(weapon)

    self.ShenBingName:setString(weapon.name)

    self.Panel_1.Text_NPC:setString(desc)

    self:show()
end

function DrRefactorWeaponLayer:initChooseBtnLv2(weapon)
    self.ListView_ShenBingType:removeAllItems()

    local weapon_sub_types = Item.WEAPON_GROUP[weapon.type]

    local now_sub_type = weapon:getCurrWeaponType2()

    for weapon_sub_type, weapon_sub_type_name in ipairs(weapon_sub_types) do
        if now_sub_type ~= weapon_sub_type then
            local btn = self:initBtn()

            self.ListView_ShenBingType:pushBackCustomItem(btn)

            btn.Type_name:setString(weapon_sub_type_name)

            btn:releaseFunc(
                function()
                    print(weapon_sub_type_name)
                    DreamEquip:refactorWeapon(
                        self.role,
                        self.equip_weapon,
                        weapon.type,
                        weapon_sub_type,
                        function(result)
                            if result == true then
                                self:hideLayer()
                            end
                        end
                    )
                end
            )
        end
    end
end

function DrRefactorWeaponLayer:initBtn()
    local btn = self.Panel_type:clone()
    Helper:convertUIByParent(btn)
    return btn
end

Helper:classDefNodeGetInstance(DrRefactorWeaponLayer)
return DrRefactorWeaponLayer
000000