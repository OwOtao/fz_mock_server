--@SuperType [src.app.models.map.MapHandle.Modules.BaseModule#BaseModule]
local ShenShuTask = class("ShenShuTask", require("app.models.map.MapHandle.Modules.BaseModule"))

local ShenShuHelper = require("app.models.shenshu.shenshu")

--@desc 涉及副本ID ：格式{["id"] = true} 默认为nil，无限制
ShenShuTask.mapId = nil

--@desc 涉及房间 : 格式{["id"] = true} 默认为nil，无限制
ShenShuTask.roomId = nil

--@desc 开启状态，默认开启
ShenShuTask.status = 1

--@desc 活动时间 : 格式：20171001，默认值0 表示无时间限制
ShenShuTask.activityTime = 0

--@desc 子模块
ShenShuTask.childModule = {}

--@desc 条件结果的方法
ShenShuTask.doResult = {
	["神书合成"] = function(map, result, environment)
		PopupLayerController:showLayer("ShenShuHeChengLayer", function(layer)
			layer:show()
			layer:initLayer()
		end)
		--PopText("神书合成")
	end,
	
	["记录神书送礼"] = function(map, result, environment)
		-----------------------------------------------------------------------------------------------------------
		-- @author GaoHanZheng
		-- @time 2017/06/17 09:49:30
		-- @desc
		-- arg2 = "shenshu101,36000;shenshu10,36000"
		-- arg3 = "money"
		-- arg4 = "你将神书交给李荣，他十分开心，给了你$n银子。"
		--从投开始遍历物品列表，找到一个则返回
		local player = User:getRole()

		local ShenShuSongLi = ShenShuHelper:getTaskSongLiNpcList(player)
		
		for k, v in pairs(ShenShuSongLi) do
			if v.bookId == result.arg2 then
				ShenShuSongLi[k].hasGive = Helper:getDef(ShenShuSongLi[k].hasGive, 0)
				ShenShuSongLi[k].hasGive = ShenShuSongLi[k].hasGive + 1

				ShenShuHelper:setTaskSongLiNpcList(player, ShenShuSongLi)
			end
		end
	end,
	
	["多余神书送礼"] = function(map, result, environment)
		local list = {}
		if result.arg2 then
			list = string.split(result.arg2, ";")
			for k, v in ipairs(list) do
				list[k] = string.split(v, ",")
			end
			for i = #list, 1, - 1 do --删除没有对应奖励的的物品itemId
				if #list[i] ~= 2 then
					table.remove(list, i)
				end
			end
			for k, v in ipairs(list) do
				local item = User:getRole():getItem(v[1])
				if item then
					local itemAttr = Item:getOneItemByKey(result.arg3)--判断是否是物品
					if itemAttr then
						User:getRole():addItemCount(v[1], - 1)
						User:getRole():addItemCount(result.arg3, tonumber(v[2]))
						PopText("获得" .. itemAttr.name .. "X" .. tostring(v[2]))
						--不能改变result.arg4
						local text = string.gsub(result.arg4, "$b", Item:getOneItemByKey(v[1]).name)
						RichPrint("main", string.gsub(text, "$n", tostring(v[2])))
					else
						local attr = User:getRole():getCHAttrName(result.arg3)
						User:getRole():addItemCount(v[1], - 1)
						User:getRole():addAttr(result.arg3, tonumber(v[2]))
						PopText("获得" .. attr .. "X" .. tostring(v[2]))
						--不能改变result.arg4
						local text = string.gsub(result.arg4, "$b", Item:getOneItemByKey(v[1]).name)
						RichPrint("main", string.gsub(text, "$n", tostring(v[2])))
					end
					return
				end
			end
		end
		RichPrint("main", "我不接受你的物品")
	end,
	
	-----------------------------------------------------------------------------------------------------------
	-- @author GaoHanZheng
	-- @time 2017/06/20 15:24:47
	-- @desc 神书每日任务
	["神书任务交谈"] = function(map, result, environment)
		local Treasure = require("app.models.treasure.treasure")
		Treasure:createShenShuDayTask()
	end,
	
	["神书任务送礼"] = function(map, result, environment)
		local Treasure = require("app.models.treasure.treasure")
		Treasure:getBookToShenShuDayTaskNPC(map, result.arg2, environment)
	end,
	
	
}

local function createHeChengNPC(map,roleId,room)
	local role = User:getRole()
	local MapInfo = require("app.models.map.MapInfo")
	local roomId
	-- local talkText
	-- local talkList = {
	-- 	"YEL文笑书：神书玄妙颇多，其中精华还需自身去感受才是。",
	-- 	"YEL文笑书：你若有神书需要合成，可交付于我。"
	-- }
	-- local func = function()
	-- 	local talkList = {
	-- 		"YEL文笑书：神书玄妙颇多，其中精华还需自身去感受才是。",
	-- 		"YEL文笑书：你若有神书需要合成，可交付于我。"
	-- 	}
	-- 	return  talkList[math.random(1,#talkList)]
	-- end
	map, roomId = MapInfo:addRoleToRoomByRoomId(map,room,Helper:tableCover(require("app.models.npc.BaseNpc"):create(),{
		id = roleId,
		sex = _sex,
		type = "role",
		name = "文笑书",
		canSee = true,
		caozuo = true,
		canTalk = true,
		caozuoName = "神书合成",
		conditionAndResults =
		{
			{
				conditionRelation = "and",
				conditions =
				{
					{
						type = "玩家操作",
						arg1 = "玩家操作",
						arg2 = "操作",
					}
				},
				results =
				{
					{
						type = "神书合成",
						arg1 = "神书合成",
					},
				}
			},
			{
				conditionRelation = "and",
				conditions =
				{
					{
						type = "玩家操作",
						arg1 = "玩家操作",
						arg2 = "交谈",
					}
				},
				results =
				{
					{
						type = "文本输出",
						arg1 = "NPC随机文本输出",
						arg2 = "YEL文笑书：神书玄妙颇多，其中精华还需自身去感受才是。#suijiYEL文笑书：你若有神书需要合成，可交付于我。",
						arg3 = "100;100"
					},
				},
			}
		}
	}))
	local result, text = role:setCurrMap(map)
	if result == true then
	else
		PopText(text)
	end
end
local function createShenShuGiftNPC(map,roleId,room,bookId,npcName,npcSex)
	if roleId == nil then
		return
	end
	local role = User:getRole()
	local MapInfo = require("app.models.map.MapInfo")
	local roomId
	map, roomId = MapInfo:addRoleToRoomByRoomId(map,room,Helper:tableCover(require("app.models.npc.BaseNpc"):create(),{
		id = roleId,
		sex = npcSex,
		type = "role",
		name = npcName,
		canSee = true,
		canTalk = false,
		receivePresent = bookId,
		canPresent = true,
		conditionAndResults =
		{
			{
				conditionRelation = "and",
				conditions =
				{
					{
						type = "玩家操作",
						arg1 = "特殊条件",
						arg2 = "赠送",
						arg3 = "成功"
					}
				},
				results =
				{
					{
						type = "玩家属性变化",
						arg1 = "玩家属性变化",
						arg2 = "exp",
						arg3 = 800
					},
					{
						type = "玩家属性变化",
						arg1 = "玩家属性变化",
						arg2 = "pot",
						arg3 = 800
					},
					{
						type = "文本输出",
						arg1 = "文本输出",
						arg2 = "YEL"..npcName.."：嗯，不错，这确实是我在找的东西，多谢你了。"
					},
					{
						arg1 = "记录神书送礼",
						arg2 = bookId
					}
				}
			}
		}
	}))
	local result, text = role:setCurrMap(map)
	if result == true then
	else
		PopText(text)
	end
end


function ShenShuTask:initTreasure(map)
	local mapId = map.id
	mapId = map.id
	local role = User:getRole()
	local map = role:getMapById(mapId)

	local function getItemIsInRoom(roomId,itemId)
		local roleList = map:getRoomRoleList(roomId)
		if roleList then
			for k,v in pairs(roleList) do
				local item = map:getRole(v)
				if item.type == "item" then
					if item.subType == "尸体" then
						for i,value in pairs(item.items) do
							if value.itemId == itemId then
								return true
							end
						end
					end
					if item.baseId == itemId then
						return true
					end
				elseif item.type == "role" then
					for i,value in pairs(item.items) do
						if value.itemId == itemId then
							return true
						end
					end
				end
			end
		end
		return false
	end
	local function getRoleIsInRoom(roomId,roleId)
		local roleList = map:getRoomRoleList(roomId)
		if roleList then
			for k,v in ipairs(roleList) do
				local role = map:getRole(v)
				if role.type == "role" and role.id == roleId then
					return true
				end
			end
			return false
		end
		return false
	end
	local function getShenShuBaseIdList()
		local Treasure = require("script.others.Treasure")
		local ShenShuXinXiList = Treasure["神书送礼"]
		-- Helper:print_lua_table(ShenShuXinXiList)
		-- assert(nil)
		for mid,v in pairs(ShenShuXinXiList) do
			if mid == mapId then
				if v.baseId then
					return string.split(v.baseId,",")
				end
			end
		end
		return {}
	end
	local function getRoomNPCList(roomId)
		local npcList = {}
		if roomId then
			local roleList = map:getRoomRoleList(roomId)
			if roleList then
				for k,v in pairs(roleList) do
					local item = map:getRole(v)
					-- 获取NPC列表，商人除外
					-- print("^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^")
					-- if item.type == "role" then
					-- 	Helper:print_lua_table(item)
					-- end
					-- print("^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^")
					if item.type == "role" and item.canSale ~= 1 and item.canSale ~= true and item.name ~= "神秘人" and item.withCorpse ~= -1 and item._canDetect ~= false then
						for k,v in ipairs(getShenShuBaseIdList()) do
							if item.id == v or item.baseId == v then
								table.insert(npcList,#npcList+1,item)
							end
						end
					end
				end
			end
		end
		return npcList
	end
	local function createShenShuNPC(book,roleId)
		local time = ShenShuHelper:getFindBookRemainingTime(role)

		map:createRole({id = roleId,canKill = true,type = "role",name = "神秘人",baseId = "shenshunpc"})

		map:InSertTaskToDelayTasks(book.itemId,GetTime()+time,function()
			map:removeRoomRole(book.roomId,roleId)
			local roleList = map:getRoomRoleList(book.roomId)
			if roleList then
				for k,v in pairs(roleList) do
					local item = map:getRole(v)
					if item.type == "item" and item.subType == "尸体" then
						if item.aliveId == roleId then
							map:removeRoomRole(book.roomId,item.id)
						end
					end

				end
			end
		end)
		map:addRoomRole(book.roomId,roleId,true)
	end
	local function getMapShenShuList(mapId, shenShuList)
		if shenShuList == nil then
			return nil
		end

		local time = ShenShuHelper:getFindBookRemainingTime(role)
		print("神书任务剩余时间:",time)

		if mapId == "fb25" then
			createHeChengNPC(map,"hechengnpc","fb25_17")
			map:InSertTaskToDelayTasks("hechengnpc",GetTime()+time,function()
				map:removeRoomRole("fb25_17","hechengnpc")
			end)
		end

		local ShenShuDropRecord = require("app.models.Record.ShenShuDropRecord.ShenShuDropRecord")

		for i, book in ipairs(shenShuList) do
			if book.mapId == mapId then
				print("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++")
				if getItemIsInRoom(book.roomId,book.itemId) == false then
					local dropInfo = {
						id = book.id,
						mapId = book.mapId,
						roomId = book.roomId,
						dropType = book.getType
					}

					local bookName = ShenShuHelper:getShenShuName(book.id)

					if book.getType == 1 then
						print("===========================================神书放在地上:", bookName)
						map:dropItem(book.roomId, book.itemId)
						map:InSertTaskToDelayTasks(book.itemId,GetTime()+time,function()
							map:removeRoomRole(book.roomId,book.itemId)
						end)
					elseif book.getType == 2 then
						local npcList = getRoomNPCList(book.roomId)
						if #npcList == 0 then
							print("===========================================第二种情况没有npc，添加一个新的npc,id为:", book["npcId"..tostring(1)]..",",bookName, book.roomId)
							local random = math.random(1,book.npcNum)
							for x=1,book.npcNum do
								createShenShuNPC(book,book["npcId"..tostring(x)])
								if x == random then
									local _role = map:getRole(book["npcId"..tostring(x)])
									if _role:getItem(book.itemId) == nil then
										_role:addItemCount(book.itemId, 1)
									end
									
									dropInfo.npcId = book["npcId"..tostring(x)]
								end
							end
						else
							--在原有的NPC身上添加物品
							local mapNpc = npcList[math.random(1,#npcList)]
							if mapNpc.canKill ~= 1 and mapNpc.canKill ~= true then
								mapNpc.canKill = 1
							end

							dropInfo.npcId = mapNpc.id

							print("=============================第二种房间内有NPC，原有NPC的名称:"..mapNpc.name..","..bookName,book.roomId)
							if mapNpc:getItem(book.itemId) == nil then
								mapNpc:addItemCount(book.itemId,1)
								mapNpc.canKill = true
							end

							map:InSertTaskToDelayTasks(book.itemId,GetTime()+time,function()
								mapNpc:addItemCount(book.itemId,-1)
								local roleList = map:getRoomRoleList(book.roomId)
								if roleList then
									for k,v in pairs(roleList) do
										local item = map:getRole(v)
										if item.type == "item" and item.subType == "尸体" then
											if item.aliveId == mapNpc.id then
												map:removeRoomRole(book.roomId,item.id)
											end
										end

									end
								end
							end)

						end
					elseif book.getType == 3 then
						print("===========================================第三种添加新的npc，神秘人的数量:"..book.npcNum..","..bookName,book.roomId)
						--添加一个新的npc，id:shenshunnpc
						local random = math.random(1,book.npcNum)
						for x=1,book.npcNum do
							createShenShuNPC(book,book["npcId"..tostring(x)])
							if x == random then
								local _role = map:getRole(book["npcId"..tostring(x)])

								dropInfo.npcId = book["npcId"..tostring(x)]

								if _role:getItem(book.itemId) == nil then
									_role:addItemCount(book.itemId, 1)
								end
							end
						end
					else
					end

					local shenShuDropRecord = ShenShuDropRecord:create(dropInfo.dropType, dropInfo.id, dropInfo.mapId, dropInfo.roomId, dropInfo.npcId)
					shenShuDropRecord:submitRecord()
				end
			end
		end
	end

	if ShenShuHelper:checkIsInSongLiTime(role) then
		local songliList = ShenShuHelper:getTaskSongLiNpcList(role)
		local time = ShenShuHelper:getSongLiRemainingTime(role)

		for k,v in pairs(songliList) do
			if v.mapId == mapId then--roleId,room,bookId,npcName,npcSex
				print("===================================副本中的送礼npc："..v.name)

				createShenShuGiftNPC(map,v.npcId,v.roomId,v.bookId,v.name,v.sex)
				
				map:InSertTaskToDelayTasks(v.npcId,GetTime()+time,function()
					map:removeRoomRole(v.roomId,v.npcId)
				end)
			end
		end
	end

	if ShenShuHelper:checkIsInFindBook(role) then
		local shenShuDropInfoList = ShenShuHelper:getTaskBookDropInfoList(role)
		getMapShenShuList(mapId, shenShuDropInfoList)
	end
end

function ShenShuTask:entryMap(map,currTime)
	self:initTreasure(map,currTime)
end


return ShenShuTask000000