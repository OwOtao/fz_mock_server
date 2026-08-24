local ReceiveTeacherTaskLayer = class("ReceiveTeacherTaskLayer", cc.Layer)
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

function ReceiveTeacherTaskLayer:create()
	local p = ReceiveTeacherTaskLayer:new()
	p:init()
	return p
end
function ReceiveTeacherTaskLayer:init()
	local UI= require("Layer/TeacherTask/ReceiveTeacherTask.lua").create()['root']
	UI:addTo(self)
	Helper:convertUIByParent(self) -- 获得所有子节点

end
function ReceiveTeacherTaskLayer:enterLayer()
	local layer = self:getInstance()
	layer:show()
	layer:initLayer()
end
function ReceiveTeacherTaskLayer:initLayer()
	self:setTaskList()
	self:setRefreshButton()
	self:setRefreshCount()
	self:setBackButton()
	self:setLayerTitleNameAndNPCName()
end
function ReceiveTeacherTaskLayer:setBackButton(func)
	-- self.Button_quit:releaseFunc(function()
	-- 	MainControllLayer:popLayer()
	-- 	MainControllLayer:getInstance():getLayer("TeacherTaskLayer"):initLayer()
	-- 	PrintLayer:setPanelVisible(false)
	-- end)
	local PrintLayer = MainControllLayer:getLayer("PrintLayer")
	local title = MainControllLayer:getLayer("TitleLayer")
	title:setBackCallFunc(function()
		PrintLayer:setPanelVisible(false)
		MainControllLayer:getInstance():getLayer("TeacherTaskLayer"):initLayer()
	end)
	PrintLayer:setPanelVisible(true)
	PrintLayer:setPanleReleaseFunc(function()
		MainControllLayer:popLayer()
		PrintLayer:setPanelVisible(false)
		MainControllLayer:getInstance():getLayer("TeacherTaskLayer"):initLayer()
		title:setTitleBack()
	end)
end
--获取师门任务的id和任务品质id
function ReceiveTeacherTaskLayer:getRandomTaskId(tab)
	if tab then
		local qualityWeightList = {60,25,14,1}
		local taskId = math.random(1,#tab)--任务id
		local taskQuality  = Helper:RandomByWeight(weightList)--任务品质
		return taskId,taskQuality
	end
end
function ReceiveTeacherTaskLayer:setHideLayer()
	self.Panel_back:releaseFunc(function()
		self.hide()
	end)
end
function ReceiveTeacherTaskLayer:setTaskList()
	local textColor = cc.c3b(159,159,159)
	local role = User:getRole()
	local tab = TeacherTask:getTeacherTaskAttr("taskTab")--TeacherTask:getTeacherTaskAttr("taskTab")
	local receiveTask = TeacherTask:getTeacherTaskAttr("receiveTask")
	local isNeedRefresh = true
	if type(tab) == "table" then
		for k,v in pairs(tab) do 
			if type(v) == "table" then
				isNeedRefresh = false
			end
		end
	end
	if isNeedRefresh == true then
		PopText(1)
	 	tab= TeacherTask:initTeacherTask()
	 end
	--  print("任务个数",#tab)
	 self:createTaskListView(tab)
	-- Helper:print_lua_table(self.Panel_back2.ListView_7)
end
function ReceiveTeacherTaskLayer:setLayerTitleNameAndNPCName()
	local familyTab = TeacherTask:getFamilyDsc()
	local TitleLayer = MainControllLayer:getLayer("TitleLayer")
	TitleLayer:setBackCallFunc(function()
		MainControllLayer:getInstance():getLayer("TeacherTaskLayer"):initLayer()
	end)
	TitleLayer:setLayerTitleName("ReceiveTeacherTaskLayer",familyTab.position)
end
function ReceiveTeacherTaskLayer:createTaskListView(tab)
	if type(tab) ~= "table" then
		print("ReceiveTeacherTaskLayer:createTaskListView tab is nil ")
		return
	end
	self.Panel_back2.ListView_7:removeAllItems()
	for k,v in pairs(tab) do 
		local panel = self.Panel_back2.Panel_27:clone()
		Helper:convertUI(panel)
		panel.Text_taskName:setString(v.taskName)
		panel.Text_1:setString(TeacherTask:getTeacherSimpleDsc(v.taskId))
		if v.taskQuality == 1 then
			panel.Text_taskName:setTextColor({r = 57, g = 219, b = 92})
		elseif v.taskQuality == 2 then
			panel.Text_taskName:setTextColor({r = 11, g = 128, b = 246})
		elseif v.taskQuality == 3 then
			panel.Text_taskName:setTextColor({r = 204, g = 51, b = 204})
		elseif v.taskQuality == 4 then
			panel.Text_taskName:setTextColor({r = 236, g = 101, b = 26})
		else
			PopText("稀有度颜色不存在")
		end
		print(">>>>>>>>>>>>>>>",type(TeacherTask:getTeacherTaskAttr("receiveTask")))
		panel.Image_xiangqing:releaseFunc(function()

			if User:getRole():isInCurrState(ROLE_CURR_STATE_ZHUDONG) == true then
				local task_zhudong = User:getRole():getAttr("currTaskId")
				if task_zhudong == "task16" then
					PopText("请先完成飞贼横行任务")
				elseif task_zhudong == "task17" then
					PopText("请先完成南阳匪乱任务")
				end
			elseif TeacherTask:getTeacherTaskAttr("receiveTask") ~= 0 then
				PopText("当前还有任务未完成")
			else
				local familyTab = TeacherTask:getFamilyDsc()
				local currNpc = Npc:getNpc(familyTab.tasknpc)
				print(GetTime()-TeacherTask:getTeacherTaskAttr("giveUpTime"),"*******************************************")
				if not TeacherTask:getTeacherTaskAttr("giveUpTime") or GetTime()-TeacherTask:getTeacherTaskAttr("giveUpTime") >= 1 then
					if TeacherTask:checkCanReceiveTask() == true then
						self:addItemByTask(v,k)
					else
						RichPrint("main","YEL"..currNpc:getName()..":你今天做的已经够多了，还是明日再来吧。")
					end
				else
					RichPrint("main","YEL"..currNpc:getName()..":你刚刚放弃过任务，还是稍等片刻再来吧")
				end
			end
		end)
		self.Panel_back2.ListView_7:pushBackCustomItem(panel)
	end
end

--接取任务，根据任务种类给角色添加相应的道具
function ReceiveTeacherTaskLayer:addItemByTask(task,num)
	if not task then
		return
	end
	if task.taskType == 2 then
		print("有任务道具")
		if User:getRole():checkCanBuyThings(task.itemId,1) then
			TeacherTask:setTeacherTaskAttr("count",tonumber(TeacherTask:getTeacherTaskAttr("count"))+1)
			User:getRole():addItemCount(task.itemId,1)
			TeacherTask:receiveTaskByTaskId(task.taskId)
			local item = User:getRole():getOneItemByKey(task.itemId)
			PopText("获得物品"..item.name.."X 1")
			self.Panel_back2.ListView_7:removeItem(num-1)			
			self:setTaskList()
		else
			PopText("背包空间不足")
		end
	elseif task.taskType == 4 then
		if task.itemId ~= nil and task.itemId ~= 0 then
			if User:getRole():checkCanBuyThings(task.itemId,1) then
				TeacherTask:setTeacherTaskAttr("count",tonumber(TeacherTask:getTeacherTaskAttr("count"))+1)
				User:getRole():addItemCount(task.itemId,1)
				TeacherTask:receiveTaskByTaskId(task.taskId)
				local item = User:getRole():getOneItemByKey(task.itemId)
				PopText("获得物品"..item.name.."X 1")
				self.Panel_back2.ListView_7:removeItem(num-1)			
				self:setTaskList()
			else
				PopText("背包空间不足")
			end
		else
			TeacherTask:receiveTaskByTaskId(task.taskId)
			self.Panel_back2.ListView_7:removeItem(num-1)			
			self:setTaskList()	
		end
	else
		print("没有任务道具")
		TeacherTask:setTeacherTaskAttr("count",tonumber(TeacherTask:getTeacherTaskAttr("count"))+1)
		TeacherTask:receiveTaskByTaskId(task.taskId)
		self.Panel_back2.ListView_7:removeItem(num-1)			
		self:setTaskList()
	end
	PopText("领取了师门任务")
	local PrintLayer = MainControllLayer:getLayer("PrintLayer")
	local title = MainControllLayer:getLayer("TitleLayer")
	PrintLayer:setPanelVisible(false)
	MainControllLayer:popLayer()
	MainControllLayer:getInstance():getLayer("TeacherTaskLayer"):initLayer()
	User:getRole():setRoleCurrState(ROLE_CURR_STATE_SHIMEN)
end
function ReceiveTeacherTaskLayer:initRichTextPreview(str,DscArea,parent,textColor,verticalSpace)
	local x, y = DscArea:getPosition()
	local size = DscArea:getContentSize()
	-- DscArea:setVisible(false)
	if parent["RichText_Print"] then
		parent["RichText_Print"]:removeFromParent()
		parent["RichText_Print"] = nil
	end
	local richTextScroll = ExtRichTextScroll:create()
	richTextScroll:setAnchorPoint( 0.5 , 0.5 )
   	DscArea:getParent():addChild(richTextScroll)
   	local point = cc.p(DscArea:getPosition())
   	richTextScroll:move(point)
   	richTextScroll:setSize(size)
   	richTextScroll:setDirection(kCCScrollViewDirectionVertical)
   	richTextScroll:getRichText():setVerticalSpace(5)
   	parent["RichText_Print"] = richTextScroll
   	parent["RichText_Print"]:setBounceEnabled(false)
   	parent["RichText_Print"]:pushBackText(str, textColor, 255, Resource:getFontPath("default"), 42)
   	parent["RichText_Print"]:pushBackNewLine()
	parent["RichText_Print"]:pushBackNewLine(verticalSpace)
	parent["RichText_Print"]:setCascadeOpacity(0)
	parent["RichText_Print"]:setAnchorPoint(0.5000, 0.5000)
	parent["RichText_Print"]:setTouchEnabled(false)
	self:delayFunc(0.3,function ()
		parent["RichText_Print"]:jumpToTop()
		parent["RichText_Print"]:setCascadeOpacity(255)
	end)
end
function ReceiveTeacherTaskLayer:setRefreshCount()
	local count = TeacherTask:getTeacherTaskAttr("refreshCount")
	if 3 - count >= 1 then
		self.Panel_back2.Text_98:setString("今日还可免费刷新"..tostring(3 - count).."次")
	else
		local yuanbaoC = math.min((count-2)*10,100)
		self.Panel_back2.Text_98:setString("本次刷新需要"..tostring(yuanbaoC).."元宝")--本次刷新需要..tostring((count-2)*10)元宝
	end
	self.Text_dCount:setString("今日已完成："..tostring(TeacherTask:getTeacherTaskAttr("dCount")).."/"..tostring(TeacherTask:getTeacherTaskMaxNum()))
	self.Text_dget:setString("已获得贡献点："..tostring(TeacherTask:getTeacherTaskAttr("ContributionPoint")).."/4000")
end
function ReceiveTeacherTaskLayer:setRefreshButton()
	self.Panel_back2.Button_refresh:releaseFunc(function()
		-- PopText("刷新")
		if TeacherTask:checkCanReceiveTask() == true then
			local count  = TeacherTask:getTeacherTaskAttr("refreshCount")
			if count >= 3 then
				-- PopText("免费刷新次数已经用光")
				local DialogGLayer = require("app.views.layer.DialogLayer.DialogGLayer")
				local dialog = DialogGLayer:getInstance()
				dialog:initPanel("refresh")
				dialog:setText_desc_1("是否花费元宝刷新当前师门任务？")
				dialog:setText_desc_4(tostring(TeacherTask:getRefreshTeacherTaskGoldCount()).."元宝")
				dialog:setButton2(function()
					--不刷新
				end)
				dialog:setButton1(function()
					--刷新
					PopText(tonumber(TeacherTask:getRefreshTeacherTaskGoldCount()))
					print("************************",tonumber(TeacherTask:getRefreshTeacherTaskGoldCount()),"**********************")
					HttpManagerEx:refreshTeacherTaskList(tonumber(TeacherTask:getRefreshTeacherTaskGoldCount()),function(status, errcode, errmsg, data, isEncrypted)
						print(status,errcode)
						Helper:print_lua_table(data)
						if status == 200 and errcode == 0 then
							PopText("任务刷新成功！")
							local tab= TeacherTask:initTeacherTask()
							TeacherTask:setTeacherTaskAttr("refreshCount",count+1)
							self:createTaskListView(tab)
							self:setRefreshCount()
						else
							PopText(errmsg)
						end
					end,IS_SHOW_WAITING)
				end)
			else
				local tab= TeacherTask:initTeacherTask()
				TeacherTask:setTeacherTaskAttr("refreshCount",count+1)
				self:createTaskListView(tab)
				self:setRefreshCount()
			end
		else
			PopText("今日完成师门任务已达上限！")
		end
	end)
end
Helper:classDefNodeGetInstance(ReceiveTeacherTaskLayer)
return ReceiveTeacherTaskLayer
000000000000