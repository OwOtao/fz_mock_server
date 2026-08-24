local EffectFactory = require("app.models.fight.Effect.EffectFactory")
local FightConfig = require("app.models.fight.FightConfig")
local LogSystem = require("app.models.LogSystem.LogSystem")

local SkillEffect = {}

local oldPrint = print

local function print(...)
    if PRINT_MODE == 1 then
        oldPrint(...)
    else
    end
end

defVars(
    SkillEffect,
    {
        -- 基本属性 add by TangJian 2017/03/06 16:44:13
        id = {"Id", ""}, -- 效果编号
        name = {"Name", ""}, -- 效果名
        desc = {"Desc", ""}, -- 效果描述
        owner = {"Owner"}, -- 释放者
        object = {"Object"}, -- 对象
        beginDesc = {"BeginDesc", nil}, -- 效果开始描述
        doDesc = {"DoDesc", nil}, -- 效果开始描述
        endDesc = {"EndDesc", nil}, -- 效果开始描述
        type = {"Type", ""}, -- 效果类型
        arg1 = {"Arg1"},
        arg2 = {"Arg2"},
        arg3 = {"Arg3"},
		arg4 = {"Arg4"},
        zargs = {"ZArgs"}, -- 得到招式参数
        target = {"Target", "目标"}, -- 释放对象
        property = {"Property", "阳性"}, -- 性质
        formula = {"Formula", "0"}, -- 计算公式
        effectTag = {"EffectTag", ""}, -- 效果标签
        isBuff = {"IsBuff", true}, -- 是否是增益
        -- 持续效果 add by TangJian 2016/12/22 15:42:38
        duration = {"Duration", 0, 0}, -- 持续回合数
        probability = {"Probability", 100, 0, 100}, -- 发动几率
        activeZhaoAvgQiAtk = {"ActiveZhaoAvgQiAtk", 1}, -- 招式的平均气血伤害
        activeZhaoCost = {"ActiveZhaoCost", 1}, -- 主动技能消耗
        activeZhao = {"ActiveZhao"}, -- 主动招式
        -- 游戏中使用 add by TangJian 2017/03/06 16:44:25
        validDuration = {"ValidDuration", 0},
        -- 影响类型;effectType
        -- 0=正面效果 1=负面效果(非毒类) 2=控制效果 3=其他效果 4= 毒类 可以填"1;4"表示属于这两种类型
        effectType = {"EffectType", ""},
        --伤害类型 1 = 真伤（无视护盾，但还是会被偏转和反弹影响）
        damagetype = {"DamageType", 0},
        -- 生效几率;truerate
        -- 默认100%生效，不填就是默认100%生效，填100就是100%，填50就是50%，填0就是不会生效
        truerate = {"Truerate", 100},
        delayTime = {"DelayTime", 0}, --延时几回合生效
        effectAnim = {"EffectAnim", nil}, --效果动画
        effectExtraValue = {"EffectExtraValue", 0}, --效果额外值
        effectFuncDesc = {"EffectFuncDesc", nil}, --效果功能逻辑执行成功文本
        activeZhaoAtkDamageClass = {"ActiveZhaoAtkDamageClass", 0}, --伤害属性类型
		popText = {"PopText", ""}, --冒字文本
    }
)
-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/12/22 15:07:01
-- @desc 通过数据创建技能效果
function SkillEffect:create(data)
    local p = clone(SkillEffect)
    p:initWithData(data)
    return p
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/12/22 15:08:49
-- @desc 通过data初始化技能效果
function SkillEffect:initWithData(data)
    assert(type(data) == "table")
    Helper:tableCover(self, data)
    -- error("sdfasdfasd")
    -- 数据初始化, 以及校验
    switch(
        self:getType(),
        {
            ["属性变化"] = function()
                local arrtName = assert(self:attrNameCnToEn(self:getArg1()))
                self:setArg1(arrtName)
            end,
            ["属性增益"] = function()
                local arrtName = assert(self:attrNameCnToEn(self:getArg1()))
                self:setArg1(arrtName)
            end,
            ["控制"] = function()
            end,
            ["护盾"] = function()
            end,
            ["反伤"] = function()
            end,
            ["偏转"] = function()
            end,
            ["打掉兵器"] = function()
            end,
            ["效果关联"] = function()
            end,
            ["招架反击"] = function()
            end,
            ["净化"] = function()
            end,
            ["解控"] = function()
            end,
            ["免疫控制"] = function()
            end,
            ["截脉"] = function()
            end,
            ["抗毒"] = function()
            end,
            ["禁锢"] = function()
            end,
            ["遗忘"] = function()
            end,
            ["闪耀"] = function()
            end,
            ["闪烁"] = function()
            end,
            ["内省"] = function()
            end,
            ["投掷"] = function()
            end,
            ["窃取"] = function()
            end,
            ["凝血"] = function()
            end,
            ["汲取"] = function()
            end,
            ["吸血"] = function()
            end,
            ["反震"] = function()
            end,
            ["内伤"] = function()
            end,
            ["真伤"] = function()
            end,
            ["强招架"] = function()
            end,
            ["卸力"] = function()
            end,
            ["破招"] = function()
            end,
            ["平衡"] = function()
            end,
            ["架御"] = function()
            end,
            ["架势"] = function()
            end,
            ["抗增益"] = function()
            end,
            ["抗减益"] = function()
            end,
            ["延时生效"] = function()
            end,
            ["恢复修正"] = function()
            end,
            ["反噬"] = function()
            end,
            ["延宕"] = function()
            end,
            ["真罡"] = function()
            end,
            ["修武"] = function()
            end,
            ["武器切换"] = function()
            end,
            ["效果切换"] = function()
            end,
            ["易伤标记"] = function()
            end,
            ["增伤标记"] = function()
            end,
            ["指定延宕"] = function()
            end,
            ["指定驱散"] = function()
            end,
            ["被动命中触发"] = function()
            end,
            ["标记触发"] = function()
            end,
            ["致盲"] = function()
            end,
            ["招架触发"] = function()
            end,
			["招架无效果触发"] = function()
            end,
            ["属性条件触发"] = function()
            end,
            ["准备武器触发"] = function()
            end,
            ["拳脚武器切换"] = function()
            end,
            ["储伤"] = function()
            end,
            ["储伤失效"] = function()
            end,
            ["监控角色属性"] = function()
            end,
            ["角色立即死亡"] = function()
            end,
            ["受击触发"] = function()
            end,
            ["伤害转气血"] = function()
            end,
            ["可取回缴械"] = function()
            end,
            ["类型抵抗"] = function()
            end,
            ["类型转移"] = function()
            end,
            ["类型驱散"] = function()
            end,
            ["闪避触发"] = function()
            end,
            ["伤害转持续自伤"] = function()
            end,
            ["追加伤害"] = function()
            end,
            ["无法攻击"] = function()
            end,
            ["属性叠加"] = function()
            end,
            ["拳脚经脉增强"] = function()
            end,
            ["无指定效果时触发"] = function()
            end,
            ["无法易武"] = function()
            end,
            ["冷却变化"] = function()
            end,
            ["使用主动技能"] = function()
            end,
            ["单次伤害上限"] = function()
            end,
            ["记录承受伤害"] = function()
            end,
            ["主动碎盾"] = function()
            end,
            ["指定抵抗"] = function()
            end,
            ["经脉天赋修正"] = function()
            end,
            ["伤害抗性修正"] = function()
            end,
			["反弹"] = function()
            end,
			["加权随机触发"] = function()
            end,
			["效果判断触发"] = function()
            end,
			["必中"] = function()
            end,
            default = function()
                error(self:getId() .. ": 没有定义效果类型 type = " .. self:getType())
            end
        }
    )

    -- -- 将秒转成帧
    -- if self.duration then
    --     self.duration = self.duration * 30
    -- end
    -- isBuff字段解析
    -- if self.isBuff then
    --     self.isBuff = switch(self.isBuff,
    --         {
    --             ["是"] = true,
    --             ["否"] = false,
    --             [""] = nil,
    --             default = function()
    --                 error("self.isBuff = ", self.isBuff)
    --             end
    --         })
    -- else
    --     self.isBuff = false
    -- end
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/03/09 16:14:11
-- @desc 测试错误
function SkillEffect:getEffectParams()
    local effectParams = {
        min = math.min,
        max = math.max,
        random = math.random,
        z1 = 1,
        z2 = 1,
        z3 = 1,
        z4 = 0,
        currcon = 1, -- 有效根骨
        currstr = 1, -- 有效臂力
        qimax = 1, -- 气血最大值
        qiMax2 = 1, --目标气血最大值
        currdex = 1,
        --有效身法
        avgqiatk = 1, -- 平均气血伤害
        cost = 1, -- 技能消耗
        neili = 1, --自己当前内力值
        neili2 = 1, --目标当前内力值
        neiliMax = 1, --自己当前内力最大值
        neiliMax2 = 1, --目标当前内力最大值
        nengGongRecoverNeiLiFactor = 1,
        qi = 1, -- 自己当前气血
        qi2 = 1, -- 目标当前气血
        qi3 = 0, --对手气血
        qiMax3 = 0, --对手气血上限
        neili3 = 0, --对手内力
        neiliMax3 = 0, --对手内力上限
        zhengqi = 1,
        W1 = 1,
        W2 = 1,
        K1 = 1,
        K2 = 1,
        YD1 = 1,
        YD2 = 1,
        RD1 = 1,
        RD2 = 1,
        CN = 1,
        dssklv = 0,
        wdamage = 0,
        wdamage2 = 0,
		wyindu = 0,
		wyindu2 = 0,
		wrendu = 0,
		wrendu2 = 0,
		wweight = 0,
		wweight2 = 0,
		
        szjLv = 0,
        CSJYIN = 0,
        looks = 0,
        roleLv = 0,
        zgxjLv = 0,
        dkxgLv = 0,
        jing = 0, --角色精力值
        jingMax = 0, --角色精力最大值
        buff1Num = 0,
        buff2Num = 0,
        buff3Num = 0,
        buff4Num = 0,
        jqdamage = 0,
        currjqdamage = 0,
        saveDamage = 0,
        saveDamageMax = 0,
        despairForce = 0,
        jiaLi = 0,  --	自己当前加力
        jiaLiMax = 0,--	自己加力上限
        jiaLi2 = 0,--	对手当前加力
        jiaLiMax2 = 0,--	对手加力上限
        damageToHurt = 0, --自己伤害累计值
        shieldCurrentHP = 0, --自己剩余护盾吸收量
        shieldDeductedHP = 0, --自己护盾已吸收量
        shieldCurrentHP2 = 0, --对手剩余护盾吸收量
        shieldDeductedHP2 = 0, --对手护盾已吸收量
        recordDamage = 0,
        recordDamage2 = 0
    }

    for i = 1, FightConfig.Constant.FragileCount do
        local info = FightConfig:getFragileInfoById(i)
        effectParams[info.arg] = 0
    end

    for i = 1, FightConfig.Constant.AugmentCount do
        local info = FightConfig:getAugmentInfoById(i)
        effectParams[info.arg] = 0
    end

    for i,markId in ipairs(self:getEffectMarkIdList()) do
        effectParams[markId] = 0
        effectParams[markId.."2"] = 0
    end

    return effectParams
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/12/24 15:44:19
-- @desc 克隆自身
function SkillEffect:clone()
    return inherit({owner = self.owner, object = self.object, activeZhao = self.activeZhao}, self)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/12/24 15:44:27
-- @desc 得到数值
function SkillEffect:getValue(atk)
    return Helper:GetValueFromScript(self:getFormula(), {atk = atk})
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/02/22 11:19:18
-- @desc 判断是否是增益效果
function SkillEffect:isBuff()
    return self.isBuff
end

local cnToEnMap = {
    ["气血"] = "qi",
    ["气血上限"] = "qiMax",
    ["内力"] = "neili",
    ["气血伤害"] = "qiAtkFactor",
    ["气血上限伤害"] = "qiMaxAtkFactor",
    ["体力回复速度"] = "tiliRestoreFactor",
    ["命中系数"] = "hitRateFactor",
    ["招架系数"] = "parryRateFactor",
    ["闪避系数"] = "dodgeRateFactor",
    ["被动气血伤害系数"] = "qiAutoAtkFactor",
    ["招架免伤强化系数"] = "parryHurtFixRateFactor",
    ["主动气血伤害系数"] = "qiActiveAtkFactor",
    ["被动气血防御系数"] = "qiAutoDefFactor",
    ["主动气血防御系数"] = "qiActiveDefFactor",
    
}
local enToCnMap = {}
for k, v in pairs(cnToEnMap) do
    enToCnMap[v] = k
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/01/09 18:05:37
-- @desc 属性中文名英文名
function SkillEffect:attrNameCnToEn(name)
    if cnToEnMap[name] then
        return cnToEnMap[name]
    else
        return name
    end
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/01/09 18:12:11
-- @desc 属性英文名转中文名
function SkillEffect:attrNameEnToCn(name)
    return enToCnMap
end

local params = {}

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/03/02 11:35:41
-- @desc 得到最终参数
function SkillEffect:getValueWithCalc(value)
    local varNameMap = Helper:getVarNameMapFromString(value)

    do
        params.min = math.min
        params.max = math.max
        params.abs = math.abs
        -- params.random = math.random
    end

    -- 拥有者属性参数
    do
        local owner = self:getOwner()
        local object = self:getObject()

        --@desc W1 自己神兵重量
        --@desc W2 对方神兵重量
        --@desc K1 自己招架等级
        --@desc K2 对方招架等级
        --@desc CN 自己神兵淬炼次数
        --@desc wdamage 自己兵器伤害力
        --@desc YD1 自己神兵硬度
        --@desc YD2 对方神兵硬度
        --@desc RD1 自己神兵韧度
        --@desc RD2 自己神兵韧度
        local YD1, YD2, RD1, RD2 = 0, 0, 0, 0
        local W1, W2, K1, K2, CN = 0, 0, 0, 0, 0
		local wdamage, wyindu, wrendu, wweight = 0, 0, 0, 0
        local wdamage2, wyindu2, wrendu2, wweight2 = 0, 0, 0, 0

        local dssklv = 0
        local szjLv = 0 --神照经等级
        local CSJYIN = 0 --长生诀阴等级
        local dkxgLv = 0 --丹匮玄功等级
        local looks = 0 -- 容貌
        local roleLv = 0 -- 角色等级
        local qiMax2 = 0 --目标气血最大值
        local qi = 0
        local qi2 = 0
        local jing = 0
        local jingMax = 0

        local buff1Num = 0 --当前自己身上有的增益效果（即影响类型;effectType=0或5的效果）的数量
        local buff2Num = 0 --当前自己身上有的负面效果（即影响类型;effectType=1或4或6或7的效果）的数量
        local buff3Num = 0 --当前对手身上有的增益效果（即影响类型;effectType=0或5的效果）的数量
        local buff4Num = 0 --当前对手身上有的负面效果（即影响类型;effectType=1或4或6或7的效果）的数量

        local neili2 = 0 --目标当前内力
        local neiliMax2 = 0 --目标内力上限

        --@desc 毒术技能等级
        if SHENBINGSYS then
            if owner ~= nil then
                if varNameMap["dssklv"] or varNameMap["W1"] or varNameMap["CN"] or varNameMap["YD1"] or varNameMap["RD1"] then
                    local ownerWeapon = owner:getRole():getEquipByName("weapon")
                    if ownerWeapon ~= nil then
                        local OwnerWeapon = owner:getRole():getOneItemByKey(ownerWeapon.itemId)
                        if OwnerWeapon ~= nil then
                            W1 = OwnerWeapon:getWeaponWeight(owner:getRole())
                            YD1 = OwnerWeapon:getWeaponYingDu(owner:getRole())
                            RD1 = OwnerWeapon:getWeaponRenDu(owner:getRole())
                            if OwnerWeapon.wpType == "神兵" then
                                CN = OwnerWeapon.cuilianCount
                            end
                        end

                        if varNameMap["dssklv"] then
                            if POISONSYS then
                                local rolePoisons = owner:getRolePoisons()
                                if rolePoisons then
                                    for poisonId, rolePoison in ipairs(rolePoisons) do
                                        dssklv = rolePoison.skillLv
                                    end
                                end
                            end
                        end
                    end
                end

                if varNameMap["K1"] then
                    local zhaoJiaSkill = owner:getRole():getPrepareSkill("zhaojia")
                    if zhaoJiaSkill ~= nil then
                        K1 = owner:getRole():getSkillLv(zhaoJiaSkill)
                    else
                        K1 = owner:getRole():getSkillLv("jibenzhaojia") / 4
                    end
                end
            end
            if varNameMap["W2"] or varNameMap["K2"] or varNameMap["YD2"] or varNameMap["RD2"] then
                if object ~= nil then
                    local objectWeapon = object:getRole():getEquipByName("weapon")
                    if objectWeapon ~= nil then
                        local ObjectWeapon = object:getRole():getOneItemByKey(objectWeapon.itemId)
                        if ObjectWeapon ~= nil then
                            W2 = ObjectWeapon:getWeaponWeight(object:getRole())
                            YD2 = ObjectWeapon:getWeaponYingDu(object:getRole())
                            RD2 = ObjectWeapon:getWeaponRenDu(object:getRole())
                        end
                    end
                    local zhaoJiaSkill = object:getRole():getPrepareSkill("zhaojia")
                    if zhaoJiaSkill ~= nil then
                        K2 = object:getRole():getSkillLv(zhaoJiaSkill)
                    else
                        K2 = object:getRole():getSkillLv("jibenzhaojia") / 4
                    end
                end
            end
        end

        if varNameMap["szjLv"] then
            --神照经等级
            if owner ~= nil and owner:getRole():getSkill("shenzhaojing003") ~= nil then
                szjLv = owner:getRole():getSkillLv("shenzhaojing003")
            end
        end

        --长生诀阴等级
        if varNameMap["CSJYIN"] then
            if owner ~= nil and owner:getRole():getSkill("changshengjueyin") ~= nil then
                CSJYIN = owner:getRole():getSkillLv("changshengjueyin")
            end
        end
        --丹匮玄功等级
        if varNameMap["dkxgLv"] then
            if owner ~= nil and owner:getRole():getSkill("dankuixuangong") ~= nil then
                dkxgLv = owner:getRole():getSkillLv("dankuixuangong")
            end
        end

        local avgQiAtk = 1

        if object then
            if varNameMap["avgqiatk"] then
                avgQiAtk = owner:getRole():getAvgQiAtk(object:getRole())
            end

            if varNameMap["qiMax2"] then
                qiMax2 = object:getFinalAttr("qiMax")
            end

            if varNameMap["shieldCurrentHP2"] then
                params.shieldCurrentHP2 = object:getAttr("shieldCurrentHP")
            end

            if varNameMap["shieldDeductedHP2"] then
                params.shieldDeductedHP2 = object:getAttr("shieldDeductedHP")
            end
			
			if varNameMap["wdamage2"] then
				wdamage2 = object:getWeaponDamage()
			end

			if varNameMap["wyindu2"] then
				wyindu2 = object:getWeaponYingDu()
			end

			if varNameMap["wrendu2"] then
				wrendu2 = object:getWeaponRenDu()
			end

			if varNameMap["wweight2"] then
				wweight2 = object:getWeaponWeight()
			end
        end


        if owner then
            if varNameMap["looks"] then
                looks = owner:getFinalAttr("looks")
            end
            if varNameMap["roleLv"] then
                roleLv = owner:getRole():getAttr("lv")
            end
            if varNameMap["jing"] then
                jing = owner:getRole():getAttr("jing")
            end
            if varNameMap["jingMax"] then
                jingMax = owner:getRole():getJingMax()
            end

			if varNameMap["wdamage"] then
				wdamage = owner:getWeaponDamage()
			end

			if varNameMap["wyindu"] then
				wyindu = owner:getWeaponYingDu()
			end

			if varNameMap["wrendu"] then
				wrendu = owner:getWeaponRenDu()
			end

			if varNameMap["wweight"] then
				wweight = owner:getWeaponWeight()
			end

            if varNameMap["buff1Num"] then
                buff1Num = owner:getEffectNumByEffectType(EFFECT_TYPE_POSITIVE) + owner:getEffectNumByEffectType(EFFECT_SPECIAL_POSITIVE)
            end

            if varNameMap["buff2Num"] then
                buff2Num =
                    owner:getEffectNumByEffectType(EFFECT_TYPE_NEGATIVE) + owner:getEffectNumByEffectType(EFFECT_TYPE_POISON) + owner:getEffectNumByEffectType(EFFECT_SPECIAL_NEGATIVE) +
                    owner:getEffectNumByEffectType(EFFECT_SPECIAL_POISON)
            end

            if varNameMap["jiaLi"] then
                params.jiaLi = owner:getFinalAttr("jiaLi")
            end

            if varNameMap["jiaLiMax"] then
                params.jiaLiMax = owner:getRole():getJiaLiMax()
            end

            if varNameMap["recordDamage"] then
                params.recordDamage = owner:getRecordDamage()
            end

            if varNameMap["shieldCurrentHP"] then
                params.shieldCurrentHP = owner:getAttr("shieldCurrentHP")
            end

            if varNameMap["shieldDeductedHP"] then
                params.shieldDeductedHP = owner:getAttr("shieldDeductedHP")
            end

            local target = owner:getTarget() --对方
            if target then
                if varNameMap["buff3Num"] then
                    buff3Num = target:getEffectNumByEffectType(EFFECT_TYPE_POSITIVE) + target:getEffectNumByEffectType(EFFECT_SPECIAL_POSITIVE)
                end

                if varNameMap["buff4Num"] then
                    buff4Num =
                        target:getEffectNumByEffectType(EFFECT_TYPE_NEGATIVE) + target:getEffectNumByEffectType(EFFECT_TYPE_POISON) + target:getEffectNumByEffectType(EFFECT_SPECIAL_NEGATIVE) +
                        target:getEffectNumByEffectType(EFFECT_SPECIAL_POISON)
                end

                for i = 1, FightConfig.Constant.FragileCount do
                    local fragileInfo = FightConfig:getFragileInfoById(i)
                    if varNameMap[fragileInfo.arg] then
                        params[fragileInfo.arg] = target:getFragileValue(i)
                    end
                end

                if varNameMap["neili3"] then
                    params.neili3 = target:getAttr("neili")
                end
        
                if varNameMap["neiliMax3"] then
                    params.neiliMax3 = target:getAttr("neiliMax")
                end

                if varNameMap["qi3"] then
                    params.qi3 = target:getAttr("qi")
                end
        
                if varNameMap["qiMax3"] then
                    params.qiMax3 = target:getAttr("qiMax")
                end

                if varNameMap["jiaLi2"] then
                    params.jiaLi2 = target:getFinalAttr("jiaLi")
                end

                if varNameMap["jiaLiMax2"] then
                    params.jiaLiMax2 = target:getRole():getJiaLiMax()
                end

                if varNameMap["recordDamage2"] then
                    params.recordDamage2 = target:getRecordDamage()
                end

                for i,markId in ipairs(self:getEffectMarkIdList()) do
                    params[markId.."2"] = target:getEffectMarkValue(markId)
                end
            end

            for i = 1, FightConfig.Constant.AugmentCount do
                local augmentInfo = FightConfig:getAugmentInfoById(i)
                if varNameMap[augmentInfo.arg] then
                    params[augmentInfo.arg] = owner:getAugmentValue(i)
                end
            end

            for i,markId in ipairs(self:getEffectMarkIdList()) do
                params[markId] = owner:getEffectMarkValue(markId)
            end
        end

        local zgxjLv = 0

        if varNameMap["zgxjLv"] then
            if owner ~= nil and owner:getRole():getSkill("zhengaoxuanjing") ~= nil then
                zgxjLv = owner:getRole():getSkillLv("zhengaoxuanjing")
            end
        end

        --随机函数
        local function randomFunc(a, b)
            return owner._fight.random(owner._fight, a, b)
        end

        params.random = randomFunc

        if varNameMap["neili"] then
            params.neili = owner:getAttr("neili") -- 内力
        end

        if varNameMap["neiliMax"] then
            params.neiliMax = owner:getAttr("neiliMax") -- 内力
        end

        if varNameMap["currint"] then
            params.currint = owner:getFinalAttr("int") + owner:getFinalAttr("secInt") -- 有效悟性
        end
        if varNameMap["currcon"] then
            params.currcon = owner:getFinalAttr("con") + owner:getFinalAttr("secCon") -- 有效根骨
        end
        if varNameMap["currstr"] then
            params.currstr = owner:getFinalAttr("str") + owner:getFinalAttr("secStr") -- 有效臂力
        end
        if varNameMap["currdex"] then
            params.currdex = owner:getFinalAttr("dex") + owner:getFinalAttr("secDex")
        end

        if varNameMap["qimax"] then
            params.qimax = owner:getFinalAttr("qiMax") -- 气血最大值
        end

        params.qiMax2 = qiMax2 -- 目标气血最大值
        params.avgqiatk = avgQiAtk -- 平均气血伤害

        if varNameMap["qi"] then
            params.qi = owner:getAttr("qi") -- 当前气血
        end

        if varNameMap["qi2"] then
            if object then
                qi2 = object:getAttr("qi") -- 目标当前气血
            end

            params.qi2 = qi2
        end

        if varNameMap["neili2"] then
            if object then
                neili2 = object:getAttr("neili") -- 目标当前内力
            end

            params.neili2 = neili2
        end

        if varNameMap["neiliMax2"] then
            if object then
                neiliMax2 = object:getAttr("neiliMax") -- --目标内力上限
            end

            params.neiliMax2 = neiliMax2
        end

        if varNameMap["jqdamage"] then
            params.jqdamage = owner:getJqdamage()
        end

        if varNameMap["currjqdamage"] then
            params.currjqdamage = 0
            local activeZhao = self:getActiveZhao()
            if activeZhao then
                --兵器为0
                if activeZhao:checkTypeIsZhaoMethods(5) then
                    params.currjqdamage = 0
                elseif activeZhao:checkTypeIsZhaoMethods(SKILL_METHOD_TYPE_QUANJIAO) then
                    local activeId = activeZhao:getId()
                    if owner:checkIsPrepSkillZhao(activeId) then
                        params.currjqdamage = owner:getPrepJqdamage()
                    elseif owner:checkIsStandBySkillZhao(activeId) then
                        params.currjqdamage = owner:getStandByJqdamage()
                    end
                else
                    params.currjqdamage = owner:getPrepJqdamage()    
                end
            else
                params.currjqdamage = self:getEffectExtraValue()
            end
        end

        if varNameMap["saveDamage"] then
            params.saveDamage = owner:getAttr("saveDamage")
        end
        if varNameMap["saveDamageMax"] then
            params.saveDamageMax = owner:getSaveDamageMax()
        end
        if varNameMap["despairForce"] then
            params.despairForce = owner:getDespairForce()
        end

        if varNameMap["damageToHurt"] then
            params.damageToHurt = owner:getAttr("damageToHurt")
        end

        if varNameMap["nengGongRecoverNeiLiFactor"] then
            params.nengGongRecoverNeiLiFactor = owner:getRole():getSkillFactor("neigong", "neili")
        end

        if varNameMap["zhengqi"] then
            params.zhengqi = owner:getFinalAttr("zhengqi")
        end 
        
        params.W1 = W1
        -- 攻方（自己）武器的重量
        params.W2 = W2
        --守方（目标）武器的重量
        params.RD1 = RD1
        -- 攻方（自己）武器的韧度
        params.RD2 = RD2
        --守方（目标）武器的韧度
        params.YD1 = YD1
        -- 攻方（自己）武器的硬度
        params.YD2 = YD2
        --守方（目标）武器的硬度
        params.K1 = K1
        --攻方（自己）招架的武功的等级
        params.K2 = K2
        --守方（目标）招架的武功的等级
        params.CN = CN
        --自己的装备的神兵的成功淬炼次数
        params.dssklv = dssklv -- 自己的毒术技能
        params.szjLv = szjLv --神照经等级
        params.CSJYIN = CSJYIN --长生诀阴等级
        params.dkxgLv = dkxgLv --丹匮玄功等级
        params.wdamage = wdamage --自己武器伤害力
        params.wdamage2 = wdamage2 --对方武器伤害力
		params.wyindu = wyindu
		params.wyindu2 = wyindu2
		params.wrendu = wrendu
		params.wrendu2 = wrendu2
		params.wweight = wweight
		params.wweight2 = wweight2
        params.looks = looks -- 容貌
        params.roleLv = roleLv -- 角色等级
        params.zgxjLv = zgxjLv -- 振槁玄经等级
        params.jing = jing --角色精力值
        params.jingMax = jingMax --角色精力最大值
        params.buff1Num = buff1Num
        params.buff2Num = buff2Num
        params.buff3Num = buff3Num
        params.buff4Num = buff4Num
    end

    -- 所属主动招式参数
    do
        if varNameMap["cost"] then
            local activeZhao = self:getActiveZhao()

            local cost = 1
            if activeZhao then
                cost = activeZhao:getFinalCost()
            end

            params.cost = cost
        -- 技能消耗
        end

        local zargs = self:getZArgs()
        if zargs then
            for i, v in ipairs(zargs) do
                params["z" .. i] = v
            end
        end
    end

    local ret = Helper:GetValueFromScript(value, params)

    LogSystem:log("旧版效果参数","-----------------------------主动效果参数开始-----------------------------")
    LogSystem:log("旧版效果参数","-----------------------------","效果Id:",self:getId(),"-----------------------------")
    for k, v in pairs(params) do
        if varNameMap[k] then
            LogSystem:log("旧版效果参数",k," = ",v)
        end
    end
    LogSystem:log("旧版效果参数","-----------------------------主动效果参数结束-----------------------------")

    return ret
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/03/02 11:44:22
-- @desc 得到运算后的arg1
function SkillEffect:getFinalArg1()
    return self:getValueWithCalc(self:getArg1())
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/03/02 11:46:08
-- @desc 得到运算后的arg2
function SkillEffect:getFinalArg2()
    return self:getValueWithCalc(self:getArg2())
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/03/02 11:46:08
-- @desc 得到运算后的arg3
function SkillEffect:getFinalArg3()
    return self:getValueWithCalc(self:getArg3())
end

-----------------------------------------------------------------------------------------------------------
--@desc: 得到运算后的arg4
--@author:LvBin
--@time:2026-01-14 15:54:25
--@return 
function SkillEffect:getFinalArg4()
    return self:getValueWithCalc(self:getArg4())
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/03/07 16:03:51
-- @desc 得到最终持续时间
function SkillEffect:getFinalDuration()
    if self.finalDuration then
        return self.finalDuration
    end
    self.finalDuration = self:getValueWithCalc(self:getDuration()) * 30
    return self.finalDuration
end

-- @desc 得到运算后的arg3
function SkillEffect:getFinalDelayTime()
    return self:getValueWithCalc(self:getDelayTime())
end

-- @desc 得到运算后的生效几率
function SkillEffect:getFinalTruerate()
    if type(self:getTruerate()) == "number" then
        return self:getTruerate()
    end

    local zargs = self:getZArgs()
    local paramList = {}
    if zargs then
        for i, v in ipairs(zargs) do
            paramList["z" .. i] = v
        end
    end
    return Helper:GetValueFromScript(self:getTruerate(), paramList)
end
-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/03/07 15:30:13
-- @desc 得到属性颜色
function SkillEffect:getPropertyColor()
    local color =
        switch(
        self:getProperty(),
        {
            ["外功"] = function()
                return cc.c4b(255, 255, 255, 255)
            end,
            ["阳性"] = function()
                return cc.c4b(175, 145, 25, 255)
            end,
            ["阴性"] = function()
                return cc.c4b(49, 132, 155, 255)
            end,
            ["混元"] = function()
                return cc.c4b(198, 217, 248, 255)
            end,
            ["毒性"] = function()
                return cc.c4b(250, 0, 255, 255)
            end,
            ["加血"] = function()
                return cc.c4b(51, 153, 51, 255)
            end,
            ["加内"] = function()
                return cc.c4b(28, 76, 163, 255)
            end,
            default = function()
                return cc.c4b(255, 255, 255, 255)
            end
        }
    )
    return color
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/03/08 17:41:15
-- @desc 得到文字颜色
function SkillEffect:getNumberColor()
    if self:getArg1() == "qi" and self:getFinalArg2() > 0 then
        return cc.c4b(51, 153, 51, 255)
    elseif self:getArg1() == "neili" then -- 减内力和加内力同一个颜色 add by TangJian 2017/03/10 16:43:07
        return cc.c4b(28, 76, 163, 255)
    end

    local color =
        switch(
        self:getProperty(),
        {
            ["外功"] = function()
                return cc.c4b(255, 255, 255, 255)
            end,
            ["阳性"] = function()
                return cc.c4b(175, 145, 25, 255)
            end,
            ["阴性"] = function()
                return cc.c4b(49, 132, 155, 255)
            end,
            ["混元"] = function()
                return cc.c4b(198, 217, 248, 255)
            end,
            ["毒性"] = function()
                return cc.c4b(250, 0, 255, 255)
            end,
            ["加血"] = function()
                return cc.c4b(51, 153, 51, 255)
            end,
            ["加内"] = function()
                return cc.c4b(28, 76, 163, 255)
            end,
            default = function()
                return cc.c4b(255, 255, 255, 255)
            end
        }
    )
    return color
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/03/13 17:33:39
-- @desc 得到角色头顶弹出描述
function SkillEffect:getRoleTopPopDesc(arg1, arg2)
    local attrName = Role:getCHAttrName(arg1)
    local text
    if attrName then
        if arg1 == "neili" then
            if arg2 >= 0 then
                text = attrName .. " + " .. arg2
            else
                text = attrName .. " - " .. math.abs(arg2)
            end
        else
            if arg2 > 0 then
                text = " + " .. arg2
            elseif arg2 == 0 then
            else
                text = " - " .. math.abs(arg2)
            end
        end
    end
    return text
end

--获得效果类型数组
function SkillEffect:getEffectTypeArray()
    local effectType = self:getEffectType()
    local effectTypeArray = string.split(effectType, ";")
    return effectTypeArray
end

--检查效果是否属于指定类型
function SkillEffect:checkHaveEffectType(effectType)
    if effectType == nil or tonumber(effectType) == nil then
        return false
    end
    local effectTypeArray = self:getEffectTypeArray()
    for i, v in ipairs(effectTypeArray) do
        if tonumber(v) == tonumber(effectType) then
            return true
        end
    end

    return false
end

--@desc: 获取效果功能对象
--@author:LvBin
--@time:2023-03-10 16:17:34
--@effect: 
--@return
function SkillEffect:getEffectObject(fightRole)
    local effectObject = EffectFactory:create(self)
    effectObject:setPlayer(fightRole)
    return effectObject
end

function SkillEffect:getEffectMarkIdList()
    local EffectConst = require("app.models.fight.Effect.EffectConst") 

    return string.split(EffectConst:getConstById("effectMarkIdList"), "#")
end

--@desc: 记录吸收伤害数值(目前只有护盾效果用到了)
--@author:LvBin
--@time:2024-05-08 15:25:28
--@damage: 伤害值
--@return
function SkillEffect:addAbsorbDamage(damage)
    if self.__absorbDamage == nil then
        self.__absorbDamage = 0
    end
    self.__absorbDamage = self.__absorbDamage + damage
end

--@desc: 获取效果吸收的伤害数值(目前只有护盾效果用到了)
--@author:LvBin
--@time:2024-05-08 15:25:20
--@return
function SkillEffect:getAbsorbDamage()
    if self.__absorbDamage == nil then
        self.__absorbDamage = 0
    end
    return self.__absorbDamage
end

return SkillEffect
00