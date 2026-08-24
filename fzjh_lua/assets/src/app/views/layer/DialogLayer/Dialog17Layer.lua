local Dialog17Layer = class("Dialog17Layer", cc.Layer)

function Dialog17Layer:create()
    local p = Dialog17Layer:new()
    p:init()
    return p
end

function Dialog17Layer:init()
    self._UI = require("app.views.ui.Dialog.Dialog17UI"):create()
    self._UI:addTo(self)
end

function Dialog17Layer:showLayer()
    self._UI:showUI()
end


function Dialog17Layer:setTextDesc(text)
    self._UI:setTextDesc(text) 
end


function Dialog17Layer:setButtonClose(name,func)
    self._UI:setButtonClose(name,function()
        if func then
            func()
        end
    end)
end

function Dialog17Layer:setButtonConfirm(name,func)
    self._UI:setButtonConfirm(name,function()
        if func then
            func()
        end
    end)
end

function Dialog17Layer:hideLayer()
    PopupLayerController:hideLayer(
        "Dialog17Layer",
        function(layer)
            self._UI:hideUI()
        end
    )
end

Helper:classDefNodeGetInstance(Dialog17Layer)
return Dialog17Layer
0000000