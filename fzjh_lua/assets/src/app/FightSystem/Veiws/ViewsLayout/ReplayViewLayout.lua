--[[
    author:Seven
    time:2024-04-19 17:02:21
    desc: 重播布局文件
]]
local newClass = require("third.class.NewClass")

local UserViewLayout = require("app.FightSystem.Veiws.ViewsLayout.UserViewLayout")

--@SuperType [src.app.FightSystem.Veiws.ViewsLayout.UserViewLayout#UserViewLayout]
local ReplayViewLayout = {}

function ReplayViewLayout:create(...)
    return ReplayViewLayout.new():__init(...)
end

function ReplayViewLayout:__initButtonsAreaLayout()
    self.__mainView:setButtonAreaVisible(false)
end

return newClass("ReplayViewLayout", {UserViewLayout}, ReplayViewLayout)
00000000