local User = require("app.models.user.User")

local Role = require("app.models.role.Role")

-- 省试题目
local ProvinceExam =  require("script.exam.exam.lua")["shengshi"]

-- 殿试题目
local PalaceExam = require("script.exam.exam.lua")["dianshitimu"]

-- 文体表
local ExamStyle = require("script.exam.exam.lua")["wenti"]

-- 科举
local Exam = {}

-- 获得文体表
function Exam:getExamStyle(id)
	if MapIsEmpty(ExamStyle) == true then
		print("文体表为空")
		return nil
	end

	return ExamStyle[tostring(id)]
end

-- 获得殿试题目
function Exam:getPalaceQuestion(id)
	return PalaceExam[tostring(id)]
end

-- 获得省试题目
function Exam:getProvinceExamQuestion()
	if MapIsEmpty(ProvinceExam) == true then
		return nil
	end

	local count = 0

	for k,v in pairs(ProvinceExam) do
		count = count + 1
	end

	local randNum = math.random(1, count)
	local index = 0
	for k,v in pairs(ProvinceExam) do
		index = index + 1
		if index == randNum then
			return v
		end
	end
	return nil
end

-- 获取乡试奖励
function Exam:getVillageExamReward()
	local role = User:getRole()
	local reward =
	{
		[0] =  "xiangshijiangli11",
		[60] = "xiangshijiangli12",
		[65] = "xiangshijiangli13",
		[70] = "xiangshijiangli14",
		[75] = "xiangshijiangli15",
		[80] = "xiangshijiangli16",
		[85] = "xiangshijiangli17",
		[90] = "xiangshijiangli18",
		[95] = "xiangshijiangli19",
		[100] ="xiangshijiangli20",
	}

	if role:getTimeLimitFlag("乡试") == 0 then
		return false
	end

	local str = role:getTimeLimitFlag("乡试")
	local state = string.split(str, ";")[1]
	if state == "1" then
		print("已领取过乡试奖励 未通过考试")
		return false
	elseif state == "2" then
		print("已领取过乡试奖励 通过考试")
		return true
	end

	local rightCount = string.split(str, ";")[2]
	local point = rightCount * 5
	local index = -1

	for k,v in pairs(reward) do
		if point >= tonumber(k) and index < tonumber(k) then
			index = tonumber(k)
		end
	end

	-- 领取乡试奖励 根据得分获取策略ID
	local rewardSchemeId = reward[index]
	local rewardArray = RewardManager:getRewardArrayWithRewardSchemeWithoutRestriction(rewardSchemeId, role:getAttr("exp"), role:getFinalAttr("luck"), role:getKongfu())
	for i, reward in ipairs(rewardArray) do
		if reward.type == "物品" then

			PopText("获得了 " .. role:getOneItemByKey(reward.id).name)

			role:addItemCount(reward.id, reward.value)
		elseif reward.type == "属性" then
			if type(role:getCHAttrName(reward.id)) == "string" then
				PopText("获得" .. role:getCHAttrName(reward.id) .. tostring(reward.value))
			end
			role:addAttr(reward.id, reward.value)
		else
			error()
		end
	end

	if rightCount * 5 >= 60 then
		self:saveVillageExamScore(2, rightCount)
		return true
	else
		self:saveVillageExamScore(1, rightCount)
		return false
	end
end

-- 获得省试奖励
function Exam:getProvinceExamReward()
	TransCheck:setTransWithWebOrderId(function(transId)
		HttpManagerEx:getExamReward(1, transId, function(status, errcode, errmsg, data)
			if status == 200 then
				if errcode == 0 then
					TransCheck:updateTrans(transId, RESPONSE_STATUS_SUCCESS)
					local role = User:getRole()
					local rewardSchemeId = data.jiangli
					local rewardArray = RewardManager:getRewardArrayWithRewardSchemeWithoutRestriction(rewardSchemeId, role:getAttr("exp"), role:getFinalAttr("luck"), role:getKongfu())
					for i, reward in ipairs(rewardArray) do
						if reward.type == "物品" then

							PopText("获得了 " .. role:getOneItemByKey(reward.id).name)

							role:addItemCount(reward.id, reward.value)
						elseif reward.type == "属性" then
							if type(role:getCHAttrName(reward.id)) == "string" then
								PopText("获得" .. role:getCHAttrName(reward.id) .. tostring(reward.value))
							end
							role:addAttr(reward.id, reward.value)
						else
							error()
						end
					end
				else
					PopText(errmsg)
				end
			else
				PopText(errmsg)
			end
		end, IS_SHOW_WAITING)
	end, "shengshijiangli", 1, 10)
end

-- 获得殿试奖励
function Exam:getPalaceExamReward()
	TransCheck:setTransWithWebOrderId(function(transId)
		HttpManagerEx:getExamReward(2, transId, function(status, errcode, errmsg, data)
			if status == 200 then
				if errcode == 0 then
					TransCheck:updateTrans(transId, RESPONSE_STATUS_SUCCESS)
					local role = User:getRole()
					local rewardSchemeId = data.jiangli
					local rewardArray = RewardManager:getRewardArrayWithRewardSchemeWithoutRestriction(rewardSchemeId, role:getAttr("exp"), role:getFinalAttr("luck"), role:getKongfu())
					for i, reward in ipairs(rewardArray) do
						if reward.type == "物品" then

							PopText("获得了 " .. role:getOneItemByKey(reward.id).name)

							role:addItemCount(reward.id, reward.value)
						elseif reward.type == "属性" then
							if type(role:getCHAttrName(reward.id)) == "string" then
								PopText("获得" .. role:getCHAttrName(reward.id) .. tostring(reward.value))
							end
							role:addAttr(reward.id, reward.value)
						else
							error()
						end
					end

					self:getExtraReward("PalaceExam",rewardSchemeId)
				else
					PopText(errmsg)
				end
			else
				PopText(errmsg)
			end
		end, IS_SHOW_WAITING)
	end, "dianshijiangli", 1, 10)
end

-- 保存乡试成绩 state 0未领奖励 1 已领奖励未入榜 2 已经奖励已入榜, rightCount
function Exam:saveVillageExamScore(state, rightCount)
	-- 保存成绩
	local role = User:getRole()

	local week =
	{
		Monday = 1,
		Tuesday = 2,
		Wednesday = 3,
		Thursday = 4,
		Friday = 5,
		Saturday = 6,
		Sunday = 7,
	}
	if state == nil then
		state = 0
	end

	if rightCount == nil then
		rightCount = 0
	end

	rightCount = tonumber(rightCount)

	-- 下周一0点 重置
	local currTime = GetTime()
	local time = ( 7 - week[Helper:date("%A", currTime)] ) * 86400
	time = time + 86400 - (Helper:date("%H", currTime) * 3600) - (Helper:date("%M", currTime) * 60) - Helper:date("%S", currTime)

	print("保存乡试成绩 state = " .. state .. "答对次数 = " .. rightCount .. "重置时间 = " .. time)
	-- 标记格式 x;答对题数 (x 0 未发榜 1 已发奖励 不通过 2 已发奖励 已发榜通过)
	role:setTimeLimitFlag("乡试", state .. ";" .. rightCount , time)
end

-- 保存省试成绩 -- state 0 未领取奖励 1 已领取 2 作弊， 答对的题目数量, 时间,
function Exam:saveProvinceScore(state, rightCount, examTime)
	-- 保存成绩
	local role = User:getRole()

	local week =
	{
		Monday = 1,
		Tuesday = 2,
		Wednesday = 3,
		Thursday = 4,
		Friday = 5,
		Saturday = 6,
		Sunday = 7,
	}
	if state == nil then
		state = 0
	end

	if rightCount == nil then
		rightCount = 0
	end

	if examTime == nil then
		examTime = 300
	end

	-- 下周一0点 重置
	local currTime = GetTime()
	local time = ( 7 - week[Helper:date("%A", currTime)] ) * 86400
	time = time + 86400 - (Helper:date("%H", currTime) * 3600) - (Helper:date("%M", currTime) * 60) - Helper:date("%S", currTime)

	local skillExp = math.floor(role:getSkillExp("dushushizi"))
	local cheat = 0
	if state == 2 then
		cheat = 1
	end

	print("保存省试成绩 state = " .. state .. "答对次数 = " .. rightCount .. "重置时间 = " .. time)
	print("考试用时 = " .. examTime .." 读书识字经验 = " .. skillExp)

	HttpManagerEx:updateExamPoint(1, rightCount, rightCount * 5, examTime, skillExp, cheat, function(status, errcode, errmsg, data)
		if status == 200 then
			if errcode == 0 then
				print("上传成绩成功")
				-- 标记格式 x;答对题数 (x 0 未发榜 1 已发奖励 2 作弊)
				role:setTimeLimitFlag("省试", state .. ";" .. rightCount .. ";" .. examTime .. ";" .. skillExp, time)
			else
				PopText(errmsg)
			end
		else
			PopText(errmsg)
		end
	end, IS_SHOW_WAITING)
end

-- 保存殿试成绩
function Exam:savePalaceExamScore(totalPoint, examTime)
	if totalPoint == nil then
		totalPoint = 0
	end

	-- 保存成绩
	local role = User:getRole()
	local skillExp = math.floor(role:getSkillExp("dushushizi"))

	HttpManagerEx:updateExamPoint(2, 0, totalPoint, examTime, skillExp, 0, function(status, errcode, errmsg, data)
		if status == 200 then
			if errcode == 0 then
				print("上传成绩成功")
			else
				PopText(errmsg)
			end
		else
			PopText(errmsg)
		end
	end, IS_SHOW_WAITING)
end

-- 获取省试剩余时间
function Exam:getProvinceExamTime()
	local week =
	{
		Monday = 1,
		Tuesday = 2,
		Wednesday = 3,
		Thursday = 4,
		Friday = 5,
		Saturday = 6,
		Sunday = 7,
	}
	local currTime = GetTime()
	local time = ( 5 - week[Helper:date("%A", currTime)] ) * 86400
	time = time + 86400 - (Helper:date("%H", currTime) * 3600) - (Helper:date("%M", currTime) * 60) - Helper:date("%S", currTime)

	local hour = math.ceil( time / 3600 )
	return hour
end

-- 获得殿试剩余时间
function Exam:getPalaceExamTime()
	local week =
	{
		Monday = 1,
		Tuesday = 2,
		Wednesday = 3,
		Thursday = 4,
		Friday = 5,
		Saturday = 6,
		Sunday = 7,
	}
	local currTime = GetTime()
	local time = ( 7 - week[Helper:date("%A", currTime)] ) * 86400

	time = time + 86400 - (Helper:date("%H", currTime) * 3600) - (Helper:date("%M", currTime) * 60) - Helper:date("%S", currTime) - 3 * 3600

	local hour = math.ceil( time / 3600 )
	return hour

end

-- 检测能够参加省试 return 1 能参加 2 未参加乡试 3 乡试未通过
function Exam:checkCanProvinceExam()
	local role = User:getRole()

	local str = role:getTimeLimitFlag("乡试")
	if str ~= 0 then
		if string.split(str, ";")[2] * 5 < 60 then
			return 3
		end
	else
		return 2
	end
	return 1
end

-- 本地检测是否在省试时间内 周一到周五
function Exam:checkInProvinceExamTime()
	local week =
	{
		Monday = 1,
		Tuesday = 2,
		Wednesday = 3,
		Thursday = 4,
		Friday = 5,
		Saturday = 6,
		Sunday = 7,
	}
	local currTime = GetTime()
	if week[Helper:date("%A", currTime)] >= 6 then
		return false
	end
	return true
end

-- 检测是否在殿试时间内 周六早上九点~ 周日晚上九点
function Exam:checkInPalaceExamTime()
	local week =
	{
		Monday = 1,
		Tuesday = 2,
		Wednesday = 3,
		Thursday = 4,
		Friday = 5,
		Saturday = 6,
		Sunday = 7,
	}
	local currTime = GetTime()
	if week[Helper:date("%A", currTime)] == 6 then
		if tonumber(Helper:date("%H", currTime)) >= 9 then
			return true
		end
	end

	if week[Helper:date("%A", currTime)] == 7 then
		if tonumber(Helper:date("%H", currTime)) < 21 then
			return true
		end
	end
	print("殿试未开始")
	return false
end

--高考来临额外奖励
function Exam:getExtraReward(type,level)
	local rewardIds={
		["PalaceExam"] = {
			["dianshijiangli11"] = "dianshijiangli19",
			["dianshijiangli12"] = "dianshijiangli19",
			["dianshijiangli13"] = "dianshijiangli18",
			["dianshijiangli14"] = "dianshijiangli18",
			["dianshijiangli15"] = "dianshijiangli17",
			["dianshijiangli16"] = "dianshijiangli17",
		},
	}
	if  GetTime() > Helper:getTimeStampWithStringDate("20200720", 0)  or GetTime() < Helper:getTimeStampWithStringDate("20200707", 0) then
		return 
	end

	local rewardSchemeId = rewardIds[type][level]
	if rewardSchemeId then
		local role = User:getRole()
		local rewardArray = RewardManager:getRewardArrayWithRewardSchemeWithoutRestriction(rewardSchemeId, role:getAttr("exp"), role:getFinalAttr("luck"), role:getKongfu())

		for i, reward in ipairs(rewardArray) do
			if reward.type == "物品" then
				PopText("获得了 " .. role:getOneItemByKey(reward.id).name)
				role:addItemCount(reward.id, reward.value)
			elseif reward.type == "属性" then
				PopText("获得" .. role:getCHAttrName(reward.id) .. tostring(reward.value))
				role:addAttr(reward.id, reward.value)
			else
				error()
			end
		end
	end
end



return Exam000