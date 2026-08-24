local LogSystem = require("app.models.LogSystem.LogSystem")
local oldPrint = print
local function print(...)
    LogSystem:log("增益日志.Effect:", ...)
end

local Constants = require("app.FightSystem.FightBuff.Constants")
local Desc = require("app.FightSystem.FightBuff.Desc")
local BuffConf = require("app.FightSystem.Configuration.BuffConf")
local ZhaoHurtDegreeFactory = require("app.FightSystem.Factory.FightSkillFactory.ZhaoHurtDegreeFactory")
local BuffEffectDamageCalculatorFactory = require("app.FightSystem.FightBuff.BuffEffectDamageCalculator.BuffEffectDamagCalculatorFactory")

local NewCalss = require("third.class.NewClass")

local Effect = {}

function Effect:create(data)
    local p = Effect.new(data)
    p:__init()
    return p
end

function Effect:__init()
    self.argsParam = string.split(self.argsParam, "#")
    self.effectTypeParam = string.split(self.effectTypeParam, "#")
end

function Effect:getId()
    return self.id
end

function Effect:getEffectId()
    return self.effectID
end
function Effect:getEffectType()
    return self.effectType
end

function Effect:getStackType()
    return Constants.EffectSackTypeMap[self.effectType]
end

function Effect:getEffectTypeParam()
    return self.effectTypeParam
end

function Effect:getArgsParam()
    return self.argsParam
end

function Effect:getRoleState()
    local buffEffectAppearence = BuffConf:getBuffEffectAppearence(self.effectID)
    return buffEffectAppearence.idleExpression, buffEffectAppearence.idleSort
end

function Effect:getRoleHurtState()
    local buffEffectAppearence = BuffConf:getBuffEffectAppearence(self.effectID)
    return buffEffectAppearence.hurtExpression, buffEffectAppearence.hurtSort
end

function Effect:getRoleHeadText()
    local buffEffectAppearence = BuffConf:getBuffEffectAppearence(self.effectID)
    return buffEffectAppearence.activeEffectRoleHeadText, buffEffectAppearence.activeEffectRoleHeadTextSort
end

-- 获取护盾动画和优先级
function Effect:getRoleShieldAnimIdAndPriority()
    local buffEffectAppearence = BuffConf:getBuffEffectAppearence(self.effectID)
    return buffEffectAppearence.activeEffectRoleShield, buffEffectAppearence.activeEffectRoleShieldSort
end

function Effect:getRoleFeetHaloAnimIdAndPriority()
    local buffEffectAppearence = BuffConf:getBuffEffectAppearence(self.effectID)
    if buffEffectAppearence and buffEffectAppearence.activeEffectRoleFeetHalo and buffEffectAppearence.activeEffectRoleFeetHaloSort then
        return buffEffectAppearence.activeEffectRoleFeetHalo, buffEffectAppearence.activeEffectRoleFeetHaloSort
    end
    return nil
end

function Effect:getRolePopText()
    return self.activeEffectRolePop
end

function Effect:getActiveEffectHurtRolePop()
    return self.activeEffectHurtRolePop
end

function Effect:getActiveEffectAtkRolePop()
    return self.activeEffectAtkRolePop
end

function Effect:isBanAutoZhao()
    return self.effectType == Constants.EffectType.BanAutoZhao
end

function Effect:isBanActiveZhao()
    return self.effectType == Constants.EffectType.BanActiveZhao
end

function Effect:isBanQingGongDodge()
    return self.effectType == Constants.EffectType.BanQinggongDodge
end

function Effect:isBanNormalParry()
    return self.effectType == Constants.EffectType.BanNormalParry
end

function Effect:isRandomBaseAutoZhao()
    return self.effectType == Constants.EffectType.RandomBaseAutoZhao
end

-- 获取描述
function Effect:getActiveDesc()
    return self.activeEffectDesc
end

function Effect:getActiveEffectOwnRolePop()
    return self.activeEffectOwnRolePop
end

function Effect:getZhaoComboDirectDamgeDesc()
    return self.zhaoComboDirectDamgeDesc
end

function Effect:getActiveEffectUseZhaoTips()
    return self.activeEffectUseZhaoTips
end

function Effect:getDamage(effectId, buffNeeded)
    return BuffEffectDamageCalculatorFactory:create(effectId, buffNeeded):getDamage()
end

return NewCalss("Effect", {}, Effect)
00