local InheritMapRoleLayer = class("InheritMapRoleLayer", require("app.views.layer.MapLayer.MapRoleLayer"))

function InheritMapRoleLayer:create()
    local p = InheritMapRoleLayer.new()
    p:init()
    return p
end

function InheritMapRoleLayer:show(role)
	self:setVisible(true)
	self.__IsInit = false
	self._role = role
	self.Panel_leave:setVisible(false)
    self.Panel_bag_title:setVisible(false)
	self.Panel_skill_title:setVisible(false)

	local item = self.Panel_14
	item:setScale(1, 0.1)
end

function InheritMapRoleLayer:showPanelAttr()
	self.Text_attr:setColor(cc.c3b(242, 255, 32))

	local MapRoleAttr = require("app.models.MapRole.MapRoleAttr"):create()
	local MapRoleAttrPresenter = require("app.presenters.MapRole.RoleAttr.InheritMapRoleAttrPresenter"):create()

	MapRoleAttr:setRole(self._role)
    MapRoleAttrPresenter:setInput(MapRoleAttr)
    MapRoleAttrPresenter:setMainPresenter(self)
	MapRoleAttrPresenter:showPresenter()

	self.__mapRoleAttrPresenter = MapRoleAttrPresenter
end

return InheritMapRoleLayer
0000000000