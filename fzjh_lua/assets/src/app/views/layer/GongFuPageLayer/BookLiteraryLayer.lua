
-- 百家典籍界面
local BookLiteraryLayer = class("BookLiteraryLayer", LayerEx)

local BookLiterary = require("app.models.book.BookLiterary")

local User = require("app.models.user.User")
local Item = require("app.models.item.Item")
local Resource = require("app.Resource")

-- 对话框
local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
local DialogBLayer = require("app.views.layer.DialogLayer.DialogBLayer")
local DialogCLayer = require("app.views.layer.DialogLayer.DialogCLayer")
local DialogELayer = require("app.views.layer.DialogLayer.DialogELayer")

local ReadBook = require("app.models.book.ReadBook")

local RoleTaskControllor = require("app.views.layer.RoleLayer.RoleTaskControllor")

--确定取消窗口
local function setDialogA(params)
	if MapIsEmpty(params) then
		return
	end
	local dialogA = DialogALayer:getInstance()
	dialogA:show(params.text, params.desc)
	dialogA:setButton1(params.butn1, params.func1)
	dialogA:setButton2(params.butn2, params.func2)
	dialogA:setButton3(params.butn3, params.func3)
end

-- 显示详细信息窗口
local function setDialogC(params)
	if MapIsEmpty(params) then
		return
	end

	local dialogC = DialogCLayer:getInstance()

	local func1 = function()
		if params.func1 then
			params.func1()
		end
		dialogC:unscheduleAll()
	end

	local func2 = function()
		if params.func2 then
			params.func2()
		end
		dialogC:unscheduleAll()
	end

	local func3 = function()
		if params.func3 then
			params.func3()
		end
		dialogC:unscheduleAll()
	end

	local func4 = function()
		if params.func4 then
			params.func4()
		end
		dialogC:unscheduleAll()
	end

	if params.update == nil then
		params.update = function()end
	end

	dialogC:show(params.title, params.list, params.state)
	dialogC:setButton1(params.butn1, func1, params.unHide1)
	dialogC:setButton2(params.butn2, func2, params.unHide2)
	dialogC:setButton3(params.butn3, func3, params.unHide3)
	dialogC:setButton4(params.butn4, func4, params.unHide4)
	dialogC:setListHeight(true)
	dialogC:setBack(false)
	dialogC:setDescTextVisible(false)
	dialogC:unscheduleAll()
	dialogC:schedule(
		function(ft)
			params.update()
		end, 1)
end

local TitleTable =
{
	{name = "全	部",		type = "quanbu", 	list = nil},
	{name = "经",		type = "jing",		list = nil},
	{name = "史",		type = "shi",		list = nil},
	{name = "子",		type = "zi",		list = nil},
	{name = "集",		type = "ji",		list = nil},
}

function BookLiteraryLayer:create()
	local p = BookLiteraryLayer:new()
	p:init()
	return p
end

function BookLiteraryLayer:init()
	local UI = require("Layer/GongfuPage/BookLiteraryUI.lua").create()['root']
	UI:addTo(self)

	Helper:convertUIByParent(self)

	self:setShowAndHideAnimType("ROLL")
    
	self:setButton()

	self._titleVector = {}

	self.bookList = {}

	self.currPageIndex = 1

	-- 是否从背包界面打开
	self.isFromBag = false

	self:initTabView(TitleTable)
	self:setTitleImageShow()
	self:createBookList()

	self.hideArray = {}
end

-- 初始化书籍列表
function BookLiteraryLayer:initBookList()
	local role = User:getRole()
	local literaryBox = role:getAttr("literaryBox")

	local AllList = {}
	local JingList = {}
	local ShiList = {}
	local ZiList = {}
	local JiList = {}
	TitleTable[1].list = AllList
	TitleTable[2].list = JingList
	TitleTable[3].list = ShiList
	TitleTable[4].list = ZiList
	TitleTable[5].list = JiList

	if role:getLiterary("wuzishenshu") ~= nil then
		table.insert(AllList, {literaryId = role:getLiterary("wuzishenshu").literaryId, exp = role:getLiterary("wuzishenshu").exp})
		table.insert(JiList, {literaryId = role:getLiterary("wuzishenshu").literaryId, exp = role:getLiterary("wuzishenshu").exp})
	end

	for i,v in ipairs(literaryBox) do
		if v.literaryId ~= "wuzishenshu" then
			table.insert(AllList, {literaryId = v.literaryId, exp = v.exp})
			local literaryType = BookLiterary:getLiteraryById(v.literaryId).type
			if literaryType == 0 then
				table.insert(JingList, {literaryId = v.literaryId, exp = v.exp})
			elseif literaryType == 1 then
				table.insert(ShiList, {literaryId = v.literaryId, exp = v.exp})
			elseif literaryType == 2 then
				table.insert(ZiList, {literaryId = v.literaryId, exp = v.exp})
			elseif literaryType == 3 then
				table.insert(JiList, {literaryId = v.literaryId, exp = v.exp})
			end
		end
	end
end

-- 初始化标签页
function BookLiteraryLayer:initTabView(titleTable)
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
			self:createBookList(TitleTable[k].list)
			self:setTitleImageShow(panel)
		end)
		self._titleVector[#self._titleVector + 1 ] = panel
		tag = tag + 1
	end
end

-- 高亮选择标题
function BookLiteraryLayer:setTitleImageShow(panel)
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

--@desc 特殊书籍 {[书籍ID] = Count（显示数量）}
local SpecialBookList = {
    ["wuzishenshu"] = 1
}

--@desc 计算显示的数量和颜色
local function showBookCount(literaryId,roleCount)
	local showColor = {r = 255, g = 255, b = 255}
	
	local count = 10

	if SpecialBookList[literaryId] then
		count = SpecialBookList[literaryId] 
	end

	if roleCount >= count then
		showColor = {r = 108, g = 168, b = 70}
	end
	
	return count,showColor
end

-- 创建书籍列表
function BookLiteraryLayer:createBookList(bookList)
	local role = User:getRole()
	local skillLv = role:getSkillLv("dushushizi")
	self.Text_dushushizi_lv:setString(skillLv .. "级")

	-- 显示藏书评价
	self:showEvaluate()

	self.hideArray = {}

	if bookList == nil then
		bookList = self.currPageIndex
	end

	if type(bookList) == "number" then
		bookList = TitleTable[bookList].list
	end
	
	self:showReadState()
	if MapIsEmpty(bookList) then
		self.ListView_titlelistArea:setVisible(false)
		return
	else
		self.ListView_titlelistArea:setVisible(true)
	end

	local showBookListInfo = {}
	for i = 1, #bookList do
		local bookInfo = {}
		local literaryId = bookList[i].literaryId

		local literary = role:getLiterary(literaryId)
		bookInfo.name = BookLiterary:getLiteraryById(literaryId).name
		bookInfo.lvDesc = math.floor(literary.exp) .. "/" .. BookLiterary:getLv(literary.exp) .. "级"
		bookInfo.dsc = BookLiterary:getStageDesc(BookLiterary:getLv(literary.exp))

		local count,showColor = showBookCount(literaryId,literary.count)
		bookInfo.countDesc = literary.count.."/"..count
		bookInfo.stateColor = showColor

		bookInfo.func = function()
			self:setPanelItemDesc(literary.itemId, literary)
			self:itemDescShow()
		end

		table.insert(showBookListInfo,bookInfo)
	end

	self:__showBookList(showBookListInfo)
end

function BookLiteraryLayer:__getItemPanel()
	local panel = self.Panel_title:clone()
	Helper:convertUIByParent(panel)
	panel.Text_dsc:setPositionX(499)

	return panel
end

function BookLiteraryLayer:__initPanelUI(panel,panelInfo)
	local outlineWidth = 5
	local textColor = cc.c3b(234,234, 234)
	local outlineColor = cc.c4b(17, 18, 18, 255)

	panel.Text_name:enableOutline(outlineColor, outlineWidth)
	panel.Text_dsc:enableOutline(outlineColor, outlineWidth)
	panel.Text_level:enableOutline(outlineColor, outlineWidth)
	panel.Text_state:enableOutline(outlineColor, outlineWidth)
	panel.Text_name:setColor(textColor)   --主动设置无颜色书籍颜色 修改text颜色

	panel.Text_name:setString(panelInfo.name)
	panel.Text_level:setString(panelInfo.lvDesc)
	panel.Text_dsc:setString(panelInfo.dsc)
	panel.Text_state:setString(panelInfo.countDesc)
	panel.Text_state:setTextColor(panelInfo.stateColor)

	panel:releaseFunc(function()
		if panelInfo.func then
			panelInfo.func()
		end

		self:__hideListPanelBg()
		self:__showPanelBg(panel)
	end)
end

function BookLiteraryLayer:__showBookList(bookList)
	self.ListView_titlelistArea:setVisible(true)
    self.ListView_titlelistArea:setSwallowTouches(false)

    local showItemsInfo = bookList

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

	if not self.__lastBagItemNum then
		self.__lastBagItemNum = roleItemNum
	end

    self.ListView_titlelistArea:setItemHeight(itemSize.height)

    self.ListView_titlelistArea:setItemInitFunc(function(item,info)
        self:__initPanelUI(item,info)
    end)

    self.ListView_titlelistArea:setItemCreateFunc(function()
        return self:__getItemPanel()
    end)

    self.ListView_titlelistArea:showListView(showItemsInfo,itemMaxCount)

    if isSchedule then
        if self.__bagListPos then
			local posY = math.min(self.__bagListPos.y - (roleItemNum - self.__lastBagItemNum) *  (itemSize.height + itemsMargin),self.ListView_titlelistArea:getInnerContainerSize().height)
			posY = math.min(0,posY)
			if posY > self.ListView_titlelistArea:getInnerContainerPosition().y then
                self.ListView_titlelistArea:setInnerContainerPosition({x = self.__bagListPos.x, y = posY})
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
            self.__bagListPos = self.ListView_titlelistArea:getInnerContainerPosition()
        end)
    end

	self.__lastBagItemNum = roleItemNum

	self:__hideListPanelBg()
end

function BookLiteraryLayer:__hideListPanelBg()
	local items = self.ListView_titlelistArea:getItems()
	for i = 1, #items do
		local item = items[i]
		local isVisible_1 = item.Image_title_bg_1:isVisible()
		local isVisible_2 = item.Image_title_bg_2:isVisible()
		local isVisible_3 = item.Image_title_bg_3:isVisible()

		if isVisible_1 == true then
			item.Image_title_bg_1:setVisible(false)
		end

		if isVisible_2 == true then
			item.Image_title_bg_2:setVisible(false)
		end

		if isVisible_3 == true then
			item.Image_title_bg_3:setVisible(false)
		end
	end
end

function BookLiteraryLayer:__showPanelBg(panel)
	local isVisible_1 = panel.Image_title_bg_1:isVisible()
	local isVisible_2 = panel.Image_title_bg_2:isVisible()
	local isVisible_3 = panel.Image_title_bg_3:isVisible()

	if isVisible_1 == false then
		panel.Image_title_bg_1:setVisible(true)
	end

	if isVisible_2 == false then
		panel.Image_title_bg_2:setVisible(true)
	end

	if isVisible_3 == false then
		panel.Image_title_bg_3:setVisible(true)
	end
end

-- 物品描述显示
function BookLiteraryLayer:itemDescShow()
	self.Panel_itemDesc:setTouchEnabled(true)
	self.Panel_bg:setVisible(true)
	self.Is_show = true
	local Panel_itemDesc = self.Panel_itemDesc
	self.Panel_bg:setVisible(true)
	Panel_itemDesc:setVisible(true)
	local actionTag = Panel_itemDesc:getActionTagByName("move")
	Panel_itemDesc:stopActionByTag(actionTag)
	Panel_itemDesc:move(cc.p(300, 1420))
	local action = cc.Sequence:create(
		cc.Spawn:create(
			cc.MoveTo:create(UI_ANIM_DURATION, cc.p(300.00, 1220.00)),
			cc.FadeIn:create(UI_ANIM_DURATION)
		),
		cc.CallFunc:create(
			function()
				self.Is_show = false
			end))
	action:setTag(actionTag)
	Panel_itemDesc:runAction(action)
end

-- 物品描述隐藏
function BookLiteraryLayer:itemDescHide()
	self.Panel_itemDesc:setTouchEnabled(false)
	self.Panel_bg:setVisible(true)
	self.Is_show = true
	local Panel_itemDesc = self.Panel_itemDesc
	self.Panel_bg:setVisible(true)
	Panel_itemDesc:setVisible(true)
	local actionTag = Panel_itemDesc:getActionTagByName("move")
	Panel_itemDesc:stopActionByTag(actionTag)
	Panel_itemDesc:move(cc.p(300, 1220))
	local action = cc.Sequence:create(
		cc.Spawn:create(
			cc.MoveTo:create(UI_ANIM_DURATION, cc.p(300.00, 1420.00)),
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

---点击书籍显示的面板
function BookLiteraryLayer:setPanelItemDesc(itemId, literaryData)
	local itemAttr = Item:getOneItemByKey(itemId)
	local literary = BookLiterary:getLiteraryById(literaryData.literaryId)
	self.Panel_itemDesc.Image_back.Panel_title.Text_name:setColor(cc.c3b(208, 208, 208))

	-- 书籍名字
	self.Panel_itemDesc.Image_back.Panel_title.Text_name:setString(literary.name)
	-- 等级描述
	self.Panel_itemDesc.Image_back.Panel_title.Text_zhuangbei:setString(BookLiterary:getStageDesc(BookLiterary:getLv(literaryData.exp)))
	-- 书籍描述
	self.Panel_itemDesc.Image_back.TextField_desc:setString(literary.desc)
	-- 技能等级
	self.Panel_itemDesc.Image_back.Text_level:setString(math.floor(literaryData.exp) .. "/" .. BookLiterary:getLv(literaryData.exp) .. "级")

	local role = User:getRole()
	local read_book = role:getAttr("read_book") or {}
	if role:isInCurrState(ROLE_CURR_STATE_READ) and read_book.id == literaryData.literaryId then
		self.Panel_itemDesc.Image_back.Image_button.Text_chuan:setString("正研\n在读")
	else
		self.Panel_itemDesc.Image_back.Image_button.Text_chuan:setString("研\n读")
	end

	---点击研读按钮
	self.Panel_itemDesc.Image_back.Image_button:releaseFunc(function()
		self:itemDescHide()

		local role = User:getRole()

		if role:getAttr("jing") <= 1 then
			PopText("精力不足，无法研读")
			return
		end

		local ReadBook = require("app.models.book.ReadBook")

		if self.isFromBag == false then
			ReadBook:setPlace(true)
		else
			ReadBook:setPlace(false)
		end

		ReadBook:setStartReadCallback(function ()
			self:createBookList()
		end)

		ReadBook:setStopReadCallback(function ()
			self:createBookList()
		end)

		ReadBook:showReadDialog(literaryData.literaryId)
		
		return
	end)
end

function BookLiteraryLayer:showLayer(isBag)
	if isBag == nil then
		isBag = false
	end
	self.isFromBag = isBag

	self:initBookList()
	self:createBookList()
	self:show()
end

function BookLiteraryLayer:setButton()
	self.Panel_back:releaseFunc(function()
		PopupLayerController:hideLayer("BookLiteraryLayer", function(layer)
			self:hide()
		end, 0)
	end)

	self.Panel_bg:releaseFunc(function()
		if self.Is_show == false then
			self:itemDescHide()
		end
	end)
	
 --添加判断人物是否通关第一章
 local player = User:getRole()
--  local lastMapState = player:getMapState("fb01")
 if player:isMapCompleted("fb01") then
	 self.Button_rank:setVisible(true)
	 self.Text_evaluateLv:setVisible(true)
	 self.Text_evaluate:setVisible(true)
 else
	 self.Button_rank:setVisible(false)
	 self.Text_evaluateLv:setVisible(false)
	--  RichPrint("main", "HIC请先通关第一章，通关后方可点击。")
	 self.Text_evaluate:setVisible(false)
 end
self.Button_rank:releaseFunc(function()
	Account:getEmail(
		function(eventName, errmsg, email, isBind, isLogout)
			if eventName == "有邮箱" and isBind == true then
				-- isBind 为true的时候 才是已绑定邮箱
				PopupLayerController:showLayer("BookRankLayer", function(layer)
					layer:showLayer()
				end)
			else
				PopText("请先返回主界面，并点击右上角设置，绑定您的邮箱")
				return 
			end
	end)	
 end)
	self.Panel_tips:releaseFunc(function()
	end)

	local dialog = DialogELayer:getInstance()
	self.Panel_tips:addTouchEventListener(
		function(ref, eventType)
	    	if eventType == ccui.TouchEventType.began then
	    		self.Panel_tips.Image_7:setVisible(false)
	        elseif eventType == ccui.TouchEventType.ended then							
	    		dialog:show("研读书籍，可以提升书籍本身的等级，并增加读书识字经验。\n已拥有书籍传承保留，书籍等级降为一级，读书识字传承保留一半经验值。如传承后研读书籍无法增加读书识字的经验，不要焦虑沉下心继续研读，当书匣里的书籍整体等级都提高了，研读的增益自然恢复。")
	    		dialog:setPanelBack(function()
	    			self.Panel_tips.Image_7:setVisible(true)
	    		end)
			elseif eventType == ccui.TouchEventType.canceled then
	    		self.Panel_tips.Image_7:setVisible(true)
	        end
	    end)
end

-- 显示当前正在进行的挂机类动作，并弹出提示窗口
function BookLiteraryLayer:showActionDialog(literaryId)
end

-- 显示藏书评价
function BookLiteraryLayer:showEvaluate()
	local str = BookLiterary:getEvaluateDesc()
	self.Text_evaluateLv:setString(str)
end


function BookLiteraryLayer:showReadState()
	--@RefType [app.models.role.Role#Role]
	local role = User:getRole()
	
	-- 显示研读状态
	if role:isInCurrState(ROLE_CURR_STATE_READ) then

		local read_book = role:getAttr("read_book")

		local literaryId = read_book.id

		local name = BookLiterary:getLiteraryById(literaryId).name

		self.Panel_Read.Text_Read_Name:setString(name)

		self.Panel_Read:setVisible(true)

		self.Panel_Read:releaseFunc(function ()
			ReadBook:setStopReadCallback(function ()
				self:createBookList()
			end)
			ReadBook:showReadDialog(literaryId)
		end)
	else
		self.Panel_Read:setVisible(false)
	end

end

Helper:classDefNodeGetInstance(BookLiteraryLayer)

return BookLiteraryLayer000000000000