local DialogUI = require("app.views.ui.Dialog.Dialog4UI")

local DialogDLayer = class("DialogDLayer", cc.Layer)

function DialogDLayer:create()
    local p = DialogDLayer:new()
    p:init()
    return p
end

function DialogDLayer:init()
    self._UI = DialogUI:create()
    self._UI:addTo(self)
end

function DialogDLayer:show(text, desc)
    self._UI:show(text, desc)
end

function DialogDLayer:hide()
    self._UI:hide()
end

function DialogDLayer:setText(name, text)
    self._UI:setText(name, text)
end

function DialogDLayer:showTheDialog(func1, func2, func3, func4)
    self._UI:showTheDialog(func1, func2, func3, func4)
end

function DialogDLayer:setPanelHide(func)
    self._UI:setPanelHide(func)
end

Helper:classDefNodeGetInstance(DialogDLayer)
return DialogDLayer
0000