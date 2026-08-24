local interface = require("third.class.interface")

local ISkillAttack = {}


--@desc: 准备出手
--@author:Seven
--@time:2021-06-27 02:36:08
function ISkillAttack:prepAttack()
end

--@desc: 一次出手攻击开始
--@author:Seven
--@time:2021-06-25 15:15:34
function ISkillAttack:startAttack()
end

--@desc: 是否需要进行跳跃攻击
--@author:Seven
--@time:2021-06-27 17:54:39
function ISkillAttack:isNeedToJump()
end

--@desc: 一次招式组合攻击开始
--@author:Seven
--@time:2021-06-25 15:16:13
function ISkillAttack:startCombAttack()
end


--@desc: 准备时间
--@author:Seven
--@time:2021-06-27 12:32:05
function ISkillAttack:getReadyDuration()
end

--@desc: 攻击准备执行
--@author:Seven
--@time:2021-06-25 15:17:17
function ISkillAttack:doReadyZhao()
end

--@desc: 一次招式攻击开始
--@author:Seven
--@time:2021-06-25 15:17:27
function ISkillAttack:startZhaoAttack()
end

--@desc: 招式攻击
--@author:Seven
--@time:2021-06-25 15:17:38
function ISkillAttack:doZhaoAttack()
end

--@desc: 招式攻击完成
--@author:Seven
--@time:2021-06-25 15:17:46
function ISkillAttack:finishZhaoAttack()
end

--@desc: 招式组合攻击完成
--@author:Seven
--@time:2021-06-25 15:17:59
function ISkillAttack:finishCombAttack()
end

--@desc: 一次出手攻击的完成
--@author:Seven
--@time:2021-06-25 15:16:03
function ISkillAttack:finishAttack()
end

--@desc: 是否有一招攻击
--@author:Seven
--@time:2021-06-25 15:18:10
function ISkillAttack:hasNextZhaoAttack()
end

--@desc: 设置下一招攻击
--@author:Seven
--@time:2021-06-25 15:49:32
function ISkillAttack:setNextZhaoAttack()
end

--@desc: 获取攻击距离
--@author:Seven
--@time:2021-06-25 20:50:41
function ISkillAttack:getAttackOffset()
end

--@desc: 获取当前攻击的攻击时间
--@author:Seven
--@time:2021-06-26 16:14:38
--@return:
function ISkillAttack:getAttackDuration()
end

function ISkillAttack:zhaoCombIsBeInterrupt()
end

return interface("ISkillAttack", ISkillAttack)
00000000000