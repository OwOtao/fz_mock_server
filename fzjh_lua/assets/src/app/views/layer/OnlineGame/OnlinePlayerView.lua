local OnlineGamePresenter = require("app.presenters.OnlineGame.OnlineGamePresenter")  
local OnlineGameModel = require("app.models.OnlineGame.OnlineGameModel")

local OnlineGamePlayerView = class("OnlineGamePlayerView", cc.Sprite)

local function lerpPoint(from, to, t)
    local gap = cc.pMul(cc.pSub(to, from), t)
    return cc.pAdd(from, gap)
end

function OnlineGamePlayerView:create(iPlayerModel)
    local p = OnlineGamePlayerView:new("Image/UI/AttrUI/nan/20.png")
    p:init(iPlayerModel)
    return p
end

function OnlineGamePlayerView:ctor()
    self._iPlayerModel = nil
end

function OnlineGamePlayerView:init(iPlayerModel)
    assert(type(iPlayerModel) == "table")

    self._iPlayerModel = iPlayerModel

    self:initView()

    self:schedule(
        function(ft)
            self._iPlayerModel:update(1 / 30)
        end,
        1 / 30
    )

    self:schedule(
        function(ft)
            local position = lerpPoint(cc.p(self:getPosition()), self._iPlayerModel:getPosition(), 0.5)
            self:setPosition(position)
            -- self:setPosition(cc.p(self._iPlayerModel:getPosition()))
        end,
        0
    )
end

function OnlineGamePlayerView:initView()
    local sprite = cc.Sprite:create("Image/UI/AttrUI/nan/20.png")
    self:addChild(sprite)
end

return OnlineGamePlayerView
0000000000000