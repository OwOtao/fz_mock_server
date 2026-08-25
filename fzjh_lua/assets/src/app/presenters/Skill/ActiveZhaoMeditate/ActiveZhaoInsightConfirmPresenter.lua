local ActiveZhaoInsightConfirmPresenter = class("ActiveZhaoInsightConfirmPresenter", cc.Layer)
local ActiveZhaoCanyeClass = require("app.models.skill.ActiveZhaoMeditate.Config.ActiveZhaoCanyeClass")

function ActiveZhaoInsightConfirmPresenter:create()
    local p = ActiveZhaoInsightConfirmPresenter:new()
    p:init()
    return p
end

function ActiveZhaoInsightConfirmPresenter:init()
    self.__ui = require("app.views.ui.SkillUI.ActiveZhaoMeditateUI.ActiveZhaoInsightConfirmUI"):create()

    self.__ui:addTo(self)
end

function ActiveZhaoInsightConfirmPresenter:showLayer()
    self:setButtonCancel()

	self.__ui:showUI()
end

function ActiveZhaoInsightConfirmPresenter:setLevelText(text)
	self.__ui:setLevelText(text)
end

function ActiveZhaoInsightConfirmPresenter:setEffectDscText(text)
	self.__ui:setEffectDscText(text)
end

function ActiveZhaoInsightConfirmPresenter:setConditionDscText(text)
	self.__ui:setConditionDscText(text)
end

function ActiveZhaoInsightConfirmPresenter:setResText(textArray)
	self.__ui:setResText(textArray)
end

function ActiveZhaoInsightConfirmPresenter:setButtonConfirm(func)
    self.__ui:setButtonConfirm(function()
        if func then
			func()
		end
		self:hideLayer()
    end)
end


function ActiveZhaoInsightConfirmPresenter:setButtonCancel()
    self.__ui:setButtonCancel(function()
        self:hideLayer()
    end)
end

function ActiveZhaoInsightConfirmPresenter:hideLayer()
    PopupLayerController:hideLayer(
        "ActiveZhaoInsightConfirmPresenter",
        function(layer)
            self.__ui:hideUI()
        end
    )
end

Helper:classDefNodeGetInstance(ActiveZhaoInsightConfirmPresenter)
return ActiveZhaoInsightConfirmPresenter
0000000