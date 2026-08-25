local ActiveZhaoStopInsightPresenter = class("ActiveZhaoStopInsightPresenter", cc.Layer)
local ActiveZhaoCanyeClass = require("app.models.skill.ActiveZhaoMeditate.Config.ActiveZhaoCanyeClass")

function ActiveZhaoStopInsightPresenter:create()
    local p = ActiveZhaoStopInsightPresenter:new()
    p:init()
    return p
end

function ActiveZhaoStopInsightPresenter:init()
    self.__ui = require("app.views.ui.SkillUI.ActiveZhaoMeditateUI.ActiveZhaoStopInsightUI"):create()

    self.__ui:addTo(self)
end

function ActiveZhaoStopInsightPresenter:setRole(role)
	self.__role = role

	self.__sys = self.__role:getActiveZhaoMeditateSystem()
end

function ActiveZhaoStopInsightPresenter:showLayer()
	self.__time = self.__sys:getResidueTime()

	self.__ui:setTextDsc("终止后本次领悟不获得熟练度，不会返还任何资源，已挂机时间作废，是否终止？")

    self:setTimeText()

    self:setButtonCancel()

    self.__handle =
            self:schedule(
            function(ft)
                self.__time = self.__time - ft

                if self.__time < 0 then
                    self.__time = 0
                    self:unschedule(self.__handle)
                    self.__handle = nil
                end

                self:setTimeText()
            end,1
        )

	self.__ui:showUI()
end

function ActiveZhaoStopInsightPresenter:setTimeText()
	local text = "剩余领悟所需时间："..Helper:getTimeString(self.__time)
    
	self.__ui:setTimeText(text)
end

function ActiveZhaoStopInsightPresenter:setButtonConfirm(func)
    self.__ui:setButtonConfirm(function()
        if func then
			func()
		end
		self:hideLayer()
    end)
end

function ActiveZhaoStopInsightPresenter:setButtonCancel()
    self.__ui:setButtonCancel(function()
        self:hideLayer()
    end)
end

function ActiveZhaoStopInsightPresenter:hideLayer()
    PopupLayerController:hideLayer(
        "ActiveZhaoStopInsightPresenter",
        function(layer)
            self.__ui:hideUI()
            if self.__handle then
                self:unschedule(self.__handle)
                self.__handle = nil
            end
        end
    )
end

Helper:classDefNodeGetInstance(ActiveZhaoStopInsightPresenter)
return ActiveZhaoStopInsightPresenter
000