local ActiveZhaoMeditateConfirmPresenter = class("ActiveZhaoMeditateConfirmPresenter", cc.Layer)
local ActiveZhaoCanyeClass = require("app.models.skill.ActiveZhaoMeditate.Config.ActiveZhaoCanyeClass")

function ActiveZhaoMeditateConfirmPresenter:create()
    local p = ActiveZhaoMeditateConfirmPresenter:new()
    p:init()
    return p
end

function ActiveZhaoMeditateConfirmPresenter:init()
    self.__ui = require("app.views.ui.SkillUI.ActiveZhaoMeditateUI.ActiveZhaoMeditateConfirmUI"):create()

    self.__ui:addTo(self)
end

function ActiveZhaoMeditateConfirmPresenter:showLayer()
    self:setButtonCancel()

	self.__ui:showUI()
end

function ActiveZhaoMeditateConfirmPresenter:setDscText(text)
	self.__ui:setDscText(text)
end

function ActiveZhaoMeditateConfirmPresenter:setText1(text)
	self.__ui:setText1(text)
end

function ActiveZhaoMeditateConfirmPresenter:setText2(text)
	self.__ui:setText2(text)
end

function ActiveZhaoMeditateConfirmPresenter:setResText(textArray)
	self.__ui:setResText(textArray)
end

function ActiveZhaoMeditateConfirmPresenter:setButtonConfirm(func)
    self.__ui:setButtonConfirm(function()
        if func then
			func()
		end
		self:hideLayer()
    end)
end


function ActiveZhaoMeditateConfirmPresenter:setButtonCancel()
    self.__ui:setButtonCancel(function()
        self:hideLayer()
    end)
end

function ActiveZhaoMeditateConfirmPresenter:hideLayer()
    PopupLayerController:hideLayer(
        "ActiveZhaoMeditateConfirmPresenter",
        function(layer)
            self.__ui:hideUI()
        end
    )
end

Helper:classDefNodeGetInstance(ActiveZhaoMeditateConfirmPresenter)
return ActiveZhaoMeditateConfirmPresenter
0000000000000000