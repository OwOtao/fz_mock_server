local FightRoleJingMai = {}
local LogSystem = require("app.models.LogSystem.LogSystem")

function FightRoleJingMai:create()
    local p = clone(FightRoleJingMai)
    p:ctor()
    return p
end

function FightRoleJingMai:ctor()
    self._jingMaiYinJiMap = {}-- 玩家拥有的经脉印记

    self._triggerJingMaiYinJiMap = {}-- 触发型经脉印记
    self._stateJingMaiYinJiMap = {}-- 状态类型经脉印记
    self._stateMachineMap = {}-- 状态机
    self._attr = {}-- 属性加成
end

function FightRoleJingMai:init(role)
    self:initJingMaiYinJi(role)

    self:initStateJingMaiYinJi(role)
    self:initTriggerJingMaiYinJi(role)

    self._belongName = role:getName()
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/05/05 17:17:31
-- @desc 初始化经脉印记
function FightRoleJingMai:initJingMaiYinJi(role)
    for i, v in ipairs(Helper:getDef(role:getMeridianSystem():getCurrentPageMeridianImprintings(), {})) do
        if v:getImprintingId() then
            self._jingMaiYinJiMap[v:getImprintingId()] = v
        end
    end


    print("角色", role:getName(), "拥有经脉:")
    for k, v in pairs(self._jingMaiYinJiMap) do
        print("k = ", k)
        print(v:getName())
    end
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/05/05 17:20:37
-- @desc 判断是否存在经脉印记
function FightRoleJingMai:getJingMaiYinJi(id)
    return self._jingMaiYinJiMap[id]
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/05/04 22:37:47
-- @desc 初始化状态型经脉印记
function FightRoleJingMai:initStateJingMaiYinJi(role)
    local fight = role._fight
    local target = fight:getRole(role:getTargetId())
    local Meridian = require("app.models.Meridian.Meridian")
    local stateJingMaiYinJiMap =
        {
            dongxuanyin = {name = "百剑不侵", vname = "RAN百\n剑\n不\n侵NOR", activeDesc = "真气在$N的体内快速运转，随着一阵灼热传来，激活了YEL百剑不侵NOR！防御提升！",
                activeCond = function()
                    local target = role._fight:getRole(role._targetId)
                    if target:getCurrWeaponType() == "剑" then
                        return true
                    end
                    return false
                end,
                attrBuff =
                {
                    attrName = "defRateFactor",
                    getAttr = function()
                        if DEBUG_MODE == 1 then
                            return role:getAttr("defRateFactor") * 100 / 100
                        end
                        local meridianBuffValue = Meridian:getMeridianBuffValue("dongxuanyin")
                        return role:getAttr("defRateFactor") * meridianBuffValue
                    end
                }
            },
            dongzhenyin = {name = "刀术克制", vname = "RAN刀\n术\n克\n制NOR", activeDesc = "真气在$N的体内快速运转，随着一阵灼热传来，激活了YEL刀术克制NOR！防御提升！",
                activeCond = function()
                    local target = role._fight:getRole(role._targetId)
                    if target:getCurrWeaponType() == "刀" then
                        return true
                    end
                    return false
                end,
                attrBuff =
                {
                    attrName = "defRateFactor",
                    getAttr = function()
                        if DEBUG_MODE == 1 then
                            return role:getAttr("defRateFactor") * 100 / 100
                        end
                        local meridianBuffValue = Meridian:getMeridianBuffValue("dongzhenyin")
                        return role:getAttr("defRateFactor") * meridianBuffValue
                    end
                }},
            dongyuanyin = {name = "枪棒克制", vname = "RAN枪\n棒\n克\n制NOR", activeDesc = "真气在$N的体内快速运转，随着一阵灼热传来，激活了YEL枪棒克制NOR！防御提升！",
                activeCond = function()
                    local target = role._fight:getRole(role._targetId)
                    if target:getCurrWeaponType() == "棍" then
                        return true
                    end
                    return false
                end,
                attrBuff =
                {
                    attrName = "defRateFactor",
                    getAttr = function()
                        if DEBUG_MODE == 1 then
                            return role:getAttr("defRateFactor") * 100 / 100
                        end
                        local meridianBuffValue = Meridian:getMeridianBuffValue("dongyuanyin")
                        return role:getAttr("defRateFactor") * meridianBuffValue
                    end
                }},
            dongkongyin = {name = "鞭长莫及", vname = "RAN鞭\n长\n莫\n及NOR", activeDesc = "真气在$N的体内快速运转，随着一阵灼热传来，激活了YEL鞭长莫及NOR！防御提升！",
                activeCond = function()
                    local target = role._fight:getRole(role._targetId)
                    if target:getCurrWeaponType() == "鞭" then
                        return true
                    end
                    return false
                end,
                attrBuff =
                {
                    attrName = "defRateFactor",
                    getAttr = function()
                        if DEBUG_MODE == 1 then
                            return role:getAttr("defRateFactor") * 100 / 100
                        end
                        local meridianBuffValue = Meridian:getMeridianBuffValue("dongkongyin")
                        return role:getAttr("defRateFactor") * meridianBuffValue
                    end
                }},
            dongtiyin = {name = "以静制动", vname = "RAN以\n静\n制\n动NOR", activeDesc = "真气在$N的体内快速运转，随着一阵灼热传来，激活了YEL以静制动NOR！防御提升！",
                activeCond = function()
                    local target = role._fight:getRole(role._targetId)
                    if target:getCurrWeaponType() == "暗器" then
                        return true
                    end
                    return false
                end,
                attrBuff =
                {
                    attrName = "defRateFactor",
                    getAttr = function()
                        if DEBUG_MODE == 1 then
                            return role:getAttr("defRateFactor") * 100 / 100
                        end
                        local meridianBuffValue = Meridian:getMeridianBuffValue("dongtiyin")
                        return role:getAttr("defRateFactor") * meridianBuffValue
                    end
                }},
            dongyiyin = {name = "拳掌克制", vname = "RAN拳\n掌\n克\n制NOR", activeDesc = "真气在$N的体内快速运转，随着一阵灼热传来，激活了YEL拳掌克制NOR！防御提升！",
                activeCond = function()
                    local target = role._fight:getRole(role._targetId)
                    if target:getCurrWeaponType() == "拳脚" then
                        return true
                    end
                    return false
                end,
                attrBuff =
                {
                    attrName = "defRateFactor",
                    getAttr = function()
                        if DEBUG_MODE == 1 then
                            return role:getAttr("defRateFactor") * 100 / 100
                        end
                        local meridianBuffValue = Meridian:getMeridianBuffValue("dongyiyin")
                        return role:getAttr("defRateFactor") * meridianBuffValue
                    end
                }},
            shuangfangyin = {name = "双持克制", vname = "RAN双\n持\n克\n制NOR", activeDesc = "真气在$N的体内快速运转，随着一阵灼热传来，激活了YEL双持克制NOR！防御提升！",
                activeCond = function()
                    local target = role._fight:getRole(role._targetId)
                    if target:getCurrWeaponType() == "双持" then
                        return true
                    end
                    return false
                end,
                attrBuff =
                {
                    attrName = "defRateFactor",
                    getAttr = function()
                        if DEBUG_MODE == 1 then
                            return role:getAttr("defRateFactor") * 100 / 100
                        end
                        local meridianBuffValue = Meridian:getMeridianBuffValue("shuangfangyin")
                        return role:getAttr("defRateFactor") * meridianBuffValue
                    end
                }},
            qinfangyin = {name = "玄韵在御", vname = "RAN玄\n韵\n在\n御NOR", activeDesc = "真气在$N的体内快速运转，随着一阵灼热传来，激活了YEL玄韵在御NOR！防御提升！",
                activeCond = function()
                    local target = role._fight:getRole(role._targetId)
                    if target:getCurrWeaponType() == "乐器" then
                        return true
                    end
                    return false
                end,
                attrBuff =
                {
                    attrName = "defRateFactor",
                    getAttr = function()
                        if DEBUG_MODE == 1 then
                            return role:getAttr("defRateFactor") * 100 / 100
                        end
                        local meridianBuffValue = Meridian:getMeridianBuffValue("qinfangyin")
                        return role:getAttr("defRateFactor") * meridianBuffValue
                    end
                }},
            linggangyin = {name = "怒气翻涌", vname = "RAN怒\n气\n翻\n涌NOR", activeDesc = "真气在$N的体内快速运转，随着一阵灼热传来，激活了CYN怒气翻涌NOR！内力消耗降低！",
                activeCond = function()
                    local qiPercent = role:getAttr("qi") / role:getFinalAttr("qiMax")
                    if qiPercent <= 0.3 then
                        return true
                    end
                    return false
                end,
                attrBuff =
                {
                    attrName = "neiliConsumeFactor",
                    getAttr = function()
                        local meridianBuffValue = Meridian:getMeridianBuffValue("linggangyin")
                        return -role:getAttr("neiliConsumeFactor") * meridianBuffValue
                    end
                }},
            yungangyin = {name = "绝处逢生", vname = "RAN绝\n处\n逢\n生NOR", activeDesc = "真气在$N的体内快速运转，随着一阵灼热传来，激活了CYN绝处逢生NOR！闪躲力提升！",
                activeCond = function()
                    local qiPercent = role:getAttr("qi") / role:getFinalAttr("qiMax")
                    if qiPercent <= 0.3 then
                        return true
                    end
                    return false
                end,
                attrBuff =
                {
                    attrName = "dodgeRateFactor",
                    getAttr = function()
                        if DEBUG_MODE == 1 then
                            return role:getAttr("dodgeRateFactor") * 200 / 100
                        end
                        local meridianBuffValue = Meridian:getMeridianBuffValue("yungangyin")
                        return role:getAttr("dodgeRateFactor") * meridianBuffValue
                    end
                }},
            fenggangyin = {name = "见招拆招", vname = "RAN见\n招\n拆\n招NOR", activeDesc = "真气在$N的体内快速运转，随着一阵灼热传来，激活了CYN见招拆招NOR！招架提升！",
                activeCond = function()
                    local qiPercent = role:getAttr("qi") / role:getFinalAttr("qiMax")
                    if qiPercent <= 0.3 then
                        return true
                    end
                    return false
                end,
                attrBuff =
                {
                    attrName = "parryRateFactor",
                    getAttr = function()
                        if DEBUG_MODE == 1 then
                            return role:getAttr("parryRateFactor") * 200 / 100
                        end
                        local meridianBuffValue = Meridian:getMeridianBuffValue("fenggangyin")
                        return role:getAttr("parryRateFactor") * meridianBuffValue
                    end
                }},
            digangyin = {name = "不动如山", vname = "RAN不\n动\n如\n山NOR", activeDesc = "真气在$N的体内快速运转，随着一阵灼热传来，激活了CYN不动如山NOR！防御提升！",
                activeCond = function()
                    local qiPercent = role:getAttr("qi") / role:getFinalAttr("qiMax")
                    if qiPercent <= 0.3 then
                        return true
                    end
                    return false
                end,
                attrBuff =
                {
                    attrName = "defRateFactor",
                    getAttr = function()
                        if DEBUG_MODE == 1 then
                            return role:getAttr("defRateFactor") * 200 / 100
                        end
                        local meridianBuffValue = Meridian:getMeridianBuffValue("digangyin")
                        return role:getAttr("defRateFactor") * meridianBuffValue
                    end
                }},
            tiangangyin = {name = "背水一战", vname = "RAN背\n水\n一\n战NOR", activeDesc = "真气在$N的体内快速运转，随着一阵灼热传来，激活了CYN背水一战NOR！攻击提升！",
                activeCond = function()
                    local qiPercent = role:getAttr("qi") / role:getFinalAttr("qiMax")
                    if qiPercent <= 0.3 then
                        return true
                    end
                    return false
                end,
                -- attrBuff =
                -- {
                --     attrName = "defRateFactor",
                --     getAttr = function()
                --         return role:getAttr("defRateFactor") * 20 / 100
                --     end
                -- }},
                attrBuff =
                {
                    attrName = "qiAtkFactor",
                    getAttr = function()
                        if DEBUG_MODE == 1 then
                            return role:getAttr("qiAtkFactor") * 200 / 100
                        end
                        local meridianBuffValue = Meridian:getMeridianBuffValue("tiangangyin")
                        return role:getAttr("qiAtkFactor") * meridianBuffValue
                    end
                }},

            zhengtiyin = {name = "嫉恶如仇", vname = "RAN嫉\n恶\n如\n仇NOR", activeDesc = "真气在$N的体内快速运转，随着一阵灼热传来，激活了HIW嫉恶如仇NOR！命中提升！",
                activeCond = function()
                    local target = role._fight:getRole(role._targetId)
                    if role:getFinalAttr("zhengqi") > target:getFinalAttr("zhengqi") then
                        return true
                    end
                    return false
                end,
                attrBuff =
                {
                    attrName = "hitRateFactor",
                    getAttr = function()
                        if DEBUG_MODE == 1 then
                            return role:getAttr("hitRateFactor") * 200 / 100
                        end
                        local meridianBuffValue = Meridian:getMeridianBuffValue("zhengtiyin")
                        return role:getAttr("hitRateFactor") * meridianBuffValue
                    end
                }},
            zhengxingyin = {name = "邪魔不侵", vname = "RAN邪\n魔\n不\n侵NOR", activeDesc = "真气在$N的体内快速运转，随着一阵灼热传来，激活了HIW邪魔不侵NOR！格挡提升！",
                activeCond = function()
                    local target = role._fight:getRole(role._targetId)
                    if role:getFinalAttr("zhengqi") > target:getFinalAttr("zhengqi") then
                        return true
                    end
                    return false
                end,
                attrBuff =
                {
                    attrName = "parryRateFactor",
                    getAttr = function()
                        if DEBUG_MODE == 1 then
                            return role:getAttr("parryRateFactor") * 200 / 100
                        end
                        local meridianBuffValue = Meridian:getMeridianBuffValue("zhengxingyin")
                        return role:getAttr("parryRateFactor") * meridianBuffValue
                    end
                }},
            zhengmingyin = {name = "邪不近身", vname = "RAN邪\n不\n近\n身NOR", activeDesc = "真气在$N的体内快速运转，随着一阵灼热传来，激活了HIW邪不近身NOR！闪躲提升！",
                activeCond = function()
                    local target = role._fight:getRole(role._targetId)
                    if role:getFinalAttr("zhengqi") > target:getFinalAttr("zhengqi") then
                        return true
                    end
                    return false
                end,
                attrBuff =
                {
                    attrName = "dodgeRateFactor",
                    getAttr = function()
                        if DEBUG_MODE == 1 then
                            return role:getAttr("dodgeRateFactor") * 200 / 100
                        end
                        local meridianBuffValue = Meridian:getMeridianBuffValue("zhengmingyin")
                        return role:getAttr("dodgeRateFactor") * meridianBuffValue
                    end
                }},
            dangxieyin = {name = "邪气凛然", vname = "RAN邪\n气\n凛\n然NOR", activeDesc = "真气在$N的体内快速运转，随着一阵灼热传来，激活了HIW邪气凛然NOR！命中提升！",
                activeCond = function()
                    local target = role._fight:getRole(role._targetId)
                    if role:getFinalAttr("zhengqi") < target:getFinalAttr("zhengqi") then
                        return true
                    end
                    return false
                end,
                attrBuff =
                {
                    attrName = "hitRateFactor",
                    getAttr = function()
                        if DEBUG_MODE == 1 then
                            return role:getAttr("hitRateFactor") * 200 / 100
                        end
                        print([[role:getAttr("hitRateFactor") = ]], role:getAttr("hitRateFactor"))
                        local meridianBuffValue = Meridian:getMeridianBuffValue("dangxieyin")
                        return role:getAttr("hitRateFactor") * meridianBuffValue
                    end
                }},
            ganxieyin = {name = "正不压邪", vname = "RAN正\n不\n压\n邪NOR", activeDesc = "真气在$N的体内快速运转，随着一阵灼热传来，激活了HIW正不压邪NOR！格挡提升！",
                activeCond = function()
                    local target = role._fight:getRole(role._targetId)
                    if role:getFinalAttr("zhengqi") < target:getFinalAttr("zhengqi") then
                        return true
                    end
                    return false
                end,
                attrBuff =
                {
                    attrName = "parryRateFactor",
                    getAttr = function()
                        if DEBUG_MODE == 1 then
                            return role:getAttr("parryRateFactor") * 200 / 100
                        end
                        local meridianBuffValue = Meridian:getMeridianBuffValue("ganxieyin")
                        return role:getAttr("parryRateFactor") * meridianBuffValue
                    end
                }},
            dengxieyin = {name = "魔高一丈", vname = "RAN魔\n高\n一\n丈NOR", activeDesc = "真气在$N的体内快速运转，随着一阵灼热传来，激活了HIW魔高一丈NOR！闪躲提升！",
                activeCond = function()
                    local target = role._fight:getRole(role._targetId)
                    if role:getFinalAttr("zhengqi") < target:getFinalAttr("zhengqi") then
                        return true
                    end
                    return false
                end,
                attrBuff =
                {
                    attrName = "dodgeRateFactor",
                    getAttr = function()
                        if DEBUG_MODE == 1 then
                            return role:getAttr("dodgeRateFactor") * 200 / 100
                        end
                        local meridianBuffValue = Meridian:getMeridianBuffValue("dengxieyin")
                        return role:getAttr("dodgeRateFactor") * meridianBuffValue
                    end
                }},


            -- 左右互搏印 add by TangJian 2017/05/08 11:16:57
            zuoyouhuboyin = {name = "互搏神通", vname = "RAN互\n搏\n神\n通NOR",activeDesc = "真气在$N的体内快速运转，随着一阵灼热传来，激活了HIW互搏神通NOR！拳脚武功伤害提升！",
                activeCond = function()
                    -- 触发条件:攻击方式是拳脚且装备拳脚2  add by LvBin
                    if role:getAttackMethod() == SKILL_METHOD_TYPE_QUANJIAO and role:getRole():getPrepareSkill("quanjiao2") ~= nil then
                        return true
                    end
                    return false
                end,
                attrBuff =
                {
                    attrName = "qiAtkFactor",
                    getAttr = function()
                        return self:getZuoYouHuBoYinAtkFactor(role:getAttr("leftRightFightExp"))
                    end
                }
            },


        -- 使用主动技能 add by TangJian 2017/05/04 22:28:18
        -- 击杀 add by TangJian 2017/05/04 22:28:19
        -- 逃跑 add by TangJian 2017/05/04 22:28:21
        -- zhenliuyin = {name = "真流印", activeDesc = "真气在$N的体内快速运转，随着一阵灼热传来，触发了真流印！本次技能不消耗内力！"},
        -- zhenyiyin = {name = "真一印", activeDesc = "真气在$N的体内快速运转，随着一阵灼热传来，触发了真一印！本次技能冷却重置！"},
        -- zhenfengyin = {name = "真风印", activeDesc = "真气在$N的体内快速运转，随着一阵灼热传来，触发了真风印！内力恢复20%！"},
        -- zhenhuoyin = {name = "真火印", activeDesc = "真气在$N的体内快速运转，随着一阵灼热传来，触发了真火印！气血恢复10%！"},
        -- zhengangyin1 = {name = "真罡印", activeDesc = "真气在$N的体内快速运转，随着一阵灼热传来，触发了真罡印！攻击提升5%！"},
        }

    self._stateJingMaiYinJiMap = {}
    for k, v in pairs(stateJingMaiYinJiMap) do
        if self:getJingMaiYinJi(k) then
            local stateMap =
                {
                    ["生效"] = {name = "生效"},
                    ["失效"] = {name = "失效"}
                }
            local stateSwitchMap =
                {
                    ["生效"] =
                    {
                        ["失效"] =
                        {
                            cond = function()
                                return not v.activeCond()
                            end,
                            act = function()
                                self:updateBuff()
                                if DEBUG_TANG then
                                    PopText(v.name .. "失效")
                                end
                                LogSystem:log("旧版战斗：经脉系统 ",self._belongName, " 经脉效果 ",v.name .. "失效")
                                fight:callEventListener("inactiveJingMaiYinJi", k, v.name, v.name .. "失效")
                            end
                        }
                    },
                    ["失效"] =
                    {
                        ["生效"] =
                        {
                            cond = function()
                                if v.times then
                                    if v.times > 0 then
                                        if v.activeCond() then
                                            v.times = v.times - 1
                                            return true
                                        end
                                    end
                                else
                                    if v.activeCond() then
                                        return true
                                    end
                                end
                                return false
                            end,
                            act = function()
                                LogSystem:log("旧版战斗：经脉系统 ",self._belongName, " 经脉效果 ",v.name .. "生效")

                                self:updateBuff()

                                -- 执行生效的action
                                if v.activeAct then
                                    v.activeAct()
                                end

                                if DEBUG_TANG then
                                    PopText(v.name .. "生效")
                                end

                                local activeDesc = self:stringGsub(v.activeDesc,role)
                                fight:callEventListener("activeJingMaiYinJi", k, v.vname, activeDesc,role:getTeamId())
                            end
                        }
                    }
                }
            local stateMachine = StateMachine:create(stateMap, stateSwitchMap, "失效")
            self._stateMachineMap[k] = stateMachine
            v.stateMachine = stateMachine

            self._stateJingMaiYinJiMap[k] = v
        end
    end
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/05/08 10:57:32
-- @desc 左右互搏伤害加成表
local zuoYouHuBoYinAtkFactorMap =
    {
        1 / 100,
        2 / 100,
        3 / 100,
        4 / 100,
        5 / 100,
        6 / 100,
        7 / 100,
        8 / 100,
        9 / 100,
        10 / 100
    }

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/05/08 10:56:22
-- @desc 得到左右互搏伤害加成
function FightRoleJingMai:getZuoYouHuBoYinAtkFactor(leftRightFightExp)
    local lv = math.ceil(Helper:getDef(leftRightFightExp, 0) / 100)

    local leftRightFightDegree = leftRightFightExp % 100
    
	if leftRightFightExp > 99 and leftRightFightDegree == 0 then
		lv = lv + 1
    end
    
	if lv > 10 then
		lv = 10
	end
    return zuoYouHuBoYinAtkFactorMap[lv]
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/05/04 22:38:50
-- @desc 初始化触发型经脉印记
function FightRoleJingMai:initTriggerJingMaiYinJi(role)
    local jingmaiTestSwitch = false

    local fight = role._fight
    local target = fight:getRole(role:getTargetId())
    local Meridian = require("app.models.Meridian.Meridian")
    local triggerJingMaiYinJiMap =
        {
            -- 使用主动技能 add by TangJian 2017/04/25 02:51:15
            zhenliuyin = {name = "灵犀造化", vname = "RAN灵\n犀\n造\n化NOR", desc = "战斗中使用主动技能时，有几率不消耗内力", activeDesc = "真气在$N的体内快速运转，随着一阵灼热传来，激活了CYN灵犀造化NOR！本次技能不消耗内力！",
                type = "使用主动技能",
                times = 1,
                func = function(role, target, activeZhao)
                    if role._fight then

                        if jingmaiTestSwitch or 20 >= role._fight:random(1, 100) then
                            LogSystem:log("旧版战斗：经脉系统 ","触发者：",role:getName()," 经脉效果 灵犀造化 节省内力 = ",activeZhao:getFinalCost())
                            role:addAttr("neili", activeZhao:getFinalCost())
                            if DEBUG_TANG then
                                PopText("灵犀造化 不消耗内力!!!")
                            end
                            return true
                        end
                    end
                    return false
                end},
            zhenyiyin = {name = "羚羊挂角", vname = "RAN羚\n羊\n挂\n角NOR", desc = "战斗中使用主动技能时，有几率立即重置CD", activeDesc = "真气在$N的体内快速运转，随着一阵灼热传来，激活了CYN羚羊挂角NOR！本次技能冷却重置！",
                type = "使用主动技能",
                times = 1,
                func = function(role, target, activeZhao)
                    if role._fight then
                        if jingmaiTestSwitch or 30 >= role._fight:random(1, 100) and role._fight:random(1, 100) >= 21 then
                            LogSystem:log("旧版战斗：经脉系统 ","触发者：",role:getName()," 经脉效果 羚羊挂角 主动招式 = ",activeZhao.name.."冷却时间归零")
                            activeZhao:setCDLeft(0)
                            if DEBUG_TANG then
                                PopText("重置技能冷却时间！")
                            end
                            return true
                        end
                    end
                    return false
                end},
            zhenfengyin = {name = "三花聚顶", vname = "RAN三\n花\n聚\n顶NOR", desc = "战斗中使用主动技能时，有几率恢复一定内力", activeDesc = "真气在$N的体内快速运转，随着一阵灼热传来，激活了CYN三花聚顶NOR！恢复一定内力！",
                type = "使用主动技能",
                times = 1,
                func = function(role, target, activeZhao)
                    if role._fight and role:getAttr("neili") < role:getFinalAttr("neiliMax") then
                        if jingmaiTestSwitch or 40 >= role._fight:random(1, 100) and role._fight:random(1, 100) >= 31 then
                            local meridianBuffValue = role:getMeridianEffectRatio("zhenfengyin")
                            local addValue = math.floor(role:getAttr("neiliMax") * meridianBuffValue)
                            if addValue + role:getAttr("neili") > role:getFinalAttr("neiliMax") then
                                addValue = math.floor(role:getFinalAttr("neiliMax") - role:getAttr("neili"))
                            end   
                            role:addAttr("neili", addValue)
                            LogSystem:log("旧版战斗：经脉系统 ","触发者：",role:getName()," 经脉效果 三花聚顶 回复内力 = ",addValue)
                            if DEBUG_TANG then
                                PopText("三花聚顶 回复内力" .. addValue)
                            end
                            return true
                        end
                    end
                    return false
                end},
            zhenhuoyin = {name = "妙手回春", vname = "RAN妙\n手\n回\n春NOR", desc = "战斗中使用主动技能时，有几率恢复一定气血", activeDesc = "真气在$N的体内快速运转，随着一阵灼热传来，激活了CYN妙手回春NOR！恢复一定气血！",
                type = "使用主动技能",
                times = 1,
                func = function(role, target, activeZhao)
                    if role._fight and role:getAttr("qi") < role:getCurrQiMax() then
                        if jingmaiTestSwitch or 50 >= role._fight:random(1, 100) and role._fight:random(1, 100) >= 41 then
                            local meridianBuffValue = role:getMeridianEffectRatio("zhenhuoyin")
                            local addValue = math.floor(role:getAttr("qiMax") * meridianBuffValue)
                            if addValue + role:getAttr("qi") > role:getCurrQiMax() then
                                addValue = math.floor(role:getCurrQiMax() - role:getAttr("qi"))
                            end                         
                            role:addAttr("qi", addValue)
                            if DEBUG_TANG then
                                PopText("妙手回春 回复气血" .. addValue)
                            end
                            LogSystem:log("旧版战斗：经脉系统 ","触发者：",role:getName()," 经脉效果 妙手回春 回复气血 = ",addValue)
                            return true
                        end
                    end
                    return false
                end},
            zhengangyin1 = {name = "招招致命", vname = "RAN招\n招\n致\n命NOR", desc = "战斗中使用主动技能时，有几率提升一定攻击", activeDesc = "真气在$N的体内快速运转，随着一阵灼热传来，激活CYN招招致命NOR！攻击提升！",
                type = "使用主动技能",
                times = 1,
                func = function(role, target, activeZhao)
                    if role._fight then
                        if jingmaiTestSwitch or 60 >= role._fight:random(1, 100) and role._fight:random(1, 100) >= 51 then
                            local meridianBuffValue = role:getMeridianEffectRatio("zhengangyin1")
                            local addValue = role:getAttr("qiAtkFactor") * meridianBuffValue
                            -- local addatk = math.floor( zhao.atk * addValue )
                            role:addAttr("qiAtkFactor", addValue)
                            LogSystem:log("旧版战斗：经脉系统 ","触发者：",role:getName()," 经脉效果 招招致命 提升攻击 气血攻击系数增加 = ",addValue)
                            if DEBUG_TANG then
                                -- PopText("招招致命 提升攻击" ..  addatk)
                                PopText("招招致命 提升攻击")
                            end
                            return true
                        end
                    end
                    return false
                end},

            -- 逃跑 add by TangJian 2017/04/25 02:50:57
            pifengyin = {name = "卷土重来", vname = "RAN卷\n土\n重\n来NOR", desc = "战斗中逃跑，有几率恢复一定内力", activeDesc = "真气在$N的体内快速运转，随着一阵灼热传来，激活了HIW卷土重来NOR！恢复部分内力！",
                type = "逃跑",
                times = 1,
                func = function(role, target, activeZhao)
                    if role._fight and role:getAttr("neili") < role:getFinalAttr("neiliMax") then
                        if jingmaiTestSwitch or 10 >= role._fight:random(1, 100) then
                            local meridianBuffValue = Meridian:getMeridianBuffValue("pifengyin")
                            meridianBuffValue = string.split(meridianBuffValue,";")
                            local minValue = tonumber(meridianBuffValue[1])
                            local maxValue = tonumber(meridianBuffValue[2])
                            local addValue = math.floor(role:getAttr("neiliMax") * role._fight:random(minValue, maxValue) / 100)
                            if addValue + role:getAttr("neili") > role:getFinalAttr("neiliMax") then
                                addValue = math.floor(role:getFinalAttr("neiliMax") - role:getAttr("neili"))
                            end
                            role:addAttr("neili", addValue)

                            LogSystem:log("旧版战斗：经脉系统 ","触发者：",role:getName()," 经脉效果 卷土重来 回复内力 = ",addValue)
                            if DEBUG_TANG then
                                PopText("卷土重来 回复内力" .. addValue)
                            end
                            return true
                        end
                    end
                    return false
                end},
            pihuoyin = {name = "败而不倒", vname = "RAN败\n而\n不\n倒NOR", desc = "战斗中逃跑，有几率恢复一定气血", activeDesc = "真气在$N的体内快速运转，随着一阵灼热传来，激活了HIW败而不倒NOR！恢复部分气血！",
                type = "逃跑",
                times = 1,
                func = function(role, target, activeZhao)
                    if role._fight and role:getAttr("qi") < role:getCurrQiMax() then
                        if jingmaiTestSwitch or 20 >= role._fight:random(1, 100) and role._fight:random(1, 100) >= 11 then
                            local meridianBuffValue = Meridian:getMeridianBuffValue("pihuoyin")
                            meridianBuffValue = string.split(meridianBuffValue,";")
                            local minValue = tonumber(meridianBuffValue[1])
                            local maxValue = tonumber(meridianBuffValue[2])
                            local addValue = math.floor(role:getAttr("qiMax") * role._fight:random(minValue, maxValue) / 100)
                            if addValue + role:getAttr("qi") > role:getCurrQiMax() then
                                addValue = math.floor(role:getCurrQiMax() - role:getAttr("qi"))
                            end
                            role:addAttr("qi", addValue)
                            LogSystem:log("旧版战斗：经脉系统 ","触发者：",role:getName()," 经脉效果 败而不倒 回复气血 = ",addValue)
                            if DEBUG_TANG then
                                PopText("败而不倒 回复气血" .. addValue)
                            end
                            return true
                        end
                    end
                    return false
                end},
            pileiyin = {name = "金蝉脱壳", vname = "RAN金\n蝉\n脱\n壳NOR", desc = "战斗中逃跑，有几率立即治愈伤势", activeDesc = "真气在$N的体内快速运转，随着一阵灼热传来，激活了HIW金蝉脱壳NOR！伤势自动痊愈！",
                type = "逃跑",
                times = 1,
                func = function(role, target, activeZhao)
                    if role._fight and role:getAttr("qiPercent") ~= 1 then
                        if jingmaiTestSwitch or 30 >= role._fight:random(1, 100) and role._fight:random(1, 100) >= 21 then
                            -- role:addAttr("qi", role:getCurrQiMax()) -- add by XiaoZhiWei 2017/06/16 17:48:31 增加气血上限的数量的气血,气血有联动检查,不会超出上限
                            role:setAttr("qiPercent", 1)
                            LogSystem:log("旧版战斗：经脉系统 ","触发者：",role:getName()," 经脉效果 金蝉脱壳 立即恢复 ")
                            if DEBUG_TANG then
                                PopText("金蝉脱壳 立即恢复")
                            end
                            return true
                        end
                    end
                    return false
                end},

            -- 击杀敌人 add by TangJian 2017/04/25 02:50:48
            xiuhuoyin = {name = "以战养战", vname = "RAN以\n战\n养\n战NOR", desc = "战斗中击杀敌人，有几率立即恢复一定气血", activeDesc = "真气在$N的体内快速运转，随着一阵灼热传来，激活了HIW以战养战NOR！恢复一定气血！",
                type = "击杀敌人",
                func = function(role, target)
                    if role._fight and role:getAttr("qi") < role:getCurrQiMax() then
                        if jingmaiTestSwitch or 10 >= role._fight:random(1, 100) then
                            -- 回复超过气血上限, 肖智威处理 add by TangJian 2017/06/15 17:44:18
                            local meridianBuffValue = Meridian:getMeridianBuffValue("xiuhuoyin")
                            meridianBuffValue = string.split(meridianBuffValue,";")
                            local minValue = tonumber(meridianBuffValue[1])
                            local maxValue = tonumber(meridianBuffValue[2])
                            local addValue = math.floor(role:getAttr("qiMax") * role._fight:random(minValue, maxValue) / 100)
                            if addValue + role:getAttr("qi") > role:getCurrQiMax() then
                                addValue = math.floor(role:getCurrQiMax() - role:getAttr("qi"))
                            end
                            role:addAttr("qi", addValue)
                            LogSystem:log("旧版战斗：经脉系统 ","触发者：",role:getName()," 经脉效果 以战养战 气血 回复 = ",addValue)
                            if DEBUG_TANG then
                                PopText("以战养战 气血 回复" .. addValue)
                            end
                            return true
                        end
                    end
                    return false
                end},
            xiufengyin = {name = "枯木逢春", vname = "RAN枯\n木\n逢\n春NOR", desc = "战斗中击杀敌人，有几率立即恢复一定内力", activeDesc = "真气在$N的体内快速运转，随着一阵灼热传来，激活了HIW枯木逢春NOR！恢复一定内力！",
                type = "击杀敌人",
                func = function(role, target)
                    if role._fight and role:getAttr("neili") < role:getFinalAttr("neiliMax") then
                        if jingmaiTestSwitch or 20 >= role._fight:random(1, 100) and role._fight:random(1, 100) >= 11 then
                            local meridianBuffValue = Meridian:getMeridianBuffValue("xiufengyin")
                            meridianBuffValue = string.split(meridianBuffValue,";")
                            local minValue = tonumber(meridianBuffValue[1])
                            local maxValue = tonumber(meridianBuffValue[2])
                            local addValue = math.floor(role:getAttr("neiliMax") * role._fight:random(minValue, maxValue) / 100)
                            if addValue + role:getAttr("neili") > role:getFinalAttr("neiliMax") then
                                addValue = math.floor(role:getFinalAttr("neiliMax") - role:getAttr("neili"))
                            end  
                            role:addAttr("neili", addValue)
                            LogSystem:log("旧版战斗：经脉系统 ","触发者：",role:getName()," 经脉效果 枯木逢春 内力 回复 = ",addValue)
                            if DEBUG_TANG then
                                PopText("枯木逢春 内力 回复" .. addValue)
                            end
                            return true
                        end
                    end
                    return false
                end},
            xiuleiyin = {name = "越战越勇", vname = "RAN越\n战\n越\n勇NOR", desc = "战斗中击杀敌人，有几率立即治愈伤势", activeDesc = "真气在$N的体内快速运转，随着一阵灼热传来，激活了HIW越战越勇NOR！伤势自动痊愈！",
                type = "击杀敌人",
                func = function(role, target)
                    if role._fight and role:getAttr("qiPercent") ~= 1 then
                        if jingmaiTestSwitch or 40 >= role._fight:random(1, 100) and role._fight:random(1, 100) >= 21 then
                            -- 需要肖智威处理 add by TangJian 2017/06/15 17:18:52
                            -- local addValue = role:getFinalAttr("qiMax")
                            -- role:addAttr("qi", addValue)
                            role:setAttr("qiPercent", 1)
                            LogSystem:log("旧版战斗：经脉系统 ","触发者：",role:getName()," 经脉效果 越战越勇 立即治愈伤势")
                            if DEBUG_TANG then
                                PopText("越战越勇 立即治愈伤势")
                            end
                            return true
                        end
                    end
                    return false
                end},

            -- 暂时没用上
            jiemaiyin = {name = "截脉印", vname = "RAN截\n脉\n印", activeDesc = "真气在$N的体内快速运转，随着一阵灼热传来，触发了RED截脉印NOR！对手经脉天赋失效！",
                type = "截脉印",
                func = function()
                    if role._fight then
                        if jingmaiTestSwitch or 10 >= role._fight:random(1, 100) then
                            if DEBUG_TANG then
                                PopText("截脉印 造成敌人经脉天赋失效")
                            end
                            return true
                        end
                    end
                    return false
                end
            }
        }

    self._triggerJingMaiYinJiMap = {}
    for k, v in pairs(triggerJingMaiYinJiMap) do
        if self:getJingMaiYinJi(k) then
            self._triggerJingMaiYinJiMap[k] = v
        end
    end

    for k, v in pairs(self._triggerJingMaiYinJiMap) do
        if type(v.times) ~= "number" then
            v.times = 9999999
        end
    end
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/05/04 22:40:31
-- @desc 使用触发型经脉印记
function FightRoleJingMai:triggerJingMaiYinJi(fightRole, type, ...)
    for k, v in pairs(self._triggerJingMaiYinJiMap) do
        if v.type == type and v.times > 0 then
            LogSystem:log("旧版战斗：经脉系统","触发判断  ","|经脉效果:",v.name,"|条件类型：",v.type)
            if v.func(...) then
                v.times = v.times - 1
                if fightRole and fightRole._fight then
                    local activeDesc = self:stringGsub(v.activeDesc,fightRole)
                    fightRole._fight:callEventListener("activeJingMaiYinJi", k, v.vname, activeDesc,fightRole:getTeamId())
                end
            else
                LogSystem:log("旧版战斗：经脉系统","触发失败  ","|经脉效果:",v.name,"|条件类型：",v.type)
            end
        end
    end
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/05/04 22:07:19
-- @desc 刷新
function FightRoleJingMai:update()
    for k, v in pairs(self._stateMachineMap) do
        v:update()
    end
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/05/04 21:48:00
-- @desc 刷新属性加成
function FightRoleJingMai:updateBuff()
    for k, jingMaiYin in pairs(self._stateJingMaiYinJiMap) do
        if self[k] ~= true and jingMaiYin.stateMachine:getCurrStateId() == "生效" then
            if jingMaiYin.attrBuff then
                self[k] = true --记录已经生效过的经脉id
                self._attr[jingMaiYin.attrBuff.attrName] = jingMaiYin.attrBuff.getAttr()
                LogSystem:log("旧版战斗：经脉系统 ","经脉效果作用属性：",jingMaiYin.attrBuff.attrName," |经脉效果值 =  ",self._attr[jingMaiYin.attrBuff.attrName])
            end
        end
    end
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/05/04 21:45:24
-- @desc 得到属性加成
function FightRoleJingMai:getAttr(name)
    local value = self._attr[name]
    if type(value) == "number" then
        return value
    end
    return 0
end

function FightRoleJingMai:stringGsub(str,role)
    local text = str
    if role:getTeamId() == 1 then
        text = string.gsub(text,"$N","你")
    else
        text = string.gsub(text,"$N",role:getName())
    end
    return text
end


return FightRoleJingMai
0000000000000000