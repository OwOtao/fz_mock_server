--[[
    author:Seven
    time:2022-12-16 20:06:40
    desc: 招式攻击基础类
]]
local abstract = require("third.class.abstract")

local ABasicZhaoAttack = {
    __currAtkIndex = 0
}

function ABasicZhaoAttack:attack()
    error("ABasicZhaoAttack:attack 重写该方法")
end

--@desc: 攻击类型
--@author:Seven
--@time:2022-12-28 15:23:45
function ABasicZhaoAttack:getHitType()
    if self.__hitType == nil then
        error("招式攻击结果类型未定义")
    end

    return self.__hitType
end

--@desc: 招式攻击持续时长
--@author:Seven
--@time:2022-12-28 15:24:27
function ABasicZhaoAttack:getDuration()
    if self.__duration == nil then
        error("招式攻击时长不可为空")
    end

    return self.__duration
end

--@desc: 释放者的动画
--@author:Seven
--@time:2023-02-01 18:20:17
function ABasicZhaoAttack:getAttackerAnim()
    return self.__attackerAnim
end

--@desc: 获取当前招式攻击第几次击中
--@author:Seven
--@time:2023-02-09 11:12:06
function ABasicZhaoAttack:getCurrentAttackIndex()
    return self.__currAtkIndex
end

--@desc: 访问击中结果
--@author:Seven
--@time:2023-02-25 15:47:58
--@hitIndex: 第几次击中
--@visitor: [src.app.FightSystem.ZhaoAttacks.AttackResultVisitor.IAttackResultVisitor#IAttackResultVisitor]
function ABasicZhaoAttack:runOneAttackVisitor(hitIndex,visitor)
    error("ABasicZhaoAttack:runOneAttackVisitor 重写该方法")
end

--@desc: 访问所有击中结果
--@author:Seven
--@time:2023-02-25 15:47:58
--@visitor: [src.app.FightSystem.ZhaoAttacks.AttackResultVisitor.IAttackResultVisitor#IAttackResultVisitor]
function ABasicZhaoAttack:runAttackResultVisitor(visitor)
    error("ABasicZhaoAttack:runAttackResultVisitor 重写该方法")
end

return abstract("ABasicZhaoAttack", {}, ABasicZhaoAttack)
00000000000000