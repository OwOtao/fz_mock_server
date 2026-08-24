--
-- Author: TanQinJian
-- Date: 2019-10-29 17:19:35
--
local LadderLanternPaperUtil = {}

local paperTable = require("script.others.yunticaideng.lua")["paper"]
local paperAward = require("script.others.yunticaideng.lua")["award"]

--获取当前纸签信息
function LadderLanternPaperUtil:getPaperInfo(paperId)
	if not paperId then 
		print("LadderLanternPaperUtil:getPaperInfo 参数出错")
		return
	end

	for index, paperInfo in pairs(paperTable) do 
		if paperId == paperInfo.id  then 
			return paperInfo
		end
	end
	print("LadderLanternPaperUtil:getPaperInfo 找不到对应纸签",paperId)
	return
end

--获取随机纸签
function LadderLanternPaperUtil:getRandomPaper()
	if MapIsEmpty(paperTable) then 
		print("LadderLanternPaperUtil:getPaper 策划文件出错")
		return 
	end
	local weightList={}
	for index, paperInfo in pairs(paperTable) do 
		weightList[paperInfo.id] = paperInfo.paperRatio
	end
	local currPaperId = Helper:RandomByWeight(weightList)
	local currPaper = self:getPaperInfo(currPaperId)
	return currPaper
end 

function LadderLanternPaperUtil:getAllPaper()
	if MapIsEmpty(paperTable) then 
		print("策划资源文件出错 script.others.yunticaideng.lua ")
	end
	local paperList={}
    for k,v in pairs(paperTable) do 
        table.insert(paperList,v)
    end

    --默认 根据id排序
    table.sort(paperList,function(a, b)
      return a.id < b.id
    end)

	return paperList

end

--paperId 对应纸签 addTimes 增加次数    paperId addTimes 类型为数字
function LadderLanternPaperUtil:setRolePaperData(paperId,addTimes)
	if type(paperId) ~="number" or type(addTimes) ~="number" then 
		print("请检查参数类型 LadderLanternPaperUtil:setRolePaperData")
		return
	end
	local role = User:getRole()
	local currPaperData = role:getInheritFlag("纸签数据")
	if currPaperData == 0 then 
		currPaperData = {}
	end

	--纸签对应id为数字 存储以字符串存储
	paperId = tostring(paperId)

	if currPaperData[paperId] then 
		currPaperData[paperId] = currPaperData[paperId] + addTimes
	else
		currPaperData[paperId] = math.max(addTimes,0) --数量为零情况不存在减 
	end
	if currPaperData[paperId] == 0 then 
		currPaperData[paperId] = nil
	end
	role:setInheritFlag("纸签数据",currPaperData)
end

--修复因table下标为数字导致转化数据丢失bug
function LadderLanternPaperUtil:fixPaperData()
	local role = User:getRole()
	local currPaperData = role:getInheritFlag("纸签数据")
	--没数据默认修复
	if currPaperData == 0 then 
		currPaperData = {}
		currPaperData["数据修复"] = true
		role:setInheritFlag("纸签数据", currPaperData)
		return
	end

	if currPaperData["数据修复"] then 
		return
	end

	local currPaperInfo = self:getAllPaper()
	local lostNum = 0
	for paperId,num in pairs(currPaperData) do
		local isPaper = false
		for k,v in pairs(currPaperInfo) do
			if paperId == v.id then 
				isPaper = true
			end
		end
		if isPaper then 
			--记录转化之前的数据
			currPaperData[tostring(paperId)] = num
		else
			lostNum = lostNum + num
		end
		--删除转化后不合法数据
		currPaperData[paperId] = nil 
	end
	--记录丢失数据
	currPaperData["丢失数量"] = lostNum
	currPaperData["数据修复"] = true
	role:setInheritFlag("纸签数据", currPaperData)
end

function LadderLanternPaperUtil:checkPaperIsEnough(paperId,paperNeedNum)
	local role = User:getRole()
	local currPaperData = role:getInheritFlag("纸签数据")
	if currPaperData == 0 then 
		return false
	end
	for id,num in pairs(currPaperData) do 
		if tonumber(paperId) == tonumber(id) then
			if  tonumber(num) >= tonumber(paperNeedNum) then 
				return true
			end
		end
	end
	return false
end

function LadderLanternPaperUtil:getAllReward()
	if MapIsEmpty(paperAward) then 
		print("策划资源文件出错 script.others.yunticaideng.lua ")
	end
	local paperAwardList={}
    for k,v in pairs(paperAward) do 
        table.insert(paperAwardList,v)
    end

    --默认 根据id排序
    table.sort(paperAwardList,function(a, b)
      return a.id < b.id
    end)

	return paperAwardList
end

function LadderLanternPaperUtil:getRewardInfo(rewardId)
	for index,info in pairs(paperAward) do 
		if rewardId == info.id then 
			return info
		end
	end
	print("未找到该id对应奖励：rewardId",rewardId)
	return
end

return LadderLanternPaperUtil00000