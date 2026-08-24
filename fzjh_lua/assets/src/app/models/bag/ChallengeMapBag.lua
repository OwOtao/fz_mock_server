--[[
Descripttion: 
version: 
Author: LvBin
Date: 2024-09-12 15:29:26
--]]
local class = require("third.class.NewClass")

local MapBag = require("app.models.bag.MapBag")

local ChallengeMapBag = {}

function ChallengeMapBag:create()
    return ChallengeMapBag:new()
end

function ChallengeMapBag:ctor()
end

function ChallengeMapBag:getLeftButtonNameByItemId(itemId)
    return nil
end

function ChallengeMapBag:createRoleDefaultItems()
    return {}
end

return class("ChallengeMapBag", {MapBag}, ChallengeMapBag)
0