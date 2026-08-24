local class = require("third.class.NewClass")

local MapRoleBagPresenter = require("app.presenters.MapRole.Bag.MapRoleBagPresenter")

local BiWuMapRoleBagPresenter = {}

function BiWuMapRoleBagPresenter:create()
    local p = BiWuMapRoleBagPresenter.new()
    return p
end

function BiWuMapRoleBagPresenter:showWeaponItemInfoUI(itemId,onlyId)
    local role = self.__input:getRole()
    local item, i = role:getItemWithOnlyId(onlyId)
    local itemAttr = role:getOneItemByKey(itemId)

    PopupLayerController:showLayer("BagDescLayer",function(layer)   
        layer:setRole(role)
        layer:setEquipItemFunc(function(item, itemAttr)
            self:__equipOneItem(item, itemAttr)
        end)

        layer:setRefreshListFunc(function()
            self:showBagList()
            self:setBagWeight()
        end)
        layer:setPrepareButtonVisible(true,item)
        if itemAttr.wpType == "神兵" then
            layer:setCangKuButtonVisible("详\n情")
        else
            layer:setCangKuButtonVisible()
        end
 
        layer:showLayer(item,itemAttr)
    end)
end

return class("BiWuMapRoleBagPresenter", {MapRoleBagPresenter}, BiWuMapRoleBagPresenter)
0