local BlackStoreResultPresenter = class("BlackStoreResultPresenter", cc.Layer)

function BlackStoreResultPresenter:create()
    local p = BlackStoreResultPresenter:new()
    p:init()
    return p
end

function BlackStoreResultPresenter:init()
    self._ui = require("app.views.ui.BlackStoreUI.BlackStoreResultUI"):create()

    self._ui:addTo(self)

    self:initButton2Func()
end

function BlackStoreResultPresenter:showLayer()
    self._ui:showUI()
end

function BlackStoreResultPresenter:hideLayer()
    PopupLayerController:hideLayer("BlackStoreResultPresenter",function()
        self._ui:hideUI()
    end)
end

function BlackStoreResultPresenter:setBuyText(text)
    self._ui:setText2Str(text)
end

function BlackStoreResultPresenter:setSellText(text)
    self._ui:setText3Str(text)
end

function BlackStoreResultPresenter:setTipText(text)
    self._ui:setText4Str(text)
end

function BlackStoreResultPresenter:setBoughttList(list)
    self._ui:setLeftList(list)
end

function BlackStoreResultPresenter:setSoldList(list)
    self._ui:setRightList(list)
end

function BlackStoreResultPresenter:setButton1Func(func)
    self._ui:setButton1Func(function()
        if func then
            func()
        end
    end)
end

function BlackStoreResultPresenter:initButton2Func()
    self._ui:setButton2Func(function()
        self:hideLayer()
    end)
end

Helper:classDefNodeGetInstance(BlackStoreResultPresenter)

return BlackStoreResultPresenter
000000000