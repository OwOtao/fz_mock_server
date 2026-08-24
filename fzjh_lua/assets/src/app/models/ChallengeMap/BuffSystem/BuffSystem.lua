local assertIsInstance = require("third.assertIsInstance.assertIsInstance")
local IBuffSystemPresenter = require("app.models.ChallengeMap.BuffSystem.IBuffSystemPresenter")
local BuffConst = require("app.models.ChallengeMap.BuffSystem.BuffConst")
local NormalBuff = require("app.models.ChallengeMap.NormalBuff.NormalBuff")
local LogSystem = require("app.models.LogSystem.LogSystem")
local normalBuffRes = require("script.newbattle.demo.normalBuff")["总Buff表常态类"]

local oldPrint = print
local function print(...)
    LogSystem:log("常态buff系统:", ...)
end

local BuffSystem = {}

local buffDataMaps = {}
for k, v in pairs(normalBuffRes) do
    buffDataMaps[tostring(v.id)] = v
end

buffDataMaps["test1"] = {
    id = "test1",
    delete = "2#20",
    effectType = 3,
    effectParam = "def#0#100",
    addBuffDesc = "添加防御+$d的效果",
    deleteBuffDesc = "防御+$d的效果消失了"
}

function BuffSystem:create()
    local p = BuffSystem.new()
    p:init()
    return p
end

function BuffSystem:ctor()
    self.__output = nil
    self.__buffMaps = {}
    self.__percentValues = {}
    self.__constValues = {}
    self.__fightCarryBuff = {}
end

function BuffSystem:setOutput(output)
    self.__output = assertIsInstance(output, IBuffSystemPresenter)
end

--添加buff
function BuffSystem:addBuff(buffId, role)
    self:__addBuff(buffId, role)
end

--删除buff
function BuffSystem:removeBuff(buffId)
    self:__removeBuff(buffId)
end

--获取当前属性加成
function BuffSystem:getPercentAttr(attrName)
    if self.__percentValues[attrName] then
        return self.__percentValues[attrName]
    end

    return 0
end

--获取战斗属性加成
function BuffSystem:getConstAttr(attrName)
    if self.__constValues[attrName] then
        return self.__constValues[attrName]
    end

    return 0
end

--刷新buff
function BuffSystem:update()
    if MapIsEmpty(self.__buffMaps) == false then
        for buffId, buff in pairs(self.__buffMaps) do
            self:__updateBuff(buffId)
        end
    end
end

--刷新buff数值
function BuffSystem:updateRoleBuffValue(role)
    self.__constValues = {}
    self.__percentValues = {}

    if MapIsEmpty(self.__buffMaps) == false then
        for buffId, buff in pairs(self.__buffMaps) do
            local buffValueType = buff.bType
            local value = buff.buffValue
            local attr = buff.bAttrName

            if buffValueType == BuffConst.BuffEffectType.ROLE_FIGHT_ATTR_VALUE or buffValueType == BuffConst.BuffEffectType.ROLE_ATTR_VALUE then
                if self.__constValues[attr] == nil then
                    self.__constValues[attr] = 0
                end
                self.__constValues[attr] = self.__constValues[attr] + value
            elseif buffValueType == BuffConst.BuffEffectType.ROLE_FIGHT_ATTR_PERCENT_VALUE or buffValueType == BuffConst.BuffEffectType.ROLE_ATTR_PERCENT_VALUE then
                if self.__percentValues[attr] == nil then
                    self.__percentValues[attr] = 0
                end
                self.__percentValues[attr] = self.__percentValues[attr] + value
            end
        end

        print("--------------当前拥有buffs:------------")
        for kuffId, buff in pairs(self.__buffMaps) do
            print("buffId ", kuffId, "  buff添加时间： ", buff.bTime, "  buff增值： ", buff.buffValue)
        end

        print("-------常态buff 当前角色增值------------")
        for attr, value in pairs(self.__percentValues) do
            print("属性名： ", attr, " 增值： ", value)
        end

        print("-------常态buff 当前战斗角色增值------------")
        for attr, value in pairs(self.__constValues) do
            print("属性名： ", attr, " 增值： ", value)
        end
    end
end

--刷新战斗场次buff
function BuffSystem:updateFightDeleteBuffs()
    if MapIsEmpty(self.__buffMaps) == false then
        for buffId, buff in pairs(self.__buffMaps) do
            local removeBuffTypeInfo = buff:getBuffRemoveInfo()

            local fightTimes = removeBuffTypeInfo[BuffConst.NormalBuffRemoveType.FIGHT_TIMES]
            if fightTimes then
                self:__updateBuffByRemoveType(BuffConst.NormalBuffRemoveType.FIGHT_TIMES, buff, fightTimes)
            end
        end
    end
end

--刷新关联系统buff
function BuffSystem:updateSystemRelationBuffs()
    if MapIsEmpty(self.__buffMaps) == false then
        for buffId, buff in pairs(self.__buffMaps) do
        end
    end
end

--刷新持续时间buff
--isFighting 是否在战斗中
function BuffSystem:updateDurationBuffs(isFighting)
    if MapIsEmpty(self.__buffMaps) == false then
        for buffId, buff in pairs(self.__buffMaps) do
            local removeBuffTypeInfo = buff:getBuffRemoveInfo()

            local timeValue = removeBuffTypeInfo[BuffConst.NormalBuffRemoveType.DURATION]
            if timeValue and isFighting == false then
                self:__updateBuffByRemoveType(BuffConst.NormalBuffRemoveType.DURATION, buff, timeValue)
            end
        end
    end
end

--战斗中神兵buff
function BuffSystem:getFightCarryBuffs()
    local buffArray = {}

    for k, buff in pairs(self.__fightCarryBuff) do
        table.insert(buffArray, buff)
    end

    return buffArray
end

function BuffSystem:recordFistFootBuff(buffId)
    if not self.__FistFootBuffs then
        self.__FistFootBuffs = {}
    end

    self.__FistFootBuffs[buffId] = true
end

function BuffSystem:removeFistFootBuffs()
    if MapIsEmpty(self.__FistFootBuffs) == false then
        for buffId, v in pairs(self.__FistFootBuffs) do
            self:__removeBuff(buffId)
        end

        self.__FistFootBuffs = nil
    end
end

--@desc:
--@author:Seven
--@time:2026-01-07 17:02:12
--@buff: [src.app.models.ChallengeMap.NormalBuff.NormalBuff#NormalBuff]
function BuffSystem:__addFightCarryBuff(buff)
    local carry_buff_info = buff:getFightBuffParamsArray()
    local buffId = carry_buff_info[1]

    if buffId == 0 then
        return
    end

    self.__fightCarryBuff[buffId] = carry_buff_info
    print("添加战斗携带buff，战斗中buffId:", buffId)
end

function BuffSystem:__removeFightCarryBuff(buff)
    local carry_buff_info = buff:getFightBuffParamsArray()

    if carry_buff_info[1] == 0 then
        return
    end

    if self.__fightCarryBuff[carry_buff_info[1]] then
        self.__fightCarryBuff[carry_buff_info[1]] = nil
    end
end

--添加buff
function BuffSystem:__addBuff(buffId, role)
    buffId = tostring(buffId)

    local buffData = buffDataMaps[buffId]
    if MapIsEmpty(buffData) then
        assert(false, "常态buff不存在，buffid:" .. tostring(buffId))
    end

    local buff = NormalBuff:create(buffData)
    local btype, value, attrName = self:__getBuffAddValues(buff, role)
    local desc = buff:getAddBuffDesc()

    buff.bTime = GetTime() --持续时间
    buff.bCount = 0 --生效次数
    buff.buffValue = value --buff增值
    buff.bAttrName = attrName --属性名
    buff.bType = btype --buff添加类型

    if desc then
        desc = string.gsub(desc, "$d", math.abs(buff.buffValue))
        self.__output:showAddBuff(desc)
    end

    self.__buffMaps[buffId] = buff
    self:__addFightCarryBuff(buff)
end

--删除buff
function BuffSystem:__removeBuff(buffId)
    buffId = tostring(buffId)

    if not self.__buffMaps[buffId] then
        return
    end

    local buff = self.__buffMaps[buffId]
    local desc = buff:getDeleteBuffDesc()

    if desc then
        desc = string.gsub(desc, "$d", math.abs(buff.buffValue))
        self.__output:showRemoveBuff(desc)
    end

    self:__removeFightCarryBuff(buff)
    self.__buffMaps[buffId] = nil
end

--根据id刷新buff
function BuffSystem:__updateBuff(buffId)
    buffId = tostring(buffId)

    local buff = self.__buffMaps[buffId]

    local removeBuffTypeInfo = buff:getBuffRemoveInfo()

    for removeType, value in pairs(removeBuffTypeInfo) do
        self:__updateBuffByRemoveType(removeType, buff, value)
    end
end

function BuffSystem:__updateBuffByRemoveType(removeType, buff, value)
    if removeType == BuffConst.NormalBuffRemoveType.FIGHT_TIMES then
        buff.bCount = buff.bCount + 1

        if buff.bCount >= value then
            self:__removeBuff(buff.id)
        end
    elseif removeType == BuffConst.NormalBuffRemoveType.DURATION then
        if GetTime() - buff.bTime > value then
            self:__removeBuff(buff.id)
        end
    elseif removeType == BuffConst.NormalBuffRemoveType.SYSTEM then
    --关联系统对应节点手动删除
    end
end

function BuffSystem:__getBuffAddValues(buff, role)
    local ChallengeMapCharacterRoleInfoBuilder = require("app.models.ChallengeMap.ChallengeMapCharacterProxy.ChallengeMapCharacterRoleInfoBuilder")

    if buff:getBuffEffectType() == BuffConst.BuffEffectType.NONE_VALUE then
        return BuffConst.BuffEffectType.NONE_VALUE, 0, nil
    end

    local buffValueType, attr, value = buff:getBuffEffectValues(ChallengeMapCharacterRoleInfoBuilder:create(role):buildCharacter())

    if not value then
        value = 0
    end

    return buffValueType, value, attr
end

return class("BuffSystem", {}, BuffSystem)
00000000000000