--[[
    author:Seven
    time:2023-10-23 11:52:17
    desc: 玩家按钮区域控制器
]]
local newClass = require("third.class.NewClass")

local PlayerButtonViewUI = require("app.FightSystem.Veiws.PlayerButtonCtrlAreaViews.UI.PlayerButtonViewUI")

local BUTTON_COUNT = 9

local PlayerButtonAreaViewCtrl = {}

function PlayerButtonAreaViewCtrl:create(mainView)
    return PlayerButtonAreaViewCtrl.new():__init(mainView)
end

function PlayerButtonAreaViewCtrl:ctor()
end

function PlayerButtonAreaViewCtrl:__init(mianView)
    --@RefType [FightMainView]
    self.__mainView = mianView

    self.__ui = self.__mainView:getUINode("ButtonsArea")
    Helper:convertUIByParent(self.__ui)

    self.__ui:setVisible(false)

    self:__initPlayerBtnViewUI()

    return self
end

function PlayerButtonAreaViewCtrl:startFightInit()
    self.__ui:setVisible(true)
end

function PlayerButtonAreaViewCtrl:__initPlayerBtnViewUI()
    self.__btnViewUIList = {}
    for i = 1, BUTTON_COUNT do
        --@RefType [src.app.FightSystem.Veiws.PlayerButtonCtrlAreaViews.UI.PlayerButtonViewUI#PlayerButtonViewUI]
        local btnViewUI = PlayerButtonViewUI:create(self.__mainView:getUINode("UserCtrlBtn"):clone())

        btnViewUI:setMainView(self.__mainView)

        btnViewUI:setBtnStatus(1)

        table.insert(self.__btnViewUIList, btnViewUI)

        self.__ui:addChild(btnViewUI:getNode())
    end

    local btnNode = self.__mainView:getUINode("UserCtrlBtn")
    Helper:foreachItemInMatrixArea(
        self.__ui:getContentSize(),
        btnNode:getContentSize(),
        3,
        3,
        80,
        60,
        function(index, ix, iy, x, y)
            local uiView = self.__btnViewUIList[index]
            uiView:setPosition(x, y)
            uiView:setVisible(true)
        end
    )
end

--@desc: 设置按钮区域可见性
--@author:Seven
--@time:2023-10-24 10:45:04
--@bool: true or false
function PlayerButtonAreaViewCtrl:setAreaVisible(bool)
    self.__ui:setVisible(bool)
end

--@desc: 获取按钮视图UI
--@author:Seven
--@time:2023-10-23 14:53:36
--@index: 索引
--@return [src.app.FightSystem.Veiws.PlayerButtonCtrlAreaViews.UI.PlayerButtonViewUI#PlayerButtonViewUI]
function PlayerButtonAreaViewCtrl:getBtnViewUI(index)
    return self.__btnViewUIList[index]
end

function PlayerButtonAreaViewCtrl:setBtnViewUIStatus(index, status)
    self:getBtnViewUI(index):setBtnStatus(status)
end

function PlayerButtonAreaViewCtrl:setBtnViewUIName(index, name)
    self:getBtnViewUI(index):setBtnName(name)
end

function PlayerButtonAreaViewCtrl:setBtnViewUIVisible(index, bool)
    self:getBtnViewUI(index):setVisible(bool)
end

function PlayerButtonAreaViewCtrl:setBtnViewUIEnable(index, bool)
    self:getBtnViewUI(index):setClickEnable(bool)
end

function PlayerButtonAreaViewCtrl:update(dt)
    for i = 1, BUTTON_COUNT do
        local ui = self:getBtnViewUI(i)

        ui:onUpdate(dt)
    end
end

return newClass("PlayerButtonAreaViewCtrl", {}, PlayerButtonAreaViewCtrl)
000000