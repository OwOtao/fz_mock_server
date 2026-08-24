--[[
Descripttion: 
version: 
Author: LvBin
Date: 2025-08-14 15:16:10
--]]
local CommercialTimePrivilegeComfirmPresent = class("CommercialTimePrivilegeComfirmPresent", cc.Layer)

local IOS_REWARD_STATUS = false

function CommercialTimePrivilegeComfirmPresent:create()
    local p = CommercialTimePrivilegeComfirmPresent:new()
    p:init()
    return p
end

function CommercialTimePrivilegeComfirmPresent:init()
    self.__ui = require("app.views.ui.Dialog.StoreDialog2UI"):create()

    self.__ui:addTo(self)

    self.__ui:setVisible(false)
end

function CommercialTimePrivilegeComfirmPresent:showLayer(showData)
	self.__ui:setTextTitle(showData.title)

	self.__ui:setText1(showData.text1)

	self.__ui:setText2(showData.text2)

	self.__ui:setText3(showData.text3)

	self.__ui:setImage(showData.imagePath)

	self.__ui:setButton1(showData.func1)

	self.__ui:setButton2(showData.func2)

    self.__ui:showUI()
end

function CommercialTimePrivilegeComfirmPresent:hideLayer()
    PopupLayerController:hideLayer(
        "CommercialTimePrivilegeComfirmPresent",
        function(layer)
            self.__ui:hideUI()
        end
    )
end

Helper:classDefNodeGetInstance(CommercialTimePrivilegeComfirmPresent)

return CommercialTimePrivilegeComfirmPresent
0000000