local class = require("third.class.NewClass")

local PuzzleGame = {}
local PuzzleGameConfig = require("script.miniGame.puzzleGameConfig")["Sheet1"]

function PuzzleGame:create()
    return PuzzleGame:new()
end

function PuzzleGame:ctor()
end

function PuzzleGame:setGameId(id)
    self._id = id
end

function PuzzleGame:initConfig()
    local config = PuzzleGameConfig[self._id]
    if not config then
        error("当前玩法id数据未配置：id"..tostring(self._id))
    end

    self._title = config.title
    self._desc = config.desc
    self._trueAnswer = tostring(config.correctsequence)

    local info = {}
    for i = 1, 9, 1 do
        table.insert(info, {index = i, text = config["button"..tostring(i).."Text"]})
    end

    self._gameUIInfo = info

    self._successResults = config.correctresult

    self._failureResults = config.incorrectresult

end

function PuzzleGame:getSuccessResults()
    return self._successResults
end

function PuzzleGame:getFailureResults()
    return self._failureResults
end

function PuzzleGame:getGameName()
    return self._title
end

function PuzzleGame:getGameDesc()
    return self._desc
end

function PuzzleGame:getGameUIInfo()
    return self._gameUIInfo
end

function PuzzleGame:checkIsTrueAnswer(index, value)
    print("---value:",value, self._trueAnswer:sub(index, index))
    if self._trueAnswer:sub(index, index) == tostring(value) then
        return true
    else
        return false
    end
end

function PuzzleGame:checkIsLastSelect(selectCount)
    return selectCount == #self._trueAnswer
end

return class("PuzzleGame", {}, PuzzleGame)00