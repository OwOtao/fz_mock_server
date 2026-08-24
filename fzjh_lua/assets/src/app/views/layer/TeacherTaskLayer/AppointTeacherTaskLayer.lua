local TeacherTask  = require("app.models.task.teacherTask.teacherTask")
local AppointTeacherTaskLayer = class("AppointTeacherTaskLayer", cc.Layer)
local Npc = require("app.models.npc.Npc")
local tab = {
	taskCount = 0,--任务已完成数量
	refreshTaskCount = 0,--任务刷新次数
	tasks = { --任务列表

	},
	rewards = 0,
	appointCount = 0,--指派同门刷新次数
}

function AppointTeacherTaskLayer:create()
	local p = AppointTeacherTaskLayer:new()
	p:init()
	return p
end
function AppointTeacherTaskLayer:init()
	local UI= require("Layer/TeacherTask/AppointTeacherTask.lua").create()['root']
	UI:addTo(self)
	Helper:convertUIByParent(self) -- 获得所有子节点

end
function AppointTeacherTaskLayer:enterLayer()
	local layer = self:getInstance()
	layer:show()
	layer:initLayer()
end
function AppointTeacherTaskLayer:initLayer()
	local textColor = cc.c3b(255,255,255)
	self.Panel_back4:releaseFunc(function()
		self:hide()
		MainControllLayer:getInstance():getLayer("TeacherTaskLayer"):initLayer()
	end)
	local role = User:getRole()
	local task = TeacherTask:getTeacherTaskAttr("receiveTask")
	if task == {} then
		return 
	end
	local str = nil 
	str = "你决定将"..TeacherTask:getTaskNameStrColor(task)..task.taskName.."NOR这个任务指派给哪位同门:"
	self:initRichTextPreview(str,self.Panel_back4.Panel_dsc,self.Panel_back4,textColor,"Text_dsc")
	self.Panel_back4.ListView_2:removeAllItems()
	-- ,menpai:门派英文，task_level:任务稀有度，task_name：任务名称, task_id:任务id
	local tab = {
		type = 0,
		menpai = User:getRole():getFamilyId(),
		task_level = task.taskQuality,
		task_name =TeacherTask:getTaskNameStrColor(task)..task.taskName.."NOR",
		task_id = task.taskId,
	}
	HttpManagerEx:getTeacherTaskPointList(tab,function(status, errcode, errmsg, data)
		if status == 200 and errcode == 0 then
			for k,v in pairs(data.user_list) do 
				self:clonePanel(v)
			end
			TeacherTask:setTeacherTaskAttr("appointRefreshCount",data.refreshCount)
			self:setRefreshButton()
		else
			PopText(errmsg)
		end
	end,IS_SHOW_WAITING)
end
function AppointTeacherTaskLayer:setRefreshButton()
	local role = User:getRole()
	local count = TeacherTask:getTeacherTaskAttr("appointRefreshCount")
	if count == nil then
		count = 0
	end
	TeacherTask:setTeacherTaskAttr("appointRefreshCount",count)
	if (3 - count) >= 1 then
		self.Panel_back4.Button_npc2:releaseFunc(function()
			local task = TeacherTask:getTeacherTaskAttr("receiveTask")
			local tab = {
				type = 1,
				menpai = User:getRole():getFamilyId(),
				task_level = task.taskQuality,
				task_name =TeacherTask:getTaskNameStrColor(task)..task.taskName.."NOR",
				task_id = task.taskId,
			}
			HttpManagerEx:getTeacherTaskPointList(tab,function(status, errcode, errmsg, data)
				if status == 200 and errcode == 0 then
					self.Panel_back4.ListView_2:removeAllItems()
					for k,v in pairs(data.user_list) do 
						self:clonePanel(v)
					end
					PopText("刷新成功")
					TeacherTask:setTeacherTaskAttr("appointRefreshCount",data.refreshCount)
					self:setRefreshButton()
				else
					PopText(errmsg)
				end
			end,IS_SHOW_WAITING)
		end)
	else
		self.Panel_back4.Button_npc2:releaseFunc(function()
			local DialogGLayer = require("app.views.layer.DialogLayer.DialogGLayer")
			local dialog = DialogGLayer:getInstance()
			dialog:initPanel("refresh")
			dialog:setText_desc_1("是否花费元宝刷新当前可指派同门？")
			dialog:setText_desc_4(tostring(TeacherTask:getAppointRefreshTeacherTaskGoldCount()).."元宝")--getAppointRefreshTeacherTaskGoldCount
			dialog:setButton2(function()
				--不刷新
			end)
			dialog:setButton1(function()
				--刷新
				local task = TeacherTask:getTeacherTaskAttr("receiveTask")
				local tab = {
					type = 1,
					menpai = User:getRole():getFamilyId(),
					task_level = task.taskQuality,
					task_name =TeacherTask:getTaskNameStrColor(task)..task.taskName.."NOR",
					task_id = task.taskId,
				}
				HttpManagerEx:getTeacherTaskPointList(tab,function(status, errcode, errmsg, data)
					if status == 200 and errcode == 0 then
						self.Panel_back4.ListView_2:removeAllItems()
						for k,v in pairs(data.user_list) do 
							self:clonePanel(v)
						end
						PopText("刷新成功")
						TeacherTask:setTeacherTaskAttr("appointRefreshCount",data.refreshCount)
						self:setRefreshButton()
					else
						PopText(errmsg)
					end
				end,IS_SHOW_WAITING)
			end)
		end)
	end
	self:setRefreshCountText()
end
function AppointTeacherTaskLayer:setRefreshCountText()
	local role = User:getRole()
	local count = role:getTeacherTaskAttr("appointRefreshCount")
	if (3 - count) >= 1 then
		self.Panel_back4.Text_refreshNum:setString("今日还可免费刷新"..tostring(3 - count).."次")
	else
		local yuanbaoC = math.min((count-2)*10,100)
		self.Panel_back4.Text_refreshNum:setString("本次刷新需要"..tostring(yuanbaoC).."元宝")
		-- self.Panel_back4.Text_refreshNum:setString("今日还可免费刷新"..tostring(0).."次")
	end
end
function AppointTeacherTaskLayer:clonePanel(list)
	local item = self.Panel_back4.Panel_27:clone()
	Helper:convertUI(item)
	item.Text_name:enableOutline({r = 17, g = 18, b = 18, a = 255}, 5)
	item.Text_7:enableOutline({r = 17, g = 18, b = 18, a = 255}, 5)
	item.Text_8:enableOutline({r = 17, g = 18, b = 18, a = 255}, 5)
	item.Text_Name:enableOutline({r = 0, g = 0, b = 0, a = 255}, 5)
	local receiveTask = TeacherTask:getTeacherTaskAttr("receiveTask")
	local func = function()
			local tab = {
			isAppoint = "Y",
			time = GetTime()+tonumber(list.spend_time)*60,
			name = list.username
		}
		print("指派任务计算完成时间:",GetTime()+tonumber(list.spend_time)*60)
		local str
		for k,v in pairs(list.reward) do 
			if k == "money" then
				User:getRole():addAttr("money",0-v)
			end
			str = "你花费"..tostring(v)..User:getRole():getCHAttrName(k).."把师门任务"..TeacherTask:getTaskNameStrColor(receiveTask)..receiveTask.taskName.."NOR指派给了YEL"..tab.name.."NOR。"
		end
		TeacherTask:setTeacherTaskAttr("isAppoint",tab)
		User:getRole():removeRoleCurrState(ROLE_CURR_STATE_SHIMEN)
		RichPrint("main",str)
		PopText("任务指派成功")
		self:hide()
		MainControllLayer:getInstance():getLayer("TeacherTaskLayer"):initLayer()
	end
	item.Text_name:setString(list.username)
	local familyDsc = ""
	if list.dsc == 1 then
		familyDsc = "第一代弟子"
	elseif list.dsc == 2 then
		familyDsc = "第二代弟子"
	elseif list.dsc == 3 then
		familyDsc = "第三代弟子"
	elseif list.dsc == 4 then
		familyDsc = "第四代弟子"
	elseif list.dsc == 5 then
		familyDsc = "第五代弟子"
	elseif list.dsc == 6 then
		familyDsc = "第六代弟子"
	elseif list.dsc == 7 then
		familyDsc = "第七代弟子"
	end
	item.Text_7:setString(familyDsc)
	for k,v in pairs(list.reward) do
		item.Text_8:setString(tostring(v)..User:getRole():getCHAttrName(k))
	end
	for k,v in pairs(list.reward) do 
		if k == "yuanbao" then
			item.Text_Name:releaseFunc(function()
				local DialogGLayer = require("app.views.layer.DialogLayer.DialogGLayer")
				local dialog = DialogGLayer:getInstance()
				dialog:initPanel("refresh")
				dialog:setText_title("指派")
				dialog:setBUttonName("指派","取消")
				dialog:setText_desc_1("你是否花费元宝指派该同门？")
				dialog:setText_desc_4(tostring(v).."元宝")
				dialog:setButton2(function()
					--不刷新
				end)
				dialog:setButton1(function()
					self:addTeacherTaskRecord(list.userid,func)
				end)
			end)
		else
			item.Text_Name:releaseFunc(function()
				if tonumber(v) > tonumber(User:getRole():getAttr("money")) then
					PopText("碎银不足")
					return
				end
				self:addTeacherTaskRecord(list.userid,func)
			end)
		end
	end
	self.Panel_back4.ListView_2:pushBackCustomItem(item)
end
function AppointTeacherTaskLayer:addTeacherTaskRecord(userid,func)
	print("指派参数：",userid)
	local tab = {
		hire_userid = userid,
		my_lv = User:getRole():getAttr("lv")
	}
	HttpManagerEx:addTeacherTaskRecord(tab,function(status, errcode, errmsg, data)
		if status == 200 and errcode == 0 then
			local receiveTask = TeacherTask:getTeacherTaskAttr("receiveTask")
			receiveTask.record_id = data.record_id
			TeacherTask:setTeacherTaskAttr("receiveTask",receiveTask)
			self:deductTaskProp(receiveTask)
			TeacherTask:setTeacherTaskAttr("appointCount",tonumber(Helper:getDef(TeacherTask:getTeacherTaskAttr("appointCount"),0))+1)
			if func then
				func()
			end
		else
			PopText(errmsg)
		end
	end,IS_SHOW_WAITING)
end
--扣除任务相关道具
function AppointTeacherTaskLayer:deductTaskProp(task)
	if task.taskType == 2 then
		User:getRole():addItemCount(task.itemId,-1)
	end
end
function AppointTeacherTaskLayer:initRichTextPreview(str,DscArea,parent,textColor,name,verticalSpace)
	local x, y = DscArea:getPosition()
	local size = DscArea:getContentSize()
	size.height = size.height + 29
	DscArea:setVisible(false)
	if parent[name] then
		parent[name]:removeFromParent()
		parent[name] = nil
	end
	local richTextScroll = ExtRichTextScroll:create()
	richTextScroll:setAnchorPoint( 0.5 , 0.5 )
   	DscArea:getParent():addChild(richTextScroll)
   	local point = cc.p(DscArea:getPosition())
   	point.y = point.y - 20
   	richTextScroll:setPosition(point)
   	richTextScroll:setSize(size)
   	richTextScroll:setDirection(kCCScrollViewDirectionVertical)
   	richTextScroll:getRichText():setVerticalSpace(5)
   	parent[name] = richTextScroll
   	parent[name]:setBounceEnabled(false)
   	parent[name]:pushBackText(str, textColor, 255, Resource:getFontPath("default"), 42)
   	parent[name]:pushBackNewLine()
	parent[name]:pushBackNewLine(verticalSpace)
	parent[name]:setCascadeOpacity(255)
	parent[name]:setAnchorPoint(0.5000, 0.5000)
	parent[name]:setTouchEnabled(false)
end
Helper:classDefNodeGetInstance(AppointTeacherTaskLayer)
return AppointTeacherTaskLayer
000