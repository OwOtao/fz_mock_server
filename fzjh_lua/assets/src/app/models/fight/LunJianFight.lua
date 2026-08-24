local AUTO_ZHAO_TIMES_DAMAGE_FACTOR_ARRAY = {100 / 100, 42 / 100, 53 / 100, 40 / 100, 40 / 100, 40 / 100, 40 / 100, 40 / 100, 40 / 100}-- 被动招式伤害系数数组

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/16 16:18:06
-- @desc 以下是局部变量定义
local NEW_VERSION = true -- 新版本开关, 用作新功能的开发测试 add by TangJian 2016/11/16 16:20:13
local INITIAL_TILI = 0 -- 角色战斗的初始体力值 add by TangJian 2016/11/16 16:20:14

local Fight = clone(require("app.models.fight.Fight"))

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
    p:init()-- 初始化
    return p
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
    local leftRoleCount = Helper:getRange(Helper:getDef(#team1RoleDatas, 1), 1, 5)
    local rightRoleCount = Helper:getRange(Helper:getDef(#team2RoleDatas, 1), 1, 5)
    -- print("leftRoleCount", leftRoleCount)
    -- print("rightRoleCount", rightRoleCount)
    -- 添加左边人物
    for i = 1, leftRoleCount do
        local roleData = team1RoleDatas[i]
        
        roleData.id = "npc_" .. Helper:getDef(id, User:getUserId()) .. tostring(math.random(1, 1000)) .. tostring(math.floor(os.time()))
        roleData.fightId = "left" .. i
        roleData.teamId = 1
        roleData.inTeamId = i -- 在队伍中的编号

        -- 论剑战斗中 经脉印记不生效
        -- roleData._roleBuff = {}
        --@desc 论剑数据，下发的旧存档可能存在该属性
        roleData.meridianImprinting = nil
        roleData.m_meridianImprintings = nil
        roleData.isInLunJian=true
        fight:addRole(roleData.id, roleData)
        local role = fight:getRole(roleData.id)
        role:setFightId(roleData.fightId)
        
        -- 设置任务初始体力值, 并且需要等待体力回复 add by TangJian 2016/11/16 16:15:12
        role:setAttr("tili", INITIAL_TILI)
        role:setWaitingTili(true)

        -- 以逸待劳 处理
        if role:getFlag("以逸待劳") == true then
            role:setIsNeedNeili(false)
        end
    end
    
    -- 添加右边人物
    for i = 1, rightRoleCount do
        local roleData = team2RoleDatas[i]
        
        roleData.id = "npc_" .. Helper:getDef(id, User:getUserId()) .. tostring(math.random(1, 1000)) .. tostring(math.floor(os.time()))
        roleData.fightId = "right" .. i
        roleData.teamId = 2
        roleData.inTeamId = i -- 在队伍中的编号
        roleData.isInLunJian = true
        fight:addRole(roleData.id, roleData)
        local role = fight:getRole(roleData.id)
        role:setFightId(roleData.fightId)
        
        -- 设置任务初始体力值, 并且需要等待体力回复 add by TangJian 2016/11/16 16:15:12
        role:setAttr("tili", INITIAL_TILI)
        role:setWaitingTili(true)
        
        -- 以逸待劳 处理
        if role:getFlag("以逸待劳") == true then
            role:setIsNeedNeili(false)
        end
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
    end
    for team2RoleId, team2Role in pairs(team2Roles) do
        for team1RoleId, team1Role in pairs(team1Roles) do
            team2Role:setAutoZhaos(team1Role:getId(), team2Role:createAutoZhaos(team1Role))
        end
        
        -- 随机选择一个敌人
        team2Role:setTargetId(fight:getTeamRandomRole(1):getId())
    end
    return fight
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/05 17:25:50
-- @desc 角色攻击数值计算
function Fight:roleAttack(role, target, zhao)
    local attackSkill = Skill:getSkill(zhao.atkSkId)
    local attackZhao = attackSkill:getAttackZhaoById(zhao.atkZhaoId)
    role:setCurrAttackSkill(attackSkill)
    role:setCurrAttackZhao(attackZhao)
    
    print("roleAttack attackZhao = ", attackZhao)
    

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
    
    -- 如果这个属性被修改了, 则需要重新计算招式结果 add by TangJian 2017/01/03 16:52:53
    if role:getAttr("hitRateFactor") ~= 1 or target:getAttr("dodgeRateFactor") ~= 1 or target:getAttr("parryRateFactor") ~= 1 then
        zhao.hitType, zhao.atk, zhao.qiMaxAtk, zhao.neiliConsume, zhao.hitPosName = role:createAttackResult(role, target, attackSkill, attackZhao, doubleAttackSkill, doubleAttackZhao, zhao.mn1, zhao.mn2)
    end
    
    -- 如果修改了攻击力
    if role:getAttr("qiAtkFactor") ~= 1 or role:getAttr("qiMaxAtkFactor") ~= 1 then
        zhao.atk = zhao.atk * role:getAttr("qiAtkFactor")
        zhao.qiMaxAtk = zhao.qiMaxAtk * role:getAttr("qiMaxAtkFactor")
    end
    
    -- 招式伤害递减
    zhao.atk = zhao.atk * Helper:getDef(AUTO_ZHAO_TIMES_DAMAGE_FACTOR_ARRAY[role._currAutoZhaoTimes], 0.4)
    zhao.qiMaxAtk = zhao.qiMaxAtk * Helper:getDef(AUTO_ZHAO_TIMES_DAMAGE_FACTOR_ARRAY[role._currAutoZhaoTimes], 0.4)
        
    if zhao.hitType == HIT_TYPE_PARRY then
        if target:canParry() == false then
            zhao.hitType = HIT_TYPE_HIT
        end
    elseif zhao.hitType == HIT_TYPE_DODGE then
        if target:canDodge() == false then
            zhao.hitType = HIT_TYPE_HIT
        end
    end
    
    -- Fight:doAutoZhao 方法 已做内力消耗处理
    -- -- 加力消耗内力 add by TangJian 2016/11/16 16:51:31
    -- do
    --     if role:isNeedNeili() then
    --         local neiliConsume = zhao.neiliConsume
    --         print("neiliConsume = ", neiliConsume)
    --         if role:getAttr("neili") - neiliConsume < 0 then
    --             neiliConsume = -(role:getAttr("neili") - neiliConsume)
    --         end
    --         role:addAttr("neili", -neiliConsume)
    --     end
    -- end
    
    if zhao.hitType == HIT_TYPE_HIT then
        
        -- 步步高升，攻击力随着出手的次数增加而增加 add by TangJian 2016/11/05 17:25:40
        if role:getFlag("步步高升") == true then
            local attackScaleFactor = Helper:getDef(role:getAttr("attackScaleFactor"), 1)
            if Helper:isNan(attackScaleFactor) then -- 如果是 nan, 则修改为 1 add by TangJian 2016/11/05 17:27:26
                attackScaleFactor = 1
            end
            if type(attackScaleFactor) == "number" then
                attackScaleFactor = attackScaleFactor + 0.05
                PopText("步步高升 伤害提高" .. tostring(math.floor(attackScaleFactor * 100)) .. "%")
            end
            role:setAttr("attackScaleFactor", attackScaleFactor)
            zhao.atk = zhao.atk * attackScaleFactor
        end
        -----------------------------------------------------------------------------------------------------------
        -- @author LiJie
        -- @time 2016/11/16 19:00:47
        -- @desc 让你三招
        if role:getFlag("让你三招") > 0 then
            role:setFlag("让你三招", role:getFlag("让你三招") - 1)
            zhao.atk = 0
            zhao.qiMaxAtk = 0
            PopText("让你三招")
        end
        
        -- 暗中下毒 处理 add by TangJian 2016/11/05 17:12:19
        if role:getFlag("暗中下毒") == true and math.random(1, 100) < 15 then
            role:setFlag("暗中下毒", false)
            zhao.atk = 999999
            PopText("暗中下毒")
        end
        
        -- -- 加力消耗内力 add by TangJian 2016/11/16 16:51:31
        -- do
        --     if role:isNeedNeili() then
        --         local neiliConsume = zhao.neiliConsume
        --         if role:getAttr("neili") - neiliConsume < 0 then
        --             neiliConsume = role:getAttr("neili") - neiliConsume
        --         end
        --         role:addAttr("neili", -neiliConsume)
        --     end
        -- end
        
        -- 扣血
        target:addAttr("qi", -zhao.atk)
        if zhao.atk > 0 then
            target:setAttr("qiPercent", (target:getFinalAttr("qiMax") * target:getAttr("qiPercent") - zhao.qiMaxAtk) / target:getFinalAttr("qiMax"))-- 扣气血上限 add by TangJian 2016/11/08 21:49:24
        end
        self:callEventListener("hit", role, target, zhao)-- 触发攻击事件 add by TangJian 2016/11/07 11:09:31
        
        
        -- 垂死挣扎 处理 add by TangJian 2016/11/05 17:29:05
        do
            print([[target:getFlag("垂死挣扎", false) = ]], target:getFlag("垂死挣扎", false))
            print([[target.getAttr("qi") = ]], target:getAttr("qi"))
            print([[role:getFlag("垂死挣扎阶段", "没开始")]], role:getFlag("垂死挣扎阶段", "没开始"))
            print([[target:getFlag("垂死挣扎阶段", "没开始")]], target:getFlag("垂死挣扎阶段", "没开始"))
            
            -- 被攻击者处理 add by TangJian 2016/11/05 17:50:53
            if target:getFlag("垂死挣扎", false) == true then
                if target:getAttr("qi") <= 0 and target:getFlag("垂死挣扎阶段", "没开始") == "没开始" then
                    target:setFlag("垂死挣扎阶段", "挣扎中")
                    target:setActived(true)-- 考虑到双方都有垂死挣扎的情况, 所以需要恢复自身行动. 如果之后暂停还受更多条件的影响, 则考虑写到 Role:isPause中 add by TangJian 2016/11/05 17:37:55
                    role:setActived(false)-- 暂停攻击者
                    target:setAttr("qi", 1)-- 保证自己不死 add by TangJian 2016/11/05 17:39:05
                    PopText("垂死挣扎")
                end
                if target:getFlag("垂死挣扎阶段")=="挣扎中" then 
                    target:setAttr("qi", 1)
                end
            end
            
            -- 攻击者处理 add by TangJian 2016/11/05 17:56:04
            if role:getFlag("垂死挣扎", false) == true then
                if role:getFlag("垂死挣扎阶段", "没开始") == "挣扎中" then
                    if role:getFlag("垂死挣扎攻击次数", 0) < 3 then
                        role:setFlag("垂死挣扎攻击次数", role:getFlag("垂死挣扎攻击次数") + 1)
                    else
                        role:setFlag("垂死挣扎阶段", "结束")-- 跳到结束阶段 add by TangJian 2016/11/05 17:53:44
                        target:setActived(true)-- 恢复对手的行动
                    end
                elseif role:getFlag("垂死挣扎阶段", "没开始") == "结束" then
                    role:setFlag("垂死挣扎", false)-- 去除标记, 这个感觉没啥意义 add by TangJian 2016/11/05 17:53:27
                end
            end
        end
        
        -- 九转大还 处理 add by TangJian 2016/11/05 17:14:18
        if target:getAttr("qi") <= 0 then
            if target:getRole():getFlag("九转大还") == true then
                target:getRole():setFlag("九转大还", false)
                target:addAttr("qi", target:getFinalAttr("qiMax") * 0.3)
                target:setAttr("qiPercent", 1)
                PopText("RED九转大还!!")
            end
        end
        -- 借尸还魂  -- @author LiJie
        -- if target:getAttr("qi") <= 0 then
        --     if target:getRole():getFlag("借尸还魂") == true then
        --         target:getRole():setFlag("借尸还魂", false)
        --         local qixue = role:getAttr("qi")
        --         ---  自己加血量
        --         target:addAttr("qi", qixue * 0.3)
        --         --对手减少血量
        --         role:addAttr("qi", - qixue * 0.3)
        --         target:setAttr("qiPercent", 1)
        --         PopText("RED借尸还魂，偷取血量")
        --     end
        -- end
        -- role:getCurrQiMax()
        if target:getCurrQiMax() <= 0 then
            print("target:isUndead() = ", target:isUndead())
            print([[target:getFinalAttr("qiPercent") = ]],target:getAttr("qiPercent"))
            if target:isUndead()
            or target:getFlag("饮鸩止渴", false) == true -- 饮鸩止渴 处理 
            then
                target:setAttr("qiPercent",0.01)   --饮鸩止渴修改  血量MAX一直为1
                -- target:setAttr("qi",1)  
            end
        end
        -- 判断死没死
        if target:getAttr("qi") <= 0 then
            print("target:isUndead() = ", target:isUndead())
            print([[target:getFlag("饮鸩止渴") = ]], target:getFlag("饮鸩止渴", false))
            if target:isUndead()
                or target:getFlag("饮鸩止渴", false) == true -- 饮鸩止渴 处理 add by TangJian 2016/11/05 17:11:29
            then
                target:setAttr("qi",1)   --饮鸩止渴修改  血量一直为1
            else
                target:setDead(true)
            end
        -- self:callEventListener("roleDead", target)
        end
    
    elseif zhao.hitType == HIT_TYPE_PARRY then
        self:callEventListener("parried", role, target, zhao, nil, 0)
    elseif zhao.hitType == HIT_TYPE_DODGE then
        self:callEventListener("dodged", role, target, zhao)
    else
        error()
    end
    
    -- 判断是否达到战斗结束条件
    if self._state ~= FIGHT_STATE_END then
        local canFightEnd, winTeamId = self:fightEndTest()
        if canFightEnd then
            self._state = FIGHT_STATE_END
            self:callEventListener("fightEnd", winTeamId, self._roles)
        end
    end
end

-- 重写效果方法
function Fight:playRoleEffect(role, frameIndex)
end

return Fight
000000000