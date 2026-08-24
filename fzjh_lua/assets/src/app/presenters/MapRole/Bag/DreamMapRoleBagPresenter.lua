local class = require("third.class.NewClass")

local MapRoleBagPresenter = require("app.presenters.MapRole.Bag.MapRoleBagPresenter")

local DreamMapRoleBagPresenter = {}

function DreamMapRoleBagPresenter:create()
    local p = DreamMapRoleBagPresenter.new()
    return p
end

function DreamMapRoleBagPresenter:clickShuXiang()
    PopupLayerController:showLayer("ActiveZhaoBookCaseLayer", function(layer)
        layer:showLayer()
        layer:setTipBtnVisible(false)
        layer:setDescVisible(false)
        layer:setButtonChangeIsvisible(false)
    end)
end

function DreamMapRoleBagPresenter:showWeaponItemInfoUI(itemId,onlyId)
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
        layer:setPrepareButtonVisible(false,item)
        layer:setCangKuButtonVisible(nil)
        layer:showLayer(item,itemAttr)
    end)
end


return class("DreamMapRoleBagPresenter", {MapRoleBagPresenter}, DreamMapRoleBagPresenter)
0