local ChallengeMapLosePresenter = class("ChallengeMapLosePresenter", cc.Layer)
local ChallengeMapConstant = require("app.models.ChallengeMap.ChallengeMapConstant")

function ChallengeMapLosePresenter:create()
    local p = ChallengeMapLosePresenter:new()
    p:init()
    return p
end

function ChallengeMapLosePresenter:init()
    self._UI = require("app.views.ui.ChallengeMapUI.ChallengeMapLoseUI"):create()
    self._UI:addTo(self)

    self._UI:hideUI()
end

function ChallengeMapLosePresenter:showLayer(itemList)
    self:setTextTitle()
    self:setTextDesc()
    self._UI:showUI()
end

function ChallengeMapLosePresenter:setButtonLeave(text, callback)
    self._UI:setButtonLeave(
        text,
        function()
            if callback then
                callback()
            end
        end
    )
end

function ChallengeMapLosePresenter:setTextTitle()
    self._UI:setTextTitle("战斗落败")
end

function ChallengeMapLosePresenter:setTextDesc()
    self._UI:setTextDesc("很不幸，你在本次战斗失败后陷入了昏迷，并且随身携带的物品散落一地，再起醒来后已不在原处。")
end

function ChallengeMapLosePresenter:hideLayer()
    PopupLayerController:hideLayer(
        "ChallengeMapLosePresenter",
        function(layer)
            self._UI:hideUI()
        end
    )
end

Helper:classDefNodeGetInstance(ChallengeMapLosePresenter)
return ChallengeMapLosePresenter
00000