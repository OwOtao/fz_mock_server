local class = require("third.class.NewClass")

local MapBag = require("app.models.bag.MapBag")

local BiWuMapBag = {}

function BiWuMapBag:create()
    return BiWuMapBag:new()
end

function BiWuMapBag:ctor()
end

function BiWuMapBag:getLeftButtonNameByItemId(itemId)
    return nil
end

return class("BiWuMapBag", {MapBag}, BiWuMapBag)
00000000000000