--[[
    author:Seven
    time:2023-11-06 17:18:55
    desc: 逃跑视图类
]]
local newClass = require("third.class.NewClass")

local ViewChangeWeapon = {}

function ViewChangeWeapon:create(...)
    return ViewChangeWeapon.new():__init(...)
end

function ViewChangeWeapon:__init(id, name, posIndex, isOpen)
    self.__id = id

    self.__name = name

    self.__posIndex = posIndex

    self.__isOpen = isOpen

    return self
end

function ViewChangeWeapon:getViewId()
    return self.__id
end

function ViewChangeWeapon:getViewName()
    return self.__name
end

function ViewChangeWeapon:getViewPosIndex()
    return tostring(self.__posIndex)
end

function ViewChangeWeapon:viewIsOpen()
    return self.__isOpen
end

function ViewChangeWeapon:setViewIsOpen(bool)
    self.__isOpen = bool
end

--@desc:更新
--@author:Seven
--@time:2023-11-13 17:04:44
--@mainView:[FightMainView]
--@isOpen: true | false
function ViewChangeWeapon:closeChangeWeaponView(mainView)
    if self.__isOpen ~= false then
        self.__isOpen = false
    end
    local ui = mainView:getPlayerButtonViewUI(self.__posIndex)
    ui:setVisible(false)
    ui:registerClickFunc(nil, nil, nil, nil)
end

--@desc:
--@author:Seven
--@time:2023-11-08 14:15:40
--@mainView: [FightMainView]
--@ui: [src.app.FightSystem.Veiws.PlayerButtonCtrlAreaViews.UI.PlayerButtonViewUI#PlayerButtonViewUI]
function ViewChangeWeapon:bindClickBtnUI(mainView, ui)
    ui:setBtnStatus(2)
    ui:setBtnName(self:getViewName())
    ui:setBtnProgressValue(1, 1)
    ui:setClickEnable(true)
    ui:setVisible(true)
    ui:registerClickFunc(
        nil,
        function()
            local FightCommons = require("app.FightSystem.FightCommons")
            mainView:sendPlayerInput(FightCommons.CHARACTER_OPERATION_TYPE.OPERATION_CHANGE_WEAPON, {})
        end,
        nil,
        nil
    )
end

return newClass("ViewChangeWeapon", {}, ViewChangeWeapon)
00000000000000