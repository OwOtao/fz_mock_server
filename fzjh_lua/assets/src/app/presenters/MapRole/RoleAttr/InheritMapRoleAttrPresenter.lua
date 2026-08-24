local class = require("third.class.NewClass")

local MapRoleAttrPresenter = require("app.presenters.MapRole.RoleAttr.MapRoleAttrPresenter")

local InheritMapRoleAttrPresenter = {}

function InheritMapRoleAttrPresenter:create()
    local p = InheritMapRoleAttrPresenter.new()
    return p
end

function InheritMapRoleAttrPresenter:__setTextExp()
    self.__ui:setTextExp("【经验】 1")
end

function InheritMapRoleAttrPresenter:__setButtonJiaLi()
    self.__ui:setButtonVisible(1,false)
end

function InheritMapRoleAttrPresenter:__setButtonCsj()
    self.__ui:setButtonVisible(2,false)
end

function InheritMapRoleAttrPresenter:__setButtonQieCuo()
    self.__ui:setButtonVisible(3,false)
end

function InheritMapRoleAttrPresenter:__setButtonHuiFu()
    self.__ui:setButtonVisible(4,false)
end

function InheritMapRoleAttrPresenter:__setButtonLiaoShang()
    self.__ui:setButtonVisible(5,false)
end

function InheritMapRoleAttrPresenter:__setButtonDaZuo()
    self.__ui:setButtonVisible(6,false)
end

return class("InheritMapRoleAttrPresenter", {MapRoleAttrPresenter}, InheritMapRoleAttrPresenter)
0000000000000