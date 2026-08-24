
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

	local taskres = require("script.others.Experiencetask")

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
		local tasklevel = Helper:getRange(dCount, 1, 5)


		-- if dCount > 5 then
		-- 	dCount = 5
		-- 	tasklevel = dCount
		-- elseif dCount < 1 then
		-- 	tasklevel =1
		-- else
		-- 	tasklevel = dCount
		-- end
		local num = math.random(1,4) 
		if Map:getMapState("fb25") == MAP_STATE.COMPLETE then
			num = math.random(1,5) 
			tasklevel = tasklevel + 5
		end

		

		local liLianTask = taskres["历练任务"]
		local taksTypeListString = liLianTask[""..tasklevel].tasktype 
		local taksTypeList = string.split(taksTypeListString, ";")
		local taskType = taksTypeList[num]
			
		local needTimeListString = liLianTask[""..tasklevel].needtime 
		local needTimeList = string.split(needTimeListString, ";")
		local needTimelist = string.split(needTimeList[num], ",")
		local needTime =  math.random(tonumber(needTimelist[1]),tonumber(needTimelist[2])) 



		local isTask = User:getRole():getFlag("历练")
		if isTask == "nil" or isTask == 0 then
			self.taskType = taskType
			self.needTime = needTime
			self.num = num
			isTask = "nil"
		end
		self.taskType = Helper:getDef(self.taskType, taskType)
		self.needTime = Helper:getDef(self.needTime, needTime)
		self.num = Helper:getDef(self.num, num)
		

		--获取随机任务的完成次数
		local mytaskid
		if self.taskType =="飞贼横行" then
			mytaskid ="task16"
		elseif self.taskType =="南阳匪乱" then
			mytaskid ="task17"
		elseif self.taskType =="江湖送信" then
			mytaskid ="task19"
		elseif self.taskType =="缉拿恶徒" then
			mytaskid ="task20"
		elseif self.taskType =="古寺失窃" then
			mytaskid ="task21"
		end
		
		self.last_dCount = User:getRole():getFlag("历练随机任务已完成次数")	
		if User:getRole():getFlag(isTask ) ~= 0 and isTask ~= "nil" then
			mytaskid = isTask
			
			self.needTime  = User:getRole():getFlag(isTask )  
			local randTask = Helper:getDef(role:getTask(mytaskid),{}) 
			self.taskType =  User:getRole():getFlag("历练随机任务名")
			if mytaskid =="task16" then
				self.num = 4
			elseif mytaskid =="task17" then
				self.num = 3
			elseif mytaskid =="task19" then
				self.num = 1
			elseif mytaskid =="task20" then
				self.num = 2
			elseif mytaskid =="task21" then
				self.num = 5
			end
		end

		local descListString = liLianTask[""..tasklevel].jobtext 
		local descList = string.split(descListString, ";")
		local desc = descList[self.num]
		self:print(desc)
        
		User:getRole():setFlag("历练随机任务名",self.taskType)
        User:getRole():setFlag("历练",mytaskid)
		User:getRole():setFlag( mytaskid ,self.needTime)
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
			local item = Item:getOneItemByKey("dundifu")
			if not item then
				return
			end
			local map = Map:getMapById(self._currTask.mapId)

			local roomId = self._roomId

			local role = User:getRole()
			local item_count = role:getItemCount("dundifu")
			local skill = role:getSkill("wuxingdunfa")

			-- if item_count >= 1 and MapIsEmpty(skill) == false then
				local dialog = DialogALayer:getInstance()
				local showStr="HIY"..map.name..self.goRoomName.."NOR"
				local dialog = DialogALayer:getInstance()
				dialog:show("选择前往"..showStr.."的方式。\n（选择遁地方式前往，会偶然出现意想不到的结果，请谨慎使用。）")
				dialog:setWeChatVisible(false)
				dialog:setButton1("自行前往", function()
					MainControllLayer:pushLayer("SelectMapLayer")
					local selectMapLayer = MainControllLayer:getLayer("SelectMapLayer")
					selectMapLayer:setMap(map.id)
					self:setVisible(false)
				end)
				dialog:setButton2("用遁地符", function()
					item:useDunDiFu(role,map.id, roomId,function ()
						self:setVisible(false)
					end,SKILL_ITEM_DUNDIFU_TYPE)
				end)
				if MapIsEmpty(skill) == false then
					dialog:setButton3("五行遁法", function()
						item:useDunDiFu(role,map.id, roomId, function(useResult)
							if useResult == false then 
								dialog:setVisible(true)
							else
								self:setVisible(false)
							end
						end,SKILL_ITEM_TYPE)
					end)
				end
			-- elseif MapIsEmpty(skill) == false then
			-- 	--@desc 直接使用五行遁法
			-- 	item:useDunDiFu(role, map.id, roomId, function (useResult)
			-- 		if useResult == false then 
			-- 		else
			-- 			self:setVisible(false)
			-- 		end
			-- 	end,SKILL_ITEM_TYPE)
			-- else
			-- 	--@desc 直接使用遁地符
			-- 	item:useDunDiFu(role, map.id, roomId,function ()
			-- 		self:setVisible(false)
			-- 	end,SKILL_ITEM_DUNDIFU_TYPE,true)
			-- end
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

return ZhuXianUI0000000000000000