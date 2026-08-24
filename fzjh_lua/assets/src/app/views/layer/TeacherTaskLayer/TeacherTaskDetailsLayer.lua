local TeacherTask  = require("app.models.task.teacherTask.teacherTask")
local TeacherTaskDetailsLayer = class("TeacherTaskDetailsLayer", cc.Layer)
local Npc = require("app.models.npc.Npc")
local tab = {
	taskCount = 0,--任务已完成数量
	refreshTaskCount = 0,--任务刷新次数
	tasks = { --任务列表

	},
	rewards = 0,
	appointCount = 0,--指派同门刷新次数
}

function TeacherTaskDetailsLayer:create()
	local p = TeacherTaskDetailsLayer:new()
	p:init()
	return p
end
function TeacherTaskDetailsLayer:init()
	local UI= require("Layer/TeacherTask/TeacherTaskDetails.lua").create()['root']
	UI:addTo(self)
	Helper:convertUIByParent(self) -- 获得所有子节点

end
function TeacherTaskDetailsLayer:enterLayer(func)
	local layer = self:getInstance()
	layer:show()
	layer:initLayer(func)
end
function TeacherTaskDetailsLayer:initLayer(func)
	local textColor = cc.c3b(255,255,255)
	self:setTitle()
	self:initRichTextPreview(self.Image_kuang.Text_desc,self.Image_kuang,textColor,"Text_dsc")
	self:setButtons(func)
	self:setNPCName()
	self:setMayGetReward()
	self.Panel_back:releaseFunc(function()
		self:hide()
	end)
	-- Helper:print_lua_table(TeacherTask:getTeacherTaskAttr("receiveTask"))
end
function TeacherTaskDetailsLayer:setMayGetReward()
	self.Text_1_0:setString("可能获得："..TeacherTask:getTeacherTaskExtraReward(TeacherTask:getTeacherTaskAttr("receiveTask").taskId))
end
function TeacherTaskDetailsLayer:setNPCName()
	local currNpc = Npc:getNpc(TeacherTask:getFamilyDsc().tasknpc)
	if currNpc == nil then
		assert("查不到相关任务NPC")
	end
	self.Text_3:setString(currNpc:getName().."：")
end
function TeacherTaskDetailsLayer:setButtons(func)
	self.ListView_1:removeAllItems()
	self:setStartDoButton()
	self:setAppointButton()
	self:setGoToDoButton()
	self:setGiveUpButton()
end
function TeacherTaskDetailsLayer:setTitle()
	local role = User:getRole()
	local task = TeacherTask:getTeacherTaskAttr("receiveTask")
	if task ~= nil then
		self.Panel_title.Text_title:setString(task.taskName)
		if task.taskQuality == 1 then
			self.Panel_title.Text_title:setTextColor({r = 57, g = 219, b = 92})
		elseif task.taskQuality == 2 then
			self.Panel_title.Text_title:setTextColor({r = 11, g = 128, b = 246})
		elseif task.taskQuality == 3 then
			self.Panel_title.Text_title:setTextColor({r = 204, g = 51, b = 204})
		elseif task.taskQuality == 4 then
			self.Panel_title.Text_title:setTextColor({r = 236, g = 101, b = 26})
		else
			PopText("稀有度颜色不存在")
		end
	else
		assert(nil)
	end
end

--开始任务
function TeacherTaskDetailsLayer:setStartDoButton()
	local panel = self:panelClone()
	panel.Button_start.Text_start:setString("开始任务")
	panel.Button_start:releaseFunc(function()
		if type(TeacherTask:getTeacherTaskAttr("isAppoint")) ~= "table" then
			local ControllLayer = require("app.views.layer.ControllLayer")
			local controllLayer = ControllLayer:getInstance()
			local RoleTaskControllor = require("app.views.layer.RoleLayer.RoleTaskControllor")
			if RoleTaskControllor:clickMapLayer(User:getRole()) == false then
				return
			end
			controllLayer:pushLayer("SelectMapLayer")
			local selectMapLayer = controllLayer:getLayer("SelectMapLayer")
			selectMapLayer:setMap(TeacherTask:getTeacherTaskAttr("receiveTask").mapId)
			self:setVisible(false)
		else
			PopText("任务已经指派出去，腾出手来做其他事情吧！")
		end
	end)
	self.ListView_1:pushBackCustomItem(panel)
end
--指派任务
function TeacherTaskDetailsLayer:setAppointButton()
	if TeacherTask:getTeacherTaskAttr("receiveTask").canAppoint == 0 then
		local panel = self:panelClone()
		panel.Button_start.Text_start:setString("指派任务")
		panel.Button_start:releaseFunc(function()
			if TeacherTask:checkCanAppoint() == true then
				if type(TeacherTask:getTeacherTaskAttr("isAppoint")) ~= "table"  then
					local AppointTeacherTaskLayer = require("app.views.layer.TeacherTaskLayer.AppointTeacherTaskLayer")
		        	AppointTeacherTaskLayer:enterLayer()
		        else
		        	PopText("任务已经指派出去，请稍候！")
		        end
		    else
		    	PopText("已达今日指派上限")
		    end
		end)
		self.ListView_1:pushBackCustomItem(panel)
    else
    	return
    end
end

--去完成
function TeacherTaskDetailsLayer:setGoToDoButton()
	local panel = self:panelClone()
	panel.Button_start.Text_start:setString("去完成")
	panel.Button_start:releaseFunc(function()
		if type(TeacherTask:getTeacherTaskAttr("isAppoint")) ~= "table" then
			local Item = require("app.models.item.Item")
			local item = Item:getOneItemByKey("dundifu")
			if not item then
				return
			end
			local controllLayer = require("app.views.layer.ControllLayer")
			controllLayer = controllLayer:getInstance()
			local title = controllLayer:getLayer("TitleLayer")
			title:setTitleBack()
			local PrintLayer = controllLayer:getLayer("PrintLayer")
			PrintLayer:setPanelVisible(false)
			local task = TeacherTask:getTeacherTaskAttr("receiveTask")
			item:useDunDiFu(User:getRole(), task.mapId, task.randomRoom, function()
				self:setVisible(false)
			end)
			-- end)
		else
			PopText("任务已经指派出去，腾出手来做其他事情吧！")
		end
	end)
	self.ListView_1:pushBackCustomItem(panel)
end

function TeacherTaskDetailsLayer:setGiveUpButton()
	local panel = self:panelClone()
	panel.Button_start.Text_start:setString("放弃任务")
	panel.Button_start:releaseFunc(function()
		local GiveUpTeacherTaskLayer = require("app.views.layer.TeacherTaskLayer.GiveUpTeacherTaskLayer")
    	GiveUpTeacherTaskLayer:enterLayer()
	end)
	self.ListView_1:pushBackCustomItem(panel)
end

function TeacherTaskDetailsLayer:panelClone()
	local panel = self.Panel_1:clone()
	Helper:convertUIByParent(panel)
	panel.Button_start.Text_start:setFontName("Font/default.ttf")
	panel.Button_start.Text_start:enableOutline({r = 26, g = 26, b = 26, a = 255}, 5)
	return panel
end
function TeacherTaskDetailsLayer:initRichTextPreview(DscArea,parent,textColor,name,verticalSpace)
	local x, y = DscArea:getPosition()
	local size = DscArea:getContentSize()
	DscArea:setVisible(false)
	if parent[name] then
		parent[name]:removeFromParent()
		parent[name] = nil
	end
	local str = "“ "..User:getRole():getReceiveTask().taskDsc.." ”"
	local richTextScroll = ExtRichTextScroll:create()
	richTextScroll:setAnchorPoint( 0.5 , 0.5 )
   	DscArea:getParent():addChild(richTextScroll)
   	local point = cc.p(DscArea:getPosition())
   	richTextScroll:move(point)
   	richTextScroll:setSize(size)
   	richTextScroll:setDirection(kCCScrollViewDirectionVertical)
   	richTextScroll:getRichText():setVerticalSpace(5)
   	parent[name] = richTextScroll
   	parent[name]:setBounceEnabled(false)
   	parent[name]:pushBackText(str, textColor, 255, Resource:getFontPath("default"), 48)
   	parent[name]:pushBackNewLine()
	parent[name]:pushBackNewLine(verticalSpace)
	parent[name]:setCascadeOpacity(255)
	parent[name]:setAnchorPoint(0.5000, 0.5000)
	parent[name]:setTouchEnabled(false)
end
Helper:classDefNodeGetInstance(TeacherTaskDetailsLayer)
return TeacherTaskDetailsLayer
00000000000