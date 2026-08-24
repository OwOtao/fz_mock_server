--[[
    author:Seven
    time:2023-11-06 17:18:55
    desc: 逃跑视图类
]]
local newClass = require("third.class.NewClass")

local ViewRunaway = {}

function ViewRunaway:create(...)
    return ViewRunaway.new():__init(...)
end

function ViewRunaway:__init(id, name, cooldownTime, posIndex, isOpen)
    self.__id = id

    self.__name = name

    self.__posIndex = posIndex

    self.__cd = 0

    self.__cooldownTime = cooldownTime

    self.__isOpen = isOpen

    return self
end

function ViewRunaway:getViewId()
    return self.__id
end

function ViewRunaway:getViewName()
    return self.__name
end

function ViewRunaway:getViewPosIndex()
    return tostring(self.__posIndex)
end

function ViewRunaway:setViewCD(cd)
    self.__cd = cd
end

function ViewRunaway:getViewCD()
    return self.__cd
end

function ViewRunaway:getViewCooldownTime()
    return self.__cooldownTime
end

function ViewRunaway:viewIsOpen()
    return self.__isOpen
end

--@desc: 更新视图层主动技能CD时间间隔
--@author:Seven
--@time:2023-10-26 14:43:36
--@mainView: [FightMainView]
--@oldCd: 旧的CD时间
--@newCd: 新的CD时间
--@ft: 时间间隔
function ViewRunaway:updateViewCd(mainView, oldCd, newCd, ft)
    self:killUpdateCDTween()

    self:setViewCD(oldCd)

    self.__updateCDTween =
        mainView:doUINumberTween(
        function()
            return self:getViewCD()
        end,
        function(value)
            self:setViewCD(value)
            local percent = (self:getViewCooldownTime() - value) / self:getViewCooldownTime()
            mainView:getPlayerButtonViewUI(self.__posIndex):setBtnProgressValue(value, self:getViewCooldownTime())
        end,
        newCd,
        ft
    )
end

function ViewRunaway:killUpdateCDTween()
    if self.__updateCDTween then
        self.__updateCDTween:kill()
        self.__updateCDTween = nil
    end
end

--@desc:
--@author:Seven
--@time:2023-11-08 14:15:40
--@mainView: [FightMainView]
--@ui: [src.app.FightSystem.Veiws.PlayerButtonCtrlAreaViews.UI.PlayerButtonViewUI#PlayerButtonViewUI]
function ViewRunaway:bindClickBtnUI(mainView, ui)
    ui:setBtnStatus(2)
    ui:setBtnName(self:getViewName())
    ui:setBtnProgressValue(self:getViewCooldownTime() - self:getViewCD(), self:getViewCooldownTime())
    ui:setClickEnable(true)
    ui:setVisible(true)
    ui:registerClickFunc(
        nil,
        function()
            local FightCommons = require("app.FightSystem.FightCommons")
            mainView:sendPlayerInput(FightCommons.CHARACTER_OPERATION_TYPE.OPERATION_RUNAWAY, {})
        end,
        nil,
        nil
    )
end

return newClass("ViewRunaway", {}, ViewRunaway)
00000000000