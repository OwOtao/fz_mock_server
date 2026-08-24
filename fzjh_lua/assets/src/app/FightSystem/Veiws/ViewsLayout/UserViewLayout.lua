--[[
    author:Seven
    time:2023-10-23 20:29:18
    desc: 玩家视角界面布局
]]
local newClass = require("third.class.NewClass")

local ViewCharacterFactory = require("app.FightSystem.Veiws.ViewCommonModel.Character.ViewCharacterFactory")

local FightCommons = require("app.FightSystem.FightCommons")

local UserViewLayout = {}

function UserViewLayout:create(...)
    return UserViewLayout.new():__init(...)
end

function UserViewLayout:__init(mainView, fight)
    --@RefType [FightMainView]
    self.__mainView = mainView

    --@RefType [src.app.FightSystem.Fight.BattleSystem#Fight]
    self.__fight = fight

    local playerId = self.__fight:getPlayerId()

    local playerCharacter = self.__fight:getCharacter(playerId)
    local playerTeamId = playerCharacter:getTeamId()

    self.__playerTeams = {}
    table.insert(self.__playerTeams, ViewCharacterFactory:createViewCharacter(playerCharacter, fight))
    local playerTeamates = self.__fight:getTeammates(playerCharacter:getId())
    if not MapIsEmpty(playerTeamates) then
        for _, v in ipairs(playerTeamates) do
            table.insert(self.__playerTeams, ViewCharacterFactory:createViewCharacter(v, fight))
        end
    end

    self.__playerTargetTeams = {}
    local playerTarget = self.__fight:getAttackTarget(playerId)
    local playerTargetTeamId = playerTarget:getTeamId()
    table.insert(self.__playerTargetTeams, ViewCharacterFactory:createViewCharacter(playerTarget, fight))
    local playerTargetTeamates = self.__fight:getTeammates(playerTarget:getId())
    if not MapIsEmpty(playerTargetTeamates) then
        for _, v in ipairs(playerTargetTeamates) do
            table.insert(self.__playerTargetTeams, ViewCharacterFactory:createViewCharacter(v, fight))
        end
    end

    self.__playerId = playerId

    return self
end

function UserViewLayout:initLayout()
    self:__initCommentView()

    self:__initInfoAreaLayout()

    self:__initBattleAreaLayout()

    self:__initButtonsAreaLayout()
end

--@desc: 初始化视图层公用属性
--@author:Seven
--@time:2023-10-24 10:48:18
function UserViewLayout:__initCommentView()
    for i, v in ipairs(self.__playerTeams) do
        self.__mainView:addViewCharacter(v)
    end

    for i, v in ipairs(self.__playerTargetTeams) do
        self.__mainView:addViewCharacter(v)
    end
end

function UserViewLayout:__initInfoAreaLayout()
    for i, v in ipairs(self.__playerTeams) do
        self.__mainView:bindLeftInfoPanel(i, v)
    end

    for i, v in ipairs(self.__playerTargetTeams) do
        self.__mainView:bindRightInfoPanel(i, v)
    end
end

function UserViewLayout:__initBattleAreaLayout()
    --@RefType [src.app.FightSystem.Veiws.ViewCommonModel.Character.ViewCharacter#ViewCharacter]
    local playerViewCharacter = self.__playerTeams[1]

    local index = playerViewCharacter:getOriginPosIndex()

    if index > 3 then
        self.__mainView:setBattleAreaFilpFactor(-1)
    else
        self.__mainView:setBattleAreaFilpFactor(1)
    end

    for i, v in ipairs(self.__playerTeams) do
        self.__mainView:addBattleCharacterAnimView(v)

        if i == 1 then
            self.__mainView:setAnimHeadTag(v:getId(),"player")
        else
            self.__mainView:setAnimHeadTag(v:getId(),"other")
        end
    end

    for i, v in ipairs(self.__playerTargetTeams) do
        self.__mainView:addBattleCharacterAnimView(v)

        if i == 1 then
            self.__mainView:setAnimHeadTag(v:getId(),"target")
        else
            self.__mainView:setAnimHeadTag(v:getId(),"other")
        end
    end
end

function UserViewLayout:__initButtonsAreaLayout()
    --@RefType [src.app.FightSystem.Veiws.ViewCommonModel.Character.ViewCharacter#ViewCharacter]
    local playerViewCharacter = self.__playerTeams[1]

    for i = 1, FightCommons.PREP_ACT_MAX_COUNT do
        local viewActiveSkill = playerViewCharacter:getViewActiveSkillByIndex(i)
        local btnUI = self.__mainView:getPlayerButtonViewUI(i)
        if viewActiveSkill then
            viewActiveSkill:bindClickBtnUI(self.__mainView, btnUI)
        else
            btnUI:setBtnStatus(1)
        end
    end

    local qiRecover = playerViewCharacter:getQiRecover()
    local posIndex = qiRecover:getViewPosIndex()
    if qiRecover:viewIsOpen() then
        local ui = self.__mainView:getPlayerButtonViewUI(tonumber(posIndex))
        qiRecover:bindClickBtnUI(self.__mainView, ui)
    else
        self.__mainView:getPlayerButtonViewUI(tonumber(posIndex)):setVisible(false)
    end

    local changeWeapon = playerViewCharacter:getChangeWeapon()
    local posIndex = changeWeapon:getViewPosIndex()
    if changeWeapon:viewIsOpen() then
        local ui = self.__mainView:getPlayerButtonViewUI(tonumber(posIndex))
        changeWeapon:bindClickBtnUI(self.__mainView, ui)
    else
        self.__mainView:getPlayerButtonViewUI(tonumber(posIndex)):setVisible(false)
    end

    local runaway = playerViewCharacter:getRunaway()
    local posIndex = runaway:getViewPosIndex()
    if runaway:viewIsOpen() then
        local ui = self.__mainView:getPlayerButtonViewUI(tonumber(posIndex))
        runaway:bindClickBtnUI(self.__mainView, ui)
    else
        self.__mainView:getPlayerButtonViewUI(tonumber(posIndex)):setVisible(false)
    end
end

return newClass("UserViewLayout", {}, UserViewLayout)
000000000000000