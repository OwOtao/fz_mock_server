--[[
	UI作用  用于遮挡页面渐隐渐现可透视后面层级的问题
]]

local Resource = require("app.Resource")

local PanelBackUI = class("PanelBackUI", cc.Layer)

function PanelBackUI:create()
	local p = PanelBackUI:new()
	p:init()		
	return p
end

function PanelBackUI:init()
	self._round = require("Layer/PanelBackUI.lua").create()['root']
	self._round:addTo(self)
	
	Helper:convertUI(self) -- 获得所有子节点
end

function PanelBackUI:showAndHide(sDuration, hDuration, func)
	if not sDuration then
		sDuration = 1
	end
	if not hDuration then
		hDuration = 1
	end
	local item = self.Panel_back

	item:setOpacity(0)

	local actionTag = item:getActionTagByName("show")
	item:stopActionByTag(actionTag)
	local action = cc.Sequence:create(
			cc.Sequence:create(
				cc.FadeIn:create(sDuration),
				cc.CallFunc:create(function()
					if func then
						func()
					end
				end)
			),
			cc.FadeOut:create(hDuration)
		)
	action:setTag(actionTag)
	item:runAction(action)
end

Helper:classDefNodeGetInstance(PanelBackUI)

return PanelBackUI00000000000000