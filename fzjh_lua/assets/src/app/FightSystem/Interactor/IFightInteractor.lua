local interface = require("third.class.interface")

local IFightInteractor = {}

function IFightInteractor:init(callback)
end

function IFightInteractor:setFightInteractorOutput(output)
end

--@author:Seven
--@time:2020-11-06 20:47:27
--@return [src.app.FightSystem.Interactor.IFightInteractorOutput#IFightInteractorOutput]
function IFightInteractor:getFightInteractorOutput()
end

function IFightInteractor:setIFightUpdater(fightUpdater)
end

--@desc: 远程调用
--@author:Seven
--@time:2021-03-18 17:25:49
function IFightInteractor:rpc(funcName, args)
end

--@desc: 获取战斗控制器
--@author:Seven
--@time:2021-03-09 17:20:03
--@return [src.app.FightSystem.Updater.IFightUpdater#IFightUpdater]
function IFightInteractor:getIFightUpdater()
end

--@desc: 战场初始化
--@author:Seven
--@time:2021-03-18 16:35:21
function IFightInteractor:initFightScene()
end

function IFightInteractor:startFight()
end

function IFightInteractor:getTeams()
end

function IFightInteractor:getFightRoles()
end

--@return [src.app.FightSystem.Interactor.IFightRoleInteractor#IFightRoleInteractor]
function IFightInteractor:getFightRole(roleId)
end

function IFightInteractor:addRole(teamId, role_data)
end

function IFightInteractor:changeRoleState(role_id, role_state)
end

--@desc: 更改状态
--@author:Seven
--@time:2020-10-14 11:00:50
--@new_state: [src.app.FightSystem.Interactor.FightState.FightStateAbstract#FightStateAbstract]
function IFightInteractor:changeState(new_state)
end

--@desc: 获取当前状态
--@author:Seven
--@time:2020-10-14 17:22:50
--@return [src.app.FightSystem.Interactor.FightState.FightStateAbstract#FightStateAbstract]
function IFightInteractor:getCurrState()
end

function IFightInteractor:getActionQueue()
end

function IFightInteractor:insertCurrentActionQueue(action)
end

--@desc: 处理上一帧数据
--@author:Seven
--@time:2021-03-10 16:49:35
--@frame:[src.app.FightSystem.FightDataModel.Frame#Frame]
function IFightInteractor:processFrame(frame)
end

--@desc: 更新当前帧
--@author:Seven
--@time:2021-03-10 16:48:43
function IFightInteractor:updateLogic()
end

function IFightInteractor:update(dt)
end

--@desc: 战斗是否已结束
--@author:Seven
--@time:2021-04-14 15:19:51
function IFightInteractor:isEnd()
end

function IFightInteractor:finishFight(win_team_id)
end

return interface("IFightInteractor", IFightInteractor)
0000000