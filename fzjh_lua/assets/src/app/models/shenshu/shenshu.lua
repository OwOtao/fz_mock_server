local ShenShuHelper = {}
local TreasureList = require("script.others.Treasure")
local ShenShuList = TreasureList["神书列表"]
local ShenShuVersionFuncHelper = require("app.models.shenshu.ShenShuVersionFuncHelper")
local shenShuTaskDuration = 3600

--需要到更新时间(20250630零点)后的第一个星期一才生效一周七次

--[[
    @desc: 获取当前版本
    author:tanqinjian
    time:2025-06-07 18:31:57
    @return: 0 为旧版本 1为新版本
]]
function ShenShuHelper:getVersion()
	if Game:isTesting() then
		local DebugHelper = require("app.views.layer.DebugLayer.DebugHelper")
		if DebugHelper:getShenShuVersion() then
			return DebugHelper:getShenShuVersion()
		end

		if WConfig and WConfig["新版神书任务"] == true then
			return 1
		else
			return 0
		end
	end
	
	if GetTime() < 1751212800 then
		return 0
	else
		return 1
	end
end

function ShenShuHelper:getHintText(itemId)
	if type(itemId) ~= "string" then
		return
	end

	local book = Item:getOneItemByKey(itemId)
	local role = User:getRole()
	local time = math.floor(self:getFindBookRemainingTime(role))
	local min,sec = tonumber(Helper:date("%M",time)),math.max(tonumber(Helper:date("%S",time)),1)
	if time >= 0 then
		-- 你将XXXX收入囊中，神书现世还剩余XXX。
		local str = "你将HIY"..book.name.."NOR收入囊中，神书现世还剩余HIY"
		if min > 0 then
			str = str .. tostring(min) .. "分"
		end
		str = str .. tostring(sec) .. "秒NOR。"
		RichPrint("main",str)
	end
end

function ShenShuHelper:getShenShuIdByItemId(itemId)
	for k, shenShuInfo in pairs(ShenShuList) do
		if itemId == shenShuInfo.iteMid then
			return shenShuInfo.Godid
		end
	end
end

function ShenShuHelper:getShenShuName(shenShuId)
	for k, shenShuInfo in pairs(ShenShuList) do
		if shenShuId == shenShuInfo.Godid then
			return shenShuInfo.Godname
		end
	end
end

function ShenShuHelper:getShenShuInfo(shenShuId)
	for k, shenShuInfo in pairs(ShenShuList) do
		if shenShuId == shenShuInfo.Godid then
			return shenShuInfo
		end
	end
end

function ShenShuHelper:getAutherWorks(auther)
    if not auther then
		return
	end

	local works = {}

	for k, v in pairs(ShenShuList) do
		if v.typE == auther then
			local info = {id = v.Godid, name = v.Godname}
			table.insert(works, #works + 1, info)
		end
	end
	
    return works
end

function ShenShuHelper:getShenShuAuthor()
    local list = {}
    
    for k, v in pairs(ShenShuList) do
        if table.indexof(list, v.typE) == false then
            table.insert(list, #list + 1, v.typE)
        end
    end

    return list
end

--[[
    @desc: 获取神书掉落房间附近随机房间
    author:tanqinjian
    time:2025-06-09 11:10:25
    --@mapId:
	--@roomId:
	--@stepType: 
    @return:
]]
function ShenShuHelper:getNearRooms(mapId, roomId, stepType)
	local list = {}
	local currMap = Map:getMapById(tostring(mapId))
	local shenShuConfig = TreasureList["神书信息配置"]
	local step = shenShuConfig[mapId][stepType]

	if step then
		list = currMap:getNearRoomsExceptSelf(roomId, step)
		local TransmitRoomModel = require("app.models.transmitRoom.TransmitRoomModel")
		local filterList = TransmitRoomModel:getShenShuFilterRoomList()

		if MapIsEmpty(filterList) == false then
			for i = #list, 1, -1 do
				if filterList[list[i]] then
					table.remove(list, i)
				end
			end
		end
	end

	return list
end

--[[
    @desc: 获取神书掉落房间附近随机房间名与roomId
    author:tanqinjian
    time:2025-06-09 11:49:48
    --@mapId:
	--@roomId: 
    @return:
]]
function ShenShuHelper:getNearRoomName(mapId, roomId)
    if mapId and roomId then
        local map = Map:getMapById(tostring(mapId))
        local roomList = self:getNearRooms(mapId, roomId, "step")

        for k, v in pairs(roomList) do
            if v == roomId then
                table.remove(roomList, k)
            end
        end

        roomId = roomList[math.random(1, #roomList)]

        for k, v in pairs(map["room"]) do
            if k == roomId then
                return v.name, roomId
            end
        end
    end
end

--[[
    @desc: 生成神书掉落信息
    author:tanqinjian
    time:2025-06-07 17:41:02
    @return: shenShuDropList
]]
function ShenShuHelper:createShenShuDropList()
	local shenShuDropList = {}

	local jinduList = Map:getCompletedMapList()
	local xinxiList = TreasureList["神书信息配置"]

	local ProbablList = {}
	for index, mapId in ipairs(jinduList) do
		ProbablList[index] = {}
		ProbablList[index].map = mapId
		ProbablList[index].Probablyroo = string.split(xinxiList[mapId].Probablyroo, ";")
		ProbablList[index]["step1"] = xinxiList[mapId]["step1"]
		ProbablList[index]["step"] = xinxiList[mapId]["step"]
		ProbablList[index].threEweight = string.split(xinxiList[mapId].threEweight, ";")
		ProbablList[index].newpeopleshuxing = xinxiList[mapId].newpeopleshuxing
	end

	for k, book in pairs(ShenShuList) do
		local roomid1 = math.random(1, #ProbablList)
		local roomid2 = math.random(1, #ProbablList[roomid1].Probablyroo)
		local baozhangList = self:getNearRooms(ProbablList[roomid1].map, ProbablList[roomid1].Probablyroo[roomid2],
			"step1")
		
		local _getType, shenshunpc, npcNum

		_getType = Helper:RandomByWeight(ProbablList[roomid1].threEweight)

		if _getType ~= 1 then
			print(book.newpeopleshuxing)
			local list = string.split(ProbablList[roomid1].newpeopleshuxing, ";")
			if list[2] then
				shenshunpc = list[2]
			end
			list = string.split(list[1], ",")
			if #list == 2 then
				npcNum = math.random(list[1], list[2])
			end
		end

		local bookInfo = {
			id = book.Godid,
			mapId = ProbablList[roomid1].map,
			roomId = baozhangList[math.random(1, #baozhangList)],
			itemId = book.iteMid,
			getType = _getType
		}

		if _getType ~= 1 then
			bookInfo.npcNum = npcNum
			for i = 1, npcNum do
				bookInfo["npcId" .. tostring(i)] = "shenshunpc" .. tostring(Helper:getOnlyId())
			end
		end

		table.insert(shenShuDropList, bookInfo)

		table.remove(ProbablList[roomid1].Probablyroo, roomid2)

		if #ProbablList[roomid1].Probablyroo == 0 then
			table.remove(ProbablList, roomid1)
		end
	end

	return shenShuDropList
end

--[[
    @desc: 生成神书送礼Npc相关信息
    author:tanqinjian
    time:2025-06-07 17:44:52
    @return: shenShuSongLiNpcList
]]
function ShenShuHelper:createSongLiNpcList()
	local shenShuSongLiNpcList = {}

	local mapList = Map:getCompletedMapList()

    local list = {}
    for _, mapId in pairs(mapList) do
        local t = {}
        t["roomList"] = string.split(TreasureList["神书送礼"][mapId].possibleRoom, ",")
        t["mapId"] = mapId
        table.insert(list, t)
    end

    for i = 1, 42 do
        local random = math.random(1, #list)
        shenShuSongLiNpcList[i] = {}
        shenShuSongLiNpcList[i]["mapId"] = list[random].mapId
        local room = math.random(1, #list[random].roomList)
        shenShuSongLiNpcList[i]["roomId"] = list[random].roomList[room]
        shenShuSongLiNpcList[i]["npcId"] = "shenshunpc" .. tostring(Helper:getOnlyId())
        shenShuSongLiNpcList[i]["bookId"] = "shenshu" .. tostring(i)
        if math.random(1, 2) == 1 then
            shenShuSongLiNpcList[i]["name"] = Helper:getRandomName("男")
            shenShuSongLiNpcList[i]["sex"] = "男"
        else
            shenShuSongLiNpcList[i]["name"] = Helper:getRandomName("女")
            shenShuSongLiNpcList[i]["sex"] = "女"
        end
    end

	return shenShuSongLiNpcList
end

--[[
    @desc: 询问灵石神书信息
    author:tanqinjian
    time:2025-06-07 18:29:17
    @return: 返回神书信息
]]
function ShenShuHelper:askLingShiToFindBook(role, bookId)
	local bookDropList = self:getTaskBookDropInfoList(role)
	local book

	for i, bookInfo in ipairs(bookDropList) do
		if bookId == bookInfo.id then
			book = bookInfo
			break
		end
	end

	if not book then
		return
	end

	local bookName = self:getShenShuName(bookId)

	local random = math.random(1, 3)
	local map = role:getMapById(book.mapId)
	local roomName, randid = self:getNearRoomName(book.mapId, book.roomId)
	if random == 1 then
		book.pointMsg = "你向灵石询问HIY" .. bookName ..
						"NOR的下落，只听一声轻响，灵石化作一道金光，光中显示出一幅场景，似乎是HIY" ..
						map.name .. roomName .. "NOR附近。"
	elseif random == 2 then
		book.pointMsg = "你向灵石询问HIY" .. bookName ..
						"NOR的下落，只听一声轻响，灵石化作一道金光，光中显示出一幅画面，但从画面上只能看出是HIY" ..
						roomName .. "NOR附近。"
	else
		book.pointMsg = "你向灵石询问HIY" .. bookName ..
						"NOR的下落，只听一声轻响，灵石化作一道金光，光中显示出一幅画面，但从画面上只能看出是HIY" ..
						map.name .. "NOR。"
	end

	book.randomRoom = randid
	book.randomType = random

	return book
end

--[[
    @desc: 周期内可完成最大次数
    author:tanqinjian
    time:2025-06-07 18:17:11
    @return: number
]]
function ShenShuHelper:getMaxCount()
	return ShenShuVersionFuncHelper:getMaxCount(self:getVersion())
end

--[[
    @desc: 周期内超出最大次数提示
    author:tanqinjian
    time:2025-06-07 18:17:37
    @return: string
]]
function ShenShuHelper:getCountLimitMsg()
	return ShenShuVersionFuncHelper:getCountLimitMsg(self:getVersion())
end

--[[
    @desc: 是否可开启神书任务
    author:tanqinjian
    time:2025-06-07 18:35:41
    --@role: 
    @return:
]]
function ShenShuHelper:checkCanOpenTask(role)
	local shenShuTask = role:getAttr("shenShuTask")

	local count = shenShuTask.count
	local task = shenShuTask.task
	local startTime = task.startTime

	if startTime > 0 and GetTime() - startTime < shenShuTaskDuration then
		return false, "当前神书已现世，赶紧开始寻找吧"
	end

	if count >= self:getMaxCount() then
		return false, self:getCountLimitMsg()
	end

	return true
end

--[[
    @desc: 开始神书任务
    author:tanqinjian
    time:2025-06-07 18:36:22
    --@role: 
    @return:
]]
function ShenShuHelper:startTask(role)
	local bookDropInfoList = self:createShenShuDropList()
	local shenShuTask = role:getAttr("shenShuTask")

	shenShuTask.count = shenShuTask.count + 1
	shenShuTask.allCount = shenShuTask.allCount + 1

	if shenShuTask.startTime == -1 then
		shenShuTask.startTime = GetTime()
	end

	shenShuTask.task = {
		startTime = GetTime(),
		bookDropInfoList = bookDropInfoList
	}

	if self:isSongLi(role) == false then
		local songLiNpcList = self:createSongLiNpcList()
		self:setTaskSongLiInfo(role, {startTime = GetTime(), npcList = songLiNpcList})
	end

	local ShenShuTaskRecord = require("app.models.Record.ShenShuRecord.ShenShuTaskRecord")
	local record = ShenShuTaskRecord:create(shenShuTask)
	record:submitRecord()
end

--[[
    @desc: 更新神书掉落信息
    author:tanqinjian
    time:2025-06-07 18:39:10
    --@role:
	--@list: 神书掉落列表
    @return:
]]
function ShenShuHelper:setTaskBookDropInfoList(role, list)
	local shenShuTask = role:getAttr("shenShuTask")
	local task = shenShuTask.task
	task.bookDropInfoList = list
end

--[[
    @desc: 获取神书掉落信息
    author:tanqinjian
    time:2025-06-07 18:39:36
    --@role: 
    @return:
]]
function ShenShuHelper:getTaskBookDropInfoList(role)
	local shenShuTask = role:getAttr("shenShuTask")
	return shenShuTask.task.bookDropInfoList
end

--[[
    @desc: 是否在神书收集时间内
    author:tanqinjian
    time:2025-06-07 18:39:47
    --@role: 
    @return:
]]
function ShenShuHelper:checkIsInFindBook(role)
	local shenShuTask = role:getAttr("shenShuTask")
	local task = shenShuTask.task

	if task.startTime == -1 then
		return false
	end

	return GetTime() - task.startTime < shenShuTaskDuration
end

--[[
    @desc: 是否在神书收集阶段
    author:tanqinjian
    time:2025-06-07 18:40:08
    --@role: 
    @return:
]]
function ShenShuHelper:isFindBook(role)
	local shenShuTask = role:getAttr("shenShuTask")
	local task = shenShuTask.task

	return task.startTime ~= -1
end

--[[
    @desc: 找到神书处理
    author:tanqinjian
    time:2025-06-07 18:41:09
    --@role:
	--@bookId: 
    @return:
]]
function ShenShuHelper:findBook(role, bookId)
	local shenShuTask = role:getAttr("shenShuTask")
	local task = shenShuTask.task
	local bookList = task.bookDropInfoList

	for i = #bookList, 1, -1 do
		if bookId == bookList[i].itemId then
			table.remove(bookList, i)
			return true
		end
	end

	return false
end

--[[
    @desc: 结束神书收集阶段
    author:tanqinjian
    time:2025-06-07 18:41:21
    --@role: 
    @return:
]]
function ShenShuHelper:endFindBook(role)
	local shenShuTask = role:getAttr("shenShuTask")
	local task = shenShuTask.task

	task.bookDropInfoList = {}
	task.startTime = -1
end

--[[
    @desc: 设置送礼相关数据
    author:tanqinjian
    time:2025-06-07 17:57:57
    --@role:
	--@info: {startTime = "送礼开始时间", npcList = {}}
    @return:
]]
function ShenShuHelper:setTaskSongLiInfo(role, info)
	role:setAttr("shenShuSongLiInfo", info)
end

--[[
    @desc: 设置送礼npc列表数据
    author:tanqinjian
    time:2025-06-07 18:42:10
    --@role:
	--@list: 
    @return:
]]
function ShenShuHelper:setTaskSongLiNpcList(role, list)
	local shenShuSongLiInfo = role:getAttr("shenShuSongLiInfo")
	shenShuSongLiInfo.npcList = list
end


--[[
    @desc: 获取送礼npc列表数据
    author:tanqinjian
    time:2025-06-07 18:42:24
    --@role: 
    @return:
]]
function ShenShuHelper:getTaskSongLiNpcList(role)
	local shenShuSongLiInfo = role:getAttr("shenShuSongLiInfo")
	return shenShuSongLiInfo.npcList
end

--[[
    @desc: 是否处于npc送礼阶段
    author:tanqinjian
    time:2025-06-07 18:42:39
    --@role: 
    @return:
]]
function ShenShuHelper:isSongLi(role)
	local shenShuSongLiInfo = role:getAttr("shenShuSongLiInfo")

	return shenShuSongLiInfo.startTime ~= -1
end

--[[
    @desc: 是否在npc送礼时间内
    author:tanqinjian
    time:2025-06-07 18:42:51
    --@role: 
    @return:
]]
function ShenShuHelper:checkIsInSongLiTime(role)
	local shenShuSongLiInfo = role:getAttr("shenShuSongLiInfo")

	if shenShuSongLiInfo.startTime == -1 then
		return false
	end

	return Helper:diffWithDate(GetTime(), shenShuSongLiInfo.startTime) < 1
end

--[[
    @desc: 清除送礼相关信息
    author:tanqinjian
    time:2025-06-07 18:43:09
    --@role: 
    @return:
]]
function ShenShuHelper:clearSongLiInfo(role)
	role:setAttr("shenShuSongLiInfo", {startTime = -1, npcList = {}})
end

--[[
    @desc: 神书任务是否需要刷新
    author:tanqinjian
    time:2025-06-04 15:43:27
    --@role: 
	--@useTime：使用灵石开启任务时间
    @return:
]]
function ShenShuHelper:checkNeedResetTask(role, useTime)
	local shenShuTask = role:getAttr("shenShuTask")

	if not useTime then
		useTime = GetTime()
	end

	return ShenShuVersionFuncHelper:checkNeedResetTask(useTime, shenShuTask.startTime, self:getVersion())
end

--[[
    @desc: 重置神书任务
    author:tanqinjian
    time:2025-06-07 18:43:25
    --@role: 
    @return:
]]
function ShenShuHelper:resetTask(role)
	local shenShuTask = role:getAttr("shenShuTask")
	shenShuTask.count = 0
	shenShuTask.startTime = -1

	shenShuTask.task = {
		startTime = -1,
		bookDropInfoList = {}
	}

	self:clearSongLiInfo(role)
end

--[[
    @desc: 获取神书收集剩余时间
    author:tanqinjian
    time:2025-06-07 18:43:37
    --@role: 
    @return:
]]
function ShenShuHelper:getFindBookRemainingTime(role)
	local shenShuTask = role:getAttr("shenShuTask")
	local task = shenShuTask.task

	if task.startTime == -1 then
		return 0
	end

	return shenShuTaskDuration -  (GetTime() - task.startTime)
end

--[[
    @desc: 获取送礼剩余时间
    author:tanqinjian
    time:2025-06-07 18:43:54
    --@role: 
    @return:
]]
function ShenShuHelper:getSongLiRemainingTime(role)
	local shenShuSongLiInfo = role:getAttr("shenShuSongLiInfo")

	if shenShuSongLiInfo.startTime == -1 then
		return 0
	end

	return Helper:getTodayRemainingTime(shenShuSongLiInfo.startTime)
end

--[[
    @desc: 查看当前神书是否找到，未找到时返回结果与神书信息
    author:tanqinjian
    time:2025-06-07 18:56:27
    --@role:
	--@bookId: 
    @return:
]]
function ShenShuHelper:checkBookIsFound(role, bookId)
	local bookList = self:getTaskBookDropInfoList(role)

	for i, bookInfo in ipairs(bookList) do
		if bookId == bookInfo.id then
			return false, bookInfo
		end
	end

	return true
end

return ShenShuHelper000