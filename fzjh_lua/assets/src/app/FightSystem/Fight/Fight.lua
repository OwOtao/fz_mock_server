local class = require("third.class.NewClass")

local FightCommons = require("app.FightSystem.FightCommons")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local FIGHT_STATE = FightCommons.FIGHT_STATE

--@RefType [src.app.FightSystem.Fight.BattleGlobalData#BattleGlobalData]
local BattleGlobalData = require("app.FightSystem.Fight.BattleGlobalData")

local Fight = {
    --@region 相关系统
    __update_system = nil,
    __cmd_system = nil,
    __auto_attack_system = nil,
    __character_system = nil,
    __buff_system = nil,
    --@endregion

    __state = nil,
    __win_team = nil,
    __playerId = nil,
    __playerTeamId = nil,
    --@desc type:{} element : teamid = team
    __teamDict = {},
    __leftTeamId = nil,
    __rightTeamId = nil
}

function Fight:create()
    return self.new()
end

function Fight:ctor()
    self.__state = FIGHT_STATE.IDLE
end

function Fight:initFight()
    self.__update_system:init()
    self.__joinFight_system:init()
    self.__cmd_system:init()
    self.__character_system:init()
    self.__buff_system:init()

    self.__buff_system:addEventListener(
        function(eventType, parmas)
            if eventType == self.__buff_system.Constants.BuffSystemEventType.UpdateRoleState then
                local roleId, state = parmas[1], parmas[2]
                self.__character_system:updateCharacterControlledState(roleId, state)
            end
        end
    )
end

function Fight:setIFightCtrl(fightCtrl)
    --@RefType [Fight2Layer]
    self.__fightUICtrl = fightCtrl
end

function Fight:setFinishCallback(fightCallback)
    --@RefType [src.app.FightSystem.Fight.FightFinishCallback#FightFinishCallback]
    self.__finishCallback = fightCallback
end

function Fight:getPlayerId()
    return self.__playerId
end

function Fight:getPlayerTeamId()
    return self.__playerTeamId
end

function Fight:startFight()
    if self.__character_system then
        --@desc 通知角色系统战斗开始，角色系统开始分配对手
        self.__character_system:startFight()
    end

    if self.__buff_system then
        self.__buff_system:startFight()
    end

    self.__fightUICtrl:setIUpdate(self.__update_system)
    self.__fightUICtrl:setIFight(self)

    local leftTeamCharacters = self:getFightTeamById(self:getLeftTeamId()):getCharacters()
    for i, v in ipairs(leftTeamCharacters) do
        self.__fightUICtrl:addLeftFightCharacter(v)
    end

    local rightTeamCharacters = self:getFightTeamById(self:getRightTeamId()):getCharacters()
    for i, v in ipairs(rightTeamCharacters) do
        self.__fightUICtrl:addRightFightCharacter(v)
    end

    self.__fightUICtrl:startFight(
        function()
            --@desc 战斗开始，进入角色进入战场状态
            self:changeState(FIGHT_STATE.JOINING)
            self.__update_system:start()
        end
    )
end

--@desc 交战开始
function Fight:startBattale()
    self:changeState(FIGHT_STATE.BATTLE)
end

function Fight:setCharacterSystem(sys)
    --@RefType[src.app.FightSystem.FightRole.CharacterSystem#CharacterSystem]
    self.__character_system = sys
end

function Fight:setBuffSystem(sys)
    --@RefType[app.FightSystem.FightBuff.BuffSystem#BuffSystem]
    self.__buff_system = sys
end

--@return [src.app.FightSystem.FightBuff.BuffSystem#BuffSystem]
function Fight:getBuffSystem()
    return self.__buff_system
end

function Fight:setJoinFightSystem(sys)
    --@RefType [src.app.FightSystem.Fight.JoinFightSystem#JoinFightSystem]
    self.__joinFight_system = sys
end

function Fight:setUpdateSystem(update_sys)
    --@RefType [src.app.FightSystem.Updater.LocalUpdateSystem#LocalUpdateSystem]
    self.__update_system = update_sys
end

function Fight:setCommandSystem(cmd_sys)
    --@RefType [src.app.FightSystem.FightCommand.FightCommandSystem#FightCommandSystem]
    self.__cmd_system = cmd_sys
end

function Fight:changeState(state)
    if state == FIGHT_STATE.JOINING then
        BattleGlobalData:getInstance():put("m_battle_recover", false)
    elseif state == FIGHT_STATE.BATTLE then
        BattleGlobalData:getInstance():put("m_battle_recover", true)
        self:triggerEnterFightBuffAdders()
    end
    self.__state = state
end

-- 出发入场buff
function Fight:triggerEnterFightBuffAdders()
    local characters = self:getFightCharacters()
    for i, character in pairs(characters) do
        local activeSkills = character:getActiveSkills()
        for id, activeSkill in pairs(activeSkills) do
            local buffAdder = activeSkill:getEnterFightBuffAdder()
            -- local BuffAdder = require("app.FightSystem.FightBuff.BuffAdder.EnterFightBuffAdder")
            -- local buffAdder = BuffAdder:create({"LaunTestGH"})
            if buffAdder then
                local CustomBuffNeeded = require("app.FightSystem.FightBuff.CustomBuffNeeded")
                local buffNeeded = CustomBuffNeeded:create()
                buffNeeded:setGetAttrFunc(
                    function(attrName)
                        return character:getAttr(attrName)
                    end
                )
        
                buffNeeded:setSelfWeaponAttrGetter(
                    function(attrName)
                        return character:getWeapon():getWeaponAttr(attrName)
                    end
                )
        
                buffNeeded:setGetTargetAttrFunc(
                    function(attrName)
                        return character:getAttr(attrName)
                    end
                )
        
                buffNeeded:setTargetWeaponAttrGetter(
                    function(attrName)
                        return character:getWeapon():getWeaponAttr(attrName)
                    end
                )
        
                buffNeeded:setSelfWeaponType(character:getWeapon():getFirstType())
                buffNeeded:setTargetWeaponType(character:getWeapon():getFirstType())
        
                buffAdder:setBuffNeeded(buffNeeded)
                buffAdder:setCharacter(character)

                buffAdder:conditionCheck(character.__character_sys:getFight(), character, character)

                buffAdder:addBuff(character.__character_sys:getFight(), character, character, 0)
            end

        end
    end
end

function Fight:getFightState()
    return self.__state
end

function Fight:isWin()
    return self.__fightResult == 1
end

function Fight:isDraw()
    return self.__fightResult == 4
end

function Fight:isRunaway()
    return self.__fightResult == 3
end

--@desc: 添加队伍
--@author:Seven
--@time:2021-07-01 20:50:33
--@team: [src.app.FightSystem.FightDataModel.FightTeam#FightTeam]
function Fight:addTeam(team)
    local teamId = team:getTeamId()
    if self.__teamDict[teamId] ~= nil then
        assert(false, "Fight:addTeam 队伍ID重复，检查代码")
    end

    self.__teamDict[teamId] = team
end

--@desc: 指定玩家队伍ID
--@author:Seven
--@time:2021-07-01 20:51:21
--@teamId: 队伍ID
function Fight:setLeftTeamId(teamId)
    --@desc 检查是否队伍ID
    local isFightTeamId = false

    for tId, _ in pairs(self.__teamDict) do
        if tId == teamId then
            isFightTeamId = true
            break
        end
    end

    if isFightTeamId == false then
        assert(false, "Fight:setLeftTeamId 设置玩家队伍id错误，设置id不为当前战斗队伍ID：" .. teamId)
    end

    self.__leftTeamId = teamId
end

--@desc: 指定敌方队伍ID
--@author:Seven
--@time:2021-07-01 20:52:02
--@teamId: 队伍ID
function Fight:setRightTeamId(teamId)
    --@desc 检查是否队伍ID
    local isFightTeamId = false

    for tId, _ in pairs(self.__teamDict) do
        if tId == teamId then
            isFightTeamId = true
            break
        end
    end

    if isFightTeamId == false then
        assert(false, "Fight:setRightTeamId 设置敌方队伍id错误，设置id不为当前战斗队伍ID：" .. teamId)
    end

    self.__rightTeamId = teamId
end

function Fight:getLeftTeamId()
    return self.__leftTeamId
end

function Fight:getRightTeamId()
    return self.__rightTeamId
end

--@desc: 获取队伍对象
--@author:Seven
--@time:2021-07-01 21:13:43
--@teamId: 队伍ID
--@return [src.app.FightSystem.FightDataModel.FightTeam#FightTeam]
function Fight:getFightTeamById(teamId)
    return self.__teamDict[teamId]
end

--@desc: 添加角色到玩家队伍
--@author:Seven
--@time:2021-07-01 20:43:50
--@character: [src.app.FightSystem.FightRole.FightCharacter#FightCharacter]
function Fight:addCharacterToLeftTeam(character)
    local team = self:getFightTeamById(self:getLeftTeamId())
    team:addCharacter(character)
    character:setTeamId(self:getLeftTeamId())

    if self.__joinFight_system then
        self.__joinFight_system:addCharacterWaitingList(character)
    end

    if self.__character_system then
        self.__character_system:addCharacter(character)
    end

    if character:isPlayer() then
        self.__playerId = character:getId()
        self.__playerTeamId = character:getTeamId()
    end
    FightUtil:printLog(string.format("添加人物：%s(id：%s) 进入队伍：%s", character:getAttr("name"), tostring(character:getId()), self:getLeftTeamId()))
end

--@desc: 添加角色到目标队伍
--@author:Seven
--@time:2021-07-01 20:44:25
function Fight:addCharacterToRightTeam(character)
    local team = self:getFightTeamById(self:getRightTeamId())

    team:addCharacter(character)

    character:setTeamId(self:getRightTeamId())

    if self.__joinFight_system then
        self.__joinFight_system:addCharacterWaitingList(character)
    end

    if self.__character_system then
        self.__character_system:addCharacter(character)
    end
    FightUtil:printLog(string.format("添加人物：%s(id：%s) 进入队伍：%s", character:getAttr("name"), tostring(character:getId()), self:getRightTeamId()))
end

--@desc: 添加玩家操作数据
--@author:Seven
--@time:2021-06-18 16:07:58
--@cmd_data: 命令数据
function Fight:addSendCommand(cmd_data)
    if cmd_data.type == nil then
        assert(false, "Fight:addSendCommand 缺少type ")
    end

    if cmd_data.c_id == nil then
        assert(false, "Fight:addSendCommand 缺少操作角色的id")
    end

    if cmd_data.data == nil then
        assert(false, "Fight:addSendCommand 缺少命令数据")
    end
    return self.__cmd_system:putSendCmd(cmd_data)
end

--@desc:添加要处理的命令
--@author:Seven
--@time:2021-06-18 16:08:22
--@cmd: 命令数据
function Fight:addCommand(frame_index, cmds)
    self.__cmd_system:addCommands(frame_index, cmds)
end

function Fight:getCurrActionCharacterId()
    return self.__character_system:getActionId()
end

--@desc: 发送命令
--@author:Seven
--@time:2021-05-07 20:52:26
function Fight:sendCommands()
    local send_cmds = self.__cmd_system:getSendCmds()

    self.__update_system:sendCmds(send_cmds)

    self.__cmd_system:clearSendCmds()
end

function Fight:getFightCharacters()
    if self.__character_system then
        return self.__character_system:getCharacters()
    end

    return {}
end

--@desc: 获取角色
--@author:Seven
--@time:2021-06-11 17:13:37
--@character_id: 角色id
--@return [src.app.FightSystem.FightRole.FightCharacter#FightCharacter]
function Fight:getFightCharacter(character_id)
    if self.__character_system then
        return self.__character_system:getCharacter(character_id)
    end

    return nil
end

--@desc: 角色进入战场
--@author:Seven
--@time:2021-06-28 21:00:43
--@team_id: 队伍id
--@f_character: [src.app.FightSystem.FightRole.FightCharacter#FightCharacter]
function Fight:characterEnterFight(team_id, f_character)
    if self.__character_system then
        self.__character_system:addCharacter(team_id, f_character)
    end
end

--@desc: 申请使用主动技能
--@author:Seven
--@time:2021-06-23 20:51:06
--@c_id: 角色id
--@act_id: 技能ID
function Fight:prepReleaseActiveSkill(c_id, act_id)
    if self.__state ~= FIGHT_STATE.BATTLE then
        return
    end

    if self.__character_system then
        self.__character_system:characterPrepReleaseActiveSkill(c_id, act_id)
    end
end

--@desc: 通知角色可进行逃跑
--@author:Seven
--@time:2022-01-13 16:12:18
--@c_id: 角色id
function Fight:prepRunaway(c_id)
    if self.__state ~= FIGHT_STATE.BATTLE then
        return
    end

    if self.__character_system then
        self.__character_system:characterPrepRunaway(c_id)
    end
end

--@desc: 通知角色准备切换武器
--@author:Seven
--@time:2022-01-13 18:00:25
--@c_id: 角色ID
function Fight:prepChangeWeapon(c_id)
    if self.__state ~= FIGHT_STATE.BATTLE then
        return
    end

    if self.__character_system then
        self.__character_system:characterPrepChangeWeapon(c_id)
    end
end

--@desc: 通知角色准备气血恢复
--@author:Seven
--@time:2022-01-13 18:00:08
--@c_id: 角色ID
function Fight:prepRecoverQi(c_id)
    if self.__state ~= FIGHT_STATE.BATTLE then
        return
    end

    if self.__character_system then
        self.__character_system:characterPrepRecoverQi(c_id)
    end
end

function Fight:__checkFinish()
    if self.__character_system:getActionId() ~= nil then
        return
    end

    local isCharactersAllDead = function(characters)
        local is_all_dead = true
        for j = 1, #characters do
            local character = characters[j]
            if not character:isDead() then
                is_all_dead = false
                break
            end
        end

        if is_all_dead == true then
            return true
        end

        return false
    end

    local isAllCharacterDead = isCharactersAllDead(self.__character_system:getCharacters())

    if isAllCharacterDead then
        self.__fightResult = 4
        self:changeState(FIGHT_STATE.FINISH)
        self:__notifyViewFinish()
        return
    end

    local team_dead = {}

    for _, team in pairs(self.__teamDict) do
        local characters = team:getCharacters()

        if isCharactersAllDead(characters) then
            table.insert(team_dead, team:getTeamId())
        end
    end

    if #team_dead > 0 then
        local playerIsLose = false
        for i = 1, #team_dead do
            local deadTeamId = team_dead[i]
            if deadTeamId == self.__playerTeamId then
                playerIsLose = true
                break
            end
        end

        if playerIsLose then
            self.__fightResult = 2
        else
            self.__fightResult = 1
        end
        self:changeState(FIGHT_STATE.FINISH)
        self:__notifyViewFinish()
        return
    end

    if self.__playerId then
        local player = self:getFightCharacter(self.__playerId)

        if player:isRunaway() then
            self.__fightResult = 3
            self:changeState(FIGHT_STATE.FINISH)
            self:__notifyViewFinish()
            return
        end
    end
end

function Fight:__notifyViewFinish()
    if self.__fightUICtrl then
        self.__fightUICtrl:showFinish(self.__fightResult)
    end
end

function Fight:isFinish()
    return self.__state == FIGHT_STATE.FINISH
end

function Fight:popMessage(msg)
    if self.__fightUICtrl then
        self.__fightUICtrl:popMessage(msg)
    end
end

function Fight:destoryFight()
    if self.__finishCallback then
        self.__finishCallback:runFinish(self)
    end

    self.__update_system:release()
    self.__joinFight_system:release()
    self.__cmd_system:release()
    self.__character_system:release()
    self.__buff_system:release()

    if self.__fightUICtrl then
        self.__fightUICtrl:hideLayer()
    end
end

function Fight:update(ft)
    self:__checkFinish()

    -- --@desc 处理上一帧的命令
    self.__cmd_system:update(ft)

    --@region 计算当前帧产生的命令

    --@region 游戏逻辑更新
    self.__joinFight_system:update(ft)

    self.__character_system:update(ft)

    self:sendCommands()
end

function Fight:updateView(ft)
    self.__fightUICtrl:updateView(ft)
end

return class("Fight", {}, Fight)
000