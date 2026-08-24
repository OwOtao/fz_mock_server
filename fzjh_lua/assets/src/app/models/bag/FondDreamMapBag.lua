local class = require("third.class.NewClass")

local MapBag = require("app.models.bag.MapBag")

local FondDreamMapBag = {}

function FondDreamMapBag:create()
    return FondDreamMapBag:new()
end

function FondDreamMapBag:ctor()
end

function FondDreamMapBag:getLeftButtonNameByItemId(itemId)
    return nil
end

function FondDreamMapBag:createRoleDefaultItems()
    return {}
end

return class("FondDreamMapBag", {MapBag}, FondDreamMapBag)
00