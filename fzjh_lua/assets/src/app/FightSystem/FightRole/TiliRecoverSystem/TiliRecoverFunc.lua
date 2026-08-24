--[[
    author:Seven
    time:2022-07-04 14:51:05
    desc: 体力回复系统
]]
local newClass = require("third.class.NewClass")

local ABasicCharacterFuncSystem = require("app.FightSystem.FightRole.BasicFuncSystem.ABasicCharacterFuncSystem")

local BattleConstConf = require("app.FightSystem.Configuration.BattleConstConf")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

--@SuperType [src.app.FightSystem.FightRole.BasicFuncSystem.ABasicCharacterFuncSystem#ABasicCharacterFuncSystem]
local TiliUpdateFunc = {}

function TiliUpdateFunc:create()
    return TiliUpdateFunc.new()
end

function TiliUpdateFunc:onInit()
end

function TiliUpdateFunc:onDestory()
end

function TiliUpdateFunc:onUpdate(ft)
    if self.__character:canRecover() and self.__character:getAttr("tili") <= tonumber(BattleConstConf:get("tiliMax")) then
        local pre_tili = self.__character:getAttr("tili")
        local addValue = self:__recoverTili(ft)
        local aft_tili = self.__character:getAttr("tili")
        local tiliMax = self.__character:getAttr("tiliMax")
        FightUtil:printLog(" 【", self.__character:getAttr("name"), "】角色体力恢复 : ", "恢复前体力：", pre_tili, "增加体力值：", addValue, "，恢复后体力：", aft_tili)

        self.__character:getFight():notifyVeiwEvent(require("app.FightSystem.Veiws.ViewEvents.Events.CharacterTiliUpdateViewEvent"):create(self.__character:getId(), pre_tili, aft_tili, ft))
    end
end

--@desc: 正常体力恢复
--@author:Seven
--@time:2022-07-04 16:14:25
function TiliUpdateFunc:__recoverTili(ft)
    local value = self.__character:getAttr("tiliSpeedBattle") * ft

    local addValue = self.__character:addAttr("tili", value)

    return addValue
end

return newClass("TiliUpdateFunc", {ABasicCharacterFuncSystem}, TiliUpdateFunc)
000000