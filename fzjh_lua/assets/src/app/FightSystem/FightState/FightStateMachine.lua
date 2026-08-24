local newClass = require("third.class.NewClass")

local FightCommons = require("app.FightSystem.FightCommons")

--@SuperType [src.app.FightSystem.Fight.BasicBattleSystem.AFightSystem#AFightSystem]
local FightStateMachine = {}

FightStateMachine.SYSTEM_NAME = "FightStateMachine"

FightStateMachine.STATE_TYPES = {
    -- READY = 0,
    ENTER = 1,
    BATTLE = 2,
    FINISH = 3
}

function FightStateMachine:create(fight)
    return FightStateMachine.new():__init(fight)
end

function FightStateMachine:__init(fight)
    --@RefType [src.app.FightSystem.Fight.BattleSystem#Fight]
    self.__fight = fight

    for _, state in pairs(self.__states) do
        state:setFight(self.__fight)
        state:onInitState()
    end

    return self
end

function FightStateMachine:ctor()
    self.__name = FightStateMachine.SYSTEM_NAME

    self.__states = {
        -- [FightStateMachine.STATE_TYPES.READY] = require("app.FightSystem.FightState.State.FightReadyState"):create(),
        [FightStateMachine.STATE_TYPES.ENTER] = require("app.FightSystem.FightState.State.FightEnterState"):create(),
        [FightStateMachine.STATE_TYPES.BATTLE] = require("app.FightSystem.FightState.State.FightBattleState"):create(),
        [FightStateMachine.STATE_TYPES.FINISH] = require("app.FightSystem.FightState.State.FightFinishState"):create()
    }
end

-- @desc: 获取战场状态
-- @author:Seven
-- @time:2022-06-24 12:02:03
-- @stateType: [src.app.FightSystem.FightState.FightStateMachine#FightStateMachine.STATE_TYPES]
--@return [src.app.FightSystem.FightState.State.AFightState#AFightState]
function FightStateMachine:__getState(stateType)
    return self.__states[stateType]
end

function FightStateMachine:updateSystem(ft)
    self.__currState:updateState(ft)
end

function FightStateMachine:changeState(stateType)
    if self.__currState then
        self.__currState:exitState()
    end

    local nextState = self:__getState(stateType)

    self.__currState = nextState

    self.__currState:enterState()
end

return newClass("FightStateMachine", {}, FightStateMachine)
000000000