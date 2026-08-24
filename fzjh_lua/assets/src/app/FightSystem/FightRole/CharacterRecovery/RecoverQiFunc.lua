--[[
    author:Seven
    time:2023-02-16 14:38:54
    desc: 气血恢复功能
]]
local newClass = require("third.class.NewClass")

local ABasicCharacterFuncSystem = require("app.FightSystem.FightRole.BasicFuncSystem.ABasicCharacterFuncSystem")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

--@SuperType [src.app.FightSystem.FightRole.BasicFuncSystem.ABasicCharacterFuncSystem#ABasicCharacterFuncSystem]
local RecoverQiFunc = {}

function RecoverQiFunc:create()
    return RecoverQiFunc.new()
end

function RecoverQiFunc:onInit()
    self.__isOpen = true

    --@RefType [src.app.FightSystem.FightRole.CharacterRecovery.RecoverQi#RecoverQi]
    self.__recoverQi = require("app.FightSystem.FightRole.CharacterRecovery.RecoverQi"):create(self.__character)
end

function RecoverQiFunc:onDestory()
end

function RecoverQiFunc:onUpdate(ft)
    if self:getRecoverIsOpen() == false then
        return
    end

    self:__updateCD(ft)
end

function RecoverQiFunc:__updateCD(ft)
    local cd = self.__recoverQi:getCD()
    if cd > 0 then
        local cdTime = math.max(cd - ft, 0)

        self.__recoverQi:setCD(cdTime)

        FightUtil:printLog(string.format(" RecoverQiFunc:__updateCD【%s】 恢复CD更新【%s】 CD剩余: %f", self.__character:getAttr("name"), self.__recoverQi:getName(), cdTime))

        local updateViewEvent = require "app.FightSystem.Veiws.ViewEvents.Events.QiRecoverCdUpdateViewEvent":create(self.__character:getId(), cd, cdTime, ft)

        self.__character:getFight():notifyVeiwEvent(updateViewEvent)
    end
end

--@desc: 获取恢复气血对象
--@author:Seven
--@time:2023-02-16 17:14:26
--@return [src.app.FightSystem.FightRole.CharacterRecovery.RecoverQi#RecoverQi]
function RecoverQiFunc:getRecoverQi()
    return self.__recoverQi
end

--@desc: 设置气血恢复功能开关
--@author:Seven
--@time:2023-02-16 18:15:41
--@bool: true | false
function RecoverQiFunc:setRcoverQiOpen(bool)
    self.__isOpen = bool
end

function RecoverQiFunc:getRecoverIsOpen()
    return self.__isOpen
end

return newClass("RecoverQiFunc", {ABasicCharacterFuncSystem}, RecoverQiFunc)
0000000000000