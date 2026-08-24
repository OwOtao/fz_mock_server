local OnlineGamePresenter = require("app.presenters.OnlineGame.OnlineGamePresenter")  
local OnlineGameModel = require("app.models.OnlineGame.OnlineGameModel")
local OnlineGamePlayerView = require("app.views.layer.OnlineGame.OnlinePlayerView")

local OnlineGameLayer = class("OnlineGameLayer", cc.Layer)

function OnlineGameLayer:create()
    local p = OnlineGameLayer.new()
    return p
end

function OnlineGameLayer:ctor()
    local onlineGameModel = OnlineGameModel:create()
    self._onlineGamePresenter = OnlineGamePresenter:create(self, onlineGameModel)
    onlineGameModel:setOutput(self._onlineGamePresenter)
end

function OnlineGameLayer:start()
    print("OnlineGameLayer:start")
    self._onlineGamePresenter:start()

    self:schedule(
        function(ft)
            self._onlineGamePresenter:update(ft)


            printMsg(3)
        end,
        0
    )

    self:registerKeyboard()
end

function OnlineGameLayer:createPlayer(playerModel)
    print("OnlineGameLayer:createPlayer", playerModel)
    local playerView = OnlineGamePlayerView:create(playerModel)
    self:addChild(playerView)
end

function OnlineGameLayer:registerKeyboard()
    local listener = cc.EventListenerKeyboard:create()
    local eventDispatcher = self:getEventDispatcher()

    local testTab = {}
    listener:registerScriptHandler(
        function(keyCode)
            self._onlineGamePresenter:inputKey(keyCode, cc.Handler.EVENT_KEYBOARD_PRESSED)
        end,
        cc.Handler.EVENT_KEYBOARD_PRESSED
    )

    listener:registerScriptHandler(
        function(keyCode)
            self._onlineGamePresenter:inputKey(keyCode, cc.Handler.EVENT_KEYBOARD_RELEASED)
        end,
        cc.Handler.EVENT_KEYBOARD_RELEASED
    )

    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
end

return OnlineGameLayer
0