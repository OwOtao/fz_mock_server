local IChallengeFinishCallback = {
    doWin = function(self, fight)
    end,
    doLose = function(self, fight)
    end,
    doDraw = function(self, fight)
    end,
    doFinish = function(self, fight)
    end,
    doRunaway = function(self, fight)
    end
}

local abstract = require("third.class.abstract")

local ChallengeMapConstant = require("app.models.ChallengeMap.ChallengeMapConstant")

--@SuperType [src.app.models.ChallengeMap.MapFightFinishCallback.AChallengeFinishCallback#IChallengeFinishCallback]
local AChallengeFinishCallback = {}

function AChallengeFinishCallback:ctor()
    --@RefType [src.app.FightSystem.Fight.FightFinishCallback#FightFinishCallback]
    self.__fightFinishCallback = require("app.FightSystem.Fight.FightFinishCallback"):create()

    self.__fightIsFinish = false

    self.__fightFinishEventType = nil

    self.__fightFinishCallback:setWinCallbackFunc(
        function(currFight)
            print("你赢了！！！！！！！！！！")
            self.__fightFinishEventType = ChallengeMapConstant.EventType.ChallengeWin

			self:doWin(currFight)
        end
    )

    self.__fightFinishCallback:setLoseCallbackFunc(
        function(currFight)
            print("你输了！！！！！！！！！")
            self.__fightFinishEventType = ChallengeMapConstant.EventType.ChallengeLose

            self:doLose(currFight)
        end
    )

    self.__fightFinishCallback:setDrawCallbackFunc(
        function(currFight)
            print("打平！！！！！！！！！")
            self.__fightFinishEventType = ChallengeMapConstant.EventType.ChallengeLose

            self:doDraw(currFight)
        end
    )

    self.__fightFinishCallback:setRunawayFunc(
        function(currFight)
            print("你逃跑了！！！！！！！！！")
            self.__fightFinishEventType = ChallengeMapConstant.EventType.ChallengeRunaway
            self:doRunaway(currFight)
        end
    )

    self.__fightFinishCallback:setFinishCallbackFunc(
        function(currFight)
            print("战斗结束")

            self.__fightIsFinish = true

            self:__doBaseFinish(currFight)

            self:doFinish(currFight)
        end
    )
end

function AChallengeFinishCallback:setMapPlayee(player)
    self.__player = player
end

function AChallengeFinishCallback:setMap(map)
    self.__map = map
end

function AChallengeFinishCallback:setRoomId(roomId)
    self.__roomId = roomId
end

function AChallengeFinishCallback:setDefenderId(id)
    self.__defenderId = id
end

--@fight: [src.app.FightSystem.Fight.BattleSystem#Fight]
function AChallengeFinishCallback:__doBaseFinish(fight)
    local fightPlayer = fight:getCharacter(self.__player:getAttr("userid"))

    local recordClass = fightPlayer:getRecordClass()

    local weapons = recordClass:getWeapons()

    --@desc 需同步完好度
    for i = 1, table.getn(weapons) do
        --@RefType [src.app.FightSystem.FightRole.CharacterEquipment.IWeapon#IWeapon]
        local weapon = weapons[i]

        if weapon:getFirstType() ~= "空手" then
            local onlyId = weapon:getId()

            local weaponCommnce = weapon:getCommence()

            local roleWeaponAttr = self.__player:getItemWithOnlyId(onlyId) -- 神兵数据

            local itemId = weapon:getItemId()

            if roleWeaponAttr == nil then
                error(self.__player:getAttr("name") .. " 没有找到id：" .. onlyId .. " , itemId：" .. itemId .. "的物品。")
            end

            if self.__player:isShengBing(itemId) then
                if weaponCommnce == 0 then
                    roleWeaponAttr.wanhaodu = 0
                end

                local ShenBingDuanZao = require("app.models.ShenBing.DuanZao.ShenBingDuanZao")
                ShenBingDuanZao:updateShenBingInfo({id = itemId, wanhaodu = weaponCommnce}, self.__player)
            else
                if weaponCommnce == 0 then
                    roleWeaponAttr.wanhaodu = 0
                end
            end

            if weaponCommnce == 0 then
                local playerUseWeapon = self.__player:getEquipByName("weapon")

                if playerUseWeapon ~= nil and playerUseWeapon.id == weapon:getId() and playerUseWeapon.itemId == weapon:getItemId() then
                    self.__player:removeEquipItem("weapon")
                end

                local prepWeapon = self.__player:getPrepareWeapon()
                if prepWeapon ~= nil and prepWeapon.id == weapon:getId() and prepWeapon.itemId == weapon:getItemId() then
                    self.__player:setPrepareWeapon(nil)
                end
            end
        end
    end

    --@desc 同步主动技能释放次数
    local activeReleaseTimesMap = recordClass:getActiveReleaseTimesMap()

    table.addToLeft(self.__player:getAttr("activeReleaseTimesMap"), activeReleaseTimesMap)
end

function AChallengeFinishCallback:getFightFinishCallback()
    return self.__fightFinishCallback
end

function AChallengeFinishCallback:isFinish()
    return self.__fightIsFinish
end

function AChallengeFinishCallback:getFightFinishEventTypt()
    return self.__fightFinishEventType
end

return abstract("AChallengeFinishCallback", {IChallengeFinishCallback}, AChallengeFinishCallback)
0000