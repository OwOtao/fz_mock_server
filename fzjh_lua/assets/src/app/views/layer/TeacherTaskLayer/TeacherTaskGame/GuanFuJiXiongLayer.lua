local GuanFuJiXiongLayer = class("GuanFuJiXiongLayer", cc.Layer)
local TeacherTask  = require("app.models.task.teacherTask.teacherTask")
function GuanFuJiXiongLayer:create()
	local p = GuanFuJiXiongLayer:new()
	p:init()
	return p
end
function GuanFuJiXiongLayer:init()
	local UI= require("Layer/TeacherTask/TeacherTaskGame/GuanFuJiXiongUI.lua").create()['root']
	UI:addTo(self)
	Helper:convertUIByParent(self) -- 获得所有子节点

end
function GuanFuJiXiongLayer:enterLayer(map,role)
	local layer = self:getInstance()
	layer:show()
	layer:initLayer(map,role)
end
function GuanFuJiXiongLayer:initLayer(map,role)
	self.count = 0
	self.Text_dsc:setString("")
	self:delayFunc(1.5,function()
		PopText("开始")
		self._handle = self:schedule(function()
			self:setButtonSAndDsc(map,role)
		end,3.0)
	end)
end
function GuanFuJiXiongLayer:setButtonSAndDsc(map,role)
	local text,num = self:getDsc()
	self.Text_dsc:setString(text)
	if num == 1 then
		self.Button_panwen:releaseFunc(function()
			RichPrint("main","RED可疑人物出现！")
			self:pauseSchedulerAndActions(self._handle)
			self:delayFunc(1.0,function()
				self:attackFunc(map,role)
			end)
			self.Button_panwen:releaseFunc(function()

			end)
		end)
	else
		self.Button_panwen:releaseFunc(function()
			RichPrint("main","仔细盘查了一番，一无所获，白费功夫，不得不放行，被拦住的人敢怒不敢言，只能愤愤地走了。")
			self.Text_dsc:setString("")
			self.Button_panwen:releaseFunc(function()
				PopText("现在还没有人经过")
			end)
			self.Button_fangxing:releaseFunc(function()
				PopText("现在还没有人经过")
			end)
		end)
	end
	self.Button_fangxing:releaseFunc(function()
		RichPrint("main","YEL你自己观察一番，感觉此人没有嫌疑便让其通过了。")
		self.Text_dsc:setString("")
		self.Button_fangxing:releaseFunc(function()
			PopText("现在还没有人经过")
		end)
		self.Button_panwen:releaseFunc(function()
			PopText("现在还没有人经过")
		end)
	end)
end
function GuanFuJiXiongLayer:getDsc()
	local weight = {[1] = 10,[2] = 90}
	local text = {
		[1] = "一个中年人正在走入城门，他一副远行归来的打扮，举止不疾不徐。",
		[2] = "一个精壮汉子正在走入城门，他袒着上身，露出黝黑的皮肤，看起来像是做苦力活的。",
		[3] = "一个农妇正在走入城门，她肩挑手提各种杂货，步履沉重。",
		[4] = "一个年轻士子正在走入城门，他迈着方步、摇着扇子，东张西望，一副公子哥的做派。",
		[5] = "一个中年人正在走入城门，他一副商贾打扮，举止不疾不徐，神情平静。",
		[6] = "一个农夫正在走入城门，他衣衫破旧，背着一个巨大的背篓，应该是来赶集的。",
		[7] = "一个老头正在走入城门，他一副算命先生的打扮，举止不疾不徐。",
		[8] = "一个和尚正在走入城门，他一副法相庄严、得道高僧的模样，举止不疾不徐。"
	}
	local number = Helper:RandomByWeight(weight)
	local rtext = text[math.random(1,#text)]
	if number == 1 then
		rtext = rtext.."神情中却闪过一丝不易察觉的慌乱。"
	end
	print("返回信息:",rtext,number)
	return rtext,number
end
function GuanFuJiXiongLayer:createNPC(map)
	local receiveTask = TeacherTask:getTeacherTaskAttr("receiveTask")
	local role = {}
	local roleId = receiveTask.npcId[self.count+2]
	local basenpc = TeacherTask:getNPCBaseList(receiveTask.npcBaseId[2])
	-- basenpc = TeacherTask:replaceRoleAttr(basenpc)
	for k ,v in pairs(basenpc) do
		role[k] = v
	end
	role.id = roleId
	role.baseId = receiveTask.npcBaseId[2]
	role.canKill = true
	role.type = "role"
	map:createRole(role)
	map:addRoomRole(receiveTask.roomId,roleId,true)
	role = map:getRole(role.id)
	return role,receiveTask.roomId
end
function GuanFuJiXiongLayer:attackFunc(map,npc)
	local currRole,roomId = self:createNPC(map)
	currRole = map:getRole(currRole.id)
	-- currRole.qi = currRole.qiMax
	currRole:setAttr("qi",currRole:getAttr("qiMax"))
	local player = User:getRole()
	local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
	local dialog = DialogALayer:getInstance()
	dialog:hide()
	dialog:show("HIR看起来"..currRole.name.."想与你决斗！")
	dialog:setBack(false)
	dialog:setButton1("迎战", function()
		local role = currRole
		local currMap = map
		self.mapLayer = map.__MapLayer

		currMap:doConditionAndResult(role.conditionAndResults,
            {
                operation = "切磋",
                currRole = role,
                currRoomId = self.mapLayer._currRoom.id,
                mapLayer = self.mapLayer
            })

		role:initNpcAttr() -- NPC状态初始化

        currMap:afterFightWithQieCuo(player, role, function(winTeamId)
            -- 战斗胜利条件结果
            print("winTeamId>>>>>>>>>>>>>>>>>>>>>:",winTeamId)
            if winTeamId == 1 then
                -- PopText("你战胜了" .. role:getName())
                currMap:doConditionAndResult(role.conditionAndResults,
                    {
                        conditionType = "切磋",
                        result = "成功",
                        currRole = role,
                        currRoomId = self.mapLayer._currRoom.id,
                        mapLayer = self.mapLayer
                    })

                self.mapLayer:delayRefreshMap()
                -- 刷新房间条件结果
                self:dealDuelResult(map,role,npc,true)
				map:doRoomConditionAndResult(roomId)
            else
                -- PopText("你被" .. role:getName() .. "打趴在地")
                currMap:doConditionAndResult(role.conditionAndResults,
                    {
                        conditionType = "切磋",
                        result = "失败",
                        currRole = role,
                        currRoomId = self.mapLayer._currRoom.id,
                        mapLayer = self.mapLayer
                    })
                self:dealDuelResult(map,role,npc,false)
                self.mapLayer:delayRefreshMap()
                -- 刷新房间条件结果
                map:doRoomConditionAndResult(roomId)
            end
        end)
	end)
	dialog:setButton2()
end
function GuanFuJiXiongLayer:dealDuelResult(map,role,npc,isWin)
	local receiveTask = TeacherTask:getTeacherTaskAttr("receiveTask")
	if isWin == true then
		self.count = self.count +1
		RichPrint("main","你成功得抓住了这名可疑人士，在你的盘查之下，此人确是任务目标。")
		self.Button_panwen:releaseFunc(function()
			PopText("现在还没有人经过")
		end)
		self.Text_dsc:setString("")
		if self.count >= 2 then
			map:removeRoomRole(receiveTask.roomId,role.id)
			map:removeRoomRole(receiveTask.roomId,receiveTask.npcId[1])
			receiveTask.roomId = {}
			receiveTask.jiangli = 2
			TeacherTask:setTeacherTaskAttr("receiveTask",receiveTask)
			TeacherTask:setTeacherTaskAttr("isComplete","Y")
			self:unschedule(self._handle)
			self:hide()
		else
			RichPrint("main","HIY抓到了一个可疑人物，应该还有同伙，继续盘查。")
			map:removeRoomRole(receiveTask.roomId,role.id)
			self:resumeSchedulerAndActions(self._handle)
		end
	else
		receiveTask.jiangli = 1
		RichPrint("main","RED可疑人士混入人群中消失不见，缉捕计划落空了。")
		map:removeRoomRole(receiveTask.roomId,role.id)
		map:removeRoomRole(receiveTask.roomId,receiveTask.npcId[1])
		receiveTask.roomId = {}
		TeacherTask:setTeacherTaskAttr("receiveTask",receiveTask)
		TeacherTask:setTeacherTaskAttr("isComplete","Y")
		self:unschedule(self._handle)
		self:hide()
		-- self:resumeSchedulerAndActions(self._handle)
	end
	map.__MapLayer:setNeedRefreshMap()
end
Helper:classDefNodeGetInstance(GuanFuJiXiongLayer)
return GuanFuJiXiongLayer
00000000000