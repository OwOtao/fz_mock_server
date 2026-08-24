local ChoiceResultPresenter = class("ChoiceResultPresenter", cc.Layer)

function ChoiceResultPresenter:create()
    local p = ChoiceResultPresenter:new()
    p:init()
    return p
end

function ChoiceResultPresenter:init()
    self._UI = require("app.views.ui.Dialog.DialogChoiceUI"):create()
    self._UI:addTo(self)
    self._UI:hideUI()
end

function ChoiceResultPresenter:showLayer()
    self._UI:showUI()
end

function ChoiceResultPresenter:setTextDesc(text)
    self._UI:setTextDesc(text)
end

function ChoiceResultPresenter:setListView(array)
    local retArray = {}
    for i, v in ipairs(array) do
        table.insert(
            retArray,
            {
                name = v.buttonName,
                func = function()
                    if v.callback then
                        v.callback()
                        self:hideLayer()
                    end
                end
            }
        )
    end

    self._UI:setListView(retArray)
end

function ChoiceResultPresenter:hideLayer()
    PopupLayerController:hideLayer(
        "ChoiceResultPresenter",
        function(layer)
            self._UI:hideUI()
        end
    )
end

Helper:classDefNodeGetInstance(ChoiceResultPresenter)
return ChoiceResultPresenter
0