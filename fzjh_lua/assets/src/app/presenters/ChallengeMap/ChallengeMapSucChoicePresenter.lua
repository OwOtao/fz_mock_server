--[[
Descripttion: 
version: 
Author: LvBin
Date: 2023-04-18 11:25:10
--]]
local ChallengeMapSucChoicePresenter = class("ChallengeMapSucChoicePresenter", cc.Layer)

function ChallengeMapSucChoicePresenter:create()
    local p = ChallengeMapSucChoicePresenter:new()
    p:init()
    return p
end

function ChallengeMapSucChoicePresenter:init()
    self.__ui = require("app.views.ui.Dialog.DialogEventChoiceUI"):create()
    self.__ui:addTo(self)

    self.__ui:hideUI()
end

function ChallengeMapSucChoicePresenter:showLayer()
    self:setTitle()

    self:setTextDesc()

    self:setButton1()

    self:setButton2()
    
    self.__ui:showUI()
end

function ChallengeMapSucChoicePresenter:setCallback(callback)
    self.__callback = callback
end

function ChallengeMapSucChoicePresenter:setTitle()
    self.__ui:setTitle("成功通关")
end

function ChallengeMapSucChoicePresenter:setTextDesc()
    self.__ui:setTextDesc("你已了结一段江湖恩怨，可以安心离开此地，请问需要离开吗？")
end

function ChallengeMapSucChoicePresenter:setButton1()
    self.__ui:setButton1("离开副本",function()
        self:hideLayer()

        if self.__callback then
            self.__callback()
        end
    end)
end

function ChallengeMapSucChoicePresenter:setButton2()
    self.__ui:setButton2("继续探索",function()
        self:hideLayer()
    end)
end

function ChallengeMapSucChoicePresenter:hideLayer()
    PopupLayerController:hideLayer(
        "ChallengeMapSucChoicePresenter",
        function(layer)
            self.__ui:hideUI()
        end
    )
end

Helper:classDefNodeGetInstance(ChallengeMapSucChoicePresenter)
return ChallengeMapSucChoicePresenter
000