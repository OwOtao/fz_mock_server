local QSLayer = class("QSLayer", LayerEx)
local qs = require("app.models.QAModel.qs")

--[[数据格式：
{
	id = answer1
	val = wenjuan_300_hasIn_question1_answer1
}
]]
local answer_list = {}
local questions = {}
local curr_answer_list = {}
local isFirst = 0

--@desc: 添加当前问题的答案
--@author:Liang Songqiang
--@time:2017-09-15 16:25:25
--@currQId: 当前问题ID
--@answer: 答案 
local function addAnswer(currQId, answer)
	local t = {
		id = currQId,
		answer = answer
	}
	table.insert(curr_answer_list, t)
	if PRINT_MODE == 1 then
		print("================ 添加一个答案 =================")
		Helper:print_lua_table(curr_answer_list)
	end
end


--@desc: 移除当前问卷的一个答案
--@author:Liang Songqiang
--@time:2017-09-15 16:25:50
local function removeAnswer(answer)
	for i, v in ipairs(curr_answer_list) do
		if v.answer == answer then
			table.remove(curr_answer_list, i)
			if PRINT_MODE == 1 then
				print("================ 移除一个答案 =================")
				Helper:print_lua_table(curr_answer_list)
			end
		end
	end
end

--@desc: 添加次份问卷的答案
--@author:Liang Songqiang
--@time:2017-09-15 16:26:11
--@content: 问卷标识
local function addTotalAnswer(content, index, count)
	--@RefType [app.models.role.Role#Role]
	local role = User:getRole()
	
	local lvDesc = 300
	if role:getLv() > 0 and role:getLv() < 300 then
		lvDesc = 300
	elseif role:getLv() > 300 and role:getLv() < 500 then
		lvDesc = 500
	elseif role:getLv() > 500 and role:getLv() < 700 then
		lvDesc = 700
	elseif role:getLv() > 700 then
		lvDesc = 701
	end
	
	local inheritDesc = "notChuanchen"
	if role:getAttr("inheritCount") > 0 then
		inheritDesc = "hasChuanchen"
	end
	
	for _, val in pairs(curr_answer_list) do
		local data = ""
		if index >= count then
			data = content .. "_" .. lvDesc .. "_" .. inheritDesc .. "_timu" .. val.id .. "_" .. val.answer	.. "_finish"
		else
			data = content .. "_" .. lvDesc .. "_" .. inheritDesc .. "_timu" .. val.id .. "_" .. val.answer
		end
		table.insert(answer_list, data)
	end
	
	if PRINT_MODE == 1 then
		print("================ 上传答案 =================")
		Helper:print_lua_table(answer_list)
	end
	-- answer_list = {}
	curr_answer_list = {}
	isFirst = 0
end


function QSLayer:create()
	local p = QSLayer:new()
	p:init()
	return p
end


function QSLayer:init()
	self._UI = require("Layer/QALayer/QSUI.lua").create() ['root']
	self._UI:addTo(self)
	Helper:convertUIByParent(self)
end


--@desc: 
--@author:Liang Songqiang
--@time:2017-09-20 14:50:59
--@content: 问卷标识
--@tb: --[[可选参数{isHide:是否每答完一题就关闭窗口（0 | 1），fprize: 全部答完的条件结果}]]
function QSLayer:showLayer(content, tb)
	self.content = content						--问卷标识
	self.index = 1 							--题目索引
	self.isHide = tb.isHide						--答完每题后是否关闭		
	self.fprize = tb.fprize						--所有问题答完后的条件结果
	self:initQuestion()
	self:show()
end

--@desc: 创建问题
--@author:Liang Songqiang
--@time:2017-09-22 10:23:00
function QSLayer:initQuestion()
	--@RefType [app.models.role.Role#Role]
	local role = User:getRole()
	local index = tonumber(role:getInheritFlag(tostring(self.content)))
	if index ~= 0 and index ~= "finish" and index ~= nil then
		if PRINT_MODE == 1 then
			print("----------------- Read cache，Question Index ：" .. index .. " -----------------")
		end
		self.index = index
	end
	
	local question = qs:getQuestion(self.index)
	self.answers = question.answers						--答案列表
	self.canSeleted = question.canSeleted				--每题最多可选的条目
	self.currid = question.id							--题目ID
	if question.prize ~= nil then
		if type(question.prize) == "string" then		--完后的奖励(条件结果集 or 一个function Map)
			self.prize = string.gsub(question.prize, ",", ";")
		elseif type(question.prize) == "table" then
			self.prize = question.prize
		end
	end
	self.count = qs:getQuesCount()						--此份问卷的总题目数
	self:setRichTextDesc(question.dec)
	self:setAnswerBtn()
	self:setNextBtn()
	self:setCancelBtn()
end


--@desc: 创建问卷标题框
--@author:Liang Songqiang
--@time:2017-09-14 16:32:49
function QSLayer:initQuestionDesc()
	local x, y = self.Text_Question:getPosition()
	local size = self.Text_Question:getContentSize()
	if self.richText then
		self.richText:getRichText():removeAllElement()
		return
	end
	local richTextScroll = ExtRichTextScroll:create()
	self.Text_Question:getParent():addChild(richTextScroll)
	richTextScroll:move(cc.p(x, y))
	richTextScroll:setSize(size)	
	richTextScroll:setDirection(kCCScrollViewDirectionVertical)
	richTextScroll:getRichText():setVerticalSpace(5)
	richTextScroll:setBounceEnabled(false)
	richTextScroll:setTouchEnabled(false)
	self.richText = richTextScroll
end


local textColor = cc.c3b(255, 255, 255)
--@desc: 设置文本 
--@author:Liang Songqiang
--@time:2017-09-14 16:29:33
function QSLayer:setRichTextDesc(text, verticalSpace)
	self:initQuestionDesc()
	text = text .. "HIC【最多选" .. tonumber(self.canSeleted) .. "个】NOR"
	self.richText:pushBackText(text, textColor, 255, Resource:getFontPath("default"), 48)
	if verticalSpace ~= nil and type(verticalSpace) == "number" then
		self.richText:pushBackNewLine(verticalSpace)
	else
		self.richText:pushBackNewLine()
	end
end

--@desc: 设置答题按钮
--@author:Liang Songqiang
--@time:2017-09-14 16:29:33
function QSLayer:setAnswerBtn()
	self.ListView_Answer:removeAllItems()
	for key, answer in pairs(self.answers) do
		local row = self.CheckBox_Answer:clone()
		Helper:convertUI(row)
		row.Text_button_1:setString(answer)
		local function selectedEvent(sender, eventType)
			if eventType == ccui.CheckBoxEventType.selected then
				if #curr_answer_list >= self.canSeleted then
					PopText("此题最多可选" .. self.canSeleted .. "项")
					row:setSelectedState(false)
					row.Text_button_1:setTextColor({r = 208, g = 208, b = 208})
					return
				end
				print("====================selected % " .. key .. " % selected=====================")
				addAnswer(self.currid, key)
				row.Text_button_1:setTextColor({r = 80, g = 246, b = 244})
			elseif eventType == ccui.CheckBoxEventType.unselected then
				print("====================unselected %" .. key .. "% unselected=====================")
				removeAnswer(key)
				row.Text_button_1:setTextColor({r = 208, g = 208, b = 208})
			end
		end
		row:addEventListenerCheckBox(selectedEvent)
		self.ListView_Answer:pushBackCustomItem(row)
	end
end

--@desc: 跳转下一题
--@author:Liang Songqiang
--@time:2017-09-15 16:00:25
function QSLayer:setNextBtn()
	self.Button_Next:releaseFunc(function()
		if MapIsEmpty(curr_answer_list) then
			-- if self.canSeleted > 1 then
			-- 	PopText("可多项选择")
			-- 	return
			-- end
			PopText("请选择一个选项")
			return
		elseif self.canSeleted > 1 and #curr_answer_list <= 1 and isFirst == 0  then
			if isFirst == 0 then
				PopText("本题为多选题，少侠可选择最多3个选项")
			end
			isFirst = 1
			-- PopText("可多项选择")
			return
		end
		
		--最后一题
		if self.prize ~= nil and type(self.prize) == "table" then
			local preFunc = self.prize.preFunc
			if preFunc ~= nil and type(preFunc) == "function" then
				local check = Helper:getDef(preFunc(), true)
				if not check then
					return
				end
			end
		end
		
		--把当前问题的答案提交
		addTotalAnswer(self.content, self.index, self.count)
		HttpManagerEx:countMultiRecord(answer_list, function(status, errcode, errmsg, data)
			if status == 200 and errcode == 0 then
				if self.index >= self.count then
					local QuestionnaireLayer = require("app.views.layer.ActionLayer.QuestionnaireLayer")
	                    local dialog = QuestionnaireLayer:getInstance()
	                    dialog:showLayer()
					if PRINT_MODE == 1 then
						print("----------------- you finish this questionnaires -----------------")
					end
					self:givePrizes()
					self:clearCache()
					self:hide()
				else
					self.index = self.index + 1
					self:setCache()
					if self.isHide == 0 then
						self:hide()
					else
						self:initQuestion()
					end
				end
				answer_list = {}
			else
				PopText(errmsg)
			end
			if type(self.prize.afterFunc) == "function" then
				local afterFunc = self.prize.afterFunc
				afterFunc()
			end
		end)
	end)
end

--@desc: 发放奖品
--@author:Liang Songqiang
--@time:2017-09-22 17:33:37
function QSLayer:givePrizes()
	print(".......................................................................")
	local QuestionnaireLayer = require("app.views.layer.ActionLayer.QuestionnaireLayer")
	local dialog = QuestionnaireLayer:getInstance()
	dialog:showLayer()
end

--@desc: 设置取消按钮
--@author:Liang Songqiang
--@time:2017-09-14 16:31:56
function QSLayer:setCancelBtn()
	self.Button_Cancel:releaseFunc(function()
		if not MapIsEmpty(curr_answer_list) then
			curr_answer_list = {}
			isFirst = 0
		end
		PopText("本次问卷尚未提交。")
		self:hide()
	end)
end

--@desc: 设置缓存
--@author:Liang Songqiang
--@time:2017-09-18 15:49:19
-- content 当前问卷的标识索引
-- currQueId 当前问题的索引
--[content] = currQueId 
function QSLayer:setCache()
	--@RefType [app.models.role.Role#Role]
	local role = User:getRole()
	role:setInheritFlag(tostring(self.content), tostring(self.index))
end

--@desc: 清除缓存
--@author:Liang Songqiang
--@time:2017-09-18 15:49:30
function QSLayer:clearCache()
	--@RefType [app.models.role.Role#Role]
	local role = User:getRole()
	self.index = "finish"
	role:setInheritFlag(tostring(self.content), tostring(self.index))
	role:setInheritFlag("tiankongti",0)
end

Helper:classDefNodeGetInstance(QSLayer)
return QSLayer 000000