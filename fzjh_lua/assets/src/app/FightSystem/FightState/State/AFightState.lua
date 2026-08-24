local abstract = require("third.class.abstract")

local IFightState = {}

function IFightState:onInitState()
end

function IFightState:onEnterState()
end

function IFightState:onUpdateState(ft)
end

function IFightState:onExitState()
end

function IFightState:onDestoryState()
end

--@SuperType [src.app.FightSystem.FightState.State.AFightState#IFightState]
local AFightState = {}

function AFightState:setFight(fight)
    --@RefType [src.app.FightSystem.Fight.BattleSystem#Fight]
    self.__fight = fight
end

function AFightState:setStateMachine(machine)
    --@RefType [src.app.FightSystem.FightState.FightStateMachine#FightStateMachine]
    self.__machine = machine
end

function AFightState:onInitState()
end

function AFightState:onDestoryState()
end

-- @desc: 初始化状态
-- @author:Seven
-- @time:2022-06-23 15:46:06
-- @return:nil
function AFightState:initState()
    self:onInitState()
end

-- @desc: 进入状态
-- @author:Seven
-- @time:2022-06-23 15:45:58
-- @return: nil
function AFightState:enterState()
    self:onEnterState()
end

-- @desc: 退出状态
-- @author:Seven
-- @time:2022-06-23 15:45:36
-- @return: nil
function AFightState:exitState()
    self:onExitState()
end

-- @desc: 更新状态
-- @author:Seven
-- @time:2022-06-23 15:45:08
-- @ft: 间隔时间
-- @return: nil
function AFightState:updateState(ft)
    self:onUpdateState(ft)
end

-- @desc: 销毁状态
-- @author:Seven
-- @time:2022-06-23 15:45:49
-- @return: nil
function AFightState:destoryState()
    self:onDestoryState()
end

return abstract("AFightState", {IFightState}, AFightState)
00000000000000