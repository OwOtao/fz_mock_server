local abstract = require("third.class.abstract")

local ICharacterState = {}

function ICharacterState:initTriggerMap()
end

function ICharacterState:onEnter(params)
end

function ICharacterState:onLeave()
end

function ICharacterState:onUpdate(ft)
end

--@SuperType [src.app.FightSystem.FightRole.CharacterState.ACharacterState#ICharacterState]
local ACharacterState = {
    __character = nil,
    __stateMachine = nil,
    __transitionDicts = {},
    __state_type = 0
}

function ACharacterState:create(f_character,stateMachine)
    local p = self.new()
    p:setCharacter(f_character)
    p:setStateMachine(stateMachine)
    return p
end

function ACharacterState:ctor()
    self:initTriggerMap()
end

function ACharacterState:setCharacter(f_character)
    --@RefType [src.app.FightSystem.FightRole.FightCharacter#FightCharacter]
    self.__character = f_character
end

function ACharacterState:setStateMachine(stateMachine)
    --@RefType [src.app.FightSystem.FightRole.CharacterState.CharacterStateMachine#CharacterStateMachine]
    self.__stateMachine = stateMachine
end

function ACharacterState:getType()
    return self.__state_type
end

function ACharacterState:triggerEvent(event)
    local actionFunc = self.__transitionDicts[event]

    if actionFunc ~= nil then
        actionFunc()
    end
end

return abstract("ACharacterState", ICharacterState, ACharacterState)
000