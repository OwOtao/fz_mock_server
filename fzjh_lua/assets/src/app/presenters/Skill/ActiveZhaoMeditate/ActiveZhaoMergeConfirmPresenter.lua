local ActiveZhaoMergeConfirmPresenter = class("ActiveZhaoMergeConfirmPresenter", cc.Layer)
local ActiveZhaoCanyeClass = require("app.models.skill.ActiveZhaoMeditate.Config.ActiveZhaoCanyeClass")

function ActiveZhaoMergeConfirmPresenter:create()
    local p = ActiveZhaoMergeConfirmPresenter:new()
    p:init()
    return p
end

function ActiveZhaoMergeConfirmPresenter:init()
    self.__ui = require("app.views.ui.SkillUI.ActiveZhaoMeditateUI.ActiveZhaoMergeConfirmUI"):create()

    self.__ui:addTo(self)
end

function ActiveZhaoMergeConfirmPresenter:showLayer()
    self:setButtonCancel()

	self.__ui:showUI()
end

function ActiveZhaoMergeConfirmPresenter:setListView(uiList)
	self.__ui:setListView(uiList)
end

function ActiveZhaoMergeConfirmPresenter:setTextDsc(text)
	self.__ui:setTextDsc(text)
end

function ActiveZhaoMergeConfirmPresenter:setButtonConfirm(func)
    self.__ui:setButtonConfirm(function()
        if func then
			func()
		end

		self:hideLayer()
    end)
end

function ActiveZhaoMergeConfirmPresenter:setButtonCancel()
    self.__ui:setButtonCancel(function()
        self:hideLayer()
    end)
end

function ActiveZhaoMergeConfirmPresenter:hideLayer()
    PopupLayerController:hideLayer(
        "ActiveZhaoMergeConfirmPresenter",
        function(layer)
            self.__ui:hideUI()
        end
    )
end

Helper:classDefNodeGetInstance(ActiveZhaoMergeConfirmPresenter)
return ActiveZhaoMergeConfirmPresenter
0000000000000