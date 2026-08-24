--[[
    author:Seven
    time:2023-02-17 14:47:32
    desc: 角色逃跑功能
]]
local newClass = require("third.class.NewClass")

local ABasicCharacterFuncSystem = require("app.FightSystem.FightRole.BasicFuncSystem.ABasicCharacterFuncSystem")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local FightCommons = require("app.FightSystem.FightCommons")

local BattleConstConf = require("app.FightSystem.Configuration.BattleConstConf")

local CharacterBattleStateSystem = require("app.FightSystem.FightRole.CharacterBattleState.CharacterBattleStateSystem")
local CHARACTER_BATTLE_STATE = CharacterBattleStateSystem.STATE

--@SuperType [src.app.FightSystem.FightRole.BasicFuncSystem.ABasicCharacterFuncSystem#ABasicCharacterFuncSystem]
local RunawayFunc = {}

function RunawayFunc:create()
    return RunawayFunc.new()
end

function RunawayFunc:onInit()
    --@RefType [src.app.FightSystem.FightRole.CharacterRunaway.Runaway#Runaway]
    self.__model = require("app.FightSystem.FightRole.CharacterRunaway.Runaway"):create()

    self.__isOpen = true
end

function RunawayFunc:onDestory()
end

function RunawayFunc:onUpdate(ft)
    if self:getCD() > 0 then
        local cdTime = math.max(self:getCD() - ft, 0)
        self:setCD(cdTime)
    -- self.__character:outputUpdateOperationCD(self.__id, self.__coolDownTime - self.__cd, self.__coolDownTime - cdTime, self.__coolDownTime, ft)
    end
end

function RunawayFunc:doRunaway()
    self:setCD(self.__model:getCoolDownTime())

    self.__character:changeCharacterBattleState(CHARACTER_BATTLE_STATE.RUNAWAY)

    FightUtil:printLog(self.__character:getAttr("name") .. "执行逃跑")
end

function RunawayFunc:checkCanDoRunawayFunc()
    if self:getCD() > 0 then
        return false, "逃跑CD中，无法逃跑"
    end

    local isBan, banMsg = self.__character:isBanOperation(FightCommons.BAN_OPERATION_TYPE.BAN_CHANGE_WEAPON)
    if isBan then
        return false, banMsg
    end

    return true
end

function RunawayFunc:setCD(cd)
    self.__model:setCD(cd)
end

function RunawayFunc:getCD()
    return self.__model:getCD()
end

--@desc: 获取逃跑信息类
--@author:Seven
--@time:2023-11-06 20:14:46
--@return [src.app.FightSystem.FightRole.CharacterRunaway.Runaway#Runaway]
function RunawayFunc:getRunaway()
    return self.__model
end

function RunawayFunc:setIsOpen(bool)
    self.__isOpen = bool
end

function RunawayFunc:isOpen()
    return self.__isOpen
end

return newClass("RunawayFunc", {ABasicCharacterFuncSystem}, RunawayFunc)
000000000000000