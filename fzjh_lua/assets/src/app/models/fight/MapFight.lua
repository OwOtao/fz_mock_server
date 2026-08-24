-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/16 16:18:06
-- @desc 以下是局部变量定义
local NEW_VERSION = true -- 新版本开关, 用作新功能的开发测试 add by TangJian 2016/11/16 16:20:13
local INITIAL_TILI = 50 -- 角色战斗的初始体力值 add by TangJian 2016/11/16 16:20:14

local Fight = clone(require("app.models.fight.Fight"))

--@RefType [src.app.models.Poison.FightForPoison.PoisonFight#PoisonFight]
local PoisonFight = require("app.models.Poison.FightForPoison.PoisonFight")

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
-- @desc 创建
function Fight:create()
    local p = clone(Fight)
    p:init() -- 初始化
    return p
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 创建一个本地对战Fight
function Fight:createFight(team1RoleDatas, team2RoleDatas)
    collectgarbage("collect")

    -- logt("team1RoleDatas", team1RoleDatas)
    -- logt("team2RoleDatas", team2RoleDatas)
    --@RefType [src.app.models.fight.Fight#Fight]
    local fight = Fight:create()
    fight:setRandomSeed(math.random(100)) -- add by XiaoZhiWei 2017/07/27 14:48:20 设置一个随机种子
    local leftRoleCount = Helper:getRange(Helper:getDef(#team1RoleDatas, 1), 1, 5)
    local rightRoleCount = Helper:getRange(Helper:getDef(#team2RoleDatas, 1), 1, 5)
    -- print("leftRoleCount", leftRoleCount)
    -- print("rightRoleCount", rightRoleCount)

    -- 添加左边人物
    for i = 1, leftRoleCount do
        local roleData = team1RoleDatas[i]

        roleData.id = "left_" .. tostring(i) .."_".. Helper:getDef(roleData.id, User:getUserId()) .."_".. tostring(math.floor(os.time()))
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

        roleData.id = "right_" .. tostring(i) .."_".. Helper:getDef(roleData.id, User:getUserId()) .."_".. tostring(math.floor(os.time()))
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
            team1Role:setAutoZhaos(team2Role:getId(), team1Role:createAutoZhaos(team2Role))
        end

        -- 随机选择一个敌人
        team1Role:setTargetId(fight:getTeamRandomRole(2):getId())

        if POISONSYS then
            PoisonFight:fightInit(team1Role)
        end
    end
    for team2RoleId, team2Role in pairs(team2Roles) do
        for team1RoleId, team1Role in pairs(team1Roles) do
            team2Role:setAutoZhaos(team1Role:getId(), team2Role:createAutoZhaos(team1Role))
        end
     
        -- 随机选择一个敌人
        team2Role:setTargetId(fight:getTeamRandomRole(1):getId())
     	--@desc 生成NPC主动招式出招规则列表
        if NPC_AI then
            fight:initNpcActiveZhaoRules(team2Role)
        end
	
	if POISONSYS then
            PoisonFight:fightInit(team2Role)
        end
    end

    return fight
end

return Fight
000000000000000