--[[
    战斗中使用的武器类型
]]
local class = require("third.class.NewClass")

local WeaponTypesResManager = require("app.FightSystem.FightRole.CharacterEquipment.WeaponTypesResManager")

local IWeapon = require("app.FightSystem.FightRole.CharacterEquipment.IWeapon")

local IArmor = require("app.FightSystem.FightRole.CharacterEquipment.IArmor")

local ACarryBuffAddToCharacter = require("app.FightSystem.FightRole.CharacterBuff.Utils.ACarryBuffAddToCharacter")

local ICarryBuffProducer = require("app.FightSystem.FightRole.CharacterBuff.Utils.ICarryBuffProducer")

local FightCommons = require("app.FightSystem.FightCommons")

local BattleConstConf = require("app.FightSystem.Configuration.BattleConstConf")

local getFuncNameCache = {}

local RegularWeapon = {}

local RegularWeapon = {
    --@desc 对应玩家背包中的id，NPC随机生成
    __id = -1,
    __name = "",
    --@desc 物品表中的id
    __itemId = "",
    __fState = FightCommons.FIGHT_WEAPON_STATE.NORMAL,
    __resId = 10101,
    __typeRes = nil,
    --@desc 伤害力
    __damage = 0,
    --@desc 保护力
    __protect = 0,
    --@desc 坚韧度
    __tenacity = 0,
    --@desc 淬炼次数
    __cuilianCount = 0,
    --@desc 重量
    __weight = 0,
    --@desc 坚硬度
    __hardnessValue = 0,
    --@desc 完好度
    __commence = 100,
    --@desc 完好度系数
    __commenceFactor = 0,
    --@desc 损耗值
    __lossOfValue = 0
}

--@author:Seven
--@time:2021-05-29 16:49:47
--@return [src.app.FightSystem.FightRole.CharacterEquipment.RegularWeapon#RegularWeapon]
function RegularWeapon:create(resId)
    local p = RegularWeapon.new()
    p:init(resId)
    return p
end

function RegularWeapon:setUseCharacter(character)
    -- 正在使用武器的角色
    self.__useCharacter = character
end

function RegularWeapon:__getUseCharacterBuffAdderValue(attrName)
    if self.__useCharacter == nil then
        return 0
    end

    return self.__useCharacter:getBuffWeaponAddAttr(attrName)
end

function RegularWeapon:getWeaponAttr(name)
    local getFuncName = getFuncNameCache[name]
    if getFuncName == nil then
        getFuncName = string.format("get%s", string.gsub(name, "^%l", string.upper))
        getFuncNameCache[name] = getFuncName
    end
    if self[getFuncName] ~= nil then
        return self[getFuncName](self)
    end

    error(string.format("武器属性：%s 不支持读取或未定义", name))
end

function RegularWeapon:init(resId)
    self.__resId = resId
    self.__typeRes = WeaponTypesResManager:getWeaponInfo(self.__resId)
end

function RegularWeapon:setId(id)
    self.__id = id
end

function RegularWeapon:getId()
    return self.__id
end

function RegularWeapon:setItemId(itemId)
    self.__itemId = itemId
end

function RegularWeapon:getItemId()
    return self.__itemId
end

--@desc: 这是武器名称
--@author:Seven
--@time:2021-06-30 17:34:18
--@name: 武器名称
function RegularWeapon:setName(name)
    self.__name = name
end

--@desc: 获取武器名字
--@author:Seven
--@time:2021-06-30 17:32:52
function RegularWeapon:getName()
    return self.__name
end

function RegularWeapon:getWeaponResId()
    return self.__resId
end

--@desc: 武器所属动作模组
--@author:Seven
--@time:2021-05-29 16:12:03
function RegularWeapon:getWeaponModule()
    return self.__typeRes.weaponModule
end

--@desc: 武器动画皮肤
--@author:Seven
--@time:2021-05-29 16:11:48
--@return
function RegularWeapon:getWeaponSkin()
    return self.__typeRes.weaponSkin
end

--@desc: 武器对应的武学准备类型
--@author:Seven
--@time:2021-05-29 16:12:20
function RegularWeapon:getAutoChooseSkill()
    return self.__typeRes.autoChooseSkill
end

--[[
    @desc:获得武器一级类型
    author:唐健
    time:2021-07-06 16:08:31
    @return:
]]
function RegularWeapon:getFirstType()
    return self.__typeRes.firstType
end

function RegularWeapon:getSecondType()
    return self.__typeRes.secondTypeId
end

function RegularWeapon:getDamage()
    return self.__damage
end

function RegularWeapon:setDamage(value)
    self.__damage = value
end

--@desc: 获取保护力
--@author:Seven
--@time:2021-06-30 17:52:32
function RegularWeapon:getProtect()
    return self.__protect
end

--@desc: 设置防护力
--@author:Seven
--@time:2021-06-30 17:58:32
function RegularWeapon:setProtect(value)
    self.__protect = value
end

--@desc 坚韧度
function RegularWeapon:setTenacity(value)
    self.__tenacity = value
end

function RegularWeapon:getTenacity()
    local buffAdderValue = self:__getUseCharacterBuffAdderValue("tenacity")
    return self.__tenacity + buffAdderValue
end
--@desc 淬炼次数
function RegularWeapon:setCuilianCount(value)
    self.__cuilianCount = value
end

function RegularWeapon:getCuilianCount()
    return self.__cuilianCount
end
--@desc 重量
function RegularWeapon:setWeight(value)
    self.__weight = value
end

function RegularWeapon:getWeight()
    local buffAdderValue = self:__getUseCharacterBuffAdderValue("weight")
    return self.__weight + buffAdderValue
end
--@desc 坚硬度
function RegularWeapon:setHardnessValue(value)
    self.__hardnessValue = value
end

function RegularWeapon:getHardnessValue()
    local buffAdderValue = self:__getUseCharacterBuffAdderValue("hardnessValue")
    return self.__hardnessValue + buffAdderValue
end
--@desc 完好度
function RegularWeapon:setCommence(value)
    self.__commence = value

    if self.__commence <= 0 then
        self:updateFightState(FightCommons.FIGHT_WEAPON_STATE.DESTROY)
    end
end

function RegularWeapon:getCommence()
    return self.__commence
end
--@desc 损耗值
function RegularWeapon:setLossOfValue(value)
    self.__lossOfValue = value
end

function RegularWeapon:getLossOfValue()
    local debugParam_weaponDestroy_lossOfValue = BattleConstConf:get("debugParam_weaponDestroy_lossOfValue")
    return self.__lossOfValue + debugParam_weaponDestroy_lossOfValue
end

function RegularWeapon:getCommenceFactor()
    return self.__commenceFactor
end

function RegularWeapon:setCommenceFactor(value)
    self.__commenceFactor = value
end

function RegularWeapon:updateFightState(state)
    self.__fState = state
end

function RegularWeapon:getFightState()
    return self.__fState
end

function RegularWeapon:setFlyWeapon(value)
    self.__flyWeapon = value
end

function RegularWeapon:getFlyWeapon()
    if self.__flyWeapon == nil then
        self:setFlyWeapon(self.__typeRes.flyWeapon)
    end

    local defaultBuffValue = 1
    if self.__useCharacter then
        defaultBuffValue = self.__useCharacter:getBuffMinValue("flyWeapon", defaultBuffValue)
    end

    return math.min(self.__flyWeapon, defaultBuffValue)
end

function RegularWeapon:setBeflyWeapon(value)
    self.__beflyWeapon = value
end

function RegularWeapon:getBeflyWeapon()
    if self.__beflyWeapon == nil then
        self:setBeflyWeapon(self.__typeRes.beflyWeapon)
    end
    local defaultBuffValue = 1
    if self.__useCharacter then
        defaultBuffValue = self.__useCharacter:getBuffMinValue("beflyWeapon", defaultBuffValue)
    end

    return math.min(self.__beflyWeapon, defaultBuffValue)
end

function RegularWeapon:setBreakWeapon(value)
    self.__breakWeapon = value
end

function RegularWeapon:getBreakWeapon()
    if self.__breakWeapon == nil then
        self:setBreakWeapon(self.__typeRes.breakWeapon)
    end

    local defaultBuffValue = 1
    if self.__useCharacter then
        defaultBuffValue = self.__useCharacter:getBuffMinValue("breakWeapon", defaultBuffValue)
    end

    return math.min(self.__breakWeapon, defaultBuffValue)
end

function RegularWeapon:setBrokenWeapon(value)
    self.__brokenWeapon = value
end

function RegularWeapon:getBrokenWeapon()
    if self.__brokenWeapon == nil then
        self:setBrokenWeapon(self.__typeRes.brokenWeapon)
    end
    local defaultBuffValue = 1
    if self.__useCharacter then
        defaultBuffValue = self.__useCharacter:getBuffMinValue("brokenWeapon", defaultBuffValue)
    end

    return math.min(self.__brokenWeapon, defaultBuffValue)
end

function RegularWeapon:canFlyWeapon()
    return self:getWeaponAttr("flyWeapon") == 1
end

function RegularWeapon:canBeFlyWeapon()
    return self:getWeaponAttr("beflyWeapon") == 1
end

function RegularWeapon:canBreakWeapon()
    return self:getWeaponAttr("breakWeapon") == 1
end

function RegularWeapon:canBrokenWeapon()
    return self:getWeaponAttr("brokenWeapon") == 1
end

function RegularWeapon:getWeaponAttackSoundId()
    return self.__typeRes.soundId
end

function RegularWeapon:setBuffArray(buffArray)
    self.__buffArray = buffArray
end

--[[
    @desc: 设置buff添加器
    author:TangJian
    time:2022-03-07 16:34:20
    --@buffAdder: 
    @return:
]]
function RegularWeapon:setBuffAdderGroupIds(buffAdderGroupIds)
    self.__buffAdderGroupIds = buffAdderGroupIds
end

--[[
    @desc: 获取buff添加器列表
    author:TangJian
    time:2022-03-07 16:34:29
    @return:
]]
function RegularWeapon:getBuffAdderGroupIds()
    return Helper:getDef(self.__buffAdderGroupIds, {})
end

function RegularWeapon:getCarryBuffArray()
    if MapIsEmpty(self.__buffArray) then
        return {}
    end

    local list = {}
    for _, normalRes in ipairs(self.__buffArray) do
        --@RefType [src.app.FightSystem.FightRole.CharacterBuff.Buffs.Builder.BasicCharacterBuffBuilder#BasicCharacterBuffBuilder]
        local buffBuilder = require("app.FightSystem.FightRole.CharacterBuff.Buffs.Builder.BasicCharacterBuffBuilder"):create()

        local origin_value_4 = normalRes.addBuffdynamicArg4

        local arg4
        if origin_value_4 == nil then
            arg4 = 0
        else
            if tonumber(origin_value_4) == nil then
                arg4 = origin_value_4
            else
                arg4 = tonumber(origin_value_4)
            end
        end
        local buff =
            buffBuilder:setBuffId(normalRes.addBuffID):setCharacter(self.__character):setBuffCreator(self.__character):setFight(self.__character:getFight()):setBuffDynamicArgValue(
            "dynamicArg1",
            normalRes.addBuffdynamicArg1
        ):setBuffDynamicArgValue("dynamicArg2", normalRes.addBuffdynamicArg2):setBuffDynamicArgValue("dynamicArg3", normalRes.addBuffdynamicArg3):setBuffDynamicArgValue("dynamicArg4", arg4):build()

        table.insert(list, buff)
    end

    return list
end

function RegularWeapon:getCarryBuffAdderGroupArray()
    local idList = self:getBuffAdderGroupIds()

    if MapIsEmpty(idList) then
        return
    end

    local CharacterBuffAdderGroupFactory = require("app.FightSystem.FightRole.CharacterBuff.BuffAdders.CharacterBuffAdderGroupFactory")

    local list = {}

    for _, id in ipairs(idList) do
        table.insert(list, CharacterBuffAdderGroupFactory:getAutoBuffAdderGroup(id, self.__character, self.__character:getFight()))
    end

    return list
end

return class("RegularWeapon", {IWeapon, IArmor, ACarryBuffAddToCharacter}, RegularWeapon)
000000