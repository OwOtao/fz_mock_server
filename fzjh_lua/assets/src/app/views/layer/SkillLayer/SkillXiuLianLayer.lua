local Resource = require("app.Resource")
local Npc = require("app.models.npc.Npc")
local Skill = require("app.models.skill.Skill")
local Item = require("app.models.item.Item")
local SkillXiuLianUtil = require("app.models.skill.SkillXiuLianUtil")

-- 角色技能列表
local RoleSkillInfoListBarUI = require("app.views.ui.SkillUI.RoleSkillInfoListBarUI")
local RoleSkillInfoTabBarUI = require("app.views.ui.SkillUI.RoleSkillInfoTabBarUI")

-- 技能详细信息弹出框
local SkillInfoPopNormalUI = require("app.views.ui.SkillUI.SkillInfoPopNormalUI")
local SkillInfoPopSpecialUI = require("app.views.ui.SkillUI.SkillInfoPopSpecialUI")

-- 对话框
local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
local DialogCLayer = require("app.views.layer.DialogLayer.DialogCLayer")


local RoleTaskControllor = require("app.views.layer.RoleLayer.RoleTaskControllor")

local SkillConst = require("app.models.skill.SkillConst")

local SkillXiuLianLayer = class("SkillXiuLianLayer", require("app.views.base.BaseLayer"))

-- 准备列表
local prepareList = SkillConst.PrepareList

function SkillXiuLianLayer:create()
	local p = SkillXiuLianLayer:new()
	p:init()
	return p
end

-- 初始化
function SkillXiuLianLayer:init()
	self._UI = require("Layer/SkillUI/SkillXiuLianUI.lua").create()['root']
	self._UI:addTo(self)

	Helper:convertUI(self) -- 获得所有子节点

	self:initPopUI()
	--点击背景隐藏弹出窗口
	self:setPanelDi()
	self:setBtnBack()

	self:schedule(
    	function(ft)
    		self:update(ft)
    	end, 0.5)
end

-- 技能详细信息初始化
function SkillXiuLianLayer:initPopUI()
	if self.skillInfoPopNormalUI == nil then
		self.skillInfoPopNormalUI = SkillInfoPopNormalUI:create()
		self.skillInfoPopNormalUI:addTo(self)
	end
	if self.skillInfoPopSpecialUI == nil then
		self.skillInfoPopSpecialUI = SkillInfoPopSpecialUI:create()
		self.skillInfoPopSpecialUI:addTo(self)
	end
	self.Pis_show = false
	self.Nis_show = false
	self.skillInfoPopNormalUI:hide()
	self.skillInfoPopSpecialUI:hide()
end

-- 点击背景控制详细面板的显示隐藏
function SkillXiuLianLayer:setPanelDi()
	self.Panel_di:releaseFunc(function()
		if self.Nis_show then
			self.Nis_show = false
			self.skillInfoPopNormalUI:hide(true)
		end
		if self.Pis_show then
			self.Pis_show = false
			self.skillInfoPopSpecialUI:hide(true)
		end
	end)
end

function SkillXiuLianLayer:setBtnBack()
	self.Button_back:releaseFunc(function()
		PopupLayerController:hideLayer("SkillXiuLianLayer",function()
			self:hide()
			local currMap = User:getRole():getCurrMap()
			if currMap then 
				currMap:doRoomConditionAndResult(currMap:getCurrRoomId())
			end
		end)
	end)
end

-- 黑条的显示隐藏控制
function SkillXiuLianLayer:lightTab(tabName)
	if PRINT_MODE == 1 then
		print("tabName = "..tostring(tabName))
	end
	local items = self.ListView_tab:getItems()
	for k, item in pairs(items) do
		if item:getName() == tabName then
			item:light()
		else
			item:dark()
		end
	end
end

-- 获取当前类型（角色技能栏目使用）
function SkillXiuLianLayer:getCurrSkillType(listName)
	if listName == nil and self._currSkillList ~= nil then
		listName = self._currSkillList.name
	end
	local skillType
	if listName == "拳脚" then
		skillType = "quanjiao1"
	elseif listName == "轻功" then
		skillType = "qinggong"
	elseif listName == "内功" then
		skillType = "neigong"
	elseif listName == "招架" then
		skillType = "zhaojia"
	elseif listName == "知识" then
		skillType = "zhishi"
	else
		skillType = "bingqi"
	end
	return skillType
end

-- 获取当前兵器技能类型
function SkillXiuLianLayer:getCurrBingQiType(skill,filterFun)
	if skill == nil then
		return "未知"
	end
	local skillType

	if tonumber(skill.multiEq) == 1 then
		--@RefType [app.models.role.Role#Role]
		local role = User:getRole()
		local tempExp = 0

		local tempList = {}

		for i,v in ipairs(skill.methods) do
			local temp = {
				name = "",
				exp = 0
			}
			

			if v == SKILL_METHOD_TYPE_NEIGONG or v == SKILL_METHOD_TYPE_QINGGONG or v == SKILL_METHOD_TYPE_QUANJIAO or v == SKILL_METHOD_TYPE_ZHAOJIA then
			elseif v == SKILL_METHOD_TYPE_JIAN then
				temp.name ="jianfa"
				temp.exp = Helper:getDef(role:getSkillExp("jibenjianfa"),0)
			elseif v == SKILL_METHOD_TYPE_GUN then
				temp.name ="gunfa"
				temp.exp = Helper:getDef(role:getSkillExp("jibengunfa"),0)
			elseif v == SKILL_METHOD_TYPE_DAO then
				temp.name ="daofa"
				temp.exp = Helper:getDef(role:getSkillExp("jibendaofa"),0)
			elseif v == SKILL_METHOD_TYPE_ANQI then
				temp.name ="anqi"
				temp.exp = Helper:getDef(role:getSkillExp("jibenanqi"),0)
			elseif v == SKILL_METHOD_TYPE_BIANFA then
				temp.name ="bianfa"
				temp.exp = Helper:getDef(role:getSkillExp("jibenbianfa"),0)
			elseif v == SKILL_METHOD_TYPE_SHUANGCHI then
				temp.name ="shuangchi"
				temp.exp = Helper:getDef(role:getSkillExp("jibenshuangchi"),0)
			elseif v == SKILL_METHOD_TYPE_QIN then
				temp.name ="qinfa"
				temp.exp = Helper:getDef(role:getSkillExp("jibenqinfa"),0)
			end

			table.insert( tempList ,temp)
		end

		local prepareList = role:getPrepareType(skill.id)

		if not MapIsEmpty(prepareList) then
			for _,preType in pairs(prepareList) do
				for _,v in ipairs(tempList) do
					if v.name == preType then
						if v.exp > tempExp then
							tempExp = v.exp
							skillType = v.name
						elseif v.exp == 0 and tempExp ==0 then
							skillType = v.name
						end
					end
				end
			end
		else
			for _,v in ipairs(tempList) do
				if v.exp > tempExp then
					tempExp = v.exp
					skillType = v.name
				elseif tempExp == 0 and tempExp == 0 then
					skillType = v.name
				end
			end
		end

		return skillType
	end

	for i,v in ipairs(skill.methods) do
		if v == SKILL_METHOD_TYPE_NEIGONG or v == SKILL_METHOD_TYPE_QINGGONG or v == SKILL_METHOD_TYPE_QUANJIAO or v == SKILL_METHOD_TYPE_ZHAOJIA then
		elseif v == SKILL_METHOD_TYPE_JIAN then
			skillType = "jianfa"
		elseif v == SKILL_METHOD_TYPE_GUN then
			skillType = "gunfa"
		elseif v == SKILL_METHOD_TYPE_DAO then
			skillType = "daofa"
		elseif v == SKILL_METHOD_TYPE_ANQI then
			skillType = "anqi"
		elseif v == SKILL_METHOD_TYPE_BIANFA then
			skillType = "bianfa"
		elseif v == SKILL_METHOD_TYPE_SHUANGCHI then
			skillType = "shuangchi"
		elseif v == SKILL_METHOD_TYPE_QIN then
			skillType = "qinfa"
		else
			-- 表示其他未填，有可能忘记填写了
			if PRINT_MODE == 1 then
				print("SkillXiuLianLayer:getCurrBingQiType(skill) -> 获取的技能类型未知")
			end
			skillType = "other"
		end
	end
	return skillType
end

-- 设置角色技能列表
--itemRole 假人信息
function SkillXiuLianLayer:showLayer(itemRole)
	self:show()
	-- 隐藏弹出框
	self:initPopUI()
	self.itemRole = itemRole
	-- self.itemRole.jjId = "jiaren001"
	-- self.itemRole.durable = 3
	 
	local role = User:getRole()
	local firstTitleBarFunc = nil
	self.ListView_tab:removeAllItems()

	-- 角色技能列表初始化
	local function initRoleSkils()
		local skillList = role:getSkills()
		local qjList, bqList, qgList, ngList, zjList, zsList = {}, {}, {}, {}, {}, {}
		for k,v in pairs(skillList) do
			local skill = Skill:getSkill(k)
			-- 知识类和特殊类放入知识类
			if skill.type == SKILL_TYPE_DUSHU or skill.type == SKILL_TYPE_SPECIAL or skill.type == SKILL_TYPE_HUIFU or skill.type == SKILL_TYPE_DUNDI or skill.type == SKILL_TYPE_ZHISHI then
				table.insert(zsList, v)
			elseif skill and skill.methods then
				for i,vtype in ipairs(skill.methods) do
					if vtype == SKILL_METHOD_TYPE_QUANJIAO then
						table.insert(qjList, v)
					elseif vtype == SKILL_METHOD_TYPE_NEIGONG then
						table.insert(ngList, v)
					elseif vtype == SKILL_METHOD_TYPE_QINGGONG then
						table.insert(qgList, v)
					elseif vtype == SKILL_METHOD_TYPE_ZHAOJIA then
						table.insert(zjList, v)
					else
						
						local temp = false
						for _,tempSkill in pairs(bqList) do
							if tempSkill.id == v.id then
								temp = true
							end
						end

						if temp == false then
							table.insert(bqList, v)
						end

					end
				end
			end
		end

		skillList =
		{
			{name = "拳脚", list = qjList},
			{name = "兵器", list = bqList},
			{name = "轻功", list = qgList},
			{name = "内功", list = ngList},
			{name = "招架", list = zjList},
			{name = "知识", list = zsList}
		}
		return skillList
	end

	local function sortSkill(listTab)
		if MapIsEmpty(listTab.list) == true then
			return listTab.list
		end
		local skillType = self:getCurrSkillType(listTab.name)
		local baseList, normalList = {}, {}

		for i, v in pairs(listTab.list) do
			local skill = Skill:getSkill(v.id)
			if skill.type == SKILL_TYPE_BASE then
				table.insert(baseList, v)
			else
				table.insert(normalList, v)
			end
		end

		if skillType == "bingqi" then
			table.sort(baseList, function(a, b)
				if a.exp == b.exp then
					return a.id > b.id
				else
					return a.exp > b.exp
				end
			end)
		end

		local rList = baseList
		if MapIsEmpty(normalList) == true then
			return rList
		end

		local tab =
		{
			jibendaofa = "daofa",
			jibenjianfa = "jianfa",
			jibenbianfa = "bianfa",
			jibengunfa = "gunfa",
			jibenanqi = "anqi",
			jibenshuangchi = "shuangchi",
			jibenqinfa = "qinfa",
			-- jibenquanjiao = "quanjiao",
			-- jibenneigong = "neigong",
			-- jibenqinggong = "qinggong",
			-- jibenzhaojia = "zhaojia",
		}

		local prepareList, unpareList = {}, {}
		for k,v in pairs(normalList) do
			if skillType == "bingqi" then
				-- 修复 没学基本功法特殊功法将不显示的 bug
				if MapIsEmpty(baseList) == true then
					table.insert(unpareList, v)
				else
					for i,v1 in ipairs(baseList) do
						if role:getPrepareSkill(tab[v1.id]) == v.id then
							table.insert(prepareList, v)
							break
						elseif i == #baseList then
							table.insert(unpareList, v)
						end
					end
				end
			elseif skillType == "quanjiao1" and (role:getPrepareSkill("quanjiao1") == v.id or role:getPrepareSkill("quanjiao2") == v.id) then
				table.insert(prepareList, v)
			elseif role:getPrepareSkill(skillType) == v.id then
				table.insert(prepareList, v)
			else
				table.insert(unpareList, v)
			end
		end

		table.sort( unpareList, function(a, b)
			if a.exp == b.exp then
				return a.id > b.id
			else
				return a.exp > b.exp
			end
		end)

		table.sort(prepareList,function(a, b)
			if a.exp == b.exp then
				return a.id > b.id
			else
				return a.exp > b.exp
			end
		end)
		
		normalList = prepareList
		for k,v in pairs(unpareList) do
			table.insert(normalList, v)
		end

		for k,v in pairs(normalList) do
			table.insert(rList, v)
		end
		return rList
	end

	local skills = initRoleSkils()
	for i,skillTab in ipairs(skills) do
		local skillTabBar = RoleSkillInfoTabBarUI:create()
		self.ListView_tab:pushBackCustomItem(skillTabBar)
		skillTabBar:setName(skillTab.name)

		if firstTitleBarFunc == nil then
			firstTitleBarFunc = function()
				if PRINT_MODE == 1 then
					print("查看"..tostring(role:getName()).."的招式")
				end
				self:lightTab(skillTab.name)
				self:setSkillList(role, skillTab)
			end
		end
		skillTab.list = sortSkill(skillTab)

		-- 点击触发
		skillTabBar:releaseFunc(
			function()
				if PRINT_MODE == 1 then
					print("查看"..tostring(role:getName()).."的招式")
				end
				Audio:playEffect("xiaoAnNiu")
				skillTab.list = sortSkill(skillTab)
				self:lightTab(skillTab.name)
				self:setSkillList(role, skillTab)

				self.Pis_show = false
				self.Nis_show = false
				self.skillInfoPopNormalUI:hide()
				self.skillInfoPopSpecialUI:hide()
			end
		)
	end

	firstTitleBarFunc()
end

-- 控制背景显示隐藏
function SkillXiuLianLayer:hideSkillListImageBack()
	local items = self.ListView_skillListArea:getItems()
	for k, item in ipairs(items) do
		item:setImageBack(false)
	end
end

-- 控制详细信息面板显示隐藏
function SkillXiuLianLayer:checkListView()
	local index = self.ListView_skillListArea:getCurSelectedIndex()
	if not self._laseIndex then
		self._laseIndex = index
	end

	if index ~= self._laseIndex then
		-- 都没有显示
		if not self.Nis_show and not self.Pis_show then
		elseif self.Nis_show then
			self.Nis_show = false
			self.skillInfoPopNormalUI:hide()
		elseif self.Pis_show then
			self.Pis_show = false
			self.skillInfoPopSpecialUI:hide()
		else
			self.Pis_show = false
			self.Nis_show = false
			self.skillInfoPopNormalUI:hide()
			self.skillInfoPopSpecialUI:hide()
		end
		self._laseIndex = index
		return true
	else
		if not self.Nis_show and not self.Pis_show then
			return true
		end
		if self.Nis_show then
			self.Nis_show = false
			self.skillInfoPopNormalUI:hide(true)
		end
		if self.Pis_show then
			self.Pis_show = false
			self.skillInfoPopSpecialUI:hide(true)
		end
		return false
	end
end

-- 设置技能列表
function SkillXiuLianLayer:setSkillList(role, skillList)
	if skillList == nil and not self._currSkillList then
		return
	elseif not skillList then
		skillList = self._currSkillList
	else
		self.__skillListPos = nil
	end
	self._currSkillList = skillList

	if MapIsEmpty(skillList.list) then
		self.ListView_skillListArea:removeAllItems()
		if self.listViewSchedule then
            self:unschedule(self.listViewSchedule)
            self.listViewSchedule = nil
        end
		return
	else
		for index, roleSkill in ipairs(skillList.list) do
			-- 即时更新面板经验值及等级状态
			do
				roleSkill = role:getSkill(roleSkill.id)
				skillList.list[index] = roleSkill
			end
		end
	end

	local skillInfoBarUI = RoleSkillInfoListBarUI

	self.ListView_skillListArea:setSwallowTouches(false)

	local roleItemNum = #skillList.list
    local listSize = self.ListView_skillListArea:getContentSize()
    local itemSize = skillInfoBarUI:create():getContentSize()
    local itemsMargin = self.ListView_skillListArea:getItemsMargin()
    local itemMaxCount = Helper:mathFloor(listSize.height/(itemSize.height + itemsMargin)) + 2
    local isSchedule = true

    if roleItemNum < itemMaxCount then
        itemMaxCount = roleItemNum
        isSchedule = false
    end

    self.ListView_skillListArea:setItemHeight(itemSize.height)

    self.ListView_skillListArea:setItemInitFunc(function(skillPanel,skillInfo)
        self:__initSkillPanelInfo(skillPanel,skillInfo,role,skillList.name)
    end)

    self.ListView_skillListArea:setItemCreateFunc(function()
        return skillInfoBarUI:create()
    end)

    self.ListView_skillListArea:showListView(skillList.list,itemMaxCount)

	if isSchedule then
        if self.__skillListPos then
            if self.__skillListPos.y > self.ListView_skillListArea:getInnerContainerPosition().y then
                self.ListView_skillListArea:setInnerContainerPosition(self.__skillListPos)
            end
        else
            self.ListView_skillListArea:jumpToTop()
        end

        local isTrue = self.ListView_skillListArea:refreshReuseItems()
		while isTrue do
			isTrue = self.ListView_skillListArea:refreshReuseItems()
		end

        if self.listViewSchedule then
            self:unschedule(self.listViewSchedule)
            self.listViewSchedule = nil
        end

        self.listViewSchedule = self:schedule(function()
            self.ListView_skillListArea:refreshReuseItems()
            self.__skillListPos = self.ListView_skillListArea:getLastInnerContainerPosition()
        end)
    end
end

function SkillXiuLianLayer:__initSkillPanelInfo(skillPanel,roleSkill,role,skillListName)
    local skill = Skill:getSkill(roleSkill.id)
	local skillLv
	if skill:checkIsSpecialZhiShiSkill() then
		skillLv = role:getSpecialZhiShiSkillLv(roleSkill.id)
	else
		skillLv = role:getSkillLvWithRoleLvLimit(roleSkill.id)
	end
	
	skillPanel:setExpDsc(skillLv.."级")

	skillPanel:setName(skill:getName())
	skillPanel:setStageDsc(skill:getStageDsc(role))
	skillPanel:setImageBack(false)

	skillPanel:releaseFunc(
		function()
			if self:checkListView() then
				Audio:playEffect("daAnNiu")

				self:showSkillInfo(roleSkill)

				self:hideSkillListImageBack()

				skillPanel:setImageBack(true)
			end
		end)


	-- 技能准备状态控制
	if role:getName() == User:getRole():getName() or role.id == User:getRole().id then
		local prepareSkills = role:getSkillPrepare()
		local itemType = self:getCurrSkillType(skillListName)
		local state = false

		for k,v in pairs(prepareSkills) do
			if prepareList[k] ~= nil then
				if (k == itemType or (k == "quanjiao2" and itemType == "quanjiao1")) and ((skill.type == SKILL_TYPE_BASE and prepareList[k] == skill.id) or v == skill.id) then
					state = true
			elseif itemType == "bingqi" and ((skill.type == SKILL_TYPE_BASE and prepareList[k] == skill.id) or v == skill.id) and (k ~= "quanjiao1" and k ~= "quanjiao2" and k ~= "zhaojia" and k ~= "neigong" and k ~= "qinggong") then
					state = true
				end
			end
		end
		skillPanel:setDian(state)
	end
end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------                    练功闭关控制部分                             ------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

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
	dialogC:setDescTextVisible(params.descTextVisible)
	dialogC:unscheduleAll()
	dialogC:schedule(
		function(ft)
			params.update()
		end, 1)
end

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


-------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------                    练功             -----------------------------------------------------
-- 判断练功前置条件
function SkillXiuLianLayer:checkForBeforXiuLian(skill)
	-- 暂时不用该判断
	if true then
		return true
	end

	if skill == nil then
		return false
	end
	local role = User:getRole()
	-- 练习前置武功条件  暂时判断10个
	for i=1,10 do
		local skillName = skill["practiceSkill"..i]
		local lv = skill["practiceSkillLv"..i]
		if skillName and string.len(skillName) >= 1 then
			if PRINT_MODE == 1 then
				print(skillName)
			end
			local roleSkill = role:getSkill(skillName)
			local skill = Skill:getSkill(skillName)
			if not roleSkill then
				PopText("【"..skill:getName().."】技能火候不足")
				return false
			end
			if tonumber(lv) ~= nil then
				lv = role:getSkillLv(roleSkill.id) + lv
				-- lv = Skill:getLv(roleSkill.exp) + lv
			else
				lv = role:getSkillLv(roleSkill.id)
			end
			if lv <= skillLv then
				PopText("【"..skill:getName().."】技能火候不足")
				return false
			end
		else
			break
		end
	end
	return true
end


--获取基本武功等级
function SkillXiuLianLayer:getjibenLvAndPrepareType(skill)
	if skill == nil then
		return nil
	end
	-- 判断技能是否准备上了 (需对应当前技能类型)

	local role = User:getRole()
	local currType = self:getCurrSkillType()
	-- 如果为空，则出现了异常
	if currType == nil then
		if PRINT_MODE == 1 then
			
		end
		print("数据出现了异常，请检查")
		return
	else
		-- 兵器时需要额外获取类型
		if currType == "bingqi" then
			currType = self:getCurrBingQiType(skill)
		end

		if  currType == "zhishi" or  currType == "neigong" then
			return
		end
	end
	-- 判断是否超过基本功法
	-- local jiBen = role:getSkill(prepareList[currType])
	-- if jiBen == nil then
	-- 	return nil
	-- end
	-- local jiBenLv = Skill:getLv(jiBen.exp)
	
	-- prepareList[currType] 为nil时 无法弹出 正在练功 的详情界面
	if not prepareList[currType] then
		return
	end
	local jiBenLv = role:getSkillLv(prepareList[currType])
	return jiBenLv, currType
end

local function checkIsNeiGong(skill)
	if skill == nil then
		return false
	end

	-- 检查武功是否为内功
	local methods = skill.methods
	if MapIsEmpty(methods) == false then
		for k,v in pairs(methods) do
			if v == SKILL_METHOD_TYPE_NEIGONG then
				return true
			end
		end
	end
	return false
end

-- 练功判断
function SkillXiuLianLayer:canXiuLian(roleSkill)
	if self.itemRole.durable <=0 then 
		PopText("耐久度不足")
		return
	end
	local role = User:getRole()
	local skill, skillLv = Skill:getSkill(roleSkill.id), Skill:getLv(roleSkill.exp)
	local params = {}

	-- 内功类型不能练功
	if checkIsNeiGong(skill) == true then
		PopText("内功类型的功法不能修炼")
		return false
	end

	local currSkillId 

	if role:isInCurrState(ROLE_CURR_STATE_XIULIAN) then
		currSkillId = role:getXiuLianSystem():getSkillId()
	end

	-- 当前武功存在
	if currSkillId then
		-- 练功的技能和当前的技能是同一个技能时，不需要做任何判断
		if currSkillId == skill.id then
			return true
		else
			local currSkill = Skill:getSkill(currSkillId)
			PopText("正在修炼"..currSkill.name)
			return false
		end
	end

	if role:isInCurrState(ROLE_CURR_STATE_LIANGONG) then
		PopText("正在修习其他功法")
		return false
	end

	local skillType = self:getCurrSkillType()
	if skillType == "bingqi" then
		-- 兵器需要获取兵器类型 （兵器类型是唯一的）
		skillType = self:getCurrBingQiType(skill)
	elseif skillType == "quanjiao1" then
		--@desc 增加拳脚自动判断是否互备的功能
		skillType = self:getCurrQuanJiaoType(skill)
	end
	-- 判断是否超过基本功法
	local breakLv= 1   --特殊道具可以突破等级上限
	breakLv = SkillXiuLianUtil:getRoleItemLvBuff(self.itemRole.jjId)
	local jiBen = role:getSkill(prepareList[skillType])

	if not jiBen or not jiBen.exp or skillLv >= role:getSkillLvLimit(jiBen.id) + 1 or skillLv >= (Skill:getLv(jiBen.exp) + breakLv) then
		PopText("你的基本功火候未到，必须先打好基础才能继续提高。")
		return false
	end
	

	if skillLv >= role:getLv() then
		PopText("你的实战经验不足，你的练习总没法进步。")
		return false
	end

	if self:checkForBeforXiuLian(skill) == false then
		return false
	end

	if skillLv >= role:getSkillLvLimit(skill.id) then
		PopText("已经达到该武学最高等级，无法修炼")
		return false
	end

	return true
end
-------------------------------------------------------------------------------------------------------------------------------------------------------------
 
--参数  name
function SkillXiuLianLayer:getEventFunc(roleSkill,name,skillState)
	self:hideSkillInfo()
	if not name then
		return
	end

	local role = User:getRole()
	local skill, skillLv = Skill:getSkill(roleSkill.id), Skill:getLv(roleSkill.exp)

	--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	------   修炼--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	if name == "修炼" and self:canXiuLian(roleSkill) == true then
		Audio:playEffect("daAnNiu")
		if role:isInCurrState(ROLE_CURR_STATE_XIULIAN) then
			role:getXinShenSystem():getXinShenValue(function(ok, data)
				if ok then
					role:getXiuLianSystem():getXiuLianTiLi(function(ok,errmsg,tiliData)
						if ok then
							PopupLayerController:showLayer("XiuLianDetailPresenter",function(layer)
								layer:setXinShen(data.curr)
								layer:setXinShenMax(data.max)
								layer:setTiLi(tiliData.currTiLi)
								layer:setTiLiMax(tiliData.maxTiLi)
								layer:showLayer()
								layer:setCallBack(function()
									self:hideSkillInfo()
									self:setSkillList(role)
								end)
							end)
						else
							PopText(errmsg)
						end
					end)
				else
					local msg = data
					PopText(msg)
				end
			end)
		else
			role:getXinShenSystem():getXinShenValue(function(ok, data)
				if ok then
					role:getXiuLianSystem():getXiuLianTiLi(function(ok,errmsg,tiliData)
						if ok then
							local jiBenLv,skillType = self:getjibenLvAndPrepareType(skill)
							PopupLayerController:showLayer("XiuLianPresenter",function(layer)
								layer:setXinShen(data.curr)
								layer:setXinShenMax(data.max)
								layer:setTiLi(tiliData.currTiLi)
								layer:setTiLiMax(tiliData.maxTiLi)
								layer:setJiBenSkillLv(jiBenLv)
								layer:showLayer(roleSkill.id,self.itemRole)
								layer:setCallBack(function()
									if data.curr <= 0 then
										PopText("你的心神不足，无法静下心来修习功法。")
										return
									end
									local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
									local dialog = DialogALayer:getInstance()
									dialog:hide()
									dialog:show("修炼时长不足一分钟时手动结束无收益，开始修炼时加速练功的精力会全部消耗，本次修炼会上传存档，少侠是否确认开始修炼？")
									dialog:setButton1("确定",function()
										RoleTaskControllor:clickXiuLianLayer(skill.id, 
											function()
												HttpManagerEx:uploadUserData("shangchuan", function(status, errcode, errmsg, data, isEncrypted)
													if status == 200 and errcode == 0 then
														role:getXiuLianSystem():startXiuLianOnline(skillType,function(ok, msg)
															if ok then
																self:showSkillInfo(role:getSkill(roleSkill.id))
																
																RichPrint("main", "HIC你摩拳擦掌，开始对着"..self.itemRole.name.."操练了起来。NOR")
															else
																PopText(msg)
															end
														end)
													else
														PopText(errmsg)
													end
												end, IS_SHOW_WAITING)
											end,
											function()
												self:getEventFunc(roleSkill, "修炼","timeSelected")
											end,
											function()
												self:hideSkillInfo()
												self:setSkillList(User:getRole())
											end,
											function()
												self:hideSkillInfo()
												self:setSkillList(User:getRole())
											end
										)
									end)
									dialog:setButton2("取消",function()
									end)
									dialog:setWeChatVisible(false)
								end)
							end)
						else
							PopText(errmsg)
						end
					end)
				else
					local msg = data
					PopText(msg)
				end
			end)
		end

		-- local xiuLianBtnFunc = function(selectTime)
		-- 	if selectTime == 0 then 
		-- 		return
		-- 	end
		-- 	--需更新当前耐久度
		-- 	self:refreshItemRoleInfo()
		-- 	self.currSelectTime = selectTime
		-- 	skillLv = Skill:getLv(roleSkill.exp)
		-- 	local cLv = role:getSkillLv("changshengjueyang")
		-- 	if cLv >= 600 then
		-- 		role:setFlag("练功长生诀等级",cLv)
		-- 	end
		-- 	--NEEDTODO 解析技能列表，找到当前的所有技能，然后获取技能等级
		-- 	--   对应技能等级和基础等级，技能等级不能超过基础等级+1

		-- 	local jbLv,skillType = self:getjibenLvAndPrepareType(skill)
		-- 	role:setFlag("武功修炼类型", skillType)
		-- 	local afterLv,needTime,actualNeedJing,actualNeedDurable,limitType = SkillXiuLianUtil:getXiuLianActualSkillInfo(roleSkill.id,self.itemRole,selectTime)

		-- 	if afterLv == nil or needTime == nil or needTime <=0 then
		-- 		return
		-- 	end
		-- 	-- 秒
		-- 	local time, hour, min, sec
		-- 	local showTime = needTime
		-- 	--对不足一秒的显示为一秒
		-- 	if showTime>0 and showTime<1 then 
		-- 		showTime = 1
		-- 	end
		-- 	hour = math.floor(showTime/3600)
		-- 	min = math.floor(math.mod(showTime/60, 60))
		-- 	sec = math.floor(math.mod(showTime, 60))
		-- 	time = hour.."小时"..min.."分钟"..sec.."秒"

		-- 	local currDurable,afterDurable = self.itemRole.durable,math.max(self.itemRole.durable-SkillXiuLianUtil:getXiuLianNeedDurable(needTime),0)
		-- 	local title, list, butn1, func1, butn2, func2,butn3,func3
		-- 	--self.afterDurable = afterDurable
		-- 	-- 最高等级不能超过基础内功等级
		-- 	if PRINT_MODE == 1 then 
		-- 		print("---------------role:getAttr:",role:getAttr("jing"),"actualNeedJing:",actualNeedJing)
		-- 	end
			
		-- 	if role:isInCurrState(ROLE_CURR_STATE_XIULIAN) then
		-- 		if self._skillToLv then 
		-- 			afterLv = self._skillToLv --直接使用记录时间 防止因为出现计算误差显示不一致
		-- 		end
		-- 		title = "修炼中"
		-- 		list =
		-- 		{
		-- 			{title = "精力：", num = tostring(math.floor(role:getAttr("jing"))).."→"..tostring(math.floor(math.max(role:getAttr("jing")-actualNeedJing,0)))},
		-- 			{title = "假人耐久：", num = math.floor(currDurable).."→"..math.floor(afterDurable)},
		-- 			{title = "修炼时间：", num = time},
		-- 			{title = "武功：", num = skill.name},
		-- 			{title = "等级：", num = skillLv.."→"..afterLv},
		-- 		}
		-- 		butn1 = "结束修炼"
		-- 		func1 = function()
		-- 			role:stopXiuLian()
		-- 			self._stata = nil
		-- 			self._skillToLv = nil
		-- 			self:hideSkillInfo()
		-- 			self:setSkillList(role)
		-- 		end
		-- 		butn2 = "关闭"
		-- 		func2=function()
		-- 			self:setSkillList(role)
		-- 		end
		-- 	else
		-- 		title = "你要开始修炼"..skill.name.."吗？"				-- 标题
		-- 		list = 												-- 内容列表
		-- 		{
		-- 			{title = "精力：", num = tostring(math.floor(role:getAttr("jing"))).."→"..tostring(math.floor(math.max(role:getAttr("jing")-actualNeedJing,0)))},
		-- 			{title = "假人耐久：", num =  math.floor(currDurable).."→"..math.floor(afterDurable)},
		-- 			{title = "修炼时间：", num = time},
		-- 			{title = "武功：", num = skill.name},
		-- 			{title = "等级：", num = skillLv.."→"..afterLv},
		-- 		}
		-- 		--使用分身符后，显示信息，并直接进入练功阶段

		-- 		butn1 = "开始"
		-- 		func1 = function()
		-- 			RoleTaskControllor:clickXiuLianLayer(skill.id, 
		-- 				function()
		-- 					SkillXiuLianUtil:startXiuLian(roleSkill.id,self.itemRole,needTime)
		-- 					roleSkill.startTime = GetTime()
		-- 					roleSkill.toLv = afterLv
		-- 					self._skillToLv = afterLv
		-- 					roleSkill.state = ROLE_CURR_STATE_XIULIAN
		-- 					self:xiuLian(roleSkill)
		-- 					self:showSkillInfo(role:getSkill(roleSkill.id))
		-- 				end,
		-- 				function()
		-- 					self:getEventFunc(roleSkill, "修炼","timeSelected")
		-- 				end,
		-- 				function()
		-- 					self:hideSkillInfo()
		-- 					self:setSkillList(User:getRole())
		-- 				end,
		-- 				function()
		-- 					self:hideSkillInfo()
		-- 					self:setSkillList(User:getRole())
		-- 				end
		-- 			)
		-- 		end
		-- 		butn2 = "取消"
		-- 	end

		-- 	if limitType == 1 then 
		-- 		list[1].num = "RED"..list[1].num
		-- 	elseif limitType ==2 then 
		-- 		list[2].num = "RED"..list[2].num
		-- 	elseif limitType ==3 then
		-- 		list[5].num = "RED"..list[5].num
		-- 	end

		-- 	if SkillXiuLianUtil:checkIsSpecailItem(self.itemRole.jjId) then 
		-- 		list[2].num = "不损耗耐久"
		-- 	end
			
		-- 	local params =
		-- 	{
		-- 		title = title,
		-- 		list = list,
		-- 		butn1 = butn1,
		-- 		func1 = func1,
		-- 		butn2 = butn2,
		-- 		butn3 = butn3,
		-- 		func2 = func2,
		-- 		func3 = func3,
		-- 		descTextVisible = false
		-- 	}

		-- 	setDialogC(params)
		-- end
		-- local btnList = {
		-- 	{name = "一小时",index = 3600.0},
		-- 	{name = "五小时",index = 18000.0},
		-- 	{name = "十小时",index = 36000.0},
		-- 	{name = "取消",index = 0},
		-- }
		
		-- if role:isInCurrState(ROLE_CURR_STATE_XIULIAN) then 
		-- 	local xiuLianData = role:getAttr("xiuLianData")
		-- 	if MapIsEmpty(xiuLianData) ==false then 
		-- 		local needTime  = xiuLianData.endTime - GetTime()
		-- 		xiuLianBtnFunc(needTime)
		-- 	else
		-- 		print("------------出错了")
		-- 	end
		-- elseif skillState == "timeSelected" and self.currSelectTime then 
		-- 	xiuLianBtnFunc(self.currSelectTime)
		-- else
		-- 	PopupLayerController:showLayer("ItemSelectAutoFitLayer",function ( layer )
		-- 		layer:setBtnClickFunc(
		-- 			function ( index )
		-- 				xiuLianBtnFunc(index)
		-- 				layer:hideLayer()
		-- 			end
		-- 		)
		-- 		layer:setList(btnList)
		-- 		layer:setTitle("请选择修炼时长")
		-- 		layer:showLayer()
		-- 	end)
		-- end
	end
end

--
function SkillXiuLianLayer:xiuLian(roleSkill)
	self._stata = "xiulian"
	local role = User:getRole()
	local skill = Skill:getSkill(roleSkill.id)
	local currItemName = self.itemRole.name
	RichPrint("main", "HIC你摩拳擦掌，开始对着"..currItemName.."操练了起来。NOR")
	self:showSkillInfo(role:getSkill(roleSkill.id))
end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 显示特殊类型的技能信息
function SkillXiuLianLayer:popSpecialInfo(params)
	if params == nil then
		return false
	end
	self.skillInfoPopSpecialUI:setName(params.name)
	self.skillInfoPopSpecialUI:setSkillStageDsc(params.desc)
	self.skillInfoPopSpecialUI:setSkillDetailDsc(params.dsc)
	self.skillInfoPopSpecialUI:setSkillExpDsc(params.expDsc)
	self.skillInfoPopSpecialUI:setButton1(params.butn1, params.func1)
	self.skillInfoPopSpecialUI:setTextDesc1(params.costDesc1)
	self.skillInfoPopSpecialUI:setButton2(params.butn2, params.func2)
	self.skillInfoPopSpecialUI:setTextDesc2(params.costDesc2)
	self.skillInfoPopSpecialUI:setActiveZhaoList(params.zhaoList)
	self.skillInfoPopSpecialUI.Image_infoArea:releaseFunc(
	function()
		-- Audio:playEffect("daAnNiu")
		self.skillInfoPopSpecialUI:hide(true)
		self.Pis_show = false

		self.skillInfoPopSpecialUI:unscheduleAll()
	end)
	if not self.Pis_show then
		self.Pis_show = true
		self.skillInfoPopSpecialUI:show(true)
	end

	--界面时间倒计时
	if  params.update == nil then
		params.update = function()end
	end
	self.skillInfoPopSpecialUI:unscheduleAll()
	self.skillInfoPopSpecialUI:schedule(
		function(ft)
			params.update()
		end,1)

end

-- 显示普通类型的技能信息
function SkillXiuLianLayer:popNormalInfo(params)
	if params == nil then
		return false
	end
	self.skillInfoPopNormalUI:setName(params.name)
	self.skillInfoPopNormalUI:setSkillStageDsc(params.desc)
	self.skillInfoPopNormalUI:setSkillDetailDsc(params.dsc)
	self.skillInfoPopNormalUI:setSkillExpDsc(params.expDsc)
	self.skillInfoPopNormalUI:setButton1(params.butn1, params.func1)
	self.skillInfoPopNormalUI:setTextDesc1(params.costDesc1)
	self.skillInfoPopNormalUI:setButton2(params.butn2, params.func2)
	self.skillInfoPopNormalUI:setTextDesc2(params.costDesc2)
	self.skillInfoPopNormalUI.Image_infoArea:releaseFunc(
	function()
		-- Audio:playEffect("daAnNiu")
		self.skillInfoPopNormalUI:hide(true)
		self.Nis_show = false
	end)
	if not self.Nis_show then
		self.Nis_show = true
		self.skillInfoPopNormalUI:show(true)
	end
end


function SkillXiuLianLayer:getCurrQuanJiaoType(skill)
	local role = User:getRole()

	local skillType = "quanjiao1"

	local pre1st = role:getPrepareSkill("quanjiao1")
						
	local pre2nd = role:getPrepareSkill("quanjiao2")
	
	if pre1st == skill.id then
		skillType = "quanjiao1"
	elseif pre2nd == skill.id then
		skillType = "quanjiao2"
	else
		if pre1st == nil or (pre1st == nil and pre2nd == nil) then
			skillType = "quanjiao1"
		elseif pre1st ~= nil and pre2nd == nil then
			local zuoyouHB = role:isHaveImprintingId("zuoyouhuboyin")
			if zuoyouHB == true then
				skillType = "quanjiao2"
			else
				local skill_1st = Skill:getSkill(pre1st)

				if skill_1st.combob and string.len(skill_1st.combob) >= 1 then
					local combobSkill = role:getSkill(skill_1st.combob)

					if combobSkill and skill_1st.combob == skill.id then
						skillType = "quanjiao2"
					else
						skillType = "quanjiao1"
					end
				else
					skillType = "quanjiao1"
				end
			end
		else
			skillType = "quanjiao1"
		end
	end

	return skillType
end

-- 检查技能是否已经准备
function SkillXiuLianLayer:checkSkillIsPrepared(role, skill)
	if role == nil or skill == nil then
		return false
	end

	local currType = self:getCurrSkillType()
	-- 拳脚需要考虑拳脚2的情况
	if currType == "quanjiao1" then
		local prepareSkill1 = role:getPrepareSkill("quanjiao1")
		local prepareSkill2 = role:getPrepareSkill("quanjiao2")
		if prepareSkill1 == skill.id or prepareSkill2 == skill.id then
			return true
		else
			return false
		end
	elseif currType == "bingqi" then
		-- 兵器需要获取兵器类型 （兵器类型是唯一的）
		currType = self:getCurrBingQiType(skill)
	end

	local prepareSkill = role:getPrepareSkill(currType)
	if prepareSkill == skill.id then
		return true
	else
		return false
	end
end

-- 显示玩家自己的技能详细
function SkillXiuLianLayer:showRoleSkillInfo(role, roleSkill, expDsc)
	if role == nil or roleSkill == nil then
		return
	end

	local skill = Skill:getSkill(roleSkill.id)
	local skillType = self:getCurrSkillType()
	if skillType == "bingqi" then
		-- 兵器需要获取兵器类型 （兵器类型是唯一的）
		skillType = self:getCurrBingQiType(skill)
	elseif skillType == "quanjiao1" then
		--@desc 增加拳脚自动判断是否互备的功能
		skillType = self:getCurrQuanJiaoType(skill)
	end

	local name, desc, dsc, butn1, func1, butn2, func2, costDesc1, costDesc2,update
	name = skill.name
	desc = skill:getStageDsc(role)
	dsc = skill.dsc

	-- expDsc = math.floor(skillExp).."/"..skillLv.."级"
	-- 基本类型 只有研究功能  研究不能超过等级上限
	if skill.type == SKILL_TYPE_BASE and skill.id ~= "jibenneigong" then
	else
		-- 特殊类型  左边按钮只有准备  右边按钮有 闭关 和 练功
		-- 左按钮
		-- 基本内功特殊处理
		--and skillType ~= "neigong" 
		if skillType ~= "zhishi"  then
			if skill.id ~= "jibenneigong" then
				butn1 = "装武\n备功"

				if self:checkSkillIsPrepared(role, skill) == true then
					butn1 = "取装\n消备"
				end
				func1 = function()
					Audio:playEffect("daAnNiu")
					PopupLayerController:showLayer("GlobalShadeLayer",function (layer)
						layer:setPopText("")
						layer:showLayer()
					end)
					if self:checkSkillIsPrepared(role, skill) == true then
						role:prepareSkill(skillType, nil)
					else
						role:prepareSkill(skillType, skill.id)
					end
					self:setSkillList(role)
					self:showSkillInfo(role:getSkill(roleSkill.id))
					PopupLayerController:hideLayer("GlobalShadeLayer",function (layer)
						layer:hideLayer()
					end)
				end
			end
			-- 非内功是练功
			local currSkillId
			if role:isInCurrState(ROLE_CURR_STATE_XIULIAN) then
				currSkillId = role:getXiuLianSystem():getSkillId()
			end

			-- 内功不能修炼
			if checkIsNeiGong(skill)==false then 
				butn2 =  "修炼"
				if currSkillId and currSkillId == skill.id then
					butn2 = "正修\n在炼"
				end
				func2 = function()
					Audio:playEffect("daAnNiu")
					self:getEventFunc(roleSkill,  "修炼")
				end
			end
		end
	end
	local params =
	{
		name = name,
		desc = desc,
		dsc = dsc,
		expDsc = expDsc,
		butn1 = butn1,
		func1 = func1,
		butn2 = butn2,
		func2 = func2,
		costDesc1 = costDesc1,
		costDesc2 = costDesc2,
		zhaoList = role:getSkillZhaoList(skill.id),
		update = update
	}
	if skill.type == SKILL_TYPE_BASE  then
		self:popNormalInfo(params)
	else
		self:popSpecialInfo(params)
	end
end

-- 隐藏技能详细
function SkillXiuLianLayer:hideSkillInfo()
	self.skillInfoPopNormalUI:hide(true)
	self.Nis_show = false
	self.skillInfoPopSpecialUI:hide(true)
	self.Pis_show = false
end

-- 显示技能详细
function SkillXiuLianLayer:showSkillInfo(roleSkill)
	if roleSkill == nil then
		return
	end
	local role = User:getRole()

	self._currSkill = roleSkill

	local skillLv,skillExp

	local skill = Skill:getSkill(roleSkill.id)

	if skill:checkIsSpecialZhiShiSkill() then
		skillLv = role:getSpecialZhiShiSkillLv(roleSkill.id)
	else
		skillLv = role:getSkillLvWithRoleLvLimit(roleSkill.id)
	end

	skillExp = role:getSkillExp(roleSkill.id)

	self:showRoleSkillInfo(role, roleSkill, math.floor(skillExp).."/"..skillLv.."级")

end

function SkillXiuLianLayer:refreshItemRoleInfo()
	local role = User:getRole()
	local xiuLianData = role:getAttr("xiuLianData")
	if MapIsEmpty(xiuLianData) == false and role:isInCurrState(ROLE_CURR_STATE_XIULIAN) and xiuLianData.durable then 
		self.itemRole.durable = xiuLianData.durable
	end
end

function SkillXiuLianLayer:update()
	local role = User:getRole()
	if role:isInCurrState(ROLE_CURR_STATE_XIULIAN) then 
		self:setSkillList(role)
	elseif self._stata == "xiulian" then
		self._stata = nil 
		self._skillToLv = nil
		self:hideSkillInfo()
		self:setSkillList(role)
	end
end

Helper:classDefNodeGetInstance(SkillXiuLianLayer)
-- 加密标记
SkillXiuLianLayer.isEncrypted = true
return SkillXiuLianLayer
0000000000