local newClass = require("third.class.NewClass")

local AChallengeFinishCallback = require("app.models.ChallengeMap.MapFightFinishCallback.AChallengeFinishCallback")

--@SuperType [src.app.models.ChallengeMap.MapFightFinishCallback.AChallengeFinishCallback#AChallengeFinishCallback]
local NormalChallengeFightFinishCallback = {}

function NormalChallengeFightFinishCallback:create()
    return NormalChallengeFightFinishCallback.new()
end

function NormalChallengeFightFinishCallback:doWin(fight)
end

function NormalChallengeFightFinishCallback:doLose(fight)
end

function NormalChallengeFightFinishCallback:doDraw(fight)
end

--@desc: 战斗完成执行
--@author:Seven
--@time:2024-01-24 17:31:44
--@fight: [src.app.FightSystem.Fight.BattleSystem#Fight]
function NormalChallengeFightFinishCallback:doFinish(fight)
    local fightPlayer = fight:getCharacter(self.__player:getAttr("userid"))

    local qi = math.max(fightPlayer:getAttr("qi"),1)

    local neili = fightPlayer:getAttr("neili")

    local currQiMax = math.max(fightPlayer:getAttr("qiMax"),1)

    local qiLimit = fightPlayer:getAttr("qiLimit")

    local qiPercent = currQiMax / qiLimit

    --@desc 切磋结束，玩家血量至少恢复到20%
    if qi < currQiMax * 0.2 then
        qi = math.ceil(currQiMax * 0.2)
    end

    self.__player:setAttr("qi", qi)

    self.__player:setAttr("neili", neili)

    self.__player:setAttr("qiPercent", qiPercent)
end

function NormalChallengeFightFinishCallback:doRunaway(fight)
end

return newClass("NormalChallengeFightFinishCallback", {AChallengeFinishCallback}, NormalChallengeFightFinishCallback)
0000000000000