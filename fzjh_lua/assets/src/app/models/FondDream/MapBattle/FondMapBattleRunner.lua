--[[
    author:Seven
    time:2024-01-19 16:17:32
    desc: 梦境副本战斗运行器
]]
local TeamIdRes = require("script.nanke.dreamworld.dreamBattleTeams")["战斗队列"]

local BattleTeamRes = require("script.newbattle.demo.battleTeamOfNPC")["战队组"]

local FightCommons = require("app.FightSystem.FightCommons")

local FondFightNpcBuilderConfig = require("app.models.FondDream.MapBattle.FondFightNpcBuilderConfig")

local BasicMapNpcFightCharacterBuilder = require("app.FightSystem.FightCharacterBuilder.NPCBuilder.BasicMapNpcFightCharacterBuilder")

local FondFightPlayerBuilder = require("app.models.FondDream.MapBattle.FondFightPlayerBuilder")

local FondMapBattleRunner = {}

function FondMapBattleRunner:runBattle(npcId, map, playerRole, environment)
    local npcTeams = self:__intiNpcTeams(npcId, map)

    local playerCharacter = self:__initPlayerCharacter(playerRole)

    --@RefType [src.app.FightSystem.Fight.BattleSystem#Fight]
    local fight = require("app.FightSystem.Fight.BattleSystem"):create(require("src.app.FightSystem.Fight.SystemConfig.BasicBattleSystemConfig") , self:__initFinishCallback(map,playerRole,environment))

    fight:addCharacter(playerCharacter)

    fight:setPlayerId(playerCharacter:getId())

    for _, npc in pairs(npcTeams) do
        fight:addCharacter(npc)
    end

    --@RefType [src.app.FightSystem.Updater.LocalUpdater#LocalUpdater]
    local updater = require("app.FightSystem.Updater.LocalUpdater"):create()

    local backgroundSceneId = map:getRoomById(map:getCurrRoomId()).fightBackground

    local fightMainView = require("app.FightSystem.Veiws.FightMainView"):create(backgroundSceneId)

    fight:setFightOutput(fightMainView)

    cc.Director:getInstance():getRunningScene():addChild(fightMainView)

    fight:start(updater)
end

function FondMapBattleRunner:__initFinishCallback(map, playerRole, environment)
    local failFunc = function(fight)
        local operations = environment.currRole.operations

        if MapIsEmpty(operations) == true then
            operations = environment.currRoom.operations
            if MapIsEmpty(operations) == true then
                return
            end
        end
        print("----------- 决斗失败 -----------")
        map:doOperationByName("决斗失败", operations, environment)
        map.__MapLayer:delayRefreshMap()
    end

    local FightFinishCallback = require("app.FightSystem.Fight.FightFinishCallback")

    --@RefType [src.app.FightSystem.Fight.FightFinishCallback#FightFinishCallback]
    local finishCallback = FightFinishCallback:create()

    finishCallback:setWinCallbackFunc(
        function(fight)
            -- --@RefType [src.app.FightSystem.Fight.BattleSystem#Fight]
            -- fight = fight
            local operations = environment.currRole.operations

            if MapIsEmpty(operations) == true then
                operations = environment.currRoom.operations
                if MapIsEmpty(operations) == true then
                    return
                end
            end

            print("----------- 决斗胜利 -----------")
            local role = environment.currRole
            
            local currRoomId = environment.currRoomId

            local npcCharacters = fight:getTargetTeam(fight:getPlayerId()):getCharacters()

            for i, character in ipairs(npcCharacters) do
                local playerZhengqi = playerRole:getAttr("zhengqi")

                local targetZhengQi = character:getAttr("zhengqi")

                if playerZhengqi < 1000 then
                elseif playerZhengqi < 10000 then
                    targetZhengQi = targetZhengQi * 0.5
                elseif playerZhengqi < 100000 then
                    targetZhengQi = targetZhengQi * 0.2
                else
                    targetZhengQi = targetZhengQi * 0.1
                end

                playerRole:setAttr("zhengqi", tonumber(playerZhengqi - targetZhengQi))
            end

            role:setFlag("是否死亡", true)

            map:removeRoomRole(currRoomId, role.id)

            map.__MapLayer:delayRefreshMap()

            map:doOperationByName("决斗胜利", operations, environment)
        end
    )

    finishCallback:setLoseCallbackFunc(failFunc)

    finishCallback:setDrawCallbackFunc(failFunc)

    finishCallback:setRunawayFunc(failFunc)

    finishCallback:setFinishCallbackFunc(
        function(fight)
            print("----------- 决斗完成 -----------")

            local fightPlayer = fight:getCharacter(playerRole:getAttr("id"))
            local qi = fightPlayer:getAttr("qi")
            local neili = fightPlayer:getAttr("neili")
            local currQiMax = fightPlayer:getAttr("qiMax")
            local qiLimit = fightPlayer:getAttr("qiLimit")
            local qiPercent = currQiMax / qiLimit

            playerRole:setAttr("qi", qi)
            playerRole:setAttr("neili", neili)
            playerRole:setAttr("qiPercent", qiPercent)
        end
    )

    return finishCallback
end

function FondMapBattleRunner:__intiNpcTeams(npcId, map)
    local teamId = assert(TeamIdRes[tostring(npcId)].queue, "角色 id = " .. tostring(npcId) .. "没有配置战斗队列")

    local teamInfo = assert(BattleTeamRes[tostring(teamId)], "战队不存在 teamId = " .. tostring(teamId))

    local FIGHT_TEAM_ID = "NPC_TEAM_" .. tostring(teamId)

    local npcTeams = {}

    for i = 1, FightCommons.TEAMMATE_COUNT do
        local posNpcId = teamInfo["pos" .. tostring(i) .. "NPC"]

        local npcAttrResId = teamInfo["pos" .. tostring(i) .. "AttributeID"]

        if posNpcId and npcAttrResId then
            local npcRole = map:getRole(posNpcId)

            --@RefType [src.app.FightSystem.FightCharacterBuilder.IFightCharacterBuilder#IFightCharacterBuilder]
            local builder = BasicMapNpcFightCharacterBuilder:create(FondFightNpcBuilderConfig:create(npcRole, npcAttrResId))

            local npc = builder:buildCharacter()

            npc:setTeamId(FIGHT_TEAM_ID)

            npc:setPosIndex(3 + i)

            npcTeams[tostring(i)] = npc
        end
    end

    return npcTeams
end

function FondMapBattleRunner:__initPlayerCharacter(playerRole)
    --@RefType [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
    local character = FondFightPlayerBuilder:create(playerRole):buildCharacter()
    character:setTeamId("PLAYER_TEAM")
    character:setPosIndex(1)
    return character
end

return FondMapBattleRunner
00000000000000