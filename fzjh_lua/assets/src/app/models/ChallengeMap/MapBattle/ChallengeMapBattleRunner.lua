--[[
    author:Seven
    time:2024-01-23 14:15:46
    desc:
]]
local FightCommons = require("app.FightSystem.FightCommons")

local BasicMapNpcFightCharacterBuilder = require("app.FightSystem.FightCharacterBuilder.NPCBuilder.BasicMapNpcFightCharacterBuilder")

local ChallengeMapResource = require("app.models.ChallengeMap.ChallengeMapResource")

local ChallengeMapFightNpcBuilderConfig = require("app.models.ChallengeMap.MapBattle.ChallengeMapFightNpcBuilderConfig")

local isImplement = require("third.assertIsInstance.assertIsInstance")

local FIGHT_TEAM_ID = "CHALLENGE_MAP_NPC_TEAM"

local ChallengeMapBattleRunner = {}

function ChallengeMapBattleRunner:runBattle(map, npcId, finishCallback)
    local npcTeams = self:__initNpcTeam(map, npcId)

    local playerCharacter = self:__initPlayerCharacter(map)

    local fight = require("app.FightSystem.Fight.BattleSystem"):create(require("src.app.FightSystem.Fight.SystemConfig.BasicBattleSystemConfig"), finishCallback)

    fight:addCharacter(playerCharacter)

    fight:setPlayerId(playerCharacter:getId())

    for _, npc in pairs(npcTeams) do
        fight:addCharacter(npc)
    end

    local backgroundSceneId = map:getRoom(map:getCurrRoomId()).fightBackground

    --@RefType [src.app.FightSystem.Updater.LocalUpdater#LocalUpdater]
    local updater = require("app.FightSystem.Updater.LocalUpdater"):create()

    local fightMainView = require("app.FightSystem.Veiws.FightMainView"):create(backgroundSceneId)

    fight:setFightOutput(fightMainView)

    cc.Director:getInstance():getRunningScene():addChild(fightMainView)

    fight:start(updater)
end

--@desc: 创建NPC
--@author:Seven
--@time:2024-01-23 14:20:25
--@map: [src.app.models.ChallengeMap.ChallengeMap#ChallengeMap]
--@npcId: npcId
--@return: array ["src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter"]
function ChallengeMapBattleRunner:__initNpcTeam(map, npcId)
    local npcRole = map:getObject(npcId)

    local idType = npcRole.combatid[1]

    local team_info

    --@idType 1 id , 2 teamId
    if idType == 1 then
        team_info = ChallengeMapResource:getInstance():getNpcTeamMapById(npcRole.combatid[2])
    else
        team_info = ChallengeMapResource:getInstance():getNpcTeamMapByGroupId(npcRole.combatid[2], map:getPlayer():getAttr("lv"))
    end

    local npcTeams = {}

    for i = 1, FightCommons.TEAMMATE_COUNT do
        local posNpcId = team_info["pos" .. tostring(i) .. "NPCbgID"]

        local npcAttrResId = team_info["pos" .. tostring(i) .. "AttributeID"]

        if posNpcId and posNpcId ~= 0 and npcAttrResId then
            local level = team_info["pos" .. tostring(i) .. "AttributeLevel"]

            local name = team_info["pos" .. tostring(i) .. "NPCname"]

            local position = 3 + i

            --@RefType [src.app.FightSystem.FightCharacterBuilder.IFightCharacterBuilder#IFightCharacterBuilder]
            local builder = BasicMapNpcFightCharacterBuilder:create(ChallengeMapFightNpcBuilderConfig:create(name, level, npcAttrResId, posNpcId, position))

            local npc = builder:buildCharacter()

            npc:setTeamId(FIGHT_TEAM_ID)

            npc:setPosIndex(position)

            npcTeams[tostring(i)] = npc
        end
    end

    return npcTeams
end

--@desc: 创建玩家角色
--@author:Seven
--@time:2024-01-23 20:38:27
--@map: [src.app.models.ChallengeMap.ChallengeMap#ChallengeMap]
function ChallengeMapBattleRunner:__initPlayerCharacter(map)
    local LocalPlayerFightCharacterBuilder = require("app.FightSystem.FightCharacterBuilder.LocalPlayerFightCharacterBuilder")
    local playerRole = map:getPlayer()

    --@RefType [src.app.models.ChallengeMap.ChallengeMapSystem#ChallengeMapSystem]
    local ChallengeMapSystem = require("app.models.ChallengeMap.ChallengeMapSystem")

    local buff_system = ChallengeMapSystem:getInstance():getBuffSystem()

    local carrybuffs = buff_system:getFightCarryBuffs()

    local challenge_player_carrybuffs = {
        -- {
        --     addBuffID = 500001,
        --     addBuffdynamicArg1 = 1,
        --     addBuffdynamicArg2 = 0,
        --     addBuffdynamicArg3 = 100,
        --     addBuffdynamicArg4 = 0
        -- }
    }
    if not MapIsEmpty(carrybuffs) then
        for i, v in ipairs(carrybuffs) do
            table.insert(
                challenge_player_carrybuffs,
                {
                    addBuffID = v[1],
                    addBuffdynamicArg1 = v[2],
                    addBuffdynamicArg2 = v[3],
                    addBuffdynamicArg3 = v[4],
                    addBuffdynamicArg4 = v[5]
                }
            )
        end
    end

    local character = LocalPlayerFightCharacterBuilder:create(playerRole, challenge_player_carrybuffs):buildCharacter()
    character:setTeamId("PLAYER_TEAM")
    character:setPosIndex(1)
    return character
end

return ChallengeMapBattleRunner
0000000000000000