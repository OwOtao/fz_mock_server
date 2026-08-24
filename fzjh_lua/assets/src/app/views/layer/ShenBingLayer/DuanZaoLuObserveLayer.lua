
local Item = require("app.models.item.Item")
local Resource = require("app.Resource")

local  DuanZaoLuObserveLayer = class("DuanZaoLuObserveLayer",cc.Layer)
local ShenBingDuanZao = require("app.models.ShenBing.DuanZao.ShenBingDuanZao")
function DuanZaoLuObserveLayer:create()
	local p = DuanZaoLuObserveLayer:new()
	p:init()
	return p
end

function DuanZaoLuObserveLayer:init()
	self._UI = require("Layer/ShenBing/DuanZaoLuObserveUI.lua").create()['root']
	self._UI:addTo(self)
	Helper:convertUI(self)


	self.Text_Equip:setVisible(false)

	--点击背景打造界面隐藏
	self.Panel_back:releaseFunc(function (ref,eventType)
		PopupLayerController:hideLayer("DuanZaoLuObserveLayer", function(layer)
			self:hide()
		end)
	end)

	self:show()

	self:ButtonJiaGong()

	self._talk = 1

	self:initRichText()	
	self:print("这是一个巨大的锻造炉，旁边放置了诸多打造用具，应有尽有，可以用来锻造，修理，淬炼兵器")
end
function DuanZaoLuObserveLayer:show(ControllLayer)
	-- MainControllLayer = ControllLayer
	self:setVisible(true)
	self:ButtonTalk()
	self:ButtonXiuLi()
	self:ButtonCuiLian()
	self:ButtonXiuLi()
	self:ButtonJiYi()
end

function DuanZaoLuObserveLayer:initRichText()
	local x, y = self.Panel_Desc:getPosition()
	local size = self.Panel_Desc:getContentSize()
	
	if self.RichText_print then
		self.RichText_print:removeFromParent()
		self.RichText_print = nil
	end

	local richTextScroll = ExtRichTextScroll:create()
   	self.Panel_Desc:getParent():addChild(richTextScroll)
   	richTextScroll:move(cc.p(90,730))
   	richTextScroll:setSize(size)   	
   	richTextScroll:setDirection(kCCScrollViewDirectionVertical)
   	richTextScroll:getRichText():setVerticalSpace(5)
   	self.RichText_print = richTextScroll

   	self.RichText_print:setBounceEnabled(false)

   	-- self.RichText_print:setVerticalSpace(-5)

	-- self:print("HIY【HIB江HIM湖HIC通HIW告RAN】:RED欢GRN迎YEL来BLU到MAG天CYN下WHT第HIR一HIG.")
	-- self:print("测试")
end
local textColor = cc.c3b(159,159,159)
function DuanZaoLuObserveLayer:print(str, verticalSpace)
	local textHeight = self.RichText_print:getRichText():getNewContentSizeHeight()
	if textHeight >= 400 then
		self:initRichText()
	end

	self.RichText_print:pushBackText(str, textColor, 255, Resource:getFontPath("default"), 42)

	if verticalSpace ~= nil and type(verticalSpace) == "number" then
		self.RichText_print:pushBackNewLine(verticalSpace)
	else
		self.RichText_print:pushBackNewLine()
	end
end


--能锻造的条件
function DuanZaoLuObserveLayer:canDuanzao()
	--判断是否能打造的  还要判断是有物品
	local role = User:getRole()
	if not User:getRole():getFlag("神兵") == "Y"  then
		return false
	end
	local tie102,tie103,tie104 = role:getItemsWithItemId("tie102"),role:getItemsWithItemId("tie103"),role:getItemsWithItemId("tie104")
	if not MapIsEmpty(tie102) then
		role.shenBingweapon.material = "tie102"
		if PRINT_MODE ==1 then
			print("******************************************************************")
			-- Helper:print_lua_table(tie102[1])
		end
		return tie102[1]
	end
	if not MapIsEmpty(tie103) then
		role.shenBingweapon.material = "tie103"
		if PRINT_MODE ==1 then
			Helper:print_lua_table(tie103[1])
		end		
		return tie103[1]
	end
	if not MapIsEmpty(tie104) then
		role.shenBingweapon.material = "tie104"
		if PRINT_MODE ==1 then
			Helper:print_lua_table(tie103[1])
		end		
		return tie104[1]
	end
	return false
end

-- 身上神兵界面控制隐藏 当前装备界面
function DuanZaoLuObserveLayer:isShow()
	local shenBingLayer = MainControllLayer:getLayer("ShenBingLayer")
	if shenBingLayer.Panel_DuanZao:isVisible() then
		shenBingLayer.Panel_DuanZaoZhong:setVisible(false)
		shenBingLayer.Text_desc:setVisible(false)
		shenBingLayer.Button_1:setVisible(false)
	else
		shenBingLayer.Text_desc:setVisible(true)
		shenBingLayer.Panel_DuanZaoZhong:setVisible(true)
		shenBingLayer.Button_1:setVisible(true)
	end
    
    -- 如果装备了神兵显示 shenBingLayer.Panel_DuanZaoZhong 可以查看神兵详情
end

--已学技艺
function DuanZaoLuObserveLayer:ButtonJiYi()	
	self.Button_JiYi:setButtonType(WIDGET_TOUCH_VOICE_TYPE_SMALLBUTTON)
	self.Button_JiYi:releaseFunc(function()
		MainControllLayer:pushLayer("ShenBingSkilledLayer")
		local ShenBingSkilledLayer = MainControllLayer:getLayer("ShenBingSkilledLayer")
		ShenBingSkilledLayer:show()
		PopupLayerController:hideLayer("DuanZaoLuObserveLayer", function(layer)
			self:hide()
		end)	
	end)
end


---锻造
function DuanZaoLuObserveLayer:ButtonTalk()
	self.Button_Talk:setButtonType(WIDGET_TOUCH_VOICE_TYPE_SMALLBUTTON)
	self.Button_Talk:releaseFunc(function()
		MainControllLayer:pushLayer("FurnaceLayer")
		local FurnaceLayer = MainControllLayer:getLayer("FurnaceLayer")
		FurnaceLayer:entryLayer()
		PopupLayerController:hideLayer("DuanZaoLuObserveLayer", function(layer)
			self:hide()
		end)	
	end)
end


--神兵改名
function DuanZaoLuObserveLayer:ButtonJiaGong()
	self.Button_JiaGong:setButtonType(WIDGET_TOUCH_VOICE_TYPE_SMALLBUTTON)
	self.Button_JiaGong:releaseFunc(function()
		local role = User:getRole()
		local items = role:getItems(function(item)
			if item.type == "神兵" then
				return true
			else
				return false
			end
		end)
		if MapIsEmpty(items) == true then
			PopText("背包中没有神兵")
		else
			local weapon = role:getDefaultShenBing()
			if weapon == nil then
				PopText("您还没有装上默认神兵，无法进行操作")
				return
			end

			PopupLayerController:showLayer("ShenBingNameLayer",function(layer)
				layer:showLayer(2,weapon,function(rweapen)
					ShenBingDuanZao:updateShenBingInfo(rweapen)
				end)
			end)
		end
		PopupLayerController:hideLayer("DuanZaoLuObserveLayer", function(layer)
			layer:hide()
		end)
	end)
end
--修理
function DuanZaoLuObserveLayer:ButtonXiuLi()
	self.Button_XiuLi:setButtonType(WIDGET_TOUCH_VOICE_TYPE_SMALLBUTTON)
	self.Button_XiuLi:releaseFunc(function()

		require("app.views.layer.ShenBingLayer.FixLayer.ShenBingFixLayer"):showLayer(1)
		PopupLayerController:hideLayer("DuanZaoLuObserveLayer", function(layer)
			self:hide()
		end)
	end)
end


-- 融兵
function DuanZaoLuObserveLayer:ButtonCuiLian()
	self.Button_CuiLian:setButtonType(WIDGET_TOUCH_VOICE_TYPE_SMALLBUTTON)
	self.Button_CuiLian:releaseFunc(function()
		local rongBing = require("app.views.layer.ShenBingLayer.RongBingLayer.RongBingLayer")
		rongBing:setBackFunc(function()
		end)
		rongBing:showLayer()

		PopupLayerController:hideLayer("DuanZaoLuObserveLayer", function(layer)
			layer:hide()
		end)
	end)
end
function DuanZaoLuObserveLayer:hideShenBing()
	self.Button_CuiLian:setButtonType(WIDGET_TOUCH_VOICE_TYPE_SMALLBUTTON)
	self.Button_CuiLian:releaseFunc(function()	
		PopupLayerController:hideLayer("DuanZaoLuObserveLayer", function(layer)
			layer:hide()
		end)
	end)	
end

Helper:classDefNodeGetInstance(DuanZaoLuObserveLayer)
return  DuanZaoLuObserveLayer0000000000000