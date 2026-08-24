local newClass = require("third.class.NewClass")

local FightCommons = require("app.FightSystem.FightCommons")

local FINISH_STATE = FightCommons.FINISH_STATE

local FightFinishCallback = {
    __winFunc = function(fight)
    end,
    __loseFunc = function(fight)
    end,
    __finishFunc = function(fight)
    end
}

function FightFinishCallback:create()
    return FightFinishCallback.new()
end

function FightFinishCallback:setWinCallbackFunc(func)
    self.__winFunc = func
end

function FightFinishCallback:setLoseCallbackFunc(func)
    self.__loseFunc = func
end

function FightFinishCallback:setFinishCallbackFunc(func)
    self.__finishFunc = func
end

function FightFinishCallback:setDrawCallbackFunc(func)
    self.__drawFunc = func
end

function FightFinishCallback:setDestoryCallbackFunc(func)
    self.__destoryFunc = func
end

function FightFinishCallback:__runWinFunc(fight)
    if self.__winFunc then
        self.__winFunc(fight)
    end
end

function FightFinishCallback:__runLoseFunc(fight)
    if self.__loseFunc then
        self.__loseFunc(fight)
    end
end

function FightFinishCallback:setRunawayFunc(func)
    self.__runawayFunc = func
end

function FightFinishCallback:__runRunawayFunc(fight)
    if self.__runawayFunc then
        self.__runawayFunc(fight)
    end
end

function FightFinishCallback:__runDrawFunc(fight)
    if self.__drawFunc then
        self.__drawFunc(fight)
    end
end

function FightFinishCallback:__runFinishFunc(fight)
    if self.__finishFunc then
        self.__finishFunc(fight)
    end
end

--@desc: 执行战斗后回调
--@author:Seven
--@time:2024-01-23 11:02:18
--@fight: [src.app.FightSystem.Fight.BattleSystem#Fight]
function FightFinishCallback:runFinish(fight)
    local result = fight:getFightFinishResult()

    --@desc 先执行战斗完成流程
    self:__runFinishFunc(fight)

    if result == FINISH_STATE.WIN then
        self:__runWinFunc(fight)
    elseif result == FINISH_STATE.NO_WINNER then
        self:__runDrawFunc(fight)
    elseif result == FINISH_STATE.RUNAWAY then
        self:__runRunawayFunc(fight)
    elseif result == FINISH_STATE.LOSE then
        self:__runLoseFunc(fight)
    else
        assert(false, "战斗结束状态错误 : " .. tostring(result))
    end
end

function FightFinishCallback:runDestoryFunc()
    if self.__destoryFunc then
        self.__destoryFunc()
    end
end

return newClass("FightFinishCallback", {}, FightFinishCallback)
0000000000000