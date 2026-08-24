local descRes = require("script.newbattle.demo.atkDamageDescRes")["命中伤害描述"]

local Desc = require("app.FightSystem.FightBuff.Desc")

local descOfTypeGroup = {}
local initDescResByType = function()
    for k, v in pairs(descRes) do
        local damageType = v.damageType

        local damageStage = v.damageStage

        if descOfTypeGroup[damageType] == nil then
            descOfTypeGroup[damageType] = {}
        end

        descOfTypeGroup[damageType][damageStage] = v

    end
end

initDescResByType()

local AttackDamageDescManager = {}

--@desc: 根据伤害描述填写值
--@author:Seven
--@time:2021-07-06 21:21:56
--@damageDesc: 伤害描述：“damageType#damageStage" 即”伤害类型#伤害程度“
--@return string
function AttackDamageDescManager:getDamageDescContent(damageType, damageStage)
    local damageGroup = descOfTypeGroup[damageType]

    if damageGroup == nil then
        assert(false, "AttackDamageDescManager:getDamageDesc 获取伤害描述对象,伤害类型错误：" .. damageType)
    end

    if damageStage == nil then
        assert(false, "AttackDamageDescManager:getDamageDesc 获取伤害描述程度,伤害程度不能为空")
    end

    local damageStageInfo = descOfTypeGroup[damageType][damageStage]

    if damageStageInfo == nil then
        assert(false, "AttackDamageDescManager:getDamageDesc 获取伤害描述程度,不存在 类型:" .. damageType .. ";伤害程度:" .. damageStage .. " 的内容。")
    end

    local content = descOfTypeGroup[damageType][damageStage].content

    return content
end

return AttackDamageDescManager
0000000000000000