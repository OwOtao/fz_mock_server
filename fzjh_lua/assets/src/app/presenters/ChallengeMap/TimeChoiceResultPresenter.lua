local TimeChoiceResultPresenter = class("TimeChoiceResultPresenter", cc.Layer)

function TimeChoiceResultPresenter:create()
    local p = TimeChoiceResultPresenter:new()
    p:init()
    return p
end

function TimeChoiceResultPresenter:init()
    self.__ui = require("app.views.ui.Dialog.DialogSelectButtonUI"):create()
    self.__ui:addTo(self)

    self.__ui:hide()
end

function TimeChoiceResultPresenter:showLayer()
    self.__durationTime = 0

    self:setTextDesc()

    self:setButtonListView()

    self:setLoadingBarPercent(100)

    self:createSchedule()
    
    self.__ui:show()
end

function TimeChoiceResultPresenter:setTime(time)
    self.__time = time
end

function TimeChoiceResultPresenter:setDesc(text)
    self.__desc = text
end

function TimeChoiceResultPresenter:setButtonList(buttonList)
    self.__buttonList = buttonList
end

function TimeChoiceResultPresenter:setDefaultCallBack(callback)
    self.__defaultCallBack = callback
end

function TimeChoiceResultPresenter:setTextDesc()
    self.__ui:setTextDesc(self.__desc)
end

function TimeChoiceResultPresenter:setLoadingBarPercent(percent)
    self.__ui:setLoadingBarPercent(percent)
end

function TimeChoiceResultPresenter:updata(ft)
    self.__durationTime = self.__durationTime + ft

    local residueTime = self.__time - self.__durationTime

    if residueTime > 0 then
        self:setLoadingBarPercent((residueTime/self.__time) * 100)
    else
        self:clearSchedule()

        self:setLoadingBarPercent(0)

        self:executeDefaultCallBack()

        self:hideLayer()
    end
end

function TimeChoiceResultPresenter:createSchedule()
    if self.__schedule then
        self:clearSchedule()
    end

    self.__schedule =
        self:schedule(
        function(ft)
            self:updata(ft)
        end,
        0
    )
end

function TimeChoiceResultPresenter:clearSchedule()
    if self.__schedule then
        self:unschedule(self.__schedule)

        self.__schedule = nil
    end
end

function TimeChoiceResultPresenter:setButtonListView()
    local retArray = {}
    for i, v in ipairs(self.__buttonList) do
        table.insert(
            retArray,
            {
                name = v.buttonName,
                func = function()
                    if v.callback then
                        v.callback()
                    end
                    self:hideLayer()
                    
                    self:clearSchedule()
                end
            }
        )
    end

    self.__ui:setButtonListView(retArray)
end

function TimeChoiceResultPresenter:executeDefaultCallBack()
    if type(self.__defaultCallBack) == "function" then
        self.__defaultCallBack()
    end 
end

function TimeChoiceResultPresenter:hideLayer()
    PopupLayerController:hideLayer(
        "TimeChoiceResultPresenter",
        function(layer)
            self.__ui:hide()
        end
    )
end

Helper:classDefNodeGetInstance(TimeChoiceResultPresenter)
return TimeChoiceResultPresenter
000000