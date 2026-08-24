-- add by ZhangShengTang 2017/06/13 16:04:30
-- 周年庆
local Anniversary = {}

-- local User = require("app.models.user.User")
-- local Item = require("app.models.item.Item")
-- local Role = require("app.models.role.Role")
-- local Map = require("app.models.map.Map")
-- local Task = require("app.models.task.Task")
-- local Npc = require("app.models.npc.Npc")

-- 周年庆刷新副本
local AnniversaryRefreshMap = require("script.others.anniversary.lua")["progress"]

-- 周年庆刷新副本房间
local AnniversaryRefreshRoom = require("script.others.anniversary.lua")["room"]

-----------------------------------------------------------------------------------------------------------
-- @author ZhangShengTang
-- @time 2017/06/13 16:09:00
-- @desc 接受萧子远任务
function Anniversary:acceptXiaoZhiYuan()
	local role = User:getRole()

	-- jian102
	-- item12_03
	-- jiu100
	-- yao101
	-- 1、落月山庄的叛徒任务
	-- 对话文本：YEL萧子远：数月前，我落月山庄跑了一名叛徒，听说他在XXXX（地点名）附近，你若能帮我处理了他，萧某感激不尽。
	-- 任务完成文本：YEL萧子远：少侠可帮了大忙了，此情我落月山庄必铭记于心。
	-- 在房间内生成落月山庄叛徒，杀死与萧子远对话可完成任务。
	-- 2、采购任务
	-- 对话文本：YEL萧子远：此次出来，萧某需采办一些XXXX（物品名），阁下可否帮衬一二？
	-- 任务完成文本：YEL萧子远：少侠高义，萧某在此谢过。
	-- 送礼给萧子远对应道具，可以完成任务。

	-- 3、拜访任务
	-- 对话文本：YEL萧子远：我落月山庄与各位武林同道交好，萧某此次出来亦是为了拜访些许武林名宿，劳烦你替我去拜访一下XXX，他现在XXX附近。
	-- 任务完成文本：YEL萧子远：你做的不错，多谢你了。
	-- 在房间内生出XXX角色，XXX身上有拜访按钮，点击拜访再返回与萧子远对话可完成任务。
	if role:getFlag("萧子远任务次数") >= 7 then
		RichPrint("main", "YEL萧子远：我的事情已然办完，没有什么需要帮忙的了，多谢少侠了。")
		return
	end

	if role:getDayFlag("萧子远任务可接") == 1 then
		RichPrint("main", "YEL萧子远：今日多谢你了，少侠亦可明日再来看看，萧某还有事情拜托你也不一定呐。")
		return
	end

	if role:getFlag("萧子远任务") == 0 then
		-- 随机三种任务
		local num = math.random(1,3)
		if num == 1 then
			-- 落月山庄的叛徒任务
			local mapId = self:getRandMap()
			local roomId = self:getRandRoom(mapId)
			local map = role:getMapById(mapId)
			local roomName = map.room[roomId].name

			RichPrint("main", "YEL萧子远：数月前，我落月山庄跑了一名叛徒，听说他在HIC" .. map.name .. roomName .. "YEL附近，你若能帮我处理了他，萧某感激不尽。")
			role:setFlag("萧子远任务", "1;0;" .. mapId .. ";" .. roomId)
		elseif num == 2 then
			-- 采购任务
			local itemList =
			{
				"jian102",
				"item12_03",
				"jiu100",
				"yao101",
			}
			local item = Item:getOneItemByKey(itemList[math.random(1, #itemList)])
			RichPrint("main", "YEL萧子远：此次出来，萧某需采办一些HIC" .. item.name .. "YEL，阁下可否帮衬一二？")
			role:setFlag("萧子远任务", "2;0;" .. item.id)
		elseif num == 3 then
			-- 拜访任务
			local mapId = self:getRandMap()
			local roomId = self:getRandRoom(mapId)
			local map = role:getMapById(mapId)
			local roomName = map.room[roomId].name
			local name = Helper:getRandomName("男")

			RichPrint("main", "YEL萧子远：我落月山庄与各位武林同道交好，萧某此次出来亦是为了拜访些许武林名宿，劳烦你替我去拜访一下HIC" .. name .. "YEL，他现在HIC" .. map.name .. roomName .. "YEL附近。")
			role:setFlag("萧子远任务", "3;0;" .. mapId .. ";" .. roomId .. ";" .. name)
		end
	else
		print(role:getFlag("萧子远任务"))
		-- 判断是否完成任务
		local str = role:getFlag("萧子远任务")
		local strList = string.split(str, ";")
		if strList[2] == "1" then

			if role:getAttr("weight") - #role:getItems() < 1 and role:getFlag("萧子远任务次数") + 1 == 7 then
				PopText("背包已满，无法领取奖励")
				return
			end

			-- HttpManagerEx:addActivityPoint(100, "zhounianqin_xzy", function(status, errcode, errmsg, data, isEncrypted)
		 --        -- PopText("返回数据 是否有加密  == "..tostring(isEncrypted))
		 --        if isEncrypted == false then
		 --            Collection:memoryCheat(User:getRoleAttr("userid"), "proxyData", 0, data)
		 --            return
		 --        end
		 --        if status == 200 then
		 --            if errcode ~= 0 then
		 --            	PopText(errmsg)
		 --            else
		 --            	if data.number ~= nil and data.number > 0 then
		 --            		PopText("周年活动积分 + " .. data.number)
		 --            	end

		            	-- 已完成
						if strList[1] == "1" then
							RichPrint("main", "YEL萧子远：少侠可帮了大忙了，此情我落月山庄必铭记于心。")
						elseif strList[1] == "2" then
							RichPrint("main", "YEL萧子远：少侠高义，萧某在此谢过。")
						elseif strList[1] == "3" then
							RichPrint("main", "YEL萧子远：你做的不错，多谢你了。")
						end

						if strList[2] == "1" then
							-- 领取奖励
							if role:getAttr("weight") - #role:getItems() < 1 and role:getFlag("萧子远任务次数") + 1 == 7 then
								PopText("背包已满，无法领取奖励")
								return
							end
							role:setFlag("萧子远任务次数", role:getFlag("萧子远任务次数") + 1)
							if role:getFlag("萧子远任务次数") == 7 then
								role:addItemCount("yizhounianjinian4", 1)
								local item = Item:getOneItemByKey("yizhounianjinian4")
								PopText("获得 " .. item.name .. " X 1")
								RichPrint("main", "YEL萧子远：这段时间你帮了我不少忙，此物送于少侠，还望不弃。")
							end
							role:addAttr("pot", 20000)
							PopText("潜能 + " .. 20000)
							role:setFlag("萧子远任务", 0)
							role:setDayFlag("萧子远任务可接", 1)

							-- 上传存档
							HttpManagerEx:uploadUserData("shangchuan", function(status, errcode, errmsg, data, isEncrypted)
								if status == 200 and errcode == 0 then
								else
									PopText(errmsg)
								end
							end, IS_SHOW_WAITING)
						end
		    --         end
		    --     end
		    -- end, IS_SHOW_WAITING)

		else
			-- 未完成
			if strList[1] == "1" then
				local map = role:getMapById(strList[3])
				local roomName = map.room[strList[4]].name
				RichPrint("main", "YEL萧子远：数月前，我落月山庄跑了一名叛徒，听说他在HIC" .. map.name .. roomName .. "YEL附近，你若能帮我处理了他，萧某感激不尽。")
			elseif strList[1] == "2" then
				local item = Item:getOneItemByKey(strList[3])
				RichPrint("main", "YEL萧子远：此次出来，萧某需采办一些HIC" .. item.name .. "YEL，阁下可否帮衬一二？")
			elseif strList[1] == "3" then
				local map = role:getMapById(strList[3])
				local roomName = map.room[strList[4]].name
				local name = strList[5]
				RichPrint("main", "YEL萧子远：我落月山庄与各位武林同道交好，萧某此次出来亦是为了拜访些许武林名宿，劳烦你替我去拜访一下HIC" .. name .. "YEL，他现在HIC" .. map.name .. roomName .. "YEL附近。")
			end
		end
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author ZhangShengTang
-- @time 2017/06/14 10:54:03
-- @desc 获取能随机到的副本
function Anniversary:getRandMap()
	local role = User:getRole()

	local completeMapList = Map:getCompletedMapList()

	local mapId = completeMapList[math.random(1,#completeMapList)]

	for k,v in pairs(AnniversaryRefreshMap) do
		if mapId == k then
			local mapList = string.split(v.list, ",")
			local mapId = mapList[math.random(1, #mapList)]
			return mapId
		end
	end

	print("没有随机到副本")
	return nil
end

-----------------------------------------------------------------------------------------------------------
-- @author ZhangShengTang
-- @time 2017/06/14 10:58:07
-- @desc 获取随机房间
function Anniversary:getRandRoom(mapId)
	if mapId == nil then
		return nil
	end

	for k,v in pairs(AnniversaryRefreshRoom) do
		if mapId == v.id then
			local roomList = string.split(v.possibleroom, ",")
			local roomId = roomList[math.random(1, #roomList)]
			return roomId
		end
	end

	return nil
end

-----------------------------------------------------------------------------------------------------------
-- @author ZhangShengTang
-- @time 2017/06/14 11:49:27
-- @desc 创建周年庆NPC
function Anniversary:createNpc(roleId, name)
	local role = Npc:createTaskNpc(roleId)
	if name ~= nil then
		role.name = name
	end
	print("创建周年庆NPC " .. role.name)
	if roleId == "zhounianqin2" then
		role.canKill = false
		role.caozuo1 = true
		role.caozuoName1 = "拜访"
		role.conditionAndResults =
		{
			{
				conditionRelation = "and",
				conditions =
				{
					{
						type = "玩家操作",
						arg1 = "玩家操作",
						arg2 = "操作1",
					}
				},
				results =
				{
					{
						type = "删除人物",
						arg1 = "删除人物",
						arg2 = role.id,
					},
					{
						type = "文本输出",
						arg1 = "文本输出",
						arg2 = "YEL" .. role.name .. "：呵呵，萧先生让少侠特意前来拜访，真是太客气了。"
					},
					{
						type = "箫子远拜访",
						arg1 = "箫子远拜访",
					},
				},
			},
		}
	end
	if roleId == "zhounianqin3" or roleId == "zhounianqin4" or roleId == "zhounianqin5"then
		-- 多疑的人
		role.canTalk = true
		role.canKill = false
		role.caozuo1 = true
		role.caozuoName1 = "偷取"
		-- 多疑的人：
		-- 恩？你是什么人，你要做什么？
		-- 总感觉有人在盯着我，得小心点了。
		-- 你看着我干嘛，难道是哪里来的小偷？

		-- 粗心的人：
		-- 唉，我这人老是粗心大意，不过这也没什么。
		-- 嗨呀，今天忘拿我那三千两的扇子出来了，这可如何是好。
		-- 唉，我那玉佩怎么不见了，噢，原来在这呢，好险好险。
		-- 做人太仔细多累啊，粗心点也不是什么坏毛病。

		-- 谨慎的人：
		-- 谨慎点，没什么不好。
		-- 听说最近这江湖中有一伙鬼面人，无恶不作，咱可得小心点呐。
		-- 做人就是得像我这样谨慎一点。

		local textStr = ""
		local pr = ""
		if roleId == "zhounianqin3" then
			textStr = "YEL" .. role.name .. "：别人都说我生性多疑，但我可不这么认为。#suijiYEL" .. role.name .. "：你这人怎么老在我周围晃悠，很可疑啊。#suiji" .. "YEL" .. role.name .. "：多疑就是小心，小心就是多疑。#suiji" .. "YEL" .. role.name .. "：你这人怎么老跟着我，莫不是哪里来的贼人。"
			pr = "100;100;100;100"
		elseif roleId == "zhounianqin4" then
			textStr = "YEL" .. role.name .. "：做人太仔细多累啊，粗心点也不是什么坏毛病。#suijiYEL" .. role.name .. "：唉，我这人老是粗心大意，不过这也没什么。#suijiYEL" .. role.name .. "：嗨呀，今天忘拿我那三千两的扇子出来了，这可如何是好。#suiji" .. "YEL" .. role.name .. "：唉，我那玉佩怎么不见了，噢，原来在这呢，好险好险。"
			pr = "100;100;100;100"
		elseif roleId == "zhounianqin5" then
			textStr = "YEL" .. role.name .. "：谨慎小心点，没什么不好。#suijiYEL" .. role.name .. "：听说最近这江湖中有一伙鬼面人，无恶不作，咱可得小心点呐。#suiji" .. "YEL" .. role.name .. "：做人就是得像我这样谨慎一点。"
			pr = "100;100;100"
		end
		role.conditionAndResults =
		{
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
						arg2 = textStr,
						arg3 = pr
					},
				},
			},
			{
				conditionRelation = "and",
				conditions =
				{
					{
						type = "玩家操作",
						arg1 = "玩家操作",
						arg2 = "操作1",
					}
				},
				results =
				{
					{
						type = "劫富济贫",
						arg1 = "劫富济贫",
					},
				},
			},
		}
	end
	return role
end

-----------------------------------------------------------------------------------------------------------
-- @author ZhangShengTang
-- @time 2017/06/14 12:14:22
-- @desc 添加NPC到房间
function Anniversary:addRoleToRoom(role, map, room)
end

-----------------------------------------------------------------------------------------------------------
-- @author ZhangShengTang
-- @time 2017/06/14 11:56:57
-- @desc 添加角色到副本
function Anniversary:createRoleToMap(map)
	-- zhounianqin2
	-- zhounianqin1
	local role = User:getRole()
	if role:getFlag("萧子远任务") ~= 0 then
		local str = role:getFlag("萧子远任务")
		local strList = string.split(str, ";")
		if strList[1] == "1" then
			if map.id == strList[3] then
				local npc = self:createNpc("zhounianqin1")
				map:createRole(npc)
				map:addRoomRole(strList[4], npc.id)
			end
		elseif strList[1] == "3" then
			if map.id == strList[3] then
				local npc = self:createNpc("zhounianqin2", strList[5])
				map:createRole(npc)
				map:addRoomRole(strList[4], npc.id)
			end
		end
	end

	if role:getFlag("惊鸿燕任务") ~= 0 then
		local str = role:getFlag("惊鸿燕任务")
		local strList = string.split(str, ";")
		if strList[1] == "1" then
			if strList[2] == "0" then
				if map.id == strList[4] then
					local npc = self:createNpc("zhounianqin3", strList[3])
					npc.name = strList[3]
					map:createRole(npc)
					map:addRoomRole(strList[5], npc.id)
				end
			end
		elseif strList[1] == "2" then
			if strList[2] == "0" then
				if map.id == strList[4] then
					local npc = self:createNpc("zhounianqin4", strList[3])
					npc.name = strList[3]
					map:createRole(npc)
					map:addRoomRole(strList[5], npc.id)
				end
			end
		elseif strList[1] == "3" then
			if strList[2] == "0" then
				if map.id == strList[4] then
					local npc = self:createNpc("zhounianqin5", strList[3])
					npc.name = strList[3]
					map:createRole(npc)
					map:addRoomRole(strList[5], npc.id)
				end
			end
		end
	end

	role:setCurrMap(map)
end

-----------------------------------------------------------------------------------------------------------
-- @author ZhangShengTang
-- @time 2017/06/14 12:20:35
-- @desc 击杀NPC
function Anniversary:killNpc(npcId)
	if string.find(npcId, "zhounianqin1") ~= nil then
		PopText("你已经杀死落月山庄叛徒，快回去复命吧。")
		self:finishTask("萧子远任务")
		return
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author ZhangShengTang
-- @time 2017/06/14 12:25:16
-- @desc 完成任务
function Anniversary:finishTask(taskName)
	local role = User:getRole()
	if role:getFlag("萧子远任务") ~= 0 and taskName == "萧子远任务" then
		local str = role:getFlag("萧子远任务")
		local strList = string.split(str, ";")
		role:setFlag("萧子远任务", strList[1] .. ";1")
	end

	if role:getFlag("惊鸿燕任务") ~= 0 and taskName == "惊鸿燕任务" then
		local str = role:getFlag("惊鸿燕任务")
		local strList = string.split(str, ";")
		role:setFlag("惊鸿燕任务", strList[1] .. ";1")
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author ZhangShengTang
-- @time 2017/06/15 16:31:59
-- @desc 任务失败
function Anniversary:failTask(taskName)
	local role = User:getRole()
	if role:getFlag("萧子远任务") ~= 0 and taskName == "萧子远任务" then
		local str = role:getFlag("萧子远任务")
		local strList = string.split(str, ";")
		role:setFlag("萧子远任务", strList[1] .. ";2")
	end

	if role:getFlag("惊鸿燕任务") ~= 0 and taskName == "惊鸿燕任务" then
		local str = role:getFlag("惊鸿燕任务")
		local strList = string.split(str, ";")
		role:setFlag("惊鸿燕任务", strList[1] .. ";2")
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author ZhangShengTang
-- @time 2017/06/15 11:30:22
-- @desc 惊鸿燕任务
function Anniversary:acceptJingHongYan()
	local role = User:getRole()

	if role:getFlag("惊鸿燕任务次数") >= 7 then
		RichPrint("main", "YEL鬼面人:任务都已经完成了，这段时间多谢你了。")
		return
	end

	if role:getDayFlag("惊鸿燕任务可接") == 1 then
		RichPrint("main", "YEL鬼面人：今日暂无其他任务，你明日再来吧。")
		return
	elseif role:getDayFlag("惊鸿燕任务可接") == 2 then
		RichPrint("main", "YEL鬼面人：今日暂无其他任务，你明日再来吧。")
		return
	end

	if role:getFlag("惊鸿燕任务") == 0 then

		-- 随机三个NPC
		local num = math.random(1,3)
		local name = Helper:getRandomName("男")
		local mapId = self:getRandMap()
		local roomId = self:getRandRoom(mapId)
		local map = role:getMapById(mapId)
		local roomName = map.room[roomId].name

		RichPrint("main", "YEL鬼面人：HIC" .. name .. "YEL有我们要的东西，此人现在在HIC" .. map.name .. roomName .. "YEL，你快快前去，将东西盗来。切记：多疑之人，东西一般会藏在怀里，粗心之人，东西一般会藏在袖囊，谨慎之人，东西一般会藏在腰间。")
		role:setFlag("惊鸿燕任务", num .. ";0;" .. name .. ";" .. mapId .. ";" .. roomId)
		print("接新任务" .. role:getFlag("惊鸿燕任务"))
	else
		print(role:getFlag("惊鸿燕任务"))
		-- 判断是否完成任务
		local str = role:getFlag("惊鸿燕任务")
		local strList = string.split(str, ";")



		if strList[2] == "1" then
			if role:getAttr("weight") - #role:getItems() < 1 then
				PopText("背包已满，无法领取奖励")
				return
			end

			-- HttpManagerEx:addActivityPoint(100, "zhounianqin_jhy", function(status, errcode, errmsg, data, isEncrypted)
		 --        -- PopText("返回数据 是否有加密  == "..tostring(isEncrypted))
		 --        if isEncrypted == false then
		 --            Collection:memoryCheat(User:getRoleAttr("userid"), "proxyData", 0, data)
		 --            return
		 --        end
		 --        if status == 200 then
		 --            if errcode ~= 0 then
		 --            	PopText(errmsg)
		 --            else
		 --            	if data.number ~= nil and data.number > 0 then
		 --            		PopText("周年活动积分 + " .. data.number)
		 --            	end
		            	-- 领取奖励
						if strList[2] == "1" then
							if role:getAttr("weight") - #role:getItems() < 1 then
								PopText("背包已满，无法领取奖励")
								return
							end
							local itemId = "yizhounianjinian" .. (5 + role:getFlag("惊鸿燕任务次数"))
							role:setFlag("惊鸿燕任务次数", role:getFlag("惊鸿燕任务次数") + 1)
							role:addItemCount(itemId , 1)
							local item = Item:getOneItemByKey(itemId)
							PopText("获得 " .. item.name .. " X 1")
							role:addAttr("exp", 10000)
							PopText("经验 + " .. 10000)

							role:setFlag("惊鸿燕任务", 0)
							role:setDayFlag("惊鸿燕任务可接", 1)
							RichPrint("main", "YEL鬼面人：做的不错嘛，我果然没看错人。")

							-- 惊鸿燕任务成功统计
							local Record = require("app.models.Record.Record")
							Record:addRecordCount("anniversary", "jhy", 1)
						end

						-- 上传存档
						HttpManagerEx:uploadUserData("shangchuan", function(status, errcode, errmsg, data, isEncrypted)
							if status == 200 and errcode == 0 then
							else
								PopText(errmsg)
							end
						end, IS_SHOW_WAITING)
					-- end
		    --     end
		    -- end, IS_SHOW_WAITING)


		elseif strList[2] == "2" then
			-- 失败
			role:setFlag("惊鸿燕任务", 0)
			role:setDayFlag("惊鸿燕任务可接", 2)
			RichPrint("main", "YEL鬼面人：哼，这么点小事都办不来，你今天先回去，明日再来吧。")

			-- 惊鸿燕任务失败统计
			local Record = require("app.models.Record.Record")
			Record:addRecordCount("anniversary", "jhy", 2)
		else
			-- 还没做完
			local name = strList[3]
			local map = role:getMapById(strList[4])
			local roomName = map.room[strList[5]].name
			RichPrint("main", "YEL鬼面人：HIC" .. name .. "YEL有我们要的东西，此人现在在HIC" .. map.name .. roomName .. "YEL，你快快前去，将东西盗来。切记：多疑之人，东西一般会藏在怀里，粗心之人，东西一般会藏在袖囊，谨慎之人，东西一般会藏在腰间。")
		end
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author ZhangShengTang
-- @time 2017/06/15 15:46:22
-- @desc 偷取NPC
function Anniversary:theft(part)
	local role = User:getRole()
	-- 根据不同部位判断偷取成功失败
	if role:getFlag("惊鸿燕任务") ~= 0 then
		local str = role:getFlag("惊鸿燕任务")
		local strList = string.split(str, ";")
		if strList[2] == "0" then
			-- 未完成可偷取
			if tonumber(strList[1]) == part then
				return true
			end
		end
	end
	return false
end

local story =
{
	[1] =
	{
		"第一折 剑斗逸龙",
		"#",
		"#",
		"醉里横剑独揽月，不管他人笑痴癫。",
		"#",
		"二十年前，落月山庄萧逸龙为报子仇，剑闯日月教，火烧朱雀堂，独败三长老，震惊天下，亦借此契机创立了落月山庄。",
		"#",
		"然数月之后，其挚友“湖山居士”于中清竟被人所害，萧逸龙丧子在先，如何受得这等刺激，一路追查之下，终于追查到此事乃是苏浙一带赫赫有名的“黑山八凶”所为！",
		"#",
		"这苏浙黑山一带，山贼猖獗，各占山头，而其中八位势力最大者，均是手段狠辣作恶多端的江湖好手，而后结为兄弟，自称“黑山八凶”，这苏浙一带，无人不对其惧怕三分。",
		"#",
		"萧逸龙当下提剑，独闯黑山，欲仿当年日月之事，谁知一路直闯，却无一人阻拦，直至黑山寨中方见一名白衣青年。萧逸龙心中火盛，未作深思便拔剑而上！",
		"#",
		"那白衣男子见此状亦是拍剑而起！萧逸龙心火难平，出剑迅猛，而白衣男子更是非同小可，出剑奇快，宛若风雷，两人斗剑数百招，胜负不分。",
		"skip",
		"#",
		"#",
		"而此时萧逸龙亦是渐渐平静下来，心中却越觉不对。黑山八凶恶名远扬，武功路数走的都是阴鸷凶狠之道，而白衣男子招数路数皆是正统，不似八凶。",
		"#",
		"落月剑法本非强攻之剑，但因萧逸龙之前心急如焚，实力不显，如今心如明镜，当即一剑逼退白衣男子，跳出战圈，收剑抱拳，问其身家。",
		"#",
		"白衣男子也不追赶，收剑回鞘，自报家门，原来此人乃是雪山琼宫冷明轩。原来这冷明轩见不得八凶作恶，已将八人尽诛之。当下误会两除，二人不打不相识，结下友谊。",
		"#",
		"雪山琼宫，居于塞北雪山之巅，常年闭门不出，历代唯数名弟子入世历练，故江湖传闻甚少。而“剑啸风雷”冷明轩便是其一。",
		"#",
		"冷明轩年纪轻轻便能在萧逸龙手下走过百招，足见武功精妙。经此一战，名声大噪，而后又行不少侠义之事，雪山琼宫之名传于江湖。",
		"#",
		"正是：",
		"#",
		"雪山缥缈峰，秘境隐其中。",
		"#",
		"剑啸惊风雷，落月决琼宫。",
		"return"
	},
	[2] =
	{
		"第二折 崇武旧事",
		"#",
		"#",
		"风雷一动惊崇武，天下谁人不识君？",
		"#",
		"说的便是崇武楼武君应龙的威名。应龙本是一名穷苦人家孩子，恰逢连年大旱，颗粒无收，他家中五兄妹，均先后离世。",
		"#",
		"那年冬天，应龙在雪地中救起一人，还将身上救命的干粮尽数予他，回家被父母一顿好揍。",
		"#",
		"然好心终有好报，应龙所救之人竟是一世外高人，三日之后寻到应龙，将其绝学“寒天神手”倾囊相授。应龙本就资质过人，只十年苦修，已至江湖一流高手行列。",
		"#",
		"然应龙为人刚正不阿，嫉恶如仇，行走江湖之间，虽创下赫赫威名，也难免得罪邪派中人。应龙对此毫不在意，终于在一次江湖纷争得罪了邪道高手“湘西四鬼”。",
		"#",
		"自古湘西多奇人异术，这湘西四鬼又是个中翘楚。但有富贵人家家人去世，必然上门以超度之名勒索，如若给，则相安无事；如若不给，不出三日，这户人家家中老小必然惨死。",
		"skip",
		"#",
		"#",
		"湘西四鬼当即拉拢了一帮江湖邪士，杀至应龙家中。此时的应龙却刚好外出，湘西四鬼等人便将应龙父母害死。",
		"#",
		"应龙得知，怒火滔天，在断龙崖拦下湘西四鬼与数十名邪道人士，血战一天一夜，凭一己之力而歼之。武林震惊，皆尊其为“武君”。",
		"#",
		"“武君”应龙虽报得血海深仇，但父母已亡，无法复生，心中亦知自身缺点，便不再涉足江湖纷争，创立崇武楼，邀战天下英雄，沉浸于武道。",
		"#",
		"这正是：",
		"#",
		"寒天藏奇功，引歌啸长风。",
		"#",
		"回首相望处，人去故园空。",
		"return"
	},
	[3] =
	{
		"第三折 华山剑痴",
		"#",
		"#",
		"有花有酒春色好，无心无关风云月。",
		"#",
		"若说这世间，谁人最不识风花雪月，众说纷纭。其中一人，人称“剑痴”，此人当真是除了习剑，其余一概不会也不闻。",
		"#",
		"剑痴真名叫百里云，相传百里云四岁之时见其父在院中练剑，抱鞘不走。父奇之，削木剑予之，百里云持剑便舞，恍然便是其父所练剑法。",
		"#",
		"而后更在其十七岁那年创出天罗步法，剑败大江帮帮主，名扬江湖，一时之间，江湖尽知华山百里云之名，皆言华山崛起在此人身上。",
		"#",
		"百里云年少成名，难免心浮气躁，竟发下战帖，邀世间能者，与之一战。",
		"#",
		"这一举动，惹来一人，此人姓严，名无我，江湖人称“剑君”，此人成名江湖数十载，其独创的逍遥无相剑，横压一代江湖高手，无人能出其右者。",
		"#",
		"“剑君”此次前来本是听闻百里云之才华，心痒难耐，欲考量其剑法，若其名副其实，便将衣钵相传。",
		"#",
		"但此时百里云见有人应战，毫无惧色，甚至言语之中还透着几分刻薄，此举让“剑君”大为恼怒。",
		"skip",
		"#",
		"#",
		"当下二人于华山之顶比剑，“剑君”含怒而战，惜才之心荡然无存，三招便将百里云击败。",
		"#",
		"百里云少年成名，江湖之上，师门之内，无不夸其天赋异禀，剑法高超，今日却在他人剑下走不过三招，故而心中羞愧弃剑而去，自此闭门参剑不出。",
		"#",
		"而严无我亦十分后悔，世间良才美玉难求，能传其衣钵者甚少，之后便好似人间蒸发，再无下落。",
		"#",
		"而今周天功现世，江湖纷乱，百里云向心而求，出关而出，悟得“心剑”，更胜往昔。现已下山，追寻周天功下落。",
		"#",
		"想百里云此人，少年成名却遇一代剑君，心境被破，沉寂数十载，方才突破，华山剑痴之名亦重临江湖。",
		"#",
		"正是：",
		"#",
		"思过垂日暮，老槐影横疏。",
		"#",
		"剑痴今犹在，世人知我无？",
		"return"
	},
	[4] =
	{
		"第四折 剑斩九煞",
		"#",
		"#",
		"神尼计出斗九煞，披风快剑诛妖邪。",
		"#",
		"历代峨眉弟子心存正义，豪杰频出，都是巾帼不让须眉的女侠。其中有一六代弟子，唤作玄灵师太，乃是宝相神尼座下得意弟子。",
		"#",
		"此女子原名唤作张玄灵，天资奇高，武功不凡，廿五年岁，即自创“乱披风剑法”。",
		"#",
		"这玄灵师太虽近年礼佛不出，年少时候却也做过惊天大事。十余年前，玄灵师太下山游历至天南附近，口渴之盛，乃向一村中讨水问路。谁知村庄之内，竟半个人影也无。",
		"#",
		"在玄灵师太调查之下，发现这整村三十多户人家，竟全部惨死家中，而村内的值钱物事，都被洗劫一空。",
		"#",
		"全村被屠，光景如同炼狱，玄灵师太心有不忍为其祷告念经，随后便欲将村人下葬。",
		"#",
		"却见一青年浑身上下并无任何伤口，脸色惨白。她心中疑惑，检查尸体，在尸体之上找到一处掌痕。",
		"skip",
		"#",
		"#",
		"这掌痕通体血红，指印清晰，却没有小指印记。这掌印，分明是天南九煞之孤煞游进手中绝学“血竭掌”所留下。",
		"#",
		"游进年轻时右手小指被毒蛇所咬，自断小指以保命，却不想天网恢恢，如今暴露身份，玄灵师太虽心怀慈悲，但此刻亦是下定决心要为全村人报仇。",
		"#",
		"天南九煞作恶多端，爱好钱财宝物，玄灵师太亦以此做局，谎称自己携带重宝，诱天南九煞前来抢夺。",
		"#",
		"天南九煞听闻此事，当即出动，将玄灵师太拦在荒郊小路上。玄灵师太毫不畏惧，剑气翻卷，与九人斗了足足六个时辰，斩九煞于剑下。",
		"#",
		"玄灵师太剑斩九煞，威震天南，江湖中人无不仰慕，但此事也让玄灵师太性情大变，为日后一件江湖之事埋下了祸根。",
		"#",
		"正是：",
		"#",
		"我心本向佛，问剑除妖魔。",
		"#",
		"因果铸业障，究竟佛还魔？",
		"return"
	},
	[5] =
	{
		"第五折 永夜之初",
		"#",
		"#",
		"寒更承永夜，凉景向秋澄。",
		"#",
		"永夜者，长夜未央也。而永夜，也恰指永无天日的已死之人。而这亦是永夜楼的创立初衷。",
		"#",
		"永夜楼行事极为隐秘，江湖中关于其传闻寥寥无几，但凡是楼中之人，均是一等高手，隐身于黑暗之中，行暗杀之事。",
		"#",
		"若有求于永夜，当寻求一种永夜专用“火鸽”。将自己姓名系于其脚上，七日之内，必有永夜线人前来联系。",
		"#",
		"事成之后，需将事先约定银两交与线人，若交不出，则需以最珍惜之物交换。而每人珍爱之物不尽相同，或亲人，或宝物，或自身性命，均会被永夜派人夺走。",
		"#",
		"永夜楼建立者已不可考。永夜楼楼主代代隐姓埋名，以永夜自称。永夜属下之人，自拜入永夜楼之始，便抛却姓名，各有代称。",
		"#",
		"永夜中人白日隐藏身份，与常人无异，夜晚则飞檐走壁，杀人无形。相传永夜楼出过不少史上赫赫有名的刺客，至于是否为真，无人得知。",
		"skip",
		"#",
		"#",
		"相传永夜楼传承至今，已有数十代，传承深厚，然经“刺龙案”一案之后，江湖之中已甚少有其传闻。",
		"#",
		"其上任楼主武功卓绝，座下四大高手，乃飞、花、风、林。这四人之中，飞擅刺探，身法鬼魅；花擅易容，真假莫辨；风擅暗器，百步穿杨；林擅刀法，无坚不摧。",
		"#",
		"几年前，林在一场刺杀后不知所踪，如今只余下三人。现任楼主乃一名女子，从未有人见过真貌，武功亦无从得知。",
		"#",
		"人道永夜楼为邪，是非不分，滥杀好人；也有道永夜本属中立，杀人只追从本心。这其中纷纷扰扰，又岂是他人所能言语？",
		"#",
		"永夜楼却从不顾及江湖眼光，只遵从永夜规矩，拿钱杀人。这又何尝不是遵循因果的道理？",
		"#",
		"正是：",
		"#",
		"只闻众生笑，不听百鬼啼。",
		"#",
		"悲欢五十载，去时尽归西。",
		"return"
	},
	[6] =
	{
		"第六折 盗君佚闻",
		"#",
		"#",
		"飞针连点机关破，踏穴寻位龙脊鸣。",
		"#",
		"豫鲁一带，墓葬数不胜数，自古便是盗墓者云集之地，而论盗墓，以开封黄家，临淄夏侯为最。",
		"#",
		"而百余年前，“长生诀”一事中，黄家满门被灭，夏侯家元气大伤，再无往日辉煌。之后百年内，夏侯家虽致力于振兴自家，奈何有心无力，一直没有突破，直到夏侯博出现。",
		"#",
		"夏侯博此人，天资卓绝，乃百年难得一见的奇才。年仅十六便将家传武学尽数练成，以金针术与游龙惊鸿的轻功独步武林。他侠义为怀，为人慷慨，常以盗墓钱财施舍穷人，声名颇佳。",
		"#",
		"一日，他行至江浙一带，却见一刺客追杀妇孺，赶忙出手救下，怎奈那妇人已身受重伤，药石无用。",
		"#",
		"临死之前求夏侯博将幼子送至京城，夏侯博心有不忍，答应了妇人，遂携稚子路北上。",
		"#",
		"却未曾想到，此举却招来江湖暗杀组织永夜楼的追杀，更兼其四大高手中的飞、风两人堵截，然夏侯博凭其绝世轻功，过人之智，逃过重重追杀，终是将人送入京城。",
		"skip",
		"#",
		"#",
		"更让人未曾想到的是，这稚子竟是当朝天子四子，天子为感其侠义，御赐“盗君”之名，同时传令剿灭永夜楼，史称“刺龙案”。",
		"#",
		"自此之后，永夜楼之势由盛转衰，一去不返，而夏侯博亦因此事被天下共推为“盗君”，名满江湖。",
		"#",
		"但纵是如此厉害的人物，也终难逃惊扰死者必然不得善终的报应。据说夏侯博而后受人所邀前去盗墓，一去数月，之后尸体在长白山被发现。",
		"#",
		"夏侯博究竟所盗为何墓？无人得知。有传闻说乃是世外高人之墓，有说是达官贵人之墓，更有甚者说乃是皇陵。",
		"#",
		"夏侯博独女夏侯燕，一路调查其父死因，究竟能否发现线索？旁人不得而知，只叹是因果报应，屡试不爽。",
		"#",
		"正是：",
		"#",
		"世清我独孤，犹抱白骨哭。",
		"#",
		"生来钱百万，去后有还无。",
		"return"
	},
	[7] =
	{
		"第七折 周天神功",
		"#",
		"#",
		"万物相生亦相克，周天生灭终成空。",
		"#",
		"江湖从来都不是一个人的江湖，天下之大，高手之多，宛如天上繁星，而柳玄风却是这数十载星空中的皓月，照耀一方，是诸多江湖人心中绕不过的巨柱！",
		"#",
		"数十年前，一伙神秘组织兴起于江湖，抢夺盗取别派秘籍，少林，峨眉等大派均遭此厄难，然数月之后，这伙神秘人中的一人被调查出身份，其名为柳玄风。",
		"#",
		"柳玄风初现之时不过是一名三流高手，但短短一年之内，竟能与宗师比肩，这让无数江湖人士都为之疯狂，经多方打探，这柳玄风所使武学名为周天功，可包容万象，纳百家之长以为己用。",
		"#",
		"消息传开，江湖风云涌动。不管是名门正派，亦或是奇门邪派，都或想一睹究竟，或想占为己有，乃至人人趋之若鹜，纷争不断。",
		"#",
		"这柳玄风原是崆峒弟子，而后偷盗秘籍叛出山门，经由江湖人士多番调查之下，发现其父母双亡似被仇人所杀，柳玄风叛门似乎也于此有关，而至于这神秘的组织，也因柳玄风坠崖，生死不明，便很难再得知。",
		"skip",
		"#",
		"#",
		"柳玄风前半生平淡无奇，而后却得此奇遇，更叛师背门，搅起武林纷争，三十余岁便已至宗师之境，而后更利益熏心，强攻灵鹫，多年辛苦，一朝坠崖，化为流水，真是可怜可叹。",
		"#",
		"正是:",
		"#",
		"少年恩仇天地间，挥刀如鬼亦似仙。",
		"#",
		"明月照崖空对影，从此无刀也无剑。",
		"#",
		"#",
		"return"
	},
	[8] =
	{
		"此事请听我道来。",
		"#",
		"#",
		"欧冶子前辈为沐前辈一事而来，",
		"#",
		"而沐前辈，",
		"#",
		"确为我唐门中人所杀。",
		"#",
		"昔年江湖动乱，",
		"#",
		"神兵利器为人人所趋鹜，",
		"#",
		"百兵又以铸剑为尊；",
		"#",
		"除超然于世的欧冶子前辈，",
		"#",
		"江湖上还有三人闻名：",
		"#",
		"西绝华山沐清风；",
		"#",
		"南隐唐门唐阡陌；",
		"#",
		"北水之巅轩辕生。",
		"#",
		"这三人便是沐清风，我父亲唐阡陌与轩辕生。",
		"#",
		"单论锻造技艺，他三人各有所长；",
		"skip",
		"#",
		"#",
		"多年分不出高下，反成为生死之交。",
		"#",
		"后三人有了子嗣，便决定让后代来一决高低。",
		"#",
		"那时唐家去的便是我。另外则是沐前辈之子沐桓，轩辕前辈之子轩辕清。",
		"#",
		"三月之后各自铸成，",
		"#",
		"沐桓铸软剑千无；",
		"#",
		"我糅合机关术，铸造机关剑含影；",
		"#",
		"而轩辕清铸双剑，并以两子之名命曰云霞、东来。",
		"#",
		"不日三剑对决，终是我唐家侥幸略胜一筹，",
		"#",
		"却不想被轩辕生看出破绽，我与父亲发生争执。",
		"#",
		"我从他二人的话语中得知，父亲传授给我的铸造术中融合了轩辕家的独门锻造术，而轩辕清之妻，恰是我父做媒，嫁去的唐门弟子。",
		"#",
		"轩辕生骂我父亲无耻之尤，为了偷学布得一手好棋；",
		"#",
		"而父亲，并无否认。",
		"#",
		"争执当晚，轩辕夫妻与两子暴毙与客栈之中，所有证据却都指向我唐家。",
		"skip",
		"#",
		"#",
		"轩辕生恼怒，决意与我父亲拼命，",
		"#",
		"我父亲出手自卫，但其暗器被人暗中淬了毒，",
		"#",
		"失手伤了轩辕生之后，他便殒命当场。",
		"#",
		"轩辕家一晚惨遭横祸，只留下最小的孩子幸存；",
		"沐前辈却深知我父为人，相信轩辕家的人并非其所杀，",
		"#",
		"只将轩辕清的剑与那孩子一同带回华山。",
		"#",
		"轩辕家虽非父亲亲手所害，却也是因盗窃铸造术一事，才会引发误会。",
		"#",
		"他回到唐家便将家主让给我，",
		"#",
		"不再管理家中之事，",
		"#",
		"也不再允许唐家人学习铸剑术。",
		"#",
		"我心存疑虑，仔细调查此事多年，",
		"#",
		"才发现嫁祸之人不是别人，",
		"#",
		"正是我二弟，唐不武。",
		"skip",
		"#",
		"#",
		"他觊觎家主之位，",
		"#",
		"本想借着嫁祸父亲与我，让三家反目成仇，进而除掉我等，",
		"#",
		"没料到此事最终被按下不提。",
		"#",
		"我知道他心怀不轨，",
		"#",
		"却念在兄弟之情，终究下不去手。",
		"#",
		"老二却暗中经营多年，",
		"#",
		"如今乘着父亲病逝，对我下毒暗算，又让自己的手下占领了唐家。",
		"#",
		"他怕当年嫁祸轩辕家的事会东窗事发，",
		"#",
		"便派人害死了知晓部分实情的沐家父子，",
		"#",
		"轩辕家的遗子轩辕夏，也下落不明。",
		"return"
	},
}

-----------------------------------------------------------------------------------------------------------
-- @author ZhangShengTang
-- @time 2017/06/17 10:30:15
-- @desc 说书人
function Anniversary:storyteller(index, succFunc)
	if index == nil or index > #story then
		return
	end

	succFunc = Helper:getDef(succFunc, function()end)

	local CustomLayer = require("app.views.layer.PopLayer.PopLayer")
	CustomLayer:getInstance():showLayer()
	local strList = {}
	for i,v in ipairs(story[index]) do
		local str = "CRO" .. v
		if v == "#" then
			CustomLayer:getInstance():pushBackPanelList("empty", str, nil, nil, nil, 50, nil, 0)
		elseif v == "return" then
			CustomLayer:getInstance():pushBackPanelList("return", str, nil, nil, nil, 50, nil, 0, function()
				PopupLayerController:showLayer("StorytellerLayer", function(layer)
					layer:showLayer(strList, succFunc)
				end)
			end, 0)
		elseif v == "skip" then
			CustomLayer:getInstance():pushBackPanelList("shade", str, nil, nil, nil, 1920, "Fade", 3)
			CustomLayer:getInstance():pushBackPanelList("empty", str, nil, nil, nil, 1920, nil, 0)
		elseif i == 1 then
			CustomLayer:getInstance():pushBackPanelList("text", str, 60, cc.VERTICAL_TEXT_ALIGNMENT_CENTER, cc.TEXT_ALIGNMENT_CENTER, 1920, "Fade", 3)
		else
			table.insert(strList, str)
			CustomLayer:getInstance():pushBackPanelList("text", str, 42, nil, nil, nil, "Fade", 3)
		end
	end
	CustomLayer:getInstance():startShow()
end

function Anniversary:newStoryteller(storyArr, timeArr, succFunc)  --新说书显示
	if MapIsEmpty(storyArr) or MapIsEmpty(timeArr) or type(storyArr)~="table" or type(timeArr)~="table" then
		print("检查文本与时间")
		return
	end

	succFunc = Helper:getDef(succFunc, function()end)

	table.insert(storyArr,"return")
	table.insert(timeArr,0)
	local CustomLayer = require("app.views.layer.PopLayer.PopLayer")
	CustomLayer:getInstance():showLayer()
	CustomLayer:getInstance().Panel_back:setVisible(true)
	local strList = {}
	for i,v in ipairs(storyArr) do
		if not v then 
			v=""
			print("error: storyArr[i] is nil ")
		end
		local str = "CRO" .. v
		
		if not timeArr[i] then 
			timeArr[i]=0
			print("error: timeArr[i] is nil ")
		end
		if  type(timeArr[i])=="string" then 
			timeArr[i]=tonumber(timeArr[i])
			print("warning: the type of timeArr[i] is string ")
		end

		if v == "return" then
			CustomLayer:getInstance():pushBackPanelList("return", str, nil, nil, nil, 50, nil, timeArr[i], function()
				PopupLayerController:showLayer("StorytellerLayer", function(layer)
					layer:showLayer(strList, succFunc)
				end)
			end, 0)
		elseif i == 1 then
		 	CustomLayer:getInstance():pushBackPanelList("newText", str, 60, cc.VERTICAL_TEXT_ALIGNMENT_CENTER, cc.TEXT_ALIGNMENT_CENTER, 1920, "Fade", timeArr[i])
		else
			table.insert(strList, str)
			CustomLayer:getInstance():pushBackPanelList("newText", str, 42, nil, nil, nil, "Fade", timeArr[i])
		end
	end
	CustomLayer:getInstance():startShow()
end

-----------------------------------------------------------------------------------------------------------
-- @author ZhangShengTang
-- @time 2017/06/28 15:57:18
-- @desc 检测是否有周年庆挂机收益
function Anniversary:checkIsProfitBuff()
	local startTime = Helper:getTimeStampWithStringDate("20170706",0)
	local endTime = Helper:getTimeStampWithStringDate("20170721",0)
	local currTime = GetTime()
	if currTime > startTime and currTime < endTime then
		return true
	end
	return false
end

return Anniversary00000000000000