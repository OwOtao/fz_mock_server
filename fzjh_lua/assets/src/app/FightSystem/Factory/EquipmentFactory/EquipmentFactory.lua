--@RefType [BattleConstConf]
local BattleConstConf = require("app.FightSystem.Configuration.BattleConstConf")

local WeaponTypesResManager = require("app.FightSystem.FightRole.CharacterEquipment.WeaponTypesResManager")

local RegularWeapon = require("app.FightSystem.FightRole.CharacterEquipment.RegularWeapon")

local ShenBingWeapon = require("app.FightSystem.FightRole.CharacterEquipment.ShenBingWeapon")

local RegularArmor = require("app.FightSystem.FightRole.CharacterEquipment.RegularArmor")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local WeaponCommenceRes = require("script.newbattle.demo.WeaponCommence")["Sheet1"]

local sortWeaponCommenceRes = function()
    local list = {}
    for k, v in pairs(WeaponCommenceRes) do
        table.insert(list, v)
    end

    table.sort(
        list,
        function(a, b)
            return a.limit < b.limit
        end
    )

    WeaponCommenceRes = list
end

sortWeaponCommenceRes()

local EquipmentFactory = {}

--@desc: 随机完好度系数
--@author:Seven
--@time:2022-01-20 20:02:25
--@commence: 完好度
local function getRandomCommenceFactor(commence)
    local res
    for i, v in ipairs(WeaponCommenceRes) do
        if commence >= v.limit then
            res = v
        end
    end

    if res == nil then
        error("随机兵器完好度系数错误，当前完好度：" .. tostring(commence))
    end

    local randMin = res.randMin * 10
    local randMax = res.randMax * 10

    local randValue = FightUtil:random(randMin, randMax) / 10

    return randValue
end

--@desc: 创建武器
--@author:Seven
--@time:2021-06-29 20:42:16
--@itemId: 物品id
--@return [src.app.FightSystem.FightRole.CharacterEquipment.RegularWeapon#RegularWeapon]
function EquipmentFactory:createWeaponWithItemId(itemId)
    local weaponTypeResId = WeaponTypesResManager:getWeaponResId(itemId)

    --@RefType [src.app.FightSystem.FightRole.CharacterEquipment.RegularWeapon#RegularWeapon]
    local c_weapon = RegularWeapon:create(weaponTypeResId)

    local item = Item:getOneItemByKey(itemId)

    --@desc 纯随机
    c_weapon:setId(FightUtil:random(10000, 12000))

    c_weapon:setItemId(itemId)

    c_weapon:setDamage(Helper:getDef(item.damage, 0))

    c_weapon:setProtect(Helper:getDef(item.protect, 0))

    c_weapon:setWeight(Helper:getDef(item.weight, 0))

    c_weapon:setTenacity(Helper:getDef(item.rendu, 0))

    c_weapon:setHardnessValue(Helper:getDef(item.yindu, 0))

    c_weapon:setCommence(Helper:getDef(item.wanhaodu, 100))

    c_weapon:setCommenceFactor(getRandomCommenceFactor(Helper:getDef(item.wanhaodu, 100)))

    c_weapon:setFlyWeapon(item:getFlyWeapon())

    c_weapon:setBeflyWeapon(item:getBeFlyWeapon())

    c_weapon:setBreakWeapon(item:getBreakWeapon())

    c_weapon:setBrokenWeapon(item:getBrokenWeapon())

    c_weapon:setName(item.name)

    return c_weapon
end

function EquipmentFactory:createWeaponWithItem(id, item)
    local weaponTypeResId = WeaponTypesResManager:getWeaponResIdByItem(item)

    --@RefType [src.app.FightSystem.FightRole.CharacterEquipment.RegularWeapon#RegularWeapon]
    local c_weapon = RegularWeapon:create(weaponTypeResId)

    c_weapon:setId(id)

    c_weapon:setItemId(item.id)

    c_weapon:setDamage(Helper:getDef(item.damage, 0))

    c_weapon:setProtect(Helper:getDef(item.protect, 0))

    c_weapon:setWeight(Helper:getDef(item.weight, 0))

    c_weapon:setTenacity(Helper:getDef(item.rendu, 0))

    c_weapon:setHardnessValue(Helper:getDef(item.yindu, 0))

    c_weapon:setCommence(Helper:getDef(item.wanhaodu, 100))

    c_weapon:setCommenceFactor(getRandomCommenceFactor(Helper:getDef(item.wanhaodu, 100)))

    c_weapon:setFlyWeapon(item:getFlyWeapon())

    c_weapon:setBeflyWeapon(item:getBeFlyWeapon())

    c_weapon:setBreakWeapon(item:getBreakWeapon())

    c_weapon:setBrokenWeapon(item:getBrokenWeapon())

    c_weapon:setName(item.name)

    return c_weapon
end

--创建神兵
function EquipmentFactory:createShenBingWeaponWithItem(id, itemTemplate, buffArray, buffLauncherIdList)
    local weaponTypeResId = WeaponTypesResManager:getWeaponResIdByTypeAndType2(itemTemplate.type, itemTemplate.type2)

    --@RefType [src.app.FightSystem.FightRole.CharacterEquipment.RegularWeapon#RegularWeapon]
    local c_weapon = ShenBingWeapon:create(weaponTypeResId)

    c_weapon:setId(id)

    c_weapon:setItemId(itemTemplate.id)

    c_weapon:setDamage(Helper:getDef(itemTemplate.damage, 0))

    c_weapon:setProtect(Helper:getDef(itemTemplate.protect, 0))

    c_weapon:setCommence(Helper:getDef(itemTemplate.wanhaodu, 100))

    c_weapon:setCommenceFactor(getRandomCommenceFactor(Helper:getDef(itemTemplate.wanhaodu, 100)))

    c_weapon:setCuilianCount(itemTemplate.cuilianCount)

    c_weapon:setWeight(itemTemplate.weight)

    c_weapon:setTenacity(itemTemplate.rendu)

    c_weapon:setHardnessValue(itemTemplate.yindu)

    c_weapon:setName(itemTemplate.name)

    c_weapon:setFlyWeapon(itemTemplate.flyWeapon)

    c_weapon:setBeflyWeapon(itemTemplate.beflyWeapon)

    c_weapon:setBreakWeapon(itemTemplate.breakWeapon)

    c_weapon:setBrokenWeapon(itemTemplate.brokenWeapon)

    c_weapon:setBuffArray(self:__getWeaponBuffInfos(buffArray))

    c_weapon:setBuffAdderGroupIds(buffLauncherIdList)

    return c_weapon
end

function EquipmentFactory:__getWeaponBuffInfos(buffArray)
    local buffInfos = {}
    if table.getn(buffArray) > 0 then
        for i, normalBuff in ipairs(buffArray) do
            table.insert(
                buffInfos,
                {
                    addBuffID = normalBuff.addBuffID,
                    argMap = {
                        dynamicArg1 = normalBuff.addBuffdynamicArg1,
                        dynamicArg2 = normalBuff.addBuffdynamicArg2,
                        dynamicArg3 = normalBuff.addBuffdynamicArg3,
                        dynamicArg4 = normalBuff.addBuffdynamicArg4
                    }
                }
            )
        end
    end

    return buffInfos
end

function EquipmentFactory:createShenBingWeaponWithTemplateId(tempId)
    local ShenBingRes = require("app.models.ShenBing.ShenBingRes")

    local ShenBingEffct = require("app.models.ShenBing.ShenBingEffct")

    local tempRes = ShenBingRes:getShenBingTemplateData(tempId)

    local resId = WeaponTypesResManager:getWeaponResIdByTypeAndType2(tempRes.type, tempRes.bType)

    --@RefType [src.app.FightSystem.FightRole.CharacterEquipment.RegularWeapon#RegularWeapon]
    local c_weapon = ShenBingWeapon:create(resId)

    --@desc 纯随机
    c_weapon:setId(FightUtil:random(10000, 12000))

    c_weapon:setItemId(tempId)

    c_weapon:setDamage(Helper:getDef(tempRes.damage, 0))

    c_weapon:setProtect(Helper:getDef(tempRes.protect, 0))

    c_weapon:setCuilianCount(tempRes.cuilianCount)

    c_weapon:setWeight(tempRes.weight)

    c_weapon:setTenacity(tempRes.rendu)

    c_weapon:setHardnessValue(tempRes.yindu)

    c_weapon:setName(tempRes.name)

    c_weapon:setFlyWeapon(tempRes.flyWeapon)

    c_weapon:setBeflyWeapon(tempRes.beflyWeapon)

    c_weapon:setBreakWeapon(tempRes.breakWeapon)

    c_weapon:setBrokenWeapon(tempRes.brokenWeapon)

    local buffArray = ShenBingEffct:getFightBuffArray(tempRes) -- 战斗常态buff
    c_weapon:setBuffArray(self:__getWeaponBuffInfos(buffArray))

    local buffLauncherIdList = ShenBingEffct:getBuffLauncherIdList(tempRes) -- 战斗buff添加器列表

    c_weapon:setBuffAdderGroupIds(buffLauncherIdList)

    return c_weapon
end

--@desc: 创建空手武器
--@author:Seven
--@time:2021-06-29 20:42:35
function EquipmentFactory:createEmptyHandWeapon()
    local weaponTypeResId = BattleConstConf:get("emptyHandedId")
    --@RefType [src.app.FightSystem.FightRole.CharacterEquipment.RegularWeapon#RegularWeapon]
    local c_weapon = RegularWeapon:create(weaponTypeResId)

    c_weapon:setName("拳脚")

    --@desc 纯随机
    c_weapon:setId(FightUtil:random(10000, 12000))

    return c_weapon
end

--@desc: 创建防具
--@author:Seven
--@time:2021-06-30 18:02:43
--@itemId: 物品id
function EquipmentFactory:createArmor(itemId)
    local item = Item:getOneItemByKey(itemId)

    --@RefType [src.app.FightSystem.FightRole.CharacterEquipment.RegularArmor#RegularArmor]
    local armor = RegularArmor:create()

    armor:setName(item.name)

    armor:setProtect(Helper:getDef(item.protect, 0))

    return armor
end

return EquipmentFactory
000000000