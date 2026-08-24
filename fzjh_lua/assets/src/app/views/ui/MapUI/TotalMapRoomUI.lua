local TotalMapRoomUI = class("TotalMapRoomUI", ccui.Widget)

local buttonDirections = 
{
	"center",
	"left",
	"leftUp",
	"up",
	"rightUp",
	"right",
	"rightDown",
	"down",
	"leftDown"
}

function TotalMapRoomUI:create()
	local p = TotalMapRoomUI:new()	
	p:init()
	return p
end

function TotalMapRoomUI:init()
	self._drawNode = cc.DrawNode:create()
	self:addChild(self._drawNode)	

	-- 房间图标的宽高
	self._roomWidth = 100
	self._roomHeight = 100


	self.Text_name = ccui.Text:create()
	self:addChild(self.Text_name)
	self.Text_name:setFontSize(32)

	self:showRect()	
end

function TotalMapRoomUI:showRect()	
	local origin = cc.p(-self._roomWidth / 2, -self._roomHeight / 2)
	local destination = cc.p(self._roomWidth / 2, self._roomHeight / 2)

	self._drawNode:drawRect(origin, destination, cc.c4f(1, 1, 1, 1))
end

function TotalMapRoomUI:setName(name)
	self.Text_name:setString(name)
end

return TotalMapRoomUI000000000