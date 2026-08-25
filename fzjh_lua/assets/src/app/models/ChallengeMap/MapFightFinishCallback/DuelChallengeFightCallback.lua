local newClass = require("third.class.NewClass")

local ChallengeMapSystem = require("app.models.ChallengeMap.ChallengeMapSystem")

local AChallengeFinishCallback = require("app.models.ChallengeMap.MapFightFinishCallback.AChallengeFinishCallback")

--@SuperType [src.app.models.ChallengeMap.MapFightFinishCallback.AChallengeFinishCallback#AChallengeFinishCallback]
local DuelChallengeFightCallback = {}

function DuelChallengeFightCallback:create()
    return DuelChallengeFightCallback.new()
end

function DuelChallengeFightCallback:__doLose(fight)
    PopupLayerController:showLayer(
        "ChallengeMapLosePresenter",
        function(layer)
            layer:setButtonLeave(
                "离开",
                function()
                    ChallengeMapSystem:getInstance():leaveTheMap(
                        self.__map,
                        2,
                        function(result, msg)
                            if result then
                                self.__map:quit()
                                layer:hideLayer()
                            else
                                PopText(msg)
                            end
                        end
                    )
                end
            )
            layer:showLayer()
        end
    )
end

function DuelChallengeFightCallback:doWin(fight)
    self.__map:playerKillRole(self.__roomId, self.__defenderId)

	local csjCD = self.__player:getFlag("长生诀时间")
	if csjCD > 0 then
		self.__player:setFlag("长生诀时间",math.max(csjCD - 10,0))
	end
end

function DuelChallengeFightCallback:doLose(fight)
    self:__doLose(fight)
end

function DuelChallengeFightCallback:doDraw(fight)
    self:__doLose(fight)
end

--@desc: 战斗完成执行
--@author:Seven
--@time:2024-01-24 17:31:12
--@fight: [src.app.FightSystem.Fight.BattleSystem#Fight]
function DuelChallengeFightCallback:doFinish(fight)
    local fightPlayer = fight:getCharacter(self.__player:getAttr("userid"))

    local qi = math.max(fightPlayer:getAttr("qi"),1)

    local neili = fightPlayer:getAttr("neili")

    local currQiMax = math.max(fightPlayer:getAttr("qiMax"),1)

    local qiLimit = fightPlayer:getAttr("qiLimit")

    local qiPercent = currQiMax / qiLimit

    self.__player:setAttr("qi", qi)

    self.__player:setAttr("neili", neili)

    self.__player:setAttr("qiPercent", qiPercent)
end

function DuelChallengeFightCallback:doRunaway(fight)
end

return newClass("DuelChallengeFightCallback", {AChallengeFinishCallback}, DuelChallengeFightCallback)
00