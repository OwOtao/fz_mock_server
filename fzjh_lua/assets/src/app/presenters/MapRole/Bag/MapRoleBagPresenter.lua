local class = require("third.class.NewClass")

local BagDescLayerShowType = {
    NormalItem = 1,
    Weapon = 2,
    Furniture = 3
}

local MapRoleBagPresenter = {}

function MapRoleBagPresenter:create()
    local p = MapRoleBagPresenter.new()
    return p
end

function MapRoleBagPresenter:setInput(iBagModel)
    self.__input = iBagModel
end

function MapRoleBagPresenter:setUI(ui)
    self.__ui = ui
end

function MapRoleBagPresenter:setMainPresenter(mainPresenter)
    self.__mainPresenter = mainPresenter
end

function MapRoleBagPresenter:hideMainPresenter()
    self.__mainPresenter:hide()
end

function MapRoleBagPresenter:showPresenter()
    PopupLayerController:showLayer("MapRoleBagUI",function(ui)
		self:setUI(ui)

        self:showBagList()

		ui:showUI()
	end)
end


function MapRoleBagPresenter:hidePresenter()
    PopupLayerController:hideLayer("MapRoleBagUI",function(ui)
		self:beforeClickItemFunc()

		ui:hideUI()
	end)
end

function MapRoleBagPresenter:hideItemInfoUI()
    self:beforeClickItemFunc()
end

function MapRoleBagPresenter:destroyMapRoleItemInfoPresenter()
    self.__mapRoleItemInfoPresenter = nil

    self:setItemInfoShowType(0)
end

function MapRoleBagPresenter:showBagList()
    local defaultList = self.__input:getRoleDefaultItems()
    local defaultListNum = #defaultList
    for index,itemInfo in ipairs(defaultList) do
        local itemPanel = self.__ui:getItem(index  - 1)
        if not itemPanel then
            itemPanel = self:getItemPanel()
            self.__ui:insertItemToListView(itemPanel)
        end
        self:__initItemUI(itemPanel,itemInfo)
    end

    local bagList = self.__input:getRoleBagItems()
    local bagItemListNum = #bagList
    for i,itemInfo in ipairs(bagList) do
        local itemPanel = self.__ui:getItem(defaultListNum + i - 1)
        if not itemPanel then
            itemPanel = self:getItemPanel()
            self.__ui:insertItemToListView(itemPanel)
        end
        self:__initItemUI(itemPanel,itemInfo)
    end

    local itemNum = #self.__ui:getItems()
    for i = bagItemListNum + defaultListNum + 1, itemNum do
		self.__ui:removeLastItem()
	end
end

function MapRoleBagPresenter:getItemPanel()
    local itemPanel = self.__ui:createItemPanel()
    itemPanel.Image_item_tiao.Text_item_name:enableOutline(cc.c4b(0, 0, 0, 255), 5)
	itemPanel:setVisible(true)
	itemPanel:setTouchEnabled(true)
	itemPanel.Panel_item_dian:setVisible(false)
	itemPanel.Image_item_back:setVisible(false)
    return itemPanel
end

function MapRoleBagPresenter:__initItemUI(itemPanel,itemInfo)
    itemPanel.Image_equipWeaponIcon:setVisible(itemInfo.equipWeaponIconVisible)

    if itemInfo.equipWeaponIconVisible then
        itemPanel.Image_equipWeaponIcon:loadTexture(itemInfo.equipWeaponIcon)
    end

    itemPanel.Image_prepareWeaponIcon:setVisible(itemInfo.prepareWeaponIconVisible)

    if itemInfo.prepareWeaponIconVisible then
        itemPanel.Image_prepareWeaponIcon:loadTexture(itemInfo.prepareWeaponIcon)
    end

	itemPanel.Image_item_tiao.Text_item_name:setColor(cc.c3b(208,208,208))---设置默认颜色
    itemPanel.Image_item_tiao.Text_item_name:setString(itemInfo.text)
    itemPanel.Panel_item_dian:setVisible(itemInfo.equipVisible)
    itemPanel.Image_item_back:setVisible(itemInfo.backVisible)
    
	itemPanel:releaseFunc(function()
        self:hideItemImageBack()

        itemPanel.Image_item_back:setVisible(true)

		self:__initItemFunc(itemInfo.itemId,itemInfo.id)
    end)
end

function MapRoleBagPresenter:hideItemImageBack()
    local items = self.__ui:getItems()
    for i, itemPanel in ipairs(items) do
		itemPanel.Image_item_back:setVisible(false)
	end
end

function MapRoleBagPresenter:setBagWeight()
    self.__mainPresenter:setWeight()
end

function MapRoleBagPresenter:setItemInfoShowType(showType)
    self.__showType = showType
end

function MapRoleBagPresenter:beforeClickItemFunc()
    if self.__showType == BagDescLayerShowType.Weapon then
        PopupLayerController:hideLayer("BagDescLayer",function ( layer )
            layer:hideLayer()
            
        end,0)
    end

    if self.__showType == BagDescLayerShowType.NormalItem then
        if self.__mapRoleItemInfoPresenter then
            self.__mapRoleItemInfoPresenter:hidePresenter()
            self.__mapRoleItemInfoPresenter = nil
        end
    end

    if self.__showType == BagDescLayerShowType.Furniture then
        PopupLayerController:hideLayer("FurnitureBackLayer",function ( layer )
            layer:hideLayer()
        end,0)
    end

    self:setItemInfoShowType(0)
end

function MapRoleBagPresenter:__initItemFunc(itemId,onlyId)
    self:beforeClickItemFunc()

    if itemId == "shuxiang" then
        self:clickShuXiang()
        return
    end

    if itemId == "decorativeBox" then
        self:__clickDecorativeBox()
        return
    end

    if itemId == "literaryBox" then
        self:__clickLiteraryBox()
        return
    end

    if itemId == "medicinalBox" then
        self:__clickMedicinalBox()
        return
    end

    if itemId == "smeltBox" then
        self:__clickSmeltBox()
        return
    end

    if itemId == "bookRack" then
        self:__clickBookRack()
        return
    end

    if itemId == "volumeBox" then
        self:__clickVolumeBox()
        return
    end

    local itemAttr = self.__input:getOneItemByKey(itemId)

    if itemAttr.type == "家具" then
        self:__clickFurniture(itemId,onlyId)
        return
    end

    if itemAttr.equipPart == "weapon" then
        self:__clickWeapon(itemId,onlyId)
        return
    end

    self:__clickNormalItem(itemId,onlyId)
end

function MapRoleBagPresenter:clickShuXiang()
    PopupLayerController:showLayer("BookCaseLayer", function(layer)
        layer:showLayer()
    end)
end

function MapRoleBagPresenter:__clickDecorativeBox()
    PopupLayerController:showLayer("DecorativeBoxLayer", function(layer)
        layer:showLayer(function()
            self:showBagList()
            self:setBagWeight()
        end)
    end)
end

function MapRoleBagPresenter:__clickLiteraryBox()
    PopupLayerController:showLayer("BookLiteraryLayer", function(layer)
        layer:showLayer(false)
    end)
end

function MapRoleBagPresenter:__clickMedicinalBox()
    PopupLayerController:showLayer("MedicinalLayer",function(layer)
        layer:showLayer(true)
    end)
end

function MapRoleBagPresenter:__clickSmeltBox()
    PopupLayerController:showLayer("SmeltBoxLayer",function(layer)
        layer:showLayer(true)
    end)
end

function MapRoleBagPresenter:__clickBookRack()
    PopupLayerController:showLayer("BookRackUI",function(layer)
        layer:showLayer()
    end)
end

function MapRoleBagPresenter:__clickVolumeBox()
    local role = self.__input:getRole()
    local currencyVersion = role:getCurrencyVersion()
    
    HttpManagerEx:getZhaoBreakThroughItems(currencyVersion,
        function(status, errcode, errmsg, data)
            if status == 200 and errcode == 0 then
                PopupLayerController:showLayer("VolumeBoxPresent",function(layer)
                    layer:showLayer(data.matters_list)
                end)
            else
                PopText(errmsg)
            end
        end,
        IS_SHOW_WAITING
    )
end


function MapRoleBagPresenter:__clickFurniture(itemId,onlyId)
    local role = self.__input:getRole()
    local item, i = role:getItemWithOnlyId(onlyId)
    local itemAttr = role:getOneItemByKey(itemId)

    PopupLayerController:showLayer("FurnitureBackLayer",function (layer)
        layer:setLeftButtonVisible(false)
        layer:setRightButtonVisible(true)
        layer:setRightButton("安\n放",function ()
            layer:hideLayer()

            local currMap = User:getRole():getCurrMap()
            if not currMap then
                PopText("该副本无法安放家具。")
                return
            end
            --@RefType [app.models.HomelandModel.FurnitureModel.FurnitureModel#FurnitureModel]
            local FurnitureModel = require("app.models.HomelandModel.FurnitureModel.FurnitureModel")

            FurnitureModel:place(
                currMap,
                item,
                function()
                    self:showBagList()
                    self:setBagWeight()
                    self:hideMainPresenter()
                end
            )
        end)
        
        layer:showLayer(item,itemAttr)
    end)

    self:setItemInfoShowType(BagDescLayerShowType.Furniture)
end

function MapRoleBagPresenter:__clickWeapon(itemId,onlyId)
    self:showWeaponItemInfoUI(itemId,onlyId)

    self:setItemInfoShowType(BagDescLayerShowType.Weapon)
end

function MapRoleBagPresenter:showWeaponItemInfoUI(itemId,onlyId)
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
        layer:setPrepareFunc(function(funcType)
            if funcType == "prepare" and itemAttr.wpType == "神兵" then
                local buffs = ShenBingEffct:getShenBingNormalBuff(itemAttr)
    
                if MapIsEmpty(buffs) == false then
                    for __,buffId in ipairs(buffs) do
                        self:removeBuff(buffId,role)
                    end
                end
            end
        end)

        layer:showLayer(item,itemAttr)
    end)
end

function MapRoleBagPresenter:__clickNormalItem(itemId,onlyId)
    PopupLayerController:showLayer("MapRoleItemUI",function(ui)
        local MapRoleItemInfoPresenter = require("app.presenters.MapRole.Item.MapRoleItemInfoPresenter"):create()
        MapRoleItemInfoPresenter:setInput(self.__input)
        MapRoleItemInfoPresenter:setBagPresenter(self)
        MapRoleItemInfoPresenter:setUI(ui)
        MapRoleItemInfoPresenter:showPresenter(itemId,onlyId)
        self.__mapRoleItemInfoPresenter = MapRoleItemInfoPresenter
    end)

    self:setItemInfoShowType(BagDescLayerShowType.NormalItem)
end

function MapRoleBagPresenter:__equipOneItem(item, itemAttr)
    if not item then
		return
	end

	if item.type == "神兵" then
		if itemAttr.wanhaodu == 0 then
			self:popText("该武器已被损坏")
			return
		end
	else
		if item.wanhaodu and item.wanhaodu == 0 then
			self:popText("该武器已被损坏")	
			return
		end
	end

    local role = self.__input:getRole()

	local desc = ""

	if not role:checkItemIsEquip(item.id) then
        if itemAttr.equipPart == "weapon" then
            local weapon = role:getEquipByName("weapon")
            if weapon then
                local itemId = weapon.itemId
                if role:isShengBing(itemId) then
                    local shenBing = role:getOneItemByKey(itemId)
                    local buffs = ShenBingEffct:getShenBingNormalBuff(shenBing)

                    if MapIsEmpty(buffs) == false then
                        for __,buffId in ipairs(buffs) do
                            self:removeBuff(buffId,role)
                        end
                    end
                end
            end
        end

		role:setEquipByName(itemAttr.equipPart, item)
		desc = itemAttr.equipText

		if itemAttr.wpType == "神兵" then
            do
                local buffs = ShenBingEffct:getShenBingNormalBuff(itemAttr)

                if MapIsEmpty(buffs) == false then
                    for __,buffId in ipairs(buffs) do
                        self:addBuff(buffId,role)
                    end
                end
            end
            
			desc = ShenBingDesc:getWeaponEquipText(itemAttr)
		end
	else
		role:setEquipByName(itemAttr.equipPart, nil)
		desc = itemAttr.unwieldText
		if itemAttr.wpType == "神兵" then
            do
                local buffs = ShenBingEffct:getShenBingNormalBuff(itemAttr)

                if MapIsEmpty(buffs) == false then
                    for __,buffId in ipairs(buffs) do
                        self:removeBuff(buffId,role)
                    end
                end
            end

			desc = ShenBingDesc:getWeaponTakeOffText(itemAttr)
		end
	end

	desc = string.gsub(desc, "$N", "你")
	desc = string.gsub(desc, "$w", itemAttr.name)
	desc = string.gsub(desc, "$W", itemAttr.name)

    self.__mainPresenter:equipOneItem(desc)
end

function MapRoleBagPresenter:addBuff(buffId,role)
end

function MapRoleBagPresenter:removeBuff(buffId,role)
end

function MapRoleBagPresenter:popText(text)
    PopText(text)
end

return class("MapRoleBagPresenter", {}, MapRoleBagPresenter)
000000000000000