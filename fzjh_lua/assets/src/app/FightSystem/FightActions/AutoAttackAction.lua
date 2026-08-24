--[[
    author:Seven
    time:2022-10-27 15:30:51
    desc: 被动攻击动作对象
]]
local newClass = require("third.class.NewClass")

local AutoAttackAction = {}

function AutoAttackAction:create()
    return AutoAttackAction.new()
end

function AutoAttackAction:init(c_id, logicIndex, fight)
    self.__cId = c_id
    self.__logicIndex = logicIndex

    --@RefType [src.app.FightSystem.Fight.BattleSystem#Fight]
    self.__fight = fight

    return self
end

--@desc: 获取角色ID
--@author:Seven
--@time:2022-10-27 15:42:39
--@return: 角色id
function AutoAttackAction:getCharacterId()
    return self.__cId
end

--@desc: 获取进入的逻辑帧时间
--@author:Seven
--@time:2022-10-27 15:42:48
--@return: 逻辑帧时间
function AutoAttackAction:getLogicIndex()
    return self.__logicIndex
end

--@desc: 被动技能释放前检查是否满足
--@author:Seven
--@time:2023-02-27 19:46:14
--@return: true|false,msg
function AutoAttackAction:checkPreRelease()
    local attacker = self.__fight:getCharacter(self:getCharacterId())

    if attacker:autoAttackIsBan() then
        return false
    end

    local AutoAttackContext = require("app.FightSystem.BattleActions.AttackBattleAction.AutoAttack.AutoAttackContext")

    --@RefType [src.app.FightSystem.BattleActions.AttackBattleAction.AutoAttack.AutoAttackContext#AutoAttackContext]
    self.__attackContext = AutoAttackContext.createContext(self.__fight, self:getCharacterId(), attacker:getTarget():getId())

    local canRelease = self.__attackContext:getAttackComb():releaseAreMet()

    return canRelease
end

--@desc: 获取攻击动作
--@author:Seven
--@time:2023-02-27 20:15:26
--@return [src.app.FightSystem.BattleActions.AttackBattleAction.AutoAttack.AutoAttackBattleAction#AutoAttackBattleAction]
function AutoAttackAction:getAndDoAttackAction()
    if self.__attackContext == nil then
        error("AutoAttackAction:getAttackBattleAction 执行该方法需先执行 onPreReleaseCheck 进行检查")
    end

    local AutoAttackBattleAction = require("app.FightSystem.BattleActions.AttackBattleAction.AutoAttack.AutoAttackBattleAction")

    return AutoAttackBattleAction:create(self.__attackContext)
end

return newClass("AutoAttackAction", {}, AutoAttackAction)
0