local newClass = require("third.class.NewClass")

local FightCommons = require("app.FightSystem.FightCommons")

local ABasicCharacterFuncSystem = require("app.FightSystem.FightRole.BasicFuncSystem.ABasicCharacterFuncSystem")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local EquipmentFactory = require("app.FightSystem.Factory.EquipmentFactory.EquipmentFactory")

--@SuperType [src.app.FightSystem.FightRole.BasicFuncSystem.ABasicCharacterFuncSystem#ABasicCharacterFuncSystem]
local CharacterEquipmentSystem = {
    --@desc 空手武器
    __emptyHandWeapon = nil,
    __currWeapon = nil,
    --@desc 装备栏
    __equips = {
        [FightCommons.EQUIP_PART.WEAPON] = nil,
        [FightCommons.EQUIP_PART.HEAD] = nil,
        [FightCommons.EQUIP_PART.CLOTH] = nil,
        [FightCommons.EQUIP_PART.BELT] = nil,
        [FightCommons.EQUIP_PART.HAND] = nil,
        [FightCommons.EQUIP_PART.PANTS] = nil,
        [FightCommons.EQUIP_PART.SHOES] = nil,
        [FightCommons.EQUIP_PART.RING] = nil,
        [FightCommons.EQUIP_PART.YAOZHUI] = nil,
        [FightCommons.EQUIP_PART.NECKLACE] = nil
    },
    --@desc 备用栏
    __standbyEquips = {
        [FightCommons.EQUIP_PART.WEAPON] = nil
        -- [FightCommons.EQUIP_PART.HEAD] = nil,
        -- [FightCommons.EQUIP_PART.CLOTH] = nil,
        -- [FightCommons.EQUIP_PART.BELT] = nil,
        -- [FightCommons.EQUIP_PART.HAND] = nil,
        -- [FightCommons.EQUIP_PART.PANTS] = nil,
        -- [FightCommons.EQUIP_PART.SHOES] = nil,
        -- [FightCommons.EQUIP_PART.RING] = nil,
        -- [FightCommons.EQUIP_PART.YAOZHUI] = nil,
        -- [FightCommons.EQUIP_PART.NECKLACE] = nil
    },
    __buffIndexs = {},
    __buffAdderGroupIndexs = {}
}

function CharacterEquipmentSystem:create()
    return CharacterEquipmentSystem.new()
end

function CharacterEquipmentSystem:setEmptyHandWeapon(weapon)
    self.__emptyHandWeapon = weapon
end

--@return [src.app.FightSystem.FightRole.CharacterEquipment.IWeapon#IWeapon]
function CharacterEquipmentSystem:getWeapon()
    return self.__currWeapon
end
function CharacterEquipmentSystem:onInit()
    self:setWeapon(self:getEquipmentWeapon())
end

function CharacterEquipmentSystem:onDestory()
end

function CharacterEquipmentSystem:onUpdate(ft)
end

function CharacterEquipmentSystem:setWeapon(weapon)
    self.__currWeapon = weapon
    self.__currWeapon:setUseCharacter(self.__character)
end

function CharacterEquipmentSystem:setEquipment(equipPart, equipment)
    self.__equips[equipPart] = equipment
end

function CharacterEquipmentSystem:getEquipment(equipPart)
    if equipPart == FightCommons.EQUIP_PART.WEAPON then
        return self:getEquipmentWeapon()
    end
    return self.__equips[equipPart]
end

function CharacterEquipmentSystem:setEquipmentWeapon(weapon)
    self:setEquipment(FightCommons.EQUIP_PART.WEAPON, weapon)
end

--@desc: 当前装备栏的武器
--@author:Seven
--@time:2023-10-12 15:00:38
--@return [src.app.FightSystem.FightRole.CharacterEquipment.IWeapon#IWeapon]
function CharacterEquipmentSystem:getEquipmentWeapon()
    local weapon = self.__equips[FightCommons.EQUIP_PART.WEAPON]
    if weapon == nil then
        weapon = self.__emptyHandWeapon
    end

    return weapon
end

function CharacterEquipmentSystem:setStandbyEquipment(equipPart, equipment)
    self.__standbyEquips[equipPart] = equipment
end

function CharacterEquipmentSystem:getStandbyEquipment(equipPart)
    if equipPart == FightCommons.EQUIP_PART.WEAPON then
        return self:getStandbyWeapon()
    end
    return self.__standbyEquips[equipPart]
end

function CharacterEquipmentSystem:setStandbyWeapon(weapon)
    self:setStandbyEquipment(FightCommons.EQUIP_PART.WEAPON, weapon)
end

--@return [src.app.FightSystem.FightRole.CharacterEquipment.IWeapon#IWeapon]
function CharacterEquipmentSystem:getStandbyWeapon()
    local weapon = self.__standbyEquips[FightCommons.EQUIP_PART.WEAPON]
    if weapon == nil then
        weapon = self.__emptyHandWeapon
    end

    return weapon
end

function CharacterEquipmentSystem:weaponIsEmptyHand()
    return self:getWeapon():getFirstType() == "空手"
end

function CharacterEquipmentSystem:standbyWeaponIsEmptyHand()
    return self:getStandbyWeapon():getFirstType() == "空手"
end

--@desc: 角色装备防护力
function CharacterEquipmentSystem:getEquipTotalProtect()
    local total = 0
    for equip_part, equip in pairs(self.__equips) do
        total = total + equip:getProtect()
    end
    return total
end

--@desc 把当前使用武器置为空手
--@returnDesc 返回被卸下的武器
--@return [src.app.FightSystem.FightRole.CharacterEquipment.IWeapon#IWeapon]
function CharacterEquipmentSystem:__unmountWeapon()
    local prevWeapon = self:getWeapon()

    prevWeapon:setUseCharacter(nil)

    self:removeWeaponCarryBuff(prevWeapon)

    self:removeWeaponCarryBuffAdderGroup(prevWeapon)

    self.__currWeapon = self.__emptyHandWeapon

    return prevWeapon
end

--@desc: 使用武器
--@author:Seven
--@time:2023-03-01 15:50:38
--@weapon: [src.app.FightSystem.FightRole.CharacterEquipment.IWeapon#IWeapon]
function CharacterEquipmentSystem:useWeapon(weapon)
    if weapon == self.__currWeapon then
        return
    end
    local prevWeapon = self.__currWeapon
    self:__unmountWeapon()
    self:setWeapon(weapon)
    self:addWeaponCarryBuff(weapon)
    self:addWeaponCarryBuffAdderGroup(weapon)
    self.__character:weaponChanged(weapon, prevWeapon)
end

--@desc: 直接添加buff
--@author:Seven
--@time:2023-10-12 15:53:50
--@weapon: [src.app.FightSystem.FightRole.CharacterEquipment.IWeapon#IWeapon]
function CharacterEquipmentSystem:addWeaponCarryBuff(weapon)
    weapon:addCarryBuffToCharacter()
end

function CharacterEquipmentSystem:removeWeaponCarryBuff(weapon)
    weapon:removeCarryBuffFromCharacter()
end

--@desc: 添加buff添加器
--@author:Seven
--@time:2023-10-12 15:54:53
--@weapon: [src.app.FightSystem.FightRole.CharacterBuff.Utils.ACarryBuffAddToCharacter#ACarryBuffAddToCharacter]
function CharacterEquipmentSystem:addWeaponCarryBuffAdderGroup(weapon)
    weapon:addCarryBuffAdderToCharacter()
end

--@weapon: [src.app.FightSystem.FightRole.CharacterBuff.Utils.ACarryBuffAddToCharacter#ACarryBuffAddToCharacter]
function CharacterEquipmentSystem:removeWeaponCarryBuffAdderGroup(weapon)
    weapon:removeCarryBuffAdderFromCharacter()
end

function CharacterEquipmentSystem:getEmptyHandWeapon()
    return self.__emptyHandWeapon
end

return newClass("CharacterEquipmentSystem", {ABasicCharacterFuncSystem}, CharacterEquipmentSystem)
0000000