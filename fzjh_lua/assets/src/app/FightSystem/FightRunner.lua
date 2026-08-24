local BattleConstConf = require("app.FightSystem.Configuration.BattleConstConf")

local FightCommons = require("app.FightSystem.FightCommons")

local FightRunner = {}

function FightRunner:newRun()
    local FightFinishCallback = require("app.FightSystem.Fight.FightFinishCallback")
    --@RefType [src.app.FightSystem.Fight.BattleSystem#Fight]
    local fight = require("app.FightSystem.Fight.BattleSystem"):create(require("app.FightSystem.Fight.SystemConfig.BasicBattleSystemConfig"), FightFinishCallback:create())

    local LocalPlayerFightCharacterBuilder = require("app.FightSystem.FightCharacterBuilder.LocalPlayerFightCharacterBuilder")
    --@RefType [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
    local character = LocalPlayerFightCharacterBuilder:create(User:getRole()):buildCharacter()
    character:setTeamId("team_1")
    character:setPosIndex(1)
    fight:addCharacter(character)

    -- local character3 = LocalPlayerFightCharacterBuilder:create(User:getRole()):buildCharacter()
    -- character3:setAttr("name", "克隆人3")
    -- character3:setAttr("id", "test_3")
    -- character3:setTeamId("team_1")
    -- character3:setPosIndex(2)
    -- fight:addCharacter(character3)

    -- local character5 = LocalPlayerFightCharacterBuilder:create(User:getRole()):buildCharacter()
    -- character5:setAttr("name", "克隆人5")
    -- character5:setAttr("id", "test_5")
    -- character5:setTeamId("team_1")
    -- character5:setPosIndex(3)
    -- fight:addCharacter(character5)

    --@RefType [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
    local character2 = LocalPlayerFightCharacterBuilder:create(User:getRole()):buildCharacter()
    character2:setAttr("name", "克隆人2")
    character2:setAttr("id", "test_2")
    character2:setTeamId("team_2")
    character2:setPosIndex(4)
    fight:addCharacter(character2)

    -- --@RefType [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
    -- local character4 = LocalPlayerFightCharacterBuilder:create(User:getRole()):buildCharacter()
    -- character4:setAttr("name", "克隆人4")
    -- character4:setAttr("id", "test_4")
    -- character4:setTeamId("team_2")
    -- character4:setPosIndex(5)
    -- fight:addCharacter(character4)

    -- --@RefType [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
    -- local character6 = LocalPlayerFightCharacterBuilder:create(User:getRole()):buildCharacter()
    -- character6:setAttr("name", "克隆人6")
    -- character6:setAttr("id", "test_6")
    -- character6:setTeamId("team_2")
    -- character6:setPosIndex(6)
    -- fight:addCharacter(character6)

    -- fight:addCharacter(character3)

    fight:setPlayerId(character:getId())

    --@RefType [src.app.FightSystem.Updater.LocalUpdater#LocalUpdater]
    local updater = require("app.FightSystem.Updater.LocalUpdater"):create()

    local fightMainView = require("app.FightSystem.Veiws.FightMainView"):create()

    fight:setFightOutput(fightMainView)

    cc.Director:getInstance():getRunningScene():addChild(fightMainView)

    fight:start(updater)
end

function FightRunner:netFightRunTest(client, character)
    local FightFinishCallback = require("app.FightSystem.Fight.FightFinishCallback")

    --@RefType [src.app.FightSystem.Fight.BattleSystem#Fight]
    local fight = require("app.FightSystem.Fight.BattleSystem"):create(require("app.FightSystem.NetworkBattle.MapNetBattleConfig"), FightFinishCallback:create())

    local LocalPlayerFightCharacterBuilder = require("app.FightSystem.FightCharacterBuilder.LocalPlayerFightCharacterBuilder")

    character:setPosIndex(1)

    --@RefType [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
    local character2 = LocalPlayerFightCharacterBuilder:create(User:getRole()):buildCharacter()
    character2:setAttr("name", "克隆人2")
    character2:setAttr("id", "test_2")
    character2:setTeamId("team_2")
    character2:setPosIndex(4)

    fight:addCharacter(character)
    fight:addCharacter(character2)

    fight:setPlayerId(character:getId())

    --@RefType [src.app.FightSystem.Updater.NetUpdater#NetUpdater]
    local updater = require("app.FightSystem.Updater.NetUpdater"):create(client)

    local fightMainView = require("app.FightSystem.Veiws.FightMainView"):create()

    fight:setFightOutput(fightMainView)

    cc.Director:getInstance():getRunningScene():addChild(fightMainView)

    fight:start(updater)
end

function FightRunner:runNetFight(client, characters, playerId)
    --@RefType [src.app.FightSystem.Fight.FightFinishCallback#FightFinishCallback]
    local finishCallback = require("app.FightSystem.Fight.FightFinishCallback"):create()

    finishCallback:setFinishCallbackFunc(
        function(fight)
            MainControllLayer:resumeUpdate()
            User:getRole():setFlag("PVP活动状态", "空闲")
            print("战斗结束")
        end
    )

    finishCallback:setDestoryCallbackFunc(
        function()
            MainControllLayer:resumeUpdate()
            User:getRole():setFlag("PVP活动状态", "空闲")
            print("战斗结束")
        end
    )

    --@RefType [src.app.FightSystem.Fight.BattleSystem#Fight]
    local fight = require("app.FightSystem.Fight.BattleSystem"):create(require("app.FightSystem.NetworkBattle.MapNetBattleConfig"), finishCallback)

    for i, v in ipairs(characters) do
        fight:addCharacter(v)
    end

    fight:setPlayerId(tostring(playerId))

    --@RefType [src.app.FightSystem.Updater.NetUpdater#NetUpdater]
    local updater = require("app.FightSystem.Updater.NetUpdater"):create(client)

    local fightMainView = require("app.FightSystem.Veiws.FightMainView"):create()

    fight:setFightOutput(fightMainView)

    cc.Director:getInstance():getRunningScene():addChild(fightMainView)

    fight:start(updater)

    User:getRole():setFlag("PVP活动状态", "忙碌")

    MainControllLayer:pauseUpdate()
end

return FightRunner
000000000000000