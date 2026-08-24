--[[
Descripttion: 
version: 
Author: LvBin
Date: 2025-02-10 16:23:42
--]]
local class = require("third.class.NewClass")

local DreamMapRoleAttrPresenter = {}

function DreamMapRoleAttrPresenter:create()
    local p = DreamMapRoleAttrPresenter.new()
    return p
end

function DreamMapRoleAttrPresenter:setInput(iRoleAttrModel)
    self.__input = iRoleAttrModel
end

function DreamMapRoleAttrPresenter:setUI(ui)
    self.__ui = ui
end

function DreamMapRoleAttrPresenter:showPresenter()
    PopupLayerController:showLayer("DreamMapRoleAttrUI",function(ui)
		self:setUI(ui)

        self:__showRoleAttr()
        
		self.__ui:showUI()
	end)
end

function DreamMapRoleAttrPresenter:__showRoleAttr()
    self.__ui:setTextMenPaiName(self.__input:getMenPaiName())

    self.__ui:setTextMenPaiDesc(self.__input:getMenPaiDesc())

    self.__ui:setTextCon(self.__input:getCon())

    self.__ui:setTextAtk(self.__input:getAtk())

    self.__ui:setTextStr(self.__input:getStr())

    self.__ui:setTextDodge(self.__input:getDodge())

    self.__ui:setTextDex(self.__input:getDex())

    self.__ui:setTextFangYu(self.__input:getFangYu())

    self.__ui:setTextDamage(self.__input:getDamage())

    self.__ui:setTextZhengQi(self.__input:getZhengQi())

    self.__ui:setTextFangHu(self.__input:getFangHu())
end

function DreamMapRoleAttrPresenter:hidePresenter()
    PopupLayerController:hideLayer("DreamMapRoleAttrUI",function(ui)
		ui:hideUI()
	end)
end

return class("DreamMapRoleAttrPresenter", {}, DreamMapRoleAttrPresenter)
0000