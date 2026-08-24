local class = require("third.class.NewClass")

local ChallengeMapSystem = require("app.models.ChallengeMap.ChallengeMapSystem")

local MapRoleBagPresenter = require("app.presenters.MapRole.Bag.MapRoleBagPresenter")

local ChallengeMapRoleBagPresenter = {}

function ChallengeMapRoleBagPresenter:create()
    local p = ChallengeMapRoleBagPresenter.new()
    return p
end

function ChallengeMapRoleBagPresenter:addBuff(buffId,role)
    ChallengeMapSystem:getInstance():addBuff(buffId,role)
end

function ChallengeMapRoleBagPresenter:removeBuff(buffId,role)
    ChallengeMapSystem:getInstance():removeBuff(buffId,role)
end

return class("ChallengeMapRoleBagPresenter", {MapRoleBagPresenter}, ChallengeMapRoleBagPresenter)
00000000000