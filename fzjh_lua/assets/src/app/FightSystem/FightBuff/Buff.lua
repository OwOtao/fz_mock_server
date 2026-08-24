-- 加载effect数据
local buffEffectDataMap = require("script.newbattle.demo.buffEffect")["Buff效果"]

local ActiveEffect = require("app.FightSystem.FightBuff.ActiveEffect")

local BuffConf = require("app.FightSystem.Configuration.BuffConf")

local Constants = require("app.FightSystem.FightBuff.Constants")

local EffectFactory = require("app.FightSystem.FightBuff.Effect.EffectFactory")

local Desc = require("app.FightSystem.FightBuff.Desc")

local class = require("third.class.NewClass")

local Buff = {}

local function NewToNumber(value, default)
    local number = tonumber(value)
    if number == nil then
        return default
    end
    return number
end

function Buff:create(data)
    local p = Buff.new(data)
    p:init()
    return p
end

local function parseTypeAndValueArray(rawString)
    local rets = {}
    if type(rawString) == "string" and #rawString > 0 then
        for _, ret in ipairs(string.split(rawString, "|")) do
            if type(ret) == "string" and #ret > 0 then
                local retType, retParam = unpack(string.split(ret, "#"))
                table.insert(rets, {tonumber(retType), NewToNumber(retParam, retParam)})
            end
        end
    end
    return rets
end

-- 叠加方式
local function analysisStackType(stackType)
    local stackType, stackTimes = unpack(string.split(stackType, "#"))
    if tonumber(stackTimes) ~= nil then
        return tonumber(stackType), tonumber(stackTimes)
    end
    return tonumber(stackType), stackTimes
end

-- 触发方式
local function analysisTrigger(triggers)
    return parseTypeAndValueArray(triggers)
end

-- 生效条件解析
local function analysisActive(active)
    return parseTypeAndValueArray(active)
end

-- 删除条件解析
local function analysisDelete(deletesString)
    return parseTypeAndValueArray(deletesString)
end

-- 解析效果
local function analysisEffects(effectsString)
    local effectIdArray = {}
    for id, effect in pairs(buffEffectDataMap) do
        if effectsString == effect.effectID then
            table.insert(effectIdArray, tostring(effect.id))
        end
    end
    return effectIdArray
end

function Buff:init()
    self.stackType, self.stackTimes = analysisStackType(self.stackType)
    self.triggers = analysisTrigger(self.trigger)
    self.actives = analysisActive(self.active)
    self.deletes = analysisDelete(self.delete)
    self.deleteConArray = parseTypeAndValueArray(self.deleteCon)

    self.effectIdArray = analysisEffects(self.effects)

    self.__effectArray =
        table.map(
        self.effectIdArray,
        function(effectId)
            return BuffConf:getEffect(effectId)
        end
    )

    self.__isRandomBaseAutoZhao = false
    for _, effect in ipairs(self.__effectArray) do
        if effect:isRandomBaseAutoZhao() then
            self.__isRandomBaseAutoZhao = true
            break
        end
    end

    -- buff添加效果数据解析
    if self.addBuffEffect ~= nil then
        self.addBuffEffect = string.split(self.addBuffEffect, "#")
    end

    do
        local getEffectUpdataNodeSwitch = 
        {
            atkBef = Constants.EffectUpdateNodeType.BeforeAttack,
            atkAft = Constants.EffectUpdateNodeType.AfterAttack,
            default = Constants.EffectUpdateNodeType.Nil
        }
        self.effectUpdataNode = string.split(self.effectUpdataNode, "#")
        for i = 1, #self.effectUpdataNode do
            self.effectUpdataNode[i] = switch(self.effectUpdataNode[i], getEffectUpdataNodeSwitch)
        end
    end
end

--[[
    @desc: 获取堆叠类型
    author:TangJian
    time:2021-06-22 11:23:36
    @return:
]]
function Buff:getStackType()
    return self.stackType
end

--@desc: 叠加层数上限
--@author:Seven
--@time:2023-02-28 16:12:14
function Buff:getStackTimes()
    return self.stackTimes
end

function Buff:getDeletes()
    return self.deletes
end

function Buff:getDeleteConArray()
    return self.deleteConArray
end

function Buff:createActiveEffects(buffNeeded)
    local activeEffectArray = {}

    for i, effect in ipairs(self.__effectArray) do
        local activeEffect = EffectFactory:create(effect, buffNeeded)
        table.insert(activeEffectArray, activeEffect)
    end

    return activeEffectArray
end

function Buff:getId()
    return self.id
end

function Buff:getClass()
    return self.buffClass
end

function Buff:getName()
    return "Buff:" .. self.id
end

function Buff:getAddText()
    return self.addBuffDesc
end

function Buff:createActiveBuff(buffNeeded)
    local ActiveBuff = require("app.FightSystem.FightBuff.ActiveBuff")
    return ActiveBuff:create(self, buffNeeded)
end

function Buff:isRandomBaseAutoZhao()
    return self.__isRandomBaseAutoZhao
end

-- 获取buff添加时动画效果数据
-- {eventName, animName}
function Buff:getAddBuffEffect()
    return self.addBuffEffect
end


function Buff:getEffectUpdataNode()
    return self.effectUpdataNode
end

function Buff:getBuffEffectClass()
    return self.buffEffectClass
end 

return class("Buff", {}, Buff)
000000000