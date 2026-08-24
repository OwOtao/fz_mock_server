local interface = require("third.class.interface")

local IFightRoleInteractor = {}

function IFightRoleInteractor:setFightInteractor(fightInteractor)
end

function IFightRoleInteractor:setFightRoleAnimInteractorOutput(animInteractorOutput)
end

function IFightRoleInteractor:setFightRoleAttrInteractorOutput(attrInteractorOutput)
end

function IFightRoleInteractor:onStartFight()
end

function IFightRoleInteractor:getId()
end

function IFightRoleInteractor:getAttr(name)
end

function IFightRoleInteractor:setAttr(name, value)
end

function IFightRoleInteractor:getFinalAttr(name)
end

function IFightRoleInteractor:getBaseAttr(name)
end

function IFightRoleInteractor:setTeamId(teamId)
end

function IFightRoleInteractor:getAtk()
end

function IFightRoleInteractor:getDef()
end

--@desc: 获取普攻动画
--@author:Seven
--@time:2020-09-29 16:02:16
--@return array
function IFightRoleInteractor:getAutoAttackAnimNames()
end

--@desc: 站立动画
--@author:Seven
--@time:2020-09-29 16:03:02
function IFightRoleInteractor:getStandAnimName()
end

--@desc: 格挡动画
--@author:Seven
--@time:2020-09-29 16:03:30
function IFightRoleInteractor:getParryAnimName()
end

--@desc: 闪避动画
--@author:Seven
--@time:2020-09-29 16:03:59
function IFightRoleInteractor:getDodgeAnimName()
end

--@desc: 选择攻击对象
--@author:Seven
--@time:2020-10-09 10:49:06
--@return 返回目标ID
function IFightRoleInteractor:selectTarget()
end

function IFightRoleInteractor:getTargetId()
end

--@desc: 体力恢复
--@author:Seven
--@time:2020-09-21 15:53:26
function IFightRoleInteractor:recoverTili(addValue)
end

--@desc: 闪避
--@author:Seven
--@time:2020-09-21 15:53:37
function IFightRoleInteractor:dodge(result)
end

--@desc: 格挡
--@author:Seven
--@time:2020-09-21 15:53:46
function IFightRoleInteractor:parry(result)
end

--@desc: 攻击对方
--@author:Seven
--@time:2020-09-21 15:53:58
function IFightRoleInteractor:attack(result)
end

--@desc: 被攻击
--@author:Seven
--@time:2020-10-09 16:33:30
function IFightRoleInteractor:beAttack(result)
end


function IFightRoleInteractor:changeState(state)
end

function IFightRoleInteractor:getCurrState()
end

function IFightRoleInteractor:getPreState()
end

--@desc: 使用主动技能
--@author:Seven
--@time:2020-09-21 15:54:09
function IFightRoleInteractor:useActiveSkill()
end

function IFightRoleInteractor:isDead()
end

function IFightRoleInteractor:updateRole(ft)
end

return interface("IFightRoleInteractor", IFightRoleInteractor)
000