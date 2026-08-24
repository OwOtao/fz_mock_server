--[[
    author:Seven
    time:2023-03-02 14:58:13
    desc: 描述角色在战场中的状态
        1、正常战斗状态
        2、逃跑状态
        3、死亡状态
]]
local newClass = require("third.class.NewClass")

local ABasicCharacterFuncSystem = require("app.FightSystem.FightRole.BasicFuncSystem.ABasicCharacterFuncSystem")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

--@SuperType [src.app.FightSystem.FightRole.BasicFuncSystem.ABasicCharacterFuncSystem#ABasicCharacterFuncSystem]
local CharacterBattleStateSystem = {}

CharacterBattleStateSystem.STATE = {
    BATTLE = 0,
    RUNAWAY = 1,
    DEAD = 2
}

function CharacterBattleStateSystem:create()
    return CharacterBattleStateSystem.new()
end

function CharacterBattleStateSystem:onInit()
    self.__state = CharacterBattleStateSystem.STATE.BATTLE
end

function CharacterBattleStateSystem:onDestory()
end

function CharacterBattleStateSystem:onUpdate(ft)
end

--@desc: 改变战斗状态
--@author:Seven
--@time:2023-03-02 15:04:47
function CharacterBattleStateSystem:changeBattleState(state)
    if state == nil then
        error("CharacterBattleStateSystem:changeBattleState 参数不可为空")
    end
    FightUtil:printLog("CharacterBattleStateSystem:changeBattleState : " .. self.__character:getAttr("name") .. " 战斗状态改变 -> " .. tostring(state))

    self.__state = state
end

--@desc: 获取当前角色战斗状态
--@author:Seven
--@time:2023-03-02 15:04:18
function CharacterBattleStateSystem:getBattleState()
    return self.__state
end

--@desc: 是否脱离战斗状态
--@author:Seven
--@time:2023-03-02 15:03:18
--@return: true | false
function CharacterBattleStateSystem:isOutOfBattleState()
    if self.__state == CharacterBattleStateSystem.STATE.DEAD or self.__state == CharacterBattleStateSystem.STATE.RUNAWAY then
        return true
    end

    return false
end

return newClass("CharacterBattleStateSystem", {ABasicCharacterFuncSystem}, CharacterBattleStateSystem)
0000000000000