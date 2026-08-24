local inherit = require("third.inherit.inherit")

local OnlineGamePresenter = {}

function OnlineGamePresenter:create(iOnlineGamePresenterOutput, iOnlineGameModel)
    local p = inherit({}, OnlineGamePresenter)
    p:init(iOnlineGamePresenterOutput, iOnlineGameModel)
    return p
end

function OnlineGamePresenter:init(iOnlineGamePresenterOutput, iOnlineGameModel)
    self._iOnlineGamePresenterOutput = iOnlineGamePresenterOutput
    self._iOnlineGameModel = iOnlineGameModel
end

function OnlineGamePresenter:start()
    self._iOnlineGameModel:start(
        function(success)
            if success then
                self:createPlayer()
            end
        end
    )
end

function OnlineGamePresenter:createPlayer(playerModel)
    print("OnlineGamePresenter:createPlayer", playerModel)

    self._iOnlineGamePresenterOutput:createPlayer(playerModel)
end

function OnlineGamePresenter:update(ft)
    self._iOnlineGameModel:update(ft)
end

function OnlineGamePresenter:inputKey(keyCode, eventType)
    self._iOnlineGameModel:inputKey(keyCode, eventType)
end

return OnlineGamePresenter
0