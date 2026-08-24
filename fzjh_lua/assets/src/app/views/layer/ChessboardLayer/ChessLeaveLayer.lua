local ChessLeaveLayer = class("ChessLeaveLayer", cc.Layer)

function ChessLeaveLayer:create()
    local p = ChessLeaveLayer:new()
    p:init()
    return p
end

function ChessLeaveLayer:init()
    self._UI = require("app.views.ui.Chessboard.ChessLeaveUI"):create()
    self._UI:addTo(self)
end

function ChessLeaveLayer:showLayer(callback)
    self._callback = callback
    self:setButton1()
    self:setButton2()
    self:setLeaveText()
    self._UI:showUI()
end

function ChessLeaveLayer:setCurrFloorText(text)
    self._UI:setCurrFloorText(text)
end

function ChessLeaveLayer:setLeaveText()
    self._UI:setLeaveText("若少侠中途失败，可以再次观摩棋局。若少侠成功解开一局棋，近期将无法再次观摩棋局。还请少侠三思而后行。")
end

function ChessLeaveLayer:setButton1()
    self._UI:setButton1("继续观摩",function()
        self:hideLayer()
    end)
end

function ChessLeaveLayer:setButton2()
    self._UI:setButton2("抽身离去",function()
        if self._callback then
            self._callback()
        end
    end)
end

function ChessLeaveLayer:hideLayer()
    PopupLayerController:hideLayer(
        "ChessLeaveLayer",
        function(layer)
            self._UI:hideUI()
        end
    )
end

Helper:classDefNodeGetInstance(ChessLeaveLayer)
return ChessLeaveLayer
0000000000