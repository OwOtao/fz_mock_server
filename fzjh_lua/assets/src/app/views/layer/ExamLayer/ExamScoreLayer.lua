-- 发榜界面
local ExamScoreLayer = class("ExamScoreLayer", LayerEx)

local Exam = require("app.models.Exam.Exam")

function ExamScoreLayer:create()
	local p = ExamScoreLayer:new()
	p:init()
	return p
end

function ExamScoreLayer:init()
	self._UI = require("Layer/ExamUI/ExamScoreUI.lua").create()['root']
	self._UI:addTo(self)

	Helper:convertUIByParent(self)

	self:setButton()

	self.isShowAnimation = false

	self.Panel_fabang:setTouchAnimEnabled(false)
end

function ExamScoreLayer:showLayer(examName, examData, mapLayer)
	if examName == nil then
		return
	end
	TransCheck:checkAllUrlTrans()

	self.mapLayer = mapLayer

	-- 考试名字
	self.examName = examName

	self.isShowAnimation = true

	self.examData = examData

	self:show()
	self:showScore()
end

function ExamScoreLayer:showScore()
	-- 显示动画
	local function showAnimation(panel, delay)
		local animDuration = 1
		panel:setOpacity(0)
		panel:runAction(
			YXEaseAction:create( cc.Sequence:create(
				cc.DelayTime:create( delay ) ,
				cc.FadeIn:create(animDuration)
			),  Sine_EaseOut ) )
	end

	local function showAnimationByImage(panel, delay)
		local animDuration = 1
		panel:setOpacity(0)
		panel:setScale(2.0)
		panel:runAction(
			YXEaseAction:create( cc.Sequence:create(
				cc.DelayTime:create( delay ),
				cc.Spawn:create(
					cc.ScaleTo:create(1 , 1.0 , 1.0 ),
					cc.FadeIn:create(animDuration)
				)
			),  Sine_EaseOut ) )
	end

	-- 设置文本
	local function setText(panel, desc, count, unit, title)
		panel:setVisible(true)
		panel.Text_desc:setString(desc)
		panel.Text_count:setString(count)
		panel.Text_1:setString(unit)
		if title then
			panel.Text_2:setString(title)
		else
			panel.Text_2:setString("")
		end
	end

	local panel = self.Panel_fabang
	panel:setVisible(false)
	self.Panel_ending:setVisible(false)

	local role = User:getRole()
	panel.Panel_text.Text_desc:setString("")
	panel.Panel_1:setVisible(false)
	panel.Panel_2:setVisible(false)
	panel.Panel_3:setVisible(false)
	panel.Panel_4:setVisible(false)

	if self.examName == "乡试" then
		local str = role:getTimeLimitFlag(self.examName)
		if str == 0 then
			return
		end
		panel:setVisible(true)

		panel.Panel_text.Text_desc:setString("YEL“男儿若遂平生志.六经勤向窗前读。”经过紧张的阅卷，乡试的成绩出来了，以下是你的成绩：")

		local rightCount = string.split(str, ";")[2]
		setText(panel.Panel_1, "答对", rightCount, "题")
		setText(panel.Panel_2, "答错", 20 - rightCount, "题")
		setText(panel.Panel_3, "得分", rightCount * 5, "分")

		panel.Image_timing:loadTexture("Image/UI/ExamUI/guibangtiming.png")

		if rightCount * 5 >= 60 then
			Audio:playEffect("VillageExam", true)
			panel.Image_timing:setVisible(true)
			panel.Image_sunshan:setVisible(false)
		else
			panel.Image_timing:setVisible(false)
			panel.Image_sunshan:setVisible(true)
		end

		showAnimation(panel.Panel_text, 0)
		showAnimation(panel.Panel_1, 1)
		showAnimation(panel.Panel_2, 2)
		showAnimation(panel.Panel_3, 3)
		showAnimationByImage(panel.Image_timing, 4)
		showAnimationByImage(panel.Image_sunshan, 4)

		self.isShowAnimation = true
		self:delayFunc(5, function()
			self.isShowAnimation = false
		end)
	elseif self.examName == "省试" then
		panel:setVisible(true)
		panel.Panel_text.Text_desc:setString("YEL“慈恩塔下题名处，十七人中最少年。”经过数日紧张的阅卷，省试的成绩终于出来了，以下是你的成绩：")

		local rightCount = self.examData.rightCount
		local examTime = self.examData.time
		local rank = self.examData.rank

		setText(panel.Panel_1, "答对", rightCount, "题")
		setText(panel.Panel_2, "得分", 5 * rightCount, "分")
		setText(panel.Panel_3, "用时", math.ceil(examTime), "秒")
		setText(panel.Panel_4, "排名", rank, "第		名")

		panel.Image_timing:loadTexture("Image/UI/ExamUI/jinbangtiming.png")

		if self.examData.flag ~= 0 then
			Audio:playEffect("VillageExam", true)
			panel.Image_timing:setVisible(true)
			panel.Image_sunshan:setVisible(false)
		else
			panel.Image_timing:setVisible(false)
			panel.Image_sunshan:setVisible(true)
		end

		showAnimation(panel.Panel_text, 0)
		showAnimation(panel.Panel_1, 1)
		showAnimation(panel.Panel_2, 2)
		showAnimation(panel.Panel_3, 3)
		showAnimation(panel.Panel_4, 4)
		showAnimationByImage(panel.Image_timing, 5)
		showAnimationByImage(panel.Image_sunshan, 5)

		self.isShowAnimation = true
		self:delayFunc(6, function()
			self.isShowAnimation = false
		end)
	elseif self.examName == "殿试" then
		panel.Panel_text.Text_desc:setString("YEL“九万抟扶排羽翼，十年辛苦涉风尘。”经过紧张阅卷，圣上御笔取士，本次科考落下帷幕。以下是你的成绩：")

		panel:setVisible(true)
		local point = self.examData.point
		local examTime = self.examData.time
		local rank = self.examData.rank
		local title =
		{
			[1] = "状元！",
			[2] = "榜眼！",
			[3] = "探花！",
		}
		setText(panel.Panel_1, "得分", point, "分")
		setText(panel.Panel_2, "用时", math.ceil(examTime), "秒")
		setText(panel.Panel_3, "排名", rank, "第		名", title[rank])

		panel.Image_timing:loadTexture("Image/UI/ExamUI/jinbangtiming.png")

		if self.examData.flag ~= 0 then
			Audio:playEffect("VillageExam", true)
			panel.Image_timing:setVisible(true)
			panel.Image_sunshan:setVisible(false)
		else
			panel.Image_timing:setVisible(false)
			panel.Image_sunshan:setVisible(true)
		end

		showAnimation(panel.Panel_text, 0)
		showAnimation(panel.Panel_1, 1)
		showAnimation(panel.Panel_2, 2)
		showAnimation(panel.Panel_3, 3)
		showAnimationByImage(panel.Image_timing, 4)
		showAnimationByImage(panel.Image_sunshan, 4)

		self.isShowAnimation = true
		self:delayFunc(6, function()
			self.isShowAnimation = false
		end)

		-- 官职相关 上榜时，同时获得官职
		if self.examData.flag > 0 then
			-- 翰林编修
			if self.examData.flag > 0 and self.examData.flag <= 3 then
				User:setRoleAttr("officialType", 1)

			-- 庶吉士
			elseif self.examData.flag == 4 then
				User:setRoleAttr("officialType", 2)

			-- 县令
			elseif self.examData.flag == 5 then
				User:setRoleAttr("officialType", 3)
			end
		end
	end
end

-- 可参加下一级考试时 显示结果界面
function ExamScoreLayer:showResult()
	self.Panel_fabang:setVisible(false)
	self.Panel_ending:setVisible(false)

	if self.examName == "乡试" then
		self.Panel_ending:setVisible(true)
		self.Panel_ending.Text_desc_3:setString("扬州城")
		self.Panel_ending.Text_desc_4:setString("参加省试")
		self.Panel_ending.Text_desc_5:setString("省试结束还有		小时")
		self.Panel_ending.Text_time:setString(Exam:getProvinceExamTime())
		self.Panel_ending.Button_goto.Text_ButtonName:setString("前往省试")
	elseif self.examName == "省试" then
		self.Panel_ending:setVisible(true)
		self.Panel_ending.Text_desc_3:setString("皇   宫")
		self.Panel_ending.Text_desc_4:setString("参加殿试")
		self.Panel_ending.Text_desc_5:setString("殿试结束还有		小时")
		self.Panel_ending.Text_time:setString(Exam:getPalaceExamTime())
		self.Panel_ending.Button_goto.Text_ButtonName:setString("前往殿试")
	end
end

function ExamScoreLayer:setButton()
	-- 前往下一级考试
	self.Panel_ending.Button_goto:releaseFunc(function()
		Audio:playEffect("xiaoAnNiu")
		if self.examName == "乡试" then
			print("前往省试")
			-- if User:getRoleAttr("jindu") < 11 then
			local role = User:getRole()
			if role:isMapCompleted("fb10") ~= true then
				PopText("请先完成“鹊起无名卷”第十章主线任务！")
				return
			end

			HttpManagerEx:checkCanExam(1, function(status, errcode, errmsg, data)
				if status == 200 then
					if errcode == 0 then
						if self.mapLayer ~= nil then
							local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
							local dialog = DialogALayer:getInstance()
							dialog:hide()
							dialog:delayFunc(0.1, function()
								local map = User:getRole():getMapById("fb10")
								User:setRoleAttr("currMapId", map.id)

								print("副本跳转 刷新副本 " .. map.id)
								map = User:getRole():initMapById(map.id)
								self.mapLayer:setMap(map)
								map._isComingIn = true

								self.mapLayer:replaceRoom("fb10_22")
								self.mapLayer.ControllLayer:pushLayer("MapLayer")
							end)
							self.mapLayer.TotalMapBtn_IsInit = false
							self.mapLayer:quit(false)
						end
						PopupLayerController:hideLayer("ExamScoreLayer", function(layer)
							self:hide()
						end, 0)
					else
						PopText(errmsg)
					end
				else
					PopText(errmsg)
				end
			end, IS_SHOW_WAITING)
		elseif self.examName == "省试" then
			print("前往殿试")
			local mapLayer = self.mapLayer
			if mapLayer ~= nil then
				PopupLayerController:showLayer("PalaceExamJumpLayer", function(layer)
					layer:showLayer(function()
						if mapLayer ~= nil then
							local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
							local dialog = DialogALayer:getInstance()
							dialog:hide()
							dialog:delayFunc(0.1, function()
								local map = User:getRole():getMapById("fb37")
								User:setRoleAttr("currMapId", map.id)

								print("副本跳转 刷新副本 " .. map.id)
								map = User:getRole():initMapById(map.id)
								mapLayer:setMap(map)
								map._isComingIn = true

								mapLayer:replaceRoom("fb37_71")
								mapLayer.ControllLayer:pushLayer("MapLayer")
							end)
							mapLayer.TotalMapBtn_IsInit = false
							mapLayer:quit(false)
						end
					end)
				end)
			end
			PopupLayerController:hideLayer("ExamScoreLayer", function(layer)
				self:hide()
			end, 0)
		end
	end)

	-- 离开发榜界面
	self.Panel_fabang:releaseFunc(function()
		if self.isShowAnimation == true then
			return
		end

		Audio:stopAllEffects()

		if self.examName == "乡试" then
			if Exam:getVillageExamReward() and Exam:checkInProvinceExamTime() then
				self:showResult()
				return
			end
		elseif self.examName == "省试" then
			local role = User:getRole()
			local items = role:getAttr("items")
			if #items >= role:getAttr("weight") then
				PopText("背包已满无法获得奖励")
			else
				Exam:getProvinceExamReward()
				if self.examData.flag ~= 0 and Exam:checkInPalaceExamTime() then
					self:showResult()
					return
				end
			end
		elseif self.examName == "殿试" then
			local role = User:getRole()
			local items = role:getAttr("items")
			if #items >= role:getAttr("weight") then
				PopText("背包已满无法获得奖励")
			else
				Exam:getPalaceExamReward()
			end
		end

		if self._handle ~= nil then
			self:unschedule(self._handle)
			self._handle = nil
		end
		PopupLayerController:hideLayer("ExamScoreLayer", function(layer)
			self:hide()
		end, 0)
	end)


	self.Panel_ending.Panel_back_0:releaseFunc(function()
		PopupLayerController:hideLayer("ExamScoreLayer", function(layer)
			self:hide()
		end, 0)
	end)
end

Helper:classDefNodeGetInstance(ExamScoreLayer)

return ExamScoreLayer00