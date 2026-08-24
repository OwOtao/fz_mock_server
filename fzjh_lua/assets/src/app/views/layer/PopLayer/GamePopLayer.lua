local GamePopLayer = class("GamePopLayer", LayerEx)

function GamePopLayer:create()
	local p = GamePopLayer:new()
	p:init()
	return p
end

function GamePopLayer:init()
	self._UI = require("Layer/PopUI/GamePopUI.lua").create()['root']
	self._UI:addTo(self)

	Helper:convertUIByParent(self)
    self:setScale(0)
end

function GamePopLayer:showLayer()
    local action = cc.Sequence:create(
            cc.DelayTime:create(0.1),
            cc.ScaleTo:create(0.3, 1.0)
        )
    self:runAction(action)
end

function GamePopLayer:hideLayer()
    local action = cc.Sequence:create(
        cc.DelayTime:create(0.1),
        cc.ScaleTo:create(0.3, 0)
    )
    self:runAction(action)
end

function GamePopLayer:setText(text)
    self.Panel_bg.Text_1:setString(text)
end

function GamePopLayer:setTitle(title)
    self.Image_titleBack.Text_title:setString(title)
end

function GamePopLayer:setBackButtonFunc(func)
    self.Image_titleBack.Button_back:releaseFunc(function()
        if func then
            func()
        end
    end)
end

Helper:classDefNodeGetInstance(GamePopLayer)

return GamePopLayer0000000000000000