local Skill = require("app.models.skill.Skill")
local Role = require("app.models.role.Role")
local FightRoleJingMai = require("app.models.fight.FightRoleJingMai")
local Meridian = require("app.models.Meridian.Meridian")
local PoisonUtil = require("app.models.Poison.PoisonUtil")
local SelfCreatedSkillManager = require("app.models.SelfCreatedSkillSystem.SelfCreatedSkillManager.SelfCreatedSkillManager")
local FightConfig = require("app.models.fight.FightConfig")
local LogSystem = require("app.models.LogSystem.LogSystem")
local EffectConst = require("app.models.fight.Effect.EffectConst") 
local EnterEffect = require("app.models.skill.EnterEffect")
local AnimResManager = require("app.FightSystem.ResourceManager.AnimResManager")

local jingmaiTestSwitch = false

local jingmaiMap =
    {
        dongxuanyin = {name = "百剑不侵", desc = "对阵装备剑类武器的对手时，提升一定防御力",
            type = "属性加成",
            getAdditionalAttr = function(role, target, attrName, attrValue)
                if attrName == "_defRateFactor" then
                    if target:getAttackMethod() == SKILL_METHOD_TYPE_JIAN then
                        if DEBUG_MODE == 1 then
                            return attrValue * 100 / 100
                        end
                        return attrValue * 5 / 100
                    end
                end
                return 0
            end},
        dongzhenyin = {name = "刀术克制", desc = "对阵装备刀类武器的对手时，提升一定防御力",
            type = "属性加成",
            getAdditionalAttr = function(role, target, attrName, attrValue)
                if attrName == "_defRateFactor" then
                    if target:getAttackMethod() == SKILL_METHOD_TYPE_DAO then
                        if DEBUG_MODE == 1 then
                            return attrValue * 100 / 100
                        end
                        return attrValue * 5 / 100
                    end
                end
                return 0
            end},
        dongyuanyin = {name = "枪棒克制", desc = "对阵装备棍类武器的对手时，提升一定防御力",
            type = "属性加成",
            getAdditionalAttr = function(role, target, attrName, attrValue)
                if attrName == "_defRateFactor" then
                    if target:getAttackMethod() == SKILL_METHOD_TYPE_GUN then
                        if DEBUG_MODE == 1 then
                            return attrValue * 100 / 100
                        end
                        return attrValue * 5 / 100
                    end
                end
                return 0
            end},
        dongkongyin = {name = "鞭长莫及", desc = "对阵装备鞭子类武器的对手时，提升一定防御力",
            type = "属性加成",
            getAdditionalAttr = function(role, target, attrName, attrValue)
                if attrName == "_defRateFactor" then
                    if target:getAttackMethod() == SKILL_METHOD_TYPE_BIANFA then
                        if DEBUG_MODE == 1 then
                            return attrValue * 100 / 100
                        end
                        return attrValue * 5 / 100
                    end
                end
                return 0
            end},
        dongtiyin = {name = "以静制动", desc = "对阵装备暗器类武器的对手时，提升一定防御力",
            type = "属性加成",
            getAdditionalAttr = function(role, target, attrName, attrValue)
                if attrName == "_defRateFactor" then
                    if target:getAttackMethod() == SKILL_METHOD_TYPE_ANQI then
                        if DEBUG_MODE == 1 then
                            return attrValue * 100 / 100
                        end
                        return attrValue * 5 / 100
                    end
                end
                return 0
            end},
        dongyiyin = {name = "拳掌克制", desc = "对阵空手的对手时，提升一定防御力",
            type = "属性加成",
            getAdditionalAttr = function(role, target, attrName, attrValue)
                if attrName == "_defRateFactor" then
                    if target:getAttackMethod() == SKILL_METHOD_TYPE_QUANJIAO then
                        if DEBUG_MODE == 1 then
                            return attrValue * 100 / 100
                        end
                        return attrValue * 5 / 100
                    end
                end
                return 0
            end},

        linggangyin = {name = "怒气翻涌", desc = "战斗中，当气血低于30%时，所有技能的内力消耗降低",
            type = "属性加成",
            getAdditionalAttr = function(role, target, attrName, attrValue)
                if attrName == "_neiliConsumeFactor" then
                    if role:getAttr("qiPercent") <= 30 then
                        return -attrValue * 50 / 100
                    end
                end
                return 0
            end},
        yungangyin = {name = "绝处逢生", desc = "战斗中，当气血低于30%时，提升一定闪躲力",
            type = "属性加成",
            getAdditionalAttr = function(role, target, attrName, attrValue)
                if attrName == "_dodgeRateFactor" then
                    if role:getAttr("qiPercent") <= 30 then
                        if DEBUG_MODE == 1 then
                            return attrValue * 200 / 100
                        end
                        return attrValue * 20 / 100
                    end
                end
                return 0
            end},
        fenggangyin = {name = "见招拆招", desc = "战斗中，当气血低于30%时，提升一定招架",
            type = "属性加成",
            getAdditionalAttr = function(role, target, attrName, attrValue)
                if attrName == "_parryRateFactor" then
                    if role:getAttr("qiPercent") <= 30 then
                        if DEBUG_MODE == 1 then
                            return attrValue * 200 / 100
                        end
                        return attrValue * 20 / 100
                    end
                end
                return 0
            end},
        digangyin = {name = "不动如山", desc = "战斗中，当气血低于30%时，提升一定防御",
            type = "属性加成",
            getAdditionalAttr = function(role, target, attrName, attrValue)
                if attrName == "_defRateFactor" then
                    if role:getAttr("qiPercent") <= 30 then
                        if DEBUG_MODE == 1 then
                            return attrValue * 200 / 100
                        end                        
                        return attrValue * 10 / 100
                    end
                end
                return 0
            end},
        tiangangyin = {name = "背水一战", desc = "战斗中，当气血低于30%时，提升一定攻击",
            type = "属性加成",
            getAdditionalAttr = function(role, target, attrName, attrValue)
                if attrName == "_qiAtkFactor" then
                    if role:getAttr("qiPercent") <= 30 then
                        if DEBUG_MODE == 1 then
                            return attrValue * 200 / 100
                        end
                        return attrValue * 10 / 100
                    end
                end
                return 0
            end},

        zhengtiyin = {name = "嫉恶如仇", desc = "对阵侠义正义值低于自己的对手时，提升一定命中",
            type = "属性加成",
            getAdditionalAttr = function(role, target, attrName, attrValue)
                if attrName == "_hitRateFactor" then
                    if role:getAttr("zhengqi") > target:getAttr("zhengqi") then
                        if DEBUG_MODE == 1 then
                            return attrValue * 200 / 100
                        end
                        return attrValue * 10 / 100
                    end
                end
                return 0
            end},
        zhengxingyin = {name = "邪魔不侵", desc = "对阵侠义正义值低于自己的对手时，提升一定格挡",
            type = "属性加成",
            getAdditionalAttr = function(role, target, attrName, attrValue)
                if attrName == "_parryRateFactor" then
                    if role:getAttr("zhengqi") > target:getAttr("zhengqi") then
                        if DEBUG_MODE == 1 then
                            return attrValue * 200 / 100
                        end
                        return attrValue * 10 / 100
                    end
                end
                return 0
            end},
        zhengmingyin = {name = "邪不近身", desc = "对阵侠义正义值低于自己的对手时，提升一定闪躲",
            type = "属性加成",
            getAdditionalAttr = function(role, target, attrName, attrValue)
                if attrName == "_dodgeRateFactor" then
                    if role:getAttr("zhengqi") > target:getAttr("zhengqi") then
                        if DEBUG_MODE == 1 then
                            return attrValue * 200 / 100
                        end
                        return attrValue * 10 / 100
                    end
                end
                return 0
            end},
        dangxieyin = {name = "邪气凛然", desc = "对阵侠义正义值高于自己的对手时，提升一定命中",
            type = "属性加成",
            getAdditionalAttr = function(role, target, attrName, attrValue)
                if attrName == "_hitRateFactor" then
                    if role:getAttr("zhengqi") < target:getAttr("zhengqi") then
                        if DEBUG_MODE == 1 then
                            return attrValue * 200 / 100
                        end
                        return attrValue * 10 / 100
                    end
                end
                return 0
            end},
        ganxieyin = {name = "正不压邪", desc = "对阵侠义正义值高于自己的对手时，提升一定格挡",
            type = "属性加成",
            getAdditionalAttr = function(role, target, attrName, attrValue)
                if attrName == "_parryRateFactor" then
                    if role:getAttr("zhengqi") < target:getAttr("zhengqi") then
                        if DEBUG_MODE == 1 then
                            return attrValue * 200 / 100
                        end
                        return attrValue * 10 / 100
                    end
                end
                return 0
            end},
        dengxieyin = {name = "魔高一丈", desc = "对阵侠义正义值高于自己的对手时，提升一定闪躲",
            type = "属性加成",
            getAdditionalAttr = function(role, target, attrName, attrValue)
                if attrName == "_dodgeRateFactor" then
                    if role:getAttr("zhengqi") < target:getAttr("zhengqi") then
                        if DEBUG_MODE == 1 then
                            return attrValue * 200 / 100
                        end
                        return attrValue * 10 / 100
                    end
                end
                return 0
            end},

        -- 使用主动技能 add by TangJian 2017/04/25 02:51:15
        zhenliuyin = {name = "灵犀造化", desc = "战斗中使用主动技能时，有几率不消耗内力",
            type = "使用主动技能",
            func = function(role, target, activeZhao)
                if role._fight then
                    if jingmaiTestSwitch or 20 >= (role._fight._currFrame % 100 + 1) then
                        role:addAttr("neili", activeZhao:getFinalCost())
                        PopText("灵犀造化 不消耗内力!!!")
                    end
                end
            end},
        zhenyiyin = {name = "羚羊挂角", desc = "战斗中使用主动技能时，有几率立即重置CD",
            type = "使用主动技能",
            func = function(role, target, activeZhao)
                if role._fight then
                    if jingmaiTestSwitch or 30 >= (role._fight._currFrame % 100 + 1) and (role._fight._currFrame % 100 + 1) >= 21 then
                        activeZhao:setCDLeft(0)
                        PopText("羚羊挂角 重置cd!!!")
                    end
                end
            end},
        zhenfengyin = {name = "三花聚顶", desc = "战斗中使用主动技能时，有几率恢复一定内力",
            type = "使用主动技能",
            func = function(role, target, activeZhao)
                if role._fight and role:getAttr("neili") < role:getFinalAttr("neiliMax") then
                    if jingmaiTestSwitch or 40 >= (role._fight._currFrame % 100 + 1) >= 31 then
                        local addValue = math.floor(role:getFinalAttr("neiliMax") * 20 / 100)
                        if addValue + role:getAttr("neili") > role:getFinalAttr("neiliMax") then
                            addValue = math.floor(role:getFinalAttr("neiliMax") - role:getAttr("neili"))
                        end  
                        role:addAttr("neili", addValue)
                        PopText("三花聚顶 回复内力" .. addValue)
                    end
                end
            end},
        zhenhuoyin = {name = "妙手回春", desc = "战斗中使用主动技能时，有几率恢复一定气血",
            type = "使用主动技能",
            func = function(role, target, activeZhao)
                if role._fight and role:getAttr("qi") < role:getCurrQiMax() then
                    if jingmaiTestSwitch or 50 >= (role._fight._currFrame % 100 + 1) and (role._fight._currFrame % 100 + 1) >= 41 then
                        local addValue = math.floor(role:getFinalAttr("qiMax") * 10 / 100)
                        if addValue + role:getAttr("qi") > role:getCurrQiMax() then
                            addValue = math.floor(role:getCurrQiMax() - role:getAttr("qi"))
                        end  
                        role:addAttr("qi", addValue)
                        PopText("妙手回春 回复气血" .. addValue)
                    end
                end
            end},
        zhengangyin1 = {name = "招招致命", desc = "战斗中使用主动技能时，有几率提升一定攻击",
            type = "使用主动技能",
            func = function(role, target, activeZhao)
                local roledata = User:getRole()
                local zhao = role:createZhaoForPVP(target)
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
                zhao.hitType, zhao.atk, zhao.qiMaxAtk, zhao.neiliConsume, zhao.hitPosName = role:createAttackResult(role, target, attackSkill, attackZhao, doubleAttackSkill, doubleAttackZhao, zhao.mn1, zhao.mn2)
                if role._fight then
                    if jingmaiTestSwitch or 60 >= (role._fight._currFrame % 100 + 1) and (role._fight._currFrame % 100 + 1) >= 51 then
                        local addValue = role:getAttr("qiAtkFactor") * 5 / 100
                        local addatk = math.floor( zhao.atk * addValue )
                        role:addAttr("qiAtkFactor", addValue)
                        PopText("招招致命 提升攻击" .. addatk)
                    end
                end
            end},

        -- 逃跑 add by TangJian 2017/04/25 02:50:57
        pifengyin = {name = "卷土重来", desc = "战斗中逃跑，有几率恢复一定内力",
            type = "逃跑",
            func = function(role, target, activeZhao)
                if role._fight and role:getAttr("neili") < role:getFinalAttr("neiliMax") then
                    if jingmaiTestSwitch or 20 >= (role._fight._currFrame % 100 + 1) then
                        local addValue = math.floor(role:getFinalAttr("neiliMax") * role._fight:random(20, 50) / 100)
                        if addValue + role:getAttr("neili") > role:getFinalAttr("neiliMax") then
                            addValue = math.floor(role:getFinalAttr("neiliMax") - role:getAttr("neili"))
                        end
                        role:addAttr("neili", addValue)
                        PopText("卷土重来 回复内力" .. addValue)
                    end
                end
            end},
        pihuoyin = {name = "败而不倒", desc = "战斗中逃跑，有几率恢复一定气血",
            type = "逃跑",
            func = function(role, target, activeZhao)
                if role._fight and role:getAttr("qi") < role:getCurrQiMax() then
                    if jingmaiTestSwitch or 40 >= (role._fight._currFrame % 100 + 1) and (role._fight._currFrame % 100 + 1) >= 21 then
                        local addValue = math.floor(role:getFinalAttr("qiMax") * role._fight:random(20, 50) / 100)
                        role:addAttr("qi", addValue)
                        PopText("败而不倒 回复气血" .. addValue)
                    end
                end
            end},
        pileiyin = {name = "金蝉脱壳", desc = "战斗中逃跑，有几率立即治愈伤势",
            type = "逃跑",
            func = function(role, target, activeZhao)
                if role._fight then
                    if jingmaiTestSwitch or 60 >= (role._fight._currFrame % 100 + 1) and (role._fight._currFrame % 100 + 1) >= 41 then
                        PopText("金蝉脱壳 立即恢复")
                    end
                end
            end},

        -- 击杀敌人 add by TangJian 2017/04/25 02:50:48
        xiuhuoyin = {name = "以战养战", desc = "战斗中击杀敌人，有几率立即恢复一定气血",
            type = "击杀敌人",
            func = function(role, target)
                if role._fight and role:getAttr("qi") < role:getCurrQiMax() then
                    if jingmaiTestSwitch or 10 >= (role._fight._currFrame % 100 + 1) then
                        local addValue = math.floor(role:getFinalAttr("qiMax") * role._fight:random(20, 50) / 100)
                        if addValue + role:getAttr("qi") > role:getCurrQiMax() then
                            addValue = math.floor(role:getCurrQiMax() - role:getAttr("qi"))
                        end
                        role:addAttr("qi", addValue)
                        PopText("以战养战 气血 回复" .. addValue)
                    end
                end
            end},
        xiufengyin = {name = "枯木逢春", desc = "战斗中击杀敌人，有几率立即恢复一定内力",
            type = "击杀敌人",
            func = function(role, target)
                if role._fight and role:getAttr("neili") < role:getFinalAttr("neiliMax") then
                    if jingmaiTestSwitch or 20 >= (role._fight._currFrame % 100 + 1) and (role._fight._currFrame % 100 + 1) >= 11 then
                        local addValue = math.floor(role:getFinalAttr("neiliMax") * role._fight:random(20, 50) / 100)
                        if addValue + role:getAttr("neili") > role:getFinalAttr("neiliMax") then
                            addValue = math.floor(role:getFinalAttr("neiliMax") - role:getAttr("neili"))
                        end
                        role:addAttr("neili", addValue)
                        PopText("枯木逢春 内力 回复" .. addValue)
                    end
                end
            end},
        xiuleiyin = {name = "越战越勇", desc = "战斗中击杀敌人，有几率立即治愈伤势",
            type = "击杀敌人",
            func = function(role, target)
                if role._fight and role:getAttr("qiPercent") ~= 1 then
                    if jingmaiTestSwitch or 30 >= (role._fight._currFrame % 100 + 1) and (role._fight._currFrame % 100 + 1) >= 21 then
                        -- local addValue = role:getAttr("qiAtk") * 5 / 100
                        -- role:addAttr("qiAtk", addValue)
                        role:setAttr("qiPercent", 1)
                        PopText("越战越勇 立即治愈伤势")
                    end
                end
            end},

        -- 特殊 add by TangJian 2017/04/25 02:51:36
        zuoyouhuboyin = {name = "左右互搏印", desc = "获得左右互搏印"},
        jiemaiyin = {name = "截脉印", desc = "获得截脉印"},
    }

local FightRole = {}

-- 一个只存在于PVPFight中的角色
-- @roleData 通过table源数据来构造一个PVPRole
function FightRole:create(roleData)
    local r = clone(FightRole)
    r:init()
    r:setData(roleData)
    r:setFightId(roleData.id)
    return r
end

-- 通过一个zhaoId计算出对target的所有数值，这个数值包含了攻击、回血、护盾等等
-- 但一定要包含造成这个结果。例如，如果是回血，那么就要带上最终生命值和内力值，
-- 这个值是用来告知给服务器的
-- @zhaoId 由这个角色生成的招式
-- @target 一个FightRole对象，这个招式作用的对象，如果是给自己的那么target就是自己，如果是对方，target就是对方
-- @return 招式数值table
function FightRole:computeZhaoValue(zhaoId, target)

end

-- @return number类型，返回一个角色生成的被动招式id
function FightRole:getZhaoByAuto()

end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 初始化
function FightRole:init()
    defVars(self,
        {
            _readyActiveZhaoId = {"ReadyActiveZhaoId", nil}, -- 准备的主动招式id
            _state = {"State", "正常"},
            _cacheMap = {"CacheMap", CacheMap:create()}, -- 缓存地图
            _isNeedNeili = {"IsNeedNeili", true}, -- 是否需要内力 add by TangJian 2017/03/22 16:27:59
        })

    self._activeZhaoUseTimesMap = {} -- 主动招式使用次数表

    self._eventListener = EMPTY_FUNC -- 时间监听

    self._fightId = nil -- 战斗id

    self._isPlayer = false -- 是否是玩家

    self._data = nil -- 角色数据

    self._currFrame = 0 --当前帧

    self._targetId = nil -- 当前目标id

    self._isWaitingTili = false -- 等待体力恢复

    -- 主动招式状态
    self._currActiveState = 1 -- 当前主动招式状态
    self._currActiveIndex = 1 -- 当前主动招式位置
    self._currActiveFrame = 1 -- 当前合主动招式帧

    -- 被动招式状态
    self._currZhaoState = 0 -- 当前招式状态
    self._currZhaoIndex = 0 -- 当前招式位置
    self._currZhaoFrame = 1 -- 当前招式帧

    self._currWeaponId = nil -- 当前武器Id
    self._currAttackSkill = nil -- 当前攻击技能
    self._currAttackZhao = nil -- 当前攻击招式
    self._currDoubleAttackSkill = nil -- 当前互备技能
    self._currDoubleAttackZhao = nil -- 当前互备招式

    self._currAutoZhaoTimes = 0 -- 当前出招数

    self._autoTable = {}-- 角色被动招式表
    self._activeTable = {}-- 角色主动招式表

    self._preparedActiveZhaoMap = {}-- 准备的主动技能地图
    self._currActiveZhaoStateMap = {}-- 当前主动技能执行状况

    -- 效果表
    self._effectMap = {}-- 效果表
    self._effectArray = {}-- 效果数组0

    self._isDead = false -- 是否死亡

    -- 记录信息 add by TangJian 2016/11/08 14:44:21
    self._killedRoles = {}-- 杀死的角色
    self._killer = nil -- 杀死自己的人 add by TangJian 2016/11/08 14:45:00

    -- 特殊效果 add by TangJian 2016/11/05 16:25:44
    self._isPaused = false -- 暂停
    self._isUndead = false -- 是否不死 add by TangJian 2016/11/05 16:26:12
    self._isActived = true -- 能否活动 add by TangJian 2016/11/07 10:47:27

    -- 增益结构
    self._buff = {
        ["属性加成"] = {},
        ["使用主动技能"] = {},
        ["击杀敌人"] = {},
        ["逃跑"] = {},
    }

    -- 额外属性 add by TangJian 2017/01/03 20:55:18
    self._hitRateFactor = 1 -- 命中率系数
    self._parryRateFactor = 1 -- 招架率系数
    self._dodgeRateFactor = 1 -- 闪避率系数

    self._qiAtkFactor = 1 -- 气血攻击系数
    self._qiMaxAtkFactor = 1 -- 气血上限攻击系数

    self._defRateFactor = 1 -- 防御系数
    self._neiliConsumeFactor = 1 -- 内力消耗系数

    self._yangXingQiAtkFactor = 1 -- 阳性气血攻击系数
    self._yangXingQiDefFactor = 1 -- 阳性气血防御系数

    self._yangXingqiMaxAtkFactor = 1 -- 气血上限攻击系数
    self._yangXingqiMaxDefFactor = 1 -- 阳性气血防御系数

    self._atkSpeedFactor = 1 -- 攻速系数

    self._jiaLiValue = 0 --加力值

    self._qiAutoAtkFactor = 0  --被动气血伤害系数
    self._qiAutoDefFactor = 0  --被动气血防御系数
    self._qiActiveAtkFactor = 0  --主动气血伤害系数
    self._qiActiveDefFactor = 0  --主动气血伤害系数

    self._parryHurtFixRateFactor = 0 --招架免伤强化系数

    self.__fragiles = {} -- 易伤标记
    self.__augments = {} -- 增伤标记

    for i = 1, FightConfig.Constant.FragileCount do
        self.__fragiles[i] = {
            value = 0,
            duration = 0,
            effectId = nil
        }
    end

    for i = 1, FightConfig.Constant.AugmentCount do
        self.__augments[i] = {
            value = 0,
            duration = 0,
            effectId = nil
        }
    end

    -- 状态机 add by TangJian 2017/05/04 19:11:26
    self._stateMachineMap = {}

	-- 在招式使用后，这里就会加一
	-- 默认是第一招等待中
	self._currentAutoIndex = 1

    self._BeforeUnloadWeaponIsSubType = nil --丢失兵器前的兵器子类型

    --当前效果动画
    self._effectAnims = {}

    --主手招式
    self.__prepSkillZhaoMap = {}
    --副手招式
    self.__standBySkillZhaoMap = {}

    self.saveDamage = 0 --储伤值

    self.despairForceBase = 0 --基础绝境力

    self.extraDespairForce = 0 --储伤附加绝境力
    -- 调试招架加成
    self.__debugParryRateBuff = 0

    self.__passiveEffectActiveZhaoIds = {} --主动技能附带被动效果的主动招式id列表

    self.__enterFightEffectActiveZhaoIds = {} --进入战斗主动技能附带效果的主动招式id列表

    self.__disarmWeapon = nil --被缴械武器

    self.__throwWeapons = {} --被投掷武器

    self._attrEffectBuffAddValue = { --属性主动效果buff加成
        hitRateFactor = 1,
        dodgeRateFactor = 1,
        parryRateFactor = 1,
        atkSpeedFactor = 1,
    }

    self._damageToHurt = 0 --伤害转自伤值

    self._recordDamage = 0 --记录承受伤害
    
    self._shieldCurrentHP = 0 --自己剩余护盾吸收量

    self._shieldDeductedHP = 0 --自己护盾已吸收量

    self._isPlayWinAnim = false --是否播放过胜利动画

    self.__activeDamageFactorMap = {} --主动技能伤害抗性修正系数

	self.__partForgetSkills = {} --部分遗忘武学
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 事件监听
function FightRole:setEventListener(eventListener)
    self._eventListener = eventListener
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 调用监听
function FightRole:callEventListener(eventName, ...)
    self._eventListener(self:getId(), eventName, ...)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 设置角色数据
function FightRole:setData(data)
    local fistFootData = data.fistFootSystemPVPInfo
    data.fistFootSystemPVPInfo = nil

    local teacherBuild = data.teacherBuildSystemPVPInfo
    data.teacherBuildSystemPVPInfo = nil

    self._data = data

    --调试招架加成
    self:setDebugParryRate(data.debugParryRateBuff)
    
    self._role = Role:create(self._data)

    -- TODO 玩家pvp后武器处理(暂未实装)
    -- function Role.afterFightBrokeWeaponInfo(this, brokeWeaponInfo)
    --     if MapIsEmpty(brokeWeaponInfo) == false then
    --         for k, weapon in pairs(brokeWeaponInfo) do
    --             local item = this.getItemWithOnlyId(weapon.id)
    --             item.wanhaodu = 0

    --             if item.type and item.type == "神兵" then
    --                 local ShenBingDuanZao = require("app.models.ShenBing.DuanZao.ShenBingDuanZao")
    --                 ShenBingDuanZao:updateShenBingInfo({wanhaodu = 0, id = item.itemId},self)
    --             end

    --             local prepareWeapon = this.getPrepareWeapon()
    --             if prepareWeapon and prepareWeapon.id == weapon.id then 
    --                 this.setPrepareWeapon()
    --             end

    --             local currWeapon = this.getEquipByName("weapon")
    --             if currWeapon and currWeapon.id == weapon.id then
    --                 this.setEquipByName("weapon", nil)
    --             end
    --         end
    --     end
    -- end

    -- 自创武学系统一定存在, 直接调用
    self._role:getSelfCreatedSkillSystem():updataSelfCreatedSkillMap()
    -- 拳脚系统pvp数据初始化
    self._role:getFistFootSystem():initFromPVPData(fistFootData)

    -- 师门建筑系统pvp数据初始化
    self._role:getTeacherBuildSystem():initFromPVPData(teacherBuild)

    -- 记录当前武器和备用武器
    self.__mainWeapon = self._role:getEquipByName("weapon")
    self.__prepareWeapon = self._role:getPrepareWeapon()

    self.__mainWeaponState = true  --记录主武器有没有损坏（没有装备或者完好为true）
    self.__prepareWeaponState = true --记录准备武器有没有损坏（没有准备或者完好为true）

    self.__replaceWeapon = self.__prepareWeapon  --当前替换武器

    self.__quaoJiaoWeaponChangeState = nil -- 1是装备武器 2准备武器 3拳脚 4异常（武器被打断）
    if self.__mainWeapon then
        self.__quaoJiaoWeaponChangeState = 1
    else
        self.__quaoJiaoWeaponChangeState = 3
    end

    -- print("```````````````````````````````分组对抗角色信息``````````````````````````````````````````````")
    -- Helper:print_lua_table(self._data)
    
    -- update不能满足需求，导致出现人物buff未计算情况  例如：经脉印记 悟性加成buff 没有被计算
    -- self._role:update()
	self._role.qi = math.max(self._role.qi,1)

	self._role.qiPercent = math.max(self._role.qiPercent,1/self._role.qiMax)

    self._role:updateRoleBuff()
    
    self._role.tiliMax = 100

    local FightRoleSkillProxy = require("app.models.fight.FightRoleProxy.FightRoleSkillProxy")
    --@desc 该对象不对外开放，没特殊情况不需要调用
    self.__roleSkillProxy = FightRoleSkillProxy:create(self._role)

    self:reinitRole()
end


-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/05/04 22:11:49
-- @desc
function FightRole:onStartFight()
    -- 初始化经脉 add by TangJian 2017/05/04 22:10:55
    if IS_OPEN_PVP_JINGMAI == true then
        self:jingMaiInit()
    end

    --添加战斗前武学技能相关默认效果
    self:addRoleDefaultEffect()

    self:addEnterFightEffects()

    self:addHiddenMeridianSysActiveEffects()

    self:refreshRoleShadowSpriteEffect()

    self:refreshRoleEffectText()

    self:printFightRoleInfo()
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/03/31 01:56:13
-- @desc 重新刷新角色
function FightRole:reinitRole()
     --记录上次准备的主动技能zhaoMap
     if not self._lastActiveZhaoStateMap then
        self._lastActiveZhaoStateMap = {}
    end
    
    for k,v in pairs(self._preparedActiveZhaoMap) do
        self._lastActiveZhaoStateMap[k] = v
    end

    -- 初始化当前攻击技能
    self:setCurrAttackSkill(self._role:getPrepareAttackSkill())

    -- 初始化准备的主动技能结构
    self._currActiveZhaoStateMap = {}
    self._preparedActiveZhaoMap = assert(self:getActiveZhaoMap())

    for k, activeZhao in pairs(self._preparedActiveZhaoMap) do
        activeZhao:setOwner(self)
        local effectArray = activeZhao:getEffectArray()
        for i, effect in ipairs(effectArray) do
            effect:setOwner(self)
        end
        if self._lastActiveZhaoStateMap[k] then
            activeZhao:setCDLeft(self._lastActiveZhaoStateMap[k]:getCDLeft()) 
        end
        
        self._currActiveZhaoStateMap[k] = activeZhao
    end

    if IS_OPEN_PVP_JINGMAI == true then
        -- 初始化经脉印记的增益
        for k, v in pairs(jingmaiMap) do
            if v.type == "属性加成" then
                self._buff["属性加成"][k] = {getAdditionalAttr = v.getAdditionalAttr}
            elseif v.type == "使用主动技能" then
                self._buff["使用主动技能"][k] = {func = v.func}
            elseif v.type == "击杀敌人" then
                self._buff["击杀敌人"][k] = {func = v.func}
            elseif v.type == "逃跑" then
                self._buff["逃跑"][k] = {func = v.func}
            end
        end
    end

    if PVP_SHENBINGSYS then
        ShenBingEffct:initWeaponEffect(self)
    end

    self._effectAnims = {}

    self:refreshRoleDefaultEffect()

    self:refreshRoleShadowSpriteEffect()

    self:refreshRoleEffectText()

    --主手招式
    self.__prepSkillZhaoMap = {}
    --副手招式
    self.__standBySkillZhaoMap = {}
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/06/15 16:40:29
-- @desc 判断是否是玩家唉
function FightRole:isPlayer()
    return self._isPlayer
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/06/15 16:40:53
-- @desc 设置为玩家
function FightRole:setIsPlayer(b)
    self._isPlayer = b
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 得到角色数据
function FightRole:getData()
    return clone(self._data)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 获得角色id
function FightRole:getId()
    return self._data.id
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 战斗id
function FightRole:getFightId()
    return self._fightId
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 得到左边还是右边
function FightRole:getDirection()
    if self:getTeamId() == 1 then
        return "left"
    elseif self:getTeamId() == 2 then
        return "right"
    else
        print("角色没有队伍编号")
    end
    return "left"
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 设置战斗Id
function FightRole:setFightId(fightId)
    self._fightId = fightId
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 得到角色
function FightRole:getRole()
    return self._role
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 得到名字
function FightRole:getName()
    return self._data.name
end

function FightRole:setTeamId(id)
    self._data.teamId = id
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 得到队伍id
function FightRole:getTeamId()
    return self._data.teamId
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 获得在队伍中的编号
function FightRole:getInTeamId()
    return 1
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 设置当前帧
function FightRole:setCurrFrame(frame)
    self._currFrame = frame
end

--[[
    @desc: 获得当前武器
    author:TangJian
    time:2022-03-20 19:50:20
    @return:
]]
function FightRole:getCurrWeapon()
    return self._role:getEquipByName("weapon")
end

--[[
    @desc: 获得主武器
    author:TangJian
    time:2022-03-20 19:49:35
    @return:
]]
function FightRole:getMainWeapon()
    return self.__mainWeapon
end

--[[
    @desc: 获得准备武器
    author:TangJian
    time:2022-03-20 19:49:41
    @return:
]]
function FightRole:getPrepareWeapon()
    return self.__prepareWeapon
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 获得当前帧
function FightRole:getCurrFrame()
    return self._currFrame
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 当前目标id
function FightRole:setTargetId(targetId)
    self._targetId = targetId
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 得到当前目标id
function FightRole:getTargetId()
    return self._targetId
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/05 17:18:23
-- @desc 得到标记
function FightRole:getFlag(...)
    return self._role:getFlag(...)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/05 17:20:58
-- @desc 设置标记
function FightRole:setFlag(flagName, value)
    return self._role:setFlag(flagName, value)
end

-------------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/16 14:57:24
-- @desc 得到当前气血上限
function FightRole:getCurrQiMax()
    return self._role:getCurrQiMax()
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/18 10:41:41
-- @desc 得到当前的攻速系数
function FightRole:getAttackSpeedFactor()
    local dodgeSkill = self._role:getPrepareDodgeSkill()
    if dodgeSkill then
        local atkSpeed = dodgeSkill:getFactor("atkSpd")
        return atkSpeed
    end
    return 0
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/04/25 03:07:56
-- @desc 执行某类buff
function FightRole:executeBuff(buffType, ...)
    if IS_OPEN_PVP_JINGMAI == true then
        self:triggerJingMaiYinJi(buffType, ...)
    end

    self:triggerActiveZhaoEffect(buffType, ...)

-- local buffs = self._buff[buffType]
-- if buffs then
--     -- PopText("buffType = " .. buffType)
--     for k, v in pairs(buffs) do
--         -- PopText("k = " .. k)
--         v.func(...)
--     end
-- else
--     if DEBUG_MODE == 1 then
--         PopText("没有buff类型: " .. buffType)
--     end
-- end
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/01/03 17:09:09
-- @desc 得到属性所在的对象, 以及属性名
function FightRole:getAttrObjAndAttrName(attrName)
    local selfAttrMap =
        {
            hitRateFactor = "_hitRateFactor",
            dodgeRateFactor = "_dodgeRateFactor",
            parryRateFactor = "_parryRateFactor",

            qiAtkFactor = "_qiAtkFactor",
            qiMaxAtkFactor = "_qiMaxAtkFactor",

            atkSpeedFactor = "_atkSpeedFactor",

            defRateFactor = "_defRateFactor", -- 防御系数

            neiliConsumeFactor = "_neiliConsumeFactor",

            jiaLiValue = "_jiaLiValue",

            qiAutoAtkFactor = "_qiAutoAtkFactor",

            qiAutoDefFactor = "_qiAutoDefFactor",

            qiActiveAtkFactor = "_qiActiveAtkFactor",

            qiActiveDefFactor = "_qiActiveDefFactor",

            parryHurtFixRateFactor = "_parryHurtFixRateFactor",
            
            saveDamage = "saveDamage",

            despairForceBase = "despairForceBase",

            extraDespairForce = "extraDespairForce",

            damageToHurt = "_damageToHurt",

            recordDamage = "_recordDamage",
            
            shieldCurrentHP = "_shieldCurrentHP",

            shieldDeductedHP = "_shieldDeductedHP",
        }
    if selfAttrMap[attrName] then
        return self, selfAttrMap[attrName]
    end
    return self:getRole(), attrName
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 获得人物属性
function FightRole:getAttr(attrName)
    local obj, attrName = self:getAttrObjAndAttrName(attrName)

    local attrValue = obj[attrName]

    if type(attrValue) == "number" then
        local effectAddValue = self:getAttrEffectBuffAddValue(attrName)
        if effectAddValue ~= 0 then
            attrValue = attrValue * effectAddValue
        end
    end
    
    -- 获取状态型经脉印记加成
    if IS_OPEN_PVP_JINGMAI == true and type(attrValue) == "number" then
        local addAttr = self:getFightRoleJingMaiAddValue(attrName)
        attrValue = attrValue + addAttr
    end

    return attrValue
end

-----------------------------------------------------------------------------------------------------------
--获取状态型经脉印记加成
function FightRole:getFightRoleJingMaiAddValue(attrName)
    local addValue = 0
    local selfAttrMap =
        {
            _hitRateFactor = "hitRateFactor",
            _dodgeRateFactor = "dodgeRateFactor",
            _parryRateFactor = "parryRateFactor",

            _qiAtkFactor = "qiAtkFactor",
            _qiMaxAtkFactor = "qiMaxAtkFactor",

            _atkSpeedFactor = "atkSpeedFactor",

            _defRateFactor = "defRateFactor", -- 防御系数

            _neiliConsumeFactor = "neiliConsumeFactor",
        }
    if self._fightRoleJingMai then
        attrName = selfAttrMap[attrName]  -- 属性名转化
        if attrName then
            local value = self._fightRoleJingMai:getAttr(attrName)
            if type(value) == "number" then
                addValue = value
            end
        end
    end
    
    return addValue
end


-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/04/24 22:28:48
-- @desc 获得属性加成
function FightRole:getAdditionalAttr(attrName, attrValue)
    if self._fight then
        local target = self._fight:getRole(self._targetId)
        if target then
            local addValue = 0
            for k, v in pairs(self._buff["属性加成"]) do
                addValue = addValue + v.getAdditionalAttr(self, target, attrName, attrValue)
            end
            return addValue
        end
    end
    return 0
end

function FightRole:getFinalAttr(attrName)
    local attrValue = self:getRole():getFinalAttr(attrName)

    -- 获得额外加成属性
    if type(attrValue) == "number" then
        local addValue = self:getAdditionalAttr(attrName, attrValue)
        -- print("属性" .. attrName .. "加成" .. addValue)
        -- print("attrValue = " .. attrValue)
        attrValue = attrValue + addValue
    end

    return attrValue
end
-----------------------------------------------------------------------------------------------------------
-- @author lvBin
-- @desc 获取攻速属性(武器重量影响攻速)
function FightRole:getAtkSpeedFactor()
    local weaponType = self._role:getCurrWeaponType()
    local addValue = 0
    if SHENBINGSYS == true and weaponType ~= "拳脚" and weaponType ~= "暗器" and self._role:getEquipByName("weapon") ~= nil then
        local W = self:getWeaponWeight()
        local S = self._role:getEffectStr()
        LogSystem:log("旧版战斗：","获取攻速属性:   |当前武器重量：",W)
        if S <= W/2 then
            addValue = -math.min((W/100),0.2)
        elseif W/2 < S and S <= W  then
            addValue = -math.min((W/200),0.15)
        elseif W < S and S <= 2*W  then
            addValue = -math.min((W/100),0.1)
        elseif 2*W < S and S <= 5*W  then
            addValue = -math.min((W/100),0.05)
        elseif 5*W < S and S <= 10*W  then
            addValue = 0
        elseif S >= 10*W  then
            addValue = math.min((W/50),0.2)
        end
    end
    -- return self:getAttr("atkSpeedFactor") + addValue
    --@desc 行针效果
    local atkSpeedFactor = self._role:getBuffAttr("atkSpeedFactor")
    if atkSpeedFactor == 0 then
        atkSpeedFactor = 1
    end

    return Helper:getRange((self:getAttr("atkSpeedFactor") + addValue) * atkSpeedFactor, 0.2, 5)
end
-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 设置任务属性
function FightRole:setAttr(attrName, value)
    local obj, attrName = self:getAttrObjAndAttrName(attrName)
    obj[attrName] = value
    self:callEventListener("setAttr", attrName, value)

    --监控角色属性变化
    self:attrMonitor()
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 增加attr
function FightRole:addAttr(attrName, value, min, max)
    if attrName == "qimax" then 
        local qiMax = self:getRole():getFinalAttr("qiMax")

        local lastQiMax = Helper:getRange(value + self:getCurrQiMax(), 0, qiMax)

        self:setAttr("qiPercent",lastQiMax / qiMax)

        if self:getAttr("qi") > self:getCurrQiMax() then
            self:setAttr("qi",self:getCurrQiMax())
        end
    else   
        if attrName=="neili" then
            max=self:getRole():getNumAttr("neiliMax")*2
        elseif attrName == "saveDamage" then
            self:updataExtraDespairForce(value)
        elseif attrName == "damageToHurt" then
            if not min then
                min = 0
            end  
        end
        value = self:getAttr(attrName) + value
         --移除经脉加成
        do
            if IS_OPEN_PVP_JINGMAI == true then
                local jingMaiAddAttr = self:getFightRoleJingMaiAddValue("_"..attrName)
                value = value - Helper:getDef(jingMaiAddAttr,0)
            end
        end

        if min and value < min then
            value = min
        end
        if max and value > max then
            value = max
        end
        self:setAttr(attrName, value)
    end
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/10 12:38:14
-- @desc 得到动画类型
function FightRole:getAnimType()
    return self._role:getAnimType()
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/07 10:48:55
-- @desc 设置活动状态
function FightRole:setActived(b)
    self._isActived = b
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/07 10:46:21
-- @desc 是否处在活动状态
function FightRole:isActived()
    return self._isActived
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/05 17:33:37
-- @desc 暂停
function FightRole:pause()
    self._isPaused = true
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/05 17:34:02
-- @desc 回复
function FightRole:resume()
    self._isPaused = false
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/05 17:34:26
-- @desc 判断是否暂停
function FightRole:isPaused()
    return self._isPaused
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/03/31 01:53:59
-- @desc 卸下武器
function FightRole:unloadWeapon()
    self._role:setEquipByName("weapon", nil)
    self:reinitRole()

    self:deleteEnterFightEffects()

    self._currZhaoState = 0
    self._currZhaoIndex = 0 -- 当前招式位置
    self._currZhaoFrame = 1 -- 当前招式帧

    -- 刷新按钮区域
    -- self._fight:callEventListener("unloadWeapon")

    --@desc 武器打落后毒药不再生效
    if PVP_POISONSYS then
        if self._poisonEffectArray then
            for _,v in ipairs(self._poisonEffectArray) do
                v.canUse = false
            end
        end
    end
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/08 15:26:59
-- @desc 得到杀死的角色
function FightRole:getKilledRoles()
    return self._killedRoles
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/08 15:27:17
-- @desc 添加杀死的角色
function FightRole:addKilledRole(role)
    table.insert(self._killedRoles, role)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/08 14:46:16
-- @desc 记录杀死自己的人
function FightRole:setKiller(role)
    self._killer = role
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/08 14:46:50
-- @desc 得到杀死自己的人
function FightRole:getKiller()
    return self._killer
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/09 17:58:24
-- @desc 体力回复
function FightRole:setWaitingTili(b)
    self._isWaitingTili = b
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/09 17:59:04
-- @desc 判断体力回复状态
function FightRole:isWaitingTili()
    return self._isWaitingTili
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 设置死亡
function FightRole:setDead(b)
    self._isDead = b
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 是否死亡
function FightRole:isDead()
    return self._isDead
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 是否活着
function FightRole:isAlive()
    return not self._isDead
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/05 16:15:20
-- @desc 是否不死
function FightRole:isUndead()
    return self._isUndead
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/03/22 16:22:23
-- @desc 是否不消耗内力
function FightRole:isNeedNeili()
    return self:getIsNeedNeili()
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/03/15 23:36:48
-- @desc 判断角色是否满血
function FightRole:isFullQi()
    -- if self:getAttr("qi") >= self:getFinalAttr("qiMax") then
    if self:getAttr("qi") >= self:getCurrQiMax() then
        return true
    end
    return false
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/02 19:06:16
-- @desc 获得角色当前气血状态
function FightRole:getFightQiDesc()
    return self:getRole():getFightQiDesc()
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 得到攻击手段
function FightRole:getAttackMethod()
    return self._role:getAttackMethod()
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 当前武器
function FightRole:getCurrWeaponName()
    return self._role:getCurrWeaponName()
end

-- 获得当前武器类型
function FightRole:getCurrWeaponType()
   return self._role:getCurrWeaponType()
end
-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 设置当前攻击技能
function FightRole:setCurrAttackSkill(attackSkill)
    -- logt("FightRole:setCurrAttackSkill(attackSkill)", self:getName(), "\n", self)
    -- print("设置当前被动技能为" .. tostring(attackSkill.id))
    self._currAttackSkill = attackSkill
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 获得当前攻击技能
function FightRole:getCurrAttackSkill()
    return self._currAttackSkill
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 得到当前闪避技能
function FightRole:getCurrDodgeSkill()
    return self._role:getPrepareDodgeSkill()
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/14 15:20:50
-- @desc 设置当前互备招式
function FightRole:setCurrDoubleAttackSkill(skill)
    self._currDoubleAttackSkill = skill
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/14 15:23:15
-- @desc 得到当前互备技能
function FightRole:getCurrDoubleAttackSkill()
    return self._currDoubleAttackSkill
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/14 15:21:17
-- @desc 设置当前互备招式
function FightRole:setCurrDoubleAttackZhao(zhao)

    do
        --根据武器子类型改造anims
        if zhao and zhao.anims then
            local newAnims = {}
            local subType = self._role:getCurrSubtypeByWeapon()
            local beforeSubType = self:getBeforeUnloadWeaponIsSubType()

            for i,v in ipairs(zhao.anims) do
                if v[subType] then
                    table.insert( newAnims,v[subType])
                elseif beforeSubType and v[beforeSubType] then
                    table.insert( newAnims,v[beforeSubType])
                end
            end

            if #newAnims > 0 then
                zhao.anims = newAnims   
            end 
        end
    end
    
    self._currDoubleAttackZhao = zhao
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/14 15:23:46
-- @desc 得到当前互备招式
function FightRole:getCurrDoubleAttackZhao()
    return self._currDoubleAttackZhao
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 得到随机的闪避招式
function FightRole:getRandomDodgeZhaoByPosition(hitPos)
    return self:getCurrDodgeSkill():getRandomDodgeZhaoByPosition(hitPos)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 得到当前招架技能
function FightRole:getCurrParrySkill()
    return self._role:getPrepareParrySkill()
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 设置招架招式
function FightRole:getRandomParryZhaoByPosition(hitPos)
    return self:getCurrParrySkill():getRandomParryZhaoByPosition(hitPos, self:getAttackMethod())
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 获得随机受伤招式
function FightRole:getRandomHurtZhaoByPosition(hitPos)
    print("FightRole:getRandomHurtZhaoByPosition(hitPos) hitPos = ", hitPos)
    return self:getCurrAttackSkill():getRandomHurtZhaoByPosition(hitPos, self:getAttackMethod())
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 设置当前攻击招式
function FightRole:setCurrAttackZhao(attackZhao)
    if attackZhao.isJingMaiAttackZhao == true then --经脉攻击招 设置攻击动画和攻击文本
        local anims,action = Meridian:createZhaoIsAnimAndText(self,attackZhao._cType)
        attackZhao.anims = anims
        attackZhao.action = action   
    else
        do
            --根据武器子类型改造anims
            if attackZhao and attackZhao.anims then
                local newAnims = {}
                local subType = self._role:getCurrSubtypeByWeapon()
                local beforeSubType = self:getBeforeUnloadWeaponIsSubType()

                for i,v in ipairs(attackZhao.anims) do
                    if v[subType] then
                        table.insert( newAnims,v[subType])
                    elseif beforeSubType and v[beforeSubType] then
                        table.insert( newAnims,v[beforeSubType])
                    end
                end

                if #newAnims > 0 then
                    attackZhao.anims = newAnims   
                end 
            end
        end
    end

    self._currAttackZhao = attackZhao
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 获得当前攻击招式
function FightRole:getCurrAttackZhao()
    return self._currAttackZhao
end

--获得当前武器子类型
function FightRole:getCurrWeaponType2()
    return self._role:getCurrWeaponType2()
end
-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/16 16:29:59
-- @desc 判断释放招式的能量是否足够
function FightRole:getAutoZhaoTiliConsume(zhao)
    -- local tiliConsume = 100 --(zhao.preDuration + zhao.aftDuration) * 100 / 3
    local tiliConsume = (zhao.preDuration + zhao.aftDuration) * 100 / 3
    -- print("tiliConsume = ", tiliConsume)
    return tiliConsume
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/16 16:38:28
-- @desc 通过招式id判断释放招式的能量是否足够
function FightRole:getAutoZhaoTiliConsumeWithZhaoId(atkSkId, atkZhaoId)
    local attackSkill = Skill:getSkill(atkSkId)
    local attackZhao = attackSkill:getAttackZhaoById(atkZhaoId)
    local tiliConsume = (zhao.preDuration + zhao.aftDuration) * 100 / 3
    -- print("tiliConsume = ", tiliConsume)
    return tiliConsume
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/03/06 14:37:35
-- @desc 得到角色当前状态
function FightRole:getCurrState()
    if self:isParalyzed() then
        return "瘫痪"
    elseif self:isSleep() then
        return "晕迷"
    elseif self:isBlind() then
        return "迷惑"
    elseif self:isFrozen() then
        return "定身"
    else
        return "正常"
    end
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2018/06/28 17:29:41
-- @params 
-- @desc 获取当前角色的攻击武学
function FightRole:getDefaultAttackSkill()
    local skillId = self:getRole():getCurrSkillIdWithWeapon()
    if skillId == nil then
        skillId = "jiben"..self:getRole():getCurrTypeByWeapon()
    end
    return Skill:getSkill(skillId)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2018/06/26 11:54:40
-- @params 
-- @desc 获得出场动画
function FightRole:getStartAnimName()
    local animId = self:getRole():getAppearanceStartFightAnimId() or self:getDefaultAttackSkill():getStartFightAnimId()
    
    if animId == nil then
        return nil
    end

    return AnimResManager:getOtherAnimName(animId)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2018/06/26 20:17:09
-- @params 
-- @desc 获取出场动画所需的时间
function FightRole:getStartAminNeedTime()
    local retTime = self:getRole():getAppearanceStartFightTime()

    if retTime == nil then
        retTime = self:getDefaultAttackSkill():getStartFightAnimNeedTime()
    end

    return Helper:getDef((1 / 30) * retTime, 0) 
end

-----------------------------------------------------------------------------------------------------------
-- @author LvBin
-- @time 2020-06-10 17:46:33
-- @params 
-- @desc 获得胜利动画
function FightRole:getWinAnimName()
    local animId = self:getRole():getAppearanceWinFightAnimId()

    if animId == nil then
        return nil
    end

    return AnimResManager:getOtherAnimName(animId)
end

-----------------------------------------------------------------------------------------------------------
-- @author LvBin
-- @time  2020-06-10 17:47:01
-- @params 
-- @desc 获取胜利动画所需的时间
function FightRole:getWinAminNeedTime()
    local retTime = Helper:getDef(self:getRole():getAppearanceWinFightTime(),0)

    return Helper:getDef((1/ 30) * retTime, 0) 
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/10 12:43:59
-- @desc 获得站站立动画名
function FightRole:getStandAnimName()
    return switch(self:getAnimType(),
        {
            human = function()
                return switch(self:getCurrState(),
                    {
                        ["瘫痪"] = FightConfig:getEffectBindAnimByPos(self,FightConfig.Constant.EffectAnimPos.StandCtrl) or "stun1",
                        ["晕迷"] = FightConfig:getEffectBindAnimByPos(self,FightConfig.Constant.EffectAnimPos.StandCtrl) or "stun1",
                        ["迷惑"] = FightConfig:getEffectBindAnimByPos(self,FightConfig.Constant.EffectAnimPos.StandCtrlCf) or "confuse1",
                        ["定身"] = FightConfig:getEffectBindAnimByPos(self,FightConfig.Constant.EffectAnimPos.StandCtrl) or "stun1",
                        ["正常"] = function() 
                            return FightConfig:getEffectBindAnimByPos(self,FightConfig.Constant.EffectAnimPos.Stand) or self:getCurrAttackSkill():getStandAnimName(self) 
                        end
                    })
            end,
			dog = self:getCurrState() == "正常" and "wolf-stand" or "wolf-controlled",
            bird = self:getCurrState() == "正常" and "bird-stand" or "bird-controlled",
            spider = self:getCurrState() == "正常" and "spider-stand" or "spider-controlled",
            snake = self:getCurrState() == "正常" and "snake-stand" or "snake-controlled",
            centipede = self:getCurrState() == "正常" and "WuGong-stand" or "WuGong-controlled",
            scorpion = self:getCurrState() == "正常" and "XieZi-stand" or "XieZi-controlled",
        })
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/10 12:58:26
-- @desc 得到跳跃动画
function FightRole:getJumpForwardAnimName()
    return switch(self:getAnimType(),
        {
            human = self:getCurrAttackSkill():getJumpForwardAnimName(self),
            dog = "wolf-stand",
            bird = "bird-stand",
            spider = "spider-stand",
            snake = "snake-stand",
            centipede = "WuGong-stand",
            scorpion = "XieZi-stand",
        })
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/10 12:59:39
-- @desc 得到后跳动画
function FightRole:getJumpBackwardAnimName()
    return switch(self:getAnimType(),
        {
            human = self:getCurrAttackSkill():getJumpBackwardAnimName(self),
            dog = "wolf-stand",
            bird = "bird-stand",
            spider = "spider-stand",
            snake = "snake-stand",
            centipede = "WuGong-stand",
            scorpion = "XieZi-stand",
        })
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/10 12:44:10
-- @desc 获得当前攻击动画
function FightRole:getAttackAnimName()
    return switch(self:getAnimType(),
        {
            human = nil,
            dog = "wolf-attack",
            bird = "bird-attack",
            spider = "spider-attack",
            snake = "snake-attack",
            centipede = "WuGong-attack",
            scorpion = "XieZi-attack",
        })
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/10 12:47:49
-- @desc 得到闪避动画
function FightRole:getDodgeAnimName(hitPos)
    return switch(self:getAnimType(),
        {
            human = function()
                return switch(
                    hitPos,
                    {
                        head = FightConfig:getEffectBindAnimByPos(self,FightConfig.Constant.EffectAnimPos.DodgeH),
                        chest = FightConfig:getEffectBindAnimByPos(self,FightConfig.Constant.EffectAnimPos.DodgeC),
                        foot = FightConfig:getEffectBindAnimByPos(self,FightConfig.Constant.EffectAnimPos.DodgeF),
                        default = FightConfig:getEffectBindAnimByPos(self,FightConfig.Constant.EffectAnimPos.DodgeC)
                    }
                )
            end,
            dog = "wolf-dodge",
            bird = "bird-dodge",
            spider = "spider-dodge",
            snake = "snake-dodge",
            centipede = "WuGong-dodge",
            scorpion = "XieZi-dodge",
        })
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/23 17:36:16
-- @desc 得到格挡动画名
function FightRole:getParryAnimName(hitPos)
    return switch(self:getAnimType(),
        {
            human = function()
                return switch(
                    hitPos,
                    {
                        head = FightConfig:getEffectBindAnimByPos(self,FightConfig.Constant.EffectAnimPos.ParryH),
                        chest = FightConfig:getEffectBindAnimByPos(self,FightConfig.Constant.EffectAnimPos.ParryC),
                        foot = FightConfig:getEffectBindAnimByPos(self,FightConfig.Constant.EffectAnimPos.ParryF),
                        default = FightConfig:getEffectBindAnimByPos(self,FightConfig.Constant.EffectAnimPos.ParryC)
                    }
                )
            end,
            dog = "wolf-dodge",
            bird = "bird-dodge",
            spider = "spider-dodge",
            snake = "snake-dodge",
            centipede = "WuGong-dodge",
            scorpion = "XieZi-dodge",
        })
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/10 12:53:29
-- @desc 得到受伤动画
function FightRole:getHurtAnimName(hitPos)
    return switch(self:getAnimType(),
        {
            human = function()
                return switch(
                    hitPos,
                    {
                        head = FightConfig:getEffectBindAnimByPos(self,FightConfig.Constant.EffectAnimPos.HurtH),
                        chest = FightConfig:getEffectBindAnimByPos(self,FightConfig.Constant.EffectAnimPos.HurtC),
                        foot = FightConfig:getEffectBindAnimByPos(self,FightConfig.Constant.EffectAnimPos.HurtF),
                        default = FightConfig:getEffectBindAnimByPos(self,FightConfig.Constant.EffectAnimPos.HurtC)
                    }
                )
            end,
            dog = "wolf-hurt-chest",
            bird = "bird-hurt-chest",
            spider = "spider-hurt-chest",
            snake = "snake-hurt-chest",
            centipede = "WuGong-hurt-chest",
            scorpion = "XieZi-hurt-chest",
        })
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/15 16:50:21
-- @desc 得到死亡动画
function FightRole:getDeadAnimName()
    return switch(self:getAnimType(),
        {
            human = FightConfig:getEffectBindAnimByPos(self,FightConfig.Constant.EffectAnimPos.Dead),
            dog = "wolf-dead",
            bird = "bird-dead",
            spider = "spider-dead",
            snake = "snake-dead",
            centipede = "WuGong-dead",
            scorpion = "XieZi-dead",
        })
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/03/02 17:46:44
-- @desc 得到主动技能命中力
function FightRole:getActiveZhaoHitRate(activeZhaoId)
    local role = self:getRole()
    local activeZhaoLv = role:getSkillZhaoLv(activeZhaoId)

    local cType = role:getCurrTypeByWeapon()
    if cType == "quanjiao" then
        -- 暂用拳脚1做计算
        cType = "quanjiao1"
    end
    local skillLv, factor = role:getSkillLvAndFactor(cType, "hitRate")

    -- local hitRate = (activeZhaoLv * 150 * factor / 100 + 1000 + 0.5 * role:getExp() ^ 0.5) * (1 + role:getEffectStr() * 0.02)
    local hitRate = (activeZhaoLv * 15 * factor / 2 + 1000 + 0.5 * role:getExp() ^ 0.5) * (1 + role:getEffectStr() * 0.02)
    return hitRate * self._hitRateFactor
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/01/03 16:57:57
-- @desc 命中率
function FightRole:getHitRate()
    return self:getRole():getHitRate() * self:getAttr("hitRateFactor")
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/01/03 16:58:21
-- @desc 得到角色闪避率
function FightRole:getDodgeRate()
    return self:getRole():getDodge() * self:getAttr("dodgeRateFactor")
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/01/03 16:58:28
-- @desc 得到角色招架率
function FightRole:getParryRate()
    return self:getRole():getParry() * self:getAttr("parryRateFactor")
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 创建攻击结果
-- @params role 的类为 Role
function FightRole:createAttackResult(__role, __target, attackSkill, attackZhao, doubleAtkSkill, doubleAtkZhao, magicNumber1, magicNumber2, isJingMaiZhao,cType)
    local fightRole = __role:getRole()
    local target = __target:getRole()

    local attackZhao = attackZhao -- 攻击招式
    attackZhao.atkSkillId = attackSkill.id

    -- -- add by XiaoZhiWei 2018/03/19 12:34:48 对手的下一个招式,用来计算招架和闪避的系数
    -- local targetNextZhao
    -- do
    --     local autoZhaos = __target:getAutoZhaos(__target:getId())
    --     targetNextZhao = autoZhaos[__target._currZhaoIndex + 1]
    --     if targetNextZhao == nil then
    --         targetNextZhao = {
    --             dodge = 0,
    --             parry = 0
    --         }
    --     end
    -- end
    
    local hitPosName, realHitPos = attackSkill:getRandomAttackPositionPart()-- 攻击部位
    
    local fightHitRate = __role:getHitRate() * (1 + Helper:getDef(attackZhao.hitRate, 0)) * (2 / (1 + 3 ^ ((target:getExp() - fightRole:getExp()) / (target:getExp() + fightRole:getExp()))))

    local targetDodge = __target:getDodgeRate() * (1)
    local targetParry = __target:getParryRate() * (1)

    local hitType = HIT_TYPE_HIT
    
    local num1, num2 = magicNumber1, magicNumber2

    -- 实际闪躲率 = 目标战斗闪躲值*0.7*100 / (目标战斗闪躲值*0.7+自身战斗命中值)
    local trueDodgeRate = math.floor(targetDodge * 100 * 0.7 / (targetDodge * 0.7 + fightHitRate))

    -- 实际招架率 = (目标战斗招架值*1.2)*100 / (目标战斗招架值*1.2+自身战斗命中值*0.85)
    local trueParryRate = math.floor((targetParry * 1.2) / (targetParry * 1.2 + fightHitRate * 0.85) * 100)
    
    --调试招架加成
    trueParryRate = __target:getDebugParryRate() + trueParryRate

    if (trueParryRate - trueDodgeRate) >= 20 then
        if num2 <= trueParryRate then
            hitType = HIT_TYPE_PARRY
        elseif num1 <= trueDodgeRate then
            hitType = HIT_TYPE_DODGE
        else
            hitType = HIT_TYPE_HIT
        end
    else
        if num1 <= trueDodgeRate then -- 闪避
            hitType = HIT_TYPE_DODGE
        elseif num2 <= trueParryRate then -- 招架
            hitType = HIT_TYPE_PARRY
        else
            hitType = HIT_TYPE_HIT
        end
    end
    -- 角色特殊状态（1 不能招架， 2不能闪躲， 3强招架， 4致盲）
    local roleState = ""

    do  
        --1 不能招架
        if __target:canParry() == false then
            if roleState ~= "" then
                roleState = roleState .. "|1"
            else
                roleState = "1"
            end
        end
        --2不能闪躲
        if __target:canDodge() == false then
            if roleState ~= "" then
                roleState = roleState .. "|2"
            else
                roleState = "2"
            end
        end
        --3强招架
        if __target:isParry() then
            if roleState ~= "" then
                roleState = roleState .. "|3"
            else
                roleState = "3"
            end
        end 
        --4致盲
        if __role:isHitFailure() then
            if roleState ~= "" then
                roleState = roleState .. "|4"
            else
                roleState = "4"
            end
        end

        if roleState == "" then
            roleState = "0"
        end
    end

    do
		if __role:isHit() then
			hitType = HIT_TYPE_HIT
		elseif __role:isHitFailure() then
            hitType = HIT_TYPE_DODGE
		elseif __target:isParry() and __target:canParry() == true then
			hitType = HIT_TYPE_PARRY
        end
    
        if hitType == HIT_TYPE_PARRY then
            if __target:canParry() == false then
                hitType = HIT_TYPE_HIT
            end
        elseif hitType == HIT_TYPE_DODGE then
            if __target:canDodge() == false then
                hitType = HIT_TYPE_HIT
            end
        end
    end

    -- 气血伤害和上限伤害 add by TangJian 2016/11/16 14:45:55
    local qiMaxAtk = fightRole:getQiMaxAtk(attackZhao, target, realHitPos,__role)
    local atk = fightRole:getQiAtk(attackZhao, target, realHitPos,__role)

    local doubleAtk = 0  -- 副手气血攻击
    local doubleQiMaxAtk = 0 -- 副手气血上限伤害
    
    LogSystem:log("旧版战斗：pvp本地角色","攻击者 = ",fightRole:getName()," |受击者 = ", target:getName()," |主手武学id = ",attackSkill.id," |主手招式id = ",attackZhao.id)
    
    LogSystem:log("旧版战斗：","招式结果(1 命中，2 招架，3 闪躲)：",hitType," |攻击者atkSpeedFactor值：",__role:getAttr("atkSpeedFactor")," |攻击者hitRateFactor值：",__role:getAttr("hitRateFactor")," |招式命中值：",fightHitRate," |受击者dodgeRateFactor值：",__target:getAttr("dodgeRateFactor")," |目标闪躲值：",targetDodge," |受击者parryRateFactor值：",__target:getAttr("parryRateFactor")," |目标招架值：",targetParry," |随机值1：",magicNumber1, " |随机值2：",magicNumber2," |闪避率：",trueDodgeRate," |招架率：",trueParryRate," |角色状态：（0 无特殊状态， 1 不能招架， 2不能闪躲， 3必定招架， 4必定闪躲）", roleState)
    
    -- 加力消耗 add by TangJian 2016/11/16 14:45:57
    local neiliConsume = math.floor(fightRole:getNumAttr("jiaLi"))

    -- 互备互博 add by TangJian 2016/11/16 14:39:02
    if doubleAtkSkill then
        local qiAtkFactor = 0.8 -- 气血伤害系数
        local qiMaxAtkFactor = 0.6 -- 气血上限伤害系数
        local jiaLiConsumeFactor = 0.5 -- 加力内力消耗系数

        -- 左右互搏, 前期, 削弱
        local lv = fightRole:getLv()
        if lv < 60 then
            qiAtkFactor = 0.6
        elseif lv < 75 then
            qiAtkFactor = 0.65
        elseif lv < 80 then
            qiAtkFactor = 0.7
        elseif lv < 85 then
            qiAtkFactor = 0.75
        else
            qiAtkFactor = 0.8
        end

        LogSystem:log("旧版战斗：pvp本地角色","副手武学id = ",doubleAtkSkill.id," |副手招式id = ",doubleAtkZhao.id)
        LogSystem:log("旧版战斗：pvp本地角色","副手武学被动招式消耗的体力 = ",self:getAutoZhaoTiliConsume(doubleAtkZhao))

        --@desc 自创伤害修正系数
        local selfCreatedSkillFactor = 1
        if doubleAtkSkill.type == SKILL_TYPE_SELFCREATE then
            local baseParam = SelfCreatedSkillManager:getParamsById("meridianImprinting_baseParam")
            local tiliParam = SelfCreatedSkillManager:getParamsById("meridianImprinting_tiliParam")
            local tiliRatio = math.min(self:getAutoZhaoTiliConsume(attackZhao)/self:getAutoZhaoTiliConsume(doubleAtkZhao),1)
            selfCreatedSkillFactor = baseParam + tiliRatio * tiliParam

            LogSystem:log("旧版战斗：pvp本地角色","自创副手基础伤害比例 = ",baseParam)
            LogSystem:log("旧版战斗：pvp本地角色","自创副手体力修正伤害比例 = ",tiliParam)
            LogSystem:log("旧版战斗：pvp本地角色","自创伤害修正系数 =",selfCreatedSkillFactor)
        end

        doubleAtk = fightRole:getQiAtk(doubleAtkZhao, target, realHitPos,__role) * selfCreatedSkillFactor * qiAtkFactor
        doubleQiMaxAtk = fightRole:getQiMaxAtk(doubleAtkZhao, target, realHitPos,__role) * selfCreatedSkillFactor * qiMaxAtkFactor
        atk = atk * qiAtkFactor
        qiMaxAtk = qiMaxAtk * qiMaxAtkFactor

        LogSystem:log("旧版战斗：pvp本地角色","主手气血伤害 = ",atk," |主手气血上限伤害 = ", qiMaxAtk)
        LogSystem:log("旧版战斗：pvp本地角色","副手气血伤害 = ",doubleAtk," |副手气血上限伤害 = ", doubleQiMaxAtk)
        LogSystem:log("旧版战斗：pvp本地角色","攻击部位 = ",hitPosName)

        atk = atk + doubleAtk
        qiMaxAtk = qiMaxAtk + doubleQiMaxAtk

        neiliConsume = 2 * neiliConsume * jiaLiConsumeFactor
        LogSystem:log("旧版战斗：pvp本地角色","主副合计手气血伤害 = ",atk," |主副合计手气血上限伤害 = ", qiMaxAtk)
    end

    -- 攻击力取整
    atk = atk + qiMaxAtk
    atk = math.floor(atk)
    LogSystem:log("旧版战斗：pvp本地角色","攻击 = ",atk, " |平均气血伤害avgqiatk = ",fightRole:getAvgQiAtk(target))

    if isJingMaiZhao == true then
        local atkSkillId = fightRole:getPrepareSkill(cType)
        local jibenLv = fightRole:getSkillLv("jiben"..cType)
        local useSkillLv = atkSkillId == "jiben"..cType and 0 or fightRole:getSkillLv(atkSkillId)
        if PRINT_MODE == 1 then
            print("jibenLv = ",jibenLv)
            print("useSkillLv = ",useSkillLv)
        end
        atk = math.floor(atk * (0.3 + (useSkillLv + jibenLv/2)/5000))
        neiliConsume = 0
        print("创建攻击结果 atk, qiMaxAtk = ",atk, qiMaxAtk)
        LogSystem:log("旧版战斗：pvp本地角色","经脉追加后攻击 = ",atk)
    end
    
    return hitType, atk, qiMaxAtk, neiliConsume, hitPosName, doubleAtk, doubleQiMaxAtk, trueDodgeRate, trueParryRate, roleState
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/12/30 16:28:47
-- @desc
function FightRole:createAutoZhao(__target, magicNumber1, magicNumber2)
    local role = self:getRole()
    local target = __target:getRole()

    local atkSkill, doubleAtkSkill = role:getPrepareAttackSkill()
    local atkZhao = atkSkill:getRandomAttackZhao(role)
    local doubleAtkZhao = nil
    if doubleAtkSkill then
        doubleAtkZhao = doubleAtkSkill:getRandomAttackZhao(role)
    end

    local befFrame, atkFrame, aftFrame = role:getAttackZhaoFrames(atkZhao)
    befFrame = (atkZhao.preDuration / 3) * 30 -- 前摇时间=表格里面招式前摇时间的 1/3 add by TangJian 2016/11/18 20:59:01

    local hitType, atk, qiMaxAtk, neiliConsume, hitPosName, doubleAtk, doubleQiMaxAtk, trueDodgeRate, trueParryRate, roleState = self:createAttackResult(self, __target, atkSkill, atkZhao, doubleAtkSkill, doubleAtkZhao, magicNumber1, magicNumber2)

    -- 如果有招式互备, 合并动画
    if doubleAtkZhao then
        -- log("有招式互备!!!!!", ", atkZhao = ", atkZhao, ", doubleAtkZhao = ", doubleAtkZhao)
        atkZhao.anims = table.mergeArray(atkZhao.anims, doubleAtkZhao.anims)
    end

    local dblAtkSkId, dblZhaoId
    if doubleAtkSkill then -- 获得
        dblAtkSkId, dblZhaoId = doubleAtkSkill.id, doubleAtkZhao.id
    end

    local count = #atkZhao.anims

    -- 统一变小, 这个暂时不用了 add by TangJian 2016/11/16 10:54:01
    -- befFrame = math.ceil( befFrame * 0.25 )
    -- aftFrame = math.ceil( aftFrame * 0.25 )
    -- print("befFrame = ", befFrame)
    --重新根据动画次数计算攻击间隔
    local atks = {}
    atkFrame = 0

    for i = 1, count do
        -- 记录每段攻击起始的帧数
        -- table.insert( atks , atkFrame )
        local pos = atkZhao.anims[i].hitPos
        if pos == 'head' then
            pos = 1
        elseif pos == 'foot' then
            pos = 3
        else
            pos = 2
        end

        atks[atkFrame] = pos

        -- 攻击中占20帧 add by TangJian 2016/11/19 11:59:03
        -- atkFrame = atkFrame + math.ceil(20 / atkZhao.anims[i].speed)
        -- 跳跃
        -- atkFrame = atkFrame + math.ceil(10 / atkZhao.anims[i].speed / FIGHT_JUMP_SPEED_SCALE)
        -- 前摇
        atkFrame = atkFrame + math.ceil(10 / atkZhao.anims[i].speed / FIGHT_PRESWING_SPEED_SCALE)

        -- 后摇
        atkFrame = atkFrame + 10
    -- atkFrame = atkFrame + math.ceil(10 / atkZhao.anims[i].speed / FIGHT_AFTSWING_SPEED_SCALE)
    end
    atkFrame = Helper:getRange(atkFrame, 1, 999999)

    local attackZhaoTable =
        {
            -- 攻击招式 add by TangJian 2016/11/14 15:15:03
            atkSkId = atkSkill.id,
            atkZhaoId = atkZhao.id,

            -- 互备招式 add by TangJian 2016/11/14 15:14:50
            dblAtkSkId = dblAtkSkId,
            dblZhaoId = dblZhaoId,

            befFrame = befFrame,
            atkFrame = atkFrame,
            aftFrame = aftFrame,

            hitType = hitType,

            atkc = count,
            atks = atks,
            atk = atk,
            qiMaxAtk = qiMaxAtk,

            hitPosName = hitPosName,

            neiliConsume = neiliConsume, -- 内力消耗

            doubleAtk = doubleAtk,  -- 副手气血伤害

            doubleQiMaxAtk = doubleQiMaxAtk, --副手气血上限伤害

            mn1 = magicNumber1,
            mn2 = magicNumber2,
            dodgeRate = trueDodgeRate,
            parryRate = trueParryRate,
            roleState = roleState,
            originalAtk = atk,
        }

    if hitType == HIT_TYPE_PARRY then
        local factor = __target:getAttr("parryHurtFixRateFactor")
        attackZhaoTable.parryFactor = factor
        attackZhaoTable.atk = attackZhaoTable.atk * math.max((1 - 0.5 - factor), 0)
        attackZhaoTable.qiMaxAtk = attackZhaoTable.qiMaxAtk * math.max((1 - 0.5 - factor), 0)
    end 

    local finalFactor = self._fight:calAutoDamageFinalFactor(self,__target, hitType)
    attackZhaoTable.damageFactor = finalFactor
    attackZhaoTable.atk = Helper:getRange(attackZhaoTable.atk * finalFactor,1)

    if self:getAttr("qiMaxAtkFactor") ~= 1 then
        attackZhaoTable.qiMaxAtk = Helper:getRange(attackZhaoTable.qiMaxAtk * self:getAttr("qiMaxAtkFactor"),0) 
    end

    if attackZhaoTable.qiMaxAtk > attackZhaoTable.atk then
        attackZhaoTable.atk = attackZhaoTable.qiMaxAtk
    end

    return attackZhaoTable
end

--创建经脉效果生成的被动招式
--cType 技能类型  jianfa/daofa
function FightRole:createJingMaiEffectAutoZhao(__target, magicNumber1, magicNumber2, cType)
    local role = self:getRole()
    local target = __target:getRole()

    local atkSkillId = role:getPrepareSkill(cType)
    if not atkSkillId then
        if cType == "quanjiao1" or cType == "quanjiao2" then
			cType = "quanjiao"
		end
		atkSkillId = "jiben"..cType 
    end
    -- print("创建经脉效果生成的被动招式  ","atkSkillId = ",atkSkillId)
    -- local atkSkill = Skill:getSkill(atkSkillId)
    
    local atkSkill = role:getPrepareAttackSkill()
    local atkZhao = atkSkill:getRandomAttackZhao(role)
    --新动画
    atkZhao.anims = Meridian:createZhaoIsAnimAndText(self,cType)

    local befFrame, atkFrame, aftFrame = role:getAttackZhaoFrames(atkZhao)
    befFrame = (atkZhao.preDuration / 3) * 30 -- 前摇时间=表格里面招式前摇时间的 1/3 add by TangJian 2016/11/18 20:59:01

    local isJingMaiZhao = true
    local hitType, atk, qiMaxAtk, neiliConsume, hitPosName, doubleAtk, doubleQiMaxAtk, trueDodgeRate, trueParryRate, roleState = self:createAttackResult(self, __target, atkSkill, atkZhao, nil, nil, magicNumber1, magicNumber2, isJingMaiZhao,cType)

    local count = #atkZhao.anims

    --重新根据动画次数计算攻击间隔
    local atks = {}
    atkFrame = 0

    for i = 1, count do
        local pos = atkZhao.anims[i].hitPos
        if pos == 'head' then
            pos = 1
        elseif pos == 'foot' then
            pos = 3
        else
            pos = 2
        end

        atks[atkFrame] = pos

        -- atkFrame = atkFrame + math.ceil(20 / atkZhao.anims[i].speed)
        -- 跳跃
        -- atkFrame = atkFrame + math.ceil(10 / atkZhao.anims[i].speed / FIGHT_JUMP_SPEED_SCALE)
        -- 前摇
        atkFrame = atkFrame + math.ceil(10 / atkZhao.anims[i].speed / FIGHT_PRESWING_SPEED_SCALE)

        -- 后摇
        atkFrame = atkFrame + 10
    -- atkFrame = atkFrame + math.ceil(10 / atkZhao.anims[i].speed / FIGHT_AFTSWING_SPEED_SCALE)
    end
    atkFrame = Helper:getRange(atkFrame, 1, 999999)

    local attackZhaoTable =
        {
            atkSkId = atkSkill.id,
            atkZhaoId = atkZhao.id,

            befFrame = befFrame,
            atkFrame = atkFrame,
            aftFrame = aftFrame,

            hitType = hitType,

            atkc = count,
            atks = atks,
            atk = atk,
            qiMaxAtk = qiMaxAtk,

            hitPosName = hitPosName,

            neiliConsume = neiliConsume, -- 内力消耗

            mn1 = magicNumber1,
            mn2 = magicNumber2,
            
            dodgeRate = trueDodgeRate,
            parryRate = trueParryRate,
            roleState = roleState,

            isJingMaiZhao = true, --经脉效果创建的招式

            _cType = cType, --具体招式类型

            doubleQiMaxAtk = doubleQiMaxAtk,

            doubleAtk = doubleAtk,

            originalAtk = atk,
        }
    return attackZhaoTable
end
-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 创建被动招式数组
function FightRole:createAutoZhaos(target, autoZhaoCount)
    autoZhaoCount = Helper:getDef(autoZhaoCount, 1)
    autoZhaoCount = Helper:getRange(autoZhaoCount, 1, 100)

    -- 生成招式表
    local autoZhaos = {}
    for i = 1, autoZhaoCount do
        local autoZhao = self:createAutoZhao(target, math.random(1, 100), math.random(1, 100))
        table.insert(autoZhaos, autoZhao)
    end
    return autoZhaos
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 创建被动招式数组
function FightRole:createZhaoForPVP(target)
    local autoZhao = self:createAutoZhao(target, math.random(1, 100), math.random(1, 100))
    return autoZhao
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 创建主动招式
function FightRole:createActiveZhao()
    local activeZhao = {test = "test"}
    return activeZhao
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 设置当前主动招式
function FightRole:setCurrActiveZhao(activeZhao)
    self._currActiveZhao = activeZhao
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 得到当前主动招式
function FightRole:getCurrActiveZhao()
    return self._currActiveZhao
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 得到被动招式
function FightRole:getAutoZhaos(targetId)
    if type(self._autoTable[targetId]) ~= "table" then
        return nil
    else
        return self._autoTable[targetId].autoZhaos
    end
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 被动招式表
function FightRole:setAutoZhaos(targetId, autoZhaos)
    self._autoTable[targetId] = Helper:getDef(self._autoTable[targetId], {})-- 初始化
    self._autoTable[targetId].currZhaoIndex = 1 -- 当前招式序列
    self._autoTable[targetId].currZhaoFrame = 1 -- 当前招式序列
    self._autoTable[targetId].autoZhaos = autoZhaos -- 设置
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/17 15:04:29
-- @desc 追加自动招式
function FightRole:appendAutoZhaos(targetId, autoZhaos)
    self._autoTable[targetId] = Helper:getDef(self._autoTable[targetId], {})-- 初始化
    print("pre appendAutoZhaos", #self._autoTable[targetId].autoZhaos)
    for k, v in pairs(autoZhaos) do
        table.insert(self._autoTable[targetId].autoZhaos, v)
    end
    print("aft appendAutoZhaos", #self._autoTable[targetId].autoZhaos)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 判断能否释放主动技能
function FightRole:canPlayActiveZhao(frameIndex)
    local activeZhao = self:getActiveZhao(self._currActiveIndex)
    if activeZhao and frameIndex >= activeZhao.f then
        return true
    else
        return false
    end
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/02/15 21:55:00
-- @desc 得到当前主动技能状态map
function FightRole:getCurrActiveZhaoStateMap()
    return self._currActiveZhaoStateMap
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/02/15 22:25:55
-- @desc 得到当前招式
function FightRole:getActiveZhaoState(activeZhaoId)
    if DEBUG_MODE == 1 then
        assert(self._currActiveZhaoStateMap[activeZhaoId], "找不到主动技能 " .. activeZhaoId)
    end
    return self._currActiveZhaoStateMap[activeZhaoId]
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/03/01 10:53:53
-- @desc 得到主动招式使用次数
function FightRole:getActiveZhaoUseTimes(activeZhaoId)
    local times = 0
    if self._activeZhaoUseTimesMap[activeZhaoId] == nil then
        self._activeZhaoUseTimesMap[activeZhaoId] = 0
    else
        times = self._activeZhaoUseTimesMap[activeZhaoId]
    end
    return times
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/03/01 10:54:37
-- @desc 主动招式使用册书++
function FightRole:addActiveZhaoUseTimes(activeZhaoId)
    if self._activeZhaoUseTimesMap[activeZhaoId] == nil then
        self._activeZhaoUseTimesMap[activeZhaoId] = 0
    end
    self._activeZhaoUseTimesMap[activeZhaoId] = self._activeZhaoUseTimesMap[activeZhaoId] + 1
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 设置autoTable
function FightRole:setAutoTable(autoTable)
    logt(self:getName(), "setAutoTable")
    self._autoTable = autoTable
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 得到被动table
function FightRole:getAutoTable()
    return self._autoTable
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 添加主动招式
function FightRole:addActiveZhao(activeZhao)
    assert(type(activeZhao.f) == "number")
    table.insert(self._activeTable, activeZhao)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 得到主动招式
function FightRole:getActiveZhao(activeZhaoIndex)
    return self._activeTable[activeZhaoIndex]
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 移除主动招式
function FightRole:removeActiveZhao(frame)
    self._activeTable[frame] = nil
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/03/15 21:03:58
-- @desc 判断招式是否是回复类型
function FightRole:activeZhaoIsInstantRecovery(activeZhaoId)
    local activeZhaoIsInstantRecoveryCache = self:getCacheMap():getCache("activeZhaoIsInstantRecoveryCache")
    local ret = activeZhaoIsInstantRecoveryCache[activeZhaoId]
    if ret ~= nil then
        return ret
    else
        local activeZhaoState = self:getActiveZhaoState(activeZhaoId)
        local effectArray = activeZhaoState:getEffectArray()
        for i, effect in ipairs(effectArray) do
            effect:setOwner(self)
            if effect:getTarget() == "目标" then
                effect:setObject(self:getTarget())
            else
                effect:setObject(self)
            end
            if effect:getType() == "属性变化" and effect:getArg1() == "qi" and effect:getFinalArg2() > 0 and effect:getFinalDuration() == 0 then
                activeZhaoIsInstantRecoveryCache[activeZhaoId] = true
                return true
            end
        end
        activeZhaoIsInstantRecoveryCache[activeZhaoId] = false
        return false
    end
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/03/11 17:49:56
-- @desc 判断招式cd是否冷却
function FightRole:activeZhaoIsCoolDown(activeZhaoId)
    local activeZhaoState = self:getActiveZhaoState(activeZhaoId)
    if activeZhaoState == nil or activeZhaoState:getCDLeft() <= 0 then
        return true
    end
    return false, "你的真气尚未调息完毕"
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/01/16 16:43:44
-- @desc 判断能否使用
function FightRole:canUseActiveZhao(activeZhaoId)
    local activeZhaoState = self:getActiveZhaoState(activeZhaoId)

    if self:getAttr("neili") < activeZhaoState:getFinalCost() then -- 内力不够无法使用 add by TangJian 2017/03/15 23:40:20
        return false, "你的内力不足"
    elseif self:isFullQi() and self:activeZhaoIsInstantRecovery(activeZhaoId) then -- 血满了限制使用回血招式 add by TangJian 2017/03/15 23:36:00
        return false, "你当前气血充盈"
    end

    if activeZhaoState:isChangeWeaponZhao() then
        local currWeapon = self:getCurrWeapon()
        local mainWeapon = self:getMainWeapon()
        local prepareWeapon = self:getPrepareWeapon()

        if currWeapon then
            if mainWeapon and mainWeapon.id == currWeapon.id then
                if prepareWeapon then
                    return true
                end

                local msg = nil
                if self.__prepareWeaponState == false then
                    msg = "另一武器已损坏，无法使用"
                else
                    msg = "没有对应武器，无法使用"
                end

                return false, msg
            end

            if prepareWeapon and prepareWeapon.id == currWeapon.id then
                if mainWeapon then
                    return true
                end

                local msg = nil
                if self.__mainWeaponState == false then
                    msg = "另一武器已损坏，无法使用"
                else
                    msg = "没有对应武器，无法使用"
                end

                return false, msg
            end
        else
            if MapIsEmpty(prepareWeapon) == false and self.__replaceWeapon and self.__replaceWeapon.id == prepareWeapon.id then
                return true
            end

            if MapIsEmpty(mainWeapon) == false and self.__replaceWeapon and self.__replaceWeapon.id == mainWeapon.id then
                return true
            end

            local msg = nil
            if self.__mainWeaponState == false or self.__prepareWeaponState == false then
                msg = "另一武器已损坏，无法使用"
            end

            if self.__mainWeaponState == true or self.__prepareWeaponState == true then
                msg = "没有对应武器，无法使用"
            end

            return false, msg
        end
    end

    return true
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/01/16 16:43:08
-- @desc 使用主动技能
function FightRole:useActiveZhao(activeZhaoId)
    local activeZhao = self:getActiveZhaoState(activeZhaoId)

    if activeZhao == nil then
        activeZhao = Skill:getActiveZhaoInPVP(activeZhaoId)
        PopText("你没有技能: " .. activeZhao:getName())
    elseif activeZhao:getCDLeft() > 0 then
        -- PopText(activeZhao:getName() .. " 正在冷却")
        elseif role:getAttr("neili") < activeZhao:getFinalCost() then
        -- PopText("内力不够, 无法使用主动招式: " .. activeZhao:getName())
        else
            PopText("使出了主动招式 " .. activeZhao:getName())

            local activeZhaos = self:getRoleActiveZhaos(roleId)
            table.insert(activeZhaos, {rid = roleId, f = frame, zid = activeZhaoId})

            local role = self:getRole(roleId)
            local activeZhaoState = role:getActiveZhaoState(activeZhaoId)
            activeZhaoState:setCDLeft(activeZhaoState:getCD())
    end
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/12/26 11:14:54
-- @desc 得到效果map
function FightRole:getEffectMap()
    return self._effectMap
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/12/26 11:16:23
-- @desc 得到效果array
function FightRole:getEffectArray()
    local effectArray = {}
    for k, v in pairs(self._effectMap) do
        table.insert(effectArray, v)
    end
    return effectArray
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/12/24 18:03:46
-- @desc 得到效果
function FightRole:getEffect(id)
    for i = #self._effectMap, 1, -1 do
        if self._effectMap[i]:getId() == id then
            return self._effectMap[i]
        end
    end
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/12/24 17:59:40
-- @desc 战斗中的效果
function FightRole:addEffect(effect)
    local isExist = false
    local id = effect:getId()

    for i = #self._effectMap, 1, -1 do
        if self._effectMap[i]:getId() == id then
            self._effectMap[i] = effect
            isExist = true
            break
        end
    end

    if isExist == false then
        table.insert(self._effectMap, effect)
    end
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/12/24 18:02:11
-- @desc 移除效果
function FightRole:removeEffect(id)
    if id ~= nil then
        for i = #self._effectMap, 1, -1 do
            if self._effectMap[i]:getId() == id then
                table.remove(self._effectMap, i)
                break
            end
        end
    end
end
-----------------------------------------------------------------------------------------------------------
function FightRole:jifeiWeapon() --打飞兵器
    --记录丢失的兵器的子类型
    local weaponSubtype = self:getRole():getCurrSubtypeByWeapon()
    self:setBeforeUnloadWeaponIsSubType(weaponSubtype)
    
    self._role:setEquipByName("weapon", nil)
    self:reinitRole()

    self:deleteEnterFightEffects()

    self._currZhaoState = 0
    self._currZhaoIndex = 0 -- 当前招式位置
    self._currZhaoFrame = 1 -- 当前招式帧    

     --@desc 武器打落后毒药不再生效
    if PVP_POISONSYS then
        if self._poisonEffectArray then
            for _,v in ipairs(self._poisonEffectArray) do
                v.canUse = false
            end
        end
    end
end
-----------------------------------------------------------------------------------------------------------
function FightRole:daduanWeapon()   --打断兵器
    --记录丢失的兵器的子类型
    local weaponSubtype = self:getRole():getCurrSubtypeByWeapon()
    self:setBeforeUnloadWeaponIsSubType(weaponSubtype)

    self._currZhaoState = 0
    self._currZhaoIndex = 0 -- 当前招式位置
    self._currZhaoFrame = 1 -- 当前招式帧 

    local weaponData = self._role:getEquipByName("weapon")

    if weaponData == nil then
        return
    end

    self:addBrokeWeaponInfo(weaponData.id,weaponData.itemId)

    -- 打断后清除武器信息，使之无法切换过去
    if self.__mainWeapon and self.__mainWeapon.id == weaponData.id then
        self.__mainWeapon = nil
        self.__mainWeaponState = false
    end
    
    -- 打断后清除武器信息，使之无法切换过去
    if self.__prepareWeapon and self.__prepareWeapon.id == weaponData.id then
        self.__prepareWeapon = nil
        self.__prepareWeaponState = false
    end

     --打断武器为切换武器目标 则清空
    if self.__replaceWeapon and self.__replaceWeapon.id == weaponData.id then
        self.__replaceWeapon = nil
    end

    if self.__quaoJiaoWeaponChangeState == 1 and self.__mainWeaponState == false then
        self.__quaoJiaoWeaponChangeState = 4
    elseif self.__quaoJiaoWeaponChangeState == 2 and self.__prepareWeaponState == false then
        self.__quaoJiaoWeaponChangeState = 4
    end 

    self._role:setEquipByName("weapon", nil)

    --@desc 武器打落后毒药不再生效
    if PVP_POISONSYS then
        if self._poisonEffectArray then
            for _,v in ipairs(self._poisonEffectArray) do
                v.canUse = false
            end
        end
    end
    
    self:reinitRole()

    self:deleteEnterFightEffects()
end
-----------------------------------------------------------------------------------------------------------
function FightRole:changeWeapon()  --易武
   
    local prepareWeapon=self._role:getPrepareWeapon()
    local weaponData = self._role:getEquipByName("weapon")
    if MapIsEmpty(prepareWeapon) then 
        print("---------------准备武器为空-------------")
        return 
    end

    if weaponData and prepareWeapon.id==weaponData.id then 
    else
        self._role:setEquipByName("weapon", prepareWeapon)
    end

    self._currZhaoState = 0
    self._currZhaoIndex = 0 -- 当前招式位置
    self._currZhaoFrame = 1 -- 当前招式帧 
    
    if POISONSYS then 
        local PoisonFight = require("app.models.Poison.FightForPoison.PoisonFight")
        PoisonFight:changeWeapon(self,true)
    end

    --文本提示(客户端本地显示)
    local prepareWeaponInfo = User:getRole():getOneItemByKey(prepareWeapon.itemId)
    if weaponData then 
        local currWeaponInfo = User:getRole():getOneItemByKey(weaponData.itemId)
        PopText("切换武器！")
        local str="YEL你将NOR"..currWeaponInfo.name.."YEL收起，将"..prepareWeaponInfo.name.."拿在手上。NOR"
        self._fight:callEventListener("printText",str)
    else
        PopText("你拿出了武器！")
        local str="YEL你将NOR"..prepareWeaponInfo.name.."YEL拿在手上，持械迎击。NOR"
        self._fight:callEventListener("printText",str)
    end
    self:reinitRole()

    self:deleteEnterFightEffects()
end

function FightRole:newWeaponChange()
    local weaponSubtype = self:getRole():getCurrSubtypeByWeapon()
    self:setBeforeUnloadWeaponIsSubType(weaponSubtype)

    local mainWeapon = self.__mainWeapon
    local prepareWeapon = self.__prepareWeapon
    local currWeapon = self._role:getEquipByName("weapon")
    local changeWeapon = nil
    local ok = false

    if self.__ChangeWeaponType == 1 then --易武
    elseif self.__ChangeWeaponType == 2 then --武器切换只跟下一次切换武器有关
        if self.__replaceWeapon then  --武器切换只跟下一次切换武器有关
            changeWeapon = self.__replaceWeapon
            self._role:setEquipByName("weapon", self.__replaceWeapon)
            if mainWeapon ~= nil and mainWeapon.id ~= self.__replaceWeapon.id then --下一次切换武器为装备武器
                self.__replaceWeapon = mainWeapon
                ok = true
            elseif prepareWeapon ~= nil and prepareWeapon.id ~= self.__replaceWeapon.id then-- 下一次切换武器为备用武器
                self.__replaceWeapon = prepareWeapon
                ok = true
            else -- 下一次切换武器为备用武器
                self.__replaceWeapon = nil
                ok = true
            end
        end
    elseif self.__ChangeWeaponType == 3 then --拳脚武器切换
        if self.__quaoJiaoWeaponChangeState == 1 then
            self._role:setEquipByName("weapon", nil)
            self.__lastQuanJiaoWeaponChangeState = 1
            self.__quaoJiaoWeaponChangeState = 3
            ok = true
        elseif self.__quaoJiaoWeaponChangeState == 2 then
            self._role:setEquipByName("weapon", nil)
            self.__lastQuanJiaoWeaponChangeState = 2
            self.__quaoJiaoWeaponChangeState = 3
            ok = true
        elseif self.__quaoJiaoWeaponChangeState == 3 then
            if self.__lastQuanJiaoWeaponChangeState == 1 then
                self.__lastQuanJiaoWeaponChangeState = 3
                self.__quaoJiaoWeaponChangeState = 1
                self._role:setEquipByName("weapon", mainWeapon)
                ok = true
            elseif self.__lastQuanJiaoWeaponChangeState == 2 then
                self._role:setEquipByName("weapon", prepareWeapon)
                self.__lastQuanJiaoWeaponChangeState = 3
                self.__quaoJiaoWeaponChangeState = 2
                ok = true
            end
        else
            PopText("没有对应武器，武器切换失败")
        end
    end

    if ok then
        self:setCurrDoubleAttackSkill(nil)
        self:setCurrDoubleAttackZhao(nil)
        self._currZhaoState = 0
        self._currZhaoIndex = 0 -- 当前招式位置
        self._currZhaoFrame = 1 -- 当前招式帧 
        
        local targetId = self:getTargetId()
        local targetRole = self:getTarget()

        local autoZhaos=self:createAutoZhaos(targetRole)
        self:setAutoZhaos(targetId, autoZhaos)
        
        if POISONSYS then 
            local PoisonFight = require("app.models.Poison.FightForPoison.PoisonFight")
            PoisonFight:changeWeapon(self,false)
        end

        if self.__ChangeWeaponType == 1 or self.__ChangeWeaponType == 2 then
             --文本提示
            local changeWeaponInfo = self._role:getOneItemByKey(changeWeapon.itemId)
            if currWeapon then 
                local currWeaponInfo = self._role:getOneItemByKey(currWeapon.itemId)
                PopText("切换武器！")
                local str="YEL$N将NOR"..currWeaponInfo.name.."YEL收起，将"..changeWeaponInfo.name.."拿在手上。NOR"
                self._fight:callEventListener("printText",str, self:getName())
            else
                PopText("你拿出了武器！")
                local str="YEL$N将NOR"..changeWeaponInfo.name.."YEL拿在手上，持械迎击。NOR"
                self._fight:callEventListener("printText",str, self:getName())
            end
        end
       
        self:reinitRole()

        self:deleteEnterFightEffects()

        self:refreshFistFootEffects()

        self:jingMaiUpdate()
    end

    return ok
end

-- changeWeaponType 1 为易武 2为切换武器效果 3拳脚武器切换
function FightRole:setChangeWeaponType(changeWeaponType)
    self.__ChangeWeaponType = changeWeaponType
end

function FightRole:getChangeWeaponType()
    return self.__ChangeWeaponType
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/03/06 16:26:32
-- @desc 能否闪避
function FightRole:canDodge()
    -- 新增瘫痪无法闪避
    if self:isSleep() or self:isFrozen() or self:isParalyzed() then
        return false
    end
    return true
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/03/06 16:26:50
-- @desc 能否招架
function FightRole:canParry()
    if self:isSleep() or self:isFrozen() then
        return false
    end
    return true
end

-- function FightRole:haveEffect()
--     for k, effect in pairs(self._effectMap) do
--         if effect:getType() == "控制" then
--             if effect:getArg1() == "晕迷" then
--                 return true
--             end
--         end
--     end
--     return false
-- end
-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/03/30 23:42:58
-- @desc 是否有反伤
function FightRole:haveFanShang()
    for k, effect in pairs(self._effectMap) do
        if effect:getType() == "反伤" then
            return true
        end
    end
    return false
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/03/31 01:12:59
-- @desc 是否有转移
function FightRole:haveZhuanYi()
    for k, effect in pairs(self._effectMap) do
        if effect:getType() == "偏转" then
            return true
        end
    end
    return false
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/03/30 20:52:34
-- @desc 是否有护盾
function FightRole:haveShield()
    for k, effect in pairs(self._effectMap) do
        if effect:getType() == "护盾" then
            return true
        end
    end
    return false
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/03/30 21:33:13
-- @desc 得到护盾值
function FightRole:getShieldValue()
    local shieldValue = 0
    for k, effect in pairs(self._effectMap) do
        if effect:getType() == "护盾" then
            shieldValue = effect:getArg1()
            break
        end
    end
    return shieldValue
end

--设置在丢失兵器之前的兵器子类型
function FightRole:setBeforeUnloadWeaponIsSubType(subType)
    self._BeforeUnloadWeaponIsSubType = subType
end

--获取丢失兵器之前的兵器子类型
function FightRole:getBeforeUnloadWeaponIsSubType()
    return self._BeforeUnloadWeaponIsSubType
end
-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/01/05 10:21:37
-- @desc 判断是否处于定身状态
function FightRole:isImmobilized()
    if self:isParalyzed() or self:isSleep() or self:isBlind() or self:isFrozen() then
        return true
    end
    return false
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/03/04 17:10:33
-- @desc 昏迷
function FightRole:isSleep()
    for k, effect in pairs(self._effectMap) do
        if effect:getType() == "控制" then
            if effect:getArg1() == "晕迷" then
                return true
            end
        end
    end
    return false
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/03/04 15:24:44
-- @desc 判断是否瘫痪
function FightRole:isParalyzed()
    for k, effect in pairs(self._effectMap) do
        if effect:getType() == "控制" then
            if effect:getArg1() == "瘫痪" then
                return true
            end
        end
    end
    return false
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/03/04 16:27:08
-- @desc 判断是否被迷惑
function FightRole:isBlind()
    for k, effect in pairs(self._effectMap) do
        if effect:getType() == "控制" then
            if effect:getArg1() == "迷惑" then
                return true
            end
        end
    end
    return false
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/03/04 17:13:43
-- @desc 定身
function FightRole:isFrozen()
    for k, effect in pairs(self._effectMap) do
        if effect:getType() == "控制" then
            if effect:getArg1() == "定身" then
                return true
            end
        end
    end
    return false
end

--@desc: 无法使用被动招式攻击
--@author:LvBin
--@time:2024-01-02 15:44:28
--@return
function FightRole:isUnableAutoAttack()
    for k, effect in pairs(self._effectMap) do
        if effect:getType() == "无法攻击" then
            return true
        end
    end
    return false
end

--@desc: 无法使用易武
--@author:LvBin
--@time:2024-02-27 15:06:55
--@return
function FightRole:isUnableYiWu()
    for k, effect in pairs(self._effectMap) do
        if effect:getType() == "无法易武" then
            return true
        end
    end
    return false
end

-- @desc 判断是否处于缴械(打掉武器)状态
function FightRole:isDisarm()
    for k, effect in pairs(self._effectMap) do
        if effect:getType() == "打掉兵器" then
           
                return true
        end
    end
    return false
end


-- @desc 判断是否处于免疫控制状态
function FightRole:isimmune()
    for k, effect in pairs(self._effectMap) do
        if effect:getType() == "免疫控制" then         
            return true
        end
    end
    return false
end

-- @desc 判断是否处于截脉状态
function FightRole:isJieMai()
    for k, effect in pairs(self._effectMap) do
        if effect:getType() == "截脉" then         
            return true
        end
    end
    return false
end

-- @desc 判断是否处于禁锢状态
function FightRole:isimprison()
    for k, effect in pairs(self._effectMap) do
        if effect:getType() == "禁锢" and effect:getArg1() == "禁锢" then         
            return true
        end
    end
    return false
end

-- @desc 判断是否处于限攻状态
function FightRole:isAttackLimit()
    for k, effect in pairs(self._effectMap) do
        if effect:getType() == "禁锢" and effect:getArg1() == "限攻" then         
            return true
        end
    end
    return false
end

-- @desc 判断是否处于抗毒状态
function FightRole:isKangDu()
    for k, effect in pairs(self._effectMap) do
        if effect:getType() == "抗毒" then         
            return true
        end
    end
    return false
end

--@desc: 判断是否处于全部遗忘状态(遗忘所有准备位武学)
--@author:LvBin
--@time:2026-04-21 17:03:06
--@return
function FightRole:isForget()
    for k, effect in pairs(self._effectMap) do
        if effect:getType() == "遗忘" and not effect:getArg2() then         
            return true
        end
    end
    return false
end

--@desc: 判断是否处于部分遗忘状态(遗忘指定准备位武学)
--@author:LvBin
--@time:2026-04-21 17:03:06
--@return
function FightRole:isPartForget()
    for k, effect in pairs(self._effectMap) do
        if effect:getType() == "遗忘" and effect:getArg2() then         
            return true
        end
    end
    return false
end

-- @desc 判断是否处于闪耀状态
function FightRole:isFlare()
    for k, effect in pairs(self._effectMap) do
        if effect:getType() == "闪耀" then         
            return true
        end
    end
    return false
end

-- @desc 判断是否处于闪烁状态
function FightRole:isGlint()
    for k, effect in pairs(self._effectMap) do
        if effect:getType() == "闪烁" then         
            return true
        end
    end
    return false
end

-- @desc 判断是否处于内省状态
function FightRole:isNeiliSave()
    for k, effect in pairs(self._effectMap) do
        if effect:getType() == "内省" then         
            return true
        end
    end
    return false
end

-- @desc 判断是否处于凝血状态
function FightRole:isCruor()
    for k, effect in pairs(self._effectMap) do
        if effect:getType() == "凝血" then         
            return true
        end
    end
    return false
end

-- @desc 判断是否处于吸血状态
function FightRole:isSuckBlood()
    for k, effect in pairs(self._effectMap) do
        if effect:getType() == "吸血" then         
            return true
        end
    end
    return false
end

-- @desc 判断是否处于反震状态
function FightRole:isFanZhen()
    for k, effect in pairs(self._effectMap) do
        if effect:getType() == "反震" then         
            return true
        end
    end
    return false
end

-- @desc 判断是否处于内伤状态
function FightRole:isNeiShang()
    for k, effect in pairs(self._effectMap) do
        if effect:getType() == "内伤" then         
            return true
        end
    end
    return false
end

-- @desc 判断是否有真伤效果
function FightRole:isTrueDamage()
    for k, effect in pairs(self._effectMap) do
        if effect:getType() == "真伤" then         
            return true
        end
    end
    return false
end

-- @desc 判断是否有强招架效果
function FightRole:isParry()
    for k, effect in pairs(self._effectMap) do
        if effect:getType() == "强招架" and effect:getFinalArg1() > 0 then      
            return true
        end
    end
    return false
end

-- @desc 判断是否有卸力效果
function FightRole:isUnloadForce()
    for k, effect in pairs(self._effectMap) do
        if effect:getType() == "卸力" then         
            return true
        end
    end
    return false
end

-- @desc 判断是否有破招效果
function FightRole:isPoZhao()
    for k, effect in pairs(self._effectMap) do
        if effect:getType() == "破招" then         
            return true
        end
    end
    return false
end

-- @desc 判断是否有抗增益效果
function FightRole:isKangZengYi()
    for k, effect in pairs(self._effectMap) do
        if effect:getType() == "抗增益" then         
            return true
        end
    end
    return false
end

-- @desc 判断是否有抗减益效果
function FightRole:isKangJianYi()
    for k, effect in pairs(self._effectMap) do
        if effect:getType() == "抗减益" then         
            return true
        end
    end
    return false
end

-- @desc 判断是否有延时效果
function FightRole:isDelayEffect()
    for k, effect in pairs(self._effectMap) do
        if effect:getType() == "延时生效" then         
            return true
        end
    end
    return false
end

-- @desc 判断是否有反噬效果
function FightRole:isFanShi()
    for k, effect in pairs(self._effectMap) do
        if effect:getType() == "反噬" then         
            return true
        end
    end
    return false
end

-- @desc 判断是否有修武效果
function FightRole:isXiuWu()
    for k, effect in pairs(self._effectMap) do
        if effect:getType() == "修武" then         
            return true
        end
    end
    return false
end

-- @desc 判断是否有真罡效果
function FightRole:isZhenGang()
    for k, effect in pairs(self._effectMap) do
        if effect:getType() == "真罡" then         
            return true
        end
    end
    return false
end

-- @desc 判断是否有致盲效果 命中失效
function FightRole:isHitFailure()
    for k, effect in pairs(self._effectMap) do
        if effect:getType() == "致盲" then         
            return true
        end
    end
    return false
end

--@desc: 必中，优先级高于致盲和强招架
--@author:LvBin
--@time:2026-04-13 11:26:56
--@return
function FightRole:isHit()
    for k, effect in pairs(self._effectMap) do
        if effect:getType() == "必中" then         
            return true
        end
    end
    return false
end

--@desc: 指定抵抗效果类型
--@author:LvBin
--@time:2024-07-12 11:05:50
--@return
function FightRole:isResistType(targetEffect)
    local resistEffectTypeList = {}
    for k, effect in pairs(self._effectMap) do
        if effect:getType() == "类型抵抗" then         
            local _resistEffectTypeList = string.split(effect:getArg1(), "#")
            table.appendArray(resistEffectTypeList, _resistEffectTypeList)
        end
    end

    if MapIsEmpty(resistEffectTypeList) == false then
        for i, effectType in ipairs(resistEffectTypeList) do
            if targetEffect:checkHaveEffectType(tonumber(effectType)) then
                return true
            end
        end
    end

    return false
end

--@desc: 指定抵抗效果id
--@author:LvBin
--@time:2024-07-12 11:05:50
--@return
function FightRole:isResistId(targetEffect)
    local resistEffectIdList = {}
    for k, effect in pairs(self._effectMap) do
        if effect:getType() == "指定抵抗" then         
            local _resistEffectIdList = string.split(effect:getArg1(), "#")
            table.appendArray(resistEffectIdList, _resistEffectIdList)
        end
    end

    if MapIsEmpty(resistEffectIdList) == false then
        for i, effectId in ipairs(resistEffectIdList) do
            if targetEffect:getId() == effectId then
                return true
            end
        end
    end

    return false
end

-- @desc 判断是否有伤害转持续自伤
function FightRole:isInDamageToHurt()
    for k, effect in pairs(self._effectMap) do
        if effect:getType() == "伤害转持续自伤" then         
            return true
        end
    end
    return false
end

function FightRole:isDamageMax()
    for k, effect in pairs(self._effectMap) do
        if effect:getType() == "单次伤害上限" then         
            return true
        end
    end
    return false
end

function FightRole:calDamageMax()
    local value = 99999999
    for k, effect in pairs(self._effectMap) do
        if effect:getType() == "单次伤害上限" and type(effect:getArg2()) == "number" and effect:getArg2() < value then
            value = effect:getArg2()
            break
        end
    end

    return value
end

function FightRole:isRecordDamage()
    for k, effect in pairs(self._effectMap) do
        if effect:getType() == "记录承受伤害" then         
            return true
        end
    end
    return false
end

--检查人物身上的效果是否有指定类型的效果
function FightRole:checkHaveEffectType(effectType)
    if effectType == nil or tonumber(effectType) == nil then
        return false
    end
    for k, effect in pairs(self._effectMap) do
        if effect:checkHaveEffectType(effectType) then         
            return true
        end
    end
    return false
end

--能否触发空手状态buff
function FightRole:IsKongShouBuff(effectId)
    if effectId ~= "KONGSHOU" then
        return false
    end
    if self:getAttackMethod() == SKILL_METHOD_TYPE_QUANJIAO then
        return true
    end
    return false
end

--能否触发持械状态buff
function FightRole:IsCheXieBuff(effectId)
    if effectId ~= "CHIXIE" then
        return false
    end
    if self:getAttackMethod() ~= SKILL_METHOD_TYPE_QUANJIAO then
        return true
    end
    return false
end

--检查特殊关联效果能否触发
function FightRole:checkCorrelationStateBuff(effectId)
    local EffectIdList = {
        KONGSHOU = self:IsKongShouBuff(effectId),
        CHIXIE = self:IsCheXieBuff(effectId),
    }

    if effectId and EffectIdList[effectId] == true then
        return true
    end

    return false
end

--@desc: 获取回复比例
--@author:LvBin
--@time:2024-04-03 17:25:03
--@attr: 回复属性
--@effectType: 效果类型
--@return
function FightRole:getHuiFuRatio(attr,effectType)
    local num = 0
    for k,effect in pairs(self:getEffectMap()) do
        if effect:getType() == "恢复修正" then
            local objectArg1 = effect:getArg1()
            local objectArg2 = tonumber(effect:getFinalArg2())
			local objectArg3 = effect:getArg3()
            if type(objectArg1) == "string" and type(objectArg2) == "number" and string.find(objectArg1,attr) and string.find(objectArg3,effectType) then
                num = num + objectArg2
            end
        end
    end

    return math.max(1-num,0)
end

--获取指定类型效果的数量
--effectType 效果的类型(0=正面效果 1=减益效果(非毒类) ...)
function FightRole:getEffectNumByEffectType(effectType)
    local effectNum = 0
    local effectMap = self:getEffectMap()
    if not MapIsEmpty(effectMap) then
        for k,effect in pairs(effectMap) do
            if effect:checkHaveEffectType(effectType) then
                effectNum = effectNum + 1
            end
        end
    end
    return effectNum
end

function FightRole:getTarget()
    local fight = self._fight
    if not fight then
        return
    end
    
    local target = fight:getRole(self:getTargetId())

    return target
end
-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/01/16 17:24:43
-- @desc 刷新帧
function FightRole:updateFrame(frameIndex)
    -- cd冷却
    for k, activeZhao in pairs(self._currActiveZhaoStateMap) do
        activeZhao:refreshCD()
    end

    --后台同步刷新上一个状态的技能cd
    for k, activeZhao in pairs(self._lastActiveZhaoStateMap) do
        activeZhao:refreshCD()
    end

    -- 经脉刷新
    if IS_OPEN_PVP_JINGMAI == true then
        self:jingMaiUpdate()
    end
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/03/15 23:16:43
-- @desc 死亡条件判断
function FightRole:canDie()
    local isDie = false
    --@desc 2018-09-29 15:32:28 加入判断人物是否已经死亡isDead()
    if self:isUndead() == false and math.floor(self:getAttr("qi")) <= 0 and self:isDead() == false then
        isDie = true
    end

    if self:getRole():getSkill("zhengaoxuanjing") ~= nil  then
        local trigger_num = 33
        local ran_num = self._fight:random(1,100)
        if isDie == true and ran_num <= trigger_num and self._isRevive ~= true then
            local list = {
                "HFZGXJ",
                "HDZGXJ",
                "LXZGXJ",
                "FYSZGXJ"
            }

            if self:getCurrQiMax() < 1 then                                                                                                                            
                local qiMax = self:getFinalAttr("qiMax")
                
                local qiPercent = 1 / qiMax
                 -- 浮点精度保护：仅在精度丢失时补偿 
                if qiMax * qiPercent < 1 then
                    qiPercent = (1 + 1e-10) / qiMax
                end

                self:setAttr("qiPercent", qiPercent)                                                                                                                                         
            end

            if self:getAttr("qi") < 0 then
                self:setAttr("qi", 0)
            end
    
            for i,v in ipairs(list) do
                local effect = clone(Skill:getSkillEffect(v))
                effect:setOwner(self)
                effect:setObject(self)
                local immediateEffectUIInfo = self._fight:roleAddEffect(self, self,effect)
                local duration = effect:getFinalDuration()
                if duration == 0 then
                    self._fight:callEventListener("doEffect", self, effect, immediateEffectUIInfo)   
                else
                    self._fight:callEventListener("beginEffect", self, effect, immediateEffectUIInfo)
                end
            end
    
            isDie = false

            self._fight:callEventListener("updateBackground","振1")

            local imageView = ccui.ImageView:create()
            imageView:ignoreContentAdaptWithSize(false)
            imageView:loadTexture("Image/UI/WordFightUI/redMesh.png",0)
            imageView:setSize({width=1080,height=900})
            imageView:setAnchorPoint(0,1)
            imageView:setPosition(0,1910)
            imageView:setCascadeColorEnabled(true)
            imageView:setCascadeOpacityEnabled(true)
            imageView:setLocalZOrder(10000)

            imageView:runAction(
                cc.RepeatForever:create(cc.Sequence:create(cc.FadeOut:create(0.5), cc.FadeIn:create(0.5)))
            )

            self._fight:callEventListener("addNode",imageView)


            self._fight:callEventListener("delayFunc",5,function ()
                self._fight:callEventListener("updateBackground","orgin")
                imageView:removeFromParent()
            end)
    
            self._isRevive = true
        end
    end
    
    return isDie
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 设置招式，自动判断是否初始化，如果没有就初始化，如果有，就append
function FightRole:setAutoZhaosAsSafe(targetId, autoZhaos)
    local isEmpty = true
    if type(self._autoTable[targetId]) ~= "table" then
        isEmpty = true
    else
        isEmpty = false
    end

    if isEmpty then
        print("setAutoZhaosAsSafe empty = true")
        self:setAutoZhaos(targetId, autoZhaos)
    else
        print("setAutoZhaosAsSafe empty = false")
        self:appendAutoZhaos(targetId, autoZhaos)
    end
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 设置当前主动招式
function FightRole:setCurrActiveZhao(activeZhao)
    self._currActiveZhao = activeZhao
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 得到当前主动招式
function FightRole:getCurrActiveZhao()
    return self._currActiveZhao
end

-- 自动招式位置自动加1
function FightRole:incrementAutoIndex()
	self._currentAutoIndex = self._currentAutoIndex + 1
end

-- 得到当前自动招式播放到的位置
function FightRole:getAutoIndex()
	return self._currentAutoIndex
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @author TangJian --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @time 2017/05/09 11:57:16 -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @desc 主动招式 -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/05/09 11:52:46
-- @desc 得到准备的主动招式
function FightRole:getPreparedActiveZhaoArray()
    if self._role.isDreamRole then
        return self._role:getPreparedActiveZhaoArray()
    elseif self._role.isNpc or self._role.isGuYongBing or self._role._isZhang then
        return self._role:getPreparedActiveZhaoArray()
    else
        return self._role:getPreparedActiveZhaoIdAndNameWithLevelMap()
    end
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/05/09 12:07:26
-- @desc 得到所有主动招式
function FightRole:getActiveZhaoMap()
    local preparedActiveZhaoMap = {}
    local prepareZhaoList = nil

    if self._role.isDreamRole then
        prepareZhaoList = self._role:getPreparedActiveZhaoIdArray()
    elseif self._role.isNpc or self._role.isGuYongBing or self._role._isZhang then
        prepareZhaoList = self._role:getPreparedActiveZhaoIdArray()
    else
        prepareZhaoList = self._role:getPreparedActiveZhaoIdWithLevelMap()
    end
    
    table.insert(prepareZhaoList, "huifu")

    for i, activeZhaoId in pairs(prepareZhaoList) do
        preparedActiveZhaoMap[activeZhaoId] = Skill:getActiveZhaoInPVP(activeZhaoId):clone()
    end
    return preparedActiveZhaoMap
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @author TangJian --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @time 2017/05/04 19:11:56 -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @desc 状态机 ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/05/04 19:13:29
-- @desc 更新状态机
function FightRole:stateMachineUpdate()
    for k, stateMachine in pairs(self._stateMachineMap) do
        stateMachine:update()
    end
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/05/04 19:13:21
-- @desc 添加状态机
function FightRole:addStateMachine(k, stateMachine)
    self._stateMachineMap[k] = stateMachine
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/05/04 19:15:39
-- @desc 移除状态机
function FightRole:removeStateMachine(k)
    self._stateMachineMap[k] = nil
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @author TangJian --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @time 2017/05/04 19:18:00 -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @desc 经脉系统相关 -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/05/04 19:19:22
-- @desc 经脉系统初始化
function FightRole:jingMaiInit()
    if IS_OPEN_PVP_JINGMAI == true then
        self._fightRoleJingMai = FightRoleJingMai:create()
        self._fightRoleJingMai:init(self)
    end

-- self:jingMaiStateMachineInit()
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/05/04 22:16:59
-- @desc 经脉刷新
function FightRole:jingMaiUpdate()
    if IS_OPEN_PVP_JINGMAI == true then
        self._fightRoleJingMai:update()
    end
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/05/04 22:45:23
-- @desc 触发筋脉印记
function FightRole:triggerJingMaiYinJi(type, ...)
    if IS_OPEN_PVP_JINGMAI == true then
        self._fightRoleJingMai:triggerJingMaiYinJi(self, type, ...)
    end
end

--@desc: 获取角色淬毒信息
--@author:Liang SongQiang
--@time:2018-01-22 17:37:23
function FightRole:getRolePoisons()
    return self._poisonEffectArray
end

--检查是否有特殊经脉效果触发
function FightRole:cheackHaveSpecialMeridianEffect()
    local role = self:getRole()
    local meridianList = {}
    local specialMeridianList = Meridian:getSpecialMeridianList()
	for i,v in ipairs(specialMeridianList) do
		if role:isHaveImprintingId(v.id) and (v.value >= self._fight:randomAndSetSeed( 1,100) or DEBUG_MODE == 1) then
			table.insert( meridianList, {id = v.id, effect = v.effect, name = v.name})
		end
	end

    local meridian = nil
    local isTrue = true

	if MapIsEmpty(meridianList) then
        local list = {}
        for k, effect in pairs(self._effectMap) do
            if effect:getType() == "拳脚经脉增强" then
                local ids = string.split(effect:getArg1(),"#")
                local idWeights = string.split(effect:getArg2(),"#")
                local effectId = effect:getId()
                local zargs = effect:getZArgs()
                local params = {}
                if zargs then
                    for i, v in ipairs(zargs) do
                        params["z" .. i] = v
                    end
                end

                for i, id in ipairs(ids) do
                    local weight = Helper:GetValueFromScript(idWeights[i], params)
                    local _info = {
                        id = id,
                        weight = tonumber(weight),
                        effectId = effectId
                    }

                    table.insert(list, _info)
                end
            end
        end

        if MapIsEmpty(list) then
            return false
        end

        local idWeightList = {}
        for i, v in ipairs(list) do
            if not idWeightList[v.id] then
                idWeightList[v.id] = 0
            end

            idWeightList[v.id] = idWeightList[v.id] + v.weight
        end

        local specialMeridianList = Meridian:getSpecialMeridianList()
        for i,v in ipairs(specialMeridianList) do
            local randWeight = idWeightList[v.id]
            if randWeight then
                LogSystem:log("旧版战斗：七化经脉","  |效果概率加成，经脉id：",v.id," |概率：",randWeight)
                if role:isHaveImprintingId(v.id) then
                    randWeight = randWeight + v.value
                end
    
                if randWeight > 0 and randWeight > self._fight:randomAndSetSeed( 1,100) then
                    table.insert( meridianList, {id = v.id, effect = v.effect, name = v.name})
                end
            end
        end

        if MapIsEmpty(meridianList) then
            return false
        end

        meridian = meridianList[self._fight:random(1,#meridianList)]
        LogSystem:log("旧版战斗：七化经脉","  |效果触发，经脉id：",meridian.id)

        local randMeridianId = meridian.id
        for i, v in ipairs(list) do
            if v.id == randMeridianId then
                local effectId = v.effectId
                local effect = self:getEffect(effectId)
                if effect then
                    local arg3 = effect:getFinalArg3()
                    
                    if arg3 - 1 <= 0 then
                        self._fight:callEventListener("endEffect", self, effect)
                        self._fight:roleRemoveEffect(self, effectId)
                    else
                        effect:setArg3(arg3 - 1)
                        LogSystem:log("旧版战斗：拳脚经脉增强","  |效果id：",effectId,"  |剩余次数：",arg3 - 1)
                    end
                end
            end
        end
    else
        meridian = meridianList[self._fight:random(1,#meridianList)]
        LogSystem:log("旧版战斗：七化经脉","  |正常触发，经脉id：",meridian.id)
	end

	return isTrue, meridian
end

function FightRole:addFragile(arg, duration, value, valueMax)
    valueMax = tonumber(valueMax)
    duration = tonumber(duration)
    local fragile = nil

    local fragileId = FightConfig:getFragileIdByArg(arg)

    fragile = self.__fragiles[fragileId]
    
    if fragile.duration == 0 then
        fragile.value = 0
    end

    if fragile.value < 0 then
        print("error：addFragile:", arg, fragile.value, duration)
        return
    end

    fragile.value = Helper:getRange(fragile.value + value, 0, valueMax)

    if duration > fragile.duration then
        fragile.duration = duration
    end

    print(string.format("%s:易伤值 + %d", arg, value))
    print(string.format("%s:重置易伤时间%d", arg, duration))
end

function FightRole:getFragileValue(id)
    if self.__fragiles[id] then
        if self.__fragiles[id].duration > 0 then
            return self.__fragiles[id].value
        end
    end

    return 0
end


function FightRole:updateFragile()
    if MapIsEmpty(self.__fragiles) == false then
        for k, fragile in pairs(self.__fragiles) do
            fragile.duration = math.max(fragile.duration - 1, 0)
        end
    end
end

function FightRole:addAugment(arg, duration, value, valueMax)
    valueMax = tonumber(valueMax)
    duration = tonumber(duration)
    local augment = nil

    local augmentId = FightConfig:getAugmentIdByArg(arg)
    augment = self.__augments[augmentId]
    
    if augment.duration == 0 then
        augment.value = 0
    end

    if augment.value < 0 then
        print("error：addAugment:", arg, augment.value, duration)
        return
    end

    augment.value = Helper:getRange(augment.value + value , 0, valueMax)

    if duration > augment.duration then
        augment.duration = duration
    end
    
    print(string.format("%s:增伤值 + %d", arg, value))
    print(string.format("%s:重置增伤时间%d", arg, duration))
end

function FightRole:getAugmentValue(id)
    if self.__augments[id] then
        if self.__augments[id].duration > 0 then
            return self.__augments[id].value
        end
    end

    return 0
end

function FightRole:updateAugment()
    if MapIsEmpty(self.__augments) == false then
        for k, augment in pairs(self.__augments) do
            augment.duration = math.max(augment.duration - 1, 0)
        end
    end
end
function FightRole:printFightRoleInfo()
    LogSystem:log("旧版战斗：","角色数据打印  名称  =  ",self:getName(),"|等级  =  ",self:getRole().lv,"|经验  =  ",self:getRole().exp,"|先天臂力  =  ",self:getRole().str,"|先天根骨  =  ",self:getRole().con,"|先天身法  =  ",self:getRole().dex,"|后天臂力  =  ",self:getRole().secStr,"|后天根骨  =  ",self:getRole().secCon,"|后天身法  =  ",self:getRole().secDex,"|等效臂力  =  ",self:getRole():getEffectStr(),"|等效根骨  =  ",self:getRole():getEffectCon(),"|等效身法  =  ",self:getRole():getEffectDex(),"|气血上限  =  ",self:getRole():getFinalAttr("qiMax"),"|内力上限  =  ",self:getRole():getFinalAttr("neiliMax"),"|攻击力  =  ",self:getRole():getAtk(),"|防御力  =  ",self:getRole():getDef(),"|加力值  =  ",self:getRole():getAttr("jiaLi"),"|伤害力  =  ",self:getRole():getPowerDamage(),"|防护力  =  ",self:getRole():getFangHu(),"|闪躲力  =  ",self:getRole():getDodge(),"|命中力  =  ",self:getRole():getHitRate(),"|招架力  =  ",self:getRole():getParry()," |拳脚谙技值  =  ",self:getJqdamage())
    LogSystem:log("旧版战斗：","--------准备武学--------")
    LogSystem:log("旧版战斗：",self:getRole():getSkillPrepare())
    LogSystem:log("旧版战斗：","------当前buff详情------")
    if self:getRole()._buffManager then
        self:getRole()._buffManager:printBuffsInfo()
    else
        LogSystem:log("旧版战斗：","无buff")
    end
end

function FightRole:printZhaoInfo(target,qiAtk,qiMaxAtk)
    local cType = self:getRole():getCurrTypeByWeapon()
    if cType == "quanjiao" then
        -- 暂用拳脚1做计算
        cType = "quanjiao1"
    end
    local skillLv, factor = self:getRole():getSkillLvAndFactor(cType, "atk")
    local skillLv1, factor1 = self:getRole():getSkillLvAndFactor(cType, "powerAtkRate")
    local ownerWeaponStr = "|武器伤害力  =  "..tostring(self:getWeaponDamage())

    LogSystem:log("旧版战斗：","招式数据打印 攻击者名称  =  ",self:getName(),"|总HP伤害  =  ",qiAtk,"|HP上限伤害  =  ",qiMaxAtk,"|攻击武学  =  ",self:getRole():getPrepareAttackSkill().id,"|武功等效技能等级 = ",skillLv,"|攻击力系数 = ",factor,"|内力上限  =  ",self:getRole():getFinalAttr("neiliMax"),"|当前经验  =  ",self:getRole().exp,"|等效臂力  =  ",self:getRole():getEffectStr(),"|实际加力值  =  ",self:getRole():getFinalAttr("jiaLi"),"|加力系数  =  ",factor1..ownerWeaponStr,"|伤害力  =  ",self:getRole():getPowerDamage(),"|目标保护力  =  ",target:getRole():getFangHu(),"|体力值 = ",self:getAttr("tili")," |拳脚谙技值  =  ",self:getJqdamage())
end

function FightRole:addEffectAnim(animName)
    assert(animName,"addEffectAnim 动画为空")
    
    table.insert(self._effectAnims, animName)
end

function FightRole:getEffectAnims()
    LogSystem:log("旧版战斗：效果动画",self._effectAnims," | 持有者：",self:getName())
    return self._effectAnims
end

function FightRole:getFistFootEffects()
end

function FightRole:recordFistFootEffect(effectId)
    if not self.__recordFistFootEffects then
        self.__recordFistFootEffects = {}
    end

    if self.__recordFistFootEffects[effectId] then
        return
    end

    if effectId then
        self.__recordFistFootEffects[effectId] = true
    else
        assert(false, "FightRole:addFistFootEffect 效果id为空")
    end
end

function FightRole:refreshFistFootEffects()
    local weapon = self._role:getEquipByName("weapon")
    local weapontype = self._role:getCurrWeaponType()

    if weapon ~= nil and weapontype ~= "拳脚" then
        local fistFootEffects = self.__fistFootEffects
        if MapIsEmpty(fistFootEffects) == false then
            for effectId , v in pairs(fistFootEffects) do
                if self:getEffect(effectId) then
                    self._fight:roleRemoveEffect(self, effectId)
                end
            end
        end
    end
end

function FightRole:getJqdamage()
    local jqdamage = 0

    local weapon = self._role:getEquipByName("weapon")
    local weapontype = self._role:getCurrWeaponType()

    if weapon == nil or weapontype == "拳脚" then
        jqdamage = self:getPrepJqdamage() + self:getStandByJqdamage()
    end

    LogSystem:log("旧版战斗：拳脚谙技值：",jqdamage," |当前玩家名字：",self:getName())

    return jqdamage
end

function FightRole:getPrepJqdamage()
    local jqdamage = self._role:getPrepJqdamage()

    LogSystem:log("旧版战斗：主手拳脚谙技值：",jqdamage," |当前玩家名字：",self:getName())

    return jqdamage
end

function FightRole:getStandByJqdamage()
    local jqdamage = self._role:getStandByJqdamage()

    LogSystem:log("旧版战斗：副手拳脚谙技值：",jqdamage," |当前玩家名字：",self:getName())

    return jqdamage
end

function FightRole:checkIsPrepSkillZhao(zhaoId)
    if self.__prepSkillZhaoMap[zhaoId] then
        return true
    end

    local skillId = self:getRole():getPrepareSkill("quanjiao1")
    if not skillId then
        return false
    end

    local isTrue = self:getRole():checkZhaoIsBelongToSkill(zhaoId, skillId)

    if isTrue then
        self.__prepSkillZhaoMap[zhaoId] = true
        return true
    end

    return false
end

function FightRole:checkIsStandBySkillZhao(zhaoId)
    if self.__standBySkillZhaoMap[zhaoId] then
        return true
    end

    local skillId = self:getRole():getPrepareSkill("quanjiao2")
    if not skillId then
        return false
    end

    local isTrue = self:getRole():checkZhaoIsBelongToSkill(zhaoId, skillId)

    if isTrue then
        self.__standBySkillZhaoMap[zhaoId] = true
        return true
    end

    return false
end

--添加角色默认效果
function FightRole:addRoleDefaultEffect()
    self:__addSkillStartFightEffects()
    self:__addActiveZhaoStartFightEffects()
end

--添加角色由武学携带的效果
--添加天竞门心法效果
--添加神照经效果
--添加长生诀阴效果
--添加丹匮玄功效果
function FightRole:__addSkillStartFightEffects()
    local roleDefaultEffects = FightConfig:getStartFightSkillDefaultEffects()
    local weaponType = self._role:getCurrTypeByWeapon()

    if not self.__startFightAddEffectSkillIds then
        self.__startFightAddEffectSkillIds = {}
    end

    for i, v in pairs(roleDefaultEffects) do
        local isAdd = false
        if v.conditionType == 1 then
            if self._role:getSkill(v.skillId) ~= nil then
                isAdd = true
            end
        elseif v.conditionType == 2 then
            local conditions = string.split(v.conditionValue, ";")
            for __, prepareType in ipairs(conditions) do
                if isAdd == false then
                    local skillId = self._role:getPrepareSkill(prepareType)
                    if v.skillId == skillId then
                        isAdd = true
                    end
    
                    if prepareType ~= "quanjiao1" and prepareType ~= "quanjiao2" and prepareType ~= "zhaojia" and prepareType ~= "neigong" and prepareType ~= "qinggong" then
                        if weaponType ~= "quanjiao" and weaponType ~= prepareType then
                            isAdd = false
                        elseif weaponType == "quanjiao" then
                            isAdd = false
                        end
                    elseif prepareType == "quanjiao1" or prepareType == "quanjiao2" then
                        if weaponType ~= "quanjiao" then
                            isAdd = false
                        end
                    end
                end
            end
        end

        if isAdd and not self.__startFightAddEffectSkillIds[v.effectId] then
            local effect = Skill:getSkillEffect(v.effectId):clone()
            effect:setOwner(self)
            effect:setObject(self)
    
            self._fight:roleAddEffect(self, self, effect)

            self.__startFightAddEffectSkillIds[v.effectId] = v.skillId
        end
    end
end

--添加角色由主动技能携带的效果
function FightRole:__addActiveZhaoStartFightEffects()
    if MapIsEmpty(self._preparedActiveZhaoMap) == false then
        if not self.__passiveEffectActiveZhaoIds then
            self.__passiveEffectActiveZhaoIds = {}
        end

        for zhaoId, activeZhao in pairs(self._preparedActiveZhaoMap) do
            local effects = FightConfig:getPassiveEffectsByActiveZhaoId(zhaoId)
            if not MapIsEmpty(effects) then
                for i,effect in ipairs(effects) do
                    effect:setOwner(self)
                    effect:setObject(self)

                    self._fight:roleAddEffect(self, self, effect)
                    self.__passiveEffectActiveZhaoIds[zhaoId] = true
                end
            end
        end
    end
end

-- 刷新角色默认效果
function FightRole:refreshRoleDefaultEffect()
    if not self._fight then
        return
    end

    local needRemoveEffects = {}
    if MapIsEmpty(self.__passiveEffectActiveZhaoIds) == false then
        for zhaoId, __ in pairs(self.__passiveEffectActiveZhaoIds) do
            local removeType = FightConfig:getPassiveEffectsRemoveType(zhaoId)
            if removeType == 1 then
                local effects = FightConfig:getPassiveEffectsByActiveZhaoId(zhaoId)
                if not MapIsEmpty(effects) then
                    needRemoveEffects[zhaoId] = effects
                end
            end
        end
    end

    if MapIsEmpty(self._preparedActiveZhaoMap) == false then
        if MapIsEmpty(needRemoveEffects) == false then
            for zhaoId, effects in pairs(needRemoveEffects) do
                local zhaoIsExist = false
                for _zhaoId, activeZhao in pairs(self._preparedActiveZhaoMap) do
                    if zhaoId == _zhaoId then
                        zhaoIsExist = true
                    end
                end
    
                if zhaoIsExist == false then
                    if not MapIsEmpty(effects) then
                        for i,effect in ipairs(effects) do
                            local effectId = effect:getId()
                            self:removeEffect(effectId)
                            self.__passiveEffectActiveZhaoIds[zhaoId] = nil
                        end
                    end
                end
            end
        end

        for zhaoId, activeZhao in pairs(self._preparedActiveZhaoMap) do
            if not self.__passiveEffectActiveZhaoIds[zhaoId] then
                local effects = FightConfig:getPassiveEffectsByActiveZhaoId(zhaoId)
                if not MapIsEmpty(effects) then
                    for i,effect in ipairs(effects) do
                        effect:setOwner(self)
                        effect:setObject(self)

                        self._fight:roleAddEffect(self, self, effect)
                        self.__passiveEffectActiveZhaoIds[zhaoId] = true
                    end
                end
            end
        end
    else
        for zhaoId, effects in pairs(needRemoveEffects) do
            if not MapIsEmpty(effects) then
                for i,effect in ipairs(effects) do
                    local effectId = effect:getId()
                    self:removeEffect(effectId)
                    self.__passiveEffectActiveZhaoIds[zhaoId] = nil
                end
            end
        end
    end

    local weaponType = self._role:getCurrTypeByWeapon()
    if MapIsEmpty(self.__startFightAddEffectSkillIds) == false then
        for k, skillId in pairs(self.__startFightAddEffectSkillIds) do
            local info = FightConfig:getStartFightInfoBySkillId(skillId)
            if info then
                if info.conditionType == 2 and info.removeType == 1 then
                    local conditions = string.split(info.conditionValue, ";")
                    local isTrue = false
                    for __, prepareType in ipairs(conditions) do
                        if isTrue == false then
                            local skillId = self._role:getPrepareSkill(prepareType)
                            if info.skillId == skillId then
                                isTrue = true
                            end

                            if prepareType ~= "quanjiao1" and prepareType ~= "quanjiao2" and prepareType ~= "zhaojia" and prepareType ~= "neigong" and prepareType ~= "qinggong" then
                                if weaponType ~= "quanjiao" and weaponType ~= prepareType then
                                    isTrue = false
                                elseif weaponType == "quanjiao" then
                                    isTrue = false
                                end
                            elseif prepareType == "quanjiao1" or prepareType == "quanjiao2" then
                                if weaponType ~= "quanjiao" then
                                    isTrue = false
                                end
                            end
                        end
                    end

                    if isTrue == false then
                        self:removeEffect(info.effectId)
                        self.__startFightAddEffectSkillIds[k] = nil
                    end
                end
            end
        end
    end

    self:__addSkillStartFightEffects()
end

-------------------------------------------------------------------------------------------------------------------------------------------------
--@desc: 是否有储伤
--@author:LvBin
--@time:2023-03-09 16:45:58
--@return
function FightRole:isSaveDamage()
    for k, effect in pairs(self._effectMap) do
        if effect:getType() == "储伤" then
            return true
        end
    end

    return false
end

--@desc: 是否有指定伤害类型储伤
--@author:LvBin
--@time:2023-03-09 16:45:58
--@hurt: [src.app.models.fight.Hurt.BaseHurt#BaseHurt]
--@return
function FightRole:isSaveDamageByHurt(hurt)
    for k, effect in pairs(self._effectMap) do
        if effect:getType() == "储伤" then
            local effectObject = effect:getEffectObject(self)
            if effectObject:isTakeEffect() then 
                if hurt:isActiveHurt() and effectObject:isActiveHurtSaveDamage() then
                    return true
                elseif hurt:isAutoHurt() and effectObject:isAutoHurtSaveDamage() then
                    return true
                end
            end
        end
    end

    return false
end

--@desc: 根据伤害类型添加储伤值
--@author:LvBin
--@time:2023-04-11 11:48:57
--@hurt: [src.app.models.fight.Hurt.BaseHurt#BaseHurt]
function FightRole:addSaveDamageValueByHurt(hurt)
    for k, effect in pairs(self._effectMap) do
        if effect:getType() == "储伤" then
            local effectObject = effect:getEffectObject(self)
            if effectObject:isTakeEffect() then
                if hurt:isActiveHurt() and effectObject:isActiveHurtSaveDamage() then
                    effectObject:addActiveHurtSaveDamageValue(hurt:getValue())
                    break
                elseif hurt:isAutoHurt() and effectObject:isAutoHurtSaveDamage() then
                    effectObject:addAutoHurtSaveDamageValue(hurt:getValue())
                    break
                end
            end
        end
    end
end

--@desc: 监控角色属性
--@author:LvBin
--@time:2023-03-10 16:38:36
--@return
function FightRole:attrMonitor()
    for k, effect in pairs(self._effectMap) do
        if effect:getType() == "监控角色属性" then
            local effectObject = effect:getEffectObject(self)
            if effectObject:isTrigger() then
                effectObject:trigger()
            end
        end
    end
end

--@desc: 刷新角色脚底光环动画
--@author:LvBin
--@time:2023-03-11 15:50:33
--@return
function FightRole:refreshRoleShadowSpriteEffect()
    if not self._fight then
        return
    end

    local effectAnimName = FightConfig:getRoleShadowSpriteEffect(self)
    
    self._fight:callEventListener("changeRoleShadowSpriteEffect",self,effectAnimName)
end

--@desc: 刷新储伤区域文本
--@author:LvBin
--@time:2023-03-14 15:30:44
--@return
function FightRole:refreshRoleEffectText()
    if not self._fight then
        return
    end

    self._fight:callEventListener("refreshRoleEffectText",self)
end

--@desc: 获取储伤效果击中动画
--@author:LvBin
--@time:2023-03-13 15:58:50
--@return
function FightRole:getSaveDamageHitAnimName(hitPos)
    return switch(
        hitPos,
        {
            head = EffectConst:getConstById("sdEffectHitAnimHead"),
            chest = EffectConst:getConstById("sdEffectHitAnimChest"),
            foot = EffectConst:getConstById("sdEffectHitAnimFoot"),
            default = EffectConst:getConstById("sdEffectHitAnimChest")
        }
    )
end

--@desc: 获取储伤值最大值(目前等于角色当前气血最大值)
--@author:LvBin
--@time:2023-03-12 11:33:29
--@return
function FightRole:getSaveDamageMax()
    return self:getCurrQiMax()
end

--@desc: 获取绝境力(基础绝境力 + 储伤额外附加绝境力)
--@author:LvBin
--@time:2023-03-12 11:51:50
--@return
function FightRole:getDespairForce()
    local despairForce = self:getAttr("despairForceBase") + self:getAttr("extraDespairForce")

    despairForce = Helper:getRange(despairForce,0,self:getDespairForceMax())

    return despairForce
end

--@desc: 当储伤值发生改变，储伤附加绝境力增加值计算规则如下
--@author:LvBin
--@time:2023-03-13 17:43:25
--@addSaveDamageValue: 储伤值变化值
--@return
function FightRole:updataExtraDespairForce(addSaveDamageValue)
    if addSaveDamageValue <= 0 then
        return
    end
    
    local oldSaveDamage = self:getAttr("saveDamage")

    local newSaveDamage = Helper:getRange(oldSaveDamage + addSaveDamageValue, 0 ,self:getSaveDamageMax())

    local metrics = EffectConst:getConstById("sdTodespairMetrics")

    local addValue = math.floor(newSaveDamage/metrics) - math.floor(oldSaveDamage/metrics)

    addValue = math.floor(addValue * EffectConst:getConstById("sdTodespairAdd"))
    
    addValue = math.max(addValue,0)
    
    self:addAttr("extraDespairForce",addValue)
end

--@desc: 获取绝境力最大值
--@author:LvBin
--@time:2023-03-12 11:51:27
--@return
function FightRole:getDespairForceMax()
    return EffectConst:getConstById("despairForceMax")
end

--@desc: 是否自杀立即死亡
--@author:LvBin
--@time:2023-03-14 17:58:51
--@return
function FightRole:isSelfKill()
    for k, effect in pairs(self._effectMap) do
        if effect:getType() == "角色立即死亡" then
            return true
        end
    end

    return false
end

--@desc: 触发角色立即死亡
--@author:LvBin
--@time:2023-03-14 19:24:19
--@hitPos: 击中部位
--@return
function FightRole:triggerSelfKill(hitPos)
    for k, effect in pairs(self._effectMap) do
        if effect:getType() == "角色立即死亡" then
            local effectObject = effect:getEffectObject(self)
            effectObject:trigger(hitPos)
            break
        end
    end
end

-- 设置调试招架率
function FightRole:setDebugParryRate(parryRate)
    self.__debugParryRateBuff = parryRate
end

function FightRole:getDebugParryRate()
    return self.__debugParryRateBuff
end

function FightRole:random(num1, num2)
    return self._fight:random(num1, num2)
end

--@desc: 进入战斗添加主动技能附带战斗效果
--@author:LvBin
--@time:2023-06-15 18:15:12
--@return
function FightRole:addEnterFightEffects()
    if MapIsEmpty(self._preparedActiveZhaoMap) == false then
        if not self.__enterFightEffectActiveZhaoIds then
            self.__enterFightEffectActiveZhaoIds = {}
        end

        for zhaoId, activeZhao in pairs(self._preparedActiveZhaoMap) do
            local enterEffect = EnterEffect:create(zhaoId,self:getRole())
            if enterEffect:condition() then
                local effects = enterEffect:getEffects()
                if not MapIsEmpty(effects) then
                    for i,effect in ipairs(effects) do
                        effect:setOwner(self)
                        effect:setObject(self)
    
                        self._fight:roleAddEffect(self, self, effect)
                        self.__enterFightEffectActiveZhaoIds[zhaoId] = true
                    end
                end
            end
        end
    end
end

--@desc: 删除战斗已添加主动技能附带战斗效果
--@author:LvBin
--@time:2023-06-15 20:56:52
--@return
function FightRole:deleteEnterFightEffects()
    if not self._fight then
        return
    end

    if MapIsEmpty(self._preparedActiveZhaoMap) == false then
        if MapIsEmpty(self.__enterFightEffectActiveZhaoIds) == false then
            for zhaoId, __ in pairs(self.__enterFightEffectActiveZhaoIds) do
                local zhaoIsExist = false
                for _zhaoId, activeZhao in pairs(self._preparedActiveZhaoMap) do
                    if zhaoId == _zhaoId then
                        zhaoIsExist = true
                        break
                    end
                end
    
                if zhaoIsExist == false then
                    --主动招式不存在的直接删除附带效果
                    local enterEffect = EnterEffect:create(zhaoId,self:getRole())
                    local effects = enterEffect:getEffects()
                    if not MapIsEmpty(effects) then
                        for i,effect in ipairs(effects) do
                            local effectId = effect:getId()
                            self:removeEffect(effectId)
                            self.__enterFightEffectActiveZhaoIds[zhaoId] = nil
                        end
                    end
                else
                    --主动招式存在的判断武学条件是否满足，不满足的删除
                    local enterEffect = EnterEffect:create(zhaoId,self:getRole())
                    if enterEffect:condition() == false then
                        local effects = enterEffect:getEffects()
                        if not MapIsEmpty(effects) then
                            for i,effect in ipairs(effects) do
                                local effectId = effect:getId()
                                self:removeEffect(effectId)
                                self.__enterFightEffectActiveZhaoIds[zhaoId] = nil
                            end
                        end
                    end
                end
            end
        end
    else
        for zhaoId, __ in pairs(self.__enterFightEffectActiveZhaoIds) do
            local enterEffect = EnterEffect:create(zhaoId,self:getRole())
            local effects = enterEffect:getEffects()
            if not MapIsEmpty(effects) then
                for i,effect in ipairs(effects) do
                    local effectId = effect:getId()
                    self:removeEffect(effectId)
                    self.__enterFightEffectActiveZhaoIds[zhaoId] = nil
                end
            end
        end
    end
end

--@desc: 临时缴械(缴械时间结束时武器会回来)
--@author:LvBin
--@time:2023-07-12 17:41:17
--@return
function FightRole:reversibleDisarmWeapon()
    local disarmWeapon = self:getCurrWeapon()
    
    if disarmWeapon ~= nil then
        self:setDisarmWeapon(clone(disarmWeapon))

        local weaponSubtype = self:getRole():getCurrSubtypeByWeapon()
        
        self:setBeforeUnloadWeaponIsSubType(weaponSubtype)

        self._role:setEquipByName("weapon", nil)

        self:setCurrDoubleAttackSkill(nil)
        self:setCurrDoubleAttackZhao(nil)
        self._currZhaoState = 0
        self._currZhaoIndex = 0 -- 当前招式位置
        self._currZhaoFrame = 1 -- 当前招式帧    

        self:setAutoZhaos(self:getTargetId(), self:createAutoZhaos(self:getTarget()))

        self:reinitRole()

        self:deleteEnterFightEffects()

        self:refreshFistFootEffects()

        self:jingMaiUpdate()

        --@desc 武器打落后毒药不再生效
        if PVP_POISONSYS then
            if self._poisonEffectArray then
                for _,v in ipairs(self._poisonEffectArray) do
                    v.canUse = false
                end
            end
        end

        -- 刷新按钮区域
        if self:isForget() then
            --目标中遗忘的情况下，不用刷新恢复按钮
            self._fight:callEventListener("unloadWeapon",self,2)
        else
            self._fight:callEventListener("unloadWeapon",self,3)
        end
        
        return true
    else
        return false,"目标未持械，无法缴械"
    end
end

--@desc: 临时缴械结束
--@author:LvBin
--@time:2023-07-12 17:55:17
--@return
function FightRole:reversibleDisarmWeaponEnd()
    local disarmWeapon = self:getDisarmWeapon()

    if disarmWeapon then
        if self:weaponIsBroke(disarmWeapon.id) then
            return false,"武器损坏，无法取回"
        end

        if self:weaponIsThrow(disarmWeapon.id) then
            return false,"武器被投掷，无法取回"
        end

        local currWeapon = self:getCurrWeapon()

        if currWeapon and currWeapon.id == disarmWeapon.id then
            return false,"已是当前武器，无需取回"
        end

        self._role:setEquipByName("weapon", disarmWeapon)

        self:setCurrDoubleAttackSkill(nil)
        self:setCurrDoubleAttackZhao(nil)
        self._currZhaoState = 0
        self._currZhaoIndex = 0 -- 当前招式位置
        self._currZhaoFrame = 1 -- 当前招式帧 

        self:setAutoZhaos(self:getTargetId(), self:createAutoZhaos(self:getTarget()))
        
        self:reinitRole()
    
        self:deleteEnterFightEffects()

        self:refreshFistFootEffects()

        self:jingMaiUpdate()

        -- 刷新按钮区域
        if self:isForget() then
            self._fight:callEventListener("unloadWeapon",self,2)
        else
            self._fight:callEventListener("unloadWeapon",self,3)
        end

        return true
    end

    return false,""
end


--@desc: 记录被缴械武器
--@author:LvBin
--@time:2023-07-12 16:17:20
--@weapon: 
--@return
function FightRole:setDisarmWeapon(weapon)
    self.__disarmWeapon = weapon
end

function FightRole:getDisarmWeapon()
    return self.__disarmWeapon
end

--@desc: 添加被投掷武器id
--@author:LvBin
--@time:2023-07-14 14:42:37
--@weaponId: 武器唯一id
--@return
function FightRole:addThrowWeapon(weaponId)
    if self.__throwWeapons == nil then
        self.__throwWeapons = {}
    end

    self.__throwWeapons[tostring(weaponId)] = true
end

--@desc: 武器是否被投掷
--@author:LvBin
--@time:2023-07-14 14:51:37
--@weaponId: 
--@return
function FightRole:weaponIsThrow(weaponId)
    if self.__throwWeapons[tostring(weaponId)] == true then
        return true
    end

    return false
end

--@desc: 记录被打断武器
--@author:LvBin
--@time:2023-07-20 17:05:18
--@weaponData: 
--@return
function FightRole:addBrokeWeaponInfo(id,itemId)
    if not self._role.brokeWeaponInfo then
        self._role.brokeWeaponInfo = {}
    end

    local info = {
        id = id,
        itemId = itemId
    }

    table.insert(self._role.brokeWeaponInfo, info)
end

--@desc: 武器是否被打断
--@author:LvBin
--@time:2023-07-20 17:08:20
--@weaponId: 
--@return
function FightRole:weaponIsBroke(weaponId)
    if MapIsEmpty(self._role.brokeWeaponInfo) then
        return false
    end

    for i,v in ipairs(self._role.brokeWeaponInfo) do
        if weaponId == v.id then
            return true
        end
    end

    return false
end

--@desc: 是否持械
--@author:LvBin
--@time:2023-08-31 16:19:53
--@return
function FightRole:isArmed()
    if self:getCurrWeapon() ~= nil then
        return true
    end

    return false
end

--添加主动效果属性加成
function FightRole:addAttrEffectBuffAddValue(attrName, value)
    if self._attrEffectBuffAddValue[attrName] then
        self._attrEffectBuffAddValue[attrName] = self._attrEffectBuffAddValue[attrName] + value
        LogSystem:log("旧版战斗：","当前角色：",self:getName(),"  |当前属性：",attrName, "  |当前加成：",value, "  |累计加成：",self._attrEffectBuffAddValue[attrName])
    end
end

--获取主动效果对当前属性加成
function FightRole:getAttrEffectBuffAddValue(attrName)
    if self._attrEffectBuffAddValue[attrName] then
        return self._attrEffectBuffAddValue[attrName]
    else
        local attrName = string.gsub(attrName,"_","")
        if self._attrEffectBuffAddValue[attrName] then
            return self._attrEffectBuffAddValue[attrName]
        end
    end

    return 0
end

--记录承受伤害
function FightRole:addRecordDamage(value)
    if self:isRecordDamage() then
        self._recordDamage = self._recordDamage + math.abs(value)
    end
end

function FightRole:getRecordDamage()
    return self._recordDamage
end

function FightRole:getEffectMarkValue(markId)
    local markValue = 0
    
    local EffectMap = self:getEffectMap()
    
    for k,effect in pairs(EffectMap) do
        if effect:getType() == "属性叠加" and effect:getArg1() == markId then
            markValue = markValue + effect:getArg2()
        end
    end

    return markValue
end

function FightRole:isSpecialActiveZhaoAnim()
    return FightConfig:isSpecialActiveZhaoAnim(self)
end

--@desc: 被动主动气血伤害防御系数刷新生命周期
--@author:LvBin
--@time:2024-04-07 16:25:45
--@attr: 属性id
--@return
function FightRole:updateAttrFactorCount(attr)
    for __,effect in ipairs(self:getEffectMap()) do
        if effect:getType() == "属性增益" and effect:getArg1() == attr then
            local count = tonumber(effect:getFinalArg3())

            count = count - 1

            if count <= 0 then
                self._fight:callEventListener("endEffect", self, effect)
                self._fight:roleRemoveEffect(self, effect:getId())
            else
                effect:setArg3(count)
            end
        end
    end
end

--@desc: 触发主动技能效果
--@author:LvBin
--@time:2024-04-09 16:53:56
--@return
function FightRole:triggerActiveZhaoEffect(buffType, role, target)
    if buffType ~= "使用主动技能" then
        return
    end

    for k, effect in pairs(self._effectMap) do
        if effect:getType() == buffType then
            local triggerId = effect:getArg1()
            local triggerOwner = effect:getArg2() == "自己" and role or target
            local triggerObject = effect:getArg3() == "自己" and role or target
            local triggerEffect = Skill:getSkillEffect(triggerId):clone()
            triggerEffect:setZArgs(effect:getZArgs())
            triggerEffect:setOwner(triggerOwner)
            triggerEffect:setObject(triggerObject)
            triggerEffect:setTarget(effect:getArg3())
            if self._fight:canAddEffect(triggerObject, triggerEffect) then
                local immediateEffectUIInfo = self._fight:roleAddEffect(triggerOwner, triggerObject, triggerEffect)
                local duration = triggerEffect:getFinalDuration()
                if duration == 0 then
                    self._fight:callEventListener(
                        "addRolesEffectChangeFunction",
                        function()
                            self._fight:callEventListener("doEffect", triggerObject, triggerEffect, immediateEffectUIInfo)
                            return true
                        end
                    )
                else
                    self._fight:callEventListener("beginEffect", triggerObject, triggerEffect, immediateEffectUIInfo)
                end
            end
        end
    end
end

--@desc: 获取经脉效果加成比例
--@author:LvBin
--@time:2024-12-25 16:33:37
--@meridianId: 经脉id
--@return
function FightRole:getMeridianEffectRatio(meridianId)
    local addRatio = 0

    for k, effect in pairs(self._effectMap) do
        if effect:getType() == "经脉天赋修正" and string.find(effect:getArg1(), meridianId) then
           addRatio = addRatio + tonumber(effect:getFinalArg2())
        end
    end

    local meridianBuffValue = Meridian:getMeridianBuffValue(meridianId)

    local minValue = EffectConst:getConstById("effectImprintingMin")
    
    local maxValue = EffectConst:getConstById("effectImprintingMax")

    local ratio = meridianBuffValue * Helper:getRange(1 + addRatio, minValue, maxValue)

    return ratio
end

function FightRole:getMeridianSystem()
    return self._role:getMeridianSystem()
end

--@desc: 是否播放过胜利动画
--@author:LvBin
--@time:2025-03-21 14:34:55
--@return
function FightRole:isPlayWinAnim()
    return self._isPlayWinAnim
end

--@desc: 设置播放胜利动画状态
--@author:LvBin
--@time:2025-03-21 14:34:55
--@return
function FightRole:setPlayWinAnim(bool)
    self._isPlayWinAnim = bool
end

--@desc: 主动效果对应伤害属性系数变化
--@author:LvBin
--@time:2025-04-14 16:47:34
--@damageAttrTypeId: 伤害属性类型id
--@damageAttrTypeStr: atkDamageClass=攻击属性 or defDamageClass=防御属性
--@return
function FightRole:addActiveDamageFactorValue(damageAttrTypeId,damageAttrTypeStr,value)
    damageAttrTypeId = tostring(damageAttrTypeId)

    if self.__activeDamageFactorMap[damageAttrTypeId] == nil then
        self.__activeDamageFactorMap[damageAttrTypeId] = {}
    end

    if self.__activeDamageFactorMap[damageAttrTypeId][damageAttrTypeStr] == nil then
        self.__activeDamageFactorMap[damageAttrTypeId][damageAttrTypeStr] = value
    else
        self.__activeDamageFactorMap[damageAttrTypeId][damageAttrTypeStr] = self.__activeDamageFactorMap[damageAttrTypeId][damageAttrTypeStr] + value
    end
end

--@desc: 获取主动效果对应伤害属性系数
--@author:LvBin
--@time:2025-04-14 16:47:34
--@damageAttrTypeId: 伤害属性类型id
--@damageAttrTypeStr: atkDamageClass=攻击属性 or defDamageClass=防御属性
--@return
function FightRole:getActiveDamageFactorValue(damageAttrTypeId,damageAttrTypeStr)
    damageAttrTypeId = tostring(damageAttrTypeId)

    local value = 0

    if self.__activeDamageFactorMap[damageAttrTypeId] then
		if self.__activeDamageFactorMap[damageAttrTypeId][damageAttrTypeStr] then
			value = self.__activeDamageFactorMap[damageAttrTypeId][damageAttrTypeStr]
		end
	end

    return value
end

--@desc: 添加隐脉系统玄络buff触发的主动效果
--@author:LvBin
--@time:2025-06-19 16:40:16
--@return
function FightRole:addHiddenMeridianSysActiveEffects()
    local effects = self:getRole():getHiddenMeridianSysActiveEffects()
    if not MapIsEmpty(effects) then
        for i,effect in ipairs(effects) do
            effect:setOwner(self)
            effect:setObject(self)

            self._fight:roleAddEffect(self, self, effect)
        end
    end
end

--@desc: 获取修武效果属性加成值
--@author:LvBin
--@time:2025-09-08 15:59:33
--@attrId: 属性id
--@return
function FightRole:getXiuWuAddValue(attrId)
	local addValue = 0

	local effectMap = self:getEffectMap()

	for i, effect in ipairs(effectMap) do
		if effect:getType() == "修武" and effect:getArg1() == attrId then
			local arg2 = effect:getFinalArg2()
			addValue = addValue + arg2
		end
	end

	LogSystem:log("旧版战斗：","修武效果属性加成值: ",self:getName(),"  |当前属性：",attrId, "  |加成值：",addValue)

	return addValue
end

--@desc: 获取战斗角色武器伤害力
--@author:LvBin
--@time:2025-09-08 16:39:14
--@return
function FightRole:getWeaponDamage()
	local roleWeapon = self:getCurrWeapon()

	if roleWeapon == nil then
		return 0
	end

	local weapon = self:getRole():getOneItemByKey(roleWeapon.itemId)

	if weapon == nil then
		return 0
	end 

	local wpAtk = weapon:getWeaponDamage(self:getRole(),false)
	
	if SHENBINGSYS == true and weapon.wpType == "神兵" then
		local weaponWanhaodu = weapon.wanhaodu
		if 100 < weaponWanhaodu and weaponWanhaodu <= 120 then
			wpAtk = wpAtk * self:random(10,11)*0.1
		elseif weaponWanhaodu == 100 then
		elseif 80 < weaponWanhaodu and weaponWanhaodu < 100 then
			wpAtk = wpAtk * self:random(8,10)*0.1
		elseif 60 < weaponWanhaodu and weaponWanhaodu <= 80 then
			wpAtk = wpAtk * self:random(6,8)*0.1
		elseif 40 <= weaponWanhaodu and weaponWanhaodu <= 60 then
			wpAtk = wpAtk * self:random(4,6)*0.1
		elseif  weaponWanhaodu < 40 then
			wpAtk = wpAtk * self:random(1,3)*0.1
		end
	end

	local xiuWuAddValue = self:getXiuWuAddValue("weaponDamage")

	wpAtk = math.max(0,wpAtk + xiuWuAddValue)

	return wpAtk
end

--@desc: 获取战斗角色武器硬度
--@author:LvBin
--@time:2025-09-08 17:10:14
--@return
function FightRole:getWeaponYingDu()
	local roleWeapon = self:getCurrWeapon()

	if roleWeapon == nil then
		return 0
	end

	local weapon = self:getRole():getOneItemByKey(roleWeapon.itemId)

	if weapon == nil then
		return 0
	end 

	local yindu = weapon:getWeaponYingDu(self:getRole(),false)

	local xiuWuAddValue = self:getXiuWuAddValue("weaponYindu")

	yindu = math.max(0,yindu + xiuWuAddValue)

	return yindu
end

--@desc: 获取战斗角色武器坚韧度
--@author:LvBin
--@time:2025-09-08 17:10:14
--@return
function FightRole:getWeaponRenDu()
	local roleWeapon = self:getCurrWeapon()

	if roleWeapon == nil then
		return 0
	end

	local weapon = self:getRole():getOneItemByKey(roleWeapon.itemId)

	if weapon == nil then
		return 0
	end 

	local rendu = weapon:getWeaponRenDu(self:getRole(),false)

	local xiuWuAddValue = self:getXiuWuAddValue("weaponRendu")

	rendu = math.max(0,rendu + xiuWuAddValue)

	return rendu
end

--@desc: 获取战斗角色武器重量
--@author:LvBin
--@time:2025-09-08 17:10:14
--@return
function FightRole:getWeaponWeight()
	local roleWeapon = self:getCurrWeapon()

	if roleWeapon == nil then
		return 0
	end

	local weapon = self:getRole():getOneItemByKey(roleWeapon.itemId)

	if weapon == nil then
		return 0
	end 

	local weight = weapon:getWeaponWeight(self:getRole(),false)

	local xiuWuAddValue = self:getXiuWuAddValue("weaponWeight")

	weight = math.max(0,weight + xiuWuAddValue)

	return weight
end

--@desc: 获取修武效果兵器状态
--@author:LvBin
--@time:2025-09-09 11:35:04
--@attrId: 属性id
--@return false不能击飞/打断   true能击飞/打断
function FightRole:getXiuWuWeaponStatusByAttrId(attrId)
	local effectMap = self:getEffectMap()

	for i, effect in ipairs(effectMap) do
		if effect:getType() == "修武" and effect:getArg1() == attrId then
			local arg2 = effect:getFinalArg2()
			if arg2 == 0 then
				return false
			end
		end
	end

	return true
end

--@desc: 能否击飞武器
--@author:LvBin
--@time:2025-09-09 15:58:10
--@return
function FightRole:canFlyWeapon()
	local roleWeapon = self:getCurrWeapon()

	if roleWeapon == nil then
		return false
	end

	local weapon = self:getRole():getOneItemByKey(roleWeapon.itemId)

	return weapon:canFlyWeapon() and self:getXiuWuWeaponStatusByAttrId("flyWeapon")
end

--@desc: 能否被击飞武器
--@author:LvBin
--@time:2025-09-09 15:58:10
--@return
function FightRole:canBeFlyWeapon()
	local roleWeapon = self:getCurrWeapon()

	if roleWeapon == nil then
		return false
	end

	local weapon = self:getRole():getOneItemByKey(roleWeapon.itemId)

	return weapon:canBeFlyWeapon() and self:getXiuWuWeaponStatusByAttrId("beflyWeapon")
end

--@desc: 能否打断武器
--@author:LvBin
--@time:2025-09-09 15:58:36
--@return
function FightRole:canBreakWeapon()
	local roleWeapon = self:getCurrWeapon()

	if roleWeapon == nil then
		return false
	end

	local weapon = self:getRole():getOneItemByKey(roleWeapon.itemId)

	return weapon:canBreakWeapon() and self:getXiuWuWeaponStatusByAttrId("breakWeapon")
end

--@desc: 能否被打断武器
--@author:LvBin
--@time:2025-09-09 16:01:04
--@return
function FightRole:canBrokenWeapon()
	local roleWeapon = self:getCurrWeapon()

	if roleWeapon == nil then
		return false
	end

	local weapon = self:getRole():getOneItemByKey(roleWeapon.itemId)

	return weapon:canBrokenWeapon() and self:getXiuWuWeaponStatusByAttrId("brokenWeapon")
end

--@desc: 判断角色效果条件是否满足或不满足
--@author:LvBin
--@time:2025-09-10 15:41:56
--@conArray: 条件数组
--@isMet: 是否判断满足，true表示判断满足，false表示判断不满足
--@return: 布尔值，符合条件返回true，否则返回false
function FightRole:checkRoleEffectCondition(conArray,isMet)
    if MapIsEmpty(conArray) then
		return true
	end

	for i, conStr in ipairs(conArray) do
		if isMet then
			if self:getEffect(conStr) or self:checkHaveEffectType(conStr) or self:checkCorrelationStateBuff(conStr) then
				return true
			end
		else
			if type(tonumber(conStr)) == "number" then
				if not self:checkHaveEffectType(conStr) then
					return true
				end
			else
				if not self:getEffect(conStr)then
					return true
				end
			end
		end
    end

    return false
end

--@desc: 判断角色效果触发（支持指定判断符号）
--@author:LvBin
--@time:2026-01-27 15:37:51
--@conStr: 条件字符串 例如：`id#HPC11 or class#1 or id#HPMPSTS or wq#CHIXIE`
--@predicateSymbol: 判断符号（true/false），校验结果需等于该值才视为满足
--@return: boolean 条件是否满足指定判断符号
function FightRole:checkRoleSkillEffectTrigger(conStr, predicateSymbol)
    -- 基础校验：空值/非法判断符号直接返回false
    if not conStr or conStr == "" or type(predicateSymbol) ~= "boolean" then
        return false
    end

    -- 单个条件校验函数：拆分条件+调用对应方法+对比判断符号
    local function checkSingleCond(condStr)
        -- 正则拆分#，兼容条件类型/值前后的空格（如 "id # HPC11"）
        local condType, condVal = string.match(condStr, "^%s*([^#]+)%s*#%s*([^#]+)%s*$")
        if not condType or not condVal then return false end

        -- 条件类型 -> 校验方法 映射表（新增类型只需在此添加）
        local condMap = {
            id = self.getEffect,
            class = self.checkHaveEffectType,
            wq = self.checkCorrelationStateBuff
        }
        -- 调用对应方法，获取原始返回值（可能是对象/布尔值/nil）
        local checkFunc = condMap[condType]
		local rawRes = checkFunc and checkFunc(self, condVal) or nil

		local boolRes = not not rawRes -- 双重not将任意值转为布尔值（Lua特性）

		LogSystem:log("旧版战斗：效果判断触发  条件:",condStr,"结果:", boolRes,"对比结果:", boolRes == predicateSymbol)
        
		-- 核心：对比转换后的布尔值和指定的判断符号
        return boolRes == predicateSymbol
    end

    -- 处理OR逻辑：只要有一个条件满足，立即返回true
    if string.find(conStr, " or ") then
        for _, cond in ipairs(string.split(conStr, " or ")) do
            -- 过滤拆分后可能的空字符串（如条件字符串末尾是"or "）
            if cond ~= "" and checkSingleCond(cond) then
                return true
            end
        end
        return false
    end

    -- 处理AND逻辑：只要有一个条件不满足，立即返回false
    if string.find(conStr, " and ") then
        for _, cond in ipairs(string.split(conStr, " and ")) do
            if cond ~= "" and not checkSingleCond(cond) then
                return false
            end
        end
        return true
    end

    -- 单个条件直接校验
    return checkSingleCond(conStr)
end

--@desc: 添加部分遗忘武学
--@author:LvBin
--@time:2026-04-24 16:22:33
--@skillId: 
--@return
function FightRole:addPartForgetSkill(skillId)
	if not skillId then
		return
	end
	self.__partForgetSkills[skillId] = true
end

--@desc: 清空部分遗忘武学
--@author:LvBin
--@time:2026-04-24 16:23:06
--@return
function FightRole:cleanPartForgetSkills()
	self.__partForgetSkills = {}
end


--@desc: 判断主动招式所属武学是否被部分遗忘
--@author:LvBin
--@time:2026-04-21 17:46:44
--@skillId: 
--@return
function FightRole:isPartForgetSkill(skillId)
	return self.__partForgetSkills[skillId] == true
end

--@desc: 部分遗忘状态下能否释放指定主动技能
--@author:LvBin
--@time:2026-04-21 19:22:24
--@activeZhaoId: 
--@return
function FightRole:isPartForgetCanUseActiveZhao(activeZhaoId)
	if activeZhaoId == "huifu" then
		return true
	end

	local skillId = Skill:getSkillIdByZhaoId(activeZhaoId)

	if not skillId then
		return true
	end
	
	if self:isPartForget() and self:isPartForgetSkill(skillId) and not self:getRole():checkSkillIsPrepared(skillId) then
		return false
	end
	
	return true
end

return FightRole000000000000000