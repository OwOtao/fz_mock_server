local TreasureList = require("script.others.Treasure")
local ControllLayer = require("app.views.layer.ControllLayer")
--@RefType [src.app.models.Record.Reward.ARewardRecord#ARewardRecord]
local ARewardRecord = require("app.models.Record.Reward.ARewardRecord")
local Treasure = {}
function Treasure:BaoZang(tag,currLayer,func)
	-- print("tag,currLayer,func = ", tag,currLayer,func)

	local role =  User:getRole()
	self:createBaoZangXinXi(currLayer,func)
end
local function checkCanUseLuoPan(mapId,listStr)
	if type(mapId) ~= "string" or type(listStr) ~= "string" then
		return true
	end
	local list = string.split(listStr,",")
	for k,v in pairs(list) do 
		if v == mapId then
			return false
		end
	end
	return true
end
function Treasure:createBaoZangXinXi(currLayer,func)
	local role =  User:getRole()
	local BaoZangXinXiList = role:getTimeLimitFlag("BaoZangXinXiList")
	if BaoZangXinXiList == nil or BaoZangXinXiList == 0 then
		if GetTime() - role:getFlag("BaoZangOpenTime") >= 8*3600 then
			BaoZangXinXiList = self:getBangZangList()
		else
			--提示当前宝藏已经被挖掘完
			RichPrint("main", "HIC你拿出寻龙罗盘，将内力灌注其中，不料却发现罗盘指针四处飞转，完全停不下来，看来并无宝藏出世。")
		end
	end
	-- local controllLayer = ControllLayer:getInstance()
	if currLayer then
		--副本内
		local mapLayer = currLayer.ControllLayer:getLayer("MapLayer")
		if mapLayer._currMap:canLeaveRoom() == false then
			PopText("请专注眼前事，莫要分心！")
			return
		end
		if BaoZangXinXiList[mapLayer._currMap.id] then 
			local roomId =  BaoZangXinXiList[mapLayer._currMap.id].roomList
			if #roomId>1 then
				roomId = self:getMinDistance(roomId)
			else
				roomId = roomId[1]
			end
			local vector = mapLayer:getCurrRoomTotalMapRoomVector(roomId)
			local text = {
				"你将内力灌入寻龙罗盘，罗盘指针飞转起来..待到罗盘停下，你定睛一看，恰是停在HIY",
				"你拿出寻龙罗盘，将内力注入其中，罗盘指针飞转起来，待到指针停下，你看了一看罗盘，指向的是HIY"
			}
			local offsetX = math.abs(vector.y/10)
			local offsetY = math.abs(vector.x/10)
			local random = math.random(1,#text)
			if vector.x > offsetX  then
				if vector.y > offsetY then
					RichPrint("main", text[random].."东北NOR方位。")
				elseif vector.y >= 0-offsetY and vector.y <= offsetY then
					RichPrint("main", text[random].."正东NOR方位。")
				elseif vector.y < 0-offsetY then 
					RichPrint("main", text[random].."东南NOR方位。")
				end
			elseif vector.x >= 0-offsetX and vector.x <= offsetX then
				if vector.y > offsetY then
					RichPrint("main", text[random].."正北NOR方位。")
				elseif vector.y >= 0-offsetY and vector.y <= offsetY then
					RichPrint("main", "HIY你拿出寻龙罗盘，一番盘查之下，发现宝藏就在此地。")
				elseif vector.y < 0-offsetY then 
					RichPrint("main", text[random].."正南方位。")
				end
			elseif vector.x < 0-offsetX then
				if vector.y > offsetY then
					RichPrint("main", text[random].."西北NOR方位。")
				elseif vector.y >= 0-offsetY and vector.y <= offsetY then
					RichPrint("main", text[random].."正西NOR方位。")
				elseif vector.y < 0-offsetY then 
					RichPrint("main", text[random].."西南NOR方位。")
				end
			end
			if func then
				func()
			end
		else
			local checkListStr = Helper:getDef(TreasureList["挖宝禁止"],{})
			checkListStr = Helper:getDef(checkListStr["1"],{})
			checkListStr = Helper:getDef(checkListStr["stopcopy"],"")
			if checkCanUseLuoPan(mapLayer._currMap.id,checkListStr) == false then
				RichPrint("main", "HIC你拿出寻龙罗盘，不料却发现罗盘指针一动不动，看来并无宝藏出世。")
				return
			end

			if mapLayer._currMap:canLeaveRoom() == false then
				PopText("请专注眼前事，莫要分心！")
				return
			end
			local minStr = self:getMinFuBen(BaoZangXinXiList)
			local role = User:getRole()
			if minStr == nil then
				RichPrint("main", "HIC你拿出寻龙罗盘，不料却发现罗盘指针一动不动，看来并无宝藏出世。")
				return
			end
			local map = role:getMapById(minStr)
			-- local mapLayer = controllLayer:getLayer("MapLayer")
			local roomId =  BaoZangXinXiList[minStr].roomList
			if #roomId>1 then
				roomId = roomId[1]
			else
				roomId = roomId[1]
			end
			RichPrint("main", "你拿出寻龙罗盘，却发现罗盘指针居然一动不动，过了许久才缓缓移向一个方位，该方位恰是HIY"..map.name.."NOR所在。")
			PopupLayerController:showLayer("DunDiFuLayer", function(layer)
				layer:show()
				layer:showXunBaolayer(self:getDunDiFuList(minStr,roomId))
			end)
			if func then
				func()
			end
		end
		print("副本中")
	else
		print("背包中")
		--背包中

		local minStr = self:getMinFuBen(BaoZangXinXiList)
		local role = User:getRole()
		if minStr == nil then
			RichPrint("main", "HIC你拿出寻龙罗盘，不料却发现罗盘指针一动不动，看来并无宝藏出世。")
			return
		end
		local map = Map:getDefaultMapById(minStr)
		RichPrint("main", "你拿出寻龙罗盘，却发现罗盘指针居然一动不动，过了许久才缓缓移向一个方位，该方位恰是HIY"..map.name.."NOR所在。")
		--遁地符
		-- local mapLayer = controllLayer:getLayer("MapLayer")
		local roomId =  BaoZangXinXiList[minStr].roomList
		if #roomId>1 then
			roomId = roomId[1]
		else
			roomId = roomId[1]
		end
		PopupLayerController:showLayer("DunDiFuLayer", function(layer)
			layer:show()
			layer:showXunBaolayer(self:getDunDiFuList(minStr,roomId))
		end)
		if func then
			func()
		end
	end
end

function Treasure:getDunDiFuList(mapid,roomid)
	if mapid and roomid then
		local currMap = User:getRole():getMapById(tostring(mapid))
		local list = currMap:getNearRoomsExceptSelf(roomid,4)
		for i = #list,1,-1 do 
			if list[i] == roomid then
				table.remove(list,i)
			end
		end

		local TransmitRoomModel = require("app.models.transmitRoom.TransmitRoomModel")
		local filterList = TransmitRoomModel:getBaoZangFilterRoomList()

		if MapIsEmpty(filterList) == false then
			for i = #list,1,-1 do 
				if filterList[list[i]] then
					table.remove(list,i)
				end
			end
		end

		local reList = {}
		reList.mapId = mapid
		local randomRoomId = list[math.random(1,#list)]
		reList.roomId = randomRoomId
		reList.title = "寻龙探宝"
		reList.str = "罗盘指针指向HIY"..currMap.name.."NOR，使用遁地符可快速前往宝藏附近。"
		return reList 
	end
end
function Treasure:getMinDistance(list)
	local distance = nil
	local roomId = nil 
	local mapLayer = ControllLayer:getInstance():getLayer("MapLayer")
	for k,roomid in pairs(list) do 
		local vector = mapLayer:getCurrRoomTotalMapRoomVector(roomid)
		if distance == nil then
			distance = math.pow(vector.x,2)+math.pow(vector.y,2)
			roomId = roomid
		else
			if distance > (math.pow(vector.x,2)+math.pow(vector.y,2)) then
				distance = math.pow(vector.x,2)+math.pow(vector.y,2)
				roomId = roomid
			end
		end
	end
	return roomId
end
function Treasure:getBangZangList()--宝藏信息的结构
	local BaoZangXinXiList = {}

	local mapList = Map:getCompletedMapList()
	local xinxiList = TreasureList["宝藏信息"]
	for _,mapId in pairs(mapList) do 
		if xinxiList[mapId]["Special"] == 0 then
			local num =	xinxiList[mapId]["treasureNumber"] 
			local copyList = string.split(xinxiList[mapId]["copyList"],",")
			local roomlist = self:createBaoZangList(num,copyList)
			if roomlist and #roomlist ~= 0 then
				BaoZangXinXiList[mapId] = {}
				BaoZangXinXiList[mapId].Special = 0
				BaoZangXinXiList[mapId].roomList = roomlist 
			end
		end
	end
	
	--@desc 配置表中没有看出需要用到特殊副本的情况。（去除Special == 1 的情况。）
	-- for mapId,v in pairs(xinxiList) do
	-- 	if v.Special == 1 then
	-- 		local num =	v.treasureNumber
	-- 		local coptList = string.split(v.copyList,",")
	-- 		local roomlist = self:createBaoZangList(num,coptList)
	-- 		if roomlist and #roomlist ~= 0 then
	-- 			BaoZangXinXiList[tostring(v.copyId)] = {}
	-- 			BaoZangXinXiList[tostring(v.copyId)].Special = 1
	-- 			BaoZangXinXiList[tostring(v.copyId)].roomList = roomlist 
	-- 		end
	-- 	end
	-- end
	
	--保存宝藏开始时间
	local role = User:getRole()
	role:setFlag("BaoZangOpenTime",GetTime())
	role:setTimeLimitFlag("BaoZangXinXiList",BaoZangXinXiList,8*3600)
	return BaoZangXinXiList
end
function Treasure:createBaoZangList(num,copyList)
	if num and copyList then
		local count
		if type(num) == "number" then
			count = num
		else
			local numList = string.split(num,",")
			count = tostring(numList[math.random(1,#numList)])
		end
		local list = {}
		if count and count ~= 0 then
			for i=1,count do 
				local random = math.random(1,#copyList)
				table.insert(list,#list+1,copyList[random])
				table.remove(copyList,random)
			end
			return list
		end
		return nil 
	end
	return nil
end
function Treasure:getMinFuBen(list)
	if list == nil or type(list) ~= "table" then
		return nil 
	end
	local min = nil
	local minStr = nil
	for k,v in pairs(list) do 
		if v.Special == 0 then
			local strList = string.split(k,"fb")
			if min == nil then
				min = tonumber(strList[2])
				minStr = k
			else
				if min > tonumber(strList[2]) then
					min = tonumber(strList[2])
					minStr = k
				end
			end
		end
	end
	return minStr
end
function Treasure:CanZi(dialog,currLayer,func)
	local role = User:getRole()
	if currLayer then
		local BaoZangXinXiList = role:getTimeLimitFlag("BaoZangXinXiList")
		local shijiancelue = TreasureList["事件策略"]

		if BaoZangXinXiList == nil or BaoZangXinXiList == 0 then
			RichPrint("main", "你抄起掘金铲，就地挖掘，挖了许久，但却一无所获，看来这儿没有宝藏。")
			if func then
				func()
			end
		else
			local currMap = role:getCurrMap()
			local resultMapId = currMap.id
			local resultRoomId = currMap:getCurrRoomId()

			if BaoZangXinXiList[resultMapId] then
				local roomId =  BaoZangXinXiList[resultMapId].roomList
				local isBaoZangRoom = false
				for k, v in pairs(roomId) do 
					if resultRoomId == v then
						isBaoZangRoom = true
						table.remove(BaoZangXinXiList[resultMapId].roomList,k)
						if #BaoZangXinXiList[resultMapId].roomList == 0 then
							BaoZangXinXiList[resultMapId] = nil
							-- BaoZangXinXiList = self:updateBaoZangXinXiList(BaoZangXinXiList,mapLayer._currMap.id)
							print("更新宝藏")
							role:updateTimeLimitFlag("BaoZangXinXiList",BaoZangXinXiList)
						end
						local MapRoleLayer = MainControllLayer:getLayer("MapRoleLayer")
						local mapLayer = MainControllLayer:getLayer("MapLayer")
						User:getRole():setFlag("PVP活动状态", "忙碌")
						MapRoleLayer:exitButtonFunc(false,function()
							 RichPrint("main","您正在挖宝，请稍等片刻。")
						end)
						MapRoleLayer:statusButtonFunc(false,function()
							 RichPrint("main","您正在挖宝，请稍等片刻。")
						end)
						mapLayer:setUnmoveRoom(true,function()
							RichPrint("main","您正在挖宝，请稍等片刻。")
						end)
						currMap:setCanLeave(false)
						local  testList = {
							"RAN你几铲下去，挖出了一些沙石，并无什么宝藏出现…",
							"RAN你挖了几铲，居然铲到了几块硬石头，坚硬的铲子都磕出了一个小角。",
							"RAN你抄起铲子，用力挖掘，但除了一些泥土，其他的还什么都看不到。",
							"RAN你拿起掘金铲，挖地三尺，但却什么都没发现。",
							"RAN你拿起铲子，掘起一片沙土，但却一无所获。",
						}
						local resultTest = {
							"YEL你挖了许久，终于看到了里面有个小小的木盒，你忙不迭地将它拾起。",
							"YEL你拿起铲子一铲下去，碰触到一个硬硬的东西，你拨开泥土一看，竟然是一个做工精致的礼盒。",
							"你抄起铲子，一铲下去，挖出了一个金光闪闪的宝箱，不过没待你看清，旁边竟然跳出个人将宝物抢走了！",
							"你抄起铲子，一铲下去，挖出了一个金光闪闪的宝箱，不过没待你看清，旁边竟然跳出个人将宝物抢走了！",
							"你抄起铲子，一铲下去，挖出了一个金光闪闪的宝箱，不过没待你看清，旁边竟然跳出个人将宝物抢走了！",
							"YEL你一铲子下去，只听“咚”地一声巨响，周围的泥土塌了一片，从中显现出一条通道，你不禁大为惊讶，顺着通道钻了进去。",
							"YEL你挖了许久，仍然一无所获，看来这里是个假宝藏所在",
						}
						local num = #testList
						for i=1,num+1 do
							dialog:delayFunc(i , function()
								if i ~= num +1 then
									local testRandom = math.random(1,#testList)
						            RichPrint("main", testList[testRandom])
						            table.remove(testList,testRandom)
						        else
									local result,randomId = self:getResult(resultMapId)--只需要在最后一次执行得到结果就可以
						        	 RichPrint("main", resultTest[randomId])
						        	 --在宝藏房间中使用
									local value
									for i,tab  in pairs(shijiancelue) do 
										if tab.copyId == resultMapId then
											value = tab["Event"..tostring(randomId)]
										end
									end
									if (result == "奖励" or result == "高级奖励") and value then

										--@RefType [src.app.models.reward.OpenRewardGet#OpenRewardGet]
										local rewardGet =
											require("app.models.reward.OpenRewardGet"):create(
												role,
											{value},
											ARewardRecord.RTYPE.TREASURE_BOX,
											"mapRewardArrayWithRewardSchemeArray",
											{
												mapid = resultMapId,
											}
										)

										rewardGet:doGetReward(function (rewardArray)
											local name,value1
											for i, reward in ipairs(rewardArray) do
												if reward.type == "物品" then
													if PRINT_MODE == 1 then
														local item = Item:getOneItemByKey(reward.id)
														if item then
															name = Helper:getDef(Item:getOneItemByKey(reward.id).name, "")
															value1 = Helper:getDef(reward.value, 1)
															if name then
																PopText("[测试才能看见]: 得到物品 [" .. name .. "] x " .. reward.value)
															end
														end
													end
													if currMap:addItemCount(reward.id, reward.value) == false then
														currMap:dropItem(resultRoomId, reward.id)
														mapLayer:setNeedRefreshMap()
														MapRoleLayer:exitButtonFunc(true)
														MapRoleLayer:statusButtonFunc(true)
														mapLayer:setUnmoveRoom(false)
														currMap:setCanLeave(true)
														return
													end
													role:addItemCount(reward.id, reward.value)
													PopText("获得 " .. Item:getOneItemByKey(reward.id).name .. " x " .. reward.value)
													Statistics:recordItemCount(reward.id, reward.value) -- 用于统计
												elseif reward.type == "属性" then
													if type(role:getCHAttrName(reward.id)) == "string" then
														PopText("获得" .. role:getCHAttrName(reward.id) .. tostring(reward.value))
													end
													role:addAttr(reward.id, reward.value)
													currMap:richPrintText(role, reward.id, reward.value) -- 角色属性变化文本显示
												end
											end
										end)
									elseif result == "添加人物" then
										local npcname = nil 
										if randomId == 3 then
											npcname = "抢宝贼"
										elseif randomId == 4 then
											npcname = "盗宝贼"
										elseif randomId == 5 then
											npcname = "掘金盗"
										end
										local time = role:getTimeLimitFlagTime("BaoZangXinXiList")
										currMap:createRole({id =value ,canKill = true,type = "role",name = npcname,baseId = value})
										local npcRole = currMap:getRole(value)
										npcRole:setAttr("qi",npcRole:getFinalAttr("qiMax"))
										currMap:InSertTaskToDelayTasks(value,GetTime()+time,function()
											currMap:removeRoomRole(resultRoomId,value)
										end)
										currMap:addRoomRole(resultRoomId,value,true)
										mapLayer:setNeedRefreshMap()
									elseif result == "副本传送" and value then
										print("副本传送:",value)
										mapLayer:setUnmoveRoom(false)
										currMap:setCanLeave(true)
										mapLayer:replaceRoom(value)
									elseif result == "无" then
										RichPrint("main", "YEL你挖了许久，仍然一无所获，看来这里是个假宝藏所在。")
									end
									User:getRole():setFlag("PVP活动状态", "空闲中")
									MapRoleLayer:exitButtonFunc(true)
									MapRoleLayer:statusButtonFunc(true)
									mapLayer:setUnmoveRoom(false)
									currMap:setCanLeave(true)
						        end
						        return
					        end)
						end
						if func then
							func()
						end
					end
				end
				if isBaoZangRoom == false then
					--在非宝藏房间中使用""
					RichPrint("main", "你抄起掘金铲，就地挖掘，挖了许久，但却一无所获，看来这儿没有宝藏。")
					if func then
						func()
					end
				end
			else
				RichPrint("main", "你抄起掘金铲，就地挖掘，挖了许久，但却一无所获，看来这儿没有宝藏。")
				if func then
					func()
				end
			end
		end
	else
		--在副本外使用
		RichPrint("main", "你抄起掘金铲，就地挖掘，挖了许久，但却一无所获，看来这儿没有宝藏。")
	end
end
function Treasure:updateBaoZangXinXiList(list,mapid)
	if list and mapid then
		local count = 1
		for k, v in pairs(list) do 
			if k == mapid then
				table.remove(list,count)
			else
				count = count + 1
			end
		end
		return list
	end
end
function Treasure:getResult(mapId)
	if mapId == nil then
		return
	end

	local xinxiList = TreasureList["宝藏信息"]
	local baoZangInfo = xinxiList[mapId]
	local weightList = {}
	for i=1,100 do 
		if baoZangInfo["typeWeight"..tostring(i)] == nil then
			break
		end
		table.insert(weightList,#weightList+1,baoZangInfo["typeWeight"..tostring(i)])
	end
	if PRINT_MODE == 1 then
		print("--------------------------处理前------------------------------------")
		Helper:print_lua_table(weightList)
	end
	if LONGEVITY_TASK_IS_OPEN then
		local TreasureHelper = require("app.models.treasure.TreasureHelper")
		weightList = TreasureHelper:getWeightList(mapId,baoZangInfo,weightList)
		if PRINT_MODE == 1 then
			print("--------------------------处理后----------------------------------")
			Helper:print_lua_table(weightList)
		end
	end
	local random = Helper:RandomByWeight(weightList)
	if random then
		return baoZangInfo["tYpe"..tostring(random)],random
	end
end

--
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/06/20 14:46:52
-- @desc 神书每日任务
-- {
-- 	date = 20170620,
-- 	bookId = "",
-- }

function Treasure:createShenShuDayTask()
	local dayTask = User:getRole():getTimeLimitFlag("ShenShuDayTask")
	--根据时间获取日期
	local function getTimeDate(time)
		return tonumber(Helper:date("%Y%m%d",time))
	end
	--根据日期获取时间
	local function getTimeByDate(date)
		return Helper:getTimeStampWithStringDate(tostring(date+1), 0)
	end
	--获取时间差
	local function getSubTime(startTime,endTime)
		return endTime - startTime
	end
	--获取随机的神书Id
	local function getBookItemId()
		return "shenshu"..tostring(math.random(1,42))
	end
	if dayTask == 0 then
		--创建任务
		local bookid = getBookItemId()
		local item = User:getRole():getOneItemByKey(bookid)
		dayTask = {
			bookId = bookid,
			bookName = item.name,
			isComplete = "N"
		}
		local time = getSubTime(GetTime(),getTimeByDate(getTimeDate(GetTime())))
		Helper:print_lua_table(dayTask)
		print("任务有效时间:",time)
		User:getRole():setTimeLimitFlag("ShenShuDayTask",dayTask,time)
	end
	-- return dayTask
	local text = {}
	if dayTask.isComplete == "Y" then
		text = {
			[1] = "YEL余长生：此书真是不错，多谢你了",
			[2] = "YEL余长生：此书已够我今日看的了，你还是明日再来吧。"
		}
		RichPrint("main",text[math.random(1,#text)])
	else
		text = {
			[1] = "YEL余长生:听说HIC$bNORYEL这本书十分有趣，你可否找来给我？",
			[2] = "YEL余长生:我生平阅书无数，听闻神书出世，心不甚喜，你可愿找一本HIC$bNORYEL与我？"
		}
		RichPrint("main",string.gsub(text[math.random(1,#text)],"$b",dayTask.bookName))
	end
end
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/06/20 15:42:04
-- @desc 神书每日任务的NPC送礼
function Treasure:getBookToShenShuDayTaskNPC(map,result,environment)
	local dayTask = User:getRole():getTimeLimitFlag("ShenShuDayTask")
	local role = User:getRole()
	if dayTask ~= 0 then
		if dayTask.isComplete == "N" then
			local book = role:getItem(dayTask.bookId)
			if book ~= nil then
				local text = {
					[1] = "YEL余长生：嗯，做的不错，多谢你了。",
					[2] = "YEL余长生：我果然没有看错人，这么快就帮我找来了，多谢你了。"
				}
				RichPrint("main",text[math.random(1,#text)])
				role:addItemCount(dayTask.bookId,-1)
				dayTask.isComplete = "Y"
				role:updateTimeLimitFlag("ShenShuDayTask",dayTask)
				map:doNoRoleResults( result, environment )
				return
			end
		end
	end
	RichPrint("main","CYN我不接受你的物品")
end
return Treasure0