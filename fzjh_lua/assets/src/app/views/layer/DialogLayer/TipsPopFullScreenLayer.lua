--[[
    author:Seven
    time:2024-03-29 17:43:47
    desc: 全屏提示弹窗
]]
local TipsPopFullScreenLayer = class("TipsPopFullScreenLayer", LayerEx)

local ButtonPopUI = require("app.views.ui.PopUI.ButtonPopUI")

function TipsPopFullScreenLayer:create()
    return TipsPopFullScreenLayer:new():__init()
end

function TipsPopFullScreenLayer:__init()
    --@RefType [src.app.views.ui.PopUI.ButtonPopUI#ButtonPopUI]
    self.__ui = ButtonPopUI:create()

    self.__ui:getUI():addTo(self)

    return self
end

function TipsPopFullScreenLayer:showLayer(tip)
    self.__ui:setText(tip)
    self.__ui:show()
    self:show()
end

function TipsPopFullScreenLayer:setButton1(name, func)
    if name == nil or func == nil then
        self.__ui:setButton1()
        return
    end
    self.__ui:setButton1(
        name,
        function()
            self:hideLayer()
            func()
        end
    )
end

function TipsPopFullScreenLayer:setButton2(name, func)
    if name == nil or func == nil then
        self.__ui:setButton2()
        return
    end
    self.__ui:setButton2(
        name,
        function()
            self:hideLayer()
            func()
        end
    )
end

function TipsPopFullScreenLayer:hideLayer()
    PopupLayerController:hideLayer(
        "TipsPopFullScreenLayer",
        function()
            self:hide(
                function()
                    self.__ui:hide()
                end
            )
        end
    )
end

Helper:classDefNodeGetInstance(TipsPopFullScreenLayer)
return TipsPopFullScreenLayer
00000000000000