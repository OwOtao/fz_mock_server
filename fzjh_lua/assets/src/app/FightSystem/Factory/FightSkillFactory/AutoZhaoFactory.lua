--[[
    @TODO 2022-12-14 14:25:24 文件可删除
]]

local AutoZhaoFactory = {}

--@desc: 随机创建攻击招式
--@author:Seven
--@time:2021-06-25 17:19:26
--@character: [src.app.FightSystem.FightRole.FightCharacter#FightCharacter]
--@return [src.app.FightSystem.FightRole.AttackSystem.AutoSkill.AutoZhaoCombination#AutoZhaoCombination]
function AutoZhaoFactory:createAttackAutoZhaoComb(character)
    local attackSkill

    if character:isRandomBaseAutoZhao() then
        attackSkill = character:getBaseAttackSkill()
    else
        attackSkill = character:getAttackSkill()
    end

    local zhao_comb = attackSkill:getAttackComb()

    local AutoZhaoCombAttack = require("app.FightSystem.FightRole.AttackSystem.AutoSkill.AutoZhaoCombAttack")

    local zhaoCombAttack = AutoZhaoCombAttack:create(zhao_comb)

    return zhaoCombAttack
end

return AutoZhaoFactory
0000000000