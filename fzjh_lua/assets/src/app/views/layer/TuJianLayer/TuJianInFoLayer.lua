local TuJianInFoLayer = class("TuJianInFoLayer", cc.Layer)
local TuJianUtil = require("app.models.TuJian.TuJianUtil")

function TuJianInFoLayer:create()
	local p = TuJianInFoLayer:new()
	p:init()
	return p
end

function TuJianInFoLayer:init()
	self._round = require("Layer/TuJianUI/tujianinfoUI.lua").create()['root']
	self._round:addTo(self)
	Helper:convertUIByParent(self)

	self.ButtonState = nil --记录按钮选择的状态
	self.currTitalIndex = nil --当前选中的标题
	self.currShowTable = nil --当前显示的列表

	self.tableList = nil --当前武学总列表的
	self.insetPos = nil --panel插入位置
	self.isScrollItem = false --是否需要滑动
	self.currClickSkillId = nil

	self.LevelState = {"first","second","third","fourth"} --武学品阶列表
end

local instance = nil

function TuJianInFoLayer:showLayer(tableList)
	if instance then
		instance:release()
		instance = nil
	end
	self.skillTableView = self:initTableView()

	self.tableList = tableList
	self.currTitalIndex = nil
	self.ButtonState = {
		first = 0,
		second = 0,
		third = 0,
		fourth = 0,
		five = 0
	}
	self.titleVector = {}

    self:setCurrTital()
	self:setLevelPanelButton()
	self:show()
end

function TuJianInFoLayer:setTextDsc()
	do
		local text = "剑"
		if self.currTitalIndex == nil then
		else
			text = TuJianUtil:getTypeChineseName(self.currTitalIndex)
		end

		self.Text_xinde:setString(text.."类武学心得：")
	end

	do
		local score = self:getCurrSelectScore()

		local index = Helper:getDef(self.currTitalIndex,"jian")
		local textarry = TuJianUtil:getTextArry(index,score)
		local tital = textarry.wxtext

		self.Text_title:setString(tital)

		self:setTipsDsc(textarry.wxjftext)
	end

	do
		local num1,num2 = 0,0
		local currList = self.tableList[Helper:getDef(self.currTitalIndex,"jian")]
		for i ,skill in ipairs(currList) do
			local skillstate = User:getRole():getSkillStatus(skill.id)
			switch(skillstate,{
				[SKILL_STATE_GRASP] = function()
					num2 = num2 + 1
					num1 = num1 + 1
				end ,
				[SKILL_STATE_NOGRASP] = function()
					num1 = num1 + 1
				end ,
				[SKILL_STATE_NOSEE] = function()
				end ,
				default = function()
				end ,
			})
		end
		-- print("num1,num2 = ",num1,num2)

		self.Text_jianwen1:setString(num1)
		self.Text_zhangwo1:setString(num2)
	end
end


function TuJianInFoLayer:initTableView()

	local panel = self:getChildrenPanel().Panel_1

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
		return 874, 88
	end, cc.TABLECELL_SIZE_FOR_INDEX)

	--列表项的数量
	tableView:registerScriptHandler(function()
		return tableView._maxCount
	end, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)

	--创建列表项
	tableView:registerScriptHandler(function(view,index)
        -- print(index)
		local panelItem = nil
		local cell = view:dequeueCell()
		if nil == cell then
			cell = cc.TableViewCell:new()

			panelItem = self.Panel_2:clone()
			Helper:convertUIByParent(panelItem)
			panelItem:setTag(123)
	        cell:addChild(panelItem)
	        panelItem:setPosition(437, 44)

			panelItem._stateFunc = nil
			panelItem._func = nil

			panelItem:setSwallowTouches(false)
			if Game:isNewPackage() == true then
				panelItem:releaseFuncTotally(
					function()
						tableView._isScroll = false
					end,
					function()
						if panelItem._func and tableView._isScroll == false then
							panelItem._func()
						end
					end,
					function()
					end)
				tableView._panelMap[tostring(tableView._onlyId)] = panelItem
				tableView._onlyId = tableView._onlyId + 1
			else
				panelItem:releaseFuncTotally(
					function()
						tableView._isScroll = false
						self.ListView_titalList:setTouchEnabled(false)
					end,
					function()
						self.ListView_titalList:setTouchEnabled(true)
						if panelItem._func and tableView._isScroll == false then
							panelItem._func()
						end
					end,
					function()
						self.ListView_titalList:setTouchEnabled(true)
					end)

				tableView._panelMap[tostring(tableView._onlyId)] = panelItem
				tableView._onlyId = tableView._onlyId + 1
			end
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

function TuJianInFoLayer:refreshTuJianList()
	local currList = self:getCurrSelectData()
	-- print("个数 = ",#currList)
	if #currList > 1 then
		table.sort(currList, function(a, b)
			return a.id < b.id
		end)
	end
	self.currClickSkillId = nil
   	self.skillTableView.refreshPanelFunc = function(cell, index)
		local skill = currList[index + 1]
		if skill then
			local panel = cell:getChildByTag(123)
			panel.skill = skill
			local skillstate = User:getRole():getSkillStatus(skill.id)
			local skillName = skill.name
			--去除技能名字的颜色字符
			for _, v in ipairs(GetColorList()) do
				local s, e = string.find(skillName, v.id)
				if s ~= nil and e ~= nil then
					skillName = string.gsub(skillName,v.id,"")
				end
			end
			-- local levelStr = TuJianUtil:getlevelStr(skill.levelScore)

			local skillId = skill.id
			local skillLv
			if Skill:getSkill(skillId):checkIsSpecialZhiShiSkill() then
				skillLv = User:getRole():getSpecialZhiShiSkillLv(skillId)
			else
				skillLv = User:getRole():getSkillLv(skillId)
			end
	
			local baseSkill = Skill:getSkill(skillId)
			
			panel.Image_tiao.Text_name:enableOutline({r = 0, g = 0, b = 0, a = 255}, 5)
			panel.Text_pinzhi:enableOutline({r = 0, g = 0, b = 0, a = 255}, 5)
			panel.Text_xinde:enableOutline({r = 0, g = 0, b = 0, a = 255}, 5)
			switch(skillstate,{
				[SKILL_STATE_GRASP] = function()
					panel.Image_tiao.Text_name:setString(skillName)
					panel.Text_pinzhi:setString(baseSkill:getSkillDescForValid(skillLv))
					panel.Text_xinde:setColor(cc.c3b(144,144,144))
					panel.Text_xinde:setString(tostring(skillLv).."级")
				end ,
				[SKILL_STATE_NOGRASP] = function()
					panel.Image_tiao.Text_name:setString(skillName)
					panel.Text_pinzhi:setColor(cc.c3b(105,147,146))
					panel.Text_pinzhi:setString("-")
					panel.Text_xinde:setColor(cc.c3b(177,46,46))
					panel.Text_xinde:setString("未掌握")
				end ,
				[SKILL_STATE_NOSEE] = function()
					panel.Image_tiao.Text_name:setString("------")
					panel.Text_pinzhi:setColor(cc.c3b(105,147,146))
					panel.Text_pinzhi:setString("-")
					panel.Text_xinde:setColor(cc.c3b(144,144,144))
					panel.Text_xinde:setString("----")
				end ,
			})

			panel:setSwallowTouches(false) --临时解决数据变换，不能穿透可点击的控件滑动 taleview
			
			panel._func = function()
				Audio:playEffect("xiaoAnNiu")
				if skillstate == SKILL_STATE_NOSEE then
					PopText("你从未见闻过该武学，故无法查看明细")
					return 
				end
				
				self.currClickSkillId = skill.id
				-- self:refreshTableViewPanel(index)
				
				local params = {
					name = skillName,
					dsc = skill.dsc,
					zhaoList = User:getRole():getSkillZhaoList(skill.id)
				}
				self:popTuJianSkillInFoPopUI(params,skill.id)
			end
		end
	end

	self.skillTableView._maxCount = #currList
	self.skillTableView:reloadData()
end

-- function TuJianInFoLayer:refreshTableViewPanel()
-- 	if self.skillTableView then
-- 		for k,panel in pairs(self.skillTableView._panelMap) do
-- 			local skill = panel.skill
-- 			if skill then
-- 				-- if skill.id == self.currClickSkillId then
-- 				-- 	panel.Image_back:setVisible(true)
-- 				-- else
-- 				-- 	panel.Image_back:setVisible(false)
-- 				-- end
-- 			end
-- 		end
-- 	end
-- end

function TuJianInFoLayer:setCurrTital(noScroll)
	local tag = 999
	local tujianIndexArray = TuJianUtil:getTujianIndexArray()
	-- print("self.insetPos = ",self.insetPos)
	if self.insetPos ~= nil then
		self.ListView_titalList:removeItem(self.insetPos)
		self.insetPos = nil
	end
	for i,index in ipairs(tujianIndexArray) do
		local panel = self.ListView_titalList:getItem(i - 1)
		if panel == nil then
			panel = self.Panel_9:clone()
			self.ListView_titalList:pushBackCustomItem(panel)
		end
		Helper:convertUIByParent(panel)
		panel:setTag(tag)
		local image = TuJianUtil:getWuXueImage(index)
		panel.Image_3:loadTexture(image)
		panel.Text_titleName:enableOutline({r = 26, g = 26, b = 26, a = 255}, 5)
		panel.Text_titleName:setString(TuJianUtil:getTypeChineseName(index).."类武学")
		self.titleVector[index] = panel
		tag = tag + 1
		panel:releaseFunc(function()
			Audio:playEffect("daAnNiu")
			-- self.TuJianSkillInFoPopUI:hide()
			if self.currTitalIndex ~= index then
				self.currTitalIndex = index
			else
				self.currTitalIndex = nil
			end

			local pos = panel:convertToWorldSpaceAR(cc.p(0,0))
			if pos.y < 1285 - 85 then
				self.isScrollItem = true
			else
				self.isScrollItem = false
			end
			print(pos.x,pos.y)

			self:setCurrTital()
		end)
		if self.currTitalIndex == index then
			self.insetPos = i
		end
	end
	if self.insetPos ~= nil and self.currTitalIndex ~= nil then
		self:refreshTuJianList()
		local ChildrenPanel = self:getChildrenPanel(index)
		
		local currListNum = #self:getCurrSelectData()
		if currListNum < 9 then
			ChildrenPanel:setSize({width = 874, height = 860-(9-currListNum)*88})
		else
			ChildrenPanel:setSize({width = 874, height = 860})
		end

		self.ListView_titalList:insertCustomItem(ChildrenPanel,self.insetPos)
		
		if currListNum < 9 then
			ChildrenPanel.Panel_1:setPositionY(399.50 - (9-currListNum)*88)
			ChildrenPanel.Panel_tital:setPositionY(812.00 - (9-currListNum)*88)
		else
			ChildrenPanel.Panel_1:setPositionY(399.50)
			ChildrenPanel.Panel_tital:setPositionY(812.00)
		end

		if Game:isNewPackage() == true then
			if self.isScrollItem == true and noScroll ~= true then
				self.ListView_titalList:scrollToItem(self.insetPos -1,cc.p(0.86,0.86),cc.p(1,1))
			else
				self.ListView_titalList:jumpToItem(self.insetPos -1,cc.p(0.86,0.86),cc.p(1,1))
			end
		end
	end

	self:setTextDsc()
	self:setCurrTitalImageShow()
end


function TuJianInFoLayer:getChildrenPanel()
	if instance ~= nil then
		return instance
	else
		local panel = self.Panel_6:clone()
		Helper:convertUIByParent(panel)
		panel.Panel_tital.Text_name:enableOutline({r = 17, g = 18, b = 18, a = 255}, 5)
		panel.Panel_tital.Text_pinzhi:enableOutline({r = 17, g = 18, b = 18, a = 255}, 5)
		panel.Panel_tital.Text_xinde:enableOutline({r = 17, g = 18, b = 18, a = 255}, 5)
		instance = panel
		instance:retain()
		return panel
	end
end

-- 高亮选择标题
function TuJianInFoLayer:setCurrTitalImageShow()
	local selectColor = cc.c3b(255, 245, 58)
	local unSelectColor = cc.c3b(213, 213, 213)

	if not MapIsEmpty(self.titleVector) then
		for K,panel in pairs(self.titleVector) do
			if self.currTitalIndex == K then
				panel.Text_titleName:setColor(selectColor)
				panel.Image_2:setVisible(true)
			else
				panel.Image_2:setVisible(false)
				panel.Text_titleName:setColor(unSelectColor)
			end
		end
	end
end

--设置品质选择按钮
function TuJianInFoLayer:setLevelPanelButton()
	for k,v in pairs(self.ButtonState) do
		self["Panel_"..k].Panel_quanquan.Image_huangdi:setVisible(false)
		self["Panel_"..k].Panel_quanquan:releaseFunc(function()
			-- self.TuJianSkillInFoPopUI:hide()
			Audio:playEffect("xiaoAnNiu")
			if self.ButtonState[k] == 0 then
				self.ButtonState[k] = 1
				self["Panel_"..k].Panel_quanquan.Image_huangdi:setVisible(true)
			else
				self.ButtonState[k] = 0
				self["Panel_"..k].Panel_quanquan.Image_huangdi:setVisible(false)
			end
			self:setCurrTital(true)
		end)
	end
end

--获取当前显示的列表
function TuJianInFoLayer:getCurrSelectData()
	self.currShowTable = {}
	local currList = {}
	if self.ButtonState.five == 1 then -- 已掌握的图鉴
		currList = TuJianUtil:getRoleSkillsTable()[self.currTitalIndex]
	else --所有图鉴
		currList = self.tableList[self.currTitalIndex]
	end

	--甲乙丙丁全不选等于全选
	if self.ButtonState.first == 0 and self.ButtonState.second == 0 and self.ButtonState.third == 0 and self.ButtonState.fourth == 0 then
		if not MapIsEmpty(currList) then
			for index,skill in ipairs(currList) do
				table.insert( self.currShowTable,skill)
			end
		end
	else
		if not MapIsEmpty(currList) then
			for index,skill in ipairs(currList) do
				for i,level in ipairs(self.LevelState) do
					local state = self.ButtonState[level]

					if state == 1 then
						local levelScore = Helper:getDef(skill.levelScore,0)
						
						local minScore ,maxScore = TuJianUtil:getScoreAndLevelStrByLevel(level)

						if levelScore >= minScore and levelScore < maxScore then
							table.insert( self.currShowTable,skill)
							break
						end
					end
				end
			end
		end
	end
	
	return self.currShowTable
end

--获取当前选中的武学分数
function TuJianInFoLayer:getCurrSelectScore()
	local score = 0

	local currindex = Helper:getDef(self.currTitalIndex,"jian")
	score = TuJianUtil:getWuXueScore(currindex)

	return score
end

function TuJianInFoLayer:popTuJianSkillInFoPopUI(params,skillId)
	if params == nil or skillId == nil then
		return false
	end
	PopupLayerController:showLayer("TuJianSkillInFoPopLayer", function(layer)
		layer:setName(params.name)
		layer:setSkillDetailDsc(params.dsc)
		layer:setShowZhaoLevel(10)
		layer:setActiveZhaoList(params.zhaoList)
		layer:playWuXueAnim(skillId,self.currTitalIndex)
		layer:setAutoZhaoDsc(skillId,self.currTitalIndex,User:getRole():getSkillStatus(skillId) == SKILL_STATE_GRASP)
		-- layer:setSkillLvDsc(skillId)
		layer:showLayer()
	end)
end

function TuJianInFoLayer:setTipsDsc(text)
    local DialogELayer = require("app.views.layer.DialogLayer.DialogELayer")
    local dialog = DialogELayer:getInstance()
	self.Panel_tips:addTouchEventListener(
	function(ref, eventType)
		if eventType == ccui.TouchEventType.began then
			self.Panel_tips.Image_7:setVisible(false)
		elseif eventType == ccui.TouchEventType.ended then
			dialog:show(text,"centre")
			dialog:setPanelBack(function()
				self.Panel_tips.Image_7:setVisible(true)
			end)
		elseif eventType == ccui.TouchEventType.canceled then
			self.Panel_tips.Image_7:setVisible(true)
		end
	end)
end

Helper:classDefNodeGetInstance(TuJianInFoLayer)
return TuJianInFoLayer000000000000000