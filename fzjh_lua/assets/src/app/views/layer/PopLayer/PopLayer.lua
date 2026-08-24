-- 自定义弹出文本UI
local CustomLayer = class("CustomLayer", LayerEx)

local TOPHEIGHT = 1920

function CustomLayer:create()
	local p = CustomLayer:new()
	p:init()
	return p
end

function CustomLayer:init()
	self._UI = require("Layer/PopUI/PopUI.lua").create()['root']
	self._UI:addTo(self)

	Helper:convertUIByParent(self)

	self.panelList = {}
end

function CustomLayer:showLayer()
	self.panelList = {}

	-- 控件索引
	self.index = 1

	-- 当前高度
	self.CurrHeight = TOPHEIGHT

	self.ListView_titlelistArea:removeAllItems()
	self:show()
end

function CustomLayer:startShow()
	self:showNextPanel()
end

function CustomLayer:showNextPanel()
	-- self.ListView_titlelistArea:requestDoLayout()
	-- if true then
	-- 	return
	-- end
	print("CustomLayer:showNextPanel()")

	if self.index <= #self.panelList then
		local panelData = self.panelList[self.index]
		local panel = nil
		switch(panelData.type,
		{
			["text"] = function()
				panel = self:insertTextPanel(panelData)
			end,
			["newText"] = function()
				panel = self:insertNewTextPanel(panelData)
			end,
			["btn"] = function()
				panel = self:insertBtnPanel(panelData)
			end,
			["empty"] = function()
				panel = self:insertEmptyPanel(panelData)
			end,
			["shade"] = function()
				panel = self:insertShadePanel(panelData)
			end,
			["return"] = function()
				panel = self:insertReturnPanel(panelData)
			end,
			default = function()
				panel = self:insertTextPanel(panelData)
            end
		})

		panel:setVisible(false)

		switch(panelData.actionType,
		{
			["Fade"] = function()
				self:panelShowWithFade(panel, panelData.interval)
			end,
			["Empty"] = function()
				self:panelShowWithEmpty(panel, panelData.interval)
			end,
			default = function()
            	self:panelShowWithFade(panel, panelData.interval)
            end
		})
		self.index = self.index + 1

	end
end

function CustomLayer:panelShowWithFade(panel, interval)
	-- add by XiaoZhiWei 2017/06/16 19:31:54 当前效果不佳,以下代码放在控件克隆的方法内,效果合适
	-- add by XiaoZhiWei 2017/06/16 19:26:53 设置子节点透明度跟随父节点联动
	panel:setCascadeOpacity(0)
	--[[
		等同于
		panel:setCascadeOpacityEnabled(true)
	    panel:callAllChild(function(child)
	        child:setCascadeOpacityEnabled(true)
	    end)
		panel:setOpacity(0)
	]]
	panel:setVisible(true)

	panel:runAction(
		cc.Sequence:create(
			cc.FadeIn:create(interval),
			cc.CallFunc:create(function()
				self:showNextPanel()
			end)
		))
end

function CustomLayer:panelShowWithEmpty(panel, interval)
	panel:setVisible(true)
	panel:runAction(
		YXEaseAction:create( cc.Sequence:create(
			cc.DelayTime:create(interval),
			cc.CallFunc:create(function()
				self:showNextPanel()
			end)
		),  Sine_EaseIn ) )
end

-- cc.TEXT_ALIGNMENT_CENTER	= 0x1
-- cc.TEXT_ALIGNMENT_LEFT  	= 0x0
-- cc.TEXT_ALIGNMENT_RIGHT 	= 0x2

-- cc.VERTICAL_TEXT_ALIGNMENT_BOTTOM   	= 0x2
-- cc.VERTICAL_TEXT_ALIGNMENT_CENTER   	= 0x1
-- cc.VERTICAL_TEXT_ALIGNMENT_TOP  		= 0x0

function CustomLayer:pushBackPanelList(type, str, fontSize, vA, hA, height, actionType, interval, func)
	type 		= Helper:getDef(type, "text")
	str 		= Helper:getDef(str, "")
	fontSize 	= Helper:getDef(fontSize, 48)
	vA 			= Helper:getDef(vA, cc.VERTICAL_TEXT_ALIGNMENT_TOP)
	hA 			= Helper:getDef(hA, cc.TEXT_ALIGNMENT_LEFT)
	height 		= height
	actionType 	= Helper:getDef(actionType, "Empty")
	interval 	= Helper:getDef(interval, 2)
	func 		= Helper:getDef(func, function()
						self:hide(function()
							self:removeFromParent(true)
						end)
					end)

	table.insert(self.panelList,
	{
		type = type,
		str = str,
		fontSize = fontSize,
		vA = vA,
		hA = hA,
		height = height,
		actionType = actionType,
		interval = interval,
		func = func,
	})

end

-----------------------------------------------------------------------------------------------------------
-- @author ZhangShengTang
-- @time 2017/06/16 14:30:54
-- @desc  插入文本Panel 自定义大小
function CustomLayer:insertTextPanel(data)
	local panel = self.Panel_Text:clone()
	Helper:convertUIByParent(panel)

	panel.Text:setString(data.str)
	panel.Text:setFontSize(data.fontSize)
	panel.Text:setTextVerticalAlignment(data.vA)
	panel.Text:setTextHorizontalAlignment(data.hA)
	panel.Text:enableOutline({r = 17, g = 17, b = 17, a = 255}, 5)

	local height = 0
	if data.height == nil then
		local hang = math.ceil(panel.Text:getAutoRenderSize().width / 864)
		height = hang * panel.Text:getAutoRenderSize().height
	else
		height = data.height
	end

	panel:setSize(1080, height)
	panel.Text:setSize(864, height)
	panel.Text:setPosition(540.0000, height / 2)


	if self.CurrHeight - height < 0 then
		self.PanelParent:removeAllChildren()
		self.CurrHeight = TOPHEIGHT
	end

	self.PanelParent:addChild(panel)
	panel:setPosition(540, self.CurrHeight)
	self.CurrHeight = self.CurrHeight - height

	return panel
end

function CustomLayer:insertNewTextPanel(data)
	local panel = self.Panel_Text:clone()
	Helper:convertUIByParent(panel)

	panel.Text:setString(data.str)
	panel.Text:setFontSize(data.fontSize)
	panel.Text:setTextVerticalAlignment(data.vA)
	panel.Text:setTextHorizontalAlignment(data.hA)
	panel.Text:enableOutline({r = 17, g = 17, b = 17, a = 255}, 5)

	local height = 0
	if data.height == nil then
		local hang = math.ceil(panel.Text:getAutoRenderSize().width / 864)+1  --多一行为空行换行
		height = hang * panel.Text:getAutoRenderSize().height
	else
		height = data.height
	end

	panel:setSize(1080, height)
	panel.Text:setSize(864, height)
	panel.Text:setPosition(540.0000, height / 2)


	if self.CurrHeight - height-100 < 0 then
		self.PanelParent:removeAllChildren()
		self.CurrHeight = TOPHEIGHT-100
	end

	self.PanelParent:addChild(panel)
	panel:setPosition(540, self.CurrHeight)
	self.CurrHeight = self.CurrHeight - height

	return panel
end


-----------------------------------------------------------------------------------------------------------
-- @author ZhangShengTang
-- @time 2017/06/16 14:31:09
-- @desc 插入按钮Panel
function CustomLayer:insertBtnPanel(data)
	local height = data.height
	local panel = self.Panel_Button:clone()
	Helper:convertUIByParent(panel)

	panel.Button.Text:setString(data.str)
	panel.Button.Text:enableOutline({r = 17, g = 17, b = 17, a = 255}, 5)
	panel:setSize(1080, height)

	panel.Button:releaseFunc(function()
		data.func()
	end)

	if self.CurrHeight - height < 0 then
		self.PanelParent:removeAllChildren()
		self.CurrHeight = TOPHEIGHT
	end

	self.PanelParent:addChild(panel)
	panel:setPosition(540, self.CurrHeight)
	self.CurrHeight = self.CurrHeight - height

	return panel
end

-----------------------------------------------------------------------------------------------------------
-- @author ZhangShengTang
-- @time 2017/06/16 14:31:28
-- @desc 插入空的Panel
function CustomLayer:insertEmptyPanel(data)
	local height = data.height
	local panel = self.Panel_Empty:clone()
	Helper:convertUIByParent(panel)

	panel:setSize(1080, height)

	if self.CurrHeight - height < 0 then
		self.PanelParent:removeAllChildren()
		self.CurrHeight = TOPHEIGHT
	end

	self.PanelParent:addChild(panel)
	panel:setPosition(540, self.CurrHeight)
	self.CurrHeight = self.CurrHeight - height

	return panel
end

-----------------------------------------------------------------------------------------------------------
-- @author ZhangShengTang
-- @time 2017/06/19 15:48:50
-- @desc 插入shade Panel
function CustomLayer:insertShadePanel(data)
	local height = data.height
	local panel = self.Panel_Empty:clone()
	Helper:convertUIByParent(panel)

	panel:setSize(1080, height)

	self.PanelParent:addChild(panel)
	panel:setPosition(540, height)

	return panel
end

-----------------------------------------------------------------------------------------------------------
-- @author ZhangShengTang
-- @time 2017/06/17 12:15:29
-- @desc 插入点击全透明界面
function CustomLayer:insertReturnPanel(data)
	local panel = self.PanelParent_clone:clone()

	self:addChild(panel)
	panel:setPosition(540, 960)

	panel:releaseFunc(function()
		data.func()
		self:hide(function()
			self:removeFromParent(true)
		end)
	end)

	return panel
end

Helper:classDefNodeGetInstance(CustomLayer)

return CustomLayer000