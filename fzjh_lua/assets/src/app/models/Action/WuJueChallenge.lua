local class = require("third.class.NewClass")

local actionMapId = "fb307"

local actionNpcList = {
    "fb307_03",
    "fb307_04",
    "fb307_05",
    "fb307_06",
    "fb307_07",
}

local WuJueChallenge = {}

function WuJueChallenge:create()
    return WuJueChallenge:new()
end

function WuJueChallenge:ctor()
end

function WuJueChallenge:init(callback)
    HttpManagerEx:getEggChallengeInfo(function(status, errcode, errmsg, data)
        if status == 200 and errcode == 0 then
            self.endTime = Helper:getDef(data.endTime,0)
            self.npcChallengeAllCountList = Helper:getDef(data.npcChallengeAllCountList,{})
            self.dayChallengeTimes = Helper:getDef(data.number,0)
            if callback then
                callback()
            end
        else
            PopText(errmsg)
        end
    end,IS_SHOW_WAITING)
end

function WuJueChallenge:getNpcChallengeAllCount(npcId)
    return self.npcChallengeAllCountList[npcId]
end

function WuJueChallenge:getNpcList()
    return actionNpcList
end

function WuJueChallenge:checkIsActionMap(mapId)
    return actionMapId == mapId
end

function WuJueChallenge:checkIsActionNpc(npcId)
    for __,_npcId in ipairs(actionNpcList) do
        if npcId == _npcId then
            return true
        end
    end
    return false
end

function WuJueChallenge:checkIsActionTime()
    if not self.endTime then
        self.endTime = 0
    end
    if GetTime() > self.endTime then
        return false
    end
    return true
end

function WuJueChallenge:checkCanChallenge()
    return self.dayChallengeTimes > 0
end

function WuJueChallenge:afterChallenge(npcId,callback)
    HttpManagerEx:addEggChallengeTimes(npcId,function(status, errcode, errmsg, data)
        if status == 200 and errcode == 0 then
            self.npcChallengeAllCountList = Helper:getDef(data.npcChallengeAllCountList,{})
            self.dayChallengeTimes = Helper:getDef(data.number,0)

            if data.currency_num > 0 then
                PopText("五绝令+"..tostring(data.currency_num))
            end

            if callback then
                callback()
            end
        else
            PopText(errmsg)
        end
    end,IS_SHOW_WAITING)
end

return class("WuJueChallenge", {}, WuJueChallenge)
0