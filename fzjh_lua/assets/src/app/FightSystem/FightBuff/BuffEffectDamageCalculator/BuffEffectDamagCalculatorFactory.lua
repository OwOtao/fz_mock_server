local BuffEffectDamageDataMap = require("script.newbattle.demo.buffDamage")["Buff效果伤害"]

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local BuffEffectDamageCalculatorFactory = {}

--[[
    @desc: 创建BuffEffectDamageCalculator对象
    author:TangJian
    time:2021-11-16 11:04:45
    --@buffEffectDamageId: 增益效果伤害编号
	--@buffNeeded: src.app.FightSystem.FightBuff.CustomBuffNeeded#CustomBuffNeeded
    @return: src.app.FightSystem.FightBuff.BuffEffectDamageCalculator.AbsBuffEffectDamageCalclator#AbsBuffEffectDamageCalclator
]]
function BuffEffectDamageCalculatorFactory:create(buffEffectDamageId, buffNeeded)
    local buffEffectDamageData = assert(BuffEffectDamageDataMap[buffEffectDamageId], "找不到id buffEffectDamageId == " .. tostring(buffEffectDamageId))

    print("BuffEffectDamageCalculatorFactory:create buffEffectDamageId = ", buffEffectDamageId)
    local calculator =
        switch(
        buffEffectDamageData.computingType,
        {
            [0] = function()
                return require("app.FightSystem.FightBuff.BuffEffectDamageCalculator.BuffEffectDamageCalculator0").new()
            end,
            [1] = function()
                return require("app.FightSystem.FightBuff.BuffEffectDamageCalculator.BuffEffectDamageCalculator1").new()
            end,
            [2] = function()
                return require("app.FightSystem.FightBuff.BuffEffectDamageCalculator.BuffEffectDamageCalculator2").new()
            end,
            [3] = function()
                return require("app.FightSystem.FightBuff.BuffEffectDamageCalculator.BuffEffectDamageCalculator3").new()
            end,
            default = function()
                error("找不到buffEffectDamageData.computingType:", buffEffectDamageData.computingType)
            end
        }
    )

    calculator:init(buffEffectDamageData, buffNeeded)
    return calculator
end

return BuffEffectDamageCalculatorFactory
000000