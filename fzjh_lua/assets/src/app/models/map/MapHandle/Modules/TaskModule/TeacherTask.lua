--@SuperType [src.app.models.map.MapHandle.Modules.BaseModule#BaseModule]
local TeacherTask = class("TeacherTask", require("app.models.map.MapHandle.Modules.BaseModule"))

--@desc 涉及副本ID ：格式{["id"] = true} 默认为nil，无限制
TeacherTask.mapId = nil

--@desc 涉及房间 : 格式{["id"] = true} 默认为nil，无限制
TeacherTask.roomId = nil

--@desc 开启状态，默认开启 【1】为开启，【0】为关闭
TeacherTask.status = 1

--@desc 活动时间 : 格式：20171001，默认值0 表示无时间限制
TeacherTask.activityTime = 0

--@desc 子模块
TeacherTask.childModule = {}

--@desc 条件结果的方法
TeacherTask.doResult = {
	["化缘"] = function(map, result, environment)
		local text = {
			[1] = {
				[1] = "你上前表明身份并提出了化缘的要求。却见那人点了点头，从怀中拿出了几个馒头与你。你口称一句佛号并表达了感谢。",
				[2] = "你上前表明身份并提出了化缘的要求。却见那人笑了一笑，拿出了一些干粮给你。你口称一句佛号并表达了感谢。"
			},
			[2] = {
				[1] = "你上前表明身份并提出了化缘的要求。却见那人冲你摆了摆手，婉拒了你便离开了。你口称一句佛号默默离开了。",
				[2] = "你上前表明身份并提出了化缘的要求。却见那人冲着你破口大骂，骂完便走了。你叹了一声默默离开了。"
			},
		}
		RichPrint("main", text[result.arg2] [math.random(1, 2)])
		local TeacherTask = require("app.models.task.teacherTask.teacherTask")
		map:removeRoomRole(result.arg4, currRole.id)
		
		TeacherTask:dealShaoLinConditionAndResult(result.arg2, result.arg3, environment.currRole, map)
	end,
	
	["询问"] = function(map, result, environment)
		local currRole = environment.currRole
		local TeacherTask = require("app.models.task.teacherTask.teacherTask")
		TeacherTask:dealTieZhangConditionAndResult(currRole, result.arg2, map)
	end,
	
	["拐走"] = function(map, result, environment)
		local TeacherTask = require("app.models.task.teacherTask.teacherTask")
		TeacherTask:dealMiZongConditionAndResult(environment.currRole, map)
	end,
	
	["敲诈"] = function(map, result, environment)
		local ZhuangShenBanGuiLayer = require("app.views.layer.TeacherTaskLayer.TeacherTaskGame.ZhuangShenBanGuiLayer")
		ZhuangShenBanGuiLayer:enterLayer(map, environment.currRole, result.arg2, map.__MapLayer._currRoom.id)
	end,
	
	["参禅"] = function(map, result, environment)
		-- @author GaoHanZheng
		-- @time 2017/06/15 16:36:40
		-- @desc 天龙寺特殊任务
		local TeacherTask = require("app.models.task.teacherTask.teacherTask")
		local isSuccess = TeacherTask:dealTianLongConditionAndResult(map, environment.currRole)
	end,
	
	["学琴"] = function(map, result, environment)
		-----------------------------------------------------------------------------------------------------------
		-- @author GaoHanZheng
		-- @time 2017/06/16 14:40:55
		-- @desc 昆仑特殊任务学琴
		local TeacherTask = require("app.models.task.teacherTask.teacherTask")
		TeacherTask:dealKunLunXueQinConditionAndResult(map, environment.currRole)
	end,
	
	["开解"] = function(map, result, environment)
		-----------------------------------------------------------------------------------------------------------
		-- @author GaoHanZheng
		-- @time 2017/06/19 11:05:43
		-- @desc 崆峒特殊任务
		local TeacherTask = require("app.models.task.teacherTask.teacherTask")
		TeacherTask:dealKongTongConditionAndResult("开解", result.arg2, environment.currRole, map)
	end,
	
	["调解"] = function(map, result, environment)
		local TeacherTask = require("app.models.task.teacherTask.teacherTask")
		TeacherTask:dealKongTongConditionAndResult("调解", result.arg2, environment.currRole, map)
	end,
	
	["收贡"] = function(map, result, environment)
		local TeacherTask = require("app.models.task.teacherTask.teacherTask")
		TeacherTask:dealTianShanConditionAndResult(environment.currRole, "ShouGong", map, true)
	end,
	
	["装神扮鬼"] = function(map, result, environment)
		-- print(result.arg2)
		local player = User:getRole()
		local currRole = environment.currRole
		local TeacherTask = require("app.models.task.teacherTask.teacherTask")
		local receiveTask = TeacherTask:getTeacherTaskAttr("receiveTask")
		local reward = {}
		for k, v in pairs(receiveTask.daoju) do
			reward[v] = 1
		end
		if User:getRole():checkCanBuyTwoOrMoreThings(reward) == false then
			PopText("背包空间不足")
			return
		end
		local answer = TeacherTask:getYouMingSpecialTaskResult(currRole, result.arg2)
		if answer == true then
			if environment.func then
				environment.func()
			end
			for k, v in pairs(receiveTask.daoju) do
				if player:getItem(v) then
					player:addItemCount(v, 0 - player:getItem(v).count)
				end
			end
			if TeacherTask:getTeacherTaskAttr("isComplete") == "Y" then
				for k, v in pairs(receiveTask.daoju) do
					if player:getItem(v) then
						player:addItemCount(v, 0 - player:getItem(v).count)
					end
				end
			end
			map:removeRoomRole(map.__MapLayer._currRoom.id, currRole.id)
			return
		end
		local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
		local dialog = DialogALayer:getInstance()
		dialog:hide()
		dialog:show("HIR看起来" .. currRole:getName() .. "想与你决斗！")
		dialog:setBack(false)
		dialog:setButton1("迎战", function()
			Audio:playEffect("jiaoHu")
			if TANGJIAN_TEST_ENABLE then
				local role = currRole
				local currMap = map
				map.mapLayer = map.__MapLayer
				
				role:initNpcAttr() -- NPC状态初始化
				map:afterFightWithShaSi(player, role, function(winTeamId)
					-- 战斗胜利条件结果
					if winTeamId == 1 then
						PopText("你决斗战胜了" .. role:getName())
						
						-- 玩家操作默认
						role:setFlag("是否死亡", true)
						currMap:dowithRoleOperation({
							operation = "杀死",
							result = "成功",
							player = player,
							currRole = role,
							currMap = currMap,
							currRoomId = map.mapLayer._currRoom.id
						})
						currMap:doConditionAndResult(role.conditionAndResults,
						{
							conditionType = "杀死",
							result = "成功",
							currRole = role,
							currRoomId = map.mapLayer._currRoom.id,
							mapLayer = map.mapLayer
						})
						currMap:doRoomConditionAndResult(map.mapLayer._currRoom.id) -- 刷新房间条件结果
						answer = TeacherTask:getYouMingSpecialTaskResult(currRole)
						if answer == true then
							if environment.func then
								environment.func()
							end
							map:removeRoomRole(map.__MapLayer._currRoom.id, currRole.id)
						else
						end
						if answer == false then
							PopText("信息处理出错,请联系客服")
						end
						map.__MapLayer:delayRefreshMap()
					elseif winTeamId == 2 or winTeamId == 3 then
						for k, v in pairs(receiveTask.roomId) do
							map:removeRoomRole(v, receiveTask.npcId[k])
						end
						if environment.func then
							environment.func()
						end
						receiveTask.roomId = {}
						receiveTask.jiangli = 1
						RichPrint("main", "RED你被" .. currRole:getName() .. "打败了。")
						for k, v in pairs(receiveTask.daoju) do
							if player:getItem(v) then
								player:addItemCount(v, 0 - player:getItem(v).count)
							end
						end
						TeacherTask:setTeacherTaskAttr("receiveTask", receiveTask)
						TeacherTask:setTeacherTaskAttr("isComplete", "Y")
						for k, v in pairs(receiveTask.daoju) do
							if player:getItem(v) then
								player:addItemCount(v, 0 - player:getItem(v).count)
							end
						end
						map.__MapLayer:setNeedRefreshMap()
						if User:getRole():getFlag("佣兵模式") == "开启" then
							currMap:doConditionAndResult(role.conditionAndResults,
							{
								conditionType = "杀死",
								result = "失败",
								currRole = role,
								currRoomId = map.mapLayer._currRoom.id,
								mapLayer = map.mapLayer
							})
							currMap:doRoomConditionAndResult(map.mapLayer._currRoom.id)-- 刷新房间条件结果
						else
							-- map.__MapLayer.TotalMapBtn_IsInit = false
							-- map.__MapLayer:quit()
						end
					else
						
					end
				end)
			else
				
			end
		end)
		dialog:setButton2()
	end,
	
	["捕雀功"] = function(map, result, environment)
		local ClimbingLayer = require("app.views.layer.TeacherTaskLayer.SpecialTeacherTask.GuMuSpecialTeacherTask")
		local str = "只见其中一只麻雀向正上飞去，快快抓住它;只见其中一只麻雀向斜上飞去，快快抓住它;只见其中一只麻雀向左上飞去，快快抓住它;只见其中一只麻雀向右上飞去，快快抓住它,正上成功;斜上成功;左上成功;右上成功"
		local climbingLayer = ClimbingLayer:getInstance()
		climbingLayer:showLayer("捕雀", "", 1.5, 10, 6, str, function()
			-- print("抓捕成功")
			local TeacherTask = require("app.models.task.teacherTask.teacherTask")
			local receiveTask = TeacherTask:getTeacherTaskAttr("receiveTask")
			map:removeRoomRole(receiveTask.roomId, environment.currRole.id)
			receiveTask.roomId = {}
			TeacherTask:setTeacherTaskAttr("receiveTask", receiveTask)
			TeacherTask:setTeacherTaskAttr("isComplete", "Y")
			RichPrint("main", "YEL杨无虑：不错不错，这次便到此为止吧。")
			map.__MapLayer:setNeedRefreshMap()
		end, function()
			-- print("抓捕失败")
			RichPrint("main", "YEL杨无虑：连飞鸟都捉不住，再来！练到你能捉住为止！")
		end)
		climbingLayer:setButtonName("往正上抓;往斜上抓;往左上抓;往右上抓")
	end,
	
	["官府缉凶"] = function(map, result, environment)
		local GuanFuJiXiongLayer = require("app.views.layer.TeacherTaskLayer.TeacherTaskGame.GuanFuJiXiongLayer")
		RichPrint("main", "YEL王推官：上面的人派你来的？也好，我这正需要人手。我得到线报，一伙江洋大盗近来要混入城中作案，你替我盘查下路人，不可放歹人入城。")
		map.__MapLayer:delayFunc(1, function()
			GuanFuJiXiongLayer:enterLayer(map, environment.currRole)
		end)
	end,
	
	["炼器"] = function(map, result, environment)
		local TeacherTask = require("app.models.task.teacherTask.teacherTask")
		TeacherTask:dealTangMenLainQiConditionAndResult(map, cenvironment.urrRole)
	end,
	
	["正在炼器"] = function(map, result, environment)
		RichPrint("main", "正在炼器不要打扰我")
	end,
	
	["歌功颂德"] = function(map, result, environment)
		local GeGongSongDe = require("app.views.layer.TeacherTaskLayer.TeacherTaskGame.GeGongSongDe")
		GeGongSongDe:enterLayer(map, environment.currRole)
	end,
	
	["学剑"] = function(map, result, environment)
		local TeacherTask = require("app.models.task.teacherTask.teacherTask")
		TeacherTask:dealLuoYueXueJianConditionAndResult(map, environment.currRole)
	end,
	
	["莲花落"] = function(map, result, environment)
		-----------------------------------------------------------------------------------------------------------
		-- @author GaoHanZheng
		-- @time 2017/06/14 17:33:30
		-- @desc 莲花落
		local RiChangQiTaoLayer = require("app.views.layer.TeacherTaskLayer.TeacherTaskGame.RiChangQiTaoLayer")
		RiChangQiTaoLayer:enterLayer(map, environment.currRole)
	end,
	
	["获得道具"] = function(map, result, environment)
		local player = User:getRole()
		local item = player:getOneItemByKey(result.arg2)
		if User:getRole():checkCanBuyThings(result.arg2, 1) then
			if item then
				player:addItemCount(result.arg2, 1)
				PopText("获得师门物品:" .. item.name .. "X 1")
				local TeacherTask = require("app.models.task.teacherTask.teacherTask")
				local receiveTask = TeacherTask:getTeacherTaskAttr("receiveTask")
				receiveTask.isGet = true
				map:removeRoomRole(receiveTask.roomId, environment.currRole.id)
				map.__MapLayer:setNeedRefreshMap()
				receiveTask.roomId = nil
				TeacherTask:setTeacherTaskAttr("receiveTask", receiveTask)
			end
		else
			PopText("背包空间不足")
		end
	end,
	
	["抓取"] = function(map, result, environment)
		local currRole = environment.currRole
		local player = User:getRole()
		if result.arg2 == 1 then
			local TeacherTask = require("app.models.task.teacherTask.teacherTask")
			TeacherTask:dealWuDuConditionAndResult(currRole, result.arg2, map)
		else
			local text = {
				[1] = "你左手拿着万灵谷专门抓取毒物五毒钩，右手拿着吸引毒物的奇香小瓶，小心翼翼地靠近毒物…",
				[2] = "毒物似乎被奇香小瓶内的气味吸引住了，一动不动..",
				[3] = "你抓住机会将五毒钩探出，伸向毒物！",
			}
			map.__MapLayer:setNPCTouchEnabled(true, function()
				RichPrint("main", "专心捕捉毒物")
			end)
			local MapRoleLayer = map.__MapLayer.ControllLayer:getLayer("MapRoleLayer")
			MapRoleLayer:statusButtonFunc(false, function()
				RichPrint("main", "专心捕捉毒物")
			end)
			MapRoleLayer:exitButtonFunc(false, function()
				RichPrint("main", "专心捕捉毒物")
			end)
			map.__MapLayer:setUnmoveRoom(true, function()
				RichPrint("main", "专心捕捉毒物")
			end)
			map._handle = map.__MapLayer:schedule(function()
				if #text > 0 then
					RichPrint("main", text[1])
					table.remove(text, 1)
				else
					RichPrint("main", "毒物受惊了！攻向了你！")
					local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
					local dialog = DialogALayer:getInstance()
					dialog:hide()
					dialog:show("HIR看起来" .. currRole:getName() .. "想与你决斗！")
					dialog:setBack(false)
					dialog:setButton1("迎战", function()
						Audio:playEffect("jiaoHu")
						if TANGJIAN_TEST_ENABLE then
							local role = currRole
							local currMap = map
							map.mapLayer = map.__MapLayer
							
							role:initNpcAttr() -- NPC状态初始化
							map:afterFightWithShaSi(player, role, function(winTeamId)
								-- 战斗胜利条件结果
								if winTeamId == 1 then
									PopText("你决斗战胜了" .. role:getName())
									
									-- 玩家操作默认
									role:setFlag("是否死亡", true)
									currMap:dowithRoleOperation({
										operation = "杀死",
										result = "成功",
										player = player,
										currRole = role,
										currMap = currMap,
										currRoomId = map.mapLayer._currRoom.id
									})
									currMap:doConditionAndResult(role.conditionAndResults,
									{
										conditionType = "杀死",
										result = "成功",
										currRole = role,
										currRoomId = map.mapLayer._currRoom.id,
										mapLayer = map.mapLayer
									})
									local TeacherTask = require("app.models.task.teacherTask.teacherTask")
									TeacherTask:dealDuelConditionAndResult(true, role, map)
									currMap:doRoomConditionAndResult(map.mapLayer._currRoom.id) -- 刷新房间条件结果
									map.__MapLayer:delayRefreshMap()
								elseif winTeamId == 2 then
									PopText("你被" .. role:getName() .. "打败了")
									
									if User:getRole():getFlag("佣兵模式") == "开启" then
										currMap:doConditionAndResult(role.conditionAndResults,
										{
											conditionType = "杀死",
											result = "失败",
											currRole = role,
											currRoomId = map.mapLayer._currRoom.id,
											mapLayer = map.mapLayer
										})
										currMap:doRoomConditionAndResult(map.mapLayer._currRoom.id)-- 刷新房间条件结果
									else
										map.__MapLayer.TotalMapBtn_IsInit = false
										map.__MapLayer:quit()
									end
								else
								end
								MapRoleLayer:exitButtonFunc(true)
								MapRoleLayer:statusButtonFunc(true)
								map.__MapLayer:setUnmoveRoom(false)
								map.__MapLayer:setNPCTouchEnabled(false)
							end)
						else
							
						end
					end)
					dialog:setButton2()
					map.__MapLayer:unschedule(map._handle)
				end
			end, 1)
		end
	end,
	
	["架起"] = function(map, result, environment)
		environment.currRole.canUse1 = false
		environment.currRole.canUse2 = true
		environment.currRole.canUse3 = false
		environment.currRole.canUse4 = false
		map.__MapLayer:setNeedRefreshMap()
		local TeacherTask = require("app.models.task.teacherTask.teacherTask")
		local receiveTask = TeacherTask:getTeacherTaskAttr("receiveTask")
		receiveTask.isdo = "架起"
		TeacherTask:setTeacherTaskAttr("receiveTask", receiveTask)
		RichPrint("main", "你把铁锅架起，准备开始煮粥。")
	end,
	
	["注入"] = function(map, result, environment)
		if User:getRole():getItem("shimenwupin31") then
			environment.currRole.canUse1 = false
			environment.currRole.canUse2 = false
			environment.currRole.canUse3 = true
			environment.currRole.canUse4 = false
			User:getRole():addItemCount("shimenwupin31", - 1)
			local TeacherTask = require("app.models.task.teacherTask.teacherTask")
			local receiveTask = TeacherTask:getTeacherTaskAttr("receiveTask")
			receiveTask.isdo = "注入"
			TeacherTask:setTeacherTaskAttr("receiveTask", receiveTask)
			RichPrint("main", "把从师门带来的大米洗净倒入铁锅里。")
		else
			RichPrint("main", "你身上没有东西可以放进去。")
		end
		map.__MapLayer:setNeedRefreshMap()
	end,
	
	["接头"] = function(map, result, environment)
		local TeacherTask = require("app.models.task.teacherTask.teacherTask")
		TeacherTask:dealQuanZhenJieTouConditionAndResult(map, environment.currRole)
	end,
	
	-- ["师门交谈"] = function(map, result, environment)
	-- 	local TeacherTask = require("app.models.task.teacherTask.teacherTask")
	-- 	TeacherTask:dealQuanZhenJieTouJiaoTan(map, environment.currRole)
	-- end,
	
	["师门送礼"] = function(map, result, environment)
		local TeacherTask = require("app.models.task.teacherTask.teacherTask")
		TeacherTask:dealQuanZhenJieTouSongLi(map, environment.currRole)
	end,
	
	["煮粥"] = function(map, result, environment)
		environment.currRole.canUse3 = false
		environment.currRole.canUse4 = true
		local TeacherTask = require("app.models.task.teacherTask.teacherTask")
		TeacherTask:dealEMeiZhuZhouConditionAndResult(map, environment.currRole)
		map.__MapLayer:setNeedRefreshMap()
	end,
	
	["正在煮粥"] = function(map, result, environment)
		RichPrint("main", "正在煮粥")
	end,
	
	["赠粥"] = function(map, result, environment)
		local TeacherTask = require("app.models.task.teacherTask.teacherTask")
		TeacherTask:dealEMeiZengZhou(map, environment.currRole)
	end,
	
	
}


local function createTeacherTaskPNC(map, tag)
	local mapId = map.id
	-- local function deleteQuanZhenLanJieNPC(roomId)
	-- 	if type(roomId) ~= "string" then
	-- 		return
	-- 	end
	-- 	local list = Helper:getDef(map:getRoomRoleList(roomId),{})
	-- 	for k,v in pairs(list) do 
	-- 		local role = map:getRole(v)
	-- 		if role.type == "role" then
	-- 			if role.baseId == "quanzhenshimenrenwu1" then
	-- 				map:removeRoomRole(roomId,role.id)
	-- 			end
	-- 		end
	-- 	end
	-- end
	-- for k,v in pairs(map.room) do 
	-- 	deleteQuanZhenLanJieNPC(v.id)
	-- end
	-- print("-----------------------------------------",tag)
	local TeacherTask  = require("app.models.task.teacherTask.teacherTask")
	local receiveTask = TeacherTask:getTeacherTaskAttr("receiveTask")
	if not receiveTask or receiveTask == 0 then
		-- print("创建师门任务NPC返回1")
		return
	end
	-- print(">>>>>>>>>>>",type(TeacherTask:getTeacherTaskAttr("isAppoint")))
	if type(TeacherTask:getTeacherTaskAttr("isAppoint")) == "table"  then--已经指派的任务不能手动完成
		-- print("创建师门任务NPC返回2")
		return
	end
	if TeacherTask:getTeacherTaskAttr("isComplete") == "Y" then
		-- print("任务已经完成，未领取奖励")
		return
	end
	if receiveTask.mapId ~= mapId then
		if receiveTask.jietouMapId ~= nil then
			if receiveTask.jietouMapId ~= mapId then
				return
			end
		else
			-- print("创建师门任务NPC返回3")
			return
		end
	else
		--[[在当前副本冷却中接取任务需要创建相关NPC]]
		if tag == 2 and receiveTask.hasCreate == true then
			-- print("===============================:已经创建了，不需要往下走")
			return
		end
	end
	if receiveTask.taskType == 0 then

	elseif receiveTask.taskType == 1 or receiveTask.taskType == 2 or receiveTask.taskType == 3 then
		local overTime = TeacherTask:getTaskOverTime()
		-- local npcId = tostring(receiveTask.npcId)..tostring(Helper:getOnlyId())
		local role = {}
		if receiveTask.taskType == 1 then
			-- print("判断师门任务类型为1")
			 if not TeacherTask:checkRoleIsInRoom(map,receiveTask.roomId,receiveTask.npcId) then
			 	-- print("检查目的房间中没有目的NPC")
				local basenpc = TeacherTask:getNPCBaseList(receiveTask.npcBaseId)
				for k ,v in pairs(basenpc) do
					role[k] = v
				end
				role.id = receiveTask.npcId
				role.baseId = receiveTask.npcBaseId
				role.canKill = false
				role.type = "role"
				role.id = receiveTask.npcId
				-- Helper:print_lua_table(role)
				map:createRole(role)
				role = map:getRole(role.id)
				-- print("创建师门任务NPC",receiveTask.taskType,receiveTask.roomId,receiveTask.npcId)
			else
				-- print("师门任务NPC>>>>",receiveTask.taskType,receiveTask.npcId,">>已经存在")
			-- map:createRole({id =receiveTask.npcId ,canKill = false,type = "role",name = receiveTask.NPCName,baseId = receiveTask.npcBaseId})
			end
		elseif receiveTask.taskType == 2 then
			PopText(2)
			if not TeacherTask:checkRoleIsInRoom(map,receiveTask.roomId,receiveTask.npcId) then
				local basenpc = TeacherTask:getNPCBaseList(receiveTask.npcBaseId)
				for k ,v in pairs(basenpc) do
					role[k] = v
				end
				role.id = receiveTask.npcId
				role.baseId = receiveTask.npcBaseId
				-- role.canKill = true
				role.type = "role"
				role.id = receiveTask.npcId
				role.canPresent = true
				role.receivePresent = receiveTask.itemId
				Helper:print_lua_table(role)
				map:createRole(role)
				role = map:getRole(role.id)
				-- print("创建师门任务NPC",receiveTask.taskType,receiveTask.roomId,receiveTask.npcId)
			else
				-- print("师门任务NPC>>>>",receiveTask.taskType,receiveTask.npcId,">>已经存在")
				-- map:createRole({id =receiveTask.npcId ,canKill = true,canPresent = true, receivePresent = receiveTask.itemId,type = "role",name = receiveTask.NPCName,baseId = receiveTask.npcBaseId})
			end
		elseif receiveTask.taskType == 3 then
			PopText(3)
			if not TeacherTask:checkRoleIsInRoom(map,receiveTask.roomId,receiveTask.npcId) then
				local basenpc = TeacherTask:getNPCBaseList(receiveTask.npcBaseId)
				for k ,v in pairs(basenpc) do
					role[k] = v
				end
				role.id = receiveTask.npcId
				role.baseId = receiveTask.npcBaseId
				-- role.canKill = true
				role.type = "role"
				role.id = receiveTask.npcId
				map:createRole(role)
				role = map:getRole(role.id)
				-- print("创建师门任务NPC",receiveTask.taskType,receiveTask.roomId,receiveTask.npcId)
			else
				-- print("师门任务NPC>>>>",receiveTask.taskType,receiveTask.npcId,">>已经存在")
				-- map:createRole({id =receiveTask.npcId ,canKill = true,type = "role",name = receiveTask.NPCName,baseId = receiveTask.npcBaseId})
			end
		end
		local roomId = receiveTask.roomId
		map:InSertTaskToDelayTasks(receiveTask.npcId,overTime+GetTime(),function()
			-- print("receiveTask.roomId:",roomId,"receiveTask.npcId:",receiveTask.npcId)
			map:removeRoomRole(roomId,receiveTask.npcId)--任务过期，或者指派任务，放弃任务删除生成的
		end,"师门任务",receiveTask.taskOId)
		-- print("receiveTask.roomId:",receiveTask.roomId,"receiveTask.npcId:",receiveTask.npcId)
		map:addRoomRole(receiveTask.roomId,receiveTask.npcId,true)
	elseif receiveTask.taskType == 4 then
		TeacherTask:createTeacherTaskPNC(map,mapId)
	end
	receiveTask.hasCreate = true
	TeacherTask:setTeacherTaskAttr("receiveTask",receiveTask)
end

--@desc: 根据
--@author:Liang SongQiang
--@time:2017-12-11 18:11:24
--@map: [src.app.models.map.BaseMap#BaseMap]
function TeacherTask:entryMap(map)
	local role = User:getRole()
	local currTime = GetTime()
	local leaveTime = role:getFlag(map.id)

	if leaveTime and leaveTime ~= 0 then
		local useTime = currTime - leaveTime
		-- 地图刷新时间设置为5分钟
		if useTime >= MAP_REFRESH_INTERVAL then
			createTeacherTaskPNC(map,1)
		else
			createTeacherTaskPNC(map,2)
		end
	else
		createTeacherTaskPNC(map,3)
	end
end


return TeacherTask000000000000000