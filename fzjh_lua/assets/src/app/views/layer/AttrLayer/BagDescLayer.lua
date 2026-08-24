local BagDescLayer = class("BagDescLayer", cc.Layer)
--@RefType [app.models.Poison.PoisonUtil#PoisonUtil]
local PoisonUtil = require("app.models.Poison.PoisonUtil")

function BagDescLayer:create()
	local p = BagDescLayer:new()
	p:init()
	return p
end

local weaponPoison = {}

function BagDescLayer:init()
	local UI = require("Layer/AttrUI/BagDescUI.lua").create()['root']
	UI:addTo(self)
	Helper:convertUIByParent(self)
	self:setVisible(false)
	self.freshFunc = function()

	end
	self.backFunc = function()

	end
	self.equipFunc = function()

	end
	self.cangKuFunc = function()
	end

	self.prepareFunc= function()
	end

	self.Panel_itemDesc:releaseFunc(function()
		PopupLayerController:hideLayer("BagDescLayer",function(layer)
			layer:hideLayer()
		end,0)
	end)
end

function BagDescLayer:showLayer(item,itemAttr)
	weaponPoison = PoisonUtil:getPoisonOnWeapon(item.id)

	if self.handle ~= nil then
		self:unschedule(self.handle)
		self.handle = nil
	end

	self:itemDescShow()
	self:setItemInfo(item,itemAttr)
	self:setImageButtonFunc(item,itemAttr)
	self:setCangKuButton(item,itemAttr)
	self:setPrepareButtonFunc(item)
	self:setSchedule()
	self:setWeaponPoisonInfo()
	self:setBack()
end

function BagDescLayer:hideLayer()
	local printLayer = MainControllLayer:getLayer("PrintLayer")
	local title = MainControllLayer:getLayer("TitleLayer")
	title:setTitleBack()
	printLayer:setPanelVisible(false)

	if self.handle ~= nil then
		self:unschedule(self.handle)
		self.handle = nil
	end
	self:hide()
	-- self.backFunc()
end
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/01/09 20:51:02
-- @desc 刷新背包列表的方法
function BagDescLayer:setRefreshListFunc(func)
	if type(func) == "function" then
		self.freshFunc = func
	end
end

function BagDescLayer:setBackFunc(func)
	if type(func) == "function" then
		self.backFunc = func
	end
end

function BagDescLayer:setEquipItemFunc(func)
	if type(func) == "function" then
		self.equipFunc = func
	end
end

function BagDescLayer:setCangKuFunc(func)
	if type(func) == "function" then
		self.cangKuFunc = func
	else
		self:setImageButton()
	end
end

function BagDescLayer:setPrepareFunc(func)
	if type(func) == "function" then
		self.prepareFunc = func
	end
end
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/01/09 20:06:53
-- @desc 显示动画
function BagDescLayer:itemDescShow()
	self:show()
	self.Panel_itemDesc:setTouchEnabled(true)
	local panel = self.Panel_itemDesc
	panel:setVisible(true)
	local actionTag = panel:getActionTagByName("move")
	panel:stopActionByTag(actionTag)
	panel:move(cc.p(380, 1610))
	local action = cc.Sequence:create(
		cc.Spawn:create(
		cc.MoveTo:create(UI_ANIM_DURATION, cc.p(380, 1440)),
		cc.FadeIn:create(UI_ANIM_DURATION)
		), cc.CallFunc:create(
			function()
				print("-------------------------------------",panel:getPositionY())
	end))
	action:setTag(actionTag)
	panel:runAction(action)
end


-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/01/09 20:12:07
-- @desc 设置兵器信息
function BagDescLayer:setItemInfo(item,itemAttr)
	if itemAttr.wpType == "神兵" then
		self.Panel_itemDesc.Image_back.Panel_title.Text_name:setString(itemAttr.nameColor..itemAttr.name)--道具名称
	else
		self.Panel_itemDesc.Image_back.Panel_title.Text_name:setColor(cc.c3b(208,208,208))---设置默认颜色
		self.Panel_itemDesc.Image_back.Panel_title.Text_name:setString(itemAttr.name)--道具名称
	end
	
	self.Panel_itemDesc.Image_back.Panel_title.Text_zhuangbei:setString(itemAttr:getItemShowType())--道具类型

	self:initDescRichText(itemAttr:getDsc()) --道具描述

	self:delayFunc(0.1,function ()
		self.richPrint:jumpToTop()
	end)
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/01/10 15:33:02
-- @desc 设置兵器淬毒信息
function BagDescLayer:setWeaponPoisonInfo()
	self.Panel_itemDesc.Panel_poison:setContentSize({width = 640, height = 57})
	self.Panel_itemDesc.Image_back.TextField_desc:setPositionY(462)
	
	if not MapIsEmpty(weaponPoison) then
		self.Panel_itemDesc.Panel_poison:setVisible(true)
		local poison = Item:getOneItemByKey(weaponPoison.poisonId)
		if poison ~= nil then
			self.Panel_itemDesc.Panel_poison.Text_name:setString(poison.name)
			self.Panel_itemDesc.Panel_poison.Text_time:setString("剩余："..weaponPoison.fightCount)
		end
	else
		self.Panel_itemDesc.Panel_poison:setVisible(false)
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/01/09 20:33:53
-- @desc 右侧按钮名称
function BagDescLayer:setImageButton(str)
	if not str then
		self.Panel_itemDesc.Image_back.Image_button:setVisible(false)
	else
		self.Panel_itemDesc.Image_back.Image_button:setVisible(true)
		self.Panel_itemDesc.Image_back.Image_button.Text_chuan:setString(str)
	end
end


-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/01/10 14:07:26
-- @desc 左侧按钮
function BagDescLayer:setCangKuButton(item,itemAttr)
	local role = Helper:getDef(self.role,User:getRole())
	local bagItems = role:getItems()
	if itemAttr.wpType == "神兵" then
		self.Panel_itemDesc.Image_back.Image_button_cangku.Text_cangku:setString("详\n情")
	end
	self.Panel_itemDesc.Image_back.Image_button_cangku:releaseFunc(function()
		local ckItems = role:getAttr("ckitems")
		local item,i=role:getItemWithOnlyId(item.id)
    	if itemAttr.wpType == "神兵" then
				local ItemDescInfo = require("app.models.item.ItemDescInfo")
				local weaponInfo = ItemDescInfo:getShenBingDescInfo(itemAttr, role)
	    		PopupLayerController:showLayer(
					"WeaponDescInfoPresenter",
					function(layer)
						layer:setData(weaponInfo)
						layer:showLayer()
					end
				)
				PopupLayerController:hideLayer("BagDescLayer",function(layer)
					layer:hideLayer()
				end,0)
    		return
    	end
    	if itemAttr.upgrade ~= nil then
    		if role:checkItemIsEquip(item.id) then
    			PopText("装备已经穿上，请先卸下再升级")
				PopupLayerController:hideLayer("BagDescLayer",function(layer)
					layer:hideLayer()
				end,0)
	    		return
    		end
    		itemAttr:upgradeItem(role, function()
    			if not MapIsEmpty(bagItems) then
		    		table.remove(bagItems,i)
		    	end
    		end)
				PopupLayerController:hideLayer("BagDescLayer",function(layer)
					layer:hideLayer()
				end,0)	
    		return
    	end
	    if role:checkItemIsEquip(item.id) then
	    	PopText("装备已经穿上，请先卸下再放入仓库")
				PopupLayerController:hideLayer("BagDescLayer",function(layer)
					layer:hideLayer()
				end,0)
	    	return
	    end

	  	 if role:checkIsPrepareWeapon(item.id) then 
			PopText("装备已经准备，请先取消准备再放入仓库。")
			PopupLayerController:hideLayer("BagDescLayer",function(layer)
					layer:hideLayer()
				end,0)
			return
		end

		if role:checkItemIsDamage(item) then
			PopText("损坏的兵器不能放入仓库！")
				PopupLayerController:hideLayer("BagDescLayer",function(layer)
					layer:hideLayer()
				end,0)
			return
		end
	    
		if itemAttr.deposit == 0 or itemAttr.deposit == false then
	    	PopText("贵重物品还是不要放入仓库为好。")
				PopupLayerController:hideLayer("BagDescLayer",function(layer)
					layer:hideLayer()
				end,0)
	    	return
	    end
	    if not role:addItemCountck(item.itemId,item.count,item.time,item.id) then
				PopupLayerController:hideLayer("BagDescLayer",function(layer)
					layer:hideLayer()
				end,0)
		    return
	    end
	    if not MapIsEmpty(bagItems) then
	    	table.remove(bagItems,i)
	    end
	    PopText("将"..itemAttr.name.." X"..item.count.."放入仓库")
	    self:hide()
	    self.freshFunc()
	    self.backFunc()
	    self.cangKuFunc()
		PopupLayerController:hideLayer("BagDescLayer",function(layer)
			layer:hideLayer()
		end,0)
	end)
end

function BagDescLayer:setCangKuButtonVisible(name)
	if name == nil or name == "" then
		self.Panel_itemDesc.Image_back.Image_button_cangku:setVisible(false)
	else
		self.Panel_itemDesc.Image_back.Image_button_cangku:setVisible(true)
		self.Panel_itemDesc.Image_back.Image_button_cangku.Text_cangku:setString(name)
	end
end
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/01/09 20:37:48
-- @desc 装备，脱下

function BagDescLayer:setImageButtonFunc(item,itemAttr)
	local role = Helper:getDef(self.role,User:getRole())
	local itemDesc = self.Panel_itemDesc
	if role:checkItemIsEquip(item.id) then
		self:setImageButton("卸\n下")
	else
		self:setImageButton("穿\n上")
	end
	itemDesc.Image_back.Image_button:releaseFunc(function()
		self:equipOneItem(item,itemAttr)
		self.freshFunc()
		self.backFunc()
		self:hideLayer()
	end)
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/01/09 20:53:48
-- @desc 装备武器
function BagDescLayer:equipOneItem(item,itemAttr)
	self.equipFunc(item,itemAttr)
	self:setImageButtonFunc(item,itemAttr)	
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/01/09 20:58:30
-- @desc 返回
function BagDescLayer:setBack()
	local printLayer = MainControllLayer:getLayer("PrintLayer")
	local title = MainControllLayer:getLayer("TitleLayer")
	printLayer:setPanelVisible(true)
	printLayer:setPanleReleaseFunc(function()
		if self.handle ~= nil then
			self:unschedule(self.handle)
			self.handle = nil
		end
		PopupLayerController:hideLayer("BagDescLayer",function (layer)
			layer:hide()
			if self.backFunc and type(self.backFunc) == "function" then
				self.backFunc()
			end
		end,0)
	end)
	title:ButtonBack(function()
		if self.handle ~= nil then
			self:unschedule(self.handle)
			self.handle = nil
		end
		PopupLayerController:hideLayer("BagDescLayer",function (layer)
			layer:hide()
			if self.backFunc and type(self.backFunc) == "function" then
				self.backFunc()
			end
		end,0)
	end)
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/01/10 15:20:40
-- @desc 时间函数
function BagDescLayer:setSchedule()
	-- self.Panel_itemDesc.Panel_poison:setVisible(true)
	-- if not MapIsEmpty(weaponPoison) then
	-- 	local year, month, day, hour, minute, second = Helper:getExpiredTime(weaponPoison.pEndtime,GetTime())
	-- 	self.Panel_itemDesc.Panel_poison.Text_time:setString(Helper:changeNumberDateToStringDate(year, month, day, hour, minute, second))
	-- 	self.handle = self:schedule(function()
	-- 		if weaponPoison.pEndtime < GetTime() then
	-- 			self.Panel_itemDesc.Panel_poison:setContentSize({width = 640, height = 0})
	-- 			self.Panel_itemDesc.Image_back.TextField_desc:setPositionY(519)
	-- 			PoisonUtil:clearPoisonWeapon(weaponPoison.index)
	-- 			if self.handle ~= nil then
	-- 				self:unschedule(self.handle)
	-- 				self.handle = nil
	-- 			end	
	-- 		else
	-- 			year, month, day, hour, minute, second = Helper:getExpiredTime(weaponPoison.pEndtime,GetTime())
	-- 			local str = Helper:changeNumberDateToStringDate(year, month, day, hour, minute, second)
	-- 			if str == "" then
	-- 				str = "0秒"
	-- 			end
	-- 			self.Panel_itemDesc.Panel_poison.Text_time:setString(str)	
	-- 		end
	-- 	end,1.0)
	-- else
	-- 	self.Panel_itemDesc.Panel_poison:setVisible(false)
	-- 	self.Panel_itemDesc.Panel_poison:setContentSize({width = 640, height = 0})
	-- 	self.Panel_itemDesc.Image_back.TextField_desc:setPositionY(519)
	-- end
end

function BagDescLayer:setPrepareButtonVisible(bool,item)
	local role = Helper:getDef(self.role,User:getRole())
	self.Panel_itemDesc.Image_back.Image_button_prepare:setVisible(bool)
	if role:checkIsPrepareWeapon(item.id) then 
		self.Panel_itemDesc.Image_back.Image_button_prepare.Text_prepare:setString("取备\n消用")
	else
		self.Panel_itemDesc.Image_back.Image_button_prepare.Text_prepare:setString("备\n用")
	end
end

function BagDescLayer:setPrepareButtonFunc(item)
	local role = Helper:getDef(self.role,User:getRole())
	local itemDesc = self.Panel_itemDesc
	itemDesc.Image_back.Image_button_prepare:releaseFunc(function()
		local itemAttr=role:getOneItemByKey(item.itemId)
		if item.type == "神兵" then
			if itemAttr.wanhaodu == 0 then
				PopText("该武器已被损坏")
				return
			end
		else
			if item.wanhaodu and item.wanhaodu == 0 then
				PopText("该武器已被损坏")	
				return
			end
		end
		local prepareWeapon=role:getPrepareWeapon()
		local currWeapon = role:getEquipByName("weapon")
		if MapIsEmpty(prepareWeapon) or (item and prepareWeapon.id ~= item.id) then 
			role:setPrepareWeapon(item)
			self.prepareFunc("prepare")
			PopText("备用武器已就绪！")
			if currWeapon and currWeapon.id == item.id then 
				RichPrint("main", "YEL你将NOR"..itemAttr.name.."YEL卸下但依然带在身上，以备不时之需。NOR")
			else
				RichPrint("main", "YEL你将NOR"..itemAttr.name.."YEL带在身上，以备不时之需。NOR")
			end
		else
			self.prepareFunc("cancel")
			role:setPrepareWeapon()
			PopText("把备用武器放回背包！")
			RichPrint("main", "YEL你将NOR"..itemAttr.name.."YEL放回了背包。NOR")
		end
		self.freshFunc()
		self.backFunc()
		self:hideLayer()
	end)
end

function BagDescLayer:setRole(role)
	self.role = role
end

function BagDescLayer:initDescRichText(str)
	if self.richPrint then
        self.richPrint:removeFromParent()
        self.richPrint = nil
    end
    self.richPrint = ExtRichTextScroll:create()
    self.Panel_itemDesc.Image_back:addChild(self.richPrint)
	self.Panel_itemDesc.Image_back.TextField_desc:setVisible(false)
    local size = self.Panel_itemDesc.Image_back.TextField_desc:getContentSize()

	self.richPrint:setAnchorPoint(self.Panel_itemDesc.Image_back.TextField_desc:getAnchorPoint())
	self.richPrint:setPosition(self.Panel_itemDesc.Image_back.TextField_desc:getPosition())
    self.richPrint:setSize(size)
    self.richPrint:setScrollBarEnabled(false)
    self.richPrint:getRichText():setVerticalSpace(5)
  
	self.richPrint:pushBackText(str, cc.c3b(97, 97, 97), 255, Resource:getFontPath("default"), 42)
    self.richPrint:pushBackNewLine(0)
end

Helper:classDefNodeGetInstance(BagDescLayer)

return BagDescLayer00000