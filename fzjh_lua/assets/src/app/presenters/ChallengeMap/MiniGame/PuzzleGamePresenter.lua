local PuzzleGamePresenter = class("PuzzleGamePresenter", cc.Layer)

function PuzzleGamePresenter:create()
    local p = PuzzleGamePresenter:new()
    p:init()
    return p
end

function PuzzleGamePresenter:init()
    self._ui = require("app.views.ui.ChallengeMapUI.MiniGame.PuzzleGameUI"):create()

    self._ui:addTo(self)

    self._ui:setButtonBack(
        function()
            self:hideLayer()
        end
    )

    local PuzzleGame = require("app.models.MiniGame.PuzzleGame")

    self._interactor = PuzzleGame:create()
end

function PuzzleGamePresenter:showLayer()
    self:initData()
    self:initUI()
    self._ui:showUI()
end

function PuzzleGamePresenter:setGameId(id)
    self._interactor:setGameId(id)
end

function PuzzleGamePresenter:setMap(map)
    self._map = map
end

function PuzzleGamePresenter:setBaseResult(result)
    self._baseResult = result
end

function PuzzleGamePresenter:initData()
    self._interactor:initConfig()
    self._selectCount = 0
end

function PuzzleGamePresenter:replay()
    self._selectCount = 0

    local gameUIInfo = self._interactor:getGameUIInfo()

    for __, info in ipairs(gameUIInfo) do
        local visible = true

        if not info.text then
            visible = false
        end

        self._ui:setButtonEnable(info.index, true)

        self._ui:setButtonBackImgVisible(info.index, false)
    end
end

function PuzzleGamePresenter:initUI()
    self._ui:setTextTitle(self._interactor:getGameName())

    self._ui:setDesc(self._interactor:getGameDesc())

    local gameUIInfo = self._interactor:getGameUIInfo()

    for __, info in ipairs(gameUIInfo) do
        local visible = true

        if not info.text then
            visible = false
        end

        self._ui:setButtonEnable(info.index, true)

        self._ui:setButtonVisible(info.index, visible)

        self._ui:setButtonText(info.index, info.text)

        self._ui:setButtonFunc(info.index, function()
            self._selectCount = self._selectCount + 1
            if self._interactor:checkIsTrueAnswer(self._selectCount, info.index) then
                self._ui:setButtonBackImgVisible(info.index, true)
                self._ui:setButtonEnable(info.index, false)
                if self._interactor:checkIsLastSelect(self._selectCount) then
                    self._map:createExecuteResultGroupAsyncFunc(self._baseResult, self._interactor:getSuccessResults()):await()
                    self:hideLayer()
                end
            else
                self._map:createExecuteResultGroupAsyncFunc(self._baseResult, self._interactor:getFailureResults()):await()
                self:replay()
            end
        end)

        self._ui:setButtonBackImgVisible(info.index, false)
    end
end

function PuzzleGamePresenter:hideLayer()
    PopupLayerController:hideLayer(
        "PuzzleGamePresenter",
        function(layer)
            self._ui:hideUI()
        end
    )
end

Helper:classDefNodeGetInstance(PuzzleGamePresenter)

return PuzzleGamePresenter
0000000000000