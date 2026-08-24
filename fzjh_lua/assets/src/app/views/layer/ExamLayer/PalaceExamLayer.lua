-- 殿试界面
local PalaceExamLayer = class("PalaceExamLayer", LayerEx)

local BookLiterary = require("app.models.book.BookLiterary")

local Exam = require("app.models.Exam.Exam")

-- 书写次数的描述
local writeDesc =
{
	[0] = "文章起始，你打算以何种文体破题：",
	[1] = "意犹未尽，你打算以何种文体对所思所想进行阐述：",
	[2] = "有感而发，你打算从何种文体对命题进一步阐述：",
	[3] = "娓娓道来，你打算以何种文体对所思所想进行阐述：",
	[4] = "旁敲侧击，你打算以何种文体对命题进行一番引申：",
	[5] = "起承转合，你打算以何种文体对行文进行一番修饰：",
	[6] = "拾遗补缺，你决定以何种文体完善自己的见解：",
	[7] = "尽善尽美，你打算以何种文体进行最后的总结陈词：",
	[8] = "文章已成，不知不觉间已下笔千言。",
}

-- 分数描述
local pointDesc =
{
	-- 艺术描述
	[1] =
	{
		{value = 0, 	desc = "行文粗鄙", color = "BLU"},
		{value = 100, 	desc = "流利晓畅", color = "HIC"},
		{value = 301, 	desc = "颇具文采", color = "GRN"},
		{value = 601, 	desc = "辞藻华美", color = "YEL"},
		{value = 901, 	desc = "传世雄文", color = "RED"},
		{value = 1000, 	desc = "大巧不工", color = "HIW"},
	},

	-- 义理描述
	[2] =
	{
		{value = 0, 	desc = "词不达意", color = "BLU"},
		{value = 100, 	desc = "管中窥一", color = "HIC"},
		{value = 301, 	desc = "颇有洞见", color = "GRN"},
		{value = 601, 	desc = "鞭辟入里", color = "YEL"},
		{value = 901, 	desc = "入木三分", color = "RED"},
		{value = 1000, 	desc = "天机道破", color = "HIW"},
	},

	-- 实用分数
	[3] =
	{
		{value = 0, 	desc = "无病呻吟", color = "BLU"},
		{value = 100, 	desc = "空洞无物", color = "HIC"},
		{value = 301, 	desc = "泛泛而谈", color = "GRN"},
		{value = 601, 	desc = "言之有物", color = "YEL"},
		{value = 901, 	desc = "可为圭臬", color = "RED"},
		{value = 1000, 	desc = "经世济民", color = "HIW"},
	},

	-- 境界分数
	[4] =
	{
		{value = 0, 	desc = "庸人之道", color = "BLU"},
		{value = 100, 	desc = "市井之道", color = "HIC"},
		{value = 301, 	desc = "士人之道", color = "GRN"},
		{value = 601, 	desc = "君子之道", color = "YEL"},
		{value = 901, 	desc = "圣贤之道", color = "RED"},
		{value = 1000, 	desc = "自然之道", color = "HIW"},
	},

	-- 创新分数
	[5] =
	{
		{value = 0, 	desc = "老生常谈", color = "BLU"},
		{value = 100, 	desc = "推陈出新", color = "HIC"},
		{value = 301, 	desc = "别出心裁", color = "GRN"},
		{value = 601, 	desc = "匠心独运", color = "YEL"},
		{value = 901, 	desc = "自出机杼", color = "RED"},
		{value = 1000, 	desc = "自成一家", color = "HIW"},
	}
}

function PalaceExamLayer:create()
	local p = PalaceExamLayer:new()
	p:init()
	return p
end

function PalaceExamLayer:init()
	self._UI = require("Layer/ExamUI/PalaceExamUI.lua").create()['root']
	self._UI:addTo(self)

	Helper:convertUIByParent(self)
	self:setButton()
end

-- subjectid 殿试题目ID
function PalaceExamLayer:showLayer(subjectid)
	-- 殿试题目
	self.subject = Exam:getPalaceQuestion(subjectid)

	if self.subject == nil then
		print("殿试题目出错")
		return
	end

	self.Text_king:setString("皇上:" .. self.subject.question)

	self:show()
	self:startExam()
end

-- 开始考试
function PalaceExamLayer:startExam()
	-- 艺术分数
	self.artPoint = 0

	-- 义理分数
	self.truthPoint = 0

	-- 实用分数
	self.practicalPoint = 0

	-- 境界分数
	self.ambitPoint = 0

	-- 创新分数
	self.innovatePoint = 0

	-- 开始考试时间
	self.startTime = GetTime()

	-- 当前随机的典籍
	self.currLiterary = nil

	self.examStyle = {}

	-- 答题历史 每次根据历史选择，重新计算得分 (literaryId, styleId)
	self.choiceHistory = {}

	-- 进度条
	self.loadingBar = nil

	-- 开始写文章时间
	self.readTime = nil

	-- 当前选择的按钮索引
	self.btnIndex = nil

	-- 写文章随机弹出文本
	self.writeDescShow = false

	--
	self:initRichText()

	-- 更新剩余时间
	if self._handle ~= nil then
		self:unschedule(self._handle)
		self._handle = nil
	end

	self:setLiterary()

	self._handle = self:schedule(function (ft)
		self:UpdateTime(ft)
	end,1/10)

	-- 先保存一次殿试成绩
	Exam:savePalaceExamScore(0, 300)
end

-- 随机获得一个文学典籍 配置文体按钮
function PalaceExamLayer:setLiterary()
	print("随机获得一个文学典籍")
	self.Text_2:setString(writeDesc[#self.choiceHistory])

	-- 写满8次无法再写
	if #self.choiceHistory >= 8 then
		print("写满8次无法再写")
		self:hideBtn()
		return
	end

	-- 随机获得一个文学典籍作为参考
	self.currLiterary = BookLiterary:getExamLiterary()

	local role = User:getRole()
	local literary = role:getLiterary(self.currLiterary.id)

	print("当前典籍ID = " .. self.currLiterary.id)

	-- 输出文本
	-- RED你脑袋空空，不知道从何入手，看来只能胡写一气了。
	if literary then
		self:print(self.currLiterary["sentence" .. math.random(1, 3)])
	else
		self:print("RED你脑袋空空，不知道从何入手，看来只能胡写一气了。")
	end

	-- 文体按钮
	local styleList = string.split(self.currLiterary.wenti, ",")
	self.examStyle = {}

	for i,v in ipairs(styleList) do
		table.insert(self.examStyle, Exam:getExamStyle(v))
	end

	self:setStyleButton()

end

-- 刷新UI
function PalaceExamLayer:refreshUI()
	self.Text_yishu_num:setString(self:getPointDesc(self.artPoint, 1))
	self.Text_yili_num:setString(self:getPointDesc(self.truthPoint, 2))
	self.Text_shiyong_num:setString(self:getPointDesc(self.practicalPoint, 3))
	self.Text_jingjie_num:setString(self:getPointDesc(self.ambitPoint, 4))
	self.Text_chuanxin_num:setString(self:getPointDesc(self.innovatePoint, 5))

	if #self.choiceHistory >= 8 then
		local textColor = cc.c3b(255, 255, 255)
		self.Image_submit:setEnabled(true)
		self.Image_submit.Text_name:setColor(textColor)
	else
		local textColor = cc.c3b(34, 34, 34)
		self.Image_submit:setEnabled(false)
		self.Image_submit.Text_name:setColor(textColor)
	end
end

function PalaceExamLayer:UpdateTime(dt)
	local currTime = GetTime()
	local sec = 0

	sec = math.floor(300 - (currTime - self.startTime))

	if sec <= 0 then
		sec = 0
		if self._handle ~= nil then
			self:unschedule(self._handle)
			self._handle = nil
		end

		self:calcPoint()
		self:showEndPanel("随着监考的礼部尚书一声“时辰已到”，殿上的诸位考生，不论是否已经写完，都放下了手中的毛笔。本次殿试到此结束。欲知是否高中，只有静候发榜了。", "结束殿试", function()
			self:calcPoint()
			PopupLayerController:hideLayer("PalaceExamLayer", function(layer)
				self:hide()
			end, 0)
		end)
	end

	self.Text_time_num:setString(sec)
	-- self.LoadingBar:setPercent((sec / 300) * 100)
	self:refreshUI()
	self:updateBar()
end

-- 更新进度条
function PalaceExamLayer:updateBar(dt)
	if self.loadingBar and self.readTime then
		local currTime = GetTime()
		local per = math.floor((1 - ((currTime - self.readTime) / 3)) * 100)
		local bar = self.loadingBar

		-- 第一秒后弹出一句文本
		if self.writeDescShow == true and currTime - self.readTime > 1 then
			self.writeDescShow = false
			local desc = {
				"HIC你悬腕挥毫，笔走龙蛇。",
				"HIC你银钩铁画，满纸漂亮的馆阁体。",
				"HIC你一鼓作气，下笔如飞。",
				"HIC笔墨纵横，文章渐渐成型。",
				"HIC文思泉涌，笔意翻江倒海。",
			}
			local role = User:getRole()
			local literary = role:getLiterary(self.currLiterary.id)
			if literary then
				self:print(desc[math.random(1, #desc)])
			end
		end

		if per <= 0 then
			per = 0
			self.loadingBar = nil
			self.readTime = nil

			bar:setPercent(per)

			local role = User:getRole()
			local literary = role:getLiterary(self.currLiterary.id)
			if literary then
				local desc =
				{
					[1] = "HIC你大笔一挥，以" .. self.examStyle[self.btnIndex].name .. "为体，将所思所想写下。",
					[2] = "HIC你以" .. self.examStyle[self.btnIndex].name .. "为体，将所思所想变成一行行文字。",
					[3] = "HIC以" .. self.examStyle[self.btnIndex].name .. "为体，你条分缕析，构建起文章的脉络。",
				}

				self:print(desc[math.random(1, #desc)])
			else
				self:print("RED写出来的东西毫无文采章法可言，看来是要无功而返了。")
			end

			self:recordChoice(self.currLiterary.id, self.examStyle[self.btnIndex].id)
			self:calcPoint()
			self:setLiterary()

			self.btnIndex = nil
		else
			bar:setPercent(per)
		end

	end
end


-- 记录选择 用于重新计算得分
function PalaceExamLayer:recordChoice(literaryId, styleId)
	if #self.choiceHistory < 8 then
		table.insert(self.choiceHistory, {literaryId = literaryId, styleId = styleId} )
	end
end

-- 计算分数 并提交成绩
function PalaceExamLayer:calcPoint()
	local art = 0
	local truth = 0
	local practical = 0
	local ambit = 0
	local innovate = 0

	local role = User:getRole()
	for i,v in pairs(self.choiceHistory) do
		local lv = role:getLiteraryLv(v.literaryId)
		local literary = BookLiterary:getLiteraryById(v.literaryId)
		local style = Exam:getExamStyle(v.styleId)

		if lv and lv > 0 then
			print("=====================")
			print(literary.name .. " " .. style.name)
			print("艺术得分" .. math.floor((literary.art * (lv + 1) ^ 0.9 + 50) * style.art))
			print("义理得分" .. math.floor((literary.truth * (lv + 1) ^ 0.9 + 50) * style.truth))
			print("实用得分" .. math.floor((literary.practical * (lv + 1) ^ 0.9 + 50) * style.practical))
			print("境界得分" .. math.floor((literary.ambit * (lv + 1) ^ 0.9 + 50) * style.ambit))
			print("创新得分" .. math.floor((literary.innovate * (lv + 1) ^ 0.9 + 50) * style.innovate))
			print("=====================")

			art = art + math.floor((literary.art * (lv + 1) ^ 0.9 + 50) * style.art)
			truth = truth + math.floor((literary.truth * (lv + 1) ^ 0.9 + 50) * style.truth)
			practical = practical + math.floor((literary.practical * (lv + 1) ^ 0.9 + 50) * style.practical)
			ambit = ambit + math.floor((literary.ambit * (lv + 1) ^ 0.9 + 50) * style.ambit)
			innovate = innovate + math.floor((literary.innovate * (lv + 1) ^ 0.9 + 50) * style.innovate)
		else
			print(literary.name .. "尚未获得")
		end
	end

	self.artPoint = art
	self.truthPoint = truth
	self.practicalPoint = practical
	self.ambitPoint = ambit
	self.innovatePoint = innovate

	local totalPoint = self:calcTotalPoint(art, truth, practical, ambit, innovate)
	print("总分 = " .. totalPoint)

	local currTime = GetTime()
	local examTime = currTime - self.startTime
	if examTime >= 300 then
		examTime = 300
	end
	Exam:savePalaceExamScore(totalPoint, examTime)
end

-- 计算总分
function PalaceExamLayer:calcTotalPoint(art, truth, practical, ambit, innovate)
	if self.subject then
		return self.subject.art * art + self.subject.truth * truth + self.subject.practical * practical + self.subject.ambit * ambit + self.subject.innovate * innovate
	end

	return 0
end

function PalaceExamLayer:setButton()
	self.Panel_category.Button_return:releaseFunc(function()
		PopupLayerController:hideLayer("PalaceExamLayer", function(layer)
			self:hide()
		end, 0)
	end)

----------------------------------------------------
	-- 交卷
	self.Image_submit:releaseFunc(function()
		Audio:playEffect("xiaoAnNiu")
		if #self.choiceHistory < 8 then
			PopText("不可交卷")
		end

		self:showEndPanel("你确定要提前交卷吗？这样级别的考试多少慎重一点吧。", "交卷", function()
			self:calcPoint()
			PopupLayerController:hideLayer("PalaceExamLayer", function(layer)
				self:hide()
			end, 0)
		end,"取消")
	end)

	-- 重写
	self.Image_afresh:releaseFunc(function()
		Audio:playEffect("xiaoAnNiu")
		if self.btnIndex ~= nil or #self.choiceHistory <= 0 then
			return
		end

		self:showEndPanel("重写会把当前的分数清空，如果时间紧张，不建议重写。确定要重写吗？", "重写", function()
			self:print("HIC你对之前写的文章不甚满意，决定重写，希望时间还来得及吧……")
			self.choiceHistory = {}
			self:calcPoint()
			self:setLiterary()
		end,"取消")
	end)
----------------------------------------------------

	self.Button_1:releaseFunc(function()
		Audio:playEffect("xiaoAnNiu")
		if MapIsEmpty(self.examStyle) == true then
			return
		end

		self:setLoadingBar(1)
	end)

	self.Button_2:releaseFunc(function()
		Audio:playEffect("xiaoAnNiu")
		if MapIsEmpty(self.examStyle) == true then
			return
		end

		self:setLoadingBar(2)
	end)

	self.Button_3:releaseFunc(function()
		Audio:playEffect("xiaoAnNiu")
		if MapIsEmpty(self.examStyle) == true then
			return
		end

		self:setLoadingBar(3)
	end)

	self.Button_4:releaseFunc(function()
		Audio:playEffect("xiaoAnNiu")
		if MapIsEmpty(self.examStyle) == true then
			return
		end

		self:setLoadingBar(4)
	end)

	self.Button_5:releaseFunc(function()
		Audio:playEffect("xiaoAnNiu")
		if MapIsEmpty(self.examStyle) == true then
			return
		end

		self:setLoadingBar(5)
	end)

	self.Button_6:releaseFunc(function()
		Audio:playEffect("xiaoAnNiu")
		if MapIsEmpty(self.examStyle) == true then
			return
		end

		self:setLoadingBar(6)
	end)
end

-- 设置进度条
function PalaceExamLayer:setLoadingBar(index)
	if self.btnIndex ~= nil then
		return
	end
	local btnList =
	{
		self.Button_1,
		self.Button_2,
		self.Button_3,
		self.Button_4,
		self.Button_5,
		self.Button_6,
	}

	for i,v in pairs(btnList) do
		v:setTouchEnabled(false)
		if index ~= i then
			v:setVisible(false)
		end
	end

	-- 设置当前按钮进度条 3秒后写完
	self.btnIndex = index
	self.loadingBar = btnList[index].ButtonBar
	self.readTime = GetTime()
	self.writeDescShow = true
end

-- 隐藏按钮
function PalaceExamLayer:hideBtn()
	self.Button_1:setVisible(false)
	self.Button_2:setVisible(false)
	self.Button_3:setVisible(false)
	self.Button_4:setVisible(false)
	self.Button_5:setVisible(false)
	self.Button_6:setVisible(false)
end

-- 设置文体按钮
function PalaceExamLayer:setStyleButton()
	if MapIsEmpty(self.examStyle) == true then
		print("self.examStyle is IsEmpty")
		return nil
	end

	local btnList =
	{
		self.Button_1,
		self.Button_2,
		self.Button_3,
		self.Button_4,
		self.Button_5,
		self.Button_6,
	}

	for i,v in ipairs(btnList) do
		v:setTouchEnabled(true)
		v:setVisible(true)
		v.ButtonBar:setPercent(100)
		v.ButtonBar.Text_ButtonName:setString(self.examStyle[i].name)
	end
end

-- 获得描述
function PalaceExamLayer:getPointDesc(point, type)
	local descList = pointDesc[type]
	local desc = ""
	local color = "NOR"

	if point <= 0 then
		return "HIW0						"
	end

	if descList then
		for i,v in ipairs(descList) do
			if point >= v.value then
				desc = v.desc
				color = v.color
			end
		end
	end

	desc = color .. point .. " (" .. desc .. ")"

	return desc
end

-- 显示结束界面
function PalaceExamLayer:showEndPanel(text, btn1Name, func1, btn2Name, func2)
	self.Panel_back_1:setVisible(true)

	self.Panel_back_1.Text_desc:setString(text)

	self.Panel_back_1.Button_1:setVisible(btn1Name ~= nil)
	self.Panel_back_1.Button_2:setVisible(btn2Name ~= nil)
	if func1 == nil then
		func1 = function()
		end
	end

	if func2 == nil then
		func2 = function()
		end
	end

	if btn1Name then
		self.Panel_back_1.Button_1.Text_button_text:setString(btn1Name)
		self.Panel_back_1.Button_1:releaseFunc(function()
			func1()
			self.Panel_back_1:setVisible(false)
		end)
	end

	if btn2Name then
		self.Panel_back_1.Button_2.Text_button_text:setString(btn2Name)
		self.Panel_back_1.Button_2:releaseFunc(function()
			func2()
			self.Panel_back_1:setVisible(false)
		end)
	end

end

-- 初始化输出框
function PalaceExamLayer:initRichText()
	local x, y = self.Image_print.Panel_print:getPosition()
	local size = self.Image_print.Panel_print:getContentSize()

	if self.RichText_print then
		self.RichText_print:removeFromParent()
		self.RichText_print = nil
	end

	local richTextScroll = ExtRichTextScroll:create()
	richTextScroll:setAnchorPoint( 0.5 , 0.5 )
   	self.Image_print.Panel_print:getParent():addChild(richTextScroll)
   	local point = cc.p(self.Image_print.Panel_print:getPosition())
   	richTextScroll:move(point)
   	richTextScroll:setSize(size)
   	richTextScroll:setDirection(kCCScrollViewDirectionVertical)
   	richTextScroll:getRichText():setVerticalSpace(5)
   	self.RichText_print = richTextScroll

   	self.RichText_print:setBounceEnabled(false)
end

function PalaceExamLayer:print(str, verticalSpace)
	if str == "" then
		return
	end
	local textColor = cc.c3b(159,159,159)
	local textHeight = self.RichText_print:getRichText():getNewContentSizeHeight()
	if textHeight >= 6666 then
		self:initRichText()
	end

	self.RichText_print:pushBackText(str, textColor, 255, Resource:getFontPath("default"), 40)

	if verticalSpace ~= nil and type(verticalSpace) == "number" then
		self.RichText_print:pushBackNewLine(verticalSpace)
	else
		self.RichText_print:pushBackNewLine()
	end
end

Helper:classDefNodeGetInstance(PalaceExamLayer)

return PalaceExamLayer000000