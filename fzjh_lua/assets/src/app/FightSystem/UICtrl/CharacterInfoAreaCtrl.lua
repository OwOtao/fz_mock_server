local NewClass = require("third.class.NewClass")

local FightCommons = require("app.FightSystem.FightCommons")

local CharacterInfoAreaCtrl = {}

function CharacterInfoAreaCtrl:create()
    return self.new()
end

function CharacterInfoAreaCtrl:ctor()
    self.__playerId = nil

    self.__targetId = nil

    self.__leftCtrls = {}

    self.__rightCtrls = {}

    self.__leftInfoUIList = {}

    self.__rightInfoUIList = {}
end

function CharacterInfoAreaCtrl:setPlayerId(playerId)
    self.__playerId = playerId
end

function CharacterInfoAreaCtrl:setTargetId(targetId)
    self.__targetId = targetId
end

function CharacterInfoAreaCtrl:setFightUICtrl(fightUICtrl)
    --@RefType[Fight2Layer]
    self.__fightUICtrl = fightUICtrl
end

function CharacterInfoAreaCtrl:setInfoAreaUI(infoAreaUI)
    --@RefType [src.app.FightSystem.UICtrl.UI.CharacterInfoAreaUI#CharacterInfoAreaUI]
    self.__ui = infoAreaUI
end

function CharacterInfoAreaCtrl:init()
    for i = 1, FightCommons.TEAMMATE_COUNT do
        local playerTeamInfoUI

        if i == 1 then
            playerTeamInfoUI = self.__fightUICtrl:createLeftPlayerUI()
        else
            playerTeamInfoUI = self.__fightUICtrl:createLeftPlayerTeammateUI()
        end

        playerTeamInfoUI:setVisible(true)

        self:__insertInfoUILeftList(i, playerTeamInfoUI)

        self.__ui:insertCustomInfoUIToLeft(i, playerTeamInfoUI)

    end
    
    for i = 1, FightCommons.TEAMMATE_COUNT do
        local targetTeamInfoUI
        
        if i == 1 then
            targetTeamInfoUI = self.__fightUICtrl:createRightTargetUI()
        else
            targetTeamInfoUI = self.__fightUICtrl:createRightTeammateUI()
        end

        targetTeamInfoUI:setVisible(true)

        self:__insertInfoUIRightList(i, targetTeamInfoUI)
        
        self.__ui:insertCustomItemToRight(i, targetTeamInfoUI)
        
    end
end

function CharacterInfoAreaCtrl:__insertInfoUILeftList(index, infoUI)
    table.insert(self.__leftInfoUIList, index, infoUI)
end

function CharacterInfoAreaCtrl:__insertInfoUIRightList(index, infoUI)
    table.insert(self.__rightInfoUIList, index, infoUI)
end

--@desc: 绑定玩家队伍infoui对应的characterUICtrl
--@author:Seven
--@time:2021-07-01 20:14:05
function CharacterInfoAreaCtrl:__setLeftTeamCharacterUICtrlInfoUI(characterUICtrls)
    for i = 1, #self.__leftInfoUIList do
        --@RefType [src.app.FightSystem.UICtrl.UI.CharacterInfoUI.ICharacterInfoUI#ICharacterInfoUI]
        local infoUI = self.__leftInfoUIList[i]

        --@RefType [src.app.FightSystem.UICtrl.CharacterUICtrl#CharacterUICtrl]
        local c_uiCtrl = self.__leftCtrls[i]

        if c_uiCtrl then
            c_uiCtrl:setInfoUI(infoUI)
            c_uiCtrl:initCharacterUI()
            infoUI:setVisible(true)
        else
            infoUI:setVisible(false)
        end
    end
end

function CharacterInfoAreaCtrl:__setRightTeamCharacterUICtrlInfoUI(characterUICtrls)
    for i = 1, #self.__rightInfoUIList do
        --@RefType [src.app.FightSystem.UICtrl.UI.CharacterInfoUI.ICharacterInfoUI#ICharacterInfoUI]
        local infoUI = self.__rightInfoUIList[i]

        --@RefType [src.app.FightSystem.UICtrl.CharacterUICtrl#CharacterUICtrl]
        local c_uiCtrl = self.__rightCtrls[i]

        if c_uiCtrl then
            c_uiCtrl:setInfoUI(infoUI)
            c_uiCtrl:initCharacterUI()
            infoUI:setVisible(true)
        else
            infoUI:setVisible(false)
        end
    end
end

function CharacterInfoAreaCtrl:__sortLeftCharacterUICtrls()
    table.sort(
        self.__leftCtrls,
        function(a, b)
            if self.__playerId ~= nil and a:getId() == self.__playerId then
                return true
            end

            if self.__playerId ~= nil and b:getId() == self.__playerId then
                return false
            end

            return a:getPosIndex() < b:getPosIndex()
        end
    )
end

function CharacterInfoAreaCtrl:__sortRightCharacterUICtrls()
    table.sort(
        self.__rightCtrls,
        function(a, b)
            if self.__targetId ~= nil and a:getId() == self.__targetId then
                return true
            end

            if self.__targetId ~= nil and b:getId() == self.__targetId then
                return false
            end

            return a:getPosIndex() < b:getPosIndex()
        end
    )
end

function CharacterInfoAreaCtrl:__updateInfoUIZOrder()
    for i = 1, #self.__leftInfoUIList do
        --@RefType [src.app.FightSystem.UICtrl.UI.CharacterInfoUI.ICharacterInfoUI#ICharacterInfoUI]
        local infoUI = self.__leftInfoUIList[i]

        infoUI:getNode():setLocalZOrder(infoUI:getNode():getPositionY())
    end
    
    for i = 1, #self.__rightInfoUIList do
        --@RefType [src.app.FightSystem.UICtrl.UI.CharacterInfoUI.ICharacterInfoUI#ICharacterInfoUI]
        local infoUI = self.__rightInfoUIList[i]
        infoUI:getNode():setLocalZOrder(infoUI:getNode():getPositionY())
    end
end

--@desc: 左边列表添加角色管理器
--@author:Seven
--@time:2021-07-03 15:06:58
--@c_uiCtrl: [src.app.FightSystem.UICtrl.CharacterUICtrl#CharacterUICtrl]
function CharacterInfoAreaCtrl:addLeftCharacterUICtrl(c_uiCtrl)
    table.insert(self.__leftCtrls, c_uiCtrl)
end

--@desc: 右边列表添加角色管理器
--@author:Seven
--@time:2021-07-03 15:06:58
--@c_uiCtrl: [src.app.FightSystem.UICtrl.CharacterUICtrl#CharacterUICtrl]
function CharacterInfoAreaCtrl:addRightCharacterUICtrl(c_uiCtrl)
    table.insert(self.__rightCtrls, c_uiCtrl)
end

function CharacterInfoAreaCtrl:startFight()
    self:__sortLeftCharacterUICtrls()
    self:__setLeftTeamCharacterUICtrlInfoUI()

    self:__sortRightCharacterUICtrls()
    self:__setRightTeamCharacterUICtrlInfoUI()

    self:__updateInfoUIZOrder()

    self.__ui:startFight()
end

function CharacterInfoAreaCtrl:characterChangeTarget(chooserId, targetId)
    if self.__playerId == nil or self.__playerId ~= chooserId then
        return
    end

    if self.__targetId ~= targetId then
        self:setTargetId(targetId)

        self:__sortRightCharacterUICtrls()
        self:__setRightTeamCharacterUICtrlInfoUI()
    end
end

function CharacterInfoAreaCtrl:onUpdate(ft)
    self.__ui:onUpdate(ft)
end

function CharacterInfoAreaCtrl:onDestroy()
    
    self.__leftCtrls = {}

    self.__rightCtrls = {}

    self.__leftInfoUIList = {}

    self.__rightInfoUIList = {}
    self.__ui:destory()
end

return NewClass("CharacterInfoAreaCtrl", {}, CharacterInfoAreaCtrl)
000000