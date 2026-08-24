local LoadingBarButton = require("app.views.ui.Button.LoadingBarButton")
local RoleStatePanel = require("app.views.ui.FightUI.RoleStatePanel")

local RECORD_FIGHT_STATUS_STRING_LINE_MAX = 50

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 战斗层
local FightUI = class("FightUI", LayerEx)

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 测试
function FightUI.test()
	local FightUI = FightUI:getInstance()
	FightUI:show()
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 创建实例
function FightUI:create()
	local p = FightUI.new()
	p:init()
	return p
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 构造
function FightUI:ctor()
	self._currLeftRoleCount = 0
	self._currRightRoleCount = 0
	
	--　战斗UI主动按钮引用map
	self._activeButtonMap = {}
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 初始化
function FightUI:init()
	self:initUI()
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 初始化UI
function FightUI:initUI()
	self._UI = require("Layer/FightUI/FightUI1.lua").create() ['root']
	self._UI:addTo(self)
	Helper:convertUIByParent(self)
	
	-- 初始化富文本
	self:initRichText()
	
	do -- 隐藏回复和逃跑按钮 add by TangJian 2017/03/11 20:02:19
		self.Panel_buttonArea.Panel_huifu:setVisible(false)
		self.Panel_buttonArea.Button_runaway:setVisible(false)
	end
	
	do -- 去除scrollview的进度条 和 触摸
		self.Panel_stateArea.ListView_left:setScrollBarEnabled(false)
		self.Panel_stateArea.ListView_left:setTouchEnabled(false)
		self.Panel_stateArea.ListView_right:setScrollBarEnabled(false)
		self.Panel_stateArea.ListView_right:setTouchEnabled(false)
	end
	
	do -- 设置角色状态面板
		self:initRoleStatePanel(5, 5)
		-- for i = 1, 5 do
		--     self:setRoleState("left" .. i, "name", "左"..i)
		-- end
		-- for i = 1, 5 do
		--     self:setRoleState("right" .. i, "name", "右"..i)
		-- end
	end
	
	-- 经脉印记相关ui初始化
	self:initJingMai()
	-- 创建效果额外展示文本
	self:createRoleEffectText()
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/23 16:48:41
-- @desc 初始化richtext
function FightUI:initRichText()
	if self.richPrint then
		self.richPrint:removeFromParent()
		self.richPrint = nil
	end
	self.Image_print.Text_print:setVisible(false)
	self.richPrint = ExtRichTextScroll:create()
	self.Image_print:addChild(self.richPrint)
	
	local size = self.Image_print.Text_print:getContentSize()
	local x, y = self.Image_print.Text_print:getPosition()
	
	-- 设置richtext位置到self.Image_2.Text_1中心位置
	self.richPrint:setPosition(cc.p(x - size.width / 2, y - size.height / 2))
	self.richPrint:setSize(size)
	self.richPrint:setScrollBarEnabled(false)
	self.richPrint:getRichText():setVerticalSpace(5)
	
	-- 设置最大显示高度
	self.richPrint:setTextMaxHeight(size.height)
	
	-- 记录文本, 用作战斗结束回顾
	self.richPrint.fightStatusStringArray = {}
	
	self.richPrint.scheduleHandle = self:scheduleUnique(function(elapsed)
		self.richPrint:scrollToBottom(0, false)
		self.richPrint:jumpToBottom()
	end, 0, "self.richPrint:setPosition")
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/23 16:11:50
-- @desc 显示按钮区域
function FightUI:setButtonAreaVisble(b)
	self.Panel_buttonArea:setVisible(b)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/23 16:38:17
-- @desc 播放战斗结束显示文本动画
function FightUI:showFightEndTextArea()
	self.Panel_fightEndTextArea:setTouchEnabled(false)
	self.Panel_fightEndTextArea:setVisible(true)
	self.Panel_fightEndTextArea:setScale(0.8)
	self.Panel_fightEndTextArea:runActionWithName("showFightEndTextArea", cc.Sequence:create(
	cc.ScaleTo:create(0.1, 1.2),
	cc.ScaleTo:create(0.1, 1),
	
	cc.CallFunc:create(function()
		self.Panel_fightEndTextArea:setTouchEnabled(true)
	end)
	))
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/23 15:39:01
-- @desc 显示战斗结束文本区域
function FightUI:setFightEndTextAreaVisble(b)
	self.Panel_fightEndTextArea:setVisible(b)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/23 16:41:21
-- @desc 显示战斗结束文本区域是否可以交互
function FightUI:setFightEndTextAreaTouchEnabled(b)
	self.Panel_fightEndTextArea:setTouchEnabled(b)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/23 16:21:43
-- @desc 设置战斗结束文本
function FightUI:setFightEndTextAreaText(textId, str)
	local text = self.Panel_fightEndTextArea["Text_" .. tostring(textId)]
	if text and type(text.setString) == "function" then
		text:setString(str)
	else
		error("FightUI:setFightEndTextAreaText(textId, str)")
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/23 15:40:43
-- @desc 设置战斗结束文本区域的触摸回调方法
function FightUI:setFightEndTextAreaReleaseFunc(releaseFunc)
	self.Panel_fightEndTextArea:releaseFunc(releaseFunc)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 输出文本
local textColor = cc.c3b(159, 159, 159)-- 战斗输出默认文字颜色
local textFont = nil
function FightUI:print(str)
	str = tostring(str)
	
	if textFont == nil then
		textFont = Resource:getFontPath("default")
	end
	
	-- 记录战斗字符串
	if self.richPrint.fightStatusStringArray then
		if #self.richPrint.fightStatusStringArray >= RECORD_FIGHT_STATUS_STRING_LINE_MAX then -- 长度超过上限, 需要移除老的记录
			table.remove(self.richPrint.fightStatusStringArray, 1)
		end
		table.insert(self.richPrint.fightStatusStringArray, str .. "NOR\n")
	end
	
	self.richPrint:pushBackText(str, textColor, 255, textFont, 42)
	self.richPrint:pushBackNewLine(0)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/23 16:55:52
-- @desc 得到战斗状态字符串
function FightUI:getFightStatusString()
	local maxLine = RECORD_FIGHT_STATUS_STRING_LINE_MAX
	if type(self.richPrint.fightStatusStringArray) == "table" then
		if #self.richPrint.fightStatusStringArray > maxLine then
			local from, to = Helper:getRange(#self.richPrint.fightStatusStringArray - maxLine, 0, maxLine), #self.richPrint.fightStatusStringArray
			return table.concat(self.richPrint.fightStatusStringArray, nil, from, to)
		else
			return table.concat(self.richPrint.fightStatusStringArray)
		end
	else
		return ""
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/23 17:08:12
-- @desc 富文本中显示战斗所有文本
function FightUI:richTextShowAllFightStatusString()
	local fightStatusString = self:getFightStatusString()
	local scheduleHandle = self.richPrint.scheduleHandle
	
	if self.richPrint then
		self.richPrint:removeFromParent()
		self.richPrint = nil
	end
	self.Image_print.Text_print:setVisible(false)
	self.richPrint = ExtRichTextScroll:create()
	self.Image_print:addChild(self.richPrint)
	
	local size = self.Image_print.Text_print:getContentSize()
	local x, y = self.Image_print.Text_print:getPosition()
	
	-- 设置richtext位置到self.Image_2.Text_1中心位置
	self.richPrint:setPosition(cc.p(x - size.width / 2, y - size.height / 2))
	self.richPrint:setSize(size)
	self.richPrint:getRichText():setVerticalSpace(5)
	
	-- 设置最大显示高度
	self.richPrint:setTextMaxHeight(9999999999)
	
	self:print(fightStatusString)
	
	self:delayFunc(0.1, function()
		self:unschedule(scheduleHandle)
	end)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 添加角色状态显示条目
function FightUI:initRoleStatePanel(leftRoleCount, rightRoleCount)
	leftRoleCount = Helper:getRange(Helper:getDef(leftRoleCount, 0), 0, 5)
	rightRoleCount = Helper:getRange(Helper:getDef(rightRoleCount, 0), 0, 5)
	
	if leftRoleCount ~= self._currLeftRoleCount then
		self.Panel_stateArea.ListView_left:removeAllItems()
		for i = 1, leftRoleCount do
			local leftRoleStatePanel = RoleStatePanel:createLeftRoleStatePanel()
			leftRoleStatePanel:setSelfAndChildrenTouchEnabled(false)
			leftRoleStatePanel:setVisible(false)
			self.Panel_stateArea.ListView_left:pushBackCustomItem(leftRoleStatePanel)
		end
	end
	
	if rightRoleCount ~= self._currRightRoleCount then
		self.Panel_stateArea.ListView_right:removeAllItems()
		for i = 1, rightRoleCount do
			local rightRoleStatePanel = RoleStatePanel:createRightRoleStatePanel()
			rightRoleStatePanel:setSelfAndChildrenTouchEnabled(false)
			rightRoleStatePanel:setVisible(false)
			self.Panel_stateArea.ListView_right:pushBackCustomItem(rightRoleStatePanel)
		end
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 设置当前角色状态面板的显示
function FightUI:setRoleStatePanel(team1Roles, team2Roles)
	
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 得到角色状态面板
function FightUI:getRoleStatePanel(roleTeamId, roleInTeamId)
	assert(type(roleTeamId) == "number", "roleTeamId = " .. tostring(roleTeamId))
	assert(type(roleInTeamId) == "number", "roleInTeamId = " .. tostring(roleInTeamId))
	
	if roleTeamId == 1 then
		return self.Panel_stateArea.ListView_left:getItem(Helper:getRange(roleInTeamId - 1, 0, 4))
	elseif roleTeamId == 2 then
		return self.Panel_stateArea.ListView_right:getItem(Helper:getRange(roleInTeamId - 1, 0, 4))
	else
		error("roleTeamId = ", roleTeamId)
	end
	
	-- return switch(roleFightId,
	-- {
	--     left1 = self.Panel_stateArea.ListView_left:getItem(0),
	--     left2 = self.Panel_stateArea.ListView_left:getItem(1),
	--     left3 = self.Panel_stateArea.ListView_left:getItem(2),
	--     left4 = self.Panel_stateArea.ListView_left:getItem(3),
	--     left5 = self.Panel_stateArea.ListView_left:getItem(4),
	--
	--     right1 = self.Panel_stateArea.ListView_right:getItem(0),
	--     right2 = self.Panel_stateArea.ListView_right:getItem(1),
	--     right3 = self.Panel_stateArea.ListView_right:getItem(2),
	--     right4 = self.Panel_stateArea.ListView_right:getItem(3),
	--     right5 = self.Panel_stateArea.ListView_right:getItem(4),
	--     default = function()error()end
	-- })
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 设置左边或者右边第index角色状态面板的stateName的数值
-- @params direction: "left" or "right"; index: 1 ~ 5;
function FightUI:setRoleState(roleTeamId, roleInTeamId, stateName, value)
	local roleStatePanel = self:getRoleStatePanel(roleTeamId, roleInTeamId)
	switch(stateName,
	{
		name = function()
			roleStatePanel:setName(value)
		end
	})
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 设置角色名
function FightUI:setRoleName(roleTeamId, roleInTeamId, name)
	-- print("roleTeamId, roleInTeamId, name = ", roleTeamId, roleInTeamId, name)
	self:getRoleStatePanel(roleTeamId, roleInTeamId):setName(name)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 设置角色气血
function FightUI:setRoleQi(roleTeamId, roleInTeamId, qi, currQiMax, qiMax)
	self:getRoleStatePanel(roleTeamId, roleInTeamId):setQi(qi, currQiMax, qiMax)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 设置角色内力
function FightUI:setRoleNeili(roleTeamId, roleInTeamId, neili, neiliMax)
	self:getRoleStatePanel(roleTeamId, roleInTeamId):setNeili(neili, neiliMax)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 设置角色体力
function FightUI:setRoleTili(roleTeamId, roleInTeamId, tili, tiliMax)
	self:getRoleStatePanel(roleTeamId, roleInTeamId):setTili(tili, tiliMax)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/02/21 19:53:07
-- @desc 设置角色效果状态图标
function FightUI:setRoleEffects(roleTeamId, roleInTeamId, effects)
	self:getRoleStatePanel(roleTeamId, roleInTeamId):setEffects(effects)
end

function FightUI:setRoleStateIcons(roleTeamId, roleInTeamId, stateIcons)
	self:getRoleStatePanel(roleTeamId, roleInTeamId):setStateIcons(stateIcons)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/02/25 10:31:38
-- @desc 从准备面板添加主动招式
function FightUI:roleReadyActiveZhao(roleTeamId, roleInTeamId, activeZhaoName)
	self:getRoleStatePanel(roleTeamId, roleInTeamId):readyActiveZhao(activeZhaoName)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/02/28 14:34:35
-- @desc 从主动招式准备面板移除主动招式
function FightUI:roleUnreadyActiveZhao(roleTeamId, roleInTeamId)
	self:getRoleStatePanel(roleTeamId, roleInTeamId):unreadyActiveZhao()
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/01/13 16:01:49
-- @desc 设置按钮列表
function FightUI:setActiveButtonArray(buttonArray, buttonReleaseFunc)
	buttonReleaseFunc = Helper:getDef(buttonReleaseFunc, EMPTY_FUNC)
	
	self._activeButtonMap = {}-- 移除主动按钮map
	self.Panel_buttonArea:removeAllChildren()-- 移除所有子节点
	local buttonCount = #buttonArray
	Helper:foreachItemInMatrixArea(self.Panel_buttonArea:getContentSize(), LoadingBarButton:create():getContentSize(), 3, 3, 80, 80,
	function(index, ix, iy, x, y)
		-- if index <= buttonCount then
		if buttonArray[index] then
			local buttonId = buttonArray[index].id
			local buttonName = Helper:getDef(buttonArray[index].name, "未知效果")
            local buttonPercent = Helper:getDef(buttonArray[index].percent, 100)
			local buttonFunc = Helper:getDef(buttonArray[index].func, EMPTY_FUNC)
			
			local loadingBarButton = LoadingBarButton:create()
			self.Panel_buttonArea:addChild(loadingBarButton)
            
			-- loadingBarButton:getVirtualRenderer():getSprite():setGLProgram(Resource:getSpriteGrayShder())
			-- loadingBarButton.LoadingBar_1:getVirtualRenderer():getSprite():setGLProgram(Resource:getSpriteGrayShder())
			-- loadingBarButton:setEnable(false)

			loadingBarButton:setName(buttonName)
			loadingBarButton:setPosition(cc.p(x, y))
			
			-- loadingBarButton:releaseFunc(buttonFunc)
			loadingBarButton:releaseFunc(function()
				buttonReleaseFunc(buttonId)
			end)

			if buttonId == 0 then
				loadingBarButton:setLoadingBarBgTexture("Image/BaseUI/btn-fight-notPrepare.png")
			else
				loadingBarButton:setLoadingBarBgTexture("Image/UI/MapUI/anniu04.png")
			end

            loadingBarButton:setPercent(buttonPercent)
			
			self._activeButtonMap[buttonId] = loadingBarButton
		end
		-- end
	end)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/01/13 16:15:02
-- @desc 设置主动按钮的百分比
function FightUI:setActiveButtonPercent(id, percent)
	local activeButton = self._activeButtonMap[id]
	if activeButton then
		activeButton:setPercent(percent)
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/02/24 16:14:29
-- @desc 设置主动技能
function FightUI:setActiveButtonEnable(id, enable)
	local activeButton = self._activeButtonMap[id]
	if activeButton then
		activeButton:setEnable(enable)
	end
end


----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @author TangJian --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @time 2017/05/04 11:35:46 -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @desc 经脉印记 -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/05/04 11:36:38
-- @desc 初始化经脉
function FightUI:initJingMai()
	self._jingMaiYinJiPanel = ccui.Layout:create()
	self:addChild(self._jingMaiYinJiPanel)
	self._jingMaiYinJiPanel:setPosition(cc.p(0, 1400))
	self._jingMaiYinJiPanel:setContentSize(cc.size(1080, 200))
	
	self._leftItemArray = {}
	self._rightItemArray = {}
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/05/04 12:10:08
-- @desc 创建经脉印记
function FightUI:createJinMaiYinJiItem(title_)
	local item = ccui.ImageView:create(Res:getImgPath("JingMaiYinJiItemBack"))
	item:ignoreContentAdaptWithSize(false)
	item:setSize({width = 56, height = 190})
	local title = ccui.Text:create()
	title:setString(title_)
	title:setFontName(Res:getFontPath("HYCFS"))
	title:setFontSize(30)
	title:enableOutline(cc.c4b(0, 0, 0, 255), 3)
	title:setPosition(cc.p(item:getSizeWidth() / 2, item:getSizeHeight() / 2))
	item:addChild(title)
	return item
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/05/04 11:38:45
-- @desc 激活经脉印记
function FightUI:playJinMaiYinJiActiveAnim(id, name,teamId)
	--add by LvBin 2019/06/26 15:02:19 区分播放经脉印记区域
	teamId = Helper:getDef(teamId,1)
	if teamId == 1 then
		self:playLeftJinMaiYinJiActiveAnim(id, name)
	else
		self:playRightJinMaiYinJiActiveAnim(id, name)
	end
	
end

-- @desc 播放队伍左边人物经脉印记动画
function FightUI:playLeftJinMaiYinJiActiveAnim(id, name)
	for i = 1, 3 do
		if self._leftItemArray[i] == nil then
			-- local item = self:createJinMaiYinJiItem("测\n试\n测")
			local item = self:createJinMaiYinJiItem(name)
			
			self._jingMaiYinJiPanel:addChild(item)
			
			item:setPosition(cc.p(70 * i, 100))
			
			self._leftItemArray[i] = item
			
			item:setCascadeOpacity(0)
			item:setPositionY(item:getPositionY() + 20)
			
			item:runAction(cc.Sequence:create(
			cc.Spawn:create(cc.FadeIn:create(1), cc.MoveBy:create(0.3, cc.p(0, - 20))),
			cc.DelayTime:create(1.5),
			cc.FadeOut:create(1),
			cc.CallFunc:create(function()
				self._leftItemArray[i] = nil
				item:removeFromParent()
			end)))
			
			break
		end
	end
end

-- @desc 播放队伍右边人物经脉印记动画
function FightUI:playRightJinMaiYinJiActiveAnim(id, name)
	for i = 1, 3 do
		if self._rightItemArray[i] == nil then
			print("测试经脉按钮区域")
			-- local item = self:createJinMaiYinJiItem("测\n试\n测")
			local item = self:createJinMaiYinJiItem(name)
			
			self._jingMaiYinJiPanel:addChild(item)
			
			item:setPosition(cc.p(1080 - (70 * i), 100))
			
			self._rightItemArray[i] = item
			
			item:setCascadeOpacity(0)
			item:setPositionY(item:getPositionY() + 20)
			
			item:runAction(cc.Sequence:create(
			cc.Spawn:create(cc.FadeIn:create(1), cc.MoveBy:create(0.3, cc.p(0, - 20))),
			cc.DelayTime:create(1.5),
			cc.FadeOut:create(1),
			cc.CallFunc:create(function()
				self._rightItemArray[i] = nil
				item:removeFromParent()
			end)))
			
			break
		end
	end
end

local effectTextPosY = {
	[1] = 1090,
	[2] = 1150
}

function FightUI:createRoleEffectText()
	for i = 1, #effectTextPosY, 1 do
		self["__leftEffectTextNode"..tostring(i)] = ccui.Text:create()
		self["__leftEffectTextNode"..tostring(i)]:ignoreContentAdaptWithSize(true)
		self["__leftEffectTextNode"..tostring(i)]:setFontName("Font/default.ttf")
		self["__leftEffectTextNode"..tostring(i)]:setFontSize(40)
		self["__leftEffectTextNode"..tostring(i)]:enableOutline({r = 0, g = 0, b = 0, a = 255}, 3)
		self["__leftEffectTextNode"..tostring(i)]:setLayoutComponentEnabled(true)
		self["__leftEffectTextNode"..tostring(i)]:setCascadeColorEnabled(true)
		self["__leftEffectTextNode"..tostring(i)]:setCascadeOpacityEnabled(true)
		self["__leftEffectTextNode"..tostring(i)]:setAnchorPoint(0,0)
		self["__leftEffectTextNode"..tostring(i)]:setTextVerticalAlignment(1)
		self["__leftEffectTextNode"..tostring(i)]:setPosition(30, effectTextPosY[i])
		self["__leftEffectTextNode"..tostring(i)]:setTextColor({r = 219, g = 57, b = 57})
		self["__leftEffectTextNode"..tostring(i)]:setString("")

	
		self._UI:addChild(self["__leftEffectTextNode"..tostring(i)])

		self["__rightEffectTextNode"..tostring(i)] = ccui.Text:create()
		self["__rightEffectTextNode"..tostring(i)]:ignoreContentAdaptWithSize(true)
		self["__rightEffectTextNode"..tostring(i)]:setFontName("Font/default.ttf")
		self["__rightEffectTextNode"..tostring(i)]:setFontSize(40)
		self["__rightEffectTextNode"..tostring(i)]:enableOutline({r = 0, g = 0, b = 0, a = 255}, 3)
		self["__rightEffectTextNode"..tostring(i)]:setLayoutComponentEnabled(true)
		self["__rightEffectTextNode"..tostring(i)]:setCascadeColorEnabled(true)
		self["__rightEffectTextNode"..tostring(i)]:setCascadeOpacityEnabled(true)
		self["__rightEffectTextNode"..tostring(i)]:setAnchorPoint(1,0)
		self["__rightEffectTextNode"..tostring(i)]:setTextHorizontalAlignment(2)
		self["__rightEffectTextNode"..tostring(i)]:setTextVerticalAlignment(1)
		self["__rightEffectTextNode"..tostring(i)]:setPosition(1050, effectTextPosY[i])
		self["__rightEffectTextNode"..tostring(i)]:setTextColor({r = 219, g = 57, b = 57})
		self["__rightEffectTextNode"..tostring(i)]:setString("")
	
		self._UI:addChild(self["__rightEffectTextNode"..tostring(i)])
	end
end

function FightUI:refreshLeftRoleEffectText(textArray)
	for i = 1, #textArray, 1 do
		if self["__leftEffectTextNode"..tostring(i)] then
			self["__leftEffectTextNode"..tostring(i)]:setString(textArray[i])
		end
	end
end

function FightUI:refreshRightRoleEffectText(textArray)
	for i = 1, #textArray, 1 do
		if self["__rightEffectTextNode"..tostring(i)] then
			self["__rightEffectTextNode"..tostring(i)]:setString(textArray[i])
		end
	end
end


return FightUI
00000