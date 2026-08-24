--[[
    author:Seven
    time:2023-03-01 12:16:13
    desc: 易武操作
]]
local newClass = require("third.class.NewClass")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local AnimResManager = require("app.FightSystem.ResourceManager.AnimResManager")

local BattleConstConf = require("app.FightSystem.Configuration.BattleConstConf")

local FightFormula = require("app.FightSystem.FightFormula")

local FightCommons = require("app.FightSystem.FightCommons")

local ABaseBattleAction = require("app.FightSystem.BattleActions.ABaseBattleAction")

--@SuperType [src.app.FightSystem.BattleActions.ABaseBattleAction#ABaseBattleAction]
local ChangeWeaponAction = {}

function ChangeWeaponAction:create(characterId)
    return ChangeWeaponAction.new():__init(characterId)
end

function ChangeWeaponAction:__init(characterId)
    self.__characterId = characterId
    return self
end

function ChangeWeaponAction:onInit()
    FightUtil:printLog("ChangeWeaponAction:onInit 易武初始化")

    --@RefType [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
    self.__character = self.__fight:getCharacter(self.__characterId)
end

function ChangeWeaponAction:onStart()
    self.__elapsedTime = 0

    self.__character:doChangeWeaponFunc()

    self.__character:correctAttrLimit()

    local weapon = self.__character:getWeapon()

    local animName = AnimResManager:getOtherAnimNameByWeapon(BattleConstConf:get("battleAction_changeWeapon_animRes"), weapon:getWeaponModule())

    local animTime = AnimResManager:getAnimTime(animName)

    self.__fight:notifyVeiwEvent(require "app.FightSystem.Veiws.ViewEvents.Events.CharacterWeaponSkinUpdateViewEvent":create(self.__characterId, self.__character:getWeapon():getWeaponSkin()))

    self.__fight:notifyVeiwEvent(require "app.FightSystem.Veiws.ViewEvents.Events.CharacterPlayAnimViewEvent":create(self.__character:getId(), animName))

    self.__fight:notifyVeiwEvent(require "app.FightSystem.Veiws.ViewEvents.Events.CharacterUpdateChangeWeaponFuncOpen":create(self.__character:getId(), self.__character:isChangeWeaponFuncOpen()))

    local prepActMap = {}
    for i = 1, FightCommons.PREP_ACT_MAX_COUNT do
        local activeSkill = self.__character:getPrepActiveSkillByPosIndex(i)
        if activeSkill then
            prepActMap[tostring(i)] = activeSkill
        end
    end
    self.__fight:notifyVeiwEvent(require "app.FightSystem.Veiws.ViewEvents.Events.PlayerRefreshAcitveSkillsViewEvent":create(self.__character:getId(), prepActMap))
    
    self.__duration = animTime
end


function ChangeWeaponAction:onFinish()

    self.__fight:notifyVeiwEvent(require("app.FightSystem.Veiws.ViewEvents.Events.CharacterUpdateAndPlayIdleAnimNameViewEvent"):create(self.__character:getId(), self.__character:getIdleAnimId()))
    FightUtil:printLog("ChangeWeaponAction:onFinish 易武动作结束")
end

function ChangeWeaponAction:onDestory()
end

function ChangeWeaponAction:onUpdate(ft)
    if self.__elapsedTime >= self.__duration then
        self:finish()
        return
    end
    self.__elapsedTime = self.__elapsedTime + ft
end

function ChangeWeaponAction:getNextBattleAction()
    return nil
end

return newClass("ChangeWeaponAction", {ABaseBattleAction}, ChangeWeaponAction)
000000