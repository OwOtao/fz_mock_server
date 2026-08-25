--[[
    author:Seven
    time:2022-06-23 16:30:41
    desc: 战场入场状态
]]
local newClass = require("third.class.NewClass")

local AFightState = require("app.FightSystem.FightState.State.AFightState")

--@RefType [src.app.FightSystem.FightState.FightStateMachine#FightStateMachine]
local FightStateMachine = require("app.FightSystem.FightState.FightStateMachine")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local AnimResManager = require("app.FightSystem.ResourceManager.AnimResManager")

local FightCommons = require("app.FightSystem.FightCommons")

--@RefType [Constants]
local BUFF_CONSTANT = require("app.FightSystem.FightBuff.Constants")
local BUFF_ADDER_TRIGGER_TYPE = BUFF_CONSTANT.ADDER_TRIGGER_TYPE
local ADD_BUFF_NODE_TYEP = BUFF_CONSTANT.ADD_BUFF_NODE_TYEP

local FightSkillHelper = require("app.FightSystem.FightRole.CharacterSkillSystem.FightCharacterSkillHelper")

--@SuperType [src.app.FightSystem.FightState.State.AFightState#AFightState]
local FightEnterState = {}

--@desc 进入状态维持最短时间
local SHORT_WAIT_TIME = 1

function FightEnterState:create()
    return FightEnterState.new()
end

function FightEnterState:ctor()
end

function FightEnterState:onInitState()
end

function FightEnterState:onDestoryState()
end

function FightEnterState:onEnterState()
    FightUtil:printLog("战场进入进场状态")

    self.__waitingList = self.__fight:getWaitingEnterCharacters()

    self.__mustWaitTime = SHORT_WAIT_TIME

    self.__runTime = 0

    local maxTime = 0

    local enterContext = {
        characterEnter = {}
    }

    if MapIsEmpty(self.__waitingList) == false then
        for i, character in ipairs(self.__waitingList) do
            --@RefType [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
            local character = character

            FightSkillHelper:addActiveSkillEnterBuffAdder(character)
            FightSkillHelper:addKnowledgeFightSkillEnterBuffAdder(character)

            local joinAnimResId = character:getJoinAnimId()

            if joinAnimResId ~= nil then
                local time = AnimResManager:getAnimTime(AnimResManager:getOtherAnimName(joinAnimResId))

                if time > maxTime then
                    maxTime = time
                end

                enterContext.characterEnter[character:getId()] = {
                    animId = joinAnimResId
                }
            end
        end
    end

    if maxTime > SHORT_WAIT_TIME then
        self.__mustWaitTime = maxTime
    end

    local enterViewEvent = require("app.FightSystem.Veiws.ViewEvents.Events.FightEnterViewEvent"):create(enterContext)
    self.__fight:notifyVeiwEvent(enterViewEvent)
end

function FightEnterState:onExitState()
    FightUtil:printLog("战场退出进场状态")
    self.__runTime = nil
    self.__waitingList = nil
end

function FightEnterState:onUpdateState(ft)
    self.__runTime = self.__runTime + ft

    if self.__runTime >= self.__mustWaitTime then
        self:__triggerBuffAdder()
        self:__execAddBuff()
        self:__addInitCarryBuff()
        self:__addActiveCarryBuff()
        self:__addWeaponCarryBuff()
        self:__removeBuffAdder()
        return self.__fight:changeFightState(FightStateMachine.STATE_TYPES.BATTLE)
    end
end

function FightEnterState:__triggerBuffAdder()
    if MapIsEmpty(self.__waitingList) then
        return
    end

    local characters = self.__waitingList

    for i, character in ipairs(characters) do
        --@RefType [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
        character = character

        local list = character:getAdderGroupByAdderTriggerType(BUFF_ADDER_TRIGGER_TYPE.ENTER_START_FIGHT)

        for _, adderGroup in ipairs(list) do
            --@RefType [src.app.FightSystem.FightRole.CharacterBuff.BuffAdders.AFightCharacterBuffAdderGroup#AFightCharacterBuffAdderGroup]
            adderGroup = adderGroup
            adderGroup:triggerBuffAdder(BUFF_ADDER_TRIGGER_TYPE.ENTER_START_FIGHT)
        end
    end
end

function FightEnterState:__execAddBuff()
    if MapIsEmpty(self.__waitingList) then
        return
    end

    local characters = self.__waitingList

    for i, character in ipairs(characters) do
        local AddBuffUtil = require("app.FightSystem.FightRole.CharacterBuff.Utils.AddBuffUtil")
        AddBuffUtil:execAddBuff(self.__fight, character, ADD_BUFF_NODE_TYEP.ENTER_START_FIGHT)
    end

    self.__fight:showAndClearAddBuffDesc()

    self.__fight:notifyVeiwEvent(require "app.FightSystem.Veiws.ViewEvents.Events.CharacterAddBuffsViewEvent":create(self.__fight, self.__fight))

    self.__fight:clearBuffEffectHurts()

    local characters = self.__fight:getCharacters()

    for _, character in ipairs(characters) do
        --@RefType [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
        character = character
        if not character:isDead() then
            character:updateSelfAlive()
        end
        character:updateViews()
    end
end

function FightEnterState:__removeBuffAdder()
    if MapIsEmpty(self.__waitingList) then
        return
    end

    local characters = self.__waitingList

    for i, character in ipairs(characters) do
        --@RefType [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
        character = character
        FightSkillHelper:removeActiveSkillEnterBuffAdder(character)
    end
end

function FightEnterState:__addInitCarryBuff()
    if MapIsEmpty(self.__waitingList) then
        return
    end

    local characters = self.__waitingList

    for i, character in ipairs(characters) do
        --@RefType [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
        character = character
        local carryBuffHandler = character:getCarryBuffHandler()
        if carryBuffHandler then
            carryBuffHandler:addCarryBuffToCharacter()
        end
    end

    self.__fight:showAndClearAddBuffDesc()
end

function FightEnterState:__addActiveCarryBuff()
    if MapIsEmpty(self.__waitingList) then
        return
    end

    local characters = self.__waitingList

    for i, character in ipairs(characters) do
        --@RefType [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
        character = character
        FightSkillHelper:attachActiveSkillCarryBuff(character)
    end

    self.__fight:showAndClearAddBuffDesc()
end

function FightEnterState:__addWeaponCarryBuff()
    if MapIsEmpty(self.__waitingList) then
        return
    end

    local characters = self.__waitingList

    for i, character in ipairs(characters) do
        --@RefType [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
        character = character

        if character:weaponIsEmptyHand() then
            character:enableFistFootCarryBuff()
            character:enableFistFootCarryBuffAdder()
        else
            character:addCurrentWeaponCarryBuff()
            character:addCurrentWeaponCarryBuffAdder()
        end
    end

    self.__fight:showAndClearAddBuffDesc()
end

return newClass("FightEnterState", {AFightState}, FightEnterState)
0000000000000000