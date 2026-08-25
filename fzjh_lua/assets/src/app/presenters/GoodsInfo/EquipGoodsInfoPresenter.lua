local NewClass = require("third.class.NewClass")

local IGoodsPresenter = require("app.presenters.GoodsInfo.IGoodsPresenter")

local ItemDescInfo = require("app.models.item.ItemDescInfo")

local EquipGoodsInfoPresenter = {}

function EquipGoodsInfoPresenter:create(goods)
    local o = EquipGoodsInfoPresenter.new()
    o:init(goods)
    return o
end

function EquipGoodsInfoPresenter:init(goods)
    self.__ui = require("app.views.ui.GoodsInfoUI.EquipGoodsInfoUI"):create()
    self.__goods = goods
	self.__item = Item:getOneItemByKey(self.__goods:getItemId())
end

function EquipGoodsInfoPresenter:getUI()
    return self.__ui
end

function EquipGoodsInfoPresenter:showUI()
    self.__ui:setTitle("装备信息")
    
	self:__initUI()

    self.__ui:showUI()
end

function EquipGoodsInfoPresenter:__initUI()
	self.__ui:setNodeText("Text_1","装备名称：")

	self.__ui:setNodeText("Text_name",self.__item.name)

	self.__ui:setNodeText("Text_2","类型："..self.__item.bType)

	if self.__item.shoucang == 1 then
		self.__ui:setNodeText("Text_4","武藏评分："..self.__item.wuzang)
	else
		self.__ui:setNodeText("Text_4","武藏评分：不可收藏")
	end

	self.__ui:setNodeText("Text_6",self.__item.dsc)

	if self.__item.equipPart ~= "weapon" then
		self.__ui:setNodeText("Text_3","保护力：+"..tostring(self.__item.protect))

		self.__ui:setPanelWeaponAttrisVisible(false)
	else
		self.__ui:setNodeText("Text_3","伤害值：+"..Helper:getDef(Helper:mathFloor(self.__item:getWeaponDamage()),0))

		self.__ui:setPanelWeaponAttrisVisible(true)

		local weaponInfo = ItemDescInfo:getNormalWeaponDescInfo(self.__item, false, User:getRole())

		for i , v in ipairs(weaponInfo.attrs) do
			self.__ui:setAttributePanel(
				i,
				v.name,
				v.state,
				function()
					self.__ui:setTipsDesc_1Text(v.desc)
					self.__ui:setTipsDesc_2Text(v.stateDesc)
					self.__ui:setTipsDesc_3Text(v.valueDesc)
				end
			)
		end
	end
end

function EquipGoodsInfoPresenter:hide()
    self.__ui:hideUI()
end

function EquipGoodsInfoPresenter:setButtonBackVisible(visible)
    self.__ui:setButtonBackVisible(visible)
end

function EquipGoodsInfoPresenter:setButtonBack(func)
    self.__ui:setButtonBack(function()
        if func then
            func()
        end
    end)
end

return NewClass("EquipGoodsInfoPresenter", {IGoodsPresenter}, EquipGoodsInfoPresenter)0000000000000000