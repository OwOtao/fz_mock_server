--[[
    author:Seven
    time:2024-01-25 20:06:31
    desc: 副本网络战斗
]]
local newClass = require("third.class.NewClass")

local NetConf = require("app.models.net.NetConf")

local NetNode = require("app.models.net.NetNode")

local MapNetBattle = {}

function MapNetBattle:create(...)
    return MapNetBattle.new():__init(...)
end

function MapNetBattle:__init(map, attackId, targetId)
    --@RefType [BaseMap]
    self.__map = map

    self.__player = self.__map:getPlayer()

    --@desc 战斗发起者
    self.__attackerId = attackId

    --@desc 战斗接受者
    self.__targetId = targetId

    return self
end

function MapNetBattle:startFight()
    local loginNet = require("app.models.net.LoginNet"):create()

    local isLogin, result = loginNet:login()

    if not isLogin then
        PopText("战斗登录失败 : " .. result)
        return
    end

    --@RefType [src.app.models.net.NetNode#NetNode]
    self.__gameNode =
        NetNode:create(
        {
            subid = result.subid,
            secret = result.secret,
            sconv = result.sconv,
            host = NetConf.GATE_HOST,
            port = NetConf.GATE_PORT
        }
    )

    local isConnected, err = self.__gameNode:connect()

    if isConnected then
        self.__gameNode:registerMessageDispatch(
            "notify_client_change_fight_scene",
            function(request)
                if self.__startFail == true then
                    return
                end
                self.__isStartChange = true
                self.__gameNode:unregisterMessageDispatch("notify_client_change_fight_scene")
                self:__fightStart(request)
            end
        )

        if tostring(self.__player:getAttr("userid")) == self.__attackerId then
            return self:__attackStart()
        end
    else
        PopText("战斗连接失败 : " .. err)
    end
end

function MapNetBattle:__attackStart()
    local userid = self.__player:getAttr("userid")

    local target = self.__map:getRole(self.__targetId)

    local mapId = self.__map.id
    self.__gameNode:request(
        "create_fight_room",
        {
            mapid = mapId,
            creator = tostring(userid),
            players = {
                {
                    uid = tostring(userid),
                    name = self.__player:getAttr("name"),
                    teamid = "team_1_" .. tostring(userid)
                },
                {
                    uid = tostring(self.__targetId),
                    name = target:getAttr("name"),
                    teamid = "team_2_" .. tostring(self.__targetId)
                }
            }
        },
        function(response)
            print("MapNetBattle create room response :" .. tostring(response.roomid))
        end,
        function(exception)
            PopText("战斗房间创建失败")
            print("MapNetBattle create room exception :" .. tostring(exception:getExceptionMsg()))
        end
    )

    self.__waitTime = 0
    self.__waitHandle =
        Game:schedule(
        function(ft)
            if self.__isStartChange == true then
                self:__closeUpdate()
                return
            end

            self.__waitTime = self.__waitTime + ft

            if self.__waitTime >= 10 then
                PopText("战斗启动失败，请检查网络（100）")
                self.__startFail = true
                self:__close()
            end
        end,
        0
    )
end

function MapNetBattle:__closeUpdate()
    if self.__waitHandle == nil then
        return
    end

    Game:unschedule(self.__waitHandle)
end

function MapNetBattle:__close()
    self:__closeUpdate()
    self.__gameNode:disconnect()
end

function MapNetBattle:__fightStart(msg)
    local LocalPlayerFightCharacterBuilder = require("app.FightSystem.FightCharacterBuilder.LocalPlayerFightCharacterBuilder")

    local characterArray = {}
    for i, v in ipairs(msg.players) do
        local user_data = v.user_data
        local roledata = json.decode(user_data)

        local role = Role:create(roledata)
        role:getSelfCreatedSkillSystem():updataSelfCreatedSkillMap()
        role:getFistFootSystem():initFromPVPData(roledata.fistFootSystemPVPInfo)
        role:getTeacherBuildSystem():initFromPVPData(roledata.teacherBuildSystemPVPInfo)

        --@RefType [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
        local character = LocalPlayerFightCharacterBuilder:create(role):buildCharacter()
        character:setTeamId(v.teamid)
        character:setPosIndex(self:__getPositionIndex(v.teamid))
        table.insert(characterArray, character)
    end

    local FightRunner = require("app.FightSystem.FightRunner")

    local result, errmsg = pcall(FightRunner.runNetFight, FightRunner, self.__gameNode, characterArray, self.__player:getAttr("userid"))

    if result == false then
        PopText("战斗启动失败")
        for i = 1, 10 do
            print(errmsg .. "\n")
        end
        self.__gameNode:disconnect()
    end
end

function MapNetBattle:__getPositionIndex(teamid)
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

return newClass("MapNetBattle", {}, MapNetBattle)
00000000000000