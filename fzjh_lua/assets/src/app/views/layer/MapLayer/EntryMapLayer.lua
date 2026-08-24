local EntryMapLayer = class("EntryMapLayer", LayerEx)

function EntryMapLayer:create()
	local p = EntryMapLayer:new()
	p:init()
	return p
end

function EntryMapLayer:init()
	local UI = require("Layer/MapUI/EntryMapUI.lua").create()['root']
	UI:addTo(self)
	Helper:convertUI(self) -- 获得所有子节点

	local animOffset = 5
	local interval = 0.111

	local action = cc.RepeatForever:create(
	cc.Sequence:create(
	cc.MoveBy:create(interval, cc.p(0, animOffset + 3)),
	cc.MoveBy:create(interval, cc.p(0, -(animOffset + 3))),
	cc.MoveBy:create(interval, cc.p(0, animOffset)),
	cc.MoveBy:create(interval, cc.p(0, animOffset)),
	cc.MoveBy:create(interval, cc.p(0, animOffset)),
	cc.MoveBy:create(interval, cc.p(0, -animOffset)),
	cc.MoveBy:create(interval, cc.p(0, animOffset)),
	cc.MoveBy:create(interval, cc.p(0, -animOffset))))

	self.Text_center:runAction(action)

	action = cc.RepeatForever:create(
	cc.Sequence:create(
	cc.CallFunc:create(function()
		Audio:playEffect("carriage")
	end),
	cc.DelayTime:create(0.888)
	))
	self.Text_center:runAction(action)

	self:setCenterText()
end

function EntryMapLayer:setMap(map)
end

function EntryMapLayer:show(backImgPath)
	-- body
	if backImgPath == nil then
		backImgPath = "Image/UI/MapUI/beijing.png"
	end

	self.Image_back:loadTexture(backImgPath,0)
	self:setVisible(true)
end

function EntryMapLayer:setCenterText(mapName)
	mapName = Helper:getDef(mapName, "你在马车里,浑然不知外面的情景.\n马车晃呀晃呀,走走停停,不知道过了多久...")
	self.Text_center:setString(mapName)
end

Helper:classDefNodeGetInstance(EntryMapLayer)
return EntryMapLayer
00000000000