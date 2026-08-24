local newClass = require("third.class.NewClass")

--@RefType [src.app.FightSystem.Updater.LocalUpdateSystem#LocalUpdateSystem]
local LocalUpdateSystem = require("app.FightSystem.Updater.LocalUpdateSystem")

--@RefType src.app.FightSystem.FightRole.CharacterSystem#CharacterSystem
local CharacterSystem = require("app.FightSystem.FightRole.CharacterSystem")

local JoinFightSystem = require("app.FightSystem.Fight.JoinFightSystem")

local FightCommandSystem = require("app.FightSystem.FightCommand.FightCommandSystem")

local BuffSystem = require("app.FightSystem.FightBuff.BuffSystem")

local FightFinishCallback = require("app.FightSystem.Fight.FightFinishCallback")

local FightBuilder = {
    __updateSysClass = nil,
    __characterSysClass = nil,
    __joinFightSysClass = nil,
    __cmdSysClass = nil,
    __fightCallback = nil
}

function FightBuilder:create()
    return self.new()
end

function FightBuilder:ctor()
end

--@desc:
--@author:Seven
--@time:2021-07-02 10:48:17
--@sysClass:
--@return [src.app.FightSystem.FightBuilder#FightBuilder]
function FightBuilder:setUpdateSysClass(sysClass)
    self.__updateSysClass = sysClass
    return self
end

--@return [src.app.FightSystem.FightBuilder#FightBuilder]
function FightBuilder:setCharacterSys(sysClass)
    self.__characterSysClass = sysClass
    return self
end

--@return [src.app.FightSystem.FightBuilder#FightBuilder]
function FightBuilder:setJoinFightSyst(sysClass)
    self.__joinFightSysClass = sysClass
    return self
end

--@return [src.app.FightSystem.FightBuilder#FightBuilder]
function FightBuilder:setCmdSys(sysClass)
    self.__cmdSysClass = sysClass
    return self
end

function FightBuilder:setFinishCallback(fightCallback)
    self.__fightCallback = fightCallback
    return self
end

function FightBuilder:__initSystemClass()
    if self.__updateSysClass == nil then
        self.__updateSysClass = LocalUpdateSystem
    end

    if self.__characterSysClass == nil then
        self.__characterSysClass = CharacterSystem
    end

    if self.__joinFightSysClass == nil then
        self.__joinFightSysClass = JoinFightSystem
    end

    if self.__cmdSysClass == nil then
        self.__cmdSysClass = FightCommandSystem
    end

    if self.__fightCallback == nil then
        self.__fightCallback = FightFinishCallback:create()
    end
end

function FightBuilder:build()
    self:__initSystemClass()

    --@RefType[src.app.FightSystem.Fight.Fight#Fight]
    local fight = require("app.FightSystem.Fight.Fight"):create()

    fight:setBuffSystem(BuffSystem:create(fight))
    fight:setJoinFightSystem(self.__joinFightSysClass:create(fight))
    fight:setCharacterSystem(self.__characterSysClass:create(fight))
    fight:setCommandSystem(self.__cmdSysClass:create(fight))
    fight:setUpdateSystem(self.__updateSysClass:create(fight))

    fight:setFinishCallback(self.__fightCallback)

    return fight
end

return newClass("FightBuilder", {}, FightBuilder)
0000000000