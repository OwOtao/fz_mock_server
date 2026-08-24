

local DialogFourUI = class("DialogFourUI", cc.Layer)

function DialogFourUI:create()
	local p = DialogFourUI:new()
	p:init()
	return p
end

function DialogFourUI:init()
	self._round = require("Layer/Dialog/Dialog4UI.lua").create()['root']
	self._round:addTo(self)

	Helper:convertUIByParent(self) -- 获得所有子节点
end

function DialogFourUI:show()
	self.Text_1:setVisible(false)
	self.Text_2:setVisible(false)
	self.Text_3:setVisible(false)
	self.Text_4:setVisible(false)
	self.Text_5:setVisible(false)
	self.Panel_2:setVisible(false)
	self.Text_7:setVisible(false)
	self.Text_8:setVisible(false)
	self.Text_9:setVisible(false)
	self:setVisible(true)

	self:setOpacity(0)
	self:setCascadeOpacityEnabled(true)
	self:callAllChild(function(child)
			child:setCascadeOpacityEnabled(true)
		end)
	local actionTag = self:getActionTagByName("showOrHide")
	self:stopActionByTag(actionTag)
	local action = cc.Sequence:create(
		cc.FadeIn:create(0.5),
		cc.CallFunc:create(
			function()
			end))
	action:setTag(actionTag)
	self:runAction(action)	
end

function DialogFourUI:hide()
	self:setVisible(false)
end

function DialogFourUI:showTheDialog(func1, func2, fucn3, fucn4)
	local txt1, txt2, txt3, txt4, txt5, txt9 = self.Text_1, self.Text_2, self.Text_3, self.Text_4, self.Text_5, self.Text_9
	Audio:playEffect("yinDao")
	self:textFadeIn(txt1, true, function()
		Audio:playEffect("yinDao2")
		self:textFadeIn(txt2, true, function()
			Audio:playEffect("yinDao3")
			self:textFadeIn(txt3, true, function()
				
			end)
			self:delayFunc(1, function()
				Audio:playEffect("yinDao4")
				local panel = self.Panel_2:clone()
				Helper:convertUIByParent(panel)
				panel:setVisible(true)
				panel:addTo(self)

				panel:move(cc.p(540, 1040))
				panel.Text_6:setString("选择你的性别")
				panel.Button_1.Text_name:setString("男")
				panel.Button_2.Text_name:setString("女")
				panel.Button_3:setVisible(false)
				panel.Button_4:setVisible(false)
				panel.Button_1:releaseFunc(function()
					Audio:playEffect("yinDao5")
					panel:setVisible(false)
					self:delayFunc(1, function()
						Audio:playEffect("yinDao6")

						self.Panel_2.Text_6:setString("这位无名小辈出生在：")
						txt9:setString("无名小辈诞生了。")

						local sexFunc = function()
							if PRINT_MODE == 1 then
								print("男")
							end
							User:setRoleAttr("name", "无名小辈")
							User:setRoleAttr("sex", "男")
							User:setRoleAttr("age", 14)
						end
						
						self.Text_8:setString("英雄不问出生，这位无名小辈的江湖路开始了。")

						self:textFadeIn(txt9, true, function()
							Audio:playEffect("yinDao7")
							self:textFadeIn(txt4, true, function()
								self:textFadeIn(txt5, true, function()
									self:delayFunc(2, function()
										self:setPanelShow(func1, func2, fucn3, fucn4, sexFunc)
									end)
								end)
							end)
						end)
					end)
				end)	
				panel.Button_2:releaseFunc(function()
					Audio:playEffect("yinDao5")
					panel:setVisible(false)
					self:delayFunc(1, function()
						Audio:playEffect("yinDao6")
						

						self.Panel_2.Text_6:setString("这位无名少女出生在：")
						txt9:setString("无名少女诞生了。")

						local sexFunc = function()
							if PRINT_MODE == 1 then
								print("女")
							end
							User:setRoleAttr("name", "无名少女")
							User:setRoleAttr("sex", "女")
							User:setRoleAttr("age", 14)
						end
						
						self.Text_8:setString("英雄不问出生，这位无名少女的江湖路开始了。")

						self:textFadeIn(txt9, true, function()
							Audio:playEffect("yinDao7")
							self:textFadeIn(txt4, true, function()
								self:textFadeIn(txt5, true, function()
									self:delayFunc(2, function()
										self:setPanelShow(func1, func2, fucn3, fucn4, sexFunc)
									end)
								end)
							end)
						end)
					end)
				end)
			end)
		end)
	end)

end

function DialogFourUI:setButton(name, func)
	if not name then
		return
	end

	self.Panel_2[name]:releaseFunc(function()
		Audio:playEffect("xiaoAnNiu")
		if func then
			func()
		end
		Audio:playEffect("yinDao8")
	end)
end

function DialogFourUI:setText(name, text)
	if not name then
		return
	end
	self[name]:setString(text)
end

function DialogFourUI:setButton1(func)
	self:setButton("Button_1", func)
end

function DialogFourUI:setButton2(func)
	self:setButton("Button_2", func)
end

function DialogFourUI:setButton3(func)
	self:setButton("Button_3", func)
end

function DialogFourUI:setButton4(func)
	self:setButton("Button_4", func)
end

function DialogFourUI:setPanelShow(func1, func2, func3, func4, sexFunc)
	self.Panel_2:setVisible(true)
	self:setButton1(
		function()			
			func1(sexFunc)			
		end)
	self:setButton2(
		function()			
			func2(sexFunc)
		end)
	self:setButton3(
		function()			
			func3(sexFunc)
		end)
	self:setButton4(
		function()			
			func4(sexFunc)
		end)
end

function DialogFourUI:setPanelHide(func)
	self.Panel_2:setVisible(false)
	local txt7, txt8 = self.Text_7, self.Text_8
	self:textFadeIn(txt7, true, function()
		self:textFadeIn(txt8, true, function()
			self:delayFunc(1, function()

				self:delayFunc(0, function()
					local panel = self.Panel_back:clone()
					panel:addTo(self:getParent())
					panel:setOpacity(0)
					panel:setCascadeOpacityEnabled(true)
					panel:callAllChild(function(child)
							child:setCascadeOpacityEnabled(true)
						end)
					local actionTag = panel:getActionTagByName("showOrHide")
					panel:stopActionByTag(actionTag)
					local action = cc.Sequence:create(
						cc.CallFunc:create(function()
							-- local ControllLayer = require("app.views.layer.ControllLayer")
							-- ControllLayer:getInstance():pushLayer("MainLayer")
							if func then
								func()
							end
						end),
						cc.FadeIn:create(1),
						cc.DelayTime:create(2),
						-- cc.Spawn:create(
							-- cc.DelayTime:create(1),
							-- cc.CallFunc:create(function()
							-- end),
						-- ),
						cc.FadeOut:create(1),
						cc.CallFunc:create(function()
							panel:removeFromParent()
								-- 隐藏重置界面
								self:hide()
								self:callAllChild(function(child)
									child:setCascadeOpacityEnabled(true)
								end)
						end))
					action:setTag(actionTag)
					panel:runAction(action)						
				end)
			end)
		end)
	end)
end

function DialogFourUI:textFadeIn(item, anim, func)
	if not item then
		return
	end
	item:setVisible(true)
	item:setOpacity(0)
	-- item:setString(text)
	local x, y = item:getPosition()
	local actionTag = item:getActionTagByName("move")
	item:stopActionByTag(actionTag)
	if anim then
		item:move(cc.p(x, y-30))
		local action = cc.Sequence:create(
			cc.Spawn:create(
				cc.MoveTo:create(0.5, cc.p(x, y)), 
				cc.FadeIn:create(0.5)
			),
			cc.CallFunc:create(
				function()
					if func then
						self:delayFunc(2, function()
							func()
						end)
					end
				end))
		action:setTag(actionTag)
		item:runAction(action)	
	else
		item:move(cc.p(0, 0))
		item:resumeSelfAndChildren()
	end	
end

-- function DialogFourUI:textFadeOut(item, anim, func)
-- 	if not item then
-- 		return
-- 	end
-- 	local actionTag = item:getActionTagByName("move")
-- 	local x, y = item:getPosition()
-- 	item:setOpacity(255)
-- 	item:stopActionByTag(actionTag)
-- 	if anim then
-- 		item:setCascadeOpacityEnabled(true)
-- 		item:callAllChild(function(child)
-- 				child:setCascadeOpacityEnabled(true)
-- 			end)
-- 		local action = cc.Sequence:create(
-- 			cc.Spawn:create(
-- 				cc.MoveTo:create(0.5, cc.p(540, 1370)), 
-- 				cc.FadeOut:create(0.5)				
-- 				),
-- 			cc.CallFunc:create(
-- 				function()
-- 					if func then
-- 						func()
-- 					end
-- 					-- self:hide()
-- 				end))
-- 		action:setTag(actionTag)
-- 		item:runAction(action)	
-- 	else
-- 		item:move(cc.p(0, display.height))
-- 		item:pauseSelfAndChildren()
-- 	end	
-- end


return DialogFourUI00000000000000