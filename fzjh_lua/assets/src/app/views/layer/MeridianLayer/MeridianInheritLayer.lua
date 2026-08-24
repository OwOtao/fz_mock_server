-- 经脉传承
local MeridianInheritLayer = class("MeridianInheritLayer", LayerEx)

local Meridian = require("app.models.Meridian.Meridian")
local Inherit = require("app.models.inherit.Inherit")

local TitleTable =
{
	{name = "已拥有",	type = "own", 	list = nil},
}

function MeridianInheritLayer:create()
	local p = MeridianInheritLayer:new()
	p:init()
	return p
end

function MeridianInheritLayer:init()
	self._UI = require("Layer/MeridianUI/MeridianInheritUI.lua").create()['root']
	self._UI:addTo(self)

	self._titleVector = {}

	self.imprintingList = {}

	self.selectImprinting = {}

	self.currPageIndex = 1

	self.selectPanelDrak = nil

	self._isChongZhu = nil --是否是经脉重筑

	self._ChongZhuData = {} --重筑相关数据

	Helper:convertUIByParent(self)

	self.Panel_bg:releaseFunc(function()
		self.Panel_bg:setVisible(false)
		self:imprintingDescHide()

		if self.selectPanelDrak ~= nil then
			self.selectPanelDrak:setVisible(false)
		end
	end)

	self:setVisible(false)

	self:initImprinting()
	self:initTabView(TitleTable)
	self:setTitleImageShow()
end

-- 初始化已选择经脉界面
function MeridianInheritLayer:initAlreadyUI()
	self.ListView_yinji:removeAllItems()

	local role = User:getRole()
	local inherit = role:getAttr("inherit")
	local name = inherit.name

	local text1 = self.Text_desc:clone()
	local text2 = self.Text_desc1:clone()

	if self._isChongZhu == true then
		self.Panel_category.Text_Title:setString("经脉重筑")
		text1:setString("你小心翼翼地导引着真气逆行，当你觉得几乎要脱力时，一种返璞归真、如封似闭的感觉入体，不禁心中大喜：看来重筑有望！")
		text2:setString("本次经脉重筑，你可以保留" .. self:getCanSelectCount() .. "条经脉天赋。\n你打算留下：")
	else
		self.Panel_category.Text_Title:setString("经脉传承")
		text1:setString("你心有所感，打算将真气注入 " .. name .. " 的体内，为其留下最后的馈赠。虽然将来 " .. name .. " 还要自修行，但起码也比同龄人先行一步、起点更高了吧。")
		text2:setString("本次传承，作为继承人可以保留" .. self:getCanSelectCount() .. "条经脉天赋。\n你打算留下：")
	end
	text1:enableOutline({r = 17, g = 18, b = 18, a = 255}, 5)
	text2:enableOutline({r = 17, g = 18, b = 18, a = 255}, 5)

	self.ListView_yinji:pushBackCustomItem(text1)
	self.ListView_yinji:pushBackCustomItem(text2)

	local function createPanel(index, imprintingData)
		local panel = self.Panel_imprinting_0:clone()
		Helper:convertUIByParent(panel)
		self.ListView_yinji:pushBackCustomItem(panel)

		panel.Panel_name.Text_name:setString(imprintingData.name)

		panel.Panel_name.Text_name:enableOutline({r = 17, g = 18, b = 18, a = 255}, 5)
		panel.Text_canel:enableOutline({r = 17, g = 18, b = 18, a = 255}, 5)

		panel:releaseFunc(function()
			table.remove(self.selectImprinting, index)
			self:initAlreadyUI()
			self:initListItem()
		end)
		return panel
	end

	for i,v in ipairs(self.selectImprinting) do
		createPanel(i, v)
	end
end

-- 初始化印记
function MeridianInheritLayer:initImprinting()
	local role = User:getRole()

	local meridian = role:getAttr("meridian")
	local meridianImprinting = role:getAttr("meridianImprinting")

	-- 已拥有的经脉印记
	local OwnList = {}
	TitleTable[1].list = OwnList

	-- 获得印记 排除左右互搏
	for i,v in ipairs(meridianImprinting) do
		if v.imprintingId ~= nil and v.imprintingId ~= "zuoyouhuboyin" then
			table.insert(OwnList, Meridian:getImprintingId(v.imprintingId))
		end
	end
end

-- 初始化标签页
function MeridianInheritLayer:initTabView(titleTable)
	local outlineWidth = 5
	local textColor = cc.c3b(234,234, 234)
	local outlineColor = cc.c4b(44, 51, 54, 255)
	local tag = 999
	for k,table in pairs(titleTable) do
		local panel = self.Panel_back_title:clone()
		Helper:convertUIByParent(panel)
		panel:setTag(tag)
		panel.Text_title:setString(table.name)
		panel.Text_title:setColor(textColor)
		panel.Text_title:enableOutline(outlineColor, outlineWidth)
		panel.Image_back:setVisible(false)

		self.Image_tab.ListView_tab:pushBackCustomItem(panel)
		panel:releaseFunc(function()
			self.currPageIndex = k
			self:initListItem(TitleTable[k].list)
			self:setTitleImageShow(panel)
		end)
		self._titleVector[#self._titleVector + 1 ] = panel
		tag = tag + 1
	end
end

-- 高亮选择标题
function MeridianInheritLayer:setTitleImageShow(panel)
	if panel then
		local tag = panel:getTag()
		if not MapIsEmpty(self._titleVector) and tag then
			for i,v in ipairs(self._titleVector) do
				if v:getTag() and v:getTag()  == tag then
					v.Image_back:setVisible(true)
				else
					v.Image_back:setVisible(false)
				end
			end
		end
	else
		if not MapIsEmpty(self._titleVector) then
			for i,v in ipairs(self._titleVector) do
				if i == 1 then
					self._titleVector[i].Image_back:setVisible(true)
				else
					self._titleVector[i].Image_back:setVisible(false)
				end
			end
		end
	end
end

-- 初始化列表
function MeridianInheritLayer:initListItem(imprintingList)
	if imprintingList == nil then
		imprintingList = self.currPageIndex
	end

	if type(imprintingList) == "number" then
		imprintingList = TitleTable[imprintingList].list
	end

	self.selectPanelDrak = nil
	self.Panel_bg:setVisible(false)
	self.Panel_itemDesc:setVisible(false)

	if MapIsEmpty(imprintingList) then
		self.ListView_titlelistArea:setVisible(false)
		return
	else
		self.ListView_titlelistArea:setVisible(true)
	end

	local index = 0
	for i,v in ipairs(imprintingList) do

		local flag = true
		for index,selectImprinting in ipairs(self.selectImprinting) do
			if selectImprinting.imprintingId == v.imprintingId then
				flag = false
				break
			end
		end

		if flag == true then
			self:createPanel(index, v)
			index = index + 1
		end
	end

	-- 移除多余的panel
	for i = index + 1,#self.ListView_titlelistArea:getItems() do
		self.ListView_titlelistArea:removeLastItem()
	end
end

function MeridianInheritLayer:createPanel(index, imprintingData)
	local listItems = self.ListView_titlelistArea:getItems()
	local panel
	if #listItems > index then
		panel = self.ListView_titlelistArea:getItem(index)
	else
		panel = self.Panel_imprinting:clone()
		Helper:convertUIByParent(panel)
		self.ListView_titlelistArea:pushBackCustomItem(panel)
	end

	panel.Panel_name.Text_name:setString(imprintingData.name)
	panel.Text_type:setString(imprintingData.type)

	if imprintingData.type == "战斗类" then
		panel.Text_type:setColor({r = 219, g = 57, b = 57, a = 255})
	else
		panel.Text_type:setColor({r = 102, g = 153, b = 153, a = 255})
	end

	panel.Panel_name.Text_name:enableOutline({r = 17, g = 18, b = 18, a = 255}, 5)
	panel.Text_type:enableOutline({r = 17, g = 18, b = 18, a = 255}, 5)

	panel.Image_dark:setVisible(false)

	panel:releaseFunc(function()
		if self.selectPanelDrak ~= nil then
			self.selectPanelDrak:setVisible(false)
		end
		self.selectPanelDrak = panel.Image_dark:setVisible(true)
		self:setImprintingDesc(imprintingData)
		self:imprintingDescShow()
	end)
end

-- 印记描述设置
function MeridianInheritLayer:setImprintingDesc(imprintingData)
	local titlePanel = self.Panel_itemDesc.Image_back.Panel_title
	titlePanel.Text_name:setString(imprintingData.name)
	titlePanel.Text_zhuangbei:setString(imprintingData.type)

	if imprintingData.type == "战斗类" then
		titlePanel.Text_zhuangbei:setColor({r = 219, g = 57, b = 57, a = 255})
	else
		titlePanel.Text_zhuangbei:setColor({r = 102, g = 153, b = 153, a = 255})
	end

	self.Panel_itemDesc.Image_back.TextField_desc:setString(imprintingData.text)
	self.Panel_itemDesc.Image_back.Image_button.Text_chuan:setString("选\n择")
	self.Panel_itemDesc.Image_back.Image_button:releaseFunc(function()
		local role = User:getRole()

		if self:getCanSelectCount() <= self:getSelectCount() then
			PopText("最多只能保留" .. self:getCanSelectCount() .. "条经脉天赋")
		else
			table.insert(self.selectImprinting, imprintingData)
		end

		self.Panel_bg:setVisible(false)
		self:imprintingDescHide()

		if self.selectPanelDrak ~= nil then
			self.selectPanelDrak:setVisible(false)
		end

		self:initAlreadyUI()
		self:initListItem()
	end)

end

-- 印记描述显示
function MeridianInheritLayer:imprintingDescShow()
	self.Panel_itemDesc:setTouchEnabled(true)
	self.Is_show = true
	local Panel_itemDesc = self.Panel_itemDesc
	self.Panel_bg:setVisible(true)
	Panel_itemDesc:setVisible(true)
	local actionTag = Panel_itemDesc:getActionTagByName("move")
	Panel_itemDesc:stopActionByTag(actionTag)
	Panel_itemDesc:move(cc.p(300, 1880.00))
	local action = cc.Sequence:create(
		cc.Spawn:create(
			cc.MoveTo:create(UI_ANIM_DURATION, cc.p(300, 1680.00)),
			cc.FadeIn:create(UI_ANIM_DURATION)
		),
		cc.CallFunc:create(
			function()
			end))
	action:setTag(actionTag)
	Panel_itemDesc:runAction(action)
end

-- 物品描述隐藏
function MeridianInheritLayer:imprintingDescHide()
	self.Panel_itemDesc:setTouchEnabled(false)
	self.Panel_bg:setVisible(true)
	self.Is_show = true
	local Panel_itemDesc = self.Panel_itemDesc
	self.Panel_bg:setVisible(true)
	Panel_itemDesc:setVisible(true)
	local actionTag = Panel_itemDesc:getActionTagByName("move")
	Panel_itemDesc:stopActionByTag(actionTag)
	Panel_itemDesc:move(cc.p(300, 1680))
	local action = cc.Sequence:create(
		cc.Spawn:create(
			cc.MoveTo:create(UI_ANIM_DURATION, cc.p(300.00, 1880.00)),
			cc.FadeOut:create(UI_ANIM_DURATION)
		),
		cc.CallFunc:create(
			function()
				self.Panel_itemDesc:setVisible(false)
				self.Panel_bg:setVisible(false)
				self.Is_show = false
			end))
	action:setTag(actionTag)
	Panel_itemDesc:runAction(action)
end

-- 显示界面
function MeridianInheritLayer:showLayer(isChongZhu,ChongZhuData)
	self._isChongZhu = isChongZhu
	self._ChongZhuData = ChongZhuData
	local role = User:getRole()
	local meridianImprinting = User:getRoleAttr("meridianImprinting")

	if self._isChongZhu == true then
	else
		if role:isHaveImprintingId("zuoyouhuboyin") == true then
			if #meridianImprinting - 1 <= self:getCanSelectCount() then
				Inherit:doInherit(meridianImprinting)
				return
			end
		else
			if #meridianImprinting <= self:getCanSelectCount() then
				Inherit:doInherit(meridianImprinting)
				return
			end
		end
	end
	

	self:initListItem()
	self:initAlreadyUI()

	self:setButton()
	self:show()
end

function MeridianInheritLayer:setButton()
	self.Panel_category.Button_return:releaseFunc(function()
		PopupLayerController:hideLayer("MeridianInheritLayer", function(layer)
			self:hide()
		end, 0)
	end)
	if self._isChongZhu == true then 
		self.Button_inherit.Text_buttonName:setString("确定重筑")
		self.Button_inherit:releaseFunc(function()
			if self:getSelectCount() == self:getCanSelectCount() then
				local meridianImprinting = {}
				for i,v in ipairs(self.selectImprinting) do
					table.insert(meridianImprinting, {imprintingId = v.imprintingId})
				end
				local role = User:getRole()
				if role:isHaveImprintingId("zuoyouhuboyin") then
					table.insert(meridianImprinting, {imprintingId = "zuoyouhuboyin"})
				end

				HttpManagerEx:submitAction("JingMaiChongZhu",1,function(status, errcode, errmsg, data)
					if status == 200 then
						if errcode == 0 then
							role:setAttr("meridianImprinting", meridianImprinting)
							role:setAttr("meridianExp",0)
							role:setFlag("冲穴真气", 0)
							local meridian =
								{
									meridianCount = 0,
									acupointCount = 0,
									acupointState = 1,
									alreadyDisease = 0,
									alreadyDisorder = 0,
									attrList = {},
									attrTotal =
									{
										["qiMax"] = 0, 			-- 气血上限
										["neiLiLimit"] = 0,		-- 内力上限
										["atk"] = 0,			-- 攻击力
										["dodge"] = 0,			-- 闪躲力
										["def"] = 0,			-- 防御力
										["damage"] = 0,			-- 伤害力
										["protect"] = 0,		-- 防护力
									},
								}
								
							role:setAttr("meridian", meridian)
							
							PopupLayerController:showLayer(
								"TextAnimLayer",
								function(layer)
									layer:setAfterAnimCallback(
										function()
											PopupLayerController:hideLayer("MeridianInheritLayer", function(layer)
												self:hide()
											end, 0)
											local MeridianBreakLayer = MainControllLayer:getLayer("MeridianBreakLayer")
											MeridianBreakLayer:createAcupointList(1)
											MeridianBreakLayer:showAttrData()
										end
									)
									layer:setHideCallbackFunc(
										function()
											if tonumber(data.remove) ~= 0 then
												PopText("消耗元宝 X"..data.remove)
											end
											PopText("重筑成功")
										end
									)
									layer:showLayer("武陵桃源繁花梦，|#AAAA苍梧关山复几重，|#AAAA漫道经渠不可测，|#AAAA还教尺泽起蛟龙。")
								end
							)
						else
							PopText(errmsg)
							print("errmsg", errmsg, "errcode", errcode)
						end
					else
						PopText(errmsg)
					end
				end,
				IS_SHOW_WAITING)
				
			else
				PopText("还未选择需要保留的经脉天赋")
			end
		end)
	else
		self.Button_inherit.Text_buttonName:setString("确定传承")
		self.Button_inherit:releaseFunc(function()
			if self:getSelectCount() == self:getCanSelectCount() then
				PopupLayerController:hideLayer("MeridianInheritLayer", function(layer)
					self:hide()
				end, 0)

				local meridianImprinting = {}
				for i,v in ipairs(self.selectImprinting) do
					table.insert(meridianImprinting, {imprintingId = v.imprintingId})
				end
				local role = User:getRole()
				if role:isHaveImprintingId("zuoyouhuboyin") then
					table.insert(meridianImprinting, {imprintingId = "zuoyouhuboyin"})
				end

				Inherit:doInherit(meridianImprinting)
			else
				PopText("还未选择需要保留的经脉天赋")
			end
		end)
	end
end

function MeridianInheritLayer:getSelectCount()
	return #self.selectImprinting
end

function MeridianInheritLayer:getCanSelectCount()
	local role = User:getRole()

	local inheritCount = role:getAttr("inheritCount")

	if self._isChongZhu then
		return inheritCount
	else
		return inheritCount + 1
	end
end

Helper:classDefNodeGetInstance(MeridianInheritLayer)

return MeridianInheritLayer0000000000000