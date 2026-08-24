-- add by XiaoZhiWei 2017/09/12 14:33:20 
-----------------------------------------------------------------------------   
-----------------------------------------------------------------------------
------------------------        已弃用        -------------------------------
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------

-- local ActionDescLayer = require("app.views.layer.StoreLayer.ActionDescLayer")

-- local ActionLayer = class("ActionLayer", cc.Layer)

-- function ActionLayer:create()
-- 	local p = ActionLayer:new()	
-- 	p:init()
-- 	return p
-- end

-- function ActionLayer:init()
-- 	local UI = require("Layer/StoreUI/ActionUI.lua").create()['root']
-- 	UI:addTo(self)

-- 	Helper:convertUI(self)

-- 	self:setPanelBack()
-- 	self.Panel_row:setVisible(false)
-- end

-- function ActionLayer:show()
-- 	self:setVisible(true)

-- 	-- HttpManagerEx:getActionData(function(str)		
-- 	-- 	self:afterGetList(str)
-- 	-- end)
-- end

-- function ActionLayer:hide()
-- 	self:setVisible(false)
-- end

-- function ActionLayer:afterGetList(str)
-- 	if not str then
-- 		return
-- 	end
-- 	local list = assert(json.decode(str))
-- 	self.ListView_list:removeAllItems()


-- 	for k,v in pairs(list) do
-- 		local row = self:createOneRow(v)
-- 		row.Image_kuang:releaseFunc(function()
-- 			-- ActionDescLayer:getInstance():show()
-- 			-- print("进入活动页面")
-- 		end)

-- 		row.Image_button:releaseFunc(function()
-- 			ActionDescLayer:getInstance():show(v)
-- 			if PRINT_MODE == 1 then
-- 				print("按钮进入活动页面")
-- 			end
-- 		end)
-- 		row:setVisible(true)
-- 		self.ListView_list:pushBackCustomItem(row)

-- 	end
-- end

-- function ActionLayer:createOneRow(action)
-- 	if not action then
-- 		return
-- 	end
-- 	local row = self.Panel_row:clone()
-- 	Helper:convertUI(row)

-- 	local s=action.time
-- 	local p="(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)"
-- 	local year,month,day,hour,min,sec=s:match(p)
-- 	local offset = os.time({day=day,month=month,year=year,hour=hour,min=min,sec=sec}) - os.time()
-- 	day = math.floor(offset/3600/24)
-- 	hour = math.floor((offset - day*3600*24)/3600)

-- 	row.Text_title:setString(action.name)
-- 	row.Text_timeNum:setString("剩余"..day.."天"..hour.."小时")
-- 	row.Text_desc:setString(action.description)
-- 	row.Text_item:setString(action.itemdesc)
-- 	return row
-- end

-- function ActionLayer:setPanelBack()
-- 	self.Panel_back:releaseFunc(function()
-- 			self:hide()
-- 		end)
-- end

-- Helper:classDefNodeGetInstance(ActionLayer)

-- return ActionLayer  00000000000000