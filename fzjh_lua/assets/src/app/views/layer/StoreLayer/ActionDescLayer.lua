-- add by XiaoZhiWei 2017/09/12 14:33:20 
-----------------------------------------------------------------------------   
-----------------------------------------------------------------------------
------------------------        已弃用        -------------------------------
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------

-- local ActionDescLayer = class("ActionDescLayer", cc.Layer)

-- function ActionDescLayer:create()
-- 	local p = ActionDescLayer:new()
-- 	p:init()
-- 	return p
-- end

-- function ActionDescLayer:init()
-- 	local UI = require("Layer/StoreUI/ActionDescUI.lua").create()['root']
-- 	UI:addTo(self)

-- 	Helper:convertUI(self)

-- 	self:setButtonClose()
-- 	self:setPanelBack()
-- end

-- function ActionDescLayer:show(action)
-- 	if not action then
-- 		return
-- 	end
-- 	self:setVisible(true)
-- 	self.Text_title:setString(action.name)
-- end

-- function ActionDescLayer:hide()
-- 	self:setVisible(false)
-- end

-- function ActionDescLayer:setImageKuang()
-- 	self.Image_kuang:releaseFunc(function()
-- 			if PRINT_MODE == 1 then
-- 				print("进入活动页面")
-- 			end
-- 		end)
-- end

-- function ActionDescLayer:setButtonClose()
-- 	self.Button_close:releaseFunc(function()
-- 			self:hide()
-- 		end)
-- end

-- function ActionDescLayer:setPanelBack()
-- 	self.Panel_back:releaseFunc(function()
-- 			self:hide()
-- 		end)
-- end

-- Helper:classDefNodeGetInstance(ActionDescLayer)

-- return ActionDescLayer
0000000000