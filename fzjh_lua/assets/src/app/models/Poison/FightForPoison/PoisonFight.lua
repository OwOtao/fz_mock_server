local PoisonFight = {}
--@RefType [app.models.Poison.PoisonUtil#PoisonUtil]
local PoisonUtil = require("app.models.Poison.PoisonUtil")
--@RefType [app.models.Poison.Poison#Poison]
local Poison = require("app.models.Poison.Poison")

local skillEffectMap = require("script.skill.activeZhao").Effect

--@desc: 战斗初始化时给角色创建毒药属性结构
--@author:Liang SongQiang
--@time:2018-01-21 20:37:02
--@role: [app.models.fight.FightRole#FightRole]
function PoisonFight:fightInit(role)
    if role._role.teamId == 1 then
        self:initForPlayer(role)
    elseif role._role.teamId == 2 then
        self:initForNpc(role)
    end
end

--@desc: 战斗初始化时给角色创建毒药属性结构
function PoisonFight:pvpFightInit(role)
    self:initForPlayer(role)
end


--@desc: 给NPC创建毒药属性结构
--@author:Liang SongQiang
--@time:2018-01-21 20:38:03
--@role: [app.models.fight.FightRole#FightRole]
function PoisonFight:initForNpc(role)
    local poisonId = role._role.poisonId

    --@desc NPC如果没有装备武器，直接返回
    if not role._role.equips.weapon then
        return
    end

    --@desc NPC如果没有毒药字段，直接返回
    if not poisonId then
        return
    end

    role._poisonEffectArray = {}

    local poison = Item:getOneItemByKey(poisonId)

    local effectMapArray = Poison:getEffectByPId(poisonId)

    --@desc 生效机率
    local effect_rate = poison.effect_rate
    local add_rate = poison.add_rate

    --@desc 这场战斗中是否生效，0为未生效，1为已生效，一场战斗中只能生效一次
    local isTake = 0

    local skillLv = role._role.pSkillLv
    if not skillLv then
        assert(false, role:getId() .. "配置了毒药，没有配置毒术等级。请检查资源。")
        return
    end

    local angry_text = poison.angry_text

    local poisonEffect = {
        id = poisonId,
        effect_rate = effect_rate,
        add_rate = add_rate,
        isTake = isTake,
        skillLv = skillLv,
        effects = effectMapArray,
        angry_text = angry_text,
        fight_text = poison.text,
        weaponItemId = role._role.equips.weapon.itemId,
        --@desc npc身法，直接获取
        dex = role._role.dex,
        canUse = true
    }

    table.insert(role._poisonEffectArray, poisonEffect)
end

--@desc: 给玩家创建毒药属性结构
--@author:Liang SongQiang
--@time:2018-01-21 20:39:08
--@role: [app.models.fight.FightRole#FightRole]
function PoisonFight:initForPlayer(role)
    --@RefType [app.models.role.Role#Role]
    local player = role._role

    role._poisonEffectArray = {}

    local weaponData = player:getEquipByName("weapon")

    --@desc 如果没有装备武器，直接返回
    if not weaponData then
        return
    end

    local playerPoison = PoisonUtil:getPoisonOnWeapon(weaponData.id,player)
    if MapIsEmpty(playerPoison) then
        return
    end
    local poisonId = playerPoison.poisonId
    local poison = Item:getOneItemByKey(poisonId)

    local effectMapArray = Poison:getEffectByPId(poisonId)

    --@desc 侠义值
    local xiayi = poison.xiayi

    --@desc 生效机率
    local effect_rate = poison.effect_rate
    local add_rate = poison.add_rate

    --@desc 此武器上战斗所剩余次数
    local fightCount = weaponData.fightCount

    --@desc 这场战斗中是否生效，0为未生效，1为已生效，一场战斗中只能生效一次
    local isTake = 0

    local angry_text = poison.angry_text

    local skillId = Poison:getPoisonSkillById(poisonId)

    local skillLv = player:getSkillLv(skillId)

    local poisonEffect = {
        id = poisonId,
        xiayi = xiayi,
        effect_rate = effect_rate,
        add_rate = add_rate,
        fightCount = fightCount,
        isTake = isTake,
        skillLv = skillLv,
        effects = effectMapArray,
        angry_text = angry_text,
        fight_text = poison.text,
        weaponItemId = weaponData.itemId,
        weaponIndex = weaponData.id,
        --@desc 等效身法
        dex = player:getEffectDex(),
        canUse = true,
    }

    table.insert(role._poisonEffectArray, poisonEffect)
end

--@desc: 如果角色中毒了，把效果ID保存到角色身上
--@author:Liang SongQiang
--@time:2018-01-25 16:13:08
--@role:[app.models.fight.FightRole#FightRole]
function PoisonFight:addPoisonEffectToRole(role, effectId)
    if not role.__poisonList then
        role.__poisonList = {}
    end
    role.__poisonList[effectId] = true
end

--@desc: 移除角色身上中毒所带来的效果
--@author:Liang SongQiang
--@time:2018-01-25 16:21:29
--@role: [app.models.fight.FightRole#FightRole]
function PoisonFight:removePoisonEffectFromRole(role, effectId)
    if not role.__poisonList then
        print("角色身上没有中毒所带来的效果！")
        return
    end

    if not role.__poisonList[effectId] then
        print(effectId .. "效果不是中毒所带来的")
        return
    end

    role.__poisonList[effectId] = nil
end

local popText = {
    "卑鄙，竟然用毒！",
    "这什么毒……",
    "有毒！鼠辈敢尔！",
    "大胆，竟然用毒！",
    "可恶！竟然使毒！"
}
--@desc: 获取弹出文本
--@author:Liang SongQiang
--@time:2018-01-25 17:26:46
function PoisonFight:getPopText()
    local index = math.random(1, #popText)
    return popText[index]
end

--@desc: 毒药效果能否生效
function PoisonFight:canAddAboutPoisonEffect(target,effect)
    if effect:checkHaveEffectType(EFFECT_TYPE_POISON) and target:isKangDu() then
        return false
    end
    return true
end

function PoisonFight:changeWeapon(fightRole,isPvp)
    if isPvp == true then
        self:pvpFightInit(fightRole)
    else
        self:fightInit(fightRole)
    end
end

return PoisonFight
0000000000000000