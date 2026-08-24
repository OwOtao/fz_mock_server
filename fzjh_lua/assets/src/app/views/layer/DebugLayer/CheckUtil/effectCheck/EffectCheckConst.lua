local EffectCheckConst = {}

--需要检测的效果类型， -1代表不用检测
EffectCheckConst.EffectType = {
    ["被动命中触发"] = "PassiveHitTrigger",
    ["标记触发"] = "TagTrigger",
    ["储伤"] = "SaveDamage",
    ["储伤失效"] = -1,
    ["打掉兵器"] = "Disarm",
    ["单次伤害上限"] = "MaxSingleDamage",
    ["反弹"] = "DamageRebound",
    ["反伤"] = "DamageReflection",
    ["反噬"] = "Backfire",
    ["反震"] = "ParryDamageRebound",
    ["护盾"] = "Shield",
    ["恢复修正"] = "RecoveryCorrection",
    ["汲取"] = "NeiLiAbsorb",
    ["记录承受伤害"] = "RecordDamage",
    ["架势"] = "NeiLiStance",
    ["架御"] = "QiStance",
    ["监控角色属性"] = "AttrMonitor",
    ["角色立即死亡"] = -1,
    ["截脉"] = -1,
    ["解控"] = "Decontrol",
    ["禁锢"] = "Imprison",
    ["经脉天赋修正"] = "MeridianEffectCorrection",
    ["净化"] = "Purge",
    ["抗毒"] = "AntiPoison",
    ["抗减益"] = "AntiDebuff",
    ["抗增益"] = "AntiBuff",
    ["可取回缴械"] = -1,
    ["控制"] = "Control",
    ["类型抵抗"] = "AntiType",
    ["类型驱散"] = "TypeDisperse",
    ["类型转移"] = "TypeTransfer",
    ["冷却变化"] = "CooldownChange",
    ["免疫控制"] = "ImmuneControl",
    ["内伤"] = "NeiliDamage",
    ["内省"] = "NeiliSave",
    ["凝血"] = "Cruor",
    ["偏转"] = "Deflection",
    ["平衡"] = "Balance",
    ["破招"] = "Counter",
    ["强招架"] = "HeavyParry",
    ["窃取"] = "Steal",
    ["拳脚经脉增强"] = "RaiseMeridianEffectOdds",
    ["拳脚武器切换"] = -1,
    ["闪避触发"] = "DodgeTrigger",
    ["闪烁"] = "DodgeAddNeiLi",
    ["闪耀"] = "DodgeAddQi",
    ["伤害抗性修正"] = "DamageResistanceCorrection",
    ["伤害转持续自伤"] = "DamageToHurt",
    ["伤害转气血"] = "DamageToQi",
    ["使用主动技能"] = "ActiveUseTrigger",
    ["受击触发"] = "HitTrigger",
    ["属性变化"] = "AttrChange",
    ["属性叠加"] = "AttrStacking",
    ["属性条件触发"] = "AttrConditionTrigger",
    ["属性增益"] = "AttrBuff",
    ["投掷"] = -1,
    ["无法攻击"] = -1,
    ["无法易武"] = -1,
    ["无指定效果时触发"] = "NoEffectTrigger",
    ["武器切换"] = -1,
    ["吸血"] = "QiAbsorb",
    ["效果关联"] = "EffectLink",
    ["效果切换"] = "EffectSwitch",
    ["卸力"] = "UnloadForce",
    ["修武"] = "AdjustWeapon",
    ["延宕"] = "DelayCooldown",
    ["延时生效"] = "DelayedEffect",
    ["遗忘"] = "Forget",
    ["易伤标记"] = "FragileTag",
    ["增伤标记"] = "AugmentTag",
    ["招架触发"] = "ParryTrigger",
    ["招架反击"] = -1,
    ["真罡"] = "ZhenGang",
    ["真伤"] = "TrueDamage",
    ["指定抵抗"] = "AntiEffect",
    ["指定驱散"] = "DisperseEffect",
    ["指定延宕"] = "SpecialDelayCooldown",
    ["加权随机触发"] = "WeightRandomTrigger",
    ["效果判断触发"] = "JudgmentTrigger",
    ["致盲"] = "Blinding",
    ["招架无效果触发"] = "ParryNoTrigger",
    ["准备武器触发"] = "WeaponPrepareTrigger",
    ["追加伤害"] = "AddDamage",
    ["主动碎盾"] = "ShieldBreak"
}

EffectCheckConst.EffectTargetValue = {
    Owner = "自己",
    Target = "目标"
}

EffectCheckConst.EffectList = {}

local function initEffectList()
    local skillEffectMap = require("script.skill.activeZhao").Effect
    for effectId, v in pairs(skillEffectMap) do
        EffectCheckConst.EffectList[effectId] = true
    end

    EffectCheckConst.EffectList["CHIXIE"] = true
    EffectCheckConst.EffectList["KONGSHOU"] = true
end

initEffectList()

return EffectCheckConst0000000000