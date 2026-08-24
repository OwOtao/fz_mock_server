
local DialogELayer = require("app.views.layer.DialogLayer.DialogELayer")

local ShenBingInfo = class("ShenBingInfo", cc.Layer)

function ShenBingInfo:create()
	local p = ShenBingInfo:new()
	p:init()
	return p
end

function ShenBingInfo:init()
	self._UI = require("Layer/ShenBing/ShenBingInfo.lua").create()['root']
	self._UI:addTo(self)
	Helper:convertUI(self)
	
	--点击背景打造界面隐藏
	self.Panel_back:releaseFunc(function (ref,eventType)
		PopupLayerController:hideLayer("ShenBingInfo", function(layer)
			self:hide()
		end)
	end)
	self.Text_desc:setVisible(false)
	self:show()
	self:setButton()
end
function ShenBingInfo:show(ControllLayer)
	-- MainControllLayer = ControllLayer
	self:setVisible(true)
end

function ShenBingInfo:initRichText()
    if self.RichText_print then
        self.RichText_print:removeFromParent()
    end

    local x, y = self.Text_desc:getPosition()
    local size = self.Text_desc:getContentSize()

    self.RichText_print = ExtRichTextScroll:create()

    self.Text_desc:getParent():addChild(self.RichText_print)
    self.RichText_print:setAnchorPoint(cc.p(0, 1))
    self.RichText_print:move(cc.p(x, y))
    self.RichText_print:setSize(size)
    self.RichText_print:setDirection(kCCScrollViewDirectionVertical)
    self.RichText_print:getRichText():setVerticalSpace(10)
    self.RichText_print:setBounceEnabled(false)
end

function ShenBingInfo:showShenBingDesc(str,color)
    self:initRichText()
    color = color or cc.c3b(127, 127, 127)
    self.RichText_print:pushBackText(str, color, 255, Resource:getFontPath("default"),48)
    self:delayFunc(0.1,function ()
		self.RichText_print:jumpToTop()
	end)
end

-- 设置神兵所有详情
function ShenBingInfo:setShenBingInfo(item, isBreakage)
	if not item then
		return
	end

	--当前武器是否破损
	self._isBreakage = isBreakage
	
	if item.wuzang ~= nil then
		self.Text_OuYeZi_title:setVisible(true)
		self.Text_title:setVisible(true)
		local wuzang = item.wuzang == -0 and 0 or item.wuzang
		self.Text_title:setString(wuzang)
	else
		self.Text_OuYeZi_title:setVisible(false)
		self.Text_title:setVisible(false)
	end

	self.Text_Equip_Name:setColor(cc.c3b(208, 208, 208))

	if item.equipPart ~= "weapon" then
		self.Panel_8:setVisible(true)
		
        self.Text_Equip_Atk:setString("保护力+"..tostring(item.protect))
		
		self:showShenBingDesc(Helper:getDef(item.dsc,""))

		self.Text_Equip_Name:setString(Helper:getDef(item.name,""))
	else
		self.Panel_8:setVisible(false)
		self:initPanelHelp(item)
		local name,str,weight,rendu,yindu,other,baseeffect

		weight = ShenBingDesc:getWeightDesc(item)--重量 文本list
		yindu = ShenBingDesc:getYingDuDesc(item) --硬度
		if yindu == nil then
			yindu = "无"
		else
			yindu = yindu.hard1dsc
		end

		rendu = ShenBingDesc:getRenDuDesc(item).Tenacity1dsc--坚韧度
		if item.wpType == "神兵" then
			name = item.nameColor..item.name
			str = ShenBingDesc:getShenBingDesc(item,true) --描述
			
			other =	"无"
			local effect2 = ShenBingDesc:getEffctTwo(item)
			if effect2 ~= nil then
				other = effect2.name 
				local effect3 = ShenBingDesc:getEffctThree(item)
				if effect3 ~= nil then
					other = other .."、"..effect3.name
				end
			end
			baseeffect = ShenBingDesc:getEffctOne(item).name
		else
			name = item.name
			str = item.dsc
			other = "无"
			yindu = Helper:getDef(yindu,"无")
			baseeffect = "无"
		end

		local wanhao
		local wanhaodu = Helper:getDef(item.wanhaodu,100)
		if self._isBreakage then
			wanhaodu = 0
		end
		
		if wanhaodu >= 80 and  wanhaodu < 100 then
			wanhao ="略有瑕疵"
		elseif wanhaodu == 100 then
			wanhao ="完美无缺"
		elseif wanhaodu < 80 and wanhaodu >= 40 then
			wanhao ="残缺不全"
		elseif wanhaodu < 40 then
			wanhao ="支离破碎"
		else
			wanhao ="巧夺天工"
		end

		self.Text_Info4:setString( Helper:getDef(weight.weight1level,""))

		self.Text_Equip_Atk:setString("伤害值+"..Helper:getDef(Helper:mathFloor(item:getWeaponDamage()),0))
		
		self:showShenBingDesc(Helper:getDef(str,""))
		
		self.Text_Info1:setString(Helper:getDef(yindu,""))

		self.Text_Info2:setString(Helper:getDef(rendu,""))

		self.Text_Info3:setString(Helper:getDef(wanhao,""))

		self.Text_Info5:setString(baseeffect)

		self.Text_Info6:setString(other)

		self.Text_Equip_Name:setString(Helper:getDef(name,""))
	end
end

function ShenBingInfo:setButton()
	self.Button_YiShi:releaseFunc(function()
		self:hide()
	end)
end

function ShenBingInfo:setPanelClick(panelName, str,dsc,value)
	local panel = self[panelName]
	if not panel then
		return
	end
	Helper:convertUIByParent(panel)
	local tipPanel = self.Panel_desc
	Helper:convertUIByParent(tipPanel)
	local dialog = DialogELayer:getInstance()
	panel:addTouchEventListener(
		
		function(ref, eventType)
		
	    	if eventType == ccui.TouchEventType.began then
	    		panel.Image_8:setVisible(false)
	        elseif eventType == ccui.TouchEventType.ended then
				-- 弹出窗口 结合已有详细描述
				tipPanel:setVisible(true)
				tipPanel.Image_desc.Text_desc1:setString(str)
				tipPanel.Image_desc.Text_desc2:setString(dsc)
				tipPanel.Image_desc.Text_Val:setString(value)
				tipPanel:releaseFunc(function()
					tipPanel:setVisible(false)
					panel.Image_8:setVisible(true)
				end)

				-- local desc = clone(str) .. "\n"..dsc --  + 现有描述(暂未定获取方式)
				-- dialog:show(desc)
	   --  		dialog:setPanelBack(function()
	   --  			panel.Image_8:setVisible(true)
	   --  		end)
			elseif eventType == ccui.TouchEventType.canceled then
	    		panel.Image_8:setVisible(true)
	        end
	    end)

end

function ShenBingInfo:initPanelHelp(itemAttr)
	local list =
	{
		{
			name = "Panel_1",
			str = "硬度：一把武器的硬度决定了它击碎他人的武器的难易程度。",
			dsc = function()
				local yindu = ShenBingDesc:getYingDuDesc(itemAttr) --硬度
				if yindu ~= nil then
					return Helper:getDef(yindu.hard1text,"")
				else
					return ""
				end
			end,
			value = function()
				return "硬度值:"..Helper:mathFloor(itemAttr:getWeaponYingDu(User:getRole()))
			end,
		},
		{
			name = "Panel_2",
			str = "坚韧度：一把武器的坚韧度决定了它被他人武器击碎的难易程度。",
			dsc = function()
				local list = ShenBingDesc:getRenDuDesc(itemAttr)
				if list ~= nil then
					return Helper:getDef(list.Tenacity1text,"")
				else
					return ""
				end
			end,
			value = function()
				return "坚韧值:"..Helper:mathFloor(itemAttr:getWeaponRenDu(User:getRole()))
			end,
		},
		{
			name = "Panel_4",
			str = "重量值：一把武器的重量值不仅决定了它是否容易被人击飞与击飞他人武器的难易程度，同时它也会影响攻击速度。",
			dsc = function()
				local list = ShenBingDesc:getWeightDesc(itemAttr)
				if list ~= nil then
					return Helper:getDef(list.weight1text,"")
				else
					return ""
				end
			end,
			value = function()
				return "重量值:"..Helper:mathFloor(itemAttr:getWeaponWeight(User:getRole()))
			end,
		},
		{
			name = "Panel_3",
			str = itemAttr.wpType == "神兵" and "状态：一把武器状态决定它的伤害力，未达完美状态的武器可经修理达到完美状态。" or "普通武器的状态主要描述武器的外观情况",
			dsc = function()
				local str,text
				if itemAttr.wpType == "神兵" then
					str,text = ShenBingDesc:getShenBingStatusDesc(itemAttr)
				else
					local wanhaodu = Helper:getDef(itemAttr.wanhaodu,100)
					if self._isBreakage then
						wanhaodu = 0
					end

					str,text = ShenBingDesc:getShenBingStatusDesc({wanhaodu = wanhaodu})
				end
				return string.gsub(text,str,"当前状态", 1)
			end,
			value = function()
				local maxWanHaodu = itemAttr.wanhaodu
				if itemAttr.wpType == "神兵" then
					maxWanHaodu = 100
				end

				local wanhaodu = Helper:getDef(itemAttr.wanhaodu,100)
				if self._isBreakage then
					wanhaodu = 0
				end

				return "完好度:"..Helper:mathFloor(wanhaodu) .. "/" .. Helper:mathFloor(maxWanHaodu)
			end,
		},
		{
			name = "Panel_5",
			str = "基础特性：武器初始便具备的特点，可以给武器带来各种各样的加成效果。",
			dsc = function()
				local effect = ShenBingDesc:getEffctOne(itemAttr)
				if effect == nil then
					return ""
				else
					return effect.specialdsc
				end
			end,
			value = function()
				return "特性值:"..Helper:mathFloor(itemAttr:getWeaponEffectNum(User:getRole()))
			end,
		},
	
		{
			name = "Panel_6",
			str = "附加特性：武器后续可改造的效果，可以给武器带来各种各样的加成效果。",
			dsc = function()
				local effect2,effect3 = ShenBingDesc:getEffctTwo(itemAttr),ShenBingDesc:getEffctThree(itemAttr)
				local desc = ""
				if effect2 == nil then
					desc =  ""
				else
					desc = effect2.specialdsc
				end
				if effect3 == nil then
				else
					desc = desc.."\n"..effect3.specialdsc
				end
				return desc
			end,
			value = function()
				return "特性值:"..Helper:mathFloor(itemAttr:getWeaponEffectNum(User:getRole()))
			end,
		},
	}

	for i,v in ipairs(list) do
		self:setPanelClick(v.name, v.str,v.dsc(),v.value())
	end
end


Helper:classDefNodeGetInstance(ShenBingInfo)
return ShenBingInfo
0000