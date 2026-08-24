local questionnaire = {}

local QSMaps = require("script.others.Questionnaires") ["Sheet1"]
local questionMap = {}  -- 根据题目生成的问卷数据
local question = {
	answers = {},
	id = 1,
	dec = "",
	prize = {}
}

--@desc: 生成当前问题的答案列表
--@author:Liang Songqiang
--@time:2017-09-18 09:41:35
local function getAnswerList(question)
	local list = {}
	for k, v in pairs(question) do
		local str = string.sub(k, 1, 6)
		if str == "answer" then
			list[k] = v
		end
	end
	return list
end


--@desc: 生成问卷题目列表，并与奖励列表对应
--@author:Liang Songqiang
--@time:2017-09-18 09:43:56
--@questions: 问卷题目列表
--[[	@doCurrResults: 奖励列表(可以是条件结果集，也可以是一个方法列表)
	字符串：“1；2；3；4；5；7；8“
	方法列表：{
		preFunc = function()end      --答案上传前执行
		runFunc = function()end      --答案上传成功后运行
		afterFunc = function()end    --无论答案上传成功与否都执行
	}
]]
function questionnaire:initQuestionMap(questions, doCurrResults)
	if MapIsEmpty(questions) then
		if DEBUG_MODE == 1 then
			print("questions 为空，创建问卷失败")
		end
		return
	end
	
	if not MapIsEmpty(questionMap) then
		self:clearQuestionMap()
	end
	
	for i, v in ipairs(questions) do
		local question = QSMaps[tostring(v)]
		--最后一题设置奖励
		if i == #questions then
			local prize = doCurrResults
			--如果不是一个方法，则设置为字符串
			if type(prize) ~= "table" then
				prize = Helper:getDef(prize, "")
			end
			question.prize = prize
		end
		table.insert(questionMap, question)
	end
	
	if DEBUG_MODE == 1 then
		print("================ 创建问卷 ================")
		Helper:print_lua_table(questionMap)
	end
	return questionMap
end

--@desc: 重置问卷题目列表
--@author:Liang Songqiang
--@time:2017-09-18 09:45:48
function questionnaire:clearQuestionMap()
	questionMap = {}
end

--@desc: 创建一个问题
--@author:Liang Songqiang
--@time:2017-09-15 24:14:57
--@index: 问题Map索引 
--@return [app.models.QAModel.qs#question]
function questionnaire:getQuestion(index)
	local q = questionMap[tonumber(index)]
	local aList = getAnswerList(q)
	question.answers = aList
	question.id = q.id
	question.dec = q.dec
	question.canSeleted = q.canSeleted
	if q.prize ~= nil then
		question.prize = q.prize
	end
	return question
end

--@desc: 获取问卷题目数量
--@author:Liang Songqiang
--@time:2017-09-15 15:27:21
function questionnaire:getQuesCount()
	local count = 0
	for k, v in pairs(questionMap) do
		count = count + 1
	end
	return count
end


return questionnaire 00000