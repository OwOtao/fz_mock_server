-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/16 16:18:06
-- @desc 以下是局部变量定义
local NEW_VERSION = true -- 新版本开关, 用作新功能的开发测试 add by TangJian 2016/11/16 16:20:13
local INITIAL_TILI = 0 -- 角色战斗的初始体力值 add by TangJian 2016/11/16 16:20:14

local AUTO_ZHAO_TAP = "au"
local ACTIVE_ZHAO_TAP = "ac"
local RUNAWAY_TAP = "runaway"

-- 体力的延迟补偿，在体力还没有达到100的时候，如果补偿满了，则一样
local TILI_LATANCY_COMPENSATE = 1

local Fight = inherit({},require("app.models.fight.Fight"))
local PVPRole = require("app.models.pvp1.PVPRole")
local AUTO_ZHAO_TIMES_DAMAGE_FACTOR_ARRAY = {100 / 100, 60 / 100, 40 / 100, 40 / 100, 40 / 100, 40 / 100, 40 / 100, 40 / 100, 40 / 100}-- 被动招式伤害系数数组
local PoisonFight = require("app.models.Poison.FightForPoison.PoisonFight")

local LogSystem = require("app.models.LogSystem.LogSystem")
local HurtFactory = require("app.models.fight.Hurt.HurtFactory")
local FightEffectUI = require("app.models.fight.FightEffectUI")
local EffectUIInfo = require("src.app.models.fight.EffectUIInfo")
local SkillConst = require("app.models.skill.SkillConst")

local Fight = {
    -- 当前帧数
    currentActualFrame = 0, 
    -- 适配单机战斗
    _currFrame = 0,
    -- 角色列表
    fightRoles = {}, 
    -- 是否是静止帧
    isIdleFrame = false,
    -- 数据IO代理
    -- dataProxy:takeData(index) 得到指定位置的数据
    -- dataProxy:addZhao(zhao) 加入一个招到招式中
    -- dataProxy:addChat(msg) 消息
    -- dataProxy:hasAutoZhao(roleId, startIndex, mode)  判断数据中是否有这个角色的自动招式
    dataProxy = {},
    state = "idle",
    _isPVP = true -- 是否是PVP战斗
}

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/07/27 14:43:22
-- @desc 设置随机种子
function Fight:setRandomSeed(t)
    print("setRandomSeed = " .. t)
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

    return f + math.floor(self.currentDataIndex + self:getRandomSeed()) % range
end

-- @desc 随机方法，会重新设置随机种子，用于同一个招式帧随机多次
function Fight:randomAndSetSeed(f, t)
    --重新设置随机种子
    self:setRandomSeed(self:getRandomSeed() + math.floor((f + t)/2) + self.currentDataIndex)

    local randomNum = self:random(f, t)

    return randomNum
end

-- 创建一个1V1的战斗
-- 战斗有如下几个状态：
-- "idle":空闲，在构造之后的状态
-- "init":这个状态一般是表示在构造地图，init完了之后，战斗就可以开始了
-- "start":战斗开始，开始后不在能回到init和idle状态
-- "pause":战斗暂停，区别于stop，暂停还能恢复
-- "stop":这词战斗已经结束，到这里一次战斗的生命周期结束
-- @role1Data 一般是本地的角色
-- @role2Data 对方的角色
-- @firstNo 拿一个先开始，1则为role1先遍历，2则是role2先遍历
-- 在观察或者回放的时候，role1和role2就不存在本地和对方了
function Fight:create(role1Data, role2Data, firstNo)
    -- POISONSYS = false
    NPC_AI = false
    -- SHENBINGSYS = false
    MainControllLayer:pauseUpdate()
    if role1Data == nil then
        print("role1Data = nil")
    end
    if role2Data == nil then
        print("role2Data = nil")
    end

    local p = inherit({},Fight)
    p:init() -- 初始化

    p.localRole = p:addRole(role1Data.id, role1Data)
    
    -- 此时已经初始化招式 如果有悟性buff等，招式等级计算就会出现误差
    -- p.localRole._role:updateRoleBuff()
    
    p.targetRole = p:addRole(role2Data.id, role2Data)
    
    if PVP_POISONSYS then
        PoisonFight:pvpFightInit(p.localRole)
        PoisonFight:pvpFightInit(p.targetRole)
    end
    p.localRole:setWaitingTili(true)
    p.targetRole:setWaitingTili(true)

    p.localRole:setTeamId(1)
    p.targetRole:setTeamId(2)

    -- 设置目标
    p.localRole:setTargetId(p.targetRole:getId())
    p.localRole:setFightId("left1")
    p.targetRole:setTargetId(p.localRole:getId())
    p.targetRole:setFightId("right1")

    p.localRole:setIsPlayer(true)
    p.targetRole:setIsPlayer(false)
    -- 设置角色遍历顺序
    if firstNo == 2 then
        p.traverseRoles = {p.targetRole, p.localRole}
    else
        p.traverseRoles = {p.localRole, p.targetRole}
    end

    p.state = "idle"
    -- 招式列表
    p.currentDataIndex = 0
    -- 当前的帧数
    p.currentFrameCount = 0

    p.currentZhao = nil
    p._player = p.localRole
    return p
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 获得玩家
function Fight:getPlayer()
    return self._player
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/02 17:43:22
-- @desc 开始战斗
function Fight:start()
    self.state = "start"
    self.lastFrameTime = GetLocalTime()
    self.isIdleFrame = true
    self.client = require("app.models.pvp1.PVPClient")
    self.fightLayer:schedule(
        function(ft)
            local currentTime = GetLocalTime()
            local deltaTime = currentTime - self.lastFrameTime
            local shouldRunFrame = math.floor(deltaTime / 0.033333333333)
            if shouldRunFrame > 0 then
                self.lastFrameTime = self.lastFrameTime + (shouldRunFrame * 0.033333333333)
            end
            for i = 1, shouldRunFrame do
                self:updateFrame()
            end
        end, 0)
    self:callEventListener("start")
    if self.callback ~= nil then
        self.callback("start")
    end

    -- 触发角色开始战斗事 add by TangJian 2017/05/04 22:15:29
    for k, v in pairs(self.traverseRoles) do
        v:onStartFight()
    end
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 得到角色
function Fight:getRole(id)
    local role = self.fightRoles[id]
    if role == nil then
        LogSystem:log("旧版战斗：","角色不存在，id:",id)
    end
    return role
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/23 20:53:08
-- @desc 得到角色map
function Fight:getRoles()
    return self.fightRoles
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/09 18:30:48
-- @desc 得到角色数目
function Fight:getRoleCount()
    local count = 0
    for k, role in pairs(self.fightRoles) do
        count = count + 1
    end
    return count
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 得到本地角色列表
function Fight:getLocalRole()
    return self.localRole
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

-- 角色主动招式 --------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 释放主动技能
function Fight:useActiveZhao(roleId, activeZhaoId)
    local role = self:getRole(roleId)
    local activeZhao =
        {
            rid = roleId, -- 角色id
            f = self.currentActualFrame + 1, -- 帧
            zid = activeZhaoId -- 主动招式id
        }
    
    if self._isOffline then
        self:addActiveZhao(roleId, self.currentActualFrame + 1, activeZhaoId)
    else
        self._fightClient:sendActiveData(self.currentActualFrame, activeZhao)
    end
end

function Fight:getTeamRoleCount(teamId)
    return 1
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

        if (effect:getValidDuration() >= effect:getFinalDuration()) and effect:getFinalDuration() ~= -30 then
            table.insert(removeEffectList, effect)
        end
        effect:setValidDuration(effect:getValidDuration() + 1)
    end
    if #removeEffectList>0 then 
        for i, effect in ipairs(removeEffectList) do
            self:roleRemoveEffect(role, effect:getId())
            self:callEventListener("endEffect", role, effect)        
        end
    end
    
    if role:isDead() then
        self:callEventListener("roleDie", role, "chest")
        self:callEventListener("playWinAnim", self:getRole(role:getTargetId()),0.4)
    end
    
    if self.state ~= "gameover" then
        local canFightEnd, winTeamId = self:fightEndTest()
        if canFightEnd then
            self:gameover(winTeamId)
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
            self:roleRemoveEffect(role, effect:getId())
            self:callEventListener("endEffect", role, effect)
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
    -- 使用主动招式
    if
        self.isIdleFrame == false
        and
        role._currZhaoState == 0
    then
        if role:getCurrActiveZhao() == nil
            and
            self:roleCanPlayActiveZhao(role:getId(), role._currActiveIndex, frameIndex)
        then
            local activeZhao = self:getRoleActiveZhao(role:getId(), role._currActiveIndex)
            if activeZhao then
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
    --打飞机制
    LogSystem:log("旧版战斗：","进入打飞机制判断")
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
    local targetWeaponType = target._role:getCurrTypeByWeapon()
    
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

    if jifeiOdds >= self:random( 1,100 )/100 then
        return true
    end
    return false

end

function Fight:needDaduanWeapon( role,target )
    local roleWeaponType = role._role:getCurrTypeByWeapon()
    local targetWeaponType = target._role:getCurrTypeByWeapon()
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
            if 20 >= self:random(1,100) then
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
            if 10 >= self:random(1,100) then
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
    -- 刷新按钮区域
    if target:isForget() then
        --目标中遗忘的情况下，不用刷新恢复按钮
        self:callEventListener("unloadWeapon",target,2)
    else
        self:callEventListener("unloadWeapon",target,3)
    end
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
    target:jifeiWeapon()
    target:setAutoZhaos(role:getId(), target:createAutoZhaos(role))  

    self:callEventListener("weaponjifei", role, target, zhao,targetWeaponType,targetWeaponType2)
    -- 刷新按钮区域
    if target:isForget() then
        --目标中遗忘的情况下，不用刷新恢复按钮
        self:callEventListener("unloadWeapon",target,2)
    else
        self:callEventListener("unloadWeapon",target,3)
    end
end


local function getZhaoQiAtkAfterDamageFactor(atk, factor)
    LogSystem:log("旧版战斗：经气血最终伤害系数计算前的atk = ", atk)
    atk = Helper:getRange(atk * factor,1)
    LogSystem:log("旧版战斗：经气血最终伤害系数计算后的atk = ", atk)
    return atk
end

local function getZhaoQiAtkAfterZhaoTimesFactor(atk, factor)
    LogSystem:log("旧版战斗：经招式递减系数计算前的atk = ", atk)
    atk = atk * factor
    LogSystem:log("旧版战斗：经招式递减系数计算后的atk = ", atk)
    return atk
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
    end

    LogSystem:log("旧版战斗：效果处理之前，命中情况下atk = ", value)

    return value
end

-- 内省效果
local function getNeiLiConsumeAfterNeiLiSaveEffects(value, role)
    if role:isNeiliSave() then
        local effects = role:getEffectMap()

        for k, effect in ipairs(effects) do
            if effect:getType() == "内省" then         
                local arg2 = effect:getFinalArg2()
                value = value *(1 - arg2)
            end
        end
    end

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
    value = getNeiLiConsumeAfterAutoZhaoTimes(value, role)

    return value
end

function Fight:doAutoZhao(role, target, zhao)
    -- add by XiaoZhiWei 2018/03/23 15:13:18 PVP增加招式次数伤害递减规则        
    -- 招式伤害递减\
    do
        --经脉招不递减
        if zhao.isJingMaiZhao ~= true then
            local zhaoTimesFactor = Helper:getDef(AUTO_ZHAO_TIMES_DAMAGE_FACTOR_ARRAY[role._currAutoZhaoTimes], 0.4)

            zhao.zhaoTimesFactor = zhaoTimesFactor
            zhao.atk = zhao.atk * zhaoTimesFactor
            zhao.qiMaxAtk = zhao.qiMaxAtk * zhaoTimesFactor
        end
    end


    local attackSkill = Skill:getSkill(zhao.atkSkId)
    local attackZhao = attackSkill:getAttackZhaoById(zhao.atkZhaoId)
    if zhao.isJingMaiZhao == true then
        attackZhao.isJingMaiAttackZhao = true
        attackZhao._cType = zhao._cType
    end
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

	if role:isHit() then
        local effectMap = role:getEffectMap()
        for k, effect in ipairs(effectMap) do
            if effect:getType() == "必中" then
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
    end

    if role:isHitFailure() then
        local effectMap = role:getEffectMap()
        for k, effect in ipairs(effectMap) do
            if effect:getType() == "致盲" then
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
    end

    --强招架
    if target:isParry() then
        --强招架
        local effectMap = target:getEffectMap()
        for k, effect in ipairs(effectMap) do
            if effect:getType() == "强招架" then
                local arg1 = effect:getFinalArg1()
                arg1 = arg1 - 1
                effect:setArg1(arg1)
                if arg1 <= 0 then
                    self:callEventListener("endEffect", target, effect)
                    self:roleRemoveEffect(target, effect:getId())
                end
                break
            end
        end
    end

    -- 加力消耗内力 add by TangJian 2016/11/16 16:51:31
    do
        -- 判断是否需要内力 add by TangJian 2017/03/22 16:30:12
        if role:isNeedNeili() then
            local neiliConsume = self:getAutoZhaoNeiliConsume(zhao.neiliConsume, role)

            if zhao.isJingMaiZhao then
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

        if PVP_SHENBINGSYS and target:getAttackMethod() ~= 1 and zhao.hitType == HIT_TYPE_PARRY and self:needUnmountWeapon(role,target) then -- 打飞武器    
           
            local roleWeaponName = role:getCurrWeaponName()
            self:unmountWeapon(role, target, zhao)
            self._eventListenerFM:addFunction(function ()

                local str = "HIR$N使用$wHIR一击打在$n的兵器之上，$n虎口发麻，兵器应声脱手！NOR"
                self:callEventListener("printText",str, role:getAttr("name"), target:getAttr("name"),roleWeaponName)

                return true
            end)


        elseif PVP_SHENBINGSYS and target:getAttackMethod() ~= 1 and zhao.hitType == HIT_TYPE_PARRY and self:needDaduanWeapon(role,target) then -- 打断武器
           
            local roleWeaponName = role:getCurrWeaponName()
            local targetWeaponName = target:getCurrWeaponName()
            self:DaduanWeapon(role, target, zhao)
            self._eventListenerFM:addFunction(function ()

                local str = "HIR$N使用$wHIR打在$n的兵器之上，只听一声脆响，$n的兵器竟然应声而断！NOR"
                self:callEventListener("printText",str, role:getAttr("name"), target:getAttr("name"),roleWeaponName)

                return true
            end)        


        else -- 一般攻击

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
    do
         --攻击就生效    
        if PVP_SHENBINGSYS then
            self:getWeaponEffect(role,target,1)
        end

        if zhao.hitType == HIT_TYPE_HIT then
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
            elseif target:isSaveDamageByHurt(HurtFactory:create(0,0)) then --储伤
                zhao.isSaveDamage = true
            end
             --击中生效(只要不被闪避或者格挡)
            if PVP_SHENBINGSYS then
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

            local qiAtk = Helper:getRange(zhao.atk - Helper:getDef(zhao.absorbAtk, 0), 0)

            --真罡
            qiAtk = Helper:getRange(qiAtk - Helper:getDef(zhao.isZhenGang, 0), 0)

            local xieLiPercent = Helper:getRange(Helper:getDef(zhao.xieLiPercent, 0), 0,1)

            --卸力
            LogSystem:log("旧版战斗：","卸力效果值：", xieLiPercent, "卸力减免伤害值：", qiAtk * xieLiPercent)
            qiAtk = qiAtk * (1 - xieLiPercent)

            --真实伤害(无视护盾)
            local trueDamage = self:calTrueDamage(role,zhao)
            qiAtk = qiAtk + trueDamage
            zhao.trueDamage = trueDamage

            qiAtk = Helper:getRange(qiAtk,0,zhao.damageMax)
            
            --防止出现气血高于当前气血上限 add by LvBin 2018/11/09 11:31:30
            zhao.qiMaxAtk = math.min(zhao.qiMaxAtk,qiAtk)

            --角色实际伤害
            local targetQiAtk = qiAtk
            local roleIsInDamageToHurt = role:isInDamageToHurt()
            local targetIsInDamageToHurt = target:isInDamageToHurt()

            if zhao.isCruor then
                    
                -- 目标回血
                local cruorFactor = Helper:getDef(zhao.cruorFactor,0)
                local value = qiAtk * cruorFactor
                LogSystem:log("旧版战斗：","凝血效果值：", cruorFactor, "凝血回血值：", value)
                target:addAttr("qi",value, 0, target:getCurrQiMax())
                self:callEventListener("hit", role, target, zhao) -- 需要对文本输出进行改造
                
                -- 攻击的时候刷新效果
                targetQiAtk = 0
                if targetQiAtk > 0 then
                    self:updateRoleEffectOnAutoAttack(role, target, targetQiAtk)
                end
            elseif zhao.isFanShang then
                -- add by LvBin 修复护盾，偏转不能抵消反伤，
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

                -- 目标掉血 add by TangJian 2016/11/16 16:51:30
                if roleIsInDamageToHurt == false then
                    role:addAttr("qi", -qiAtk)-- 扣气血 add by TangJian 2016/11/08 21:49:25
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
                -- 目标掉血 add by TangJian 2016/11/16 16:51:30

                --@desc 打印招式详情
                role:printZhaoInfo(target,qiAtk,zhao.qiMaxAtk)
                targetQiAtk = qiAtk

                if targetIsInDamageToHurt == false then
                    target:addAttr("qi", -targetQiAtk)-- 扣气血 add by TangJian 2016/11/08 21:49:25
                    --伤害转气血效果累计伤害
                    if qiAtk > 0 then
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

                if qiAtk > 0 and target._role:getBuffAttr("xingzhenQiXue") ~= 1  then
                    target:setAttr("qiPercent", (target:getFinalAttr("qiMax") * target:getAttr("qiPercent") - zhao.qiMaxAtk) / target:getFinalAttr("qiMax"))-- 扣气血上限 add by TangJian 2016/11/08 21:49:24
                end

                self:callEventListener("hit", role, target, zhao)
                -- 攻击的时候刷新效果
                if targetQiAtk > 0 then
                    self:updateRoleEffectOnAutoAttack(role, target, targetQiAtk)

                    target:addRecordDamage(targetQiAtk)
                end
                
                if target:canDie() then
                    self:roleKill(role, target)
				else
					self:doDamageReturnEffect(role,target,targetQiAtk)

					target:hpRecoverOnHurt(HurtFactory:create(0,targetQiAtk))
                end

                if role:canDie() then
                    self:roleKill(target, role)
                end
            end
        elseif zhao.hitType == HIT_TYPE_PARRY then
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
            end
            
            local qiAtk = Helper:getRange(zhao.atk - Helper:getDef(zhao.absorbAtk, 0), 0)
            --真罡
            qiAtk = Helper:getRange(qiAtk - Helper:getDef(zhao.isZhenGang, 0), 0)

            local xieLiPercent = Helper:getRange(Helper:getDef(zhao.xieLiPercent, 0), 0,1)
            --卸力
            LogSystem:log("旧版战斗：","卸力效果值：", xieLiPercent, "卸力减免伤害值：", qiAtk * xieLiPercent)
            qiAtk = qiAtk * (1 - xieLiPercent)

            --真实伤害(无视护盾)
            local trueDamage = self:calTrueDamage(role,zhao)
            qiAtk = qiAtk + trueDamage
            zhao.trueDamage = trueDamage
            
            --防止出现气血高于当前气血上限 add by LvBin 2018/11/09 11:31:30
            zhao.qiMaxAtk = math.min(zhao.qiMaxAtk,qiAtk)
            local targetQiAtk = qiAtk
            local targetIsAlive = true
            local roleIsInDamageToHurt = role:isInDamageToHurt()
            local targetIsInDamageToHurt = target:isInDamageToHurt()

            if zhao.isCruor then
                -- 目标回血
                targetQiAtk = 0
                local cruorFactor = Helper:getDef(zhao.cruorFactor,0)
                local value = qiAtk * cruorFactor
                LogSystem:log("旧版战斗：","凝血效果值：", cruorFactor, "凝血回血值：", value)
                target:addAttr("qi", value, 0, target:getCurrQiMax())
                
                -- 攻击的时候刷新效果
                if targetQiAtk > 0 then
                    self:updateRoleEffectOnAutoAttack(role, target, targetQiAtk)
                end
            elseif zhao.isFanShang then
                targetQiAtk = 0
                -- add by LvBin 修复护盾，偏转不能抵消反伤，
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

                if roleIsInDamageToHurt == false then
                    -- 目标掉血 add by TangJian 2016/11/16 16:51:30
                    role:addAttr("qi", -qiAtk)-- 扣气血 add by TangJian 2016/11/08 21:49:25
                end

                self:addRoleDamageToHurtValue(role, qiAtk)
                self:addAppendDamageEffectDamageValue(role, qiAtk)
                
                if qiAtk > 0 and role._role:getBuffAttr("xingzhenQiXue") ~= 1 then
                    role:setAttr("qiPercent", (role:getFinalAttr("qiMax") * role:getAttr("qiPercent") - zhao.qiMaxAtk) / role:getFinalAttr("qiMax"))-- 扣气血上限 add by TangJian 2016/11/08 21:49:24
                end
                -- 攻击的时候刷新效果
                if targetQiAtk > 0 then
                    self:updateRoleEffectOnAutoAttack(role, target, targetQiAtk)
                end
                
                if role:canDie() then
                    self:roleKill(target, role)
                end
            else
                -- add by XiaoZhiWei 2017/07/26 14:17:47 偏转伤害移除
                if zhao.isZhuanYi == true then
                    qiAtk = 0
                    zhao.qiMaxAtk = 0
                    targetQiAtk = 0
                end
                -- 目标掉血 add by TangJian 2016/11/16 16:51:30

                --@desc 打印招式详情
                role:printZhaoInfo(target,qiAtk,zhao.qiMaxAtk)

                if targetIsInDamageToHurt == false then
                    target:addAttr("qi", -targetQiAtk)-- 扣气血 add by TangJian 2016/11/08 21:49:25
                    --伤害转气血效果累计伤害
                    if qiAtk > 0 then
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
                
                if targetQiAtk > 0 and target._role:getBuffAttr("xingzhenQiXue") ~= 1  then
                    target:setAttr("qiPercent", (target:getFinalAttr("qiMax") * target:getAttr("qiPercent") - zhao.qiMaxAtk) / target:getFinalAttr("qiMax"))-- 扣气血上限 add by TangJian 2016/11/08 21:49:24
                end

                if target:canDie() then
                    self:roleKill(role, target)
                    targetIsAlive = false
				else
					self:doDamageReturnEffect(role,target,targetQiAtk)

					target:hpRecoverOnHurt(HurtFactory:create(0,targetQiAtk))
                end

                -- 攻击的时候刷新效果
                if targetQiAtk > 0 then
                    self:updateRoleEffectOnAutoAttack(role, target, targetQiAtk)
                end

                if role:canDie() then
                    self:roleKill(target, role)
                end
            end

            local EffectMapList = {}
            if targetIsAlive then
                if PVP_SHENBINGSYS then
                    self:getWeaponEffect(role,target,3)--攻击被对手格挡
                    self:getWeaponEffect(role,target,5)
                    self:getWeaponEffect(target,role,4)--对手攻击被自己格挡
                end
    
                 --经脉触发的招式不触发拳脚特性
                if zhao.isJingMaiZhao ~= true then
                    self:getFistFootEffect(role,target,3)
                end
    
                self:calWeaponPoison(role,target)
    
                self:doParryTriggerEffect(role,target)

                if role:canDie() then
                    self:roleKill(target, role)
                end
    
                do
                    local effectMap = target:getEffectMap()
                    for k,effect in ipairs(effectMap) do
                        if effect:getType() == "反震" then
                            local arg1 ,arg2 = effect:getArg1(), effect:getFinalArg2()
                            --填0则反弹原值
                            if arg2 == 0 then
                                local factors = {
                                    damageFactor = zhao.damageFactor,
                                    zhaoTimesFactor = zhao.zhaoTimesFactor,
                                }

                                local value = self:getBeforeEffectAtkInHitResult(zhao.originalAtk, factors)
                                arg2 = -value
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
        
        if self.state ~= "gameover" then
            local canFightEnd, winTeamId = self:fightEndTest()
            if canFightEnd then
                self:gameover(winTeamId)
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
--@role:[app.models.fight.FightRole#FightRole]
--@target: [app.models.fight.FightRole#FightRole]
function Fight:calWeaponPoison(role, target)
    if not PVP_POISONSYS then
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

        local rate = self:random( 1,100 )
        local k1 = rolePoison.dex
        local k2
        if target:isPlayer() then
            k2 = target._role:getEffectDex()
        else
            k2 = target._role.dex
        end
        local successRate = (math.min(k1/(k2+500)+rolePoison.effect_rate,0.75) + rolePoison.add_rate) * 100
        LogSystem:log("旧版战斗：毒药相关系数","k1:",k1,"   |k2:",k2,"   |生效几率:",rolePoison.effect_rate,"   |修正几率:",rolePoison.add_rate,"   |当前成功率:",successRate,"   |当前随机率:",rate)

        local isSuccess = false
        if rate <= successRate then
            isSuccess = true
        end
    
        if not isSuccess then
            return
        end
    
        if role:isPlayer() then
            local zhengqi = role._role:getFinalAttr("zhengqi")
            local range = string.split(rolePoison.xiayi,";")
            local reduceZhengqi = self:random( range[1],range[2] )
            role._role:setAttr("zhengqi",tonumber(zhengqi - reduceZhengqi))

            PopText("侠义正气值 -"..reduceZhengqi)
            --@RefType [app.models.Poison.PoisonUtil#PoisonUtil]
            local PoisonUtil = require("app.models.Poison.PoisonUtil")
        
            --@desc 减少战斗场次
            PoisonUtil:reducePoisonFightCount(rolePoison.weaponIndex)
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
            elseif effect:getTarget() == "目标" then
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

                local printAngryStr = angryText[self:random( 1,#angryText)]
                local printFightStr = fightText[self:random( 1,#fightText)]

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

--计算真实伤害
function Fight:calTrueDamage(role,zhao)
    local trueDamage = 0
    if role:isTrueDamage() then
        local effectMap = role:getEffectMap()
        for k, effect in ipairs(effectMap) do
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

    LogSystem:log("旧版战斗：","真伤计算时体力消耗：",tiliConsume, "削减前真伤伤害：",trueDamage)
    --根据招式消耗的体力削减附加的真伤伤害
    trueDamage = trueDamage * (tiliConsume/100)

    return math.floor(trueDamage)
end

--计算卸力百分比
function Fight:calUnloadForce(role)
    local value = 0
    local effectMap = role:getEffectMap()
    for k, effect in ipairs(effectMap) do
        if effect:getType() == "卸力" then
            local arg1 = effect:getArg1()
            value = effect:getFinalArg2()
            break
        end
    end

    return value
end

-- @author GaoHanZheng
-- @time 2018/01/15 16:04:11
-- @desc 获取神兵特效效果并添加特效
function Fight:getWeaponEffect(role,target,effectType)
    local weapon = role._role:getEquipByName("weapon")
    local weapontype = role._role:getCurrWeaponType()
    if weapon ~= nil and weapontype ~= "拳脚" then
        local weaponAttr = role._role:getOneItemByKey(weapon.itemId)
        local effectList ,fighttextList , effctNameList = ShenBingEffct:getRandomEwaponEffectResult(role,weaponAttr,effectType)
        if MapIsEmpty(effectList) == false then
            for k,effect in ipairs(effectList) do                
                if effect:getTarget() == "自己" then
                    if self:canAddEffect(role,effect) then
                        effect:setOwner(role)-- 设置效果释放者
                        effect:setObject(role)
                    
                        local immediateEffectUIInfo = self:roleAddEffect(role, role, effect)
                        --延时到攻击那一刻 
                        self:callEventListener("addRolesEffectChangeFunction", function()
                            self:callEventListener("doEffect", role, effect)
                            return true
                        end)
                        self:callEventListener("beginEffect", role, effect, immediateEffectUIInfo)
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
                    
                        for _, v in ipairs(GetColorList()) do
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
                            self:callEventListener("addRolesEffectChangeFunction", function()
                                self:callEventListener("doEffect", target, effect, immediateEffectUIInfo)
                                return true
                            end)
                        else
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
                triggerEffect:setObject(target)
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
-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/12/24 18:08:41
-- @desc 主动技能
-- 命中系数 = 根据当前的招架武功，获取武功命中系数（hitRate）
-- 命中力 = (武功主动技能等级*150*命中系数/100+1000+0.5*玩家经验^0.5)*(1+等效臂力*0.02)
function Fight:roleActiveZhao(role, target, activeZhao)
    -- 触发主动技能相关的buff效果 add by TangJian 2017/04/25 03:16:29
    role:executeBuff("使用主动技能", role, target, activeZhao)

    -- 判断是否命中
    local hitType = "dodge"
    
    local hitRate = role:getActiveZhaoHitRate(activeZhao:getId())
    local targetDodge = target:getDodgeRate()
    local targetParry = target:getParryRate()

    hitType = "hurt"
    
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
    
    for k, effect in pairs(effectArray) do
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
    if self.state ~= "gameover" then
        local canFightEnd, winTeamId = self:fightEndTest()
        if canFightEnd then
            self:gameover(winTeamId)
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
    LogSystem:log("旧版战斗：","效果类型 = ",effectType," |效果Id",effect:getId())
    switch(effectType,
        {
            ["属性变化"] = function()
                -- add by LvBin 修复护盾 偏转 反伤 对主动技能不生效问题
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
                        elseif effect:getObject():haveFanShang() and not effect:checkHaveEffectType(EFFECT_TYPE_POISON) and effect:getFinalDuration() == 0 then --反伤
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
                            arg2 = - math.min(math.abs(arg2), role:calDamageMax())
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

                    if arg2 < 0 then
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
                    
                    LogSystem:log("旧版战斗：","效果释放者 = ",role:getName()," |效果作用属性类型 = ",arg1," |效果值 = ",arg2," |效果最大值（实际效果值不能超过最大值） = ",role:getAttr("neiliMax")*2)

                    role:addAttr(arg1,arg2,0,role:getAttr("neiliMax")*2)
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
                effect:setArg1(arg1 - damage)
                effect:addAbsorbDamage(damage)
                LogSystem:log("旧版战斗：","护盾吸收值", damage)
                damage = 0
            else
                effect:setArg1(0)
                effect:addAbsorbDamage(arg1)
                damage = damage - arg1
                LogSystem:log("旧版战斗：","护盾吸收值", arg1)
                -- 移除效果
                self:roleRemoveEffect(role, effect:getId())
                self:callEventListener("endEffect", role, effect)
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
                    print("增益 duration 数值异常，请检查配置是否正常，duration："..duration)
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
                target.hasUsedYiWu = true
                target:setChangeWeaponType(2)
                self:changeWeapon(target)

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
                
                if target:getRole():getEquipByName("weapon") ~= nil and change*100 >= self:random(1,100) then
                    --记录丢失的兵器的子类型
                    local weaponSubtype = target:getRole():getCurrSubtypeByWeapon()
                    target:setBeforeUnloadWeaponIsSubType(weaponSubtype)

                    target:unloadWeapon()

                    self:callEventListener("jiaoxieEffect",target, effect)

                    -- 刷新按钮区域
                    if target:isForget() then
                        --目标中遗忘的情况下，不用刷新恢复按钮
                        self:callEventListener("unloadWeapon",target,2)
                    else
                        self:callEventListener("unloadWeapon",target,3)
                    end
                end
            end,
             ["净化"] = function()
                local odds = effect:getFinalArg1()
                if odds*100 >= self:random(1,100) then
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
                    if odds*100 >= self:random(1,100) then
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
                    if odds*100 >= self:random(1,100) then
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
                    if odds*100 >= self:random(1,100) and not target:isForget() and not target:isPartForget() then       
                        target:addEffect(effect)

						target._prePrepareSkills = {}

						table.mergeToLeft(target._prePrepareSkills,target._role.skillPrepare)
						
						local forgetType = effect:getArg2()
						local btnType = 2
						if forgetType then
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
						else
							target._role.skillPrepare = {}
						end
                        
                        target._role:updateActiveZhaoStatus()
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
                    
                    -- 刷新按钮区域
                    if owner:isForget() then
                        --目标中遗忘的情况下，不用刷新恢复按钮
                        self:callEventListener("unloadWeapon",owner,2)
                    else
                        self:callEventListener("unloadWeapon",owner,3)
                    end
                else
                    PopText("你没有装备兵器")
                end
            end,    
            ["窃取"] = function()
                local owner = effect:getOwner()
                local targetEffectMap = target:getEffectMap()
                local count = effect:getFinalArg1() --窃取增益效果的数量
                print("count = "..count)
                local list = {} --目标的增益效果表
                local select = {}   --窃取的增益效果
                for K,effect in ipairs(targetEffectMap) do
                    if effect:checkHaveEffectType(EFFECT_TYPE_POSITIVE) then
                        table.insert(list,effect)
                    end
                end
                print("目标的增益效果数量 = "..#list)

                if not MapIsEmpty(list) then
                    table.sort(list,function(a, b)
                        return a:getId() < b:getId()
                    end)
                    
                    if count >= #list then
                        for i,effect in ipairs(list) do
                            self:callEventListener("endEffect", target, effect)
                            self:roleRemoveEffect(target, effect:getId())

                            self:roleAddEffect(owner, owner, effect)
                        end
                    else
                        while #select < count do
                            table.insert(select,table.remove(list,self:random(1,#list))) --pvp记得调用重写的random接口
                            print("2222"..self:random(1,#list))
                        end
                        print("窃取的增益效果数量 = "..#select)
                        for i,effect in ipairs(select) do
                            self:callEventListener("endEffect", target, effect)
                            self:roleRemoveEffect(target, effect:getId())

                            self:roleAddEffect(owner, owner, effect)
                        end
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
                    print("内省 duration 数值异常，请检查配置是否正常，duration："..duration)
                    print(debug.traceback())           
                end
            end,
            ["强招架"] = function()
                if duration <= 0 then
                    print("强招架 duration 数值异常，请检查配置是否正常，duration："..duration)
                    print(debug.traceback())
                else
                    local odds = Helper:getDef(arg2,0)
                    if odds*100 >= self:random(1,100) then
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
                    if odds*100 >= self:random(1,100) then
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
                    if odds*100 >= self:random(1,100) then
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
                    print("延宕 duration 数值异常，请检查配置是否正常，duration："..duration)
                    print(debug.traceback())
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
                        if cdLeft > 0 and haveYanDanEffect == false then --只对还在cd中的主动技能作用,也不能影响有延宕效果的主动技能
                            local addCd = arg2*30 --cd时间转为帧
                            local finalCdLeft = Helper:getRange(cdLeft + addCd, 0, 120*30)
                            activeZhaoState:setCDLeft(finalCdLeft)

                            LogSystem:log("旧版战斗：延宕","主动技能：",activeZhaoState:getName()," | 当前CD：",cdLeft," | 生效后CD：",finalCdLeft)
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
                LogSystem:log("旧版战斗：指定驱散","生效者 = "..target:getName(),"| arg2：",effectList)

                local effectMap = target:getEffectMap()
                
                for k, _effect in ipairs(effectMap) do
                    local effectId = _effect:getId()
                    LogSystem:log("旧版战斗：指定驱散","生效者 = "..target:getName(),"| 拥有效果id：",effectId)

                    for __, id in ipairs(removeEffectList) do
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

                table.sort(canRemoveEffectList, function(a, b)
                    return a:getId() < b:getId()
                end)

                local effectNum = effect:getFinalArg2()
                local addEffectList = {}
                if effectNum < #canRemoveEffectList then
                    for i = 1, effectNum, 1 do
                        table.insert(addEffectList,table.remove(canRemoveEffectList,self:random(1, #canRemoveEffectList)))
                    end
                else
                    addEffectList = canRemoveEffectList
                end

                local effectOwner = effect:getOwner()
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
                        trueTargetName = effectOwner:getTarget():getAttr("name")
                        self:roleAddEffect(effectOwner, effectOwner:getTarget(), _effect)
                        LogSystem:log("旧版战斗：类型转移","效果转移目标：",transferTarget,"效果转移目标名字：",trueTargetName)
                    end
                    LogSystem:log("旧版战斗：类型转移","转移效果Id:", _effect:getId())
                end

                self:callEventListener("printText",effect:getEffectFuncDesc(), effectOwner:getAttr("name"), trueTargetName, nil, nil, nil, {})
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
                    else
                        local currValue = tonumber(effect:getFinalArg2())

                        currValue = Helper:getRange(currValue,0,tonumber(effect:getFinalArg3()))

                        if currValue <= 0 then
                        else
                            effect:setArg2(currValue)

                            target:addEffect(effect)
                        end
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

					local randomEffectIndex = self:RandomByWeight(randomList,"weight")

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
    if Helper:getDef(effect:getFinalTruerate(),100) < self:random(1,100) then
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
     
    local effect = role:getEffect(effectId)
    if effect then
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
                    role._role:updateActiveZhaoStatus()

                    role._prePrepareSkills = nil

                    
                    self:callEventListener("Forget",role,3)
                    role:reinitRole()
                    end,
                ["内伤"] = function()
                    role._role.jiaLi = role:getAttr("jiaLiValue")    
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
    
    end
    
    
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

    local value = 0
    if self.localRole:isDead() then
        -- 本地死了
        value = 2
        canFightEnd = true
    end
    if self.targetRole:isDead() then
        -- 对方死了
        value = 1
        canFightEnd = true
    end

    if self.targetRole:isDead() and self.localRole:isDead() then
        value = 3
        canFightEnd = true
    end

    -- 队伍1人物全部死亡
    return canFightEnd, value
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 战斗结束
function Fight:fightEnd(value)
    POISONSYS = true
    NPC_AI = true
    SHENBINGSYS = true
    MainControllLayer:resumeUpdate()
    self:callEventListener("fightEnd", value, self.fightRoles)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 刷新UI
function Fight:refreshUI()
    self:callEventListener("refreshUI", self.fightRoles)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 初始化
function Fight:init()
    self._eventListenerFM = FunctionManager:create()-- 时间监听方法
    self._preUpdateFM = FunctionManager:create()-- 更新前方法
    self.currentActualFrame = 0 -- 当前帧
    self._currFrame = 0
    self.fightRoles = {}-- 角色列表
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/01 10:29:58
-- @desc 自带创建角色方法
function Fight:createRole(roleData)
    local role = PVPRole:create(roleData)
    role:setEventListener(
        function(roleId, eventName, ...)
            self:callEventListener("roleEvent", roleId, eventName, ...)
        end)
    return role
end

-- 一个战斗必须要设置的proxy
-- @proxy 数据IO代理
function Fight:setDataProxy(proxy)
    self.dataProxy = proxy
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 添加角色
function Fight:addRole(id, roleData)
    local fightRole = self:createRole(roleData)
    self.fightRoles[id] = fightRole

    fightRole._fight = self

    return fightRole
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 通过队伍id和角色在队伍中的id来得到角色
function Fight:getRoleByTeamIdAndInTeamId(roleTeamId, roleInTeamId)
    if roleTeamId == 1 and roleInTeamId == 1 then
        return self.localRole
    end

    if roleTeamId == 2 and roleInTeamId == 1 then
        return self.targetRole
    end

    return nil
end

function Fight:isPaused()
    return self.state == "pause"
end

function Fight:isStop()
    return self.state == "stop"
end

function Fight:isStart()
    return self.state == "start"
end

function Fight:getState()
    return self.state
end

--设置当前战斗处于离线状态
function Fight:setFightIsOffLine(isOffLine)
    self._fightOffLineState = isOffLine
end

function Fight:getFightIsOffLine()
    return self._fightOffLineState
end

-- 正常战斗结束就是GameOver，有玩家逃跑也是正常结束
function Fight:gameover(value)
    if self.state == "gameover" then
        return
    end
    self.state = "gameover"
    self:fightEnd(value)

    if self.callback ~= nil then
        self.callback("gameover", self.localRole:getRole(), self.targetRole:getRole(), value)
    end
end

function Fight:pause()
    self.state = "pause"
end

function Fight:setCallback(cbs)
    self.callback = cbs
end

function Fight:runaway()
    if self.state == "init" then
        if GetLocalTime() - self.initTime > 10 then
            self:processRunaway(self.localRole)
        end

        return
    end

    local hasRunaway = self.dataProxy:hasZhao(roleId, self.currentDataIndex, RUNAWAY_TAP)
    if self.state == "start" and hasRunaway ~= true then
        -- 发送逃跑数据
        local runZhao = {}
        runZhao.x_f = self.localRole:getId()
        runZhao.x_t = self.targetRole:getId()
        runZhao.x_m = RUNAWAY_TAP

        self.dataProxy:addZhao(runZhao)
    end    
end

--添加经脉触发的额外招式
function Fight:addMeridianZhao(role,target,zhao)
    if IS_OPEN_HUAZHIWEIJIAN and role:getAttackMethod() == SKILL_METHOD_TYPE_QUANJIAO then
        --经脉招式不能继续触发
        if zhao.isJingMaiZhao ~= true then
            local ret ,meridian = role:cheackHaveSpecialMeridianEffect()
            if ret == true then
                --清空互博招式
                role:setCurrDoubleAttackSkill(nil)
                role:setCurrDoubleAttackZhao(nil)

                local hasMeridianZhao = self.dataProxy:hasZhao(role:getId(), self.currentDataIndex, AUTO_ZHAO_TAP)
                if hasMeridianZhao ~= true and role:getId() == self.localRole:getId() then --只需要一个客户端上传招式
                    local num1 = math.random(1, 100)
                    local num2 = math.random(1, 100)
                    local meridianZhao = inherit({},role:createJingMaiEffectAutoZhao(target, num1, num2, meridian.effect))
                    meridianZhao.x_f = role:getId()
                    meridianZhao.x_t = target:getId()
                    meridianZhao.x_m = AUTO_ZHAO_TAP
                    
                    self.dataProxy:addZhao(meridianZhao)
                end

                self:callEventListener("activeJingMaiYinJi", meridian.id, meridian.name, nil,role:getTeamId())
                return true
            end
        end
    end
    return false
end

function Fight:resume()
    self.state = "start"
end

-- 非正常退出就是Stop
function Fight:stop()

end

-- 检测游戏，主要是检测是否有玩家已经死了，游戏状态是否正常，数据是否正常
-- @return 如果一切正常，那么将会返回
function Fight:readyGame()
    
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
        local activeZhao = Skill:getActiveZhaoInPVP(activeZhaoId)
        if activeZhao:getType() ~= "释放" then
            return false, "此技能暂时无法使用"
        end
    end

    -- 被禁锢不能释放任何主动技能
    if role:isimprison() then
        return false, "禁锢中，无法使用主动技能！"
    end

    if role:isAttackLimit() then
        local activeZhao = Skill:getActiveZhaoInPVP(activeZhaoId)
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

    print("active zhao id: " .. activeZhaoId)
    
    local isTrue, msg = self:checkRoleCanReadyActiveZhao(role, activeZhaoId)
    if isTrue == false then
        PopText(msg)
        return
    end

    --走穴十四经，得到效果无法使用主动技能
    if role._role:getBuffAttr("xingzhenZhanDou") == 1 then
        PopText("受行针走穴影响，你暂时无法自由运转内力。")
        return
    end
    
    local hasActiveZhao = self.dataProxy:hasZhao(roleId, self.currentDataIndex, ACTIVE_ZHAO_TAP)
    if hasActiveZhao == true then
        return false, ""
    end

    local canUse, notice = role:activeZhaoIsCoolDown(activeZhaoId)
    if canUse then
        canUse, notice = role:canUseActiveZhao(activeZhaoId)
        -- 判断当前能否释放招式
        if canUse then
            -- 如果招式能够使用，那么将会生成好招式发给服务器
            -- 这里要完成招式所有的数值计算
            local activeZhao = {}
            activeZhao.x_f = role:getId()
            activeZhao.x_t = self.targetRole:getId()
            activeZhao.x_m = ACTIVE_ZHAO_TAP
            activeZhao.zid = activeZhaoId
            self.dataProxy:addZhao(activeZhao)
        end
    end
    return canUse, notice
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 更新帧
function Fight:updateFrame()
    self.currentFrameCount = self.currentFrameCount + 1

    if self:isStart() then
        -- 如果是静止帧, 则帧数不增加
        if self.isIdleFrame then
            -- 播放当前帧
            self:processRole(self.currentActualFrame)
            self.currentActualFrame = self.currentActualFrame + 1
            self._currFrame = self._currFrame + 1

            -- 检测是否有zhao
            local data = self.dataProxy:takeData(self.currentDataIndex)

            if data ~= nil then
                -- 消费
                self:consumeData(data)
            end
        end

        -- 处理当前招
        self:processCurrentZhao()
    end
        -- 事件提醒
    self._eventListenerFM:callFunctions()
end

-- @author WenYF
-- @desc 处理每一角色
function Fight:processRole(frameIndex)
    -- 遍历刷新所有角色
    for i, role in ipairs(self.traverseRoles) do
        -- 只有在空闲帧的时候才去刷新角色
        self:updateRoleFrame(role, frameIndex)
    end
end

function Fight:isNeedPrepareZhao(role)
    if role:isUnableAutoAttack() then
        return false
    end
    
    -- 本地的玩家才准备数据
    if role:getAttr("tili") + TILI_LATANCY_COMPENSATE >= role:getFinalAttr("tiliMax") and role:getId() == self.localRole:getId() then
        if self.dataProxy:hasZhao(role:getId(), self.currentDataIndex, AUTO_ZHAO_TAP) == true then
            return false
        else
            return true
        end
    else
        return false
    end  
end

-- 每一帧对角色的处理，主要包括角色自己的体力，CD等处理
-- @author TangJian
-- @desc 
function Fight:updateRoleFrame(role, frameIndex)
    -- 如果自己挂了，那么后面的操作都存在
    if role and role:isDead() then 
        -- TODO
        local fightEnd, value = self.fightEndTest()
        self:gameover(value)
        return
    end
    
    -- -- 刷新主动技能CD
    role:updateFrame(frameIndex)
    self:callEventListener("updateActiveZhaoButton", self:getPlayer())
    
    -- TODO 体力基础CD可以在战斗开始的时候计算出来
    -- old MIN((等效身法+208)*(攻速系数+230)/1000,100)    now 体力回复速度 = min((有效身法 + 550) * (攻速系数+ 80) / 1140, 150) 
    local RestoreTiliPerSecond = math.min((role:getRole():getEffectDex() + 550) * (role:getAttackSpeedFactor() + 80) / 1140, 150)

    local atkSpeedFactor = role:getAtkSpeedFactor() 

    RestoreTiliPerSecond = RestoreTiliPerSecond * atkSpeedFactor

    local updaetRestoreTili = RestoreTiliPerSecond / 40

    role:addAttr("tili", updaetRestoreTili, 0, role:getFinalAttr("tiliMax"))

    LogSystem:log("旧版战斗：", "角色：",role:getName()," |人物初始攻速:",role:getAttr("atkSpeedFactor"),"  |武器重量影响后的攻速:",atkSpeedFactor,"  |体力恢复：",updaetRestoreTili , socket.gettime())

    -- 静止帧 效果刷新 add by TangJian 2017/03/02 15:23:50
    self:playRoleEffect(role, frameIndex)

    do  --刷新增伤易伤
        role:updateFragile()
        role:updateAugment()
    end
    
    if role:isImmobilized() then
        role:setAttr("tili", 0)
    end

    -- 只有在时事的时候才有效
    if self:isNeedPrepareZhao(role) == true then
        local target = self:getRole(role:getTargetId())
        local zhao = role:createZhaoForPVP(target)

        zhao.x_f = role:getId()
        zhao.x_t = target:getId()
        zhao.x_m = AUTO_ZHAO_TAP
        self.dataProxy:addZhao(zhao)
    end
end

-- 消费一个数据，如果这个招消费成功
-- @data 数据
-- @return 消费成功
function Fight:consumeData(data)
    if data.title == "ct" then
        -- TODO 消息
        self.currentDataIndex = self.currentDataIndex + 1
        return true
    end

    if data.title == "dt" then
        -- 先得到这个zhao是谁发出来的
        local from = data.x_f

        -- 没有from，属于脏招，丢弃
        if from == nil then
            return true
        end

        local role = self:getRole(from)

        local target  = nil

        if data.x_m ~= RUNAWAY_TAP then
            local to = data.x_t
            target = self:getRole(to)
        end

        self.currentZhaoWrapper = {
            role = role,
            target = target,
            zhao = inherit({},data)
        }

        self.currentDataIndex = self.currentDataIndex + 1

        return true
    end
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 播放角色被动技能
function Fight:processCurrentZhao()
    -- 当前没有执行的招式，返回
    if self.currentZhaoWrapper == nil then
        return
    end

    local role, target, zhao = self.currentZhaoWrapper.role, self.currentZhaoWrapper.target, self.currentZhaoWrapper.zhao

    if zhao.x_m == AUTO_ZHAO_TAP then
        self:processAutoZhao(role, target, zhao)
    elseif zhao.x_m == ACTIVE_ZHAO_TAP then
        self:processActiveZhao(role, target, zhao)
    elseif zhao.x_m == RUNAWAY_TAP then
        self:processRunaway(role, zhao)
    end
end

function Fight:processRunaway(role, zhao)
    if role:getId() == self.localRole:getId() then
        self:gameover(5)
    elseif role:getId() == self.targetRole:getId() then
        -- 对方已经逃跑，战斗胜利
        self:gameover(4)
    else
        self:gameover(3)
    end

    self.currentZhaoWrapper = nil
end

function Fight:processAutoZhao(role, target, zhao)
    if self:autoZhaoVerify(role,zhao) == false then
        return
    end

    local currZhaoState = role._currZhaoState

    switch(currZhaoState,
        {
            [0] = function() 
                -- 重置当前被动招式释放次数     
                role._currAutoZhaoTimes = 0 

                -- 如果处在非等待状态, 则尝试消耗体力, 发动进攻 add by TangJian 2016/11/09 18:04:28
                local attackSkill = Skill:getSkill(zhao.atkSkId)
                local attackZhao = attackSkill:getAttackZhaoById(zhao.atkZhaoId)
                local tiliConsume = role:getAutoZhaoTiliConsume(attackZhao)

                --经脉招式不消耗体力
                if zhao.isJingMaiZhao == true then
                    tiliConsume = 0
                end

                -- 进入前摇
                self.isIdleFrame = false -- 设置为静止帧
                role._currZhaoIndex = role._currZhaoIndex + 1
                role._currZhaoFrame = 1
                role._currZhaoState = 1 -- 进入前摇
                role:addAttr("tili", -tiliConsume, 0)

                 --打印被动招式数据
                self:__printAutoZhaoInfo(role, target, zhao, tiliConsume)

                end, -- 空闲帧
            [1] = function()-- 前摇
                if role:isActived() then
                    -- 招式帧加1
                    role._currZhaoFrame = role._currZhaoFrame + 1
                    -- 判断前摇是否结束
                    if role._currZhaoFrame > zhao.befFrame then
                        -- 进入攻击帧
                        self.isIdleFrame = false -- 设置为静止帧
                        role._currZhaoFrame = 1 -- 招式帧这只为1
                        role._currZhaoState = 2 -- 进入攻击帧
                        
                        LogSystem:log("旧版战斗：被动招式", "角色：",role:getName()," |前摇结束")
                    else
                        LogSystem:log("旧版战斗：被动招式", "角色：",role:getName()," |前摇中")
                    end
                else
                    LogSystem:log("旧版战斗：被动招式", "角色：",role:getName()," |静止帧, 前摇中")
                end
            end,
            [2] = function()-- 攻击
                -- 第一帧执行操作
                if role._currZhaoFrame == 1 then

                    -- 攻击前增加攻击次数
                    role._currAutoZhaoTimes = role._currAutoZhaoTimes + 1 
                    
                    -- 数值计算
                    self:doAutoZhao(role, target, zhao)

                    -- 附加动画隐藏 add by TangJian 2017/04/08 11:53:22                    
                    self:callEventListener("setRoleAllAdditionalAnimEnabled", role, false)
                end
                
                -- 招式帧加 1
                role._currZhaoFrame = role._currZhaoFrame + 1
                
                -- 判断前摇是否结束
                local atkFrame = zhao.atkFrame
                if role._currAutoZhaoTimes == 1 or role:isWaitingTili() then -- 第一招有跳跃, 需要加上跳跃时间
                    if zhao.anims then
                        atkFrame = zhao.atkFrame + math.ceil(10 / attackZhao.anims[1].speed / FIGHT_JUMP_SPEED_SCALE)
                    end
                end

                if role._currZhaoFrame > atkFrame then
                    -- 进入攻击帧
                    self.isIdleFrame = false -- 设置为静止帧
                    role._currZhaoFrame = 1 -- 招式帧设置为1
                    role._currZhaoState = 3 -- 进入后摇
                    LogSystem:log("旧版战斗：被动招式", "角色：",role:getName()," |攻击结束")

                    -- 附加动画显示 add by TangJian 2017/04/08 11:53:22                    
                    self:callEventListener("setRoleAllAdditionalAnimEnabled", role, true)
                else
                    LogSystem:log("旧版战斗：被动招式", "角色：",role:getName()," |攻击中")
                end
            end,
            [3] = function()-- 后摇
                -- 招式帧加 1
                role._currZhaoFrame = role._currZhaoFrame + 1
                -- 判断前摇是否结束
                -- if role._currZhaoFrame > zhao.aftFrame then
                if role._currZhaoFrame >= 0 then
                    -- 进入攻击帧
                    role._currZhaoFrame = 1 -- 招式帧设置为1
                    role._currZhaoState = 0 -- 进入空闲帧
                    self.currentZhaoWrapper = nil -- 当前招式设为nil

                    do
                        -- 判断是否触发经脉招式
                        self:addMeridianZhao(role,target,zhao)
                    end

                    self.isIdleFrame = true -- 设置为静止帧
                    LogSystem:log("旧版战斗：被动招式", "角色：",role:getName()," |后摇结束")
                else
                    LogSystem:log("旧版战斗：被动招式", "角色：",role:getName()," |后摇中")
                end
            end,
            
            default = function()error("currZhaoState = ") end
        })
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 播放主动技能
function Fight:processActiveZhao(role, target, zhao)
    local activeZhao = nil
    if self.isIdleFrame == true then
        -- 如果是主动招式，预处理
        if role:getId() == zhao.x_f then
            local isTrue = self:checkRoleCanReadyActiveZhao(role, zhao.zid)
            if isTrue == false then
                self.currentZhaoWrapper = nil -- 当前招式设为nil
                return
            else
                -- 通知显示
                self:callEventListener("readyActiveZhao", role:getId(), zhao.zid)
            end
        end

        activeZhao = role:getActiveZhaoState(zhao.zid)
        
        if activeZhao then
            role:setCurrActiveZhao(activeZhao)
            role:setCurrAttackZhao(activeZhao)-- add by XiaoZhiWei 2017/03/16 19:38:55 设置主动招式的同时 需要将其设置为攻击招式 否则结算时会报错
        else
            self.currentZhaoWrapper = nil -- 当前招式设为nil
        end
    end
  
    activeZhao = role:getCurrActiveZhao()

    if activeZhao == nil then
        print(debug.traceback())
        return
    end

    if target then
        switch(role._currActiveState,
            {
                [1] = function()
                    if self.isIdleFrame == true then
                        LogSystem:log("旧版战斗：主动技能","攻击者 = ",role:getName()," |受击者 = ",target:getName()," |主动招式ID = ",activeZhao:getId()," |平均气血伤害avgqiatk = ",role:getRole():getAvgQiAtk(target:getRole()))
                        local activeZhaoState = role:getActiveZhaoState(activeZhao:getId())
                        
                        role:setReadyActiveZhaoId(nil)
                        
                        -- 判断能否释放该主动技能
                        if activeZhaoState:getCDLeft() > 0 then
                            role:setCurrActiveZhao(nil)
                            self.currentZhaoWrapper = nil -- 当前招式设为nil
                            role._currActiveIndex = role._currActiveIndex + 1
                            
                            -- 移除无效主动技能
                            self:callEventListener("removeInvalidActiveZhao", role:getId(), target:getId(), activeZhao:getId())
                            return
                        
                        -- 判断是否需要内力 add by TangJian 2017/03/22 16:32:31
                        elseif role:isNeedNeili() == false then
                            
                            -- 设置cd
                            activeZhaoState:setCDLeft(activeZhaoState:getCD())
                        
                        elseif activeZhaoState:getFinalCost() ~= 0 and role:getAttr("neili") < activeZhaoState:getFinalCost() then
                            LogSystem:log("旧版战斗：主动招式", "角色当前内力：",role:getAttr("neili")," |主动招式内力消耗：",activeZhaoState:getFinalCost())
                            
                            role:setCurrActiveZhao(nil)
                            self.currentZhaoWrapper = nil -- 当前招式设为nil
                            role._currActiveIndex = role._currActiveIndex + 1
                            
                            if role:isPlayer() then
                                PopText("内力不够, 无法使用主动招式: " .. activeZhaoState:getName())
                            end
                            -- 移除无效主动技能
                            self:callEventListener("removeInvalidActiveZhao", role:getId(), target:getId(), activeZhao:getId())
                            
                            return
                        else
                            -- 消耗内力 add by TangJian 2017/03/22 16:30:19
                            role:addAttr("neili", -activeZhao:getFinalCost(), 0)
                            
                            -- 设置cd
                            activeZhaoState:setCDLeft(activeZhaoState:getCD())
                        end

                        -- 主动技能使用次数++ add by TangJian 2017/03/01 10:57:52
                        role:addActiveZhaoUseTimes(activeZhao:getId())
                        
                        -- 使用主动技能
                        self:callEventListener("useActiveZhao", role:getId(), target:getId(), activeZhao:getId())
                        
                        -- 招式帧加 1
                        role._currActiveFrame = role._currActiveFrame + 1
                        -- 判断前摇是否结束
                        if role._currActiveFrame > 0 then
                            -- 进入攻击帧
                            self.isIdleFrame = false -- 设置为静止帧
                            role._currActiveFrame = 1 -- 招式帧这只为1
                            role._currActiveState = 2 -- 进入攻击帧
                            LogSystem:log("旧版战斗：主动招式", "角色：",role:getName()," |主动招式前摇结束")
                        else
                            LogSystem:log("旧版战斗：主动招式", "角色：",role:getName()," |主动招式前摇中")
                        end
                    else
                        LogSystem:log("旧版战斗：主动招式", "角色：",role:getName()," |静止帧, 主动招式前摇中")
                    end
                end,
                [2] = function()
                    -- 第一帧执行操作
                    if role._currActiveFrame == 1 then
                        -- 主动技能
                        self:roleActiveZhao(role, target, activeZhao)

                        -- 附加动画隐藏 add by TangJian 2017/04/08 11:53:22                    
                        self:callEventListener("setRoleAllAdditionalAnimEnabled", role, false)
                    end
                    
                    role._currActiveFrame = role._currActiveFrame + 1
                    
                    -- 攻击完成
                    if role._currActiveFrame > activeZhao:getDuration() then
                        self.isIdleFrame = false -- 设置为静止帧
                        role._currActiveFrame = 1 -- 招式帧这只为1
                        role._currActiveState = 3 -- 进入后摇

                        -- 附加动画显示 add by TangJian 2017/04/08 11:53:22                    
                        self:callEventListener("setRoleAllAdditionalAnimEnabled", role, true)
                    end
                end,
                [3] = function()
                    -- 招式帧加 1
                    role._currActiveFrame = role._currActiveFrame + 1
                    -- 判断前摇是否结束
                    if role._currActiveFrame > 0 then
                        -- 进入攻击帧
                        self.isIdleFrame = true -- 设置为静止帧
                        role._currActiveFrame = 1 -- 招式帧这只为1
                        role._currActiveState = 1 -- 进入前摇
                        
                        role._currActiveIndex = role._currActiveIndex + 1 -- 帧数增加

                        role:setCurrActiveZhao(nil)
                        self.currentZhaoWrapper = nil -- 当前招式设为nil
                        LogSystem:log("旧版战斗：主动招式", "角色：",role:getName()," |主动招式后摇结束")
                    else
                        LogSystem:log("旧版战斗：主动招式", "角色：",role:getName()," |主动招式后摇中")
                    end
                end,
            })
    end
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
            
            if odds >= self:random(1,100) then
                return true
            end
        end
    end

    return false
end
-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 触发事件监听
function Fight:callEventListener(eventName, ...)
    if eventName == "start" then
        self.fightLayer:onStart(...)
    elseif eventName == "hit" then
        self.fightLayer:roleHit(...)
    elseif eventName == "dodged" then
        self.fightLayer:roleDodged(...)
    elseif eventName == "parried" then
        self.fightLayer:roleParried(...)
    elseif eventName == "weaponjifei" then
        self.fightLayer:playjifeiWeaponAnim(...)
    elseif eventName == "weaponDaduan" then
        self.fightLayer:playDaduanWeaponAnim(...)
    elseif eventName == "changeWeapon" then
        self.fightLayer:playchangeWeaponAnim(...)
    elseif eventName == "jiaoxieEffect" then
        self.fightLayer:playJiaoXieEffectAnim(...)
    elseif eventName == "afterChangeWeapon" then 
        self.fightLayer:refreshIsPlayerButtonArea(...)
    elseif eventName == "activeZhao" then
        self.fightLayer:roleActiveZhao(...)
    elseif eventName == "refresh_tili" then
        self.fightLayer:refreshUI_tili(...)
    elseif eventName == "refreshUI" then
        self.fightLayer:refreshUI()
    elseif eventName == "fightEnd" then -- 战斗结束
        local winTeamId, roles = ...
        
        self.fightLayer:delayFunc(1, function()
            self.fightLayer:delayOnFinish(winTeamId, self.localRole, self.targetRole)
        end)
    elseif eventName == "roleEvent" then
        local roleId, roleEventName = ...
        if roleEventName == "setAttr" then
            self.fightLayer:refreshUI()
        else
            if PRINT_MODE == 1 then
                print("未实现的事件", eventName)
            end
        end
    elseif eventName == "roleDie" then
        self.fightLayer:roleDie(...)
    elseif eventName == "readyActiveZhao" then
        self.fightLayer:readyActiveZhao(...)
    elseif eventName == "useActiveZhao" then
        self.fightLayer:useActiveZhao(...)
    elseif eventName == "removeInvalidActiveZhao" then
        self.fightLayer:removeInvalidActiveZhao(...)
    elseif eventName == "updateActiveZhaoButton" then
        self.fightLayer:updateActiveZhaoButton(...)
    elseif eventName == "updateRoleBuff" then
        self.fightLayer:updateRoleBuff()
    elseif eventName == "setPlayer" then
        self.fightLayer:refreshButtonArea()
    elseif eventName == "unloadWeapon" then
        self.fightLayer:refreshIsPlayerButtonArea(...)
    elseif eventName == "Forget" then
        self.fightLayer:refreshIsPlayerButtonArea(...)
    elseif eventName == "beginEffect" then
        self.fightLayer:roleBeginEffect(...)
    elseif eventName == "endEffect" then
        self.fightLayer:roleEndEffect(...)
    elseif eventName == "doEffect" then
        self.fightLayer:roleDoEffect(...)
    
    -- 动画相关 add by TangJian 2017/04/08 11:46:24
    elseif eventName == "setRoleAllAdditionalAnimEnabled" then
        self.fightLayer:setRoleAllAdditionalAnimEnabled(...)
    -- 显示经脉印记动画
    elseif eventName == "activeJingMaiYinJi" then
        if IS_OPEN_PVP_JINGMAI == true then
            self.fightLayer:activeJingMaiYinJi(...)
        end
    elseif eventName == "inactiveJingMaiYinJi" then
        if IS_OPEN_PVP_JINGMAI == true then
            self.fightLayer:inactiveJingMaiYinJi(...)
        end
    elseif eventName == "printText" then
        print("=============printText==============")
        local tab = {...}
        Helper:print_lua_table(tab)
        self.fightLayer:printFightStatus( ... )
    elseif eventName == "popText" then
        self.fightLayer:rolePopNumber(...)
    --延时方法 
	elseif eventName == "popTextUP" then
        self.fightLayer:rolePopNumberUP(...)
    elseif eventName == "addRolesEffectChangeFunction" then      
        local func = ...
        self.fightLayer._rolesEffectChangeFM:addFunction(func)
    elseif eventName == "delayFunc" then
        local time ,func = ...
        self.fightLayer:delayFunc(time, func)
    elseif eventName == "updateBackground" then
        local backgroundId = ...

        if backgroundId == "orgin" and self.fightLayer._animFightLayer then
            backgroundId = self.fightLayer._animFightLayer:getOriginBackgroundId()
        end

        self.fightLayer:setAnimFightBackground(backgroundId)
    elseif eventName == "addNode" then
        local node = ...
        self.fightLayer:callUIMemFunc("addChild",node)
    elseif eventName == "changeRoleShadowSpriteEffect" then
        self.fightLayer:setRoleShadowSpriteEffectAnim(...)
    elseif eventName == "refreshRoleEffectText" then
        self.fightLayer:refreshRoleEffectText(...)
    elseif eventName == "playSelfKill" then
        self.fightLayer:selfKillDie(...)
    elseif eventName == "playWinAnim" then
        self.fightLayer:playWinAnim(...)
    else
        if PRINT_MODE == 1 then
            print("未实现的事件", eventName)
        end
    end
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 设置事件监听
function Fight:setEventListener(eventListener)
    self._eventListener = Helper:getDef(eventListener, EMPTY_FUNC)
end

function Fight:uiCallback(eventName)
    if eventName == "show" then
        -- 战斗UI已经准备就绪
        if self.room ~= nil then
            self.room:fightListener("init")
        end
    elseif eventName == "hide" then
        -- 战斗UI已经隐藏
    end
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 创建一个网络对战Fight
function Fight:createFight(role1Data, role2Data, firstNo, room, randomSeed)
    -- 构造Fight
    local fight = Fight:create(role1Data, role2Data, firstNo)
    fight:setRandomSeed(randomSeed)
    fight.room = room
    -- 创建一个FightLayer
    local PVPFightLayer = require("app.models.pvp1.PVPFightLayer")
    fight.fightLayer = PVPFightLayer:createFightLayer()
    fight.fightLayer:setFight(fight)
    fight.localRole:setAttr("tili", INITIAL_TILI)
    fight.targetRole:setAttr("tili", INITIAL_TILI)
    fight.state = "init"
    fight.initTime = GetLocalTime()
    return fight
end
-----------------------------------------------------------------------------------------------------------

function Fight:show()
    self.fightLayer:localShow()
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

function Fight:__printAutoZhaoInfo(fightRole,target,zhao,tiliConsume)
    LogSystem:log("旧版战斗：","攻击者 = ",fightRole:getName()," |受击者 = ", target:getName()," |主手武学id = ",zhao.atkSkId," |主手招式id = ",zhao.atkZhaoId)
    LogSystem:log("旧版战斗：","副手武学id = ",zhao.dblAtkSkId," |副手招式id = ",zhao.dblZhaoId)

     -- 根据气血攻击系数和防御系数计算伤害
    local finalAtk = zhao.atk
    local finalQiMaxAtk = zhao.qiMaxAtk

    local finalFactor = self:calAutoDamageFinalFactor(fightRole,target)
    LogSystem:log("旧版战斗：","伤害系数计算后攻击伤害 = ",finalAtk)
    finalAtk = finalAtk/finalFactor
    LogSystem:log("旧版战斗：","伤害系数计算前攻击伤害 = ",finalAtk)

    if fightRole:getAttr("qiMaxAtkFactor") ~= 1 then
        finalQiMaxAtk = finalQiMaxAtk / fightRole:getAttr("qiMaxAtkFactor")
    end

    LogSystem:log("旧版战斗：","主手气血伤害 = ",finalAtk - finalQiMaxAtk - zhao.doubleAtk," |主手气血上限伤害 = ", finalQiMaxAtk - zhao.doubleQiMaxAtk)
    LogSystem:log("旧版战斗：","副手气血伤害 = ",zhao.doubleAtk," |副手气血上限伤害 = ", zhao.doubleQiMaxAtk)

    LogSystem:log("旧版战斗：","攻击部位 = ",zhao.hitPosName)
    LogSystem:log("旧版战斗：","体力消耗 = ",tiliConsume)
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

--@desc: 被动招式释放校验,检查武学类型和持械类型是否一致
--@author:LvBin
--@time:2023-08-31 17:14:31
--@role:
	--@zhao: 
--@return
function Fight:autoZhaoVerify(role,zhao)
    local attackSkill = Skill:getSkill(zhao.atkSkId)

    if role:isArmed() and attackSkill:isWeaponAttack() then
        return role:getRole():checkSkillZhaoCanPreparedByWeaponSubType(zhao.atkSkId)
    elseif not role:isArmed() and attackSkill:isQuanJiaoAttack() then
        return true
    else
        print("--------Fight:autoZhaoVerify----------",role:isArmed(),attackSkill:isWeaponAttack(),attackSkill:isQuanJiaoAttack())
        return false
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

--@desc: 按权重随机选择
--@author:LvBin
--@time:2026-02-06 18:27:38
--@list: 待随机的原始列表
--@weightName: 权重字段名（可选），如果为空则直接用v作为权重
--@returnName: 返回值字段名（可选），如果为空则返回列表的key
--@return 返回一个指定的 ID / 键值
function Fight:RandomByWeight(list, weightName, returnName)
    local randomList = {}
    local totalWeight = 0
    for k, v in ipairs(list) do
        local weight, id
        if returnName == nil or returnName == "" then
            id = k
        else
            id = v[returnName]
        end
        if weightName == nil or weightName == "" then
            weight = v
        else
            weight = tonumber(v[weightName])
        end

        table.insert(randomList, {id = id, weight = weight})
        totalWeight = totalWeight + weight
    end
    local randomValue = self:randomAndSetSeed(1, totalWeight)
    for i, v in ipairs(randomList) do
        local weight = v.weight
        if weight > 0 then -- 大于0才做处理
            randomValue = randomValue - weight
            if randomValue <= 0 then
                return v.id
            end
        end
    end
    
    return nil
end

return Fight
0000000000000000