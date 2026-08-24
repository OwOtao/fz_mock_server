local NewClass = require("third.class.NewClass")
local IBuffSystemPresenter = require("app.models.ChallengeMap.BuffSystem.IBuffSystemPresenter")

local BuffSystemPresenter = {}

function BuffSystemPresenter:create()
    local p = BuffSystemPresenter:new()
    p:init()
    return p
end

function BuffSystemPresenter:init()
end

function BuffSystemPresenter:setOutput(iViewModel)
    self.__output = iViewModel
end

function BuffSystemPresenter:showAddBuff(printText)
    self.__output:print(printText)
end

function BuffSystemPresenter:showRemoveBuff(printText)
    self.__output:print(printText)
end

return NewClass("BuffSystemPresenter", {IBuffSystemPresenter}, BuffSystemPresenter)
0000000