
local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
-- local Map = require("app.models.map.Map")
local Resource = require("app.Resource")
-- local User = require("app.models.user.User")

local ZhuXianUI = class("ZhuXianUI", cc.Layer)

function ZhuXianUI:create()
	local p = ZhuXianUI:new()
	p:init()
	return p
end

function ZhuXianUI:init()
	self._round = require("Layer/TaskUI/ZhuXianUI.lua").create()['root']
	self._round:addTo(self)

	Helper:convertUI(self) -- 获得所有子节点
end

function ZhuXianUI:hide()
	local actionTag = self:getActionTagByName("zhuxian")
	self:stopActionByTag(actionTag)
	local action = cc.Sequence:create(
			cc.Spawn:create(
				cc.MoveTo:create(0.2, cc.p(0,100)),
				cc.FadeOut:create(0.2)
				),
			cc.CallFunc:create(
				function()
					self:setVisible(false)
				end)
		)
	action:setTag(actionTag)
	self:runAction(action)
end

function ZhuXianUI:show(task,taskSystem)
	self.__taskSystem = taskSystem
	self:setVisible(true)
	self:setTask(task)
	self:setOpacity(0)
	local actionTag = self:getActionTagByName("zhuxian")
	self:stopActionByTag(actionTag)
	self:move(cc.p(0,100))
	local action = cc.Sequence:create(
			cc.Spawn:create(
				cc.MoveTo:create(0.2, cc.p(0,0)),
				cc.FadeIn:create(0.2)
				)
		)
	action:setTag(actionTag)
	self:runAction(action)
end

function ZhuXianUI:initRichText()
	local x, y = self.Text_desc:getPosition()
	local size = self.Text_desc:getContentSize()

	if self.RichText_print then
		self.RichText_print:removeFromParent()
		self.RichText_print = nil
	end

	local richTextScroll = ExtRichTextScroll:create()
   	self.Text_desc:getParent():addChild(richTextScroll)
	richTextScroll:setAnchorPoint(0.5000, 0.5000)
   	richTextScroll:move(cc.p(x, y))
   	richTextScroll:setSize(size)
   	richTextScroll:setDirection(kCCScrollViewDirectionVertical)
   	richTextScroll:getRichText():setVerticalSpace(5)
   	self.RichText_print = richTextScroll
   	self.Text_desc:setVisible(false)
end

local textColor = cc.c3b(255, 255, 255)
function ZhuXianUI:print(str)
	self:initRichText()
	self.RichText_print:pushBackText(str, textColor, 255, Resource:getFontPath("default"), 42)
end

function ZhuXianUI:setTask(task)
	if not task or not task.zhuXianCondition then
		assert(nil, "ZhuXianUI:setTask(task)")
	end
	local condition = task.zhuXianCondition
	local role = User:getRole()

	local LiLianTaskHelper = require("app.models.task.LiLianTaskHelper")

	-- 设置当前主线任务地图标签

	--@desc 预防随机到不是选择列表中的副本。
	local mapId = task.mapId
	if mapId == nil then
		if task.defaultMapId == nil then
			local mapIdList = Map:getCompletedMapList(function (map_id)
				if map_id == "fb37" then
					return true
				end
	
				return false
			end)
	
			mapId = mapIdList[math.random(1,#mapIdList)]
		else
			mapId = task.defaultMapId
		end
	end

	local map = Map:getMapById(mapId)
	task.mapId = mapId

	if PRINT_MODE == 1 then
		print("Map.id = "..tostring(map.id))
	end
	local roleTask = role:getTask(task.id)
	local dCount = roleTask.dCount == nil and 0 or roleTask.dCount
	local zCount = roleTask.zCount == nil and 0 or roleTask.zCount

	if task.type == "主线任务" then
		self.Text_title:setString("任务-"..task.name)
	else
		self.Text_title:setString(task.type.."-"..task.name)
	end
	
	--江湖历练任务 单独处理
	if task.id == "task15" then
		--历练中dCount完成次数作为任务等级，最高为5
		local taskIndex = Helper:getRange(dCount, 1, 5)


		-- if dCount > 5 then
		-- 	dCount = 5
		-- 	taskIndex = dCount
		-- elseif dCount < 1 then
		-- 	taskIndex =1
		-- else
		-- 	taskIndex = dCount
		-- end
		local taskTypeCount = 4
		if Map:getMapState("fb25") == MAP_STATE.COMPLETE then
			taskTypeCount = 5
			taskIndex = taskIndex + 5
		end

		local taskIdByType =
		{
			["江湖送信"] = "task19",
			["缉拿恶徒"] = "task20",
			["南阳匪乱"] = "task17",
			["飞贼横行"] = "task16",
			["古寺失窃"] = "task21"
		}

		local taskIndexById =
		{
			task19 = 1,
			task20 = 2,
			task17 = 3,
			task16 = 4,
			task21 = 5
		}

		local mytaskid
		local isTask = role:getFlag("历练")
		local hasTask = false

		if isTask ~= nil and isTask ~= "nil" and isTask ~= 0 then
			local savedNeedTime = role:getFlag(isTask)
			local savedTaskIndex = taskIndexById[isTask]

			if savedNeedTime ~= nil and savedNeedTime ~= "nil" and savedNeedTime ~= 0 and savedTaskIndex ~= nil then
				hasTask = true
				mytaskid = isTask
				self.needTime = savedNeedTime
				self.num = savedTaskIndex
				self.taskType = role:getFlag("历练随机任务名")
			end
		end

		local configVersion
		if hasTask then
			configVersion = LiLianTaskHelper:getRoleTaskConfigVersion(roleTask)
		else
			local isActiveRoundState = roleTask.state == TASK_STATE_ACCEPT or roleTask.state == TASK_STATE_TO_SUBMIT or roleTask.state == TASK_STATE_DISPATCH
			if roleTask.aConfVer == nil and isActiveRoundState then
				roleTask.aConfVer = LiLianTaskHelper:getRoleTaskConfigVersion(roleTask)
			elseif roleTask.aConfVer == nil or isActiveRoundState == false then
				roleTask.aConfVer = LiLianTaskHelper:getConfigVersionByTime(GetTime())
			end
			configVersion = roleTask.aConfVer
		end

		local liLianTask = LiLianTaskHelper:getExperienceTaskConfigInfo(taskIndex, configVersion)
		local taskTypeList = string.split(liLianTask.tasktype, ";")
		local needTimeList = string.split(liLianTask.needtime, ";")

		if hasTask and (self.taskType == nil or self.taskType == "nil" or self.taskType == 0) then
			self.taskType = taskTypeList[self.num]
		end

		if hasTask == false then
			local num = math.random(1, taskTypeCount)
			local taskType = taskTypeList[num]
			local needTimeRange = string.split(needTimeList[num], ",")
			local needTime = math.random(tonumber(needTimeRange[1]), tonumber(needTimeRange[2]))

			self.taskType = taskType
			self.needTime = needTime
			self.num = num
			mytaskid = taskIdByType[taskType]
		end

		self.last_dCount = role:getFlag("历练随机任务已完成次数")

		local descListString = liLianTask.jobtext 
		local descList = string.split(descListString, ";")
		local desc = descList[self.num]
		self:print(desc)
        
		role:setFlag("历练随机任务名",self.taskType)
        role:setFlag("历练",mytaskid)
		role:setFlag( mytaskid ,self.needTime)
		self.Text_dayCount:setString("完成"..self.taskType.."任务："..(self.last_dCount).."/"..self.needTime)
		
		self.Button_start:setVisible(false)
		self.Button_GO:setVisible(true)
		self.Text_GO:setString("更换任务")
		self.Button_GO:setPosition(540.0000, 750.0000)
		self.Button_cancel:setPosition(540.0000, 600.0000)
		self.Text_cancel:setString("返回")
		self.Text_totlalCount:setString("本周获得奖励"..dCount.."/5")
		self.Text_totlalCount:setColor(cc.c3b(219, 57, 57))
		self.Text_BoxCount:setVisible(false)
		self.Text_BoxCount:setString("完成"..self.needTime.."次"..self.taskType.."可获得奖励（每周限5个）")
		self.Text_GO:setTextColor(task.zhuXianCondition.buttonColor)
		self._currTask = task
		self._roomId = {}
		return
	end

	local desc
	local descList =  task.desc
	local texttimelist =Helper:getDef(task.texttime,{})
	-- if #texttimelist == 2 then

	-- elseif #texttimelist == 3 then
	-- end
	
	if MapIsEmpty(texttimelist) then
		desc =  descList[1]
	else
		for i,v in pairs(texttimelist) do
			if dCount >= tonumber(v )  then
				 desc =  descList[i+1]
			else
				desc =  descList[1]
			end 
		end 
	end


	local roomId 
	local roomName
	if condition.mapRoom[map.id] ~= nil then
		roomId = assert(condition.mapRoom[map.id].roomId)
		roomName = map:getRoomNameById(roomId)
		desc = string.gsub(desc, "$X", map.name)
		desc = string.gsub(desc, "$D", roomName)
	end
	if roomName == nil then
		roomName = ""
	end
	self.goRoomName=roomName
	self:print(desc)
	----飞贼任务
	if task.id == "task16" then
		self.Text_BoxCount:setVisible(false)
		self.Text_GO:setString("去"..roomName)
		self.Button_start:setVisible(true)
		self.Button_GO:setVisible(true)
		self.Button_GO:setPosition(540.0000, 600.0000)
		self.Button_cancel:setPosition(540.0000, 450.0000)
		self.Text_totlalCount:setString("今日获得包裹"..role:getDayFlag("飞贼任务奖励").."/3")
		self.Text_totlalCount:setColor(cc.c3b(219, 57, 57))
		self._roomId = roomId
	--江湖送信任务
	elseif task.id == "task19" then
		self.Text_BoxCount:setVisible(false)
		self.Button_start:setVisible(true)
		self.Button_cancel:setPosition(540.0000, 600.0000)
		local items  = User:getRole():getItemsWithItemId(	role:getFlag("主动任务物品"))
		if MapIsEmpty(items) == true then
			self.Button_GO:setVisible(false)
		else
			self.Button_GO:setVisible(true)
			self.Button_cancel:setPosition(540.0000, 450.0000)
			self.Button_GO:setPosition(540.0000, 600.0000)
		end
		self.Text_GO:setString("更换任务")
			self.Text_totlalCount:setString("本日获得宝箱奖励"..role:getDayFlag("信使任务奖励").."/3")
			self.Text_totlalCount:setColor(cc.c3b(219, 57, 57))
			self._roomId = {}
	--缉拿恶徒任务
	elseif task.id == "task20" then
		self.Text_BoxCount:setVisible(false)
		self.Button_start:setVisible(true)
		self.Button_cancel:setPosition(540.0000, 600.0000)
		local items  = User:getRole():getItemsWithItemId(	role:getFlag("主动任务物品"))
		if MapIsEmpty(items) == true then
			self.Button_GO:setVisible(false)
		else
			self.Button_GO:setVisible(true)
			self.Button_cancel:setPosition(540.0000, 450.0000)
			self.Button_GO:setPosition(540.0000, 600.0000)
		end
		self.Text_GO:setString("更换任务")
			self.Text_totlalCount:setString("本日获得宝箱奖励"..role:getDayFlag("缉拿任务奖励").."/3")
			self.Text_totlalCount:setColor(cc.c3b(219, 57, 57))
			self._roomId = {}
	--限时主线任务 腊八施粥
	elseif task.id == "task18" then
		self.Button_start:setVisible(true)
		self.Button_cancel:setPosition(540.0000, 600.0000)
		self.Button_GO:setVisible(false)
		self.Text_totlalCount:setString("总完成次数"..zCount.." 次")
		self.Text_BoxCount:setVisible(true)
		self.Text_BoxCount:setString("本任务只能在2018年1月23日至2018年2月5日内进行。")
		self.Text_totlalCount:setColor(cc.c3b(219, 57, 57))
		self._roomId = {}
	else
		self.Text_BoxCount:setVisible(false)
		self.Text_GO:setString("去"..roomName)
		self.Button_GO:setVisible(true)
		self.Button_start:setVisible(true)
		self.Button_GO:setPosition(540.0000, 600.0000)
		self.Button_cancel:setPosition(540.0000, 450.0000)
		self.Text_totlalCount:setString("总完成次数"..zCount.." 次")
		self.Text_totlalCount:setColor(cc.c3b(48, 168, 53))
		self._roomId = roomId
	end
	self.Text_cancel:setString("取消任务")
	self.Text_dayCount:setString("今日完成次数 "..dCount.." 次")
	-- self.Text_GO:setString("去"..roomName)
	self.Text_GO:setTextColor(task.zhuXianCondition.buttonColor)
	self._currTask = task
	-- self._roomId = roomId
end

function ZhuXianUI:setButtonStart(task)
	self.Button_start:releaseFunc(function()
		local id = task.id
		if id =="task15" or  id =="task19" or id =="task20" or id =="task18"  then
			task:setSpecialTask()
			self:hide()
		else
			task:setSpecialTask()
			MainControllLayer:pushLayer("SelectMapLayer")
			local selectMapLayer = MainControllLayer:getLayer("SelectMapLayer")
			selectMapLayer:setMap(task.mapId)
			self:setVisible(false)
		end
    end)
end

function ZhuXianUI:setButtonGO(id)
	if not self._roomId then
		return
	end
	self.Button_GO:releaseFunc(function()
		if id =="task15" then
			if GetTime() - User:getRole():getFlag("历练更换刷新CD") < 3600 * 24 then
				PopText("每隔24小时只可更换一次历练任务")
				return
			end
		
			local dialog = DialogALayer:getInstance()
			dialog:show("确定更换当前历练任务吗？")
			dialog:setButton1("是", function()
					local task = self._currTask
					task:cancelTask()
					self:setVisible(false)
				end)
			dialog:setButton2("否", function()
					if PRINT_MODE == 1 then
						print("不取消任务")
					end
				end)
		elseif	id =="task19" then
			if User:getRole():getFlag("更换人物刷新CD"..id)==0 then
			else	
				if DEBUG_MODE == 1 then
				else
					if GetTime() - User:getRole():getFlag("更换人物刷新CD"..id) < 60*5 then
						PopText("五分钟才能使用一次更换任务")
						return
					end 
				end
			end
			if User:getRole():getFlag("主动任务物品") == 0 or  User:getRole():getFlag("主动任务物品") == "nil" then
				PopText("没有道具不能更换任务")
				return
			end
			local dialog = DialogALayer:getInstance()
			dialog:show("确定更换当前任务吗？")
			dialog:setButton1("是", function()
					local task = self._currTask
					task:changeTaskNPC()
					self:setVisible(false)
				end)
			dialog:setButton2("否", function()
					if PRINT_MODE == 1 then
						print("不取消任务")
					end
				end)
		elseif	id == "task20" then
			if User:getRole():getFlag("更换人物刷新CD"..id)==0 then
			else	
				if DEBUG_MODE == 1 then
				else
					if GetTime() - User:getRole():getFlag("更换人物刷新CD"..id) <  60*5 then
						PopText("五分钟才能使用一次更换任务")
						return
					end 
				end
			end
			if User:getRole():getFlag("主动任务物品") == 0  or  User:getRole():getFlag("主动任务物品") == "nil" then
				PopText("没有道具不能更换任务")
				return
			end
			local dialog = DialogALayer:getInstance()
			dialog:show("确定更换当前任务吗？")
			dialog:setButton1("是", function()
					local task = self._currTask
					task:changeTaskNPC()
					self:setVisible(false)
				end)
			dialog:setButton2("否", function()
					if PRINT_MODE == 1 then
						print("不取消任务")
					end
				end)
			
		else
			local map = Map:getMapById(self._currTask.mapId)
			local text = "选择前往HIY"..map.name..self.goRoomName.."NOR的方式。\n（选择遁地方式前往，会偶然出现意想不到的结果，请谨慎使用。）"
			local backClick = true
			local callfunc = function(result, failureState)
				if result == true then
					self:setVisible(false)
				end
			end
			
			local JumpMapStylePrensenter = require("app.presenters.JumpMapStyle.JumpMapStylePrensenter"):create()
            JumpMapStylePrensenter:showLayer(User:getRole(), self._currTask.mapId, self._roomId, text, backClick, callfunc)
		end
	end)
end

function ZhuXianUI:setButtonCancel()
	self.Button_cancel:releaseFunc(function()
		local task = self._currTask
		if task.id == "task15" then		
			-- task:cancelTask()
			self:setVisible(false)
		else
		
			local dialog = DialogALayer:getInstance()
			dialog:show("确定取消吗？", "（放弃任务将消耗100碎银）")
			dialog:setButton1("是", function()
					local task = self._currTask
					self.__taskSystem:cancelZhuDongTask(task.id)
					self:setVisible(false)
				end)
			dialog:setButton2("否", function()
					if PRINT_MODE == 1 then
						print("不取消任务")
					end
				end)
				
			end
		end)
end

function ZhuXianUI:setBack()
	self.Panel_back:setTouchEnabled(true)
	self.Panel_back:releaseFunc(function()
		self:hide()
	end)
end

return ZhuXianUI
000