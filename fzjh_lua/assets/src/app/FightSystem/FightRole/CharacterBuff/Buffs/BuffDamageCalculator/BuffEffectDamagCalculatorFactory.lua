local BuffEffectDamageDataMap = require("script.newbattle.demo.buffDamage")["Buff效果伤害"]

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local BuffEffectDamageCalculatorFactory = {}

--@desc: 创建BuffEffectDamageCalculator对象
--author:TangJian
--time:2021-11-16 11:04:45
--@buffEffectDamageId: 增益效果伤害编号
--@buff: [src.app.FightSystem.FightRole.CharacterBuff.Buffs.BasicFightCharacterBuff#BasicFightCharacterBuff]
--@return [src.app.FightSystem.FightRole.CharacterBuff.Buffs.BuffDamageCalculator.ABuffEffectDamageCalclator#ABuffEffectDamageCalclator]
function BuffEffectDamageCalculatorFactory:create(buffEffectDamageId, buff)
    local buffEffectDamageData = assert(BuffEffectDamageDataMap[buffEffectDamageId], "找不到id buffEffectDamageId == " .. tostring(buffEffectDamageId))

    print("BuffEffectDamageCalculatorFactory:create buffEffectDamageId = ", buffEffectDamageId)
    local calculator =
        switch(
        buffEffectDamageData.computingType,
        {
            [0] = function()
                return require("app.FightSystem.FightRole.CharacterBuff.Buffs.BuffDamageCalculator.BuffEffectDamageCalculator0").new()
            end,
            [1] = function()
                return require("app.FightSystem.FightRole.CharacterBuff.Buffs.BuffDamageCalculator.BuffEffectDamageCalculator1").new()
            end,
            [2] = function()
                return require("app.FightSystem.FightRole.CharacterBuff.Buffs.BuffDamageCalculator.BuffEffectDamageCalculator2").new()
            end,
            [3] = function()
                return require("app.FightSystem.FightRole.CharacterBuff.Buffs.BuffDamageCalculator.BuffEffectDamageCalculator3").new()
            end,
            default = function()
                error("找不到buffEffectDamageData.computingType:", buffEffectDamageData.computingType)
            end
        }
    )

    calculator:initCalclator(buffEffectDamageData, buff)
    return calculator
end

return BuffEffectDamageCalculatorFactory
000000000000000