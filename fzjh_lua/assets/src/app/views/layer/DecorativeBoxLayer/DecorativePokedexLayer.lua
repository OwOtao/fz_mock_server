-- 装饰图鉴
local DecorativePokedexLayer = class("DecorativePokedexLayer", LayerEx)
local Pokedex = require("script.others.tujian")

local TitleTable =
{
	{name = "全部成就",	type = "All",				list = nil},
	{name = "已激活",		type = "Activation",		list = nil},
	{name = "未激活",		type = "UnActivation",		list = nil},
}

function DecorativePokedexLayer:create()
    local p = DecorativePokedexLayer:new()
    p:init()
    return p
end

function DecorativePokedexLayer:init()
	
    self._UI = require("Layer/DecorativeUI/DecorativePokedexUI.lua").create()['root']
    self._UI:addTo(self)
    Helper:convertUIByParent(self)

	self.DecorativePokedexTableView = self:initTableView()

    self._titleVector = {}
    self.currPageIndex = 1
	
	self.Panel_bg:releaseFunc(function()
		if self.Is_show == false then
			self:itemDescHide()
		end
	end)

    -- 成就积分
    self.point = 0
    self:setBack()
   
    self:initPokdex()
    self:initTabView(TitleTable)
    
end

function DecorativePokedexLayer:initTableView()
	local panel = self.Panel_5

	local size = panel:getContentSize()
	local tableView = cc.TableView:create(size)
	tableView:setAnchorPoint(cc.p(0,0))
	tableView:setPosition(0,0)
	tableView:setDirection(1)
	tableView:setVerticalFillOrder(0)
	tableView:setDelegate()
	tableView:setBounceable(false)	-- 取消回弹
	tableView._maxCount = 0
	tableView._panelMap = {}
	tableView._onlyId = 1

	--滚动时的回掉函数
	tableView:registerScriptHandler(function()
		tableView._isScroll = true
	end, cc.SCROLLVIEW_SCRIPT_SCROLL)

	--列表项的尺寸
	tableView:registerScriptHandler(function()
		return 1050, 170
	end, cc.TABLECELL_SIZE_FOR_INDEX)

	--列表项的数量
	tableView:registerScriptHandler(function()
		return tableView._maxCount
	end, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)

	--创建列表项
	tableView:registerScriptHandler(function(view,index)
		local panelItem = nil
		local cell = view:dequeueCell()
		if nil == cell then
			cell = cc.TableViewCell:new()

			panelItem = self.Panel_title:clone()
			Helper:convertUIByParent(panelItem)
			panelItem:setTag(123)
	        cell:addChild(panelItem)
	        panelItem:setPosition(525, 85)

			panelItem._stateFunc = nil
			panelItem._func = nil

			panelItem:setSwallowTouches(false)

			tableView._panelMap[tostring(tableView._onlyId)] = panelItem
			tableView._onlyId = tableView._onlyId + 1
		end

		if tableView.refreshPanelFunc then
			tableView.refreshPanelFunc(cell, index)
		end

		return cell
	end, cc.TABLECELL_SIZE_AT_INDEX)

	panel:addChild(tableView)
	panel._tableView = tableView
	return tableView
end

-- 显示界面
function DecorativePokedexLayer:showLayer()
    self:setTitleImageShow()
    self:createPokedexList()

	self:show()
end

-- 初始化图鉴列表
function DecorativePokedexLayer:initPokdex()
	local role = User:getRole()
	local AllList = {}
	local ActivationList = {}
	local UnActivationList = {}

	TitleTable[1].list = AllList
	TitleTable[2].list = ActivationList
	TitleTable[3].list = UnActivationList

	self.point = role:getPokedexPoint()

	-- state 2未激活 3已激活 1可激活
	for k,v in pairs(Pokedex["江湖容貌"]) do
		local state = 2
		if role:getFlag("江湖容貌图鉴成就" .. v.achievementId ) == 1 then
			state = 3
		else
			if role:getFinalAttr("looks") >= v.demand then
				state = 1
			end
		end
		table.insert(AllList, {id = tonumber(k), demand = v.demand, point = v.point, state = state, type = "江湖容貌", achievement = v.achievement, typeNum = 1, achievementId = v.achievementId})
	end

	for k,v in pairs(Pokedex["面具"]) do
		local state = 1
		local items = string.split(v.demand, ";")
		if role:getFlag("面具图鉴成就" .. v.achievementId ) == 1 then
			state = 3
		else
			for i,v in ipairs(items) do
				if v ~= nil then
					if role:getDecorativeCount(v) <= 0 then
						state = 2
					end
				end
			end
		end
		table.insert(AllList, {id = tonumber(k), demand = v.demand, point = v.point, state = state, type = "面具", achievement = v.achievement, typeNum = 2, achievementId = v.achievementId})
	end

	for k,v in pairs(Pokedex["信物"]) do
		local state = 1
		local items = string.split(v.demand, ";")
		if role:getFlag("信物图鉴成就" .. v.achievementId ) == 1 then
			state = 3
		else
			for i,v in ipairs(items) do
				if v ~= nil then
					if role:getDecorativeCount(v) <= 0 then
						state = 2
					end
				end
			end
		end
		table.insert(AllList, {id = tonumber(k), demand = v.demand, point = v.point, state = state, type = "信物", achievement = v.achievement, typeNum = 3, achievementId = v.achievementId})
	end

	for i,v in ipairs(AllList) do
		if v.state == 3 then
			table.insert(ActivationList, v)
		else
			table.insert(UnActivationList, v)
		end
	end

	-- 排序
	table.sort( AllList, function(a, b)
		if a.state == b.state then
			if a.typeNum == b.typeNum then
				return a.id < b.id
			else
				return a.typeNum < b.typeNum
			end
		else
			return a.state < b.state
		end
	end)
	table.sort( ActivationList, function(a, b)
		if a.state == b.state then
			if a.typeNum == b.typeNum then
				return a.id < b.id
			else
				return a.typeNum < b.typeNum
			end
		else
			return a.state < b.state
		end
	end)
	table.sort( UnActivationList, function(a, b)
		if a.state == b.state then
			if a.typeNum == b.typeNum then
				return a.id < b.id
			else
				return a.typeNum < b.typeNum
			end
		else
			return a.state < b.state
		end
	end)

	-- 设置成就积分
	self.Text_Points:setString(self.point)

end

-- 初始化标签页
function DecorativePokedexLayer:initTabView(titleTable)
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

			self:createPokedexList(TitleTable[k].list)
			self:setTitleImageShow(panel)
		end)
		self._titleVector[#self._titleVector + 1 ] = panel
		tag = tag + 1
	end
end

-- 高亮选择标题
function DecorativePokedexLayer:setTitleImageShow(panel)

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

function DecorativePokedexLayer:createPokedexList(pokedexList)
	
	if pokedexList == nil then
		pokedexList = self.currPageIndex
	end

	if type(pokedexList) == "number" then
		pokedexList = TitleTable[pokedexList].list
	end
	

	self.DecorativePokedexTableView.refreshPanelFunc = function(cell, index)
		print("index = ",index)
		local pokedexData = pokedexList[index + 1]
		local panel = cell:getChildByTag(123)
		
		self:createPanel(panel,pokedexData)
	end

	self.DecorativePokedexTableView._maxCount = #pokedexList
	self.DecorativePokedexTableView:reloadData()		
end

function DecorativePokedexLayer:createPanel(panel, pokedex)
	-- 拥有描述
	local outlineWidth = 4
	local outlineColor = cc.c4b(24, 24, 24, 255)
	local portraitIdList = {}
	if type(pokedex.demand) == "number" then
		portraitIdList[1] = pokedex.demand
	else
		portraitIdList = string.split(pokedex.demand, ";")
	end

	--------------------头像称号--------------------
	local title = ""
	local str = string.split(pokedex.achievement, ",")
	if #str == 2 then
		if User:getRoleAttr("sex") == "男" then
			title = str[1]
		else
			title = str[2]
		end
	else
		title = str[1]
	end
	panel.Text_title:setString(title)
	panel.Text_title:setColor(cc.c3b(236,238, 237))
	panel.Text_title:enableOutline(outlineColor, outlineWidth)
	
	-- 成就完成状态
	if pokedex.state == 2 then
		--未激活
		panel.Image_jihuo:setVisible(true)
		panel.Text_achievement:setVisible(false)
		panel.Image_jihuo:loadTexture("Image/UI/MaskUI/jihuohuise.png")
		panel.Image_jihuo:setSwallowTouches(false)
		panel.Image_jihuo:releaseFuncTotally(function()	
			self.DecorativePokedexTableView._isScroll = false
			end,
			function()end
		)
	elseif pokedex.state == 1 then
		-- 可激活
		panel.Text_title:setColor(cc.c3b(52, 198, 84))
		panel.Image_jihuo:setVisible(true)
		panel.Text_achievement:setVisible(false)
		panel.Image_jihuo:loadTexture("Image/UI/MaskUI/jihuo.png")
		panel.Image_jihuo:setSwallowTouches(false)
		panel.Image_jihuo:releaseFuncTotally(function()	
			self.DecorativePokedexTableView._isScroll = false
			end,
			function()
				if self.DecorativePokedexTableView._isScroll == false then
					local role = User:getRole()
					role:setFlag(pokedex.type .. "图鉴成就" .. pokedex.achievementId, 1)
					PopText("成就+" .. pokedex.point)
					self:initPokdex()
					self:createPokedexList()
				end
			end
		)
	elseif pokedex.state == 3 then
		-- 已激活
		panel.Image_jihuo:setVisible(false)
		panel.Text_achievement:setVisible(true)
		panel.Text_achievement:setString("成就+" .. pokedex.point)
		panel.Text_achievement:enableOutline(outlineColor, outlineWidth)
	end
	panel.Image_chakan:setSwallowTouches(false)
	panel.Image_chakan:releaseFuncTotally(function()	
		self.DecorativePokedexTableView._isScroll = false
		end,
		function()
			if self.DecorativePokedexTableView._isScroll == false then
				if MapIsEmpty(portraitIdList) then
					print("没有详情")
					return
				end
				self:itemDescShow(pokedex,title,portraitIdList)
			end
		end
	)
end

-- 物品描述显示
function DecorativePokedexLayer:itemDescShow(pokedex,title,portraitIdList)
	local role = User:getRole()
	self.Panel_itemDesc:setTouchEnabled(true)
	self.Panel_bg:setVisible(true)
	self.Is_show = true
	local Panel_itemDesc = self.Panel_itemDesc
	Panel_itemDesc:setVisible(true)
	local actionTag = Panel_itemDesc:getActionTagByName("move")
	Panel_itemDesc:stopActionByTag(actionTag)
	Panel_itemDesc:move(cc.p(320, 1320))
	local action = cc.Sequence:create(
		cc.Spawn:create(
			cc.MoveTo:create(UI_ANIM_DURATION, cc.p(320, 1300)),
			cc.FadeIn:create(UI_ANIM_DURATION)
		),
		cc.CallFunc:create(
			function()
				self.Is_show = false
			end))
	action:setTag(actionTag)
	Panel_itemDesc:runAction(action)

	Panel_itemDesc.Image_back.Panel_title.Text_name:setString(title)
	Panel_itemDesc.Image_back.Panel_title.Text_zhuangbei:setVisible(false)
	Panel_itemDesc.Image_back.Image_frame:setVisible(true)
	Panel_itemDesc.Image_back.Text_name:setVisible(true)
	Panel_itemDesc.Image_back.Image_kuang:setVisible(false)

	self.currHeadIndex = 1

	self:setPanel_itemDesc(portraitIdList,pokedex)
end

function DecorativePokedexLayer:setPanel_itemDesc(portraitIdList,pokedex)
	local role = User:getRole()
	self.Panel_itemDesc.Image_back.Image_di:setVisible(false)
	self.Panel_itemDesc.Image_back.Image_head:setVisible(false)
	self.Panel_itemDesc.Image_back.Panel_title.Text_number:setString(self.currHeadIndex.."/"..#portraitIdList)

	local portraitId = portraitIdList[self.currHeadIndex]

	if type(portraitId) == "number" then
		-- 容貌
		self.Panel_itemDesc.Image_back.Text_name:setString("容貌达到"..portraitId)
		self.Panel_itemDesc.Image_back.Image_di:setVisible(true)
		self.Panel_itemDesc.Image_back.Image_head:setVisible(true)
		local present = require("app.presenters.HeadView.HVPPresent"):create(self.Panel_itemDesc.Image_back.Image_head,self.Panel_itemDesc.Image_back.Image_di,{
			sex = role:getAttr("sex"),
			looks = portraitId,
		})
		present:showHead()
	else
		-- 装饰
		local item = Item:getOneItemByKey(portraitId)
		if item then
			local maskGrade = role:getMaskSystem():getMaskGrade(item.gradeId,1)
			self.Panel_itemDesc.Image_back.Text_name:setString(maskGrade:getMaskName())
			self.Panel_itemDesc.Image_back.Image_di:setVisible(true)
			self.Panel_itemDesc.Image_back.Image_head:setVisible(true)
			local present = require("app.presenters.HeadView.HVPPresent"):create(self.Panel_itemDesc.Image_back.Image_head,self.Panel_itemDesc.Image_back.Image_di,{
				portrait = portraitId,
			})
			present:showAnim()
		else
			print("头像物品不存在" .. portraitId)
		end
	end

	self.Panel_itemDesc.Image_back.Panel_left:releaseFunc(function()
		if self.currHeadIndex > 1 then
			self.currHeadIndex = self.currHeadIndex - 1
			self:setPanel_itemDesc(portraitIdList,pokedex)
		end
	end)
	self.Panel_itemDesc.Image_back.Panel_right:releaseFunc(function()
		if self.currHeadIndex < #portraitIdList then
			self.currHeadIndex = self.currHeadIndex + 1
			self:setPanel_itemDesc(portraitIdList,pokedex)
		end
	end)
end

-- 物品描述隐藏
function DecorativePokedexLayer:itemDescHide()
	self.Panel_itemDesc:setTouchEnabled(false)
	self.Panel_bg:setVisible(true)
	self.Is_show = true
	local Panel_itemDesc = self.Panel_itemDesc
	Panel_itemDesc:setVisible(true)
	local actionTag = Panel_itemDesc:getActionTagByName("move")
	Panel_itemDesc:stopActionByTag(actionTag)
	Panel_itemDesc:move(cc.p(320, 1300))
	local action = cc.Sequence:create(
		cc.Spawn:create(
			cc.MoveTo:create(UI_ANIM_DURATION, cc.p(320, 1320)),
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

function DecorativePokedexLayer:setBack()
	self.Panel_back:releaseFunc(function()
		PopupLayerController:hideLayer("DecorativePokedexLayer", function(layer)
			self:hide()
		end, 0)
	end)
end


Helper:classDefNodeGetInstance(DecorativePokedexLayer)

return DecorativePokedexLayer000000