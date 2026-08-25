-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/16 16:18:06
-- @desc 以下是局部变量定义
local NEW_VERSION = true -- 新版本开关, 用作新功能的开发测试 add by TangJian 2016/11/16 16:20:13
local INITIAL_TILI = 0 -- 角色战斗的初始体力值 add by TangJian 2016/11/16 16:20:14
-- local AUTO_ZHAO_TIMES_DAMAGE_FACTOR_ARRAY = {100 / 100, 42 / 100, 53 / 100, 40 / 100, 40 / 100, 40 / 100, 40 / 100, 40 / 100, 40 / 100}-- 被动招式伤害系数数组
local AUTO_ZHAO_TIMES_DAMAGE_FACTOR_ARRAY = {100 / 100, 60 / 100, 40 / 100, 40 / 100, 40 / 100, 40 / 100, 40 / 100, 40 / 100, 40 / 100}-- 被动招式伤害系数数组

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/16 16:17:52
-- @desc 一下是类的定义以及方法实现
local Skill = require("app.models.skill.Skill")
local FightRole = require("app.models.fight.FightRole")
local FightClient = require("app.models.fight.FightClient")
--@RefType [src.app.models.fight.NPCAI.ActiveZhaoRules#ActiveZhaoRules]
local ActiveZhaoRules= require("app.models.fight.NPCAI.ActiveZhaoRules")
--@RefType [src.app.models.Poison.FightForPoison.PoisonFight#PoisonFight]
local PoisonFight = require("app.models.Poison.FightForPoison.PoisonFight")

local LogSystem = require("app.models.LogSystem.LogSystem")
local HurtFactory = require("app.models.fight.Hurt.HurtFactory")
local FightEffectUI = require("app.models.fight.FightEffectUI")
local EffectUIInfo = require("src.app.models.fight.EffectUIInfo")
local SkillConst = require("app.models.skill.SkillConst")

-------------------------------------------------------------------------------------------------------------
-- @author Tangjian
-- @time 2016/4/14 0014 21:07
local Fight = {
    _currFrame = 0, -- 当前帧数
    _eventListener = function(...)print("_eventListener:")print(...) end, -- 时间监听
    _fightClient = nil, -- 战斗客户端
    _state = FIGHT_STATE_NONE, -- 战斗状态
    _isPaused = false, -- 是否暂停
    _roles = {}, -- 角色列表
    _roleUpdateArray = {}, -- 角色刷新队列
    _localRoles = {}, -- 本机角色
    
    _isSleepFrame = false, -- 是否是静止帧
    
    _roleActiveTable = {}, -- 角色主动表
    
    _needBackupList = {"_roles", "_isSleepFrame", "_currFrame", "_currFrameIsValid"}, -- 需要备份的属性列表
    _backups = {}, -- 备份
    
    _controlCommandArray = {}, -- 控制命令数组
    
    _isOffline = true -- 离线
}

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 获得随机的角色数据
local function getRandomRoleData(name, id)
    assert(type(name) == "string")
    id = Helper:getDef(id, User:getUserId())
    qi = math.random(2000, 8000)
    neili = math.random(500, 1000)
    local roleData =
        {
            id = "npc_" .. id .. tostring(math.random(1, 1000)) .. tostring(math.floor(os.time())),
            name = name,
            atk = math.random(200, 500),
            qi = qi,
            qiMax = qi,
            neili = neili,
            neiliMax = neili
        }
    return roleData
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 创建测试战斗
function Fight.createTestFight(leftRoleCount, rightRoleCount)
    local fight = Fight:create()
    if leftRoleCount == nil and rightRoleCount == nil then
        -- 准备自己的角色
        local roleData1 = getRandomRoleData("一号")
        roleData1.teamId = 1
        local roleData2 = getRandomRoleData("二号")
        roleData2.teamId = 2
        
        -- 加入角色
        fight:addRole(roleData1.id, roleData1)
        fight:addRole(roleData2.id, roleData2)
        
        -- 得到角色
        local role1 = fight:getRole(roleData1.id)
        local role2 = fight:getRole(roleData2.id)
        
        -- 设置为本机角色
        fight:addLocalRole(role1)
        
        -- 设置角色1为玩家
        fight:setPlayer(role1)
        
        -- 创建并且设置被动招式
        role1:setAutoZhaos(role2:getId(), role1:createAutoZhaos(role2))
        role2:setAutoZhaos(role1:getId(), role2:createAutoZhaos(role1))
        
        role1:setTargetId(role2:getId())
        role2:setTargetId(role1:getId())
        
        -- 发送主动招式, 选择对手
        fight:selectTarget(role1:getId(), role2:getId())
        fight:selectTarget(role2:getId(), role1:getId())
        
        -- 备份
        fight:backup()
    else
        leftRoleCount = Helper:getRange(Helper:getDef(leftRoleCount, 1), 1, 5)
        rightRoleCount = Helper:getRange(Helper:getDef(rightRoleCount, 1), 1, 5)
        
        -- 添加左边人物
        for i = 1, leftRoleCount do
            local roleData = getRandomRoleData("leftRole" .. i)
            roleData.fightId = "left" .. i
            roleData.teamId = 1
            fight:addRole(roleData.id, roleData)
            local role = fight:getRole(roleData.id)
            role:setFightId(roleData.fightId)
        end
        
        -- 添加右边人物
        for i = 1, rightRoleCount do
            local roleData = getRandomRoleData("rightRole" .. i)
            roleData.fightId = "right" .. i
            roleData.teamId = 2
            fight:addRole(roleData.id, roleData)
            local role = fight:getRole(roleData.id)
            role:setFightId(roleData.fightId)
        end
        
        local team1Roles = fight:getTeamRoles(1)
        local team2Roles = fight:getTeamRoles(2)
        
        -- 为每个角色生成招式列表
        for team1RoleId, team1Role in pairs(team1Roles) do
            -- 对每一个敌人生成被动招式列表
            for team2RoleId, team2Role in pairs(team2Roles) do
                team1Role:setAutoZhaos(team2Role:getId(), team1Role:createAutoZhaos(team2Role))
            end
            
            -- 随机选择一个敌人
            team1Role:setTargetId(fight:getTeamRandomRole(2):getId())
        end
        for team2RoleId, team2Role in pairs(team2Roles) do
            for team1RoleId, team1Role in pairs(team1Roles) do
                team2Role:setAutoZhaos(team1Role:getId(), team2Role:createAutoZhaos(team1Role))
            end
            
            -- 随机选择一个敌人
            team2Role:setTargetId(fight:getTeamRandomRole(1):getId())
        end
    end
    return fight
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 创建测试战斗
function Fight.createNetTestFight(accountName)
    local fight = nil
    if accountName == "123123" then
        fight = Fight:create()
        
        -- 准备自己的角色
        local roleData = getRandomRoleData("一号", accountName)
        roleData.teamId = 1
        
        -- 加入角色
        fight:addRole(roleData.id, roleData)
        local role = fight:getRole(roleData.id)
        -- 设置为本机角色
        fight:addLocalRole(role:getId(), role)
        -- 设置角色为玩家
        fight:setPlayer(role)
        fight._isOffline = false
    elseif accountName == "321321" then
        fight = Fight:create()
        
        -- 准备自己的角色
        local roleData = getRandomRoleData("二号", accountName)
        roleData.teamId = 2
        
        -- 加入角色
        fight:addRole(roleData.id, roleData)
        local role = fight:getRole(roleData.id)
        -- 设置为本机角色
        fight:addLocalRole(role:getId(), role)
        -- 设置角色为玩家
        fight:setPlayer(role)
        fight._isOffline = false
    else
        error("帐号名出错")
    end
    return fight
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 测试
function Fight.test()
    if true then
        local FightLayer = require("app.views.layer.FightLayer.FightLayer")
        FightLayer.test()
        return
    end
    
    local fight = Fight:create()
    
    -- 准备自己的角色
    local roleData1 = getRandomRoleData("一号")
    roleData1.teamId = 1
    local roleData2 = getRandomRoleData("二号")
    roleData2.teamId = 2
    
    -- 加入角色
    fight:addRole(roleData1.id, roleData1)
    fight:addRole(roleData2.id, roleData2)
    
    -- 得到角色
    local role1 = fight:getRole(roleData1.id)
    local role2 = fight:getRole(roleData2.id)
    
    -- 创建并且设置被动招式
    role1:setAutoZhaos(role2:getId(), role1:createAutoZhaos(role2))
    role2:setAutoZhaos(role1:getId(), role2:createAutoZhaos(role1))
    
    -- 发送主动招式, 选择对手
    fight:selectTarget(role1:getId(), role2:getId())
    fight:selectTarget(role2:getId(), role1:getId())
    
    -- 备份
    fight:backup()
    -- fight:updateFrame()
    --
    -- fight:backup()
    -- fight:updateFrame()
    --
    -- fight:backup()
    -- fight:updateFrame()
    -- io.writefile(device.writablePath.."fight" , luaTableEncode(fight), "w")
    --  logt("fight", fight)
    --  logt("role1", role1)
    -- 更新游戏帧
    for i = 1, 100 do
        fight:updateFrame()
    end
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/07/27 14:43:22
-- @desc 设置随机种子
function Fight:setRandomSeed(t)
    self._randomSeed = t
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/07/27 14:44:56
-- @desc 获取随机种子
function Fight:getRandomSeed()
    return Helper:getDef(self._randomSeed, 0)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/04/25 02:53:31
-- @desc 随机方法
function Fight:random(f, t)
    local range = math.floor(t - f) + 1

    return f + math.floor(self._currFrame + self:getRandomSeed()) % range
end

-- @desc 随机方法，会重新设置随机种子，用于同一帧随机多次
function Fight:randomAndSetSeed(f, t)
    --重新设置随机种子
    self:setRandomSeed(self:getRandomSeed() + self._currFrame)

    local randomNum = self:random(f, t)

    return randomNum
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 创建一个本地对战Fight
function Fight:createLocalFight(team1RoleDatas, team2RoleDatas)
    collectgarbage("collect")
    
    -- logt("team1RoleDatas", team1RoleDatas)
    -- logt("team2RoleDatas", team2RoleDatas)
    local fight = Fight:create()
    fight:setRandomSeed(math.random(100)) -- add by XiaoZhiWei 2017/07/27 14:48:20 设置一个随机种子
    leftRoleCount = Helper:getRange(Helper:getDef(#team1RoleDatas, 1), 1, 5)
    rightRoleCount = Helper:getRange(Helper:getDef(#team2RoleDatas, 1), 1, 5)
    -- print("leftRoleCount", leftRoleCount)
    -- print("rightRoleCount", rightRoleCount)
    -- 添加左边人物
    for i = 1, leftRoleCount do
        local roleData = team1RoleDatas[i]
        
        roleData.id = "npc_" .. Helper:getDef(id, User:getUserId()) .. tostring(math.random(1, 1000)) .. tostring(math.floor(os.time()))
        roleData.fightId = "left" .. i
        roleData.teamId = 1
        roleData.inTeamId = i -- 在队伍中的编号
        fight:addRole(roleData.id, roleData)
        local role = fight:getRole(roleData.id)
        role:setFightId(roleData.fightId)
        
        -- 设置任务初始体力值, 并且需要等待体力回复 add by TangJian 2016/11/16 16:15:12
        role:setAttr("tili", INITIAL_TILI)
        role:setWaitingTili(true)
    end
    
    -- 添加右边人物
    for i = 1, rightRoleCount do
        local roleData = team2RoleDatas[i]
        
        roleData.id = "npc_" .. Helper:getDef(id, User:getUserId()) .. tostring(math.random(1, 1000)) .. tostring(math.floor(os.time()))
        roleData.fightId = "right" .. i
        roleData.teamId = 2
        roleData.inTeamId = i -- 在队伍中的编号
        fight:addRole(roleData.id, roleData)
        local role = fight:getRole(roleData.id)
        role:setFightId(roleData.fightId)
        
        -- 设置任务初始体力值, 并且需要等待体力回复 add by TangJian 2016/11/16 16:15:12
        role:setAttr("tili", INITIAL_TILI)
        role:setWaitingTili(true)
    end
    
    local team1Roles = fight:getTeamRoles(1)
    local team2Roles = fight:getTeamRoles(2)
    
    -- print("队伍1人数 = " .. tostring(team1Roles))
    -- print("队伍2人数 = " .. tostring(team2Roles))
    -- 为每个角色生成招式列表
    for team1RoleId, team1Role in pairs(team1Roles) do
        -- 对每一个敌人生成被动招式列表
        for team2RoleId, team2Role in pairs(team2Roles) do
            team1Role:setAutoZhaos(team2Role:getId(), team1Role:createAutoZhaos(team2Role, 50))
        end
        
        -- 随机选择一个敌人
        team1Role:setTargetId(fight:getTeamRandomRole(2):getId())
    end
    
    for team2RoleId, team2Role in pairs(team2Roles) do
        for team1RoleId, team1Role in pairs(team1Roles) do
            team2Role:setAutoZhaos(team1Role:getId(), team2Role:createAutoZhaos(team1Role, 50))
        end
        
        -- 随机选择一个敌人
        team2Role:setTargetId(fight:getTeamRandomRole(1):getId())
    end
    return fight
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 创建
function Fight:create()
    local p = clone(Fight)
    p:init()-- 初始化
    return p
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 初始化
function Fight:init()
    self._eventListenerFM = FunctionManager:create()-- 时间监听方法
    self._preUpdateFM = FunctionManager:create()-- 更新前方法
    
    self.__sleepFrameFM = FunctionManager:create()-- 静止帧方法

    self._state = FIGHT_STATE_NONE -- 战斗状态
    self._isPaused = false -- 是否暂停
    
    self._currFrame = 0 -- 当前帧
    
    self._roles = {}-- 角色列表

    self.__aiFrameIndex = 0
    -- self._autoZhaos = {} -- 被动招式列表
    -- self._activeZhaos = {} -- 主动招式列表
    -- 初始化战斗客户端
    self:initFightClient()
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 初始化战斗客户端
function Fight:initFightClient()
    self._fightClient = FightClient:create()-- 战斗客户端
    self._fightClient:setEventCallback(function(eventName, ...)
            -- PopText(eventName)
            -- logt("Fight EventCallback", "eventName = "..eventName)
            switch(eventName,
                {
                    ["创建房间成功"] = function()
                        self:uploadLocalRoles()
                    end,
                    ["加入房间成功"] = function()
                        self:uploadLocalRoles()
                        self:getRoomInfo()
                    end,
                    ["上传角色数据成功"] = function()
                        self:ready()-- 准备
                    end,
                    ["收到角色数据"] = function(...)
                        local roles = ...
                        logt("收到角色数据", roles)
                        for roleId, roleData in pairs(roles) do
                            self:setRole(roleId, roleData)
                        end
                    end,
                    ["获得房间数据成功"] = function(...)
                        logt("获得房间数据成功")
                    end,
                    ["准备完成"] = function()
                    
                    end,
                    ["全都准备好了"] = function()
                    
                    end,
                    ["战斗开始"] = function()
                        self:prepareLocalAuto()-- 准备被动数据
                        self:uploadAutoZhaos()-- 上传被动招式
                    end,
                    ["收到被动招式"] = function(...)
                        local autoZhaos = ...
                        for roleId, autoTable in pairs(autoZhaos) do
                            local role = self:getRole(roleId)
                            role:setAutoTable(autoTable)
                        end
                        -- 备份一下游戏
                        self:backup()
                        
                        -- 收到被动招式就可以开始战斗了.
                        self:callEventListener("startFight")
                        self:refreshUI()
                    end,
                    ["收到主动招式"] = function(...)
                        local frame, roleId, activeZhaoId = ...
                        self:addActiveZhao(roleId, frame, activeZhaoId)
                    end
                }, ...)
            self._eventListenerFM:callFunctions()
    end)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/02 17:43:02
-- @desc 流程控制方法
-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/07 16:10:03
-- @desc 暂停
function Fight:pause()
    self._isPaused = true
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/07 16:10:26
-- @desc 恢复战斗
function Fight:resume()
    self._isPaused = false
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/07 16:10:57
-- @desc 是否暂停判断
function Fight:isPaused()
    return self._isPaused
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/02 17:43:22
-- @desc 开始战斗
function Fight:start( flag)
    self._state = FIGHT_STATE_RUNNING
    self:callEventListener("start")

    --论剑中激活flag，不让战斗进行经脉初始化
    if  flag then
        self._fightRoleJingMai = nil
        return
    end
    -- 触发角色开始战斗事 add by TangJian 2017/05/04 22:15:29
    for k, v in pairs(self._roles) do
        v:onStartFight()
        v:updateFightRoleBuff()

        --@desc 打印人物战斗数据详情
        v:printFightRoleInfo()
    end
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 设置事件监听
function Fight:setEventListener(eventListener)
    self._eventListener = Helper:getDef(eventListener, EMPTY_FUNC)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 触发事件监听
function Fight:callEventListener(...)
    -- self._eventListener(...)
    local arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10 = ...
    self._eventListenerFM:addFunction(
        function()
            self._eventListener(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10)
            return true
        end)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/01/16 16:21:29
-- @desc 添加控制命令
function Fight:addControlCommand(commandName, ...)
    -- print("addControlCommand", commandName, ...)
    table.insert(self._controlCommandArray,
        {
            name = commandName,
            params = {...}
        })
-- self[commandName](self, ...)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/01/16 16:22:55
-- @desc 执行所有控制命令
function Fight:executeAllControlCommand()
    for i, command in ipairs(self._controlCommandArray) do
        self[command.name](self, unpack(command.params))
    end
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/01/16 16:26:35
-- @desc 移除所有控制命令
function Fight:removeAllControlCommand()
    self._controlCommandArray = {}
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/01/16 16:27:25
-- @desc 执行并且移除所有控制命令
function Fight:executeAndRemoveAllControlCommand()
    self:executeAllControlCommand()
    self:removeAllControlCommand()
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/01 10:42:18
-- @desc 获得状态
function Fight:getState()
    return self._state
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/01 10:29:58
-- @desc 自带创建角色方法
function Fight:createRole()
    local role = FightRole:create()
    role:setEventListener(
        function(roleId, eventName, ...)
            self:callEventListener("roleEvent", roleId, eventName, ...)
        end)
    return role
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 添加角色
function Fight:addRole(id, roleData)
    local fightRole = self:createRole()
    fightRole:setData(roleData)
    self._roles[id] = fightRole
    
    
    fightRole._fight = self

-- logt("当前角色列表", "当前角色数目为 ", self:getRoleCount(), "\n", self._roles)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 得到角色
function Fight:getRole(id)
    -- log("id = ", id)
    local role = self._roles[id]
    if role == nil then
        if PRINT_MODE == 1 then
            log("没有找到角色 ", id)
        end
    end
    return role
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 设置角色
function Fight:setRole(id, roleData)
    if self._roles[id] == nil then
        self._roles[id] = self:createRole()
    end
    local fightRole = self._roles[id]
    fightRole:setData(roleData)
    
    assert(type(fightRole) == "table")
    assert(type(roleData) == "table")
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/23 20:53:08
-- @desc 得到角色map
function Fight:getRoles()
    return self._roles
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/09 18:30:48
-- @desc 得到角色数目
function Fight:getRoleCount()
    local count = 0
    for k, role in pairs(self._roles) do
        count = count + 1
    end
    return count
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/10 10:35:07
-- @desc 获得队伍角色数目
function Fight:getTeamRoleCount(teamId)
    local count = 0
    for k, role in pairs(self._roles) do
        if role:getTeamId() == teamId then
            count = count + 1
        end
    end
    return count
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 得到所有角色的列表
function Fight:getRoleIdArray()
    local roleIdArray = {}
    for roleId, v in pairs(self._roles) do
        table.insert(roleIdArray, roleId)
    end
    return roleIdArray
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 角色刷新队列
function Fight:getRandomRoleUpdateArray()
    local randomRoleIdArray = getRandomArray(self:getRoleIdArray())
    return randomRoleIdArray
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 刷新角色
function Fight:updateRole(id, roleData)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 通过队伍id和角色在队伍中的id来得到角色
function Fight:getRoleByTeamIdAndInTeamId(roleTeamId, roleInTeamId)
    for roleId, role in pairs(self._roles) do
        if roleTeamId == role:getTeamId() and roleInTeamId == role:getInTeamId() then
            return role
        end
    end
    return nil
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 添加为本机角色
function Fight:addLocalRole(id, role)
    self._localRoles[id] = true
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 得到本地角色列表
function Fight:getLocalRoles()
    local localRoles = {}
    for roleId, v in pairs(self._localRoles) do
        localRoles[roleId] = self:getRole(roleId)
    end
    return localRoles
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 获得当前角色数据
function Fight:getRoleCount()
    local count = 0
    for k, v in pairs(self._roles) do
        count = count + 1
    end
    return count
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 设置玩家
function Fight:setPlayer(role)
    if self._player then
        self._player:setIsPlayer(false)
    end
    self._player = role
    role:setIsPlayer(true)
    
    -- PopText("设置玩家为: " .. role:getName())

    -- 设置玩家后调用事件方法
    self:callEventListener("setPlayer", self._player)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 获得玩家
function Fight:getPlayer()
    return self._player
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 得到敌方队伍id
function Fight:getEnemyTeamId(teamId)
    if teamId == 1 then
        return 2
    elseif teamId == 2 then
        return 1
    end
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 得到指定队伍所有角色
function Fight:getTeamRoles(teamId)
    local roles = {}
    for roleId, role in pairs(self._roles) do
        if teamId == role:getTeamId() then
            roles[roleId] = role
        end
    end
    return roles
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 得到队伍中活着的角色
function Fight:getTeamAliveRoles(teamId)
    local roles = {}
    for roleId, role in pairs(self._roles) do
        if teamId == role:getTeamId() and role:isAlive() then
            roles[roleId] = role
        end
    end
    return roles
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 得到指定队伍所有角色数组
function Fight:getTeamRoleArray(teamId)
    local roleArray = {}
    for roleId, role in pairs(self._roles) do
        if teamId == role:getTeamId() then
            table.insert(roleArray, role)
        end
    end
    return roleArray
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 得到队伍中随机的一个角色
function Fight:getTeamRandomRole(teamId)
    local roleArray = self:getTeamRoleArray(teamId)
    local ret = nil
    if #roleArray > 0 then
        ret = roleArray[math.random(1, #roleArray)]
    end

    if ret == nil then
        -- if type(roleArray) == "table" then
        --     error("roleArray = ", #roleArray)
        --     for i=1, #roleArray do
        --         print("roleArray[i]", roleArray[i])
        --     end
        -- else
        --     error("roleArray = nil")
        -- end

        -- for k,v in pairs(self._roles) do
        --     print(k,v)
        -- end


        -- Helper:print_lua_table(self._roles)
    end

    return ret
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 生成被动招式
function Fight:prepareLocalAuto()
    local localRoles = self:getLocalRoles()
    -- logt("localRoles = ", localRoles)
    for roleId, role in pairs(localRoles) do
        -- 得到敌方所有角色
        local enemys = self:getTeamRoles(self:getEnemyTeamId(role:getTeamId()))
        -- logt("enemys", enemys)
        for enemyId, enemy in pairs(enemys) do
            local autoZhaos = role:createAutoZhaos(enemy, 1)
            role:setAutoZhaos(enemy:getId(), autoZhaos)
        end
    end
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 创建房间
function Fight:createRoom(roomName)
    self._fightClient:createRoom(roomName)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 进入房间
function Fight:enterRoom(roomId)
    self._fightClient:enterRoom(roomId)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 上传角色数据
function Fight:uploadRoles(roles)
    self._fightClient:uploadRoles(roles)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 获得房间信息
function Fight:getRoomInfo()
    self._fightClient:getRoomInfo()
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 上传本地角色数据
function Fight:uploadLocalRoles()
    local roleDatas = {}
    for k, v in pairs(self:getLocalRoles()) do
        roleDatas[k] = v:getData()
    end
    self._fightClient:uploadRoles(roleDatas)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 上传被动招式
function Fight:uploadAutoZhaos()
    local autos = {}
    local localRoles = self:getLocalRoles()
    for roleId, role in pairs(localRoles) do
        local autoTable = role:getAutoTable()
        autos[roleId] = autoTable
    end
    -- logt("autos = ", autos)
    self._fightClient:sendAutoData(autos)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 准备
function Fight:ready()
    self._state = FIGHT_STATE_READY
    self:callEventListener("ready")
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 生成角色被动招式列表
function Fight:createRoleAutoZhaos(roleId, targetId)
    local role = self._roles[roleId]
    local target = self._roles[targetId]
    assert(isTable(role))
    assert(isTable(target))
    return role:createAutoZhaos(target, 1)
end

-- 角色主动招式 --------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 释放主动技能
function Fight:useActiveZhao(roleId, activeZhaoId)
    local role = self:getRole(roleId)
    local activeZhao =
        {
            rid = roleId, -- 角色id
            f = self._currFrame + 1, -- 帧
            zid = activeZhaoId -- 主动招式id
        }
    
    if self._isOffline then
        self:addActiveZhao(roleId, self._currFrame + 1, activeZhaoId)
    -- role:addActiveZhao(activeZhao)
    else
        self._fightClient:sendActiveData(self._currFrame, activeZhao)
    end
end


function Fight:checkRoleCanReadyActiveZhao(role, activeZhaoId)
    --遗忘状态下不可以使用主动技能
    if role:isForget() then
        return false, ""
    end

	if not role:isPartForgetCanUseActiveZhao(activeZhaoId) then
		return false, ""
	end

    -- 晕迷：无法行动，不能攻击，不能使用主动技能，不会闪避和格挡；
    -- 致残：无法行动，不能攻击，只能使用释放类主动技能，不会闪避，但会格挡；
    -- 定身：无法行动，不能攻击，只能使用释放类主动技能，不会闪避和格挡；
    -- 迷惑：无法行动，不能攻击，不能使用主动技能，但会闪避和格挡。
    if role:isSleep() or role:isBlind() then
        return false, "此技能暂时无法使用"
    end
    
    if role:isFrozen() or role:isParalyzed() then
        local activeZhao = Skill:getActiveZhao(activeZhaoId)
        if activeZhao:getType() ~= "释放" then
            return false, "此技能暂时无法使用"
        end
    end

    -- 被禁锢不能释放任何主动技能
    if role:isimprison() then
        return false, "禁锢中，无法使用主动技能！"
    end

    if role:isAttackLimit() then
        local activeZhao = Skill:getActiveZhao(activeZhaoId)
        if activeZhao:getType() ~= "释放" then
            return false, "此技能暂时无法使用"
        end
    end
    

    return true
end
-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/03/01 17:47:03
-- @desc 准备主动招式
function Fight:readyActiveZhao(roleId, activeZhaoId)
    local role = self:getRole(roleId)

    local isTrue, msg = self:checkRoleCanReadyActiveZhao(role, activeZhaoId)
    if isTrue == false then
        PopText(msg)
        return
    end
    -- -- 被缴械(打掉武器)不能释放武器主动技能
    -- if role:isDisarm()  then
    --     local skillId = Skill:getSkillIdByZhaoId(activeZhaoId)
    --     if DEBUG_MODE == 1 then
    --         print("招式所归属的类型:"..skillId.methods)
    --     end
    --     if skillId.methods  == SKILL_METHOD_TYPE_DAO 
    --     or skillId.methods  == SKILL_METHOD_TYPE_JIAN 
    --     or skillId.methods  == SKILL_METHOD_TYPE_GUN 
    --     or skillId.methods  == SKILL_METHOD_TYPE_ANQI then
    --         return
    --     end
    
    -- end

    --走穴十四经，得到效果无法使用主动技能
    if User:getRole():getBuffAttr("xingzhenZhanDou") == 1 then
        PopText("受行针走穴影响，你暂时无法自由运转内力。")
        return
    end

    local canUse, notice = role:activeZhaoIsCoolDown(activeZhaoId)
    if canUse then
        canUse, notice = role:canUseActiveZhao(activeZhaoId)
        -- 判断当前能否释放招式
        if canUse then
            local frame = self._currFrame + 1
            
            self._preUpdateFM:addFunction(function()
                if PRINT_MODE == 1 then
                    logt("Fight:addActiveZhao(roleId, frame, activeZhaoId)", "roleId = ", roleId, ", frame = ", frame, ", activeZhaoId = ", activeZhaoId)
                end
                
                -- 如果当前大于收到帧, 则需要回溯
                if self._currFrame > frame then
                    self:restore(frame)-- 回溯
                end
                
                local role = self:getRole(roleId)
                local isTrue = self:checkRoleCanReadyActiveZhao(role, activeZhaoId)
                if isTrue == false then
                    return true
                end

                if role:getReadyActiveZhaoId() == nil then
                    role:setReadyActiveZhaoId(activeZhaoId)
                    
                    -- 添加主动招式
                    local activeZhaos = self:getRoleActiveZhaos(roleId)
                    table.insert(activeZhaos, {rid = roleId, f = frame, zid = activeZhaoId})
                    
                    -- 通知显示
                    self:callEventListener("readyActiveZhao", roleId, activeZhaoId)
                end
                return true
            end)
        end
    end
    return canUse, notice
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 添加主动招式
function Fight:addActiveZhao(roleId, frame, activeZhaoId)
    self._preUpdateFM:addFunction(function()
        if PRINT_MODE == 1 then
            logt("Fight:addActiveZhao(roleId, frame, activeZhaoId)", "roleId = ", roleId, ", frame = ", frame, ", activeZhaoId = ", activeZhaoId)
        end
        
        -- 如果当前大于收到帧, 则需要回溯
        if self._currFrame > frame then
            self:restore(frame)-- 回溯
        end
        
        local role = self:getRole(roleId)
        if role:getReadyActiveZhaoId() == nil then
            role:setReadyActiveZhaoId(activeZhaoId)
            
            -- 添加主动招式
            local activeZhaos = self:getRoleActiveZhaos(roleId)
            table.insert(activeZhaos, {rid = roleId, f = frame, zid = activeZhaoId})
            
            -- 通知显示
            self:callEventListener("readyActiveZhao", roleId, activeZhaoId)
        end
        return true
    end)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 得到主动招式
function Fight:getRoleActiveZhaos(roleId)
    if self._roleActiveTable[roleId] == nil then
        self._roleActiveTable[roleId] = {}
    end
    return self._roleActiveTable[roleId]
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 得到角色主动招式
function Fight:getRoleActiveZhao(roleId, activeZhaoIndex)
    local activeZhaos = self:getRoleActiveZhaos(roleId)
    return activeZhaos[activeZhaoIndex]
end
-----------------------------------------------------------------------------------------------------------
--@desc: 删除主动招式
--@author:LvBin
--@time:2026-04-21 17:50:02
--@roleId:
--@activeZhaoId: 
function Fight:deleteRoleActiveZhao(roleId, activeZhaoId)
    local activeZhaos = self:getRoleActiveZhaos(roleId)
    if not MapIsEmpty(activeZhaos) then
		for i,v in ipairs(activeZhaos) do
			if v.zid == activeZhaoId then
				table.remove(activeZhaos,i)
				break
			end
		end
	end
end
-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 判断能否释放主动技能
function Fight:roleCanPlayActiveZhao(roleId, activeZhaoIndex, frameIndex)
    local activeZhao = self:getRoleActiveZhao(roleId, activeZhaoIndex)
    if activeZhao and frameIndex >= activeZhao.f then
        return true
    else
        return false
    end
end

--清空战斗角色主动招式
function Fight:clearRoleActiveZhao(role)
    local activeZhaos = self:getRoleActiveZhaos(role:getId())
    activeZhaos = {}

    --需要在静止帧清空，进入攻击帧后，不能清空
    if self._isSleepFrame == false then
        role:setCurrActiveZhao(nil)
    end
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 选择对手
function Fight:selectTarget(roleId, targetId)
    local role = self._roles[roleId]
    local target = self._roles[targetId]
    local activeZhao =
        {
            id = "selectTarget",
            f = self._currFrame,
            rid = roleId,
            tid = targetId
        }
    role:addActiveZhao(activeZhao)
    return activeZhao
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 判断角色能否执行主动技能
function Fight:canRolePlayActiveZhao(role, frameIndex)
    return self:getActiveZhao(frameIndex)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 播放主动技能
function Fight:playRoleActiveZhao(role, target, frameIndex)
    if PRINT_MODE == 1 then
        logt("播放主动技能!!!!!!!!!!!!!!!!!!!!")
    end

    local activeZhao = role:getCurrActiveZhao()

    if role:getReadyActiveZhaoId() then
        local isTrue = self:checkRoleCanReadyActiveZhao(role, activeZhao.id)
        if isTrue == false then
            role:setReadyActiveZhaoId(nil)
            self:clearRoleActiveZhao(role)

            self:callEventListener("unReadyActiveZhao", role:getTeamId(), role:getInTeamId())
            return
        end
    end
    
    
    if activeZhao.id == "selectTarget" then
        if PRINT_MODE == 1 then
            print("先择目标")
        end
        
        -- 设置角色目标
        role:setTargetId(activeZhao.tid)
        
        -- 选择目标执行完毕
        role._currActiveIndex = role._currActiveIndex + 1
    else
        -- local target = self:getRole(role:getTargetId())
        if target then
            switch("normal",
                {
                    normal = function()-- 六脉神剑
                        -- print("六脉神剑 self._currActiveState = ", role._currActiveState
                        -- , ", role._currActiveFrame = ", role._currActiveFrame
                        -- , ", role._currActiveIndex = ", role._currActiveIndex)
                        switch(role._currActiveState,
                            {
                                [1] = function()
                                    if self._isSleepFrame == false then
                                        LogSystem:log("旧版战斗：主动技能","攻击者 = ", role:getName()," |受击者 = ", target:getName()," |主动招式ID = ", activeZhao:getId()," |平均气血伤害avgqiatk = ",role:getRole():getAvgQiAtk(target:getRole()))

                                        local activeZhaoState = role:getActiveZhaoState(activeZhao:getId())
                                        

                                        -- 主动技能使用次数++ add by TangJian 2017/03/01 10:57:52
                                        role:addActiveZhaoUseTimes(activeZhao:getId())

                                        role:setReadyActiveZhaoId(nil)
                                        
                                        -- 判断能否释放该主动技能
                                        if activeZhaoState:getCDLeft() > 0 then
                                            role:setCurrActiveZhao(nil)
                                            role._currActiveIndex = role._currActiveIndex + 1
                                            
                                            PopText(activeZhaoState:getName() .. " 正在冷却")
                                            return
                                        
                                        -- 判断是否需要内力 add by TangJian 2017/03/22 16:32:31
                                        elseif role:isNeedNeili() == false then
    
                                            self:callEventListener("useActiveZhao", role:getId(), target:getId(), activeZhao:getId())
                                            -- 设置cd
                                            activeZhaoState:setCDLeft(activeZhaoState:getCD())
                                            if NPC_AI then
                                                if role._role.teamId == 2 then
                                                    local ruleId = role._npcActiveZhaoRules[activeZhaoState:getId()]
                                                    ActiveZhaoRules:setRuleCd(activeZhaoState:getId().."_"..ruleId)
                                                end
                                            end
                                        else

                                            --[[
                                                原消耗公式 ： neilicost * role:getAttr("neiliConsumeFactor")

                                                变更： ((neilicost + neilicostbuff(默认为0)) * neilicostpercent(默认为1)) * role:getAttr("neiliConsumeFactor")
                                            ]]
                                            local neiliCost = activeZhaoState:getFinalCost()

                                            local neiliConsumeFactor = Helper:getDef(role:getAttr("neiliConsumeFactor"), 1)

                                            local finalCost = math.max((neiliCost + role:getRole():getFinalAttr("activeNeiliCost") * role:getRole():getFinalAttr("activeNeiliCostPercent")) * neiliConsumeFactor, 0)

                                            local failUseRate = role:getRole():getFinalAttr("drActiveZhaoUseFailRate")
                                            if failUseRate > 0 and math.random(1, 100) <= failUseRate then
                                                self:callEventListener("unReadyActiveZhao", role:getTeamId(), role:getInTeamId())
                                                PopText("你毫无战意，无力发动")
                                                role._currActiveIndex = role._currActiveIndex + 1
                                                role:setCurrActiveZhao(nil)
                                                role:addAttr("neili", -finalCost, 0)
                                                activeZhaoState:setCDLeft(activeZhaoState:getCD())
                                                if NPC_AI then
                                                    if role._role.teamId == 2 then
                                                        local ruleId = role._npcActiveZhaoRules[activeZhaoState:getId()]
                                                        ActiveZhaoRules:setRuleCd(activeZhaoState:getId().."_"..ruleId)
                                                    end
                                                end
                                                return
                                            end

                                                                                    -- 使用主动技能
                                            if finalCost ~= 0 and role:getAttr("neili") < finalCost then
                                                if PRINT_MODE == 1 then
                                                    print([[role:getAttr("neili") = ]], role:getAttr("neili"))
                                                    print([[activeZhaoState:getFinalCost() = ]], activeZhaoState:getFinalCost())
                                                    print([[activeZhao final Cost = ]], finalCost)
                                                end
                                                
                                                role:setCurrActiveZhao(nil)
                                                role._currActiveIndex = role._currActiveIndex + 1

                                                self:callEventListener("unReadyActiveZhao", role:getTeamId(), role:getInTeamId())

                                                PopText("内力不够, 无法使用主动招式: " .. activeZhaoState:getName())
                                                return
                                            else
                                                self:callEventListener("useActiveZhao", role:getId(), target:getId(), activeZhao:getId())
                                                role:addAttr("neili", -finalCost, 0)
                                                print("消耗内力".. finalCost)
                                                -- 设置cd
                                                activeZhaoState:setCDLeft(activeZhaoState:getCD())
                                                if NPC_AI then
                                                    if role._role.teamId == 2 then
                                                        local ruleId = role._npcActiveZhaoRules[activeZhaoState:getId()]
                                                        ActiveZhaoRules:setRuleCd(activeZhaoState:getId().."_"..ruleId)
                                                    end
                                                end

                                                role:getRole():dispatchEvent("PlayActiveZhaoEvent", {role = role, target = target, activeZhao = activeZhao})
                                            -- PopText("内力充沛, 使出了主动招式 " .. activeZhao:getName())
                                            end
                                        end
                                        
                                        
                                        -- 招式帧加 1
                                        role._currActiveFrame = role._currActiveFrame + 1
                                        -- 判断前摇是否结束
                                        if role._currActiveFrame > 0 then
                                            -- 进入攻击帧
                                            self._isSleepFrame = true -- 设置为静止帧
                                            role._currActiveFrame = 1 -- 招式帧这只为1
                                            role._currActiveState = 2 -- 进入攻击帧
                                            
                                            if PRINT_MODE == 1 then
                                                print(role:getName(), "主动招式前摇结束")
                                            end
                                        else
                                            if PRINT_MODE == 1 then
                                                print(role:getName(), "主动招式前摇中")
                                            end
                                        end
                                    else
                                        if PRINT_MODE == 1 then
                                            print(role:getName(), "静止帧, 主动招式前摇中")
                                        end
                                    end
                                end,
                                [2] = function()
                                    -- 第一帧执行操作
                                    if role._currActiveFrame == 1 then
                                        if PRINT_MODE == 1 then
                                            log(role:getName() .. "使用了" .. activeZhao:getName())
                                        end
                                        -- PopText(role:getName() .. "使用了" .. activeZhao:getName())
                                        -- 主动技能
                                        self:roleActiveZhao(role, target, activeZhao, frameIndex)
                                        
                                        -- 附加动画隐藏 add by TangJian 2017/04/08 11:53:22
                                        self:callEventListener("setRoleAllAdditionalAnimEnabled", role, false)
                                    end
                                    
                                    role._currActiveFrame = role._currActiveFrame + 1
                                    
                                    -- 攻击完成
                                    if role._currActiveFrame > activeZhao:getDuration() then
                                        self._isSleepFrame = false -- 设置为静止帧
                                        role._currActiveFrame = 1 -- 招式帧这只为1
                                        role._currActiveState = 3 -- 进入后摇
                                        
                                        -- 附加动画显示 add by TangJian 2017/04/08 11:53:22
                                        self:callEventListener("setRoleAllAdditionalAnimEnabled", role, true)
                                    end

                                end,
                                [3] = function()
                                    if self._isSleepFrame == false then
                                        -- 招式帧加 1
                                        role._currActiveFrame = role._currActiveFrame + 1
                                        -- 判断前摇是否结束
                                        if role._currActiveFrame > 0 then
                                            -- 进入攻击帧
                                            self._isSleepFrame = false -- 设置为静止帧
                                            role._currActiveFrame = 1 -- 招式帧这只为1
                                            role._currActiveState = 1 -- 进入前摇
                                            
                                            role._currActiveIndex = role._currActiveIndex + 1 -- 帧数增加
                                            
                                            role:setCurrActiveZhao(nil)
                                            
                                            if PRINT_MODE == 1 then
                                                print(role:getName(), "主动招式后摇结束")
                                            end
                                        else
                                            if PRINT_MODE == 1 then
                                                print(role:getName(), "主动招式后摇中")
                                            end
                                        end
                                    else
                                        if PRINT_MODE == 1 then
                                            print(role:getName(), "静止帧, 主动招式后摇中")
                                        end
                                    end
                                end,
                            })
                    end,
                    default = function()
                        self._isSleepFrame = true -- 设置为静止帧
                        
                        PopText(role:getName() .. "使用了未实现主动招式")
                        
                        role._currActiveIndex = role._currActiveIndex + 1
                        self._isSleepFrame = false
                    end
                })
        end
    end
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 播放角色被动技能
function Fight:playRoleAutoZhao(role, target, frameIndex)

    if role.isInYiWu==true then 
        local isYiWu=self:yiwu(role)
        if isYiWu==true then 
            return
        end
    end
    if role.yiWuTime then 
        if role.yiWuTime<60  then
            self._isSleepFrame = true
            role.yiWuTime=role.yiWuTime+1
            return
        else
            role.yiWuTime=nil
            self._isSleepFrame = false
            return
        end
    end

    -- 无法进行被动攻击
    if role:isUnableAutoAttack() then
        return                        
    end
    
    local autoZhaos = role:getAutoZhaos(target:getId())
    
    --判断当前状态：类型包括：0 空闲帧，1 前摇帧，2 攻击帧，3 后摇帧，控制帧
    local currZhaoState = role._currZhaoState
    
    -- 空闲
    if currZhaoState == 0 then
        if PRINT_MODE == 1 then
            print([[role:getAttr("tili")]] .. role:getAttr("tili"))
        end
        
        -- 如果在等待体力回复, 而且 体力值已经满了, 则改为非等待状态
        if role:isWaitingTili() and role:getAttr("tili") >= role:getFinalAttr("tiliMax") then
            role:setWaitingTili(false)
            role._currAutoZhaoTimes = 0 -- 重置当前被动招式释放次数
        end
        
        -- 如果处在非等待状态, 则尝试消耗体力, 发动进攻 add by TangJian 2016/11/09 18:04:28
        if not role:isWaitingTili() then
            if autoZhaos[role._currZhaoIndex + 1] == nil then -- 如果没有下一招了, 自动生成下一招 add by TangJian 2016/11/18 20:50:54
                role:appendAutoZhaos(target:getId(), role:createAutoZhaos(target, 1))-- 生成下一招, 这个在联机版本需要修改 add by TangJian 2016/11/17 15:34:19
            end
            
            local nextZhao = autoZhaos[role._currZhaoIndex + 1]
            local attackSkill = Skill:getSkill(nextZhao.atkSkId)
            local attackZhao = attackSkill:getAttackZhaoById(nextZhao.atkZhaoId)
            local baseTiliConsume = role:getAutoZhaoTiliConsume(attackZhao)

            local tiliConsumeBuff = 0
            local tiliConsumeBuffScale = 1

            --@region 情绪系统带来的buff
            local isDrTiliConsume = false
            local drTiliConsumeRate = role:getRole():getFinalAttr("drTiliConsumeRate")
            if drTiliConsumeRate > 0 and drTiliConsumeRate >= math.random(1,100) then
                local addValue = role:getRole():getFinalAttr("drTiliConsumePercent")
                if addValue ~= 0 then
                    tiliConsumeBuffScale  = tiliConsumeBuffScale + addValue
                end
            end
            --@endregion

            local tiliConsume = (baseTiliConsume + tiliConsumeBuff) * tiliConsumeBuffScale

            if role:getAttr("tili") >= tiliConsume then -- role:getAttr("tili") >= 50 then

                --#TODO 2020-06-20 15:33:55 生成准备要攻击的对象信息并通知监听对象。
                local preAutoAtk = {
                    canAtk = true,
                    attacker = role,
                    target = target,
                    tiliConsume = tiliConsume,
                    fight = self
                }
                
                --@desc 因情绪带来的攻击失败
                local attackFailureRate = role:getRole():getFinalAttr("drEmgrAttackFailRate")
                local beAttackFailureRate = target:getRole():getFinalAttr("drEmgrTargetAttackFailRate")
                if attackFailureRate >= 1 and math.random(1,100) <= attackFailureRate then
                    preAutoAtk.canAtk = false
                    local str = role:getRole().emotionMgr:getAttackFailDesc()
                    self:callEventListener("popFightText",str, role:getAttr("name"), target:getAttr("name"))
                elseif beAttackFailureRate >= 1 and math.random(1,100) <= beAttackFailureRate then
                    preAutoAtk.canAtk = false
                    local str = role:getRole().emotionMgr:getTargetAttackFailDesc()
                    self:callEventListener("popFightText",str, role:getAttr("name"), target:getAttr("name"))
                end

                if preAutoAtk.canAtk == true then
                    -- self:playRoleEffect(role, frameIndex)
                    -- 进入前摇
                    role._currZhaoIndex = role._currZhaoIndex + 1
                    role._currZhaoFrame = 1
                    role._currZhaoState = 1 -- 进入前摇
                else
                    role:setWaitingTili(true)
                end

                if isDrTiliConsume then
                    local str = role:getRole().emotionMgr:getTiliConsumeDesc()
                    self:callEventListener("popFightText",str, role:getAttr("name"), target:getAttr("name"))
                end

                role:addAttr("tili", -preAutoAtk.tiliConsume)
            end
        end

        --空闲状态初始化化指类经脉相关的字段
        role.isZhuiJia = nil
        role._cType = nil
        role._ishuazhieffect = nil
        role.jingMaiZhaoIsCreate = false

    -- log("role._currZhaoIndex = ", role._currZhaoIndex, ", role._currZhaoFrame = ", role._currZhaoFrame, ", role._currZhaoState = ", role._currZhaoState)
    -- log("开始释放招式 zhao = ", nextZhao)
    end
    
    local zhao = inherit({}, autoZhaos[role._currZhaoIndex])

    --判断是否是特殊经脉效果追加的招式
    if role.isZhuiJia == true and role.jingMaiZhaoIsCreate == false then
        zhao = inherit({}, role:createJingMaiEffectAutoZhao(target, math.random( 1,100), math.random( 1,100), role._cType))
        role.jingMaiZhaoIsCreate = true
    end

    -- logt("zhao", zhao)
    switch(currZhaoState,
        {
            [0] = function() end, -- 空闲帧
            [1] = function()-- 前摇
                if self._isSleepFrame == false and role:isActived() then
                    -- 被定身不能动 add by TangJian 2017/03/22 16:44:35
                    if role:isImmobilized() then
                        return
                    end
                    
                    -- 招式帧加1
                    role._currZhaoFrame = role._currZhaoFrame + 1
                    -- 判断前摇是否结束
                    if role._currZhaoFrame > zhao.befFrame then
                        -- 进入攻击帧
                        self._isSleepFrame = true -- 设置为静止帧
                        role._currZhaoFrame = 1 -- 招式帧这只为1
                        role._currZhaoState = 2 -- 进入攻击帧
                        
                        if PRINT_MODE == 1 then
                            print(role:getName(), "前摇结束")
                        end
                    else
                        if PRINT_MODE == 1 then
                            print(role:getName(), "前摇中")
                        end
                    end
                else
                    if PRINT_MODE == 1 then
                        print(role:getName(), "静止帧, 前摇中")
                    end
                end
            end,
            [2] = function()-- 攻击
                -- 第一帧执行操作
                if role._currZhaoFrame == 1 then
                    role._currAutoZhaoTimes = role._currAutoZhaoTimes + 1 -- 攻击前增加攻击次数
                    
                    -- 尝试是否有体力执行下一招
                    do
                        if autoZhaos[role._currZhaoIndex + 1] == nil then -- 如果没有下一招了, 自动生成下一招 add by TangJian 2016/11/18 20:50:54
                            role:appendAutoZhaos(target:getId(), role:createAutoZhaos(target, 1))-- 生成下一招, 这个在联机版本需要修改 add by TangJian 2016/11/17 15:34:19
                        end
                        
                        if PRINT_MODE == 1 then
                            print("#autoZhaos = ", #autoZhaos)
                        end
                        if PRINT_MODE == 1 then
                            print("role._currZhaoIndex = ", role._currZhaoIndex)
                        end
                        
                        local nextZhao = autoZhaos[role._currZhaoIndex + 1]
                        
                        local attackSkill = Skill:getSkill(nextZhao.atkSkId)
                        local attackZhao = attackSkill:getAttackZhaoById(nextZhao.atkZhaoId)
                        local tiliConsume = role:getAutoZhaoTiliConsume(attackZhao) 
                        if role:getAttr("tili") >= tiliConsume then -- 攻击前判断体力是否足够
                            else
                            -- 体力不够, 进入等待体力恢复状态 add by TangJian 2016/11/09 18:01:57
                            role:setWaitingTili(true)
                            zhao.isWaitingTili = true

                            if IS_OPEN_HUAZHIWEIJIAN and role:getAttackMethod() == SKILL_METHOD_TYPE_QUANJIAO and role.isZhuiJia == nil then
                                local ret ,meridian = role:cheackHaveSpecialMeridianEffect()
                                
                                if ret == true then
                                    role._isHuaZhi = true --记录是否触发了化指类经脉
                                    role._ishuazhieffect = meridian.effect --记录触发的具体效果
                                    --触发化指为剑或者同类型经脉效果,要延迟进入等待体力恢复状态
                                    role:setWaitingTili(false)
                                    zhao.isWaitingTili = false
    
                                    self:callEventListener("activeJingMaiYinJi", meridian.id, meridian.name, nil,role:getTeamId())
                                end
                            end
                        end
                    end
                   

                    self:doAutoZhao(role, target, zhao)
                   
                    
                    -- 附加动画隐藏 add by TangJian 2017/04/08 11:53:22
                    self:callEventListener("setRoleAllAdditionalAnimEnabled", role, false)
                end
                
                -- 招式帧加 1
                role._currZhaoFrame = role._currZhaoFrame + 1
                
                -- 判断前摇是否结束
                local atkFrame = zhao.atkFrame
                if role._currAutoZhaoTimes == 1 or role:isWaitingTili() then -- 第一招有跳跃, 需要加上跳跃时间
                    local attackZhao = role:getCurrAttackZhao()
					local speed = Helper:getDef(attackZhao.anims[1].speed,1)
                    if attackZhao.anims then
                        atkFrame = zhao.atkFrame + math.ceil(10 / speed / FIGHT_JUMP_SPEED_SCALE)
                    end
                end
                if PRINT_MODE == 1 then
                    print("atkFrame = ", atkFrame)
                end
                if role._currZhaoFrame > atkFrame then
                    -- 进入攻击帧
                    self._isSleepFrame = false -- 设置为静止帧
                    role._currZhaoFrame = 1 -- 招式帧设置为1
                    role._currZhaoState = 3 -- 进入后摇
                    if PRINT_MODE == 1 then
                        print(role:getName(), "攻击结束")
                    end
                    
                    if NEW_VERSION then
                        -- 尝试是否有体力执行下一招
                        local nextZhao = autoZhaos[role._currZhaoIndex + 1]
                        local attackSkill = Skill:getSkill(nextZhao.atkSkId)
                        local attackZhao = attackSkill:getAttackZhaoById(nextZhao.atkZhaoId)
                        local tiliConsume = role:getAutoZhaoTiliConsume(attackZhao)
                        if role:getAttr("tili") >= tiliConsume then

                            local preAutoAtk = {
                                canAtk = true,
                                attacker = role,
                                target = target,
                                tiliConsume = tiliConsume,
                                fight = self
                            }
                            MessageCenter:notify("PreAutoAtk",preAutoAtk)
    
                            if preAutoAtk.canAtk == true then
                                role._currZhaoIndex = role._currZhaoIndex + 1
                                self._isSleepFrame = true -- 设置为静止帧
                                role._currZhaoFrame = 1
                                role._currZhaoState = 2 -- 直接进入攻击状态
                                
                                if preAutoAtk.tiliConsume > 0 then
                                    role:addAttr("tili", -tiliConsume)
                                end
                            else
                                if role._isHuaZhi == true then
                                    --清空互博招式
                                    role:setCurrDoubleAttackSkill(nil)
                                    role:setCurrDoubleAttackZhao(nil)
                                    role.isZhuiJia = true
                                    role._cType = role._ishuazhieffect  --触发的是化指为剑就是剑法，化掌为刀就是刀法

                                    self._isSleepFrame = true -- 设置为静止帧
                                    role._currZhaoFrame = 1
                                    role._currZhaoState = 2 -- 直接进入攻击状态
                                    role._isHuaZhi = false
                                end
                            end
                        else

                            if role._isHuaZhi == true then
                                -- role._currZhaoIndex = role._currZhaoIndex + 1
                                --清空互博招式
                                role:setCurrDoubleAttackSkill(nil)
                                role:setCurrDoubleAttackZhao(nil)
                                role.isZhuiJia = true
                                role._cType = role._ishuazhieffect  --触发的是化指为剑就是剑法，化掌为刀就是刀法

                                self._isSleepFrame = true -- 设置为静止帧
                                role._currZhaoFrame = 1
                                role._currZhaoState = 2 -- 直接进入攻击状态

                                role._isHuaZhi = false
                            end
                        end
                    end
                    
                    -- 附加动画显示 add by TangJian 2017/04/08 11:53:22
                    self:callEventListener("setRoleAllAdditionalAnimEnabled", role, true)
                else
                    if PRINT_MODE == 1 then
                        print(role:getName(), "攻击中")
                    end
                end
            end,
            [3] = function()-- 后摇
                if self._isSleepFrame == false then
                    -- 招式帧加 1
                    role._currZhaoFrame = role._currZhaoFrame + 1
                    -- 判断前摇是否结束
                    -- if role._currZhaoFrame > zhao.aftFrame then
                    if role._currZhaoFrame > 0 then
                        -- 进入攻击帧
                        self._isSleepFrame = false -- 设置为静止帧
                        role._currZhaoFrame = 1 -- 招式帧设置为1
                        role._currZhaoState = 0 -- 进入空闲帧
                        if PRINT_MODE == 1 then
                            print(role:getName(), "后摇结束")
                        end
                    else
                        if PRINT_MODE == 1 then
                            print(role:getName(), "后摇中")
                        end
                    end
                else
                    if PRINT_MODE == 1 then
                        print(role:getName(), "静止帧, 后摇中")
                    end
                end
            end,
            
            default = function()error("currZhaoState = ") end
        })
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/03/02 15:08:12
-- @desc 效果处理
function Fight:playRoleEffect(role, frameIndex)
    -- 攻击前先做自身效果处理
    local notRemoveEffect={ --战斗中一直存在的效果
        ["SZJ001"]=true, --神照经
        ["SZJ002"]=true,
        ["ZSTS"]=true,  --长生诀阴
    }
    local effectMap = role:getEffectMap()
    local removeEffectList = {}
    for k, effect in ipairs(effectMap) do
        if effect:getValidDuration() < effect:getFinalDuration() or effect:getFinalDuration() == -30 then
			if effect:getType() == "伤害转持续自伤" and math.floor(effect:getValidDuration()) % (effect:getFinalArg3() * 30) == 0 then
				self:roleDoEffect(role, effect)
				self:callEventListener("doEffect", role, effect)
			elseif math.floor(effect:getValidDuration()) % 60 == 0 then
				if effect:getType() == "属性变化" then
					self:roleDoEffect(role, effect)
					if role:canDie() then
						if effect:getTarget() == "目标" then
							self:roleKill(effect:getOwner(), role)
						else
							self:roleKill(self:getRole(role:getTargetId()), role)
						end
					end
				elseif notRemoveEffect[effect:getId()] == true then 
					self:roleDoEffect(role, effect)
				end
				self:callEventListener("doEffect", role, effect)
			end
        end
        if effect:getValidDuration() >= effect:getFinalDuration() and effect:getFinalDuration()~=-30 then
            table.insert(removeEffectList, effect)
        end
        effect:setValidDuration(effect:getValidDuration() + 1)
    end
    for i, effect in ipairs(removeEffectList) do
        self:callEventListener("endEffect", role, effect)
        self:roleRemoveEffect(role, effect:getId())
    end
    
    if role:isDead() then
        self:callEventListener("roleDie", role, "chest")
        self:callEventListener("playWinAnim", self:getRole(role:getTargetId()),0.4)
    end
    
    if self._state ~= FIGHT_STATE_END then
        local canFightEnd, winTeamId = self:fightEndTest()
        if canFightEnd then
            self._state = FIGHT_STATE_END
            self:callEventListener("fightEnd", winTeamId, self._roles)
        end
    end
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/03/06 16:02:40
-- @desc 被攻击的时候刷新效果(以最终实际受到伤害为准)
function Fight:updateRoleEffectOnAutoAttack(role, target, damage)
    do
        local role = target
        local effectMap = role:getEffectMap()
        local removeEffectList = {}
        for k, effect in ipairs(effectMap) do
            if effect:getType() == "控制" then
                if effect:getArg1() == "定身" or effect:getArg1() == "迷惑" then
                    LogSystem:log("旧版战斗：","|控制效果 当前剩余可累计伤害：", effect:getFinalArg2(),"   |当次伤害：",damage)
                    effect:setArg2(effect:getFinalArg2() - damage)
                    if effect:getFinalArg2() <= 0 then
                        table.insert(removeEffectList, effect)
                    end
                end
            end
        end

        for i, effect in ipairs(removeEffectList) do
            self:callEventListener("endEffect", role, effect)
            self:roleRemoveEffect(role, effect:getId())
        end

        self:addRoleDamageToHurtValue(target, damage)
        self:addAppendDamageEffectDamageValue(target, damage)
    end
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/02/16 17:33:41
-- @desc 角色命令处理
function Fight:executeRoleCommand(role, frameIndex)
    --遗忘清除当前准备主动招式
    if role:isForget() then
        local activeZhaos = self:getRoleActiveZhaos(role:getId())
        activeZhaos = {}
        return
    end
    
    -- 使用主动招式
    if
        self._isSleepFrame == false
        and
        role._currZhaoState == 0
    then
        if role:getCurrActiveZhao() == nil
            and
            self:roleCanPlayActiveZhao(role:getId(), role._currActiveIndex, frameIndex)
        then
            local activeZhao = self:getRoleActiveZhao(role:getId(), role._currActiveIndex)
            if activeZhao then
				--部分遗忘清除当前准备主动招式
				if not role:isPartForgetCanUseActiveZhao(activeZhao.zid) then
					self:deleteRoleActiveZhao(role:getId(), activeZhao.zid)
					return
				end
                activeZhao = role:getActiveZhaoState(activeZhao.zid)
                if activeZhao then
                    role:setCurrActiveZhao(activeZhao)
                    role:setCurrAttackZhao(activeZhao)-- add by XiaoZhiWei 2017/03/16 19:38:55 设置主动招式的同时 需要将其设置为攻击招式 否则结算时会报错
                end
            end
        end
    end
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 播放角色帧
function Fight:playRoleFrame(role, frameIndex)
    local target = self:getRole(role:getTargetId())
    if target and target:isDead() then -- 如果对手挂了, 就切换对手
        role:setTargetId(self:getTeamRandomRole(self:getEnemyTeamId(role:getTeamId())):getId())
        target = self:getRole(role:getTargetId())
    end
    
    if role and role:isAlive() then
        -- 刷新自己角色
        role:updateFrame(frameIndex)

        if not role:isPlayer() then
            ActiveZhaoRules:updateRulesCd(frameIndex)
        end
        self:callEventListener("updateActiveZhaoButton", self:getPlayer())
        
        
        if self._isSleepFrame == false
            and
            role._currZhaoState == 0 then -- 只有空闲帧才回复体力
            
            -- old MIN((等效身法+208)*(攻速系数+230)/1000,100)  now 体力回复速度 = min((有效身法 + 550) * (攻速系数+ 80) / 1140, 150) 
            local RestoreTiliPerSecond = math.min((role:getRole():getEffectDex() + 550) * (role:getAttackSpeedFactor() + 80) / 1140, 150)
            local atkSpeedFactor = role:getAtkSpeedFactor()
            RestoreTiliPerSecond = RestoreTiliPerSecond * atkSpeedFactor
            if PRINT_MODE == 1 then
                print("人物初始攻速 = ",role:getAttr("atkSpeedFactor"))
                print("武器重量影响后的攻速 = ",atkSpeedFactor)
                print("RestoreTiliPerSecond = ", RestoreTiliPerSecond)
                print(role:getName() .. "RestoreTiliPerSecond = ", RestoreTiliPerSecond)            
                print(role:getName() .. [[role:getFinalAttr("tiliMax") = ]], role:getFinalAttr("tiliMax"))
            end            
            role:addAttr("tili", RestoreTiliPerSecond / 30, 0, role:getFinalAttr("tiliMax"))
        
        end
        
        -- 静止帧 效果刷新 add by TangJian 2017/03/02 15:23:50
        if self._isSleepFrame == false then
            self.__sleepFrameFM:callFunctions()

            self:playRoleEffect(role, frameIndex)

            -- 效果每次静止帧算一轮
            role:updateFragile()
            role:updateAugment()
            
            if role:isImmobilized() then
                role:setAttr("tili", 0)
            end
        end
    end

    -- 对手存在且活着才能发动进攻
    if target and target:isAlive() then
        -- 主动技能 add by TangJian 2017/02/16 17:36:28
  
        if role:getCurrActiveZhao() then
            self:playRoleActiveZhao(role, target, frameIndex)
        end
        
        -- 被动招式 add by TangJian 2017/02/16 17:40:50
        if role:getCurrActiveZhao() == nil then
            self:playRoleAutoZhao(role, target, frameIndex)
        end
    else
        if PRINT_MODE == 1 then
            print("对手不存在")
        end
    end
end
--@desc: 初始化NPC的主动招式释放规则
--@author:Liang SongQiang
--@time:2018-01-19 14:19:45
--@role:
function Fight:initNpcActiveZhaoRules(role)
    -- role = self:getRole(role:getId())
    role._npcActiveZhaoRules = {}
    for i = 1, 10 do
        if role._role["activeZhao" .. tostring(i)] ~= nil then
            role._npcActiveZhaoRules[role._role["activeZhao" .. tostring(i)]] =
                role._role["release_rule" .. tostring(i)]
        end
    end

    if MapIsEmpty(role._npcActiveZhaoRules) then
        role._npcActiveZhaoRules = nil
    end
end

--@desc: 判断主动招式是否可以出招
--@author:Liang SongQiang
--@time:2018-01-19 14:40:18
--@role:[src.app.models.fight.FightRole#FightRole]
--@activeZhaoId: 主动招式ID
local function isCanPlayActiveZhaoByNpc(role, player, activeZhaoId)
    local isCan = false
    if MapIsEmpty(role._npcActiveZhaoRules) == true then
        return isCan
    end 
    local ruleId = role._npcActiveZhaoRules[activeZhaoId]

    if not ruleId then
        assert(false, activeZhaoId .. "没有配置释放规则")
        return
    end

    local ruleCdId = activeZhaoId.."_"..ruleId

    local ruleCD = ActiveZhaoRules:getRulesCd(ruleCdId)

    if ruleCD and ruleCD > 0 then
        isCan = false
        return isCan
    end
    
    local rule = ActiveZhaoRules:getRuleById(ruleId)
    
	-- npc气血属性值判断
    local npcQi = ActiveZhaoRules:checkRoleAttrQi(role, rule.qi)

    --@desc NPC内力条件
    local npcNeili = ActiveZhaoRules:checkRoleAttrNeiLi(role, rule.neili)

	-- 玩家气血属性值判断
	local playerQi = ActiveZhaoRules:checkRoleAttrQi(player, rule.playerqi)

	-- 玩家内力属性值判断
    local playerNeili = ActiveZhaoRules:checkRoleAttrNeiLi(player, rule.playerneili)

    -- NPC持有效果ID判断
    local npcEffect = ActiveZhaoRules:checkEffect(role, rule.effect)

    -- NPC标记类属性值判断
    local npcEffectNum = ActiveZhaoRules:checkEffectNum(role, rule.effectNum)

    -- 玩家持有效果ID判断
    local playerEffect = ActiveZhaoRules:checkEffect(player, rule.playerEffect)

    -- 玩家标记类属性值判断
    local playerEffectNum = ActiveZhaoRules:checkEffectNum(player, rule.playerEffectNum)

    -- 所有条件（原有属性+新增Buff）都满足时，返回可释放
    if npcQi and npcNeili and playerQi and playerNeili 
        and npcEffect and npcEffectNum and playerEffect and playerEffectNum then
        isCan = true
    end

    return isCan
end

--@desc: 给NPC设置准备主动招式准备出招
--@author:Liang SongQiang
--@time:2018-01-18 15:59:38
--@role: [src.app.models.fight.FightRole#FightRole]
function Fight:setActiveZhaoByNpc(role, frameIndex)
    --@desc teamId是1的话是玩家自己，不是NPC，直接返回
    if role:isPlayer() then
        return
    end

    --@desc 降低刷新计算频率
    if self.__aiFrameIndex ~= 0 and frameIndex - self.__aiFrameIndex < 10 then
        return
    end
    self.__aiFrameIndex = frameIndex


    role = self:getRole(role:getId())

    --@desc 迷惑 和 晕迷不能释放
    if role:isSleep() or role:isBlind() then
        return
    end

    --@desc 禁锢 不能释放
    if role:isimprison() then
        return
    end

    --@desc 遗忘状态无法释放
    if role:isForget() then
        return
    end
    
    local frame = self._currFrame + 1
    
    for activeZhaoId, activeZhaoState in pairs(role._currActiveZhaoStateMap) do
        if activeZhaoId ~= "huifu"  then
            self._preUpdateFM:addFunction(
                function()
                    if activeZhaoState:getCDLeft() <= 0 and role:getAttr("neili") >= activeZhaoState:getFinalCost() then
                        
                        -- 如果当前大于收到帧, 则需要回溯
                        if self._currFrame > frame then
                            self:restore(frame)
                            -- 回溯
                        end

                        if role:isFrozen() or role:isParalyzed() then
                            local activeZhao = Skill:getActiveZhao(activeZhaoId)
                            if activeZhao:getType() ~= "释放" then
                                return true
                            end
                        end

                        if role:isAttackLimit() then
                            local activeZhao = Skill:getActiveZhao(activeZhaoId)
                            if activeZhao:getType() ~= "释放" then
                                return true
                            end
                        end

                        if role:isForget() then
                            return true
                        end

						if not role:isPartForgetCanUseActiveZhao(activeZhaoId) then
							return true
						end
                        
                        if role:getReadyActiveZhaoId() == nil then
                            local isSet = isCanPlayActiveZhaoByNpc(role, self:getPlayer(), activeZhaoId)
                            if not isSet then
                                return true
                            end
                            
                            role:setReadyActiveZhaoId(activeZhaoId)
                            -- 添加主动招式
                            local roleId = role:getId()
                            local activeZhaos = self:getRoleActiveZhaos(roleId)
                            table.insert(activeZhaos, {rid = roleId, f = frame, zid = activeZhaoId})

                            -- 通知显示
                            self:callEventListener("readyActiveZhao", roleId, activeZhaoId)
                            return true
                        end
                    end
                    return true
                end
            )
        end
    end
end


-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 播放帧
function Fight:playFrame(frameIndex)
    -- 遍历刷新所有角色
    -- local roleUpdateArray = self:getRandomRoleUpdateArray()
    local roleUpdateArray = self:getRoleIdArray()
    for i, roleId in ipairs(roleUpdateArray) do
        local role = self:getRole(roleId)
        if not role:isPaused() and role:isAlive() then
            if NPC_AI then
                --@desc 设置NPC是否播放主动技能
                self:setActiveZhaoByNpc(role,frameIndex)
            end
            self:executeRoleCommand(role, frameIndex)
            self:playRoleFrame(role, frameIndex)
        end
    end
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 更新帧
function Fight:updateFrame()
    if self:isPaused() then
        if PRINT_MODE == 1 then
            print("Fight 暂停中")
        end
        return
    end
    
    if PRINT_MODE == 1 then
        print("self._currFrame = ", self._currFrame)
    end
    self._preUpdateFM:callFunctions()
    if self._state == FIGHT_STATE_RUNNING then
        -- 播放当前帧
        self:playFrame(self._currFrame)
        
        -- 如果是静止帧, 则帧数不增加
        if self._isSleepFrame then
        else
            self._currFrame = self._currFrame + 1
        end
    end
    -- 事件提醒
    self._eventListenerFM:callFunctions()
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 备份战斗状态
function Fight:backup()
    local currFrame = self._currFrame
    self._backups[currFrame] = Helper:getDef(self._backups[currFrame], {})
    for i, v in ipairs(self._needBackupList) do
        self._backups[currFrame][v] = clone(self[v])
    end
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 回复战斗状态
function Fight:restore(frame)
    if PRINT_MODE == 1 then
        logt("回溯", self._currFrame, " -> ", frame)
    end
    
    local nearAndMaxFrame = nil
    for backupFrame, v in pairs(self._backups) do
        if backupFrame > frame then
            elseif backupFrame < frame then
            if nearAndMaxFrame == nil then
                nearAndMaxFrame = backupFrame
            else
                nearAndMaxFrame = math.max(nearAndMaxFrame, backupFrame)
            end
            elseif backupFrame == frame then
                nearAndMaxFrame = backupFrame
                break
            else
                error()
        end
    end
    
    if nearAndMaxFrame == nil then -- 没找到可用备份
        if PRINT_MODE == 1 then
            log("没找到可用备份")
        end
        return false
    end
    
    local backup = self._backups[nearAndMaxFrame]
    
    -- 恢复
    for i, v in ipairs(self._needBackupList) do
        self[v] = clone(backup[v])
    end
    
    -- 执行帧到设定帧
    if PRINT_MODE == 1 then
        print("开始跳帧")
    end
    while self._currFrame < frame do
        if PRINT_MODE == 1 then
            print("frame = " .. frame)
            print("self._currFrame = " .. self._currFrame)
        end
        self:playFrame(self._currFrame)
        self._currFrame = self._currFrame + 1
    end
    
    if PRINT_MODE == 1 then
        print("跳帧结束")
    end
    self._eventListenerFM:removeFunctions()
    return true
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 打印信息
function Fight:printInfo()
    if PRINT_MODE == 1 then
        logt("Fight", self)
    end
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/03/15 23:14:28
-- @desc 杀人
function Fight:roleKill(role, target)
    if not target:isUndead() then
        -- 触发击杀敌人buff add by TangJian 2017/04/25 03:17:20
        role:executeBuff("击杀敌人", role, target)

        target:setDead(true)-- 设置为死亡状态
        target:setKiller(role)-- 记录杀死自己的人
        role:addKilledRole(target)-- 添加杀死的角色 add by TangJian 2016/11/25 18:35:39
    end
end

--------------------------------------打飞与打断机制-------------------------------------------
function Fight:needUnmountWeapon(role, target)
    LogSystem:log("旧版战斗：","进入打飞机制判断")
    --打飞机制
    if role._role:getEquipByName("weapon") == nil or target._role:getEquipByName("weapon") == nil then
        return false
    end

    local jifeiOdds = 0
    local item = role._role:getOneItemByKey(role._role:getEquipByName("weapon").itemId)
    local item1 = target._role:getOneItemByKey(target._role:getEquipByName("weapon").itemId)
    local W1,W2,K1,K2 = 0,0,0,0

    if item and item1 then
        LogSystem:log("旧版战斗：","打飞机制 当前武器flyWeapon： ",role:canFlyWeapon()," |目标武器beflyWeapon：",target:canBeFlyWeapon())
        if not role:canFlyWeapon() or not target:canBeFlyWeapon() then
            LogSystem:log("旧版战斗：", "不参与打飞机制")
            return false
        end
        W1 = role:getWeaponWeight()
        W2 = target:getWeaponWeight()
    end
    
    local bingqiskill = role._role:getPrepareSkill("bingqi")
    local roleWeaponType = role._role:getCurrTypeByWeapon()

    if role._role:getCurrSkillIdWithWeapon() == nil then

        local prepareList =
            {
                jianfa = "jibenjianfa",
                daofa = "jibendaofa",
                gunfa = "jibengunfa",
                bianfa = "jibenbianfa",
                shuangchi = "jibenshuangchi",
                qinfa = "jibenqinfa",
                anqi = "jibenanqi",
            }
        K1 = role._role:getSkillLv(prepareList[roleWeaponType])
    else
        K1 = role._role:getSkillLv(role._role:getCurrSkillIdWithWeapon())
    end

    local zhaoJiaSkill = target._role:getPrepareSkill("zhaojia")
    if zhaoJiaSkill ~= nil then
        K2 = target._role:getSkillLv(zhaoJiaSkill)
    else
        K2 = target._role:getSkillLv("jibenzhaojia")
    end

    if W1 >= (2 * W2) then 
        jifeiOdds= math.min((1-K2/1200),0.6)

    elseif  (2*W2) > W1 and W1 > W2 and K1 > K2 then
        jifeiOdds = Helper:getRange((1-K2/K1),0.07,0.25)
    
    elseif (2*W2) > W1 and W1 > W2 and K1 <= K2 then
        jifeiOdds = 7/100

    else 
        jifeiOdds = 0
    end

    LogSystem:log("旧版战斗：","打飞机制相关参数：","  |打飞概率：",jifeiOdds,"   |攻击方武器重量：",W1, "  |格挡方武器重量：", W2,"  |攻击方武器武学等级：", K1,"  |格挡方武器武学等级：", K2)
    
    if jifeiOdds >= math.random( 1,100 )/100 then
        return true
    end
    return false

end

function Fight:needDaduanWeapon( role,target )
    local roleWeaponYingDu = 0
    local targetWeaponrendu = 0
    local roleWeaponName = role:getCurrWeaponName()
    LogSystem:log("旧版战斗：","进入打断机制判断")
    if role._role:getEquipByName("weapon") ~= nil and target._role:getEquipByName("weapon") ~= nil then
        local targetWeaponId = target._role:getEquipByName("weapon").itemId
        local item = role._role:getOneItemByKey(role._role:getEquipByName("weapon").itemId)
        local item1 = target._role:getOneItemByKey(targetWeaponId)

        if item and item1 then
            LogSystem:log("旧版战斗：","打断机制 当前武器breakWeapon： ",role:canBreakWeapon()," |目标武器brokenWeapon：",target:canBrokenWeapon())
            if not role:canBreakWeapon() or not target:canBrokenWeapon() then
                LogSystem:log("旧版战斗：","不参与打断机制")
                return false
            end

            roleWeaponYingDu = role:getWeaponYingDu()
            targetWeaponrendu = target:getWeaponRenDu()
        end

        local k = Helper:preciseDecimal(roleWeaponYingDu*((250-targetWeaponrendu)/250) * 0.03, 3)

        if not self._jianrenduCount then
            self._jianrenduCount = {}
        end

        self._jianrenduCount[targetWeaponId] = Helper:getDef(self._jianrenduCount[targetWeaponId],0) 
        self._jianrenduCount[targetWeaponId] = self._jianrenduCount[targetWeaponId] + k

        LogSystem:log("旧版战斗：","兵器打断机制相关参数：","   |攻击方武器硬度：",roleWeaponYingDu, "  |格挡方武器韧度：", targetWeaponrendu,"  |格挡方武器当前损耗值：", k,"  |格挡方武器累计损耗值：", self._jianrenduCount[targetWeaponId])
        
        if self._jianrenduCount[targetWeaponId] - targetWeaponrendu >= 0 then
            if 20 >= math.random(1,100) then
                return true
            end           
        end
        return false

    elseif roleWeaponName == "拳脚" and target._role:getEquipByName("weapon") ~= nil then
        local targetWeaponId = target._role:getEquipByName("weapon").itemId
        local item1 = target._role:getOneItemByKey(targetWeaponId)
        if item1 then
            LogSystem:log("旧版战斗：","打断机制 当前拳脚|目标武器brokenWeapon：",target:canBrokenWeapon())
            if not target:canBrokenWeapon() then
                LogSystem:log("旧版战斗：","不参与打断机制")
                return false
            end
            targetWeaponrendu = target:getWeaponRenDu()
        end

        local currStr = role._role:getFinalAttr("currStr")
        local M = role._role:getSkillLv("jibenquanjiao")
        local k = math.min(Helper:preciseDecimal(currStr/432 + M/1000, 3),1.8)

        if not self._jianrenduCount then
            self._jianrenduCount = {}
        end
        self._jianrenduCount[targetWeaponId] = Helper:getDef(self._jianrenduCount[targetWeaponId],0) 
        self._jianrenduCount[targetWeaponId] = self._jianrenduCount[targetWeaponId] + k

        LogSystem:log("旧版战斗：","拳脚打断机制相关参数：","   |攻击方有效臂力：",currStr,"   |攻击方基本拳脚等级：",M, "  |格挡方武器韧度：", targetWeaponrendu,"  |格挡方武器当前损耗值：", k,"  |格挡方武器累计损耗值：", self._jianrenduCount[targetWeaponId])

        if self._jianrenduCount[targetWeaponId] - targetWeaponrendu >= 0 then
            if 10 >= math.random(1,100) then
                return true
            end
        end
        return false
    else
        return false
    end
end

function Fight:DaduanWeapon(role, target, zhao)
    local attackSkill = Skill:getSkill(zhao.atkSkId)
    local attackZhao = attackSkill:getAttackZhaoById(zhao.atkZhaoId)
    role:setCurrAttackSkill(attackSkill)
    role:setCurrAttackZhao(attackZhao)
    
    local doubleAttackSkill = nil
    local doubleAttackZhao = nil
    if zhao.dblAtkSkId then
        doubleAttackSkill = Skill:getSkill(zhao.dblAtkSkId)
        if doubleAttackSkill then
            doubleAttackZhao = doubleAttackSkill:getAttackZhaoById(zhao.dblZhaoId)
            role:setCurrDoubleAttackSkill(doubleAttackSkill)
            role:setCurrDoubleAttackZhao(doubleAttackZhao)
        end
    end

    local targetWeaponType = target._role:getCurrWeaponType()  
    local targetWeaponType2 = target._role:getCurrWeaponType2()
    target:daduanWeapon()
    target:setAutoZhaos(role:getId(), target:createAutoZhaos(role))  

    self:callEventListener("weaponDaduan", role, target, zhao,targetWeaponType,targetWeaponType2)
end

function Fight:yiwu(role)
    if not role then 
        return false
    end
    
    if role:getAttr("tili") < role:getFinalAttr("tiliMax") then 
        return false
    end
    
    role:setAttr("tili",0)
    role:setChangeWeaponType(1)
    self:changeWeapon(role)
    self:callEventListener("changeWeapon", role)


    role.isInYiWu = false
    self._isSleepFrame = false
    role.yiWuTime=0

    role.hasUsedYiWu = true

    return true
end

function Fight:changeWeapon(role)
    role:newWeaponChange()

    if role:isForget() then
        self:callEventListener("afterChangeWeapon", role,2)  
    else
        self:callEventListener("afterChangeWeapon", role,3)
    end
end

function Fight:unmountWeapon(role, target, zhao)
    local attackSkill = Skill:getSkill(zhao.atkSkId)
    local attackZhao = attackSkill:getAttackZhaoById(zhao.atkZhaoId)
    role:setCurrAttackSkill(attackSkill)
    role:setCurrAttackZhao(attackZhao)
    
    local doubleAttackZhao = nil
    local doubleAttackSkill = nil
    if zhao.dblAtkSkId then
        doubleAttackSkill = Skill:getSkill(zhao.dblAtkSkId)
        if doubleAttackSkill then
            doubleAttackZhao = doubleAttackSkill:getAttackZhaoById(zhao.dblZhaoId)
            role:setCurrDoubleAttackSkill(doubleAttackSkill)
            role:setCurrDoubleAttackZhao(doubleAttackZhao)
        end
    end
    
    local targetWeaponType = target._role:getCurrWeaponType() 
    local targetWeaponType2 = target._role:getCurrWeaponType2()
    target:jifeiWeapon()
    target:setAutoZhaos(role:getId(), target:createAutoZhaos(role))  

    self:callEventListener("weaponjifei", role, target, zhao,targetWeaponType,targetWeaponType2)
end

local function getZhaoQiAtkAfterParryFactor(atk, factor)
    LogSystem:log("旧版战斗：招架免伤强化系数 = ", factor)
    atk = atk * math.max((1 - 0.5 - factor), 0)
    LogSystem:log("旧版战斗：招架免伤强化系数计算后伤害 = ", atk)
    return atk
end

local function getZhaoQiMaxAtkAfterParryFactor(atk, factor)
    atk = atk * math.max((1 - 0.5 - factor), 0)
    return atk
end

local function getZhaoQiAtkAfterDamageFactor(atk, factor)
    LogSystem:log("旧版战斗：经气血最终伤害系数计算前的atk = ", atk)
    atk = Helper:getRange(atk * factor,1)
    LogSystem:log("旧版战斗：经气血最终伤害系数计算后的atk = ", atk)
    return atk
end

local function getZhaoQiMaxAtkAfterQiMaxAtkFactor(atk, factor)
    atk = Helper:getRange(atk * factor,0) 
    return atk
end

local function getZhaoQiAtkAfterZhaoTimesFactor(atk, factor)
    LogSystem:log("旧版战斗：经招式递减系数计算前的atk = ", atk)
    atk = atk * factor
    LogSystem:log("旧版战斗：经招式递减系数计算后的atk = ", atk)
    return atk
end

local function getZhaoQiMaxAtkAfterZhaoTimesFactor(atk, factor)
    atk = atk * factor
    return atk
end

local function getZhaoQiAtkAfterBuff(atk, buff1, buff2, buff3, buff4)
    LogSystem:log("旧版战斗：经相关buff系数计算前的atk = ", atk)
    atk = (atk + buff1) * (buff2 + buff3 + buff4)
    LogSystem:log("旧版战斗：经相关buff系数计算后的atk = ", atk)
    return atk
end

function Fight:getBeforeEffectAtk(atk, atkFactors)
    local value = atk

    if MapIsEmpty(atkFactors) == false then
        if atkFactors.parryFactor then
            value = getZhaoQiAtkAfterParryFactor(value, atkFactors.parryFactor)
        end

        if atkFactors.damageFactor then
            value = getZhaoQiAtkAfterDamageFactor(value, atkFactors.damageFactor)
        end

        if atkFactors.zhaoTimesFactor then
            value = getZhaoQiAtkAfterZhaoTimesFactor(value, atkFactors.zhaoTimesFactor)
        end

        if atkFactors.buff1 and atkFactors.buff2 and atkFactors.buff3 and atkFactors.buff4 then
            value = getZhaoQiAtkAfterBuff(value, atkFactors.buff1, atkFactors.buff2, atkFactors.buff3, atkFactors.buff4)
        end
    end

    LogSystem:log("旧版战斗：效果处理之前，atk = ", value)

    return value
end

function Fight:getBeforeEffectQiMaxAtk(qiMaxAtk, qiMaxAtkFactors)
    local value = qiMaxAtk

    if MapIsEmpty(qiMaxAtkFactors) == false then
        if qiMaxAtkFactors.parryFactor then
            value = getZhaoQiMaxAtkAfterParryFactor(value, qiMaxAtkFactors.parryFactor)
        end

        if qiMaxAtkFactors.qiMaxAtkFactor then
            value = getZhaoQiMaxAtkAfterQiMaxAtkFactor(value, qiMaxAtkFactors.qiMaxAtkFactor)
        end

        if qiMaxAtkFactors.zhaoTimesFactor then
            value = getZhaoQiMaxAtkAfterZhaoTimesFactor(value, qiMaxAtkFactors.zhaoTimesFactor)
        end
    end

    return value
end

function Fight:getBeforeEffectAtkInHitResult(atk, atkFactors)
    local value = atk

    if MapIsEmpty(atkFactors) == false then
        if atkFactors.damageFactor then
            value = getZhaoQiAtkAfterDamageFactor(value, atkFactors.damageFactor)
        end

        if atkFactors.zhaoTimesFactor then
            value = getZhaoQiAtkAfterZhaoTimesFactor(value, atkFactors.zhaoTimesFactor)
        end

        if atkFactors.buff1 and atkFactors.buff2 and atkFactors.buff3 and atkFactors.buff4 then
            value = getZhaoQiAtkAfterBuff(value, atkFactors.buff1, atkFactors.buff2, atkFactors.buff3, atkFactors.buff4)
        end
    end

    LogSystem:log("旧版战斗：效果处理之前，命中情况下atk = ", value)

    return value
end

-- 内省效果
local function getNeiLiConsumeAfterNeiLiSaveEffects(value, role)
    if role:isNeiliSave() then
        local effects = role:getEffectMap()

        for k, effect in pairs(effects) do
            if effect:getType() == "内省" then         
                local arg2 = effect:getFinalArg2()
                value = value *(1 - arg2)
            end
        end
    end

    return value
end

local function getNeiLiConsumeAfterJiaLiNeiLiAttrs(value, role)
    value = math.max((value + role:getFinalAttr("jiaLiNeiliCost")) * role:getFinalAttr("jiaLiNeiliCostPercent") ,0)
    return value
end

--第二招以及第二招之后的招式,内力消耗值将为75%
local function getNeiLiConsumeAfterAutoZhaoTimes(value, role)
    if role._currAutoZhaoTimes >= 2 then
        value = value * 0.75
    end
    return value
end

function Fight:getAutoZhaoNeiliConsume(value, role)
    value = getNeiLiConsumeAfterNeiLiSaveEffects(value, role)
    value = getNeiLiConsumeAfterJiaLiNeiLiAttrs(value, role)
    value = getNeiLiConsumeAfterAutoZhaoTimes(value, role)

    return value
end


function Fight:doAutoZhao(role, target, zhao)
    local attackSkill = Skill:getSkill(zhao.atkSkId)
    local attackZhao = attackSkill:getAttackZhaoById(zhao.atkZhaoId)
    role:setCurrAttackSkill(attackSkill)
    role:setCurrAttackZhao(attackZhao)
    
    local doubleAttackSkill = nil
    local doubleAttackZhao = nil
    if zhao.dblAtkSkId then
        doubleAttackSkill = Skill:getSkill(zhao.dblAtkSkId)
        if doubleAttackSkill then
            doubleAttackZhao = doubleAttackSkill:getAttackZhaoById(zhao.dblZhaoId)
            role:setCurrDoubleAttackSkill(doubleAttackSkill)
            role:setCurrDoubleAttackZhao(doubleAttackZhao)
        end
    end

    zhao.originalAtk = zhao.atk
    zhao.originalQiMaxAtk = zhao.qiMaxAtk
    zhao.calculateAtkFactors = {}
    zhao.calculateQiMaxAtkFactors = {}

    local calculateAtkFactors = zhao.calculateAtkFactors
    local calculateQiMaxAtkFactors = zhao.calculateQiMaxAtkFactors

    -- 特殊情况, 需要改造招式
    do
        -- 如果这个属性被修改了, 则需要重新计算招式结果 add by TangJian 2017/01/03 16:52:53
        if role:getAttr("hitRateFactor") ~= 1 or target:getAttr("dodgeRateFactor") ~= 1 or target:getAttr("parryRateFactor") ~= 1 then
            if PRINT_MODE == 1 then
                print("命中率系数————————————>"..role:getAttr("hitRateFactor"))
                print("闪避率系数————————————>"..target:getAttr("dodgeRateFactor"))
                print("招架率系数————————————>"..target:getAttr("parryRateFactor"))
            end
            zhao.hitType, zhao.atk, zhao.qiMaxAtk, zhao.neiliConsume, zhao.hitPosName = role:createAttackResult(role, target, attackSkill, attackZhao, doubleAttackSkill, doubleAttackZhao, zhao.mn1, zhao.mn2)
            
            zhao.originalAtk = zhao.atk
            zhao.originalQiMaxAtk = zhao.qiMaxAtk
            zhao.calculateAtkFactors = {}
            zhao.calculateQiMaxAtkFactors = {}
        
            calculateAtkFactors = zhao.calculateAtkFactors
            calculateQiMaxAtkFactors = zhao.calculateQiMaxAtkFactors
        end

		if role:isHit() then
			self:refreshRoleEffectRemaining(role,"必中")
		end

		if role:isHitFailure() then
			self:refreshRoleEffectRemaining(role,"致盲")
		end

        if target:isParry() then
			self:refreshRoleEffectRemaining(target,"强招架")
        end

		do
			if role:isHit() then
				zhao.hitType = HIT_TYPE_HIT
			elseif role:isHitFailure() then
				zhao.hitType = HIT_TYPE_DODGE
			elseif target:isParry() and target:canParry() == true then
				zhao.hitType = HIT_TYPE_PARRY
			end
		
			if zhao.hitType == HIT_TYPE_PARRY and target:canParry() == false then
				zhao.hitType = HIT_TYPE_HIT
			elseif zhao.hitType == HIT_TYPE_DODGE and target:canDodge() == false then
				zhao.hitType = HIT_TYPE_HIT
			end
		end


        -- 招架免伤强化系数
        if zhao.hitType == HIT_TYPE_PARRY then
            local factor = target:getAttr("parryHurtFixRateFactor")
            calculateAtkFactors.parryFactor = factor
            calculateQiMaxAtkFactors.parryFactor = factor
        end 

        calculateAtkFactors.damageFactor = self:calAutoDamageFinalFactor(role,target, zhao.hitType)

        if role:getAttr("qiMaxAtkFactor") ~= 1 then
            local qiMaxAtkFactor = role:getAttr("qiMaxAtkFactor")
            calculateQiMaxAtkFactors.qiMaxAtkFactor = qiMaxAtkFactor
        end
    end

    -- 招式伤害递减\
    do
        --经脉招不递减
        if zhao.isJingMaiZhao ~= true then
            local zhaoTimesFactor = Helper:getDef(AUTO_ZHAO_TIMES_DAMAGE_FACTOR_ARRAY[role._currAutoZhaoTimes], 0.4)
            calculateAtkFactors.zhaoTimesFactor = zhaoTimesFactor
            calculateQiMaxAtkFactors.zhaoTimesFactor = zhaoTimesFactor
        end
    end

    -- 加力消耗内力 add by TangJian 2016/11/16 16:51:31
    do
        -- 判断是否需要内力 add by TangJian 2017/03/22 16:30:12
        if role:isNeedNeili() == true then
            local neiliConsume = self:getAutoZhaoNeiliConsume(zhao.neiliConsume, role)

            if role.isZhuiJia then
                neiliConsume = 0
            end

            if role:getAttr("neili") - neiliConsume < 0 then
                neiliConsume = -(role:getAttr("neili") - neiliConsume)
            end
            
            role:addAttr("neili", -neiliConsume, 0)
        end
    end

    -- 不同攻击情况
    do
        local condition_1 = target:getAttackMethod() ~= 1
        local condition_2,condition_3 = false,false

        if condition_1 == true then
            condition_2 = zhao.hitType == HIT_TYPE_PARRY
        end

        if condition_2 == true then
            condition_3 = self:getPlayer():getRole():getAttr("userid") ~= "liLianClonePlayer01"
        end

        if TEST_COMMAD_VALUE == 4 then
            condition_1 = true
            condition_2 = true
            condition_3 = true
        end

        LogSystem:log("旧版战斗：","打飞打断机制前置条件condition_1:",condition_1,"|condition_2:",condition_2,"|condition_3:",condition_3)
        

        if (TEST_COMMAD_VALUE == 2 and target:isPlayer()) or (SHENBINGSYS and condition_1 and condition_2 and condition_3 and self:needUnmountWeapon(role,target)) then -- 打飞武器    
           
            local roleWeaponName = role:getCurrWeaponName()
            self:unmountWeapon(role, target, zhao)
            self._eventListenerFM:addFunction(function ()

                local str = "HIR$N使用$wHIR一击打在$n的兵器之上，$n虎口发麻，兵器应声脱手！NOR"
                self:callEventListener("printText",str, role:getAttr("name"), target:getAttr("name"),roleWeaponName)

                return true
            end)


        elseif (TEST_COMMAD_VALUE == 3 and target:isPlayer()) or (SHENBINGSYS and condition_1 and condition_2 and condition_3 and self:needDaduanWeapon(role,target)) then -- 打断武器
           
            local roleWeaponName = role:getCurrWeaponName()
            local targetWeaponName = target:getCurrWeaponName()
            self:DaduanWeapon(role, target, zhao)
            self._eventListenerFM:addFunction(function ()

                local str = "HIR$N使用$wHIR打在$n的兵器之上，只听一声脆响，$n的兵器竟然应声而断！NOR"
                self:callEventListener("printText",str, role:getAttr("name"), target:getAttr("name"),roleWeaponName)

                return true
            end)        


        else -- 一般攻击

            local atkAddValue = 0
            local selfAtkPercent = 0
            local targetAtkPercent = 0
            --@region  情绪附带攻击力加成
            local drEmotionAttackRate = role:getRole():getFinalAttr("drEmotionAttackRate")
            if drEmotionAttackRate >= 1 and zhao.hitType == HIT_TYPE_HIT and  drEmotionAttackRate >= math.random(1,100) then
                local percent = role:getRole():getFinalAttr("drEmotionAttackPercent")
                if percent ~= 0  then
                    selfAtkPercent  = selfAtkPercent + role:getRole():getFinalAttr("drEmotionAttackPercent")
                    local str = role:getRole().emotionMgr:getAttackAddPercentDesc()
                    self:callEventListener("popFightText",str, role:getAttr("name"), target:getAttr("name"))
                end
            end
            
            local drEmotionTargetAtkRate = target:getRole():getFinalAttr("drEmotionTargetAtkRate")
            if drEmotionTargetAtkRate >= 1 and zhao.hitType == HIT_TYPE_HIT and drEmotionTargetAtkRate >= math.random(1, 100) then
                local percent = target:getRole():getFinalAttr("drEmotionTargetAtkScale")
                if percent ~= 0 then
                    local str = target:getRole().emotionMgr:getBeHitAtkAddDesc()
                    self:callEventListener("popFightText",str)
                    targetAtkPercent  = targetAtkPercent + target:getRole():getFinalAttr("drEmotionTargetAtkPercent")
                end
            end

            calculateAtkFactors.buff1 = atkAddValue
            calculateAtkFactors.buff2 = role:getRole():getFinalAttr("zhaoAtkScale")
            calculateAtkFactors.buff3 = selfAtkPercent
            calculateAtkFactors.buff4 = targetAtkPercent

            zhao.calculateAtkFactors = calculateAtkFactors
            zhao.calculateQiMaxAtkFactors = calculateQiMaxAtkFactors
            zhao.atk = self:getBeforeEffectAtk(zhao.originalAtk, calculateAtkFactors)
            zhao.qiMaxAtk = self:getBeforeEffectQiMaxAtk(zhao.originalQiMaxAtk, calculateQiMaxAtkFactors)

            --防止出现扣的气血上限大于气血
            if zhao.qiMaxAtk > zhao.atk then
                zhao.atk = zhao.qiMaxAtk
            end

            -- 数值计算
            self:roleAttack(role, target, zhao)                    
        end
        
    end
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 角色攻击数值计算
function Fight:roleAttack(role, target, zhao)
    -- 延时效果处理
    self:executeDelayEffect(role,target)
    
    -- 攻击结果
    do

        --攻击就生效    
        if SHENBINGSYS then
            self:getWeaponEffect(role,target,1)
        end

        if zhao.hitType == HIT_TYPE_HIT then
            -- 效果(反伤, 偏转, 护盾,凝血,真罡)
            do  
                if target:isCruor() then
                    local effectMap = target:getEffectMap()
                    for k,effect in ipairs(effectMap) do
                        if effect:getType() == "凝血" then
                            local arg1 = effect:getArg1()
                            zhao.cruorFactor = arg1
                            zhao.isCruor = true
                            break
                        end
                    end      
                elseif target:haveFanShang() then -- 反伤
                    local effectMap = target:getEffectMap()
                    for k, effect in ipairs(effectMap) do
                        if effect:getType() == "反伤" then
                            local arg1 = effect:getArg1()
                            arg1 = arg1 - 1
                            effect:setArg1(arg1)
                            if arg1 <= 0 then
                                self:callEventListener("endEffect", target, effect)
                                self:roleRemoveEffect(target, effect:getId())
                            end
                            zhao.isFanShang = true
                            break
                        end
                    end
                elseif target:haveZhuanYi() then
                    local effectMap = target:getEffectMap()
                    for k, effect in ipairs(effectMap) do
                        if effect:getType() == "偏转" then
                            local arg1 = effect:getArg1()
                            arg1 = arg1 - 1
                            effect:setArg1(arg1)
                            if arg1 <= 0 then
                                self:callEventListener("endEffect", target, effect)
                                self:roleRemoveEffect(target, effect:getId())
                            end
                            zhao.isZhuanYi = true
                            break
                        end
                    end
                elseif target:haveShield() then -- 护盾            
                    zhao.absorbAtk = self:consumeShield(target, zhao.atk)
                elseif target:isDamageMax() then -- 单次伤害上限            
                    zhao.damageMax = target:calDamageMax()
                elseif target:isZhenGang() then -- 真罡            
                    local objectEffectMap = target:getEffectMap()
                    local zhenGangValue = 0 --真罡承受值
                    for k,objectEffect in ipairs(objectEffectMap) do
                        if objectEffect:getType() == "真罡" then
                            zhenGangValue = objectEffect:getFinalArg2()
                            break
                        end
                    end
                    zhao.isZhenGang = zhenGangValue
                elseif target:isUnloadForce() then --卸力
                    --计算卸力百分比
                    zhao.xieLiPercent = self:calUnloadForce(target)
                    if DEBUG_MODE == 1 then
                        print(target:getName().."的卸力百分比 = ",zhao.xieLiPercent)
                    end
                elseif target:isSaveDamageByHurt(HurtFactory:create(0,zhao.atk)) then --储伤
                    zhao.isSaveDamage = true
                end
            end
            --击中生效(只要不被闪避或者格挡)
            if SHENBINGSYS then
                self:getWeaponEffect(role,target,2)
            end

            --经脉触发的招式不触发拳脚特性
            if zhao.isJingMaiZhao ~= true then
                self:getFistFootEffect(role,target,2)
            end
            
            self:calWeaponPoison(role,target)
            --命中触发效果
            self:doHitTriggerEffect(role,target)

            --被命中者触发效果
            self:doHitTriggerTargetEffect(role,target)

            --刷新被动气血伤害系数生命周期
            role:updateAttrFactorCount("qiAutoAtkFactor")

            --刷新被动气血防御系数生命周期
            target:updateAttrFactorCount("qiAutoDefFactor")

            local roleIsInDamageToHurt = role:isInDamageToHurt()
            local targetIsInDamageToHurt = target:isInDamageToHurt()

            local qiAtk = Helper:getRange(zhao.atk - Helper:getDef(zhao.absorbAtk, 0), 0) --护盾
            
            --真罡
            qiAtk = Helper:getRange(qiAtk - Helper:getDef(zhao.isZhenGang, 0), 0)

            local xieLiPercent = Helper:getRange(Helper:getDef(zhao.xieLiPercent, 0), 0,1)

            --卸力
            LogSystem:log("旧版战斗：","卸力效果值：", xieLiPercent, "卸力减免伤害值：", qiAtk * xieLiPercent)
            qiAtk = qiAtk * (1 - xieLiPercent)

            --真实伤害(无视护盾，无视卸力)
            local trueDamage = self:calTrueDamage(role,zhao)
            -- print("111111111111111111111111","trueDamage = ",trueDamage,"qiAtk = ",qiAtk)
            qiAtk = qiAtk + trueDamage
            zhao.trueDamage = trueDamage

            qiAtk = Helper:getRange(qiAtk,0,zhao.damageMax)

            --防止出现气血高于当前气血上限 add by LvBin 2018/11/09 11:31:30
            zhao.qiMaxAtk = math.min(zhao.qiMaxAtk,qiAtk)

            --角色实际伤害
            local targetQiAtk = qiAtk
            
            if zhao.isCruor then
                
                -- 目标回血
                local cruorFactor = Helper:getDef(zhao.cruorFactor,0)
                local value = qiAtk * cruorFactor
                target:addAttr("qi", value, 0, target:getCurrQiMax())
                LogSystem:log("旧版战斗：","凝血效果值：", cruorFactor, "凝血回血值：", value)
                self:callEventListener("hit", role, target, zhao) -- 需要对文本输出进行改造
                
                -- 攻击的时候刷新效果
                targetQiAtk = 0
                if targetQiAtk > 0 then
                    self:updateRoleEffectOnAutoAttack(role, target, targetQiAtk)
                end
            elseif zhao.isFanShang then
                if role:haveShield() then
                    local absorbAtk = self:consumeShield(role,zhao.atk)

                    --记录消耗的护盾值
                    if type(role.absorbAtk) ~= "table" then
                        role.absorbAtk = {}
                    end
                    role.absorbAtk["FanShang"] = absorbAtk
                            
                    qiAtk =  Helper:getRange(zhao.atk - Helper:getDef(absorbAtk, 0), 0)
                elseif role:haveZhuanYi() then
                    qiAtk = 0
                    zhao.qiMaxAtk = 0
                    local effectMap = role:getEffectMap()
                    for k, effect in ipairs(effectMap) do
                        if effect:getType() == "偏转" then
                            local arg1 = effect:getArg1()
                            arg1 = arg1 - 1
                            effect:setArg1(arg1)
                            if arg1 <= 0 then
                                self:callEventListener("endEffect", role, effect)
                                self:roleRemoveEffect(role, effect:getId())
                            end
                            zhao.roleHaveZhuanYi = true
                            break
                        end
                    end
                end
                --@desc 反伤扣血
                if roleIsInDamageToHurt == false then
                    role:addAttr("qi", -qiAtk)
                end
                self:addRoleDamageToHurtValue(role, qiAtk)
                self:addAppendDamageEffectDamageValue(role, qiAtk)

                if qiAtk > 0 and role._role:getBuffAttr("xingzhenQiXue") ~= 1 then
                    role:setAttr("qiPercent", (role:getFinalAttr("qiMax") * role:getAttr("qiPercent") - zhao.qiMaxAtk) / role:getFinalAttr("qiMax"))-- 扣气血上限 add by TangJian 2016/11/08 21:49:24
                end
                self:callEventListener("hit", role, target, zhao)
                
                -- 攻击的时候刷新效果
                targetQiAtk = 0
                if targetQiAtk > 0 then
                    self:updateRoleEffectOnAutoAttack(role, target, targetQiAtk)
                end
                
                if role:canDie() then
                    self:roleKill(target, role)
                end
            elseif zhao.isSaveDamage == true then
                target:addSaveDamageValueByHurt(HurtFactory:create(0,zhao.atk + trueDamage))

                --@desc 打印招式详情
                role:printZhaoInfo(target,qiAtk,zhao.qiMaxAtk)

                self:callEventListener("hit", role, target, zhao)

                targetQiAtk = 0
                if targetQiAtk > 0 then
                    self:updateRoleEffectOnAutoAttack(role, target, targetQiAtk)
                end
            else
                -- add by XiaoZhiWei 2017/07/26 14:17:47 偏转伤害移除
                if zhao.isZhuanYi == true then
                    qiAtk = 0
                    zhao.qiMaxAtk = 0
                end
                --@desc 打印招式详情
                role:printZhaoInfo(target,qiAtk,zhao.qiMaxAtk)
                
                targetQiAtk = qiAtk
                -- 目标掉血 add by TangJian 2016/11/16 16:51:30
                if targetIsInDamageToHurt == false then
                    target:addAttr("qi", -targetQiAtk)-- 扣气血 add by TangJian 2016/11/08 21:49:25
                    --伤害转气血效果累计伤害
                    if targetQiAtk > 0 then
                        self:doDamageToQiEffect(target, targetQiAtk)
                    end

                    --自己回血 add by LvBin
                    if role:isSuckBlood() then
                        zhao.isSuckBlood = true
                        local roleEffectMap = role:getEffectMap()
                        for k,effect in ipairs(roleEffectMap) do
                            if effect:getType() == "吸血" then
                                local arg1 ,arg2 = effect:getArg1(), effect:getFinalArg2()
                                zhao.arg1 = arg1
                                zhao.SuckBloodPercen = arg2

                                print("吸血系数 = ",arg2)
                                role:addAttr(arg1,arg2 * targetQiAtk,0,role:getCurrQiMax())
                            end
                        end
                    end

                    if role:isFanShi() then
                        local roleEffectMap = role:getEffectMap()
                        for k,effect in ipairs(roleEffectMap) do
                            if effect:getType() == "反噬" then
                                local arg1 ,arg2 = effect:getArg1(), effect:getFinalArg2()
                                if arg1 == "qi" then
                                    if roleIsInDamageToHurt == false then
                                        role:addAttr(arg1,-arg2 * targetQiAtk)
                                    end
                                    self:addRoleDamageToHurtValue(role, arg2 * targetQiAtk)
                                    self:addAppendDamageEffectDamageValue(role, arg2 * targetQiAtk)
                                else
                                    role:addAttr(arg1,-arg2 * targetQiAtk)
                                end

                                self:callEventListener("addRolesEffectChangeFunction", function()
                                     self:callEventListener("popText",role,math.floor(-arg2 * targetQiAtk),cc.c4b(255, 255, 255, 255))
                                    return true
                                end)
                            end
                        end
                    end
                end
                
                -- 攻击的时候刷新效果
                if targetQiAtk > 0 then
                    self:updateRoleEffectOnAutoAttack(role, target, targetQiAtk)

                    target:addRecordDamage(targetQiAtk)
                end

                if targetQiAtk > 0 and target._role:getBuffAttr("xingzhenQiXue") ~= 1 then
                    target:setAttr("qiPercent", (target:getFinalAttr("qiMax") * target:getAttr("qiPercent") - zhao.qiMaxAtk) / target:getFinalAttr("qiMax"))-- 扣气血上限 add by TangJian 2016/11/08 21:49:24
                end

                self:callEventListener("hit", role, target, zhao)

                if target:canDie() then
                    self:roleKill(role, target)
				else
					self:doDamageReturnEffect(role,target,targetQiAtk)

					target:hpRecoverOnHurt(HurtFactory:create(0,targetQiAtk))

					if role:canDie() then
						self:roleKill(target, role)
					end
				end
            end
        elseif zhao.hitType == HIT_TYPE_PARRY then
            -- 效果(反伤, 偏转, 卸力,护盾,凝血,真罡)
            do  
                if target:isCruor() then
                    local effectMap = target:getEffectMap()
                    for k,effect in ipairs(effectMap) do
                        if effect:getType() == "凝血" then
                            local arg1 = effect:getArg1()
                            zhao.cruorFactor = arg1
                            zhao.isCruor = true
                            break
                        end
                    end      
                elseif target:haveFanShang() then -- 反伤
                    local effectMap = target:getEffectMap()
                    for k, effect in ipairs(effectMap) do
                        if effect:getType() == "反伤" then
                            local arg1 = effect:getArg1()
                            arg1 = arg1 - 1
                            effect:setArg1(arg1)
                            if arg1 <= 0 then
                                self:callEventListener("endEffect", target, effect)
                                self:roleRemoveEffect(target, effect:getId())
                            end
                            zhao.isFanShang = true
                            break
                        end
                    end
                elseif target:haveZhuanYi() then
                    local effectMap = target:getEffectMap()
                    for k, effect in ipairs(effectMap) do
                        if effect:getType() == "偏转" then
                            local arg1 = effect:getArg1()
                            arg1 = arg1 - 1
                            effect:setArg1(arg1)
                            if arg1 <= 0 then
                                self:callEventListener("endEffect", target, effect)
                                self:roleRemoveEffect(target, effect:getId())
                            end
                            zhao.isZhuanYi = true
                            break
                        end
                    end
                elseif target:haveShield() then -- 护盾            
                    zhao.absorbAtk = self:consumeShield(target, zhao.atk)
                elseif target:isZhenGang() then -- 真罡            
                    local objectEffectMap = target:getEffectMap()
                    local zhenGangValue = 0 --真罡承受值
                    for k,objectEffect in ipairs(objectEffectMap) do
                        if objectEffect:getType() == "真罡" then
                            zhenGangValue = objectEffect:getFinalArg2()
                            break
                        end
                    end
                    zhao.isZhenGang = zhenGangValue
                elseif target:isUnloadForce() then --卸力
                    --计算卸力百分比
                    zhao.xieLiPercent = self:calUnloadForce(target)
                    if DEBUG_MODE == 1 then
                        print(target:getName().."的卸力百分比 = ",zhao.xieLiPercent)
                    end
                end
            end

            local qiAtk = Helper:getRange(zhao.atk - Helper:getDef(zhao.absorbAtk, 0), 0) --护盾
            --真罡
            qiAtk = Helper:getRange(qiAtk - Helper:getDef(zhao.isZhenGang, 0), 0)

            local xieLiPercent = Helper:getRange(Helper:getDef(zhao.xieLiPercent, 0), 0,1)
            --卸力
            LogSystem:log("旧版战斗：","卸力效果值：", xieLiPercent, "卸力减免伤害值：", qiAtk * xieLiPercent)
            qiAtk = qiAtk * (1 - xieLiPercent)
            --真实伤害(无视护盾，无视卸力)
            local trueDamage = self:calTrueDamage(role,zhao)

            qiAtk = qiAtk + trueDamage
            zhao.trueDamage = trueDamage

            --防止出现气血高于当前气血上限 add by LvBin 2018/11/09 11:31:30
            zhao.qiMaxAtk = math.min(zhao.qiMaxAtk,qiAtk)

            local roleIsInDamageToHurt = role:isInDamageToHurt()
            local targetIsInDamageToHurt = target:isInDamageToHurt()

            local targetQiAtk = qiAtk
            local targetIsAlive= true

            if zhao.isCruor then
                targetQiAtk = 0
                -- 目标回血
                local cruorFactor = Helper:getDef(zhao.cruorFactor,0)
                local value = qiAtk * cruorFactor
                LogSystem:log("旧版战斗：","凝血效果值：", cruorFactor, "凝血回血值：", value)
                target:addAttr("qi", value, 0, target:getCurrQiMax())

                if targetQiAtk > 0 then
                    self:updateRoleEffectOnAutoAttack(role, target, targetQiAtk)
                end
            elseif zhao.isFanShang then
                targetQiAtk = 0
                if role:haveShield() then
                    local absorbAtk = self:consumeShield(role, zhao.atk)

                    --记录消耗的护盾值
                    if type(role.absorbAtk) ~= "table" then
                        role.absorbAtk = {}
                    end
                    role.absorbAtk["FanShang"] = absorbAtk

                    qiAtk = Helper:getRange(zhao.atk - Helper:getDef(absorbAtk, 0), 0)
                elseif role:haveZhuanYi() then
                    qiAtk = 0
                    zhao.qiMaxAtk = 0

                    local effectMap = role:getEffectMap()
                    for k, effect in ipairs(effectMap) do
                        if effect:getType() == "偏转" then
                            local arg1 = effect:getArg1()
                            arg1 = arg1 - 1
                            effect:setArg1(arg1)
                            if arg1 <= 0 then
                                self:callEventListener("endEffect", role, effect)
                                self:roleRemoveEffect(role, effect:getId())
                            end
                            zhao.roleHaveZhuanYi = true
                            break
                        end
                    end
                end
                --@desc 反伤扣血
                if roleIsInDamageToHurt == false then
                    role:addAttr("qi", -qiAtk)
                end
                
                self:addRoleDamageToHurtValue(role, qiAtk)
                self:addAppendDamageEffectDamageValue(role, qiAtk)

                if qiAtk > 0 and role._role:getBuffAttr("xingzhenQiXue") ~= 1 then
                    role:setAttr("qiPercent", (role:getFinalAttr("qiMax") * role:getAttr("qiPercent") - zhao.qiMaxAtk) / role:getFinalAttr("qiMax"))-- 扣气血上限 add by TangJian 2016/11/08 21:49:24
                end

                if targetQiAtk > 0 then
                    self:updateRoleEffectOnAutoAttack(role, target, targetQiAtk)
                end
                
                if role:canDie() then
                    self:roleKill(target, role)
                end
            else
                -- add by XiaoZhiWei 2017/07/26 14:17:47 偏转伤害移除
                if zhao.isZhuanYi == true then
                    zhao.qiMaxAtk = 0
                    qiAtk = 0
                    targetQiAtk = 0
                end

                --@desc 打印招式详情
                role:printZhaoInfo(target,qiAtk,zhao.qiMaxAtk)
                -- 目标掉血 add by TangJian 2016/11/16 16:51:30
                if targetIsInDamageToHurt == false then
                    target:addAttr("qi", -targetQiAtk)
                    --伤害转气血效果累计伤害
                    if targetQiAtk > 0 then
                        self:doDamageToQiEffect(target, targetQiAtk)
                    end

                    --自己回血 add by LvBin
                    if role:isSuckBlood() then
                        zhao.isSuckBlood = true
                        local roleEffectMap = role:getEffectMap()
                        for k,effect in ipairs(roleEffectMap) do
                            if effect:getType() == "吸血" then
                                local arg1 ,arg2 = effect:getArg1(), effect:getFinalArg2()
                                zhao.arg1 = arg1
                                zhao.SuckBloodPercen = arg2

                                print("吸血系数 = ",arg2)
                                role:addAttr(arg1, arg2 * qiAtk, 0, role:getCurrQiMax())
                            end
                        end
                    end

                    if role:isFanShi() then
                        local roleEffectMap = role:getEffectMap()
                        for k,effect in ipairs(roleEffectMap) do
                            if effect:getType() == "反噬" then
                                local arg1 ,arg2 = effect:getArg1(), effect:getFinalArg2()
                                if arg1 == "qi" then
                                    if roleIsInDamageToHurt == false then
                                        role:addAttr(arg1,-arg2 * targetQiAtk)
                                        
                                        self:callEventListener("addRolesEffectChangeFunction", function()
                                            self:callEventListener("popText",role, math.floor(-arg2 * targetQiAtk),cc.c4b(255, 255, 255, 255))
                                        return true
                                    end)
                                    end
                                    self:addRoleDamageToHurtValue(role, arg2 * targetQiAtk)
                                    self:addAppendDamageEffectDamageValue(role, arg2 * targetQiAtk)
                                else
                                    role:addAttr(arg1,-arg2 * targetQiAtk)
                                    self:callEventListener("addRolesEffectChangeFunction", function()
                                        self:callEventListener("popText",role, math.floor(-arg2 * targetQiAtk),cc.c4b(255, 255, 255, 255))
                                    return true
                                end)
                                end
                            end
                        end
                    end
                end
                
                if targetQiAtk > 0 and target._role:getBuffAttr("xingzhenQiXue") ~= 1 then
                    target:setAttr("qiPercent", (target:getFinalAttr("qiMax") * target:getAttr("qiPercent") - zhao.qiMaxAtk) / target:getFinalAttr("qiMax"))-- 扣气血上限 add by TangJian 2016/11/08 21:49:24
                end

                if target:canDie() then
                    self:roleKill(role, target)
                    targetIsAlive = false
                end
                
                if targetQiAtk > 0 then
                    self:updateRoleEffectOnAutoAttack(role, target, targetQiAtk)
                end

                if target:canDie() then
                    self:roleKill(role, target)
				else
					self:doDamageReturnEffect(role,target,targetQiAtk)

					target:hpRecoverOnHurt(HurtFactory:create(0,targetQiAtk))

                	if role:canDie() then
                    	self:roleKill(target, role)
					end
                end
            end

            local EffectMapList = {}
            
            if targetIsAlive then
                if SHENBINGSYS then
                    if role._role.teamId == 1 then
                        self:getWeaponEffect(role,target,3)--攻击被对手格挡
                    else
    
                    self:getWeaponEffect(role,target,5)
                    self:getWeaponEffect(target,role,4)--对手攻击被自己格挡
                    end
                end
    
                 --经脉触发的招式不触发拳脚特性
                if zhao.isJingMaiZhao ~= true then
                    self:getFistFootEffect(role,target,3)
                end
    
                self:calWeaponPoison(role,target)
    
                self:doParryTriggerEffect(role,target)
    
                do
                    local effectMap = target:getEffectMap()
                    for k,effect in ipairs(effectMap) do
                        if effect:getType() == "反震" then
                            local arg1 ,arg2 = effect:getArg1(), effect:getFinalArg2()
                            --填0则反弹原值
                            if arg2 == 0 then
                                local fanZhenValue = self:getBeforeEffectAtkInHitResult(zhao.originalAtk, zhao.calculateAtkFactors)
                                arg2 = -fanZhenValue
                            end

                            if arg1 == "qi" then
                                if roleIsInDamageToHurt == false then
                                    role:addAttr(arg1,arg2)
                                end
                                self:addRoleDamageToHurtValue(role, math.abs(arg2))
                                self:addAppendDamageEffectDamageValue(role, math.abs(arg2))
                            else
                                role:addAttr(arg1,arg2)    
                            end

                            LogSystem:log("旧版战斗：","反震伤害值：", arg2)
                            
                            table.insert(EffectMapList, effect)
    
                            if role:canDie() then
                                self:roleKill(target, role)
                            end
                        elseif effect:getType() == "破招" then
                            local arg1 ,arg2 = effect:getArg1(), effect:getFinalArg2()
                            target:addAttr(arg1,arg2,0,target:getFinalAttr("tiliMax"))
                            table.insert(EffectMapList, effect)
                        elseif effect:getType() == "架御" then
                            local arg1 ,arg2 = effect:getArg1(), effect:getFinalArg2()
							--恢复修正
							local huiFuNum = role:getHuiFuRatio(arg1,"架御")
							arg2 = math.floor(arg2 * huiFuNum)
							effect:setPopText(effect:getRoleTopPopDesc(arg1, arg2))

                            target:addAttr(arg1,arg2,0,target:getCurrQiMax())
                            table.insert(EffectMapList, effect)
                        elseif effect:getType() == "架势" then
                            local arg1 ,arg2 = effect:getArg1(), effect:getFinalArg2()
							--恢复修正
							local huiFuNum = role:getHuiFuRatio(arg1,"架势")
							arg2 = math.floor(arg2 * huiFuNum)
							effect:setPopText(effect:getRoleTopPopDesc(arg1, arg2))
							
                            target:addAttr(arg1,arg2,0, target:getAttr("neiliMax")*2)
                            table.insert(EffectMapList, effect)
                        end 
                    end
                end
            end
            
            self:callEventListener("parried", role, target, zhao, EffectMapList, targetQiAtk)
        elseif zhao.hitType == HIT_TYPE_DODGE then
            self:doDodgeTriggerTargetEffect(target, role)
            -- 闪耀 闪烁效果
            local EffectMapList = {}
            do 
                local effectMap = target:getEffectMap()
                for k,effect in ipairs(effectMap) do
                    if target:isFlare() then
                        if effect:getType() == "闪耀" then
                            local arg1 ,arg2 = effect:getArg1(), effect:getFinalArg2()
							--恢复修正
							local huiFuNum = role:getHuiFuRatio(arg1,"闪耀")
							arg2 = math.floor(arg2 * huiFuNum)
							effect:setPopText(effect:getRoleTopPopDesc(arg1, arg2))

                            target:addAttr(arg1,arg2,0,target:getCurrQiMax())
                            table.insert(EffectMapList, effect)
                        end
                    end
                    if target:isGlint() then
                        if effect:getType() == "闪烁" then
                            local arg1 ,arg2 = effect:getArg1(), effect:getFinalArg2()
							--恢复修正
							local huiFuNum = role:getHuiFuRatio(arg1,"闪烁")
							arg2 = math.floor(arg2 * huiFuNum)
							effect:setPopText(effect:getRoleTopPopDesc(arg1, arg2))

                            target:addAttr(arg1,arg2,0, target:getAttr("neiliMax")*2)
                            table.insert(EffectMapList, effect)
                        end
                    end
                end
            end
            self:callEventListener("dodged", role, target, zhao,EffectMapList)
        else
            error()
        end
        
        if self._state ~= FIGHT_STATE_END then
            local canFightEnd, winTeamId = self:fightEndTest()
            if canFightEnd then
                self._state = FIGHT_STATE_END
                self:callEventListener("fightEnd", winTeamId, self._roles)
            end
        end

    end

    -- 刷新角色buff
    self:callEventListener("updateRoleBuff")

    target:refreshRoleEffectText()
end

--@desc: 角色武器淬毒计算
--@author:Liang SongQiang
--@time:2018-01-22 20:25:44
--@role:[src.app.models.fight.FightRole#FightRole]
--@target: [src.app.models.fight.FightRole#FightRole]
function Fight:calWeaponPoison(role, target)
    if not POISONSYS then
        print("毒药系统未开放")
        return 
    end

    local poisonMap = role:getRolePoisons()
    if not poisonMap then
        return
    end
    for _,rolePoison in ipairs(poisonMap) do
        --@desc 如果没有淬毒相关信息，直接返回
        if not rolePoison or MapIsEmpty(rolePoison) then
            return 
        end

        if not rolePoison.canUse then
            return
        end
        
        --@desc 该毒药已经生效过一次，不再生效
        if rolePoison.isTake ~= 0 or rolePoison.isTake == 1 then
            return
        end

        local rate = math.random( 1,100 )
        local k1 = rolePoison.dex
        local k2
        if target:isPlayer() then
            k2 = target._role:getEffectDex()
        else
            k2 = target._role.dex
        end
        local successRate = (math.min(k1/(k2+500)+rolePoison.effect_rate,0.75) + rolePoison.add_rate) * 100
        print(k1,k2,rolePoison.effect_rate,rolePoison.add_rate,successRate,rate)

        local isSuccess = false
        if rate <= successRate then
            print("毒药效果生效")
            isSuccess = true
        end
    
        if not isSuccess then
            return
        end
    
        if role:isPlayer() then
            local zhengqi = role._role:getAttr("zhengqi")
            local range = string.split(rolePoison.xiayi,";")
            local reduceZhengqi = math.random( range[1],range[2] )
            print("随机降低狭义值:",reduceZhengqi)
            role._role:setAttr("zhengqi",tonumber(zhengqi - reduceZhengqi))

            PopText("侠义正气值 -"..reduceZhengqi)
            --@RefType [src.app.models.Poison.PoisonUtil#PoisonUtil]
            local PoisonUtil = require("app.models.Poison.PoisonUtil")
        
            --@desc 减少战斗场次
            PoisonUtil:reducePoisonFightCount(rolePoison.weaponIndex,role._role)
        end
    
        --@desc 标识这场战斗已生效
        rolePoison.isTake = 1
        --@desc 如果对方有抗毒
        if target:isKangDu() then
            return
        end
    
        local effects = rolePoison.effects
        local isShowTag = false
        local isTakeEffect = false --实际是否有效果生效（例如有些控制效果会被免疫）
        for i,effect in ipairs(effects) do
            if effect:getTarget() == "自己" then
                if DEBUG_MODE == 1 then
                    assert(false,"毒药效果目标配置出错，不该对自己产生效果")
                end
            elseif effect:getTarget() == "目标" then
                print("effect id:",effect:getId(),effect.name)
                if self:canAddEffect(target,effect) then
                    effect:setOwner(role)
                    effect:setObject(target)
                    isTakeEffect = true
                    
                    local duration = effect:getFinalDuration()
                    if duration == 0 then
                        local immediateEffectUIInfo = self:roleDoEffect(target,effect)
                        self:callEventListener("addRolesEffectChangeFunction", function()
                            self:callEventListener("doEffect", target, effect, immediateEffectUIInfo)
                            return true
                        end)
                    else

                        local immediateEffectUIInfo = self:roleAddEffect(role, target, effect)
                        self:callEventListener("beginEffect", target, effect, immediateEffectUIInfo)
        
                        PoisonFight:addPoisonEffectToRole(target,effect:getId())
                        isShowTag = true
                    end
                    

                    -- 判断角色死亡 add by TangJian 2017/03/16 16:29:22
                    if target:canDie() then
                        self:roleKill(role, target)
                    end
                end
            end
        end

        if isShowTag then
            local duyaoEffect = Skill:getSkillEffect("DUYAOZHUANPEI")
            duyaoEffect:setArg2(0)
            duyaoEffect:setOwner(role)
            duyaoEffect:setObject(target)
            duyaoEffect:setType("属性增益")
            local immediateEffectUIInfo = self:roleAddEffect(role, target,duyaoEffect)
            self:callEventListener("beginEffect", target, duyaoEffect, immediateEffectUIInfo)
        end

        if isTakeEffect then
            self._eventListenerFM:addFunction(function ()
                local angryText = string.split(rolePoison.angry_text,";")
                local fightText = string.split(rolePoison.fight_text,";")

                local printAngryStr = angryText[math.random( 1,#angryText)]
                local printFightStr = fightText[math.random( 1,#fightText)]

                local item = role._role:getOneItemByKey(rolePoison.weaponItemId)
                
                self:callEventListener("printText",printFightStr, role:getAttr("name"), target:getAttr("name"),item.name)

                self:callEventListener("printText",printAngryStr, role:getAttr("name"), target:getAttr("name"))
                
                --@desc 头顶冒字
                local pop_text = Helper:getDef(PoisonFight:getPopText(),"")
                self:callEventListener("popText",target,pop_text)
                return true
            end)
        end
    end
end

--计算真实伤害
function Fight:calTrueDamage(role,zhao)
    local trueDamage = 0
    if role:isTrueDamage() then
        local effectMap = role:getEffectMap()
        for k, effect in pairs(effectMap) do
            if effect:getType() == "真伤" then
                local arg1 = effect:getArg1()
                trueDamage = math.abs(math.floor(effect:getFinalArg2()))+trueDamage
            end
        end
    end

    local attackSkill = Skill:getSkill(zhao.atkSkId)
    local attackZhao = attackSkill:getAttackZhaoById(zhao.atkZhaoId)
    local tiliConsume = role:getAutoZhaoTiliConsume(attackZhao)
    if zhao.isJingMaiZhao == true then --经脉效果附加的招式不消耗体力
        tiliConsume = 0
    end
    if DEBUG_MODE == 1 then
        print("消耗体力 = ",tiliConsume)
        print("削减前真伤伤害 = ",trueDamage)
    end
    --根据招式消耗的体力削减附加的真伤伤害
    trueDamage = trueDamage * (tiliConsume/100)

    return math.floor(trueDamage)
end

--计算卸力百分比
function Fight:calUnloadForce(role)
    local value = 0
    local effectMap = role:getEffectMap()
    for k, effect in pairs(effectMap) do
        if effect:getType() == "卸力" then
            local arg1 = effect:getArg1()
            value = effect:getFinalArg2()
            break
        end
    end

    return value
end
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/01/15 16:04:11
-- @desc 获取神兵特效效果并添加特效
function Fight:getWeaponEffect(role,target,effectType)
    local weapon = role._role:getEquipByName("weapon")
        --     local owner = self:getOwner()
        -- local object = self:getObject()
    local weapontype = role._role:getCurrWeaponType()
    if weapon ~= nil and weapontype ~= "拳脚" then
        local weaponAttr = role._role:getOneItemByKey(weapon.itemId)
        local effectList ,fighttextList , effctNameList = ShenBingEffct:getRandomEwaponEffectResult(role,weaponAttr,effectType)
        -- print("effectList 个数 = ",#effectList)
        if MapIsEmpty(effectList) == false then
            for k,effect in ipairs(effectList) do                
                if effect:getTarget() == "自己" then
                    if self:canAddEffect(role,effect) then
                        effect:setOwner(role)-- 设置效果释放者
                        effect:setObject(role)
                    
                        local immediateEffectUIInfo = self:roleAddEffect(role, role, effect)
                        --延时到攻击那一刻 
                        self:callEventListener("addRolesEffectChangeFunction", function()
                            self:callEventListener("doEffect", role, effect, immediateEffectUIInfo)
                            return true
                        end)
                        self:callEventListener("beginEffect", role, effect, immediateEffectUIInfo)
                        -- self:callEventListener("popText", effect:getOwner(), effctNameList[k])
                        self:callEventListener("printText",fighttextList[k], role:getAttr("name"), target:getAttr("name"),weaponAttr.name)
                        -- 判断角色死亡 add by TangJian 2017/03/16 16:29:22
                        if role:canDie() then
                            self:roleKill(target, role)
                        end
                    end
                elseif effect:getTarget() == "目标" then
                    -- 对方没武器时，打断兵器系列特效不生效，不输出神兵战斗特性文本
                    if effect:getType() == "打掉兵器" and (target._role:getEquipByName("weapon") == nil or target._role:getCurrTypeByWeapon() == "anqi")  then
                        return
                    end
                    if self:canAddEffect(target,effect) then
                        effect:setOwner(role)-- 设置效果释放者
                        effect:setObject(target)
                        local immediateEffectUIInfo = self:roleAddEffect(role, target, effect)
                        local color = nil
                        local text = effctNameList[k]

                        for _, v in pairs(GetColorList()) do
                            local pos = string.find(text, v.id)
                            if pos and pos >= 0 then
                                if color == nil then
                                    color = v.color
                                end
                                text = string.gsub(text, v.id, "")
                                break
                            end
                        end

                        local duration = effect:getFinalDuration()
                        if duration == 0 then
                            -- self:roleDoEffect(target,effect)
                            self:callEventListener("addRolesEffectChangeFunction", function()
                                self:callEventListener("doEffect", target, effect, immediateEffectUIInfo)
                                return true
                            end)
                        else
                            -- self:roleAddEffect(target, effect)
                            self:callEventListener("beginEffect", target, effect, immediateEffectUIInfo)
                        end
                        self:callEventListener("printText",fighttextList[k], role:getAttr("name"), target:getAttr("name"),weaponAttr.name)
                        self:callEventListener("addRolesEffectChangeFunction", function()
                            self:callEventListener("popTextUP", target,text, color)
                            return true
                        end)

                        -- 判断角色死亡 add by TangJian 2017/03/16 16:29:22
                        if target:canDie() then
                            self:roleKill(role, target)
                        end
                    end
                else
                    error([[function Fight:roleActiveZhao(role, target, activeZhao)]])
                end
            end
        end
    end
end

function Fight:getFistFootEffect(role,target,effectType)
    local weapon = role._role:getEquipByName("weapon")
    local weapontype = role._role:getCurrWeaponType()

    if weapon == nil or weapontype == "拳脚" then
        local FightRoleFistFootEffect = require("src.app.models.fight.FightRoleFistFootEffect")
        local effects = FightRoleFistFootEffect:getFightRandomTriggerEffects(role, effectType)
        if MapIsEmpty(effects) == false then
            for k,effect in ipairs(effects) do
                local effectId = effect:getId()

                if effect:getTarget() == "自己" then
                    if self:canAddEffect(role,effect) then
                        effect:setOwner(role)-- 设置效果释放者
                        effect:setObject(role)

                        role:recordFistFootEffect(effectId)
                        local immediateEffectUIInfo = self:roleAddEffect(role, role, effect)

                        local duration = effect:getFinalDuration()
                        if duration == 0 then
                            self:callEventListener("addRolesEffectChangeFunction", function()
                                self:callEventListener("doEffect", role, effect, immediateEffectUIInfo)
                                return true
                            end)
                        else
                            self:callEventListener("beginEffect", role, effect, immediateEffectUIInfo)
                        end
                    end
                elseif effect:getTarget() == "目标" then
                    if self:canAddEffect(target,effect) then
                        effect:setOwner(role)-- 设置效果释放者
                        effect:setObject(target)

                        target:recordFistFootEffect(effectId)
                        local immediateEffectUIInfo = self:roleAddEffect(role, target, effect)

                        local duration = effect:getFinalDuration()
                        if duration == 0 then
                            self:callEventListener("addRolesEffectChangeFunction", function()
                                self:callEventListener("doEffect", target, effect, immediateEffectUIInfo)
                                return true
                            end)
                        else
                            self:callEventListener("beginEffect", target, effect, immediateEffectUIInfo)
                        end
                    end
                else
                    error([[function Fight:roleActiveZhao(role, target, activeZhao)]])
                end
            end
        end
    end
end

--命中触发效果
function Fight:doHitTriggerEffect(role, target)
    local effectMap = role:getEffectMap()

    for k,effect in ipairs(effectMap) do
        if effect:getType() == "被动命中触发" then
            local effectTarget = effect:getArg1()
            local triggerEffectId = effect:getArg2()
            local zargs = effect:getZArgs()

            local triggerEffect = Skill:getSkillEffect(triggerEffectId):clone()
            triggerEffect:setZArgs(zargs)

            if effectTarget == "目标" then
                triggerEffect:setOwner(role)
                triggerEffect:setObject(target)
                local immediateEffectUIInfo = self:roleAddEffect(role, target, triggerEffect)
                local duration = triggerEffect:getFinalDuration()
                if duration == 0 then
                    self:callEventListener("addRolesEffectChangeFunction", function()
                        self:callEventListener("doEffect", target, triggerEffect, immediateEffectUIInfo)
                        return true
                    end)
                else
                    self:callEventListener("beginEffect", target, triggerEffect, immediateEffectUIInfo)
                end
            elseif effectTarget == "自己" then
                triggerEffect:setOwner(role)
                triggerEffect:setObject(role)
                local immediateEffectUIInfo = self:roleAddEffect(role, role, triggerEffect)
                local duration = triggerEffect:getFinalDuration()
                if duration == 0 then
                    self:callEventListener("addRolesEffectChangeFunction", function()
                        self:callEventListener("doEffect", role, triggerEffect, immediateEffectUIInfo)
                        return true
                    end)
                else
                    self:callEventListener("beginEffect", role, triggerEffect, immediateEffectUIInfo)
                end
            end
        end
    end
end

-- or操作 add by TangJian 2017/03/31 20:45:33
local function operationOr(array, func)
    for i, v in ipairs(array) do
        if func(v) == true then
            return true
        end
    end
    return false
end

-- and操作 add by TangJian 2017/03/31 20:45:34
local function operationAnd(array, func)
    for i, v in ipairs(array) do
        if func(v) ~= true then
            return false
        end
    end
    return true
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/12/24 18:08:41
-- @desc 主动技能
-- 命中系数 = 根据当前的招架武功，获取武功命中系数（hitRate）
-- 命中力 = (武功主动技能等级*150*命中系数/100+1000+0.5*玩家经验^0.5)*(1+等效臂力*0.02)
function Fight:roleActiveZhao(role, target, activeZhao, frameIndex)    
    -- 触发主动技能相关的buff效果 add by TangJian 2017/04/25 03:16:29
    role:executeBuff("使用主动技能", role, target, activeZhao)


    -- 判断是否命中
    local hitType = "dodge"
    
    local hitRate = role:getActiveZhaoHitRate(activeZhao:getId())
    local targetDodge = target:getDodgeRate()
    local targetParry = target:getParryRate()
    
    local percent = frameIndex % 100 + 1
    if percent < math.floor(targetDodge / (targetDodge + hitRate) * 100) then -- 闪避
        hitType = "dodge"
    elseif percent < math.floor((targetDodge + targetParry) / (targetDodge + targetParry + hitRate) * 100) then -- 招架
        hitType = "parry"
    else
        hitType = "hurt"
    end
    
    hitType = "hurt"
    
    -- PopText("hitRate = " .. hitRate)
    local effectArray = activeZhao:getEffectArray()

    local function getAdditionalEffectArray(effect)
        if effect:getType() == "效果关联" then
            local refObject = effect:getArg1()-- 参考对象
            local refEffectId = effect:getArg2()-- 关联效果id
            local outPutEffectId = effect:getArg3()-- 输出的效果id
            
            if refObject == "自己" then
                -- 判断是否能够关联 add by TangJian 2017/03/31 20:45:16
                local andArray = string.split(refEffectId, ";")
                if operationAnd(andArray,
                    function(orString)
                        local orArray = string.split(orString, " or ")
                        return operationOr(orArray,
                            function(effectId)
                                if role:getEffect(effectId) or role:checkHaveEffectType(effectId) or role:checkCorrelationStateBuff(effectId) then
                                    return true
                                end
                            end)
                    end) then

                    local zargs = effect:getZArgs()
                    table.insert(zargs, 1, outPutEffectId)

                    local effectString = luaTableEncode(zargs)
                    print("effectString = ", effectString)
                    return outPutEffectId,effectString, zargs
                end
            
            elseif refObject == "目标" then
                -- 判断是否能够关联 add by TangJian 2017/03/31 20:45:16
                local andArray = string.split(refEffectId, ";")
                if operationAnd(andArray,
                    function(orString)
                        local orArray = string.split(orString, " or ")
                        return operationOr(orArray,
                            function(effectId)
                                if target:getEffect(effectId) or target:checkHaveEffectType(effectId) or target:checkCorrelationStateBuff(effectId) then
                                    return true
                                end
                            end)
                    end) then
                    local zargs = effect:getZArgs()
                    table.insert(zargs, 1, outPutEffectId)
                    
                    local effectString = luaTableEncode(zargs)
                    print("effectString = ", effectString)
                    return outPutEffectId, effectString, zargs
                end
            else
                return false
            end
        elseif effect:getType() == "无指定效果时触发" then
            local refObject = effect:getArg1()-- 判断对象
            local refEffectId = effect:getArg2()-- 判断效果类型orid
            local outPutEffectId = effect:getArg3()-- 成功触发效果id
            local conditions = string.split(refEffectId, " or ")
            local isTrue = true

            if refObject == "自己" then
                LogSystem:log("旧版战斗：无指定效果时触发","效果判断目标:", role:getName())
                for i, v in ipairs(conditions) do
                    if role:getEffect(v) or role:checkHaveEffectType(v) then
                        isTrue = false
                        break
                    end
                end
            elseif refObject == "目标" then
                LogSystem:log("旧版战斗：无指定效果时触发","效果判断目标:", target:getName())
                for i, v in ipairs(conditions) do
                    if target:getEffect(v) or target:checkHaveEffectType(v) then
                        isTrue = false
                        break
                    end
                end
            else
                isTrue = false
            end

            if isTrue == true then
                local zargs = effect:getZArgs()
                table.insert(zargs, 1, outPutEffectId)
                LogSystem:log("旧版战斗：无指定效果时触发","效果触发效果Id:", outPutEffectId)
                local effectString = luaTableEncode(zargs)
                print("effectString = ", effectString)
                return outPutEffectId, effectString, zargs
            else
                return false
            end
        else
            return false
        end
    end

    
    -- 先检测有没有需要附加的效果 add by TangJian 2017/03/31 03:09:14
    do
        local additionalEffectIdArray = nil

        for k, effect in pairs(effectArray) do
            if additionalEffectIdArray == nil then
                additionalEffectIdArray = {}
            end
            local effectId,effectString,effectZargs = getAdditionalEffectArray(effect)
            while effectId do
                local _effect = Skill:getSkillEffect(effectId):clone()
                table.remove(effectZargs, 1)
                _effect:setZArgs(effectZargs)
                local _effectId,_effectString, _effectZargs = getAdditionalEffectArray(_effect) 
                if _effectId == false then
                    table.insert(additionalEffectIdArray,effectString)
                end

                effectId = _effectId
                effectString = _effectString
                effectZargs = _effectZargs
            end
        end
        
        if type(additionalEffectIdArray) == "table" then
            activeZhao:setAdditionalEffectArray(table.concat(additionalEffectIdArray, ";"))
            effectArray = activeZhao:getEffectArray()
        end
    end
    

    local function tableSort(array)
        if MapIsEmpty(array) then
            return
        end
        local xixueNum = 0 --计算吸血数量
        for i, effect in ipairs(array) do
            if effect:getType() == "吸血" then
                xixueNum = xixueNum + 1
            end
        end
        if xixueNum == 1 then
            for i, effect in ipairs(array) do
                if effect:getType() == "吸血" then
                    table.insert( array, 1,table.remove( array,i) )
                end
            end
        end
    end

    -- 调整效果顺序
    tableSort(effectArray)

    activeZhao.isSpecialAnim = role:isSpecialActiveZhaoAnim()
    
    local immediateEffectUIArray = {}

    for k, effect in ipairs(effectArray) do
        if effect:getTarget() == "自己" then
            if self:canAddEffect(role,effect) then
                effect:setOwner(role)-- 设置效果释放者
                effect:setObject(role)
                
                local effectUIInfo = self:roleAddEffect(role, role, effect)
                if MapIsEmpty(effectUIInfo) == false then
                    table.insert(immediateEffectUIArray, effectUIInfo)
                end

                local effectAnim = effect:getEffectAnim()
                if effectAnim then
                    role:addEffectAnim(effectAnim)
                end

                self:callEventListener("beginEffect", role, effect, effectUIInfo)
                
                -- 判断角色死亡 add by TangJian 2017/03/16 16:29:22
                if role:canDie() then
                    self:roleKill(target, role)
                end
            end
        elseif effect:getTarget() == "目标" then
            if self:canAddEffect(target,effect) then
                if hitType == "hurt" then
                    effect:setOwner(role)-- 设置效果释放者
                    effect:setObject(target)

                    local effectUIInfo = self:roleAddEffect(role, target, effect)
                    if MapIsEmpty(effectUIInfo) == false then
                        table.insert(immediateEffectUIArray, effectUIInfo)
                    end
                    
                    local effectAnim = effect:getEffectAnim()
                    if effectAnim then
                        target:addEffectAnim(effectAnim)
                    end
                    
                    self:callEventListener("beginEffect", target, effect, effectUIInfo)
                    
                    -- 判断角色死亡 add by TangJian 2017/03/16 16:29:22
                    if target:canDie() then
                        self:roleKill(role, target)
                    end
                end
            end

        else
            error([[function Fight:roleActiveZhao(role, target, activeZhao)]])
        end
    end

    activeZhao.immediateEffectUIArray = immediateEffectUIArray
    
    self:callEventListener("activeZhao", role, target, activeZhao, hitType)
    self:callEventListener("printText",activeZhao:getHitDesc(),role:getName(), target:getName(), role:getCurrWeaponName(), target:getCurrWeaponName())

    -- 判断游戏结束条件 add by TangJian 2017/03/16 16:30:36
    if self._state ~= FIGHT_STATE_END then
        local canFightEnd, winTeamId = self:fightEndTest()
        if canFightEnd then
            self._state = FIGHT_STATE_END
            self:callEventListener("fightEnd", winTeamId, self._roles)
        end
    end
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/12/26 11:20:51
-- @desc
function Fight:roleDoEffect(role, effect)
    if role == nil or effect == nil then
        return 
    end
    
    effect = effect:clone()

    local immediateEffectUIInfo = FightEffectUI:create(effect:getId())

    -- 气血攻击系数搭配防御系数使用 modify by LvBin 2019/03/14 18:26:08
    if effect:getOwner() and role then
        if effect:getType() == "属性变化" or effect:getType() == "属性增益" then
            --必须是直接伤害
            if effect:getArg1() == "qi" and effect:getFinalArg2() < 0 and effect:getFinalDuration() == 0 then
                if effect:getFinalArg3() == 5 then
                    local finalFactor = self:calAutoDamageFinalFactor(effect:getOwner(),role)

                    local damageAttrModifValueFactor = effect:getOwner():getRole():getDamageAttrModifValueFactor(effect:getActiveZhaoAtkDamageClass(),role:getRole(),self:getRole(role:getTargetId()))

                    effect:setArg2(effect:getFinalArg2() * finalFactor * damageAttrModifValueFactor)

                    effect:getOwner():updateAttrFactorCount("qiAutoAtkFactor")

                    role:updateAttrFactorCount("qiAutoDefFactor")
                elseif effect:getFinalArg3() == 1 then
                    local finalFactor = self:calActiveDamageFinalFactor(effect:getOwner(),role)

                    local damageAttrModifValueFactor = effect:getOwner():getRole():getDamageAttrModifValueFactor(effect:getActiveZhaoAtkDamageClass(),role:getRole(),self:getRole(role:getTargetId()))

                    effect:setArg2(effect:getFinalArg2() * finalFactor * damageAttrModifValueFactor)
                
                    effect:getOwner():updateAttrFactorCount("qiActiveAtkFactor")

                    role:updateAttrFactorCount("qiActiveDefFactor")
                else
                    local finalFactor = self:calActiveDamageFinalFactor(effect:getOwner(),role)

                    effect:setArg2(effect:getFinalArg2() * finalFactor)
                
                    effect:getOwner():updateAttrFactorCount("qiActiveAtkFactor")

                    role:updateAttrFactorCount("qiActiveDefFactor")
                end
            end
        end
    end
    
    local effectType, value = effect:getType(), effect:getValue()
    local arg1, arg2, arg3 = effect:getArg1(), effect:getFinalArg2(), effect:getFinalArg3()
    LogSystem:log("旧版战斗：","----------buff初始数据开始-------------------")
    LogSystem:log("旧版战斗：","效果类型 = ",effectType," |效果Id",effect:getId()," |arg1:", arg1," |arg2:", arg2," |arg3:", arg3)
    switch(effectType,
        {
            ["属性变化"] = function()
                if arg1 == "qi" then
                    if type(role:getFlag("长生诀战斗恢复")) == "table" then
                        local skillLv = role._role:getSkillLv("changshengjueyang") ~= 0 and role._role:getSkillLv("changshengjueyang") or role._role:getSkillLv("changshengjueyin")
                        local tb = role:getFlag("长生诀战斗恢复")
                        arg2 = tonumber(arg2 * (1 + skillLv/2500))
                        tb.value = arg2
                    end

                    if arg2 < 0 and effect:getTarget() == "目标" then
                        if effect:getObject():isCruor() and not effect:checkHaveEffectType(EFFECT_TYPE_POISON) and effect:getFinalDuration() == 0 then
                            local objectEffectMap = role:getEffectMap()
                            local cruorFactor
                            for k,effect in pairs(objectEffectMap) do
                                if effect:getType() == "凝血" then
                                    cruorFactor = effect:getArg1()  --凝血系数
                                    break
                                end
                            end

                            local value = arg2 * cruorFactor

                            local objectUIInfo = {
                                attr = arg1,
                                value = 0,
                                popValue = math.abs(value),
                                popTextColor = cc.c4b(51, 153, 51, 255),
                                popText = nil
                            }

                            immediateEffectUIInfo:addEffectObjectUIInfo(EffectUIInfo:create(objectUIInfo))

                            role:addAttr(arg1, math.abs(value), 0, role:getCurrQiMax())
                            LogSystem:log("旧版战斗：","效果生效者 = ",role:getName()," |效果作用属性类型 = ",arg1," |效果值 = ",math.abs(arg2*cruorFactor)," |效果最大值（实际效果值不能超过最大值） = ",role:getCurrQiMax())

                            return
                        elseif effect:getObject():haveFanShang() and not effect:checkHaveEffectType(EFFECT_TYPE_POISON) and effect:getFinalDuration() == 0 then --反伤(不能反弹毒类伤害，不能反弹持续伤害)
                            if effect:getOwner():isInDamageToHurt() == false then
                                effect:getOwner():addAttr(arg1, arg2, 0, effect:getOwner():getCurrQiMax())
                            end

                            local ownerUIInfo = {
                                attr = arg1,
                                value = arg2,
                                popValue = arg2,
                                popText = nil
                            }

                            local objectUIInfo = {
                                attr = arg1,
                                value = 0,
                                popValue = 0,
                                popText = "反弹"
                            }

                            immediateEffectUIInfo:addEffectObjectUIInfo(EffectUIInfo:create(objectUIInfo))
                            immediateEffectUIInfo:addEffectOwnerUIInfo(EffectUIInfo:create(ownerUIInfo))
                           
                            self:addRoleDamageToHurtValue(effect:getOwner(), math.abs(arg2))
                            self:addAppendDamageEffectDamageValue(effect:getOwner(), math.abs(arg2))
                            LogSystem:log("旧版战斗：","效果释放者 = ",effect:getOwner():getName()," |效果作用属性类型 = ",arg1," |效果值 = ",arg2," |效果最大值（实际效果值不能超过最大值） = ",effect:getOwner():getCurrQiMax())

                            local objectEffectMap = role:getEffectMap()
                            for k,effect in pairs(objectEffectMap) do
                                if effect:getType() == "反伤" then
                                    local arg1 = effect:getArg1()
                                    arg1 = arg1 - 1
                                    effect:setArg1(arg1)
                                    if arg1 <= 0 then
                                        self:callEventListener("endEffect", role, effect)
                                        self:roleRemoveEffect(role, effect:getId())
                                    end              
                                    break
                                end
                            end
                            
                            --判断是否死亡
                            if effect:getOwner():canDie() then
                                self:roleKill(role, effect:getOwner())
                            end

                            return
                        elseif effect:getObject():haveZhuanYi() and effect:checkHaveEffectType(EFFECT_TYPE_POISON) == false and effect:checkHaveEffectType(EFFECT_TYPE_NEGATIVE) == false and effect:getFinalDuration() == 0 then --偏转
                            local objectUIInfo = {
                                attr = arg1,
                                value = 0,
                                popValue = 0,
                                popText = "偏转"
                            }

                            immediateEffectUIInfo:addEffectObjectUIInfo(EffectUIInfo:create(objectUIInfo))

                            arg2 = 0

                            local objectEffectMap = role:getEffectMap()
                            for k,effect in pairs(objectEffectMap) do
                                if effect:getType() == "偏转" then
                                    local arg1 = effect:getArg1()
                                    arg1 = arg1 - 1
                                    effect:setArg1(arg1)
                                    if arg1 <= 0 then
                                        self:callEventListener("endEffect", role, effect)
                                        self:roleRemoveEffect(role, effect:getId())
                                    end                                 
                                    break
                                end
                            end
                        elseif effect:getObject():haveShield() and (effect:getDamageType() ~= True_Damage and effect:checkHaveEffectType(EFFECT_TYPE_POISON) == false and effect:checkHaveEffectType(EFFECT_TYPE_NEGATIVE) == false) and effect:getFinalDuration() == 0 then --护盾        
                            local absorbAtk = self:consumeShield(effect:getObject(),math.abs(arg2))
                            LogSystem:log("旧版战斗：","护盾吸收值：",absorbAtk,"效果类型：",effect:getEffectType())
                            --记录不同效果消耗的护盾值
                            if type(effect:getObject().absorbAtk) ~= "table" then
                                effect:getObject().absorbAtk = {}
                            end
                            effect:getObject().absorbAtk[effect:getId()] = absorbAtk

                            arg2 = math.min(arg2 + absorbAtk,0)

                            if arg2 == 0 then
                                local objectUIInfo = {
                                    attr = arg1,
                                    value = 0,
                                    popValue = 0,
                                    popText = nil
                                }
        
                                immediateEffectUIInfo:addEffectObjectUIInfo(EffectUIInfo:create(objectUIInfo))
                            end
                        elseif role:isDamageMax() then --单次伤害上限
                            arg2 = - math.min(math.abs(arg2),role:calDamageMax())
                        elseif role:isZhenGang() and effect:getDamageType() ~= True_Damage and effect:getFinalDuration() == 0 then --真罡
                            local objectEffectMap = role:getEffectMap()
                            local zhenGangValue = 0 --真罡承受值
                            for k,objectEffect in pairs(objectEffectMap) do
                                if objectEffect:getType() == "真罡" then
                                    zhenGangValue = objectEffect:getFinalArg2()
                                    break
                                end
                            end
                            arg2 = math.min(arg2 + zhenGangValue,0)

                            if arg2 == 0 then
                                local objectUIInfo = {
                                    attr = arg1,
                                    value = 0,
                                    popValue = 0,
                                    popTextColor = effect:getNumberColor(),
                                    popText = nil
                                }
        
                                immediateEffectUIInfo:addEffectObjectUIInfo(EffectUIInfo:create(objectUIInfo))
                            end
                        elseif effect:getFinalDuration() == 0 and role:isSaveDamageByHurt(HurtFactory:create(arg3,arg2)) then
                            local objectUIInfo = {
                                attr = arg1,
                                value = 0,
                                popValue = arg2,
                                popTextColor = effect:getNumberColor(),
                                popText = nil
                            }

                            immediateEffectUIInfo:addEffectObjectUIInfo(EffectUIInfo:create(objectUIInfo))

                            role:addSaveDamageValueByHurt(HurtFactory:create(arg3,arg2))
                            arg2 = 0
                        end

                        --自己回血
                        if effect:getOwner():isSuckBlood() then
                            local OwnerEffectMap = effect:getOwner():getEffectMap()
                            for k,effect in pairs(OwnerEffectMap) do
                                if effect:getType() == "吸血" then
                                    local param1 ,param2 = effect:getArg1(), effect:getFinalArg2()
                                    local value = math.abs(arg2 * param2)

                                    local ownerUIInfo = {
                                        attr = param1,
                                        value = value,
                                        popValue = value,
                                        popTextColor = effect:getNumberColor(),
                                        popText = nil
                                    }

                                    immediateEffectUIInfo:addEffectOwnerUIInfo(EffectUIInfo:create(ownerUIInfo))

                                    effect:getOwner():addAttr(param1,math.abs(value),0,effect:getOwner():getCurrQiMax())
                                    break
                                end
                            end
                        end
                    end

                    --恢复修正
                    if arg2 > 0 then
                        local huiFuNum = role:getHuiFuRatio("qi",effectType)
                        arg2 = math.floor(arg2 * huiFuNum)
                    end

                    if arg2 < 0  then
                        if role:isInDamageToHurt() == false then
                            role:addAttr(arg1, arg2, 0, role:getCurrQiMax())
                            if arg3 then
                                --伤害转气血效果累计伤害
                                self:doDamageToQiEffect(role, -arg2, arg3)
                            end
                        end
                        
                        self:addRoleDamageToHurtValue(role, math.abs(arg2))
                        self:addAppendDamageEffectDamageValue(role, math.abs(arg2))

                        role:addRecordDamage(math.abs(arg2))
                    else
                        role:addAttr(arg1, arg2, 0, role:getCurrQiMax())
                    end

                    if arg2 ~= 0 then
                        local objectUIInfo = {
                            attr = arg1,
                            value = arg2,
                            popValue = arg2,
                            popTextColor = effect:getNumberColor(),
                            popText = nil
                        }

                        immediateEffectUIInfo:addEffectObjectUIInfo(EffectUIInfo:create(objectUIInfo))
                    end

                    LogSystem:log("旧版战斗：","效果释放者 = ",role:getName()," |效果作用属性类型 = ",arg1," |效果值 = ",arg2," |效果最大值（实际效果值不能超过最大值） = ",role:getCurrQiMax())

                    do
                        --反噬(只能反噬直接伤害)
                        if effect:getOwner():isFanShi() and arg2 < 0 and effect:getTarget() == "目标" and effect:getFinalDuration() == 0 then
                            --先判断目标是否死亡
                            if role:canDie() then
                                self:roleKill(effect:getOwner(), role)
                                return
                            end

                            --目标没死，自己被反噬
                            local ownerEffectMap = effect:getOwner():getEffectMap()

                            for k,ownerEffect in pairs(ownerEffectMap) do
                                if ownerEffect:getType() == "反噬" then
                                    local fanshiAttr = ownerEffect:getArg1()
                                    local fanshiFactor = ownerEffect:getFinalArg2() --反噬系数
                                    local value = fanshiFactor * arg2
                                    
                                    if fanshiAttr == "qi" then
                                        if effect:getOwner():isInDamageToHurt() == false then
                                            effect:getOwner():addAttr(fanshiAttr, value)
                                        end
                                        
                                        self:addRoleDamageToHurtValue(role, math.abs(value))
                                        self:addAppendDamageEffectDamageValue(role, math.abs(value))
                                    else
                                        effect:getOwner():addAttr(fanshiAttr, value)
                                    end

                                    local ownerUIInfo = {
                                        attr = fanshiAttr,
                                        value = value,
                                        popValue = value,
                                        popTextColor = cc.c4b(255, 255, 255, 255),
                                        popText = nil
                                    }

                                    immediateEffectUIInfo:addEffectOwnerUIInfo(EffectUIInfo:create(ownerUIInfo))
                                end
                            end
                            
                            --判断技能释放者是否死亡
                            if effect:getOwner():canDie() then
                                self:roleKill(role, effect:getOwner())
                                return
                            end
                        end
                    end

					local targetRole = self:getRole(role:getTargetId())

                    --判断目标是否死亡
                    if role:canDie() then
                        self:roleKill(targetRole, role)
                    else
						if arg2 < 0 and effect:getTarget() == "目标" and effect:getFinalDuration() == 0 then
							self:doDamageReturnEffect(targetRole,role,math.abs(arg2))

							role:hpRecoverOnHurt(HurtFactory:create(effect:getArg3(),math.abs(arg2)))
						end

						if targetRole:canDie() then
                        	self:roleKill(role, targetRole)
						end
                    end
                elseif arg1 == "neili" then
                    --恢复修正
                    if arg2 > 0 then
                        local huiFuNum = role:getHuiFuRatio("neili",effectType)
                        arg2 = math.floor(arg2 * huiFuNum)
                    end

                    local objectUIInfo = {
                        attr = arg1,
                        value = arg2,
                        popValue = arg2,
                        popTextColor = effect:getNumberColor(),
                        popText = nil
                    }

                    immediateEffectUIInfo:addEffectObjectUIInfo(EffectUIInfo:create(objectUIInfo))

                    role:addAttr(arg1,arg2,0, role:getAttr("neiliMax")*2)
                    LogSystem:log("旧版战斗：","效果释放者 = ",role:getName()," |效果作用属性类型 = ",arg1," |效果值 = ",arg2," |效果最大值（实际效果值不能超过最大值） = ",role:getAttr("neiliMax")*2)
                elseif arg1 == "saveDamage" then
                    local objectUIInfo = {
                        attr = arg1,
                        value = arg2,
                        popValue = arg2,
                        popTextColor = effect:getNumberColor(),
                        popText = nil
                    }

                    immediateEffectUIInfo:addEffectObjectUIInfo(EffectUIInfo:create(objectUIInfo))

                    role:addAttr(arg1, arg2, 0, role:getSaveDamageMax())
                    LogSystem:log("旧版战斗：","效果释放者 = ",role:getName()," |效果作用属性类型 = ",arg1," |效果值 = ",arg2)
                elseif arg1 == "shieldCurrentHP" or arg1 == "shieldDeductedHP" then
                    role:addAttr(arg1, arg2, 0)

                    local objectUIInfo = {
                        attr = arg1,
                        value = arg2,
                        popValue = arg2,
                        popTextColor = effect:getNumberColor(),
                        popText = nil
                    }

                    immediateEffectUIInfo:addEffectObjectUIInfo(EffectUIInfo:create(objectUIInfo))
                    LogSystem:log("旧版战斗：","效果释放者 = ",role:getName()," |效果作用属性类型 = ",arg1," |效果值 = ",arg2)
				elseif arg1 == "damageToHurt" then
                    role:addAttr(arg1, arg2, 0, arg3)

                    local objectUIInfo = {
                        attr = arg1,
                        value = arg2,
                        popValue = arg2,
                        popTextColor = effect:getNumberColor(),
                        popText = nil
                    }

                    immediateEffectUIInfo:addEffectObjectUIInfo(EffectUIInfo:create(objectUIInfo))
                    LogSystem:log("旧版战斗：","效果释放者 = ",role:getName()," |效果作用属性类型 = ",arg1," |效果值 = ",arg2," |效果最大值 = ",arg3)
                else
                    role:addAttr(arg1, arg2)

                    local objectUIInfo = {
                        attr = arg1,
                        value = arg2,
                        popValue = arg2,
                        popTextColor = effect:getNumberColor(),
                        popText = nil
                    }

                    immediateEffectUIInfo:addEffectObjectUIInfo(EffectUIInfo:create(objectUIInfo))
                    LogSystem:log("旧版战斗：","效果释放者 = ",role:getName()," |效果作用属性类型 = ",arg1," |效果值 = ",arg2)
                end
            end,
            
            ["属性增益"] = function()
                local addValue = Helper:GetValueFromScript(arg2)
                local minValue, maxValue
                local EffectConst = require("app.models.fight.Effect.EffectConst") 
                if arg1 == "hitRateFactor" then
                    minValue = EffectConst:getConstById("effectFactorhitMin")
                    maxValue = EffectConst:getConstById("effectFactorhitMax")
                elseif arg1 == "dodgeRateFactor" then
                    minValue = EffectConst:getConstById("effectFactordodgeMin")
                    maxValue = EffectConst:getConstById("effectFactordodgeMax")
                elseif arg1 == "parryRateFactor" then
                    minValue = EffectConst:getConstById("effectFactorparryMin")
                    maxValue = EffectConst:getConstById("effectFactorparryMax")
                elseif arg1 == "atkSpeedFactor" then
                    minValue = EffectConst:getConstById("effectFactoratkSpeedMin")
                    maxValue = EffectConst:getConstById("effectFactoratkSpeedMax")
                end

                if minValue and maxValue then
                    local attrValue = role:getAttrEffectBuffAddValue(arg1)

                    if addValue + attrValue < minValue then
                        addValue = minValue - attrValue
                    end

                    if addValue + attrValue > maxValue then
                        addValue = maxValue - attrValue
                    end

                    addValue = Helper:preciseDecimal(addValue, 3)

                    local roleEffect = role:getEffect(effect:getId())
                    roleEffect:setArg2(addValue)
                    role:addAttrEffectBuffAddValue(arg1, addValue)
                else
                    role:addAttr(arg1, addValue)
                end

                LogSystem:log("旧版战斗：","效果释放者 = ",role:getName()," |效果作用属性类型 = ",arg1," |效果值 = ", addValue)
            end,
            
            ["控制"] = function()
            end,
            
            ["护盾"] = function()
            end,
            
            ["打掉兵器"] = function()
            
            end,

            ["招架反击"] = function()

            end,

            ["平衡"] = function()
                local qi = role:getAttr("qi")
                local neili = role:getAttr("neili")
                local currQiMax = role:getCurrQiMax()
                local neiliMax = role:getAttr("neiliMax")

                local qiPercent = qi/currQiMax
                local neiliPercent = neili/(neiliMax*2)
                local averagePercent = (qiPercent + neiliPercent)/2

                local addQi = averagePercent*currQiMax*arg2 - qi
                local addNeiLi = averagePercent*(neiliMax*2)*arg2 - neili

                if DEBUG_MODE == 1 then
                    print("气血百分比 = ",qiPercent)
                    print("内力百分比 = ",neiliPercent)
                    print("平均百分比 = ",averagePercent)
                    print("增加气血值 = ",addQi)
                    print("增加内力值 = ",addNeiLi)
                end
                
                local duration = 0
                if math.floor(addQi) ~= 0 then
                    role:addAttr("qi",addQi,1,currQiMax)
                    LogSystem:log("旧版战斗：","效果释放者 = ",role:getName()," |效果作用属性类型 = qi"," |效果值 = ",addQi," |效果最大值（实际效果值不能超过最大值） = ",currQiMax)
                    local color
                    if addQi > 0 then
                        color = cc.c4b(51, 153, 51, 255)
                    else
                        color = cc.c4b(255, 255, 255, 255)
                    end
                    duration = 1/3
                    self:callEventListener("popText",role,math.floor(addQi),color)
                end
                if math.floor(addNeiLi) ~= 0 then
                    role:addAttr("neili",addNeiLi,0,neiliMax*2)
                    LogSystem:log("旧版战斗：","效果释放者 = ",role:getName()," |效果作用属性类型 = neili"," |效果值 = ",addNeiLi," |效果最大值（实际效果值不能超过最大值） = ",neiliMax*2)
                    
                    self:callEventListener("delayFunc",duration,function()
                        self:callEventListener("popText",role,math.floor(addNeiLi),cc.c4b(28, 76, 163, 255))
                    end)
                end
            end,

            ["伤害转持续自伤"] = function()
                local damageToHurtValue = role:getAttr("damageToHurt")
                local factor = effect:getFinalArg1()
                local value = damageToHurtValue * factor
                LogSystem:log("旧版战斗："," |伤害转持续自伤累计值",damageToHurtValue," |系数 = ",factor,"  |自伤扣血 = ",value)
                role:addAttr("qi", -value, 0, role:getCurrQiMax())
                role:addAttr("damageToHurt", -value)

                self:addAppendDamageEffectDamageValue(role, value)

                --判断目标是否死亡
                if role:canDie() then
                    self:roleKill(self:getRole(role:getTargetId()), role)
                    return
                end
            end,

            ["伤害抗性修正"] = function()
                role:addActiveDamageFactorValue(arg3,arg1,arg2)
            end,
        })
    LogSystem:log("旧版战斗：","----------buff初始数据结束-------------------")

    return immediateEffectUIInfo
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/03/30 23:17:44
-- @desc
-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/03/30 21:35:28
-- @desc 消耗护盾
function Fight:consumeShield(role, damage)
    local effectMap = role:getEffectMap()
    local absorbDamage = damage

    for k, effect in ipairs(effectMap) do
        if effect:getType() == "护盾" then
            local arg1 = effect:getArg1()
            LogSystem:log("旧版战斗：","当前护盾效果值", arg1)
            if damage <= 0 then
                break
            end
            
            if arg1 > damage then
                LogSystem:log("旧版战斗：","护盾吸收值", damage)
                effect:setArg1(arg1 - damage)
                effect:addAbsorbDamage(damage)
                damage = 0
            else
                effect:setArg1(0)
                effect:addAbsorbDamage(arg1)
                damage = damage - arg1
                LogSystem:log("旧版战斗：","护盾吸收值", arg1)
                -- 移除效果
                self:callEventListener("endEffect", role, effect)
                self:roleRemoveEffect(role, effect:getId())
            end

            break
        end
    end

    return absorbDamage - damage
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/12/26 12:21:07
-- @desc
function Fight:roleUndoEffect(role, effect)
    if role == nil or effect == nil then
        return 
    end
    -- print("Fight:roleUndoEffect(role, effect)")
    local type, value = effect:getType(), effect:getValue()
    local arg1, arg2, arg3 = effect:getArg1(), effect:getFinalArg2(), effect:getFinalArg3()
    
    switch(type,
        {
            ["属性变化"] = function()
                role:addAttr(arg1, -Helper:GetValueFromScript(arg2))
            end,
            
            ["属性增益"] = function()
                local attrValue = role:getAttrEffectBuffAddValue(arg1)
                if attrValue ~= 0 then
                    role:addAttrEffectBuffAddValue(arg1, -Helper:GetValueFromScript(arg2))
                else
                    role:addAttr(arg1, -Helper:GetValueFromScript(arg2))
                end
            end,
            
            ["控制"] = function()
            end,
            
            ["护盾"] = function()
            end,

            ["伤害抗性修正"] = function()
                role:addActiveDamageFactorValue(arg3,arg1,-arg2)
            end,
        })
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/12/26 11:19:29
-- @desc 添加效果
function Fight:roleAddEffect(attacker, target, effect)
    if target == nil or effect == nil then
        return 
    end
    effect = effect:clone()

    local immediateEffectUIInfo = {}

    local duration = effect:getFinalDuration()
    local type, value = effect:getType(), effect:getValue()
    local arg1, arg2, arg3 = effect:getArg1(), effect:getFinalArg2(), effect:getFinalArg3()
    LogSystem:log("旧版战斗：主动技能添加","效果id:", effect:getId(), "| 效果类型：",type,"| 目标： ",target:getName(),"|arg1:",arg1,"|arg2:",arg2,"|arg3:",arg3,"|duration:",duration)
    switch(type,
        {
            ["属性变化"] = function()
                if duration == 0 then
                    immediateEffectUIInfo = self:roleDoEffect(target, effect)
                elseif duration > 0 then
                    target:addEffect(effect)
                elseif duration == -30 then
                    target:addEffect(effect)
                else
                    print("属性变化 duration 数值异常，请检查配置是否正常，duration："..duration)
                    print(debug.traceback())
                end
            end,
            
            ["属性增益"] = function()
                if duration == 0 then
                    print("属性增益 duration 数值异常，请检查配置是否正常，duration："..duration)
                    print(debug.traceback())
                else
                    local lastEffect = target:getEffect(effect:getId())
                    if lastEffect then
                        self:roleUndoEffect(target, lastEffect)
                    end
                    target:addEffect(effect)
                    self:roleDoEffect(target, effect)
                end
            end,
            
            ["控制"] = function()
                if duration <= 0 then
                    print("控制 duration 数值异常，请检查配置是否正常，duration："..duration)
                    print(debug.traceback())
                else
                    target:addEffect(effect)
                end
            end,
            
            ["护盾"] = function()
                if duration <= 0 then
                    print("护盾 duration 数值异常，请检查配置是否正常，duration："..duration)
                    print(debug.traceback())
                else
                    local effectMap = target:getEffectMap()
                    for i, targetEffect in ipairs(effectMap) do
                        if targetEffect:getType() == "护盾" then
                            self:callEventListener("endEffect", target, targetEffect)
                            self:roleRemoveEffect(target, targetEffect:getId())
                        end
                    end
                    -- 初始化 add by TangJian 2017/03/31 20:57:04
                    local value = effect:getFinalArg1()
                    LogSystem:log("旧版战斗：","护盾效果值：", value)
                    effect:setArg1(value)
                    
                    target:addEffect(effect)
                end
            end,
            
            ["反伤"] = function()
                if duration <= 0 then
                    print("反伤 duration 数值异常，请检查配置是否正常，duration："..duration)
                    print(debug.traceback())
                else
                    -- 初始化 add by TangJian 2017/03/31 20:57:04
                    effect:setArg1(effect:getFinalArg1())
                    
                    target:addEffect(effect)
                end
            end,
            
            ["偏转"] = function()
                if duration <= 0 then
                    print("偏转 duration 数值异常，请检查配置是否正常，duration："..duration)
                    print(debug.traceback())
                else
                    -- 初始化 add by TangJian 2017/03/31 20:57:04
                    effect:setArg1(effect:getFinalArg1())
                    
                    target:addEffect(effect)
                end
            end,

            ["武器切换"] = function()
                target:setChangeWeaponType(2)
                self:changeWeapon(target)
                -- self:yiwu(target)
                self:callEventListener("changeWeapon", target, true)
            end,

            ["拳脚武器切换"] = function()
                target:setChangeWeaponType(3)
                self:changeWeapon(target)

                self:callEventListener("changeWeapon", target, true)
            end,

            ["效果切换"] = function()
                local mainEffectId = arg1
                local secendEffectId = effect:getArg3()
                local FightConfig = require("app.models.fight.FightConfig")
                if target:getEffect(mainEffectId) and secendEffectId then
                    target:removeEffect(mainEffectId)
                    local secendaryEffect = Skill:getSkillEffect(secendEffectId):clone()
                    secendaryEffect:setActiveZhao(effect:getActiveZhao())
                    secendaryEffect:setOwner(attacker)
                    secendaryEffect:setObject(target)
                    secendaryEffect:setDuration(arg2)
                    self:roleAddEffect(attacker, target, secendaryEffect)
                elseif target:getEffect(secendEffectId) and mainEffectId then
                    target:removeEffect(secendEffectId)
                    local mainEffect = Skill:getSkillEffect(mainEffectId):clone()
                    mainEffect:setActiveZhao(effect:getActiveZhao())
                    mainEffect:setOwner(attacker)
                    mainEffect:setObject(target)
                    mainEffect:setDuration(arg2)
                    self:roleAddEffect(attacker, target, mainEffect)
                elseif mainEffectId then
                    local mainEffect = Skill:getSkillEffect(mainEffectId):clone()
                    mainEffect:setActiveZhao(effect:getActiveZhao())
                    mainEffect:setOwner(attacker)
                    mainEffect:setObject(target)
                    mainEffect:setDuration(arg2)
                    self:roleAddEffect(attacker, target, mainEffect)
                else
                    print("error: 效果切换: mainEffectId, secendEffectId = ", mainEffectId, secendEffectId)
                end
            end,

            ["易伤标记"] = function()
                target:addFragile(arg1, duration, arg2, arg3)
            end,

            ["增伤标记"] = function()
                target:addAugment(arg1, duration, arg2, arg3)
            end,
            
            ["打掉兵器"] = function()
                -- add by TangJian 2017/03/31 22:06:20
                local change = effect:getFinalArg1()
                if target:getRole():getEquipByName("weapon") ~= nil and Helper:percentFunc(change * 100) then
					--记录丢失的兵器的子类型
                    local weaponSubtype = target:getRole():getCurrSubtypeByWeapon()
                    target:setBeforeUnloadWeaponIsSubType(weaponSubtype)

                    target:unloadWeapon()
                    local attacker = self:getRole(target:getTargetId())
                    target:setAutoZhaos(attacker:getId(), target:createAutoZhaos(attacker))

                    self:callEventListener("jiaoxieEffect",target, effect)
                end
            end,
            ["招架反击"] = function()
            
                effect:setArg2(effect:getFinalArg2())
                local attacker = self:getRole(target:getTargetId())
                attacker:addEffect(effect)
        
            end,
            ["净化"] = function()
                local odds = effect:getFinalArg1()
                if Helper:percentFunc(odds * 100) then
                    local effectMap = target:getEffectMap()
                    local removeEffectList = {}
                    for k, effect in ipairs(effectMap) do
                        if effect:checkHaveEffectType(EFFECT_TYPE_NEGATIVE) then
                            table.insert(removeEffectList, effect)                     
                        end
                    end
                    for i, effect in ipairs(removeEffectList) do
                        self:callEventListener("endEffect", target, effect)
                        self:roleRemoveEffect(target, effect:getId())
                    end
                end
            end,
            ["解控"] = function()
                if -arg2 < target:getAttr("qi")  then
                    local effectMap = target:getEffectMap()
                    local removeEffectList = {}
                    for k, effect in ipairs(effectMap) do
                        if effect:checkHaveEffectType(EFFECT_TYPE_CONTROLL) then
                            table.insert(removeEffectList, effect)                     
                        end
                    end
                    for i, effect in ipairs(removeEffectList) do
                        self:callEventListener("endEffect", target, effect)
                        self:roleRemoveEffect(target, effect:getId())
                    end
                    --损血
                    if arg1 == "qi" then
                        if arg2 < 0 then
                            if target:isInDamageToHurt() == false then
                                target:addAttr(arg1, arg2)
                            end
                            
                            self:addRoleDamageToHurtValue(target, math.abs(arg2))
                            self:addAppendDamageEffectDamageValue(target, math.abs(arg2))
							self:doDamageToQiEffect(target, math.abs(arg2))
                        end
                    else
                        target:addAttr(arg1, arg2)
                    end
                else
                    PopText("血量不足!")
                end              
            end,
            ["免疫控制"] = function()
                if duration <= 0 then
                    print("免疫控制 duration 数值异常，请检查配置是否正常，duration："..duration)
                    print(debug.traceback())
                else
                    local odds = effect:getFinalArg1()
                    if Helper:percentFunc(odds * 100) then
                        effect:setArg1(effect:getFinalArg1())
                        target:addEffect(effect)
                    end
                    
                end
            end,
            ["截脉"] = function()
                if duration < 0 then
                    print("截脉 duration 数值异常，请检查配置是否正常，duration："..duration)
                    print(debug.traceback())
                else
                    target:addEffect(effect)

                    local effectMap = target:getEffectMap()
                    local removeEffectList = {}
                    for k, effect in ipairs(effectMap) do
                        if effect:checkHaveEffectType(EFFECT_TYPE_POSITIVE) then
                            table.insert(removeEffectList, effect)                     
                        end
                    end

                    if MapIsEmpty(removeEffectList) == false then
                        for i, effect in ipairs(removeEffectList) do
                            self:callEventListener("endEffect", target, effect)
                            self:roleRemoveEffect(target, effect:getId())
                        end

                        self:callEventListener("printText",effect:getEffectFuncDesc(), effect:getOwner():getAttr("name"), target:getAttr("name"),nil, nil, nil, {})
                    end
                    
                end
            end,
            ["禁锢"] = function()
                if duration <= 0 then
                    print("禁锢 duration 数值异常，请检查配置是否正常，duration："..duration)
                    print(debug.traceback())
                else                 
                    target:addEffect(effect)                   
                end
            end,
            ["抗毒"] = function()
                if duration <= 0 then
                    print("抗毒 duration 数值异常，请检查配置是否正常，duration："..duration)
                    print(debug.traceback())
                else
                    local odds = effect:getFinalArg1()
                    if Helper:percentFunc(odds * 100) then
                        effect:setArg1(effect:getFinalArg1())
                        target:addEffect(effect)
                    end                
                end
            end,
            ["遗忘"] = function()
                if duration <= 0 then
                    print("遗忘 duration 数值异常，请检查配置是否正常，duration："..duration)
                    print(debug.traceback())
                else
                    local odds = effect:getFinalArg1()
                    if Helper:percentFunc(odds * 100) and not target:isForget() and not target:isPartForget() then
                        effect:setArg1(effect:getFinalArg1())                    
                        target:addEffect(effect)

                        local targetId = target:getId()

                        target._prePrepareSkills = {}

						table.mergeToLeft(target._prePrepareSkills,target._role.skillPrepare)

						local forgetType = effect:getArg2()
						local btnType = 2
						if forgetType then	
							target:setPartForgetZhaoMethod(forgetType)

							btnType = 3
							
							local methods = string.split(forgetType,"#")
							
							for _,method in ipairs(methods) do
								if method == "攻击" then
									local attackSkillPrepares = SkillConst:getAttackSkillPrepares()
									for __,prepareIndex in ipairs(attackSkillPrepares) do
										local prepareSkillId = target._role.skillPrepare[prepareIndex]
										if prepareSkillId then
											target._role.skillPrepare[prepareIndex] = nil
										end
									end
								else
									local skillType = SkillConst:getSkillTypeByName(method)
									local prepareSkillId = target._role.skillPrepare[skillType]
									if prepareSkillId then
										target._role.skillPrepare[skillType] = nil
									end
								end
							end

							local activeZhaos = self:getRoleActiveZhaos(targetId)
							if not MapIsEmpty(activeZhaos) then
								for i,v in ipairs(activeZhaos) do
									if not target:isPartForgetCanUseActiveZhao(v.zid) then
										table.remove(activeZhaos,i)
									end
								end
							end
						else
							local activeZhaos = self:getRoleActiveZhaos(targetId)
							activeZhaos = {}
							
							target._role.skillPrepare = {}
						end

                        target._role:updateActiveZhaoStatus()

                        target._currZhaoState = 0
                        target._currZhaoIndex = 0
                        target._currZhaoFrame = 1

                        local attacker = effect:getOwner()
                        target:setAutoZhaos(attacker:getId(), target:createAutoZhaos(attacker))
                        target:setCurrDoubleAttackSkill(nil)
                        target:setCurrDoubleAttackZhao(nil)
                        self:callEventListener("Forget",target,btnType)

                        target:reinitRole()                   
                    end
                end
            end,
            ["闪耀"] = function()
                if duration <= 0 then
                    print("闪耀 duration 数值异常，请检查配置是否正常，duration："..duration)
                    print(debug.traceback())
                else                  
                    target:addEffect(effect)                
                end
            end,
            ["闪烁"] = function()
                if duration <= 0 then
                    print("闪烁 duration 数值异常，请检查配置是否正常，duration："..duration)
                    print(debug.traceback())
                else
                    target:addEffect(effect)                
                end
            end,  
            ["内省"] = function()
                if duration == -30 then
                    target:addEffect(effect)
                elseif duration > 0 then
                    target:addEffect(effect)
                else
                    print("内省 duration 数值异常，请检查配置是否正常，duration："..duration)
                    print(debug.traceback())           
                end
            end,
            ["投掷"] = function()
                local owner = effect:getOwner()
                local ownerWeapon = owner:getRole():getEquipByName("weapon")
                local ownerWeaponType = owner:getRole():getCurrTypeByWeapon()
				local weaponSubtype = owner:getRole():getCurrSubtypeByWeapon()
                if ownerWeapon ~= nil and ownerWeaponType ~= "anqi" and weaponSubtype then
					--记录丢失的兵器的子类型
                    owner:setBeforeUnloadWeaponIsSubType(weaponSubtype)
                    owner:unloadWeapon()
                    owner:setAutoZhaos(target:getId(), owner:createAutoZhaos(target))

                    owner:jingMaiUpdate()

                    owner:addThrowWeapon(ownerWeapon.id)
                else
                    PopText("你没有装备兵器")
                end
            end,    
            ["窃取"] = function()
                local owner = effect:getOwner()
                local targetEffectMap = target:getEffectMap()
                local count = effect:getFinalArg1() --窃取增益效果的数量
                local list = {} --目标的增益效果表
                local select = {}   --窃取的增益效果
                for K,effect in ipairs(targetEffectMap) do
                    if effect:checkHaveEffectType(EFFECT_TYPE_POSITIVE) then
                        table.insert(list,effect)
                    end
                end
                if count >= #list then
                    for i,effect in ipairs(list) do
                        self:callEventListener("endEffect", target, effect)
                        self:roleRemoveEffect(target, effect:getId())

                        self:roleAddEffect(owner, owner, effect)
                    end
                else
                    while #select < count do
                        table.insert(select,table.remove(list,math.random(#list))) --pvp记得调用重写的random接口
                    end

                    for i,effect in ipairs(select) do
                        self:callEventListener("endEffect", target, effect)
                        self:roleRemoveEffect(target, effect:getId())

                        self:roleAddEffect(owner, owner, effect)
                    end
                end
            end,    
            ["凝血"] = function()
                if duration <= 0 then
                    print("凝血 duration 数值异常，请检查配置是否正常，duration："..duration)
                    print(debug.traceback())
                else
                    local value = effect:getFinalArg1()
                    LogSystem:log("旧版战斗：","凝血效果值：", value)      
                    effect:setArg1(value)
                    target:addEffect(effect)                
                end
            end,       
            ["汲取"] = function()
                immediateEffectUIInfo = FightEffectUI:create(effect:getId())

                local roleCurrAttr = target:getAttr(arg1)
                --内力吸收转化率
                local inversionRate = Helper:getDef(arg3, 0)
                if math.abs(arg2) <= roleCurrAttr then
                    effect:getOwner():addAttr(arg1,math.abs(arg2) * inversionRate,0,effect:getOwner():getAttr("neiliMax")*2)
                    target:addAttr(arg1,arg2,0,target:getAttr("neiliMax")*2)
                    
                else
                    --最终汲取值
                    local finalValue = roleCurrAttr

                    effect:getOwner():addAttr(arg1,finalValue * inversionRate,0,effect:getOwner():getAttr("neiliMax")*2)
                    target:addAttr(arg1,-finalValue,0,target:getAttr("neiliMax")*2)
                end

                local objectUIInfo = {
                    attr = arg1,
                    value = math.abs(arg2),
                    popValue = -math.abs(arg2),
                    popTextColor = effect:getNumberColor(),
                    popText = nil
                }

                immediateEffectUIInfo:addEffectObjectUIInfo(EffectUIInfo:create(objectUIInfo))

                local ownerUIInfo = {
                    attr = arg1,
                    value = math.abs(arg2) * inversionRate,
                    popValue = math.abs(arg2) * inversionRate,
                    popTextColor = effect:getNumberColor(),
                    popText = nil
                }

                immediateEffectUIInfo:addEffectOwnerUIInfo(EffectUIInfo:create(ownerUIInfo))
            end,
            ["吸血"] = function()
                if duration <= 0 then
                    print("吸血 duration 数值异常，请检查配置是否正常，duration："..duration)
                    print(debug.traceback())
                else
                    target:addEffect(effect)                
                end
            end,
            ["反震"] = function()
                if duration <= 0 then
                    print("反震 duration 数值异常，请检查配置是否正常，duration："..duration)
                    print(debug.traceback())
                else
                    target:addEffect(effect)                
                end
            end,
            ["内伤"] = function()
                if duration <= 0 then
                    print("内伤 duration 数值异常，请检查配置是否正常，duration："..duration)
                    print(debug.traceback()) 
               else
                    target:addEffect(effect)   
                    local jiaLi =  target._role.jiaLi
                    target:setAttr("jiaLiValue",jiaLi)

                    target._role.jiaLi = target._role.jiaLi * arg2   
                end
            end,
            ["真伤"] = function()
                if duration == -30 then
                    target:addEffect(effect)
                elseif duration > 0 then
                    target:addEffect(effect)  
                else
                    print("真伤 duration 数值异常，请检查配置是否正常，duration："..duration)
                    print(debug.traceback())          
                end
            end,
            ["强招架"] = function()
                if duration <= 0 then
                    print("强招架 duration 数值异常，请检查配置是否正常，duration："..duration)
                    print(debug.traceback())
                else
                    local odds = Helper:getDef(arg2,0)
                    if Helper:percentFunc(odds * 100) then
                        target:addEffect(effect)             
                    end
                end
            end,
            ["卸力"] = function()
                if duration <= 0 then
                    print("卸力 duration 数值异常，请检查配置是否正常，duration："..duration)
                    print(debug.traceback())
                else
                    target:addEffect(effect)             
                end
            end,
            
            ["破招"] = function()
                if duration <= 0 then
                    print("破招 duration 数值异常，请检查配置是否正常，duration："..duration)
                    print(debug.traceback())
                else
                    target:addEffect(effect)                
                end
            end,
            
            ["平衡"] = function()
                if duration == 0 then
                    self:roleDoEffect(target, effect)
                else
                    print("平衡 duration ~= 0!!!!")                
                end
            end,

            ["架势"] = function()
                if duration <= 0 then
                    print("架势 duration 数值异常，请检查配置是否正常，duration："..duration)
                    print(debug.traceback())
                else
                    target:addEffect(effect)                
                end
            end,

            ["架御"] = function()
                if duration <= 0 then
                    print("架御 duration 数值异常，请检查配置是否正常，duration："..duration)
                    print(debug.traceback())
                else
                    target:addEffect(effect)                
                end
            end,

            ["抗增益"] = function()
                if duration <= 0 then
                    print("抗增益 duration 数值异常，请检查配置是否正常，duration："..duration)
                    print(debug.traceback())
                else
                    local odds = effect:getFinalArg1()
                    if Helper:percentFunc(odds * 100) then
                        effect:setArg1(effect:getFinalArg1())
                        target:addEffect(effect)
                    end      
                end
            end,

            ["抗减益"] = function()
                if duration <= 0 then
                    print("抗减益 duration 数值异常，请检查配置是否正常，duration："..duration)
                    print(debug.traceback())
                else
                    local odds = effect:getFinalArg1()
                    if Helper:percentFunc(odds * 100) then
                        effect:setArg1(effect:getFinalArg1())
                        target:addEffect(effect)
                    end                 
                end
            end,

            ["延时生效"] = function()
                if duration <= 0 then
                    print("延时生效 duration 数值异常，请检查配置是否正常，duration："..duration)
                    print(debug.traceback())
                else
                    print("给目标加了一个延时效果")
                    effect:setDelayTime(effect:getFinalDelayTime())

                    target:addEffect(effect)
                end
            end,

            ["恢复修正"] = function()
                if duration <= 0 then
                    print("恢复修正 duration 数值异常，请检查配置是否正常，duration："..duration)
                    print(debug.traceback())
                else
                    target:addEffect(effect)              
                end
            end,
            ["反噬"] = function()
                if duration <= 0 then
                    print("反噬 duration 数值异常，请检查配置是否正常，duration："..duration)
                    print(debug.traceback())
                else
                    target:addEffect(effect)              
                end
            end,
            ["修武"] = function()
                if duration <= 0 then
                    print("修武 duration 数值异常，请检查配置是否正常，duration："..duration)
                    print(debug.traceback())
                else
                    target:addEffect(effect)              
                end
            end,
            ["延宕"] = function()
                if duration ~= 0 then
                     print("延宕 duration ~= 0!!!!")
                else
                    local currActiveZhaoMap = target:getActiveZhaoMap()
                    for k,v in pairs(currActiveZhaoMap) do
                        local activeZhaoState = target:getActiveZhaoState(k)
                        local haveYanDanEffect = false
                        local effectArray = activeZhaoState:getEffectArray()
                        for i, effect in ipairs(effectArray) do
                            if effect:getType() == "延宕" then
                                haveYanDanEffect = true
                            end
                        end
                        
                        local cdLeft = activeZhaoState:getCDLeft()
                        print(activeZhaoState:getName().."效果开始前cd =  ",cdLeft)
                        if cdLeft > 0 and haveYanDanEffect == false then --只对还在cd中的主动技能作用,也不能影响有延宕效果的主动技能
                            local addCd = arg2*30 --cd时间转为帧
                            local finalCdLeft = Helper:getRange(cdLeft + addCd, 0, 120*30)
                            print(activeZhaoState:getName().."的cd冷却时间加"..arg2.."秒")
                            activeZhaoState:setCDLeft(finalCdLeft)
                            print(activeZhaoState:getName().."效果生效后cd = ",finalCdLeft)
                        end
                    end
                end
            end,
            ["真罡"] = function()
                if duration <= 0 then
                    print("真罡 duration 数值异常，请检查配置是否正常，duration："..duration)
                    print(debug.traceback())
                else
                    target:addEffect(effect)              
                end
            end,

            ["指定驱散"] = function()
                local effectList = effect:getArg2()
                local removeEffectList = string.split(effectList, " or ")
                local canRemoveEffectList = {}
                local effectMap = target:getEffectMap()

                LogSystem:log("旧版战斗：指定驱散","生效者 = "..target:getName(),"| arg2：",effectList)
                
                for k, _effect in ipairs(effectMap) do
                    local effectId = _effect:getId()
                    LogSystem:log("旧版战斗：指定驱散","生效者 = "..target:getName(),"| 拥有效果id：",effectId)

                    for __, id in pairs(removeEffectList) do
                        if effectId == id then
                            table.insert(canRemoveEffectList, _effect)
                        end
                    end
                end

                if MapIsEmpty(canRemoveEffectList) then
                    LogSystem:log("旧版战斗：指定驱散","对方不存在对应效果",removeEffectList)
                    return
                end

                for i, _effect in ipairs(canRemoveEffectList) do
                    self:callEventListener("endEffect", target, _effect)
                    self:roleRemoveEffect(target, _effect:getId())
                    LogSystem:log("旧版战斗：指定驱散","生效者 = "..target:getName(),"| 驱散效果Id:", _effect:getId())
                end
            end,

            ["指定延宕"] = function()
                local cd = effect:getFinalArg2()
                local activeZhaoId = effect:getArg3()

                LogSystem:log("旧版战斗：指定延宕","生效者 = "..target:getName(),"| arg2-cd：",cd,"| 指定招式id =:", activeZhaoId)

                local currActiveZhaoMap = target:getActiveZhaoMap()
                for zhaoId,v in pairs(currActiveZhaoMap) do
                    if string.find(zhaoId, activeZhaoId) then
                        local activeZhaoState = target:getActiveZhaoState(zhaoId)

                        local cdLeft = activeZhaoState:getCDLeft()
                        if cdLeft > 0 then
                            LogSystem:log("旧版战斗：指定延宕","生效者 = "..target:getName(),"| 效果名字：",activeZhaoState:getName(),"| 指定延宕效果开始前cd =:", cdLeft)
                            local addCd = cd * 30 --cd时间转为帧
                            local finalCdLeft = Helper:getRange(cdLeft + addCd, 0, 120*30)
                            
                            activeZhaoState:setCDLeft(finalCdLeft)
                            LogSystem:log("旧版战斗：指定延宕","生效者 = "..target:getName(),"| 效果名字：",activeZhaoState:getName(),"| 指定延宕效果生效后cd =:", finalCdLeft)
                        end

                        break
                    end
                end
            end,

            ["被动命中触发"] = function()
                local effectId = effect:getId()
                if target:getEffect(effectId) then
                    return
                end

                target:addEffect(effect)
            end,

            ["受击触发"] = function()
                local effectId = effect:getId()
                if target:getEffect(effectId) then
                    return
                end

                target:addEffect(effect)
            end,

            ["标记触发"] = function()
                local effectId = effect:getId()
               
                local roleEffect = target:getEffect(effectId)
                if roleEffect then
                     -- 策划资源设定为默认不配置，辅助计数
                    local addCount = roleEffect:getArg3()
                    
                    local count = roleEffect:getFinalArg2()
                    count = count - 1

                    addCount = addCount + 1

                    local zargs = effect:getZArgs()
                    roleEffect:setZArgs(zargs)
                    roleEffect:setArg2(count)
                    roleEffect:setArg3(addCount)

                    if duration > roleEffect:getFinalDuration() - roleEffect:getValidDuration() then
                        roleEffect:setValidDuration(0)
                    end

                    LogSystem:log("旧版战斗：标记触发","效果id = ", effectId," |当前标记层数 = ", addCount)

                    if count <= 0 then
                        local zargs = roleEffect:getZArgs()
                        self:roleRemoveEffect(target, effectId)
                        local targetEffect = Skill:getSkillEffect(arg1):clone()
                        targetEffect:setOwner(attacker)
                        targetEffect:setObject(target)
                        targetEffect:setZArgs(zargs)

                        local immediateEffectUIInfo = self:roleAddEffect(attacker, target, targetEffect)

                        local duration = targetEffect:getFinalDuration()
                        if duration == 0 then
                            self:callEventListener("addRolesEffectChangeFunction", function()
                                self:callEventListener("doEffect", target, targetEffect, immediateEffectUIInfo)
                                return true
                            end)
                        else
                            self:callEventListener("beginEffect", target, targetEffect, immediateEffectUIInfo)
                        end
                    end
                else
                    local addCount = 1
                    effect:setArg3(addCount)
                    effect:setArg2(arg2 - 1)
                    target:addEffect(effect)

                    if arg2 <= 0 then
                        local zargs = effect:getZArgs()
                        self:roleRemoveEffect(target, effectId)
                        local targetEffect = Skill:getSkillEffect(arg1):clone()
                        targetEffect:setOwner(attacker)
                        targetEffect:setObject(target)
                        targetEffect:setZArgs(zargs)

                        local immediateEffectUIInfo = self:roleAddEffect(attacker, target, targetEffect)

                        local duration = targetEffect:getFinalDuration()
                        if duration == 0 then
                            self:callEventListener("addRolesEffectChangeFunction", function()
                                self:callEventListener("doEffect", target, targetEffect, immediateEffectUIInfo)
                                return true
                            end)
                        else
                            self:callEventListener("beginEffect", target, targetEffect, immediateEffectUIInfo)
                        end
                    end

                    LogSystem:log("旧版战斗：标记触发","效果id = ", effectId," |当前标记层数 = ", addCount)
                end
            end,

            ["致盲"] = function()
                if duration <= 0 then
                    print("致盲 duration 数值异常，请检查配置是否正常，duration："..duration)
                    print(debug.traceback())
                else
                    effect:setArg1(effect:getFinalArg1())
                    target:addEffect(effect)
                end
            end,

            ["招架触发"] = function()
                if duration == -30 then
                    target:addEffect(effect)
                elseif duration > 0 then
                    target:addEffect(effect)
                else
                    print("招架触发 duration 数值异常，请检查配置是否正常，duration："..duration)
                    print(debug.traceback())
                end
            end,

			["招架无效果触发"] = function()
				target:addEffect(effect)
            end,
			

            ["属性条件触发"] = function()
                local isTrigger = effect:getFinalArg1()
                if isTrigger == 1 then
                    local triggerEffectId = effect:getArg2()
                    
                    local effectTarget = effect:getTarget()

                    local triggerEffect = Skill:getSkillEffect(triggerEffectId):clone()

                    local zargs = effect:getZArgs()
                    
                    triggerEffect:setZArgs(zargs)

                    triggerEffect:setActiveZhao(effect:getActiveZhao())

                    if effectTarget == "目标" then
                        if self:canAddEffect(target,triggerEffect) then
                            triggerEffect:setOwner(attacker)
                            triggerEffect:setObject(target)
                            local immediateEffectUIInfo = self:roleAddEffect(attacker, target, triggerEffect)

                            local effectAnim = triggerEffect:getEffectAnim()
                            if effectAnim then
                                target:addEffectAnim(effectAnim)
                            end

                            local duration = triggerEffect:getFinalDuration()
                            if duration == 0 then
                                self:callEventListener("addRolesEffectChangeFunction", function()
                                    self:callEventListener("doEffect", target, triggerEffect, immediateEffectUIInfo)
                                    return true
                                end)
                            else
                                self:callEventListener("beginEffect", target, triggerEffect, immediateEffectUIInfo)
                            end
                        end
                    elseif effectTarget == "自己" then
                        if self:canAddEffect(attacker,triggerEffect) then
                            triggerEffect:setOwner(attacker)
                            triggerEffect:setObject(attacker)
                            local immediateEffectUIInfo = self:roleAddEffect(attacker, attacker, triggerEffect)

                            local effectAnim = triggerEffect:getEffectAnim()
                            if effectAnim then
                                attacker:addEffectAnim(effectAnim)
                            end

                            local duration = triggerEffect:getFinalDuration()
                            if duration == 0 then
                                self:callEventListener("addRolesEffectChangeFunction", function()
                                    self:callEventListener("doEffect", attacker, triggerEffect, immediateEffectUIInfo)
                                    return true
                                end)
                            else
                                self:callEventListener("beginEffect", attacker, triggerEffect, immediateEffectUIInfo)
                            end
                        end
                    end
                else
                    print("属性条件未触发")
                end
            end,

            ["准备武器触发"] = function()
                local function isTrigger()
                    local conTarget = effect:getArg1()
    
                    local weaponSubtype

                    if conTarget == "自己" then
                        weaponSubtype = attacker:getRole():getCurrSubtypeByWeapon()
                    else
                        weaponSubtype = target:getRole():getCurrSubtypeByWeapon()
                    end

                    local conWeaponSubtypeStr = effect:getArg2()

                    local conWeaponSubtypeList = string.split(conWeaponSubtypeStr,"#")

                    for i,subType in ipairs(conWeaponSubtypeList) do
                        if subType == weaponSubtype then
                            return true
                        end
                    end

                    return false
                end
                
                if isTrigger() == true then
                    local triggerEffectId = effect:getArg3()
                    
                    local effectTarget = effect:getTarget()

                    local triggerEffect = Skill:getSkillEffect(triggerEffectId):clone()

                    local zargs = effect:getZArgs()
                    
                    triggerEffect:setZArgs(zargs)

                    if effectTarget == "目标" then
                        triggerEffect:setOwner(attacker)
                        triggerEffect:setObject(target)
                        local immediateEffectUIInfo = self:roleAddEffect(attacker, target, triggerEffect)

                        local duration = triggerEffect:getFinalDuration()
                        if duration == 0 then
                            self:callEventListener("addRolesEffectChangeFunction", function()
                                self:callEventListener("doEffect", target, triggerEffect, immediateEffectUIInfo)
                                return true
                            end)
                        else
                            self:callEventListener("beginEffect", target, triggerEffect, immediateEffectUIInfo)
                        end
                    elseif effectTarget == "自己" then
                        triggerEffect:setOwner(attacker)
                        triggerEffect:setObject(attacker)
                        local immediateEffectUIInfo = self:roleAddEffect(attacker, attacker, triggerEffect)

                        local duration = triggerEffect:getFinalDuration()
                        if duration == 0 then
                            self:callEventListener("addRolesEffectChangeFunction", function()
                                self:callEventListener("doEffect", attacker, triggerEffect, immediateEffectUIInfo)
                                return true
                            end)
                        else
                            self:callEventListener("beginEffect", attacker, triggerEffect, immediateEffectUIInfo)
                        end
                    end
                end
            end,

            ["储伤"] = function()
                target:addEffect(effect)
            end,

            ["储伤失效"] = function()
                target:addEffect(effect)
            end,

            ["监控角色属性"] = function()
                target:addEffect(effect)
            end,

            ["角色立即死亡"] = function()
                if target:isAlive() then
                    self:roleKill(self:getRole(target:getTargetId()), target)

                    target:setAttr("qi",0)

                    target:addEffect(effect)
                end
            end,

            ["伤害转气血"] = function()
                local targetEffects = target:getEffectMap()
                --移除现有类型效果
                for i = #targetEffects, 1, -1 do
                    local _effect = targetEffects[i]
                    if _effect:getType() == "伤害转气血" then
                        self:roleRemoveEffect(target, _effect:getId())
                    end
                end

                target:addEffect(effect)
            end,
            ["可取回缴械"] = function()
                local isOk,msg = target:reversibleDisarmWeapon()

                if isOk then
                    target:addEffect(effect)
                else
                    PopText(msg)
                end
            end,

            ["类型驱散"] = function()
                local removeEffectTypes = string.split(effect:getArg1(), "#")

                local canRemoveEffectList = {}
                local effectMap = target:getEffectMap()

                LogSystem:log("旧版战斗：类型驱散","生效者 = "..target:getName(),"| arg1：",removeEffectTypes)
                
                for k, _effect in ipairs(effectMap) do
                    for __, _effectType in ipairs(removeEffectTypes) do
                        if _effect:checkHaveEffectType(_effectType) then
                            table.insert(canRemoveEffectList, _effect)
                        end
                    end
                end

                if MapIsEmpty(canRemoveEffectList) then
                    LogSystem:log("旧版战斗：类型驱散","不存在对应效果类型",removeEffectTypes)
                    return
                end

                for i, _effect in ipairs(canRemoveEffectList) do
                    self:callEventListener("endEffect", target, _effect)
                    self:roleRemoveEffect(target, _effect:getId())
                    LogSystem:log("旧版战斗：类型驱散","生效者 = "..target:getName(),"| 驱散效果Id:", _effect:getId())
                end
            end,

            ["类型抵抗"] = function()
                target:addEffect(effect)
            end,

            ["类型转移"] = function()
                local effectTypes = string.split(effect:getArg1(), "#")

                local canRemoveEffectList = {}
                local effectOwner = effect:getOwner()
                local effectMap = target:getEffectMap()

                LogSystem:log("旧版战斗：类型转移","生效者 = "..target:getName(),"| arg1：",effectTypes)
                
                for k, _effect in ipairs(effectMap) do
                    for __, _effectType in ipairs(effectTypes) do
                        if _effect:checkHaveEffectType(_effectType) then
                            table.insert(canRemoveEffectList, _effect)
                        end
                    end
                end

                if MapIsEmpty(canRemoveEffectList) then
                    LogSystem:log("旧版战斗：类型转移","不存在对应效果类型",effectTypes)
                    return
                end

                local effectNum = effect:getFinalArg2()
                local addEffectList = {}
                if effectNum < #canRemoveEffectList then
                    for i = 1, effectNum, 1 do
                        table.insert(addEffectList,table.remove(canRemoveEffectList,math.random(#canRemoveEffectList)))
                    end
                else
                    addEffectList = canRemoveEffectList
                end

                local transferTarget = effect:getArg3()
                local trueTargetName = ""

                for i, _effect in ipairs(addEffectList) do
                    self:callEventListener("endEffect", target, _effect)
                    self:roleRemoveEffect(target, _effect:getId())

                    if transferTarget == "自己" then
                        _effect:setOwner(effectOwner)
                        _effect:setObject(effectOwner)
                        self:roleAddEffect(effectOwner, effectOwner, _effect)
                        trueTargetName = effectOwner:getAttr("name")
                        LogSystem:log("旧版战斗：类型转移","效果转移目标：",transferTarget,"效果转移目标名字：",trueTargetName)
                    elseif transferTarget == "目标" then
                        _effect:setOwner(effectOwner)
                        _effect:setObject(effectOwner:getTarget())
                        self:roleAddEffect(effectOwner, effectOwner:getTarget(), _effect)
                        trueTargetName = effectOwner:getTarget():getAttr("name")
                        LogSystem:log("旧版战斗：类型转移","效果转移目标：",transferTarget,"效果转移目标名字：",trueTargetName)
                    end
                    LogSystem:log("旧版战斗：类型转移","转移效果Id:", _effect:getId())
                end

                self:callEventListener("printText",effect:getEffectFuncDesc(), effectOwner:getAttr("name"), trueTargetName,nil, nil, nil, {})
            end,

            ["闪避触发"] = function()
                target:addEffect(effect)
            end,

            ["伤害转持续自伤"] = function()
				local targetEffects = target:getEffectMap()
                --移除现有类型效果
                for i = #targetEffects, 1, -1 do
                    local _effect = targetEffects[i]
                    if _effect:getType() == "伤害转持续自伤" then
                        self:roleRemoveEffect(target, _effect:getId())
                    end
                end

                target:addEffect(effect)
            end,

            ["追加伤害"] = function()
                local targetEffects = target:getEffectMap()
                --移除现有类型效果
                for i = #targetEffects, 1, -1 do
                    local _effect = targetEffects[i]
                    if _effect:getType() == "追加伤害" then
                        self:roleRemoveEffect(target, _effect:getId())
                    end
                end

                target:addEffect(effect)
            end,
            
            ["无法攻击"] = function()
                target:addEffect(effect)
            end,

            ["属性叠加"] = function()
                if duration == 0 then
                    print("属性叠加 duration 数值异常，请检查配置是否正常，duration："..duration)
                    print(debug.traceback())
                else
                    local lastEffect = target:getEffect(effect:getId())
                    
                    if lastEffect then
                        local currValue = tonumber(lastEffect:getFinalArg2())
                        
                        currValue = Helper:getRange(currValue + tonumber(effect:getFinalArg2()),0,tonumber(effect:getFinalArg3()))

                        if currValue <= 0 then
                            self:callEventListener("endEffect", target, lastEffect)
                            
                            self:roleRemoveEffect(target, lastEffect:getId())
                        else
                            effect:setArg2(currValue)

                            target:addEffect(effect)
                        end

                        LogSystem:log("旧版战斗：属性叠加","属性Id:", arg1, "当前值：",currValue)
                    else
                        local currValue = tonumber(effect:getFinalArg2())

                        currValue = Helper:getRange(currValue,0,tonumber(effect:getFinalArg3()))

                        if currValue <= 0 then
                        else
                            effect:setArg2(currValue)

                            target:addEffect(effect)
                        end

                        LogSystem:log("旧版战斗：属性叠加","属性Id:", arg1, "当前值：",currValue)
                    end

                end
            end,

            ["拳脚经脉增强"] = function()
                target:addEffect(effect)
            end,

            ["无法易武"] = function()
                target:addEffect(effect)
            end,

            ["冷却变化"] = function()
                local typeStr = arg1
                local addCdTime = tonumber(arg2) * 30
                local cdLimit = arg3

                local currActiveZhaoMap = target:getActiveZhaoMap()

                local currActiveZhao = effect:getActiveZhao()
                
                for zhaoId,v in pairs(currActiveZhaoMap) do
                    if effect:getTarget() == "自己" and currActiveZhao and currActiveZhao:getId() == zhaoId then
                        --冷却变化不影响当前主动技能
                    else
                        local activeZhaoState = target:getActiveZhaoState(zhaoId)
    
                        if string.find(arg1, activeZhaoState:getType()) then
                            if cdLimit == "cd" or tonumber(cdLimit) == nil then
                                cdLimit = activeZhaoState:getCD()
                            else
                                cdLimit = tonumber(cdLimit) * 30
                            end
    
                            local cdLeftTime =  Helper:getRange(activeZhaoState:getCDLeft() + addCdTime,0,cdLimit) 
    
                            activeZhaoState:setCDLeft(cdLeftTime)
                        end
                    end
                end
            end,
            ["使用主动技能"] = function()
                target:addEffect(effect)
            end,
            ["单次伤害上限"] = function()
                effect:setArg2(math.floor(effect:getFinalArg2()))

                target:addEffect(effect)
            end,
            ["记录承受伤害"] = function()
                target:addEffect(effect)
            end,
            ["主动碎盾"] = function()
                local effectMap = target:getEffectMap()
                for i, targetEffect in ipairs(effectMap) do
                    if targetEffect:getType() == "护盾" then
                        target:setAttr("shieldCurrentHP", targetEffect:getArg1())
                        target:setAttr("shieldDeductedHP", targetEffect:getAbsorbDamage())
                        
                        self:callEventListener("endEffect", target, targetEffect)
                        self:roleRemoveEffect(target, targetEffect:getId())

                        local triggerId = effect:getArg2()
                        local triggerOwner = attacker
                        local triggerObject = arg1 == "自己" and attacker or target
                        local triggerEffect = Skill:getSkillEffect(triggerId):clone()
                        triggerEffect:setZArgs(effect:getZArgs())
                        triggerEffect:setOwner(triggerOwner)
                        triggerEffect:setObject(triggerObject)
                        triggerEffect:setTarget(arg1)
                        if self:canAddEffect(triggerObject, triggerEffect) then
                            local immediateEffectUIInfo = self:roleAddEffect(triggerOwner, triggerObject, triggerEffect)
                            local duration = triggerEffect:getFinalDuration()
                            if duration == 0 then
                                self:callEventListener(
                                    "addRolesEffectChangeFunction",
                                    function()
                                        self:callEventListener("doEffect", triggerObject, triggerEffect, immediateEffectUIInfo)
                                        return true
                                    end
                                )
                            else
                                self:callEventListener("beginEffect", triggerObject, triggerEffect, immediateEffectUIInfo)
                            end
                        end
                        break
                    end
                end
            end,
            ["指定抵抗"] = function()
                target:addEffect(effect)
            end,
            ["经脉天赋修正"] = function()
                target:addEffect(effect)
            end,
            ["伤害抗性修正"] = function()
                local lastEffect = target:getEffect(effect:getId())
                if lastEffect then
                    self:roleUndoEffect(target, lastEffect)
                end

                effect:setArg2(effect:getFinalArg2())
                target:addEffect(effect)
                self:roleDoEffect(target, effect)
            end,
			["反弹"] = function()
                target:addEffect(effect)
            end,
			["加权随机触发"] = function()
				local randomList = {}
				local groups = string.split(arg1, "|")
				for i,v in ipairs(groups) do
					local groupData = string.split(v, "#") 
					table.insert(randomList,{effectId = groupData[1],weight = tonumber(groupData[2])})
				end

				local zargs = effect:getZArgs()

				local rondomCount = arg2
				
				for i = 1,rondomCount do
					if #randomList < 1 then
						break
					end

					local randomEffectIndex = Helper:RandomByWeight(randomList,"weight")

					local randomEffectId = randomList[randomEffectIndex].effectId

					local triggerEffect = Skill:getSkillEffect(randomEffectId):clone()

                    triggerEffect:setZArgs(zargs)

					self:__triggerEffect(target,target:getTarget(),triggerEffect)

					table.remove(randomList,randomEffectIndex)

					LogSystem:log("旧版战斗：加权随机触发","效果Id:", randomEffectId)
				end
            end,
			["效果判断触发"] = function()
				local effectConditionRole = arg1 == "自己" and target or target:getTarget()

				local predicateSymbol = effect:getArg4() == "有" and true or false

				local triggerResult = effectConditionRole:checkRoleSkillEffectTrigger(effect:getArg2(),predicateSymbol)

				LogSystem:log("旧版战斗：效果判断触发  触发结果:", triggerResult)
				
				if triggerResult then
					local zargs = effect:getZArgs()

					local triggerEffectId = effect:getArg3()

					local triggerEffect = Skill:getSkillEffect(triggerEffectId):clone()

                    triggerEffect:setZArgs(zargs)

					self:__triggerEffect(target,target:getTarget(),triggerEffect)
				end
            end,
			["必中"] = function()
                if duration <= 0 then
                    print("必中 duration 数值异常，请检查配置是否正常，duration："..duration)
                else
                    effect:setArg1(effect:getFinalArg1())
                    target:addEffect(effect)
                end
            end,
			["受伤回血"] = function()
                LogSystem:log("旧版战斗：受伤回血  arg1:", effect:getFinalArg1())
                target:addEffect(effect)
            end,
        })
    
    -- 刷新角色buff
    self:callEventListener("updateRoleBuff")

    target:refreshRoleShadowSpriteEffect()

    target:refreshRoleEffectText()

    return immediateEffectUIInfo
end

-- @desc 判断效果能否生效
-- @return true 能   false 不能
function Fight:canAddEffect(role,effect)
    assert(role,"没有人物信息")
    assert(effect,"没有传效果")
    if Helper:getDef(effect:getFinalTruerate(),100) < math.random(1,100) then
        return false
    end

    if effect:checkHaveEffectType(EFFECT_TYPE_POSITIVE) and role:isKangZengYi() then
        return false
    elseif effect:checkHaveEffectType(EFFECT_TYPE_POISON) and role:isKangDu() then
        return false
    elseif effect:checkHaveEffectType(EFFECT_TYPE_CONTROLL) and role:isimmune() then
        return false
    elseif effect:checkHaveEffectType(EFFECT_TYPE_NEGATIVE) and role:isKangJianYi() then
        return false
    elseif role:isResistType(effect) or role:isResistId(effect) then
        return false
    end
    return true
end

-- @desc 执行延时效果
function Fight:executeDelayEffect(role,target)
    if role == nil or target == nil then
        return 
    end
    if role:isDelayEffect() == false then
        return
    end
    local effectMap = role:getEffectMap()
    for k, effect in ipairs(effectMap) do
        if effect:getType() == "延时生效" then
            local delayTime = effect:getDelayTime()

            if delayTime <= 0 then
                local doEffectId = effect:getArg1()
                local zargs = effect:getZArgs()

                local doEffect = assert(Skill:getSkillEffect(doEffectId):clone(), doEffectId .. "效果不存在，检查资源")
                doEffect:setZArgs(zargs)
                
                if doEffect:getTarget() == "自己" then
                    if self:canAddEffect(role,doEffect) then
                        doEffect:setOwner(role)-- 设置效果释放者
                        doEffect:setObject(role)
                        local immediateEffectUIInfo = self:roleAddEffect(role, role, doEffect)
                        
                        local duration = doEffect:getFinalDuration()
                        if duration == 0 then
                            self:callEventListener("addRolesEffectChangeFunction", function()
                                self:callEventListener("doEffect", role, doEffect, immediateEffectUIInfo)
                                return true
                            end)
                        else
                            self:callEventListener("beginEffect", role, doEffect, immediateEffectUIInfo)
                        end
                        
                        -- 判断角色死亡 add by TangJian 2017/03/16 16:29:22
                        if role:canDie() then
                            self:roleKill(target, role)
                        end
                    end
                elseif doEffect:getTarget() == "目标" then
                    if self:canAddEffect(target,doEffect) then
                        doEffect:setOwner(role)-- 设置效果释放者
                        doEffect:setObject(target)
                        local immediateEffectUIInfo = self:roleAddEffect(role, target, doEffect)

                        local duration = doEffect:getFinalDuration()
                        if duration == 0 then
                            self:callEventListener("addRolesEffectChangeFunction", function()
                                self:callEventListener("doEffect", target, doEffect, immediateEffectUIInfo)
                                return true
                            end)
                        else
                            self:callEventListener("beginEffect", target, doEffect, immediateEffectUIInfo)
                        end
                        
                        -- 判断角色死亡 add by TangJian 2017/03/16 16:29:22
                        if target:canDie() then
                            self:roleKill(role, target)
                        end
                    end
                end

                self:callEventListener("endEffect",role, effect)
                self:roleRemoveEffect(role, effect:getId())
            else
                delayTime = delayTime - 1
                effect:setDelayTime(delayTime)
            end
        end
    end
end

--@desc: 计算被动伤害最终系数
--@author:LvBin
--@time:2024-04-07 12:00:44
--@role:
--@target:
--@hitType: 击中类型
--@return
function Fight:calAutoDamageFinalFactor(role,target, hitType)
    local finalFactor = 1
    if role == nil or target == nil then
        return finalFactor
    end

    hitType = Helper:getDef(hitType,HIT_TYPE_HIT)

    local qiAutoAtkFactor = 0
    local qiAutoDefFactor = 0

    if hitType == HIT_TYPE_HIT then
        qiAutoAtkFactor = role:getAttr("qiAutoAtkFactor")
        qiAutoDefFactor = target:getAttr("qiAutoDefFactor")
    end


    local value = 1 + role:getAttr("qiAtkFactor") - target:getAttr("defRateFactor") + qiAutoAtkFactor - qiAutoDefFactor

    finalFactor = Helper:getRange(value, 0.2, 5)
    
    LogSystem:log("旧版战斗：气血攻击系数 = ",role:getAttr("qiAtkFactor"))
    LogSystem:log("旧版战斗：对方气血防御系数 = ",target:getAttr("defRateFactor"))
    LogSystem:log("旧版战斗：被动气血伤害系数 = ",qiAutoAtkFactor)
    LogSystem:log("旧版战斗：被动气血防御系数 = ",qiAutoDefFactor)
    LogSystem:log("旧版战斗：气血最终伤害系数 = ",finalFactor)

    return finalFactor
end

--@desc: 计算主动伤害最终系数
--@author:LvBin
--@time:2024-04-07 15:23:09
--@role:
--@target:
--@return
function Fight:calActiveDamageFinalFactor(role,target)
    local finalFactor = 1
    if role == nil or target == nil then
        return finalFactor
    end

    local qiActiveAtkFactor = role:getAttr("qiActiveAtkFactor")

    local qiActiveDefFactor = target:getAttr("qiActiveDefFactor")

    local value = 1 + role:getAttr("qiAtkFactor") - target:getAttr("defRateFactor") + qiActiveAtkFactor - qiActiveDefFactor

    finalFactor = Helper:getRange(value, 0.2, 5)
    
    LogSystem:log("旧版战斗：气血攻击系数 = ",role:getAttr("qiAtkFactor"))
    LogSystem:log("旧版战斗：对方气血防御系数 = ",target:getAttr("defRateFactor"))
    LogSystem:log("旧版战斗：主动气血伤害系数 = ",qiActiveAtkFactor)
    LogSystem:log("旧版战斗：主动气血防御系数 = ",qiActiveDefFactor)
    LogSystem:log("旧版战斗：气血最终伤害系数 = ",finalFactor)

    return finalFactor
end
-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/12/26 12:20:06
-- @desc 移除效果
function Fight:roleRemoveEffect(role, effectId)
    print("Fight:roleRemoveEffect(role, effectId)")
    
    local effect = role:getEffect(effectId)

    PoisonFight:removePoisonEffectFromRole(role,effectId)

    if MapIsEmpty(role.__poisonList) then
        local dushuEffect = role:getEffect("DUYAOZHUANPEI")
        if dushuEffect then
            role:removeEffect("DUYAOZHUANPEI")
        end
    end
    
    role:removeEffect(effectId)

    switch(effect:getType(),
        {
            ["属性变化"] = function()
            end,
            
            ["属性增益"] = function()
                self:roleUndoEffect(role, effect)
            end,
            
            ["控制"] = function()
            end,
            
            ["护盾"] = function()
            end,

            ["遗忘"] = function()
                
                role._role.skillPrepare = role._prePrepareSkills 
                role._prePrepareSkills = nil
				role:setPartForgetZhaoMethod(nil)

                if role:isPlayer() then
                    if role._role.isMenKe then
                        Npc:initNpcActiveZhao(role._role)
                    else
                        role._role:updateActiveZhaoStatus()
                    end
                else
                    Npc:initNpcActiveZhao(role._role)
                end

                self:callEventListener("Forget",role,3)
                role:reinitRole()
            end,
            ["内伤"] = function()
                role._role.jiaLi = role:getAttr("jiaLiValue")    
            end,

            ["致盲"] = function()
            end,

            ["伤害转气血"] = function()
                local damage = effect:getEffectExtraValue()
                local qiRate = effect:getFinalArg1()
                local maxDamage = effect:getFinalArg2()

                if damage > maxDamage then
                    damage = maxDamage
                end
				
				local huiFuNum = role:getHuiFuRatio("qi","伤害转气血")
				local huiFuQi = math.floor(damage * qiRate * huiFuNum)
				effect:setPopText(huiFuQi)

                LogSystem:log("旧版战斗：","|伤害转气血效果id:", effect:getId()," 当前累计总伤害：", damage, " |气血恢复系数：",qiRate," |最大伤害值：",maxDamage," 气血回复比例：", huiFuNum," 回复气血：", huiFuQi)

                role:addAttr("qi", huiFuQi)
            end,
            ["可取回缴械"] = function()
                local isOk,msg = role:reversibleDisarmWeaponEnd()

                if isOk then
                else
                    PopText(msg)
                end
            end,

            ["追加伤害"] = function()
                local damage = effect:getEffectExtraValue()
                local qiRate = effect:getFinalArg1()
                local maxDamage = effect:getFinalArg2()

                if damage > maxDamage then
                    damage = maxDamage
                end

                LogSystem:log("旧版战斗：","|追加伤害id:", effect:getId()," 当前累计总伤害：", damage, " |气血伤害系数：",qiRate," |最大伤害值：",maxDamage)

                role:addAttr("qi", -damage * qiRate)
            end,

            ["记录承受伤害"] = function()
                role:setAttr("recordDamage", 0)
            end,

            ["伤害抗性修正"] = function()
                self:roleUndoEffect(role, effect)
            end,
        })
    
       
    -- 刷新角色buff
    self:callEventListener("updateRoleBuff")

    role:refreshRoleShadowSpriteEffect()

    role:refreshRoleEffectText()
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 判断战斗能否结束
function Fight:fightEndTest()
    local canFightEnd = false
    local team1Roles = self:getTeamRoles(1)
    local team2Roles = self:getTeamRoles(2)
    
    local team1AliveRoles = self:getTeamAliveRoles(1)
    local team2AliveRoles = self:getTeamAliveRoles(2)
    
    -- 队伍1人物全部死亡
    if next(team1AliveRoles) == nil then
        return true, 2
    elseif next(team2AliveRoles) == nil then
        return true, 1
    end
    return false
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 战斗结束
function Fight:fightEnd()
    self:callEventListener("fightEnd")
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/04/25 03:25:41
-- @desc 逃跑
function Fight:runaway()
    local role = self._player
    local target = self:getRole(self._player:getTargetId())
    if role and target then
        role:executeBuff("逃跑", role, target)
    end

    self:callEventListener("runaway")
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2018/06/26 21:11:48
-- @params 
-- @desc 获取最大的开场动画播放时间
function Fight:getLargestStartanimTime()
    local role = self:getPlayer()
    local target = self:getRole(role:getTargetId())
    if role and target then
        -- add by XiaoZhiWei 2018/06/26 21:15:04 两个人的开场动画时间,取最大值
        return role:getStartAminNeedTime() > target:getStartAminNeedTime() and role:getStartAminNeedTime() or target:getStartAminNeedTime()
    else
        return 0
    end
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 刷新UI
function Fight:refreshUI()
-- self:callEventListener("refreshUI", self._roles)
end

--释放主动技能时检查能否触发特殊buff
function Fight:cheackCanTriggerSpecialBuff(role,activeZhaoId)
    if role == nil or activeZhaoId == nil then
        return false
    end
    if activeZhaoId == "huifu" then
          --@desc 长生诀600级后的 增益
        do
            local odds = 0
            local skillLv = 0

            if role._role:getSkill("changshengjueyang") or role._role:getSkill("changshengjueyin") then
                skillLv = role._role:getSkillLv("changshengjueyang") ~= 0 and role._role:getSkillLv("changshengjueyang") or role._role:getSkillLv("changshengjueyin")
                odds = math.max((skillLv*3-1400)/16,25)
            end
            
            if odds >= math.random(1,100) then
                return true
            end
        end
    end

    return false
end

--@TODO 2025-09-10 16:45:15 目前这种类似触发效果的流程太多了，后续把其它相同代码替换整合（暂时用于招架触发）
--@desc: 触发效果
--@author:LvBin
--@time:2025-09-10 16:41:48
--@role: 自己（效果触发者）
--@target: 对方
--@triggerEffect: 触发的效果
--@return
function Fight:__triggerEffect(role,target,triggerEffect)
	local triggerEffectTarget = triggerEffect:getTarget()

	local triggerEffectOwner = role

	local triggerEffectObject = triggerEffectTarget == "自己" and role or target

	if self:canAddEffect(triggerEffectObject, triggerEffect) then
		triggerEffect:setOwner(triggerEffectOwner)
		triggerEffect:setObject(triggerEffectObject)
		local immediateEffectUIInfo = self:roleAddEffect(triggerEffectOwner, triggerEffectObject, triggerEffect)

		local duration = triggerEffect:getFinalDuration()
		if duration == 0 then
			self:callEventListener("addRolesEffectChangeFunction", function()
				self:callEventListener("doEffect", triggerEffectObject, triggerEffect, immediateEffectUIInfo)
				return true
			end)
		else
			self:callEventListener("beginEffect", triggerEffectObject, triggerEffect, immediateEffectUIInfo)
		end
	end
end

--@desc: 招架成功触发技能效果
--@author:LvBin
--@time:2025-09-10 16:15:27
--@role: 攻击者
--@target: 招架者
--@return
function Fight:doParryTriggerEffect(role, target)
    local effectMap = target:getEffectMap()

    for k,effect in ipairs(effectMap) do
		local effectType = effect:getType()

		local arg1 = effect:getArg1()

		local arg2 = effect:getArg2()

		local arg3 = effect:getArg3()

		local zargs = effect:getZArgs()
		
		if effectType == "招架触发" then
			local triggerEffect = Skill:getSkillEffect(arg2):clone()
			
			triggerEffect:setZArgs(zargs)

			if arg1 == nil or arg3 == nil then
				self:__triggerEffect(target,role,triggerEffect)
			else
				local effectConditionRole = arg1 == "自己" and target or role
				
				local conArray = string.split(arg3, " or ")

				if effectConditionRole:checkRoleEffectCondition(conArray,true) then
					self:__triggerEffect(target,role,triggerEffect)
				end
			end
			
		elseif effectType == "招架无效果触发" then
			local effectConditionRole = arg1 == "自己" and target or role

			local triggerEffect = Skill:getSkillEffect(arg2):clone()
			
			triggerEffect:setZArgs(zargs)
			
			local conArray = string.split(arg3, " or ")

			if effectConditionRole:checkRoleEffectCondition(conArray,false) then
				self:__triggerEffect(target,role,triggerEffect)
			end
		end
    end
end

--[[
    @desc: 受击触发
    author:LvBin
    time:2023-05-23 17:31:06
    --@role:
	--@target: 
    @return:
]]
function Fight:doHitTriggerTargetEffect(role, target)
    local effectMap = target:getEffectMap()

    for k,effect in ipairs(effectMap) do
        if effect:getType() == "受击触发" then
            local effectTarget = effect:getArg1()
            local triggerEffectId = effect:getArg2()
            local zargs = effect:getZArgs()

            local triggerEffect = Skill:getSkillEffect(triggerEffectId):clone()
            triggerEffect:setZArgs(zargs)

            if effectTarget == "目标" then
                triggerEffect:setOwner(target)
                triggerEffect:setObject(role)
                local immediateEffectUIInfo = self:roleAddEffect(role, role, triggerEffect)
                local duration = triggerEffect:getFinalDuration()
                if duration == 0 then
                    self:callEventListener("addRolesEffectChangeFunction", function()
                        self:callEventListener("doEffect", role, triggerEffect, immediateEffectUIInfo)
                        return true
                    end)
                else
                    self:callEventListener("beginEffect", role, triggerEffect, immediateEffectUIInfo)
                end
            elseif effectTarget == "自己" then
                triggerEffect:setOwner(target)
                triggerEffect:setObject(target)
                local immediateEffectUIInfo = self:roleAddEffect(role, target, triggerEffect)
                local duration = triggerEffect:getFinalDuration()
                if duration == 0 then
                    self:callEventListener("addRolesEffectChangeFunction", function()
                        self:callEventListener("doEffect", target, triggerEffect, immediateEffectUIInfo)
                        return true
                    end)
                else
                    self:callEventListener("beginEffect", target, triggerEffect, immediateEffectUIInfo)
                end
            end
        end
    end
end

--伤害转气血效果（当前仅有一个同类型效果）
function Fight:doDamageToQiEffect(role, damage, type)
    if damage and damage > 0 then
        local effectMap = role:getEffectMap()

        for k, effect in ipairs(effectMap) do
            if effect:getType() == "伤害转气血" then
                if type then
                    local types = string.split(effect:getArg3(), "#")
                    local isTrue = false
                    for i, v in ipairs(types) do
                        if tonumber(v) == tonumber(type) then
                            isTrue = true
                        end
                    end

                    if isTrue == false then
                        break
                    end
                end

                local currDamage = effect:getEffectExtraValue()
                effect:setEffectExtraValue(currDamage + damage)
                LogSystem:log("旧版战斗：","|伤害转气血效果 当前累计总伤害：", currDamage + damage,"   |当次伤害：",damage)
                break
            end
        end
    end
end

--被动招式时闪避触发
--role 闪避者
--target 攻击者
function Fight:doDodgeTriggerTargetEffect(role, target)
    local effectMap = role:getEffectMap()

    for k,effect in ipairs(effectMap) do
        if effect:getType() == "闪避触发" then
            local effectTarget = effect:getArg1()
            local triggerEffectId = effect:getArg2()
            local zargs = effect:getZArgs()

            local triggerEffect = Skill:getSkillEffect(triggerEffectId):clone()
            triggerEffect:setZArgs(zargs)

            if effectTarget == "目标" then
                if self:canAddEffect(target, triggerEffect) then
                    triggerEffect:setOwner(role)
                    triggerEffect:setObject(target)
                    local immediateEffectUIInfo = self:roleAddEffect(role, target, triggerEffect)
                    local duration = triggerEffect:getFinalDuration()
                    if duration == 0 then
                        self:callEventListener("addRolesEffectChangeFunction", function()
                            self:callEventListener("doEffect", target, triggerEffect, immediateEffectUIInfo)
                            return true
                        end)
                    else
                        self:callEventListener("beginEffect", target, triggerEffect, immediateEffectUIInfo)
                    end
                end
            elseif effectTarget == "自己" then
                if self:canAddEffect(role, triggerEffect) then
                    triggerEffect:setOwner(role)
                    triggerEffect:setObject(role)
                    local immediateEffectUIInfo = self:roleAddEffect(role, role, triggerEffect)
                    local duration = triggerEffect:getFinalDuration()
                    if duration == 0 then
                        self:callEventListener("addRolesEffectChangeFunction", function()
                            self:callEventListener("doEffect", role, triggerEffect, immediateEffectUIInfo)
                            return true
                        end)
                    else
                        self:callEventListener("beginEffect", role, triggerEffect, immediateEffectUIInfo)
                    end
                end
            end
        end
    end
end

--伤害转持续自伤累计伤害 value 当前伤害
function Fight:addRoleDamageToHurtValue(role, value)
	value = math.abs(value)
	
    local effectMap = role:getEffectMap()

    for k, effect in ipairs(effectMap) do
        if effect:getType() == "伤害转持续自伤" then
			local maxDamageToHurt = effect:getFinalArg4()
			if role:getAttr("damageToHurt") < maxDamageToHurt then
				local factor = effect:getFinalArg2()
				local value = factor * value
				role:addAttr("damageToHurt", value)
				LogSystem:log("旧版战斗："," |伤害转持续自伤累计值",role:getAttr("damageToHurt")," |当前系数 = ",factor," |当前伤害 = ",value," |最大伤害 = ",maxDamageToHurt)
			else
				role:addAttr("qi", -value)
				LogSystem:log("旧版战斗："," |伤害转持续自伤累计值已达到最大值")
			end
			break
        end
    end
end

--追加伤害效果累计伤害
function Fight:addAppendDamageEffectDamageValue(role, value)
    local effectMap = role:getEffectMap()

    for k, effect in ipairs(effectMap) do
        if effect:getType() == "追加伤害" then
            local damageValue = effect:getEffectExtraValue()
            effect:setEffectExtraValue(damageValue + value)
            LogSystem:log("旧版战斗："," |追加伤害累计值",damageValue," |当前伤害 = ",value)
            break
        end
    end
end

--@desc: 伤害反弹
--@author:LvBin
--@time:2025-11-18 17:03:56
--@role: 攻击者
--@target: 受击者
--@damage: 伤害值
--@return
function Fight:doDamageReturnEffect(role,target,damage)
    if damage > 0 then
        local effectMap = target:getEffectMap()

        for k, effect in ipairs(effectMap) do
            if effect:getType() == "反弹" and effect:getArg1() == "qi" then
                local ratio = effect:getFinalArg2()
				
				local retDamage = math.floor(damage * ratio)

				role:addAttr("qi", -retDamage)

				local immediateEffectUIInfo = FightEffectUI:create(effect:getId())

				local objectUIInfo = 
					{
						attr = effect:getArg1(),
						value = -retDamage,
						popValue = -retDamage,
						popTextColor = cc.c4b(255, 255, 255, 255),
						popText = nil
					}

                immediateEffectUIInfo:addEffectObjectUIInfo(EffectUIInfo:create(objectUIInfo))
				self:callEventListener("addRolesEffectChangeFunction", function()
					self:callEventListener("doEffect", role, effect ,immediateEffectUIInfo)
					return true
				end)

				LogSystem:log("旧版战斗："," |反弹 效果  受到伤害",damage," |反弹系数 = ",ratio," |反弹伤害 = ",retDamage)
            end
        end
    end
end

--@desc: 刷新角色效果剩余次数
--@author:LvBin
--@time:2026-05-14 15:47:37
--@role: 角色
--@effectType: 效果类型
--@return
function Fight:refreshRoleEffectRemaining(role,effectType)
	local effectMap = role:getEffectMap()
	for k, effect in ipairs(effectMap) do
		if effect:getType() == effectType then
			local arg1 = type(effect:getArg1()) == "number" and effect:getArg1() or effect:getFinalArg1()
			arg1 = arg1 - 1
			effect:setArg1(arg1)
			if arg1 <= 0 then
				self:callEventListener("endEffect", role, effect)
				self:roleRemoveEffect(role, effect:getId())
			end
			break
		end
	end
end
-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 回复
-- -- 监控方法调用
-- Decorator:beforeAll(Fight,
-- function(funcName, ...)
--     -- local params = {...}
--     logt("调用 Fight 方法", "funcName = Fight:"..tostring(funcName))
-- end)

local start_time 
local end_time
Decorator:before(Fight,"roleDoEffect",
	function(funcName, _,role,effect)
        start_time = socket.gettime()
        print("开始执行 Fight:roleDoEffect ",role:getName(), effect:getType())
	end)

Decorator:after(Fight,"roleDoEffect",
    function(funcName, _,role,effect)
        end_time = socket.gettime()
        print("结束执行 Fight:roleDoEffect ",role:getName(), effect:getType(),"总耗时：",end_time - start_time)
    end)

return Fight
0000000000000