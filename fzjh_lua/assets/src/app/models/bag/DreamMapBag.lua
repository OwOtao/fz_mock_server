local class = require("third.class.NewClass")

local MapBag = require("app.models.bag.MapBag")

local DreamMapBag = {}

function DreamMapBag:create()
    return DreamMapBag:new()
end

function DreamMapBag:ctor()
end

function DreamMapBag:getLeftButtonNameByItemId(itemId)
    return nil
end

function DreamMapBag:createRoleDefaultItems()
    return {"shuxiang"}
end

return class("DreamMapBag", {MapBag}, DreamMapBag)
00000000