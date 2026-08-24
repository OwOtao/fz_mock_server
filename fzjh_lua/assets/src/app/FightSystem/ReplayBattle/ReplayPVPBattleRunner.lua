--[[
    author:Seven
    time:2024-04-19 21:11:28
    desc:
]]
local newClass = require("third.class.NewClass")

local LocalPlayerFightCharacterBuilder = require("app.FightSystem.FightCharacterBuilder.LocalPlayerFightCharacterBuilder")

local ReplayPVPBattleRunner = {}

function ReplayPVPBattleRunner:create(...)
    return ReplayPVPBattleRunner.new():__init(...)
end

function ReplayPVPBattleRunner:__init(usersinfo, frames)
    self.__usersinfo = usersinfo

    self.__frames = frames

    return self
end

function ReplayPVPBattleRunner:__getPositionIndex(teamid)
    self.__indexRecordMap = self.__indexRecordMap or {}

    if MapIsEmpty(self.__indexRecordMap) then
        self.__indexRecordMap[teamid] = 1

        return self.__indexRecordMap[teamid]
    end

    if self.__indexRecordMap[teamid] == nil then
        self.__indexRecordMap[teamid] = 4
        return self.__indexRecordMap[teamid]
    end

    self.__indexRecordMap[teamid] = self.__indexRecordMap[teamid] + 1

    return self.__indexRecordMap[teamid]
end

function ReplayPVPBattleRunner:__createCharacter(roledata)
    local role = Role:create(roledata)

    role:getSelfCreatedSkillSystem():updataSelfCreatedSkillMap()

    role:getFistFootSystem():initFromPVPData(roledata.fistFootSystemPVPInfo)

    role:getTeacherBuildSystem():initFromPVPData(roledata.teacherBuildSystemPVPInfo)

    local character = LocalPlayerFightCharacterBuilder:create(role):buildCharacter()

    return character
end

function ReplayPVPBattleRunner:runReplayBattle()
    --@RefType [src.app.FightSystem.Fight.FightFinishCallback#FightFinishCallback]
    local finishCallback = require("app.FightSystem.Fight.FightFinishCallback"):create()

    finishCallback:setFinishCallbackFunc(
        function(fight)
            print("战斗结束")
        end
    )

    finishCallback:setDestoryCallbackFunc(
        function()
            MainControllLayer:resumeUpdate()
            print("战斗结束")
        end
    )

    --@RefType [src.app.FightSystem.Fight.BattleSystem#Fight]
    local fight = require("app.FightSystem.Fight.BattleSystem"):create(require("app.FightSystem.NetworkBattle.MapNetBattleConfig"), finishCallback)

    if #self.__usersinfo > 1 then
        for i, v in ipairs(self.__usersinfo) do
            local userdata = v.userdata
            local role = Role:create(userdata)

            role:getSelfCreatedSkillSystem():updataSelfCreatedSkillMap()

            role:getFistFootSystem():initFromPVPData(userdata.fistFootSystemPVPInfo)

            role:getTeacherBuildSystem():initFromPVPData(userdata.teacherBuildSystemPVPInfo)

            local character = LocalPlayerFightCharacterBuilder:create(role):buildCharacter()

            character:setTeamId(v.teamid)

            character:setPosIndex(self:__getPositionIndex(v.teamid))
            
            fight:addCharacter(character)

            if i == 1 then
                fight:setPlayerId(character:getId())
            end
        end
    else
        local role_info = self.__usersinfo[1]

        local roledata = role_info.userdata

        local role = Role:create(roledata)

        role:getSelfCreatedSkillSystem():updataSelfCreatedSkillMap()

        role:getFistFootSystem():initFromPVPData(roledata.fistFootSystemPVPInfo)

        role:getTeacherBuildSystem():initFromPVPData(roledata.teacherBuildSystemPVPInfo)

        local character = LocalPlayerFightCharacterBuilder:create(role):buildCharacter()

        character:setTeamId(role_info.teamid)

        character:setPosIndex(1)

        fight:addCharacter(character)

        fight:setPlayerId(character:getId())

        --@RefType [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
        local character2 = LocalPlayerFightCharacterBuilder:create(role):buildCharacter()
        character2:setAttr("name", "克隆人2")
        character2:setAttr("id", "test_2")
        character2:setTeamId("team_2")
        character2:setPosIndex(4)
        fight:addCharacter(character2)
    end

    --@RefType [src.app.FightSystem.Updater.ReplayUpdater#ReplayUpdater]
    local updater = require("app.FightSystem.Updater.ReplayUpdater"):create(self.__frames)

    local fightMainView = require("app.FightSystem.Veiws.FightMainView"):create(nil, require("app.FightSystem.Veiws.ViewsLayout.ReplayViewLayout"))

    fight:setFightOutput(fightMainView)

    cc.Director:getInstance():getRunningScene():addChild(fightMainView)

    fight:start(updater)
end

return newClass("ReplayPVPBattleRunner", {}, ReplayPVPBattleRunner)
0000000000