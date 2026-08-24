--[[
    author:Seven
    time:2023-03-06 11:46:42
    desc: buff 资源基础类
]]
-- 加载effect数据
local Constants = require("app.FightSystem.FightBuff.Constants")

local EffectFactory = require("app.FightSystem.FightBuff.Effect.EffectFactory")

local Desc = require("app.FightSystem.FightBuff.Desc")

local class = require("third.class.NewClass")

local BasicBuff = {}

local function NewToNumber(value, default)
    local number = tonumber(value)
    if number == nil then
        return default
    end
    return number
end

function BasicBuff:create(data)
    return BasicBuff.new(data):__init()
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

function BasicBuff:__init()
    self.__stackType, self.__stackTimes = analysisStackType(self.stackType)

    do
        local getEffectUpdataNodeSwitch = {
            atkBef = Constants.EffectUpdateNodeType.BeforeAttack,
            atkAft = Constants.EffectUpdateNodeType.AfterAttack,
            default = Constants.EffectUpdateNodeType.Nil
        }
        self.effectUpdataNode = string.split(self.effectUpdataNode, "#")
        for i = 1, #self.effectUpdataNode do
            self.effectUpdataNode[i] = switch(self.effectUpdataNode[i], getEffectUpdataNodeSwitch)
        end
    end

    return self
end

--[[
    @desc: 获取堆叠类型
    author:TangJian
    time:2021-06-22 11:23:36
    @return:
]]
function BasicBuff:getStackType()
    return self.__stackType
end

--@desc: 叠加层数上限
--@author:Seven
--@time:2023-02-28 16:12:14
function BasicBuff:getStackTimes()
    return self.__stackTimes
end

function BasicBuff:getBuffLives()
    local value = tonumber(self.lives)

    if value == nil then
        return self.lives
    end

    return value
end

--@desc: 删除条件数组
--@author:Seven
--@time:2023-03-06 12:03:53
function BasicBuff:getDeleteConArray()
    if self.__deleteConArray == nil then
        self.__deleteConArray = parseTypeAndValueArray(self.deleteCon)
    end

    return self.__deleteConArray
end

function BasicBuff:getId()
    return self.id
end

function BasicBuff:getClass()
    return self.buffClass
end

function BasicBuff:getName()
    return "BasicBuff:" .. self.id
end

--@desc: 添加文本
--@author:Seven
--@time:2023-03-06 12:05:59
function BasicBuff:getAddBuffDesc()
    return Helper:getDef(self.addBuffDesc, "")
end

--@desc: 删除文本
--@author:Seven
--@time:2023-03-06 12:06:07
function BasicBuff:getDeleteBuffDesc()
    return Helper:getDef(self.deleteBuffDesc, "")
end

--@desc: 获取buff附带效果
--@author:Seven
--@time:2023-03-06 12:06:19
--@return: basicEffect 效果数组
function BasicBuff:getEffects()
    if self.__effects == nil then
        local BuffConf = require("app.FightSystem.Configuration.BuffConf")
        if self.effects == nil then
            self.effects = {}
        else
            self.__effects = BuffConf:getBasicEffectsByEffectGroupId(self.effects)
        end
    end

    return self.__effects
end

function BasicBuff:getEffectsId()
    return self.effects
end

--@desc: 效果值刷新节点(可为空)
--@author:Seven
--@time:2023-03-06 11:35:20
--@return: list
function BasicBuff:getEffectUpdataNode()
    return self.effectUpdataNode
end

--@desc: 添加成功特效，根据释放者动画中帧时间播放（只用于主动技能）可为空
--@author:Seven
--@time:2023-03-06 14:32:12
function BasicBuff:getAddBuffEffect()
    -- buff添加效果数据解析
    if self.__addBuffEffect == nil and self.addBuffEffect ~= nil then
        self.__addBuffEffect = string.split(self.addBuffEffect, "#")
    end

    return self.__addBuffEffect
end

--@desc: buff所带图标（可为空）
--@author:Seven
--@time:2023-03-06 11:36:32
--@return: 图标id
function BasicBuff:getIcon()
    return self.buffIcon
end

--@desc: 标明buff的删除类型
--@author:Seven
--@time:2023-12-04 15:55:51
function BasicBuff:getDeleteBuffCon()
    if self.__deleteBuffCons == nil then
        self.__deleteBuffCons = {}

        local array = string.split(self.deleteBuffCon, "#")

        for i = 1, #array do
            table.insert(self.__deleteBuffCons, tonumber(array[i]))
        end
    end

    return self.__deleteBuffCons
end

--@desc: 标明buff关注的生效节点
--@author:Seven
--@time:2023-12-04 15:55:18
--@return:
function BasicBuff:getTriggerBuffCons()
    --[[
        可以认为是buff触发扣除存活次数的节点。
        在Buff触发节点会先执行buff效果，如果符合条件则存活次数-1
        deleteBuffCon=1这里才有效，否则不填

        格式：触发节点#Buff持有者限制#招式组合限制

        【触发节点】buff添加后=1；buff删除前=2；任意招式组合开始=11；任意招式组合结束=12；
        被动组合开始=21；被动招式开始=22；被动招式击中=23；被动招式结束=24；被动组合结束=25；
        主动组合开始=41；主动招式开始=42；主动招式击中=43；主动招式结束=44；主动组合结束=45；
        使用恢复时（一般指动画开始前）=101；使用易武时（一般指动画开始前）=102；
        使用逃跑时（一般指动画开始前）=103；

        【Buff持有者限制】Buff持有者攻击=atk；Buff持有者受击=def；不判断Buff持有者限制=all；

        【招式组合限制】如果触发节点是被动招式：
        不限命中结果=0；
        被动组合每次招式判定都是命中=1；
        被动组合任意一次招式判定是普通招架=2；
        被动组合任意一次招式判定是轻功闪躲=3；
        被动组合任意一次招式判定是格挡招架=4；
        被动组合任意一次招式判定是轻功跳离=5
        其他情况填默认0

    ]]
    if self.__triggerBuffCons == nil then
        if self.triggerBuffCons == nil then
            self.__triggerBuffCons = {}
        else
            self.__triggerBuffCons = string.split(self.triggerBuffCons, "#")
        end
    end
    return self.__triggerBuffCons
end

function BasicBuff:getEffectClass()
    return self.buffEffectClass
end

return class("BasicBuff", {}, BasicBuff)
0000