-- add by XiaoZhiWei 2017/09/13 19:22:16 未调用

-- local FightResultPopLayer = class("FightResultPopLayer", require("app.views.base.BaseLayer"))

-- function FightResultPopLayer:create()
-- 	local p = FightResultPopLayer:new()
-- 	p:init()
-- 	return p
-- end

-- function FightResultPopLayer:init()
-- 	self._round = require("Layer/PopUI/FightResultPopUI.lua").create()['root']
-- 	self._round:addTo(self)
	
-- 	Helper:convertUIByParent(self) -- 获得所有子节点

-- 	self.Button_confirm:releaseFunc(
-- 		function()
-- 			self:hide(true)
-- 		end)
-- end

-- function FightResultPopLayer:setConfirmFunc(func)
-- 	self.Button_confirm:releaseFunc(
-- 		function()
-- 			self:hide(true)
-- 			if func then
-- 				func()
-- 			end
-- 		end)
-- end

-- function FightResultPopLayer:setTitle(title)
-- 	self.Test_title:setString(title)
-- end

-- function FightResultPopLayer:setDsc(dsc)
-- 	self.Text_main:setString(dsc)
-- end


-- Helper:classDefNodeGetInstance(FightResultPopLayer)
-- return FightResultPopLayer0000000000