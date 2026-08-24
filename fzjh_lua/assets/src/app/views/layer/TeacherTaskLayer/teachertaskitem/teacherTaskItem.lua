local teacherTaskItem = {}
local TeacherTask  = require("app.models.task.teacherTask.teacherTask")
function teacherTaskItem:useSnakelet(func, dialog, layer,role)--幼蛇
	local receiveTask = TeacherTask:getTeacherTaskAttr("receiveTask")
	if receiveTask.taskType ~= 4 or role:getFamilyId() ~= "baituoshan" then
		role:addItemCount("shimenwupin29",0-role:getItemCount("shimenwupin29"))
		return
	end
	if layer and layer.ControllLayer ~= nil then
		local mapLayer = layer.ControllLayer:getLayer("MapLayer")
		if mapLayer._currMap.id ~= receiveTask.mapId then
			PopText("请前往指定地点牧蛇！")
			return
		end
		if mapLayer._currRoom.id ~= receiveTask.roomId then
			PopText("请前往指定地点牧蛇！")
			return
		end
		role:addItemCount("shimenwupin29",-1)
		role:addItemCount("shimenwupin30",1)
		RichPrint("main","放出幼蛇,2分钟之后可以收回")
		receiveTask.itemUseTime = GetTime()
		TeacherTask:setTeacherTaskAttr("receiveTask",receiveTask)
		if func then
			func()
		end
	else
		PopText("请前往指定地点牧蛇！")
	end
end
function teacherTaskItem:useLongZi(func,dialog,layer,role)
	local receiveTask = TeacherTask:getTeacherTaskAttr("receiveTask")
	if receiveTask.taskType ~= 4 or role:getFamilyId() ~= "baituoshan" then
		role:addItemCount("shimenwupin30",0-role:getItemCount("shimenwupin30"))
		return
	end
	if layer and layer.ControllLayer ~= nil then
		local mapLayer = layer.ControllLayer:getLayer("MapLayer")
		if mapLayer._currMap.id ~= receiveTask.mapId then
			PopText("请前往牧蛇的地方将蛇回收！")
			return
		end
		if mapLayer._currRoom.id ~= receiveTask.roomId then
			PopText("请前往牧蛇的地方将蛇回收！")
			return
		end
		if GetTime() - receiveTask.itemUseTime < 120 then
			PopText("难得出来一趟，让蛇再放风一会吧!")
			return 
		end
		if math.random(1,2) == 1 then--进入战斗，战斗胜利方可收回幼蛇
			TeacherTask:createBaiTuoShanSpecialNPC(mapLayer._currMap,mapLayer._currMap.id,mapLayer._currRoom.id)

			--战斗胜利后收回幼蛇
		else--收回幼蛇
			RichPrint("main","你小心翼翼地将幼蛇收回了笼中。")
			role:addItemCount("shimenwupin30",-1)
			local receiveTask = TeacherTask:getTeacherTaskAttr("receiveTask")
			receiveTask.roomId = {}
			receiveTask.mapId = {}
			receiveTask.jiangli = 2
			TeacherTask:setTeacherTaskAttr("receiveTask",receiveTask)
			TeacherTask:setTeacherTaskAttr("isComplete","Y")
		end
		if func then
			func()
		end
	else
		PopText("请前往牧蛇的地方将蛇回收！")
	end
end

function teacherTaskItem:useJunQingMiHan(dialog,func,layer,role)--军情密函
	local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
	local dialog = DialogALayer:getInstance()
	dialog:hide()
	dialog:show("确定要毁掉这封密函吗？")
	dialog:setBack(false)
	dialog:setButton1("销毁", function()
		role:addItemCount("shimenwupin32",-1)
		if func then
			func()
		end
		local ControllLayer = require("app.views.layer.ControllLayer")
		local controllLayer = ControllLayer:getInstance()
		local mapLayer = controllLayer:getLayer("MapLayer")
		TeacherTask:deleteRoleByBaseId(mapLayer._currMap,mapLayer._currRoom.id,"quanzhenshimenrenwu1")
		mapLayer:setNeedRefreshMap()
		PopText("元军高手见军情密函被你销毁,便放弃了对你的追杀")
	end)
	dialog:setButton2("取消", function()
		PopText("此等重要的物品怎能随便销毁。")
	end)
end
--黑木崖令
function teacherTaskItem:useHeiMuYaLing(dialog,role)
	print("使用黑木崖令")
	local receiveTask = TeacherTask:getTeacherTaskAttr("receiveTask")
	local tab = {
		["riyueshimenrenwu1"] = {
			[1] = "他现在应该躲在YEL$DNOR地图。",
			[2] = "他善于易容伪装，经常扮作一个老头子。",
			[3] = "他的妻女都死了，他自己身上应该带着伤。",
		},
		["riyueshimenrenwu2"] = {
			[1] = "她现在应该躲在YEL$DNOR地图。",
			[2] = "她善于易容伪装，经常扮作尼姑或者老太太。",
			[3] = "她喜欢小孩子，擅长用剑。",
		},
		["riyueshimenrenwu3"] = {
			[1] = "他现在应该躲在YEL$DNOR地图。",
			[2] = "他嗜酒如命，一日不可无酒。",
			[3] = "他拳脚功夫很不错。",
		},
	}
	if receiveTask.success == nil  or tab[receiveTask.success] == nil then
		return
	end
	local tmp = tab[receiveTask.success]


	-- local roomName = TeacherTask:getRoomName(receiveTask.roomId,receiveTask.mapId)
	-- print("roomName**********************************:",roomName,receiveTask.roomId,receiveTask.mapId)

	-- dsc = self:spliceTaskDsc(dsc,"$N",list.npcName)
	local map = User:getRole():getMapById(receiveTask.mapId)
	local dsc = TeacherTask:spliceTaskDsc(tmp[1],"$D",map.name)
	tmp[1] = dsc
	for i=1,#tmp do
		dialog:delayFunc(i / 2, function()
            RichPrint("main", tmp[i])
        end)
	end
	-- local list = tab["shimennpc008"]

	-- local random = receiveTask.tishinum
	-- if random == nil or random == 3  then
	-- 	random = 1 
	-- else
	-- 	random = random +1 
	-- end

	-- if random == 1 then
	-- 	local roomName = self:getRoomName(receiveTask.roomId,receiveTask.mapId)
	-- 	local map = User:getRole():getMapById(receiveTask.mapId)
	-- 	RichPrint("main",self:spliceTaskDsc(list[random],"$D",map.name..roomName))
	-- 	-- PopText()
	-- else
	-- 	-- PopText(list[random])
	-- 	RichPrint("main",list[random])
	-- end

	-- TeacherTask:setTeacherTaskAttr("receiveTask",receiveTask)
end
return teacherTaskItem
-- shimenwupin29	幼蛇
-- shimenwupin30	笼子
-- shimenwupin31	大袋大米
-- shimenwupin32	军情密函
-- shimenwupin33	黑木崖令
-- shimenwupin34	财物
-- shimenwupin35	船夫贡品
-- shimenwupin36	江湖贡品
0000000000000000