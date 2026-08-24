local User = require("app.models.user.User")
local Item = require("app.models.item.Item")
local Role = require("app.models.role.Role")

local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
local DialogBLayer = require("app.views.layer.DialogLayer.DialogBLayer")
local RoleTaskControllor = require("app.views.layer.RoleLayer.RoleTaskControllor")

local Meridian = require("app.models.Meridian.Meridian")

-- 静修室
local QuietRoomLayer = class("QuietRoomLayer", LayerEx)

function QuietRoomLayer:create()
	local p = QuietRoomLayer:new()
	p:init()
	return p
end

function QuietRoomLayer:init()
	self._UI = require("Layer/MeridianUI/QuietRoomUI.lua").create()['root']
	self._UI:addTo(self)

	Helper:convertUIByParent(self)
	self:setButton()

	-- 经脉状态 改变图片用
	self.meridianCount = -1

	-- 是否正在调息
	self.isPranayama = false
	-- 上次调息时经脉等级
	self.lastPranayama = 0

	Meridian:initMerdian()

	self:initRichText()

	self._handle = self:schedule(function (ft)
		self:update(ft)
	end,1)
end

-- 初始化输出框
function QuietRoomLayer:initRichText()
	local x, y = self.Image_help.Panel_talk:getPosition()
	local size = self.Image_help.Panel_talk:getContentSize()

	if self.RichText_print then
		self.RichText_print:removeFromParent()
		self.RichText_print = nil
	end

	local richTextScroll = ExtRichTextScroll:create()
	richTextScroll:setAnchorPoint( 0.5 , 0.5 )
   	self.Image_help.Panel_talk:getParent():addChild(richTextScroll)
   	local point = cc.p(self.Image_help.Panel_talk:getPosition())
   	richTextScroll:move(point)
   	richTextScroll:setSize(size)
   	richTextScroll:setDirection(kCCScrollViewDirectionVertical)
   	richTextScroll:getRichText():setVerticalSpace(5)
   	self.RichText_print = richTextScroll

   	self.RichText_print:setBounceEnabled(false)
end

function QuietRoomLayer:print(str, verticalSpace)
	if str == "" then
		return
	end

	if self.RichText_print == nil then
		return
	end
	local textColor = cc.c3b(159,159,159)
	local textHeight = self.RichText_print:getRichText():getNewContentSizeHeight()
	if textHeight >= 6666 then
		self:initRichText()
	end

	self.RichText_print:pushBackText(str, textColor, 255, Resource:getFontPath("default"), 36)

	if verticalSpace ~= nil and type(verticalSpace) == "number" then
		self.RichText_print:pushBackNewLine(verticalSpace)
	else
		self.RichText_print:pushBackNewLine()
	end
end

function QuietRoomLayer:onResume()
	local role = User:getRole()
	local meridian = role:getAttr("meridian")
	self.isPranayama = false

	if meridian.meridianCount == 8 then
		self.Panel_jingmai.Image_jingmai:loadTexture("Image/UI/MeridianUI/jingmai1.png")
		self.Panel_jingmai.Image_meridian:setVisible(false)
	else
		local image_path = "Image/UI/MeridianUI/meridian" .. meridian.meridianCount + 1 .. ".png"
		self.Panel_jingmai.Image_meridian:setVisible(true)
		self.Panel_jingmai.Image_meridian:loadTexture(image_path)
		self.Panel_jingmai.Image_jingmai:loadTexture("Image/UI/MeridianUI/jingmai.png")
	end
	self:update()
end

-- 刷新UI
function QuietRoomLayer:refreshUI()
	local role = User:getRole()

	local meridian = role:getAttr("meridian")
	local breathVal = math.floor(role:getAttr("breathVal"))
	local meridianExp = role:getAttr("meridianExp")

	self.Text_MeridianLv_num:setString(Meridian:getMeridianLv(role:getAttr("meridianExp")))
	self.Text_zhenqi_num:setString(breathVal)

	-- 调息
	self.Text_time:setString("")
	if role:isInCurrState(ROLE_CURR_STATE_TIAOXI) then
		self.isPranayama = true
		self.lastPranayama = Meridian:getMeridianLv(meridianExp)
		self.Button_Pranayama.Text_buttonName:setString("结束调息")
		local year, month, day, hour, minute, second = Helper:getExpiredTime(role:getFlag("调息完成时间"), GetTime())
		self.Text_time:setString("剩余时间:" .. hour .. "小时" .. minute .. "分" .. second .. "秒")
		if self.meridianExp == nil and self.breathVal == nil then
			self.meridianExp, self.breathVal = Meridian:getPranayamaReward(meridianExp)
		end
	else
		if self.isPranayama == true then
			self:print("HIC随着一股暖流流过，你感到自己体内的真气增加了。")
			if self.lastPranayama ~= 0 then
				if self.meridianExp ~= nil and self.breathVal ~= nil then
					self:print("HIW获得真气 " .. Helper:getRoundNumber(self.breathVal) .. "!")
					self:print("HIW获得经脉经验 " .. Helper:getRoundNumber(self.meridianExp) .. "!")
					self.meridianExp = nil
					self.breathVal = nil
				end
			end
			self.isPranayama = false
		end
		self.Button_Pranayama.Text_buttonName:setString("调息")
	end

	if self.meridianCount ~= meridian.meridianCount then
		for i=1,8 do
			self:showMeridian(i, meridian)
		end
		self.meridianCount = meridian.meridianCount
	end

	if role:getTimeLimitFlag("真气加成") == 1 then
		local overTime = role:getTimeLimitFlagTime("真气加成")
		local year, month, day, hour, minute, second = Helper:getExpiredTime(GetTime() + overTime, GetTime())
		self.Text_AromaBurnerTime:setString("香薰炉:" .. hour .. "小时" .. minute .. "分" .. second .. "秒")
	else
		self.Text_AromaBurnerTime:setString("")
	end
end

-- 显示可培养经脉
function QuietRoomLayer:showMeridian(index, meridian)
	local panels =
	{
		["任脉"] = self.Panel_jingmai.Panel_1,
		["阳维"] = self.Panel_jingmai.Panel_2,
		["冲脉"] = self.Panel_jingmai.Panel_3,
		["阳跷"] = self.Panel_jingmai.Panel_4,
		["督脉"] = self.Panel_jingmai.Panel_5,
		["阴跷"] = self.Panel_jingmai.Panel_6,
		["带脉"] = self.Panel_jingmai.Panel_7,
		["阴维"] = self.Panel_jingmai.Panel_8,
	}

	local lines =
	{
		["任脉"] = self.Panel_jingmai.Image_xian1,
		["阳维"] = self.Panel_jingmai.Image_xian2,
		["冲脉"] = self.Panel_jingmai.Image_xian3,
		["阳跷"] = self.Panel_jingmai.Image_xian4,
		["督脉"] = self.Panel_jingmai.Image_xian5,
		["阴跷"] = self.Panel_jingmai.Image_xian6,
		["带脉"] = self.Panel_jingmai.Image_xian7,
		["阴维"] = self.Panel_jingmai.Image_xian8,
	}

	local meridianName = Meridian:getMeridianName(index)
	panels[meridianName].Text_MeridianName:setString(meridianName)

	local state = 1
	if meridian.meridianCount >= index then
		state = 3
	elseif meridian.meridianCount + 1 == index then
		state = 2
	end

	-- 1 上锁 2 待培养 3 已培养
	if state == 2 then
		panels[meridianName].Image_suo:setVisible(false)
		panels[meridianName].Image_point:setVisible(true)
		panels[meridianName].Text_MeridianName:setVisible(true)
		panels[meridianName]:setTouchEnabled(true)

		-- 点击经脉
		-- panels[meridianName]:releaseFunc(function()
		-- 	local MeridianBreakLayer = MainControllLayer:getLayer("MeridianBreakLayer")
		-- 	MeridianBreakLayer:createAcupointList(index)
		-- 	MainControllLayer:pushLayer("MeridianBreakLayer")
		-- end)

		panels[meridianName].Image_point:loadTexture("Image/UI/MeridianUI/mai2.png")

	elseif state == 3 then
		panels[meridianName].Image_suo:setVisible(false)
		panels[meridianName].Image_point:setVisible(true)
		panels[meridianName].Text_MeridianName:setVisible(true)
		panels[meridianName]:setTouchEnabled(true)

		-- 点击经脉
		-- panels[meridianName]:releaseFunc(function()
		-- 	local MeridianBreakLayer = MainControllLayer:getLayer("MeridianBreakLayer")
		-- 	MeridianBreakLayer:createAcupointList(index)
		-- 	MainControllLayer:pushLayer("MeridianBreakLayer")
		-- end)

		panels[meridianName].Image_point:loadTexture("Image/UI/MeridianUI/mai.png")

	else
		panels[meridianName].Image_suo:setVisible(true)
		panels[meridianName].Image_point:setVisible(false)
		panels[meridianName].Text_MeridianName:setVisible(false)
		panels[meridianName]:setTouchEnabled(false)
	end
end

-- 调息
function QuietRoomLayer:pranayama()
	local role = User:getRole()
	role:pranayama()

	do
		local LimitedTimeExperience = require("app.models.Action.LimitedTimeExperience")

		if LimitedTimeExperience:checkTaskIsOpen("tiaoxi") then
			LimitedTimeExperience:setRole(User:getRole())
			LimitedTimeExperience:finishTaskByTaskType("tiaoxi")
		end
	end

	do --每日任务
		local DailyTasksActivity = require("app.models.Action.DailyTasksActivity")
		DailyTasksActivity:addDailyTaskPoint("tiaoxi")
	end
	
	local HomelandUtil = require("app.models.HomelandModel.HomelandUtil")
	if HomelandUtil:isRoomByTypeFromFlag("tsfangjian015") then
		self:print("你走入调息室，松弛筋骨、坐了下来，静气凝神，呼吸变得悠长，开始进行调息……")
	else
		self:print("HIC你静气凝神，呼吸变得悠长，开始进行调息……")
	end

	self:update()
end

function QuietRoomLayer:update()
	self:refreshUI()
end

function QuietRoomLayer:setButton()
	-- 调息
	self.Button_Pranayama:releaseFunc(function()
		Audio:playEffect("daAnNiu")
		local role = User:getRole()
		if role:isInCurrState(ROLE_CURR_STATE_TIAOXI) then
			print("正在调息")
			local str, params
			params =
			{
				str = "正在调息中，可使用醒身丸立即结束调息并获得真气",
				name1 = "使用醒身丸",
				func1 = function()
					local ret
					ret, self.meridianExp, self.breathVal = role:stopPranayama()
					if ret == true then
						self:print("HIC你一个激灵，将内劲回收，结束调息。")
						self:update()
					end
				end,
				name2 = "取消调息",
				func2 = function()
					self.isPranayama = false
					role:cancelPranayama()
					self:update()
				end,
				name3 = "返回"
			}
			self:createDialog("A", params)
		else
			RoleTaskControllor:clickTiaoXiLayer(function()
				self:pranayama()
			end)
		end
	end)

	-- 进入经脉界面
	self.Button_Practice:releaseFunc(function()
		Audio:playEffect("xiaoAnNiu")
		local index = User:getRoleAttr("meridian").meridianCount + 1
		if index > 8 then
			index = 8
		end

		local MeridianBreakLayer = MainControllLayer:getLayer("MeridianBreakLayer")
		MainControllLayer:pushLayer("MeridianBreakLayer")
		MeridianBreakLayer:createAcupointList(index)
		MeridianBreakLayer:showAttrData()
	end)

	-- 进入经脉印记界面
	self.Button_MeridianMark:releaseFunc(function()
		Audio:playEffect("xiaoAnNiu")
		local role = User:getRole()
		if MapIsEmpty(role:getMeridianSystem():getCurrentPageMeridianImprintings()) == true then
			PopText("还没获得经脉天赋")
			return
		end
		local MeridianImprintingPresenter = MainControllLayer:getLayer("MeridianImprintingPresenter")
		MainControllLayer:pushLayer("MeridianImprintingPresenter")
		MeridianImprintingPresenter:showPresenter()
	end)

	-- 进入隐脉界面
	self.Button_HiddenMeridian:releaseFunc(function()
		Audio:playEffect("xiaoAnNiu")
		local role = User:getRole()

		if role:getHiddenMeridianSystem():isUnlocked() == false then
			PopText("隐脉尚未领悟，目前无法使用")
			return
		end

		role:getHiddenMeridianSystem():getHiddenMeridianInfo(function(isOk,msg)
			if isOk then
				local interactor = require("app.models.Meridian.HiddenMeridianInteractor"):create(role)
				local HiddenMeridianMenuPresenter = MainControllLayer:getLayer("HiddenMeridianMenuPresenter")
				MainControllLayer:pushLayer("HiddenMeridianMenuPresenter")
				HiddenMeridianMenuPresenter:setInput(interactor)
				HiddenMeridianMenuPresenter:showPresenter()
			else
				PopText(msg)
			end
		end)
	end)

	-- 香薰炉
	self.Button_AromaBurner:releaseFunc(function()
		Audio:playEffect("xiaoAnNiu")
		PopupLayerController:showLayer("MerdianAromaBurnerLayer", function(layer)
			layer:showLayer(self)
		end)
	end)
end

function QuietRoomLayer:createDialog(dtype, params)
	local dialog
	if dtype == "A" then
		dialog = DialogALayer:getInstance()
		dialog:show(params.str)
		dialog:setButton1(params.name1, params.func1)
		dialog:setButton2(params.name2, params.func2)
		dialog:setButton3(params.name3, params.func3)
	elseif dtype == "B" then
		dialog = DialogBLayer:getInstance()
		dialog:show(params.list)
		dialog:setButton1(params.name1, params.func1)
		dialog:setButton2(params.name2, params.func2)
		dialog:setButton3(params.name3, params.func3)
	else
	end
end

Helper:classDefNodeGetInstance(QuietRoomLayer)

return QuietRoomLayer000000000000