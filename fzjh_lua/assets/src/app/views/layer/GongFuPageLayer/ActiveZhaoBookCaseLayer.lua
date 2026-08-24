local User = require("app.models.user.User")
local Item = require("app.models.item.Item")
local Resource = require("app.Resource")

local ActiveZhaoBookCaseLayer = class("ActiveZhaoBookCaseLayer", LayerEx)



local TitleTable =
{
	{name = "拳脚",	type = "quanjiao",	list = nil},
	{name = "兵器",	type = "bingqi",	list = nil},
	{name = "轻功",	type = "qinggong",	list = nil},
	{name = "内功",	type = "neigong",	list = nil},
	{name = "招架",	type = "zhaojia",	list = nil},
	{name = "知识",	type = "zhishi",	list = nil},
}

function ActiveZhaoBookCaseLayer:create()
	local p = ActiveZhaoBookCaseLayer:new()
	p:init()
	return p
end

function ActiveZhaoBookCaseLayer:init()
	local UI = require("Layer/GongfuPage/BookCaseUI.lua").create()['root']
	UI:addTo(self)

	Helper:convertUIByParent(self)

	self:setVisible(false)

	self:setShowAndHideAnimType("ROLL")

	self._titleVector = {}

	-- UI列表
	self.skillListItems = {}

	-- 所有书页技能
	self.activeZhao = {}

	self.currPageIndex = 1

	-- 是否从背包界面打开
	self.isFromBag = false

	self.Player = nil
	self:initPlayer()

	self._isGrant = nil

	self:initTabView(TitleTable)
	self:setTitleImageShow()
	self:setBack()
	
	self:ActiveZhaoBookCaseDsc()

	self.Text_bookcase:setString("秘籍残页")
	self.Button_change:setVisible(true)
	self.Button_change.Text_buttonName:setString("武功书页")
	self.Button_change:releaseFunc(function()
		local BookCaseLayer = require("app.views.layer.GongFuPageLayer.BookCaseLayer")
		BookCaseLayer:getInstance():showLayer(self.isFromBag)
		PopupLayerController:hideLayer("ActiveZhaoBookCaseLayer", function(layer)
			if self.listViewSchedule then
				self:unschedule(self.listViewSchedule)
				self.listViewSchedule = nil
			end
			self:hide()
		end)
	end)

	self.Text_desc:setString("\n点击上方感叹号可查看技能残页介绍。")
end

function ActiveZhaoBookCaseLayer:showLayer(isBag,currRole)
	if isBag == nil then
		isBag = false
	end
	if isBag == "isGrant" then
		self.Button_change:setVisible(false)
		self._isGrant = "isGrant"
		self._currRole = currRole
	else
		self._isGrant = nil
		self.Button_change:setVisible(true)
	end
	self.isFromBag = isBag

	self:show()
	self:initPlayer()
	self:initSkills()
	self:__initListPanelData()
	self:setTipBtnVisible(true)
	self:setDescVisible(true)
	self:setTextInt()
end

function ActiveZhaoBookCaseLayer:setTextInt()
	local int = self.Player:getFinalAttr("int")

    local secInt = self.Player:getFinalAttr("secInt")
	
	self.Text_int:setVisible(true)
	
	self.Text_int:setString("悟性："..tostring(secInt+int).."/"..int)
end

function ActiveZhaoBookCaseLayer:setButtonChangeIsvisible(boole)
	self.Button_change:setVisible(boole)
end

function ActiveZhaoBookCaseLayer:initPlayer()
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
function ActiveZhaoBookCaseLayer:initSkills()
	local bookSkills = require("app.models.book.BookSkills")
	self.activeZhao = inherit({},bookSkills:getBookActiveZhao())
	local zhaoShuXiang = self.Player:getAttr("zhaoShuXiang")

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

	local _zhaoshuxiang = {}

	for i, bookCase in pairs(zhaoShuXiang) do
		if _zhaoshuxiang[bookCase.itemId] then
			_zhaoshuxiang[bookCase.itemId] = bookCase.count + _zhaoshuxiang[bookCase.itemId]
		else
			_zhaoshuxiang[bookCase.itemId] = bookCase.count
		end
	end

	local _zhaoshuxiang_add = {}

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
	for skillName, skill in pairs(self.activeZhao) do
		for j,page in pairs(skill.page) do
			if _zhaoshuxiang[page.name] then
				local itemAttr = Item:getOneItemByKey(page.name)
				page.count = tonumber(_zhaoshuxiang[page.name]) + Helper:getDef(page.count,0)
				page.CHName = itemAttr.name
				page.itemId = page.name

				if not _zhaoshuxiang_add[skillName] and page.count > 0 then
					_zhaoshuxiang_add[skillName] = true
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

function ActiveZhaoBookCaseLayer:__createPanel()
	local panel = self.Panel_title:clone()
	Helper:convertUIByParent(panel)
	return panel
end

function ActiveZhaoBookCaseLayer:__initPanel(panel,panelData)
	panel:setTouchEnabled(true)
	panel:releaseFunc(function()
		if panelData.func then
			panelData.func()
		end
	end)
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
	
	
end

function ActiveZhaoBookCaseLayer:__initListPanelData(skillList)
	if skillList == nil then
		skillList = self.currPageIndex
	end
	if type(skillList) == "number" then
		skillList = TitleTable[skillList].list
	end

	if #self.Player:getAttr("zhaoShuXiang") > 0 then
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

	local listPanelData = {}

	table.sort(skillList, function(a, b)
		return a.sortIndex < b.sortIndex
	end)

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
		panelData.num_visible = false
		panelData.fold_visible = true
		panelData.title_bg_1_visible = true
		panelData.title_bg_2_visible = true

		panelData.title_name = "【" .. currSkill.name .. "】"

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
						self:setPanelItemDesc(page.itemId, Helper:getDef(page.needCount, 1),skill.skillId,page.count)
						self:itemDescShow()
					end
					table.insert(listPanelData, panelData)
				end
			end
		end
	end

	self:__showList(listPanelData)
end

function ActiveZhaoBookCaseLayer:__showList(listPanelData)
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
function ActiveZhaoBookCaseLayer:initTabView(titleTable)
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
function ActiveZhaoBookCaseLayer:setTitleImageShow(panel)
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

function ActiveZhaoBookCaseLayer:setBack()
	self.Image_back:releaseFunc(function()
		-- PopupLayerController:hideLayer("ActiveZhaoBookCaseLayer", function(layer)
		-- 	self:hide()
		-- end)
	end)

	self.Panel_back:releaseFunc(function()
		PopupLayerController:hideLayer("ActiveZhaoBookCaseLayer", function(layer)
			if self.listViewSchedule then
				self:unschedule(self.listViewSchedule)
				self.listViewSchedule = nil
			end
			self:hide()
		end)
	end)

	self.Panel_bg:releaseFunc(function()
		self.Panel_bg:setVisible(false)
		self.Panel_itemDesc:setVisible(false)
	end)
end

---点击残页显示的面板
function ActiveZhaoBookCaseLayer:setPanelItemDesc(itemId, needCount, skillId,count)
	local itemAttr = Item:getOneItemByKey(itemId)
	if MapIsEmpty(itemAttr) == true then
		return
	end
	self.Panel_itemDesc.Image_back.Panel_title.Text_name:setColor(cc.c3b(208, 208, 208))
	self.Panel_itemDesc.Image_back.Panel_title.Text_name:setString(itemAttr.name)
	self.Panel_itemDesc.Image_back.Panel_title.Text_zhuangbei:setString(itemAttr.type)
	self.Panel_itemDesc.Image_back.TextField_desc:setString(itemAttr.dsc)

	local zhaoId = itemAttr.zhaoId
	local zhao = Skill:getActiveZhao(zhaoId)
	-- add by XiaoZhiWei 2017/04/01 17:52:54 招式已学会或招式的学习类型是条件判断型,则只能研习
	if self._isGrant ==  "isGrant" then
		self.Panel_itemDesc.Image_back.Image_button.Text_chuan:setString("赠\n予")
		self.Panel_itemDesc.Image_back.Text_learn_desc:setVisible(false)

		self.Panel_itemDesc.Image_back.Image_button:releaseFunc(function()
			local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
        	local dialog = DialogALayer:getInstance()
			
        	dialog:show("是否要给"..self._currRole.name.."学习"..itemAttr.name.."招式？(陪练在学习招式后，可与其对练该绝学招式，陪练学习残页招式后不可遗忘!)")
			dialog:setButton1("确定",function()
				if self._currRole.extra == nil then
					self._currRole.extra = {}
				end
				local tab = self._currRole.extra				
				if tab.zhaoIdList == nil then
					tab.zhaoIdList = {} --记录招式Id
				end
				if self:cheakHaveZhaoId(zhaoId,tab.zhaoIdList) then
					PopText(itemAttr.name.."招式，"..self._currRole.name.."已经学习过了")
					return
				end
				local up_data = {}
				local zhaoIdList = clone(tab.zhaoIdList)
				local zhaoLearnNum = Helper:getDef(tab.zhaoLearnNum,0)

				local HomelandRoleUtil = require("app.models.HomelandModel.HomelandRoleUtil")
				local zcLv = HomelandRoleUtil:getFidelityLv(self._currRole.defaultZhongCheng)
				if zhaoLearnNum >= (zcLv+2)*2 then
					PopText("该陪练目前的忠诚度有限，不足以学习更多招式！")
					return
				end

				local mid = self._currRole.mid
				table.insert(zhaoIdList,zhaoId)	
				table.insert( up_data,{rwId =self._currRole.id,extra = { zhaoIdList = zhaoIdList,zhaoLearnNum = zhaoLearnNum + 1}})

				HttpManagerEx:updateEmployeeExtra(mid,up_data, function(status, errcode, errmsg, data)
					if status == 200 then
						if errcode == 0 then		
							table.insert(tab.zhaoIdList,zhaoId)
							tab.zhaoLearnNum = Helper:getDef(tab.zhaoLearnNum,0) + 1
							self.Player:addZhaoShuXiang(itemAttr.id, - 1)
							self.Panel_bg:setVisible(false)
							self.Panel_itemDesc:setVisible(false)
							self:initSkills()
							self:__initListPanelData(self.currPageIndex)

							PopText("赠与成功，你可与其对练该绝学招式")
						else
							PopText(errmsg)
						end
					else
						PopText(errmsg)
					end
				end, IS_SHOW_WAITING)
			end)
			dialog:setButton2(
            "取消",
            function()
               dialog:hide()
            end
        )
			
		end)
	else
		local learnDesc = ""
		
		local buttonVisible = false
		
		local buttonName = ""

		if self.Player:getSkillExp(skillId) <= 0 then
			learnDesc = "未习得"..Skill:getSkill(skillId):getNoColorName()
		else
			if self.Player:getSkillZhao(zhaoId) == nil and zhao.learnMethod == 1 then
				learnDesc = "首次学习需要"..needCount.."张残页"
				
				if count >= needCount then
					buttonVisible = true
					buttonName = "学\n习"
				end
			elseif self.Player:getSkillZhao(zhaoId) == nil and zhao.learnMethod == 0 then
				for i,v in ipairs(zhao:getLearnConditionResList()) do
					if i == 1 then
						learnDesc = v
					else
						learnDesc = learnDesc .. "\n"..v
					end
				end
			elseif self.Player:getSkillZhao(zhaoId) == nil and zhao.learnMethod == nil and not MapIsEmpty(zhao:getLearnConditionResList()) then
				if count >= needCount then
					learnDesc = "当前可使用"..needCount.."张残页提前领悟"
					buttonVisible = true
					buttonName = "学\n习"
				else
					for i,v in ipairs(zhao:getLearnConditionResList()) do
						if i == 1 then
							learnDesc = v
						else
							learnDesc = learnDesc .. "\n"..v
						end
					end

					learnDesc = learnDesc .. "\n或\n".."使用"..needCount.."张残页提前领悟"
				end
			elseif self.Player:getSkillZhao(zhaoId) ~= nil then
				local levelText = "技能重数：".. self.Player:getSkillZhaoLv(zhaoId)

				local expText = "技能熟练度："..Helper:mathFloor(self.Player:getSkillZhaoExp(zhaoId)).."/"..self.Player:getZhaoExpLimit(zhaoId,self.Player:getZhaoLvLimit(zhaoId))

				learnDesc = levelText .. "\n"..expText

				local ret, addExp = self.Player:checkSkillZhaoCanUp(zhaoId, 500)
				
				if addExp < 500 then
					learnDesc = learnDesc .. "\n当前熟练度已不可研习!"
				else
					buttonVisible = true
					buttonName = "研\n习"
				end
			end
		end

		self.Panel_itemDesc.Image_back.Text_learn_desc:setVisible(true)

		self.Panel_itemDesc.Image_back.Text_learn_desc:setTextColor({r = 255, g = 255, b = 0})

		self.Panel_itemDesc.Image_back.Text_learn_desc:setString(learnDesc)

		self.Panel_itemDesc.Image_back.Image_button:setVisible(buttonVisible)
		
		self.Panel_itemDesc.Image_back.Image_button.Text_chuan:setString(buttonName)

		self.Panel_itemDesc.Image_back.Image_button:releaseFunc(function()
			if self.Player:getSkillZhao(zhaoId) ~= nil and count > 1 then
				PopupLayerController:showLayer("BatchUseActiveZhaoPagePresenter",function(layer)
					layer:setCallBack(function(useCount)
						self:__useItem(itemAttr,useCount)
					end)
					layer:showLayer(itemAttr,count)
				end)
			else
				self:__useItem(itemAttr,1)
			end
		end)
	end

end

function ActiveZhaoBookCaseLayer:__useItem(itemAttr,count)
	-- 使用书页方法
	itemAttr:useItem(function()
		self.Panel_bg:setVisible(false)
		self.Panel_itemDesc:setVisible(false)
		self:initSkills()
		self:__initListPanelData(self.currPageIndex)
	end,nil,nil,nil,self.Player,count)
end

-- 物品描述显示
function ActiveZhaoBookCaseLayer:itemDescShow()
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

--检查保存的招式列表是否有这个招式 
function ActiveZhaoBookCaseLayer:cheakHaveZhaoId(zhaoId,zhaoIdList)
    if MapIsEmpty(zhaoIdList) then
        return false
    end
    for k,v in pairs(zhaoIdList) do
        if zhaoId == v then
            return true
        end    
    end 

    return false
end

--秘籍残页描述
function ActiveZhaoBookCaseLayer:ActiveZhaoBookCaseDsc()
	self.Panel_tips:setPosition(688.93,1747.33)
	
    local DialogELayer = require("app.views.layer.DialogLayer.DialogELayer")
    local dialog = DialogELayer:getInstance()
	self.Panel_tips:addTouchEventListener(
	function(ref, eventType)
		if eventType == ccui.TouchEventType.began then
			self.Panel_tips.Image_7:setVisible(false)
		elseif eventType == ccui.TouchEventType.ended then
			dialog:show("江湖武学主动技能残页参与挑战玩法、历练任务有几率获得。\n门派武学主动技能残页可通过师门处寻找商人花费师门贡献点购买。\n已学的江湖、门派武学主动技能传承不保留，没使用在书箱内的主动技能残页传承保留。")
			dialog:setPanelBack(function()
				self.Panel_tips.Image_7:setVisible(true)
			end)
		elseif eventType == ccui.TouchEventType.canceled then
			self.Panel_tips.Image_7:setVisible(true)
		end
	end)
end

function ActiveZhaoBookCaseLayer:setTipBtnVisible(visible)
	if visible == true then
		self.Panel_tips:setVisible(true)
	else
		self.Panel_tips:setVisible(false)
	end
end

function ActiveZhaoBookCaseLayer:setDescVisible(visible)
	if visible == true then
		self.Text_desc:setVisible(true)
	else
		self.Text_desc:setVisible(false)
	end
end

Helper:classDefNodeGetInstance(ActiveZhaoBookCaseLayer)

return ActiveZhaoBookCaseLayer00000000