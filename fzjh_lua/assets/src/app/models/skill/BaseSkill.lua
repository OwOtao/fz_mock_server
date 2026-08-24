local SkillDamageAttrConf = require("app.FightSystem.Configuration.SkillDamageAttrConf")

local SkillConst = require("app.models.skill.SkillConst")

local SkillClassifyManager = require("app.FightSystem.FightSkill.SkillClassifyManager")

local BaseSkill =
    {
        type = SKILL_TYPE_BASE,
        name = "无名功法",
        
        methods = -- 可以准备的类型
        {
            SKILL_METHOD_TYPE_QUANJIAO,
            SKILL_METHOD_TYPE_DAO,
            SKILL_METHOD_TYPE_JIAN,
            SKILL_METHOD_TYPE_GUN,
            SKILL_METHOD_TYPE_ANQI,
            SKILL_METHOD_TYPE_ZHAOJIA,
            SKILL_METHOD_TYPE_NEIGONG,
            SKILL_METHOD_TYPE_QINGGONG,
        },
        
        factors = -- 各种系数
        {
            atk = 80, -- 攻击系数
            hitRate = 80, -- 命中系数
            def = 80, -- 防御系数
            parry = 80, -- 招架系数
            neili = 80, -- 内力系数
            dodge = 80, -- 闪避系数
            atkSpd = 80, -- 攻速系数
            HpRate = 60, --生命回复系数
            
            powerDamRate = 80, -- 伤害系数
            powerAtkRate = 80 -- 攻击系数
        },
        
        parryType = "普通", -- 招架类型
        skillDamageFactor = -- 招式伤害系数
        function(lv)
            return 0.2 + math.floor(lv / 20) * 0.015
        end,
        
        jialiAtk = -- 内力加力附加攻击
        function(neili)
            local atk
            if neili < 500 then
                atk = 0.4 * neili ^ 2
            else
                atk = 0.4 * 500 * neili
            end
            return atk
        end,
        
        autoSkills = -- 自动招式
        {
            -- {
            --     lv = 0, -- 需要武学等级
            --     atk = 0.5, -- 攻击加成
            --     hitRate = 0, -- 命中加成
            --     dam = 0, -- 附加伤害
            --     parry = 0, -- 招架加成
            --     dodge = 0, -- 闪避加成
            --     preDuration = 0.5, -- 前摇
            --     aftDuration = 1, -- 后摇
            --     damageType = "", -- 伤害类型
            --     action = "一招万里挑一" -- 描述
            -- }
        },
        useSkills = -- 手动招式
        {
            -- {
            --     name = "真武除邪",
            --     requirement =
            --     {
                
            --     }
            -- }
        },
        
        learn = -- 学习技能
        {
            potEfficiency = 0.83, -- 潜能转化效率
            requirement = -- 学习条件
            {-- 可以拥有多个条件，用数组存储
                {}
            }
        },
        
        printText =
        {
        
        }
    }

function BaseSkill:getName()
    return self.name
end

function BaseSkill:getDsc()
    return self.dsc
end

function BaseSkill:getMethods()
    return self.methods
end

function BaseSkill:getType()
    return self.type
end

function BaseSkill:getNoColorName()
    return self._NoColorName
end

function BaseSkill:getExp(lv)
    if not lv or type(lv) ~= "number" then
        print("BaseSkill:等级不存在或者不是数字类型")
        return
    end
    local exp
    if lv < 8 then
        exp = lv
    else
        exp = math.ceil((0.015 * lv ^ 3 + 1), 1)
    end
    return exp
end

function BaseSkill:canLianGong()
    return true
end

function BaseSkill:canBiGuan()
    return true
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/12/06 10:25:44
-- @desc 得到技能等级
local getLvCache = {}
function BaseSkill:getLv(exp)
    local lv = getLvCache[exp]
    if lv then
        return lv
    else
        if not exp or type(exp) ~= "number" then
            print("BaseSkill:经验值不存在或者不是数字类型")
            return 0
        end
        if exp < 8 then
            lv = exp
        else
            lv = ((exp - 1) / 0.015) ^ (1 / 3)
        end
        lv = Helper:mathFloor(lv)
        getLvCache[exp] = lv
        return lv
    end
end

-- 根据有效等级获取技能描述
function BaseSkill:getSkillDescForValid(lv)
    local Skill = require("app.models.skill.Skill")
    local skillLv = lv
    local list = Skill:getStageDscs()
    
    if self.id == "wuxingdunfa" then
        list = 
        {
            {lv = 99, dsc = "BLU新学乍用"},
            {lv = 199, dsc = "HIB初窥门径"},
            {lv = 299, dsc = "HIC运用自如"},
            {lv = 399, dsc = "GRN深入浅出"},
            {lv = 499, dsc = "HIY心领神会"},
            {lv = 599, dsc = "HIW精通玄妙"},
        }
    elseif self.type == SKILL_TYPE_SPECIAL or self.type == SKILL_TYPE_DUSHU then
        list = Skill:getStageDscs2()
    end
    local str = "初学乍练"
    for i = 1, #list do
        local stageDsc = list[i]
        if stageDsc and stageDsc.lv and skillLv > tonumber(stageDsc.lv) then
            str = stageDsc.dsc
        else
            str = stageDsc.dsc
            break
        end
    end
    return str
end

function BaseSkill:checkIsSpecialZhiShiSkill()
	if table.indexof(SkillConst.SpecialGrowUpZhiShiSkillList, self.id) then
		return true
	else
		return false
	end
end

function BaseSkill:getStageDsc(role)
    assert(role)
    local Skill = require("app.models.skill.Skill")
    
    local skillLv
    --特殊知识类武学（周公之术与溯源诀）
    if self:checkIsSpecialZhiShiSkill() then
        skillLv = role:getSpecialZhiShiSkillLv(self.id)
    else
        skillLv = role:getSkillLvWithRoleLvLimit(self.id)
    end

    local list = Skill:getStageDscs()
    
    if self.id == "wuxingdunfa" then
        list = 
        {
            {lv = 99, dsc = "BLU新学乍用"},
            {lv = 199, dsc = "HIB初窥门径"},
            {lv = 299, dsc = "HIC运用自如"},
            {lv = 399, dsc = "GRN深入浅出"},
            {lv = 499, dsc = "HIY心领神会"},
            {lv = 599, dsc = "HIW精通玄妙"},
        }
    elseif self.type == SKILL_TYPE_SPECIAL or self.type == SKILL_TYPE_DUSHU then
        list = Skill:getStageDscs2()
    end
    local str = "初学乍练"
    for i = 1, #list do
        local stageDsc = list[i]
        if stageDsc and stageDsc.lv and skillLv > tonumber(stageDsc.lv) then
            str = stageDsc.dsc
        else
            str = stageDsc.dsc
            break
        end
    end
    return str
end

function BaseSkill:getUseSkills()
    return self.useSkills
end

function BaseSkill:getAutoSkills()
    return self.autoSkills
end

-- 获得随机主动技能
function BaseSkill:getRandomAttackSkill()
    local autoSkill = nil
    if type(self.autoSkills) == "table" then
        autoSkill = self.autoSkills[math.random(1, #self.autoSkills)]
    end
    if autoSkill == nil then -- 使用默认招式
        autoSkill = Skill:getAutoSkill("jibenquanjiao")
    end
    return autoSkill
end

-- 判断skill可准备为的类型
function BaseSkill:canPrepareType(prepareType)
    if self.methods == nil then
        return false
    end
    for i, v in ipairs(self.methods) do
        if prepareType == v then
            return true
        end
    end
    return false
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 通过手段获取基本武功
local methodToBaseSkill =
{
    
    [SKILL_METHOD_TYPE_QUANJIAO] = "jibenquanjiao", -- 拳脚
    [SKILL_METHOD_TYPE_NEIGONG] = "jibenneigong", -- 内功
    [SKILL_METHOD_TYPE_QINGGONG] = "jibenqinggong", -- 轻功
    [SKILL_METHOD_TYPE_ZHAOJIA] = "jibenzhaojia", -- 招架
    [SKILL_METHOD_TYPE_JIAN] = "jibenjianfa", -- 剑法
    [SKILL_METHOD_TYPE_DAO] = "jibendaofa", -- 刀法
    [SKILL_METHOD_TYPE_GUN] = "jibengunfa", -- 棍法
    [SKILL_METHOD_TYPE_ANQI] = "jibenanqi", -- 暗器
    [SKILL_METHOD_TYPE_BIANFA] = "jibenbianfa", -- 鞭法
    [SKILL_METHOD_TYPE_SHUANGCHI] = "jibenshuangchi", -- 双持
    [SKILL_METHOD_TYPE_QIN] = "jibenqinfa", -- 琴
}
function BaseSkill:getBaseSkillNameByMethod(method)
    return methodToBaseSkill[method]
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 通过手段获取基本武功
function BaseSkill:getBaseSkillByMethod(method)
    local Skill = require("app.models.skill.Skill")
    local baseAttackSkill = Skill:getSkill(self:getBaseSkillNameByMethod(self:getAttackMethod()))
    return baseAttackSkill
end

local methodList = {
    [SKILL_METHOD_TYPE_QUANJIAO] = true,
    [SKILL_METHOD_TYPE_GUN] = true,
    [SKILL_METHOD_TYPE_JIAN] = true,
    [SKILL_METHOD_TYPE_DAO] = true,
    [SKILL_METHOD_TYPE_ANQI] = true,
    [SKILL_METHOD_TYPE_BIANFA] = true,
    [SKILL_METHOD_TYPE_SHUANGCHI] = true,
    [SKILL_METHOD_TYPE_QIN] = true,
}
-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 获得攻击手段
function BaseSkill:getAttackMethod()
    for i, method in ipairs(self.methods) do
        if methodList[method] == true then
            return method
        end
    end
    -- print(self.id .. "没有攻击手段 !!!!!!!!!!!!!!!!!!!!!!")
    -- 没有攻击手段
    return nil
end

--[[
    @desc: 判断武学是否为攻击类型武学
    author:TangJian
    time:2022-09-16 17:43:46
    @return:
]]
function BaseSkill:isAttackSkill()
    for i, method in ipairs(self.methods) do
        if methodList[method] == true then
            return true
        end
    end
    return false
end

-- 获取系数
function BaseSkill:getFactor(name)
    if not name then
        return 0
    end
    local result = self.factors[name]
    if not result then
        if PRINT_MODE == 1 then
            print("没有这个系数" .. name)
        end
        return 0
    end
    return result
end

function BaseSkill:getPotEfficiency(role)
    if not self.learn.potEfficiency then
        return 80
    end
    return self.learn.potEfficiency * (200 + role:getFinalAttr("currInt")) / 200
end

function BaseSkill:getLearnPotEfficiency()
    return self.learn.potEfficiency or 80
end

-- 获取需要潜能点
function BaseSkill:getNeedExp(lv, num)
    if not num then
        return 0
    end
    local needExp = self:getExp(lv + num) - self:getExp(lv)
    if not needExp then
        return 0
    end
    return needExp
end

function BaseSkill:getRequirement()
    return self.learn.requirement
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 通过招式序列, 得到攻击招式
function BaseSkill:getAttackZhao(index,role)
    index = Helper:getRange(index, 1, #self.autoSkills)
    local attackZhao = clone(self.autoSkills[index])
    
    if attackZhao.anims == nil then
        attackZhao.anims = self:getRandomAttackZhaoAnim(1)
    end

    --根据武器子类型改造anims
    local newAnims = {}
    local subType = role:getCurrSubtypeByWeapon()

    for i,v in ipairs(attackZhao.anims) do
        if v[subType] then
            table.insert( newAnims,v[subType])
        end
    end

    if #newAnims > 0 then
        attackZhao.anims = newAnims   
    end
    
    -- print("~~~~~~~~~~~~~~~~~~~~~~过招式序列, 得到攻击招式~~~~~~~~~~~~~~~~~~~~~~~~~")
    -- Helper:print_lua_table(attackZhao.anims)
    -- print("~~~~~~~~~~~~~~~~~~~~~~~~~~@@@@@@@@@@@@@@@@@@@@@@@@@@")

    return attackZhao
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/30 15:31:59
-- @desc 通过招式id, 得到攻击招式
function BaseSkill:getAttackZhaoById(id)
    local attackZhaos = self.autoSkills
    local attackZhao = nil
    
    for k, zhao in pairs(attackZhaos) do
        if zhao.id == id then
            attackZhao = inherit({}, zhao)
            break
        end
    end
    
    if attackZhao.anims == nil then
        attackZhao.anims = self:getRandomAttackZhaoAnim(1)
    end
    
    return assert(attackZhao)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/30 15:02:06
-- @desc 得到随机攻击招式
function BaseSkill:getRandomAttackZhao(role,ignoreLv)
    ignoreLv = Helper:getDef(ignoreLv, false)
    if not role then
        assert(nil, "BaseSkill:getRandomAutoSkill(role) -> 数据异常，未获取到角色")
        return
    end

    local roleSkill = role:getSkill(self.id)
    local skillLv
    if not roleSkill or not roleSkill.exp then
        skillLv = 0
    else
        skillLv = self:getLv(roleSkill.exp)
    end
    
    assert(type(self.autoSkills) == "table")
    
    local index = 1
    if ignoreLv then -- 忽略等级 add by TangJian 2016/11/16 17:13:57
        index = #self.autoSkills
    else
        for i, v in ipairs(self.autoSkills) do
            if v.lv > skillLv then
                break
            end
            index = i
        end
    end
    
    return self:getAttackZhao(math.random(1, index),role)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/30 15:12:37
-- @desc 得到随机攻击招式动画
function BaseSkill:getRandomAttackZhaoAnim(animCount)
    animCount = Helper:getDef(animCount, 1)
    -- local Skill = require("app.models.skill.Skill")
    local baseAttackSkill = Skill:getSkill(self:getBaseSkillNameByMethod(self:getAttackMethod()))
    local animArray = {}
    for i, zhao in ipairs(baseAttackSkill.autoSkills) do
        if zhao.anims and #zhao.anims == animCount then
            table.insert(animArray, zhao.anims)
        end
    end
    return Helper:tableCover({}, (assert(animArray[math.random(1, #animArray)]))) 
end

-- 得到随机的闪避招式action
function BaseSkill:getRandomDodgeSkill(role)
    local dodgeZhao = nil
    if type(self.dodgeSkills) == "table" and #self.dodgeSkills > 0 then
        dodgeZhao = self.dodgeSkills[math.random(1, #self.dodgeSkills)]
        if dodgeZhao == nil then
            local skill = Skill:getSkill("jibenqinggong")
            dodgeZhao = skill:getRandomDodgeSkill(role)
        end
    else
        local skill = Skill:getSkill("jibenqinggong")
        dodgeZhao = skill:getRandomDodgeSkill(role)
    end
    return assert(dodgeZhao, "dodgeZhao == nil")
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 获得闪避招式
function BaseSkill:getParryZhao(index)
    index = Helper:getRange(1, #self.parrySkills)
    return self.parrySkills[index]
end

-- 得到随机的招架招式action
function BaseSkill:getRandomParrySkill(role)
    local parryZhao = nil
    if type(self.parrySkills) == "table" and #self.parrySkills > 0 then
        parryZhao = self.parrySkills[math.random(1, #self.parrySkills)]
        if parryZhao == nil then
            local skill = Skill:getSkill("jibenzhaojia")
            parryZhao = skill:getRandomParrySkill(role)
        end
    else
        local skill = Skill:getSkill("jibenzhaojia")
        parryZhao = skill:getRandomParrySkill(role)
    end
    return assert(parryZhao, "parryZhao == nil")
end

-- 获得随机的攻击部位
function BaseSkill:getRandomAttackPositionPart()
    local attackPosition = Skill:getAttackPosition(self.id)
    assert(attackPosition)
    assert(type(attackPosition.parts) == "table", type(attackPosition))
    
    -- Helper:print_lua_table(attackPosition.parts)
    local randomIndex = math.random(1, #attackPosition.parts)
    return attackPosition.parts[randomIndex], attackPosition.realParts[randomIndex]
end

-- 技能是否已准备
function BaseSkill:isPrepared(type)
    local role = User:getRole()
    if type ~= nil then
        if self.id == role:getPrepareSkill(type) then
            return true
        end
    else
        local prepareSkills = role:getSkillPrepare()
        for pType, pSkillid in pairs(prepareSkills) do
            if self.id == pSkillid then
                return true
            end
        end
    end
    return false
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 获得站立动画
function BaseSkill:getStandAnimName(role)
    local animMap, animName, standAnim = {}, "", self.standAnim
    if self.standAnim == nil then
        local baseSkill = self:getBaseSkillByMethod(self:getAttackMethod())
        assert(baseSkill, "无法获取改武学的基础招式, SkillId = "..self.id)
        standAnim = baseSkill.standAnim
    else
    end

    animMap = string.split(standAnim, ";")
    if MapIsEmpty(animMap) == true then
        if PRINT_MODE == 1 then
            error(tostring(self.id).." :招式未填写站立动画")
        end
    else
        animName = animMap[math.random(1, Helper:getDef(#animMap, 1))]
    end

    if role and role._fight and role._fight._isPVP == true then  --pvp
        if #animMap>1 then 
            local e = 2.718
            local currentDataIndex=role._fight.currentDataIndex
            local randomSeed=role._fight:getRandomSeed()
            animName = animMap[math.floor((currentDataIndex+(currentDataIndex+randomSeed)^e))%(#animMap)+1]
        else
            animName = animMap[1] or ""
        end
    end

    if role and string.sub(animName,-1) == "_" then
        local weaponType2 = role:getCurrWeaponType2()
        if weaponType2 then
            animName = animName..weaponType2
        else
            print("animName = ",animName)
            if DEBUG_MODE == 1 then
                assert(weaponType2,"BaseSkill:getStandAnimName    weaponType2 = nil")
            end
        end
    end
    return animName
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 获得向前跳跃动画
function BaseSkill:getJumpForwardAnimName(role)
    local animName = self.jumpForwardAnim
    if self.jumpForwardAnim == nil then
        local baseSkill = self:getBaseSkillByMethod(self:getAttackMethod())
        animName = baseSkill:getJumpForwardAnimName()
        assert(animName, baseSkill.name .. ": getJumpForwardAnimName == nil")
    end

    if role and string.sub(animName,-1) == "_" then
        local weaponType2 = role:getCurrWeaponType2()
        if weaponType2 then
            animName = animName..weaponType2
        else
            print("animName = ",animName)
            if DEBUG_MODE == 1 then
                assert(weaponType2,"BaseSkill:getJumpForwardAnimName    weaponType2 = nil")
            end
        end
    end
    return animName
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 获得向后跳跃动画
function BaseSkill:getJumpBackwardAnimName(role)
    local animName = self.jumpBackwardAnim
    if self.jumpBackwardAnim == nil then
        local baseSkill = self:getBaseSkillByMethod(self:getAttackMethod())
        animName = baseSkill:getJumpBackwardAnimName()
        assert(animName, baseSkill.name .. ": getJumpBackwardAnimName == nil")
    end

    if role and string.sub(animName,-1) == "_" then
        local weaponType2 = role:getCurrWeaponType2()
        if weaponType2 then
            animName = animName..weaponType2
        else
            print("animName = ",animName)
            if DEBUG_MODE == 1 then
                assert(weaponType2,"BaseSkill:getJumpBackwardAnimName    weaponType2 = nil")
            end
        end
    end
    return animName
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2018/06/26 11:47:53
-- @params 
-- @desc 获得出场动画
function BaseSkill:getStartFightAnimId()
    local animName = self.actionid

    return self.actionid
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2018/06/26 20:18:19
-- @params 
-- @desc 获取出场动画所需时间
function BaseSkill:getStartFightAnimNeedTime()
    return Helper:getDef(self.framenumber, 0)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 基本受伤表
local BASE_HURT_ZHAOS =
    {
        [SKILL_METHOD_TYPE_QUANJIAO] =
        {
            {
                hitPos = "head", -- 闪躲部位: "head" or "chest or "foot"
                anim = "barehand-hurt-head", -- 受伤动画
                offset = -25, -- 闪躲移动位置
            },
            {
                hitPos = "chest", -- 闪躲部位: "head" or "chest or "foot"
                anim = "barehand-hurt-chest", -- 受伤动画
                offset = -50, -- 闪躲移动位置
            },
            {
                hitPos = "foot", -- 闪躲部位: "head" or "chest or "foot"
                anim = "barehand-hurt-foot", -- 受伤动画
                offset = -25, -- 闪躲移动位置
            }
        },
        -- [SKILL_METHOD_TYPE_JIAN] =
        -- {
        -- },
        -- [SKILL_METHOD_TYPE_DAO] =
        -- {
        -- },
        -- [SKILL_METHOD_TYPE_ANQI] =
        -- {
        -- },
        -- [SKILL_METHOD_TYPE_BIANFA] =
        -- {
        -- },
        default =
        {
            {
                hitPos = "head", -- 闪躲部位: "head" or "chest or "foot"
                anim = "barehand-hurt-head", -- 受伤动画
                offset = -25, -- 闪躲移动位置
            },
            {
                hitPos = "chest", -- 闪躲部位: "head" or "chest or "foot"
                anim = "barehand-hurt-chest", -- 受伤动画
                offset = -50, -- 闪躲移动位置
            },
            {
                hitPos = "foot", -- 闪躲部位: "head" or "chest or "foot"
                anim = "barehand-hurt-foot", -- 受伤动画
                offset = -25, -- 闪躲移动位置
            }
        }
    }

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 招架还分拿不同兵器时候的招架
function BaseSkill:getRandomBaseHurtZhaoByPosition(hitPos, attackMethod)    
    local selectHurtZhaos = switch(attackMethod, BASE_HURT_ZHAOS)
    assert(selectHurtZhaos, "attackMethod = " .. tostring(attackMethod) .. "BASE_PARRAY_ZHAOS = " .. tostring(BASE_PARRAY_ZHAOS) .. "selectHurtZhaos = " .. luaTableEncode(selectHurtZhaos))
    
    -- 攻击部位检测 add by TangJian 2017/03/18 16:11:31
    if hitPos == "head" or hitPos == "chest" or hitPos == "foot" then
    else
        print("异常的 hitPos = ", "[" .. tostring(hitPos) .. "]" )
        hitPos = "chest"
    end

    local hurtZhaos = {}
    for i, hurtZhao in ipairs(selectHurtZhaos) do
        if PRINT_MODE == 1 then
            print("hurtZhao.anim = " .. tostring(hurtZhao.anim))
            print("hitPos = " .. "[" .. hitPos .. "]")
            print("hurtZhao.hitPos = " .. "[" .. tostring(hurtZhao.hitPos) .. "]")
            print("hurtZhao.offset = " .. tostring(hurtZhao.offset))
        end
        if hurtZhao.hitPos == hitPos then
            table.insert(hurtZhaos, hurtZhao)
        end
    end    
    return assert(hurtZhaos[math.random(1, #hurtZhaos)], "返回攻击部位为空!!!!")
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 获得随机挨打招式动画
function BaseSkill:getRandomHurtZhaoByPosition(hitPos, attackMethod)
    return self:getRandomBaseHurtZhaoByPosition(hitPos, attackMethod)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 随机取一个闪躲招式动画
function BaseSkill:getRandomDodgeZhaoByPosition(hitPos)
    assert(hitPos)
    
    local dodgeZhaos = {}
    if self.dodgeSkills then
        for i, dodgeZhao in ipairs(self.dodgeSkills) do
            if PRINT_MODE == 1 then
                print("dodgeZhao.anim = " .. tostring(dodgeZhao.anim))
                print("dodgeZhao.hitPos = " .. tostring(dodgeZhao.hitPos))
                print("dodgeZhao.offset = " .. tostring(dodgeZhao.offset))
            end
            if dodgeZhao.hitPos == hitPos then
                table.insert(dodgeZhaos, dodgeZhao)
            end
        end
    end
    
    if PRINT_MODE == 1 then
        print("#dodgeZhaos = " .. tostring(#dodgeZhaos))
    end
    
    local dodgeZhao = nil
    if #dodgeZhaos > 0 then
        dodgeZhao = dodgeZhaos[math.random(1, #dodgeZhaos)]
    end
    
    -- if PRINT_MODE == 1 then
    -- 	print("dodgeZhao.anim = "..tostring(dodgeZhao.anim))
    -- 	print("dodgeZhao.hitPos = "..tostring(dodgeZhao.hitPos))
    -- 	print("dodgeZhao.offset = "..tostring(dodgeZhao.offset))
    -- end
    if PRINT_MODE == 1 then
        print("self.id = " .. tostring(self.id))
    end
    
    if dodgeZhao == nil and self.id ~= "jibenqinggong" then
        local Skill = require("app.models.skill.Skill")
        local jibenzhaojia = Skill:getSkill("jibenqinggong")
        dodgeZhao = jibenzhaojia:getRandomDodgeZhaoByPosition(hitPos)
    end
    return assert(dodgeZhao)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 基本招架表
local BASE_PARRAY_ZHAOS =
    {
        [SKILL_METHOD_TYPE_QUANJIAO] =
        {
            {
                id = 1,
                action = "结果「当」地一声被$p挡开了。",
                textColor = "YEL",
                anim = "barehand-defend-head1",
                hitPos = "head",
                offset = -50
            },
            {
                id = 2,
                action = "结果「当」地一声被$p挡开了。",
                textColor = "YEL",
                anim = "barehand-defend-chest1",
                hitPos = "chest",
                offset = -50
            },
            {
                id = 3,
                action = "结果「当」地一声被$p挡开了。",
                textColor = "YEL",
                anim = "barehand-defend-foot1",
                hitPos = "foot",
                offset = -50
            }
        },
        -- [SKILL_METHOD_TYPE_JIAN] =
        -- {
        -- },
        -- [SKILL_METHOD_TYPE_DAO] =
        -- {
        -- },
        -- [SKILL_METHOD_TYPE_ANQI] =
        -- {
        -- },
        -- [SKILL_METHOD_TYPE_BIANFA] =
        -- {
        -- },
        default =
        {
            {
                id = 1,
                action = "结果「当」地一声被$p挡开了。",
                textColor = "YEL",
                anim = "barehand-defend-head1",
                hitPos = "head",
                offset = -50
            },
            {
                id = 2,
                action = "结果「当」地一声被$p挡开了。",
                textColor = "YEL",
                anim = "barehand-defend-chest1",
                hitPos = "chest",
                offset = -50
            },
            {
                id = 3,
                action = "结果「当」地一声被$p挡开了。",
                textColor = "YEL",
                anim = "barehand-defend-foot1",
                hitPos = "foot",
                offset = -50
            }
        }
    }

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 招架还分拿不同兵器时候的招架
function BaseSkill:getRandomBaseParryZhaoByPosition(hitPos, attackMethod)
    local selectParryZhaos = switch(attackMethod, BASE_PARRAY_ZHAOS)
    assert(selectParryZhaos, "attackMethod = " .. tostring(attackMethod) .. "BASE_PARRAY_ZHAOS = " .. tostring(BASE_PARRAY_ZHAOS) .. "selectParryZhaos = " .. luaTableEncode(selectParryZhaos))
    
    local parryZhaos = {}
    for i, parryZhao in ipairs(selectParryZhaos) do
        if PRINT_MODE == 1 then
            print("parryZhao.anim = " .. tostring(parryZhao.anim))
            print("parryZhao.hitPos = " .. tostring(parryZhao.hitPos))
            print("parryZhao.offset = " .. tostring(parryZhao.offset))
        end
        if parryZhao.hitPos == hitPos then
            table.insert(parryZhaos, parryZhao)
        end
    end
    return assert(parryZhaos[math.random(1, #parryZhaos)])
end

-- 格挡动画表 add by TangJian 2016/11/23 19:33:41
local parryAnimMap =
    {
        [SKILL_METHOD_TYPE_QUANJIAO] = function(hitPos)
            return switch(hitPos,
                {
                    head = Helper:getRandomParam("barehand-defend-head1", "barehand-defend-head2"),
                    chest = Helper:getRandomParam("barehand-defend-chest1", "barehand-defend-chest2"),
                    foot = Helper:getRandomParam("barehand-defend-foot1", "barehand-defend-foot2"),
                    default = Helper:getRandomParam("barehand-defend-chest1", "barehand-defend-chest2")
                })
        end,
        [SKILL_METHOD_TYPE_JIAN] = function(hitPos)
            return switch(hitPos,
                {
                    head = "sword-defend-head",
                    chest = Helper:getRandomParam("sword-defend-chest", "sword-defend-chest2"),
                    foot = "sword-defend-foot",
                    default = Helper:getRandomParam("barehand-defend-chest1", "barehand-defend-chest2")
                })
        end,
        [SKILL_METHOD_TYPE_DAO] = function(hitPos)
            return switch(hitPos,
                {
                    head = "sword-defend-head",
                    chest = Helper:getRandomParam("sword-defend-chest", "sword-defend-chest2"),
                    foot = "sword-defend-foot",
                    default = Helper:getRandomParam("barehand-defend-chest1", "barehand-defend-chest2")
                })
        end,
        [SKILL_METHOD_TYPE_ANQI] = function(hitPos)
            return switch(hitPos,
                {
                    head = Helper:getRandomParam("barehand-defend-head1", "barehand-defend-head2"),
                    chest = Helper:getRandomParam("barehand-defend-chest1", "barehand-defend-chest2"),
                    foot = Helper:getRandomParam("barehand-defend-foot1", "barehand-defend-foot2"),
                    default = Helper:getRandomParam("barehand-defend-chest1", "barehand-defend-chest2")
                })
        end,
        [SKILL_METHOD_TYPE_GUN] = function(hitPos)
            return switch(hitPos,
                {
                    head = "sword-defend-head",
                    chest = Helper:getRandomParam("sword-defend-chest", "sword-defend-chest2"),
                    foot = "sword-defend-foot",
                    default = Helper:getRandomParam("barehand-defend-chest1", "barehand-defend-chest2")
                })
        end,
        [SKILL_METHOD_TYPE_BIANFA] = function(hitPos)
            return switch(hitPos,
                {
                    head = "bian-defend-head",
                    chest = "bian-defend-chest",
                    foot = "bian-defend-foot",
                    default = Helper:getRandomParam("barehand-defend-chest1", "barehand-defend-chest2")
                })
        end,
        [SKILL_METHOD_TYPE_SHUANGCHI] = function(hitPos)
            return switch(hitPos,
                {
                    head = "jqb_shuanghuan0010",
                    chest = "jqb_shuanghuan008",
                    foot = "jqb_shuanghuan009",
                    default = Helper:getRandomParam("barehand-defend-chest1", "barehand-defend-chest2")
                })
        end,
        [SKILL_METHOD_TYPE_QIN] = function(hitPos)
            return switch(hitPos,
                {
                    head = "barehand-defend-head3",
                    chest = "barehand-defend-chest3",
                    foot = "barehand-defend-foot3",
                    default = Helper:getRandomParam("barehand-defend-chest1", "barehand-defend-chest2")
                })
        end,
        default = function(hitPos)
            return switch(hitPos,
                {
                    head = Helper:getRandomParam("barehand-defend-head1", "barehand-defend-head2"),
                    chest = Helper:getRandomParam("barehand-defend-chest1", "barehand-defend-chest2"),
                    foot = Helper:getRandomParam("barehand-defend-foot1", "barehand-defend-foot2"),
                    default = Helper:getRandomParam("barehand-defend-chest1", "barehand-defend-chest2")
                })
        end
    }

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/23 19:48:53
-- @desc 通过攻击手段得到招架动画名
function BaseSkill:getParryAnimNameWithAttackMethodAndHitPos(attackMethod, hitPos)
    return switch(attackMethod, parryAnimMap, hitPos)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 随机取一个招架动画
function BaseSkill:getRandomParryZhaoByPosition(hitPos, attackMethod)
    -- 老的
    assert(hitPos)
    
    local parryZhaos = {}
    if self.parrySkills then
        for i, parryZhao in ipairs(self.parrySkills) do
            if PRINT_MODE == 1 then
                print("parryZhao.anim = " .. tostring(parryZhao.anim))
                print("parryZhao.hitPos = " .. tostring(parryZhao.hitPos))
                print("parryZhao.offset = " .. tostring(parryZhao.offset))
            end
            if parryZhao.hitPos == hitPos then
                table.insert(parryZhaos, parryZhao)
            end
        end
    end
    
    if PRINT_MODE == 1 then
        print("#parryZhaos = " .. tostring(#parryZhaos))
    end
    
    local parryZhao = nil
    if #parryZhaos > 0 then
        parryZhao = parryZhaos[math.random(1, #parryZhaos)]
    end
    
    if PRINT_MODE == 1 then
        if parryZhao then
            print("parryZhao.anim = " .. tostring(parryZhao.anim))
            print("parryZhao.hitPos = " .. tostring(parryZhao.hitPos))
            print("parryZhao.offset = " .. tostring(parryZhao.offset))
        else
            print("parryZhao 不存在")
        end
    end
    
    if PRINT_MODE == 1 then
        print("self.id = " .. tostring(self.id))
    end
    
    if parryZhao == nil then
        parryZhao = self:getRandomBaseParryZhaoByPosition(hitPos, attackMethod)
    end
    return assert(parryZhao)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 主动技能
function BaseSkill:getActiveZhao(zhaoName)
    local ActiveZhaoMap = require("app.models.skill.ActiveZhao")
    return ActiveZhaoMap["liumaishenjian"]
end


-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/03/09 17:25:54
-- @desc 得到平均攻击力
function BaseSkill:getAvgAtk()
    local avgAtk = 0
    if self.getAvgAtkCache == nil then
        local atk, count = 0, 0
        
        for k, v in pairs(self.autoSkills) do
            atk = atk + v.atk
            count = count + 1
        end
        avgAtk = atk / count
        self.getAvgAtkCache = avgAtk
    else
        avgAtk = self.getAvgAtkCache
    end
    return avgAtk
end

function BaseSkill:addExp(exp)
end

--@desc: 是否有多个攻击准备类型（例如一刀流，既能准备为剑又能准备为刀）,现在只有兵器类存在这种情况，只需要判断兵器类型
--@author:LvBin
--@time:2022-03-22 16:10:37
--@return
function BaseSkill:isMultiAttackPrepareType()
    if MapIsEmpty(self.methods) then
        return false
    end

    local multiAttackPrepareTypes = {}

    for i, v in ipairs(self.methods) do
        if v == SKILL_METHOD_TYPE_JIAN then
            table.insert(multiAttackPrepareTypes,{prepareType = "jianfa",name = "剑法"})
        elseif v == SKILL_METHOD_TYPE_DAO then
            table.insert(multiAttackPrepareTypes,{prepareType = "daofa",name = "刀法"})
        elseif v == SKILL_METHOD_TYPE_GUN then
            table.insert(multiAttackPrepareTypes,{prepareType = "gunfa",name = "棍法"})
        elseif v == SKILL_METHOD_TYPE_ANQI then 
            table.insert(multiAttackPrepareTypes,{prepareType = "anqi",name = "暗器"})
        elseif v == SKILL_METHOD_TYPE_BIANFA then 
            table.insert(multiAttackPrepareTypes,{prepareType = "bianfa",name = "鞭法"})
        elseif v == SKILL_METHOD_TYPE_SHUANGCHI then 
            table.insert(multiAttackPrepareTypes,{prepareType = "shuangchi",name = "双持"})
        elseif v == SKILL_METHOD_TYPE_QIN then 
            table.insert( multiAttackPrepareTypes,{prepareType = "qinfa",name = "乐器"})
        end
    end

    if #multiAttackPrepareTypes > 1 then
        return true,multiAttackPrepareTypes
    end

    return false,multiAttackPrepareTypes
end

function BaseSkill:isQuanJiaoAttack()
    if MapIsEmpty(self.methods) then
        return false
    end

    for i, v in ipairs(self.methods) do
        if v == SKILL_METHOD_TYPE_QUANJIAO then
            return true
        end
    end

    return false
end

function BaseSkill:isWeaponAttack()
    if MapIsEmpty(self.methods) then
        return false
    end

    for i, v in ipairs(self.methods) do
        if v == SKILL_METHOD_TYPE_JIAN or v == SKILL_METHOD_TYPE_DAO or v == SKILL_METHOD_TYPE_GUN or v == SKILL_METHOD_TYPE_ANQI or
        v == SKILL_METHOD_TYPE_BIANFA or v == SKILL_METHOD_TYPE_SHUANGCHI or v == SKILL_METHOD_TYPE_QIN then
            return true
        end
    end

    return false
end

function BaseSkill:isParrySkill()
    if MapIsEmpty(self.methods) then
        return false
    end

    for i, v in ipairs(self.methods) do
        if v == SKILL_METHOD_TYPE_ZHAOJIA then
            return true
        end
    end

    return false
end

function BaseSkill:getSkillTypes()
    local BasicSkillManager = require("app.models.skill.BasicSkill.BasicSkillManager")

    return BasicSkillManager:getBasicSkill(self.id):getSkillType()
end

function BaseSkill:getSkillThridTypes()
    local BasicSkillManager = require("app.models.skill.BasicSkill.BasicSkillManager")

    return BasicSkillManager:getBasicSkill(self.id):getClassifyThirdTypes()
end

function BaseSkill:getMcmrestrict()
    local skillId = nil

    local lv = 0

    if self.mcmrestrict == nil then
        return skillId,lv
    end

    local retList = {}

    local mentalList = string.split(self.mcmrestrict,",")

    skillId = mentalList[1]

    lv = tonumber(mentalList[2])

    if skillId == nil or lv == nil then
        error("武学门派心法限制配置错误 "..self.mcmrestrict)
    end

    return skillId,lv
end

--@desc: 是否是本门武学(不包括江湖武学)
--@author:LvBin
--@time:2023-10-08 14:41:54
--@familyId: 门派id
--@return
function BaseSkill:isSectSkill(familyId)
	local skillFamily = self.familyId
	
	if skillFamily == nil then
		return false
	end

    local skillFamilyList = string.split(skillFamily,"#")

    for i,v in ipairs(skillFamilyList) do
        if familyId == v then
            return true
        end
    end

    return false
end

--@desc: 是否是江湖武学
--@author:LvBin
--@time:2023-11-18 20:06:53
--@return
function BaseSkill:isJiangHuSkill()
    return self.familyId == nil
end

--@desc: 是否是外门武学(不是江湖武学不是本门武学就是外门武学)
--@author:LvBin
--@time:2023-11-18 20:20:20
--@familyId: 
--@return
function BaseSkill:isUnSectSkill(familyId)
	return not self:isJiangHuSkill() and not self:isSectSkill(familyId)
end

--@desc: 获取武学伤害属性类型
--@author:LvBin
--@time:2024-09-19 11:57:00
--@return
function BaseSkill:getAtkDamageClass()
    return self.autoZhaoAtkDamageClass
end

--@desc: 获取武学招架防御伤害属性类型
--@author:LvBin
--@time:2024-09-19 17:38:18
--@return
function BaseSkill:getDefDamageClass()
    return self.zhaoJiaDefDamageClass
end

--@desc: 获取武学招架防御伤害属性系数
--@author:LvBin
--@time:2024-09-19 17:38:36
--@return
function BaseSkill:getDefDamageParam()
    return self.zhaoJiaDefDamageParam
end

--@desc: 获取武学伤害属性类型名称
--@author:LvBin
--@time:2024-09-19 15:42:16
--@return
function BaseSkill:getDamageClassName()
    if self:getAtkDamageClass() then
        return SkillDamageAttrConf:getDamageClassName(self:getAtkDamageClass())
    else
        return nil
    end
end

--@desc: 获取武学防御属性类型名称
--@author:LvBin
--@time:2024-09-19 15:42:16
--@return
function BaseSkill:getDefClassName()
    if self:getDefDamageClass() then
        return SkillDamageAttrConf:getDamageClassName(self:getDefDamageClass())
    else
        return nil
    end
end

--@desc: 是否为内功
--@author:LvBin
--@time:2024-08-08 15:17:46
--@return
function BaseSkill:isNeiGong()
	local methods = self.methods

	if MapIsEmpty(methods) == false then
		for k,v in pairs(methods) do
			if v == SKILL_METHOD_TYPE_NEIGONG then
				return true
			end
		end
	end
    
	return false
end

--@desc: 获取武学兵器准备类型
--@author:LvBin
--@time:2024-08-09 16:00:06
--@return
function BaseSkill:getBingQiPrepareTypes()
    local skillTypes = self:getSkillTypes()

    local bqPrepareTypes = {}

    for _,classifyId in ipairs(skillTypes) do
        local firstType = SkillClassifyManager:getClassifyFirstType(classifyId)

        if SkillClassifyManager:isBingQiSkllTypeByFirstType(firstType) then
            local secondType = SkillClassifyManager:getClassifySecondType(classifyId)

            local prepareType = SkillClassifyManager:getBingQiPrepareTypeBySecondType(secondType)

            table.insert(bqPrepareTypes,prepareType)
        end
    end

    return bqPrepareTypes
end

--[[
    @desc: 武学所属门派
    author:tanqinjian
    time:2025-05-15 11:29:37
    @return: array {familyId1, familyId2,...},江湖为{}
]]
function BaseSkill:getBelongFamily()
    local skillFamily = self.familyId
	
	if skillFamily == nil then
		return {}
	end

    local skillFamilyList = string.split(skillFamily,"#")

    return skillFamilyList
end

BaseSkill.isEncrypted = true
return BaseSkill
0000000