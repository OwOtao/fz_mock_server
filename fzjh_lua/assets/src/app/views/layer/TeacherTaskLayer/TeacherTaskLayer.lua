local TeacherTaskLayer = class("TeacherTaskLayer", cc.Layer)  
local TeacherTask  = require("app.models.task.teacherTask.teacherTask")
local Npc = require("app.models.npc.Npc")
local tab = {
	taskCount = 0,--任务已完成数量
	refreshTaskCount = 0,--任务刷新次数
	tasks = { --任务列表

	},
	rewards = 0,
	appointCount = 0,--指派同门刷新次数
}

function TeacherTaskLayer:create()
	local p = TeacherTaskLayer:new()
	p:init()
	return p
end
function TeacherTaskLayer:init()
	local UI= require("Layer/TeacherTask/TeacherTaskUI.lua").create()['root']
	UI:addTo(self)
	Helper:convertUIByParent(self) -- 获得所有子节点
	self:setNPCOneButton()
	self:setNPCTwoButton()
end
function TeacherTaskLayer:enterLayer()
	local layer = self:getInstance()
	layer:show()
	layer:initLayer()
end
function TeacherTaskLayer:initLayer()
	local role = User:getRole()
	self:setContributionPoint(tostring(TeacherTask:getTeacherTaskAttr("ContributionPoint")).."/4000")
	self:setTask(TeacherTask:getTeacherTaskAttr("receiveTask"))
	local familyTab = TeacherTask:getFamilyDsc()
	local TitleLayer = MainControllLayer:getLayer("TitleLayer")
	TitleLayer:setLayerTitleName("TeacherTaskLayer",familyTab.position)
	-- TitleLayer:ButtonBack(function()
	-- 	MainControllLayer:popLayer()
	-- 	local layer = MainControllLayer:getLayer("TeacherLayer")
	-- 	layer:refreshGongXian()
	-- 	TitleLayer:setTitleBack()
	-- end)
	self:setTeacherDsc(familyTab.dsc)
	self:setHasComplete()
	-- Helper:print_lua_table(TeacherTask:getTeacherTaskAttr("taskTab"))

end
function TeacherTaskLayer:setBackButton()

end
function TeacherTaskLayer:setHasComplete()
	local receiveTask = TeacherTask:getTeacherTaskAttr("receiveTask")
	-- if receiveTask == 0 then
	-- 	self.Panel_back.Text_dCount:setString("『今日已完成』"..tostring(TeacherTask:getTeacherTaskAttr("dCount")).."/"..tostring(TeacherTask:getTeacherTaskMaxNum()))
	-- else
	-- 	self.Panel_back.Text_dCount:setString("『今日已完成』"..tostring(TeacherTask:getTeacherTaskAttr("count")-1).."/"..tostring(TeacherTask:getTeacherTaskMaxNum()))
	-- end
	self.Panel_back.Text_dCount:setString("『今日已完成』"..tostring(TeacherTask:getTeacherTaskAttr("dCount")).."/"..tostring(TeacherTask:getTeacherTaskMaxNum()))
end
function TeacherTaskLayer:getRandomTaskId(tab)
	if tab then
		local qualityWeightList = {60,25,14,1}
		local taskId = math.random(1,#tab)--任务id
		local taskQuality  = Helper:RandomByWeight(weightList)--任务品质
		return taskId,taskQuality
	end
end
--npc1
function TeacherTaskLayer:setNPCOneButton()
	local currNpc = Npc:getNpc(TeacherTask:getFamilyDsc().tasknpc)
	if currNpc == nil then
		return
	end
	-- table.insert(currNpc.functions,{name = "师门清规",funcName = "obRule"})
	-- table.insert(currNpc.functions,{name = "交易",funcName = "obSale"})
	self.Panel_back.Button_npc1.Text_buttonName:setString(currNpc:getName())
	self.Panel_back.Button_npc1:releaseFunc(function()
		-- PopText("npc1")
		PopupLayerController:showLayer("FamilySalesInfoLayer", function(layer)
			layer.teacherLayer = self
			layer:showLayer()
			layer:setRole(currNpc)
			layer:setRoleDsc(currNpc:getDsc(User:getRole(),true,true,false),currNpc)
		end)
	end)
end
function TeacherTaskLayer:setNPCTwoButton()
	local currNpc = Npc:getNpc(TeacherTask:getFamilyDsc().awardnpc)
	self.Panel_back.Button_npc2.Text_buttonName:setString(currNpc:getName())
	self.Panel_back.Button_npc2:releaseFunc(function()
		-- PopText("npc2")

		PopupLayerController:showLayer("FamilySalesInfoLayer", function(layer)
			layer.teacherLayer = self
			layer:showLayer()
			layer:setRole(currNpc)
			layer:setRoleDsc(currNpc:getDsc(User:getRole(),true,true,false),currNpc)
		end)
	end)
end
--师门的描述
function TeacherTaskLayer:setTeacherDsc(str)
	self.Panel_back.Text_dsc:setString(str)
end
--显示现有贡献点和今日师门任务获取的贡献点
function TeacherTaskLayer:setContributionPoint(num2)
	HttpManagerEx:getDevotePoint(function(status, errcode, errmsg, data)
		if status == 200 and errcode == 0 then
			Helper:getDef(data,{})
			Helper:print_lua_table(data)
			self.Panel_back.Text_num1:setString(Helper:getDef(data.dev_point,0))
			if num2 then
				self.Panel_back.Text_num2:setString(tostring(num2))
			end
			if Helper:getDef(data.has_reward,"N") =="Y" then
				self.Panel_back.Button_npc2.Image_hongdian:setVisible(true)
			else
				self.Panel_back.Button_npc2.Image_hongdian:setVisible(false)
			end
		else
			PopText(errmsg)
		end
	end, IS_SHOW_WAITING)
end
--显示任务
function TeacherTaskLayer:setTask(task)
	if task and task ~= 0 then
		self.Panel_back.Text_kong:setVisible(false)
		self.Panel_back.Panel_10:setVisible(true)
		self.Panel_back.Panel_10.Image_do.Text_taskName:setString(task.taskName)
		if task.taskQuality == 1 then
			self.Panel_back.Panel_10.Image_do.Text_taskName:setTextColor({r = 57, g = 219, b = 92})
		elseif task.taskQuality == 2 then
			self.Panel_back.Panel_10.Image_do.Text_taskName:setTextColor({r = 11, g = 128, b = 246})
		elseif task.taskQuality == 3 then
			self.Panel_back.Panel_10.Image_do.Text_taskName:setTextColor({r = 204, g = 51, b = 204})
		elseif task.taskQuality == 4 then
			self.Panel_back.Panel_10.Image_do.Text_taskName:setTextColor({r = 236, g = 101, b = 26})
		else
			PopText("稀有度颜色不存在")
		end
		self.Panel_back.Panel_10.Image_xiangqing.Text_name:setString("详情")
		self.Panel_back.Panel_10.Image_xiangqing.Text_name:releaseFunc(function()
			local TeacherTaskDetailsLayer = require("app.views.layer.TeacherTaskLayer.TeacherTaskDetailsLayer")
        	TeacherTaskDetailsLayer:enterLayer(function()
        		self:initLayer()
        	end)
		end)
		if self._handle == nil then
			self._handle = self:schedule(
				function(dt)
					self:setAppointText(dt)
				end, 1.0)
		end
		self:setAppointText()

	else
		self.Panel_back.Text_kong:setVisible(true)
		self.Panel_back.Panel_10:setVisible(false)
	end
end
function TeacherTaskLayer:setAppointText(dt)
	local receiveTask = TeacherTask:getTeacherTaskAttr("receiveTask")
	local Appoint = TeacherTask:getTeacherTaskAttr("isAppoint")
	if type(receiveTask)~="number" and receiveTask.taskType == 0 and TeacherTask:getTeacherTaskAttr("isComplete") ~= "Y" then
		if Appoint ~= "Y" then--没有指派的任务才会扣除
			local item = User:getRole():getItem(receiveTask.target)
			if item and item.count >= tonumber(receiveTask.targetNum) then
				if TeacherTask:getTeacherTaskAttr("isComplete") == "N" then
					TeacherTask:setTeacherTaskAttr("isComplete","Y")
					User:getRole():addItemCount(receiveTask.target,0-tonumber(receiveTask.targetNum))
				end
			end
		end
	end
	if TeacherTask:getTeacherTaskAttr("isComplete") == "Y" then
		self.Panel_back.Panel_10.Image_xiangqing.Text_name:setString("领取奖励")
		self.Panel_back.Panel_10.Image_xiangqing.Text_name:releaseFunc(function()
			self:getReward()
		end)
		self.Panel_back.Panel_10.Text_appointName:setVisible(false)
		return
	end
	if Appoint ~= 0 and Appoint.isAppoint == "Y" then
		self.Panel_back.Panel_10.Text_appointName:setVisible(true)
		if Appoint.time-GetTime() <= 0 then
			self.Panel_back.Panel_10.Image_xiangqing.Text_name:setString("领取奖励")
			self.Panel_back.Panel_10.Image_xiangqing.Text_name:releaseFunc(function()
				self:getReward()
			end)
			self.Panel_back.Panel_10.Text_appointName:setVisible(false)
			self:unschedule(self._handle)
			self._handle = nil
		else
			local  minute = tonumber(Helper:date("%M", tonumber(Appoint.time - GetTime())))--
			local  second = tonumber(Helper:date("%S", tonumber(Appoint.time - GetTime())))
			local str = "已指派给"..Appoint.name..",\n预计"..tostring(minute).."分"..tostring(second).."秒完成"
			self.Panel_back.Panel_10.Text_appointName:setString(str)
		end
	else
		self.Panel_back.Panel_10.Text_appointName:setVisible(false)
		self:unschedule(self._handle)
		self._handle = nil
	end
end
function TeacherTaskLayer:getReward()
	local receiveTask = TeacherTask:getTeacherTaskAttr("receiveTask")
	local rewList = receiveTask.reward
	rewList = table.mergeMap(rewList,TeacherTask:getTeacherTaskExtraRewardByTaskId(receiveTask.taskId))
	if receiveTask.reward and User:getRole():checkCanBuyTwoOrMoreThings(rewList) == false then
		PopText("背包空间不足,无法领取")
		return
	else
		-- print("**********************",User:getRole():checkCanBuyTwoOrMoreThings(receiveTask.reward),"***************************")
	end 
	-- assert(nil)
	local point = {
			point = TeacherTask:getTeacherTaskReward(),
			task_lv = receiveTask.taskQuality,
			record_id = receiveTask.record_id,
			my_lv = User:getRole():getAttr("lv")
		}
	if receiveTask.jiangli ~= nil and receiveTask.jiangli == 1 then--没有成功完成任务，例如 军情密函，白驼山放蛇
		point.point = math.floor(point.point/2)
	end
	HttpManagerEx:addDevotePoint(5,point,function(status, errcode, errmsg, data)
		Helper:print_lua_table(data)
		if status == 200 and errcode == 0 then
			TeacherTask:setTeacherTaskAttr("ContributionPoint",TeacherTask:getTeacherTaskAttr("ContributionPoint")+data.get_point)--以服务器增加的贡献点为准
			TeacherTask:setTeacherTaskAttr("receiveTask",0)
			TeacherTask:setTeacherTaskAttr("isAppoint",0)
			TeacherTask:setTeacherTaskAttr("isComplete","N")
			TeacherTask:setTeacherTaskAttr("dCount",TeacherTask:getTeacherTaskAttr("dCount") + 1)
			PopText(data.msg)
			if receiveTask.reward then
				if receiveTask.jiangli == nil or receiveTask.jiangli == 2 then--成功完成任务才会获得额外奖励
					for k,v in pairs(receiveTask.reward) do 
						local item = User:getRole():getOneItemByKey(k)
						if item ~= nil then
							PopText("获得物品"..item.name.."X 1")
							User:getRole():addItemCount(k,v)
						end
					end
					for k,v in pairs(TeacherTask:getExtraReward(receiveTask.taskId,receiveTask.taskQuality)) do 
						local item = User:getRole():getOneItemByKey(v)
						if item ~= nil  then
							PopText("获得物品"..item.name.."X 1")
							User:getRole():addItemCount(v,1)
						end
					end
					if data.special_time == true then
						for k,v in pairs(TeacherTask:getFestivaExtraReward(receiveTask.taskId,receiveTask.taskQuality)) do 
							local item = User:getRole():getOneItemByKey(v)
							if item ~= nil  then
								PopText("获得物品"..item.name.."X 1")
								User:getRole():addItemCount(v,1)
							end
						end
					end
				end
			end
			self:initLayer()
			User:getRole():removeRoleCurrState(ROLE_CURR_STATE_SHIMEN)
		elseif status == 200 and errcode == 3 then --获得的贡献点到达上限
			TeacherTask:setTeacherTaskAttr("receiveTask",0)
			TeacherTask:setTeacherTaskAttr("isAppoint",0)
			TeacherTask:setTeacherTaskAttr("isComplete","N")
			TeacherTask:setTeacherTaskAttr("dCount",TeacherTask:getTeacherTaskAttr("dCount") + 1)
			PopText(errmsg)
			if receiveTask.reward then
				if receiveTask.jiangli == nil or receiveTask.jiangli == 2 then--成功完成任务才会获得额外奖励
					for k,v in pairs(receiveTask.reward) do 
						if item ~= nil then
							PopText("获得物品"..item.name.."X 1")
							User:getRole():addItemCount(k,v)
						end
					end
					for k,v in pairs(TeacherTask:getExtraReward(receiveTask.taskId,receiveTask.taskQuality)) do 
						local item = User:getRole():getOneItemByKey(v)
						if item ~= nil  then
							PopText("获得物品"..item.name.."X 1")
							User:getRole():addItemCount(v,1)
						end
					end
					if data.special_time == true then
						for k,v in pairs(TeacherTask:getFestivaExtraReward(receiveTask.taskId,receiveTask.taskQuality)) do 
							local item = User:getRole():getOneItemByKey(v)
							if item ~= nil  then
								PopText("获得物品"..item.name.."X 1")
								User:getRole():addItemCount(v,1)
							end
						end
					end
				end
			end
			self:initLayer()
			User:getRole():removeRoleCurrState(ROLE_CURR_STATE_SHIMEN)	
		else
			PopText(errmsg)	
		end
	end,IS_SHOW_WAITING)
end
Helper:classDefNodeGetInstance(TeacherTaskLayer)
return TeacherTaskLayer
00000000000