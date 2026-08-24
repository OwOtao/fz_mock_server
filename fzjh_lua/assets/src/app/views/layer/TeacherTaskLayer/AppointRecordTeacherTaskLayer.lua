local TeacherTask  = require("app.models.task.teacherTask.teacherTask")
local AppointRecordTeacherTaskLayer = class("AppointRecordTeacherTaskLayer", cc.Layer)
local Npc = require("app.models.npc.Npc")
local tab = {
	taskCount = 0,--任务已完成数量
	refreshTaskCount = 0,--任务刷新次数
	tasks = { --任务列表

	},
	rewards = 0,
	appointCount = 0,--指派同门刷新次数
}

function AppointRecordTeacherTaskLayer:create()
	local p = AppointRecordTeacherTaskLayer:new()
	p:init()
	return p
end
function AppointRecordTeacherTaskLayer:init()
	local UI= require("Layer/TeacherTask/AppointRecordTeacherTask.lua").create()['root']
	UI:addTo(self)
	Helper:convertUIByParent(self) -- 获得所有子节点

end
function AppointRecordTeacherTaskLayer:enterLayer()
	local layer = self:getInstance()
	layer:show()
	layer:initLayer()
end
function AppointRecordTeacherTaskLayer:initLayer()
	--AppointRecordTeacherTaskLayer
	local familyTab = TeacherTask:getFamilyDsc()
	local TitleLayer = MainControllLayer:getLayer("TitleLayer")
	TitleLayer:setLayerTitleName("AppointRecordTeacherTaskLayer",familyTab.position)
	local textColor = cc.c3b(156,156,156)
	self:setTitle("今日指派记录")
	self.Panel_back3.ListView_9:removeAllItems()
	HttpManagerEx:getTeacherTaskRecord(function(status, errcode, errmsg, data)
		if status == 200 and errcode == 0 then
			print("******************************************************")
			Helper:print_lua_table(data)
			print("******************************************************")
			if #data == 0 then
				self.Text_1:setVisible(true)
				self.Text_1:setString("HIY今天你还没有指派任务给其他同门，\n也还没有人把任务指派给你 ")
			else
				self.Text_1:setVisible(false)
				for k,v in pairs(data) do 
					self:clonePanel(v)
				end
			end
		else
			PopText(errmsg)
		end
	end,IS_SHOW_WAITING)
	self:setBack()
end
function AppointRecordTeacherTaskLayer:setBack()
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
function AppointRecordTeacherTaskLayer:setTitle(str)
	self.Panel_back3.Text_title:setString(str)

end
function AppointRecordTeacherTaskLayer:initRichTextPreview(str,DscArea,parent,textColor,name,verticalSpace)
	local x, y = DscArea:getPosition()
	local size = DscArea:getContentSize()
	-- DscArea:setVisible(false)
	if parent[name] then
		parent[name]:removeFromParent()
		parent[name] = nil
	end
	local richTextScroll = ExtRichTextScroll:create()
	richTextScroll:setAnchorPoint( 0.5 , 0.5 )
   	DscArea:getParent():addChild(richTextScroll)
   	local point = cc.p(DscArea:getPosition())
   	-- point.y = point.y - 0
   	richTextScroll:move(point)
   	richTextScroll:setSize(size)
   	richTextScroll:setDirection(kCCScrollViewDirectionVertical)
   	richTextScroll:getRichText():setVerticalSpace(5)
   	parent[name] = richTextScroll
   	parent[name]:setBounceEnabled(false)
   	parent[name]:pushBackText(str, textColor, 255, Resource:getFontPath("default"), 42)
   	parent[name]:pushBackNewLine()
	parent[name]:pushBackNewLine(verticalSpace)
	parent[name]:setCascadeOpacity(0)
	parent[name]:setAnchorPoint(0.5000, 0.5000)
	parent[name]:setTouchEnabled(false)
	self:delayFunc(0.25,function ()
		parent[name]:jumpToTop()
		parent[name]:setCascadeOpacity(255)
	end)
end
function AppointRecordTeacherTaskLayer:clonePanel(list)
	local item = self.Panel_back3.Panel_item:clone()
	local textColor = cc.c3b(156,156,156)
	Helper:convertUI(item)
	-- item.Text_time
	item.Text_buttonName:enableOutline({r = 0, g = 0, b = 0, a = 255}, 5)
	local userId = User:getUserId()
	local str = ""
	if tonumber(list.userid) == tonumber(userId) then
		str = "HIW"..list.from_username.."NOR把师门任务"..list.task_name.."指派给你，你虽然诸事缠身，但还是硬着头皮完成了。"
	else
		str = "把师门任务"..list.task_name.."指派给HIW"..list.username.."NOR，HIW"..list.username.."NOR虽然不情不愿，但碍于同门情面，还是乖乖地完成了。"
	end
	self:initRichTextPreview(str,item.Panel_dsc,item,textColor,"Text_dsc")
	self.Panel_back3.ListView_9:pushBackCustomItem(item)
	if list.is_get then
		item.Button_receive:setVisible(true)
		if list.is_get == "N" then
			item.Text_buttonName:setString("领取奖励")
			item.Button_receive:releaseFunc(function()
				HttpManagerEx:getTeacherTaskRewaard(list.reward_id,function(status, errcode, errmsg, data)
					if status == 200 and errcode == 0 then
						for k,v in pairs(data) do 
							PopText("获得物品"..User:getRole():getCHAttrName(k).. " X "..tostring(v))
							if k == "money" then
								User:getRole():addAttr(k,tonumber(v))
							end
							item.Text_buttonName:setString("已领取")
							item.Button_receive:releaseFunc(function()
								PopText("奖励已经领取")
							end)
						end
					else
						PopText(errmsg)
					end
				end)
			end)
		else
			item.Text_buttonName:setString("已领取")
			item.Button_receive:releaseFunc(function()
				PopText("奖励已经领取")
			end)
		end
	else
		item.Button_receive:setVisible(false)
	end
	item.Text_time:setString(list.update_time)
end
Helper:classDefNodeGetInstance(AppointRecordTeacherTaskLayer)
return AppointRecordTeacherTaskLayer
00000