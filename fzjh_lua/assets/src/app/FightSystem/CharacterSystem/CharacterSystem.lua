--[[
    author:Seven
    time:2022-06-29 16:54:55
    desc: 角色管理系统
]]
local newClass = require("third.class.NewClass")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local CharacterTeam = require("app.FightSystem.CharacterSystem.CharacterTeam")

local AFightSystem = require("app.FightSystem.Fight.BasicBattleSystem.AFightSystem")

--@SuperType [src.app.FightSystem.Fight.BasicBattleSystem.AFightSystem#AFightSystem]
local CharacterSystem = {}

CharacterSystem.SYSTEM_NAME = "CharacterSystem"

local log = function(...)
    FightUtil:printLog("CharacterSystem : ", ...)
end

function CharacterSystem:create()
    return CharacterSystem.new()
end

function CharacterSystem:ctor()
    self.__name = CharacterSystem.SYSTEM_NAME
    self.__characters = {}
    --@desc 等待入场角色
    self.__waitingList = {}
    self.__attackTargetMap = {}
    self.__teams = {}
end

function CharacterSystem:onInit()
    log("onInit")
    for i, v in ipairs(self.__characters) do
        self:__allocAttackTarget(v:getId())
    end
end

function CharacterSystem:onEnter()
    log("onEnter")
end

function CharacterSystem:onStart()
    log("onStart")
    for i, v in ipairs(self.__characters) do
        v:startFight()
    end
end

function CharacterSystem:onFinish()
    log("onFinish")
end

function CharacterSystem:__addWaitingEnterCharacter(c_id)
    table.insert(self.__waitingList, c_id)
end

--@desc: 等待进入战场的角色
--@author:Seven
--@time:2022-07-14 14:51:10
function CharacterSystem:getWaitingEnterCharacters()
    if table.getn(self.__waitingList) <= 0 then
        return {}
    end

    local list = {}

    for i, c_id in ipairs(self.__waitingList) do
        table.insert(list, self:getCharacter(c_id))
    end

    return list
end

--@desc: 移除移除等待进入角色列表
--@author:Seven
--@time:2022-07-14 14:53:30
--@c_id: 要移除的角色id
function CharacterSystem:removeWaitingEnterCharacter(c_id)
    if table.getn(self.__waitingList) <= 0 then
        return
    end
    for i, v in ipairs(self.__waitingList) do
        if v == c_id then
            table.remove(self.__waitingList, i)
            return
        end
    end
end

--@desc: 添加角色
--@author:Seven
--@time:2022-06-30 17:35:01
--@teamId: 队伍ID
--@character: [src.app.FightSystem.FightRole.FightCharacter#FightCharacter]
--@return: nil
function CharacterSystem:addCharacter(teamId, character)
    self:__addCharacter(character)
    self:__addCharacterToTeam(teamId, character)
    self:__addWaitingEnterCharacter(character:getId())
    log(string.format("添加角色 {队伍ID：%s，角色ID：%s，角色名字：%s}", tostring(teamId), character:getId(), character:getAttr("name")))
end

function CharacterSystem:__addCharacter(character)
    table.insert(self.__characters, character)
end

function CharacterSystem:__addCharacterToTeam(teamId, character)
    local team = self:getTeam(teamId)

    if team == nil then
        local c_team = CharacterTeam:create(teamId)

        self:__addTeam(c_team)

        team = c_team
    end

    team:addCharacter(character)
end

function CharacterSystem:removeCharacter(c_id)
    for i = table.getn(self.__characters), 1, -1 do
        local character = self.__characters[i]
        if character:getId() == c_id then
            table.remove(self.__characters, i)

            self:__removeCharacterToTeam(character:getTeamId(), c_id)

            log("战斗移除角色：", c_id)

            return character
        end
    end

    error("CharacterSystem:removeCharacter 移除角色失败，未找到角色：" .. tostring(c_id))
end

function CharacterSystem:__removeCharacterToTeam(teamId, c_id)
    local team = self:getTeam(teamId)

    if team == nil then
        assert(false, "__removeCharacterToTeam 没有队伍id：" .. tostring(teamId) .. "的队伍")
    end

    team:removeCharacter(c_id)
end

--@desc: 获取角色
--@author:Seven
--@time:2022-06-30 17:51:37
--@c_id: 角色id
--@return [src.app.FightSystem.FightRole.FightCharacter#FightCharacter]
function CharacterSystem:getCharacter(c_id)
    c_id = tostring(c_id)
    for i, character in ipairs(self.__characters) do
        if character:getId() == c_id then
            return character
        end
    end
end

function CharacterSystem:getCharacters()
    return self.__characters
end

--@desc: 获取全队队员
--@author:Seven
--@time:2022-06-30 17:52:25
--@teamId: 队伍ID
function CharacterSystem:getTeamCharacters(teamId)
    local list = {}

    local team = self:getTeam(teamId)

    if team == nil then
        assert(false, "getTeamCharacters 队伍id: " .. teamId .. " 不存在")
    end

    for i, v in ipairs(team:getCharacters()) do
        table.insert(list, v)
    end

    return list
end

--@desc: 获取队友
--@author:Seven
--@time:2022-06-30 17:53:01
--@c_id: 角色ID
--@return 队友列表
function CharacterSystem:getTeammates(c_id)
    local character = self:getCharacter(c_id)

    local list = {}

    local team = self:getTeam(character:getTeamId())

    for i, v in ipairs(team:getCharacters()) do
        if v:getId() ~= character:getId() then
            table.insert(list, v)
        end
    end

    return list
end

--@desc: 添加队伍
--@author:Seven
--@time:2022-08-30 11:15:50
--@c_team: [src.app.FightSystem.CharacterSystem.CharacterTeam#CharacterTeam]
function CharacterSystem:__addTeam(c_team)
    if table.getn(self.__teams) >= 2 then
        assert(false, "队伍数量超出限定最大数量2。")
    end
    table.insert(self.__teams, c_team)
end

function CharacterSystem:getTeams()
    if table.getn(self.__teams) <= 0 then
        assert(false, "当前战斗没有队伍")
    end

    return self.__teams
end

--@desc: 获取队伍
--@author:Seven
--@time:2022-08-30 11:18:08
--@teamId: 队伍id
--@return[src.app.FightSystem.CharacterSystem.CharacterTeam#CharacterTeam]
function CharacterSystem:getTeam(teamId)
    local team

    self:__walkTeam(
        function(t)
            if t:getId() == teamId then
                team = t
                return true
            end
        end
    )

    return team
end

function CharacterSystem:__walkTeam(func)
    for _, v in ipairs(self.__teams) do
        local isBreak = func(v)
        if isBreak == true then
            break
        end
    end
end

--@desc: 分配攻击目标
--@author:Seven
--@time:2022-09-06 14:57:31
--@c_id: 角色id
--@return: 攻击目标id
function CharacterSystem:__allocAttackTarget(c_id)
    local targetTeam = self:getTargetTeam(c_id)

    local targets = targetTeam:getCharacters()

    local allocList = {}

    for i, v in ipairs(targets) do
        --@RefType[src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
        v = v
        if not v:isOutOfBattleState() then
            table.insert(allocList, v:getId())
        end
    end

    if table.getn(allocList) > 0 then
        local ranIndex = FightUtil:random(1, table.getn(allocList))

        local targetId = allocList[ranIndex]

        self.__attackTargetMap[c_id] = targetId

        return targetId
    end

    return nil
end

--@desc: 获取敌方队伍
--@author:Seven
--@time:2022-09-06 14:50:41
--@c_id: 角色id
--@return[src.app.FightSystem.CharacterSystem.CharacterTeam#CharacterTeam]
function CharacterSystem:getTargetTeam(c_id)
    local c_team = self:getTeam(self:getCharacter(c_id):getTeamId())

    for i, v in ipairs(self:getTeams()) do
        if v:getId() ~= c_team:getId() then
            return v
        end
    end
end

--@desc: 获取攻击目标
--@author:Seven
--@time:2022-06-30 18:11:39
--@c_id: 角色ID
--@return [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
function CharacterSystem:getAttackTarget(c_id)
    local targetId = self.__attackTargetMap[tostring(c_id)]

    if targetId == nil then
        assert(false, "已无目标可选取，检查代码流程！")
    end

    return self:getCharacter(targetId)
end

--@desc: 检查并重新分配攻击目标
--@author:Seven
--@time:2023-03-03 10:48:10
function CharacterSystem:checkAndAllocTarget()
    for _, character in ipairs(self.__characters) do
        --@RefType [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
        character = character
        if not character:isOutOfBattleState() then
            local targetId = self.__attackTargetMap[character:getId()]
            if targetId then
                local target = self:getCharacter(targetId)

                --@desc 目标是脱战状态，需重新分配
                if target:isOutOfBattleState() then
                    local newTargetId = self:__allocAttackTarget(character:getId())
                    if newTargetId then
                        self.__fight:outputSwitchAttackTarget(character:getId(), newTargetId)
                    else
                        error("CharacterSystem:checkAndAllocTarget 无法分配到攻击目标，检查代码流程！！")
                    end
                end
            else
                --@desc 本身没有目标
                local newTargetId = self:__allocAttackTarget(character:getId())
                if newTargetId then
                    self.__fight:outputSwitchAttackTarget(character:getId(), targetId)
                else
                    error("CharacterSystem:checkAndAllocTarget 无法分配到攻击目标，检查代码流程！！")
                end
            end
        end
    end
end

return newClass("CharacterSystem", {AFightSystem}, CharacterSystem)
000000000