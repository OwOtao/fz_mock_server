local User = require("app.models.user.User")
local Item = require("app.models.item.Item")
local Resource = require("app.Resource")

local BookCaseLayer = class("BookCaseLayer", LayerEx)



local TitleTable =
{
	{name = "拳脚",	type = "quanjiao",	list = nil},
	{name = "兵器",	type = "bingqi",	list = nil},
	{name = "轻功",	type = "qinggong",	list = nil},
	{name = "内功",	type = "neigong",	list = nil},
	{name = "招架",	type = "zhaojia",	list = nil},
	{name = "知识",	type = "zhishi",	list = nil},
}

function BookCaseLayer:create()
	local p = BookCaseLayer:new()
	p:init()
	return p
end

function BookCaseLayer:init()
	local UI = require("Layer/GongfuPage/BookCaseUI.lua").create()['root']
	UI:addTo(self)

	Helper:convertUIByParent(self)

	self:setVisible(false)

	self:setShowAndHideAnimType("ROLL")

	self._titleVector = {}

	-- UI列表
	self.skillListItems = {}

	-- 所有书页技能
	self.skills = {}

	self.currPageIndex = 1

	-- 是否从背包界面打开
	self.isFromBag = false
	self.Player = nil
	self:initPlayer()

	self:initTabView(TitleTable)
	self:setTitleImageShow()
	self:setBack()
	self:BookCaseDsc()
	self.Text_bookcase:setString("武功书页")
	self.Button_change:setVisible(true)
	self.Button_change.Text_buttonName:setString("秘籍残页")
	self.Button_change:releaseFunc(function()
		PopupLayerController:showLayer("ActiveZhaoBookCaseLayer", function(layer)
			layer:showLayer(self.isFromBag)
		end)
		PopupLayerController:hideLayer("BookCaseLayer", function(layer)
			if self.listViewSchedule then
				self:unschedule(self.listViewSchedule)
				self.listViewSchedule = nil
			end
			self:hide()
		end)
	end)

	self.Text_desc:setString("\n点击上方感叹号可查看武学秘籍介绍。")
end

-- isBag 是否从背包打开
function BookCaseLayer:showLayer(isBag)
	if isBag == nil then
		isBag = false
	end
	self.isFromBag = isBag

	self:show()
	self:initPlayer()

	self:__initSkills()
	self:__initListPanelData()
end

function BookCaseLayer:initPlayer()
	local role = User:getRole()
	if MainControllLayer:getCurrLayer() == "MapLayer" then
		local currMap = role:getCurrMap()
		if currMap and (currMap:getMapType() == MAP_TYPE.DREAMMAP or currMap:getMapType() == MAP_TYPE.FONDDREAMMAP) then
			self.Player = currMap:getPlayer()
			return
		end
	end	
	self.Player = role
end

-- 初始化已拥有的书页技能
function BookCaseLayer:__initSkills()
	local bookSkills = require("app.models.book.BookSkills")
	self.skills = clone(bookSkills:getbookSkill())
	local shuxiang = self.Player:getAttr("shuxiang")

	-- 存放已拥有的书页技能
	local QuanJiaoList = {}
	local BingQiList = {}
	local QingGongList = {}
	local NeiGongList = {}
	local ZhaoJiaList = {}
	local ZhiShiList = {}

	TitleTable[1].list = QuanJiaoList
	TitleTable[2].list = BingQiList
	TitleTable[3].list = QingGongList
	TitleTable[4].list = NeiGongList
	TitleTable[5].list = ZhaoJiaList
	TitleTable[6].list = ZhiShiList

	local _shuxiang = {}

	for i, bookCase in pairs(shuxiang) do
		if _shuxiang[bookCase.itemId] then
			_shuxiang[bookCase.itemId] = bookCase.count + _shuxiang[bookCase.itemId]
		else
			_shuxiang[bookCase.itemId] = bookCase.count
		end
	end

	local _shuxiang_add = {}

	local function addSkillToTable(skillType, skill, skillId)
		if skillType == "quanjiao" then
			table.insert(QuanJiaoList, skill)
		elseif skillType == "bingqi" then
			table.insert(BingQiList, skill)
		elseif skillType == "qinggong" then
			table.insert(QingGongList, skill)
		elseif skillType == "neigong" then
			table.insert(NeiGongList, skill)
		elseif skillType == "zhaojia" then
			table.insert(ZhaoJiaList, skill)
		elseif skillType == "zhishi" then
			table.insert(ZhiShiList, skill)
		end
	end

	-- 添加书页
	for skillName, skill in pairs(self.skills) do
		for j,page in pairs(skill.page) do
			if _shuxiang[page.name] then
				local itemAttr = Item:getOneItemByKey(page.name)
				page.CHName = itemAttr.name
				page.itemId = page.name
				page.count = tonumber( _shuxiang[page.name]) + Helper:getDef(page.count,0)

				if not _shuxiang_add[skillName] and page.count > 0 then
					_shuxiang_add[skillName] = true
					if skill.type[1] ~= nil then
						addSkillToTable(skill.type[1], skill, skillName)
					end
					if skill.type[2] ~= nil then
						addSkillToTable(skill.type[2], skill, skillName)
					end
					if skill.type[3] ~= nil then
						addSkillToTable(skill.type[3], skill, skillName)
					end
				end
			end
		end
	end
end

function BookCaseLayer:__createPanel()
	local panel = self.Panel_title:clone()
	Helper:convertUIByParent(panel)
	return panel
end

function BookCaseLayer:__initPanel(panel,panelData)
	panel.Text_title_name:setVisible(panelData.title_name_visible or false)
	panel.Text_num:setVisible(panelData.num_visible or false)
	panel.Image_flod:setVisible(panelData.fold_visible or false)
	panel.Text_name:setVisible(panelData.name_visible or false)
	panel.Image_title_bg_1:setVisible(panelData.title_bg_1_visible or false)
	panel.Image_title_bg_2:setVisible(panelData.title_bg_2_visible or false)
	panel.Image_title_bg_3:setVisible(panelData.title_bg_3_visible or false)

	local color = {r = 26, g = 26, b = 26, a = 255}
	panel.Text_name:setColor(cc.c3b(208, 208, 208))
	panel.Text_title_name:enableOutline(color, 5)
	panel.Text_num:enableOutline(color, 5)
	panel.Text_name:enableOutline(color, 5)

	panel.Image_flod:loadTexture(panelData.flod_texture)
	panel.Text_title_name:setString(panelData.title_name or "")
	panel.Text_name:setString(panelData.name or "")
	panel.Text_num:setString(panelData.num or "")
	
	panel:setTouchEnabled(true)
	panel:releaseFunc(function()
		if panelData.func then
			panelData.func()
		end
	end)
end

function BookCaseLayer:__initListPanelData(skillList)
	if skillList == nil then
		skillList = self.currPageIndex
	end
	if type(skillList) == "number" then
		skillList = TitleTable[skillList].list
	end

	if #self.Player:getAttr("shuxiang") > 0 then
		self.Text_empty:setVisible(false)
	else
		self.Text_empty:setVisible(true)
	end

	if MapIsEmpty(skillList) then
		self.ListView_titlelistArea:setVisible(false)
		return
	else
		self.ListView_titlelistArea:setVisible(true)
	end

	table.sort(skillList, function(a, b)
		return a.sortIndex < b.sortIndex
	end)

	local listPanelData = {}

	for skillId, skill in ipairs(skillList) do
		local panelData = {}
		-- 当前已拥有书页数量
		local currNum = 0

		for k,page in pairs(skill.page) do
			if page.count > 0 then
				currNum = currNum + 1
			end
		end

		local currSkill = Skill:getSkill(skill.skillId)

		panelData.title_name_visible = true
		panelData.name_visible = false
		panelData.num_visible = true
		panelData.fold_visible = true
		panelData.title_bg_1_visible = true
		panelData.title_bg_2_visible = true

		panelData.title_name = "【" .. currSkill.name .. "】"
		panelData.num = " (" .. currNum .. "/" .. skill.totalNum .. ")"

		if self.skillListItems[skill.skillId] == nil then
			self.skillListItems[skill.skillId] = {isFold = true}
		end

		if self.skillListItems[skill.skillId].isFold == false then
			panelData.title_bg_3_visible = true
			panelData.flod_texture = Resource:getImgPath("title_unflod")
		else
			panelData.title_bg_3_visible = false
			panelData.flod_texture = Resource:getImgPath("title_flod")
		end

		panelData.func = function()
			Audio:playEffect("xiaoAnNiu")
			if self.skillListItems[skill.skillId].isFold == true then
				for k,v in pairs(self.skillListItems) do
					v.isFold = true
				end
			end
			self.skillListItems[skill.skillId].isFold = not self.skillListItems[skill.skillId].isFold
			self:__initListPanelData(self.currPageIndex)
		end

		table.insert(listPanelData, panelData)

		if self.skillListItems[skill.skillId].isFold == false then
			-- 创建子页
			for k,page in pairs(skill.page) do
				if page.count > 0 then
					local panelData = {}

					panelData.title_name_visible = false
					panelData.name_visible = true
					panelData.num_visible = false
					panelData.fold_visible = false
					panelData.title_bg_1_visible = false
					panelData.title_bg_2_visible = false
					panelData.title_bg_3_visible = false

					panelData.name = "【" .. page.CHName .. "】" .. " X " .. page.count
					panelData.flod_texture = Resource:getImgPath("title_flod")

					panelData.func = function()
						Audio:playEffect("xiaoAnNiu")
						self:setPanelItemDesc(page.itemId, skill.skillId)
						self:itemDescShow()
					end
					table.insert(listPanelData, panelData)
				end
			end
		end
	end

	self:__showList(listPanelData)
end

function BookCaseLayer:__showList(listPanelData)
	self.ListView_titlelistArea:setVisible(false)
    self.ListView_titlelistArea:setSwallowTouches(false)

    local showItemsInfo = listPanelData
    if MapIsEmpty(showItemsInfo) then
        self.ListView_titlelistArea:removeAllItems()
        if self.listViewSchedule then
            self:unschedule(self.listViewSchedule)
            self.listViewSchedule = nil
        end
        return
    end

    local roleItemNum = #showItemsInfo
    local listSize = self.ListView_titlelistArea:getContentSize()
    local itemSize = self.Panel_title:getContentSize()
    local itemsMargin = self.ListView_titlelistArea:getItemsMargin()
    local itemMaxCount = Helper:mathFloor(listSize.height/(itemSize.height + itemsMargin)) + 2
    local isSchedule = true

    if roleItemNum < itemMaxCount then
        itemMaxCount = roleItemNum
        isSchedule = false
    end

	if not self.lastItemNum then
		self.lastItemNum = roleItemNum
	end

    self.ListView_titlelistArea:setItemHeight(itemSize.height)

    self.ListView_titlelistArea:setItemInitFunc(function(item,info)
        self:__initPanel(item,info)
    end)

    self.ListView_titlelistArea:setItemCreateFunc(function()
        return self:__createPanel()
    end)

    self.ListView_titlelistArea:showListView(showItemsInfo,itemMaxCount)

    self.ListView_titlelistArea:setVisible(true)

    if isSchedule then
        if self._lastContentPos then
			local posY = math.min(self._lastContentPos.y - (roleItemNum - self.lastItemNum) *  (itemSize.height + itemsMargin),self.ListView_titlelistArea:getInnerContainerSize().height)
			posY = math.min(0,posY)
			if posY > self.ListView_titlelistArea:getInnerContainerPosition().y then
                self.ListView_titlelistArea:setInnerContainerPosition({x = self._lastContentPos.x, y = posY})
            end
        else
            self.ListView_titlelistArea:jumpToTop()
        end

        local isTrue = self.ListView_titlelistArea:refreshReuseItems()
		while isTrue do
			isTrue = self.ListView_titlelistArea:refreshReuseItems()
		end

        if self.listViewSchedule then
            self:unschedule(self.listViewSchedule)
            self.listViewSchedule = nil
        end

        self.listViewSchedule = self:schedule(function()
            self.ListView_titlelistArea:refreshReuseItems()
            self._lastContentPos = self.ListView_titlelistArea:getLastInnerContainerPosition()
        end)
    end

	self.lastItemNum = roleItemNum
end

-- 初始化标签页
function BookCaseLayer:initTabView(titleTable)
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
			self.skillListItems = {}
			self.currPageIndex = k
			self:__initListPanelData(TitleTable[k].list)
			self:setTitleImageShow(panel)
		end)
		self._titleVector[#self._titleVector + 1 ] = panel
		tag = tag + 1
	end
end

-- 高亮选择标题
function BookCaseLayer:setTitleImageShow(panel)
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

function BookCaseLayer:setBack()
	self.Image_back:releaseFunc(function()
		-- PopupLayerController:hideLayer("BookCaseLayer", function(layer)
		-- 	self:hide()
		-- end)
	end)

	self.Panel_back:releaseFunc(function()
		if self.listViewSchedule then
			self:unschedule(self.listViewSchedule)
			self.listViewSchedule = nil
		end
		PopupLayerController:hideLayer("BookCaseLayer", function(layer)
			self:hide()
		end)
	end)

	self.Panel_bg:releaseFunc(function()
		self.Panel_bg:setVisible(false)
		self.Panel_itemDesc:setVisible(false)
	end)
end

---点击残页显示的面板
function BookCaseLayer:setPanelItemDesc(itemId, skillId)
	local itemAttr = Item:getOneItemByKey(itemId)
	self.Panel_itemDesc.Image_back.Panel_title.Text_name:setColor(cc.c3b(208, 208, 208))
	self.Panel_itemDesc.Image_back.Panel_title.Text_name:setString(itemAttr.name)
	self.Panel_itemDesc.Image_back.Panel_title.Text_zhuangbei:setString(itemAttr.type)
	self.Panel_itemDesc.Image_back.TextField_desc:setString(itemAttr.dsc)
	if self.Player:getSkill(skillId) ~= nil then
		self.Panel_itemDesc.Image_back.Image_button.Text_chuan:setString("使\n用")
	else
		self.Panel_itemDesc.Image_back.Image_button.Text_chuan:setString("学\n习")
	end

	---点击学习按钮
	self.Panel_itemDesc.Image_back.Image_button:releaseFunc(function()
		-- 使用书页方法
		itemAttr:useItem(function()
			self.Panel_bg:setVisible(false)
			self.Panel_itemDesc:setVisible(false)
			self:__initSkills()
			self:__initListPanelData(self.currPageIndex)
		end,nil,nil,nil,self.Player,nil)
	end)
end

-- 物品描述显示
function BookCaseLayer:itemDescShow()
	self.Panel_itemDesc:setTouchEnabled(true)
	self.Is_show = true
	local Panel_itemDesc = self.Panel_itemDesc
	self.Panel_bg:setVisible(true)
	Panel_itemDesc:setVisible(true)
	local actionTag = Panel_itemDesc:getActionTagByName("move")
	Panel_itemDesc:stopActionByTag(actionTag)
	Panel_itemDesc:move(cc.p(380, 1710))
	local action = cc.Sequence:create(
		cc.Spawn:create(
			cc.MoveTo:create(UI_ANIM_DURATION, cc.p(380, 1540)),
			cc.FadeIn:create(UI_ANIM_DURATION)
		),
		cc.CallFunc:create(
			function()
			end))
	action:setTag(actionTag)
	Panel_itemDesc:runAction(action)
end

--武功书页描述
function BookCaseLayer:BookCaseDsc()
	self.Panel_tips:setPosition(688.93,1747.33)
    local DialogELayer = require("app.views.layer.DialogLayer.DialogELayer")
    local dialog = DialogELayer:getInstance()
	self.Panel_tips:addTouchEventListener(
	function(ref, eventType)
		if eventType == ccui.TouchEventType.began then
			self.Panel_tips.Image_7:setVisible(false)
		elseif eventType == ccui.TouchEventType.ended then
			dialog:show("完成挑战任务有几率获得书页。\n书页可用来学习及升级武功。\n已学的江湖秘籍武学传承不保留，没使用在书箱内的武学残页传承保留。传承后通关“柳玄风卷下”第五章可找到上一代继承已学江湖秘籍武学并掌握一半的武学经验，需要一定的江湖阅历才可继承。")
			dialog:setPanelBack(function()
				self.Panel_tips.Image_7:setVisible(true)
			end)
		elseif eventType == ccui.TouchEventType.canceled then
			self.Panel_tips.Image_7:setVisible(true)
		end
	end)
end

Helper:classDefNodeGetInstance(BookCaseLayer)

return BookCaseLayer0000