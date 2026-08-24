local class = require("third.class.NewClass")

local DreamMapRoleInfoPresenter = require("app.presenters.MapRole.RoleInfo.DreamMapRoleInfoPresenter")

local FoodDreamMapRoleInfoPresenter = {}

function FoodDreamMapRoleInfoPresenter:create()
    local p = FoodDreamMapRoleInfoPresenter.new()
    return p
end

function FoodDreamMapRoleInfoPresenter:__setEmotion()
    self.__ui:setTextEmotion("")
end

return class("FoodDreamMapRoleInfoPresenter", {DreamMapRoleInfoPresenter}, FoodDreamMapRoleInfoPresenter)
00000